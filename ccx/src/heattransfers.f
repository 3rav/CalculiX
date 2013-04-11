!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2007 Guido Dhondt
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation(version 2);
!     
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of 
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
!     GNU General Public License for more details.
!
!     You should have received a copy of the GNU General Public License
!     along with this program; if not, write to the Free Software
!     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
!
      subroutine heattransfers(inpc,textpart,nmethod,iperturb,isolver,
     &  istep,istat,n,tinc,tper,tmin,tmax,idrct,ithermal,iline,ipol,
     &  inl,ipoinp,inp,alpha,mei,fei,ipoinpc,ctrl,ttime)
!
!     reading the input deck: *HEAT TRANSFER
!
!     isolver=0: SPOOLES
!             2: iterative solver with diagonal scaling
!             3: iterative solver with Cholesky preconditioning
!             4: sgi solver
!             5: TAUCS
!             7: pardiso
!
      implicit none
!
      logical timereset
!
      character*1 inpc(*)
      character*20 solver
      character*132 textpart(16)
!
      integer nmethod,iperturb,isolver,istep,istat,n,key,i,idrct,nev,
     &  ithermal,iline,ipol,inl,ipoinp(2,*),inp(3,*),mei(4),ncv,mxiter,
     &  ipoinpc(0:*),idirect
!
      real*8 tinc,tper,tmin,tmax,alpha,fei(3),tol,fmin,fmax,ctrl(*),
     &  ttime
!
      tmin=0.d0
      tmax=0.d0
      nmethod=4
      alpha=0.d0
      mei(4)=0
      timereset=.false.
!
      if(iperturb.eq.0) then
         iperturb=2
      elseif((iperturb.eq.1).and.(istep.gt.1)) then
         write(*,*) '*ERROR in heattransfers: perturbation analysis is'
         write(*,*) '       not provided in a *HEAT TRANSFER step.'
         stop
      endif
!
      if(istep.lt.1) then
         write(*,*) '*ERROR in heattransfers: *HEAT TRANSFER can only'
         write(*,*) '       be used within a STEP'
         stop
      endif
!
!     default solver
!
      solver='                    '
      if(isolver.eq.0) then
         solver(1:7)='SPOOLES'
      elseif(isolver.eq.2) then
         solver(1:16)='ITERATIVESCALING'
      elseif(isolver.eq.3) then
         solver(1:17)='ITERATIVECHOLESKY'
      elseif(isolver.eq.4) then
         solver(1:3)='SGI'
      elseif(isolver.eq.5) then
         solver(1:5)='TAUCS'
      elseif(isolver.eq.7) then
         solver(1:7)='PARDISO'
      endif
!
      idirect=2
      do i=2,n
         if(textpart(i)(1:7).eq.'SOLVER=') then
            read(textpart(i)(8:27),'(a20)') solver
         elseif((textpart(i)(1:6).eq.'DIRECT').and.
     &          (textpart(i)(1:9).ne.'DIRECT=NO')) then
            idirect=1
         elseif(textpart(i)(1:9).eq.'DIRECT=NO') then
            idirect=0
         elseif(textpart(i)(1:11).eq.'STEADYSTATE') then
            nmethod=1
         elseif(textpart(i)(1:9).eq.'FREQUENCY') then
            nmethod=2
         elseif(textpart(i)(1:12).eq.'MODALDYNAMIC') then
            iperturb=0
         elseif(textpart(i)(1:11).eq.'STORAGE=YES') then
            mei(4)=1
         elseif(textpart(i)(1:7).eq.'DELTMX=') then
            read(textpart(i)(8:27),'(f20.0)',iostat=istat) ctrl(27)
         elseif(textpart(i)(1:9).eq.'TIMERESET') then
            timereset=.true.
         else
            write(*,*) 
     &        '*WARNING in heattransfers: parameter not recognized:'
            write(*,*) '         ',
     &                 textpart(i)(1:index(textpart(i),' ')-1)
            call inputwarning(inpc,ipoinpc,iline)
         endif
      enddo
      if(nmethod.eq.1) ctrl(27)=1.d30
!
!     default for modal dynamic calculations is DIRECT,
!     for static or dynamic calculations DIRECT=NO
!
      if(iperturb.eq.0) then
         idrct=1
         if(idirect.eq.0)idrct=0
      else
         idrct=0
         if(idirect.eq.1)idrct=1
      endif
