/*
	Keyboard.m

	Controller class for this bundle

	Copyright (C) 2001 Dusk to Dawn Computing, Inc.
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
static const char rcsid[] = 
	"$Id$";

#ifdef HAVE_CONFIG_H
# include "Config.h"
#endif

#import <AppKit/NSButton.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSOpenPanel.h>

#import "Keyboard.h"
#import "KeyboardView.h"

@interface Keyboard (Private)

- (NSDictionary *) preferencesFromDefaults;
- (void) savePreferencesToDefaults: (NSDictionary *) dict;

- (void) commitDisplayedValues;
- (void) discardDisplayedValues;

- (void) updateUI;

@end

@implementation Keyboard (Private)

static NSDictionary			*currentValues = nil;
static NSMutableDictionary	*displayedValues = nil;
static id <PrefsController>	controller;

static NSMutableDictionary *
defaultValues (void) {
    static NSMutableDictionary *dict = nil;

    if (!dict) {
        dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
				@"Meta_L", @"GSFirstCommandKey",
				@"Meta_R", @"GSSecondCommandKey",
				@"Control_L", @"GSFirstControlKey",
				@"Control_L", @"GSSecondControlKey",
				@"Alt_L", @"GSFirstAlternateKey",
				@"Alt_L", @"GSSecondAlternateKey",
				nil];
    }
    return dict;
}

static NSArray *
commonMenu (void) {
    static NSArray *arr = nil;

    if (!arr) {
        arr = [[NSArray alloc] initWithObjects:
				@"Left Alt",
				@"Right Alt",
				@"Left Meta/Windows",
				@"Right Meta/Windows",
				@"Left Control",
				@"Right Control",
				@"Mode Switch",
				nil];
    }
    return arr;
}

static NSDictionary *
menuItemNames (void) {
    static NSDictionary *dict = nil;

    if (!dict) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
				@"Alt_L", @"Left Alt",
				@"Alt_R", @"Right Alt",
				@"Control_L", @"Left Control",
				@"Control_R", @"Right Control",
				@"Meta_L", @"Left Meta/Windows",
				@"Meta_R", @"Right Meta/Windows",
				@"Mode_switch", @"Mode Switch",
				nil];
    }
    return dict;
}

#if 0
static BOOL
getBoolDefault (NSMutableDictionary *dict, NSString *name)
{
	NSString	*str = [[NSUserDefaults standardUserDefaults] stringForKey: name];
	NSNumber	*num;

	if (!str)
		str = [[defaultValues() objectForKey: name] stringValue];

	num = [NSNumber numberWithBool: [str hasPrefix: @"Y"]];
	[dict setObject: num forKey: name];

	return [num boolValue];
}
#endif

static NSString *
getStringDefault (NSMutableDictionary *dict, NSString *name)
{
	NSString	*str = [[NSUserDefaults standardUserDefaults] stringForKey: name];

	if (!str)
		str = [defaultValues() objectForKey: name];

	[dict setObject: str forKey: name];
	
	return str;
}

- (NSDictionary *) preferencesFromDefaults
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: 5];

	getStringDefault (dict, @"GSFirstAlternateKey");
	getStringDefault (dict, @"GSFirstCommandKey");
	getStringDefault (dict, @"GSFirstControlKey");
	getStringDefault (dict, @"GSSecondAlternateKey");
	getStringDefault (dict, @"GSSecondCommandKey");
	getStringDefault (dict, @"GSSecondControlKey");
	return dict;
}

- (void) savePreferencesToDefaults: (NSDictionary *) dict
{
	NSUserDefaults		*defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary	*domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];

#define setStringDefault(name) \
	[domain setObject: [dict objectForKey: (name)] forKey: (name)]
#define setBoolDefault(name) \
	[domain setBool: [[dict objectForKey: (name)] boolValue] forKey: (name)]

	NSDebugLog (@"Updating Main Preferences...");
	setStringDefault (@"GSFirstAlternateKey");
	setStringDefault (@"GSFirstCommandKey");
	setStringDefault (@"GSFirstControlKey");
	setStringDefault (@"GSSecondAlternateKey");
	setStringDefault (@"GSSecondCommandKey");
	setStringDefault (@"GSSecondControlKey");

	[defaults setPersistentDomain: domain forName: NSGlobalDomain];
	[defaults synchronize];
}

- (void) commitDisplayedValues
{
	[currentValues release];
	currentValues = [[displayedValues copy] retain];
	[self savePreferencesToDefaults: currentValues];
	[self updateUI];
}

- (void) discardDisplayedValues
{
	[displayedValues release];
	displayedValues = [[currentValues mutableCopy] retain];
	[self updateUI];
}

- (void) updateUI
{
	[firstAlternatePopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [displayedValues objectForKey: @"GSFirstAlternateKey"]] objectAtIndex: 0]];
	[firstCommandPopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [displayedValues objectForKey: @"GSFirstCommandKey"]] objectAtIndex: 0]];
	[firstControlPopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [displayedValues objectForKey: @"GSFirstControlKey"]] objectAtIndex: 0]];
	[secondAlternatePopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [displayedValues objectForKey: @"GSSecondAlternateKey"]] objectAtIndex: 0]];
	[secondCommandPopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [displayedValues objectForKey: @"GSSecondCommandKey"]] objectAtIndex: 0]];
	[secondControlPopUp selectItemWithTitle: [[menuItemNames() allKeysForObject: [displayedValues objectForKey: @"GSSecondControlKey"]] objectAtIndex: 0]];
	[view setNeedsDisplay: YES];
}

@end	// Keyboard (Private)

@implementation Keyboard

static Keyboard			*sharedInstance = nil;
static id <PrefsApplication>	owner = nil;

- (id) initWithOwner: (id <PrefsApplication>) anOwner
{
	NSMutableArray	*popups = [NSMutableArray arrayWithCapacity: 6];

	if (sharedInstance) {
		[self dealloc];
	} else {
		self = [super init];
		owner = anOwner;
		controller = [owner prefsController];
		[controller registerPrefsModule: self];
		if (![NSBundle loadNibNamed: @"Keyboard" owner: self]) {
			NSLog (@"Keyboard: Could not load nib \"Keyboard\", using compiled-in version");
			view = [[KeyboardView alloc] initWithOwner: self andFrame: PrefsRect];

			// hook up to our outlet(s)
			firstAlternatePopUp = [view firstAlternatePopUp];
			firstCommandPopUp = [view firstCommandPopUp];
			firstControlPopUp = [view firstControlPopUp];
			secondAlternatePopUp = [view secondAlternatePopUp];
			secondCommandPopUp = [view secondCommandPopUp];
			secondControlPopUp = [view secondControlPopUp];
		} else {
			// window can be any size, as long as it's 486x228 :)
			view = [window contentView];
		}
		[view retain];

		[popups addObject: firstAlternatePopUp];
		[popups addObject: firstCommandPopUp];
		[popups addObject: firstControlPopUp];
		[popups addObject: secondAlternatePopUp];
		[popups addObject: secondCommandPopUp];
		[popups addObject: secondControlPopUp];
		{
			id	myEnum = [popups objectEnumerator];
			id	obj;
		
			while ((obj = [myEnum nextObject])) {
				[obj removeAllItems];
				[obj addItemsWithTitles: commonMenu()];
			}
		}

		[self loadPrefs: self];

		sharedInstance = self;
	}
	return sharedInstance;
}

- (void) loadPrefs: (id) sender
{
	if (currentValues)
		[currentValues release];

	currentValues = [[[self preferencesFromDefaults] copyWithZone: [self zone]] retain];
	[self discardDisplayedValues];
}

- (void) savePrefs: (id) sender
{
	[self commitDisplayedValues];
}

- (void) resetPrefsToDefault: (id) sender
{
	if (currentValues)
		[currentValues release];

	currentValues = [[defaultValues () copyWithZone: [self zone]] retain];

	[self discardDisplayedValues];
}

- (void) showView: (id) sender;
{
	[controller setCurrentModule: self];
	[view setNeedsDisplay: YES];
}

- (NSView *) view
{
	return view;
}

- (NSString *) buttonCaption
{
	return @"Keyboard";
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
	[displayedValues setObject: [menuItemNames() objectForKey: [firstAlternatePopUp titleOfSelectedItem]] forKey: @"GSFirstAlternateKey"];
	[self updateUI];
}

- (IBAction) firstCommandChanged: (id) sender
{
	[displayedValues setObject: [menuItemNames() objectForKey: [firstCommandPopUp titleOfSelectedItem]] forKey: @"GSFirstCommandKey"];
	[self updateUI];
}

- (IBAction) firstControlChanged: (id) sender
{
	[displayedValues setObject: [menuItemNames() objectForKey: [firstControlPopUp titleOfSelectedItem]] forKey: @"GSFirstControlKey"];
	[self updateUI];
}

- (IBAction) secondAlternateChanged: (id) sender
{
	[displayedValues setObject: [menuItemNames() objectForKey: [secondAlternatePopUp titleOfSelectedItem]] forKey: @"GSSecondAlternateKey"];
	[self updateUI];
}

- (IBAction) secondCommandChanged: (id) sender
{
	[displayedValues setObject: [menuItemNames() objectForKey: [secondCommandPopUp titleOfSelectedItem]] forKey: @"GSSecondCommandKey"];
	[self updateUI];
}

- (IBAction) secondControlChanged: (id) sender
{
	[displayedValues setObject: [menuItemNames() objectForKey: [secondControlPopUp titleOfSelectedItem]] forKey: @"GSSecondControlKey"];
	[self updateUI];
}

@end	// Keyboard
