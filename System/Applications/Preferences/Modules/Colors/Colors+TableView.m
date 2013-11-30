#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include "Colors.h"

@implementation Colors (TableView)

/*
	Browser delegate methods
*/
- (int) browser: (NSBrowser *)sender numberOfRowsInColumn: (int)column
{
	if ((sender != schemeBrowser) || column != 0)
		return 0;

	return [schemeList count];
}

- (void) browser: (NSBrowser *)sender
 willDisplayCell: (id)cell
           atRow: (int)row
          column: (int)column
{
	NSArray	*sorted = [schemeList keysSortedByValueUsingSelector: @selector(compare:)];

	NSDebugLog (@"Scheme list: %@", schemeList);
	[cell setLeaf: YES];
	[cell setStringValue: [sorted objectAtIndex: row]];
}
@end
