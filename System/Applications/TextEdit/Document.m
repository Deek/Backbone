/*
		Document.m
		Copyright (c) 1995-1996, NeXT Software, Inc.
		All rights reserved.
		Author: Ali Ozer

		You may freely copy, distribute and reuse the code in this example.
		NeXT disclaims any warranty of any kind, expressed or implied,
		as to its fitness for any particular use.

		Document object for Edit...
*/

#include <math.h>
#include <float.h>
#include <stdio.h>								// for NULL

#import <AppKit/AppKit.h>

#import "Document.h"
#import "MultiplePageView.h"
#import "TextFinder.h"
#import "Preferences.h"

@implementation Document

- (void)setupInitialTextViewSharedState {
	NSTextView *textView = [self firstTextView];
	
	[textView setUsesFontPanel:YES];
	[textView setDelegate:self];
	[self setRichText:[[Preferences objectForKey:RichText] boolValue]];
	[self setHyphenationFactor:0.0];
}

- (id)init {
	static NSPoint cascadePoint = {0.0, 0.0};
	NSLayoutManager *layoutManager;
	NSZone *zone = [self zone];
		
	self = [super init];
	textStorage = [[NSTextStorage allocWithZone:zone] init];

	if (![NSBundle loadNibNamed:@"Document" owner:self])  {
		NSLog(@"Failed to load Document.nib");
		[self release];
		return nil;
	}

	layoutManager = [[NSLayoutManager allocWithZone:zone] init];
	[textStorage addLayoutManager:layoutManager];
	[layoutManager setDelegate:self];
	[layoutManager release];

	encodingIfPlainText = [[Preferences objectForKey:PlainTextEncoding] intValue];

	[self setPrintInfo:[NSPrintInfo sharedPrintInfo]];
	[[self printInfo] setHorizontalPagination:NSFitPagination];
	[[self printInfo] setHorizontallyCentered:NO];
	[[self printInfo] setVerticallyCentered:NO];
		
	// This gives us our first view
	[self setHasMultiplePages:[[Preferences objectForKey:ShowPageBreaks] boolValue]];

	// This ensures the first view gets set up correctly
	[self setupInitialTextViewSharedState];

	if (NSEqualPoints(cascadePoint, NSZeroPoint)) {		/* First time through... */
		NSRect frame = [[self window] frame];
		cascadePoint = NSMakePoint(frame.origin.x, NSMaxY(frame));
	}
	cascadePoint = [[self window] cascadeTopLeftFromPoint:cascadePoint];
	[[self window] setDelegate:self];

	// Set the window size from defaults...
	if ([self hasMultiplePages]) {
		[self setViewSize:[[scrollView documentView] pageRectForPageNumber:0].size];
	} else {
		int 	windowHeight = [[Preferences objectForKey:WindowHeight] intValue];
		int 	windowWidth = [[Preferences objectForKey:WindowWidth] intValue];
		NSFont	*font = [Preferences objectForKey:[self isRichText] ? RichTextFont : PlainTextFont];
		NSSize	size;
#ifdef GNUSTEP
		NSFont	*screenFont = [font screenFont];
		NSGlyph nGlyph;

		if (screenFont)
			font = screenFont;

		if ([font respondsToSelector: @selector(glyphForCharacter:)])
			nGlyph = (NSGlyph) [font glyphForCharacter: 'n'];
		else
			nGlyph = 'n';

		if ([font glyphIsEncoded: nGlyph]) {	/* Better to use n-width than the maximum, for rich text fonts... */
			size.width = [font advancementForGlyph: nGlyph].width;
#else
		if ([font glyphIsEncoded: 'n']) {	/* Better to use n-width than the maximum, for rich text fonts... */
			size.width = [font advancementForGlyph: nGlyph].width;
#endif
		} else {
			size.width = [font maximumAdvancement].width;
		}

		size.width	= ceil(size.width * windowWidth + [[[self firstTextView] textContainer] lineFragmentPadding] * 2.0);
		size.height = ceil([font boundingRectForFont].size.height) * windowHeight;
		[self setViewSize:size];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixUpScrollViewBackgroundColor:)
		name:NSSystemColorsDidChangeNotification object:nil];

	potentialSaveDirectory = nil;
	return self;
}

- (id)initWithPath:(NSString *)filename encoding:(int)encoding uniqueZone:(BOOL)flag {
	if (!(self = [self init])) {
		if (flag) NSRecycleZone([self zone]);
		return nil;
	}
	uniqueZone = flag;	/* So if something goes wrong we can recycle the zone correctly in dealloc */
	if (filename && ![self loadFromPath:filename encoding:encoding]) {
		[self release];
		return nil;
	}
	if (filename) {
		[Document setLastOpenSavePanelDirectory:[filename stringByDeletingLastPathComponent]];
	}
	[[self firstTextView] setSelectedRange:NSMakeRange(0, 0)];
	[self setDocumentName:filename];
	return self;
}

+ (BOOL)openUntitled {
	NSZone *zone = NSCreateZone(NSPageSize(), NSPageSize(), YES);
	Document *document = [[self allocWithZone:zone] initWithPath:nil encoding:UnknownStringEncoding uniqueZone:YES];
	if (document) {
		[document setPotentialSaveDirectory:[Document openSavePanelDirectory]];
		[document setDocumentName:nil];
		[[document window] makeKeyAndOrderFront:nil];
		return YES;
	} else {
		return NO;
	}
}

+ (BOOL)openDocumentWithPath:(NSString *)filename encoding:(int)encoding {
	Document *document = [self documentForPath:filename];
	if (!document) {
		NSZone *zone = NSCreateZone(NSPageSize(), NSPageSize(), YES);
		document =	[[self allocWithZone:zone] initWithPath:filename encoding:encoding uniqueZone:YES];
	}
	if (document) {
		[document doForegroundLayoutToCharacterIndex:[[Preferences objectForKey:ForegroundLayoutToIndex] intValue]];
		[[document window] makeKeyAndOrderFront:nil];
		return YES;
	} else {
		return NO;
	}
}

/* Clear the delegates of the text views and window, then release all resources and go away...
*/
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSSystemColorsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextStorageDidProcessEditingNotification object:[self textStorage]];
	[[self firstTextView] setDelegate:nil];
	[[self window] setDelegate:nil];
	[documentName release];
	[textStorage release];
	[printInfo release];
	if (uniqueZone) {
		NSRecycleZone([self zone]);
	}
	[super dealloc];
}

