set terminal postscript eps enhanced color "GothicBBB-Medium-UniJIS-UTF8-H"
set output 'V_pressure.eps'

set xlabel "圧力P / Pa"
set ylabel "運動量p / ms"

plot "deltaV_pressure.dat" notitle
