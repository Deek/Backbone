#ifndef __NSCOLOR_COLORSPREF__
#define __NSCOLOR_COLORSPREF__

#include <AppKit/AppKit.h>

@interface NSColor (ColorsPrefs)
+ (NSColor *) colorFromString: (NSString *) aString;
@end

#endif // __NSCOLOR_COLORSPREF__
