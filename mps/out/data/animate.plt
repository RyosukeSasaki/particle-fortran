set term gif enhanced animate optimize size 700,480
set output 'animation.gif'

set palette model RGB defined (0 "red", 1 "blue", 2 "green")
do for[i=1:100:1]{
  filename = sprintf('data%03d.dat',i)
  plot_title = sprintf('timestep=%d', i*10)
  set title plot_title
  plot filename u 1:2:3 with points pt 5 palette notitle
}

set out
reset
set term wxt
