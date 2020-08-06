set term gif enhanced animate delay 2 optimize size 720,1280
set output 'animation.gif'
#set terminal postscript eps enhanced color "GothicBBB-Medium-UniJIS-UTF8-H"
#set output 'init.eps'

#set palette model RGB defined (0 "red", 1 "blue", 2 "green")
#set palette model RGB functions 0,0,gray
set size ratio 3.5
set palette defined (0.0 "blue",\
                     1.0 "red")

wall_size = 0.8
fluid_size = 0.7

set xrange [-0.05:0.15]
set yrange [-0.25:0.45]
set cbrange [0:6000]
do for[i=0:600:1]{
  filename = sprintf('data%04d.dat',i)
  plot_title = sprintf('timestep=%d', i)
  set title plot_title
  plot filename u 1:($3==-1 ? $2 : 1/0) with points pt 5 ps wall_size lc "gray" title "dummy",\
  filename u 1:($3==1 ? $2 :1/0) with points pt 5 ps wall_size lc "black" title "wall",\
  filename u 1:($3==0 ? $2 :1/0):4 with points pt 5 ps fluid_size palette title "fluid",\
  filename u 1:($5==1 ? $2 :1/0) with points pt 2 lc "red" ps 0.7 title "collision"
}

set out
reset
set term wxt
