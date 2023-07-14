MKLROOT=$(HOME)/intel/mkl
MKLLIB=$(MKLROOT)/lib/intel64_lin
MKLINCLUDE=$(MKLROOT)/include

MKL=mkl-static-lp64-iomp
MKL_CFLAGS=$(shell pkg-config --cflags $(MKL))
MKL_LIBS=$(shell pkg-config --libs $(MKL))

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
	$(CXX) -o $@ $(MKL_CFLAGS) -c $<

ralg_ez.o: ralg.cpp ralg.h
	$(CXX) -o $@ -I"cblas/" -c $<

mkl_cblas.o: cblas/*
	gcc -c -Wall cblas/mkl_cblas.c -fPIC

python/pyralg.so: python/pyralg.cpp libralg_ez.a
	$(CXX) -o $@ -shared -I/usr/include/python2.7 -I./ -lpython2.7 -shared -Xlinker -z -Xlinker defs $^

test: libralg.a test.cpp
	$(CXX) -o $@ test.cpp ./libralg.a $(MKL_LIBS)

test_ez: test.cpp ralg_ez.o mkl_cblas.o
	$(CXX) -o $@ -I"cblas/" $^

clean:
	rm -f *.o *.a python/*.so