- (NSTextView *)firstTextView {
	return [[self layoutManager] firstTextView];
}

- (NSSize)viewSize {
	return [scrollView contentSize];
}

- (void)setViewSize:(NSSize)size {
	NSWindow *window = [scrollView window];
	NSRect origWindowFrame = [window frame];
	NSSize scrollViewSize = [NSScrollView frameSizeForContentSize:size hasHorizontalScroller:[scrollView hasHorizontalScroller] hasVerticalScroller:[scrollView hasVerticalScroller] borderType:[scrollView borderType]];
	[window setContentSize:scrollViewSize];
	[window setFrameTopLeftPoint:NSMakePoint(origWindowFrame.origin.x, NSMaxY(origWindowFrame))];
}

/* This method causes the text to be laid out in the foreground (approximately) up to the indicated character index.
*/
- (void)doForegroundLayoutToCharacterIndex:(unsigned)loc {
	unsigned len;
	if (loc > 0 && (len = [[self textStorage] length]) > 0) {
		NSRange glyphRange;
		if (loc >= len) loc = len - 1;
		/* Find out which glyph index the desired character index corresponds to */
		glyphRange = [[self layoutManager] glyphRangeForCharacterRange:NSMakeRange(loc, 1) actualCharacterRange:NULL];
		if (glyphRange.location > 0) {
			/* Now cause layout by asking a question which has to determine where the glyph is */
			(void)[[self layoutManager] textContainerForGlyphAtIndex:glyphRange.location - 1 effectiveRange:NULL];
		}
	}
}

+ (NSString *)cleanedUpPath:(NSString *)filename {
	NSString *resolvedSymlinks = [filename stringByResolvingSymlinksInPath];
	if ([resolvedSymlinks length] > 0) {
		NSString *standardized = [resolvedSymlinks stringByStandardizingPath];
		return [standardized length] ? standardized : resolvedSymlinks;
	}
	return filename;
}

- (void)setDocumentName:(NSString *)filename {
	[documentName autorelease];
	if (filename) {
		documentName = [[filename stringByResolvingSymlinksInPath] copyWithZone:[self zone]];
		[[self window] setTitleWithRepresentedFilename:documentName];
		if (uniqueZone) NSSetZoneName([self zone], documentName);
	} else {
		NSString *untitled = NSLocalizedString(@"UNTITLED", @"Name of new, untitled document");
		if ([self isRichText]) untitled = [untitled stringByAppendingPathExtension:@"rtf"];
		if (potentialSaveDirectory) {
			[[self window] setTitleWithRepresentedFilename:[potentialSaveDirectory stringByAppendingPathComponent:untitled]];
		} else {
			[[self window] setTitle:untitled];
		}
		if (uniqueZone) NSSetZoneName([self zone], untitled);
		documentName = nil;
	}
}

- (NSString *)documentName {
	return documentName;
}

- (void)setPotentialSaveDirectory:(NSString *)nm {
	if (! [[Preferences objectForKey:OpenPanelFollowsMainWindow] boolValue]) return;
	[potentialSaveDirectory autorelease];
	potentialSaveDirectory = [nm copy];
}

- (NSString *)potentialSaveDirectory {
	if (! [[Preferences objectForKey:OpenPanelFollowsMainWindow] boolValue]) {
		return NSHomeDirectory();
	}
	return potentialSaveDirectory;
}

- (void)setDocumentEdited:(BOOL)flag {
	if (flag != isDocumentEdited) {
		isDocumentEdited = flag;
		[[self window] setDocumentEdited:isDocumentEdited];
	}
}

- (BOOL)isDocumentEdited {
	return isDocumentEdited;
}

- (NSTextStorage *)textStorage {
	return textStorage;
}

- (NSWindow *)window {
	return [[self firstTextView] window];
}

- (NSLayoutManager *)layoutManager {
	return [[textStorage layoutManagers] objectAtIndex:0];
}

- (void)setPrintInfo:(NSPrintInfo *)anObject {
	if (printInfo == anObject || [[printInfo dictionary] isEqual:[anObject dictionary]]) return;

	[printInfo autorelease];
	printInfo = [anObject copyWithZone:[self zone]];

	if ([self hasMultiplePages]) {
		unsigned cnt, numberOfPages = [self numberOfPages];
		MultiplePageView *pagesView = [scrollView documentView];
		NSArray *textContainers = [[self layoutManager] textContainers];

		[pagesView setPrintInfo:printInfo];
		
		for (cnt = 0; cnt < numberOfPages; cnt++) {
			NSRect textFrame = [pagesView documentRectForPageNumber:cnt];
			NSTextContainer *textContainer = [textContainers objectAtIndex:cnt];
			[textContainer setContainerSize:textFrame.size];
			[[textContainer textView] setFrame:textFrame];
		}
	}
}

- (NSPrintInfo *)printInfo {
	return printInfo;
}

/* Multiple page related code */

- (unsigned)numberOfPages {
	if (hasMultiplePages) {
		return [[scrollView documentView] numberOfPages];
	} else {
		return 1;
	}
}

- (BOOL)hasMultiplePages {
	return hasMultiplePages;
}

- (void)addPage {
	NSZone *zone = [self zone];
	unsigned numberOfPages = [self numberOfPages];
	MultiplePageView *pagesView = [scrollView documentView];
	NSSize textSize = [pagesView documentSizeInPage];
	NSTextContainer *textContainer = [[NSTextContainer allocWithZone:zone] initWithContainerSize:textSize];
	NSTextView *textView;
	[pagesView setNumberOfPages:numberOfPages + 1];
	textView = [[NSTextView allocWithZone:zone] initWithFrame:[pagesView documentRectForPageNumber:numberOfPages] textContainer:textContainer];
	[textView setHorizontallyResizable:NO];
	[textView setVerticallyResizable:NO];
	[pagesView addSubview:textView];
	[[self layoutManager] addTextContainer:textContainer];
	[textView release];
	[textContainer release];
}

- (void)removePage {
	unsigned numberOfPages = [self numberOfPages];
	NSArray *textContainers = [[self layoutManager] textContainers];
	NSTextContainer *lastContainer = [textContainers objectAtIndex:[textContainers count] - 1];
	MultiplePageView *pagesView = [scrollView documentView];
	[pagesView setNumberOfPages:numberOfPages - 1];
	[[lastContainer textView] removeFromSuperview];
	[[lastContainer layoutManager] removeTextContainerAtIndex:[textContainers count] - 1];
}

