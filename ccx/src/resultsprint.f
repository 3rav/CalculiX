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
      subroutine resultsprint(co,nk,kon,ipkon,lakon,ne,v,stn,inum,
     &  stx,ielorien,norien,orab,t1,ithermal,filab,een,iperturb,fn,
     &  nactdof,iout,vold,nodeboun,ndirboun,nboun,nmethod,ttime,xstate,
     &  epn,mi,
     &  nstate_,ener,enern,xstaten,eei,set,nset,istartset,iendset,
     &  ialset,nprint,prlab,prset,qfx,qfn,trab,inotr,ntrans,
     &  nelemload,nload,ikin,ielmat,thicke,eme,emn)
!
!     - stores the results in the .dat file, if requested
!       - nodal quantities at the nodes
!       - element quantities at the integration points
!     - calculates the extrapolation of element quantities to
!       the nodes (if requested for .frd output)
!     - calculates 1d/2d results for 1d/2d elements by
!       interpolation
!
      implicit none
!
      logical force
!
      character*1 cflag
      character*6 prlab(*)
      character*8 lakon(*)
      character*81 set(*),prset(*)
      character*87 filab(*)
!
      integer kon(*),inum(*),iperm(20),mi(*),ielorien(mi(3),*),
     &  ipkon(*),cfd,nactdof(0:mi(2),*),nodeboun(*),
     &  nelemload(2,*),ndirboun(*),ielmat(mi(3),*),
     &  inotr(2,*),iorienloc,iflag,nload,mt,nk,ne,ithermal(2),i,
     &  norien,iperturb(*),iout,nboun,nmethod,node,
     &  nfield,ndim,nstate_,nset,istartset(*),iendset(*),ialset(*),
     &  nprint,ntrans,ikin
!
      real*8 co(3,*),v(0:mi(2),*),stx(6,mi(1),*),stn(6,*),
     &  qfx(3,mi(1),*),qfn(3,*),orab(7,*),fn(0:mi(2),*),
     &  t1(*),een(6,*),vold(0:mi(2),*),epn(*),thicke(mi(3),*),
     &  ener(mi(1),*),enern(*),eei(6,mi(1),*),
     &  ttime,xstate(nstate_,mi(1),*),trab(7,*),xstaten(nstate_,*),
     &  eme(6,mi(1),*),emn(6,*)
!
      data iflag /3/
      data iperm /5,6,7,8,1,2,3,4,13,14,15,16,9,10,11,12,17,18,19,20/
!
      mt=mi(2)+1
!
      force=.false.
!
!     no print requests
!
      if(iout.le.0) then
!
!        2d basic dof results (displacements, temperature) are
!        calculated in each iteration, so that they are available
!        in the user subroutines
!
         if(filab(1)(5:5).ne.' ') then
            nfield=mt
            call map3dto1d2d_v(v,ipkon,inum,kon,lakon,nfield,nk,
     &           ne,nactdof)
         endif
         return
      endif
!
!     output in dat file (with *NODE PRINT or *EL PRINT)
!
      call printout(set,nset,istartset,iendset,ialset,nprint,
     &  prlab,prset,v,t1,fn,ipkon,lakon,stx,eei,xstate,ener,
     &  mi(1),nstate_,ithermal,co,kon,qfx,ttime,trab,inotr,ntrans,
     &  orab,ielorien,norien,nk,ne,inum,filab,vold,ikin,ielmat,thicke,
     &  eme)
!
!     interpolation in the original nodes of 1d and 2d elements
!     this operation has to be performed in any case since
!     the interpolated values may be needed as boundary conditions
!     in the next step (e.g. the temperature in a heat transfer
!     calculation as boundary condition in a subsequent static
!     step)
!
      if(filab(1)(5:5).ne.' ') then
         nfield=mt
         cflag=filab(1)(5:5)
c         force=.false.
         call map3dto1d2d(v,ipkon,inum,kon,lakon,nfield,nk,
     &        ne,cflag,co,vold,force,mi)
      endif
