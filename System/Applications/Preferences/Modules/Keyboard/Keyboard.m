/*
	Keyboard.m

	Controller class for this bundle

	Copyright (C) 2002 Dusk to Dawn Computing, Inc.
	Additional copyrights here

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	24 Nov 2001

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public
	License along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA
*/
#ifdef HAVE_CONFIG_H
# include "Config.h"
#endif

RCSID("$Id$");

#include <AppKit/NSButton.h>
#include <AppKit/NSNibLoading.h>
#include <AppKit/NSOpenPanel.h>

#include "Keyboard.h"

@interface Keyboard (Private)

- (void) initUI;
- (void) updateUI;
- (void) preferencesFromDefaults;

@end

@implementation Keyboard (Private)

static id <PrefsController>	controller;
static NSUserDefaults		*defaults = nil;
static NSMutableDictionary	*domain = nil;

#define setStringDefault(string,name) \
	[domain setObject: (string) forKey: (name)]; \
	[defaults setPersistentDomain: domain forName: NSGlobalDomain]; \
	[defaults synchronize];

static NSMutableDictionary *
defaultValues (void) {
    static NSMutableDictionary *dict = nil;

    if (!dict) {
        dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
				@"Alt_L", @"GSFirstCommandKey",
				@"NoSymbol", @"GSSecondCommandKey",
				@"Control_L", @"GSFirstControlKey",
				@"Control_R", @"GSSecondControlKey",
				@"Alt_R", @"GSFirstAlternateKey",
				@"NoSymbol", @"GSSecondAlternateKey",
				nil];
    }
    return dict;
}

static NSArray *
commonMenu (void) {
    static NSArray *arr = nil;

    if (!arr) {
        arr = [[NSArray alloc] initWithObjects:
				@"None",
				@"AltGr (XFree86 4.3+)",
				@"Left Alt",
				@"Left Control",
				@"Left Hyper",
				@"Left Meta",
				@"Left Super",
				@"Right Alt",
				@"Right Control",
				@"Right Hyper",
				@"Right Meta",
				@"Right Super",
				@"Mode Switch",
				@"Multi-Key",
				nil];
    }
    return arr;
}

static NSDictionary *
menuItemNames (void) {
    static NSDictionary *dict = nil;

    if (!dict) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
				@"NoSymbol", @"None",
				@"ISO_Level3_Shift", @"AltGr (XFree86 4.3+)",
				@"Alt_L", @"Left Alt",
				@"Control_L", @"Left Control",
				@"Hyper_L", @"Left Hyper",
				@"Meta_L", @"Left Meta",
				@"Super_L", @"Left Super",
				@"Alt_R", @"Right Alt",
				@"Control_R", @"Right Control",
				@"Hyper_R", @"Right Hyper",
				@"Meta_R", @"Right Meta",
				@"Super_R", @"Right Super",
				@"Mode_switch", @"Mode Switch",
				@"Multi_key", @"Multi-Key",
				nil];
    }
    return dict;
}

static NSString *
getStringDefault (NSMutableDictionary *dict, NSString *name)
{
	NSString	*str = [domain objectForKey: name];

	if (!str)
		str = [defaultValues() objectForKey: name];

	[dict setObject: str forKey: name];
	
	return str;
}

- (void) preferencesFromDefaults
{
	getStringDefault (domain, @"GSFirstAlternateKey");
	getStringDefault (domain, @"GSFirstCommandKey");
	getStringDefault (domain, @"GSFirstControlKey");
	getStringDefault (domain, @"GSSecondAlternateKey");
	getStringDefault (domain, @"GSSecondCommandKey");
	getStringDefault (domain, @"GSSecondControlKey");
	return;
}

- (void) updateUI
{
	[firstAlternatePopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [domain objectForKey: @"GSFirstAlternateKey"]] objectAtIndex: 0]];
	[firstCommandPopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [domain objectForKey: @"GSFirstCommandKey"]] objectAtIndex: 0]];
	[firstControlPopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [domain objectForKey: @"GSFirstControlKey"]] objectAtIndex: 0]];
	[secondAlternatePopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [domain objectForKey: @"GSSecondAlternateKey"]] objectAtIndex: 0]];
	[secondCommandPopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [domain objectForKey: @"GSSecondCommandKey"]] objectAtIndex: 0]];
	[secondControlPopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [domain objectForKey: @"GSSecondControlKey"]] objectAtIndex: 0]];
	[view setNeedsDisplay: YES];
}

- (void) initUI
{
	NSArray	*popups;

	if (![NSBundle loadNibNamed: @"Keyboard" owner: self]) {
		NSLog (@"Keyboard: Could not load nib \"Keyboard\", aborting.");
		return;
	}

	view = [[window contentView] retain];
	[view removeFromSuperview];
	[window setContentView: NULL];
	[window dealloc];
	window = nil;

	popups = [NSArray arrayWithObjects: firstAlternatePopUp,
										firstCommandPopUp,
										firstControlPopUp,
										secondAlternatePopUp,
										secondCommandPopUp,
										secondControlPopUp,
										nil];

	[popups makeObjectsPerformSelector: @selector(removeAllItems)];
	[popups makeObjectsPerformSelector: @selector(addItemsWithTitles:)
							withObject: commonMenu ()];

	[self updateUI];
}
@end	// Keyboard (Private)

@implementation Keyboard

static Keyboard			*sharedInstance = nil;
static id <PrefsApplication>	owner = nil;

- (id) initWithOwner: (id <PrefsApplication>) anOwner
{
	if (sharedInstance) {
		[self dealloc];
	} else {
		self = [super init];
		owner = anOwner;
		controller = [owner prefsController];
		defaults = [NSUserDefaults standardUserDefaults];
		domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];
		[self preferencesFromDefaults];

		[controller registerPrefsModule: self];

		sharedInstance = self;
	}
	return sharedInstance;
}

- (void) showView: (id) sender;
{
	if (!view)
		[self initUI];

	[controller setCurrentModule: self];
	[view setNeedsDisplay: YES];
}

- (NSView *) view
{
	return view;
}

- (NSString *) buttonCaption
{
	return @"Modifier Key Preferences";
}

- (NSImage *) buttonImage
{
	return [NSImage imageNamed: @"PrefsIcon_Keyboard"];
}

- (SEL) buttonAction
{
	return @selector(showView:);
}

/*
	Action methods
*/
- (IBAction) firstAlternateChanged: (id) sender
{
	setStringDefault ([menuItemNames() objectForKey: [firstAlternatePopUp titleOfSelectedItem]], @"GSFirstAlternateKey");
}

- (IBAction) firstCommandChanged: (id) sender
{
	setStringDefault ([menuItemNames() objectForKey: [firstCommandPopUp titleOfSelectedItem]], @"GSFirstCommandKey");
}

- (IBAction) firstControlChanged: (id) sender
{
	setStringDefault ([menuItemNames() objectForKey: [firstControlPopUp titleOfSelectedItem]], @"GSFirstControlKey");
}

- (IBAction) secondAlternateChanged: (id) sender
{
	setStringDefault ([menuItemNames() objectForKey: [secondAlternatePopUp titleOfSelectedItem]], @"GSSecondAlternateKey");
}

- (IBAction) secondCommandChanged: (id) sender
{
	setStringDefault ([menuItemNames() objectForKey: [secondCommandPopUp titleOfSelectedItem]], @"GSSecondCommandKey");
}

- (IBAction) secondControlChanged: (id) sender
{
	setStringDefault ([menuItemNames() objectForKey: [secondControlPopUp titleOfSelectedItem]], @"GSSecondControlKey");
}

@end	// Keyboard
