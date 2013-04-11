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
      subroutine fluidextrapolate(v,ipkon,inum,kon,lakon,
     &  ne,mi)
!
!     extrapolates nodal values in fluid elements
!
      implicit none
!
      character*8 lakon(*),lakonl
!
      integer ipkon(*),inum(*),kon(*),ne,indexe,i,node1,node2,node3,
     &  mi(2)
!
      real*8 v(0:mi(2),*)
!
!     determining all outflowing mass flow in the end nodes and
!     assigning it to the end nodes
!
      do i=1,ne
!
         if(ipkon(i).lt.0) cycle
         lakonl=lakon(i)
         if(lakonl(1:1).ne.'D') cycle
!
         indexe=ipkon(i)
         if(kon(indexe+1).ne.0)  then
            node1=kon(indexe+1)
            v(1,node1)=0.d0
         endif
         if(kon(indexe+3).ne.0) then
            node3=kon(indexe+3)
            v(1,node3)=0.d0
         endif
      enddo
!
      do i=1,ne
!
         if(ipkon(i).lt.0) cycle
         lakonl=lakon(i)
         if(lakonl(1:1).ne.'D') cycle
!
         indexe=ipkon(i)
         node2=kon(indexe+2)
         if(kon(indexe+1).ne.0)  then
            node1=kon(indexe+1)
            inum(node1)=1
            if(v(1,node2).gt.0.d0) v(1,node1)=v(1,node1)+v(1,node2)
         endif
         inum(node2)=inum(node2)+1
         if(kon(indexe+3).ne.0) then
            node3=kon(indexe+3)
            inum(node3)=1
            if(v(1,node2).lt.0.d0) v(1,node3)=v(1,node3)-v(1,node2)
         endif
      enddo
!
!     interpolating the total temperature, total pressure
!     and static temperature; changing the sign of inum
!
      do i=1,ne
!
         if(ipkon(i).lt.0) cycle
         lakonl=lakon(i)
         if(lakonl(1:1).ne.'D') cycle
!
         indexe=ipkon(i)
!
!        end node
!
         node1=kon(indexe+1)
c         if(node1.ne.0)  then
c            if(inum(node1).lt.0) then
c               v(1,node1)=-v(1,node1)/inum(node1)
c               inum(node1)=-inum(node1)
c            endif
c         endif
!
!        other end node
!
         node3=kon(indexe+3)
c         if(node3.ne.0)  then
c            if(inum(node3).lt.0) then
c               v(1,node3)=-v(1,node3)/inum(node3)
c               inum(node3)=-inum(node3)
c            endif
c         endif
!
!        middle node and zero nodes (network entrances/exits)
!        interpolating the total temperature, total pressure
!        and static temperature
!
         node2=kon(indexe+2)
         if(node1.eq.0) then
            v(0,node2)=v(0,node3)
            v(2,node2)=v(2,node3)
            v(3,node2)=v(3,node3)
         elseif(node3.eq.0) then
            v(0,node2)=v(0,node1)
            v(2,node2)=v(2,node1)
            v(3,node2)=v(3,node1)
         else
            v(0,node2)=(v(0,node1)+v(0,node3))/2.d0
            v(2,node2)=(v(2,node1)+v(2,node3))/2.d0
            v(3,node2)=(v(3,node1)+v(3,node3))/2.d0
         endif
      enddo
!
      return
      end
