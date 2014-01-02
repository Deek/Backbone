#ifndef PRINT_H
# define PRINT_H

#undef DEBUG

#ifdef DEBUG
# define DPRINT(fmt, ...) \
    printf ("%s\n", [[NSString stringWithFormat: fmt, __VA_ARGS__] UTF8String])
#else
# define DPRINT(fmt, ...)
#endif

#define PRINT(fmt, ...) \
    printf ("%s\n", [[NSString stringWithFormat: fmt, __VA_ARGS__] UTF8String])

#endif // PRINT_H
