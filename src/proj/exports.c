#include <<PKG>/exports.h>

#define _STR(x) #x
#define STR(x) _STR(x)

const char* <PKGUPPER>_VERSION = STR(<PKGUPPER>_MAJOR_VER) "."
                                  STR(<PKGUPPER>_MINOR_VER) "."
                                  STR(<PKGUPPER>_PATCH_VER);
