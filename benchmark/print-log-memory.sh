#!/bin/sh
NAMES=`ls *.out|sed -e's/.out//g'`
for name in $NAMES
do
    echo "ms_print $name.out > $name.format"
    ms_print $name.out > $name.format
    SIZE=`perl -nle' ($x=$1, $x=~s/,//g, print $x) if/[\d,]+\s+[\d,]+\s+([\d,]+)\s+[\d,]+\s+[\d,]+\s+[\d,]$/' $name.format|perl -le'print ((sort{$b<=>$a} <>)[0])'`
    echo "echo $SIZE >$name.max"
    echo $SIZE >$name.max 
done
