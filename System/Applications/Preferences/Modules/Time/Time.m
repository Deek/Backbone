/*
	Time.m

	Controller class for this bundle

	Copyright (C) 2002 Dusk to Dawn Computing, Inc.
	Additional copyrights here

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	29 Jun 2002

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public
	License along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA
*/
static const char rcsid[] = 
	"$Id$";

#ifdef HAVE_CONFIG_H
# include "Config.h"
#endif

#import <Foundation/NSDebug.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSValue.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSOpenPanel.h>

#import "Time.h"
#import "ClockView.h"

@interface Time (Private)
- (void) updateUI;
@end

@implementation Time (Private)

static NSBundle				*bundle = nil;
static NSUserDefaults		*defaults = nil;
static id <PrefsController>	controller = nil;
static NSWindow				*iconWin = nil;
static ClockView			*iconClock = nil;

- (void) updateUI
{
	[clockUses24HoursButton setIntValue: [defaults boolForKey: @"ClockUses24Hours"]];
	[clockIsAnalogButton setIntValue: [defaults boolForKey: @"ClockIsAnalog"]];
	[clockSecondHandButton setIntValue: [defaults boolForKey: @"AnalogClockHasSecondHand"]];
	[localTimeZoneField setStringValue: [defaults stringForKey: @"Local Time Zone"]];

	[iconClock setUses24Hours: [defaults boolForKey: @"ClockUses24Hours"]];
	[iconClock setAnalog: [defaults boolForKey: @"ClockIsAnalog"]];
	[iconClock setAnalogSecondHand: [defaults boolForKey: @"AnalogClockHasSecondHand"]];
	[view setNeedsDisplay: YES];
}

@end	// Time (Private)

@implementation Time

static Time						*sharedInstance = nil;
static id <PrefsApplication>	owner = nil;

- (id) initWithOwner: (id <PrefsApplication>) anOwner
{
	if (sharedInstance) {
		[self dealloc];
	} else {
		NSDictionary		*dict;

		self = [super init];
		owner = anOwner;
		bundle = [NSBundle bundleForClass: [self class]];
		controller = [owner prefsController];
		defaults = [NSUserDefaults standardUserDefaults];
		dict = [[NSDictionary alloc] initWithObjectsAndKeys:
				[NSNumber numberWithBool: NO], @"ClockUses24Hours",
				[NSNumber numberWithBool: NO], @"ClockIsAnalog",
				[NSNumber numberWithBool: NO], @"AnalogClockHasSecondHand",
				nil];

		if (![NSBundle loadNibNamed: @"Time" owner: self]) {
			NSLog (@"Time: Could not load nib \"Time\", aborting.");
			[self dealloc];
			return nil;
		}
		[defaults registerDefaults: dict];
		[controller registerPrefsModule: self];
		// window can be any size, as long as it's 486x228 :)
		view = [window contentView];

		// Let's be mean to the app, taking its icon away
		iconWin = [NSApp iconWindow];
		iconClock = [[ClockView alloc] initWithFrame: [iconWin frame]];
		[iconClock setUses24Hours: [defaults boolForKey: @"ClockUses24Hours"]];
		[iconClock setAnalog: [defaults boolForKey: @"ClockIsAnalog"]];
		[iconClock setAnalogSecondHand: [defaults boolForKey: @"AnalogClockHasSecondHand"]];

		[iconWin setContentView: iconClock];

		NSLog (@"%@", [bundle pathForImageResource: @"WorldMap"]);
		[map setImage: [[NSImage alloc]
						initWithContentsOfFile: [bundle
							pathForImageResource: @"WorldMap"]]];
		[view retain];

		[self updateUI];

		sharedInstance = self;
	}
	return sharedInstance;
}

- (void) showView: (id) sender;
{
	[controller setCurrentModule: self];
	[view setNeedsDisplay: YES];
}

- (NSView *) view
{
	return view;
}

- (NSString *) buttonCaption
{
	return @"Time & Date Preferences";
}

- (NSImage *) buttonImage
{
	return [NSImage imageNamed: @"PrefsIcon_Time"];
}

- (SEL) buttonAction
{
	return @selector(showView:);
}

/*
	Action methods
*/
- (IBAction) clockIsAnalogChanged: (id) sender
{
	[defaults setBool: [sender intValue] forKey: @"ClockIsAnalog"];
	[defaults synchronize];
	[self updateUI];
}

- (IBAction) clockSecondHandChanged: (id) sender
{
	[defaults setBool: [sender intValue] forKey: @"AnalogClockHasSecondHand"];
	[defaults synchronize];
	[self updateUI];
}

- (IBAction) clockUses24HoursChanged: (id) sender
{
	[defaults setBool: [sender intValue] forKey: @"ClockUses24Hours"];
	[defaults synchronize];
	[self updateUI];
}

- (IBAction) localTimeFieldChanged: (id) sender
{
	NSMutableDictionary	*globals = nil;

	globals = [[defaults persistentDomainForName: @"NSGlobalDomain"] mutableCopy];
	[globals setObject: [sender stringValue] forKey: @"Local Time Zone"];
	[defaults setPersistentDomain: globals forName: NSGlobalDomain]; \
	[defaults synchronize];
	[globals release];
	[self updateUI];
}

@end	// Time
