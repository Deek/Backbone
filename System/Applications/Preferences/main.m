#ifdef HAVE_CONFIG_H
# include "Config.h"
#endif

RCSID("$Id$");

#import <AppKit/NSApplication.h>

int main (int argc, const char *argv[], const char *env[]) 
{
	return NSApplicationMain (argc, argv);
}
