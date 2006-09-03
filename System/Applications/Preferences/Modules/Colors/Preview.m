#include "Preview.h"

@implementation Preview

- (void) setColors: (NSMutableDictionary *) col
{
	[col retain];
	[colors release];
	colors = col;
}

- (void) drawTextfield: (NSRect) border : (NSRect) clip
{
	NSRectEdge up_sides[] = {NSMaxYEdge, NSMaxXEdge, NSMinYEdge, NSMinXEdge,
	                         NSMaxYEdge, NSMaxXEdge, NSMinYEdge, NSMinXEdge};
	NSRectEdge dn_sides[] = {NSMinYEdge, NSMaxXEdge, NSMaxYEdge, NSMinXEdge,
	                         NSMinYEdge, NSMaxXEdge, NSMaxYEdge, NSMinXEdge};

	// These names are role names not the actual colours
	NSColor *black = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"controlDarkShadowColor"]];
	NSColor *dark = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"controlShadowColor"]];
	NSColor *light = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"controlColor"]];
	NSColor *white = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"controlLightHighlightColor"]];
	NSColor *bgd = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"textBackgroundColor"]];
	NSColor *colrs[] = {dark, white, white, dark,
	                    black, light, light, black};
	NSRect frame;

	if ([[NSView focusView] isFlipped] == YES) {
		frame = NSDrawColorTiledRects(border, clip, dn_sides, colrs, 8);
	} else {
		frame = NSDrawColorTiledRects(border, clip, up_sides, colrs, 8);
    }

	[bgd set];
	NSRectFill (frame);
} 

- (void) drawButton: (NSRect) border : (NSRect) clip
{
	NSRectEdge up_sides[] = {NSMaxXEdge, NSMinYEdge, NSMinXEdge,
	                         NSMaxYEdge, NSMaxXEdge, NSMinYEdge};
	NSRectEdge dn_sides[] = {NSMaxXEdge, NSMaxYEdge, NSMinXEdge,
	                         NSMinYEdge, NSMaxXEdge, NSMaxYEdge};

	NSColor *black = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"controlDarkShadowColor"]];
	NSColor *dark = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"controlShadowColor"]];
	NSColor *white = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"controlLightHighlightColor"]];
	NSColor *bgd = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"controlBackgroundColor"]];
	NSColor *colrs[] = {black, black, white, white, dark, dark};
	NSRect frame;

	if ([[NSView focusView] isFlipped] == YES) {
		frame = NSDrawColorTiledRects(border, clip, dn_sides, colrs, 6);
	} else {
		frame = NSDrawColorTiledRects(border, clip, up_sides, colrs, 6);
	}

	[bgd set];
	NSRectFill (frame);
}

- (void) drawSlider: (NSRect)border : (NSRect)clip
{
	NSColor *black = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"controlShadowColor"]];
	NSColor *bgd = [NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"scrollBarColor"]];

	NSRect frame =  NSInsetRect (border, 2, 2);

	[black set];
	NSFrameRect (border);

	[bgd set];
	NSRectFill (frame);
}

- (void) drawRect: (NSRect)rect
{
	NSRect  slider = NSMakeRect (rect.origin.x, rect.origin.y,
	                             22, rect.size.height);
	NSRect  text = NSMakeRect (rect.origin.x + 30, rect.origin.y + 40,
	                           rect.size.width - 38, 24);
	NSRect  button = NSMakeRect ((rect.origin.x + rect.size.width) - (64+8), 8,
	                             64, 24);

	[[NSColor colorWithRGBStringRepresentation: [colors objectForKey: @"windowBackgroundColor"]] set];

	NSRectFill (rect);

	[self drawTextfield: text : rect];
	[self drawSlider: slider : rect];
	[self drawButton: button : rect];
}

@end
