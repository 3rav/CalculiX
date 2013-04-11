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
      subroutine restartwrite(istepnew,nset,nload,nforc, nboun,nk,ne,
     &  nmpc,nalset,nmat,ntmat_,npmat_,norien,nam,nprint,mi,
     &  ntrans,ncs_,namtot_,ncmat_,mpcend,maxlenmpc,
     &  ne1d,ne2d,nflow,nlabel,iplas,
     &  nkon,ithermal,nmethod,iperturb,nstate_,nener,set,istartset,
     &  iendset,ialset,co,kon,ipkon,lakon,nodeboun,ndirboun,iamboun,
     &  xboun,ikboun,ilboun,ipompc,nodempc,coefmpc,labmpc,ikmpc,ilmpc,
     &  nodeforc,ndirforc,iamforc,xforc,ikforc,ilforc,nelemload,iamload,
     &  sideload,xload,elcon,nelcon,rhcon,nrhcon,
     &  alcon,nalcon,alzero,plicon,nplicon,plkcon,nplkcon,orname,orab,
     &  ielorien,trab,inotr,amname,amta,namta,t0,t1,iamt1,veold,
     &  ielmat,matname,prlab,prset,filab,vold,nodebounold,
     &  ndirbounold,xbounold,xforcold,xloadold,t1old,eme,
     &  iponor,xnor,knor,thickn,thicke,offset,iponoel,inoel,rig,
     &  shcon,nshcon,cocon,ncocon,ics,sti,
     &  ener,xstate,jobnamec,infree,nnn,prestr,iprestr,cbody, 
     &  ibody,xbody,nbody,xbodyold,ttime,qaold,cs,mcs,output,
     &  physcon,ctrl,typeboun,fmpc,tieset,ntie,tietol)
!
      implicit none
!
      logical op
!
      character*1 typeboun(*)
      character*3 output
      character*6 prlab(*)
      character*8 lakon(*)
      character*20 labmpc(*),sideload(*)
      character*80 orname(*),amname(*),matname(*)
      character*81 set(*),prset(*),tieset(3,*),cbody(*)
      character*87 filab(*)
      character*132 fnrstrt,jobnamec(*)
!
      integer nset,nload,nforc,nboun,nk,ne,nmpc,nalset,nmat,
     &  ntmat_,npmat_,norien,nam,nprint,mi(2),ntrans,ncs_,
     &  namtot_,ncmat_,mpcend,ne1d,ne2d,nflow,nlabel,iplas,nkon,
     &  ithermal,nmethod,iperturb(*),nstate_,istartset(*),iendset(*),
     &  ialset(*),kon(*),ipkon(*),nodeboun(*),ndirboun(*),iamboun(*),
     &  ikboun(*),ilboun(*),ipompc(*),nodempc(*),ikmpc(*),ilmpc(*),
     &  nodeforc(*),ndirforc(*),iamforc(*),ikforc(*),ilforc(*),
     &  nelemload(*),iamload(*),nelcon(*),
     &  nrhcon(*),nalcon(*),nplicon(*),nplkcon(*),ielorien(*),inotr(*),
     &  namta(*),iamt1(*),ielmat(*),nodebounold(*),ndirbounold(*),
     &  iponor(*),knor(*),iponoel(*),inoel(*),rig(*),
     &  nshcon(*),ncocon(*),ics(*),infree(*),nnn(*),i,ipos,
     &  nener,iprestr,istepnew,maxlenmpc,mcs,j,ntie,
     &  ibody(*),nbody,mt
!
      real*8 co(*),xboun(*),coefmpc(*),xforc(*),xload(*),elcon(*),
     &  rhcon(*),alcon(*),alzero(*),plicon(*),plkcon(*),orab(*),
     &  trab(*),amta(*),t0(*),t1(*),prestr(*),veold(*),tietol(2,*),
     &  vold(*),xbounold(*),xforcold(*),xloadold(*),t1old(*),eme(*),
     &  xnor(*),thickn(*),thicke(*),offset(*),
     &  shcon(*),cocon(*),sti(*),ener(*),xstate(*),
     &  qaold(2),cs(17,*),physcon(*),ctrl(*),
     &  ttime,fmpc(*),xbody(*),xbodyold(*)
!
      mt=mi(2)+1
!
      ipos=index(jobnamec(1),char(0))
      fnrstrt(1:ipos-1)=jobnamec(1)(1:ipos-1)
      fnrstrt(ipos:ipos+4)=".rout"
      do i=ipos+5,132
         fnrstrt(i:i)=' '
      enddo
!
!     check whether the restart file exists and is opened
!
      inquire(FILE=fnrstrt,OPENED=op,err=152)
!
      if(.not.op) then
         open(15,file=fnrstrt,ACCESS='SEQUENTIAL',FORM='UNFORMATTED',
     &      err=151)
      endif
