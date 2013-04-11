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
      subroutine e_c3d_krhs(co,nk,konl,lakonl,ffk,fft,nelem,nmethod,
     &  rhcon,nrhcon,ielmat,ntmat_,vold,voldaux,dtime,matname,mint_,
     &  shcon,nshcon,voldtu)
!
!     computation of the turbulence element matrix and rhs for the
!     element with the topology in konl: step 4
!
!     ffk and fft: rhs (x 2: kinetic term and turbulence frequency term):
!
      implicit none
!
      character*8 lakonl
      character*80 matname(*),amat
!
      integer konl(20),ifaceq(8,6),nk,nelem,
     &  nload,i,j,k,i1,i2,j1,k1,
     &  nmethod,ii,jj,id,ipointer,ig,kk,
     &  nrhcon(*),ielmat(*),nshcon(*),
     &  ntmat_,nope,nopes,imat,mint2d,
     &  mint3d,mint_,ifacet(6,4),nopev,
     &  ifacew(8,5),istep,iinc,
     &  layer,kspt,jltyp,iflag
!
      real*8 co(3,*),xl(3,20),shp(4,20),xs2(3,2),r,cp,dvi,
     &  ffk(60),xsjmod,dtem(3),vkl(3,3),
     &  rhcon(0:1,ntmat_,*),reltime,t(3,3),bfv,press,
     &  vel(3),div,shcon(0:3,ntmat_,*),pgauss(3),xkin,xtuf,
     &  voldl(0:4,20),
     &  xl2(0:3,8),xsj2(3),shp2(4,8),vold(0:4,*),
     &  om,omx,xi,et,ze,const,xsj,fft(60),dxkin(3),
     &  temp,voldaux(0:5,*),voldauxl(0:5,20),rho,dxtuf(3),
     &  weight,shpv(20),rhokin,rhotuf,y,vort,c1,c2,arg2,f2,
     &  a1,unt,umt,cdktuf,arg1,f1,skin,skin1,skin2,stuf,stuf1,
     &  stuf2,beta,beta1,beta2,betas,gamm,gamm1,xkappa,un,
     &  gamm2,umsk,umst,tu,tuk,tut,voldtu(2,*),voldtul(2,20),
     &  f1m
!
      real*8 dtime,ttime,time,tvar(2),
     &  coords(3)
!
      include "gauss.f"
!
      data ifaceq /4,3,2,1,11,10,9,12,
     &            5,6,7,8,13,14,15,16,
     &            1,2,6,5,9,18,13,17,
     &            2,3,7,6,10,19,14,18,
     &            3,4,8,7,11,20,15,19,
     &            4,1,5,8,12,17,16,20/
      data ifacet /1,3,2,7,6,5,
     &             1,2,4,5,9,8,
     &             2,3,4,6,10,9,
     &             1,4,3,8,10,7/
      data ifacew /1,3,2,9,8,7,0,0,
     &             4,5,6,10,11,12,0,0,
     &             1,2,5,4,7,14,10,13,
     &             2,3,6,5,8,15,11,14,
     &             4,6,3,1,12,15,9,13/
      data iflag /3/
c      data iperm /13,14,-15,16,17,-18,19,20,-21,22,23,-24,
c     &            1,2,-3,4,5,-6,7,8,-9,10,11,-12,
c     &            37,38,-39,40,41,-42,43,44,-45,46,47,-48,
c     &            25,26,-27,28,29,-30,31,32,-33,34,35,-36,
c     &            49,50,-51,52,53,-54,55,56,-57,58,59,-60/
!
!     turbulence constants
!
      data skin1 /0.85d0/
      data skin2 /1.d0/
      data stuf1 /0.5d0/
      data stuf2 /0.856d0/
      data beta1 /0.075d0/
      data beta2 /0.0828d0/
      data a1 /0.31d0/
      data betas /0.09d0/
      data xkappa / 0.41d0/
!
      gamm1=beta1/betas-stuf1*xkappa*xkappa/dsqrt(betas)
      gamm2=beta2/betas-stuf2*xkappa*xkappa/dsqrt(betas)
!
      tvar(1)=time
      tvar(2)=ttime+dtime
!
      imat=ielmat(nelem)
      amat=matname(imat)
