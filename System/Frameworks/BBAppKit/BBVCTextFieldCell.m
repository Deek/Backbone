#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <AppKit/NSAttributedString.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSGraphics.h>
#include <AppKit/NSStringDrawing.h>

#include <BBAppKit/BBVCTextFieldCell.h>

@implementation BBVCTextFieldCell

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