!
      write(15)istepnew
!
!     set size
!
      write(15)nset
      write(15)nalset
!
!     load size
!
      write(15)nload
      write(15)nbody
      write(15)nforc
      write(15)nboun
      write(15)nflow
!
!     mesh size
!
      write(15)nk
      write(15)ne
      write(15)nkon
      write(15)(mi(i),i=1,2)
!
!     constraint size
!
      write(15)nmpc
      write(15)mpcend
      write(15)maxlenmpc
!
!     material size
!
      write(15)nmat
      write(15)ntmat_
      write(15)npmat_
      write(15)ncmat_
!
!     transformation size
!
      write(15)norien
      write(15)ntrans
!
!     amplitude size
!
      write(15)nam
      write(15)namtot_
!
!     print size
!
      write(15)nprint
      write(15)nlabel
!
!     tie size
!
      write(15)ntie
!
!     cyclic symmetry size
!
      write(15)ncs_
      write(15)mcs
!
!     1d and 2d element size
!
      write(15)ne1d 
      write(15)ne2d 
      write(15)(infree(i),i=1,4)
!
!     procedure info
!
      write(15)nmethod
      write(15)(iperturb(i),i=1,2)
      write(15)nener
      write(15)iplas
      write(15)ithermal
      write(15)nstate_
      write(15)iprestr
!
!     sets
!
      write(15)(set(i),i=1,nset)
      write(15)(istartset(i),i=1,nset)
      write(15)(iendset(i),i=1,nset)
!
!     watch out: the statement
!        write(15)(ialset(i),i=nalset)    (short form)
!     needs less space to store than
!        do i=1,nalset
!           write(15) ialset(i)           (long form)
!        enddo
!     but cannot be accessed by read statements of the form
!        do i=1,nalset
!           read(15) im0
!        enddo
!     as needed in routine restartshort. Therefore the long form
!     is used for ialset.
!
      do i=1,nalset
         write(15) ialset(i)
      enddo
!
!     mesh
!
      write(15)(co(i),i=1,3*nk)
      write(15)(kon(i),i=1,nkon)
      write(15)(ipkon(i),i=1,ne)
      write(15)(lakon(i),i=1,ne)
!
!     single point constraints
!
      write(15)(nodeboun(i),i=1,nboun)
      write(15)(ndirboun(i),i=1,nboun)
      write(15)(typeboun(i),i=1,nboun)
      write(15)(xboun(i),i=1,nboun)
      write(15)(ikboun(i),i=1,nboun)
      write(15)(ilboun(i),i=1,nboun)
      if(nam.gt.0) write(15)(iamboun(i),i=1,nboun)
      write(15)(nodebounold(i),i=1,nboun)
      write(15)(ndirbounold(i),i=1,nboun)
      write(15)(xbounold(i),i=1,nboun)
!
!     multiple point constraints
!
      write(15)(ipompc(i),i=1,nmpc)
      write(15)(labmpc(i),i=1,nmpc)
      write(15)(ikmpc(i),i=1,nmpc)
      write(15)(ilmpc(i),i=1,nmpc)
      write(15)(fmpc(i),i=1,nmpc)
      write(15)(nodempc(i),i=1,3*mpcend)
      write(15)(coefmpc(i),i=1,mpcend)
!
!     point forces
!
      write(15)(nodeforc(i),i=1,2*nforc)
      write(15)(ndirforc(i),i=1,nforc)
      write(15)(xforc(i),i=1,nforc)
      write(15)(ikforc(i),i=1,nforc)
      write(15)(ilforc(i),i=1,nforc)
      if(nam.gt.0) write(15)(iamforc(i),i=1,nforc)
      write(15)(xforcold(i),i=1,nforc)
!
!     distributed loads
!
      write(15)(nelemload(i),i=1,2*nload)
      write(15)(sideload(i),i=1,nload)
      write(15)(xload(i),i=1,2*nload)
      if(nam.gt.0) write(15)(iamload(i),i=1,2*nload)
      write(15)(xloadold(i),i=1,2*nload)
      write(15)(cbody(i),i=1,nbody)
      write(15)(ibody(i),i=1,3*nbody)
      write(15)(xbody(i),i=1,7*nbody)
      write(15)(xbodyold(i),i=1,7*nbody)
!
!     prestress
!
      if(iprestr.gt.0) write(15) (prestr(i),i=1,6*mi(1)*ne)
!
!     labels
!
      write(15) (prlab(i),i=1,nprint)
      write(15) (prset(i),i=1,nprint)
      write(15)(filab(i),i=1,nlabel)
!
!     elastic constants
!
      write(15)(elcon(i),i=1,(ncmat_+1)*ntmat_*nmat)
      write(15)(nelcon(i),i=1,2*nmat)
