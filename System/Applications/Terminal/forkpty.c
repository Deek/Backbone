#ifdef HAVE_CONFIG_H
# include "config.h"
#endif
#ifndef HAVE_FORKPTY
/* forkpty replacement */

#include "forkpty.h"

#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif

#include <stdlib.h>
#include <stdio.h> /* for stderr and perror*/
#include <errno.h> /* for int errno */
#include <fcntl.h>

#include <string.h>

#ifdef HAVE_STROPTS_H
# include <stropts.h>	// for I_PUSH
#endif

#define PATH_TTY "/dev/tty"

#ifndef HAVE_OPENPTY
int
openpty (int *amaster, int *aslave, char *name, const struct termios *termp, const struct winsize *winp)
{
	int   fdm, fds;
	char  *slaveName;

	if ((fdm = open ("/dev/ptmx", O_RDWR)) < 0) {	/* open master */
		perror ("openpty: open(master)");
		return -1;
	}
	if (grantpt (fdm)) {		/* grant access to the slave */
		perror ("openpty: grantpt(master)");
		close (fdm);
		return -1;
	}
	if (unlockpt (fdm)) {		/* unlock the slave terminal */
		perror ("openpty: unlockpt(master)");
		close (fdm);
		return -1;
	}

	if (!(slaveName = ptsname (fdm))) {	/* get name of the slave */
		perror ("openpty: ptsname(master)");
		close (fdm);
		return -1;
	}

	if (name) {	/* if name isn't null, copy slaveName back */
		strcpy (name, slaveName);
	}

	if ((fds = open (slaveName, O_RDWR | O_NOCTTY)) < 0) {	/* open slave */
		perror ("openpty: open(slave)");
		close (fdm);
		return -1;
	}

#ifdef I_PUSH
	/*
		ldterm and ttcompat are automatically pushed on the stack on some
	  	systems, but it's harmless to do it anyway.
	*/
	if (ioctl (fds, I_PUSH, "ptem") < 0) {	/* pseudo terminal module */
		perror ("openpty: ioctl I_PUSH ptem");
		close (fdm);
		close (fds);
		return -1;
	}

	if (ioctl (fds, I_PUSH, "ldterm") < 0) {	/* ldterm atop ptem */
		perror ("openpty: ioctl I_PUSH ldterm");
		close (fdm);
		close (fds);
		return -1;
	}

	if (ioctl (fds, I_PUSH, "ttcompat") < 0) {	/* ttcompat atop ldterm */
		perror ("openpty: ioctl I_PUSH ldterm");
		close (fdm);
		close (fds);
		return -1;
	}
#endif

	/* set terminal parameters if present */
	if (termp) {
		ioctl (fds, TCSETS, termp);
	}
	if (winp) {
		ioctl (fds, TIOCSWINSZ, winp);
	}

	*amaster = fdm;
	*aslave = fds;
	return 0;
}
#endif	// HAVE_OPENPTY

int
ptyMakeControllingTty (int *slaveFd, const char *slaveName)
{
	pid_t	pgid;
	int		fd;

	if (!slaveFd || *slaveFd < 0) {
		perror ("slaveFd invalid");
		return -1;
	}

	/* disconnect from the old controlling tty */
#ifdef TIOCNOTTY
	if ((fd = open (PATH_TTY, O_RDWR | O_NOCTTY)) >= 0) {
		ioctl (fd, TIOCNOTTY, NULL);
		close (fd);
	}
#endif

	pgid = setsid ();	/* create session and set process ID */
	if (pgid == -1) {
		if (errno == EPERM) {
			perror ("EPERM error on setsid");
		}
	}

	/* Make it our controlling tty */
#ifdef TIOCSCTTY
	if (ioctl (*slaveFd, TIOCSCTTY, NULL) == -1) {
		return -1;
	}
#else
	{
		/* first terminal we open after setsid() is the controlling one */
		char  *controllingTty;
		int   ctr_fdes;

		controllingTty = ttyname (*slaveFd);
		ctr_fdes = open (controllingTty, O_RDWR);
		close (ctr_fdes);
	}
#endif	/* TIOCSCTTY */

#if defined (TIOCSPGRP)
	ioctl (0, TIOCSPGRP, &pgid);
#else
# warning no TIOCSPGRP
	tcsetpgrp (0, pgid);
#endif

	if ((fd = open (slaveName, O_RDWR)) >= 0) {
		close (*slaveFd);
		*slaveFd = fd;
		printf ("Got new filedescriptor...\n");
	}

	if ((fd = open (PATH_TTY, O_RDWR)) < 0) {
		return -1;
	}

	close (fd);

	return 0;
}

int
forkpty (int *amaster, char *slaveName, const struct termios *termp, const struct winsize *winp)
{
	int    fdm, fds;	/* master and slave file descriptors */
	pid_t  pid;

	if (openpty (&fdm, &fds, slaveName, termp, winp) == -1) {
		perror ("forkpty:openpty()");
		return -1;
	}


	pid = fork ();
	if (pid == -1) {
		/* error */
		perror ("forkpty: fork()");
		close (fdm);
		close (fds);
		return -1;
	} else if (pid == 0) {
		/* child */
		ptyMakeControllingTty (&fds, slaveName);
		if (fds != STDIN_FILENO && dup2 (fds, STDIN_FILENO) < 0) {
			perror ("error duplicationg stdin");
		}
		if (fds != STDOUT_FILENO && dup2 (fds, STDOUT_FILENO) < 0) {
			perror ("error duplicationg stdout");
		}
		if (fds != STDERR_FILENO && dup2 (fds, STDERR_FILENO) < 0) {
			perror ("error duplicationg stderr");
		}

		if (fds != STDIN_FILENO && fds != STDOUT_FILENO && fds != STDERR_FILENO) {
			close (fds);
		}

		close (fdm);
	} else {
		/* parent */
		close (fds);
		*amaster = fdm;
	}
	return pid;
}

#endif	// HAVE_FORKPTY
