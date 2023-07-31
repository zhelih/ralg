#BLAS=mkl-static-lp64-iomp
#BLAS=openblas
#BLAS=blas

ifeq ($(BLAS),)
BLAS_CFLAGS=-Icblas
BLAS_LIBS=
BLAS_BUILTIN=cblas.o
else
BLAS_CFLAGS=$(shell pkg-config --cflags $(BLAS))
BLAS_LIBS=$(shell pkg-config --libs $(BLAS))
BLAS_BUILTIN=
endif

CXXFLAGS=-Wall -Wextra -std=c++11 -fPIC -g -O2
CXX:=g++ $(CXXFLAGS)

all: test lib

lib: libralg.a

%.a:
	rm -f $@
	ar -cvq $@ $^
	ar -t $@
	ranlib $@

libralg.a: ralg.o $(BLAS_BUILTIN)

ralg.o: ralg.cpp ralg.h
	$(CXX) -o $@ $(BLAS_CFLAGS) -c $<

cblas.o: cblas/*
	gcc -c -Wall cblas/cblas.c -fPIC

python/pyralg.so: python/pyralg.cpp libralg.a
	$(CXX) -o $@ -shared -I/usr/include/python2.7 -I./ -lpython2.7 -shared -Xlinker -z -Xlinker defs $^

.PHONY: ocaml
ocaml: lib
	dune build

test: test.cpp libralg.a
	$(CXX) -o $@ $^ $(BLAS_LIBS)

clean:
	rm -f *.o *.a python/*.so
	-dune clean
