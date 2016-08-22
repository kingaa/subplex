library(subplex)

ripple <- function (x) {
    r <- sqrt(sum(x^2))
    1-exp(-r^2)*cos(10*r)^2
}

subplex(par=c(1),fn=ripple,hessian=TRUE)

subplex(par=c(0.1,3),fn=ripple,hessian=TRUE)

subplex(par=c(0.1,3,2),fn=ripple,hessian=TRUE)

try(subplex(par=c(0.1,3,2),fn=3,hessian=FALSE))
try(subplex(par=c(0.1,3,2),fn=ripple,control=list(reltol=-100)))
try(subplex(par=c(0.1,3,2),fn=ripple,control=list(maxit=-100)))

subplex(par=c(0.1,3,2),fn=ripple,control=list(parscale=0.1))
try(subplex(par=c(0.1,3,2),fn=ripple,control=list(parscale=c(0.1,0.5))))

try(subplex(par=c(0.1,3,2),fn=ripple,control=list(maxit=2)))

try(subplex(par=c(0.1,3,2),fn=ripple,control=list(reltol=1e-3)))
