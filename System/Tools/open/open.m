/*
	open.m

	Open files and/or programs

	Copyright (C) 2001 Free Software Foundation, Inc.
	Copyright (C) 2001-2003 Dusk to Dawn Computing, Imc.

	Author:	Jeff Teunissen <deek@d2dc.net>
	Created: November 2001

	Based on "gopen", written by Gregory Casamento <greg_casamento@yahoo.com>

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

#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSString.h>
#include <Foundation/NSProcessInfo.h>
#include <Foundation/NSTask.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSException.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSFileHandle.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSUserDefaults.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSWorkspace.h>

NSAutoreleasePool	*pool = nil;
NSFileManager		*fm = nil;
NSProcessInfo		*process = nil;
NSUserDefaults		*defaults = nil;
NSWorkspace			*workspace = nil;

int
doStdInput (NSString *name, NSString *application)
{
	NSFileHandle	*fh = [NSFileHandle fileHandleWithStandardInput];
	NSData			*data = [fh readDataToEndOfFile];
	NSNumber		*pid = [NSNumber numberWithInt: [process processIdentifier]];
	NSString		*tempFile = [NSTemporaryDirectory () stringByAppendingPathComponent: name];

	tempFile = [tempFile stringByAppendingString: [pid stringValue]];
	tempFile = [tempFile stringByAppendingString: @".txt"];
	[data writeToFile: tempFile atomically: YES];
	[workspace openFile: tempFile withApplication: application];
	return 0;
}

BOOL redirectStdError (char *filename)
{
	signed int		fd = -1;

	if ((fd = open (filename, O_WRONLY)) < 0)
		return NO;
	close (2);
	dup2 (fd, 2);
	return YES;
}

int
main (int argc, char** argv, char **env)
{
	NSEnumerator	*argEnumerator = nil;
	NSString		*appAutoLaunch = nil;
	NSString		*application = nil;
	NSString		*arg = nil;
	NSString		*editor = nil;
	NSString		*processName = nil;
	NSString		*terminal = nil;

	pool = [NSAutoreleasePool new];	// create the autorelease pool

	process = [NSProcessInfo processInfo];
	defaults = [NSUserDefaults standardUserDefaults];
	fm = [NSFileManager defaultManager];
	workspace = [NSWorkspace sharedWorkspace];

	// Default applications for opening unregistered file types....
	if (!(editor = [defaults stringForKey: @"GSDefaultEditor"]))
		editor = @"TextEdit";

	if (!(terminal = [defaults stringForKey: @"GSDefaultTerminal"]))
		terminal = @"Terminal";

	// Process options...
	processName = [[NSProcessInfo processInfo] processName];

	if (argc == 1)	// stdin, open it with editor and don't do anything further
		return doStdInput (processName, editor);

	application = [defaults stringForKey: @"a"];
	appAutoLaunch = [defaults stringForKey: @"A"];

	if (!redirectStdError ("/dev/null")) {
		printf ("Error redirecting standard output: %s\n", strerror (errno));
		return 1;
	}

	if (appAutoLaunch) {
		[workspace launchApplication: appAutoLaunch showIcon: YES autolaunch: YES];
		application = appAutoLaunch;
	} else if (application) {
		[workspace launchApplication: application];
	}

	argEnumerator = [[process arguments] objectEnumerator];
	[argEnumerator nextObject];	// skip zeroth entry
	while((arg = [argEnumerator nextObject])) {
		NSString	*ext = [arg pathExtension];
		BOOL		isDir = NO;
		BOOL		exists = NO;

		if ([arg isEqualToString: @"-h"] || [arg isEqualToString: @"--help"]) {
			printf ("%s - open files\n", [processName cString]);
			printf ("Usage: %s [ options ] filename ...\n", [processName cString]);
			printf (
"Options:\n"
"	-a APP		Specify an application to use for opening the file(s)\n"
"			(App will be launched if it is not running)\n"
"	-A APP		Like -a, but app will be run as if on startup\n"
"			(Some apps do different things if \"Autolaunched\")\n"
"	-h, --help	Display this help and exit\n"
"	-o		Accepted for backward compatibility. Does nothing.\n"
"	-p		Causes the file(s) to be printed instead of opened.\n"
"	-NSHost HOST	Try to open the file on the specified host\n"
			);
			exit (0);
		}

		if ([arg isEqualToString: @"-o"])	// ignored, this is the default
			continue;

		if ([arg isEqualToString: @"-p"]) {
			printf ("%s: Printing not implemented.\n", [processName cString]);
			continue;
		}

		if ([arg isEqualToString: @"-a"]	// skip it, handled already
				|| [arg isEqualToString: @"-A"]	// ditto
				|| [arg isEqualToString: @"-NSHost"]) {

			arg = [argEnumerator nextObject];
			continue;
		}

NS_DURING
		if ([ext isEqualToString: @"app"]	// is it an app?
				|| [ext isEqualToString: @"debug"]
				|| [ext isEqualToString: @"profile"]) {
			if (![workspace launchApplication: arg]) {
				NSString	*appName = [[arg lastPathComponent] stringByDeletingPathExtension];
				NSString	*executable = [arg stringByAppendingPathComponent: appName];

				if ([fm fileExistsAtPath: arg]) {
					if (![NSTask launchedTaskWithLaunchPath: executable arguments: nil])
						printf ("Unable to launch: %s", [arg cString]);
				}
			}
			continue;
		}

		// standardize the path
		if (![arg isAbsolutePath])
			arg = [[[fm currentDirectoryPath]
					stringByAppendingPathComponent: arg]
					stringByStandardizingPath];

//		printf ("Filename: %s\n", [arg cString]);

		if (!(exists = [fm fileExistsAtPath: arg isDirectory: &isDir])) {
			printf ("%s: File \"%s\" not found.\n", [processName cString], [arg cString]);
			continue;
		}

		if (application) {
			[workspace openFile: arg withApplication: application];
			continue;
		}

		if (!isDir && [fm isExecutableFileAtPath: arg]) {
			[workspace openFile: arg withApplication: terminal];
			continue;
		}

		if (![workspace openFile: arg]) {	// run Editor application
			[workspace openFile: arg withApplication: editor];
		}
NS_HANDLER
		NSLog (@"Exception while attempting open file %@ - %@: %@",
				arg, [localException name], [localException reason]);
		return 1;
NS_ENDHANDLER
	}

	[pool release];

	return 0;
}