!
      if(lakonl(4:4).eq.'2') then
         nope=20
         nopev=8
         nopes=8
      elseif(lakonl(4:4).eq.'8') then
         nope=8
         nopev=8
         nopes=4
      elseif(lakonl(4:5).eq.'10') then
         nope=10
         nopev=4
         nopes=6
      elseif(lakonl(4:4).eq.'4') then
         nope=4
         nopev=4
         nopes=3
      elseif(lakonl(4:5).eq.'15') then
         nope=15
         nopev=6
      elseif(lakonl(4:4).eq.'6') then
         nope=6
         nopev=6
      endif
!
         if(lakonl(4:5).eq.'8R') then
            mint2d=1
            mint3d=1
         elseif((lakonl(4:4).eq.'8').or.(lakonl(4:6).eq.'20R')) then
            if((lakonl(7:7).eq.'A').or.(lakonl(7:7).eq.'S').or.
     &         (lakonl(7:7).eq.'E')) then
               mint2d=2
               mint3d=4
            else
               mint2d=4
               mint3d=8
            endif
         elseif(lakonl(4:4).eq.'2') then
            mint2d=9
            mint3d=27
         elseif(lakonl(4:5).eq.'10') then
            mint2d=3
            mint3d=4
         elseif(lakonl(4:4).eq.'4') then
            mint2d=1
            mint3d=1
         elseif(lakonl(4:5).eq.'15') then
            mint3d=9
         elseif(lakonl(4:4).eq.'6') then
            mint3d=2
         else
            mint3d=0
         endif
!
!     computation of the coordinates of the local nodes
!
      do i=1,nope
        do j=1,3
          xl(j,i)=co(j,konl(i))
        enddo
      enddo
!
!       initialisation for distributed forces
!
      do i=1,nope
         ffk(i)=0.d0
         fft(i)=0.d0
      enddo
!
!     temperature, velocity and auxiliary variables
!     (rho*energy density, rho*velocity and rho)
!
         do i1=1,nope
            do i2=0,4
               voldl(i2,i1)=vold(i2,konl(i1))
            enddo
            voldauxl(5,i1)=voldaux(5,konl(i1))
            voldtul(1,i1)=voldtu(1,konl(i1))
            voldtul(2,i1)=voldtu(2,konl(i1))
         enddo
!
!     computation of the matrix: loop over the Gauss points
!
      do kk=1,mint3d
         if(lakonl(4:5).eq.'8R') then
            xi=gauss3d1(1,kk)
            et=gauss3d1(2,kk)
            ze=gauss3d1(3,kk)
            weight=weight3d1(kk)
         elseif((lakonl(4:4).eq.'8').or.(lakonl(4:6).eq.'20R')) 
     &           then
            xi=gauss3d2(1,kk)
            et=gauss3d2(2,kk)
            ze=gauss3d2(3,kk)
            weight=weight3d2(kk)
         elseif(lakonl(4:4).eq.'2') then
            xi=gauss3d3(1,kk)
            et=gauss3d3(2,kk)
            ze=gauss3d3(3,kk)
            weight=weight3d3(kk)
         elseif(lakonl(4:5).eq.'10') then
            xi=gauss3d5(1,kk)
            et=gauss3d5(2,kk)
            ze=gauss3d5(3,kk)
            weight=weight3d5(kk)
         elseif(lakonl(4:4).eq.'4') then
            xi=gauss3d4(1,kk)
            et=gauss3d4(2,kk)
            ze=gauss3d4(3,kk)
            weight=weight3d4(kk)
         elseif(lakonl(4:5).eq.'15') then
            xi=gauss3d8(1,kk)
            et=gauss3d8(2,kk)
            ze=gauss3d8(3,kk)
            weight=weight3d8(kk)
         elseif(lakonl(4:4).eq.'6') then
            xi=gauss3d7(1,kk)
            et=gauss3d7(2,kk)
            ze=gauss3d7(3,kk)
            weight=weight3d7(kk)
         endif
!     
!     calculation of the shape functions and their derivatives
!     in the gauss point
!     
         if(nope.eq.20) then
            if(lakonl(7:7).eq.'A') then
               call shape20h_ax(xi,et,ze,xl,xsj,shp,iflag)
            elseif((lakonl(7:7).eq.'E').or.(lakonl(7:7).eq.'S')) then
               call shape20h_pl(xi,et,ze,xl,xsj,shp,iflag)
            else
               call shape20h(xi,et,ze,xl,xsj,shp,iflag)
            endif
         elseif(nope.eq.8) then
            call shape8h(xi,et,ze,xl,xsj,shp,iflag)
         elseif(nope.eq.10) then
            call shape10tet(xi,et,ze,xl,xsj,shp,iflag)
         elseif(nope.eq.4) then
            call shape4tet(xi,et,ze,xl,xsj,shp,iflag)
         elseif(nope.eq.15) then
            call shape15w(xi,et,ze,xl,xsj,shp,iflag)
         else
            call shape6w(xi,et,ze,xl,xsj,shp,iflag)
         endif
