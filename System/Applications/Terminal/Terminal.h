/*
copyright 2002 Alexander Malmberg <alexander@malmberg.org>

This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#ifndef Terminal_h
#define Terminal_h


typedef struct
{
	unichar ch;
	unsigned char color;
	unsigned char attr;
/*
bits
0,1   intensity, 0-2
2     underline
3     reverse
4     blink
5     unused
6     used as a selected flag internally
7     used as a dirty flag internally
*/
} screen_char_t;


/* Used as a marker. */
#define MULTI_CELL_GLYPH 0xfffe


@protocol TerminalScreen
-(void) ts_sendCString: (const char *)str;
-(void) ts_goto: (int)x:(int)y;
-(void) ts_putChar: (screen_char_t)ch  count: (int)c  at: (int)x:(int)y;
-(void) ts_putChar: (screen_char_t)ch  count: (int)c  offset: (int)ofs;

/* The portions scrolled/shifted from remain unchanged. However, it's
assumed that they will be cleared or overwritten before the redraw is
complete. (TODO check this) */
-(void) ts_scrollUp: (int)top:(int)bottom  rows: (int)nr  save: (BOOL)save;
-(void) ts_scrollDown: (int)top:(int)bottom  rows: (int)nr;
-(void) ts_shiftRow: (int)y  at: (int)x0  delta: (int)d;

-(screen_char_t) ts_getCharAt: (int)x:(int)y;

-(void) ts_setTitle: (NSString *)new_title  type: (int)title_type;


-(BOOL) useMultiCellGlyphs;
-(int) relativeWidthOfCharacter: (unichar)ch;
@end


@protocol TerminalParser
- initWithTerminalScreen: (id<TerminalScreen>)ats  width: (int)w  height: (int)h;
-(void) processByte: (unsigned char)c;
-(void) setTerminalScreenWidth: (int)w height: (int)h;
-(void) handleKeyEvent: (NSEvent *)e;
-(void) sendString: (NSString *)str;
@end


#endif

