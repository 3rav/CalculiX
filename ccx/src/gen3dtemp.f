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
      subroutine gen3dtemp(iponoel,inoel,iponoelmax,kon,ipkon,lakon,ne,
     &  iponor,xnor,knor,t0,t1,thicke,offset,rig,nk,nk_,co,istep,
     &  ithermal)
!
!     maps the temperatures and temperature gradients in 1-D and 2-D
!     elements on their expanded counterparts
!
      implicit none
!
      character*8 lakon(*)
!
      integer iponoel(*),inoel(3,*),iponoelmax,kon(*),ipkon(*),ne,
     &  iponor(2,*),knor(*),rig(*),i,i1,nk,nk_,i2,index,ielem,j,
     &  indexe,indexk,k,node,istep,ithermal
!
      real*8 xnor(*),t0(*),t1(*),thicke(2,*),offset(2,*),co(3,*)
!
!     initial conditions
!
      if(istep.eq.1) then
         do i=1,iponoelmax
            i1=i+nk_
            i2=i+2*nk_
            index=iponoel(i)
            do
               if(index.eq.0) exit
               ielem=inoel(1,index)
               j=inoel(2,index)
               indexe=ipkon(ielem)
               indexk=iponor(2,indexe+j)
               if((lakon(ielem)(7:7).eq.'E').or.
     &              (lakon(ielem)(7:7).eq.'A').or.
     &              (lakon(ielem)(7:7).eq.'S')) then
                  do k=1,3
                     node=knor(indexk+k)
                     t0(node)=t0(i)
                  enddo
               elseif(lakon(ielem)(7:7).eq.'L') then
                  node=knor(indexk+1)
                  t0(node)=t0(i)
     &                -t0(i1)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
                  node=knor(indexk+2)
                  t0(node)=t0(i)
                  node=knor(indexk+3)
                  t0(node)=t0(i)
     &                +t0(i1)*thicke(1,indexe+j)*(0.5d0-offset(1,ielem))
               elseif(lakon(ielem)(7:7).eq.'B') then
                  node=knor(indexk+1)
                  t0(node)=t0(i)
     &                -t0(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
     &                +t0(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+2)
                  t0(node)=t0(i)
     &                -t0(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
     &                -t0(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+3)
                  t0(node)=t0(i)
     &                +t0(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
     &                -t0(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+4)
                  t0(node)=t0(i)
     &                +t0(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
     &                +t0(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+5)
                  t0(node)=t0(i)
     &                -t0(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
                  node=knor(indexk+6)
                  t0(node)=t0(i)
     &                -t0(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+7)
                  t0(node)=t0(i)
     &                +t0(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
                  node=knor(indexk+8)
                  t0(node)=t0(i)
     &                +t0(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
               endif
               if(rig(i).eq.0) exit
               index=inoel(3,index)
            enddo
         enddo
      endif
!
!     temperature loading for mechanical calculations
!
      if(ithermal.eq.1) then
         do i=1,iponoelmax
            i1=i+nk_
            i2=i+2*nk_
            index=iponoel(i)
            do
               if(index.eq.0) exit
               ielem=inoel(1,index)
               j=inoel(2,index)
               indexe=ipkon(ielem)
               indexk=iponor(2,indexe+j)
               if((lakon(ielem)(7:7).eq.'E').or.
     &              (lakon(ielem)(7:7).eq.'A').or.
     &              (lakon(ielem)(7:7).eq.'S')) then
                  do k=1,3
                     node=knor(indexk+k)
                     t1(node)=t1(i)
                  enddo
               elseif(lakon(ielem)(7:7).eq.'L') then
                  node=knor(indexk+1)
                  t1(node)=t1(i)
     &                -t1(i1)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
                  node=knor(indexk+2)
                  t1(node)=t1(i)
                  node=knor(indexk+3)
                  t1(node)=t1(i)
     &                +t1(i1)*thicke(1,indexe+j)*(0.5d0-offset(1,ielem))
               elseif(lakon(ielem)(7:7).eq.'B') then
                  node=knor(indexk+1)
                  t1(node)=t1(i)
     &               -t1(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
     &               +t1(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+2)
                  t1(node)=t1(i)
     &                -t1(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
     &                -t1(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+3)
                  t1(node)=t1(i)
     &                +t1(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
     &                -t1(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+4)
                  t1(node)=t1(i)
     &                +t1(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
     &                +t1(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+5)
                  t1(node)=t1(i)
     &                -t1(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
                  node=knor(indexk+6)
                  t1(node)=t1(i)
     &                -t1(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
                  node=knor(indexk+7)
                  t1(node)=t1(i)
     &                +t1(i2)*thicke(1,indexe+j)*(0.5d0+offset(1,ielem))
                  node=knor(indexk+8)
                  t1(node)=t1(i)
     &                +t1(i1)*thicke(2,indexe+j)*(0.5d0+offset(2,ielem))
               endif
               if(rig(i).eq.0) exit
               index=inoel(3,index)
            enddo
         enddo
      endif
!
      return
      end


