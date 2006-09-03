#ifndef __COLORS_PREFS_H__
#define __COLORS_PREFS_H__

#include <AppKit/AppKit.h>
#include <AppKit/NSNibDeclarations.h>
#include <PrefsModule/PrefsModule.h>
#include "NSColor+StringHandling.h"

extern NSUserDefaults	*defaults;

@interface Colors: NSObject <PrefsModule>
{
	IBOutlet NSWindow	*window;
	IBOutlet NSView		*view;

	id preview;

	IBOutlet NSBrowser		*schemeBrowser;
	IBOutlet NSPopUpButton	*commands;
	IBOutlet NSPopUpButton	*colorSelectionPopUp;
	IBOutlet NSColorWell	*colorSelectionWell;

	IBOutlet NSColorWell	*color1;
	IBOutlet NSColorWell	*color2;
	IBOutlet NSColorWell	*color3;
	IBOutlet NSColorWell	*color4;
	IBOutlet NSColorWell	*color5;
	IBOutlet NSColorWell	*color6;
	IBOutlet NSColorWell	*color7;
	IBOutlet NSColorWell	*color8;
	IBOutlet NSColorWell	*color9;
	IBOutlet NSColorWell	*color10;
	IBOutlet NSColorWell	*color11;
	IBOutlet NSColorWell	*color12;

	NSDictionary			*schemeList;
	NSMutableDictionary		*currentScheme;
}

@end

@interface Colors (Actions)

- (IBAction) saveScheme: (id)sender;
- (IBAction) colorChanged: (id)sender;
- (IBAction) colorSelected: (id)sender;
- (IBAction) schemeSelected: (id)sender;
- (IBAction) removeScheme: (id)sender;
- (IBAction) updateSystemColors: (id)sender;

@end

@interface Colors (BrowserDelegate)

@end

@interface Colors (Utilities)

- (NSArray *) colorSchemeDirectoryList;
- (NSArray *) colorSchemeFilesInPath: (NSString *) path;
- (NSDictionary *) colorSchemes;

- (void) loadColorWells;

- (void) removeColorSchemeNamed: (NSString *)name;
- (void) setColorList: (NSDictionary *)colorList;
- (void) setColor: (NSColor *)aColor forKey: (NSString *)colorKey;

@end

#endif // __COLORS_PREFS_H__
