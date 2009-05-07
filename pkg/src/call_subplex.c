#include <R.h>
#include <Rmath.h>
#include <Rdefines.h>

static SEXP subplex_obj_fn;
static SEXP subplex_X_names;
static SEXP subplex_envir;

void F77_NAME(subplx) (double (*)(int *, double*), 
		       int *, double *, int *, int *, 
		       double *, double *, double *, 
		       int *, double *, int *, int *);


static double subplex_user_fn (int *n, double *x) 
{
  int nprotect = 0;
  double *xp, retval;
  int k;
  SEXP R_fcall, X, ans;
  PROTECT(X = NEW_NUMERIC(*n)); nprotect++;
  xp = REAL(X);
  for (k = 0; k < *n; k++) xp[k] = x[k];
  SET_NAMES(X, subplex_X_names);
  PROTECT(R_fcall = lang2(subplex_obj_fn,X)); nprotect++;
  PROTECT(ans = eval(R_fcall,subplex_envir)); nprotect++;
  retval = REAL(ans)[0];
  UNPROTECT(nprotect);
  return retval;
}

SEXP call_subplex (SEXP x, SEXP f, SEXP tol, SEXP maxnfe, SEXP scale, SEXP rho) 
{
  int nprotect = 0;
  double *work, *scalp, *xp, *Xp, fx;
  int n, *iwork, mode, nfe, iflag = 0;
  int k, nscal;
  SEXP ans, ansnames, X, val, counts, conv;

  n = GET_LENGTH(x);
  PROTECT(subplex_envir=rho); nprotect++;
  PROTECT(subplex_obj_fn=f); nprotect++;
  PROTECT(subplex_X_names=GET_NAMES(x)); nprotect++;
  PROTECT(ans = NEW_LIST(4)); nprotect++;
  PROTECT(ansnames = NEW_CHARACTER(4)); nprotect++;
  SET_ELEMENT(ansnames,0,mkChar("par"));
  SET_ELEMENT(ansnames,1,mkChar("value"));
  SET_ELEMENT(ansnames,2,mkChar("counts"));
  SET_ELEMENT(ansnames,3,mkChar("convergence"));
  SET_NAMES(ans,ansnames);
  PROTECT(X = NEW_NUMERIC(n)); nprotect++;
  SET_NAMES(X,subplex_X_names);

  xp = REAL(x); Xp = REAL(X);
  for (k = 0; k < n; k++) Xp[k] = xp[k];

  work = (double *) Calloc(2*n+46,double *);
  iwork = (int *) Calloc(2*n,int *);

  nscal = GET_LENGTH(scale);
  scalp = REAL(scale);
  if (nscal == 1) {
    scalp[0] = -fabs(scalp[0]);
  } else {
    for (k = 0; k < nscal; k++) scalp[k] = fabs(scalp[k]);
  }
  
  mode = 0;
  nfe = 0;
  fx = 0;
  F77_CALL(subplx)(subplex_user_fn,&n,REAL(tol),INTEGER(maxnfe),&mode,scalp,Xp,&fx,&nfe,work,iwork,&iflag);

/*     call subplx (UserFun,n,tol,maxnfe,mode,scale,x,fx,nfe,work,iwork,iflag) */

  PROTECT(val = NEW_NUMERIC(1)); nprotect++;
  REAL(val)[0] = fx;
  PROTECT(counts = NEW_INTEGER(1)); nprotect++;
  INTEGER(counts)[0] = nfe;
  PROTECT(conv = NEW_INTEGER(1)); nprotect++;
  INTEGER(conv)[0] = iflag;
  SET_ELEMENT(ans,0,X);
  SET_ELEMENT(ans,1,val);
  SET_ELEMENT(ans,2,counts);
  SET_ELEMENT(ans,3,conv);

/*   if (inherits(func, "NativeSymbol"))  */
/*     { */
/*       derivs = (deriv_func *) R_ExternalPtrAddr(func); */
/*       /\* If there is an initializer, use it here *\/ */
/*       if (!isNull(initfunc)) */
/* 	{ */
/* 	  initializer = (init_func *) R_ExternalPtrAddr(initfunc); */
/* 	  initializer(Initodeparms); */
/* 	} */
	  
/*     } else { */
/*       derivs = (deriv_func *) lsoda_derivs; */
/*       PROTECT(odesolve_deriv_func = func); incr_N_Protect(); */
/*       PROTECT(odesolve_envir = rho);incr_N_Protect(); */
/*     } */
  Free(iwork); Free(work);

  UNPROTECT(nprotect);
  return ans;
}
