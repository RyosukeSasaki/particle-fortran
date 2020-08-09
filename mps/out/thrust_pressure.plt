#set terminal postscript eps enhanced color "GothicBBB-Medium-UniJIS-UTF8-H"
#set output 'thrust.eps'
#set term wxt
set term png size 1280, 720
set output "pressure.png"

nearint(x)=(x - floor(x) <= 0.5 ? floor(x) : floor(x)+1) # 一番近い整数に丸める関数
filter(x,y)=nearint(x/y)*y                                  # yの整数倍に丸める関数

plot "data06/thrust.dat" u (filter($1,0.005)):2 smooth unique title "4000 Pa",\
"data07/thrust.dat" u (filter($1,0.005)):2 smooth unique title "3500 Pa",\
"data08/thrust.dat" u (filter($1,0.005)):2 smooth unique title "3000 Pa",\
"data09/thrust.dat" u (filter($1,0.005)):2 smooth unique title "2500 Pa",\
"data10/thrust.dat" u (filter($1,0.005)):2 smooth unique title "2000 Pa",\
"data11/thrust.dat" u (filter($1,0.005)):2 smooth unique title "1500 Pa",\
"data12/thrust.dat" u (filter($1,0.005)):2 smooth unique title "1000 Pa",\

reset

