include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME=		Keyboard
BUNDLE_EXTENSION=	.prefs

BUNDLE_INSTALL_DIR=	$(GNUSTEP_INSTALLATION_DIR)/Library/Preferences

Keyboard_RESOURCE_FILES= \
	Keyboard.gorm

Keyboard_OBJC_FILES=	\
	KeyboardView.m \
	Keyboard.m

Keyboard_HEADERS= \
	KeyboardView.h \
	Keyboard.h

Keyboard_PRINCIPAL_CLASS= \
	Keyboard

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
