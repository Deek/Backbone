/*
	open.m

	Open files and/or programs

	Copyright (C) 2001 Free Software Foundation, Inc.
	Copyright (C) 2001-2003 Jeff Teunissen <deek@d2dc.net>

	Author:	Jeff Teunissen <deek@d2dc.net>
	Created: November 2001

	Originally based on "gopen", by Gregory Casamento <greg_casamento@yahoo.com>

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
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSFileHandle.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSValue.h>

#include <AppKit/NSApplication.h>

#include "BBFileOpener.h"
#include "open.h"

NSAutoreleasePool	*pool = nil;
NSFileManager		*fm = nil;
NSProcessInfo		*process = nil;
BBFileOpener		*opener = nil;

/*
	Variables for the application to be used.

	appName is the current app to contact. Can validly be nil.
	appNameForced is YES when specific app was forced by program name
	or the -a argument.
*/
NSString			*appName = nil;
BOOL				appNameForced = NO;

/*
	printFiles is YES when -p has been used, and is only disabled by -o.
	waitForFileChanged is YES when forced by program name or the --wait argument
*/
BOOL				printFiles = NO;
BOOL				waitForFileChanged = NO;
BOOL				appAutolaunch = NO;

/*
	FIXME: Only partially implemented

	Opening files as other types. This requires symlinks unless stdin is used.
	That's why only stdin is currently implemented for this feature
	-- I'm not sure how best to handle it. Should these always be opened as
	temp files?
*/
BOOL				openAs = NO;
NSString			*openAsType = nil;

/* prototypes */
id connectToApp (NSString *appName, NSString *hostName);
BOOL openWithApp (NSString *appName, NSString *host, NSString *file, BOOL print, BOOL temp);

int
doStdInput (NSString *name)
{
	NSFileHandle	*fh = [NSFileHandle fileHandleWithStandardInput];
	NSData			*data = [fh readDataToEndOfFile];
	NSNumber		*pid = [NSNumber numberWithInt: [process processIdentifier]];
	NSString		*tempFile = [NSTemporaryDirectory () stringByAppendingPathComponent: name];

	// FIXME: this is NOT secure!
	tempFile = [tempFile stringByAppendingString: [pid stringValue]];

	if (openAs && [openAsType length]) {
		tempFile = [tempFile stringByAppendingPathExtension: openAsType];
	} else {
		char			buffer[8];
		int				dataLength;

		memset (buffer, '\0', sizeof (buffer));
		if ([data length] > sizeof (buffer) - 1)
			[data getBytes: buffer length: sizeof (buffer) - 1];
		else
			[data getBytes: buffer length: [data length]];

		dataLength = strlen (buffer);

		if (dataLength >= 5 && !strncmp (buffer, "{\\rtf", 5)) {
			tempFile = [tempFile stringByAppendingPathExtension: @"rtf"];
		}
	}

	[data writeToFile: tempFile atomically: YES];

	if (appNameForced) {
		if (![opener openTempFile: tempFile withApp: appName])
			return 1;

		return 0;
	} else {
		if (![opener openTempFile: tempFile])
			if (![opener openFile: tempFile])
				return 1;
	}

	return 0;
}

BOOL
redirectStdError (char *filename)
{
	signed int	fd = -1;

	if ((fd = open (filename, O_WRONLY)) < 0)
		return NO;
	close (2);
	dup2 (fd, 2);
	return YES;
}

void
usage (NSString *name, NSString *desc)
{
	if (!name || !desc)
		abort();

	printf ("Usage: %s %s\n", [name cString], [desc cString]);
	printf (
"Options:\n"
"	-a APP		Specify an application to use for opening the file(s).\n"
"			(APP will be launched if it is not running.)\n"
"	-A APP		Like -a, only APP won't be launched unless a file is\n"
"			opened.\n"
"	-s		If an app is launched, it will be run as if on startup.\n"
"			(Some apps do different things if \"Autolaunched\".)\n"
"	-o		Cause following files to be opened (this is the\n"
"			default).\n"
"	-p		Cause following files to be printed instead of opened.\n"
"	-h, --help	Display this help and exit\n"
	);
	exit (0);
}

