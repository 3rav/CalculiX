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
      subroutine liquidpipe(node1,node2,nodem,nelem,lakon,
     &     nactdog,identity,ielprop,prop,iflag,v,xflow,f,
     &     nodef,idirf,df,rho,g,co,dvi,numf,vold,mi,ipkon,kon,set)
!
!     pipe element for incompressible media
!     
      implicit none
!     
      logical identity,flowunknown
      character*8 lakon(*)
      character*81 set(*)
!      
      integer nelem,nactdog(0:3,*),node1,node2,nodem,iaxial,
     &     ielprop(*),nodef(4),idirf(4),index,iflag,mi(*),
     &     inv,ncoel,ndi,nbe,id,nen,ngv,numf,nodea,nodeb,
     &     ipkon(*),isothermal,kon(*),nelemswirl
!      
      real*8 prop(*),v(0:mi(2),*),xflow,f,df(4),a,d,pi,radius,
     &     p1,p2,rho,dvi,friction,reynolds,vold(0:mi(2),*),
     &     g(3),a1,a2,xn,xk,xk1,xk2,zeta,dl,dg,rh,a0,alpha,
     &     coarseness,rd,xks,z1,z2,co(3,*),xcoel(11),yel(11),
     &     yco(11),xdi(10),ydi(10),xbe(7),ybe(7),zbe(7),ratio,
     &     xen(10),yen(10),xgv(8),ygv(8),xkn,xkp,
     &     dh,kappa,r,dkda,form_fact,dzetadalpha,t_chang,
     &     xflow_vol,r1d,r2d,r1,r2,eta, K1, Kr, U1,Ui, ciu, c1u, 
     &     c2u, omega,rpm,cinput,un,T
!
      data ncoel /11/
      data xcoel /0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0/
      data yco /0.5,0.46,0.41,0.36,0.30,0.24,0.18,0.12,0.06,0.02,0./
      data yel /1.,0.81,0.64,0.49,0.36,0.25,0.16,0.09,0.04,0.01,0./
!
      data ndi /10/
      data xdi /0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1./
      data ydi /226.,47.5,17.5,7.8,3.75,1.80,0.8,0.29,0.06,0./
!
      data nbe /7/
      data xbe /1.,1.5,2.,3.,4.,6.,10./
      data ybe /0.21,0.12,0.10,0.09,0.09,0.08,0.2/
      data zbe /0.51,0.32,0.29,0.26,0.26,0.17,0.31/
!
      data nen /10/
      data xen /0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1./
      data yen /232.,51.,18.8,9.6,5.26,3.08,1.88,1.17,0.734,0.46/
!
      data ngv /8/
      data xgv /0.125,0.25,0.375,0.5,0.625,0.75,0.875,1./
      data ygv /98.,17.,5.52,2.,0.81,0.26,0.15,0.12/
!
      numf=4
!
      pi=4.d0*datan(1.d0)
      dkda=0.d0
!
      if (iflag.eq.0) then
         identity=.true.
!     
         if(nactdog(2,node1).ne.0)then
            identity=.false.
         elseif(nactdog(2,node2).ne.0)then
            identity=.false.
         elseif(nactdog(1,nodem).ne.0)then
            identity=.false.
         elseif(nactdog(3,nodem).ne.0) then
            identity=.false.
         endif
!     
      elseif((iflag.eq.1).or.(iflag.eq.2).or.(iflag.eq.3))then
!     
         index=ielprop(nelem)
!     
         p1=v(2,node1)
         p2=v(2,node2)
!     
         z1=-g(1)*co(1,node1)-g(2)*co(2,node1)-g(3)*co(3,node1)
         z2=-g(1)*co(1,node2)-g(2)*co(2,node2)-g(3)*co(3,node2)
!
         T=v(0,node1)
!     
         if(iflag.eq.1) then
            inv=0
            if(nactdog(1,nodem).ne.0) then
               flowunknown=.true.
            else
               flowunknown=.false.
               xflow=v(1,nodem)
            endif
         else
            xflow=v(1,nodem)
            if(xflow.ge.0.d0) then
               inv=1
            else
               inv=-1
            endif
            nodef(1)=node1
            nodef(2)=nodem
            nodef(3)=node2
            nodef(4)=nodem
            idirf(1)=2
            idirf(2)=1
            idirf(3)=2
            idirf(4)=3
         endif
