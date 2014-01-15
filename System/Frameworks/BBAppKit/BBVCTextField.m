#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <BBAppKit/BBVCTextField.h>
#include <BBAppKit/BBVCTextFieldCell.h>

static Class defaultTextCellClass;
static Class cellClass;

@implementation BBVCTextField

+ (void) initialize
{
	if (self == [BBVCTextField class]) {
		cellClass = defaultTextCellClass = [BBVCTextFieldCell class];
	}
}

+ (Class) cellClass
{
	return cellClass;
}

+ (void) setCellClass: (Class)newClass
{
	cellClass = defaultTextCellClass;
	if (newClass)
		cellClass = newClass;
}

- (void) awakeFromNib
{
	BBVCTextFieldCell *new = [[BBVCTextFieldCell alloc] initWithTextFieldCell: _cell];
	id tmp = _cell;

	_cell = new;
	[tmp release];
}

@end
