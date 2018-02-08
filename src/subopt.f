      subroutine subopt (n)
c
      integer n
c
c                                         Coded by Tom Rowan
c                            Department of Computer Sciences
c                              University of Texas at Austin
c
c subopt sets options for subplx.
c
c input
c
c   n      - problem dimension
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
      save
c
c subroutines and functions
c
c   fortran
      intrinsic min
c
c-----------------------------------------------------------
c
c***********************************************************
c simplex method strategy parameters
c***********************************************************
c
c alpha  - reflection coefficient
c          alpha .gt. 0
c
      alpha = 1.d0
c
c beta   - contraction coefficient
c          0 .lt. beta .lt. 1
c
      beta = .5d0
c
c gamma  - expansion coefficient
c          gamma .gt. 1
c
      gamma = 2.d0
c
c delta  - shrinkage (massive contraction) coefficient
c          0 .lt. delta .lt. 1
c
      delta = .5d0
c
c***********************************************************
c subplex method strategy parameters
c***********************************************************
c
c psi    - simplex reduction coefficient
c          0 .lt. psi .lt. 1
c
      psi = .25d0
c
c omega  - step reduction coefficient
c          0 .lt. omega .lt. 1
c
      omega = .1d0
c
c nsmin and nsmax specify a range of subspace dimensions.
c In addition to satisfying  1 .le. nsmin .le. nsmax .le. n,
c nsmin and nsmax must be chosen so that n can be expressed
c as a sum of positive integers where each of these integers
c ns(i) satisfies   nsmin .le. ns(i) .ge. nsmax.
c Specifically,
c     nsmin*ceil(n/nsmax) .le. n   must be true.
c
c nsmin  - subspace dimension minimum
c
      nsmin = min(2,n)
c
c nsmax  - subspace dimension maximum
c
      nsmax = min(5,n)
c
c***********************************************************
c subplex method special cases
c***********************************************************
c nelder-mead simplex method with periodic restarts
c   nsmin = nsmax = n
c***********************************************************
c nelder-mead simplex method
c   nsmin = nsmax = n, psi = small positive
c***********************************************************
      return
      end
