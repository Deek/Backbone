/*
	PrefsController.m

	Preferences window controller class

	Copyright (C) 2001 Dusk to Dawn Computing, Inc.

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	11 Nov 2001

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

#import <Foundation/NSDebug.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSObjCRuntime.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSNibLoading.h>

#import <PrefsModule/PrefsModule.h>

#import "PrefsController.h"

@implementation PrefsController

static PrefsController	*sharedInstance = nil;
static NSMutableArray	*prefsViews = nil;
static id <PrefsModule>	currentModule = nil;

+ (PrefsController *) sharedPrefsController
{
	return (sharedInstance ? sharedInstance : [[self alloc] init]);
}

- (id) init
{
	if (sharedInstance) {
		[self dealloc];
	} else {
		self = [super init];
		prefsViews = [[[NSMutableArray alloc] initWithCapacity: 5] retain];
	}
	sharedInstance = self;
	return sharedInstance;	
}

/*
	awakeFromNib

	Initialize stuff that can't be set in the nib/gorm file.
*/
- (void) awakeFromNib
{
	// Let the systen keep track of where it belongs
	[window setFrameAutosaveName: @"PreferencesMainWindow"];
	[window setFrameUsingName: @"PreferencesMainWindow"];

	if (iconList)	// stop processing if we already have an icon list
		return;

	/* What is the matrix? :) */
	iconList = [[NSMatrix alloc] initWithFrame: NSMakeRect (0, 0, 64*30, 64)];
	[iconList setCellClass: [NSButtonCell class]];
	[iconList setCellSize: NSMakeSize (64, 64)];
	[iconList setMode: NSRadioModeMatrix];
	[iconList setAllowsEmptySelection: YES];

	[iconScrollView setDocumentView: iconList];
	[iconScrollView setHasHorizontalScroller: YES];
	[iconScrollView setHasVerticalScroller: NO];
}

- (void) dealloc
{
	NSDebugLog (@"PrefsController -dealloc");

	[prefsViews release];
	[super dealloc];
}

- (void) windowWillClose: (NSNotification *) aNotification
{
}

- (BOOL) registerPrefsModule: (id <PrefsModule>) aPrefsModule;
{
	NSButtonCell	*button = [[NSButtonCell alloc] init];

	if (!aPrefsModule)
		return NO;

	if (! [prefsViews containsObject: aPrefsModule]) {
		[prefsViews addObject: aPrefsModule];
	}

	[button setTitle: [aPrefsModule buttonCaption]];
	[button setFont: [NSFont systemFontOfSize: 9]];
	[button setImage: [aPrefsModule buttonImage]];
	[button setImagePosition: NSImageOnly];
	[button setHighlightsBy: NSChangeBackgroundCellMask];
	[button setShowsStateBy: NSChangeBackgroundCellMask];
	[button setTarget: aPrefsModule];
	[button setAction: [aPrefsModule buttonAction]];

	[iconList addColumnWithCells: [NSArray arrayWithObject: button]];
	[iconList sizeToCells];

	[aPrefsModule autorelease];
	return YES;
}

- (BOOL) setCurrentModule: (id <PrefsModule>) aPrefsModule;
{
	if (!aPrefsModule || ![aPrefsModule view])
		return NO;

	currentModule = aPrefsModule;
	[[currentModule view] setBounds: [[prefsViewBox contentView] bounds]];
	[prefsViewBox setContentView: [currentModule view]];
	[window setTitle: [currentModule buttonCaption]];
	return YES;
}

- (id) window;
{
	return window;
}

- (id) currentModule;
{
	return currentModule;
}

/*
	Note: This is ugly.
*/
#ifndef NeXT_RUNTIME
extern BOOL __objc_responds_to (id, SEL);
#endif

- (BOOL) respondsToSelector: (SEL) aSelector
{
	if (!aSelector)
		return NO;

	if (__objc_responds_to (self, aSelector))
		return YES;

	if ([self methodSignatureForSelector: aSelector])
		return YES;

	return NO;
}

- (NSMethodSignature *) methodSignatureForSelector: (SEL) aSelector
{
	NSMethodSignature	*sig = nil;

	if ((sig = [[self class] instanceMethodSignatureForSelector: aSelector]))
		return sig;

	if (!currentModule)
		return nil;

	if ([currentModule respondsToSelector: aSelector])
		return [(id)currentModule methodSignatureForSelector: aSelector];

	return nil;
}

- (void) forwardInvocation: (NSInvocation *)invocation
{
	if (currentModule && [currentModule respondsToSelector: [invocation selector]])
		[invocation invokeWithTarget: currentModule];
	else
		[self doesNotRecognizeSelector: [invocation selector]];
}
@end
