include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME=		Colors
BUNDLE_EXTENSION=	.prefs

BUNDLE_INSTALL_DIR=	$(GNUSTEP_INSTALLATION_DIR)/Library/Preferences

FRAMEWORKS= PrefsModule
include $(TOP_SRCDIR)/Backbone.make

Colors_LANGUAGES=	\
	English 

Colors_LOCALIZED_RESOURCE_FILES= \
	Colors.gorm 

Colors_OBJC_FILES= \
	Colors.m Colors+Actions.m Colors+Utilities.m Colors+TableView.m Preview.m NSColor+str.m

Colors_HEADERS= \
	Colors.h Preview.h NSColor+str.h

Colors_PRINCIPAL_CLASS= \
	Colors

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
