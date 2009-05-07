subplex <- function (par, fn, tol = .Machine$double.eps, maxnfe = 10000, scale = 1, hessian = FALSE, ...) {
  .Call("call_subplex",
        par,
        match.fun(fn),
        tol,
        maxnfe,
        scale,
        hessian,
        environment(fn),
        pairlist(...)
        )
}
