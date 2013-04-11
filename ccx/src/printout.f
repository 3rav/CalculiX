
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
      subroutine printout(set,nset,istartset,iendset,ialset,nprint,
     &  prlab,prset,v,t1,fn,ipkon,lakon,stx,eme,xstate,ener,
     &  mi,nstate_,ithermal,co,kon,qfx,ttime,trab,inotr,ntrans,
     &  orab,ielorien,norien,nk,ne,inum,filab,vold,ikin)
!
!     stores results in the .dat file
!
      implicit none
!
      logical force
!
      character*1 cflag
      character*6 prlab(*)
      character*8 lakon(*)
      character*80 noset,elset
      character*81 set(*),prset(*)
      character*87 filab(*)
!
      integer nset,istartset(*),iendset(*),ialset(*),nprint,ipkon(*),
     &  mi(2),nstate_,ii,jj,iset,l,lb,limit,node,ipos,ithermal,
     &  nelem,kon(*),inotr(2,*),ntrans,ielorien(*),norien,nk,ne,
     &  inum(*),nfield,ikin,nodes,ne0,nope,mt
!
      real*8 v(0:mi(2),*),t1(*),fn(0:mi(2),*),stx(6,mi(1),*),
     &  eme(6,mi(1),*),xstate(nstate_,mi(1),*),ener(mi(1),*),energytot,
     &  volumetot,co(3,*),qfx(3,mi(1),*),rftot(0:3),ttime,
     &  trab(7,*),orab(7,*),vold(0:mi(2),*),enerkintot
!
      mt=mi(2)+1
!
!     interpolation in the original nodes of 1d and 2d elements
!
      do ii=1,nprint
         if((prlab(ii)(1:4).eq.'U   ').or.
     &      ((prlab(ii)(1:4).eq.'NT  ').and.(ithermal.gt.1))) then
            if(filab(1)(5:5).ne.' ') then
               nfield=mt
               cflag=' '
               force=.false.
               call map3dto1d2d(v,ipkon,inum,kon,lakon,nfield,nk,
     &              ne,cflag,co,vold,force,mi)
            endif
            exit
          endif
      enddo
      do ii=1,nprint
         if((prlab(ii)(1:4).eq.'NT  ').and.(ithermal.le.1)) then
            if(filab(2)(5:5).ne.' ') then
               nfield=1
               cflag=' '
               force=.false.
               call map3dto1d2d(t1,ipkon,inum,kon,lakon,nfield,nk,
     &              ne,cflag,co,vold,force,mi)
            endif
            exit
          endif
      enddo
      do ii=1,nprint
         if(prlab(ii)(1:2).eq.'RF') then
            if(filab(1)(5:5).ne.' ') then
               nfield=mt
               cflag=' '
               force=.true.
               call map3dto1d2d(fn,ipkon,inum,kon,lakon,nfield,nk,
     &              ne,cflag,co,vold,force,mi)
            endif
            exit
          endif
      enddo
!
      do ii=1,nprint
!
!        nodal values
!
         if((prlab(ii)(1:4).eq.'U   ').or.(prlab(ii)(1:4).eq.'NT  ').or.
     &      (prlab(ii)(1:4).eq.'RF  ').or.(prlab(ii)(1:4).eq.'RFL ').or. 
     &      (prlab(ii)(1:4).eq.'PS  ').or.(prlab(ii)(1:4).eq.'PT  ').or.
     &      (prlab(ii)(1:4).eq.'MF  ').or.(prlab(ii)(1:4).eq.'V   ')) 
     &      then
!
            ipos=index(prset(ii),' ')
            noset='                    '
            noset(1:ipos-1)=prset(ii)(1:ipos-1)
