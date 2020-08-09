set terminal postscript eps enhanced color "GothicBBB-Medium-UniJIS-UTF8-H"
set output 'V_size.eps'

set xlabel "水の量 / m^3"
set ylabel "運動量p / ms"

a=1
b=1
f(x) = a*x+b
fit f(x) "deltaV_size.dat" u 1:2 via a, b
plot "deltaV_size.dat" notitle, f(x)
