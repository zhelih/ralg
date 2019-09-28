import pyralg

def cb_f_grad(x):
  x_s = x[0] - 10
  y_s = x[1] + 5
  f = 100*x_s**2 + y_s**2 + 20
  grad = [ 200*x_s, 2*y_s ]
  return (f, grad)

print(pyralg.ralg([1,2], cb_f_grad))
