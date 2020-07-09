FILES=../lib/consts_variables.f90\
			../lib/Define.f90\
			../lib/functions.f90\
			../lib/calcExplicit.f90\
			../lib/calcImplicit.f90\
			../lib/InitParticles.f90\
			../lib/calcConsts.f90\
			../main.f90

main: $(FILES)
	gfortran -fopenmp $(FILES) -o main.o
	#gfortran $(FILES) -o main.o

clean:
	rm *.o
	rm *.mod
