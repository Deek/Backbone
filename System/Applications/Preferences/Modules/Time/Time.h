/*
	Time.h

	Controller class for this bundle

	Copyright (C) 2001 Dusk to Dawn Computing

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	24 Nov 2001

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
#ifndef PA_M_Time_Time_h
#define PA_M_Time_Time_h

#include <Foundation/NSObject.h>

#include <AppKit/NSNibDeclarations.h>
#include <AppKit/NSButton.h>
#include <AppKit/NSTextField.h>

#include <PrefsModule/PrefsModule.h>

@interface Time: NSObject <PrefsModule>
{
	IBOutlet NSButton		*clockUses24HoursButton;
	IBOutlet NSButton		*clockIsAnalogButton;
	IBOutlet NSButton		*clockSecondHandButton;
	IBOutlet NSTextField	*localTimeZoneField;

	IBOutlet id		window;
	IBOutlet id		view;
	IBOutlet id		map;
}

- (IBAction) clockIsAnalogChanged: (id)sender;
- (IBAction) clockSecondHandChanged: (id)sender;
- (IBAction) clockUses24HoursChanged: (id)sender;
- (IBAction) localTimeFieldChanged: (id)sender;

@end

#endif	// PA_M_Time_Time_h
