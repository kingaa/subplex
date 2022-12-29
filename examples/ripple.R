ripple <- function (x) {
  r <- sqrt(sum(x^2))
  1-exp(-r^2)*cos(10*r)^2
}

subplex(par=c(1),fn=ripple,hessian=TRUE)

subplex(par=c(0.1,3),fn=ripple,hessian=TRUE)

subplex(par=c(0.1,3,2),fn=ripple,hessian=TRUE)
