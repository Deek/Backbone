#ifndef __PREVIEW_COLOR_H__
#define __PREVIEW_COLOR_H__

#include <AppKit/AppKit.h>
#include "NSColor+str.h"

@interface Preview: NSView
{
	NSMutableDictionary* colors;	
}
- (void) drawButton: (NSRect) rect : (NSRect) clip;
- (void) drawTextfield: (NSRect) rect : (NSRect) clip;
- (void) setColors: (NSMutableDictionary*) col;
@end

#endif // __PREVIEW_COLOR_H__
