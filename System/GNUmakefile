include $(GNUSTEP_MAKEFILES)/common.make

export TOP_SRCDIR= $(CURDIR)

include Backbone.make

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
	@-.misc/cvs2cl --stdout -b --utc -U .misc/logNames.txt > $@

distdir: distclean changelog
	@-echo "Making distribution tree for Backbone System v$(BACKBONE_VERSION)"
	@-rm -rf $(distdir)
	@mkdir $(distdir)
	@-chmod 755 $(distdir)
	@echo "	Creating directories..."
	@for dir in $(distdirs); do \
	  mkdir $(distdir)/$$dir; \
	done
	@echo "	Copying files..."
	@for file in $(distfiles); do \
	  if test -d $(here)/$$file; then \
	    cp -pr $(here)/$$file $(distdir)/$$file; \
	  else \
	    test -f $(distdir)/$$file \
	    || ln $(here)/$$file $(distdir)/$$file 2> /dev/null \
	    || cp -p $(here)/$$file $(distdir)/$$file || :; \
	  fi; \
	done

distro: distdir
	-chmod -R a+r $(distdir)
	tar -cho $(distdir) | gzip -9 > $(distdir).tar.gz
	tar -cho $(distdir) | bzip2 -9 > $(distdir).tar.bz2
	-rm -rf $(distdir)

.PHONY: changelog ChangeLog distdir distro
