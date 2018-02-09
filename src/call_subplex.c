// Dear Emacs, treat this as -*- C++ -*-

#include <R.h>
#include <Rmath.h>
#include <Rdefines.h>
#include <R_ext/Constants.h>

typedef double _subplex_objective_function (int *, double *);

static double *vect(int n);
static double default_subplex_objective(int *n, double *x);
static void numer_deriv(_subplex_objective_function *f, const double *x, const double *h, double *Rf_df, int n);
static void numer_hessian(_subplex_objective_function *f, const double *x, const double *h, double *d2f, int n);

SEXP call_subplex(SEXP x, SEXP f, SEXP tol, SEXP maxnfe, SEXP scale, SEXP hessian, SEXP rho, SEXP args);

void F77_NAME(subplx) (_subplex_objective_function *f, int *n, double *tol, int *maxnfe,
		       double *scale, double *x, double *fx, int *nfe, double *work, int *iwork,
		       int *iflag);

// these global objects will pass the needed information to the user-defined function (see 'default_subplex_objective')
SEXP _subplex_Xvec; // vector of arguments (allocated once, refilled many times)
SEXP _subplex_envir;	  // environment in which function was defined
SEXP _subplex_fcall;	      // function call (constructed just once)

SEXP call_subplex (SEXP x, SEXP f, SEXP tol, SEXP maxnfe, SEXP scale, SEXP hessian, SEXP rho, SEXP args)
{
  int nprotect = 0;
  double *work = 0, *scalp, *xp, *Xp, eps, *hstep;
  int n, *iwork = 0;
  int k, nscal;
  int hess_reqd;
  _subplex_objective_function *objfn = default_subplex_objective;
  SEXP ans, ansnames;
  SEXP X, Xnames;
  SEXP val, counts, conv, fn, hess;
  SEXP message = R_NilValue;
  SEXP H = R_NilValue, Hnames;

  n = LENGTH(x);
  PROTECT(x = AS_NUMERIC(x)); nprotect++;
  if (n < 1) {
    errorcall(R_NilValue,"'par' must be a non-empty vector");
  }

  // check the convergence tolerance, tol
  PROTECT(tol = AS_NUMERIC(tol)); nprotect++;
  if ((LENGTH(tol) > 1) || (NUMERIC_VALUE(tol) < 0.0)) {
    errorcall(R_NilValue,"'reltol' must be a non-negative scalar");
  }

  // check the maximum number of function evaluations, maxnfe
  PROTECT(maxnfe = AS_INTEGER(maxnfe)); nprotect++;
  if (INTEGER_VALUE(maxnfe) <= 0) {
    errorcall(R_NilValue,"'maxit' must be a positive integer");
  }

  // process the scale and first step parameters, scale
  nscal = LENGTH(scale);
  if ((nscal > 1) && (nscal != n)) {
    errorcall(R_NilValue,"'parscale' misspecified: either specify a single scale or one for each component of 'par'");
  }
  PROTECT(scale = AS_NUMERIC(scale)); nprotect++;
  scalp = REAL(scale);
  if (nscal == 1) { // peculiarity of subplex: if scale < 0, assume there is one scale for all components
    scalp[0] = -fabs(scalp[0]);
  } else {
    for (k = 0; k < nscal; k++) scalp[k] = fabs(scalp[k]);
  }

  PROTECT(hess = AS_LOGICAL(hessian)); nprotect++;
  hess_reqd = LOGICAL_VALUE(hess);

  PROTECT(fn = f); nprotect++;
  PROTECT(Xnames = GET_NAMES(x)); nprotect++; // get the names attribute
  PROTECT(X = NEW_NUMERIC(n)); nprotect++; // allocate a vector for passing to subplx and holding the return values
  PROTECT(_subplex_Xvec = NEW_NUMERIC(n)); nprotect++; // for internal use
  SET_NAMES(X,Xnames); // make sure the names attribute is copied to the return vector
  SET_NAMES(_subplex_Xvec,Xnames); // make sure the names attribute shows up in each call to the user function
  PROTECT(_subplex_envir=rho); nprotect++; // store the function's environment
  PROTECT(_subplex_fcall = LCONS(fn,LCONS(_subplex_Xvec,args))); nprotect++; // set up the function call

  PROTECT(val = NEW_NUMERIC(1)); nprotect++; // to hold the objective function value
  PROTECT(counts = NEW_INTEGER(1)); nprotect++;	// to count the number of function evaluations
  PROTECT(conv = NEW_INTEGER(1)); nprotect++; // to hold the convergence code

  // ALERT: POTENTIAL BUG
  // THE FOLLOWING MEMORY ALLOCATION IS BASED ON AN INTERPRETATION OF THE SUBPLEX DOCUMENTATION
  work = (double *) Calloc(n*(n+6)+1,double);
  iwork = (int *) Calloc(2*n,int);

  xp = REAL(x); Xp = REAL(X);
  for (k = 0; k < n; k++) Xp[k] = xp[k]; // copy in the initial guess vector

  F77_CALL(subplx)(objfn,&n,REAL(tol),INTEGER(maxnfe),scalp,Xp,REAL(val),INTEGER(counts),
		   work,iwork,INTEGER(conv));

  Free(iwork);
  Free(work);

  PROTECT(message = NEW_CHARACTER(1)); nprotect++;
  switch (INTEGER_VALUE(conv)) {
  case -1:
    SET_STRING_ELT(message,0,mkChar("number of function evaluations exceeds 'maxit'"));
    break;
  case 0:
    SET_STRING_ELT(message,0,mkChar("success! tolerance satisfied"));
    break;
  case 1:
    SET_STRING_ELT(message,0,mkChar("limit of machine precision reached"));
    break;
  case -2:
    errorcall(R_NilValue,"'parscale' is too small relative to 'par'");
    break;
  case 2: default:
    errorcall(R_NilValue,"impossible error in subplex"); // # nocov
    break;
  }

  if (hess_reqd) {	     // compute the Hessian matrix if required
    PROTECT(H = allocMatrix(REALSXP,n,n)); nprotect++;
    hstep = vect(n);
    eps = pow(DOUBLE_EPS,1.0/3.0); // scale with the cube-root of the machine precision
    // ALERT: FEATURE IMPROVEMENT NEEDED
    if (nscal == 1) { // THE DOUBLE USE OF 'scale' SHOULD PROBABLY BE REPLACED WITH 'ndeps' AS IN 'optim'
      for (k = 0; k < n; k++) hstep[k] = fabs(scalp[0])*eps;
    } else {
      for (k = 0; k < n; k++) hstep[k] = fabs(scalp[k])*eps;
    }
    numer_hessian(objfn,Xp,hstep,REAL(H),n); // just a naive finite difference approach
    PROTECT(Hnames = allocVector(VECSXP,2)); nprotect++;
    SET_VECTOR_ELT(Hnames,0,Xnames);
    SET_VECTOR_ELT(Hnames,1,Xnames);
    SET_DIMNAMES(H,Hnames);
  }

  PROTECT(ansnames = NEW_CHARACTER(6)); nprotect++;
  SET_STRING_ELT(ansnames,0,mkChar("par"));
  SET_STRING_ELT(ansnames,1,mkChar("value"));
  SET_STRING_ELT(ansnames,2,mkChar("counts"));
  SET_STRING_ELT(ansnames,3,mkChar("convergence"));
  SET_STRING_ELT(ansnames,4,mkChar("message"));
  SET_STRING_ELT(ansnames,5,mkChar("hessian"));
  PROTECT(ans = NEW_LIST(6)); nprotect++;
  SET_NAMES(ans,ansnames);
  SET_VECTOR_ELT(ans,0,X);
  SET_VECTOR_ELT(ans,1,val);
  SET_VECTOR_ELT(ans,2,counts);
  SET_VECTOR_ELT(ans,3,conv);
  SET_VECTOR_ELT(ans,4,message);
  SET_VECTOR_ELT(ans,5,H);

  UNPROTECT(nprotect);
  return ans;
}

