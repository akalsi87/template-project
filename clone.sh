#!/usr/bin/env sh

if [ "$#" -ne 1 ]; then
    printf "Usage:\n\t$0 <dir>\n"
    exit 1;
fi

set -e

exe=`realpath $0`
srcDir=`dirname $exe`

projDir=`realpath $1`

mkdir -p $projDir

projName=`basename $projDir`
projNameUpper=`echo $projName | tr [a-z] [A-Z]`

# handle CMakeLists.txt
cat $srcDir/CMakeLists.txt | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/CMakeLists.txt

# handle export header
mkdir -p $projDir/export/$projName
cat $srcDir/export/template-project/version.hpp | sed "s/<PKG>/$projNameUpper/g" > $projDir/export/$projName/version.hpp

# handle cmake/projConfig.cmake.in
mkdir -p $projDir/cmake
cmakeConfig="$projDir/cmake/$projName"Config.cmake.in
cat $srcDir/cmake/projConfig.cmake.in | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $cmakeConfig

# handle build.sh, clean.sh
cp $srcDir/build.sh $srcDir/clean.sh $projDir

# copy empty.cpp
mkdir -p $projDir/src/$projName
cp $srcDir/src/proj/empty.cpp $projDir/src/$projName

# copy tests
mkdir -p $projDir/tests/install
cp -rf $srcDir/tests $projDir/

# handle tests.cmake and install/CMakeLists.txt
cat $srcDir/tests.cmake | sed "s/<PKG>/$projName/g" > $projDir/tests.cmake
cat $srcDir/tests/install/CMakeLists.txt | sed "s/<PKG>/$projName/g" > $projDir/tests/install/CMakeLists.txt

# copy LICENSE
cp $srcDir/LICENSE $projDir
