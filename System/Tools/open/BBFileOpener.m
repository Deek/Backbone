/*
	ContactApp.m

	Code for contacting an application and getting it to open files.

	Copyright (C) 2001-2003 Jeff Teunissen <deek@d2dc.net>

	Author:	Jeff Teunissen <deek@d2dc.net>
	Created: 31 Oct 2003

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

		Free Software Foundation
		59 Temple Place - Suite 330
		Boston, MA 02111-1307, USA
*/
#include <Foundation/NSConnection.h>
#include <Foundation/NSException.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSString.h>
#include <Foundation/NSUserDefaults.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSWorkspace.h>

#include "BBFileOpener.h"

static NSUserDefaults	*defaults = nil;
static NSWorkspace		*workspace = nil;
static NSFileManager	*fm = nil;

static BBFileOpener		*sharedInstance = nil;

@interface BBFileOpener (Private)
- (id) connectToApp: (NSString *)appName;
- (BOOL) openFile: (NSString *)file : (NSString *)app : (BOOL)print : (BOOL)temp;
- (NSString *) bestAppForFile: (NSString *)file;
@end

@implementation BBFileOpener

/*
	Singleton bookkeeping stuff.
*/
+ (BBFileOpener *) fileOpener
{
	return (sharedInstance ? sharedInstance : [[self alloc] init]);
}

- (id) init
{
	if (sharedInstance) {
		[self dealloc];
	} else {
		self = [super init];

		// set up defaults and "class variables"
		fileMustExist = YES;

		defaults = [NSUserDefaults standardUserDefaults];
		fm = [NSFileManager defaultManager];
		workspace = [NSWorkspace sharedWorkspace];
		timeout = 10.0;	// default seconds
	}
	return sharedInstance = self;
}

- (id) retain
{
	return self;
}

- (oneway void) release
{
	return;
}

- (void) dealloc
{
	if (sharedInstance && self != sharedInstance) {
		[super dealloc];
	}
	return;
}

/***
	Okay, now that we got that crap out of the way, let's do something useful.
***/

- (BOOL) autolaunch
{
	return autolaunch;
}

- (void) setAutolaunch: (BOOL)flag
{
	autolaunch = (flag != NO);
}

- (BOOL) fileMustExist
{
	return fileMustExist;
}

- (void) setFileMustExist: (BOOL)flag
{
	fileMustExist = (flag != NO);
}

- (BOOL) waitsForFileChange
{
	return waitForFileChanged;
}

- (void) setWaitsForFileChange: (BOOL)flag
{
	waitForFileChanged = (flag != NO);
}

- (NSTimeInterval) connectionTimeout
{
	return timeout;
}

- (void) setConnectionTimeout: (NSTimeInterval)seconds
{
	timeout = seconds;
}

- (id) openApp: (NSString *)app
{
	return [self connectToApp: app];
}

- (BOOL) openFile: (NSString *)file
{
	id	app = [self bestAppForFile: file];

	if (app)
		return [self openFile: file : app : NO : NO];

	return NO;
}

- (BOOL) openFile: (NSString *)file withApp:(NSString *)app
{
	return [self openFile: file : app : NO : NO];
}

- (BOOL) openTempFile: (NSString *)file
{
	id	app = [self bestAppForFile: file];

	if (app)
		return [self openFile: file : app : NO : YES];

	return NO;
}

- (BOOL) openTempFile: (NSString *)file withApp:(NSString *)app
{
	return [self openFile: file : app : NO : YES];
}

- (BOOL) printFile: (NSString *)file
{
	id	app = [self bestAppForFile: file];

	if (app)
		return [self openFile: file : app : YES : NO];

	return NO;
}

- (BOOL) printFile: (NSString *)file withApp:(NSString *)app
{
	return [self openFile: file : app : YES : NO];
}
@end


@implementation BBFileOpener (Private)
/*
	connectToApp (appname, hostname)

	Attempt to connect to a running application. If it is not running, it will
	be launched, using NSWorkspace -launchApplication:showIcon:autolaunch:.

	This function keeps trying to connect to the application for up to 10
	seconds.
*/
- (id) connectToApp: (NSString *)appName
{
	id				app = nil;
	NSDate			*expiry = [NSDate dateWithTimeIntervalSinceNow: timeout];

	if (!appName)
		return nil;

	appName = [appName stringByDeletingPathExtension];

NS_DURING
	app = [NSConnection rootProxyForConnectionWithRegisteredName: appName
															host: host];
NS_HANDLER
	app = nil;
NS_ENDHANDLER
	if (app)
		return app;

	if (![workspace launchApplication: appName showIcon: YES autolaunch: autolaunch])
		return nil;	// don't bother, workspace couldn't exec it

NS_DURING
	app = [NSConnection rootProxyForConnectionWithRegisteredName: appName
															host: host];

	while (!app && [expiry timeIntervalSinceNow] > 0) {
		NSRunLoop	*loop = [NSRunLoop currentRunLoop];

		[NSTimer scheduledTimerWithTimeInterval: 0.1
									 invocation: nil
										repeats: NO];
		[loop runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.2]];

		app = [NSConnection rootProxyForConnectionWithRegisteredName: appName
																host: host];
	}
NS_HANDLER
	return nil;
NS_ENDHANDLER

	return app;
}

- (BOOL) openFile: (NSString *)file
				 : (NSString *)appName
				 : (BOOL)print
				 : (BOOL)temp
{
	const char	*appCString;
	const char	*fileCString;
	id			app;

	if (!appName || !file)
		return NO;

	appCString = [appName cString];
	fileCString = [file cString];

	if (!(app = [self connectToApp: appName])) {
		printf ("Could not contact application \"%s\"\n", appCString);
		return NO;
	}

	if (print) {
		if (![app respondsToSelector: @selector(application:printFile:)]
			|| ![app application: nil printFile: file]) {
			printf ("Application \"%s\" could not print file \"%s\"",
					appCString,
					fileCString);
			return NO;
		}
		return YES;
	} else {
		if (temp) {
			if (![app respondsToSelector: @selector(application:openTempFile:)]
				|| ![app application: nil openTempFile: file]) {
				printf ("Application \"%s\" could not open temporary file \"%s\"",
						appCString,
						fileCString);
				return NO;
			}
			return YES;
		} else {
			if (![app respondsToSelector: @selector(application:openFile:)]
				|| ![app application: nil openFile: file]) {
				printf ("Application \"%s\" could not open file \"%s\"",
						appCString,
						fileCString);
				return NO;
			}
			return YES;
		}
	}
}

- (NSString *) bestAppForFile: (NSString *)file
{
	NSString	*app = nil;
	NSString	*type = nil;
	NSString	*defaultApp = nil;

	if (![workspace getInfoForFile: file application: &app type: &type])
		return nil;	// file does not exist

	if (!(defaultApp = [defaults stringForKey: @"GSDefaultEditor"]))
		defaultApp = @"TextEdit";
	
	if ([type isEqualToString: NSShellCommandFileType]) {	// is executable
		id temp = [defaults stringForKey: @"GSDefaultTerminal"];

		if (temp)
			return temp;

		return @"Terminal";
	}

	if (app)
		return app;

	return defaultApp;
}

@end
