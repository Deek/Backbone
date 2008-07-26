/*
	BBClassicAnalog.m

	A clock delegate that looks like the old NeXT analog clock

	Copyright (C) 2004 Dusk to Dawn Computing

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	28 Jan 2004

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
#include <Foundation/NSBundle.h>
#include <Foundation/NSCalendarDate.h>

#include <AppKit/NSColor.h>
#include <AppKit/NSImage.h>
#include <AppKit/PSOperators.h>

#include "BBClassicAnalog.h"

#define NEW_IMAGE(a) \
	[[NSImage alloc] initWithContentsOfFile: [this_bundle pathForImageResource: (a)]]

static	NSBundle	*this_bundle = nil;

@implementation BBClassicAnalog (Private)

+ (void) initialize
{
	this_bundle = [NSBundle bundleForClass: self];
}

@end

@implementation BBClassicAnalog

- (id) initWithClockView: (BBClockView *)aClockView
{
	if (!(self = [super init]) || !aClockView)
		return nil;

	lastdom = lastmonth = lasthour = lastmin = lastsec = -1;
	last24 = NO;

	clock = aClockView;

	mask = NEW_IMAGE (@"AnalogMask");

	[self setDate: [NSCalendarDate calendarDate]];
	[clock setInterval: 0.5];

	return self;
}

- (void) dealloc
{
	DESTROY (mask);

	[super dealloc];
}

- (void) setAnalogSecondHand: (BOOL)flag
{
	hasSecondHand = flag;
}

- (void) setClockView: (BBClockView *)aClockView
{
	ASSIGN (clock, aClockView);

	[self setDate: [NSCalendarDate calendarDate]];
	[clock setInterval: 0.5];
	[clock setNeedsDisplay: YES];
}

- (void) setDate: (NSCalendarDate *)aDate
{
	BOOL	dateChanged = NO;

	_sec = [aDate secondOfMinute];
	_min = [aDate minuteOfHour];
	_hour = [aDate hourOfDay];
	_dow = [aDate dayOfWeek];
	_dom = [aDate dayOfMonth];
	_month = [aDate monthOfYear];

	lastdom = lastmonth = -1;

	if (lasthour != _hour || last24 != use24Hours) {
		lasthour = _hour;
		last24 = use24Hours;

		dateChanged = YES;
	}

	if (lastmin != _min) {
		lastmin = _min;
		dateChanged = YES;
	}

	if (lastSecHand != hasSecondHand) {
		lastSecHand = hasSecondHand;
		dateChanged = YES;
	}

	if (hasSecondHand && lastsec != _sec) {
		lastsec = _sec;
		dateChanged = YES;
	}

	if (dateChanged)
		[clock setNeedsDisplay: YES];

	return;
}

- (void) setUses24Hours: (BOOL)flag
{
	use24Hours = flag;
}

- (void) drawRect: (NSRect)aRect
{
	NSSize	maskSize;
	NSPoint	maskLoc;
	NSRect	tempRect;

	int		centerX, centerY;
	int		secLength, minLength, hourLength;
	float	hourAdvancement;

	maskSize = [mask size];
	tempRect = NSInsetRect (aRect, (aRect.size.width - maskSize.width) / 2,
							(aRect.size.height - maskSize.height) / 2);
	maskLoc = NSMakePoint (tempRect.origin.x, tempRect.origin.y);

	centerX = maskLoc.x + (maskSize.width / 2);
	centerY = maskLoc.y + (maskSize.height / 2);
	secLength = maskSize.height / 2 - 4;
	minLength = maskSize.height / 2 - 8;
	hourLength = maskSize.height / 4;

	// draw the mask
	[mask compositeToPoint: maskLoc operation: NSCompositeSourceOver];

	PStranslate (centerX, centerY);	// set the center as the origin

	hourAdvancement = 360 / ((use24Hours) ? 24 : 12);

	if (hasSecondHand) {
		[[NSColor darkGrayColor] set];

		PSgsave ();
		PSrotate (0 - (_sec * 6.0));
		PSmoveto (0, 0);
		PSlineto (0, secLength);
		PSstroke ();
		PSgrestore ();
	}

	[[NSColor blackColor] set];

	PSgsave ();
	PSrotate (0 - ((_hour * hourAdvancement) + (hourAdvancement * (_min / 60.0))));
	PSmoveto (0, 0);
	PSlineto (0, hourLength);
	PSstroke ();
	PSgrestore ();

	PSgsave ();
	PSrotate (0 - (_min * 6.0));
	PSmoveto (0, 0);
	PSlineto (0, minLength);
	PSstroke ();
	PSgrestore ();
}

@end
