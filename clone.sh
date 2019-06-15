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
cat $srcDir/CMakeLists.txt | \
  sed "s/<PKG>/$projName/g" | \
  sed "s/<PKGUPPER>/$projNameUpper/g" | \
  sed "s/<OWNER>/`git config --global user.name`/g" | \
  sed "s/<EMAIL>/`git config --global user.email`/g" > $projDir/CMakeLists.txt

# copy cmake helpers
mkdir -p $projDir/cmake
cp $srcDir/cmake/vcpkg-toolchain.cmake $projDir/cmake
cp $srcDir/cmake/proj-helpers.cmake $projDir/cmake

# handle build.sh, clean.sh
cp $srcDir/build.sh $srcDir/clean.sh $projDir

# copy version.c/h
mkdir -p $projDir/src/$projName
mkdir -p $projDir/include/$projName
cat $srcDir/src/proj/version.c | \
  sed "s/<PKG>/$projName/g" | \
  sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/src/$projName/version.c
cat $srcDir/include/proj/version.h | \
  sed "s/<PKG>/$projName/g" | \
  sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/include/$projName/version.h

# copy main.c
mkdir -p $projDir/src/${projName}exec
cat $srcDir/src/projexec/main.c | \
  sed "s/<PKG>/$projName/g" | \
  sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/src/${projName}exec/main.c

# copy tests
cp -rf $srcDir/tests $projDir/
rm -fr $projDir/tests/proj
mkdir -p $projDir/tests/$projName
cat $srcDir/tests/proj/version.cxx | \
  sed "s/<PKG>/$projName/g" | \
  sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/tests/$projName/version.cxx

# copy LICENSE
cat $srcDir/LICENSE | \
  sed "s/<YEAR>/`date +%Y`/g" | \
  sed "s/<OWNER>/`git config --global user.name`/g" | \
  sed "s/<EMAIL>/`git config --global user.email`/g" > $projDir/LICENSE

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
