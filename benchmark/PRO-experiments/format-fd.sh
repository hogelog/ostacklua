#!/bin/sh

ISIZE=`perl -e'print $1 if readline =~ / (\d+).+ (\d+)/' $1`
echo $ISIZE
perl -nle"print(\$1-$ISIZE, ' ', \$2) if/ (\d+).+ (\d+)/" $1
