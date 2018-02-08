      subroutine evalf (f,ns,ips,xs,n,x,sfx,nfe)
c
      integer ns,n,nfe
      integer ips(*)
      double precision f,xs(*),x(n),sfx
c
c                                         Coded by Tom Rowan
c                            Department of Computer Sciences
c                              University of Texas at Austin
c
c evalf evaluates the function f at a point defined by x
c with ns of its components replaced by those in xs.
c
c input
c
c   f      - user supplied function f(n,x) to be optimized
c
c   ns     - subspace dimension
c
c   ips    - permutation vector
c
c   xs     - double precision ns-vector to be mapped to x
c
c   n      - problem dimension
c
c   x      - double precision n-vector
c
c   nfe    - number of function evaluations
c
c output
c
c   sfx    - signed value of f evaluated at x
c
c   nfe    - incremented number of function evaluations
c
c common
c
      integer nsmin,nsmax,nfxe
      double precision alpha,beta,gamma,delta,psi,omega,
     *     fxstat,ftest
      logical initx
c
      common /usubc/ alpha,beta,gamma,delta,psi,omega,nsmin,
     *     nsmax,nfxe,initx,fxstat(4),ftest
c
c local variables
c
      integer i
      double precision fx
c
      save
c
c subroutines and functions
c
      external f,fstats
c
c-----------------------------------------------------------
c
      do 10 i = 1,ns
         x(ips(i)) = xs(i)
 10   continue
      fx = f(n,x)
      sfx = fx
      nfe = nfe+1
      return
      end
