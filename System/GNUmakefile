include $(GNUSTEP_MAKEFILES)/common.make

export TOP_SRCDIR= $(CURDIR)

include Backbone.make

SUBPROJECTS= \
	Frameworks/PrefsModule \
	\
	Applications/Preferences \
	Applications/Terminal \
	Applications/TextEdit \
	\
	Tools/open

include $(GNUSTEP_MAKEFILES)/aggregate.make

changelog: ChangeLog
ChangeLog:
	cvs2cl --stdout -b --utc -U .misc/logNames.txt > $@

.PHONY: changelog ChangeLog
