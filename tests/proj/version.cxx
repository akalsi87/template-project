/*! version.cxx */

#include "<PKG>/version.h"

#if defined(<PKGUPPER>_C_API) &&     \
    defined(<PKGUPPER>_MAJOR_VER) && \
    defined(<PKGUPPER>_MINOR_VER) && \
    defined(<PKGUPPER>_PATCH_VER)
#  define VER_DEFS_FOUND 1
#else
#  define VER_DEFS_FOUND 0
#endif

#include "doctest.h"

#include <cstring>

TEST_CASE("export-macro-defined")
{
    CHECK_EQ(VER_DEFS_FOUND, 1);
}

TEST_CASE("export-version-defined")
{
    CHECK_GT(std::strlen(<PKGUPPER>_VERSION), 0);
}
