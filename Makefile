#BLAS=mkl-static-lp64-iomp
#BLAS=openblas
BLAS=blas

BLAS_CFLAGS=$(shell pkg-config --cflags $(BLAS))
BLAS_LIBS=$(shell pkg-config --libs $(BLAS))

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
libralg_ez.a: ralg_ez.o cblas.o

ralg.o: ralg.cpp ralg.h
	$(CXX) -o $@ $(BLAS_CFLAGS) -c $<

ralg_ez.o: ralg.cpp ralg.h
	$(CXX) -o $@ -I"cblas/" -c $<

cblas.o: cblas/*
	gcc -c -Wall cblas/cblas.c -fPIC

python/pyralg.so: python/pyralg.cpp libralg_ez.a
	$(CXX) -o $@ -shared -I/usr/include/python2.7 -I./ -lpython2.7 -shared -Xlinker -z -Xlinker defs $^

test: test.cpp libralg.a
	$(CXX) -o $@ $^ $(BLAS_LIBS)

test_ez: test.cpp ralg_ez.o cblas.o
	$(CXX) -o $@ $^

clean:
	rm -f *.o *.a python/*.so
