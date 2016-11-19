library(subplex)

ripple <- function (x) {
    r <- sqrt(sum(x^2))
    1-exp(-r^2)*cos(10*r)^2
}

fit <- subplex(par=c(1),fn=ripple,hessian=TRUE)
stopifnot(all.equal(fit$par,0,tol=1e-5))

fit <- subplex(par=c(1),fn="ripple",hessian=TRUE)
stopifnot(all.equal(fit$par,0,tol=1e-5))

fit <- subplex(par=c(1),fn="ripple",hessian=TRUE)
stopifnot(all.equal(fit$par,0,tol=1e-5))

fit <- subplex(par=c(0.1,3),fn=ripple,hessian=TRUE)
stopifnot(all.equal(fit$value,0,tol=1e-5))

fit <- subplex(par=c(0.1,3,2),fn=ripple,hessian=TRUE)
stopifnot(all.equal(fit$par,c(0.45932,1.10399,0.34408),tol=1e-4))

try(subplex(par=c(0.1,3,2),fn=3,hessian=FALSE))
try(subplex(par=c(0.1,3,2),fn=ripple,control=list(reltol=-100)))
try(subplex(par=c(0.1,3,2),fn=ripple,control=list(maxit=-100)))

fit <- subplex(par=c(0.1,3,2),fn=ripple,control=list(parscale=0.1))
stopifnot(all.equal(fit$value,1,tol=1e-4))

try(subplex(par=c(0.1,3,2),fn=ripple,control=list(parscale=c(0.1,0.5))))

fit <- subplex(par=c(0.1,3,2),fn=ripple,control=list(maxit=2))
stopifnot(fit$conv==-1)

fit <- subplex(par=c(0.1,3,2),fn=ripple,control=list(reltol=1e-3))
stopifnot(all.equal(fit$value,0.791,tol=1e-3))
