#!/bin/bash

#-------------------------------------------------------------------------------
echo "* setup"

srcdir=/usr/bin
[[ -f awk.exe ]] && mv awk.exe gawk.exe
rm -f *.dll

#-------------------------------------------------------------------------------
echo "* renew all files"

for f in *
do
    if [[ -f $srcdir/$f ]]
    then
	cp --preserve=timestamps "$srcdir/$f" .
    elif [[ ${f:0:1} != _ ]]
    then
        echo "   - Can't find file in '$srcdir': $f"
    fi
done

#-------------------------------------------------------------------------------
echo "* search needed dll files"

for f in *.exe
do
    ldd "$f" | grep -F '=> /usr/bin/' | awk '{print $1}'
done | sort | uniq \
    | while read dll
    do
	echo "   - $dll"
	cp --preserve=timestamps "$srcdir/$dll" .
    done

rm -f "$list" "$list.new"

#-------------------------------------------------------------------------------
echo "* term"

[[ -f gawk.exe ]] && mv gawk.exe awk.exe

