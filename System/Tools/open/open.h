/*
	open.h

	Open files and/or programs

	Copyright (C) 2001-2003 Jeff Teunissen <deek@d2dc.net>

	Author:	Jeff Teunissen <deek@d2dc.net>
	Created: 31 Oct 2003

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

		Free Software Foundation
		59 Temple Place - Suite 330
		Boston, MA 02111-1307, USA
*/

#include <Foundation/NSObject.h>

@class NSMutableArray;
@class NSPort;
@class NSString;

/*
	Program modes:
	
	Note: in all cases, if an app is specified that is not already running, it
	will be launched.

	PM_OPEN		the standard. In this mode, the program will act much like the
				standard "open" tool on NeXT.
	PM_OPENAPP	In this mode, the first argument is taken to be the name of an
				application, as if "-a" came before it. Processing continues as
				above.
	PM_OPEN_AS	In this mode, the first argument is taken to be the name of a
				type. Following files are opened as if they were of this type.
*/

#define PM_OPEN		1
#define PM_OPENAPP	2
#define PM_OPEN_AS	3
#define	PM_APP		4
