#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <AppKit/NSApplication.h>
#include <Foundation/NSBundle.h>

int main (int argc, const char *argv[], const char *env[]) 
{
	return NSApplicationMain (argc, argv);
}
