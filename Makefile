MKLROOT=/home/lykhovyd/intel/mkl
MKLLIB=$(MKLROOT)/lib/intel64_lin
MKLINCLUDE=$(MKLROOT)/include

all: test lib

lib: ralg.o
	rm libralg.a || true
	ar -cvq libralg.a ralg.o
	ar -t libralg.a
	ranlib libralg.a

ralg.o: ralg.cpp ralg.h
	g++ -c -Wall ralg.cpp -O2 -I"$(MKLINCLUDE)" -std=c++11

ralg_ez.o: ralg.cpp ralg.h
	g++ -c -Wall ralg.cpp -I"cblas/" -std=c++11 -o ralg_ez.o

cblas.o: cblas/*
	gcc -c -Wall cblas/mkl_cblas.c

test: lib test.cpp
	g++ -o test -Wall test.cpp -std=c++11 -O2 -L$(MKLLIB) -L/home/lykhovyd/intel/lib/intel64 -I$(MKLINCLUDE) -I$(MKLINCLUDE)/intel64/lp64 -lmkl_blas95_lp64 -Wl,--start-group ./libralg.a $(MKLLIB)/libmkl_intel_lp64.a $(MKLLIB)/libmkl_intel_thread.a $(MKLLIB)/libmkl_core.a -Wl,--end-group -liomp5 -lpthread -lm -ldl

test_cblas: ralg_ez.o cblas.o
	g++ -o test_cblas -Wall test.cpp -std=c++11 -O2 mkl_cblas.o ralg_ez.o -I"cblas/"
