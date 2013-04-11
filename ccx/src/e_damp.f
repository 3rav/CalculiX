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
      subroutine e_damp(co,nk,konl,lakonl,p1,p2,omx,bodyfx,nbody,s,sm,
     &  ff,nelem,elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,
     &  ielmat,ielorien,norien,orab,ntmat_,
     &  t0,t1,ithermal,vold,iperturb,nelemload,
     &  sideload,xload,nload,idist,sti,stx,iexpl,plicon,
     &  nplicon,plkcon,nplkcon,xstiff,npmat_,dtime,
     &  matname,mint_,ncmat_,ttime,time,istep,iinc)
!
!     computation of the element matrix and rhs for the element with
!     the topology in konl
!
!     ff: rhs without temperature and eigenstress contribution
!
      implicit none
!
      character*8 lakonl
      character*20 sideload(*)
      character*80 matname(*)
!
      integer konl(20),nelemload(2,*),nk,nbody,nelem,
     &  ithermal,iperturb,nload,idist,i,j,i1,i2,
     &  nelcon(2,*),nrhcon(*),nalcon(2,*),ielmat(*),ielorien(*),
     &  ntmat_,nope,norien,iexpl,kode,imat,mint_,ncmat_,
     &  istep,iinc
!
      integer nplicon(0:ntmat_,*),nplkcon(0:ntmat_,*),npmat_
!
      real*8 co(3,*),xl(3,20),
     &  s(60,60),p1(3),p2(3),bodyfx(3),ff(60),elcon(0:ncmat_,ntmat_,*),
     &  rhcon(0:1,ntmat_,*),alcon(0:6,ntmat_,*),alzero(*),orab(7,*),
     &  t0(*),t1(*),voldl(3,20),vold(0:3,*),xload(2,*),omx,sm(60,60),
     &  sti(6,mint_,*),stx(6,mint_,*),t0l,t1l,elas(21),elconloc(21)
!
      real*8 plicon(0:2*npmat_,ntmat_,*),plkcon(0:2*npmat_,ntmat_,*),
     &  xstiff(27,mint_,*),dtime,ttime,time,tvar(2)
!
      tvar(1)=time
      tvar(2)=ttime+dtime
!
      imat=ielmat(nelem)
!
      read(lakonl(8:8),'(i1)') nope
!
!     computation of the coordinates of the local nodes
!
      do i=1,nope
        do j=1,3
          xl(j,i)=co(j,konl(i))
        enddo
      enddo
!
!     displacements for 2nd order static and modal theory
!
      if(iperturb.ne.0) then
         do i1=1,nope
            do i2=1,3
               voldl(i2,i1)=vold(i2,konl(i1))
            enddo
         enddo
      endif
!
!     initialisation of s
!
      do i=1,3*nope
        do j=1,3*nope
          s(i,j)=0.d0
        enddo
      enddo
!
!     calculating the stiffness matrix for the contact spring elements
!
         if(lakonl(7:7).eq.'A') then
            kode=nelcon(1,imat)
            t0l=0.d0
            t1l=0.d0
            if(ithermal.eq.1) then
               t0l=(t0(konl(1))+t0(konl(2)))/2.d0
               t1l=(t1(konl(1))+t1(konl(2)))/2.d0
            elseif(ithermal.ge.2) then
               t0l=(t0(konl(1))+t0(konl(2)))/2.d0
               t1l=(vold(0,konl(1))+vold(0,konl(2)))/2.d0
            endif
         endif
         call dashdamp(xl,elas,konl,voldl,s,imat,elcon,nelcon,
     &      ncmat_,ntmat_,nope,lakonl,t0l,t1l,kode,elconloc,plicon,
     &      nplicon,npmat_,iperturb)
         return
      return
      end

