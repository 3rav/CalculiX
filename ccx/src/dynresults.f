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
      subroutine dynresults(nk,v,ithermal,nactdof,vold,nodeboun,
     &  ndirboun,xboun,nboun,ipompc,nodempc,coefmpc,labmpc,nmpc,
     &  b)
!
!     calculates the displacements or temperatures in a modal dynamics 
!     calculation
!
      implicit none
!
      character*20 labmpc(*)
!
      integer nactdof(0:3,*),nodeboun(*),ndirboun(*),ipompc(*),
     &  nodempc(3,*),nk,ithermal,i,j,index,
     &  nboun,nmpc,ist,ndir,node,incrementalmpc,jmin,jmax
!
      real*8 v(0:4,*),vold(0:4,*),xboun(*),coefmpc(*),
     &  fixed_disp,b(*)
!
      if(ithermal.le.1) then
         jmin=1
         jmax=3
      elseif(ithermal.eq.2) then
         jmin=0
         jmax=2
      else
         jmin=0
         jmax=3
      endif
!
!     extracting the displacement information from the solution
!
      do i=1,nk
         do j=jmin,jmax
            if(nactdof(j,i).ne.0) then
               v(j,i)=b(nactdof(j,i))
            else
               v(j,i)=0.d0
            endif
         enddo
      enddo
!
!     inserting the boundary conditions
!
      do i=1,nboun
         if(ndirboun(i).gt.3) cycle
         fixed_disp=xboun(i)
         v(ndirboun(i),nodeboun(i))=fixed_disp
      enddo
!
!     inserting the mpc information
!     the parameter incrementalmpc indicates whether the
!     incremental displacements enter the mpc or the total 
!     displacements (incrementalmpc=0)
!
      do i=1,nmpc
         if((labmpc(i)(1:20).eq.'                    ').or.
     &      (labmpc(i)(1:6).eq.'CYCLIC').or.
     &      (labmpc(i)(1:9).eq.'SUBCYCLIC')) then
            incrementalmpc=0
         else
            incrementalmpc=1
         endif
         ist=ipompc(i)
         node=nodempc(1,ist)
         ndir=nodempc(2,ist)
         if(ndir.eq.0) then
            if(ithermal.lt.2) cycle
         else
            if(ithermal.eq.2) cycle
         endif
         index=nodempc(3,ist)
         fixed_disp=0.d0
         if(index.ne.0) then
            do
               if(incrementalmpc.eq.0) then
                  fixed_disp=fixed_disp-coefmpc(index)*
     &                 v(nodempc(2,index),nodempc(1,index))
               else
                  fixed_disp=fixed_disp-coefmpc(index)*
     &                 (v(nodempc(2,index),nodempc(1,index))-
     &                  vold(nodempc(2,index),nodempc(1,index)))
               endif
               index=nodempc(3,index)
               if(index.eq.0) exit
            enddo
         endif
         fixed_disp=fixed_disp/coefmpc(ist)
         if(incrementalmpc.eq.1) then
            fixed_disp=fixed_disp+vold(ndir,node)
         endif
         v(ndir,node)=fixed_disp
      enddo
!
      return
      end
