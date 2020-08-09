set terminal postscript eps enhanced color "GothicBBB-Medium-UniJIS-UTF8-H"
set output 'rho.eps'
#set term wxt
#set term png size 1280, 720
#set output "rho.png"

nearint(x)=(x - floor(x) <= 0.5 ? floor(x) : floor(x)+1) # 一番近い整数に丸める関数
filter(x,y)=nearint(x/y)*y                                  # yの整数倍に丸める関数

plot \
"data13/thrust.dat" u 1:2 smooth unique title "1100 kg/m^3",\
"data14/thrust.dat" u 1:2 smooth unique title "1200 kg/m^3",\
"data15/thrust.dat" u 1:2 smooth unique title "1300 kg/m^3",\
"data16/thrust.dat" u 1:2 smooth unique title "1400 kg/m^3",\
"data17/thrust.dat" u 1:2 smooth unique title "1500 kg/m^3",\
"data18/thrust.dat" u 1:2 smooth unique title "1600 kg/m^3",\
"data19/thrust.dat" u 1:2 smooth unique title "1700 kg/m^3",\
"data20/thrust.dat" u 1:2 smooth unique title "1800 kg/m^3",\
"data21/thrust.dat" u 1:2 smooth unique title "1900 kg/m^3",\
"data22/thrust.dat" u 1:2 smooth unique title "1200 kg/m^3",\

reset

