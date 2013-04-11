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
      subroutine noelfiles(inpc,textpart,jout,filab,nmethod,
     &  nodefile_flag,elfile_flag,ifile_output,nener,ithermal,
     &  istep,istat,n,iline,ipol,inl,ipoinp,inp,out3d,nlabel,
     &  amname,nam,itpamp,idrct,ipoinpc,cfd,contactfile_flag,
     &  set,nset,xmodal)
!
!     reading the *NODE FILE, *EL FILE and *CONTACT FILE cards in the 
!     input deck
!
      implicit none
!
      logical nodefile_flag,elfile_flag,out3d,sectionforces,
     &  contactfile_flag
!
      character*1 nodesys,elemsys,inpc(*)
      character*80 amname(*),timepointsname
      character*81 noset,set(*)
      character*87 filab(*)
      character*132 textpart(16)
!
      integer istep,istat,n,key,ii,jout(2),joutl,nmethod,nener,ithermal,
     &  iline,ipol,inl,ipoinp(2,*),inp(3,*),j,nlabel,nam,itpamp,i,
     &  idrct,ipoinpc(0:*),cfd,ifile_output,ipos,nset
!
      real*8 xmodal(*)
!
      save sectionforces
!
!     default ist the global system
!
      nodesys='G'
      elemsys='G'
!
      ipos=0
            noset='
     &                           '
!
      if(istep.lt.1) then
         write(*,*) '*ERROR in noelfiles: *NODE FILE, *EL FILE'
         write(*,*) '       *CONTACT FILE'
         write(*,*) '       should only be used within a *STEP' 
         write(*,*) '       definition'
         stop
      endif
!
      if(ifile_output.eq.1) then
!
!        reset the nodal print requests
!
         if(ifile_output.eq.1) then
            filab(1)(1:4)='    '
            filab(2)(1:4)='    '
            filab(5)(1:4)='    '
            do j=10,12
               filab(j)(1:4)='    '
            enddo
            do j=14,17
               filab(j)(1:4)='    '
            enddo
            filab(19)(1:4)='    '
            do j=21,25
               filab(j)(1:4)='    '
            enddo
!
            filab(1)(6:87)=' '
            filab(2)(6:87)=' '
            filab(5)(6:87)=' '
            do j=10,12
               filab(j)(6:87)=' '
            enddo
            do j=14,17
               filab(j)(6:87)=' '
            enddo
            filab(19)(6:87)=' '
            do j=21,25
               filab(j)(6:87)=' '
            enddo
         endif
      elseif(ifile_output.eq.2) then
!
!        reset the element print requests
!
         if(.not.elfile_flag) then
            filab(3)(1:4)='    '
            filab(4)(1:4)='    '
            do j=6,9
               filab(j)(1:4)='    '
            enddo
            filab(13)(1:4)='    '
            filab(18)(1:4)='    '
            filab(20)(1:4)='    '
!
            filab(3)(6:87)=' '
            filab(4)(6:87)=' '
            do j=6,9
               filab(j)(6:87)=' '
            enddo
            filab(13)(6:87)=' '
            filab(18)(6:87)=' '
            filab(20)(6:87)=' '
!
            sectionforces=.false.
         endif
      elseif(ifile_output.eq.3)then
!
!     reset the contact print requests
!         
         if(.not.contactfile_flag) then
            filab(26)(1:4)='    '
            filab(26)(6:87)='    '
         endif
      endif
