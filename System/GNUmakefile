include $(GNUSTEP_MAKEFILES)/common.make

export TOP_SRCDIR= $(CURDIR)

include Backbone.make

# Additional flags to pass to the C compiler
ADDITIONAL_OBJCFLAGS += -Wall
ADDITIONAL_CFLAGS += -Wall
ifeq ($(werror), yes)
ADDITIONAL_OBJCFLAGS += -Werror
ADDITIONAL_CFLAGS += -Werror
endif

# work around gcc 3.3 strict-aliasing bug in selector handling
ifeq ($(shell $(CC) -dumpversion | cut -d. -f1,2), 3.3)
ADDITIONAL_OBJCFLAGS += -fno-strict-aliasing
endif

# work around gcc 4.1 bug in constant strings
ifeq ($(shell $(CC) -dumpversion | cut -d. -f1,2), 4.1)
ADDITIONAL_OBJCFLAGS += -Wno-unused-variable
endif

export ADDITIONAL_OBJCFLAGS
export ADDITIONAL_CFLAGS

SUBPROJECTS= \
	Frameworks/PrefsModule \
	\
	Fonts \
	Applications/Preferences \
	Applications/Terminal \
	Applications/TextEdit \
	\
	Tools/open

include $(GNUSTEP_MAKEFILES)/aggregate.make

here=		$(shell pwd)
distdir=	Backbone-System-$(BACKBONE_VERSION)

distfiles :=	$(shell find . -type f -print | egrep -ve '($(distdir)|CVS|/\..*$$|\.tar\..*$$)')
distdirs :=	$(shell find . -type d -print | egrep -ve '($(distdir)|CVS|/\..*$$|^\.$$)')

changelog: ChangeLog
ChangeLog:
	@-echo "Creating ChangeLog from CVS. This may take some time..."
	@-perl -w .misc/cvs2cl --stdout -b --utc -U .misc/logNames.txt > $@

distdir: distclean changelog
	@-echo "Making distribution tree for Backbone System v$(BACKBONE_VERSION)"
	@-rm -rf $(distdir)
	@mkdir $(distdir)
	@-chmod 755 $(distdir)
	@echo "	Creating directories..."
	@for dir in $(distdirs); do \
	  mkdir "$(distdir)/$$dir"; \
	done
	@echo "	Copying files..."
	@for file in $(distfiles); do \
	  if test -d "$(here)/$$file"; then \
	    cp -pr "$(here)/$$file" "$(distdir)/$$file"; \
	  else \
	    test -f "$(distdir)/$$file" \
	    || ln "$(here)/$$file" "$(distdir)/$$file" 2> /dev/null \
	    || cp -p "$(here)/$$file" "$(distdir)/$$file" || :; \
	  fi; \
	done

distro: distdir
	-chmod -R a+r $(distdir)
	tar -ch $(distdir) | gzip -9 > $(distdir).tar.gz
	tar -ch $(distdir) | bzip2 -9 > $(distdir).tar.bz2
	-rm -rf $(distdir)

.PHONY: changelog ChangeLog distdir distro
