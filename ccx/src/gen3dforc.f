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
      subroutine gen3dforc(ikforc,ilforc,nforc,nforc_,nodeforc,
     &  ndirforc,xforc,iamforc,ntrans,inotr,trab,rig,ipompc,nodempc,
     &  coefmpc,nmpc,nmpc_,mpcfree,ikmpc,ilmpc,labmpc,iponoel,inoel,
     &  iponoelmax,kon,ipkon,lakon,ne,iponor,xnor,knor,nam,nk,nk_,
     &  co,thicke,nodeboun,ndirboun,ikboun,ilboun,nboun,nboun_,
     &  iamboun,typeboun,xboun,nmethod,iperturb,istep,vold,mi)
!
!     connects nodes of 1-D and 2-D elements, for which 
!     concentrated forces were
!     defined, to the nodes of their expanded counterparts
!
      implicit none
!
      logical add,fixed,user
!
      character*1 type,typeboun(*)
      character*8 lakon(*)
      character*20 labmpc(*)
!
      integer ikforc(*),ilforc(*),nodeforc(2,*),ndirforc(*),iamforc(*),
     &  nforc,nforc_,ntrans,inotr(2,*),rig(*),ipompc(*),nodempc(3,*),
     &  nmpc,nmpc_,mpcfree,ikmpc(*),ilmpc(*),iponoel(*),inoel(3,*),
     &  iponoelmax,kon(*),ipkon(*),ne,iponor(2,*),knor(*),nforcold,
     &  i,node,index,ielem,j,indexe,indexk,nam,iamplitude,idir,
     &  irotnode,nk,nk_,newnode,idof,id,mpcfreenew,k,isector,ndepnodes,
     &  idepnodes(80),l,iexpnode,indexx,irefnode,imax,isol,mpcfreeold,
     &  nod,impc,istep,nodeboun(*),ndirboun(*),ikboun(*),ilboun(*),
     &  nboun,nboun_,iamboun(*),nmethod,iperturb,nrhs,ipiv(3),info,m,
     &  mi(2)
!
      real*8 xforc(*),trab(7,*),coefmpc(*),xnor(*),val,co(3,*),
     &  thicke(2,*),pi,xboun(*),xnoref(3),dmax,d(3,3),e(3,3,3),
     &  alpha,q(3),w(3),xn(3),a(3,3),a1(3),a2(3),dd,c1,c2,c3,ww,c(3,3),
     &  vold(0:mi(2),*)
!
      data d /1.,0.,0.,0.,1.,0.,0.,0.,1./
      data e /0.,0.,0.,0.,0.,-1.,0.,1.,0.,
     &        0.,0.,1.,0.,0.,0.,-1.,0.,0.,
     &        0.,-1.,0.,1.,0.,0.,0.,0.,0./
!
      fixed=.false.
!
      add=.false.
      user=.false.
      pi=4.d0*datan(1.d0)
      isector=0
!
      nforcold=nforc
      do i=1,nforcold
         node=nodeforc(1,i)
         if(node.gt.iponoelmax) then
            if(ndirforc(i).gt.4) then
               write(*,*) '*WARNING: in gen3dforc: node ',i,
     &              ' does not'
               write(*,*) '       belong to a beam nor shell'
               write(*,*) '       element and consequently has no'
               write(*,*) '       rotational degrees of freedom'
            endif
            cycle
         endif
         index=iponoel(node)
         if(index.eq.0) then
            if(ndirforc(i).gt.4) then
               write(*,*) '*WARNING: in gen3dforc: node ',i,
     &              ' does not'
               write(*,*) '       belong to a beam nor shell'
               write(*,*) '       element and consequently has no'
               write(*,*) '       rotational degrees of freedom'
            endif
            cycle
         endif
         ielem=inoel(1,index)
         j=inoel(2,index)
         indexe=ipkon(ielem)
         indexk=iponor(2,indexe+j)
         if(nam.gt.0) iamplitude=iamforc(i)
         idir=ndirforc(i)
!
         if(rig(node).ne.0) then
            if(idir.gt.4) then
               if(rig(node).lt.0) then
                  write(*,*) '*ERROR in gen3dforc: in node ',node
                  write(*,*) '       a rotational DOF is loaded;'
                  write(*,*) '       however, the elements to which'
                  write(*,*) '       this node belongs do not have'
                  write(*,*) '       rotational DOFs'
                  stop
               endif
               val=xforc(i)
               k=idir-4
               irotnode=rig(node)
               call forcadd(irotnode,k,val,nodeforc,
     &              ndirforc,xforc,nforc,nforc_,iamforc,
     &              iamplitude,nam,ntrans,trab,inotr,co,
     &              ikforc,ilforc,isector,add,user)
            endif
         else
