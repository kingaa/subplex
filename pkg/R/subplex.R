subplex <- function (par, fn, tol = .Machine$double.eps, maxnfe = 10000, scale = 1, ...) {
  if (!is.function(fn)) stop("'fn' must be a function")
  .Call("call_subplex",
        par,
        fn,
        tol,
        maxnfe,
        scale,
        environment(fn),
        pairlist(...)
        )
}
