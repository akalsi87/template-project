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
test_name=`echo $filename | tr '[:upper:]' '[:lower:]' | cut -d'.' -f1`

mkdir -p $(dirname "$file")

IFS=''
read -d'' -r content << EOM
/*! $filename */

#include "doctest.h"

TEST_CASE("${test_name}: basic")
{
    CHECK_EQ(0, 0);
}
EOM

printf "$content" > $file
