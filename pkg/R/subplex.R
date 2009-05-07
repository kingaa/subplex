subplex <- function (par, fn, tol = .Machine$double.eps, maxnfe = 10000, scale = 1, ...) {
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
