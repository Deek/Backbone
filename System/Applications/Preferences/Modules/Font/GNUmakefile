include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME=		Font
BUNDLE_EXTENSION=	.prefs

BUNDLE_INSTALL_DIR=	$(GNUSTEP_INSTALLATION_DIR)/Library/Preferences

FRAMEWORKS= PrefsModule
include $(TOP_SRCDIR)/Backbone.make

Font_LANGUAGES=	\
	English \
	Russian

Font_LOCALIZED_RESOURCE_FILES= \
	Font.gorm \
	Localizable.strings

Font_OBJC_FILES= \
	Font.m

Font_HEADERS= \
	Font.h

Font_PRINCIPAL_CLASS= \
	Font

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
