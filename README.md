# ralg

[![Build](https://github.com/zhelih/ralg/actions/workflows/build.yml/badge.svg)](https://github.com/zhelih/ralg/actions/workflows/build.yml)

Efficient implementation of Shor's r-algorithm using MKL

During build define BLAS to the name of your blas library, e.g. `make BLAS=blas` or `make BLAS=openblas` or
`make BLAS=mkl-static-lp64-iomp`, etc. By default (BLAS undefined) builtin naive implementation will be used.

Copyright Eugene Lykhovyd 2014-2023.
All rights reserved.

- July 2019
  * OCaml stubs
  * Makefile, code refactoring

- June 5, 2019
	* partial implementation of cblas routines used; convenient when
		no MKL available and speed is not a consideration

- May 21, 2019
	* add monotonicity parameter to store the solution if
		the descned is known to be unmonotone

- Aug 21, 2018
	* public release

- Oct 2, 2014
  * matrix B mult. init

- Oct 1, 2014
  * added unlimited iterations var

- Sep 29, 2014
  * show time stats

- Sep 28, 2014
  * store the minimum func value in the case of jumps

- Sep 25, 2014
  * added support for choosing max/min problem
  * compute grad and function in 1 block
  * stepmax now is unsigned too
  * added simple test
  * fix MKL include

- late Aug 2014
  * MKL library
  * C++11 support
