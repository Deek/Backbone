/*
	PrefsController.m

	Preferences window controller class

	Copyright (C) 2001 Dusk to Dawn Computing, Inc.

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	11 Nov 2001

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

#import <AppKit/NSApplication.h>
#import <AppKit/NSNibLoading.h>

#import <PrefsModule/PrefsModule.h>

#import "PrefsController.h"
#import "PrefsWindow.h"

@implementation PrefsController

static PrefsController	*sharedInstance = nil;
static NSMutableArray	*prefsViews = nil;
static id <PrefsModule>	currentModule = nil;

+ (PrefsController *) sharedPrefsController
{
	return (sharedInstance ? sharedInstance : [[self alloc] initWithWindowNibName: @"PrefsWindow"]);
}

- (id) initWithWindowNibName: (NSString *) windowNibName
{
	PrefsWindow	*theWindow = nil;

	if (sharedInstance) {
		[self dealloc];
	} else {
		if (![NSBundle loadNibNamed: windowNibName owner: self]) {
			NSLog (@"PrefsController: Could not load nib \"%@\", using compiled-in version", windowNibName);
			theWindow = [[PrefsWindow alloc]
						initWithContentRect: NSMakeRect (250, 250, 516, 394)
						styleMask: NSTitledWindowMask
								 | NSMiniaturizableWindowMask
								 | NSClosableWindowMask
						backing: NSBackingStoreBuffered
						defer: YES
					  ];
			self = [super initWithWindow: theWindow];
			[theWindow initUI];

			// connect our outlets
			window = theWindow;
			prefsViewBox = [theWindow prefsViewBox];
			
			[theWindow setMinSize: [theWindow frame].size];
			[theWindow setDelegate: self];

			[theWindow release];
		} else {
			self = [super initWithWindow: window];
		}
		[window setTitle: _(@"System Preferences")];

		prefsViews = [[[NSMutableArray alloc] initWithCapacity: 5] retain];
	}
	sharedInstance = self;
	return sharedInstance;	
}

- (void) dealloc
{
	NSDebugLog (@"PrefsController -dealloc");

	[prefsViews release];
	[super dealloc];
}

- (void) windowWillClose: (NSNotification *) aNotification
{
}

- (void) save: (id) sender
{
	NSLog (@"Saving current preferences...");

	[currentModule savePrefs: self];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) saveAll: (id) sender
{
	NSEnumerator		*enumerator = [prefsViews objectEnumerator];
	id <PrefsModule>	current;

	NSLog (@"Saving all preferences...");
	while ((current = [enumerator nextObject])) {
		[current savePrefs: self];
	}

	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadPreferences: (id) sender
{
	NSEnumerator		*enumerator = [prefsViews objectEnumerator];
	id <PrefsModule>	current;

	NSLog (@"Loading all preferences from database...");
	while ((current = [enumerator nextObject])) {
		[current loadPrefs: self];
	}

	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) reset: (id) sender
{
	NSLog (@"Setting preferences to defaults for current page");

	[currentModule resetPrefsToDefault: self];

	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) registerPrefsModule: (id <PrefsModule>) aPrefsModule;
{
	PrefsWindow		*prefsWindow = (PrefsWindow *) [self window];

	if (!aPrefsModule)
		return NO;

	if (! [prefsViews containsObject: aPrefsModule]) {
		[prefsViews addObject: aPrefsModule];
		[aPrefsModule autorelease];
	}

	[prefsWindow addPrefsViewButton: aPrefsModule];
	return YES;
}

- (BOOL) setCurrentModule: (id <PrefsModule>) aPrefsModule;
{
	if (!aPrefsModule || ![aPrefsModule view])
		return NO;

	currentModule = aPrefsModule;
	[prefsViewBox setContentView: [currentModule view]];
	return YES;
}

- (id) currentModule;
{
	return currentModule;
}
@end
