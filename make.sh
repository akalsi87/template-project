#!/usr/bin/env sh

dirnm=`dirname $0`
filnm=`basename $0`
exec=`cd $dirnm && pwd`/$filnm
root=`dirname $exec`
libs=''

build_type="Debug"
prefix="$root/_install"
gen_arg=""
shared=0
target=tests

proj=$(cat CMakeLists.txt | \
           tr -s '\n' '|' | \
           grep -o "|project(.*\(\w+\\)" | \
           tr -d '|' | \
           tr -s ' ' | \
           cut -d' ' -f2)

usage() {
    cat <<EOF
make.sh TARGET
        [--prefix=INSTALL_PATH]
        [--generator=GENERATOR]
        [--type=TYPE]
        [--shared]
        [-h|--help]

Runs the CMake project in the current directory of the script.
  o TARGET can be (tests, install, install-tests, clean)
    All libraries and executables are built (unless TARGET is 'clean')
  o PREFIX is the installation directory
    Default: _install
  o GENERATOR is the CMake generator to use
    Default: Platform's CMake default
  o TYPE is the build type (Debug, Release, MinSizeRel, RelWithDebInfo)
    Default: Debug
  o 'shared' is specified if shared library builds are requested
EOF
    exit 0
}

target="$1"
shift

while [ "$1" != "" ]; do
    PARAM=`echo $1 | cut -d'=' -f1`
    VALUE=`echo $1 | cut -d'=' -f2`
    case $PARAM in
        -h|--help)
            usage
            exit 0
            ;;
        --type)
            build_type=$VALUE
            ;;
        --prefix)
            prefix=$VALUE
            ;;
        --generator)
            gen_arg="-G'$VALUE'"
            ;;
        --shared)
            shared=1
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

set -e

clear_tmp() {
    cd $root
    for lib in "$libs"; do
        rm -f ${prefix}/bin/${lib}_test || true
        rm -f ${prefix}/bin/${lib}_test.exe || true
    done
    rmdir ${prefix}/bin || true
    rm -fr $root/tmp/* || true
    rm -fr $root/tmp || true
}

run_cmake() {
    cmd="cmake -H$root -B$root/_build $gen_arg \
         -DCMAKE_INSTALL_PREFIX=\"$prefix\" \
         -DCMAKE_BUILD_TYPE=\"$build_type\" \
         -DBUILD_SHARED_LIBS=\"$shared\" \
         -Wno-dev"

    sh -c "$cmd"
    env VERBOSE=1 cmake --build $root/_build \
                        --target $1 \
                        --config "$build_type"
}

install_tests() {
    run_cmake install
    mkdir -p $root/tmp
    trap clear_tmp EXIT

    cd $root/tmp

    cp -rf $root/tests .

    # find tests
    libs=$(cat $root/CMakeLists.txt | \
           grep 'cm_add_tests' | \
           sed 's|NAME|;|g' | \
           sed 's|)||g' | \
           sed 's| ||g' | \
           cut -d';' -f2)

    echo Test libs: $libs

    cat <<EOF > CMakeLists.txt
## CMakeLists.txt for install test: $proj

cmake_minimum_required(VERSION 3.0)

set(CMAKE_PREFIX_PATH $prefix)
set(CMAKE_INSTALL_PREFIX $prefix)

include(../cmake/proj-helpers.cmake)

find_package($proj CONFIG REQUIRED)

set(CMAKE_CXX_STANDARD 11)

include_directories($root/tmp/tests)

EOF

    for lib in "$libs"; do
        srcs=$(find tests/$lib | grep '\.c\|\.cxx\|\.cpp')
        cat <<EOF >> CMakeLists.txt
## Test for ${lib}
set(${lib}_src ${srcs})

add_executable(${lib}_test \${${lib}_src} tests/tmain.cxx)

target_link_libraries(${lib}_test ${proj}::${lib})

install(
  TARGETS ${lib}_test
  RUNTIME DESTINATION bin)

EOF
    done

    export VERBOSE=1

    sh -c "cmake -H. -B_build ${gen_arg} -DCMAKE_BUILD_TYPE=${build_type}"
    cmake --build _build --target install

    for lib in "$libs"; do
        if ! sh -c "cd $prefix/bin && ./${lib}_test"; then
            >&2 echo "Failed install test for ${lib}"
            exit 1
        fi
    done

    echo "-------- INSTALL TEST COMPLETE --------"
}

if test "$target" = "clean"; then
    rm -fr $root/_build $root/_install
    exit 0
fi

if test "$target" = "install-tests"; then
    install_tests
    exit 0
fi

run_cmake "$target"
