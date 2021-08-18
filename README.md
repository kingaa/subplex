## subplex

[![codecov](https://codecov.io/gh/kingaa/subplex/branch/master/graph/badge.svg)](https://codecov.io/gh/kingaa/subplex/)
[![Development Release](https://img.shields.io/github/release/kingaa/subplex.svg)](https://github.com/kingaa/subplex/)
[![CRAN Status](http://www.r-pkg.org/badges/version/subplex)](http://cran.r-project.org/package=subplex)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/subplex)](http://www.r-pkg.org/pkg/subplex)

An R package implementing the Subplex optimization algorithm

**subplex** solves unconstrained optimization problems using a simplex method on subspaces.
The method is well suited for optimizing objective functions that are noisy or are discontinuous at the solution.
The subplex algorithm is due to Tom Rowan, ORNL.

#### Binary install

```
install.packages("subplex",repos="http://kingaa.github.io/")
```

#### Source install

```
library(devtools)  
install_github("kingaa/subplex")
```

#### Package manual

[HTML](https://kingaa.github.io/manuals/subplex/html/00Index.html)  
[PDF](https://kingaa.github.io/manuals/subplex/subplex.pdf)
