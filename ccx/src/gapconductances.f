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
      subroutine gapconductances(inpc,textpart,nelcon,nmat,ntmat_,
     &        npmat_,plicon,nplicon,iperturb,irstrt,istep,istat,n,iline,
     &        ipol,inl,ipoinp,inp,ipoinpc)
!
!     reading the input deck: *GAP CONDUCTANCE
!
      implicit none
!
      character*1 inpc(*)
      character*132 textpart(16)
!
      integer nelcon(2,*),nmat,ntmat_,ntmat,npmat_,npmat,istep,
     &  n,key,i,nplicon(0:ntmat_,*),
     &  iperturb(*),istat,
     &  irstrt,iline,ipol,inl,ipoinp(2,*),inp(3,*),ipoinpc(0:*)
!
      real*8 plicon(0:2*npmat_,ntmat_,*),
     & temperature
!
      ntmat=0
      npmat=0
!
      if((istep.gt.0).and.(irstrt.ge.0)) then
         write(*,*) '*ERROR in gapconductances: *GAP CONDUCTANCE should'
         write(*,*) '        be placed before all step definitions'
         stop
      endif
!
      if(nmat.eq.0) then
         write(*,*) '*ERROR in gapconductances: *GAP CONDUCTANCE should'
         write(*,*) '       be preceded by a *SURFACE INTERACTION card'
         stop
      endif
!
      if(nelcon(1,nmat).eq.0) then
         write(*,*) '*ERROR in gapconductances: *GAP CONDUCTANCE should'
         write(*,*) '       be preceeded by a *SURFACE BEHAVIOR card'
         stop
      endif
!
      iperturb(1)=2
      iperturb(2)=1
!
      nelcon(1,nmat)=-51
!
      do i=2,n
         if(textpart(i)(11:14).eq.'USER') then
            call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &           ipoinp,inp,ipoinpc)
            return
         else
            write(*,*) 
     &        '*WARNING in gapconductances: parameter not recognized:'
            write(*,*) '         ',
     &                 textpart(i)(1:index(textpart(i),' ')-1)
            call inputwarning(inpc,ipoinpc,iline)
         endif
      enddo
!
         do
            call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &           ipoinp,inp,ipoinpc)
            if((istat.lt.0).or.(key.eq.1)) exit
            read(textpart(3)(1:20),'(f20.0)',iostat=istat) temperature
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
!
!           first temperature
!
            if(ntmat.eq.0) then
               npmat=0
               ntmat=ntmat+1
               if(ntmat.gt.ntmat_) then
                  write(*,*) '*ERROR in gapconductances:'
                  write(*,*) '       increase ntmat_'
                  stop
               endif
               nplicon(0,nmat)=ntmat
               plicon(0,ntmat,nmat)=temperature
!
!           new temperature
!
            elseif(plicon(0,ntmat,nmat).ne.temperature) then
               npmat=0
               ntmat=ntmat+1
               if(ntmat.gt.ntmat_) then
                  write(*,*) '*ERROR in gapconductances:' 
                  write(*,*) '       increase ntmat_'
                  stop
               endif
               nplicon(0,nmat)=ntmat
               plicon(0,ntmat,nmat)=temperature
            endif
            do i=1,2
               read(textpart(i)(1:20),'(f20.0)',iostat=istat) 
     &              plicon(2*npmat+i,ntmat,nmat)
               if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
            enddo
            npmat=npmat+1
            if(npmat.gt.npmat_) then
               write(*,*) '*ERROR in gapconductances: increase npmat_'
               stop
            endif
            nplicon(ntmat,nmat)=npmat
         enddo
!
      if(ntmat.eq.0) then
         write(*,*) '*ERROR in gapconductances: *GAP CONDUCTANCE card'
         write(*,*) '       without data'
         stop
      endif
!
      return
      end