!
!           check for moments defined in any but the first step
!
            if(idir.gt.4) then
!
!              create a knot: determine the knot
!
               ndepnodes=0
               if(lakon(ielem)(7:7).eq.'L') then
                  do k=1,3
                     ndepnodes=ndepnodes+1
                     idepnodes(ndepnodes)=knor(indexk+k)
                  enddo
               elseif(lakon(ielem)(7:7).eq.'B') then
                  do k=1,8
                     ndepnodes=ndepnodes+1
                     idepnodes(ndepnodes)=knor(indexk+k)
                  enddo
               else
                  write(*,*) 
     &           '*ERROR in gen3dboun: a rotational DOF was applied'
                  write(*,*) 
     &           '*      to node',node,' without rotational DOFs'
                  stop
               endif
!
!              remove all MPC's in which the knot nodes are
!              dependent nodes
!              
               do k=1,ndepnodes
                  nod=idepnodes(k)
                  do l=1,3
                     idof=8*(nod-1)+l
                     call nident(ikmpc,idof,nmpc,id)
                     if(id.gt.0) then
                        if(ikmpc(id).eq.idof) then
                           impc=ilmpc(id)
                           call mpcrem(impc,mpcfree,nodempc,nmpc,
     &                       ikmpc,ilmpc,labmpc,coefmpc,ipompc)
                        endif
                     endif
                  enddo
               enddo
!
!              generate a rigid body knot
!
               irefnode=node
               nk=nk+1
               if(nk.gt.nk_) then
                  write(*,*) '*ERROR in rigidbodies: increase nk_'
                  stop
               endif
               irotnode=nk
               rig(node)=irotnode
               nk=nk+1
               if(nk.gt.nk_) then
                  write(*,*) '*ERROR in rigidbodies: increase nk_'
                  stop
               endif
               iexpnode=nk
               do k=1,ndepnodes
                  call knotmpc(ipompc,nodempc,coefmpc,irefnode,
     &                 irotnode,iexpnode,
     &                 labmpc,nmpc,nmpc_,mpcfree,ikmpc,ilmpc,nk,nk_,
     &                 nodeboun,ndirboun,ikboun,ilboun,nboun,nboun_,
     &                 idepnodes(k),typeboun,co,xboun,istep)
               enddo
!
!              determine the location of the center of gravity of
!              the section and its displacements
!
               do l=1,3
                  q(l)=0.d0
                  w(l)=0.d0
               enddo
               if(ndepnodes.eq.3) then
                  do k=1,ndepnodes,2
                     nod=idepnodes(k)
                     do l=1,3
                        q(l)=q(l)+co(l,nod)
                        w(l)=w(l)+vold(l,nod)
                     enddo
                  enddo
                  do l=1,3
                     q(l)=q(l)/2.d0
                     w(l)=w(l)/2.d0
                  enddo
               else
                  do k=1,ndepnodes
                     nod=idepnodes(k)
                     do l=1,3
                        q(l)=q(l)+co(l,nod)
                        w(l)=w(l)+vold(l,nod)
                     enddo
                  enddo
                  do l=1,3
                     q(l)=q(l)/ndepnodes
                     w(l)=w(l)/ndepnodes
                  enddo
               endif
!
!              determine the first displacements of iexpnode
!
               alpha=0.d0
               do k=1,ndepnodes
                  nod=idepnodes(k)
                  dd=(co(1,nod)-q(1))**2
     &              +(co(2,nod)-q(2))**2
     &              +(co(3,nod)-q(3))**2
                  if(dd.lt.1.d-20) cycle
                  alpha=alpha+dsqrt(
     &             ((co(1,nod)+vold(1,nod)-q(1)-w(1))**2
     &             +(co(2,nod)+vold(2,nod)-q(2)-w(2))**2
     &             +(co(3,nod)+vold(3,nod)-q(3)-w(3))**2)/dd)
               enddo
               alpha=alpha/ndepnodes
