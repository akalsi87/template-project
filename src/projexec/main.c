/*! main.c */

#include <<PKG>/version.h>

#include <stdio.h>

int main(int argc, char const* argv[])
{
    printf("Lib ver: %s\nExe ver: %s\n",
           <PKGUPPER>_VERSION,
           <PKGUPPER>EXEC_VER_STRING);
    return 0;
}
