#!/usr/bin/env sh
dirnm=`dirname $0`
filnm=`basename $0`
exec=`cd $dirnm && pwd`/$filnm
currdir=`dirname $exec`
parent=`dirname $currdir`
root=`dirname $parent`

set -e

if [ "$GENERATOR" != "" ]; then
    gen_arg=-G"${GENERATOR}"
else
    gen_arg=
fi

if [ "$CMAKE_BUILD_TYPE" = "" ]; then
    export CMAKE_BUILD_TYPE=Debug
fi

bld_arg="-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"

cmake -H. -B$currdir/_build -DCMAKE_INSTALL_PREFIX=$root/_install -DTESTS_DIR=$root/tests "$gen_arg" $bld_arg
env VERBOSE=1 cmake --build $currdir/_build --target tests_run --config $CMAKE_BUILD_TYPE > $currdir/testLog.txt
rm -fr $currdir/_build

echo '----------------------------------------------------------'
echo '# TEST LOG                                               #'
echo '----------------------------------------------------------'
cat $currdir/testLog.txt
echo '----------------------------------------------------------'
