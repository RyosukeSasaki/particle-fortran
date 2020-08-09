FILES=../lib/consts_variables.f90\
			../lib/Define.f90\
			../lib/functions.f90\
			../lib/calcExplicit.f90\
			../lib/calcImplicit.f90\
			../lib/InitParticles.f90\
			../lib/calcConsts.f90\
			../main.f90

n=main

main: $(FILES)
	gfortran -fopenmp $(FILES) -o $(n).o
	#gfortran $(FILES) -o main.o

run: $(FILES)
	gfortran -fopenmp $(FILES) -o $(n).o
	./$(n).o

clean:
	rm *.o
	rm *.mod
