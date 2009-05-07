subplex <- function (par, fn, tol = sqrt(.Machine$double.eps), maxnfe = 10000, scale = 1) {
  .Call("call_subplex",
        as.double(par),
        fn,
        as.double(tol),
        as.integer(maxnfe),
        as.double(scale),
        environment(fn)
        )
}