// the wrapper around the user's objective function.
// will be called by the Fortran routine "subplx".
static double default_subplex_objective (int *n, double *x)
{
  double *xp, retval;
  int k;
  SEXP ans;
  R_CheckUserInterrupt();
  xp = REAL(_subplex_Xvec);
  for (k = 0; k < *n; k++) xp[k] = x[k]; // copy the values
  PROTECT(ans = eval(_subplex_fcall,_subplex_envir)); // evaluate the call
  retval = NUMERIC_VALUE(ans);	// extract the function value
  UNPROTECT(1);
  return retval;
}

static double *vect (int n)
{
  return (double *) R_alloc(n,sizeof(double));
}

static void numer_deriv (_subplex_objective_function *f, const double *x, const double *h, double *df, int n)
{
  double *xx;
  double fv1, fv2;
  int i;
  xx = vect(n);
  for (i = 0; i < n; i++) xx[i] = x[i];
  for (i = 0; i < n; i++) {
    xx[i] = x[i] + h[i];
    fv1 = f(&n,xx);
    xx[i] = x[i] - h[i];
    fv2 = f(&n,xx);
    df[i] = (fv1-fv2)/(x[i]-xx[i])/2;
    xx[i] = x[i];
  }
}

static void numer_hessian (_subplex_objective_function *f, const double *x, const double *h, double *d2f, int n)
{
  double *xx;
  double *df1, *df2;
  int i, j;
  xx = vect(n);
  df1 = vect(n);
  df2 = vect(n);
  for (i = 0; i < n; i++) xx[i] = x[i];
  for (i = 0; i < n; i++) {
    xx[i] = x[i] + h[i];
    numer_deriv(f,xx,h,df1,n);
    xx[i] = x[i] - h[i];
    numer_deriv(f,xx,h,df2,n);
    for (j = 0; j < n; j++)
      d2f[i*n+j] = (df1[j]-df2[j])/(x[i]-xx[i])/2;
    xx[i] = x[i];
  }
}