!     
         if((lakon(nelem)(4:5).ne.'BE').and.
     &        (lakon(nelem)(6:7).eq.'MA')) then
!     
!     pipe, Manning (LIPIMA)
!     
            if(lakon(nelem)(8:8).eq.'F') then
               nodea=int(prop(index+1))
               nodeb=int(prop(index+2))
               xn=prop(index+3)
               iaxial=int(prop(index+4))
               radius=dsqrt((co(1,nodeb)+vold(1,nodeb)-
     &                       co(1,nodea)-vold(1,nodea))**2+
     &                      (co(2,nodeb)+vold(2,nodeb)-
     &                       co(2,nodea)-vold(2,nodea))**2+
     &                      (co(3,nodeb)+vold(3,nodeb)-
     &                       co(3,nodea)-vold(3,nodea))**2)
               if(iaxial.ne.0) then
                  a=pi*radius*radius/iaxial
               else
                  a=pi*radius*radius
               endif
               rh=radius/2.d0
            else
               a=prop(index+1)
               rh=prop(index+2)
            endif
            xn=prop(index+3)
            a1=a
            a2=a
            dl=dsqrt((co(1,node2)-co(1,node1))**2+
     &           (co(2,node2)-co(2,node1))**2+
     &           (co(3,node2)-co(3,node1))**2)
            dg=dsqrt(g(1)*g(1)+g(2)*g(2)+g(3)*g(3))
            if(inv.ne.0) then
               xk=2.d0*xn*xn*dl*dg/(a*a*rh**(4.d0/3.d0))
            else
               xkn=2.d0*xn*xn*dl*dg/(a*a*rh**(4.d0/3.d0))
               xkp=xkn
            endif
         elseif(lakon(nelem)(6:7).eq.'WC') then
!     
!     pipe, White-Colebrook
!     
            if(lakon(nelem)(8:8).eq.'F') then
               nodea=int(prop(index+1))
               nodeb=int(prop(index+2))
               xn=prop(index+3)
               iaxial=int(prop(index+4))
               radius=dsqrt((co(1,nodeb)+vold(1,nodeb)-
     &                       co(1,nodea)-vold(1,nodea))**2+
     &                       (co(2,nodeb)+vold(2,nodeb)-
     &                       co(2,nodea)-vold(2,nodea))**2+
     &                       (co(3,nodeb)+vold(3,nodeb)-
     &                       co(3,nodea)-vold(3,nodea))**2)
               if(iaxial.ne.0) then
                  a=pi*radius*radius/iaxial
               else
                  a=pi*radius*radius
               endif
               d=2.d0*radius
            else
               a=prop(index+1)
               d=prop(index+2)
            endif
            dl=prop(index+3)
            if(dl.le.0.d0) then
               dl=dsqrt((co(1,node2)-co(1,node1))**2+
     &              (co(2,node2)-co(2,node1))**2+
     &              (co(3,node2)-co(3,node1))**2)
            endif
            xks=prop(index+4)
            form_fact=prop(index+5)
            a1=a
            a2=a
            if(iflag.eq.1) then
!
!              assuming large reynolds number
!
               friction=1.d0/(2.03*dlog10(xks/(d*3.7)))**2
            else
!
!              solving the implicit White-Colebrook equation
!
               reynolds=xflow*d/(a*dvi)
               call friction_coefficient(dl,d,xks,reynolds,form_fact,
     &               friction)
            endif
            if(inv.ne.0) then
               xk=friction*dl/(d*a*a)
               dkda=-2.5d0*xk/a
            else
               xkn=friction*dl/(d*a*a)
               xkp=xkn
            endif
         elseif(lakon(nelem)(6:7).eq.'EL') then
