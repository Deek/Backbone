#include "Preview.h"

@implementation Preview

- (void) setColors: (NSMutableDictionary*) col
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
  NSColor *dark = [NSColor colorFromString: [colors objectForKey: @"controlShadowColor"]];
  NSColor *light = [NSColor colorFromString: [colors objectForKey: @"controlColor"]];
  NSColor *white = [NSColor colorFromString: [colors objectForKey: @"controlLightHighlightColor"]];
  NSColor *bgd = [NSColor colorFromString: [colors objectForKey: @"textBackgroundColor"]];
  NSColor *colrs[] = {dark, white, white, dark,
                       dark, light, light, dark};
  NSRect frame;

  if ([[NSView focusView] isFlipped] == YES)
    {
      frame = NSDrawColorTiledRects(border, clip, dn_sides, colrs, 8);
    }
  else
    {
      frame = NSDrawColorTiledRects(border, clip, up_sides, colrs, 8);
    }
   [bgd set];
   NSRectFill (frame);
} 

- (void) drawButton: (NSRect) border : (NSRect) clip
{
  NSRectEdge up_sides[] = {NSMaxXEdge, NSMinYEdge, 
			   NSMinXEdge, NSMaxYEdge, 
			   NSMaxXEdge, NSMinYEdge};
  NSRectEdge dn_sides[] = {NSMaxXEdge, NSMaxYEdge, 
			   NSMinXEdge, NSMinYEdge, 
			   NSMaxXEdge, NSMaxYEdge};
  NSColor *black = [NSColor colorFromString: [colors objectForKey: @"controlDarkShadowColor"]];
  NSColor *dark = [NSColor colorFromString: [colors objectForKey: @"controlShadowColor"]];
  NSColor *white = [NSColor colorFromString: [colors objectForKey: @"controlLightHighlightColor"]];
  NSColor *bgd = [NSColor colorFromString: [colors objectForKey: @"controlBackgroundColor"]];
  NSColor *colrs[] = {black, black, white, white,
		       dark, dark};
  NSRect frame;

  if ([[NSView focusView] isFlipped] == YES)
    {
      frame = NSDrawColorTiledRects(border, clip, dn_sides, colrs, 6);
    }
  else
    {
      frame = NSDrawColorTiledRects(border, clip, up_sides, colrs, 6);
    }
   [bgd set];
   NSRectFill (frame);
}

- (void) drawSlider: (NSRect) border : (NSRect) clip
{
        NSColor *black = [NSColor colorFromString: [colors objectForKey: @"controlShadowColor"]];
	NSColor *bgd = [NSColor colorFromString: [colors objectForKey: @"scrollBarColor"]];
	NSRect frame =  NSInsetRect(border, 2, 2);
	[black set];
	NSFrameRect (border);
	[bgd set];
        NSRectFill (frame);
}

- (void) drawRect: (NSRect) rect
{
  [[NSColor colorFromString: [colors objectForKey: @"windowBackgroundColor"]] set];
  NSRectFill (rect);

  [self drawButton: NSMakeRect (30, 30, 40, 20) : rect];
  [self drawTextfield: NSMakeRect (80, 30, 70, 20) : rect];
  [self drawSlider: NSMakeRect (rect.origin.x, rect.origin.y, 20, rect.size.height) : rect];
}

@end
