\name{subplex}
\alias{subplex}
\title{Minimization of a function by the subplex algorithm}
\description{
  \code{subplex} minimizes a function.
}
\usage{
subplex(par, fn, tol = sqrt(.Machine$double.eps), maxnfe = 10000,
        scale = 1)
}
\arguments{
  \item{par}{initial guess}
  \item{fn}{function to be minimized}
  \item{tol}{tolerance}
  \item{maxnfe}{maximum number of function evaluations to perform before
    giving up}
  \item{scale}{sets the scale on the parameters}.
}
\value{
  \item{par}{Estimated parameters that minimize the function.}
  \item{value}{Minimized value of the function.}
  \item{count}{Number of function evaluations required.}
  \item{convergence}{Convergence code (see below).}
}
\author{Aaron A. King \email{kingaa@umich.edu}}
\references{T. Rowan, "Functional Stability Analysis of Numerical
  Algorithms", Ph.D. thesis, Department of Computer Sciences, University
  of Texas at Austin, 1990.}
\examples{
rosen <- function (x) {   ## Rosenbrock Banana function
  x1 <- x['a']
  x2 <- x['b']
  100 * (x2 - x1 * x1)^2 + (1 - x1)^2
}
subplex(par=c(a=11,b=-33),fn=rosen)
rosen2 <- function (x) {
  X <- matrix(x,ncol=2) 
  sum(apply(X,1,rosen))
}
subplex(par=c(-33,11,14,9,0,12),fn=rosen2,maxnfe=30000)
ripple <- function (x) {
  r <- sqrt(sum(x^2))
  1-exp(-r^2)*cos(10*r)^2
}
subplex(par=c(1),fn=ripple)
subplex(par=c(0.1,3),fn=ripple)
}
\seealso{\code{\link{optim}}}
\keyword{optimize}

