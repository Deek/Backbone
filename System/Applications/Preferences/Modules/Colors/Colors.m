#include "Colors.h"

@implementation Colors 

static id <PrefsController>	controller;
static NSBundle			*bundle = nil;
static NSUserDefaults		*defaults = nil;
static NSMutableDictionary	*domain = nil;
static Colors			*sharedInstance = nil;
static id <PrefsApplication>	owner = nil;

- (void) dealloc
{
	[list release];
}

- (void) initUI
{
	if (![NSBundle loadNibNamed: @"Colors" owner: self]) {
		NSLog (@"Colors: Could not load nib \"Colors\", aborting.");
		[self dealloc];
		return;
	}
	

	if (!view) {
		view = [[window contentView] retain];
		[view removeFromSuperview];
		[window setContentView: NULL];
	}
	[window release];
	window = nil;
}

- (id) initWithOwner: (id <PrefsApplication>) anOwner
{
	if (sharedInstance) {
		[self dealloc];
	} else {
		self = [super init];
		owner = anOwner;
		controller = [owner prefsController];
		defaults = [NSUserDefaults standardUserDefaults];
		domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];
		bundle = [NSBundle bundleForClass: [self class]];

		NSString* path = [[NSString stringWithString: @"~/GNUstep/Library/Colors/"] 
					stringByExpandingTildeInPath];
		list = [[self loadSchemesFromPath: path] retain];

		[colorSchemesList setAllowsEmptySelection: YES];
		[colorSchemesList setAllowsMultipleSelection: NO];

		[controller registerPrefsModule: self];

		currentScheme = nil;
		sharedInstance = self;
	}
	return sharedInstance;
}

- (void) showView: (id) sender;
{
	if (!view)
		[self initUI];

	[controller setCurrentModule: self];
	[view setNeedsDisplay: YES];
}

- (NSView *) view
{
	return view;
}

- (NSString *) buttonCaption
{
	return NSLocalizedStringFromTableInBundle(@"Colors Preferences", @"Localizable", bundle, @"");
}

- (NSImage *) buttonImage
{
	return [NSImage imageNamed: @"PrefsIcon_Appearances"];
}

- (SEL) buttonAction
{
	return @selector(showView:);
}

- (NSMutableDictionary*) loadSchemesFromPath: (NSString*) path
{
	NSMutableDictionary* ret = [NSMutableDictionary new];

	NSFileManager* fm = [NSFileManager defaultManager];
	if( [fm changeCurrentDirectoryPath: path] )
	{
		NSArray* files = [fm directoryContentsAtPath: path];	
		int i;
		for (i=0; i < [files count]; i++)
		{
			NSString* file = [files objectAtIndex: i];
			if ([[file pathExtension] isEqualToString:@"uicolors"])	
			{
				NSMutableDictionary* cl = [NSMutableDictionary dictionaryWithContentsOfFile: file];
				if ([cl objectForKey: @"name"] != nil)
				{
					[ret setObject: cl forKey: [cl objectForKey: @"name"]];
				}
			}
		}
	}
	return [ret autorelease];
}


/*
	updates the colors dictionary based on the percents value of the sliders
*/

