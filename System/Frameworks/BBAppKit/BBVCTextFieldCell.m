#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <AppKit/NSAttributedString.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSGraphics.h>
#include <AppKit/NSStringDrawing.h>

#include <BBAppKit/BBVCTextFieldCell.h>

@implementation BBVCTextFieldCell

/**
	This is ugly.

	What we do here is clone all of the attributes we know about from a "donor"
	cell, so that we can replace it later. It would probably be better to use
	coding or something, but this is working so far.
*/
- (id) initWithTextFieldCell: (NSTextFieldCell *)aCell
{
	self = [super initTextCell: [aCell stringValue]];

	[self setAction: [aCell action]];
	[self setAlignment: [aCell alignment]];
	[self setAllowsEditingTextAttributes: [aCell allowsEditingTextAttributes]];
	[self setAllowsMixedState: [aCell allowsMixedState]];
	[self setAllowsUndo: [aCell allowsUndo]];
	[self setBackgroundColor: [aCell backgroundColor]];
//	[self setBackgroundStyle: [aCell backgroundStyle]];
	[self setBaseWritingDirection: [aCell baseWritingDirection]];
	[self setBezeled: [aCell isBezeled]];
	[self setBezelStyle: [aCell bezelStyle]];
	[self setBordered: [aCell isBordered]];
	[self setContinuous: [aCell isContinuous]];
	[self setDrawsBackground: [aCell drawsBackground]];
	[self setEditable: [aCell isEditable]];
	[self setEnabled: [aCell isEnabled]];
	[self setImportsGraphics: [aCell importsGraphics]];
	[self setLineBreakMode: [aCell lineBreakMode]];
	[self setMenu: [aCell menu]];
//	[self setPlaceholder: [aCell placeholder]];
	[self setRefusesFirstResponder: [aCell refusesFirstResponder]];
	[self setRepresentedObject: [aCell representedObject]];
	[self setScrollable: [aCell isScrollable]];
	[self setShowsFirstResponder: [aCell showsFirstResponder]];
	[self setTag: [aCell tag]];
	[self setTarget: [aCell target]];
	[self setTextColor: [aCell textColor]];
//	[self setUserInterfaceLayoutDirection: [aCell userInterfaceLayoutDirection]];
//	[self setUsesSingleLineMode: [aCell usesSingleLineMode]];
	[self setWraps: [aCell wraps]];
	[self setState: [aCell state]];

	return self;
}

- (void) drawInteriorWithFrame: (NSRect)cellFrame inView: (NSView *)controlView
{
	NSAttributedString  *str = [self attributedStringValue];

	if ([self drawsBackground]) {
		if ([self isEnabled]) {
			[[self backgroundColor] set];
		} else {
			[[NSColor controlBackgroundColor] set];
		}
		NSRectFill(cellFrame);
	}

	if ([self isHighlighted]) {
		NSMutableAttributedString  *colorString = [str mutableCopy];
		[colorString addAttribute: NSForegroundColorAttributeName
		                    value: [NSColor controlHighlightColor]
		                    range: NSMakeRange (0, [colorString length])];
		ASSIGN(str, colorString);
	}

	[str drawWithRect: [self titleRectForBounds: cellFrame]
	          options: NSStringDrawingUsesLineFragmentOrigin];
}

- (NSRect) titleRectForBounds: (NSRect)theRect
{
	NSRect  titleFrame = [super titleRectForBounds: theRect];

	NSAttributedString  *str = [self attributedStringValue];
	NSRect              textRect;

	textRect = [str boundingRectWithSize: titleFrame.size
	                             options: NSStringDrawingUsesLineFragmentOrigin];

	if (textRect.size.height < titleFrame.size.height) {
		titleFrame.origin.y = theRect.origin.y + (theRect.size.height - textRect.size.height) / 2.0;
		titleFrame.size.height = textRect.size.height;
	}
	return titleFrame;
}

@end
