set ytics 100
set xtics 10000
set grid xtics ytics

set xlabel "elapsed time (bytes)"
set ylabel "file descriptor"
plot "fdcount-original.log" using 1:2 with lines ti "original"
replot "fdcount-stackalloc.log" using 1:2 with lines ti "proposal"

set term postscript eps enhanced
set output "fdcount.eps"
replot
set term wxt 0