!
      do ii=2,n
        if(textpart(ii)(1:10).eq.'FREQUENCY=') then
           read(textpart(ii)(11:20),'(i10)',iostat=istat) joutl
           if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
           if(joutl.eq.0) then
              do
                 call getnewline(inpc,textpart,istat,n,key,iline,ipol,
     &                inl,ipoinp,inp,ipoinpc)
                 if((key.eq.1).or.(istat.lt.0)) return
              enddo
           endif
           if(joutl.gt.0) then
              jout(1)=joutl
              itpamp=0
           endif
        elseif(textpart(ii)(1:11).eq.'FREQUENCYF=') then
           read(textpart(ii)(12:21),'(i10)',iostat=istat) joutl
           if(istat.gt.0) call inputerror(inpc,ipoinpc,iline)
           if(joutl.eq.0) then
              do
                 call getnewline(inpc,textpart,istat,n,key,iline,ipol,
     &                inl,ipoinp,inp,ipoinpc)
                 if((key.eq.1).or.(istat.lt.0)) return
              enddo
           endif
           if(joutl.gt.0) then
              jout(2)=joutl
              itpamp=0
           endif
        elseif(textpart(ii)(1:10).eq.'GLOBAL=YES') then
           nodesys='G'
           elemsys='G'
        elseif(textpart(ii)(1:9).eq.'GLOBAL=NO') then
           nodesys='L'
           elemsys='L'
        elseif(textpart(ii)(1:9).eq.'OUTPUT=3D') then
           if(istep.eq.1) then
              out3d=.true.
              do j=1,nlabel
                 filab(j)(5:5)='E'
              enddo
           elseif(.not.out3d) then
              write(*,*) '*WARNING in noelfiles: OUTPUT=3D has no'
              write(*,*) '         effect in all but the first step'
           endif
        elseif(textpart(ii)(1:13).eq.'SECTIONFORCES') then
           if(out3d) then
              write(*,*) '*WARNING in noelfiles: SECTION FORCES cannot'
              write(*,*) '         be selected for 3D output'
           else
              filab(3)(5:5)='M'
           endif
        elseif(textpart(ii)(1:11).eq.'TIMEPOINTS=') then
           timepointsname=textpart(ii)(12:91)
           do i=1,nam
              if(amname(i).eq.timepointsname) then
                 itpamp=i
                 exit
              endif
           enddo
           if(i.gt.nam) then
              write(*,*) '*ERROR in noelfiles: time'
              write(*,*) '       points definition',
     &               timepointsname,' is unknown'
              stop
           endif
           if(idrct.eq.1) then
              write(*,*) '*ERROR in noelfiles: the DIRECT option'
              write(*,*) '       collides with a TIME POINTS '
              write(*,*) '       specification'
              stop
           endif
           jout(1)=1
           jout(2)=1
        elseif(textpart(ii)(1:5).eq.'NSET=') then
            noset=textpart(ii)(6:85)
            noset(81:81)=' '
            ipos=index(noset,' ')
            noset(ipos:ipos)='N'
         else
            write(*,*) 
     &        '*WARNING in noelfiles: parameter not recognized:'
            write(*,*) '         ',
     &                 textpart(ii)(1:index(textpart(ii),' ')-1)
            call inputwarning(inpc,ipoinpc,iline)
        endif
      enddo
!
!     check the existence of the node set (if any was specified)
!
      if(ipos.ne.0) then
         do i=1,nset
            if(set(i).eq.noset) exit
         enddo
         if(i.gt.nset) then
            noset(ipos:ipos)=' '
            write(*,*) '*ERROR in transforms: node set ',noset
            write(*,*) '  has not yet been defined.'
            stop
         endif
      endif
