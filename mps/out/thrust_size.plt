#set terminal postscript eps enhanced color "GothicBBB-Medium-UniJIS-UTF8-H"
#set output 'thrust.eps'
#set term wxt
set term png size 1280, 720
set output "size.png"

nearint(x)=(x - floor(x) <= 0.5 ? floor(x) : floor(x)+1) # 一番近い整数に丸める関数
filter(x,y)=nearint(x/y)*y                                  # yの整数倍に丸める関数

plot \
"data06/thrust.dat" u (filter($1,0.01)):2 smooth unique title "y=0.10 m",\
"data27/thrust.dat" u (filter($1,0.01)):2 smooth unique title "y=0.15 m",\
"data32/thrust.dat" u (filter($1,0.01)):2 smooth unique title "y=0.20 m"
#"data23/thrust.dat" u (filter($1,0.005)):2 smooth unique title "y=0.11 m",\
#"data24/thrust.dat" u (filter($1,0.005)):2 smooth unique title "y=0.12 m",\
#"data25/thrust.dat" u (filter($1,0.005)):2 smooth unique title "y=0.13 m",\
#"data26/thrust.dat" u (filter($1,0.005)):2 smooth unique title "y=0.14 m",\
#"data28/thrust.dat" u (filter($1,0.005)):2 smooth unique title "y=0.16 m",\
#"data29/thrust.dat" u (filter($1,0.005)):2 smooth unique title "y=0.17 m",\
#"data30/thrust.dat" u (filter($1,0.005)):2 smooth unique title "y=0.18 m",\
#"data31/thrust.dat" u (filter($1,0.005)):2 smooth unique title "y=0.19 m",\

reset

