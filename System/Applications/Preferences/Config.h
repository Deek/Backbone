/*
	Config.h

	Configuration header for Preferences

	Copyright (C) 2003 Dusk to Dawn Computing, Inc.

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	17 Jan 2003

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

#ifndef PREFERENCES_CONFIG_H
# define PREFERENCES_CONFIG_H
# ifdef __GNUC__
#  define RCSID(str) \
	static const __attribute((unused)) char *rcsid = (str)
# else
#  define RCSID(str) \
	static const char *rcs_id = (str); \
	static const char *__rcs_id_hack(void) { __rcs_id_hack(); return rcs_id; }
# endif
#endif // PREFERENCES_CONFIG_H