!     
!     pipe, sudden enlargement Berlamont version: fully turbulent
!     all section ratios
!     
            a1=prop(index+1)
            a2=prop(index+2)
            ratio=a1/a2
            call ident(xcoel,ratio,ncoel,id)
            if(inv.ge.0) then
               if(id.eq.0) then
                  zeta=yel(1)
               elseif(id.eq.ncoel) then
                  zeta=yel(ncoel)
               else
                  zeta=yel(id)+(yel(id+1)-yel(id))*(ratio-xcoel(id))/
     &                 (xcoel(id+1)-xcoel(id))
               endif
               if(inv.ne.0) then
                  xk=zeta/(a1*a1)
               else
                  xkp=zeta/(a1*a1)
               endif
            endif
            if(inv.le.0) then
               if(id.eq.0) then
                  zeta=yco(1)
               elseif(id.eq.ncoel) then
                  zeta=yco(ncoel)
               else
                  zeta=yco(id)+(yco(id+1)-yco(id))*(ratio-xcoel(id))/
     &                 (xcoel(id+1)-xcoel(id))
               endif
               if(inv.ne.0) then
                  xk=zeta/(a1*a1)
               else
                  xkn=zeta/(a1*a1)
               endif
            endif
         elseif(lakon(nelem)(4:5).eq.'EL') then
!     
!     pipe, sudden enlargement Idelchik version: reynolds dependent,
!     0.01 <= section ratio <= 0.6
!     
            a1=prop(index+1)
            a2=prop(index+2)
            dh=prop(index+3)
            if(dh.eq.0.d0) then
               dh=dsqrt(4*a1/pi)
            endif
            if(inv.eq.0) then
               reynolds=5000.d0
            else
               reynolds=xflow*dh/(dvi*a1)
            endif
            if(inv.ge.0) then
               call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &              isothermal,kon,ipkon,R,Kappa,v,mi)
               if(inv.ne.0) then
                  xk=zeta/(a1*a1)
               else
                  xkp=zeta/(a1*a1)
               endif
            endif
            if(inv.le.0) then
               reynolds=-reynolds
!
!              setting length and angle for contraction to zero
!
               prop(index+4)=0.d0
               prop(index+5)=0.d0
               lakon(nelem)(4:5)='CO'
               call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &              isothermal,kon,ipkon,R,Kappa,v,mi)
               lakon(nelem)(4:5)='EL'
               if(inv.ne.0) then
                  xk=zeta/(a1*a1)
               else
                  xkn=zeta/(a1*a1)
               endif
            endif
         elseif(lakon(nelem)(6:7).eq.'CO') then
!     
!     pipe, sudden contraction Berlamont version: fully turbulent
!     all section ratios
!     
            a1=prop(index+1)
            a2=prop(index+2)
            ratio=a2/a1
            call ident(xcoel,ratio,ncoel,id)
            if(inv.ge.0) then
               if(id.eq.0) then
                  zeta=yco(1)
               elseif(id.eq.ncoel) then
                  zeta=yco(ncoel)
               else
                  zeta=yco(id)+(yco(id+1)-yco(id))*(ratio-xcoel(id))/
     &                 (xcoel(id+1)-xcoel(id))
               endif
               if(inv.ne.0) then
                  xk=zeta/(a2*a2)
               else
                  xkp=zeta/(a2*a2)
               endif
            endif
            if(inv.le.0) then
               if(id.eq.0) then
                  zeta=yel(1)
               elseif(id.eq.ncoel) then
                  zeta=yel(ncoel)
               else
                  zeta=yel(id)+(yel(id+1)-yel(id))*(ratio-xcoel(id))/
     &                 (xcoel(id+1)-xcoel(id))
               endif
               if(inv.ne.0) then
                  xk=zeta/(a2*a2)
               else
                  xkn=zeta/(a2*a2)
               endif
            endif
         elseif(lakon(nelem)(4:5).eq.'CO') then
!     
!     pipe, sudden contraction Idelchik version: reynolds dependent,
!     0.1 <= section ratio <= 0.6
!     
            a1=prop(index+1)
            a2=prop(index+2)
            dh=prop(index+3)
            if(dh.eq.0.d0) then
               dh=dsqrt(4*a2/pi)
            endif
            if(inv.eq.0) then
               reynolds=5000.d0
            else
               reynolds=xflow*dh/(dvi*a2)
            endif
            if(inv.ge.0) then
               call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &              isothermal,kon,ipkon,R,Kappa,v,mi)
               if(inv.ne.0) then
                  xk=zeta/(a2*a2)
               else
                  xkp=zeta/(a2*a2)
               endif
            endif
            if(inv.le.0) then
               reynolds=-reynolds
               lakon(nelem)(4:5)='EL'
               call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &              isothermal,kon,ipkon,R,Kappa,v,mi)
               lakon(nelem)(4:5)='CO'
               if(inv.ne.0) then
                  xk=zeta/(a2*a2)
               else
                  xkn=zeta/(a2*a2)
               endif
            endif
         elseif(lakon(nelem)(6:7).eq.'DI') then