/*
	checkArgs (name, args)

	Checks the arguments and the program name. Returns the processing mode to
	be used by the main function.

	NOTE: This function modifies the object pointed to by its second argument.
*/
int
checkArgs (NSString *name, NSMutableArray *args)
{
	NSString	*desc = @"[ options ] FILE ...";
	BOOL		doHelp = NO;
	int 		progMode = PM_OPEN;

	[args removeObjectAtIndex: 0];	// remove app name from args

	if (![name isEqualToString: @"open"]) {	// not being called as open
		if ([name isEqualToString: @"openapp"] || [name isEqualToString: @"run"]) {
			progMode = PM_OPENAPP;
			desc = @"Application [ options ] FILE...";

			if ([args count] < 1) {
				doHelp = YES;
				printf ("%s error: not enough arguments\n", [name cString]);
			} else {
				NSString	*newAppName = [args objectAtIndex: 0];
				NSString	*tmp = newAppName;
				NSString	*ext = [newAppName pathExtension];
				BOOL		exists, isDir;

				/*
					First, check for absolute path.
					Second, check for app in current directory.
					Finally, try passing it off to the opener.
				*/
				// standardize the path
				if (![newAppName isAbsolutePath]) {
					tmp = [[[fm currentDirectoryPath]
							stringByAppendingPathComponent: newAppName]
							stringByStandardizingPath];
				}

				exists = [fm fileExistsAtPath: tmp isDirectory: &isDir];
				if (exists && isDir
						&& ([ext isEqualToString: @"app"]
							|| [ext isEqualToString: @"debug"]
							|| [ext isEqualToString: @"profile"])) {	// got it
				}

				if ([ext isEqualToString: @"app"]	// is it an app?
						|| [ext isEqualToString: @"debug"]
						|| [ext isEqualToString: @"profile"]) {
				}

				if (![opener openApp: newAppName]) {	// look for it ourselves

					printf ("%s: could not contact application: %s\n", [name cString], [appName cString]);
					exit (1);
				}

				appName = [newAppName retain];
				appNameForced = YES;
				[args removeObjectAtIndex: 0];
			}
		} else if ([name isEqualToString: @"open-as"]) {
			progMode = PM_OPEN_AS;
			desc = @"FileType [ options ] FILE...";

			if ([args count] < 2) {
				doHelp = YES;
				printf ("%s: not enough arguments\n", [name cString]);
			} else {
				openAs = YES;
				openAsType = [args objectAtIndex: 0];
				[args removeObjectAtIndex: 0];
			}
		} else if ([name hasSuffix: @".client"]) {
			progMode = PM_APP;
			appName = [name stringByDeletingPathExtension];
			if (![opener openApp: appName]) {
				printf ("%s: could not contact application: %s\n", [name cString], [appName cString]);
				exit (1);
			}
			appNameForced = YES;
			waitForFileChanged = YES;
		} else {
			progMode = PM_APP;
			appName = name;
			if (![opener openApp: appName]) {
				printf ("%s: could not contact application: %s\n", [name cString], [appName cString]);
				exit (1);
			}
			appNameForced = YES;
		}
	}

	// If there is a "help" arg anywhere on the command-line, only do help.
	if (doHelp
			|| [args indexOfObject: @"-h"] != NSNotFound
			|| [args indexOfObject: @"--help"] != NSNotFound) {
		usage (name, desc);
	}

	return progMode;
}

int
main (int argc, char** argv, char **env)
{
	NSMutableArray	*args = [[[NSProcessInfo processInfo] arguments] mutableCopy];
	NSEnumerator	*argEnumerator = nil;
	NSString		*arg = nil;
	NSString		*processName = nil;

	int				programMode;

	pool = [NSAutoreleasePool new];	// create the autorelease pool

	process = [NSProcessInfo processInfo];
	fm = [NSFileManager defaultManager];
	opener = [BBFileOpener fileOpener];

	// Check the name of the process for the names we recognize
	processName = [process processName];
	programMode = checkArgs (processName, args);

	if (!redirectStdError ("/dev/null")) {
		printf ("%s: error redirecting stderr: %s\n", [processName cString], strerror (errno));
		return 1;
	}
	
	// Process options...
#if 0
	if ([args count] == 0)	// stdin, open it with editor and don't do anything further
		return doStdInput (processName);
#endif

	argEnumerator = [args objectEnumerator];
	while((arg = [argEnumerator nextObject])) {
		NSString	*ext = [arg pathExtension];
		BOOL		isDir = NO;
		BOOL		exists = NO;

		if ([arg isEqualToString: @"-"]) {	// special filename
			return doStdInput (processName);
			break;
		}

		if ([arg isEqualToString: @"-o"]) {	// this is the default
			printFiles = NO;
		}

		if ([arg isEqualToString: @"-p"]) {
			printFiles = YES;
			continue;
		}

		/*
			We can't send -unhide: commands to app, they get dropped by the
			GSListener managing its DO connection.
		*/
#if 0
		if ([arg isEqualToString: @"--unhide"]) {
			if (!(app = [opener openApp: arg])) {
				printf ("%s: could not contact application: %s\n", [processName cString], [appName cString]);
				break;
			}

			[app unhide: nil];
			continue;
		}
#endif

		if ([arg isEqualToString: @"-s"]) {
			[opener setAutolaunch: YES];
			continue;
		}

		if ([arg isEqualToString: @"-a"]) {	// launch, set app for following
			id		newAppName = [argEnumerator nextObject]; // eat the next arg

			if (!newAppName) {
				printf ("%s: no appname given for -a\n", [processName cString]);
				break;
			}

			appNameForced = YES;
			[appName release];
			appName = [newAppName retain];

			if (![opener openApp: newAppName]) {
				printf ("%s: could not contact application: %s\n", [processName cString], [appName cString]);
				break;
			}

			continue;
		}

		if ([arg isEqualToString: @"-A"]) {	// set the app for following files
			id		newAppName = [argEnumerator nextObject]; // eat the next arg

			if (!newAppName) {
				printf ("%s: no appname given for -A\n", [processName cString]);
				break;
			}

			appNameForced = YES;
			appName = newAppName;

			continue;
		}

		// standardize the path
		if (![arg isAbsolutePath]) {
			arg = [[[fm currentDirectoryPath]
					stringByAppendingPathComponent: arg]
					stringByStandardizingPath];
		}

//		printf ("Filename: %s\n", [arg cString]);

		if (!(exists = [fm fileExistsAtPath: arg isDirectory: &isDir])) {
			printf ("%s: file not found: %s\n", [processName cString], [arg cString]);
			continue;
		}

		if ([ext isEqualToString: @"app"]	// is it an app?
			|| [ext isEqualToString: @"debug"]
			|| [ext isEqualToString: @"profile"]) {	// 
			if (![opener openApp: arg]) {
				printf ("%s: unable to launch: %s\n", [processName cString], [arg cString]);
			}
			continue;
		}

		if (appNameForced) {
			if (![opener openFile: arg withApp: appName])
				break;

			continue;
		}

		if (![opener openFile: arg]) {	// use default application(s)
			printf ("%s: unable to open: %s\n", [processName cString], [arg cString]);
			break;
		}

		break;	// should never reach here
	}
	[pool release];
	return 0;
}