!     
!     check the jacobian determinant
!     
         if(xsj.lt.1.d-20) then
            write(*,*) '*WARNING in e_c3d: nonpositive jacobian'
            write(*,*) '         determinant in element',nelem
            write(*,*)
            xsj=dabs(xsj)
            nmethod=0
         endif
!     
         xsjmod=dtime*xsj*weight
!     
!        calculating of
!        rho times turbulent kinetic energy times shpv(*): rhokin
!        rho times turbulence frequency times shpv(*): rhotuf
!        distance from solid surface: y
!        the velocity vel
!        the velocity gradient vkl
!        the divergence of the shape function times the velocity shpv(*)
!              in the integration point
!     
         temp=0.d0
         rhokin=0.d0
         rhotuf=0.d0
         y=0.d0
         do i1=1,3
            vel(i1)=0.d0
            dtem(i1)=0.d0
            do j1=1,3
               vkl(i1,j1)=0.d0
            enddo
         enddo
         do i1=1,nope
            temp=temp+shp(4,i1)*voldl(0,i1)
            y=y+shp(4,i1)*voldauxl(5,i1)
            do j1=1,3
               vel(j1)=vel(j1)+shp(4,i1)*voldl(j1,i1)
               do k1=1,3
                  vkl(j1,k1)=vkl(j1,k1)+shp(k1,i1)*voldl(j1,i1)
               enddo
            enddo
         enddo
         do i1=1,nope
            shpv(i1)=shp(1,i1)*vel(1)+shp(2,i1)*vel(2)+
     &           shp(3,i1)*vel(3)+shp(4,i1)*div
            rhokin=rhokin+shpv(i1)*voldtul(1,i1)
            rhotuf=rhotuf+shpv(i1)*voldtul(2,i1)
         enddo
!     
!     material data (density and dynamic viscosity)
!     
         call materialdata_tg(imat,ntmat_,temp,shcon,nshcon,cp,r,dvi,
     &        rhcon,nrhcon,rho)
!
!     determining the stress and and stress x velocity + conductivity x
!     temperature gradient
!
         do i1=1,3
            do j1=1,3
               t(i1,j1)=vkl(i1,j1)+vkl(j1,i1)
            enddo
            t(i1,i1)=t(i1,i1)-2.d0*vkl(i1,i1)/3.d0
         enddo
!     
!     calculation of the density for gases
!     
!     calculation of the turbulent kinetic energy, turbulence
!     frequency and their spatial derivatives for gases and liquids
!
         if(dabs(rho).lt.1.d-20) then
!
!           gas
!
            rho=0.d0
            xkin=0.d0
            xtuf=0.d0
            do j1=1,3
               dxkin(j1)=0.d0
               dxtuf(j1)=0.d0
            enddo
            do i1=1,nope
               rho=rho+shp(4,i1)*voldauxl(4,i1)
               xkin=xkin+shp(4,i1)*voldtul(1,i1)/voldauxl(4,i1)
               xtuf=xtuf+shp(4,i1)*voldtul(2,i1)/voldauxl(4,i1)
               do j1=1,3
                  dxkin(j1)=dxkin(j1)+
     &               shp(j1,i1)*voldtul(1,i1)/voldauxl(4,i1)
                  dxtuf(j1)=dxtuf(j1)+
     &               shp(j1,i1)*voldtul(2,i1)/voldauxl(4,i1)
               enddo
            enddo
         else
!
!           liquid
!
            xkin=0.d0
            xtuf=0.d0
            do j1=1,3
               dxkin(j1)=0.d0
               dxtuf(j1)=0.d0
            enddo
            do i1=1,nope
               xkin=xkin+shp(4,i1)*voldtul(1,i1)/rho
               xtuf=xtuf+shp(4,i1)*voldtul(2,i1)/rho
               do j1=1,3
                  dxkin(j1)=dxkin(j1)+
     &               shp(j1,i1)*voldtul(1,i1)/rho
                  dxtuf(j1)=dxtuf(j1)+
     &               shp(j1,i1)*voldtul(2,i1)/rho
               enddo
            enddo
         endif
