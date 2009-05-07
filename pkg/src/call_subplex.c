#include <R.h>
#include <Rmath.h>
#include <Rdefines.h>

SEXP Xvec;
SEXP subplex_envir;
SEXP R_fcall;

void F77_NAME(subplx) (double (*f)(int *n, double *x), int *n, double *tol, int *maxnfe, int *mode,
		       double *scale, double *x, double *fx, int *nfe, double *work, int *iwork, 
		       int *iflag);

static double subplex_objective (int *n, double *x) 
{
  int nprotect = 0;
  double *xp, retval;
  int k;
  SEXP ans;
  R_CheckUserInterrupt();
  xp = REAL(Xvec);
  for (k = 0; k < *n; k++) xp[k] = x[k];
  PROTECT(ans = eval(R_fcall,subplex_envir)); nprotect++;
  retval = REAL(ans)[0];
  UNPROTECT(nprotect);
  return retval;
}

SEXP call_subplex (SEXP x, SEXP f, SEXP tol, SEXP maxnfe, SEXP scale, SEXP rho) 
{
  int nprotect = 0;
  double *work, *scalp, *xp, *Xp;
  int n, *iwork, mode = 0;
  int k, nscal;
  SEXP ans, ansnames, X, Xnames, val, counts, conv, fn;

  n = GET_LENGTH(x);
  PROTECT(subplex_envir=rho); nprotect++;
  PROTECT(fn=f); nprotect++;
  PROTECT(Xnames=GET_NAMES(x)); nprotect++;
  PROTECT(X = NEW_NUMERIC(n)); nprotect++; // for returning
  PROTECT(Xvec = NEW_NUMERIC(n)); nprotect++; // for internal use within subplex_objective
  SET_NAMES(X,Xnames);
  SET_NAMES(Xvec,Xnames);
  PROTECT(R_fcall = lang2(fn,Xvec)); nprotect++;

  xp = REAL(x); Xp = REAL(X);
  for (k = 0; k < n; k++) Xp[k] = xp[k];

  // the following memory allocation is based on an interpretation of the subplex documentation
  work = (double *) R_alloc(n*(n+6)+1,sizeof(double));
  iwork = (int *) R_alloc(2*n,sizeof(int));

  nscal = GET_LENGTH(scale);
  scalp = REAL(scale);
  if (nscal == 1) {
    scalp[0] = -fabs(scalp[0]);
  } else {
    for (k = 0; k < nscal; k++) scalp[k] = fabs(scalp[k]);
  }
  
  PROTECT(val = NEW_NUMERIC(1)); nprotect++;
  PROTECT(counts = NEW_INTEGER(1)); nprotect++;
  PROTECT(conv = NEW_INTEGER(1)); nprotect++;

  F77_CALL(subplx)(subplex_objective,&n,REAL(tol),INTEGER(maxnfe),&mode,scalp,Xp,REAL(val),INTEGER(counts),
		   work,iwork,INTEGER(conv));

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
