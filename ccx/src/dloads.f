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
      subroutine dloads(inpc,textpart,set,istartset,iendset,
     &  ialset,nset,nelemload,sideload,xload,nload,nload_,
     &  ielmat,ntmat_,iamload,
     &  amname,nam,lakon,ne,dload_flag,istep,istat,n,iline,ipol,
     &  inl,ipoinp,inp,cbody,ibody,xbody,nbody,nbody_,xbodyold,
     &  iperturb,physcon,nam_,namtot_,namta,amta,nmethod,ipoinpc)
!
!     reading the input deck: *DLOAD
!
      implicit none
!
      logical dload_flag
!
      character*1 inpc(*)
      character*8 lakon(*)
      character*20 sideload(*),label
      character*80 amname(*),amplitude
      character*81 set(*),elset,cbody(*)
      character*132 textpart(16)
!
      integer istartset(*),iendset(*),ialset(*),nelemload(2,*),
     &  ielmat(*),nset,nload,nload_,ntmat_,istep,istat,n,i,j,l,key,
     &  iamload(2,*),nam,iamplitude,ipos,ne,iline,ipol,iperturb,
     &  inl,ipoinp(2,*),inp(3,*),ibody(3,*),nbody,nbody_,nam_,namtot,
     &  namtot_,namta(3,*),idelay,nmethod,lc,isector,node,ipoinpc(0:*)
!
      real*8 xload(2,*),xbody(7,*),xmagnitude,dd,p1(3),p2(3),bodyf(3),
     &  xbodyold(7,*),physcon(3),amta(2,*)
!
      iamplitude=0
      idelay=0
      lc=1
      isector=0
!
      if(istep.lt.1) then
         write(*,*) '*ERROR in dloads: *DLOAD should only be used'
         write(*,*) '  within a STEP'
         stop
      endif
!
      do i=2,n
         if((textpart(i)(1:6).eq.'OP=NEW').and.(.not.dload_flag)) then
            do j=1,nload
               if(sideload(j)(1:1).eq.'P') then
                  xload(1,j)=0.d0
               endif
            enddo
            do j=1,nbody
               xbody(1,j)=0.d0
            enddo
         elseif(textpart(i)(1:10).eq.'AMPLITUDE=') then
            read(textpart(i)(11:90),'(a80)') amplitude
            do j=1,nam
               if(amname(j).eq.amplitude) then
                  iamplitude=j
                  exit
               endif
            enddo
            if(j.gt.nam) then
               write(*,*)'*ERROR in dloads: nonexistent amplitude'
               write(*,*) '  '
               call inputerror(inpc,ipoinpc,iline)
               stop
            endif
            iamplitude=j
         elseif(textpart(i)(1:10).eq.'TIMEDELAY=') THEN
            if(idelay.ne.0) then
               write(*,*) '*ERROR in dloads: the parameter TIME DELAY'
               write(*,*) '       is used twice in the same keyword'
               write(*,*) '       '
               call inputerror(inpc,ipoinpc,iline)
               stop
            else
               idelay=1
            endif
            nam=nam+1
            if(nam.gt.nam_) then
               write(*,*) '*ERROR in dloads: increase nam_'
               stop
            endif
            amname(nam)='
     &                                 '
            if(iamplitude.eq.0) then
               write(*,*) '*ERROR in dloads: time delay must be'
               write(*,*) '       preceded by the amplitude parameter'
               stop
            endif
            namta(3,nam)=isign(iamplitude,namta(3,iamplitude))
            iamplitude=nam
            if(nam.eq.1) then
               namtot=0
            else
               namtot=namta(2,nam-1)
            endif
            namtot=namtot+1
            if(namtot.gt.namtot_) then
               write(*,*) '*ERROR dloads: increase namtot_'
               stop
            endif
            namta(1,nam)=namtot
            namta(2,nam)=namtot
            read(textpart(i)(11:30),'(f20.0)',iostat=istat) 
     &           amta(1,namtot)
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         elseif(textpart(i)(1:9).eq.'LOADCASE=') then
            read(textpart(i)(10:19),'(i10)',iostat=istat) lc
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
            if(nmethod.ne.5) then
               write(*,*) '*ERROR in dloads: the parameter LOAD CASE'
               write(*,*) '       is only allowed in STEADY STATE'
               write(*,*) '       DYNAMICS calculations'
               stop
            endif
         elseif(textpart(i)(1:7).eq.'SECTOR=') then
            read(textpart(i)(8:17),'(i10)',iostat=istat) isector
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
            if((nmethod.le.3).or.(iperturb.gt.1)) then
               write(*,*) '*ERROR in dloads: the parameter SECTOR'
               write(*,*) '       is only allowed in MODAL DYNAMICS or'
               write(*,*) '       STEADY STATE DYNAMICS calculations'
               stop
            endif
            isector=isector-1
         endif
      enddo
