#include "Colors.h"

@implementation Colors (Actions)

- (IBAction) percentChanged: (id) sender
{
	[self updateEditWindow];
}

- (IBAction) schemeUpdated: (id) sender
{
	[self updateEditWindow];
}

- (IBAction) colorChanged: (id) sender
{
	if (currentScheme != nil)
	{
		[self setColor: backgroundColorWell withName: @"base"];
		[self setColor: textBackgroundColorWell withName: @"textfieldbgd"];
		[self setColor: sliderBackgroundColorWell withName: @"sliderbgd"];
		[self updateEditWindow];		
	}
}

- (IBAction) checkboxChanged: (id) sender
{
	if (currentScheme != nil)
	{
		[self setCheckbox: checkboxTextBackground withName: @"use_textfieldbgd"];
		[self setCheckbox: checkboxSliderBackground withName: @"use_sliderbgd"];
		[self updateEditWindow];		
	}
}

- (IBAction) useScheme: (id) sender
{
	if (currentScheme != nil)
	{
		[self setColorList: currentScheme];
		[self saveScheme: self];
	}
}

- (IBAction) initColorLevels: (id) sender
{
	[highlightPercent setFloatValue: 50.0];
	[mediumPercent setFloatValue: -25.0];
	[darkPercent setFloatValue: -50.0];
	[blackPercent setFloatValue: -100.0];
	
	[self percentChanged: self];	
}

- (IBAction) newScheme: (id) sender
{
	NSMutableDictionary* colorStrings = [self defaultColors];
	NSString* name = @"new Scheme";
	int i=1;
	while ([list objectForKey: name] != nil)
	{
		name = [NSString stringWithFormat: @"new Scheme %d", i];
		i++;
	}
	[colorStrings setObject: name forKey: @"name"];
	[list setObject: colorStrings forKey: name];
	currentScheme = colorStrings;
	[colorSchemesList deselectAll: nil];
	[colorSchemesList reloadData];
	//[colorSchemesList display]; // That's a GNUstep BUG ! the display shouldn't be forced. TODO: patch it...
	[self updateEditWindow];
	[self saveScheme: self];
}

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

@end	
