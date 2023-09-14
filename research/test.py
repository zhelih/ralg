#!/usr/bin/python3

from ralg_B import ralg

ralg_options = {
    "q1": 0.95,
    "q2": 1.2,
    "nh": 3,
    "alpha": 2,
    "itermax": 10000,
    "stepmax": 500,
    "stepmin": 1.e-12,
    "b_mult_grad_min": 1.e-12,
    "reset": 1.e-12,
    "initstep": 1.,
    "output": True,
    "output_iter": 1,
    "b_init": 1.,
    "is_monotone": True
}

def sign( x ):
    if x > 0:
        return 1.
    elif x < 0:
        return -1.
    else:
        return 0.

nr_f_evals = 0

def cb_f_grad_1( xk, grad ):
    # |x-3| + 100|x+2| + 0.001|y| and min
    x = xk[0]
    y = xk[1]
    f = abs(x-3) + 100*abs(x+2) + 0.001*abs(y)
    grad[0] = sign(x-3) + 100*sign(x+2)
    grad[1] = 0.001 * sign(y)
    global nr_f_evals
    nr_f_evals+=1
    return f

def cb_f_grad_rosenbrock( xk, grad ): # not really convex
    # f(x,y) = (a-x)^2 + b(y-x^2)^2, a = 1, b = 100
    x = xk[0]
    y = xk[1]
    f = (1-x)**2 + 100*(y - x**2)**2
    grad[0] = -2*(1-x) + 2*100*(y-x**2)*(-2)*x
    grad[1] = 2*100*(y-x**2)
    global nr_f_evals
    nr_f_evals+=1
    return f

import numpy

dim = 2
x0 = numpy.array( [100]*dim )

#f_opt, x_opt = ralg( ralg_options, cb_f_grad_1, x0, True ) # True = minimize

# test Rosenbrock from nasty (-3,-4)
x0[0] = -3
x0[0] = -4
f_opt, x_opt = ralg( ralg_options, cb_f_grad_rosenbrock, x0, True ) # True = minimize
print(f"Optimal point is {x_opt}")
print(f"Callback f/grad was called {nr_f_evals} times")
