#!/usr/bin/env sh
exec=`realpath $0`
root=`dirname $exec`
rm -fr $root/_build $root/_install
