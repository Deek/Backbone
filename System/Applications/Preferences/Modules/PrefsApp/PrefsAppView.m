/*
	PrefsAppView.m

	Forge internal preferences view

	Copyright (C) 2001 Dusk to Dawn Computing, Inc.

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	17 Nov 2001

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

#import <AppKit/NSButton.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSColor.h>

#import "PrefsAppView.h"
#import "PrefsApp.h"

@implementation PrefsAppView
/*
	This class shouldn't be necessary. With working "nibs", it isn't.
*/
- (id) initWithOwner: (id) anOwner andFrame: (NSRect) frameRect
{
	id		temp = nil;

	owner = anOwner;

	if ((self = [super initWithFrame: frameRect])) {
		temp = [[NSBox alloc] initWithFrame: NSMakeRect (0, 81, 189, 104)];
		[temp setTitlePosition: NSAtTop];
		[temp setBorderType: NSGrooveBorder];
		[temp setTitle: @"Load modules from"];
		
		[self addSubview: [temp autorelease]];

		bundlesFromUserButton = [[NSButton alloc] initWithFrame: NSMakeRect (20, 149, 150, 16)];
		[bundlesFromUserButton setTitle: @"Personal library path"];
		[bundlesFromUserButton setButtonType: NSSwitchButton];
		[bundlesFromUserButton setImagePosition: NSImageRight];
		[bundlesFromUserButton setTarget: owner];
		[bundlesFromUserButton setAction: @selector(bundlesFromUserButtonChanged:)];
		[self addSubview: [bundlesFromUserButton autorelease]];

		bundlesFromLocalButton = [[NSButton alloc] initWithFrame: NSMakeRect (20, 129, 150, 16)];
		[bundlesFromLocalButton setTitle: @"Local library path"];
		[bundlesFromLocalButton setButtonType: NSSwitchButton];
		[bundlesFromLocalButton setImagePosition: NSImageRight];
		[bundlesFromLocalButton setTarget: owner];
		[bundlesFromLocalButton setAction: @selector(bundlesFromLocalButtonChanged:)];
		[self addSubview: [bundlesFromLocalButton autorelease]];

		bundlesFromNetworkButton = [[NSButton alloc] initWithFrame: NSMakeRect (20, 109, 150, 16)];
		[bundlesFromNetworkButton setTitle: @"Network library path"];
		[bundlesFromNetworkButton setButtonType: NSSwitchButton];
		[bundlesFromNetworkButton setImagePosition: NSImageRight];
		[bundlesFromNetworkButton setTarget: owner];
		[bundlesFromNetworkButton setAction: @selector(bundlesFromNetworkButtonChanged:)];
		[self addSubview: [bundlesFromNetworkButton autorelease]];

		bundlesFromSystemButton = [[NSButton alloc] initWithFrame: NSMakeRect (20, 89, 150, 16)];
		[bundlesFromSystemButton setTitle: @"System library path"];
		[bundlesFromSystemButton setButtonType: NSSwitchButton];
		[bundlesFromSystemButton setImagePosition: NSImageRight];
		[bundlesFromSystemButton setTarget: owner];
		[bundlesFromSystemButton setAction: @selector(bundlesFromSystemButtonChanged:)];
		[self addSubview: [bundlesFromSystemButton autorelease]];

	}
	return self;
}

- (id) bundlesFromUserButton
{
	return bundlesFromUserButton;
}

- (id) bundlesFromLocalButton
{
	return bundlesFromLocalButton;
}

- (id) bundlesFromNetworkButton
{
	return bundlesFromNetworkButton;
}

- (id) bundlesFromSystemButton
{
	return bundlesFromSystemButton;
}

@end
