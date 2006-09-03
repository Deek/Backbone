#include <Foundation/NSScanner.h>
#include <Foundation/NSString.h>
#include <Foundation/NSUserDefaults.h>
#include <AppKit/NSColor.h>

#include "NSColor+StringHandling.h"

#undef MAX
#define MAX(a,b)		(a) > (b) ? (a) : (b)
#undef MIN
#define MIN(a,b)		(a) < (b) ? (a) : (b)
#undef CLAMP
#define CLAMP(a,b,c)	MAX((a), MIN((c), (b)))

static float
ClampedColorFloat (float colorFloat)
{
	return CLAMP(0.0, colorFloat, 1.0);
}

@implementation NSColor (StringHandling)

+ (NSColor *) colorWithRGBStringRepresentation: (NSString *) aString
{
	NSColor	*color = [[NSColor windowBackgroundColor] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace"];
	float	r = [color redComponent];
	float	g = [color greenComponent];
	float	b = [color blueComponent];

	if (aString) {
		NSScanner	*scanner = [NSScanner scannerWithString: aString];

		[scanner scanFloat: &r];
		[scanner scanFloat: &g];
		[scanner scanFloat: &b];
//		NSLog (@"got : %f %f %f", r, g, b);
    }

	color = [NSColor colorWithCalibratedRed: r green: g blue: b alpha: 1.0];
	return color;
}

+ (NSColor *) colorWithCalibratedRed: (float)r green: (float)g blue: (float)b percent: (float)percent
{
	return [self colorWithCalibratedRed: ClampedColorFloat (r + (r * percent))
								  green: ClampedColorFloat (g + (g * percent))
								   blue: ClampedColorFloat (g + (g * percent))
								  alpha: 1.0];
}

- (NSString *) RGBStringRepresentation
{
	id rgb = [self colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace"];

	return [NSString stringWithFormat: @"%g %g %g", [rgb redComponent], [rgb greenComponent], [rgb blueComponent]];
}

@end
