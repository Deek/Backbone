/*
**  DefaultsView.h
**
**  Copyright (c) 2002 Fabien VALLON <fabien.vallon@fr.alcove.com>
**                     
**  Author: Fabien VALLON <fabien.vallon@fr.alcove.com>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope thatf it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License
**  along with this program; if not, write to the Free Software
**  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#ifndef PA_M_Defaults_DefaultsView_h
#define PA_M_Defaults_DefaultsView_h

#include <PrefsModule/PrefsModule.h>
#include <AppKit/NSScrollView.h>

@interface DefaultsView: NSView
{
	id				defaultsBrowser;
	id				editTextView;
	id				removeButton;
	id				owner;
	NSScrollView	*scrollView;
}

- (id) initWithOwner: (id) anOwner andFrame: (NSRect) frameRect;
- (id) defaultsBrowser; 
- (id) editTextView;
- (id) remove;

@end

#endif	// PA_M_Defaults_DefaultsView_h