!
!              determine the displacements of irotnodes
!
               do l=1,3
                  do m=1,3
                     a(l,m)=0.d0
                  enddo
                  xn(l)=0.d0
               enddo
               do k=1,ndepnodes
                  nod=idepnodes(k)
                  dd=0.d0
                  do l=1,3
                     a1(l)=co(l,nod)-q(l)
                     a2(l)=vold(l,nod)-w(l)
                     dd=dd+a1(l)*a1(l)
                  enddo
                  dd=dsqrt(dd)
                  if(dd.lt.1.d-10) cycle
                  do l=1,3
                     a1(l)=a1(l)/dd
                     a2(l)=a2(l)/dd
                  enddo
                  xn(1)=xn(1)+(a1(2)*a2(3)-a1(3)*a2(2))
                  xn(2)=xn(2)+(a1(3)*a2(1)-a1(1)*a2(3))
                  xn(3)=xn(3)+(a1(1)*a2(2)-a1(2)*a2(1))
                  do l=1,3
                     do m=1,3
                        a(l,m)=a(l,m)+a1(l)*a1(m)
                     enddo
                  enddo
               enddo
!
               do l=1,3
                  do m=1,3
                     a(l,m)=a(l,m)/ndepnodes
                  enddo
                  xn(l)=xn(l)/ndepnodes
                  a(l,l)=1.d0-a(l,l)
               enddo
!
               m=3
               nrhs=1
               call dgesv(m,nrhs,a,m,ipiv,xn,m,info)
               if(info.ne.0) then
                  write(*,*) '*ERROR in gen3dforc:'
                  write(*,*) '       singular system of equations'
                  stop
               endif
!
               dd=0.d0
               do l=1,3
                  dd=dd+xn(l)*xn(l)
               enddo
               dd=dsqrt(dd)
               do l=1,3
                  xn(l)=dasin(dd/alpha)*xn(l)/dd
               enddo
!
!              determine the displacements of irefnode
!
               ww=dsqrt(xn(1)*xn(1)+xn(2)*xn(2)+xn(3)*xn(3))
!
               c1=dcos(ww)
               if(ww.gt.1.d-10) then
                  c2=dsin(ww)/ww
               else
                  c2=1.d0
               endif
               if(ww.gt.1.d-5) then
                  c3=(1.d0-c1)/ww**2
               else
                  c3=0.5d0
               endif
!
!              rotation matrix c
!
               do k=1,3
                  do l=1,3
                     c(k,l)=c1*d(k,l)+
     &                  c2*(e(k,1,l)*xn(1)+e(k,2,l)*xn(2)+
     &                  e(k,3,l)*xn(3))+c3*xn(k)*xn(l)
                  enddo
               enddo
!
               do l=1,3
                  w(l)=w(l)+(alpha*c(l,1)-d(l,1))*(co(1,irefnode)-q(1))
     &                     +(alpha*c(l,2)-d(l,2))*(co(2,irefnode)-q(2))
     &                     +(alpha*c(l,3)-d(l,3))*(co(3,irefnode)-q(3))
               enddo
!
!              copying the displacements
!
               do l=1,3
                  vold(l,irefnode)=w(l)
                  vold(l,irotnode)=xn(l)
               enddo
               vold(1,iexpnode)=alpha
!
!              apply the moment
!               
               idir=idir-4
               val=xforc(i)
               call forcadd(irotnode,idir,val,nodeforc,
     &              ndirforc,xforc,nforc,nforc_,iamforc,
     &              iamplitude,nam,ntrans,trab,inotr,co,
     &              ikforc,ilforc,isector,add,user)
!
!              check for shells whether the rotation about the normal
!              on the shell has been eliminated
!               
               if(lakon(ielem)(7:7).eq.'L') then
                  indexx=iponor(1,indexe+j)
                  do k=1,3
                     xnoref(k)=xnor(indexx+k)
                  enddo
                  dmax=0.d0
                  imax=0
                  do k=1,3
                     if(dabs(xnoref(k)).gt.dmax) then
                        dmax=dabs(xnoref(k))
                        imax=k
                     endif
                  enddo
!     
!                 check whether a SPC suffices
!
                  if(dabs(1.d0-dmax).lt.1.d-3) then
                     val=0.d0
                     if(nam.gt.0) iamplitude=0
                     type='R'
                     call bounadd(irotnode,imax,imax,val,nodeboun,
     &                    ndirboun,xboun,nboun,nboun_,iamboun,
     &                    iamplitude,nam,ipompc,nodempc,coefmpc,
     &                    nmpc,nmpc_,mpcfree,inotr,trab,ntrans,
     &                    ikboun,ilboun,ikmpc,ilmpc,co,nk,nk_,labmpc,
     &                    type,typeboun,nmethod,iperturb,fixed,vold,
     &                    irotnode,mi)
                  else
