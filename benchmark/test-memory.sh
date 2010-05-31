#!/bin/zsh
export TIME='%C: %U user %S system %e total %PCPU (%F+%R)pfault %Wswap'
LUA=$1
SCRIPTDIR=scripts
MASSIF='valgrind --tool=massif --massif-out-file=tmp.out'
report() {
  echo '#start test' >>$1.out
  cat tmp.out >>$1.out
  ms_print tmp.out >>$1.format
}
test() {
  sh -c "$1 $2 $SCRIPTDIR/FileLoop.lua 0"
  report 'log-memory/FileLoop'
  sh -c "$1 $2 $SCRIPTDIR/revcomp.lua 0 < input/revcomp-input25000.txt"
  report 'log-memory/revcomp'
  sh -c "$1 $2 $SCRIPTDIR/meteor.lua 2098"
  report 'log-memory/meteor'
  sh -c "$1 $2 $SCRIPTDIR/knucleotide.lua 0 < input/knucleotide-input250000.txt"
  report 'log-memory/knucleotide'
  sh -c "$1 $2 $SCRIPTDIR/pidigits.lua 10000"
  report 'log-memory/pidgits'
  sh -c "$1 $2 $SCRIPTDIR/binarytrees.lua 16"
  report 'log-memory/binarytrees'
  sh -c "$1 $2 $SCRIPTDIR/fasta.lua 25000000"
  report 'log-memory/fasta'
  sh -c "$1 $2 $SCRIPTDIR/ao.lua 0"
  report 'log-memory/ao'
  sh -c "$1 $2 $SCRIPTDIR/spectralnorm.lua 5500"
  report 'log-memory/spectralnorm'
  sh -c "$1 $2 $SCRIPTDIR/nbody.lua 50000000"
  report 'log-memory/nbody'
  sh -c "$1 $2 $SCRIPTDIR/mandelbrot.lua 16000"
  report 'log-memory/mandelbrot'
  sh -c "$1 $2 $SCRIPTDIR/fannkuch.lua 12"
  report 'log-memory/fannkuch'
}
test $MASSIF $LUA >/dev/null
