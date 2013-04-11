!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2011 Guido Dhondt
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
      subroutine dualshape3tri(xi,et,xl,xsj,xs,shp,ns,pslavdual,iflag)
!
!     shape functions and derivatives for a 3-node linear
!     isoparametric triangular element. 0<=xi,et<=1,xi+et<=1 
!
!     iflag=2: calculate the value of the shape functions,
!              their derivatives w.r.t. the local coordinates
!              and the Jacobian vector (local normal to the
!              surface)
!     iflag=3: calculate the value of the shape functions, the
!              value of their derivatives w.r.t. the global
!              coordinates and the Jacobian vector (local normal
!              to the surface)
!
      implicit none
!
      integer i,j,k,iflag,ns
!
      real*8 shp(4,3),xs(3,2),xsi(2,3),xl(3,8),sh(3),xsj(3),
     &       pslavdual(16,*)
!
      real*8 xi,et
!
!     shape functions and their glocal derivatives for an element
!     described with two local parameters and three global ones.
!
!     local derivatives of the shape functions: xi-derivative
!
      shp(1,1)=-1.d0
      shp(1,2)=1.d0
      shp(1,3)=0.d0
!
!     local derivatives of the shape functions: eta-derivative
!
      shp(2,1)=-1.d0
      shp(2,2)=0.d0
      shp(2,3)=1.d0
!
!     standard shape functions
!
      shp(3,1)=1.d0-xi-et
      shp(3,2)=xi
      shp(3,3)=et
!
!     Dual shape functions
!
      shp(4,1)=pslavdual(1,ns)*shp(3,1)+pslavdual(2,ns)*shp(3,2)
     &     + pslavdual(3,ns)*shp(3,3)
      shp(4,2)=pslavdual(5,ns)*shp(3,1)+pslavdual(6,ns)*shp(3,2)
     &     +pslavdual(7,ns)*shp(3,3)
      shp(4,3)=pslavdual(9,ns)*shp(3,1)+pslavdual(10,ns)*shp(3,2)
     &     +pslavdual(11,ns)*shp(3,3)
!
!     computation of the local derivative of the global coordinates
!     (xs)
!
      do i=1,3
        do j=1,2
          xs(i,j)=0.d0
          do k=1,3
            xs(i,j)=xs(i,j)+xl(i,k)*shp(j,k)
          enddo
        enddo
      enddo
!
!     computation of the jacobian vector
!
      xsj(1)=xs(2,1)*xs(3,2)-xs(3,1)*xs(2,2)
      xsj(2)=xs(1,2)*xs(3,1)-xs(3,2)*xs(1,1)
      xsj(3)=xs(1,1)*xs(2,2)-xs(2,1)*xs(1,2)
!
      if(iflag.eq.2) return
!
!     computation of the global derivative of the local coordinates
!     (xsi) (inversion of xs)
!
      xsi(1,1)=xs(2,2)/xsj(3)
      xsi(2,1)=-xs(2,1)/xsj(3)
      xsi(1,2)=-xs(1,2)/xsj(3)
      xsi(2,2)=xs(1,1)/xsj(3)
      xsi(1,3)=-xs(2,2)/xsj(1)
      xsi(2,3)=xs(2,1)/xsj(1)
!
!     computation of the global derivatives of the shape functions
!
      do k=1,3
        do j=1,3
          sh(j)=shp(1,k)*xsi(1,j)+shp(2,k)*xsi(2,j)
        enddo
        do j=1,3
          shp(j,k)=sh(j)
        enddo
      enddo
!
      return
      end



