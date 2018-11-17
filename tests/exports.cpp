/*! exports.cpp */

#include "<PKG>/exports.h"

#ifdef <PKGUPPER>_C_API
#  define VER_DEF_FOUND 1
#else
#  define VER_DEF_FOUND 0
#endif

#include "doctest.h"

TEST_CASE("export-macro-defined")
{
    CHECK_EQ(VER_DEF_FOUND, 1);
}
