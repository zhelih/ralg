MKLROOT=$(HOME)/intel/mkl
MKLLIB=$(MKLROOT)/lib/intel64_lin
MKLINCLUDE=$(MKLROOT)/include

CXXFLAGS=-Wall -Wextra -std=c++11 -fPIC -g -O2
CXX:=g++ $(CXXFLAGS)

all: test lib

lib: libralg.a
lib_ez: libralg_ez.a

%.a:
	rm -f $@
	ar -cvq $@ $^
	ar -t $@
	ranlib $@

libralg.a: ralg.o
libralg_ez.a: ralg_ez.o mkl_cblas.o

ralg.o: ralg.cpp ralg.h
	$(CXX) -o $@ -I"$(MKLINCLUDE)" -c ralg.cpp

ralg_ez.o: ralg.cpp ralg.h
	$(CXX) -o $@ -I"cblas/" -c ralg.cpp

mkl_cblas.o: cblas/*
	gcc -c -Wall cblas/mkl_cblas.c -fPIC

python/pyralg.so: python/pyralg.cpp libralg_ez.a
	$(CXX) -o $@ -shared -I/usr/include/python2.7 -I./ -lpython2.7 -shared -Xlinker -z -Xlinker defs $^

test: libralg.a test.cpp
	$(CXX) -o $@ test.cpp -L$(MKLLIB) -L/home/lykhovyd/intel/lib/intel64 -I$(MKLINCLUDE) -I$(MKLINCLUDE)/intel64/lp64 -lmkl_blas95_lp64 -Wl,--start-group ./libralg.a $(MKLLIB)/libmkl_intel_lp64.a $(MKLLIB)/libmkl_intel_thread.a $(MKLLIB)/libmkl_core.a -Wl,--end-group -liomp5 -lpthread -lm -ldl

test_cblas: test.cpp ralg_ez.o mkl_cblas.o
	$(CXX) -o $@ -I"cblas/" $^

clean:
	rm -f *.o *.a python/*.so
