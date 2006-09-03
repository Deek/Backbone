#include "Colors.h"

@implementation Colors (TableView)

/*
	Browser delegate methods
*/
- (int) browser: (NSBrowser *)sender numberOfRowsInColumn: (int)column
{
	if (sender != schemeBrowser)
		return 0;

	if (column != 0)
		return 0;

	return [schemeList count];
}

- (void) browser: (NSBrowser *)sender willDisplayCell: (id)cell atRow: (int)row column: (int)column
{
	NSArray	*sorted = [schemeList keysSortedByValueUsingSelector:@selector(compare:)];
	
	[cell setLeaf: YES];
	[cell setStringValue: [sorted objectAtIndex: row]];
}

@end	