/* This method determines whether the document has multiple pages or not. It can be called at anytime.
*/	 
- (void)setHasMultiplePages:(BOOL)flag {
	NSZone *zone = [self zone];

	hasMultiplePages = flag;

	if (hasMultiplePages) {
		NSTextView *textView = [self firstTextView];
		MultiplePageView *pagesView = [[MultiplePageView allocWithZone:zone] init];

		[scrollView setDocumentView:pagesView];

		[pagesView setPrintInfo:[self printInfo]];
		// MF: Add the first new page before we remove the old container so we can avoid losing all the shared text view state.
		[self addPage];
		if (textView) {
			[[self layoutManager] removeTextContainerAtIndex:0];
		}
		[scrollView setHasHorizontalScroller:YES];

	} else {
		NSSize size = [scrollView contentSize];
		NSTextContainer *textContainer = [[NSTextContainer allocWithZone:zone] initWithContainerSize:NSMakeSize(size.width, FLT_MAX)];
		NSTextView *textView = [[NSTextView allocWithZone:zone] initWithFrame:NSMakeRect(0.0, 0.0, size.width, size.height) textContainer:textContainer];

		// Insert the single container as the first container in the layout manager before removing the existing pages in order to preserve the shared view state.
		[[self layoutManager] insertTextContainer:textContainer atIndex:0];

		if ([[scrollView documentView] isKindOfClass:[MultiplePageView class]]) {
			NSArray *textContainers = [[self layoutManager] textContainers];
			unsigned cnt = [textContainers count];
			while (cnt-- > 1) {
				[[self layoutManager] removeTextContainerAtIndex:cnt];
			}
		}

		[textContainer setWidthTracksTextView:YES];
		[textContainer setHeightTracksTextView:NO];				/* Not really necessary */
		[textView setHorizontallyResizable:NO];					/* Not really necessary */
		[textView setVerticallyResizable:YES];
		[textView setAutoresizingMask:NSViewWidthSizable];
#ifndef GNUSTEP
		[textView setMinSize:size];		/* Not really necessary; will be adjusted by the autoresizing... */
#else
		[textView setMinSize:NSMakeSize(0,0)];
#endif
		[textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];		/* Will be adjusted by the autoresizing... */  

		/* The next line should cause the multiple page view and everything else to go away */
		[scrollView setDocumentView:textView];
		[scrollView setHasHorizontalScroller:NO];
		
		[textView release];
		[textContainer release];
	}
	[[scrollView window] makeFirstResponder:[self firstTextView]];
}

/* This method is called at startup and in response to a colors changed notification to fix up the color displayed in the background area of the scrollview (actually clipview) when in "wrap to page" mode.

   The reason we need to get fancy here is to assure that the color on Windows is a blend of black and the "3D Objects" color (which is what some Windows apps do). If the color was a regular system color, registering for the notification would not be necessary.
*/
- (void)fixUpScrollViewBackgroundColor:(NSNotification *)notification {
	NSColor *backgroundColor;
	if (NSInterfaceStyleForKey(NSInterfaceStyleDefault, scrollView) == NSWindows95InterfaceStyle) {
		backgroundColor = [[NSColor controlColor] blendedColorWithFraction:0.5 ofColor:[NSColor blackColor]];
		if (backgroundColor == nil) backgroundColor = [NSColor controlColor];
	} else {
		backgroundColor = [NSColor controlColor];
	}
	[[scrollView contentView] setBackgroundColor:backgroundColor]; 
}

/* Outlet methods */

- (void)setScrollView:(id)anObject {
	scrollView = anObject;
	[scrollView setHasVerticalScroller:YES];
	[scrollView setHasHorizontalScroller:NO];
	[[scrollView contentView] setAutoresizesSubviews:YES];
	[self fixUpScrollViewBackgroundColor:nil];
	if (NSInterfaceStyleForKey(NSInterfaceStyleDefault, scrollView) == NSWindows95InterfaceStyle) {
		[scrollView setBorderType:NSBezelBorder];
	}		 
}
		
static NSPopUpButton *encodingPopupButton = nil;
static NSView *encodingAccessory = nil;

+ (void)loadEncodingPopupButton:(NSPopUpButton *)anObject {
}

+ (void)setEncodingPopupButton:(id)anObject {			/* Outlet method... */
	encodingPopupButton = [anObject retain];
	[self loadEncodingPopupButton:encodingPopupButton];
}

+ (void)setEncodingAccessory:(id)anObject {		/* Outlet method... */
	encodingAccessory = [anObject retain];
}

/* Use this method to get the accessory. It reinitailizes the popup, selects the specified item, and also includes or deletes the first entry (corresponding to "Default")
*/
+ (NSView *)encodingAccessory:(int)encoding includeDefaultEntry:(BOOL)includeDefaultItem {
	if (!encodingAccessory) {
		if (![NSBundle loadNibNamed:@"EncodingAccessory" owner:self])  {
			NSLog(@"Failed to load EncodingAccessory.nib");
		}
	}
	SetUpEncodingPopupButton(encodingPopupButton, encoding, includeDefaultItem);
	return encodingAccessory;
}

- (void)removeAttachments {
	NSTextStorage *attrString = [self textStorage];
	unsigned loc = 0;
	unsigned end = [attrString length];
	[attrString beginEditing];
	while (loc < end) { /* Run through the string in terms of attachment runs */
		NSRange attachmentRange;		/* Attachment attribute run */
		NSTextAttachment *attachment = [attrString attribute:NSAttachmentAttributeName atIndex:loc longestEffectiveRange:&attachmentRange inRange:NSMakeRange(loc, end-loc)];
		if (attachment) {		/* If there is an attachment, make sure it is valid */
			unichar ch = [[attrString string] characterAtIndex:loc];
			if (ch == NSAttachmentCharacter) {
				[attrString replaceCharactersInRange:NSMakeRange(loc, 1) withString:@""];
				end = [attrString length];		/* New length */
			} else {
				loc++;	/* Just skip over the current character... */
			}
		}		 else {
			loc = NSMaxRange(attachmentRange);
		}
	}
	[attrString endEditing];
}

