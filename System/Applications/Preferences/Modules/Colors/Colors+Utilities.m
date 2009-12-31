#include "Colors.h"

#include <Foundation/NSArray.h>

#define ColorString(r,g,b) \
	[NSString stringWithFormat: @"%g %g %g", (r), (g), (b)]

@implementation Colors (Utilities)

- (NSMutableDictionary *) standardColors
{
	static float	Black = 0.0;
	static float	DarkGray = 1.0 / 3.0;
	static float	Gray = 1.0 / 2.0;
	static float	LightGray = 2.0 / 3.0;
	static float	White = 1.0;

	NSString	*white = ColorString (White, White, White);
	NSString	*lightGray = ColorString (LightGray, LightGray, LightGray);
	NSString	*gray = ColorString (Gray, Gray, Gray);
	NSString	*darkGray = ColorString (DarkGray, DarkGray, DarkGray);
	NSString	*black = ColorString (Black, Black, Black);

	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
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
				NULL];
}

- (void) setColorList: (NSDictionary *)colorList
{
	NSColorList		*systemColors = [NSColorList colorListNamed: @"System"];
	NSEnumerator	*keys;
	id				current;
	BOOL			changed = NO;

	if (!systemColors)
		systemColors = [[NSColorList alloc] initWithName: @"System"];

	// Set up default system colors
	keys = [colorList keyEnumerator];

	while ((current = [keys nextObject])) {
		if ([systemColors colorWithKey: current]) {	// continue;
			NSColor *new = [NSColor colorWithRGBStringRepresentation: [colorList objectForKey: current]];

//			NSCAssert1 (new, @"couldn't get default system color %@", r);
			if (new) {
				[systemColors setColor: new forKey: current];
				changed = YES;
			}
		}
	}

	if (changed)
		[systemColors writeToFile: nil];
}

- (void) setColor: (NSColor *)aColor forKey: (NSString *)colorKey
{
	// We want it in RGB space
	NSColor* c = [aColor colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace"];

	if (c) {
		[currentScheme setObject: [c RGBStringRepresentation] forKey: colorKey];
	}
}

- (void) removeColorSchemeNamed: (NSString *)name
{
	NSArray			*dirs = [self colorSchemeDirectoryList];
	NSString		*dir = [dirs objectAtIndex: 0];
	NSFileManager	*fm = [NSFileManager defaultManager];
	NSString		*path = [NSString stringWithFormat: @"%@/%@.colorScheme", dir, name];

	if (dir	&& path
		&& [fm fileExistsAtPath: path]
		&& [fm isDeletableFileAtPath: path]) {
		[fm removeFileAtPath: path handler: nil];
	}

	[schemeList release];
	schemeList = [self colorSchemes];
}

- (NSArray *) colorSchemeDirectoryList
{
	NSMutableArray		*dirList = [[NSMutableArray alloc] initWithCapacity: 3];
	NSArray				*temp;
	NSEnumerator		*counter;
	id					entry;

	NSDebugLog (@"Finding Colors dirs...");
	// Get the library dirs and add our path to all of its entries
	temp = NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSAllDomainsMask, YES);

	counter = [temp objectEnumerator];
	while ((entry = [counter nextObject])) {
		[dirList addObject: [entry stringByAppendingPathComponent: @"Colors"]];
	}
	NSDebugLog (@"Colors dirs: %@", dirList);

	return [NSArray arrayWithArray: [dirList autorelease]];
}

- (NSArray *) colorSchemeFilesInPath: (NSString *) path
{
	NSMutableArray	*fileList = [[NSMutableArray alloc] initWithCapacity: 5];
	NSEnumerator	*enumerator;
	NSFileManager	*fm = [NSFileManager defaultManager];
	NSString		*file;
	BOOL			isDir;

	// ensure path exists, and is a directory
	if (![fm fileExistsAtPath: path isDirectory: &isDir])
		return nil;

	if (!isDir)
		return nil;

	// scan for files matching the extension in the dir
	enumerator = [[fm directoryContentsAtPath: path] objectEnumerator];
	while ((file = [enumerator nextObject])) {
		NSString	*fullFileName = [path stringByAppendingPathComponent: file];

		// ensure file exists, and is NOT directory
		if (![fm fileExistsAtPath: fullFileName isDirectory: &isDir])
			continue;

		if (isDir)
			continue;

		if ([[file pathExtension] isEqualToString: @"colorScheme"])
			[fileList addObject: fullFileName];
	}
	return [NSArray arrayWithArray: [fileList autorelease]];
}

- (NSDictionary *) colorSchemes
{
	NSEnumerator		*dirs = [[self colorSchemeDirectoryList] objectEnumerator];
	NSEnumerator		*files = [NSMutableArray new];
	NSMutableDictionary	*schemes = [NSMutableDictionary new];
	id					current;

	while ((current = [dirs nextObject])) {
		files = [[self colorSchemeFilesInPath: current] objectEnumerator];

		while ((current = [files nextObject])) {
			NSMutableDictionary	*scheme;
			NSString			*name;

			if ((scheme = [NSDictionary dictionaryWithContentsOfFile: current])
					&& (name = [scheme objectForKey: @"Name"])
					&& ![[schemes allKeys] containsObject: name])
				[schemes setObject: current forKey: name];
		}
	}
	NSDebugLog (@"Color scheme files: %@", schemes);
	return [NSDictionary dictionaryWithDictionary: [schemes autorelease]];
}

- (void) loadColorWells
{
	id				customColors;
	id				colorString;

	if (!(customColors = [defaults dictionaryForKey: @"CustomColors"]))
		return;

	if ((colorString = [customColors objectForKey: @"1"]))
		[color1 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"2"]))
		[color2 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"3"]))
		[color3 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"4"]))
		[color4 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"5"]))
		[color5 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"6"]))
		[color6 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"7"]))
		[color7 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"8"]))
		[color8 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"9"]))
		[color9 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"10"]))
		[color10 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"11"]))
		[color11 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];

	if ((colorString = [customColors objectForKey: @"12"]))
		[color12 setColor: [NSColor colorWithRGBStringRepresentation: colorString]];
}

@end
