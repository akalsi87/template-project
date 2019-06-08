#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
read -d'' -r help << EOM
Usage: $0 <filename>
EOM
echo "$help"
exit 1
fi

file="$1"
filename=`basename $file`

fileabs=`readlink -f $file`
filedir=$(basename $(dirname "$fileabs"))/"$filename"

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

namespace $dir {



} // namespace $dir

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

namespace $parent {
namespace $dir {



} // namespace $dir
} // namespace $parent

EOM
fi

printf "$content" > $file
