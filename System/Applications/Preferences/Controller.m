/*
	Controller.m

	Application controller class

	Copyright (C) 2001 Dusk to Dawn Computing, Inc.

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	5 Nov 2001

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
#ifdef HAVE_CONFIG_H
# include "Config.h"
#endif

RCSID("$Id$");

#include <Foundation/NSDebug.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSUserDefaults.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSMenu.h>
#include <AppKit/NSOpenPanel.h>

#include <PrefsModule/PrefsModule.h>

#include "Controller.h"
#include "BundleController.h"
#include "PrefsController.h"

@implementation Controller

static NSUserDefaults *defaults = nil;
#if 1
static BOOL doneLaunching = NO;
#endif

- (id) init
{
	if (!(self = [super init]))
		return nil;

	if (!defaults)
		defaults = [NSUserDefaults standardUserDefaults];

	return self;
}

- (BOOL) application: (NSApplication *) app openFile: (NSString *) filename
{
	BundleController	*bundler = [BundleController sharedBundleController];

	return [bundler loadBundleWithPath: filename];
}

- (BOOL) applicationShouldTerminate: (NSApplication *) app;
{
	return YES;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) app;
{
	return YES;
}

/*
	Action methods
*/
- (void) open: (id) sender;
{
	BundleController	*bundler = [BundleController sharedBundleController];
	int					result;
	NSArray				*fileTypes = [NSArray arrayWithObject: @"prefs"];
	NSOpenPanel			*oPanel = [NSOpenPanel openPanel];

	[oPanel setAllowsMultipleSelection: NO];
	[oPanel setCanChooseFiles: YES];
	[oPanel setCanChooseDirectories: NO];

	result = [oPanel runModalForDirectory: NSHomeDirectory() file: nil types: fileTypes];
	if (result == NSOKButton) {		// got a new dir
		NSArray		*pathArray = [oPanel filenames];

		[bundler loadBundleWithPath: [pathArray objectAtIndex: 0]];
	}
}

/*
	Notifications
*/

/*
	applicationDidFinishLaunching:

	Sent when the app has finished starting up
*/
- (void) applicationDidFinishLaunching: (NSNotification *) not;
{
	if ([defaults boolForKey: @"NXAutoLaunch"]) {
#if 1
		doneLaunching = YES;
		[NSApp hide: self];
#endif
	} else {
		[[prefsController window] makeKeyAndOrderFront: self];
	}
}

/*
	applicationWillFinishLaunching:

	Sent when the app is just about to complete its startup
*/
- (void) applicationWillFinishLaunching: (NSNotification *) not;
{
	NSMenu			*menu = [NSApp mainMenu];

//	[menu setTitle: [[[NSBundle mainBundle] infoDictionary] objectForKey: @"ApplicationName"]];
	/*
		Windows
	*/
	NSDebugLog (@"Windows");
	[NSApp setWindowsMenu: [[menu itemWithTitle: _(@"Windows")] submenu]];

	/*
		Services
	*/
	NSDebugLog (@"Services");
	[NSApp setServicesMenu: [[menu itemWithTitle: _(@"Services")] submenu]];

	[bundleController loadBundles];

	/*
		This should work, but doesn't because GNUstep starts apps hidden and
		unhides them between -applicationWillFinishLaunching: and
		-applicationDidFinishLaunching:
	*/
#if 0
	if ([defaults boolForKey: @"NXAutoLaunch"]) {
		[NSApp hide: self];
	}
#endif
}

/*
	applicationDidUnhide:

	Check whether the prefs controller window is visible, and if not, order it
	front.
*/
- (void) applicationDidUnhide: (NSNotification *) not;
{
#if 1
	if (doneLaunching && ![[prefsController window] isVisible])
#else
	if (![[prefsController window] isVisible])
#endif
		[[prefsController window] makeKeyAndOrderFront: self];
}

/*
	applicationWillTerminate:

	We're about to die, but AppKit is giving us a chance to clean up
*/
- (void) applicationWillTerminate: (NSNotification *) not;
{
}

/******
	PrefsApplication delegate methods
******/

- (void) moduleLoaded: (NSBundle *) aBundle
{
	NSDictionary		*info = nil;

	/*
		Let's get paranoid about stuff we load... :)
	*/
	if (!aBundle) {
		NSLog (@"Controller -moduleLoaded: sent nil bundle");
		return;
	}

	if (!(info = [aBundle infoDictionary])) {
		NSLog (@"Bundle `%@´ has no info dictionary!", aBundle);
		return;
	}

	if (![info objectForKey: @"NSExecutable"]) {
		NSLog (@"Bundle `%@´ has no executable!", aBundle);
		return;
	}

	if (![aBundle principalClass]) {
		NSLog (@"Bundle `%@´ has no principal class!", [[info objectForKey: @"NSExecutable"] lastPathComponent]);
		return;
	}

	if (![[aBundle principalClass] conformsToProtocol: @protocol(PrefsModule)]) {
		NSLog (@"Bundle %@'s principal class does not conform to the PrefsModule protocol.", [[info objectForKey: @"NSExecutable"] lastPathComponent]);
		return;
	}

	[[[aBundle principalClass] alloc] initWithOwner: self];
}

- (id <PrefsController>) prefsController
{
	return prefsController;
}
@end
