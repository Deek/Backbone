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

#import <Foundation/NSDebug.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSUserDefaults.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSOpenPanel.h>

#import <PrefsModule/PrefsModule.h>

#import "Controller.h"
#import "BundleController.h"
#import "PrefsController.h"

@implementation Controller

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
	NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];

	if ([defaults boolForKey: @"NXAutoLaunch"]
			|| [defaults boolForKey: @"GSAutoLaunch"])
		[NSApp hide: self];
}

/*
	applicationWillFinishLaunching:

	Sent when the app is just about to complete its startup
*/
- (void) applicationWillFinishLaunching: (NSNotification *) not;
{
	NSMenu		*menu = [NSApp mainMenu];

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
		NSLog (@"Controller moduleLoaded: sent nil bundle");
		return;
	}

	if (!(info = [aBundle infoDictionary])) {
		NSLog (@"Bundle %@ has no info dictionary!", aBundle);
		return;
	}

	if (![info objectForKey: @"NSExecutable"]) {
		NSLog (@"Bundle %@ has no executable!", aBundle);
		return;
	}

	if (![aBundle principalClass]) {
		NSLog (@"Bundle `%@' has no principal class!", [[info objectForKey: @"NSExecutable"] lastPathComponent]);
		return;
	}

	if (![[aBundle principalClass] conformsToProtocol: @protocol(PrefsModule)]) {
		NSLog (@"Bundle %@'s principal class does not conform to the PrefsModule protocol.", [[info objectForKey: @"NSExecutable"] lastPathComponent]);
		return;
	}

	[[(id <NSObject,PrefsModule>) [aBundle principalClass] alloc] initWithOwner: self];
}

- (id <PrefsController>) prefsController
{
	return prefsController;
}
@end
