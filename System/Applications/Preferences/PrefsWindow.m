/*
	PrefsWindow.m

	Preferences panel class

	Copyright (C) 2001 Dusk to Dawn Computing, Inc.

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	11 Nov 2001

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

#import <Foundation/NSGeometry.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSButtonCell.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSMatrix.h>
#import <AppKit/NSScrollView.h>

#import "BundleController.h"
#import "PrefsWindow.h"

@implementation PrefsWindow

- (void) initUI
{
	NSButtonCell	*prototype;
	NSScrollView	*iconScrollView;

	_topTag = 0;	// This is for the matrix

/*
	Window dimensions:

	content view size: (400, 300)

	8-pixel space on all sides
	Box content view is is 265 pixels high, 500 wide
	Scroll area is 86 pixels tall, 500 wide
*/
	/* We're going top to bottom here... */
	// Prototype button for the matrix
	prototype = [[[NSButtonCell alloc] init] autorelease];
	[prototype setButtonType: NSOnOffButton];
	[prototype setImagePosition: NSImageOverlaps];

	// The matrix itself -- horizontal
	prefsViewList = [[NSMatrix alloc] initWithFrame: NSMakeRect (0, 0, 560, 70)];
	[prefsViewList setAllowsEmptySelection: YES];
	[prefsViewList setCellSize: NSMakeSize (70, 70)];
	[prefsViewList setMode: NSRadioModeMatrix];
	[prefsViewList setPrototype: prototype];

	[prefsViewList setAction: @selector(cellWasClicked:)];
	[prefsViewList setTarget: [self windowController]];

	iconScrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect (8, 202, 384, 92)];
	[iconScrollView autorelease];
	[iconScrollView setHasHorizontalScroller: YES];
	[iconScrollView setHasVerticalScroller: NO];
	[iconScrollView setDocumentView: prefsViewList];
	[[self contentView] addSubview: iconScrollView];

	prefsViewBox = [[NSBox alloc] initWithFrame: NSMakeRect (-2, -2, 404, 196)];
	[prefsViewBox setTitlePosition: NSNoTitle];
	[prefsViewBox setBorderType: NSGrooveBorder];
	[prefsViewBox setContentViewMargins: NSMakeSize (8, 8)];
	NSDebugLog (@"prefsViewBox bounds: %@", NSStringFromRect ([[prefsViewBox contentView] bounds]));
	[[self contentView] addSubview: prefsViewBox];
}

- (void) dealloc
{
	NSDebugLog (@"PrefsWindow -dealloc");
	[prefsViewBox release];

	[super dealloc];
}

- (void) addPrefsViewButton: (id <PrefsModule>) aController
{
	NSButtonCell	*button = [[NSButtonCell alloc] init];

	[button setTag: _topTag++];
	[button setButtonType: NSOnOffButton];
	[button setImage: [aController buttonImage]];
	[button setImagePosition: NSImageOnly];
	[button setTarget: aController];
	[button setAction: [aController buttonAction]];
	[prefsViewList addColumnWithCells: [NSArray arrayWithObject: button]];
	[prefsViewList sizeToCells];
	[prefsViewList setNeedsDisplay: YES];
}

- (NSBox *) prefsViewBox
{
	return prefsViewBox;
}

- (NSMatrix *) prefsViewList
{
	return prefsViewList;
}

@end
