/*! exports.cpp */

#include "defs.h"

void basic()
{
    testThat(1 == 1);
}

setupSuite(exports)
{
    addTest(basic);
}