!     
!     pipe, diaphragm
!     
            a=prop(index+1)
            a0=prop(index+2)
            a1=a
            a2=a
            ratio=a0/a
            call ident(xdi,ratio,ndi,id)
            if(id.eq.0) then
               zeta=ydi(1)
            elseif(id.eq.ndi) then
               zeta=ydi(ndi)
            else
               zeta=ydi(id)+(ydi(id+1)-ydi(id))*(ratio-xdi(id))/
     &              (xdi(id+1)-xdi(id))
            endif
            if(inv.ne.0) then
               xk=zeta/(a*a)
            else
               xkn=zeta/(a*a)
               xkp=xkn
            endif
         elseif(lakon(nelem)(6:7).eq.'EN') then
!     
!     pipe, entrance (Berlamont data)
!     
            a=prop(index+1)
            a0=prop(index+2)
            a1=a*1.d10
            a2=a
            ratio=a0/a
            call ident(xen,ratio,nen,id)
            if(id.eq.0) then
               zeta=yen(1)
            elseif(id.eq.nen) then
               zeta=yen(nen)
            else
               zeta=yen(id)+(yen(id+1)-yen(id))*(ratio-xen(id))/
     &              (xen(id+1)-xen(id))
            endif
            if(inv.ne.0) then
               if(inv.gt.0) then
!                 entrance
                  xk=zeta/(a*a)
               else
!                 exit
                  xk=1.d0/(a*a)
               endif
            else
               xkn=1.d0/(a*a)
               xkp=zeta/(a*a)
            endif
         elseif(lakon(nelem)(4:5).eq.'EN') then
!     
!     pipe, entrance (Idelchik)
!     
            a1=prop(index+1)
            a2=prop(index+2)
            call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &           isothermal,kon,ipkon,R,Kappa,v,mi)
!
!           check for negative flow: in that case the loss
!           coefficient is wrong
!
            if(inv.lt.0) then
               write(*,*) '*ERROR in liquidpipe: loss coefficients'
               write(*,*) '       for entrance (Idelchik) do not apply'
               write(*,*) '       to reversed flow'
               stop
            endif
!
            dh=prop(index+3)
            if(dh.eq.0.d0) then
               dh=dsqrt(4*a2/pi)
            endif
            if(inv.eq.0) then
               reynolds=5000.d0
            else
               reynolds=dabs(xflow)*dh/(dvi*a2)
            endif
!
            if(inv.ne.0) then
               xk=zeta/(a2*a2)
            else
               xkn=zeta/(a2*a2)
               xkp=xkn
            endif
         elseif(lakon(nelem)(4:5).eq.'EX') then
!     
!     pipe, exit (Idelchik)
!     
            a1=prop(index+1)
            a2=prop(index+2)
            call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &           isothermal,kon,ipkon,R,Kappa,v,mi)
            if(inv.lt.0) then
               write(*,*) '*ERROR in liquidpipe: loss coefficients'
               write(*,*) '       for exit (Idelchik) do not apply to'
               write(*,*) '       reversed flow'
               stop
            endif
!
            dh=prop(index+3)
            if(dh.eq.0.d0) then
               dh=dsqrt(4*a1/pi)
            endif
            if(inv.eq.0) then
               reynolds=5000.d0
            else
               reynolds=dabs(xflow)*dh/(dvi*a1)
            endif
!
            if(inv.ne.0) then
               xk=zeta/(a1*a1)
            else
               xkn=zeta/(a1*a1)
               xkp=xkn
            endif
         elseif(lakon(nelem)(4:5).eq.'US') then
!     
!     pipe, user defined loss coefficient
!     
            a1=prop(index+1)
            a2=prop(index+2)
            call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &           isothermal,kon,ipkon,R,Kappa,v,mi)
            if(inv.lt.0) then
               write(*,*) '*ERROR in liquidpipe: loss coefficients'
               write(*,*) '       for a user element do not apply to'
               write(*,*) '       reversed flow'
               stop
            endif
            if(a1.lt.a2) then
               a=a1
               a2=a1
            else
               a=a2
               a1=a2
            endif
