#include "Colors.h"

#include <AppKit/NSPopUpButton.h>

static id <PrefsController>	controller;
static NSBundle			*bundle = nil;
static Colors			*sharedInstance = nil;
static id <PrefsApplication>	owner = nil;
NSUserDefaults			*defaults = nil;

static NSArray *
colorPopUpNames (void)
{
	static NSArray *names = nil;
	
	if (!names)
		names = [NSArray arrayWithObjects:
			@"3D Light Highlight",
			@"3D Highlight",
			@"3D Light Shadow",
			@"3D Dark Shadow",
			@"Control Backing",
			@"Control Text",
			@"Editable Text",
			@"Editable Text Backing",
			@"Disabled Control Text",
			@"Focus Indicator",
			@"Scroller Backing",
			@"Scroller Handle",
			@"Selected Control Backing",
			@"Selected Control Text",
			@"Selected Menu Item",
			@"Selected Menu Item Text",
			@"Selected Scroller Handle",
			@"Selected Text",
			@"Selected Text Backing",
			@"Table Grid",
			@"Table Header Backing",
			@"Table Header Text",
			@"Window Backing",
			@"Window Frame",
			@"Window Frame Text",
			nil];

	return names;
}

@implementation Colors 

- (void) dealloc
{
	[schemeList release];
	[currentScheme release];
}

- (void) initUI
{
	if (![NSBundle loadNibNamed: @"Color" owner: self]) {
		NSLog (@"Colors: Could not load nib \"Color\", aborting.");
		[self dealloc];
		return;
	}
	
	if (!view) {
		view = [[window contentView] retain];
		[view removeFromSuperview];
		[window setContentView: NULL];
	}
	[window release];
	window = nil;

	schemeList = [[self colorSchemes] retain];

	[self loadColorWells];

	[schemeBrowser setDoubleAction: @selector(updateSystemColors:)];
	[schemeBrowser setAcceptsArrowKeys: YES];
	[schemeBrowser setSendsActionOnArrowKeys: YES];

	[colorSelectionPopUp removeAllItems];
	[colorSelectionPopUp addItemsWithTitles: colorPopUpNames()];
	[colorSelectionPopUp selectItemAtIndex: 0];
}

- (id) initWithOwner: (id <PrefsApplication>)anOwner
{
	if (sharedInstance) {
		[self dealloc];
	} else {
		self = [super init];
		owner = anOwner;
		controller = [owner prefsController];
		defaults = [NSUserDefaults standardUserDefaults];
		bundle = [NSBundle bundleForClass: [self class]];

		[controller registerPrefsModule: self];

		currentScheme = nil;
		sharedInstance = self;
	}
	return sharedInstance;
}

- (void) showView: (id)sender;
{
	if (!view)
		[self initUI];

	[controller setCurrentModule: self];
	[view setNeedsDisplay: YES];
}

- (NSView *) view
{
	return view;
}

- (NSString *) buttonCaption
{
	return NSLocalizedStringFromTableInBundle (@"Color Preferences", @"Localizable", bundle, @"");
}

- (NSImage *) buttonImage
{
	return [NSImage imageNamed: @"PrefsIcon_Appearances"];
}

- (SEL) buttonAction
{
	return @selector (showView:);
}

/*
	updates the colors dictionary based on the percents value of the sliders
*/

- (void) updateEditWindow
{
}

@end	
