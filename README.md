## subplex

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Development Release](https://img.shields.io/github/release/kingaa/subplex.svg)](https://github.com/kingaa/subplex/releases/latest)
[![CRAN Status](https://www.r-pkg.org/badges/version/subplex)](https://cran.r-project.org/package=subplex)
[![Last CRAN release date](https://www.r-pkg.org/badges/last-release/subplex)](https://cran.r-project.org/package=subplex)
[![R-CMD-check](https://github.com/kingaa/subplex/actions/workflows/r-cmd-check.yml/badge.svg)](https://github.com/kingaa/subplex/actions/workflows/r-cmd-check.yml)
[![binary-build](https://github.com/kingaa/subplex/actions/workflows/binary-build.yml/badge.svg)](https://github.com/kingaa/subplex/actions/workflows/binary-build.yml)
[![test-coverage](https://github.com/kingaa/subplex/actions/workflows/test-coverage.yml/badge.svg)](https://github.com/kingaa/subplex/actions/workflows/test-coverage.yml)
[![codecov](https://codecov.io/gh/kingaa/subplex/branch/master/graph/badge.svg)](https://app.codecov.io/gh/kingaa/subplex)
![CRAN mirror monthly downloads](https://cranlogs.r-pkg.org/badges/last-month/subplex)
![CRAN mirror total downloads](https://cranlogs.r-pkg.org/badges/grand-total/subplex)
[![Dependencies](https://tinyverse.netlify.app/badge/subplex)](https://tinyverse.netlify.app/)

An R package implementing the Subplex optimization algorithm

**subplex** solves unconstrained optimization problems using a simplex method on subspaces.
The method is well suited for optimizing objective functions that are noisy or are discontinuous at the solution.
The subplex algorithm is due to Tom Rowan, ORNL.

#### Binary install

```
install.packages("subplex",repos="https://kingaa.github.io/")
```

#### Source install

```
library(devtools)  
install_github("kingaa/subplex")
```

#### Package manual

[HTML](https://kingaa.github.io/manuals/subplex/html/00Index.html)  
[PDF](https://kingaa.github.io/manuals/subplex/subplex.pdf)
