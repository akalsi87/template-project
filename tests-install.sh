#!/usr/bin/env sh

dirnm=`dirname $0`
filnm=`basename $0`
exec=`cd $dirnm && pwd`/$filnm
root=`dirname $exec`

set -e

if [ -z "$BUILD_SHARED_LIBS" ]; then
    shared=0
else
    shared="$BUILD_SHARED_LIBS"
fi

if [ -z "$CMAKE_BUILD_TYPE" ]; then
    build=RelWithDebInfo
else
    build="$CMAKE_BUILD_TYPE"
fi

if [ -z "$GENERATOR" ]; then
    gen_arg=
else
    gen_arg="-G'$GENERATOR'"
fi

$root/build.sh
env VERBOSE=1 cmake --build $root/_build --target install --config "$build"
cd $root/tests/install
./test.sh
