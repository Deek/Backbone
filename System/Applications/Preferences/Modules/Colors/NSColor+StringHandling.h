#ifndef __Preferences_Modules_Colors_NSColor_StringHandling_h
#define __Preferences_Modules_Colors_NSColor_StringHandling_h

#include <Foundation/NSString.h>
#include <AppKit/NSColor.h>

@interface NSColor (StringHandling)

+ (NSColor *) colorWithRGBStringRepresentation: (NSString *) aString;
+ (NSColor *) colorWithCalibratedRed: (float)r green: (float)g blue: (float)b percent: (float)percent;
- (NSString *) RGBStringRepresentation;

@end

#endif	// __Preferences_Modules_Colors_NSColor_StringHandling_h
