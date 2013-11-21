#ifndef FORKPTY_H_INCLUDED
#define FORKPTY_H_INCLUDED

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#ifdef HAVE_FCNTL_H
# include <fcntl.h>
#endif

#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_SYS_IOCTL_H
# include <sys/ioctl.h>
#endif

#ifdef HAVE_TERMIOS_H
# include <termios.h>
#else
# include <termio.h>
#endif

#ifdef HAVE_PTY_H
# include <pty.h>
#endif
#ifdef HAVE_LIBUTIL_H
# include <libutil.h>
#endif
#ifdef HAVE_UTIL_H
# include <util.h>
#endif

#ifndef HAVE_FORKPTY
int forkpty (int *, char *, const struct termios *, const struct winsize *);
#endif

#endif	// FORKPTY_H_INCLUDED
