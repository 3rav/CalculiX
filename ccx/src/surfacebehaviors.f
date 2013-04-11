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
      subroutine surfacebehaviors(inpc,textpart,elcon,nelcon,
     &  nmat,ntmat_,ncmat_,irstrt,istep,istat,n,iline,ipol,inl,ipoinp,
     &  inp,ipoinpc)
!
!     reading the input deck: *SURFACE BEHAVIOR
!
      implicit none
!
      character*1 inpc(*)
      character*132 textpart(16)
!
      integer nelcon(2,*),nmat,ntmat_,istep,istat,ipoinpc(0:*),
     &  n,key,i,ncmat_,irstrt,iline,ipol,inl,ipoinp(2,*),inp(3,*)
!
      real*8 elcon(0:ncmat_,ntmat_,*)
!
      if((istep.gt.0).and.(irstrt.ge.0)) then
         write(*,*) '*ERROR in surfacebehaviors:'
         write(*,*) '       *SURFACE BEHAVIOR should be placed'
         write(*,*) '       before all step definitions'
         stop
      endif
!
      if(nmat.eq.0) then
         write(*,*) '*ERROR in surfacebehaviors:'
         write(*,*) '       *SURFACE BEHAVIOR should be preceded'
         write(*,*) '       by a *SURFACE INTERACTION card'
         stop
      endif
!
      nelcon(1,nmat)=2
      nelcon(2,nmat)=1
!
!     no temperature dependence allowed; last line is decisive
!
      do
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((istat.lt.0).or.(key.eq.1)) return
         do i=1,2
            read(textpart(i)(1:20),'(f20.0)',iostat=istat)
     &           elcon(i,1,nmat)
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         enddo
!     
!     transforming the parameters c_0 into
!     beta such that the pressure p satisfies:
!     p=p_0*dexp(-beta*distance)
!     where n is the normal to the master surface, and
!     distance is the distance between slave node and
!     master surface (negative for penetration)
!     
         elcon(1,1,nmat)=dlog(100.d0)/elcon(1,1,nmat)
!     
         elcon(0,1,nmat)=0.d0
      enddo
!     
      return
      end