!
      do
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((key.eq.1).or.(istat.lt.0)) return
         do ii=1,n
            if(textpart(ii)(1:4).eq.'U   ') then
               filab(1)(1:4)='U   '
               filab(1)(6:6)=nodesys
               filab(1)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'NT  ') then
               filab(2)(1:4)='NT  '
               filab(2)(6:6)=nodesys
               filab(2)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'S   ') then
               filab(3)(1:4)='S   '
               filab(3)(6:6)=elemsys
               filab(3)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'E   ') then
               filab(4)(1:4)='E   '
               filab(4)(6:6)=elemsys
               filab(4)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'RF  ') then
               filab(5)(1:4)='RF  '
               filab(5)(6:6)=nodesys
               filab(5)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'PEEQ') then
               if((nmethod.eq.2).or.(nmethod.eq.3)) then
                  write(*,*) '*WARNING in noelfiles: selection of PEEQ'
                  write(*,*) '         does not make sense for a'
                  write(*,*) '         frequency or bucking calculation'
               else
                  filab(6)(1:4)='PEEQ'
                  filab(6)(6:6)=elemsys
                  filab(6)(7:87)=noset
               endif
            elseif((textpart(ii)(1:4).eq.'CEEQ').or.
     &             (textpart(ii)(1:2).eq.'CE').or.
     &             (textpart(ii)(1:2).eq.'PE')) then
               textpart(ii)(1:4)='PEEQ'
               if((nmethod.eq.2).or.(nmethod.eq.3)) then
                  write(*,*) 
     &            '*WARNING in noelfiles: selection of CEEQ or CE or PE'
                  write(*,*) '         does not make sense for a'
                  write(*,*) '         frequency or bucking calculation'
               else
                  write(*,*) 
     &            '*WARNING in elprints: selection of CEEQ or CE or PE'
                  write(*,*) '         is converted into PEEQ; no distin
     &ction'
                  write(*,*) 
     &             '        is made between PEEQ, CEEQ, CE and PE'
                  filab(6)(1:4)='PEEQ'
                  filab(6)(6:6)=elemsys
                  filab(6)(7:87)=noset
               endif
            elseif(textpart(ii)(1:4).eq.'ENER') then
               filab(7)(1:4)='ENER'
               filab(7)(6:6)=elemsys
               filab(7)(7:87)=noset
              nener=1
            elseif(textpart(ii)(1:4).eq.'SDV ') then
               if((nmethod.eq.2).or.(nmethod.eq.3)) then
                  write(*,*) '*WARNING in noelfiles: selection of SDV'
                  write(*,*) '         does not make sense for a'
                  write(*,*) '         frequency or bucking calculation'
               else
                  filab(8)(1:4)='SDV '
                  filab(8)(6:6)=elemsys
                  filab(8)(7:87)=noset
               endif
            elseif(textpart(ii)(1:4).eq.'HFL ') then
               if(ithermal.le.1) then
                  write(*,*) '*WARNING in noelfiles: HFL only makes '
                  write(*,*) '         sense for heat transfer '
                  write(*,*) '          calculations'
               else
                  filab(9)(1:4)='HFL '
c                  if(.not.out3d) filab(9)(5:5)='I'
                  filab(9)(6:6)=elemsys
                  filab(9)(7:87)=noset
               endif
            elseif(textpart(ii)(1:4).eq.'RFL ') then
               if(ithermal.le.1) then
                  write(*,*) '*WARNING in noelfiles: RFL only makes '
                  write(*,*) '         sense for heat transfer '
                  write(*,*) '          calculations'
               else
                  filab(10)(1:4)='RFL '
                  filab(10)(6:6)=nodesys
                  filab(10)(7:87)=noset
               endif
            elseif(textpart(ii)(1:4).eq.'PU  ') then
               if((nmethod.ne.2).and.(nmethod.ne.5)) then
                  write(*,*) '*WARNING in noelfiles: PU only makes'
                  write(*,*) '         sense for frequency and steady'
                  write(*,*) '         state dynamics calculations'
               elseif((nmethod.eq.5).and.(xmodal(7).gt.0.d0)) then
                  write(*,*) '*WARNING in noelfiles: PU does not make'
                  write(*,*) '         sense for nonharmonic periodic'
                  write(*,*) '         excitations; use U instead'
               else
                  filab(11)(1:4)='PU  '
                  filab(11)(7:87)=noset
               endif
            elseif(textpart(ii)(1:4).eq.'PNT ') then
               filab(12)(1:4)='PNT '
               filab(12)(7:87)=noset
            elseif(textpart(ii)(1:3).eq.'ZZS') then
               filab(13)(1:4)='ZZS '
               filab(13)(6:6)=elemsys
               filab(13)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'TT  ') then
               filab(14)(1:4)='TT  '
               filab(14)(6:6)=nodesys
               filab(14)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'MF  ') then
               filab(15)(1:4)='MF  '
               filab(15)(6:6)=nodesys
               filab(15)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'PT  ') then
               filab(16)(1:4)='PT  '
               filab(16)(6:6)=nodesys
               filab(16)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'TS  ') then
               filab(17)(1:4)='TS  '
               filab(17)(6:6)=nodesys
               filab(17)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'PHS ') then
               if((nmethod.ne.2).and.(nmethod.ne.5)) then
                  write(*,*) '*WARNING in noelfiles: PHS only makes'
                  write(*,*) '         sense for frequency and steady'
                  write(*,*) '         state dynamics calculations'
               else
                  filab(18)(1:4)='PHS '
                  filab(18)(6:6)=elemsys
                  filab(18)(7:87)=noset
            endif
            elseif(textpart(ii)(1:4).eq.'MAXU') then
               if(nmethod.ne.2) then
                  write(*,*) '*WARNING in noelfiles: MAXU only makes'
                  write(*,*) '         sense for frequency calculations'
               else
                  filab(19)(1:4)='MAXU'
                  filab(19)(6:6)=nodesys
                  filab(19)(7:87)=noset
               endif
            elseif(textpart(ii)(1:4).eq.'MAXS') then
               if(nmethod.ne.2) then
                  write(*,*) '*WARNING in noelfiles: MAXS only makes'
                  write(*,*) '         sense for frequency calculations'
               else
                  filab(20)(1:4)='MAXS'
                  filab(20)(6:6)=elemsys
                  filab(20)(7:87)=noset
               endif
            elseif(textpart(ii)(1:4).eq.'V   ') then
                if((nmethod.eq.1).or.(nmethod.eq.4)) then
                   filab(21)(1:4)='V   '
                   filab(21)(6:6)=nodesys
                   filab(21)(7:87)=noset
                else
                   write(*,*) '*WARNING in noelfiles: V only available'
                   write(*,*) '         for dynamic calculations and'
                   write(*,*) '         steady state fluid calculations'
                endif
            elseif(textpart(ii)(1:4).eq.'PS  ') then