!
!           printing the header
!
            if(prlab(ii)(1:4).eq.'U   ') then
               write(5,*)
               write(5,100) noset(1:ipos-2),ttime
 100           format(' displacements (vx,vy,vz) for set ',A,
     &             ' and time ',e14.7)
               write(5,*)
            elseif(prlab(ii)(1:4).eq.'NT  ') then
               write(5,*)
               write(5,101) noset(1:ipos-2),ttime
 101           format(' temperatures for set ',A,' and time ',e14.7)
               write(5,*)
            elseif((prlab(ii)(1:5).eq.'RF   ').or.
     &             (prlab(ii)(1:5).eq.'RF  T')) then
               write(5,*)
               write(5,102) noset(1:ipos-2),ttime
 102           format(' forces (fx,fy,fz) for set ',A,
     &                ' and time ',e14.7)
               write(5,*)
            elseif((prlab(ii)(1:5).eq.'RFL ').or.
     &             (prlab(ii)(1:5).eq.'RFL T')) then
               write(5,*)
               write(5,103) noset(1:ipos-2),ttime
 103           format(' heat generation for set ',A,' and time ',e14.7)
               write(5,*)
            elseif(prlab(ii)(1:4).eq.'PS  ') then
               write(5,*)
               write(5,115) noset(1:ipos-2),ttime
 115           format(' static pressures for set ',A,' and time ',e14.7)
               write(5,*)
            elseif(prlab(ii)(1:4).eq.'PT  ') then
               write(5,*)
               write(5,117) noset(1:ipos-2),ttime
 117           format(' total pressures for set ',A,' and time ',e14.7)
               write(5,*)
            elseif(prlab(ii)(1:4).eq.'MF  ') then
               write(5,*)
               write(5,118) noset(1:ipos-2),ttime
 118           format(' mass flows for set ',A,' and time ',e14.7)
               write(5,*)
            elseif(prlab(ii)(1:4).eq.'V   ') then
               write(5,*)
               write(5,119) noset(1:ipos-2),ttime
 119           format(' velocities (vx,vy,vz) for set ',A,
     &             ' and time ',e14.7)
               write(5,*)
            endif
!
!           printing the data
!
            do iset=1,nset
               if(set(iset).eq.prset(ii)) exit
            enddo
            do jj=0,3
               rftot(jj)=0.d0
            enddo
            do jj=istartset(iset),iendset(iset)
               if(ialset(jj).lt.0) cycle
               if(jj.eq.iendset(iset)) then
                  node=ialset(jj)
                  call printoutnode(prlab,v,t1,fn,ithermal,ii,node,
     &              rftot,trab,inotr,ntrans,co,mi)
               elseif(ialset(jj+1).gt.0) then
                  node=ialset(jj)
                  call printoutnode(prlab,v,t1,fn,ithermal,ii,node,
     &              rftot,trab,inotr,ntrans,co,mi)
               else
                  do node=ialset(jj-1)-ialset(jj+1),ialset(jj),
     &                 -ialset(jj+1)
                  call printoutnode(prlab,v,t1,fn,ithermal,ii,node,
     &              rftot,trab,inotr,ntrans,co,mi)
                  enddo
               endif
            enddo
!
!           writing total values to file
!
            if((prlab(ii)(1:5).eq.'RF  O').or.
     &           (prlab(ii)(1:5).eq.'RF  T')) then
               write(5,*)
               write(5,104) noset(1:ipos-2),ttime
 104           format(' total force (fx,fy,fz) for set ',A,
     &                 ' and time ',e14.7)
               write(5,*)
               write(5,'(6x,1p,3(1x,e11.4))') rftot(1),rftot(2),rftot(3)
            elseif((prlab(ii)(1:5).eq.'RFL O').or.
     &              (prlab(ii)(1:5).eq.'RFL T')) then
               write(5,*)
               write(5,105)noset(1:ipos-2),ttime
 105           format(' total heat generation for set ',A,
     &                ' and time ',e14.7)
               write(5,*)
               write(5,'(6x,1p,1x,e11.4)') rftot(0)
            endif
!
!        integration point values
!
         elseif((prlab(ii)(1:4).eq.'S   ').or.
     &          (prlab(ii)(1:4).eq.'E   ').or.
     &          (prlab(ii)(1:4).eq.'PEEQ').or.
     &          (prlab(ii)(1:4).eq.'ENER').or.
     &          (prlab(ii)(1:4).eq.'SDV ').or.
     &          (prlab(ii)(1:4).eq.'HFL ')) then
!
            ipos=index(prset(ii),' ')
            elset='                    '
            elset(1:ipos-1)=prset(ii)(1:ipos-1)
!
            limit=1
!
            do l=1,limit