!
!     user defined output
!
      call uout(v,mi)
!
      if((filab(2)(1:4).eq.'NT  ').and.(ithermal(1).le.1)) then
         if(filab(2)(5:5).eq.'I') then
            nfield=1
            cflag=filab(2)(5:5)
c            force=.false.
            call map3dto1d2d(t1,ipkon,inum,kon,lakon,nfield,nk,
     &           ne,cflag,co,vold,force,mi)
         endif
      endif
!
      cfd=0
!
!     for composites:
!     interpolation of the displacements and temperatures
!     from the expanded nodes to the layer nodes
!
      if(mi(3).gt.1) then
         if((filab(1)(1:3).eq.'U  ').or.
     &        ((filab(2)(1:4).eq.'NT  ').and.(ithermal(1).gt.1))) then
            nfield=mt
            call map3dtolayer(v,ipkon,kon,lakon,nfield,
     &           ne,co,ielmat,mi)
         endif
         if((filab(2)(1:4).eq.'NT  ').and.(ithermal(1).le.1)) then
            nfield=1
            call map3dtolayer(t1,ipkon,kon,lakon,nfield,
     &           ne,co,ielmat,mi)
         endif
      endif
!
!     determining the stresses in the nodes for output in frd format
!
      if((filab(3)(1:4).eq.'S   ').or.(filab(18)(1:4).eq.'PHS ').or.
     &   (filab(20)(1:4).eq.'MAXS')) then
         nfield=6
         ndim=6
         if((norien.gt.0).and.(filab(3)(6:6).eq.'L')) then
            iorienloc=1
         else
            iorienloc=0
         endif
         cflag=filab(3)(5:5)
!
         call extrapolate(stx,stn,ipkon,inum,kon,lakon,nfield,nk,
     &        ne,mi(1),ndim,orab,ielorien,co,iorienloc,cflag,
     &        nelemload,nload,nodeboun,nboun,ndirboun,vold,
     &        ithermal,force,cfd,ielmat,thicke)
!
      endif
!
!     determining the total strains in the nodes for output in frd format
!
      if((filab(4)(1:4).eq.'E   ').or.(filab(30)(1:4).eq.'MAXE')) then
         nfield=6
         ndim=6
         if((norien.gt.0).and.(filab(4)(6:6).eq.'L')) then
            iorienloc=1
         else
            iorienloc=0
         endif
         cflag=filab(4)(5:5)
         call extrapolate(eei,een,ipkon,inum,kon,lakon,nfield,nk,
     &        ne,mi(1),ndim,orab,ielorien,co,iorienloc,cflag,
     &        nelemload,nload,nodeboun,nboun,ndirboun,vold,
     &        ithermal,force,cfd,ielmat,thicke)
      endif
!
!     determining the mechanical strains in the nodes for output in 
!     frd format
!
      if(filab(32)(1:4).eq.'ME  ') then
         nfield=6
         ndim=6
         if((norien.gt.0).and.(filab(4)(6:6).eq.'L')) then
            iorienloc=1
         else
            iorienloc=0
         endif
         cflag=filab(4)(5:5)
         call extrapolate(eme,emn,ipkon,inum,kon,lakon,nfield,nk,
     &        ne,mi(1),ndim,orab,ielorien,co,iorienloc,cflag,
     &        nelemload,nload,nodeboun,nboun,ndirboun,vold,
     &        ithermal,force,cfd,ielmat,thicke)
      endif
!
!     determining the plastic equivalent strain in the nodes 
!     for output in frd format
!
      if(filab(6)(1:4).eq.'PEEQ') then
         nfield=1
         ndim=nstate_
         iorienloc=0
         cflag=filab(6)(5:5)
         call extrapolate(xstate,epn,ipkon,inum,kon,lakon,nfield,nk,
     &        ne,mi(1),ndim,orab,ielorien,co,iorienloc,cflag,
     &        nelemload,nload,nodeboun,nboun,ndirboun,vold,
     &        ithermal,force,cfd,ielmat,thicke)
      endif
