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

#import <AppKit/NSBezierPath.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSColor.h>

#import "KeyboardView.h"
#import "Keyboard.h"

@implementation KeyboardView
/*
	This class sucks, and shouldn't be necessary. With working "nibs", it isn't.
*/
- (id) initWithOwner: (id) anOwner andFrame: (NSRect) frameRect
{
	id		label = nil;

	owner = anOwner;

	if ((self = [super initWithFrame: frameRect])) {
		label = [[NSTextField alloc] initWithFrame: NSMakeRect (3, 104, 130, 20)];
		[label setEditable: NO];
		[label setSelectable: NO];
		[label setAllowsEditingTextAttributes: NO];
		[label setImportsGraphics: NO];
		[label setTextColor: [NSColor blackColor]];
		[label setBackgroundColor: [NSColor controlColor]];
		[label setBezeled: NO];
		[label setStringValue: @"Load bundles from:"];
		[self addSubview: [label autorelease]];

#if 0
		bundlesFromUserButton = [[NSButton alloc] initWithFrame: NSMakeRect (160, 138, 150, 20)];
		[bundlesFromUserButton setTitle: @"Personal Library path"];
		[bundlesFromUserButton setButtonType: NSSwitchButton];
		[bundlesFromUserButton setImagePosition: NSImageRight];
		[bundlesFromUserButton setTarget: owner];
		[bundlesFromUserButton setAction: @selector(bundlesFromUserButtonChanged:)];
		[self addSubview: [bundlesFromUserButton autorelease]];

		bundlesFromLocalButton = [[NSButton alloc] initWithFrame: NSMakeRect (160, 115, 150, 20)];
		[bundlesFromLocalButton setTitle: @"Local Library path"];
		[bundlesFromLocalButton setButtonType: NSSwitchButton];
		[bundlesFromLocalButton setImagePosition: NSImageRight];
		[bundlesFromLocalButton setTarget: owner];
		[bundlesFromLocalButton setAction: @selector(bundlesFromLocalButtonChanged:)];
		[self addSubview: [bundlesFromLocalButton autorelease]];

		bundlesFromNetworkButton = [[NSButton alloc] initWithFrame: NSMakeRect (160, 92, 150, 20)];
		[bundlesFromNetworkButton setTitle: @"Networked Library path"];
		[bundlesFromNetworkButton setButtonType: NSSwitchButton];
		[bundlesFromNetworkButton setImagePosition: NSImageRight];
		[bundlesFromNetworkButton setTarget: owner];
		[bundlesFromNetworkButton setAction: @selector(bundlesFromNetworkButtonChanged:)];
		[self addSubview: [bundlesFromNetworkButton autorelease]];

		bundlesFromSystemButton = [[NSButton alloc] initWithFrame: NSMakeRect (160, 69, 150, 20)];
		[bundlesFromSystemButton setTitle: @"System Library path"];
		[bundlesFromSystemButton setButtonType: NSSwitchButton];
		[bundlesFromSystemButton setImagePosition: NSImageRight];
		[bundlesFromSystemButton setTarget: owner];
		[bundlesFromSystemButton setAction: @selector(bundlesFromSystemButtonChanged:)];
		[self addSubview: [bundlesFromSystemButton autorelease]];
#endif

	}
	return self;
}

- (id) firstAlternatePopUp;
{
	return firstAlternatePopUp;
}

- (id) firstCommandPopUp;
{
	return firstAlternatePopUp;
}

- (id) firstControlPopUp;
{
	return firstAlternatePopUp;
}

- (id) secondAlternatePopUp;
{
	return firstAlternatePopUp;
}

- (id) secondCommandPopUp;
{
	return firstAlternatePopUp;
}

- (id) secondControlPopUp;
{
	return firstAlternatePopUp;
}

@end
