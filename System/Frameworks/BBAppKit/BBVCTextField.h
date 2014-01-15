/*
	BBVCTextFieldCell.h

	A vertically-centering text field

	Author:	Jeff Teunissen <deek@d2dc.net>
	Date:	12 Dec 2013

	This file is part of BBAppKit.

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public License
	as published by the Free Software Foundation; either version 2.1
	of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this program; if not, write to:

		Free Software Foundation
		51 Franklin Street, Fifth Floor
		Boston, MA  02110-1301
		USA
*/
#ifndef _BB_BBAppKit_BBVCTextField_h_
#define _BB_BBAppKit_BBVCTextField_h_

#include <AppKit/NSTextField.h>

/*
	This is a convenience class to more easily use BBVCTextFieldCell.
*/
@interface BBVCTextField: NSTextField
{
	// no new ivars
}

// overridden methods

+ (void) setCellClass: (Class)newClass;
+ (Class) cellClass;

@end

#endif	// _BB_BBAppKit_BBVCTextField_h_
