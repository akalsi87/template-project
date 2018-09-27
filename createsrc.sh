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
include_guard=`echo $filedir | tr '[:lower:]' '[:upper:]' | sed 's/\./_/g' | sed 's/\//_/g'`

dir=$(dirname "$filedir" | tr '[:upper:]' '[:lower:]')

srcdir=$(readlink -f $(dirname "$0"))

IFS=''
read -d '' -r content << EOM
/*! $filename */
/*!
`cat $srcdir/LICENSE | sed 's/^/ \* /' | sed 's/ \* $/ \*/'`
 */

namespace $dir {



} // namespace $dir

EOM

printf "$content" > $file