!
      do
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((istat.lt.0).or.(key.eq.1)) return
!
         read(textpart(2)(1:20),'(a20)',iostat=istat) label
         if(label(3:4).ne.'NP') then
            read(textpart(3)(1:20),'(f20.0)',iostat=istat) xmagnitude
         else
            read(textpart(3)(1:10),'(i10)',iostat=istat) node
         endif
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         if(label(1:7).eq.'CENTRIF') then
            do i=1,3
               read(textpart(i+3)(1:20),'(f20.0)',iostat=istat) p1(i)
               if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
            enddo
            do i=1,3
               read(textpart(i+6)(1:20),'(f20.0)',iostat=istat) p2(i)
               if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
            enddo
            dd=dsqrt(p2(1)**2+p2(2)**2+p2(3)**2)
            do i=1,3
               p2(i)=p2(i)/dd
            enddo
         elseif(label(1:4).eq.'GRAV') then
            do i=1,3
               read(textpart(i+3)(1:20),'(f20.0)',iostat=istat) bodyf(i)
               if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
            enddo
         elseif(label(1:6).eq.'NEWTON') then
            if(iperturb.le.1) then
               write(*,*) '*ERROR in dloads: NEWTON gravity force'
               write(*,*) '       can only be used in a nonlinear'
               write(*,*) '       procedure'
               stop
            endif
            if(physcon(3).le.0.d0) then
               write(*,*) '*ERROR in dloads: NEWTON gravity force'
               write(*,*) '       requires the definition of a'
               write(*,*) '       positive gravity constant with'
               write(*,*) '       a *PHYSICAL CONSTANTS card'
               stop
            endif
         elseif(((label(1:2).ne.'P1').and.(label(1:2).ne.'P2').and.
     &           (label(1:2).ne.'P3').and.(label(1:2).ne.'P4').and.
     &           (label(1:2).ne.'P5').and.(label(1:2).ne.'P6').and.
     &           (label(1:2).ne.'P ')).or.
     &          ((label(3:4).ne.'  ').and.(label(3:4).ne.'NU').and.
     &           (label(3:4).ne.'NP'))) then
            call inputerror(inpc,ipoinpc,iline)
         endif
