# vim: set ft=gnuplot:
set yrange [ 10 : 300 ]
set mxtics 2
set mytics 2
set xlabel 'age at collection [allocation bytes]'
set ylabel 'objeect counts'
set grid xtics ytics mxtics mytics
plot 'LUA_TSTRING.life.lua.gclog' with linespoints ti 'LUA\_TSTRING'
set term postscript eps enhanced
set output 'life.lua.gclog.eps'
replot
set term x11
