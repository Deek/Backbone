/*
	Defaults.h

	Copyright (C) 2002 Fabien VALLON <fabien.vallon@fr.alcove.com>
	Copyright (C) 2002 Dusk to Dawn Computing, Inc.
                   
	Author:	Fabien VALLON <fabien.vallon@fr.alcove.com>
	Date:	15 Aug 2002

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

#import <AppKit/NSWindow.h>
#import <AppKit/NSMatrix.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSBrowser.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSNibDeclarations.h>
#import <PrefsModule/PrefsModule.h>
#import <Foundation/NSUserDefaults.h>

@interface Defaults: NSObject <PrefsModule>
{
	IBOutlet NSBrowser	*defaultsBrowser;
	IBOutlet NSTextView	*editTextView;
	IBOutlet NSButton	*revertButton;
	IBOutlet NSButton	*saveButton;

	IBOutlet id			window;
	IBOutlet id			view;
}

// Action methods
- (IBAction) createDefault: (id) sender;
- (IBAction) createDomain: (id) sender;
- (IBAction) removeDefault: (id) sender;
- (IBAction) removeDomain: (id) sender;

- (IBAction) saveDefault: (id) sender;
- (IBAction) discardDefault: (id) sender;

- (IBAction) browserSelectedSomething: (id) sender;

@end 
