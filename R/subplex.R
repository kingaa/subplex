##' Minimization of a function by the subplex algorithm
##'
##' \code{subplex} minimizes a function.
##'
##' The convergence codes are as follows: \describe{ \item{-2}{invalid input}
##' \item{-1}{number of function evaluations needed exceeds \code{maxnfe}}
##' \item{0}{success: tolerance \code{tol} satisfied} \item{1}{limit of machine
##' precision reached} }
##'
##' For more details, see the source code.
##'
##' @name subplex
##' @rdname subplex
##' @include subplex-package.R
##'
##' @param par Initial guess of the parameters to be optimized over.
##' @param fn The function to be minimized.  Its first argument must be the
##' vector of parameters to be optimized over.  It should return a scalar
##' result.
##' @param control A list of control parameters, consisting of some or all of
##' the following: \describe{ \item{reltol}{ The relative optimization tolerance
##' for \code{par}.  This must be a positive number.  The default value is
##' \code{.Machine$double.eps}.  } \item{maxit}{ Maximum number of function
##' evaluations to perform before giving up.  The default value is \code{10000}.
##' } \item{parscale}{ The scale and initial stepsizes for the components of
##' \code{par}.  This must either be a single scalar, in which case the same
##' scale is used for all parameters, or a vector of length equal to the length
##' of \code{par}.  For \code{parscale} to be valid, it must not be too small
##' relative to \code{par}: if \code{par + parscale = par} in any component,
##' \code{parscale} is too small.  The default value is \code{1}.  } }
##' @param hessian If \code{hessian=TRUE}, the Hessian of the objective at the
##' estimated optimum will be numerically computed.
##' @param \dots Additional arguments to be passed to the function \code{fn}.
##' @return \code{subplex} returns a list containing the following:
##' \item{par}{Estimated parameters that minimize the function.}
##' \item{value}{Minimized value of the function.} \item{count}{Number of
##' function evaluations required.} \item{convergence}{Convergence code (see
##' Details).} \item{message}{ A character string giving a diagnostic message
##' from the optimizer, or 'NULL'.  } \item{hessian}{Hessian matrix.}
##' @author Aaron A. King \email{kingaa@@umich.edu}
##' @seealso \code{\link{optim}}
##' @references T. Rowan, ``Functional Stability Analysis of Numerical
##' Algorithms'', Ph.D. thesis, Department of Computer Sciences, University of
##' Texas at Austin, 1990.
##' @keywords optimize
##' @examples
##'
##' rosen <- function (x) {   ## Rosenbrock Banana function
##'   x1 <- x[1]
##'   x2 <- x[2]
##'   100*(x2-x1*x1)^2+(1-x1)^2
##' }
##' subplex(par=c(11,-33),fn=rosen)
##'
##' rosen2 <- function (x) {
##'   X <- matrix(x,ncol=2)
##'   sum(apply(X,1,rosen))
##' }
##' subplex(par=c(-33,11,14,9,0,12),fn=rosen2,control=list(maxit=30000))
##' ## compare with optim:
##' optim(par=c(-33,11,14,9,0,12),fn=rosen2,control=list(maxit=30000))
##'
##' ripple <- function (x) {
##'   r <- sqrt(sum(x^2))
##'   1-exp(-r^2)*cos(10*r)^2
##' }
##' subplex(par=c(1),fn=ripple,hessian=TRUE)
##' subplex(par=c(0.1,3),fn=ripple,hessian=TRUE)
##' subplex(par=c(0.1,3,2),fn=ripple,hessian=TRUE)
##'
##' rosen <- function (x, g = 0, h = 0) {   ## Rosenbrock Banana function (using names)
##'   x1 <- x['a']
##'   x2 <- x['b']-h
##'   100*(x2-x1*x1)^2+(1-x1)^2+g
##' }
##' subplex(par=c(b=11,a=-33),fn=rosen,h=22,control=list(abstol=1e-9,parscale=5),hessian=TRUE)
##'
##' @export subplex
subplex <- function (par, fn, control = list(), hessian = FALSE, ...) {
  ## set default control parameters
  con <- list(
    reltol = .Machine$double.eps,
    maxit = 10000,
    parscale = 1
  )
  namc <- names(control)[names(control)%in%names(con)]
  con[namc] <- control[namc]
  fn <- match.fun(fn)
  tryCatch(
    .Call(
      call_subplex,
      par,
      fn,
      tol=con$reltol,
      maxnfe=con$maxit,
      scale=con$parscale,
      hessian,
      environment(fn),
      pairlist(...)
    ),
    error = function (e) {
      stop("in ",sQuote("subplex"),": ",conditionMessage(e),call.=FALSE)
    })
}