!
            dh=prop(index+3)
            if(dh.eq.0.d0) then
               dh=dsqrt(4*a/pi)
            endif
            if(inv.eq.0) then
               reynolds=5000.d0
            else
               reynolds=dabs(xflow)*dh/(dvi*a)
            endif
!
            if(inv.ne.0) then
               xk=zeta/(a*a)
            else
               xkn=zeta/(a*a)
               xkp=xkn
            endif
         elseif(lakon(nelem)(6:7).eq.'GV') then
!     
!     pipe, gate valve (Berlamont)
!     
            a=prop(index+1)
            if(nactdog(3,nodem).eq.0) then
!              geometry is fixed
               alpha=prop(index+2)
            else
!              geometry is unknown
               alpha=v(3,nodem)
            endif
            a1=a
            a2=a
            dzetadalpha=0.d0
            call ident(xgv,alpha,ngv,id)
            if(id.eq.0) then
               zeta=ygv(1)
            elseif(id.eq.ngv) then
               zeta=ygv(ngv)
            else
               dzetadalpha=(ygv(id+1)-ygv(id))/(xgv(id+1)-xgv(id))
               zeta=ygv(id)+dzetadalpha*(alpha-xgv(id))
            endif
            if(inv.ne.0) then
               xk=zeta/(a*a)
               dkda=dzetadalpha/(a*a)
            else
               if(flowunknown) then
                  xkn=zeta/(a*a)
                  xkp=xkn
               endif
            endif
         elseif(lakon(nelem)(6:7).eq.'BE') then
!     
!     pipe, bend; values from Berlamont
!     
            a=prop(index+1)
            rd=prop(index+2)
            alpha=prop(index+3)
            coarseness=prop(index+4)
            a1=a
            a2=a
            call ident(xbe,rd,nbe,id)
            if(id.eq.0) then
               zeta=ybe(1)+(zbe(1)-ybe(1))*coarseness
            elseif(id.eq.nbe) then
               zeta=ybe(nbe)+(zbe(nbe)-ybe(nbe))*coarseness
            else
               zeta=(1.d0-coarseness)*
     &              (ybe(id)+(ybe(id+1)-ybe(id))*(rd-xbe(id))/
     &              (xbe(id+1)-xbe(id)))
     &              +coarseness*
     &              (zbe(id)+(zbe(id+1)-zbe(id))*(rd-xbe(id))/
     &              (xbe(id+1)-xbe(id)))
            endif
            zeta=zeta*alpha/90.d0
            if(inv.ne.0) then
               xk=zeta/(a*a)
            else
               xkn=zeta/(a*a)
               xkp=xkn
            endif
         elseif(lakon(nelem)(4:5).eq.'BE') then
!     
!     pipe, bend; values from Idelchik or Miller, OWN
!     
            a=prop(index+1)
            dh=prop(index+3)
            if(dh.eq.0.d0) then
               dh=dsqrt(4*a/pi)
            endif
            if(inv.eq.0) then
               reynolds=5000.d0
            else
               reynolds=dabs(xflow)*dh/(dvi*a)
            endif
            call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &           isothermal,kon,ipkon,R,Kappa,v,mi)
            if(inv.ne.0) then
               xk=zeta/(a*a)
            else
               xkn=zeta/(a*a)
               xkp=xkn
            endif
            a1=a
            a2=a
         elseif(lakon(nelem)(4:5).eq.'LO') then
!     
!     long orifice; values from Idelchik or Lichtarowicz
!     
            a1=prop(index+1)
            dh=prop(index+3)
            if(inv.eq.0) then
               reynolds=5000.d0
            else
               reynolds=dabs(xflow)*dh/(dvi*a1)
            endif
            call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &           isothermal,kon,ipkon,R,Kappa,v,mi)
            if(inv.ne.0) then
               xk=zeta/(a1*a1)
            else
               xkn=zeta/(a1*a1)
               xkp=xkn
            endif
            a2=a1
         elseif(lakon(nelem)(4:5).eq.'WA') then
!     
!     wall orifice; values from Idelchik
!   
!           entrance is infinitely large
!  
            a1=1.d10*prop(index+1)
!
!           reduced cross section
!
            a2=prop(index+2)
            dh=prop(index+3)
            if(inv.eq.0) then
               reynolds=5000.d0
            else
               reynolds=dabs(xflow)*dh/(dvi*a2)
            endif
            call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &           isothermal,kon,ipkon,R,Kappa,v,mi)
