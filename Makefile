MKLROOT=/home/lykhovyd/intel/mkl
MKLLIB=$(MKLROOT)/lib/intel64_lin
MKLINCLUDE=$(MKLROOT)/include

all: test lib

lib:
	rm libralg.a || true
	g++ -c -Wall ralg.cpp -O2 -I"$(MKLINCLUDE)" -std=c++11
	ar -cvq libralg.a ralg.o
	ar -t libralg.a
	ranlib libralg.a

test: lib
	g++ -o test -Wall test.cpp -std=c++11 -O2 -L$(MKLLIB) -L/home/lykhovyd/intel/lib/intel64 -I$(MKLINCLUDE) -I$(MKLINCLUDE)/intel64/lp64 -lmkl_blas95_lp64 -Wl,--start-group ./libralg.a $(MKLLIB)/libmkl_intel_lp64.a $(MKLLIB)/libmkl_intel_thread.a $(MKLLIB)/libmkl_core.a -Wl,--end-group -liomp5 -lpthread -lm -ldl
