#!/usr/bin/python3

import numpy as np
import copy

#EL: can do all copies without mem alloc, TODO!

def ralg(opt, cb_grad_and_func, x0, is_min):
    print("Running RALG PYTHON, matrix B")
    dim = len(x0)

    B = opt['b_init'] * np.eye(dim) # identity matrix

    xk = copy.deepcopy( x0 )
    grad = np.ndarray( dim )
    # following C++ implementation
    tmp = None
    tmp2 = None
    f_optimal = 1.e100 if is_min else -1.e100

    f_val = cb_grad_and_func( xk, grad )

    it = 0
    step = opt['initstep']
    is_min_coef = 1. if is_min else -1.
    nr_matrix_reset = 0

    while True:
        it += 1
        tmp = is_min_coef * np.matmul( np.transpose(B), grad )
        d_var = np.linalg.norm(tmp)
        if d_var < opt['b_mult_grad_min']:
            print("B(grad) is 0, break")
            break

        tmp2 = np.matmul( B, tmp ) / d_var

        # adaptive step
        i = 0
        j = 0

        d_var = np.linalg.norm( tmp2 )
        tmp = copy.deepcopy( grad ) # save grad

        step_diff = 0.

        while True:
            # tmp2 : min direction
            # tmp : old grad
            # grad: new grad
            i += 1
            j += 1
            xk = xk - step*tmp2
            step_diff = step_diff + step

            f_val = cb_grad_and_func( xk, grad )
            if i == opt['nh']:
                step = step * opt['q2']
                i = 0
            if is_min_coef * (grad*tmp2).sum() <= 0.:
                break
            if j > opt['stepmax']:
                print("function is unbounded, done {} steps, current step {}".format( j, step ))
                return 0. # TODO raise?

        # TODO is_monotone

        if is_min:
            f_optimal = min(f_optimal, f_val)
        else:
            f_optimal = max(f_optimal, f_val)

        step_diff = step_diff * d_var
        if step_diff < opt['stepmin']:
            print("step is 0, break")
            break

        if j == 1:
            step = step * opt['q1']

        tmp = tmp - grad
        tmp2 = np.matmul( np.transpose(B), tmp ) * (-is_min_coef)
        d_var = np.linalg.norm( tmp2 )

        if (it-1) % opt['output_iter'] == 0:
            print(f"iter = {it}, step = {step}, func = {f_val}, norm = {d_var}, diff = {step_diff}")

        if d_var <= opt['reset']:
            print('MATRIX RESET')
            nr_matrix_reset += 1
            B = np.eye(dim)
            step = step_diff / opt['nh']
        else:
            tmp2 = tmp2 / d_var
            tmp = np.matmul( B, tmp2 )
            B = B + (1./opt['alpha'] - 1.)* ( np.vstack(tmp) * tmp2 )

        if it > opt['itermax']:
            print("max_iter reached\n")
            break

        if step <= opt['stepmin']:
            break

    print("ralg done, iterations : {}, matrix resets : {}".format( it, nr_matrix_reset ))
    print("f_optimal = {}".format( f_optimal ))
    return f_optimal, xk
