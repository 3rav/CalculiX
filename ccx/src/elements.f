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
      subroutine elements(inpc,textpart,kon,ipkon,lakon,nkon,ne,ne_,
     &  set,istartset,iendset,ialset,nset,nset_,nalset,nalset_,mi,
     &  ixfree,iponor,xnor,istep,istat,n,iline,ipol,inl,ipoinp,inp,
     &  iaxial,ipoinpc,solid,cfd,network)
!
!     reading the input deck: *ELEMENT
!
      implicit none
!
      logical solid,network
!
      character*1 inpc(*)
      character*8 lakon(*),label
      character*81 set(*),elset
      character*132 textpart(16)
!
      integer kon(*),istartset(*),iendset(*),ialset(*),ne,ne_,nset,
     &  nset_,nalset,nalset_,istep,istat,n,key,i,ielset,js,k,nn,
     &  nteller,j,ipkon(*),nkon,nope,indexe,mi(2),ipos,indexy,ixfree,
     &  iponor(2,*),nopeexp,iline,ipol,inl,ipoinp(2,*),inp(3,*),
     &  iaxial,ipoinpc(0:*),cfd
!
      real*8 xnor(*)
!
      if(istep.gt.0) then
         write(*,*) '*ERROR in elements: *ELEMENT should be placed'
         write(*,*) '  before all step definitions'
         stop
      endif
!
      indexy=-1
      ielset=0
!
      label='        '
!
!     checking for set definition
!      
      loop: do i=2,n
         if(textpart(i)(1:6).eq.'ELSET=') then
            elset=textpart(i)(7:86)
            if(textpart(i)(87:87).ne.' ') then
               write(*,*) '*ERROR in elements: set name too long'
               write(*,*) '       (more than 80 characters)'
               write(*,*) '       set name:',textpart(i)(1:132)
               stop
            endif
            elset(81:81)=' '
            ipos=index(elset,' ')
            elset(ipos:ipos)='E'
            ielset=1
            do js=1,nset
               if(set(js).eq.elset) then
!
!                 existent set
!
                  if(iendset(js).eq.nalset) then
                     cycle loop
                  else
!
!                    rearranging set information towards the end
!
                     nn=iendset(js)-istartset(js)+1
                     if(nalset+nn.gt.nalset_) then
                        write(*,*)'*ERROR in elements: increase nalset_'
                        stop
                     endif
                     do k=1,nn
                        ialset(nalset+k)=ialset(istartset(js)+k-1)
                     enddo
                     do k=istartset(js),nalset
                        ialset(k)=ialset(k+nn)
                     enddo
                     do k=1,nset
                        if(istartset(k).gt.iendset(js)) then
                           istartset(k)=istartset(k)-nn
                           iendset(k)=iendset(k)-nn
                        endif
                     enddo
                     istartset(js)=nalset-nn+1
                     iendset(js)=nalset
                     cycle loop
                  endif
               endif
            enddo
!
!           new set
!
            nset=nset+1
            if(nset.gt.nset_) then
               write(*,*) '*ERROR in elements: increase nset_'
               stop
            endif
            js=nset
            istartset(js)=nalset+1
            iendset(js)=nalset
            set(js)=elset
            cycle
         elseif(textpart(i)(1:5).eq.'TYPE=') then
            read(textpart(i)(6:13),'(a8)') label
!
!           removing the ABAQUS label for heat transfer elements
!
            if(label(1:2).eq.'DC') then
               label(1:7)=label(2:8)
               label(8:8)=' '
            endif
!
!           full integration quadratic hexahedral element
!           (including such which are expanded into one)
!
            if((label.eq.'C3D20   ').or.
     &         (label.eq.'CPE8    ').or.
     &         (label.eq.'CPS8    ').or.
     &         (label.eq.'CAX8    ').or.
     &         (label.eq.'S8      ').or.
     &         (label.eq.'B32     ').or.
!
!           reduced integration quadratic hexahedral element
!           (including such which are expanded into one)
!
     &         (label.eq.'C3D20R  ').or.
     &         (label.eq.'C3D20RI ').or.
     &         (label.eq.'C3D8    ').or.
     &         (label.eq.'CPE8R   ').or.
     &         (label.eq.'CPS8R   ').or.
     &         (label.eq.'CAX8R   ').or.
     &         (label.eq.'S8R     ').or.
     &         (label.eq.'B32R    ').or.
!
!           reduced integration linear hexahedral element
!
     &         (label.eq.'C3D8R   ').or.
c    Bernhardi start
c
c           incompatible modes element
c
     &         (label.eq.'C3D8I   ').or.
c    Bernhardi end
!
!           quadratic tetrahedral element
!
     &         (label.eq.'C3D10   ').or.
!
!           linear tetrahedral element
!
     &         (label.eq.'C3D4    ').or.
!
!           quadratic wedge
!           (including such which are expanded into one)
!
     &         (label.eq.'C3D15   ').or.
     &         (label.eq.'CPE6    ').or.
     &         (label.eq.'CPS6    ').or.
     &         (label.eq.'CAX6    ').or.
     &         (label.eq.'S6      ').or.
!
!           linear wedge
!
     &         (label.eq.'C3D6    ').or.
!
!           gap element
!
     &         (label.eq.'GAPUNI  ').or.
!
!           spring element
!
     &         (label.eq.'SPRINGA ').or.
!
!           dashpot element
!
     &         (label.eq.'DASHPOTA'))
     &                then
               solid=.true.