/* The hyphenation methods are added to NSLayoutManager in OPENSTEP 4.2. Given that we'd like the app to keep on running against earlier versions of OPENSTEP, we make all hyphenation-related calls check to see if they are implemented.
*/
static BOOL hyphenationSupported(void) {
	return [NSLayoutManager instancesRespondToSelector:@selector(setHyphenationFactor:)];
}

- (void)setHyphenationFactor:(float)factor {
	if (hyphenationSupported()) [[self layoutManager] setHyphenationFactor:factor];
}

- (float)hyphenationFactor {
	return hyphenationSupported() ? [[self layoutManager] hyphenationFactor] : 0.0;
}

/* ??? Doesn't check to see if the prev value is the same! (Otherwise the first time doesn't work...)
*/
- (void)setRichText:(BOOL)flag {
	NSTextView *view = [self firstTextView];
	NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] initWithCapacity:2];

	isRichText = flag;

	if (isRichText) {
		[textAttributes setObject:[Preferences objectForKey:RichTextFont] forKey:NSFontAttributeName];
		[textAttributes setObject:[NSParagraphStyle defaultParagraphStyle] forKey:NSParagraphStyleAttributeName];

		// Make sure we aren't watching the DidProcessEditing notification since we don't adjust tab stops in rich text.
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextStorageDidProcessEditingNotification object:[self textStorage]];
	} else {
		[textAttributes setObject:[Preferences objectForKey:PlainTextFont] forKey:NSFontAttributeName];
		[textAttributes setObject:[NSParagraphStyle defaultParagraphStyle] forKey:NSParagraphStyleAttributeName];
		[self removeAttachments];
		
		// Register for DidProcessEditing to fix the tabstops.
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:[self textStorage]];
	}
	
	[view setRichText:isRichText];
	[view setUsesRuler:isRichText];		/* If NO, this correctly gets rid of the ruler if it was up */
	[view setImportsGraphics:isRichText];

	if ([textStorage length]) {
		[textStorage setAttributes:textAttributes range: NSMakeRange(0, [textStorage length])];
	}
	[view setTypingAttributes:textAttributes];
	[textAttributes release];
}

- (BOOL)isRichText {
	return isRichText;
}

/* User commands... */

- (void)printDocumentUsingPrintPanel:(BOOL)uiFlag {
	NSPrintOperation *op;

	op = [NSPrintOperation printOperationWithView:[scrollView documentView] printInfo:printInfo];
	[op setShowPanels:uiFlag];
	[op runOperation];
}

- (void)printDocument:(id)sender {
	[self printDocumentUsingPrintPanel:YES];
}

- (void)toggleRich:(id)sender {
	if (isRichText && ([textStorage length] > 0)) {
		int choice = NSRunAlertPanel(NSLocalizedString(@"Make Plain Text", @"Title of alert confirming Make Plain Text"), 
						NSLocalizedString(@"Convert document to plain text? This will lose fonts, colors, and other text attribute settings.", @"Message confirming Make Plain Text"), 
						NSLocalizedString(@"OK", @"OK."), NSLocalizedString(@"Cancel", @"Button choice allowing user to cancel."), nil);
		if (choice != NSAlertDefaultReturn) return;
	}
	[self setRichText:!isRichText];
	[self setDocumentEdited:YES];
	[self setDocumentName:nil];
}

- (void)togglePageBreaks:(id)sender {
	[self setHasMultiplePages:![self hasMultiplePages]];
}

- (void)toggleHyphenation:(id)sender {
	[self setHyphenationFactor:([self hyphenationFactor] > 0.0) ? 0.0 : 0.9];	/* Toggle between 0.0 and 0.9 */
	if ([self isRichText]) {
		[self setDocumentEdited:YES];
	}
}

- (void)runPageLayout:(id)sender {
	NSPrintInfo *tempPrintInfo = [[self printInfo] copy];
	NSPageLayout *pageLayout = [NSPageLayout pageLayout];
	int runResult;
	runResult = [pageLayout runModalWithPrintInfo:tempPrintInfo];
	if (runResult == NSOKButton) {
		[self setPrintInfo:tempPrintInfo];
	}
	[tempPrintInfo release];
}

- (void)revert:(id)sender {
	if (documentName) {
		NSString *fileName = [documentName lastPathComponent];
		int choice = NSRunAlertPanel(NSLocalizedString(@"Revert", @"Title of alert confirming revert"), 
								NSLocalizedString(@"Revert to saved version of %@?", @"Message confirming revert of specified document name."), 
								NSLocalizedString(@"OK", @"OK."), NSLocalizedString(@"Cancel", @"Button choice allowing user to cancel."), nil, fileName);
		if (choice == NSAlertDefaultReturn) {
			if (![self loadFromPath:documentName encoding:encodingIfPlainText]) {
				(void)NSRunAlertPanel(NSLocalizedString(@"Couldn't Revert", @"Title of alert indicating file couldn't be reverted"), 
								NSLocalizedString(@"Couldn't revert to saved version of %@.", @"Message indicating file couldn't be reverted."), 
								NSLocalizedString(@"OK", @"OK."), nil, nil, documentName);
			} else {
				[self setDocumentEdited:NO];
			}
		}
	}
}

- (void)close:(id)sender {
	[[self window] close];
}

/* Not correct! */
- (void)saveTo:(id)sender {
	[self saveAs:sender];
}

- (void)saveAs:(id)sender {
	(void)[self saveDocument:YES];
}

- (void)save:(id)sender {
	(void)[self saveDocument:NO];
}

+ (void)openWithEncodingAccessory:(BOOL)flag {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	if (flag) {
		[panel setAccessoryView:[self encodingAccessory:[[Preferences objectForKey:PlainTextEncoding] intValue] includeDefaultEntry:YES]];
	}
	[panel setAllowsMultipleSelection:YES];
	[panel setDirectory:[Document openSavePanelDirectory]];
	if ([panel runModal]) {
		NSArray *filenames = [panel filenames];
		unsigned cnt, numFiles = [filenames count];
		for (cnt = 0; cnt < numFiles; cnt++) {
			NSString *filename = [filenames objectAtIndex:cnt];
			if (![Document openDocumentWithPath:filename encoding:flag ? [[encodingPopupButton selectedItem] tag] : UnknownStringEncoding]) {
				NSString *alternate = (cnt + 1 == numFiles) ? nil : NSLocalizedString(@"Abort", @"Button allowing user to abort opening multiple files after one couldn't be opened");
				unsigned choice = NSRunAlertPanel(NSLocalizedString(@"File system error", @"Title of alert indicating file couldn't be opened"), 
								NSLocalizedString(@"Couldn't open file %@.", @"Message indicating file couldn't be opened."), 
								NSLocalizedString(@"OK", @"OK"), alternate, nil, filename);
				if (choice == NSCancelButton) break;
			}
		}
	}
}

