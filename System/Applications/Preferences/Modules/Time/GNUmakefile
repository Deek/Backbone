include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME=		Time
BUNDLE_EXTENSION=	.prefs
BUNDLE_INSTALL_DIR=	$(GNUSTEP_INSTALLATION_DIR)/Library/Preferences

Time_RESOURCE_FILES= \
	Time.gorm \
	Date-0.tiff Date-1.tiff Date-2.tiff Date-3.tiff Date-4.tiff Date-5.tiff \
		Date-6.tiff Date-7.tiff Date-8.tiff Date-9.tiff \
	Day-1.tiff Day-2.tiff Day-3.tiff Day-4.tiff Day-5.tiff Day-6.tiff \
		Day-7.tiff \
	Mask.tiff \
	Month-01.tiff Month-02.tiff Month-03.tiff Month-04.tiff Month-05.tiff \
		Month-06.tiff Month-07.tiff Month-08.tiff Month-09.tiff \
		Month-10.tiff Month-11.tiff Month-12.tiff \
	Time-0.tiff Time-1.tiff Time-2.tiff Time-3.tiff Time-4.tiff Time-5.tiff \
	Time-6.tiff Time-7.tiff Time-8.tiff Time-9.tiff Time-A.tiff Time-Colon.tiff \
	Time-P.tiff

Time_OBJC_FILES= \
	ClockView.m \
	Time.m

Time_HEADERS= \
	ClockView.h \
	Time.h

Time_PRINCIPAL_CLASS= \
	Time

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble

