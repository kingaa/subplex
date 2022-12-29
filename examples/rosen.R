## Rosenbrock Banana function
rosen <- function (x) {
  x1 <- x[1]
  x2 <- x[2]
  100*(x2-x1*x1)^2+(1-x1)^2
}

subplex(par=c(11,-33),fn=rosen)

## Rosenbrock Banana function (using names)
rosen <- function (x, g = 0, h = 0) {
  x1 <- x['a']
  x2 <- x['b']-h
  100*(x2-x1*x1)^2+(1-x1)^2+g
}

subplex(par=c(b=11,a=-33),fn=rosen,h=22,control=list(abstol=1e-9,parscale=5),hessian=TRUE)
