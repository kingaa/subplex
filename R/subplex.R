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
