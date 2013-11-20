include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME=		Colors
BUNDLE_EXTENSION=	.prefs
BUNDLE_INSTALL_DIR=	$(GNUSTEP_LIBRARY)/Preferences

FRAMEWORKS= PrefsModule
include $(TOP_SRCDIR)/Backbone.make

Colors_LANGUAGES= \
	English

Colors_LOCALIZED_RESOURCE_FILES= \
	Color.gorm

Colors_PRINCIPAL_CLASS= \
	Colors

Colors_OBJC_FILES= \
	NSColor+StringHandling.m \
	Colors.m \
	Colors+Utilities.m \
	Colors+Actions.m \
	Colors+TableView.m \
	Preview.m

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
