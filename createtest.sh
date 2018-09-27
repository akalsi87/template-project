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
test_name=`echo $filename | tr '[:upper:]' '[:lower:]' | sed 's/\./_/g' | sed 's/\//_/g'`

IFS=''
read -d'' -r content << EOM
/*! $filename */

#include "defs.h"

setupSuite($test_name)
{
    /* addTest(foo); */
}

EOM

printf "$content" > $file

base_exe=`readlink -f $0`
base_dir=`dirname $base_exe`

echo "runSuite($test_name);" >> "$base_dir/tests/suites.h"
