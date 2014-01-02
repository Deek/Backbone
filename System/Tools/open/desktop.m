#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <Foundation/NSCharacterSet.h>
#include <Foundation/NSData.h>
#include <Foundation/NSScanner.h>
#include <Foundation/NSString.h>

#include "desktop.h"
#include "print.h"
#include "run.h"

/**
    This is a PRELIMINARY version of a desktop file launcher. The real one will
    use an external class that will correctly parse the whole thing as an "INI"
    file, and replace %f etc. codes. This one is mainly for executing the
    contents of /etc/xdg/autostart/ *.desktop
*/
void
launchDesktopFile (NSString *location)
{
	NSString  *shellCommand = @"";
	NSString  *onlyShowIn = @"";
	NSString  *notShowIn = @"";
	NSString  *name = @"";
	NSString  *desktopFile = [[NSString alloc]
	                          initWithData: [NSData dataWithContentsOfFile: location]
	                              encoding: NSUTF8StringEncoding];
	NSScanner  *scanner = [NSScanner scannerWithString: desktopFile];

	while (![scanner isAtEnd]) {
		NSString  *token;
		if ([scanner scanUpToCharactersFromSet: [NSCharacterSet newlineCharacterSet]
		                            intoString: &token]) {
			if ([token hasPrefix: @"Exec="]) {
				shellCommand = [token stringByDeletingPrefix: @"Exec="];
				continue;
			} else if ([token hasPrefix: @"Name="]) {
				name = [token stringByDeletingPrefix: @"Name="];
				continue;
			} else if ([token hasPrefix: @"NotShowIn="]) {
				notShowIn = [token stringByDeletingPrefix: @"NotShowIn="];
				continue;
			} else if ([token hasPrefix: @"OnlyShowIn="]) {
				onlyShowIn = [token stringByDeletingPrefix: @"OnlyShowIn="];
				continue;
			}
		}
		[scanner scanCharactersFromSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]
		                    intoString: NULL];
	}

	// process Exec keywords
	shellCommand = [shellCommand stringByReplacingString: @"%f" withString: @""];
	shellCommand = [shellCommand stringByReplacingString: @"%F" withString: @""];
	shellCommand = [shellCommand stringByReplacingString: @"%u" withString: @""];
	shellCommand = [shellCommand stringByReplacingString: @"%U" withString: @""];

	// process NotShowIn
	if ([notShowIn length]
	    && ([notShowIn rangeOfString: @"Old"].length
	        || [notShowIn rangeOfString: @"GNUstep"].length
	        || [notShowIn rangeOfString: @"Backbone"].length)) {
		PRINT (@"Asked to ignore app '%@'", name);
	} else if ([onlyShowIn length]
	           && !([onlyShowIn rangeOfString: @"Old"].length
	                || [onlyShowIn rangeOfString: @"GNUstep"].length
	                || [onlyShowIn rangeOfString: @"Backbone"].length)) {
		PRINT (@"app '%@' is not for us", name);
	} else {
		DPRINT (@"app '%@' execs %@", name, shellCommand);
		runCommand (shellCommand);
	}
}
