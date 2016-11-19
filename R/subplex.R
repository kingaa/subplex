subplex <- function (par, fn, control = list(), hessian = FALSE, ...) {
## set default control parameters
  con <- list(
              reltol = .Machine$double.eps,
              maxit = 10000,
              parscale = rep.int(1,length(par))
              )
  namc <- names(control)[names(control)%in%names(con)]
  con[namc] <- control[namc]
  fn <- tryCatch(match.fun(fn),
                 error = function (e) {
                   stop("in ",sQuote("subplex"),
                        ": no objective function specified: ",
                        conditionMessage(e),
                        call.=FALSE)
                 })
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
