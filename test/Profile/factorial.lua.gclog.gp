# vim: set ft=gnuplot:
set mxtics 2
set mytics 2
set xlabel 'age at collection [allocation bytes]'
set ylabel 'objeect counts'
set grid xtics ytics mxtics mytics
plot 'LUA_TSTRING.factorial.lua.gclog' with linespoints ti 'LUA_TSTRING','LUA_TTABLE.factorial.lua.gclog' with linespoints ti 'LUA_TTABLE','LUA_TFUNCTION.factorial.lua.gclog' with linespoints ti 'LUA_TFUNCTION','LUA_TUSERDATA.factorial.lua.gclog' with linespoints ti 'LUA_TUSERDATA','LUA_TTHREAD.factorial.lua.gclog' with linespoints ti 'LUA_TTHREAD','LUA_TPROTO.factorial.lua.gclog' with linespoints ti 'LUA_TPROTO','LUA_TUPVAL.factorial.lua.gclog' with linespoints ti 'LUA_TUPVAL'
set term postscript eps enhanced
set output 'factorial.lua.gclog.eps'
replot
set term x11
