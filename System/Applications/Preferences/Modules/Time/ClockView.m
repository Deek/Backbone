/*
	ClockView.m

	A digital clock view

	Copyright (C) 2002 Dusk to Dawn Computing, Inc.
	Additional copyrights here

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	29 Jun 2002

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

#import <Foundation/NSCalendarDate.h>
#import <Foundation/NSTimer.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSImage.h>

#import "ClockView.h"

#define NEW_IMAGE(a) \
	[[NSImage alloc] initWithContentsOfFile: [this_bundle pathForImageResource: (a)]]

static	NSBundle	*this_bundle = nil;

// unchanging images
static	NSImage		*mask = nil;
static	NSImage		*colon = nil;

// changing images
static	NSImage		*min1 = nil, *min2 = nil;
static	NSImage		*hour1 = nil, *hour2 = nil, *ampm = nil;
static	NSImage		*dow = nil,	*dom1 = nil, *dom2 = nil;
static	NSImage		*month = nil;

@implementation ClockView (Private)

+ (void) initialize
{
	this_bundle = [NSBundle bundleForClass: self];
	mask = NEW_IMAGE (@"Mask");
	colon = NEW_IMAGE (@"Time-Colon");
}

- (BOOL) acceptsFirstMouse: (NSEvent *) anEvent
{
	return YES;
}

- (void) mouseDown: (NSEvent *) event
{
	if ([event clickCount] >= 2)
		[NSApp unhide: self];
}

- (void) awakeFromNib
{
	[self setDrawsTile: YES];
	[self setDate: [NSCalendarDate calendarDate]];
	timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
											 target: self
										   selector: @selector(update:)
										   userInfo: nil
											repeats: YES];
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

@implementation ClockView

- (id) init
{
	if (!(self = [super init]))
		return nil;

	return self;
}
- (void) dealloc
{
	[timer invalidate];
	[timer release];

	[mask release];
	[hour1 release];
	[hour2 release];
	[colon release];
	[min1 release];
	[min2 release];
	[dow release];
	[dom1 release];
	[dom2 release];
	[month release];
	[tileImage release];
	[super dealloc];
}

- (void) setDate: (NSCalendarDate *) aDate
{
	static int	lastdom = -1, lastmonth = -1, lasthour = -1, lastmin = -1;
	static BOOL	last24 = NO;

	int		_hour = [aDate hourOfDay];
	int		_min = [aDate minuteOfHour];
	int		_dow = [aDate dayOfWeek];
	int		_dom = [aDate dayOfMonth];
	int		_month = [aDate monthOfYear];

	BOOL	dateChanged = NO;

	if (lastdom != _dom) {
		lastdom = _dom;
		dateChanged = YES;

		[dow release];
		[dom1 release];
		[dom2 release];
		dom1 = nil;

		dow = NEW_IMAGE (([NSString stringWithFormat: @"Day-%d", _dow]));

		if (_dom / 10)
			dom1 = NEW_IMAGE (([NSString stringWithFormat: @"Date-%d", _dom / 10]));

		dom2 = NEW_IMAGE (([NSString stringWithFormat: @"Date-%d", _dom % 10]));
	}

	if (lastmonth != _month) {
		lastmonth = _month;
		dateChanged = YES;

		[month release];
		month = NEW_IMAGE (([NSString stringWithFormat: @"Month-%02d", _month]));
	}

	if (lasthour != _hour || last24 != use24Hours) {
		lasthour = _hour;
		last24 = use24Hours;

		dateChanged = YES;

		[hour1 release];
		[hour2 release];
		hour1 = nil;
		if (use24Hours) {
			hour1 = NEW_IMAGE (([NSString stringWithFormat: @"Time-%d", _hour / 10]));
			hour2 = NEW_IMAGE (([NSString stringWithFormat: @"Time-%d", _hour % 10]));
		} else {
			[ampm release];

			if (_hour > 11) {
				ampm = NEW_IMAGE (@"Time-P");
				_hour -= 12;
			} else {
				ampm = NEW_IMAGE (@"Time-A");
			}

			if (_hour == 0) {
				_hour = 12;
			}
			if (_hour / 10)
				hour1 = NEW_IMAGE (([NSString stringWithFormat: @"Time-%d", _hour / 10]));
			hour2 = NEW_IMAGE (([NSString stringWithFormat: @"Time-%d", _hour % 10]));
		}
	}

	if (lastmin != _min) {
		lastmin = _min;
		dateChanged = YES;

		[min1 release];
		[min2 release];
		min1 = NEW_IMAGE (([NSString stringWithFormat: @"Time-%d", _min / 10]));
		min2 = NEW_IMAGE (([NSString stringWithFormat: @"Time-%d", _min % 10]));
	}

	if (dateChanged)
		[self setNeedsDisplay: YES];
}

- (void) drawRect: (NSRect) aRect
{
	NSSize	maskSize;
	NSPoint	maskLoc;
	NSPoint	location;
	NSRect	bottomInsideRect;
	NSRect	topInsideRect;
	NSRect	tempRect;
	int		width;

	maskSize = [mask size];
	tempRect = NSInsetRect (aRect, (aRect.size.width - maskSize.width) / 2,
							(aRect.size.height - maskSize.height) / 2);
	maskLoc = NSMakePoint (tempRect.origin.x, tempRect.origin.y);

	// Rect defining the inside of the "date" area
	bottomInsideRect = NSMakeRect (tempRect.origin.x + 1,
								   tempRect.origin.y + 1, 54, 35);

	// Rect defining the inside of the "time" area
	topInsideRect = NSMakeRect (tempRect.origin.x + 1,
								tempRect.origin.y + 39, 54, 15);

	// draw the tile and mask
	if (drawsTile && tileImage)
		[tileImage compositeToPoint: NSZeroPoint operation: NSCompositeSourceOver];
	[mask compositeToPoint: maskLoc operation: NSCompositeSourceOver];

	// day of week
	width = [dow size].width + [month size].width;
	tempRect = NSInsetRect (bottomInsideRect,
							(bottomInsideRect.size.width - width) / 2,
							0);

	location.x = tempRect.origin.x + 2;
	location.y = tempRect.origin.y + [dom2 size].height - 4;
	[dow compositeToPoint: location operation: NSCompositeSourceOver];
	location.x += [dow size].width;

	// month name
	[month compositeToPoint: location operation: NSCompositeSourceOver];

	// day of month
	width = [dom2 size].width;
	if (dom1) {
		width += [dom1 size].width;
	}

	tempRect = NSInsetRect (bottomInsideRect,
							(bottomInsideRect.size.width - width) / 2,
							0);

	location.x = tempRect.origin.x + 2;

	if (dom1) {
		location.y = tempRect.origin.y;
		[dom1 compositeToPoint: location operation: NSCompositeSourceOver];
		location.x += [dom1 size].width;
	}
	[dom2 compositeToPoint: location operation: NSCompositeSourceOver];

	/*
		Draw the time
	*/
	if (!use24Hours) {	// skew the clock left for AM/PM display
		topInsideRect.size.width -= [ampm size].width + 1;
		location.x = topInsideRect.origin.x + topInsideRect.size.width;
		location.y = topInsideRect.origin.y +
					(topInsideRect.size.height / 2 - 
					([ampm size].height / 2)) + 1;
		[ampm compositeToPoint: location operation: NSCompositeSourceOver];
	}

	width = 1 + [hour2 size].width + 1
			+ [colon size].width + 1
			+ [min1 size].width + 1
			+ [min2 size].width;

	if (hour1)
		width += [hour1 size].width + 1;

	tempRect = NSInsetRect (topInsideRect,
							(topInsideRect.size.width - width) / 2,
							1);

	location.x = tempRect.origin.x;

	if (hour1) {
		location.y = tempRect.origin.y +
					(tempRect.size.height / 2 - 
					([hour1 size].height / 2)) + 1;
		[hour1 compositeToPoint: location operation: NSCompositeSourceOver];
		location.x += [hour1 size].width + 1;
	}

	location.y = tempRect.origin.y +
				(tempRect.size.height / 2 - 
				([hour2 size].height / 2)) + 1;
	[hour2 compositeToPoint: location operation: NSCompositeSourceOver];
	location.x += [hour2 size].width + 1;

	location.y = tempRect.origin.y +
				(tempRect.size.height / 2 - 
				([colon size].height / 2));
	[colon compositeToPoint: location operation: NSCompositeSourceOver];
	location.x += [colon size].width + 1;

	location.y = tempRect.origin.y +
				(tempRect.size.height / 2 - 
				([min1 size].height / 2)) + 1;
	[min1 compositeToPoint: location operation: NSCompositeSourceOver];
	location.x += [min1 size].width + 1;

	location.y = tempRect.origin.y +
				(tempRect.size.height / 2 - 
				([min2 size].height / 2)) + 1;
	[min2 compositeToPoint: location operation: NSCompositeSourceOver];
}

- (void) update: (id) sender
{
	[self setDate: [NSCalendarDate calendarDate]];
}

- (BOOL) drawsTile
{
	return drawsTile;
}

- (void) setDrawsTile: (BOOL) flag
{
	drawsTile = flag;

	if (flag)
		tileImage = [NSImage imageNamed: @"common_Tile"];
	else
		DESTROY (tileImage);
}

- (BOOL) uses24Hours
{
	return use24Hours;
}

- (void) setUses24Hours: (BOOL) flag
{
	use24Hours = flag;
}

@end
