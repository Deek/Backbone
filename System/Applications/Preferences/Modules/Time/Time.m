/*
	Time.m

	Controller class for this bundle

	Copyright (C) 2002 Dusk to Dawn Computing

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
#include <Foundation/NSDebug.h>
#include <Foundation/NSUserDefaults.h>
#include <Foundation/NSValue.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSButton.h>
#include <AppKit/NSNibLoading.h>
#include <AppKit/NSOpenPanel.h>

#include "Time.h"
#include "BBClockView.h"

static Time						*sharedInstance = nil;
static id <PrefsApplication>	owner = nil;
static id <PrefsController>		controller = nil;

@interface Time (Private)

- (void) initUI;
- (void) updateUI;

@end

@implementation Time (Private)

static NSBundle				*bundle = nil;
static NSUserDefaults		*defaults = nil;
static NSWindow				*iconWin = nil;
static BBClockView			*iconClock = nil;

- (void) updateUI
{
	[localTimeZoneField setStringValue: [defaults stringForKey: @"Local Time Zone"]];
//FIXME
	[view setNeedsDisplay: YES];
}

- (void) initUI
{
	if (![NSBundle loadNibNamed: @"Time" owner: self]) {
		NSLog (@"Time: Could not load nib \"Time\", aborting.");
		[self dealloc];
		return;
	}

	// Set up our view, and destroy our window.
	if (!view) {
		view = [[window contentView] retain];

		[view removeFromSuperview];
		[window setContentView: NULL];
	}
	[window release];
	window = nil;

	[map setImage: [[NSImage alloc]
					initWithContentsOfFile: [bundle pathForImageResource: @"WorldMap"]]];

	[view retain];

	[self updateUI];
}

@end	// Time (Private)

@implementation Time

- (id) initWithOwner: (id <PrefsApplication>)anOwner
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

		[defaults registerDefaults: dict];
		[controller registerPrefsModule: self];

		// Let's be mean to the app, taking its icon away
		iconWin = [NSApp iconWindow];
		iconClock = [[BBClockView alloc] initWithFrame: [iconWin frame]];
//FIXME
		[iconWin setContentView: iconClock];

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
	return _(@"Time & Date Preferences");
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
- (IBAction) clockIsAnalogChanged: (id)sender
{
	[defaults setBool: [sender intValue] forKey: @"ClockIsAnalog"];
	[defaults synchronize];
	[self updateUI];
}

- (IBAction) clockSecondHandChanged: (id)sender
{
	[defaults setBool: [sender intValue] forKey: @"AnalogClockHasSecondHand"];
	[defaults synchronize];
	[self updateUI];
}

- (IBAction) clockUses24HoursChanged: (id)sender
{
	[defaults setBool: [sender intValue] forKey: @"ClockUses24Hours"];
	[defaults synchronize];
	[self updateUI];
}

- (IBAction) localTimeFieldChanged: (id)sender
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