!
!        calculation of turbulent auxiliary variables
!
!        vorticity
!
         vort=dsqrt((vkl(3,2)-vkl(2,3))**2+
     &              (vkl(1,3)-vkl(3,1))**2+
     &              (vkl(2,1)-vkl(1,2))**2)
!
!        kinematic viscosity
!
         un=dvi/rho
!
!        factor F2
!
         c1=dsqrt(xkin)/(0.09d0*xtuf*y)
         c2=500.d0*un/(y*y*xtuf)
         arg2=max(2.d0*c1,c2)
         f2=dtanh(arg2*arg2)
!
!        kinematic and dynamic turbulent viscosity
!
         unt=a1*xkin/max(a1*xtuf,vort*f2)
         umt=unt*rho
!
!        factor F1
!     
         cdktuf=max(2.d0*rho*stuf2*
     &      (dxkin(1)*dxtuf(1)+dxkin(2)*dxtuf(2)+dxkin(3)*dxtuf(3))/
     &      xtuf,1.d-20)
         arg1=min(max(c1,c2),4.d0*rho*stuf2*xkin/(cdktuf*y*y))
         f1=dtanh(arg1**4.d0)
         f1m=1.d0-f1
!
!        interpolation of the constants
!
         skin=f1*skin1+f1m*skin2
         stuf=f1*stuf1+f1m*stuf2
         beta=f1*beta1+f1m*beta2
         gamm=f1*gamm1+f1m*gamm2
!
!        auxiliary quantities
!
         umsk=dvi+skin*umt
         umst=dvi+stuf*umt
         tu=umt*(t(1,1)*vkl(1,1)+t(1,2)*vkl(1,2)+t(1,3)*vkl(1,3)+
     &           t(2,1)*vkl(2,1)+t(2,2)*vkl(2,2)+t(2,3)*vkl(2,3)+
     &           t(3,1)*vkl(3,1)+t(3,2)*vkl(3,2)+t(3,3)*vkl(3,3))-
     &           2.d0*rho*xkin*(vkl(1,1)+vkl(2,2)+vkl(3,3))/3.d0
         tuk=tu-betas*rho*xtuf*xkin
         tut=gamm*tu/unt-beta*rho*xtuf*xtuf+2.d0*f1m*rho*stuf2*
     &       (dxkin(1)*dxtuf(1)+dxkin(2)*dxtuf(2)+dxkin(3)*dxtuf(3))/
     &       xtuf
         do i1=1,3
            dxkin(i1)=dxkin(i1)*umsk
            dxtuf(i1)=dxtuf(i1)*umst
         enddo
!     
!     determination of lhs and rhs
!     
         do jj=1,nope
!     
            ffk(jj)=ffk(jj)+xsjmod*((shp(4,jj)+dtime*shpv(jj)/2.d0)*
     &           (rhokin+tuk)-(shp(1,jj)*dxkin(1)+shp(2,jj)*dxkin(2)
     &              +shp(3,jj)*dxkin(3)))
            fft(jj)=fft(jj)+xsjmod*((shp(4,jj)+dtime*shpv(jj)/2.d0)*
     &           (rhotuf+tut)-(shp(1,jj)*dxtuf(1)+shp(2,jj)*dxtuf(2)
     &              +shp(3,jj)*dxtuf(3)))
         enddo
         
!     
      enddo