c               if(cfd.eq.0) then
c                  write(*,*) '*WARNING in noelfiles: PS only makes'
c                  write(*,*) '         sense for 3D fluid calculations'
c               else
                  filab(22)(1:4)='PS  '
                  filab(22)(6:6)=nodesys
                  filab(22)(7:87)=noset
c               endif
            elseif(textpart(ii)(1:4).eq.'MACH') then
               if(cfd.eq.0) then
                  write(*,*) '*WARNING in noelfiles: MACH only makes'
                  write(*,*) '         sense for 3D fluid calculations'
               else
                  filab(23)(1:4)='MACH'
                  filab(23)(6:6)=nodesys
                  filab(23)(7:87)=noset
               endif
            elseif(textpart(ii)(1:4).eq.'CP  ') then
               if(cfd.eq.0) then
                  write(*,*) '*WARNING in noelfiles: CP only makes'
                  write(*,*) '         sense for 3D fluid calculations'
               else
                  filab(24)(1:4)='CP  '
                  filab(24)(6:6)=nodesys
                  filab(24)(7:87)=noset
               endif
            elseif(textpart(ii)(1:4).eq.'TURB') then
               if(cfd.eq.0) then
                  write(*,*) '*WARNING in noelfiles: TURB only makes'
                  write(*,*) '         sense for 3D fluid calculations'
               else
                  filab(25)(1:4)='TURB'
                  filab(25)(6:6)=nodesys
                  filab(25)(7:87)=noset
               endif
            elseif((textpart(ii)(1:4).eq.'CSTR').or.
     &             (textpart(ii)(1:4).eq.'CDIS')) then
               filab(26)(1:4)='CONT'
               filab(26)(6:6)=nodesys
               filab(26)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'CELS') then
               filab(27)(1:4)='CELS'
               filab(27)(6:6)=nodesys
               filab(27)(7:87)=noset
               nener=1
            elseif(textpart(ii)(1:4).eq.'DEPT') then
                  filab(28)(1:4)='DEPT'
                  filab(28)(6:6)=nodesys
                  filab(28)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'HCRI') then
                  filab(29)(1:4)='HCRI'
                  filab(29)(6:6)=nodesys
                  filab(29)(7:87)=noset
            elseif(textpart(ii)(1:4).eq.'MAXE') then
               if(nmethod.ne.2) then
                  write(*,*) '*WARNING in noelfiles: MAXE only makes'
                  write(*,*) '         sense for frequency calculations'
               else
                  filab(30)(1:4)='MAXE'
                  filab(30)(6:6)=elemsys
                  filab(30)(7:87)=noset
               endif
            else
               write(*,*) '*WARNING in noelfiles: label not applicable'
               write(*,*) '         or unknown; '
               call inputwarning(inpc,ipoinpc,iline)
            endif
         enddo
      enddo
!
      return
      end