!
!           check for negative flow: in that case the loss
!           coefficient is wrong
!
            if(inv.lt.0) then
               write(*,*) '*ERROR in liquidpipe: loss coefficients'
               write(*,*) '       for wall orifice do not apply to'
               write(*,*) '       reversed flow'
               stop
            endif
            if(inv.ne.0) then
               xk=zeta/(a2*a2)
            else
               xkn=zeta/(a2*a2)
               xkp=xkn
            endif
         elseif(lakon(nelem)(4:5).eq.'BR') then
!     
!     branches (joints and splits); values from Idelchik and GE
!   
            if(nelem.eq.int(prop(index+2))) then
               a=prop(index+5)
            else
               a=prop(index+6)
            endif
            a1=a
            a2=a
!
!           check for negative flow: in that case the loss
!           coefficient is wroing
!
            if(inv.lt.0) then
               write(*,*) '*ERROR in liquidpipe: loss coefficients'
               write(*,*) '       for branches do not apply to'
               write(*,*) '       reversed flow'
               stop
            endif
            if(inv.ne.0) then
               call zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &              isothermal,kon,ipkon,R,Kappa,v,mi)
               xk=zeta/(a*a)
            else
!
!              here, the flow is unknown. To this end zeta is needed. However,
!              zeta depends on the flow: circular argument. Therefore a
!              fixed initial value for zeta is taken
!
               zeta=0.5d0
               xkn=zeta/(a*a)
               xkp=xkn
            endif
!
!     all types of orifices
!
        elseif((lakon(nelem)(4:5).eq.'C1')) then
            a1=prop(index+1)
            a2=a1
            dh=prop(index+2)
            if(inv.eq.0) then
               reynolds=5000.d0
            else
               reynolds=dabs(xflow)*dh/(dvi*a1)
            endif
            zeta=1.d0
!
             a=a1
             zeta=1/zeta**2
            if(inv.ne.0) then
               xk=zeta/(a*a)
            else
               xkn=zeta/(a*a)
               xkp=xkn
            endif
!     
!     all types of vorticies
!
         elseif((lakon(nelem)(4:4).eq.'V')) then
!
!     radius downstream
            r2d=prop(index+1)
!     
!     radius upstream
            r1d=prop(index+2)
!     
!     pressure correction factor
            eta=prop(index+3) 
!
            if(((xflow.gt.0.d0).and.(R2d.gt.R1d))
     &              .or.((R2.lt.R1).and.(xflow.lt.0d0))) then
               inv=1.d0
               p1=v(2,node1)
               p2=v(2,node2)
               R1=r1d
               R2=r2d
!     
            elseif(((xflow.gt.0.d0).and.(R2d.lt.R1d))
     &                 .or.((R2.gt.R1).and.(xflow.lt.0d0))) then
               inv=-1.d0
               R1=r2d
               R2=r1d
               p1=v(2,node2)
               p2=v(2,node1)
               xflow=-v(1,nodem)
!     
               nodef(1)=node2
               nodef(2)=nodem
               nodef(3)=node1
!     
            endif
!     
            idirf(1)=2
            idirf(2)=1
            idirf(3)=2
!
!     FREE VORTEX
!            
            if((lakon(nelem)(4:5).eq.'VF')) then
!     rotation induced loss (correction factor)
               K1= prop(index+4)
!     
!     tangential velocity of the disk at vortex entry
               U1=prop(index+5)
!     
!     number of the element generating the upstream swirl
               nelemswirl=int(prop(index+6))
!     
!     rotation speed (revolution per minutes)
               rpm=prop(index+7)
!
!     Temperature change
               t_chang=prop(index+8)
!
               if(rpm.gt.0) then
!
!     rotation speed is given (rpm) if the swirl comes from a rotating part
!     typically the blade of a coverplate
!
                  omega=pi/30d0*rpm
               
!     C_u is given by radius r1d (see definition of the flow direction)
!     C_u related to radius r2d is a function of r1d
!     
                  if(inv.gt.0) then
                     c1u=omega*r1
!     
!     flow rotation at outlet 
                     c2u=c1u*r1/r2
!     
                  elseif(inv.lt.0) then
                     c2u=omega*r2
!     
                     c1u=c2u*r2/r1
                  endif
