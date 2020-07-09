set term gif enhanced animate optimize size 700,480
set output 'animation.gif'

#set palette model RGB defined (0 "red", 1 "blue", 2 "green")
#set palette model RGB functions 0,0,gray
set palette defined (0.0 "blue",\
                     1.0 "red")
set xrange [-0.2:1.2]
set yrange [-0.2:0.8]
set cbrange [0:10000]
do for[i=2010:2050:1]{
  filename = sprintf('data%04d.dat',i)
  plot_title = sprintf('timestep=%d', i)
  set title plot_title
  #plot filename u 1:2:3 with points pt 5 palette notitle
  plot filename u 1:($3==-1 ? $2 : 1/0) with points pt 5 lc "gray" notitle,\
  filename u 1:($3==1 ? $2 :1/0) with points pt 5 lc "black" notitle,\
  filename u 1:($3==0 ? $2 :1/0):4 with points pt 5 palette notitle,\
  filename u 1:($5==1 ? $2 :1/0) with points pt 2 lc "red" ps 2 notitle
}

set out
reset
set term wxt