+ (void)open:(id)sender {
	[self openWithEncodingAccessory:YES];
}

/* Find submenu commands */

- (void)orderFrontFindPanel:(id)sender {
	[[TextFinder sharedInstance] orderFrontFindPanel:sender];
}

- (void)findNext:(id)sender {
	[[TextFinder sharedInstance] findNext:sender];
}

- (void)findPrevious:(id)sender {
	[[TextFinder sharedInstance] findPrevious:sender];
}

- (void)enterSelection:(id)sender {
	NSRange range = [[self firstTextView] selectedRange];
	if (range.length) {
		[[TextFinder sharedInstance] setFindString:[[textStorage string] substringWithRange:range]];
	} else {
		NSBeep();
	}
}

- (void)jumpToSelection:(id)sender {
	NSTextView *textView = [self firstTextView];
	[textView scrollRangeToVisible:[textView selectedRange]];
}



/* Returns YES if the document can be closed. If the document is edited, gives the user a chance to save. Returns NO if the user cancels.
*/
- (BOOL)canCloseDocument {
	if (isDocumentEdited) {
		int result = NSRunAlertPanel(
						NSLocalizedString(@"Close", @"Title of alert panel which comes when the user tries to quit or close a window containing an unsaved document."),
						NSLocalizedString(@"Document has been edited. Save?", @"Question asked of user when he/she tries to close a window containing an unsaved document."),
						NSLocalizedString(@"Save", @"Button choice which allows the user to save the document."),
						NSLocalizedString(@"Don't Save", @"Button choice which allows the user to abort the save of a document which is being closed."),
						NSLocalizedString(@"Cancel", @"Button choice allowing user to cancel."));
		if (result == NSAlertDefaultReturn) {	/* Save */
			if (![self saveDocument:NO]) return NO;
		} else if (result == NSAlertOtherReturn) {		/* Cancel */
			return NO;
		}		/* Don't save case falls through to the YES return */
	}
	return YES;
}

/* Saves the document. Puts up save panel if necessary or if showSavePanel is YES. Returns NO if the user cancels the save...
*/
- (BOOL)saveDocument:(BOOL)showSavePanel {
	NSString *nameForSaving = [self documentName];
	int encodingForSaving;
	BOOL haveToChangeType = NO;
	BOOL showEncodingAccessory = NO;
		
	if ([self isRichText]) {
		if (nameForSaving && [@"rtfd" isEqualToString:[nameForSaving pathExtension]]) {
			encodingForSaving = RichTextWithGraphicsStringEncoding;
		} else {
			encodingForSaving = [textStorage containsAttachments] ? RichTextWithGraphicsStringEncoding : RichTextStringEncoding;
			if ((encodingForSaving == RichTextWithGraphicsStringEncoding) && nameForSaving && [@"rtf" isEqualToString:[nameForSaving pathExtension]]) {
				nameForSaving = nil;	/* Force the user to provide a new name... */
			}
		}
	} else {
		NSString *string = [textStorage string];
		showEncodingAccessory = YES;
		encodingForSaving = encodingIfPlainText;
		if ((encodingForSaving != UnknownStringEncoding) && ![string canBeConvertedToEncoding:encodingForSaving]) {
			haveToChangeType = YES;
			encodingForSaving = UnknownStringEncoding;
		}
		if (encodingForSaving == UnknownStringEncoding) {
			NSStringEncoding defaultEncoding = [[Preferences objectForKey:PlainTextEncoding] intValue];
			if ([string canBeConvertedToEncoding:defaultEncoding]) {
				encodingForSaving = defaultEncoding;
			} else {
				const int *plainTextEncoding = SupportedEncodings();
				while (*plainTextEncoding != -1) {
					if ((*plainTextEncoding >= 0) && (*plainTextEncoding != defaultEncoding) && (*plainTextEncoding != NSUnicodeStringEncoding) && (*plainTextEncoding != NSUTF8StringEncoding) && [string canBeConvertedToEncoding:*plainTextEncoding]) {
						encodingForSaving = *plainTextEncoding;
						break;
					}
					plainTextEncoding++;
				}
			}
			if (encodingForSaving == UnknownStringEncoding) encodingForSaving = NSUnicodeStringEncoding;
			if (haveToChangeType) {
				(void)NSRunAlertPanel(NSLocalizedString(@"Save Plain Text", @"Title of save and alert panels when saving plain text"), 
						NSLocalizedString(@"Document can no longer be saved using its original %@ encoding. Please choose another encoding (%@ is one possibility).", @"Contents of alert panel informing user that the file's string encoding needs to be changed"), 
						NSLocalizedString(@"OK", @"OK."), nil, nil, [NSString localizedNameOfStringEncoding:encodingIfPlainText], [NSString localizedNameOfStringEncoding:encodingForSaving]);
			}
		}
	}

	while (1) {
		if (!nameForSaving || haveToChangeType || showSavePanel) {
			if (![self getDocumentName:&nameForSaving encoding:(haveToChangeType || showEncodingAccessory) ? &encodingForSaving : NULL oldName:nameForSaving oldEncoding:encodingForSaving]) return NO; /* Cancelled */
		}
		/* The value of updateFileNames: below will have to become conditional on whether we're doing Save To at some point.  Also, we'll want to avoid doing the stuff inside the if if we're doing Save To. */
		if ([self saveToPath:nameForSaving encoding:encodingForSaving updateFilenames:YES]) {
			if (![self isRichText]) encodingIfPlainText = encodingForSaving;
			[self setDocumentName:nameForSaving];
			[self setDocumentEdited:NO];
			[Document setLastOpenSavePanelDirectory:[nameForSaving stringByDeletingLastPathComponent]];
			return YES;
		} else {
			NSRunAlertPanel(@"Couldn't Save",
				NSLocalizedString(@"Couldn't save document as %@.", @"Message indicating document couldn't be saved under the given name."),
				NSLocalizedString(@"OK", @"OK."), nil, nil, nameForSaving);
			nameForSaving = nil;
		}
	}
	return YES;
}