!
               elseif(nelemswirl.gt.0) then
                  if(lakon(nelemswirl)(2:5).eq.'LPPN') then
                     cinput=prop(ielprop(nelemswirl)+5)
                  elseif(lakon(nelemswirl)(2:5).eq.'LPVF') then
                     cinput=prop(ielprop(nelemswirl)+9)
                  elseif(lakon(nelemswirl)(2:5).eq.'LPFS') then
                     cinput=prop(ielprop(nelemswirl)+7)
                  endif
!     
                  cinput=U1+K1*(cinput-U1)
!     
                  if(inv.gt.0) then
                     c1u=cinput
                     c2u=c1u*R1/R2
                  elseif(inv.lt.0) then
                     c2u=cinput
                     c1u=c2u*R2/R1
                  endif
               endif
!     storing the tengential velocity for later use (wirbel cascade)
               if(inv.gt.0) then
                  prop(index+9)=c2u
               elseif(inv.lt.0) then
                  prop(index+9)=c1u
               endif
!
!    inner rotation
!     
               if(R1.lt.R2) then
                  ciu=c1u
               elseif(R1.ge.R2) then
                  ciu=c2u
               endif
!            
!               if (iflag.eq.1) then
                  a1=1E-6
                  a2=a1 
               if(inv.ne.0) then                         
                  xkn=rho/2*ciu**2*(1-(R1/R2)**2)
                  xkp=xkn
               else
                  xkn=rho/2*ciu**2*(1-(R1/R2)**2)
                  xkp=xkn
               endif
            endif
!
!     FORCED VORTEX
!            
            if((lakon(nelem)(4:5).eq.'VS')) then
!     
!     core swirl ratio
               Kr=prop(index+4)
!     
!     rotation speed (revolution per minutes) of the rotating part
!     responsible for the swirl
               rpm=prop(index+5)
!     
!     Temperature change
               t_chang=prop(index+6)
! 
!     rotation speed
               omega=pi/30*rpm
!     
                  Ui=omega*R1
                  c1u=Ui*kr
                  c2u=c1u*R2/R1
!     
!     storing the tengential velocity for later use (wirbel cascade)
               if(inv.gt.0) then
                  prop(index+7)=c2u
               elseif(inv.lt.0) then
                  prop(index+7)=c1u
               endif
!     
               a1=1E-6
               a2=a1 
               if(iflag.eq.1)then
                  xflow=0.5d0
               endif
!     
               if(inv.ne.0) then                         
                  xkn=rho/2*Ui**2*((R2/R1)**2-1)
                  xkp=xkn
               else
                  xkn=rho/2*Ui**2*((R2/R1)**2-1)
                  xkp=xkn
               endif
            endif                 
         endif
!     
         if(iflag.eq.1) then
            if(flowunknown) then
!     
               xk1=1.d0/(a1*a1)
               xk2=1.d0/(a2*a2)
               xflow=(z1-z2+(p1-p2)/rho)/(xk2-xk1+xkp)
               if(xflow.lt.0.d0) then
                  xflow=(z1-z2+(p1-p2)/rho)/(xk2-xk1-xkn)
                  if(xflow.lt.0.d0) then
                     write(*,*) '*WARNING in liquidpipe:'
                     write(*,*) '         initial mass flow could'
                     write(*,*) '         not be determined'
                     write(*,*) '         1.d-10 is taken'
                     xflow=1.d-10
                  else
                     xflow=-rho*dsqrt(2.d0*xflow)
                  endif
               else
                  xflow=rho*dsqrt(2.d0*xflow)
               endif
            else
!
!              mass flow known, geometry unknown
!
               if(lakon(nelem)(6:7).eq.'GV') then
                  prop(index+2)=0.5d0
               endif
            endif
         elseif(iflag.eq.2) then
            xk1=1.d0/(a1*a1)
            xk2=1.d0/(a2*a2)
!
            if(lakon(nelem)(4:4).ne.'V') then
!     
               numf=4
               df(3)=1.d0/rho
               df(1)=-df(3)
               df(2)=(xk2-xk1+inv*xk)*xflow/(rho*rho)
               df(4)=(xflow*xflow*inv*dkda)/(2.d0*rho*rho)
               f=df(3)*p2+df(1)*p1+df(2)*xflow/2.d0+z2-z1
