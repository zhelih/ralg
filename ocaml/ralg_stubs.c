extern "C" {
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/alloc.h>
#include <caml/callback.h>

#include <assert.h>
}

#include <cstring>

#define UNUSED(x) (void)(x)
#define ML_EXTERN extern "C" value

#include "../ralg.h"

struct ralg_options ralg_options_of_val(value v)
{
  struct ralg_options r;

  r.q1 = Double_val(Field(v,0));
  r.q2 = Double_val(Field(v,1));
  r.nh = Unsigned_int_val(Field(v,2));
  r.alpha = Double_val(Field(v,3));
  r.itermax = Unsigned_int_val(Field(v,4));
  r.stepmax = Unsigned_int_val(Field(v,5));
  r.stepmin = Double_val(Field(v,6));
  r.b_mult_grad_min = Double_val(Field(v,7));
  r.reset = Double_val(Field(v,8));
  r.initstep = Double_val(Field(v,9));
  r.b_init = Double_val(Field(v,10));
  r.is_monotone = Bool_val(Field(v,11));
  r.output = Bool_val(Field(v,12));
  r.output_iter = Unsigned_int_val(Field(v,13));

  return r;
}

value val_of_ralg_options(struct ralg_options const& r)
{
  CAMLparam0();
  CAMLlocal1(v);

  v = caml_alloc_tuple(14);
  Store_field(v,0,caml_copy_double(r.q1));
  Store_field(v,1,caml_copy_double(r.q2));
  Store_field(v,2,Val_int(r.nh));
  Store_field(v,3,caml_copy_double(r.alpha));
  Store_field(v,4,Val_int(r.itermax));
  Store_field(v,5,Val_int(r.stepmax));
  Store_field(v,6,caml_copy_double(r.stepmin));
  Store_field(v,7,caml_copy_double(r.b_mult_grad_min));
  Store_field(v,8,caml_copy_double(r.reset));
  Store_field(v,9,caml_copy_double(r.initstep));
  Store_field(v,10,caml_copy_double(r.b_init));
  Store_field(v,11,Val_bool(r.is_monotone));
  Store_field(v,12,Val_bool(r.output));
  Store_field(v,13,Val_int(r.output_iter));

  CAMLreturn(v);
}

ML_EXTERN ml_ralg(value v_options, value v_cb, value v_vector)
{
  CAMLparam3(v_options, v_cb, v_vector);
  CAMLlocal2(v_res, v_r);
  const size_t dim = caml_array_length(v_vector);
  struct ralg_options options = ralg_options_of_val(v_options);

  auto cb = [&v_cb,dim](const double* cur, double& f, double* grad)
  {
    CAMLparam0();
    CAMLlocal4(v_cur,v_result,v_f,v_grad);
    v_cur = caml_alloc_float_array(dim);
    memcpy(&Double_flat_field(v_cur,0), cur, sizeof(double) * dim);
    v_result = caml_callback_exn(v_cb, v_cur);
    bool valid = Is_exception_result(v_result) ? false : Is_some(v_result);
    if (valid)
    {
      f = Double_val(Field(Some_val(v_result),0));
      memcpy(grad, &Double_flat_field(Field(Some_val(v_result),1),0), sizeof(double) * dim);
    }
    CAMLreturnT(bool,valid);
  };

  double* res = (double*)malloc(dim * sizeof(double));
  /* FIXME v_vector not 100% safe */
  double f = ralg(&options, cb, dim, &Double_flat_field(v_vector,0), res);
  v_res = caml_alloc_float_array(dim);
  memcpy(&Double_flat_field(v_res,0), res, dim * sizeof(double));
  free(res); res = NULL;
  v_r = caml_alloc_tuple(2);
  Store_field(v_r, 0, caml_copy_double(f));
  Store_field(v_r, 1, v_res);

  CAMLreturn(v_r);
}

ML_EXTERN ml_ralg_default_options(value v_unit)
{
  return val_of_ralg_options(defaultOptions);
}
