#include "Colors.h"

@implementation Colors (Utilities)

- (NSMutableDictionary*) defaultColors
{
  float NSBlack = 0;
  float NSDarkGray = 0.333;
  float NSGray = 0.5;
  float NSLightGray = 0.667;
  float NSWhite = 1;

  NSString* white = [NSString stringWithFormat: @"%f %f %f",
		    NSWhite, NSWhite, NSWhite];
  NSString* lightGray = [NSString stringWithFormat: @"%f %f %f",
			NSLightGray, NSLightGray, NSLightGray];
  NSString* gray = [NSString stringWithFormat: @"%f %f %f",
		   NSGray, NSGray, NSGray];
  NSString* darkGray = [NSString stringWithFormat: @"%f %f %f",
		       NSDarkGray, NSDarkGray, NSDarkGray];
  NSString* black = [NSString stringWithFormat: @"%f %f %f",
		    NSBlack, NSBlack, NSBlack];

  NSMutableDictionary* colorStrings = [[NSMutableDictionary alloc]
		     initWithObjectsAndKeys:
		     @"System Colors (dark)", @"name",
		     lightGray, @"base",
		     lightGray, @"controlBackgroundColor",
		     lightGray, @"controlColor",
		     lightGray, @"controlHighlightColor",
		     white, @"controlLightHighlightColor",
		     darkGray, @"controlShadowColor",
		     black, @"controlDarkShadowColor",
		     black, @"controlTextColor",
		     darkGray, @"disabledControlTextColor",
		     gray, @"gridColor",
		     lightGray, @"headerColor",
		     black, @"headerTextColor",
		     white, @"highlightColor",
		     black, @"keyboardFocusIndicatorColor",
		     lightGray, @"knobColor",
		     gray, @"scrollBarColor",
		     white, @"selectedControlColor",
		     black, @"selectedControlTextColor",
		     lightGray, @"selectedKnobColor",
		     white, @"selectedMenuItemColor",
		     black, @"selectedMenuItemTextColor",
		     lightGray, @"selectedTextBackgroundColor",
		     black, @"selectedTextColor",
		     black, @"shadowColor",
		     white, @"textBackgroundColor",
		     black, @"textColor",
		     lightGray, @"windowBackgroundColor",
		     black, @"windowFrameColor",
		     white, @"windowFrameTextColor",
		     nil];

	return [colorStrings autorelease];
}

- (void) setColorList: (NSMutableDictionary*) clist
{
	NSColorList* systemColors = [NSColorList colorListNamed: @"System"];
	if (systemColors == nil)
	{
		systemColors = [[NSColorList alloc] initWithName: @"System"];
	}

	{
	  NSEnumerator *e;
	  NSString *r;
	  BOOL changed = NO;

	  // Set up default system colors

	  e = [clist keyEnumerator];
	
	  while ((r = (NSString *)[e nextObject])) 
	    {
	      NSString *cs;
	      NSColor *c;

	      if ([systemColors colorWithKey: r])
	      {
	      //  continue;

	      cs = [clist objectForKey: r];
	      c = [NSColor colorFromString: cs];

	      //NSCAssert1(c, @"couldn't get default system color %@", r);
		if (c) [systemColors setColor: c forKey: r];

	      changed = YES;
              }
	    }

	  if (changed)
	    [systemColors writeToFile: nil];
	}
}

- (float) checkFloat: (float) c 
{
	if (c < 0) return 0;
	if (c > 1) return 1;
	return c;
}

- (NSColor*) createColorFromRed: (float) r Green: (float) g Blue: (float) b Percent: (float) p
{
	float R = [self checkFloat: r+(r*p)];
	float G = [self checkFloat: g+(g*p)];
	float B = [self checkFloat: b+(b*p)];
	return [NSColor colorWithCalibratedRed: R green: G blue: B alpha: 1.0];
}

- (void) setColor: (NSColorWell*) colorWell withName: (NSString*) colorName
{
	// NSLog (@"colorspacename : %@", [[backgroundColorWell color] colorSpaceName]);
	NSColor* c = [[colorWell color] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace"];
	if (c != nil)
	{
		[currentScheme setObject: [NSString stringWithFormat: @"%f %f %f",
			    [c redComponent], [c greenComponent], [c blueComponent]] forKey: colorName];
	}
}

- (void) setCheckbox: (NSButton*) checkbox withName: (NSString*) name
{
	if ([checkbox state] == NSOnState) 
	{
		[currentScheme setObject: @"YES" forKey: name];
	}
	else
	{
		[currentScheme setObject: @"NO" forKey: name];
	} 
}

- (void) deleteSchemeNamed: (NSString*) name
{
	NSString* path = [[NSString stringWithFormat: 
		@"~/GNUstep/Library/Colors/%@.uicolors", name] stringByExpandingTildeInPath];
	NSFileManager* fm = [NSFileManager defaultManager];
	[fm removeFileAtPath: path handler: nil];
	[list removeObjectForKey: name];
}

@end	
