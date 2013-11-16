#import <Foundation/NSObject.h>
#import <Foundation/NSDictionary.h>
#import <AppKit/NSFont.h>
#import "Document.h"

/* Keys in the dictionary... */
#define RichTextFont               @"RichTextFont"
#define PlainTextFont              @"PlainTextFont"
#define DeleteBackup               @"DeleteBackup"
#define SaveFilesWritable          @"SaveFilesWritable"
#define RichText                   @"RichText"
#define WriteBOM                   @"WriteBOM"
#define ShowPageBreaks             @"ShowPageBreaks"
#define WindowWidth                @"WidthInChars"
#define WindowHeight               @"HeightInChars"
#define PlainTextEncoding          @"PlainTextEncoding"
#define TabWidth                   @"TabWidth"
#define ForegroundLayoutToIndex    @"ForegroundLayoutToIndex"
#define OpenPanelFollowsMainWindow @"OpenPanelFollowsMainWindow"

@interface Preferences: NSObject
{
	id  richTextFontNameField;
	id  plainTextFontNameField;
	id  keepBackupButton;
	id  saveFilesWritableButton;
	id  richTextMatrix;
	id  showPageBreaksButton;
	id  windowWidthField;
	id  windowHeightField;
	id  plainTextEncodingPopup;
	id  tabWidthField;
	id  writeBOMButton;

	NSDictionary         *curValues;
	NSMutableDictionary  *displayedValues;
}

+ (id) objectForKey: (id)key;	/* Convenience for getting global preferences */
+ (void) saveDefaults;		/* Convenience for saving global preferences */

+ (Preferences *) sharedInstance;

/*
    The current preferences; contains values for the documented keys
*/
- (NSDictionary *) preferences;

- (void) showPanel: (id)sender;	/* Shows the panel */

- (void) updateUI;		/* Updates the displayed values in the UI */
- (void) commitDisplayedValues;	/* The displayed values are made current */
- (void) discardDisplayedValues;	/* The displayed values are replaced with
									  current prefs and updateUI is called */

/*
    Reverts the displayed values to the current preferences
*/
- (void) revert: (id)sender;

/*
    Calls commitUI to commit the displayed values as current
*/
- (void) ok: (id)sender;
- (void) revertToDefault: (id)sender;

/*
    Action message for most of the misc items in the UI to get displayedValues
*/
- (void) miscChanged: (id)sender;

/*
    Request to change the rich text font
*/
- (void) changeRichTextFont: (id)sender;

/*
    Request to change the plain text font
*/
- (void) changePlainTextFont: (id)sender;

/*
    Sent by the font manager
*/
- (void) changeFont: (id)fontManager;

+ (NSDictionary *) preferencesFromDefaults;
+ (void) savePreferencesToDefaults: (NSDictionary *)dict;

@end
