subplex <- function (par, fn, tol = sqrt(.Machine$double.eps), maxnfe = 10000, scale = 1) {
  if (!is.numeric(par)) {
    nm <- names(par)
    par <- as.numeric(par)
    names(par) <- nm
  }
  if (length(scale)>1 && length(scale)!=length(par))
    stop("'scale' misspecified: either specify a single scale or one for each component of 'par'")
  .Call("call_subplex",
        par,
        fn,
        as.double(tol),
        as.integer(maxnfe),
        as.double(scale),
        environment(fn)
        )
}
