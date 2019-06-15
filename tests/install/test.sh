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

cd $currdir
mkdir -p _build
cd _build

cmake \
  -DCMAKE_INSTALL_PREFIX=$root/_install \
  -DTESTS_DIR=$root/tests \
  "$gen_arg" \
  $bld_arg \
  ..

env VERBOSE=1 \
  cmake --build . --target tests_run \
        --config $CMAKE_BUILD_TYPE > ../testLog.txt || true

cd ..
rm -fr _build

echo '----------------------------------------------------------'
echo '# TEST LOG                                               #'
echo '----------------------------------------------------------'
cat testLog.txt
echo '----------------------------------------------------------'
