#
#	GNUmakefile
#
#	Main makefile for Preferences.app
#
#	Copyright (C) 2002 Jeff Teunissen <deek@d2dc.net>
#
#	This Makefile is free software; you can redistribute it and/or
#	modify it under the terms of the GNU General Public License
#	as published by the Free Software Foundation; either version 2
#	of the License, or (at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#	See the GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to:
#
#		Free Software Foundation, Inc.
#		59 Temple Place - Suite 330
#		Boston, MA  02111-1307, USA
#
#	$Id$

include $(GNUSTEP_MAKEFILES)/common.make

#
# Subprojects
#
SUBPROJECTS=	\
	PrefsModule \
	Modules/Font \
	Modules/Keyboard \
	Modules/Time
#
# Distribution information
#
CVS_MODULE_NAME=	Preferences
CVS_FLAGS=		-d:pserver:anonymous@cvs.quakeforge.net:/cvsroot/prefsapp
#
# Main application
#
PACKAGE_NAME=		Preferences
APP_NAME=		Preferences
VERSION=		1.2.99beta
Preferences_PRINCIPAL_CLASS=	NSApplication
Preferences_APPLICATION_ICON=	Preferences.tiff

#
# Additional libraries
#
ADDITIONAL_GUI_LIBS += 
Preferences_FRAMEWORKS=		-lPrefsModule

#
# Resource files
#
Preferences_MAIN_MODEL_FILE=	Preferences.gorm
Preferences_RESOURCE_FILES= \
	Preferences.tiff \
	PrefsModule.tiff \
	PrefsIcon_Appearances.tiff \
	PrefsIcon_Font.tiff \
	PrefsIcon_Keyboard.tiff \
	PrefsIcon_Localisation.tiff \
	PrefsIcon_Login.tiff \
	PrefsIcon_Mouse.tiff \
	PrefsIcon_Screen.tiff \
	PrefsIcon_SelectSpooler.tiff \
	PrefsIcon_Time.tiff \
	PreferencesInfo.plist

Preferences_LOCALIZED_RESOURCE_FILES= \
	Preferences.gorm \
	Localizable.strings

# Languages we're localized for
Preferences_LANGUAGES= \
	English

#
# Header files
#
Preferences_HEADERS= \
	Config.h \
	BundleController.h \
	Controller.h \
	PrefsController.h

#
# Class files
#
Preferences_OBJC_FILES= \
	BundleController.m \
	Controller.m \
	PrefsController.m \
	main.m

#
# C files
#
Preferences_C_FILES=

-include GNUmakefile.preamble
-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make

-include GNUmakefile.postamble