!     
c      if(nload.ne.0) then
c!     
c!     distributed loads
c!     
c         call nident2(nelemload,nelem,nload,id)
c         do
c            if((id.eq.0).or.(nelemload(1,id).ne.nelem)) exit
c            if(sideload(id)(1:1).ne.'P') then
c               id=id-1
c               cycle
c            endif
c            read(sideload(id)(2:2),'(i1)') ig
c!     
c!     treatment of wedge faces
c!     
c            if(lakonl(4:4).eq.'6') then
c               mint2d=1
c               if(ig.le.2) then
c                  nopes=3
c               else
c                  nopes=4
c               endif
c            endif
c            if(lakonl(4:5).eq.'15') then
c               if(ig.le.2) then
c                  mint2d=3
c                  nopes=6
c               else
c                  mint2d=4
c                  nopes=8
c               endif
c            endif
c!     
c            if((nope.eq.20).or.(nope.eq.8)) then
c               do i=1,nopes
c                  do j=1,3
c                     xl2(j,i)=co(j,konl(ifaceq(i,ig)))
c                  enddo
c               enddo
c            elseif((nope.eq.10).or.(nope.eq.4)) then
c               do i=1,nopes
c                  do j=1,3
c                     xl2(j,i)=co(j,konl(ifacet(i,ig)))
c                  enddo
c               enddo
c            else
c               do i=1,nopes
c                  do j=1,3
c                     xl2(j,i)=co(j,konl(ifacew(i,ig)))
c                  enddo
c               enddo
c            endif
c!     
c            do i=1,mint2d
c               if((lakonl(4:5).eq.'8R').or.
c     &              ((lakonl(4:4).eq.'6').and.(nopes.eq.4))) then
c                  xi=gauss2d1(1,i)
c                  et=gauss2d1(2,i)
c                  weight=weight2d1(i)
c               elseif((lakonl(4:4).eq.'8').or.
c     &                 (lakonl(4:6).eq.'20R').or.
c     &                 ((lakonl(4:5).eq.'15').and.(nopes.eq.8))) then
c                  xi=gauss2d2(1,i)
c                  et=gauss2d2(2,i)
c                  weight=weight2d2(i)
c               elseif(lakonl(4:4).eq.'2') then
c                  xi=gauss2d3(1,i)
c                  et=gauss2d3(2,i)
c                  weight=weight2d3(i)
c               elseif((lakonl(4:5).eq.'10').or.
c     &                 ((lakonl(4:5).eq.'15').and.(nopes.eq.6))) then
c                  xi=gauss2d5(1,i)
c                  et=gauss2d5(2,i)
c                  weight=weight2d5(i)
c               elseif((lakonl(4:4).eq.'4').or.
c     &                 ((lakonl(4:4).eq.'6').and.(nopes.eq.3))) then
c                  xi=gauss2d4(1,i)
c                  et=gauss2d4(2,i)
c                  weight=weight2d4(i)
c               endif
c!     
c               if(nopes.eq.8) then
c                  call shape8q(xi,et,xl2,xsj2,xs2,shp2,iflag)
c               elseif(nopes.eq.4) then
c                  call shape4q(xi,et,xl2,xsj2,xs2,shp2,iflag)
c               elseif(nopes.eq.6) then
c                  call shape6tri(xi,et,xl2,xsj2,xs2,shp2,iflag)
c               else
c                  call shape3tri(xi,et,xl2,xsj2,xs2,shp2,iflag)
c               endif
c!     
c!     for nonuniform load: determine the coordinates of the
c!     point (transferred into the user subroutine)
c!     
c               if(sideload(id)(3:4).eq.'NU') then
c                  do k=1,3
c                     coords(k)=0.d0
c                     do j=1,nopes
c                        coords(k)=coords(k)+xl2(k,j)*shp2(4,j)
c                     enddo
c                  enddo
c                  read(sideload(id)(2:2),'(i1)') jltyp
c                  jltyp=jltyp+20
c                  call dload(xload(1,id),istep,iinc,tvar,nelem,i,layer,
c     &                 kspt,coords,jltyp,sideload(id))
c                  if(nmethod.eq.1) xload(1,id)=xloadold(1,id)+
c     &                 (xload(1,id)-xloadold(1,id))*reltime
c               endif
c!     
c               do k=1,nopes
c                  if((nope.eq.20).or.(nope.eq.8)) then
c                     ipointer=(ifaceq(k,ig)-1)*3
c                  elseif((nope.eq.10).or.(nope.eq.4)) then
c                     ipointer=(ifacet(k,ig)-1)*3
c                  else
c                     ipointer=(ifacew(k,ig)-1)*3
c                  endif
cc                  ff(ipointer+1)=ff(ipointer+1)-shp2(4,k)*xload(1,id)
cc     &                 *xsj2(1)*weight
cc                  ff(ipointer+2)=ff(ipointer+2)-shp2(4,k)*xload(1,id)
cc     &                 *xsj2(2)*weight
cc                  ff(ipointer+3)=ff(ipointer+3)-shp2(4,k)*xload(1,id)
cc     &                 *xsj2(3)*weight
c               enddo
c            enddo
c         enddo
c      endif
!     
!     
!     for axially symmetric and plane stress/strain elements: 
!     complete s and sm
!
c      if((lakonl(6:7).eq.'RA').or.(lakonl(6:7).eq.'RS').or.
c     &   (lakonl(6:7).eq.'RE')) then
c!
c         if((nload.ne.0).or.(nbody.ne.0)) then
c            do i=1,60
c               k=abs(iperm(i))
c               ffax(i)=ff(k)*iperm(i)/k
c            enddo
c            do i=1,60
c               ff(i)=ff(i)+ffax(i)
c            enddo
c         endif
c!
c      endif
c!
      return
      end

