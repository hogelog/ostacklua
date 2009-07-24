# vim: set ft=gnuplot:
set mxtics 2
set mytics 2
set xlabel 'age at collection [allocation bytes]'
set ylabel 'objeect counts'
set grid xtics ytics mxtics mytics
plot 'LUA_TSTRING.ao.lua.gclog' with linespoints ti 'LUA_TSTRING','LUA_TTABLE.ao.lua.gclog' with linespoints ti 'LUA_TTABLE','LUA_TFUNCTION.ao.lua.gclog' with linespoints ti 'LUA_TFUNCTION','LUA_TUSERDATA.ao.lua.gclog' with linespoints ti 'LUA_TUSERDATA','LUA_TTHREAD.ao.lua.gclog' with linespoints ti 'LUA_TTHREAD','LUA_TPROTO.ao.lua.gclog' with linespoints ti 'LUA_TPROTO'
set term postscript eps enhanced
set output 'ao.lua.gclog.eps'
replot
set term x11
