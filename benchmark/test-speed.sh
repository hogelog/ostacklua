#!/bin/zsh
export TIME='%C: %U user %S system %e total %PCPU (%F+%R)pfault %Wswap'
LUA=$1
OUT=$2
SCRIPTDIR=scripts
test() {
  $1 $2 $SCRIPTDIR/FileLoop.lua 0 2>$OUT/FileLoop.txt
  $1 $2 $SCRIPTDIR/revcomp.lua 0 < input/revcomp-input2500000.txt 2>$OUT/revcomp.txt
  $1 $2 $SCRIPTDIR/meteor.lua 2098 2>$OUT/meteor.txt
  $1 $2 $SCRIPTDIR/knucleotide.lua 0 < input/knucleotide-input250000.txt 2>$OUT/knucleotide.txt
  $1 $2 $SCRIPTDIR/pidigits.lua 10000 2>$OUT/pidgits.txt
  $1 $2 $SCRIPTDIR/binarytrees.lua 16 2>$OUT/binarytrees.txt
  $1 $2 $SCRIPTDIR/fasta.lua 25000000 2>$OUT/fasta.txt
  $1 $2 $SCRIPTDIR/ao.lua 0 2>$OUT/ao.txt
  $1 $2 $SCRIPTDIR/spectralnorm.lua 5500 2>$OUT/spectralnorm.txt
  $1 $2 $SCRIPTDIR/nbody.lua 50000000 2>$OUT/nbody.txt
  $1 $2 $SCRIPTDIR/mandelbrot.lua 16000 2>$OUT/mandelbrot.txt
  $1 $2 $SCRIPTDIR/fannkuch.lua 12 2>$OUT/fannkuch.txt
}
echo '## start test'
test time $LUA 2>&1 >/dev/null
echo '## end test'
