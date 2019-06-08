#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
read -r -d '' help << EOM
Usage: $0 <filename>
EOM
echo "$help"
exit 1
fi

file="$1"
filename=`basename $file`

fileabs=`readlink -f $file`
filedir=$(basename $(dirname "$fileabs"))/"$filename"
include_guard=$(echo "$file" | tr '[:lower:]' '[:upper:]' | sed 's/\./_/g' | sed 's/\//_/g')

dir=$(dirname "$filedir" | tr '[:upper:]' '[:lower:]')

srcdir=$(readlink -f $(dirname "$0"))
mkdir -p $(dirname "$file")

if [[ $(dirname $(dirname $(dirname "$file"))) == "." ]]; then
IFS=''
read -d '' -r content << EOM
/*! $filename */
/*!
`cat $srcdir/LICENSE | sed 's/^/ \* /' | sed 's/ \* $/ \*/'`
 */
#ifndef $include_guard
#define $include_guard

namespace $dir {



} // namespace $dir

#endif/*$include_guard*/
EOM
else
parent=$(basename $(dirname $(dirname "$file")))
dir=$(basename $(dirname "$file"))
IFS=''
read -d '' -r content << EOM
/*! $filename */
/*!
`cat $srcdir/LICENSE | sed 's/^/ \* /' | sed 's/ \* $/ \*/'`
 */

#ifndef $include_guard
#define $include_guard

namespace $parent {
namespace $dir {



} // namespace $dir
} // namespace $parent

#endif/*$include_guard*/
EOM
fi
printf "$content" > $file
