#include <R.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>

extern SEXP call_subplex (SEXP x, SEXP f, SEXP tol, SEXP maxnfe, SEXP scale, SEXP hessian, SEXP rho, SEXP args);

static const R_CallMethodDef callMethods[] = {
  {"C_subplex", (DL_FUNC) &call_subplex, 8},
  {NULL, NULL, 0}
};

void R_init_subplex (DllInfo *info) {
  // Register routines
  R_registerRoutines(info,NULL,callMethods,NULL,NULL);
  R_useDynamicSymbols(info,FALSE);
  R_forceSymbols(info,TRUE);
}
