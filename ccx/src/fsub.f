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
      real*8 function fsub(time,t,a,b,dd,h1,h2,h3,h4)
!
      implicit none
!
      real*8 time,t,a,b,dd,h1,h2,h3,h4,h5,h6,h7
!
      h5=dexp(-h1*t)
      h6=dsin(dd*t)
      h7=dcos(dd*t)
!
      fsub=(a+b*time)*h5*(-h1*h6-dd*h7)/h2-b*h5/h2*((-h1*t-h3/h2)*
     &     h6-(dd*t+h4)*h7)
!
      return
      end