!
!     determining the total energy in the nodes 
!     for output in frd format
!
      if(filab(7)(1:4).eq.'ENER') then
         nfield=1
         ndim=1
         iorienloc=0
         cflag=filab(7)(5:5)
         call extrapolate(ener,enern,ipkon,inum,kon,lakon,nfield,nk,
     &        ne,mi(1),ndim,orab,ielorien,co,iorienloc,cflag,
     &        nelemload,nload,nodeboun,nboun,ndirboun,vold,
     &        ithermal,force,cfd,ielmat,thicke)
      endif
!
!     determining the internal state variables in the nodes 
!     for output in frd format
!
      if(filab(8)(1:4).eq.'SDV ') then
         nfield=nstate_
         ndim=nstate_
         if((norien.gt.0).and.(filab(9)(6:6).eq.'L')) then
            write(*,*) '*WARNING in results: SDV variables cannot'
            write(*,*) '         be stored in a local frame;'
            write(*,*) '         the global frame will be used'
         endif
         iorienloc=0
         cflag=filab(8)(5:5)
         call extrapolate(xstate,xstaten,ipkon,inum,kon,lakon,nfield,nk,
     &        ne,mi(1),ndim,orab,ielorien,co,iorienloc,cflag,
     &        nelemload,nload,nodeboun,nboun,ndirboun,vold,
     &        ithermal,force,cfd,ielmat,thicke)
      endif
!
!     determining the heat flux in the nodes for output in frd format
!
      if((filab(9)(1:4).eq.'HFL ').and.(ithermal(1).gt.1)) then
         nfield=3
         ndim=3
         if((norien.gt.0).and.(filab(9)(6:6).eq.'L')) then
            iorienloc=1
         else
            iorienloc=0
         endif
         cflag=filab(9)(5:5)
         call extrapolate(qfx,qfn,ipkon,inum,kon,lakon,nfield,nk,
     &        ne,mi(1),ndim,orab,ielorien,co,iorienloc,cflag,
     &        nelemload,nload,nodeboun,nboun,ndirboun,vold,
     &        ithermal,force,cfd,ielmat,thicke)
      endif
!
!     if no element quantities requested in the nodes: calculate
!     inum if nodal quantities are requested: used in subroutine frd
!     to determine which nodes are active in the model 
!
      if((filab(3)(1:4).ne.'S   ').and.(filab(4)(1:4).ne.'E   ').and.
     &   (filab(6)(1:4).ne.'PEEQ').and.(filab(7)(1:4).ne.'ENER').and.
     &   (filab(8)(1:4).ne.'SDV ').and.(filab(9)(1:4).ne.'HFL ').and.
     &   ((nmethod.ne.4).or.(iperturb(1).ge.2))) then
!
         nfield=0
         ndim=0
         iorienloc=0
         cflag=filab(1)(5:5)
         call createinum(ipkon,inum,kon,lakon,nk,ne,cflag,nelemload,
     &       nload,nodeboun,nboun,ndirboun,ithermal,co,vold,mi)
      endif
!
      if(ithermal(1).gt.1) then
!
!        extrapolation for the network
!         -interpolation for the total pressure and temperature
!          in the middle nodes
!         -extrapolation for the mass flow in the end nodes
!
         call networkextrapolate(v,ipkon,inum,kon,lakon,ne,mi)
!
!     printing values for environmental film, radiation and
!     pressure nodes (these nodes are considered to be network
!     nodes)
!
         do i=1,nload
            node=nelemload(2,i)
            if(node.gt.0) then
               if(inum(node).gt.0) cycle
               inum(node)=1
            endif
         enddo
!
!     printing values of prescribed boundary conditions (these
!     nodes are considered to be structural nodes)
!
         do i=1,nboun
            node=nodeboun(i)
            if(inum(node).ne.0) cycle
            if((cflag.ne.' ').and.(ndirboun(i).eq.3)) cycle
            inum(node)=1
         enddo
      endif
!
      return
      end