!     
!                    check for an unused rotational DOF
!     
                     isol=0
                     do l=1,3
                        idof=8*(node-1)+4+imax
                        call nident(ikboun,idof,nboun,id)
                        if((id.gt.0).and.(ikboun(id).eq.idof)) then
                           imax=imax+1
                           if(imax.gt.3) imax=imax-3
                           cycle
                        endif
                        isol=1
                        exit
                     enddo
!     
!     if one of the rotational dofs was not used so far,
!     it can be taken as dependent side for fixing the
!     rotation about the normal. If all dofs were used,
!     no additional equation is needed.
!     
                     if(isol.eq.1) then
                        idof=8*(irotnode-1)+imax
                        call nident(ikmpc,idof,nmpc,id)
                        nmpc=nmpc+1
                        if(nmpc.gt.nmpc_) then
                           write(*,*) 
     &                          '*ERROR in gen3dnor: increase nmpc_'
                           stop
                        endif
!     
                        ipompc(nmpc)=mpcfree
                        labmpc(nmpc)='                    '
!     
                        do l=nmpc,id+2,-1
                           ikmpc(l)=ikmpc(l-1)
                           ilmpc(l)=ilmpc(l-1)
                        enddo
                        ikmpc(id+1)=idof
                        ilmpc(id+1)=nmpc
!     
                        nodempc(1,mpcfree)=irotnode
                        nodempc(2,mpcfree)=imax
                        coefmpc(mpcfree)=xnoref(imax)
                        mpcfree=nodempc(3,mpcfree)
                        imax=imax+1
                        if(imax.gt.3) imax=imax-3
                        nodempc(1,mpcfree)=irotnode
                        nodempc(2,mpcfree)=imax
                        coefmpc(mpcfree)=xnoref(imax)
                        mpcfree=nodempc(3,mpcfree)
                        imax=imax+1
                        if(imax.gt.3) imax=imax-3
                        nodempc(1,mpcfree)=irotnode
                        nodempc(2,mpcfree)=imax
                        coefmpc(mpcfree)=xnoref(imax)
                        mpcfreeold=mpcfree
                        mpcfree=nodempc(3,mpcfree)
                        nodempc(3,mpcfreeold)=0
                     endif
                  endif
               endif
               cycle
            endif
!
!                    2d element shell element: generate MPC's
!
            if(lakon(ielem)(7:7).eq.'L') then
               newnode=knor(indexk+1)
               idof=8*(newnode-1)+idir
               call nident(ikmpc,idof,nmpc,id)
               if((id.le.0).or.(ikmpc(id).ne.idof)) then
                  nmpc=nmpc+1
                  if(nmpc.gt.nmpc_) then
                     write(*,*) 
     &                    '*ERROR in gen3dforc: increase nmpc_'
                     stop
                  endif
                  labmpc(nmpc)='                    '
                  ipompc(nmpc)=mpcfree
                  do k=nmpc,id+2,-1
                     ikmpc(k)=ikmpc(k-1)
                     ilmpc(k)=ilmpc(k-1)
                  enddo
                  ikmpc(id+1)=idof
                  ilmpc(id+1)=nmpc
!
!                 for middle nodes: u_1+u_3-2*u_node=0
!                 for end nodes: -u_1+4*u_2-u_3-2*u_node=0
!
!                 u_1 corresponds to knor(indexk+1)....
!
                  nodempc(1,mpcfree)=newnode
                  nodempc(2,mpcfree)=idir
                  if(j.gt.4) then
                     coefmpc(mpcfree)=1.d0
                  else
                     coefmpc(mpcfree)=-1.d0
                  endif
                  mpcfree=nodempc(3,mpcfree)
                  if(mpcfree.eq.0) then
                     write(*,*) 
     &                    '*ERROR in gen3dforc: increase nmpc_'
                     stop
                  endif
!
                  if(j.le.4) then
                     nodempc(1,mpcfree)=knor(indexk+2)
                     nodempc(2,mpcfree)=idir
                     coefmpc(mpcfree)=4.d0
                     mpcfree=nodempc(3,mpcfree)
                     if(mpcfree.eq.0) then
                        write(*,*) 
     &                       '*ERROR in gen3dforc: increase nmpc_'
                        stop
                     endif
                  endif
