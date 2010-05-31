#!/bin/sh
perl -nle' ($x=$1, $x=~s/,//g, print $x) if/[\d,]+\s+[\d,]+\s+([\d,]+)\s+[\d,]+\s+[\d,]+\s+[\d,]$/' $1|perl -le'print ((sort{$b<=>$a} <>)[0])'
