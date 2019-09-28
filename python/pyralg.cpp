#include <Python.h>
#include "ralg.h"

static PyObject* ralg_wrapper(PyObject* self, PyObject *args)
{
  // get x0
  PyObject* py_x0; PyObject* py_func;
  if(!PyArg_ParseTuple(args, "OO", &py_x0, &py_func))
  {
    //TODO fail
  }
  if(!PyCallable_Check(py_func))
  {
    //TODO fail
    PyErr_SetString(PyExc_TypeError, "second argument must be a function");
    // TODO fail
  }
  py_x0 = PySequence_Fast(py_x0, "argument must be iterable");
  if(!py_x0)
  {
    //TODO fail
  }
  int py_x0_len = PySequence_Fast_GET_SIZE(py_x0);

  double* x0 = new double[py_x0_len];
  if(!x0)
  {
    Py_DECREF(py_x0);
    PyErr_NoMemory();//TODO Fail
  }
  for(int i = 0; i < py_x0_len; ++i)
  {
    PyObject* item = PySequence_Fast_GET_ITEM(py_x0, i);
    if(!item)
    {
      Py_DECREF(py_x0);
      delete [] x0;
      //TODO fail
    }
    PyObject* ditem = PyNumber_Float(item);
    if(!ditem)
    {
      Py_DECREF(py_x0);
      delete [] x0;
      PyErr_SetString(PyExc_TypeError, "all items in x0 must be numbers");
      //TODO fail
    }
    x0[i] = PyFloat_AS_DOUBLE(ditem);
    Py_DECREF(ditem);
  }

  Py_DECREF(py_x0);

  double* res = new double[py_x0_len];

  PyObject *l = PyList_New(py_x0_len);
  if(!l)
  {
    //TODO fail
  }
  // get grad_and_func handler
  auto cb_grad_and_func = [l, py_func, py_x0_len](const double* x, double& f_val, double* grad) -> bool {
    // build Python array
    for(int i = 0; i < py_x0_len; ++i)
      PyList_SetItem(l, i, PyFloat_FromDouble(x[i]));
    //FIXME without BuildValue for performance
    PyObject* args = Py_BuildValue("(O)", l);
    PyObject* res = PyObject_CallObject(py_func, args);
    if(res == NULL)
    {
      //TODO fail
      PyErr_Print();
      return false;
    }
    double obj; PyObject* py_grad;
    if(!PyArg_ParseTuple(res, "dO", &obj, &py_grad))
    {
      //TODO fail
    }
    PyObject* py_grad_seq = PySequence_Fast(py_grad, "argument must be iterable");
    if(!py_grad_seq)
    {
      //TODO fail
    }

    int py_grad_seq_len = PySequence_Fast_GET_SIZE(py_grad_seq);
    if(py_grad_seq_len != py_x0_len)
    {
      //TODO fail
    }
    //TODO factor with x0
    for(int i = 0; i < py_x0_len; ++i)
    {
      PyObject* d_item = PySequence_Fast_GET_ITEM(py_grad_seq, i);
      if(!d_item)
      {
        //TODO fail
      }
      grad[i] = PyFloat_AS_DOUBLE(d_item);
      Py_DECREF(d_item);
    }
    f_val = obj;
    Py_DECREF(py_grad_seq);
    Py_DECREF(py_grad);
    Py_DECREF(res);
    Py_DECREF(args);
    return true;
  };

  ralg_options opt = defaultOptions;
  opt.output_iter = 1;

  double out = ralg(&opt,
          cb_grad_and_func,
          py_x0_len,
          x0,
          res, RALG_MIN);

  Py_DECREF(l);
  PyObject* py_res = PyList_New(py_x0_len);
  if(!py_res)
  {
    //TODO fail
  }
  for(int i = 0; i < py_x0_len; ++i)
    PyList_SET_ITEM(py_res, i, PyFloat_FromDouble(res[i]));

  delete [] res;
  delete [] x0;
  return Py_BuildValue("(d,O)", out, py_res);
}


static PyMethodDef pyralgMethods[] = {
    {"ralg", ralg_wrapper, METH_VARARGS, "Execute r-algorithm."},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

PyMODINIT_FUNC initpyralg()
{
  Py_InitModule("pyralg", pyralgMethods);
}

int main(int argc, char* argv[])
{
  Py_SetProgramName(argv[0]);
  Py_Initialize();
  initpyralg();
  return 0;
}