!
!              printing the header
!
               if(prlab(ii)(1:4).eq.'S   ') then
                  write(5,*)
                  write(5,106) elset(1:ipos-2),ttime
 106              format(' stresses (elem, integ.pnt.,sxx,syy,szz,sxy,sx
     &z,syz) for set ',A,' and time ',e14.7)
                  write(5,*)
               elseif(prlab(ii)(1:4).eq.'E   ') then
                  write(5,*)
                  write(5,107) elset(1:ipos-2),ttime
 107              format(' strains (elem, integ.pnt.,exx,eyy,ezz,exy,exz
     &,eyz) forset ',A,' and time ',e14.7)
                  write(5,*)
               elseif(prlab(ii)(1:4).eq.'PEEQ') then
                  write(5,*)
                  write(5,108) elset(1:ipos-2),ttime
 108              format(' equivalent plastic strain (elem, integ.pnt.,p 
     &e)for set ',A,' and time ',e14.7)
                  write(5,*)
               elseif(prlab(ii)(1:4).eq.'ENER') then
                  write(5,*)
                  write(5,109) elset(1:ipos-2),ttime
 109              format(' internal energy density (elem, integ.pnt.,energy) for 
     &set ',A,' and time ',e14.7)
                  write(5,*)
               elseif(prlab(ii)(1:4).eq.'SDV ') then
                  write(5,*)
                  write(5,111) elset(1:ipos-2),ttime
 111              format
     &           (' internal state variables (elem, integ.pnt.,values) f
     &or set ',A,' and time ',e14.7)
                  write(5,*)
               elseif(prlab(ii)(1:4).eq.'HFL ') then
                  write(5,*)
                  write(5,112) elset(1:ipos-2),ttime
 112              format(' heat flux (elem, integ.pnt.,qx,qy,qz) for set 
     & ',A,' and time ',e14.7)
                  write(5,*)
               endif
!
!           printing the data
!
               do iset=1,nset
                  if(set(iset).eq.prset(ii)) exit
               enddo
               do jj=istartset(iset),iendset(iset)
                  if(ialset(jj).lt.0) cycle
                  if(jj.eq.iendset(iset)) then
                     nelem=ialset(jj)
                     call printoutint(prlab,ipkon,lakon,stx,eme,xstate,
     &                    ener,mi(1),nstate_,l,lb,ii,nelem,qfx,
     &                    orab,ielorien,norien,co,kon)
                  elseif(ialset(jj+1).gt.0) then
                     nelem=ialset(jj)
                     call printoutint(prlab,ipkon,lakon,stx,eme,xstate,
     &                    ener,mi(1),nstate_,l,lb,ii,nelem,qfx,orab,
     &                    ielorien,norien,co,kon)
                  else
                     do nelem=ialset(jj-1)-ialset(jj+1),ialset(jj),
     &                    -ialset(jj+1)
                        call printoutint(prlab,ipkon,lakon,stx,eme,
     &                       xstate,ener,mi(1),nstate_,l,lb,ii,nelem,
     &                       qfx,orab,ielorien,norien,co,kon)
                     enddo
                  endif
               enddo
!
            enddo
!
!        whole element values
!     
         elseif((prlab(ii)(1:4).eq.'ELSE').or.
     &           (prlab(ii)(1:4).eq.'ELKE').or.
     &           (prlab(ii)(1:4).eq.'EVOL').or.
     &           (prlab(ii)(1:4).eq.'CSTR').or.
     &           (prlab(ii)(1:4).eq.'CDIS').or.
     &           (prlab(ii)(1:4).eq.'CELS')) then
!     
                 ipos=index(prset(ii),' ')
                 elset='                    '
                 elset(1:ipos-1)=prset(ii)(1:ipos-1)
!     
!     printing the header
!     
            if((prlab(ii)(1:5).eq.'ELSE ').or.
     &                (prlab(ii)(1:5).eq.'ELSET')) then
               write(5,*)
               write(5,113) elset(1:ipos-2),ttime
 113           format(' internal energy (element, energy) for set ',A,
     &              ' and time ',e14.7)
               write(5,*)
            elseif((prlab(ii)(1:5).eq.'ELKE ').or.
     &              (prlab(ii)(1:5).eq.'ELKET')) then
               write(5,*)
               write(5,110) elset(1:ipos-2),ttime
 110           format(' kinetic energy (elem, energy) for set '
     &              ,A,' and time ',e14.7)
               write(5,*)
            elseif((prlab(ii)(1:5).eq.'EVOL ').or.
     &             (prlab(ii)(1:5).eq.'EVOLT')) then
               write(5,*)
               write(5,114) elset(1:ipos-2),ttime
 114           format(' volume (element, volume) for set ',A,
     &                ' and time ',e14.7)
               write(5,*)
            elseif((prlab(ii)(1:5).eq.'CSTR ').or.
     &              (prlab(ii)(1:5).eq.'CSTRT')) then
               write(5,*)
               write(5,122) ttime
 122           format(' contact stress (slave node,press,'
     &              'tang1,tang2) for all contact elements and time',
     &              e14.7)
               write(5,*)
            elseif((prlab(ii)(1:5).eq.'CDIS ').or.
     &              (prlab(ii)(1:5).eq.'CDIST')) then
               write(5,*)
               write(5,123) ttime
 123           format(' relative contact displacement (slave node,'
     &              'normal,tang1,tang2) for all contact elements and '
     &              'time',e14.7)
               write(5,*)
            elseif((prlab(ii)(1:5).eq.'CELS ').or.
     &              (prlab(ii)(1:5).eq.'CELST')) then
               write(5,*)
               write(5,124) ttime
 124           format(' contact print energy (slave node,energy) for'  
     &              'all contact elements and time',e14.7)
               write(5,*)
            endif
!     
!     printing the data
!     
            
            volumetot=0.d0
            energytot=0.d0
            enerkintot=0.d0
            
            if ((prlab(ii)(1:4).eq.'CSTR').or.
     &           (prlab(ii)(1:4).eq.'CDIS').or.
     &           (prlab(ii)(1:4).eq.'CELS')) then
!     
               do jj=ne,1,-1
                  if((lakon(jj)(2:2).ne.'S').or.
     &                 (lakon(jj)(7:7).ne.'C')) then
                     ne0=jj+1
                     exit
                  endif
               enddo
               do nelem=ne0,ne
                  read(lakon(nelem)(8:8),'(i1)') nope
                  nodes=kon(ipkon(nelem)+nope)
                  call printoutelem(prlab,ipkon,lakon,kon,co,
     &                 ener,mi(1),ii,nelem,energytot,volumetot,
     &                 enerkintot,ikin,ne,stx,nodes)
               enddo
            else
               do iset=1,nset
                  if(set(iset).eq.prset(ii)) exit
               enddo
               do jj=istartset(iset),iendset(iset)
                  if(ialset(jj).lt.0) cycle
                  if(jj.eq.iendset(iset)) then
                     nelem=ialset(jj)
                     call printoutelem(prlab,ipkon,lakon,kon,co,
     &                    ener,mi(1),ii,nelem,energytot,volumetot,
     &                    enerkintot,ikin,ne,stx,nodes)
                  elseif(ialset(jj+1).gt.0) then
                     nelem=ialset(jj)
                     call printoutelem(prlab,ipkon,lakon,kon,co,
     &                    ener,mi(1),ii,nelem,energytot,volumetot,
     &                    enerkintot,ikin,ne,stx,nodes)
                  else
                     do nelem=ialset(jj-1)-ialset(jj+1),ialset(jj),
     &                    -ialset(jj+1)
                        call printoutelem(prlab,ipkon,lakon,kon,co,
     &                       ener,mi(1),ii,nelem,energytot,volumetot,
     &                    enerkintot,ikin,ne,stx,nodes)
                     enddo
                  endif
               enddo
            endif
!     
!     writing total values to file
!     
            if((prlab(ii)(1:5).eq.'ELSEO').or.
     &           (prlab(ii)(1:5).eq.'ELSET')) then
               write(5,*)
               write(5,116) elset(1:ipos-2),ttime
 116           format(' total internal energy for set ',A,' and time ',
     &              e14.7)
               write(5,*)
               write(5,'(6x,1p,1x,e11.4)') energytot
            elseif((prlab(ii)(1:5).eq.'ELKEO').or.
     &              (prlab(ii)(1:5).eq.'ELKET')) then
               write(5,*)
               write(5,120) elset(1:ipos-2),ttime
 120           format(' total kinetic energy for set ',A,' and time ',
     &              e14.7)
               write(5,*)
               write(5,'(6x,1p,1x,e11.4)') enerkintot
            elseif((prlab(ii)(1:5).eq.'EVOLO').or.
     &              (prlab(ii)(1:5).eq.'EVOLT')) then
               write(5,*)
               write(5,121) elset(1:ipos-2),ttime
 121           format(' total volume for set ',A,' and time ',e14.7)
               write(5,*)
               write(5,'(6x,1p,1x,e11.4)') volumetot
            elseif((prlab(ii)(1:5).eq.'CELSO').or.
     &              (prlab(ii)(1:5).eq.'CELST')) then
               write(5,*)
               write(5,125) ttime
 125           format(' total contact spring energy for time ',e14.7)
               write(5,*)
               write(5,'(6x,1p,1x,e11.4)') energytot
!     
            endif
         endif
      enddo
!                     
      return
      end
