/*
	ClockView.h

	A digital clock view

	Copyright (C) 2002 Dusk to Dawn Computing, Inc.

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	23 Jun 2002

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

	$Id$
*/
#ifndef PA_M_Time_ClockView_h
#define PA_M_Time_ClockView_h

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <Foundation/NSCalendarDate.h>

#include <AppKit/NSNibDeclarations.h>
#include <AppKit/NSView.h>

@interface ClockView: NSView
{
	IBOutlet BOOL		drawsTile;
	IBOutlet NSImage	*tileImage;

	NSTimer		*timer;


	NSImage		*colon;
	NSImage		*mask;
	NSImage		*min1, *min2;
	NSImage		*hour1, *hour2, *ampm;
	NSImage		*dom1, *dom2, *dow;
	NSImage		*month;

	int			_sec, lastsec;
	int			_min, lastmin;
	int			_hour, lasthour;
	int			_dow, _dom, lastdom;
	int			_month, lastmonth;

	BOOL		use24Hours, last24;
	BOOL		isAnalog;
	BOOL		hasSecondHand, lastSecHand;
}

- (BOOL) drawsTile;
- (BOOL) uses24Hours;
- (BOOL) isAnalog;
- (BOOL) hasAnalogSecondHand;

- (void) setDate: (NSCalendarDate *) aDate;

- (void) setAnalog: (BOOL) flag;
- (void) setAnalogSecondHand: (BOOL) flag;
- (void) setDrawsTile: (BOOL) flag;
- (void) setUses24Hours: (BOOL) flag;

@end

#endif	// PA_M_Time_ClockView_h
