#include "NSColor+str.h"

@implementation NSColor (ColorsPrefs)
+ (NSColor *) colorFromString: (NSString *) aString
{
  NSColor *color = [[NSColor windowBackgroundColor] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace"];
  float r = [color redComponent]; 
  float g = [color greenComponent];
  float b = [color blueComponent];
  
  if ( aString )
    {
	NSScanner* scanner = [NSScanner scannerWithString: aString];
	[scanner scanFloat: &r];
	[scanner scanFloat: &g];
	[scanner scanFloat: &b];
	//NSLog (@"got : %f %f %f", r, g, b);
    }

  color = [NSColor colorWithCalibratedRed: r
		    green: g 
		    blue: b
		    alpha: 1.0];
  
  return color;
}
@end
