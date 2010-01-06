#!/bin/zsh
export TIME='%C: %U user %S system %e total %PCPU (%F+%R)pfault %Wswap'
LUA=$1
test() {
  $1 $2 revcomp.lua 0 < input/revcomp-input2500000.txt
  $1 $2 meteor.lua 2098
  $1 $2 knucleotide.lua 0 < input/knucleotide-input250000.txt
  $1 $2 pidigits.lua 10000
  $1 $2 binarytrees.lua 16
  $1 $2 fasta.lua 25000000
  $1 $2 ao.lua
  $1 $2 spectralnorm.lua 5500
  $1 $2 nbody.lua 50000000
  $1 $2 mandelbrot.lua 16000
  $1 $2 fannkuch.lua 12
}
test time $LUA >/dev/null