!
!     density
!
      write(15)(rhcon(i),i=1,2*ntmat_*nmat)
      write(15)(nrhcon(i),i=1,nmat)
!
!     specific heat
!
      write(15)(shcon(i),i=1,4*ntmat_*nmat)
      write(15)(nshcon(i),i=1,nmat)
!
!     conductivity
!
      write(15)(cocon(i),i=1,7*ntmat_*nmat)
      write(15)(ncocon(i),i=1,2*nmat)
!
!     expansion coefficients
!
      write(15)(alcon(i),i=1,7*ntmat_*nmat)
      write(15)(nalcon(i),i=1,2*nmat)
      write(15)(alzero(i),i=1,nmat)
!
!     physical constants
!
      write(15)(physcon(i),i=1,3)
!
!     plastic data
!
      if(iplas.ne.0)then
         write(15)(plicon(i),i=1,(2*npmat_+1)*ntmat_*nmat)
         write(15)(nplicon(i),i=1,(ntmat_+1)*nmat)
         write(15)(plkcon(i),i=1,(2*npmat_+1)*ntmat_*nmat)
         write(15)(nplkcon(i),i=1,(ntmat_+1)*nmat)
      endif
!
!     material orientation
!
      if(norien.ne.0)then
         write(15)(orname(i),i=1,norien)
         write(15)(orab(i),i=1,7*norien)
         write(15)(ielorien(i),i=1,ne)
      endif
!
!     transformations
!
      if(ntrans.ne.0)then
         write(15)(trab(i),i=1,7*ntrans)
         write(15)(inotr(i),i=1,2*nk)
      endif
!
!     amplitudes
!
      if(nam.gt.0)then
         write(15)(amname(i),i=1,nam)
         write(15)(namta(i),i=1,3*nam-1)
         write(15) namta(3*nam)
         write(15)(amta(i),i=1,2*namta(3*nam-1))
      endif
!
!     temperatures
!
      if(ithermal.gt.0)then
         if((ne1d.gt.0).or.(ne2d.gt.0))then
            write(15)(t0(i),i=1,3*nk)
            write(15)(t1(i),i=1,3*nk)
         else
            write(15)(t0(i),i=1,nk)
            write(15)(t1(i),i=1,nk)
         endif
         if(nam.gt.0) write(15)(iamt1(i),i=1,nk)
         write(15)(t1old(i),i=1,nk)
      endif
!
!     materials
!
      write(15)(matname(i),i=1,nmat)
      write(15)(ielmat(i),i=1,ne)
!
!     temperature, displacement, static pressure, velocity and acceleration
!
      write(15)(vold(i),i=1,mt*nk)
      if((nmethod.eq.4).or.((nmethod.eq.1).and.(iperturb(1).ge.2))) then
         write(15)(veold(i),i=1,mt*nk)
      endif
!
!     reordering
!
      write(15)(nnn(i),i=1,nk)
!
!     1d and 2d elements
!
      if((ne1d.gt.0).or.(ne2d.gt.0))then
         write(15)(iponor(i),i=1,2*nkon)
         write(15)(xnor(i),i=1,infree(1)-1)
         write(15)(knor(i),i=1,infree(2)-1)
         write(15)(thicke(i),i=1,2*nkon)
         write(15)(offset(i),i=1,2*ne)
         write(15)(iponoel(i),i=1,infree(4))
         write(15)(inoel(i),i=1,3*(infree(3)-1))
         write(15)(rig(i),i=1,infree(4))
      endif
!
!     tie constraints
!
      if(ntie.gt.0) then
         write(15)((tieset(i,j),i=1,3),j=1,ntie)
         write(15)((tietol(i,j),i=1,2),j=1,ntie)
      endif
!
!     cyclic symmetry
!
      if(ncs_.gt.0)then
         write(15)(ics(i),i=1,ncs_)
      endif
      if(mcs.gt.0) then
         write(15)((cs(i,j),i=1,17),j=1,mcs)
      endif
!
!     integration point variables
!
      write(15)(sti(i),i=1,6*mi(1)*ne)
      write(15)(eme(i),i=1,6*mi(1)*ne)
      if(nener.eq.1) then
         write(15)(ener(i),i=1,mi(1)*ne)
      endif
      if(nstate_.gt.0)then
         write(15)(xstate(i),i=1,nstate_*mi(1)*ne)
      endif
!
!     control parameters
!
      write(15) (ctrl(i),i=1,27)
      write(15) (qaold(i),i=1,2)
      write(15) output
      write(15) ttime
!
      return
!
 151  write(*,*) '*ERROR in restartwrite: could not open file ',fnrstrt
      stop
!
 152  write(*,*) '*ERROR in restartwrite: could not inquire file ',
     &    fnrstrt
      stop
      end



















