# vim: set ft=gnuplot:
set mxtics 2
set mytics 2
set xlabel 'age at collection [allocation bytes]'
set ylabel 'objeect counts'
set grid xtics ytics mxtics mytics
plot 'LUA_TTABLE.ao.lua.gclog' with linespoints ti 'LUA\_TTABLE'
set term postscript eps enhanced
set output 'ao.lua.gclog.eps'
replot
set term x11