- (void) updateEditWindow
{
	if (currentScheme != nil)
	{
		float hP = [highlightPercent floatValue]/100.0;
		float mP = [mediumPercent floatValue]/100.0;
		float dP = [darkPercent floatValue]/100.0;
		float bP = [blackPercent floatValue]/100.0;

		float r,g,b;

		[schemeName setStringValue: [currentScheme objectForKey: @"name"]];
		[schemeName setEnabled: YES];
		[backgroundColorWell setEnabled: YES];
		[textBackgroundColorWell setEnabled: YES];
		[sliderBackgroundColorWell setEnabled: YES];

		NSColor* basecol = [NSColor colorFromString: [currentScheme objectForKey: @"base"]];
		NSColor* textBackgroundColor = [NSColor colorFromString: 
			[currentScheme objectForKey: @"textfieldbgd"]];
		NSColor* sliderBackgroundColor = [NSColor colorFromString: 
			[currentScheme objectForKey: @"sliderbgd"]];

		[basecol getRed: &r green: &g blue: &b alpha: NULL];

		NSColor* hCol = [self createColorFromRed: r Green: g Blue: b Percent: hP];
		NSColor* mCol = [self createColorFromRed: r Green: g Blue: b Percent: mP];
		NSColor* dCol = [self createColorFromRed: r Green: g Blue: b Percent: dP];
		NSColor* bCol = [self createColorFromRed: r Green: g Blue: b Percent: bP];

		if (![[backgroundColorWell color] isEqual: basecol]) [backgroundColorWell setColor: basecol];
		if (![[textBackgroundColorWell color] isEqual: textBackgroundColor]) [textBackgroundColorWell setColor: textBackgroundColor];
		if (![[sliderBackgroundColorWell color] isEqual: sliderBackgroundColor]) [sliderBackgroundColorWell setColor: sliderBackgroundColor];
		[highlightColorWell setColor: hCol];
		[mediumColorWell setColor: mCol];
		[darkColorWell setColor: dCol];
		[blackColorWell setColor: bCol];

		// we update "lightGray"

		//lightGray
		[currentScheme setObject: [basecol description] forKey: @"controlBackgroundColor"];
		[currentScheme setObject: [basecol description] forKey: @"controlColor"];
		[currentScheme setObject: [basecol description] forKey: @"controlHighlightColor"];
		[currentScheme setObject: [basecol description] forKey: @"headerColor"]; 
		[currentScheme setObject: [basecol description] forKey: @"knobColor"];
		[currentScheme setObject: [basecol description] forKey: @"selectedKnobColor"];
		[currentScheme setObject: [basecol description] forKey: @"selectedTextBackgroundColor"]; 
		[currentScheme setObject: [basecol description] forKey: @"windowBackgroundColor"];

		//gray
		[currentScheme setObject: [mCol description] forKey: @"gridColor"];
		if ([[currentScheme objectForKey: @"use_sliderbgd"] isEqualToString: @"YES"])
		{
			[currentScheme setObject: [sliderBackgroundColor description] forKey: @"scrollBarColor"];
			[checkboxSliderBackground setState: NSOnState];
		}
		else
		{
			[currentScheme setObject: [mCol description] forKey: @"scrollBarColor"];
			[checkboxSliderBackground setState: NSOffState];
		}

		//darkGray
		[currentScheme setObject: [dCol description] forKey: @"controlShadowColor"];
		[currentScheme setObject: [dCol description] forKey: @"disabledControlTextColor"];

		//white
		[currentScheme setObject: [hCol description] forKey: @"controlLightHighlightColor"];
		[currentScheme setObject: [hCol description] forKey: @"highlightColor"];
		[currentScheme setObject: [hCol description] forKey: @"selectedControlColor"];
		[currentScheme setObject: [hCol description] forKey: @"selectedMenuItemColor"];
		if ([[currentScheme objectForKey: @"use_textfieldbgd"] isEqualToString: @"YES"])
		{
			[currentScheme setObject: [textBackgroundColor description] 
				forKey: @"textBackgroundColor"];
			[checkboxTextBackground setState: NSOnState];
		}
		else
		{
			//[currentScheme setObject: [hCol description] forKey: @"textBackgroundColor"];
			[currentScheme setObject: @"1.0 1.0 1.0" forKey: @"textBackgroundColor"];
			[checkboxTextBackground setState: NSOffState];
		}
		[currentScheme setObject: [hCol description] forKey: @"windowFrameTextColor"];
		
		//black
		[currentScheme setObject: [bCol description] forKey: @"controlDarkShadowColor"];
		[currentScheme setObject: [bCol description] forKey: @"controlTextColor"];
		[currentScheme setObject: [bCol description] forKey: @"headerTextColor"];
		[currentScheme setObject: [bCol description] forKey: @"keyboardFocusIndicatorColor"];
		[currentScheme setObject: [bCol description] forKey: @"selectedControlTextColor"];
		[currentScheme setObject: [bCol description] forKey: @"selectedMenuItemTextColor"];
		[currentScheme setObject: [bCol description] forKey: @"selectedTextColor"];
		[currentScheme setObject: [bCol description] forKey: @"shadowColor"];
		[currentScheme setObject: [bCol description] forKey: @"textColor"];
		[currentScheme setObject: [bCol description] forKey: @"windowFrameColor"];
		[preview setColors: currentScheme];
		[preview setNeedsDisplay: YES];
	}
	else
	{
		[schemeName setStringValue: @"No scheme selected"];
		[schemeName setEnabled: NO];
		[backgroundColorWell setEnabled: NO];
		[textBackgroundColorWell setEnabled: NO];
		[sliderBackgroundColorWell setEnabled: NO];
	}
}

@end	
