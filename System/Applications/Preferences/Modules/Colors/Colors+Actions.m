#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include "Colors.h"
#include "Preview.h"

@implementation Colors (Actions)

- (IBAction) colorChanged: (id)sender
{
	NSString 	*key = nil;

	if (sender == color1)
		key = @"1";
	else if (sender == color2)
		key = @"2";
	else if (sender == color3)
		key = @"3";
	else if (sender == color4)
		key = @"4";
	else if (sender == color5)
		key = @"5";
	else if (sender == color6)
		key = @"6";
	else if (sender == color7)
		key = @"7";
	else if (sender == color8)
		key = @"8";
	else if (sender == color9)
		key = @"9";
	else if (sender == color10)
		key = @"10";
	else if (sender == colorSelectionWell) {
		// do something here
	}

	if (key) {
		NSMutableDictionary	*colors = [defaults dictionaryForKey: @"CustomColors"];

		if (!colors)
			colors = [NSMutableDictionary new];
		[colors setObject: [[sender color] RGBStringRepresentation] forKey: key];
		[defaults setObject: colors forKey: @"CustomColors"];
		[defaults synchronize];
	}
}

/*
- (IBAction) saveScheme: (id)sender;
- (IBAction) colorSelected: (id)sender;
- (IBAction) schemeSelected: (id)sender;
- (IBAction) removeScheme: (id)sender;
- (IBAction) updateSystemColors: (id)sender;
*/
- (IBAction) schemeSelected: (id)sender
{
	NSString	*file;
	NSString	*selected;

	if (sender != schemeBrowser
			|| !(selected = [[sender selectedCell] stringValue])
			|| !(file = [schemeList objectForKey: selected])) {
		[colorSelectionPopUp setEnabled: NO];
		return;
	}

	[currentScheme release];
	currentScheme = [[NSMutableDictionary dictionaryWithContentsOfFile: file] retain];

	[colorSelectionPopUp setEnabled: YES];
	[preview setColors: currentScheme];
	[preview setNeedsDisplay: YES];
}

- (IBAction) updateSystemColors: (id)sender
{
	if (currentScheme)
		[self setColorList: currentScheme];
}

/*
- (IBAction) deleteScheme: (id) sender 
{
	if ((currentScheme != nil) && ([currentScheme objectForKey: @"name"] != nil))
	{
		int ret = NSRunAlertPanel (@"Deleting the color scheme", @"Are you sure you want to delete that color scheme ?", @"No", @"Yes, delete it", NULL);
		if (ret != NSAlertDefaultReturn) // we delete the scheme
		{
			NSString* name = [currentScheme objectForKey: @"name"];
			[self deleteSchemeNamed: name];
			[colorSchemesList selectRow: 0 byExtendingSelection: NO];
			if ([list count] >= 1)
			{
				id key = [[list allKeys] objectAtIndex: 0];
				currentScheme = [list objectForKey: key];
			}
			[colorSchemesList reloadData];
			[self updateEditWindow];
			NSLog (@"n of rows: %d", [colorSchemesList numberOfRows]);
			NSLog (@"n of selected rows: %d", [colorSchemesList numberOfSelectedRows]);
			NSLog (@"selected row : %d", [colorSchemesList selectedRow]);
		}
	}
}

- (IBAction) saveScheme: (id) sender 
{
	if ((currentScheme != nil) && ([currentScheme objectForKey: @"name"] != nil))
	{
		NSString* name = [[NSString stringWithFormat: @"~/GNUstep/Library/Colors/%@.uicolors", 
					[currentScheme objectForKey: @"name"]]
					stringByExpandingTildeInPath];
		[currentScheme writeToFile: name atomically: YES];
	}
}

- (IBAction) schemeNameChanged: (id) sender 
{
	if (currentScheme != nil)
	{
		NSString* oldName = [[currentScheme objectForKey: @"name"] retain];
		NSString* newName = [schemeName stringValue];
		if ([list objectForKey: newName] != nil)
		{
			int ret = NSRunAlertPanel (@"Existing scheme", @"Are you sure to use that name ?\nA scheme with the same name already exists, and will be\n replaced by the current scheme if you choose this name", @"Cancel", @"Accept the new name", NULL);
	 		if (ret != NSAlertDefaultReturn) // we change the name
			{
				[list removeObjectForKey: newName];
				[currentScheme setObject: newName forKey: @"name"];
				[list setObject: currentScheme forKey: newName];
				[self saveScheme: self];
				[self deleteSchemeNamed: oldName];
				[list removeObjectForKey: oldName];
			}
			else
			{
				[schemeName setStringValue: oldName];
			}
		}
		else
		{
			[currentScheme setObject: newName forKey: @"name"];
			[list setObject: currentScheme forKey: newName];
			[self saveScheme: self];
			[self deleteSchemeNamed: oldName];
			[list removeObjectForKey: oldName];
		}
		[colorSchemesList reloadData];
	}
}

*/
@end
