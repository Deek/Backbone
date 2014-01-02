#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <Foundation/NSArray.h>
#include <Foundation/NSCharacterSet.h>
#include <Foundation/NSString.h>

#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif

#ifdef HAVE_SYS_WAIT_H
# include <sys/wait.h>
#endif

#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif

#include "print.h"

void
runCommand(NSString *cmd)
{
	pid_t	pid, sid;
	int		i = 0;
	const char	**cmd_args = calloc (32, sizeof (char *)); // 32 max args
	NSArray	*argList = [cmd componentsSeparatedByCharactersInSet:
	                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSEnumerator *args = [argList objectEnumerator];
	NSString *current;

	while ((current = [args nextObject])) {
		if ([current length])	// eat empty args
			cmd_args[i++] = [current UTF8String];
	}

	DPRINT (@"arglist: %@", argList);

	if ((pid = fork ()) == -1) {
		PRINT(@"fork: %s", strerror (errno));
		return;
	}

	if (!pid) {	// we're a child, daemonize
		signal (SIGHUP, SIG_IGN);	// ignore SIGHUP
		if ((sid = setsid()) < 0) {
			exit (EXIT_FAILURE);
		}

		if ((chdir ("/") < 0)) {	// to prevent locked dirs
			exit (EXIT_FAILURE);
		}

		// Redirect stdin/out/error
//		freopen ("/dev/null", "r", stdin);
//		freopen ("/dev/null", "w", stdout);
//		freopen ("/dev/null", "w", stderr);

		// actually run the command
		printf("%s\n", cmd_args[0]);
		execvp (cmd_args[0], (char **)cmd_args);

		// only executed if execvp fails
		// Our exit code is the only way we can communicate back now
		exit (1);
	} else {
		// give parental guidance (or bury it in the back yard)
//		PRINT (@"doing nothing...", nil);
#if 0
		int         status;
		pid_t       rc;

//		printf ("pid = %d\n", pid);
#ifdef HAVE_WAITPID
		rc = waitpid (0, &status, 0 | WUNTRACED);
#else
		rc = wait (&status);
#endif
		if ((rc) != pid) {
			if (rc == -1) {
				perror ("wait");
				return;
			}
			PRINT(@"The wrong child (%ld) died. Don't ask me, I don't know either.",
			        (long) rc);
			return;
		}
		if (WIFEXITED (status)) {
			if (WEXITSTATUS (status)) {
				PRINT(@"%s returned error code %d", cmd_args[0], WEXITSTATUS (status));
				return;
			}
		} else {
			PRINT(@"%s returned prematurely", cmd_args[0]);
			return;
		}
#endif
	}
}
