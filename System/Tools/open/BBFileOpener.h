/*
    BBFileOpener.h

    Class for contacting an application and getting it to open files.

    Copyright (C) 2001-2003 Jeff Teunissen <deek@d2dc.net>

    Author:	Jeff Teunissen <deek@d2dc.net>
    Created: 3 Nov 2003

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

#ifndef Tools_open_BBFileOpener_h
#define Tools_open_BBFileOpener_h

@interface BBFileOpener: NSObject
{
	BOOL  autolaunch;
	BOOL  waitForFileChanged;
	BOOL  fileMustExist;

	NSString        *host;
	NSTimeInterval  timeout;
}

/*
    Returns the shared file opener, or nil if one can't be created.
*/
+ (BBFileOpener *) fileOpener;

/*
    If YES, object will "autolaunch" any apps that are launched.
*/
- (BOOL) autolaunch;
- (void) setAutolaunch: (BOOL)flag;

/*
    If YES, -open*File: calls will block until either the app dies or the file
    is changed/deleted.
*/
- (BOOL) waitsForFileChange;
- (void) setWaitsForFileChange: (BOOL)flag;

/*
    If YES (the default), files must exist for an open attempt to succeed.
*/
- (BOOL) fileMustExist;
- (void) setFileMustExist: (BOOL)flag;

/*
    The number of seconds to wait for a connection to an app. Default is ten
    seconds.
*/
- (NSTimeInterval) connectionTimeout;
- (void) setConnectionTimeout: (NSTimeInterval)seconds;

/*
    Convenience method. Launches an app if it isn't running and checks if it
    can be contacted over DO. This method blocks until either the timeout
    expires, or until the app is contacted.

    Returns an autoreleased proxy if the app is currently reachable,
    otherwise nil.
*/
- (id) openApp: (NSString *)app;

/*
    Open a file, the normal case. If the app does not respond to the open
    command, or if it returns NO (signalling failure), then report back to the
    user.

    if -openFile: is used, Workspace (or NSWorkspace, if Workspace is not
    available) is contacted to find out what application should be used.
    If there is no application that "fits" the file to be opened, then
    either TextEdit or Terminal is used to open the file (depending on
    whether or not it is executable).
    if -*File:withApp: is used, only the named application is tried.
*/
- (BOOL) openFile: (NSString *)file;
- (BOOL) openFile: (NSString *)file withApp: (NSString *)app;

- (BOOL) openTempFile: (NSString *)file;
- (BOOL) openTempFile: (NSString *)file withApp: (NSString *)app;

- (BOOL) printFile: (NSString *)file;
- (BOOL) printFile: (NSString *)file withApp: (NSString *)app;

@end

#endif
