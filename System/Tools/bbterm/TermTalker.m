/*
	TermTalker.m

	Code for contacting Terminal and using it to run things.

	Copyright (C) 2004 Jeff Teunissen <deek@d2dc.net>

	Author:	Jeff Teunissen <deek@d2dc.net>
	Created: 20 Jul 2004

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

#include "TermTalker.h"

static NSUserDefaults	*defaults = nil;
static NSWorkspace		*workspace = nil;
static NSFileManager	*fm = nil;

static TermTalker		*sharedInstance = nil;

/* Yes, I know this is a hack. */
@interface Terminal: NSObject
{
	id pwc;

	id quitPanel;
	BOOL quitPanelOpen;
}

- (BOOL) application: (NSApplication *)sender
	openFile: (NSString *)filename;

- (BOOL) application: (NSApplication *)sender
	runProgram: (NSString *)path
	withArguments: (NSArray *)args
	inDirectory: (NSString *)directory
	properties: (NSDictionary *)properties;

- (BOOL) application: (NSApplication *)sender
	runCommand: (NSString *)cmdline
	inDirectory: (NSString *)directory
	properties: (NSDictionary *)properties;
@end

@interface TermTalker (Private)
- (id) connect;
@end

@implementation TermTalker

/*
	Singleton bookkeeping stuff.
*/
+ (TermTalker *) talker
{
	return (sharedInstance ? sharedInstance : [[self alloc] init]);
}

- (id) init
{
	if (sharedInstance) {
		[self dealloc];
	} else {
		self = [super init];

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

- (NSTimeInterval) connectionTimeout
{
	return timeout;
}

- (void) setConnectionTimeout: (NSTimeInterval)seconds
{
	timeout = seconds;
}
@end


@implementation TermTalker (Private)
/*
	connect

	Attempt to connect to a running Terminal. If it is not running it will
	be launched, using NSWorkspace -launchApplication:showIcon:autolaunch:.

	This function keeps trying to connect for up to 10 seconds.
*/
- (id) connect
{
	id				app = nil;
	NSDate			*expiry = [NSDate dateWithTimeIntervalSinceNow: timeout];
	NSString		*appName = @"Terminal";

	if (!fileName)
		return nil;

	appName = [[fileName lastPathComponent] stringByDeletingPathExtension];

NS_DURING
	app = [NSConnection rootProxyForConnectionWithRegisteredName: appName
															host: host];
NS_HANDLER
	app = nil;
NS_ENDHANDLER
	if (app)
		return app;

	if (![workspace launchApplication: fileName showIcon: YES autolaunch: autolaunch])
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

@end
