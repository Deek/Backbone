#ifndef __COLORS_PREFS_H__
#define __COLORS_PREFS_H__

#include <AppKit/AppKit.h>
#include <PrefsModule/PrefsModule.h>
#include "NSColor+str.h"
#include "Preview.h"

@interface Colors: NSObject <PrefsModule>
{
	IBOutlet NSWindow	*window;
	id			view;
	IBOutlet id		editButton;

	IBOutlet id		highlightColorWell;
	IBOutlet id		highlightPercent;

	IBOutlet id		backgroundColorWell;

	IBOutlet id		mediumColorWell;
	IBOutlet id		mediumPercent;

	IBOutlet id		darkColorWell;
	IBOutlet id		darkPercent;

	IBOutlet id		blackColorWell;
	IBOutlet id		blackPercent;

	IBOutlet id		colorSchemesList;
	IBOutlet id		preview;

	IBOutlet id		schemeName;

	IBOutlet id		checkboxTextBackground;
	IBOutlet id		textBackgroundColorWell;
	IBOutlet id		checkboxSliderBackground;
	IBOutlet id		sliderBackgroundColorWell;

	NSMutableDictionary* 	list;
	NSMutableDictionary*	currentScheme;
}

- (void) initUI;
- (id) initWithOwner: (id <PrefsApplication>) anOwner;
- (void) showView: (id) sender;
- (NSView *) view;
- (NSString *) buttonCaption;
- (NSImage *) buttonImage;
- (SEL) buttonAction;

- (NSMutableDictionary*) loadSchemesFromPath: (NSString*) path;
- (void) updateEditWindow;

@end

@interface Colors (Actions)

- (IBAction) colorChanged: (id) sender;
- (IBAction) checkboxChanged: (id) sender;
- (IBAction) initColorLevels: (id) sender;

- (IBAction) schemeUpdated: (id) sender;

- (IBAction) useScheme: (id) sender;
- (IBAction) newScheme: (id) sender;
- (IBAction) deleteScheme: (id) sender;
- (IBAction) saveScheme: (id) sender;

@end

@interface Colors (Utilities)

- (NSMutableDictionary*) defaultColors;
- (void) setColorList: (NSMutableDictionary*) clist;
- (float) checkFloat: (float) c;
- (NSColor*) createColorFromRed: (float) r Green: (float) g Blue: (float) b Percent: (float) p;
- (void) setColor: (NSColorWell*) colorWell withName: (NSString*) colorName;
- (void) setCheckbox: (NSButton*) checkbox withName: (NSString*) name;
- (void) deleteSchemeNamed: (NSString*) name;

@end

#endif // __COLORS_PREFS_H__
