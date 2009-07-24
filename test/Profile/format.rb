#!/usr/bin/env ruby
if ARGV.length == 0
  puts "#$0 foo.gclog"
  exit
end
LINEREG = /(\d+),(\d+)/;
THRESHOLD = 10

TYPES = [
  "LUA_TNIL", "LUA_TBOOLEAN", "LUA_TLIGHTUSERDATA",
  "LUA_TNUMBER", "LUA_TSTRING", "LUA_TTABLE",
  "LUA_TFUNCTION", "LUA_TUSERDATA", "LUA_TTHREAD",
  "LUA_TPROTO", "LUA_TUPVAL", "LUA_TDEADKEY",
]
AGELOG = {}
(0..TYPES.length).each do|typenum|
  AGELOG[typenum] = {}
end
GCLOG = ARGV[0]
File.open(GCLOG).each do|line|
  if LINEREG =~ line
    typelog = AGELOG[$1.to_i]
    age = $2.to_i
    if typelog.key?(age)
      typelog[age] += 1
    else
      typelog[age] = 1
    end
  end
end
def put_log(agelog, dir)
  valid_types = []
  (0..TYPES.length).each do|i|
    typelog = AGELOG[i]
    typename = TYPES[i]
    logname = "#{dir}/#{typename}.#{GCLOG}"
    if typelog.keys.size > 0
      File.open(logname, "w") do |file|
        valid_types.push(typename)
        typelog.keys.sort.each do|age|
          count = typelog[age]
          file.puts "#{age}\t#{count}"
        end
      end
    end
  end
  plot = "#{dir}/#{GCLOG}.gp"
  File.open(plot,"w") do|file|
    file.print <<EOM
# vim: set ft=gnuplot:
set mxtics 2
set mytics 2
set xlabel 'age at collection [allocation bytes]'
set ylabel 'objeect counts'
set grid xtics ytics mxtics mytics
plot #{valid_types.map{|t| "'#{t}.#{GCLOG}' with linespoints ti '#{t}'"}.join(",")}
set term postscript eps enhanced
set output '#{GCLOG}.eps'
replot
set term x11
EOM
  end
end
put_log(AGELOG, ".")
AGELOG.keys.each{|typenum|
  AGELOG[typenum].reject!{|age,count| count<THRESHOLD}
}
put_log(AGELOG, "rough")
