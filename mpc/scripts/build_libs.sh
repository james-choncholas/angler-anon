#!/bin/bash
scriptpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set -e

# emp-tool has to be first to put common.cmake in /usr/local
dirz="${scriptpath}/../emp-tool/
${scriptpath}/../emp-ot/
${scriptpath}/../emp-ag2pc/
${scriptpath}/../emp-agmpc/
${scriptpath}/../emp-sh2pc/"

echo "$dirz" | while read libdir; do
    cd $libdir
    rm -f CMakeCache.txt
    echo "Running for dir $libdir "
    cmake .
    make -j8
    sudo make install
    cd -
done