!
!           3D fluid element
!
            elseif((label.eq.'F3D20   ').or.
     &             (label.eq.'F3D20R  ').or.
     &             (label.eq.'F3D8    ').or.
     &             (label.eq.'F3D8R   ').or.
     &             (label.eq.'F3D10   ').or.
     &             (label.eq.'F3D4    ').or.
     &             (label.eq.'F3D15   ').or.
     &             (label.eq.'F3D6R   ').or.
     &             (label.eq.'F3D6    ')) then
               cfd=1
!
!           network element
!
            elseif(label(1:1).eq.'D') then
               network=.true.
            else
               write(*,*) '*ERROR in elements:'
               write(*,*) label,' is an unknown element type'
               stop
            endif
!
            if(label(1:3).eq.'CAX') iaxial=180
!
         else
            write(*,*) 
     &        '*WARNING in elements: parameter not recognized:'
            write(*,*) '         ',
     &                 textpart(i)(1:index(textpart(i),' ')-1)
            call inputwarning(inpc,ipoinpc,iline)
         endif
      enddo loop
!
      if(label.eq.'        ') then
         write(*,*) '*ERROR in elements: element type is lacking'
         write(*,*) '       '
         call inputerror(inpc,ipoinpc,iline)
         stop
      endif
!
!     nope is the number of nodes per element as defined in the input
!     deck, nopeexp is the number of nodes per element after expansion
!     (only applicable to 1D and 2D elements such as beams, shells..)
!
c     Bernhardi start
      if(label(1:5).eq.'C3D8I') then
         nope=8
         nopeexp=11
      elseif(label(4:5).eq.'20') then
c     Bernhardi end
         nope=20
         nopeexp=20
      elseif((label(1:4).eq.'CPE8').or.(label(1:4).eq.'CPS8').or.
     &        (label(1:4).eq.'CAX8').or.(label(1:2).eq.'S8')) then
         nope=8
         nopeexp=28
      elseif((label(1:4).eq.'CPE6').or.(label(1:4).eq.'CPS6').or.
     &        (label(1:4).eq.'CAX6').or.(label(1:2).eq.'S6')) then
         nope=6
         nopeexp=21
      elseif(label(1:1).eq.'B') then
         nope=3
         nopeexp=23
      elseif(label(4:4).eq.'8') then
         nope=8
         nopeexp=8
      elseif(label(4:5).eq.'10') then
         nope=10
         nopeexp=10
      elseif(label(4:4).eq.'4') then
         nope=4
         nopeexp=4
      elseif(label(4:5).eq.'15') then
         nope=15
         nopeexp=15
      elseif(label(4:4).eq.'6') then
         nope=6
         nopeexp=6
      elseif(label(1:8).eq.'DASHPOTA') then
         label='EDSHPTA2'
         nope=2
         nopeexp=2
      elseif(label(1:1).eq.'D') then
         nope=3
         nopeexp=3
      elseif(label(1:1).eq.'G') then
         nope=2
         nopeexp=2
      elseif(label(1:7).eq.'SPRINGA') then
         label='ESPRNGA2'
         nope=2
         nopeexp=2
      endif
!
      do
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((istat.lt.0).or.(key.eq.1)) return
         read(textpart(1)(1:10),'(i10)',iostat=istat) i
         if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         if(i.gt.ne_) then
            write(*,*) '*ERROR in elements: increase ne_'
            stop
         endif
!
!        check whether element was already defined
!
         if(ipkon(i).ne.-1) then
            write(*,*) '*ERROR in elements: element',i
            write(*,*) '       is already defined'
            write(*,*) '       '
            call inputerror(inpc,ipoinpc,iline)
         endif
!            
!        new element
!
         ipkon(i)=nkon
         lakon(i)=label
         indexe=nkon
!
         nkon=nkon+nopeexp
!
         do j=2,n
            read(textpart(j)(1:10),'(i10)',iostat=istat) kon(indexe+j-1)
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
         enddo
         nteller=n-1
         if(nteller.lt.nope) then
            do
               call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &              ipoinp,inp,ipoinpc)
               if((istat.lt.0).or.(key.eq.1)) then
                  write(*,*) '*ERROR in elements: element definition'
                  write(*,*) '       incomplete for element ',i
                  stop
               endif
               if(nteller+n.gt.nope) n=nope-nteller
               do j=1,n
                  read(textpart(j)(1:10),'(i10)',iostat=istat) 
     &                  kon(indexe+nteller+j)
                  if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
               enddo
               nteller=nteller+n
               if(nteller.eq.nope) exit
            enddo
         endif
         ne=max(ne,i)
!
!        assigning element to set
!
         if(ielset.eq.1) then
            if(nalset+1.gt.nalset_) then
               write(*,*) '*ERROR in elements: increase nalset_'
               stop
            endif
            nalset=nalset+1
            ialset(nalset)=i
            iendset(js)=nalset
         endif
!
!        for plane stress, plane strain and axisymmetric elements:
!        define the normal
!
         if((label(1:2).eq.'CP').or.(label(1:2).eq.'CA')) then
            if(indexy.eq.-1) then
               indexy=ixfree
               xnor(indexy+1)=0.d0
               xnor(indexy+2)=0.d0
               xnor(indexy+3)=1.d0
               ixfree=ixfree+3
            endif
            do j=1,nope
               iponor(1,indexe+j)=indexy
            enddo
         endif
!
      enddo
!
      return
      end







