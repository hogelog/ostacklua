set ytics 100000
set xtics 200000
set grid xtics ytics

set xlabel "elapsed time (bytes)"
set ylabel "memory usage"
plot "massif-original.log" using 1:2 with lines ti "original"
replot "massif-stackalloc.log" using 1:2 with lines ti "proposal"

set term postscript eps enhanced
set output "massif.eps"
replot
set term wxt 0
