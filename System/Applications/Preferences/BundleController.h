/*
	BundleController.h

	Bundle manager class and protocol

	Copyright (C) 2001 Dusk to Dawn Computing, Inc.
	Additional copyrights here

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	20 Nov 2001

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

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSObject.h>

//#import "PrefsView.h"
#import <PrefsModule/PrefsModule.h>

/*
	Bundle Delegate protocol

	App controllers need to adopt this protocol to receive notifications
*/
@class BundleController;			// forward reference so the compiler doesn't get confused

@interface BundleController: NSObject
{
	id				delegate;
	NSMutableArray	*loadedBundles;
}

+ (BundleController *) sharedBundleController;

- (id) init;
- (void) dealloc;

- (id) delegate;
- (void) setDelegate: (id) aDelegate;

- (BOOL) loadBundleInPath: (NSString *) path;
- (void) loadBundles;

- (NSArray *) loadedBundles;

@end
