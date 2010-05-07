#!/bin/zsh
export TIME='%C: %U user %S system %e total %PCPU (%F+%R)pfault %Wswap'
LUA=$1
OUT=$2
test() {
  $1 $2 revcomp.lua 0 < input/revcomp-input2500000.txt 2>$OUT/revcomp.txt
  $1 $2 meteor.lua 2098 2>$OUT/meteor.txt
  $1 $2 knucleotide.lua 0 < input/knucleotide-input250000.txt 2>$OUT/knucleotide.txt
  $1 $2 pidigits.lua 10000 2>$OUT/pidgits.txt
  $1 $2 binarytrees.lua 16 2>$OUT/binarytrees.txt
  $1 $2 fasta.lua 25000000 2>$OUT/fasta.txt
  $1 $2 ao.lua 0 2>$OUT/ao.txt
  $1 $2 spectralnorm.lua 5500 2>$OUT/spectralnorm.txt
  $1 $2 nbody.lua 50000000 2>$OUT/nbody.txt
  $1 $2 mandelbrot.lua 16000 2>$OUT/mandelbrot.txt
  $1 $2 fannkuch.lua 12 2>$OUT/fannkuch.txt
}
echo '## start test'
test time $LUA 2>&1 >/dev/null
echo '## end test'
