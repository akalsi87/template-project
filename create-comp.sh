#!/usr/bin/env sh

dirnm=`dirname $0`
filnm=`basename $0`
exec=`cd $dirnm && pwd`/$filnm
root=`dirname $exec`

comp_path=""
lang=CXX

usage() {
    cat <<EOF
create-comp.sh PATH [--lang=LANG] [-h|--help]

Creates a C/C++ component
  o PATH is the components hierarchy, e.g. foo/bar
    This would create 3 files:
      o src/foo/bar.LANG_EXT_SRC
      o include/foo/bar.LANG_EXT_HDR
      o tests/foo/bar.cxx
  o LANG can be either C or CXX
    Note that:
      o C implies that headers are '.h' and source files are '.c'
      o CXX implies that headersr are '.hxx' and source files are '.cxx'
EOF
    exit 0
}

comp_path=$1
shift

while [ "$1" != "" ]; do
    PARAM=`echo $1 | cut -d'=' -f1`
    VALUE=`echo $1 | cut -d'=' -f2`
    case $PARAM in
        -h|--help)
            usage
            exit 0
            ;;
        --lang)
            lang=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if test "$lang" = CXX; then
    hdr_ext='.hxx'
    src_ext='.cxx'
elif test "$lang" = C; then
    hdr_ext='.h'
    src_ext='.c'
else
    >&2 echo Invalid language: "$lang"
    exit 1
fi

comp_name=$(basename "$comp_path")
comp_dir=$(dirname "$comp_path")

reverse_word_order() {
    local result=
    for word in $@; do
        result="$word $result"
    done
    echo "$result" 
}

print_include_guard() {
    echo "$comp_path$hdr_ext" | \
      tr '[:lower:]' '[:upper:]' | \
      sed 's|\.|_|g' | \
      sed 's|\/|_|g' | \
      sed 's|\\|_|g'
}

print_namespace_begin() {
    if test "$lang" = C; then
        return
    fi
    list=$(dirname "$comp_path" | \
      sed 's|\.| |g' | \
      sed 's|\/| |g' | \
      sed 's|\\| |g')
    for item in ${list};
    do
        echo "namespace $item {"
    done
}

print_namespace_end() {
    if test "$lang" = C; then
        return
    fi
    list=$(dirname "$comp_path" | \
      sed 's|\.| |g' | \
      sed 's|\/| |g' | \
      sed 's|\\| |g')
    for item in $(reverse_word_order "$list");
    do
        echo "} // namespace $item"
    done
}

print_starred_license() {
    cat "$root/LICENSE" | sed 's|^| * |g' | sed 's|[[:space:]]*$||'
}

cd $root

guard=$(print_include_guard)

mkdir -p "include/${comp_dir}"
cat <<EOF > "include/${comp_path}${hdr_ext}"
/*! ${comp_name}${hdr_ext} */
/*!
$(print_starred_license)
 */

#ifndef $guard
#define $guard

$(print_namespace_begin)


$(print_namespace_end)

#endif/*$guard*/
EOF

mkdir -p "src/${comp_dir}"
cat <<EOF > "src/${comp_path}${src_ext}"
/*! ${comp_name}${src_ext} */
/*!
$(print_starred_license)
 */

#include <${comp_path}${hdr_ext}>

$(print_namespace_begin)


$(print_namespace_end)
EOF

mkdir -p "tests/${comp_dir}"
cat <<EOF > "tests/${comp_path}.cxx"
/*! ${comp_name}.cxx */

#include <${comp_path}${hdr_ext}>

#include "doctest.h"

TEST_CASE("t${comp_name}: basic")
{
    CHECK_EQ(0, 0);
}
EOF
