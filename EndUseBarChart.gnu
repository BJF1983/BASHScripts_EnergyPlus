set term png

set datafile separator ","

set boxwidth 0.5
set style fill solid
set style line 1 lc rgb "blue"
set ylabel "kWh"
set title "Annual Energy Use by Category"
unset key

set yrange [0:40000]

plot "MeterskWh.csv" using 1:3:xtic(2) with boxes ls 1