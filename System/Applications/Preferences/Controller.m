/*
	Controller.h

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
static const char rcsid[] = 
	"$Id$";

#ifdef HAVE_CONFIG_H
# include "Config.h"
#endif

#import <AppKit/NSApplication.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSOpenPanel.h>

#import <PrefsModule/PrefsModule.h>

#import "Controller.h"
#import "BundleController.h"
#import "PrefsController.h"

@implementation Controller

- (BOOL) application: (NSApplication *) app openFile: (NSString *) filename;
{
	BundleController	*bundler = [BundleController sharedBundleController];

	[bundler loadBundleInPath: filename];
	return YES;
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
- (void) infoPanel: (id) sender;
{
	[NSApp orderFrontStandardAboutPanel: self];
}

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

		[bundler loadBundleInPath: [pathArray objectAtIndex:0]];
	}
}

- (void) saveCurrent: (id) sender;
{
	NSLog (@"This _will_ save the settings for the current module, but it doesn't yet.");
}

- (void) saveAll: (id) sender;
{
	NSLog (@"This _will_ save the settings for all modules, but it doesn't yet.");
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
	NSDebugLog (@"Showing window...");
	[[PrefsController sharedPrefsController] showWindow: self];
}

/*
	applicationWillFinishLaunching:

	Sent when the app is just about to complete its startup
*/
- (void) applicationWillFinishLaunching: (NSNotification *) not;
{

	NSMenu		*menu = [NSApp mainMenu];
	NSMenu		*infoMenu;
	NSMenu		*prefsMenu;
	NSMenu		*windowsMenu;
	NSMenu		*servicesMenu;

	[menu addItemWithTitle: _(@"Info")		action: NULL	keyEquivalent: @""];
	[menu addItemWithTitle: _(@"Prefs")		action: NULL	keyEquivalent: @""];
	[menu addItemWithTitle: _(@"Windows")	action: NULL	keyEquivalent: @""];
	[menu addItemWithTitle: _(@"Services")	action: NULL	keyEquivalent: @""];

	[menu addItemWithTitle: _(@"Hide")		action: @selector(hide:)	keyEquivalent: @"h"];
	[menu addItemWithTitle: _(@"Quit")		action: @selector(terminate:)	keyEquivalent: @"q"];

	/*
		Info
	*/
	NSDebugLog (@"Info");
	infoMenu = [[[NSMenu alloc] init] autorelease];
	[menu setSubmenu: infoMenu	forItem: [menu itemWithTitle: _(@"Info")]];

	[infoMenu addItemWithTitle: _(@"Info Panel...")
						action: @selector (orderFrontStandardAboutPanel:)
				 keyEquivalent: @""];
	[infoMenu addItemWithTitle: _(@"Help")
						action: @selector (orderFrontHelpPanel:)
				 keyEquivalent: @"?"];

	/*
		Prefs
	*/
	NSDebugLog (@"Prefs");
	prefsMenu = [[[NSMenu alloc] init] autorelease];
	[menu setSubmenu: prefsMenu	forItem: [menu itemWithTitle: _(@"Prefs")]];

	[prefsMenu addItemWithTitle: _(@"Open module...")
						 action: @selector (open:)
				  keyEquivalent: @"o"];
	[prefsMenu addItemWithTitle: _(@"Save this page")
						 action: @selector (save:)
				  keyEquivalent: @"s"];
	[prefsMenu addItemWithTitle: _(@"Save all pages")
						 action: @selector (saveAll:)
				  keyEquivalent: @"S"];
	[prefsMenu addItemWithTitle: _(@"Reset page to default")
						 action: @selector (reset:)
				  keyEquivalent: @"r"];

	/*
		Windows
	*/
	NSDebugLog (@"Windows");
	windowsMenu = [[[NSMenu alloc] init] autorelease];
	[menu setSubmenu: windowsMenu forItem: [menu itemWithTitle: _(@"Windows")]];

	[windowsMenu addItemWithTitle: _(@"Close window")
						   action: @selector (performClose:)
					keyEquivalent: @"w"];
	[windowsMenu addItemWithTitle: _(@"Miniaturize window")
						   action: @selector (performMiniaturize:)
					keyEquivalent: @"m"];
	[windowsMenu addItemWithTitle: _(@"Arrange in front")
						   action: @selector (arrangeInFront:)
					keyEquivalent: @""];

	[NSApp setWindowsMenu: windowsMenu];

	/*
		Services
	*/
	NSDebugLog (@"Services");
	servicesMenu = [[[NSMenu alloc] init] autorelease];

	[menu setSubmenu: servicesMenu forItem: [menu itemWithTitle: _(@"Services")]];
	[NSApp setServicesMenu: servicesMenu];

	[PrefsController sharedPrefsController];
	{	// yeah, yeah, shaddap
		id	controller = [BundleController sharedBundleController];

		[controller setDelegate: self];
		[controller loadBundles];
	}
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

	if (!aBundle) {
		NSLog (@"Controller -bundleController: sent nil bundle");
		return;
	}

	info = [aBundle infoDictionary];

	if (!(info || [info objectForKey: @"NSExecutable"])) {
		NSLog (@"%@ has no principal class and no info dictionary", aBundle);
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
	[[(id <PrefsModule>) [aBundle principalClass] alloc] initWithOwner: self];
}

- (id <PrefsController>) prefsController
{
	return [PrefsController sharedPrefsController];
}
@end
