/*
	BBClockView.m

	A general clock view using delegation for drawing

	Copyright (C) 2004 Dusk to Dawn Computing

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	29 Jan 2004

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
#include <Foundation/NSCalendarDate.h>
#include <Foundation/NSTimer.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSImage.h>
#include <AppKit/PSOperators.h>

#include "BBClockView.h"

@implementation BBClockView (Private)

- (BOOL) acceptsFirstMouse: (NSEvent *)anEvent
{
	return YES;
}

- (void) mouseDown: (NSEvent *)event
{
	if ([event clickCount] >= 2)
		[NSApp unhide: self];
}

- (void) displayIfNeeded
{
	if ([self needsDisplay])
		[self display];
}

- (BOOL) isOpaque
{
	if (drawsTile)
		return YES;
	return NO;
}

@end

@implementation BBClockView

- (id) initWithFrame: (NSRect)frameRect
{
	if (!(self = [super initWithFrame: frameRect]))
		return nil;

	[self setDrawsTile: YES];
	[self setDate: [NSCalendarDate calendarDate]];
	[self setInterval: 0.5];
	return self;
}

- (void) dealloc
{
	[timer invalidate];
	[timer release];

	DESTROY (tileImage);

	[super dealloc];
}

- (void) setInterval: (double)interval
{
	[timer invalidate];
	[timer release];
	timer = [NSTimer scheduledTimerWithTimeInterval: interval
											 target: self
										   selector: @selector(update:)
										   userInfo: nil
											repeats: YES];
}

- (void) setDate: (NSCalendarDate *)aDate
{
	[delegate setDate: aDate];
}

- (void) drawRect: (NSRect)aRect
{
	NSRect	myRect = [self bounds];

	// draw the tile if told to
	if (drawsTile && tileImage)
		[tileImage compositeToPoint: NSZeroPoint operation: NSCompositeSourceOver];

	[delegate drawRect: myRect];
}

- (void) update: (id)sender
{
	[self setDate: [NSCalendarDate calendarDate]];
}

- (BOOL) drawsTile
{
	return drawsTile;
}

- (void) setDrawsTile: (BOOL)flag
{
	drawsTile = flag;

	if (flag)
		tileImage = [NSImage imageNamed: @"common_Tile"];
	else
		DESTROY (tileImage);
}

- (id) delegate
{
	return delegate;
}

- (void) setDelegateClass: (Class)obj
{
	id temp;

	if (!obj)
		return;

	if (!(temp = [[obj alloc] initWithClockView: self]))
		return;

	if (![temp conformsToProtocol: @protocol(BBClockDelegate)]) {
		[temp release];
		return;
	}

	[delegate release];
	delegate = temp;
}

- (void) showClockConfigPanel: (id)sender
{
}

- (void) preferredClockSet: (id)sender
{
}

- (void) setDelegate: (id)obj
{
	if (obj && [obj conformsToProtocol: @protocol(BBClockDelegate)]) {
		[delegate release];
		[obj setClockView: self];
		delegate = [obj retain];
	}
}

@end