!
            else if (lakon(nelem)(4:5).eq.'VF') then
               numf=3  
               if(R2.ge.R1) then
                  f=P1-P2+xkp
                  df(1)=1
                  df(2)=0
                  df(3)=-1
               elseif(R2.lt.R1) then 
                  f=P1-P2-xkp
                  df(1)=1
                  df(2)=0
                  df(3)=-1
               endif
            else if (lakon(nelem)(4:5).eq.'VS') then
               if(((R2.ge.R1).and.(xflow.gt.0d0))
     &              .or.((R2.lt.R1).and.(xflow.lt.0d0)))then
!     
                  f=p1-p2+xkn
!     pressure node1
                  df(1)=1
!     massflow nodem
                  df(2)=0
!     pressure node2
                  df(3)=-1
!     
               elseif(((R2.lt.R1).and.(xflow.gt.0d0))
     &                 .or.((R2.gt.R1).and.(xflow.lt.0d0)))then
!     
                  f=p2-p1+xkn
!     pressure node1
                  df(1)=-1
!     massflow nodem
                  df(2)=0
!     pressure node2
                  df(3)=1
               endif             
            endif
!     
         else if (iflag.eq.3) then
            xflow_vol=xflow/rho            
            un=dvi/rho
            if(inv.eq.1) then
               T=v(0,node1)
            else
               T=v(0,node2)
            endif
!     
            write(1,*) ''
            write(1,55) 'In line',int(nodem/1000),' from node',node1,
     &           ' to node', node2,':  oil massflow rate = ',xflow,
     &       ' kg/s i.e. ',xflow_vol, ' m**3/s'
 55         FORMAT(1X,A,I6.3,A,I6.3,A,I6.3,A,F9.6,A,F9.6,A)
            write(1,57)'                                              
     &Rho=   ',rho,' kg/m**3, Nu=   ',un,' m**2/s, Eta=   ',dvi,
     &' kg/(m*s)'
         
            if(inv.eq.1) then
               write(1,56)'       Inlet node  ',node1,':   Tt1=',T,
     &              'K, Pt1=',P1/1E5, 'Bar'
               if(lakon(nelem)(4:5).eq.'EL'.or.
     &            lakon(nelem)(4:5).eq.'CO'.or.
     &            lakon(nelem)(4:5).eq.'EN'.or.
     &            lakon(nelem)(4:5).eq.'EX'.or.
     &            lakon(nelem)(4:5).eq.'US'.or.
     &            lakon(nelem)(4:5).eq.'BE'.or.
     &            lakon(nelem)(4:5).eq.'LO'.or.
     &            lakon(nelem)(4:5).eq.'WA'.or.
     &            lakon(nelem)(4:5).eq.'BR')then
                  
                  write(1,*)'             element F   ',set(numf)(1:20)
                  write(1,58)'             Re=   ',reynolds,' zeta=   ',
     &                 zeta
!
               elseif((lakon(nelem)(4:5).eq.'C1')) then
                  write(1,*)'             element R   ',set(numf)(1:20)
                  write(1,58)'             Re=   ',reynolds,' cd=   ',
     &                 zeta
!
               else if(lakon(nelem)(4:5).eq.'FR')then                  
                  write(1,*)'             element W   ',set(numf)(1:20)
                  write(1,59)'             Re=   ',reynolds,' lambda=  
     &',friction,'  lambda*L/D=   ',friction*dl/d
!
               else if (lakon(nelem)(4:4).eq.'V')then  
                  write(1,*)'             element V    ',set(numf)(1:20)
                  write(1,*)'             C1u= ',C1u,'m/s ,C2u= '
     &,C2u,'m/s',' ,DeltaP= ',xkn/1E5,' Bar'
               endif
!
               write(1,56)'       Outlet node ',node2,':   Tt2=',T,
     &              'K, Pt2=',P2/1e5,'Bar'
!     
            else if(inv.eq.-1) then
               
            endif
!
 56         FORMAT(1X,A,I6.3,A,f6.1,A,f9.5,A)
 57         FORMAT(1X,A,f8.3,A,G9.4,A,G9.4,A)
 58         FORMAT(1X,A,G9.4,A,F6.4)
 59         FORMAT(1X,A,G9.4,A,F6.4,A,F6.4) 
         endif
!     
      endif
!     
      return
      end
      

