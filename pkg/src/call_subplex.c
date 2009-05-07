// Dear Emacs, treat this as -*- C++ -*-

#include <R.h>
#include <Rmath.h>
#include <Rdefines.h>

SEXP _subplex_Xvec;
SEXP _subplex_envir;
SEXP _subplex_fcall;

void F77_NAME(subplx) (double (*f)(int *n, double *x), int *n, double *tol, int *maxnfe, int *mode,
		       double *scale, double *x, double *fx, int *nfe, double *work, int *iwork, 
		       int *iflag);

static double subplex_objective (int *n, double *x) 
{
  double *xp, retval;
  int k;
  SEXP ans;
  R_CheckUserInterrupt();
  xp = REAL(_subplex_Xvec);
  for (k = 0; k < *n; k++) xp[k] = x[k];
  PROTECT(ans = eval(_subplex_fcall,_subplex_envir));
  retval = NUMERIC_VALUE(ans);
  UNPROTECT(1);
  return retval;
}

SEXP call_subplex (SEXP x, SEXP f, SEXP tol, SEXP maxnfe, SEXP scale, SEXP rho, SEXP args) 
{
  int nprotect = 0;
  double *work, *scalp, *xp, *Xp;
  int n, *iwork, mode = 0;
  int k, nscal;
  SEXP ans, ansnames, X, Xnames, val, counts, conv, fn, arglist;

  n = LENGTH(x);
  PROTECT(x = AS_NUMERIC(x)); nprotect++;

  if (!isFunction(f)) {
    UNPROTECT(nprotect);
    error("'f' must be a function");
  }

  PROTECT(tol = AS_NUMERIC(tol)); nprotect++;
  if ((LENGTH(tol) > 1) || (NUMERIC_VALUE(tol) < 0.0)) {
    UNPROTECT(nprotect);
    error("'tol' must be a non-negative scalar");
  }

  PROTECT(maxnfe = AS_INTEGER(maxnfe)); nprotect++;
  if (INTEGER_VALUE(maxnfe) <= 0) {
    UNPROTECT(nprotect);
    error("'maxnfe' must be a positive integer");
  }

  nscal = LENGTH(scale);
  if ((nscal > 1) && (nscal != n)) {
    UNPROTECT(nprotect);
    error("'scale' misspecified: either specify a single scale or one for each component of 'par'");
  }
  PROTECT(scale = AS_NUMERIC(scale)); nprotect++;
  scalp = REAL(scale);
  if (nscal == 1) {
    scalp[0] = -fabs(scalp[0]);
  } else {
    for (k = 0; k < nscal; k++) scalp[k] = fabs(scalp[k]);
  }

  PROTECT(fn=f); nprotect++;
  PROTECT(Xnames=GET_NAMES(x)); nprotect++;
  PROTECT(X = NEW_NUMERIC(n)); nprotect++; // for passing to subplx and return
  PROTECT(_subplex_Xvec = NEW_NUMERIC(n)); nprotect++; // for internal use within subplex_objective
  SET_NAMES(X,Xnames);
  SET_NAMES(_subplex_Xvec,Xnames);
  PROTECT(_subplex_envir=rho); nprotect++; // store the function's environment
  PROTECT(arglist = CONS(_subplex_Xvec,args)); nprotect++; // prepend Xvec onto the argument list
  PROTECT(_subplex_fcall = LCONS(fn,arglist)); nprotect++; // set up the function call
  
  PROTECT(val = NEW_NUMERIC(1)); nprotect++;
  PROTECT(counts = NEW_INTEGER(1)); nprotect++;
  PROTECT(conv = NEW_INTEGER(1)); nprotect++;

  // the following memory allocation is based on an interpretation of the subplex documentation
  if (
      !(work = (double *) R_alloc(n*(n+6)+1,sizeof(double))) ||
      !(iwork = (int *) R_alloc(2*n,sizeof(int)))
      ) {
    UNPROTECT(nprotect);
    error("'par' too large, insufficient memory available");
  }

  xp = REAL(x); Xp = REAL(X);
  for (k = 0; k < n; k++) Xp[k] = xp[k]; // copy in the initial guess vector

  F77_CALL(subplx)(subplex_objective,&n,REAL(tol),INTEGER(maxnfe),&mode,scalp,Xp,REAL(val),INTEGER(counts),
		   work,iwork,INTEGER(conv));

  if (INTEGER_VALUE(conv) == -2) {
    UNPROTECT(nprotect);
    error("illegal input in subplex");
  }

  PROTECT(ansnames = NEW_CHARACTER(4)); nprotect++;
  SET_STRING_ELT(ansnames,0,mkChar("par"));
  SET_STRING_ELT(ansnames,1,mkChar("value"));
  SET_STRING_ELT(ansnames,2,mkChar("counts"));
  SET_STRING_ELT(ansnames,3,mkChar("convergence"));
  PROTECT(ans = NEW_LIST(4)); nprotect++;
  SET_NAMES(ans,ansnames);
  SET_VECTOR_ELT(ans,0,X);
  SET_VECTOR_ELT(ans,1,val);
  SET_VECTOR_ELT(ans,2,counts);
  SET_VECTOR_ELT(ans,3,conv);

  UNPROTECT(nprotect);
  return ans;
}
