/*
	BBCalClock.h

	A clock delegate that looks like wmCalClock

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
#ifndef PA_M_Time_BBCalClock_h
#define PA_M_Time_BBCalClock_h

#include "BBClockView.h"

@class NSImage;

@interface BBCalClock: NSObject <BBClockDelegate>
{
	id		clock;

	NSImage	*colon;
	NSImage	*mask;
	NSImage	*min1, *min2;
	NSImage	*hour1, *hour2, *ampm;
	NSImage	*dom1, *dom2, *dow;
	NSImage	*month;

	int		_sec, lastsec;
	int		_min, lastmin;
	int		_hour, lasthour;
	int		_dow, _dom, lastdom;
	int		_month, lastmonth;

	BOOL	use24Hours, last24;
}

@end

#endif	// PA_M_Time_BBCalClock_h
