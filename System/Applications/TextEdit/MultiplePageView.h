#import <AppKit/NSView.h>
@class NSPrintInfo;
@class NSColor;

@interface MultiplePageView: NSView
{
	NSPrintInfo  *printInfo;
	NSColor      *lineColor;
	NSColor      *marginColor;
	unsigned     numPages;
}

- (void) setPrintInfo: (NSPrintInfo *)anObject;
- (NSPrintInfo *) printInfo;
- (float) pageSeparatorHeight;
- (NSSize) documentSizeInPage;	// Returns the area where the document can draw
/*
    Our pages are zero-based; the kit's are 1-based.
*/
- (NSRect) documentRectForPageNumber: (unsigned)pageNumber;
- (NSRect) pageRectForPageNumber: (unsigned)pageNumber;

- (void) setNumberOfPages: (unsigned)num;
- (unsigned) numberOfPages;
- (void) setLineColor: (NSColor *)color;
- (NSColor *) lineColor;
- (void) setMarginColor: (NSColor *)color;
- (NSColor *) marginColor;

@end