!
         read(textpart(1)(1:10),'(i10)',iostat=istat) l
         if(istat.eq.0) then
            if(l.gt.ne) then
               write(*,*) '*ERROR in dloads: element ',l
               write(*,*) '       is not defined'
               stop
            endif
            if((label(1:7).eq.'CENTRIF').or.(label(1:4).eq.'GRAV').or.
     &         (label(1:6).eq.'NEWTON')) then
               elset(1:80)=textpart(1)(1:80)
               elset(81:81)=' '
               call bodyadd(cbody,ibody,xbody,nbody,nbody_,elset,label,
     &           iamplitude,xmagnitude,p1,p2,bodyf,xbodyold,lc)
            else
               if((lakon(l)(1:2).eq.'CP').or.
     &              (lakon(l)(2:2).eq.'A').or.
     &              (lakon(l)(7:7).eq.'E').or.
     &              (lakon(l)(7:7).eq.'S').or.
     &              (lakon(l)(7:7).eq.'A')) then
                  if(label(1:2).eq.'P1') then
                     label(1:2)='P3'
                  elseif(label(1:2).eq.'P2') then
                     label(1:2)='P4'
                  elseif(label(1:2).eq.'P3') then
                     label(1:2)='P5'
                  elseif(label(1:2).eq.'P4') then
                     label(1:2)='P6'
                  endif
               elseif((lakon(l)(1:1).eq.'B').or.
     &                (lakon(l)(7:7).eq.'B')) then
                  if(label(1:2).eq.'P2') label(1:2)='P5'
               elseif((lakon(l)(1:1).eq.'S').or.
     &                (lakon(l)(7:7).eq.'L')) then
                  label(1:2)='P1'
               endif
               if(lc.ne.1) l=l+ne
               if(label(3:4).ne.'NP') then
                  call loadadd(l,label,xmagnitude,nelemload,sideload,
     &                 xload,nload,nload_,iamload,iamplitude,
     &                 nam,isector)
               else
                  call loadaddp(l,label,nelemload,sideload,
     &                 xload,nload,nload_,iamload,iamplitude,
     &                 nam,node)
               endif
            endif
         else
            read(textpart(1)(1:80),'(a80)',iostat=istat) elset
            elset(81:81)=' '
            ipos=index(elset,' ')
            elset(ipos:ipos)='E'
            do i=1,nset
               if(set(i).eq.elset) exit
            enddo
            if(i.gt.nset) then
               elset(ipos:ipos)=' '
               write(*,*) '*ERROR in dloads: element set ',elset
               write(*,*) '       has not yet been defined. '
               call inputerror(inpc,ipoinpc,iline)
               stop
            endif
!
            if((label(1:7).eq.'CENTRIF').or.(label(1:4).eq.'GRAV').or.
     &         (label(1:6).eq.'NEWTON')) then
               call bodyadd(cbody,ibody,xbody,nbody,nbody_,elset,label,
     &           iamplitude,xmagnitude,p1,p2,bodyf,xbodyold,lc)
            else
               l=ialset(istartset(i))
               if((lakon(l)(1:2).eq.'CP').or.
     &              (lakon(l)(2:2).eq.'A').or.
     &              (lakon(l)(7:7).eq.'E').or.
     &              (lakon(l)(7:7).eq.'S').or.
     &              (lakon(l)(7:7).eq.'A')) then
                  if(label(1:2).eq.'P1') then
                     label(1:2)='P3'
                  elseif(label(1:2).eq.'P2') then
                     label(1:2)='P4'
                  elseif(label(1:2).eq.'P3') then
                     label(1:2)='P5'
                  elseif(label(1:2).eq.'P4') then
                     label(1:2)='P6'
                  endif
               elseif((lakon(l)(1:1).eq.'B').or.
     &                 (lakon(l)(7:7).eq.'B')) then
                  if(label(1:2).eq.'P2') label(1:2)='P5'
               elseif((lakon(l)(1:1).eq.'S').or.
     &                 (lakon(l)(7:7).eq.'L')) then
                  label(1:2)='P1'
               endif
!
               do j=istartset(i),iendset(i)
                  if(ialset(j).gt.0) then
                     l=ialset(j)
                     if(lc.ne.1) l=l+ne
                     if(label(3:4).ne.'NP') then
                        call loadadd(l,label,xmagnitude,nelemload,
     &                       sideload,xload,nload,nload_,iamload,
     &                       iamplitude,nam,isector)
                     else
                        call loadaddp(l,label,nelemload,
     &                       sideload,xload,nload,nload_,iamload,
     &                       iamplitude,nam,node)
                     endif
                  else
                     l=ialset(j-2)
                     do
                        l=l-ialset(j)
                        if(l.ge.ialset(j-1)) exit
                        if(lc.ne.1) l=l+ne
                        if(label(3:4).ne.'NP') then
                           call loadadd(l,label,xmagnitude,nelemload,
     &                          sideload,xload,nload,nload_,
     &                          iamload,iamplitude,nam,isector)
                        else
                           call loadaddp(l,label,nelemload,
     &                          sideload,xload,nload,nload_,
     &                          iamload,iamplitude,nam,node)
                        endif
                     enddo
                  endif
               enddo
            endif
         endif
      enddo
!
      return
      end

