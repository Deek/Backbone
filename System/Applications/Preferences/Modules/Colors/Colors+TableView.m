#include "Colors.h"

@implementation Colors (TableView)

/*
	TableView delegate
*/

- (int) numberOfRowsInTableView: (NSTableView*) tableView
{
	return [list count];
}

- (id) tableView: (NSTableView*) tableView objectValueForTableColumn: (NSTableColumn*) column row: (int) row
{
	NSArray* keys = [[list allKeys] sortedArrayUsingSelector: @selector (caseInsensitiveCompare:)];
	id object = [keys objectAtIndex: row];
	if ([[list objectForKey: object] isEqual: currentScheme]) 
	{
		[tableView selectRow: row byExtendingSelection: NO];
	}
	else
	{
//		[tableView deselectRow: row]; // shouldn't be needed; bug gnustep TODO: patch gnustep
	}
	return object;
}

- (BOOL) tableView: (NSTableView*) tableview shouldSelectRow: (int) row
{
	[editButton setEnabled: YES];
	NSArray* keys = [[list allKeys] sortedArrayUsingSelector: @selector (caseInsensitiveCompare:)];
	currentScheme = [list objectForKey: [keys objectAtIndex: row]];
	[self updateEditWindow];

	return YES;
}

- (BOOL) tableView: (NSTableView*) tableview shouldEditTableColumn: (NSTableColumn*) column row: (int) row
{
	return YES;
}

@end	