!
                  nodempc(1,mpcfree)=knor(indexk+3)
                  nodempc(2,mpcfree)=idir
                  if(j.gt.4) then
                     coefmpc(mpcfree)=1.d0
                  else
                     coefmpc(mpcfree)=-1.d0
                  endif
                  mpcfree=nodempc(3,mpcfree)
                  if(mpcfree.eq.0) then
                     write(*,*) 
     &                    '*ERROR in gen3dforc: increase nmpc_'
                     stop
                  endif
!
                  nodempc(1,mpcfree)=node
                  nodempc(2,mpcfree)=idir
                  coefmpc(mpcfree)=-2.d0
                  mpcfreenew=nodempc(3,mpcfree)
                  if(mpcfreenew.eq.0) then
                     write(*,*) 
     &                    '*ERROR in gen3dforc: increase nmpc_'
                     stop
                  endif
!
                  nodempc(3,mpcfree)=0
                  mpcfree=mpcfreenew
               endif
            elseif(lakon(ielem)(7:7).eq.'B') then
!
!                       1d beam element: generate MPC's
!
               newnode=knor(indexk+1)
               idof=8*(newnode-1)+idir
               call nident(ikmpc,idof,nmpc,id)
               if((id.le.0).or.(ikmpc(id).ne.idof)) then
                  nmpc=nmpc+1
                  if(nmpc.gt.nmpc_) then
                     write(*,*) 
     &                    '*ERROR in gen3dforc: increase nmpc_'
                     stop
                  endif
                  labmpc(nmpc)='                    '
                  ipompc(nmpc)=mpcfree
                  do k=nmpc,id+2,-1
                     ikmpc(k)=ikmpc(k-1)
                     ilmpc(k)=ilmpc(k-1)
                  enddo
                  ikmpc(id+1)=idof
                  ilmpc(id+1)=nmpc
c                  nodempc(1,mpcfree)=newnode
c                  nodempc(2,mpcfree)=idir
c                  coefmpc(mpcfree)=1.d0
c                  mpcfree=nodempc(3,mpcfree)
c                  if(mpcfree.eq.0) then
c                     write(*,*) 
c     &                    '*ERROR in gen3dforc: increase nmpc_'
c                     stop
c                  endif
c                  if(j.eq.2) then
                     do k=1,4
                        nodempc(1,mpcfree)=knor(indexk+k)
                        nodempc(2,mpcfree)=idir
                        coefmpc(mpcfree)=1.d0
                        mpcfree=nodempc(3,mpcfree)
                        if(mpcfree.eq.0) then
                           write(*,*) 
     &                          '*ERROR in gen3dforc: increase nmpc_'
                           stop
                        endif
                     enddo
c                  else
c                     do k=1,4
c                        nodempc(1,mpcfree)=knor(indexk+k)
c                        nodempc(2,mpcfree)=idir
c                        coefmpc(mpcfree)=-1.d0/3.d0
c                        mpcfree=nodempc(3,mpcfree)
c                        if(mpcfree.eq.0) then
c                           write(*,*) 
c     &                          '*ERROR in gen3dforc: increase nmpc_'
c                           stop
c                        endif
c                     enddo
c                     do k=5,8
c                        nodempc(1,mpcfree)=knor(indexk+k)
c                        nodempc(2,mpcfree)=idir
c                        coefmpc(mpcfree)=4.d0/3.d0
c                        mpcfree=nodempc(3,mpcfree)
c                        if(mpcfree.eq.0) then
c                           write(*,*) 
c     &                          '*ERROR in gen3dforc: increase nmpc_'
c                           stop
c                        endif
c                     enddo
c                  endif
                  nodempc(1,mpcfree)=node
                  nodempc(2,mpcfree)=idir
                  coefmpc(mpcfree)=-4.d0
                  mpcfreenew=nodempc(3,mpcfree)
                  if(mpcfreenew.eq.0) then
                     write(*,*) 
     &                    '*ERROR in gen3dforc: increase nmpc_'
                     stop
                  endif
                  nodempc(3,mpcfree)=0
                  mpcfree=mpcfreenew
               endif
            else
!
!              2d plane strain, plane stress or axisymmetric 
!              element
!
               node=knor(indexk+2)
               val=xforc(i)
               call forcadd(node,idir,val,nodeforc,
     &              ndirforc,xforc,nforc,nforc_,iamforc,
     &              iamplitude,nam,ntrans,trab,inotr,co,
     &              ikforc,ilforc,isector,add,user)
            endif
         endif
      enddo
!
      return
      end


