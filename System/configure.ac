#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.59c])
AC_INIT([Backbone], [0.1.0],,, [http://backbone.nongnu.org/])
AC_LANG([Objective C])
AC_CONFIG_SRCDIR([Backbone.make.in])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_OBJC
AC_PROG_OBJCPP
AC_PROG_GREP
AC_PROG_SED

# declare some functions
AC_DEFUN([BB_OBJC_OPTION_TEST], [
AC_MSG_CHECKING([whether $OBJC accepts $1])
save_OBJCFLAGS="$OBJCFLAGS"
OBJCFLAGS="$OBJCFLAGS $1"
bb_opt_ok=no
AC_TRY_COMPILE(
	[],
	[],
	bb_opt_ok=yes
	AC_MSG_RESULT([yes]),
	AC_MSG_RESULT([no])
)
OBJCFLAGS="$save_OBJCFLAGS"
if test "x$bb_opt_ok" = xyes; then
	true
	$2
else
	true
	$3
fi
])

AC_DEFUN([BB_OBJC_OPTION], [
BB_OBJC_OPTION_TEST([$1], [OBJCFLAGS="$OBJCFLAGS $1"])
])

# Checks for compiler characteristics
if test "x$GOBJC" = xyes; then
	set $OBJC
	shift
	args="$*"
	AC_MSG_CHECKING([$OBJC version])
	OBJCVER="`$OBJC --version | grep '[[0-9]]\.[[0-9]]' | sed -e 's/.*(GCC)//' -e 's/[[^0-9]]*\([[0-9.]]*\).*/\1/'`"
	set $OBJCVER
	save_IFS="$IFS"
	IFS="."
	set $1
	OBJC_MAJ=$1
	OBJC_MIN=$2
	OBJC_SUB=$3
	IFS="$save_IFS"
	AC_MSG_RESULT($OBJCVER)

	BB_OBJC_OPTION([-std=gnu99])

	AC_MSG_CHECKING([for broken $OBJC versions])
	if test $OBJC_MAJ -eq 3 -a $OBJC_MIN -eq 3; then
		AC_MSG_RESULT([yes, 3.3])
		BB_OBJC_OPTION([-fno-strict-aliasing])
	elif test "$OBJC_MAJ" -eq 4 -a "$OBJC_MIN" -eq 1; then
		AC_MSG_RESULT([yes, 4.1])
		BB_OBJC_OPTION([-Wno-unused-variable])
	else
		AC_MSG_RESULT([no, hooray!])
	fi
fi

# Checks for libraries.

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS(
	[sys/ioctl.h termios.h termio.h pcap.h stropts.h]
)

# Checks for typedefs, structures, and compiler characteristics.
#AC_TYPE_SIZE_T

# Checks for library functions.
AC_CHECK_FUNCS([foo])

FORKPTY_LIBS=""
AC_CHECK_FUNC([forkpty], FORKPTY=yes, FORKPTY=no)
if test "$FORKPTY" = "yes"; then
	AC_CHECK_HEADER([pty.h], HAVE_PTY_H=yes, HAVE_PTY_H=no)
	if test "$HAVE_PTY_H" = "yes"; then
		AC_DEFINE([HAVE_PTY_H], 1, [Define if <pty.h> works])
	fi
else
	AC_CHECK_LIB([util], [forkpty], FORKPTY_IN_LIBUTIL=yes, FORKPTY_IN_LIBUTIL=no)
	if test "$FORKPTY_IN_LIBUTIL" = "yes"; then
		AC_CHECK_HEADER([libutil.h], HAVE_LIBUTIL_H=yes, HAVE_LIBUTIL_H=no)
		AC_CHECK_HEADER([pty.h], HAVE_PTY_H=yes, HAVE_PTY_H=no)

		if test "$HAVE_LIBUTIL_H" = "yes"; then
			FORKPTY_LIBS="-lutil"
			AC_DEFINE([HAVE_LIBUTIL_H], 1, [Define if <libutil.h> works])
		fi
		if test "$HAVE_PTY_H" = "yes"; then
			AC_DEFINE([HAVE_PTY_H], 1, [Define if <pty.h> works])
		fi
	fi
fi
AC_SUBST([FORKPTY_LIBS])

# Make sure that GNUSTEP_MAKEFILES is set.
# First, try the "gnustep-config" program which should be in the path somewhere.
# If that fails, try sourcing the GNUstep.conf file (which should be a legal Make fragment).
# Finally, just give up and assume the default value.
AC_PATH_PROG([GSCONFIG], [gnustep-config], [no])
AC_MSG_CHECKING([for gnustep-make])
if test "z$GSCONFIG" != "xno"; then
	AS_VAR_SET([GNUSTEP_MAKEFILES], m4_chomp_all([`"$GSCONFIG" --variable=GNUSTEP_MAKEFILES`]))
fi
if test -n "$GNUSTEP_MAKEFILES" -a -d "$GNUSTEP_MAKEFILES"; then
	AC_MSG_RESULT([$GNUSTEP_MAKEFILES])
elif test -f /etc/GNUstep/GNUstep.conf; then
	AS_VAR_SET([GNUSTEP_MAKEFILES], m4_chomp_all([`eval . /etc/GNUstep/GNUstep.conf; echo $GNUSTEP_MAKEFILES`]))
	if test -n "$GNUSTEP_MAKEFILES" -a -d "$GNUSTEP_MAKEFILES"; then
		AC_MSG_RESULT([$GNUSTEP_MAKEFILES])
	else
		GNUSTEP_MAKEFILES=/usr/GNUstep/Library/Makefiles
		if test "x$GNUSTEP_MAKEFILES" != "x" -a -d "$GNUSTEP_MAKEFILES"; then
			AC_MSG_RESULT([$GNUSTEP_MAKEFILES])
		else
			AC_MSG_ERROR([Can't find GNUstep makefile package!])
		fi
	fi
fi
AC_SUBST([GNUSTEP_MAKEFILES])

AC_CONFIG_FILES([
	GNUmakefile
	Backbone.make
	Applications/Terminal/GNUmakefile
	Applications/TextEdit/GNUmakefile
	Applications/Preferences/GNUmakefile
	Applications/Preferences/Modules/Time/GNUmakefile
	Applications/Preferences/Modules/Font/GNUmakefile
	Applications/Preferences/Modules/Defaults/GNUmakefile
	Applications/Preferences/Modules/PrefsApp/GNUmakefile
	Applications/Preferences/Modules/Keyboard/GNUmakefile
	Applications/Preferences/Modules/Colors/GNUmakefile
	Frameworks/PrefsModule/GNUmakefile
	Fonts/GNUmakefile
	Tools/open/GNUmakefile
])

AC_CONFIG_FILES([stamp-h], [echo timestamp > stamp-h])

AC_OUTPUT

#ifdef __NetBSD__
#  include <sys/types.h>
#  include <sys/ioctl.h>
#  include <termios.h>
#  include <pcap.h>
#else
#ifdef freebsd
#  include <sys/types.h>
#  include <sys/ioctl.h>
#  include <termios.h>
#  include <libutil.h>
#  include <pcap.h>
#else
#  include <termio.h>
#endif
#endif

#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#ifndef freebsd
#ifndef __NetBSD__
#  include <pty.h>
#endif
#endif

