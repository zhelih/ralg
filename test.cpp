// NB
// turn the std=c++11 feature with g++
// no actions needed with Visual C++ which support C++11 standart

#include <cstdio>
#include <cmath>
#include "ralg.h"

inline double sign(double x)
{
  if (x < 0) return -1.;
  if (x > 0) return 1.;
  return 0.;
}

int main()
{
  double x0[2]; x0[0] = 1000; x0[1] = 1000;
  double res[2];


  ralg_options opt = defaultOptions;
  opt.output_iter = 1;
  ralg(&opt,
          [](const double* x, double& f, double* grad) -> bool
          {
            f = 1000*(x[0]-3)*(x[0]-3) + x[1]*x[1];
            grad[0] = 1000*2*(x[0]-3);
            grad[1] = 2*x[1];
            return true;
          },
          2,
          x0,
          res);
  printf("for 1000(x-3)^2 + y^2 -> min the answer is %.2lf %.2lf\n", res[0], res[1]);
  ralg(&opt,
          [](const double* x, double& f, double* grad) -> bool
          {
            f = 1000*(x[0]-3)*(x[0]-3) + x[1]*x[1];
            grad[0] = 1000*2*(x[0]-3);
            grad[1] = 2*x[1];
            f = -f; grad[0] = -grad[0]; grad[1] = -grad[1];
            return true;
          },
          2,
          x0,
          res, RALG_MAX);
  printf("for inv 1000(x-3)^2 + y^2 -> max the answer is %.2lf %.2lf\n", res[0], res[1]);
  opt.is_monotone = false;
  ralg(&opt,
          [](const double* x, double& f, double* grad) -> bool
          {
            f = -(x[0]-3)*(x[0]-3) - 0.001*x[1]*x[1];
            grad[0] = -2*(x[0]-3);
            grad[1] = -0.001*2*x[1];
            return true;
          },
          2,
          x0,
          res,
          RALG_MIN);
  printf("for -(x-3)^2 - 0.001y^2 -> max the answer is %.2lf %.2lf\n", res[0], res[1]);
  ralg(&opt,
          [](const double* x, double& f, double* grad) -> bool
          {
            f = fabs(x[0]-3) + 100.*fabs(x[0]+2) + 0.001*fabs(x[1]);
            grad[0] = sign(x[0]-3) + 100.*sign(x[0]+2);
            grad[1] = 0.001*sign(x[1]);
            return true;
          },
          2,
          x0,
          res,
          RALG_MIN);
  printf("for |x-3| + 100|x+2| + 0.001|y| -> min the answer is %.2lf %.2lf\n", res[0], res[1]);

  return 0;
}
