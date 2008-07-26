/*
	BBClockView.h

	A specialized clock view class

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
#ifndef PA_M_Time_BBClockView_h
#define PA_M_Time_BBClockView_h

@class NSBundle;
@class NSCalendarDate;
@class NSTimer;

#include <AppKit/NSNibDeclarations.h>
#include <AppKit/NSView.h>
@class NSImage;

@protocol BBClockDelegate;

@interface BBClockView: NSView
{
	IBOutlet BOOL		drawsTile;
	IBOutlet NSImage	*tileImage;

	NSTimer	*timer;
	id		delegate;
}

- (void) setDate: (NSCalendarDate *)aDate;

// Action methods for the UI
- (IBAction) preferredClockSet: (id)sender;
- (IBAction) showClockConfigPanel: (id)sender;

- (id) delegate;
- (void) setDelegate: (id)delegate;

- (BOOL) drawsTile;
- (void) setDrawsTile: (BOOL)flag;

// methods for delegates to call
- (void) setInterval: (double)interval;

@end

@protocol BBClockDelegate <NSObject>

/*
	Sent when the clock view is first initialized.

	Save the passed-in value, you'll need it later. :)
*/
- (id) initWithClockView: (BBClockView *)aClockView;

/*
	Sent on delegate selection.
*/
- (void) setClockView: (BBClockView *)aClockView;

/*
	Called when the date/time changes in the timer. If the view needs redisplay,
	send -setNeedsDisplay:YES to the clock view.
*/
- (void) setDate: (NSCalendarDate *)aDate;

/*
	Called from within BBClockView -drawRect:. If the view draws a tile, it will
	already have been drawn.

	aRect will always be the full bounds of the view.
*/
- (void) drawRect: (NSRect)aRect;

@end

#endif	// PA_M_Time_ClockView_h