/* Puts up a save panel to get a final name from the user. If the user cancels, returns NO. If encoding is non-NULL, puts up the encoding accessory.
*/
- (BOOL)getDocumentName:(NSString **)newName encoding:(int *)encodingForSaving oldName:(NSString *)oldName oldEncoding:(int)encoding {
	NSSavePanel *panel = [NSSavePanel savePanel];
	switch (encoding) {
		case RichTextStringEncoding:
			[panel setRequiredFileType:@"rtf"];
			[panel setTitle:NSLocalizedString(@"Save RTF", @"Title of save and alert panels when saving RTF")];
			encodingForSaving = NULL;
			break;
		case RichTextWithGraphicsStringEncoding:
			[panel setRequiredFileType:@"rtfd"];
			[panel setTitle:NSLocalizedString(@"Save RTFD", @"Title of save and alert panels when saving RTFD")];
			encodingForSaving = NULL;
			break;
		default:
			[panel setTitle:NSLocalizedString(@"Save Plain Text", @"Title of save and alert panels when saving plain text")];
			if (encodingForSaving) {
				unsigned cnt;
				[panel setAccessoryView:[[self class] encodingAccessory:*encodingForSaving includeDefaultEntry:NO]];
				for (cnt = 0; cnt < [encodingPopupButton numberOfItems]; cnt++) {
					int encoding = [[encodingPopupButton itemAtIndex:cnt] tag];
					if ((encoding != UnknownStringEncoding) && ![[textStorage string] canBeConvertedToEncoding:encoding]) {
						[[encodingPopupButton itemAtIndex:cnt] setEnabled:NO];
					}
				}
			}
			break;
	}
	if (potentialSaveDirectory) {
		[Document setLastOpenSavePanelDirectory:potentialSaveDirectory];
	}
	if (oldName ? [panel runModalForDirectory:[oldName stringByDeletingLastPathComponent] file:[oldName lastPathComponent]] : [panel runModalForDirectory:[Document openSavePanelDirectory] file:@""]) {
		*newName = [panel filename];
		if (potentialSaveDirectory) {
			[self setPotentialSaveDirectory:nil];
		}
		if (encodingForSaving) *encodingForSaving = [[encodingPopupButton selectedItem] tag];
		return YES;
	} else {
		return NO;
	}
}

/* Window delegation messages */

- (BOOL)windowShouldClose:(id)sender {
	return [self canCloseDocument];
}

- (void)windowWillClose:(NSNotification *)notification {
	NSWindow *window = [self window];
	[window setDelegate:nil];
	[self release];
}

/* Text view delegation messages */

- (void)textDidChange:(NSNotification *)textObject {
	if (!isDocumentEdited) {
		[self setDocumentEdited:YES];
	}
}

- (void)textView:(NSTextView *)view doubleClickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)rect {
	BOOL success = NO;
	NSString *name = [[[cell attachment] fileWrapper] filename];
	if (name && documentName && ![name isEqualToString:@""] && ![documentName isEqualToString:@""]) {
		NSString *fullPath = [documentName stringByAppendingPathComponent:name];
		success = [[NSWorkspace sharedWorkspace] openFile:fullPath];
	}
	if (!success) {
		NSBeep();
	}
}

