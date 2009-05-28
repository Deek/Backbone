include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME=		Keyboard
BUNDLE_EXTENSION=	.prefs
BUNDLE_INSTALL_DIR=	$(GNUSTEP_LIBRARY)/Preferences

FRAMEWORKS= PrefsModule
include $(TOP_SRCDIR)/Backbone.make

Keyboard_LANGUAGES= \
	English

Keyboard_LOCALIZED_RESOURCE_FILES= \
	Keyboard.gorm

Keyboard_OBJC_FILES=	\
	Keyboard.m

Keyboard_HEADERS= \
	Keyboard.h

Keyboard_PRINCIPAL_CLASS= \
	Keyboard

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
