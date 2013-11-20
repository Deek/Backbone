include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME=		PrefsApp
BUNDLE_EXTENSION=	.prefs
#
# We don't install this bundle, it goes inside the app.
#
BUNDLE_INSTALL_DIR=	none
PrefsApp_STANDARD_INSTALL= no

PrefsApp_RESOURCE_FILES= \
	PrefsApp.gorm

PrefsApp_OBJC_FILES=	\
	PrefsAppView.m \
	PrefsApp.m

PrefsApp_HEADERS= \
	PrefsAppView.h \
	PrefsApp.h

PrefsApp_PRINCIPAL_CLASS= \
	PrefsApp

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
