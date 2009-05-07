\name{subplex-package}
\docType{package}
\alias{subplex-package}
\title{Subplex unconstrained optimization algorithm}
\description{The `subplex' package implements Tom Rowan's
  subspace-searching simplex algorithm for unconstrained minimization of
  a function.}
\details{
  Subplex is a subspace-searching simplex method for the unconstrained
  optimization of general multivariate functions. Like the Nelder-Mead
  simplex method it generalizes, the subplex method is well suited for
  optimizing noisy objective functions. The number of function
  evaluations required for convergence typically increases only linearly
  with the problem size, so for most applications the subplex method is
  much more efficient than the simplex method.

  Subplex was written in FORTRAN by Tom Rowan (Oak Ridge National
  Laboratory).  The FORTRAN source code is maintained on the netlib
  repository (netlib.org).
}
\references{T. Rowan, "Functional Stability Analysis of Numerical
  Algorithms", Ph.D. thesis, Department of Computer Sciences, University
  of Texas at Austin, 1990.}
\author{Aaron A. King (kingaa at umich dot edu)}
\seealso{\code{\link{subplex}}, \code{\link{optim}}}
\keyword{optimize}
