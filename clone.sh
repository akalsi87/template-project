#!/usr/bin/env sh

if [ "$#" -ne 1 ]; then
    printf "Usage:\n\t$0 <dir>\n"
    exit 1;
fi

set -e

dirnm=`dirname $0`
filnm=`basename $0`
exec=`cd $dirnm && pwd`/$filnm
srcDir=`dirname $exec`

projDir=`mkdir -p $1 && cd $1 && pwd`

mkdir -p $projDir

projName=`basename $projDir`
projNameUpper=`echo $projName | tr [a-z] [A-Z]`

# handle CMakeLists.txt
cat $srcDir/CMakeLists.txt | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" | sed "s/<OWNER>/`git config --global user.name`/g" | sed "s/<EMAIL>/`git config --global user.email`/g" > $projDir/CMakeLists.txt

# handle export header
mkdir -p $projDir/include/$projName
cat $srcDir/include/proj/exports.h.in | sed "s/<PKG>/$projNameUpper/g" > $projDir/include/$projName/exports.h.in

# handle cmake/proj-config.cmake.in
mkdir -p $projDir/cmake
cmakeConfig="$projDir/cmake/$projName"-config.cmake.in
cat $srcDir/cmake/proj-config.cmake.in | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $cmakeConfig

# copy cmake/vcpkg-toolchain.cmake
cp $srcDir/cmake/vcpkg-toolchain.cmake $projDir/cmake
cp $srcDir/cmake/proj-helpers.cmake $projDir/cmake

# handle build.sh, clean.sh, tests-install.sh
cp $srcDir/build.sh $srcDir/clean.sh $srcDir/tests-install.sh $projDir

# copy exports.c
mkdir -p $projDir/src/$projName
cat $srcDir/src/proj/exports.c | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/src/$projName/exports.c

# copy tests
mkdir -p $projDir/tests/install
cp -rf $srcDir/tests $projDir/
cat $srcDir/tests/exports.cpp | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/tests/exports.cpp

# handle tests.cmake and install/CMakeLists.txt
cat $srcDir/tests.cmake | sed "s/<PKG>/$projName/g" > $projDir/tests.cmake
cat $srcDir/tests/install/CMakeLists.txt | sed "s/<PKG>/$projName/g" > $projDir/tests/install/CMakeLists.txt

# copy LICENSE
cat $srcDir/LICENSE | sed "s/<YEAR>/`date +%Y`/g" | sed "s/<OWNER>/`git config --global user.name`/g" | sed "s/<EMAIL>/`git config --global user.email`/g" > $projDir/LICENSE

# create .gitignore
cat <<EOF > $projDir/.gitignore
# .gitignore
_build/
_install/
tests/install/_source/
tests/install/_build/
tests/install/testLog.txt

# IDEs
.idea/
cmake-build-*
include/$projName/exports.h
EOF

# copy convenience scripts
cp $srcDir/create*.sh $projDir/
