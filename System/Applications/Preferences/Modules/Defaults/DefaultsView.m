/*
**  DefaultsView.m
**
**  Copyright (c) 2002 Fabien VALLON <fabien.vallon@fr.alcove.com>
**                     
**  Author: Fabien VALLON <fabien.vallon@fr.alcove.com>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope thatf it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License
**  along with this program; if not, write to the Free Software
**  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/


#import <AppKit/NSButton.h>
#import <AppKit/NSClipView.h>
#import <AppKit/NSTextContainer.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSBrowser.h>
#import "DefaultsView.h"

@implementation DefaultsView

- (id) initWithOwner: (id) anOwner andFrame: (NSRect) frameRect
{
	owner = anOwner;
	NSRect	textViewRect;
  
	if ((self = [super initWithFrame: frameRect])) {
		defaultsBrowser = [[NSBrowser alloc] initWithFrame: NSMakeRect(8, 76, 384, 112)];
		[defaultsBrowser setAllowsMultipleSelection: NO];
		[defaultsBrowser setAllowsEmptySelection: YES];
		[defaultsBrowser setHasHorizontalScroller: NO];
		[defaultsBrowser setMaxVisibleColumns: 2];
		[defaultsBrowser setDelegate: owner];
		[defaultsBrowser setTarget: owner];
		[defaultsBrowser setAction: @selector(browserSelectedSomething:)];
		[self addSubview: [defaultsBrowser autorelease]];

		scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(8, 8, 312, 62)];
		[scrollView setBorderType: NSBezelBorder];
		[scrollView setHasVerticalScroller: YES];
		[scrollView setHasHorizontalScroller: NO];
		[[scrollView contentView] setAutoresizingMask: NSViewHeightSizable];
		[[scrollView contentView] setAutoresizesSubviews: YES];

		textViewRect = [[scrollView contentView] frame];
		editTextView = [[NSTextView alloc] initWithFrame: textViewRect];

		[editTextView setDelegate: owner];
		[editTextView setHorizontallyResizable: NO];
		[editTextView setVerticallyResizable: YES];
		[editTextView setMinSize: NSMakeSize (0, 0)];
		[editTextView setMaxSize: NSMakeSize (1e7, 1e7)];
//		[editTextView setFieldEditor: NO];
		[editTextView setAutoresizingMask: NSViewHeightSizable];

		[editTextView setTextContainerInset: NSMakeSize(2, 2)];
		[[editTextView textContainer]
				setContainerSize: NSMakeSize (textViewRect.size.width - 4, 1e7)];
		[[editTextView textContainer] setHeightTracksTextView: NO];
		[[editTextView textContainer] setWidthTracksTextView: YES];

		[scrollView setDocumentView: [editTextView autorelease]];

		[self addSubview: [scrollView autorelease]];
	    
		removeButton = [[NSButton alloc] initWithFrame: NSMakeRect (328, 43, 64, 27)];
		[removeButton setTitle: @"Save"];
		[removeButton setTarget: owner];
		[removeButton setAction: @selector(saveDefault:)];
		[self addSubview: [removeButton autorelease]];

		removeButton = [[NSButton alloc] initWithFrame: NSMakeRect (328, 8, 64, 27)];
		[removeButton setTitle: @"Revert"];
		[removeButton setTarget: owner];
		[removeButton setAction: @selector(revert:)];
		[self addSubview: [removeButton autorelease]];
	}

	return self;
}

- (id) defaultsBrowser; 
{
	return defaultsBrowser;
}

- (id) editTextView;
{
	return editTextView;
}

- (id) remove;
{
	return removeButton;
}


@end
