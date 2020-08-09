set terminal postscript eps enhanced color "GothicBBB-Medium-UniJIS-UTF8-H"
set output 'pre.eps'
#set term wxt
#set term png size 1280, 720
#set output "pressure.png"

nearint(x)=(x - floor(x) <= 0.5 ? floor(x) : floor(x)+1) # 一番近い整数に丸める関数
filter(x,y)=nearint(x/y)*y                                  # yの整数倍に丸める関数

set xlabel "時間 / sec"
set ylabel "推力 / N"

plot \
"data12/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件1.1",\
"data10/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件1.3",\
"data06/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件1.7",\
#"data09/thrust.dat" u (filter($1,0.01)):2 smooth unique title "条件1.4",\
#"data07/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件1.6",\
#"data11/thrust.dat" u (filter($1,0.001)):2 smooth unique title "条件1.2",\
#"data08/thrust.dat" u (filter($1,0.001)):2 smooth unique title "条件1.5",\

reset

