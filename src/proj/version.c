#include <<PKG>/version.h>

#define _STR(x) #x
#define STR(x) _STR(x)

const char* <PKGUPPER>_VERSION = "<PKG> v"
                                 STR(<PKGUPPER>_MAJOR_VER) "."
                                 STR(<PKGUPPER>_MINOR_VER) "."
                                 STR(<PKGUPPER>_PATCH_VER);
