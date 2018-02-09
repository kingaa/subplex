      subroutine subplx (f,n,tol,maxnfe,scale,x,fx,nfe,
     *                   work,iwork,iflag)
c      subroutine subplx (f,n,tol,maxnfe,mode,scale,x,fx,nfe,
c     *                   work,iwork,iflag)
c
      integer n,maxnfe,nfe,iwork(*),iflag
      double precision f,tol,scale(*),x(n),fx,work(*)
c
c                                         Coded by Tom Rowan
c                            Department of Computer Sciences
c                              University of Texas at Austin
c
c subplx uses the subplex method to solve unconstrained
c optimization problems.  The method is well suited for
c optimizing objective functions that are noisy or are
c discontinuous at the solution.
c
c subplx sets default optimization options by calling the
c subroutine subopt.  The user can override these defaults
c by calling subopt prior to calling subplx, changing the
c appropriate common variables, and setting the value of
c mode as indicated below.
c
c THIS BEHAVIOR HAS BEEN MODIFIED BY AAK.
c IN EFFECT, mode IS NOW SET TO 0.
c
c By default, subplx performs minimization.
c
c input
c
c   f      - user supplied function f(n,x) to be optimized,
c            declared external in calling routine
c
c   n      - problem dimension
c
c   tol    - relative error tolerance for x (tol .ge. 0.)
c
c   maxnfe - maximum number of function evaluations
c
c   mode   - integer mode switch with binary expansion
c            (bit 1) (bit 0) :
c            bit 0 = 0 : first call to subplx
c                  = 1 : continuation of previous call
c            bit 1 = 0 : use default options
c                  = 1 : user set options
c     AAK: mode is now hardcoded to 0
c
c   scale  - scale and initial stepsizes for corresponding
c            components of x
c            (If scale(1) .lt. 0.,
c            abs(scale(1)) is used for all components of x,
c            and scale(2),...,scale(n) are not referenced.)
c
c   x      - starting guess for optimum
c
c   work   - double precision work array of dimension .ge.
c            2*n + nsmax*(nsmax+4) + 1
c            (nsmax is set in subroutine subopt.
c            default: nsmax = min(5,n))
c
c   iwork  - integer work array of dimension .ge.
c            n + int(n/nsmin)
c            (nsmin is set in subroutine subopt.
c            default: nsmin = min(2,n))
c
c output
c
c   x      - computed optimum
c
c   fx     - value of f at x
c
c   nfe    - number of function evaluations
c
c   iflag  - error flag
c            = -2 : invalid input
c            = -1 : maxnfe exceeded
c            =  0 : tol satisfied
c            =  1 : limit of machine precision
c            iflag should not be reset between calls to
c            subplx.
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
c     
c     local variables
c     
      integer i,j,ifsptr,ins,insfnl,insptr,ipptr,isptr,
     *     istep,istptr,ns,nsubs
      double precision bnsfac(3,2),dum,scl,sfx,xpscl
      logical cmode
c     
      save
c     
c     subroutines and functions
c     
      external f,sortd,evalf,partx,setstp,simplx,subopt
c     blas
      external dcopy
c     fortran
      intrinsic abs,mod
c     
c     data
c     
      data ((bnsfac(i,j),i=1,3),j=1,2) /-1.d0,-2.d0,0.d0,
     *     1.d0,0.d0,2.d0/
c-----------------------------------------------------------
c     
c     first call, check input
c     
      if (scale(1) .ge. 0.d0) then
         do 10 i = 1,n
            xpscl = x(i)+scale(i)
            if (xpscl .eq. x(i)) go to 120
 10      continue
      else
         scl = abs(scale(1))
         do 20 i = 1,n
            xpscl = x(i)+scl
            if (xpscl .eq. x(i)) go to 120
 20      continue
      end if
      call subopt (n)
c     
c     initialization
c     
      istptr = n+1
      isptr = istptr+n
      ifsptr = isptr+nsmax*(nsmax+3)
      insptr = n+1
      if (scale(1) .gt. 0.d0) then
         call dcopy (n,scale,1,work,1)
         call dcopy (n,scale,1,work(istptr),1)
      else
         call dcopy (n,scl,0,work,1)
         call dcopy (n,scl,0,work(istptr),1)
      end if
      do 30 i = 1,n
         iwork(i) = i
 30   continue
      nfe = 0
      nfxe = 1
      ftest = 0.d0
      cmode = .false.
      initx = .true.
      call evalf (f,0,iwork,dum,n,x,sfx,nfe)
      initx = .false.
c     
c     subplex loop
c     
 40   continue
      do 50 i = 1,n
         work(i) = abs(work(i))
 50   continue
      call sortd (n,work,iwork)
      call partx (n,iwork,work,nsubs,iwork(insptr))
      call dcopy (n,x,1,work,1)
      ins = insptr
      insfnl = insptr+nsubs-1
      ipptr = 1
c     
c     simplex loop
c     
 60   continue
      ns = iwork(ins)
      continue
      call simplx (f,n,work(istptr),ns,iwork(ipptr),
     *     maxnfe,cmode,x,sfx,nfe,work(isptr),
     *     work(ifsptr),iflag)
      cmode = .false.
      if (iflag .ne. 0) go to 110
      if (ins .lt. insfnl) then
         ins = ins+1
         ipptr = ipptr+ns
         go to 60
      end if
c     
c     end simplex loop
c     
      do 80 i = 1,n
         work(i) = x(i)-work(i)
 80   continue
c     
c     check termination
c     
      continue
      istep = istptr
      do 100 i = 1,n
         if (max(abs(work(i)),abs(work(istep))*psi)/
     *        max(abs(x(i)),1.d0) .gt. tol) then
            call setstp (nsubs,n,work,work(istptr))
            go to 40
         end if
         istep = istep+1
 100  continue
c     
c     end subplex loop
c     
      iflag = 0
 110  continue
      fx = sfx
      return
c     
c     invalid input
c     
 120  continue
      iflag = -2
      return
      end
