set term gif enhanced animate optimize size 700,480
set output 'animation.gif'

set palette model RGB defined (0 "red", 1 "blue", 2 "green")
set xrange [-0.2:1.2]
set yrange [-0.2:0.8]
do for[i=1:200:2]{
  filename = sprintf('data%04d.dat',i)
  plot_title = sprintf('timestep=%d', i*10)
  set title plot_title
  plot filename u 1:2:3 with points pt 5 palette notitle
}

set out
reset
set term wxt