- (void)textView:(NSTextView *)view draggedCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)rect event:(NSEvent *)event {
	BOOL success = NO;
	NSString *name = [[[cell attachment] fileWrapper] filename];
	if (name && documentName && ![name isEqualToString:@""] && ![documentName isEqualToString:@""]) {
		NSString *fullPath = [documentName stringByAppendingPathComponent:name];
		NSImage *image = nil;
		if ([cell isKindOfClass:[NSCell class]]) image = [(NSCell *)cell image];		/* Cheezy; should really draw the cell into an image... */
		if (!image) image = [[NSWorkspace sharedWorkspace] iconForFile:fullPath];
		if (image) {
			NSSize cellSizeInBaseCoords = [view convertSize:rect.size toView:nil];
			NSSize imageSize = [image size];
			NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
			[pasteboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
			[pasteboard setPropertyList:[NSArray arrayWithObject:fullPath] forType:NSFilenamesPboardType];
			if (!NSEqualSizes(cellSizeInBaseCoords, imageSize)) {
				NSPoint mouseDownLocation = [view convertPoint:[event locationInWindow] fromView:nil];
				rect.origin.x = mouseDownLocation.x - (imageSize.width - floor(imageSize.width / 4.0));
				rect.origin.y = mouseDownLocation.y - (imageSize.height - floor(imageSize.height / 4.0));
			} else {
				// We need to pass the image origin which means we need to unflip the rect we're getting.
				rect.origin.y += rect.size.height;
			}
			[view dragImage:image at:rect.origin offset:NSZeroSize event:event pasteboard:pasteboard source:self slideBack:YES];
			success = YES;
		}
	}
	if (!success) {
		NSBeep();
	}
}

- (unsigned)draggingSourceOperationMaskForLocal:(BOOL)flag {
	return NSDragOperationGeneric | NSDragOperationCopy;
}

/*** Layout manager delegation message ***/

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag {

	if ([self hasMultiplePages]) {
		NSArray *containers = [layoutManager textContainers];

		if (!layoutFinishedFlag || (textContainer == nil)) {
			// Either layout is not finished or it is but there are glyphs laid nowhere.
			NSTextContainer *lastContainer = [containers lastObject];

			if ((textContainer == lastContainer) || (textContainer == nil)) {
				// Add a new page only if the newly full container is the last container or the nowhere container.
				[self addPage];
			}
		} else {
			// Layout is done and it all fit.  See if we can axe some pages.
			unsigned lastUsedContainerIndex = [containers indexOfObjectIdenticalTo:textContainer];
			unsigned numContainers = [containers count];
			while (++lastUsedContainerIndex < numContainers) {
				[self removePage];
			}
		}
	}
}

/*** Text storage notification message ***/

static NSArray *tabStopArrayForFontAndTabWidth(NSFont *font, unsigned tabWidth) {
	static NSMutableArray *array = nil;
	static float currentWidthOfTab = -1;
	float charWidth;
	float widthOfTab;
	unsigned i;

	if ([font glyphIsEncoded:(NSGlyph)' ']) {
		charWidth = [font advancementForGlyph:(NSGlyph)' '].width;
	} else {
		charWidth = [font maximumAdvancement].width;
	}
	widthOfTab = (charWidth * tabWidth);

	if (!array) {
		array = [[NSMutableArray allocWithZone:NULL] initWithCapacity:100];
	}

	if (widthOfTab != currentWidthOfTab) {
		//NSLog(@"Calculating tabstops for font %@, tabWidth %u, real width %f.", font, tabWidth, widthOfTab);
		[array removeAllObjects];
		for (i = 1; i <= 100; i++) {
			NSTextTab *tab = [[NSTextTab alloc] initWithType:NSLeftTabStopType location:widthOfTab * i];
			[array addObject:tab];
			[tab release];
		}
		currentWidthOfTab = widthOfTab;
	}

	return array;
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification {
	NSTextStorage *theTextStorage = [notification object];
	NSString *string = [theTextStorage string];

	if ([string length] > 0) {
		// Generally NSTextStorage's attached to plain text NSTextViews only have one font.	 But this is not generally true.  To ensure the tabstops are uniform throughout the document we always base them on the font of the first character in the NSTextStorage.
		NSFont *font = [theTextStorage attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];

		// Substitute a screen font is the layout manager will do so for display.
		// MF: printing will probably be an issue here...
		font = [[self layoutManager] substituteFontForFont:font];
		if ([font isFixedPitch]) {
			unsigned tabWidth = [[Preferences objectForKey:TabWidth] intValue];
			NSArray *desiredTabStops = tabStopArrayForFontAndTabWidth(font, tabWidth);
			NSRange editedRange = [theTextStorage editedRange];
			NSRange eRange;
			NSParagraphStyle *paraStyle;
			NSMutableParagraphStyle *newStyle;

			editedRange = [string lineRangeForRange:editedRange];

			// We will traverse the edited range by paragraphs fixing the paragraph styles
			while (editedRange.length > 0) {
				paraStyle = [theTextStorage attribute:NSParagraphStyleAttributeName atIndex:editedRange.location longestEffectiveRange:&eRange inRange:editedRange];
				if (!paraStyle) {
					paraStyle = [NSParagraphStyle defaultParagraphStyle];
				}
				eRange = NSIntersectionRange(editedRange, eRange);
				if (![[paraStyle tabStops] isEqual:desiredTabStops]) {
					// Make sure we don't change stuff outside editedRange.
					newStyle = [paraStyle mutableCopyWithZone:[theTextStorage zone]];
					[newStyle setTabStops:desiredTabStops];
					[theTextStorage addAttribute:NSParagraphStyleAttributeName value:newStyle range:eRange];
					[newStyle release];
				}
				if (NSMaxRange(eRange) < NSMaxRange(editedRange)) {
					editedRange.length = NSMaxRange(editedRange) - NSMaxRange(eRange);
					editedRange.location = NSMaxRange(eRange);
				} else {
					editedRange = NSMakeRange(NSMaxRange(editedRange), 0);
				}
			}
		}
	}
}

/* Return the document in the specified window.
*/
+ (Document *)documentForWindow:(NSWindow *)window {
	id delegate = [window delegate];
	return (delegate && [delegate isKindOfClass:[Document class]]) ? delegate : nil;
}

/* Return an existing document...
*/
+ (Document *)documentForPath:(NSString *)filename {
	NSArray *windows = [[NSApplication sharedApplication] windows];
	unsigned cnt, numWindows = [windows count];
	filename = [self cleanedUpPath:filename];	/* Clean up the incoming path */
	for (cnt = 0; cnt < numWindows; cnt++) {
		Document *document = [Document documentForWindow:[windows objectAtIndex:cnt]];
		NSString *docName = [document documentName];	
		if (docName && [filename isEqual:[self cleanedUpPath:docName]]) return document;
	}
	return nil;
}

+ (unsigned)numberOfOpenDocuments {
	NSArray *windows = [[NSApplication sharedApplication] windows];
	unsigned cnt, numWindows = [windows count], numDocuments = 0;
	for (cnt = 0; cnt < numWindows; cnt++) {
		if ([Document documentForWindow:[windows objectAtIndex:cnt]]) numDocuments++;
	}
	return numDocuments;
}

/* Menu validation: Arbitrary numbers to determine the state of the menu items whose titles change. Speeds up the validation... Not zero. */   
#define TagForFirst 42
#define TagForSecond 43

static void validateToggleItem(NSMenuItem *aCell, BOOL useFirst, NSString *first, NSString *second) {
	if (useFirst) {
		if ([aCell tag] != TagForFirst) {
			[aCell setTitleWithMnemonic:first];
			[aCell setTag:TagForFirst];
#ifdef GNUSTEP
			[[aCell menu] sizeToFit];
#else
			[((NSMenu *)[[(NSCell *)aCell controlView] window]) sizeToFit];
#endif
		}
	} else {
		if ([aCell tag] != TagForSecond) {
			[aCell setTitleWithMnemonic:second];
			[aCell setTag:TagForSecond];
#ifdef GNUSTEP
			[[aCell menu] sizeToFit];
#else
			[((NSMenu *)[[(NSCell *)aCell controlView] window]) sizeToFit];
#endif
		}
	}
}

/* Menu validation
*/
- (BOOL)validateMenuItem:(NSMenuItem *)aCell {
	SEL action = [aCell action];
#ifdef GNUSTEP
	const char *sel_name = sel_get_name(action);

	if (!strcmp(sel_name, sel_get_name(@selector(toggleRich:)))) {
		validateToggleItem(aCell, [self isRichText], NSLocalizedString(@"&Make Plain Text", @"Menu item to make the current document plain text"), NSLocalizedString(@"&Make Rich Text", @"Menu item to make the current document rich text"));
	} else if (!strcmp(sel_name, sel_get_name(@selector(togglePageBreaks:)))) {
		validateToggleItem(aCell, [self hasMultiplePages], NSLocalizedString(@"&Wrap to Window", @"Menu item to cause text to be laid out to size of the window"), NSLocalizedString(@"&Wrap to Page", @"Menu item to cause text to be laid out to the size of the currently selected page type"));
	} else if (!strcmp(sel_name, sel_get_name(@selector(toggleHyphenation:)))) {
		if (!hyphenationSupported()) return NO;	/* Disable it... */
		validateToggleItem(aCell, ([self hyphenationFactor] > 0.0), NSLocalizedString(@"Disallow &Hyphenation", @"Menu item to disallow hyphenation in the document"), NSLocalizedString(@"Allow &Hyphenation", @"Menu item to allow hyphenation in the document"));
	}
#else
	if (action == @selector(toggleRich:)) {
		validateToggleItem(aCell, [self isRichText], NSLocalizedString(@"&Make Plain Text", @"Menu item to make the current document plain text"), NSLocalizedString(@"&Make Rich Text", @"Menu item to make the current document rich text"));
	} else if (action == @selector(togglePageBreaks:)) {
		validateToggleItem(aCell, [self hasMultiplePages], NSLocalizedString(@"&Wrap to Window", @"Menu item to cause text to be laid out to size of the window"), NSLocalizedString(@"&Wrap to Page", @"Menu item to cause text to be laid out to the size of the currently selected page type"));
	} else if (action == @selector(toggleHyphenation:)) {
		if (!hyphenationSupported()) return NO; /* Disable it... */
		validateToggleItem(aCell, ([self hyphenationFactor] > 0.0), NSLocalizedString(@"Disallow &Hyphenation", @"Menu item to disallow hyphenation in the document"), NSLocalizedString(@"Allow &Hyphenation", @"Menu item to allow hyphenation in the document"));
	}
#endif
	return YES;
}

static NSString *lastOpenSavePanelDir = nil;

/* Sets the directory in which a save was last done...
*/
+ (void)setLastOpenSavePanelDirectory:(NSString *)dir {
	if (lastOpenSavePanelDir != dir) {
		[lastOpenSavePanelDir autorelease];
		lastOpenSavePanelDir = [dir copy];
	}
}

/* Returns the directory in which open/save panels should come up...
*/
+ (NSString *)openSavePanelDirectory {
	if ([[Preferences objectForKey:OpenPanelFollowsMainWindow] boolValue]) {
		Document *doc = [Document documentForWindow:[NSApp mainWindow]];
		if (doc && [doc documentName]) {
			return [[doc documentName] stringByDeletingLastPathComponent];
		} else if (doc && lastOpenSavePanelDir) {
			return lastOpenSavePanelDir;
		}
	} else if (lastOpenSavePanelDir) {
		return lastOpenSavePanelDir;
	}
	return NSHomeDirectory();
}

@end

/* Get list of supported encodings from the file Encodings.txt (containing comma-separated ints). If the file doesn't exist, a default, built-in list is used.
*/
const int *SupportedEncodings(void) {
	static const int *encodings = NULL;
	static const int plainTextFileStringEncodingsSupported[] = {
		NSNEXTSTEPStringEncoding, NSISOLatin1StringEncoding, NSWindowsCP1252StringEncoding, NSISOLatin2StringEncoding, NSJapaneseEUCStringEncoding, NSUTF8StringEncoding, NSUnicodeStringEncoding, -1
	};
	if (!encodings) {
		NSString *str = [[NSBundle mainBundle] pathForResource:@"Encodings" ofType:@"txt"];
		if (str && (str = [[NSString alloc] initWithContentsOfFile:str])) {
			unsigned numEncodings = 0;
			int encoding;
			NSScanner *scanner = [NSScanner scannerWithString:str];
			[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@" ,\t"]];
			while ([scanner scanInt:&encoding]) if ([NSString localizedNameOfStringEncoding:encoding]) numEncodings++;
			if (numEncodings) {
				int *tmp = NSZoneMalloc(NULL, (numEncodings + 1) * sizeof(int));
				encodings = tmp;
				[scanner setScanLocation:0];
				while ([scanner scanInt:tmp]) if ([NSString localizedNameOfStringEncoding:*tmp]) tmp++;
				*tmp = -1;
			}
			[str release];
		}
		if (!encodings) encodings = plainTextFileStringEncodingsSupported;		/* Default value... */
	}
	return encodings;
}

void SetUpEncodingPopupButton(NSPopUpButton *popup, int selectedEncoding, BOOL includeDefaultItem) {
	BOOL defaultItemIsIncluded = NO;
	unsigned cnt = [popup numberOfItems];
	if (cnt <= 1) {		/* Seems like the popup hasn't been initialized yet... */
		const int *enc = SupportedEncodings();
		[popup removeAllItems];
		while (*enc != -1) {
			[popup addItemWithTitle:[NSString localizedNameOfStringEncoding:*enc]];
			[[popup lastItem] setTag:*enc];
			enc++;
		}
	} else {	/* Check to see if the default item is in there... */
		while (!defaultItemIsIncluded && cnt-- > 0) {
			NSButtonCell *item = [popup itemAtIndex:cnt];
			if ([item tag] == UnknownStringEncoding) defaultItemIsIncluded = YES;
		}
	}
	if (includeDefaultItem && !defaultItemIsIncluded) {
		[popup insertItemWithTitle:NSLocalizedString(@"Default", @"Encoding popup entry indicating default encoding") atIndex:0];
		[[popup itemAtIndex:0] setTag:UnknownStringEncoding];
	} else if (!includeDefaultItem && defaultItemIsIncluded) {
		[popup removeItemAtIndex:0];
	}
	defaultItemIsIncluded = includeDefaultItem;
	cnt = [popup numberOfItems];
	while (cnt-- > 0) {
		NSButtonCell *item = [popup itemAtIndex:cnt];
		[item setEnabled:YES];
		if ([item tag] == selectedEncoding) [popup selectItemAtIndex:cnt];
	}
}

/*

 1/28/95 aozer	Created for Edit II.
 2/16/95 aozer	Added multiple page support.
 3/28/95 mferris Removed some old code and fixed firstTextView method to just call layout manager instead of doing it itself.
 4/11/95 aozer	Paper size read/write support
 8/16/95 aozer	Added plain text tabs (but they're semi broken)
 10/4/95 aozer	Combined open/save and open/save with encoding panels
  3/3/96 aozer	Got rid of page layout accessory
				Switched over to public RTF/attributed string API
 4/19/96 aozer	Foreground layout
				Create each document in its own zone
 8/29/96 rick	Added potentialSaveDirectory for untitled docs, to follow the main window at
				time the untitled doc is created
 11/7/96 aozer	Hyphenation support

*/