!
      if((ithermal.eq.0).and.(nmethod.ne.1).and.
     &   (nmethod.ne.2).and.(iperturb.ne.0)) then
         write(*,*) '*ERROR in heattransfers: please define initial '
         write(*,*) '       conditions for the temperature'
         stop
      else
         ithermal=2
      endif
!
      if((nmethod.ne.2).and.(iperturb.ne.0)) then
!
!        static or dynamic thermal analysis
!
         if(solver(1:7).eq.'SPOOLES') then
            isolver=0
         elseif(solver(1:16).eq.'ITERATIVESCALING') then
            isolver=2
         elseif(solver(1:17).eq.'ITERATIVECHOLESKY') then
            isolver=3
         elseif(solver(1:3).eq.'SGI') then
            isolver=4
         elseif(solver(1:5).eq.'TAUCS') then
            isolver=5
         elseif(solver(1:7).eq.'PARDISO') then
            isolver=7
         else
            write(*,*) '*WARNING in heattransfers: unknown solver;'
            write(*,*) '         the default solver is used'
         endif
!
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((istat.lt.0).or.(key.eq.1)) then
            if(iperturb.ge.2) then
               write(*,*) '*WARNING in heattransfers: a nonlinear geomet
     &ric analysis is requested'
               write(*,*) '         but no time increment nor step is sp
     &ecified'
               write(*,*) '         the defaults (1,1) are used'
               tinc=1.d0
               tper=1.d0
               tmin=1.d-5
               tmax=1.d+30
            endif
            if(timereset)ttime=ttime-tper
            return
         endif
!
         read(textpart(1)(1:20),'(f20.0)',iostat=istat) tinc
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         read(textpart(2)(1:20),'(f20.0)',iostat=istat) tper
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         read(textpart(3)(1:20),'(f20.0)',iostat=istat) tmin
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         read(textpart(4)(1:20),'(f20.0)',iostat=istat) tmax
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
!
         if(tinc.le.0.d0) then
            write(*,*) '*ERROR in heattransfers: initial increment size 
     &is negative'
         endif
         if(tper.le.0.d0) then
            write(*,*) '*ERROR in heattransfers: step size is negative'
         endif
         if(tinc.gt.tper) then
            write(*,*) '*ERROR in heattransfers: initial increment size 
     &exceeds step size'
         endif
!      
         if(idrct.ne.1) then
            if(dabs(tmin).lt.1.d-10) then
               tmin=min(tinc,1.d-5*tper)
            endif
            if(dabs(tmax).lt.1.d-10) then
               tmax=1.d+30
            endif
         endif
      elseif(nmethod.eq.2) then
!
!        thermal eigenmode analysis
!
         iperturb=0
!
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((istat.lt.0).or.(key.eq.1)) then
            write(*,*)'*ERROR in heattransfers: definition not complete'
            write(*,*) '  '
            call inputerror(inpc,ipoinpc,iline)
            stop
         endif
         read(textpart(1)(1:10),'(i10)',iostat=istat) nev
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         if(nev.le.0) then
            write(*,*) '*ERROR in frequencies: less than 1 eigenvalue re
     &quested'
            stop
         endif
         tol=1.d-2
         ncv=4*nev
         ncv=ncv+nev
         mxiter=1000
         read(textpart(2)(1:20),'(f20.0)',iostat=istat) fmin
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         read(textpart(3)(1:20),'(f20.0)',iostat=istat) fmax
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
!
         mei(1)=nev
         mei(2)=ncv
         mei(3)=mxiter
         fei(1)=tol
         fei(2)=fmin
         fei(3)=fmax
      else
!
!        modal dynamic analysis for variables which satisfy the
!        Helmholtz equation
!
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((istat.lt.0).or.(key.eq.1)) then
            write(*,*)'*ERROR in heattransfers: definition not complete'
            write(*,*) '  '
            call inputerror(inpc,ipoinpc,iline)
            stop
         endif
         read(textpart(1)(1:20),'(f20.0)',iostat=istat) tinc
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         read(textpart(2)(1:20),'(f20.0)',iostat=istat) tper
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
      endif
!
      if(timereset)ttime=ttime-tper
!
      call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &     ipoinp,inp,ipoinpc)
!
      return
      end








