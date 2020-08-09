set terminal postscript eps enhanced color "GothicBBB-Medium-UniJIS-UTF8-H"
set output 'size.eps'
#set term wxt
#set term png size 1280, 720
#set output "size.png"

nearint(x)=(x - floor(x) <= 0.5 ? floor(x) : floor(x)+1) # 一番近い整数に丸める関数
filter(x,y)=nearint(x/y)*y                                  # yの整数倍に丸める関数

set xlabel "時間 / sec"
set ylabel "推力 / N"

plot \
"data06/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.1",\
"data27/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.6",\
"data32/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.11",\
#"data31/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.10",\
#"data24/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.3",\
#"data23/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.2",\
#"data25/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.4",\
#"data26/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.5",\
#"data28/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.7",\
#"data29/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.8",\
#"data30/thrust.dat" u (filter($1,0.005)):2 smooth unique title "条件2.9",\

reset

