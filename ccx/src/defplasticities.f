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
      subroutine defplasticities(inpc,textpart,elcon,nelcon,
     &  nmat,ntmat_,ncmat_,irstrt,istep,istat,n,iperturb,iline,ipol,
     &  inl,ipoinp,inp,ipoinpc)
!
!     reading the input deck: *DEFORMATION PLASTICITY
!
      implicit none
!
      character*1 inpc(*)
      character*132 textpart(16)
!
      integer nelcon(2,*),nmat,ntmat,ntmat_,istep,istat,
     &  n,key,i,iperturb(2),iend,ncmat_,irstrt,iline,ipol,inl,
     &  ipoinp(2,*),inp(3,*),ipoinpc(0:*)
!
      real*8 elcon(0:ncmat_,ntmat_,*)
!
      ntmat=0
      iperturb(1)=3
      iperturb(2)=1
!
      if((istep.gt.0).and.(irstrt.ge.0)) then
         write(*,*) '*ERROR in defplasticities: *DEFORMATION PLASTICITY'
         write(*,*) '  should be placed before all step definitions'
         stop
      endif
!
      if(nmat.eq.0) then
         write(*,*) '*ERROR in defplasticities: *DEFORMATION PLASTICITY'
         write(*,*) '  should bepreceded by a *MATERIAL card'
         stop
      endif
!
      do i=2,n
         write(*,*) 
     &        '*WARNING in defplasticities: parameter not recognized:'
         write(*,*) '         ',
     &        textpart(i)(1:index(textpart(i),' ')-1)
         call inputwarning(inpc,ipoinpc,iline)
      enddo
!
      nelcon(1,nmat)=-50
!
      iend=5
      do
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((istat.lt.0).or.(key.eq.1)) return
         ntmat=ntmat+1
         nelcon(2,nmat)=ntmat
         if(ntmat.gt.ntmat_) then
            write(*,*) '*ERROR in defplasticities: increase ntmat_'
            stop
         endif
         do i=1,iend
            read(textpart(i)(1:20),'(f20.0)',iostat=istat) 
     &              elcon(i,ntmat,nmat)
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         enddo
         read(textpart(6)(1:20),'(f20.0)',iostat=istat) 
     &              elcon(0,ntmat,nmat)
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
      enddo
!
      return
      end

