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
      subroutine gen3dconnect(kon,ipkon,lakon,ne,iponoel,inoel,
     &  iponoelmax,rig,iponor,xnor,knor,ipompc,nodempc,coefmpc,nmpc,
     &  nmpc_,mpcfree,ikmpc,ilmpc,labmpc)
!
!     connects expanded 1-D and 2-D elements with genuine 3D elements
!
      implicit none
!
      character*8 lakon(*)
      character*20 labmpc(*)
!
      integer kon(*),ipkon(*),ne,iponoel(*),inoel(3,*),iponoelmax,
     &  rig(*),iponor(2,*),knor(*),ipompc(*),nodempc(3,*),nmpc,nmpc_,
     &  mpcfree,ikmpc(*),ilmpc(*),i,indexes,nope,l,node,index2,ielem,
     &  indexe,j,indexk,newnode,idir,idof,id,mpcfreenew,k
!
      real*8 xnor(*),coefmpc(*)
!
!        generating MPC's to connect shells and beams with solid
!        elements
!
      do i=1,ne
         indexes=ipkon(i)
         if(indexes.lt.0) cycle
!
!        looking for solid elements or spring elements only
!
         if((lakon(i)(7:7).ne.' ').and.(lakon(i)(1:1).ne.'E')) cycle
c         if(lakon(i)(4:4).eq.'8') then
c            nope=8
c         elseif(lakon(i)(4:4).eq.'1') then
c            nope=10
c         elseif(lakon(i)(4:4).eq.'2') then
c            nope=20
c         elseif(lakon(i)(1:1).eq.'E') then
c            read(lakon(i)(8:8),'(i1)') nope
c         else
c            cycle
c         endif
!
!        determining the number of nodes belonging to the element
!
         if(lakon(i)(4:4).eq.'4') then
            nope=4
         elseif(lakon(i)(4:4).eq.'6') then
            nope=6
         elseif(lakon(i)(4:4).eq.'8') then
            nope=8
         elseif(lakon(i)(4:5).eq.'10') then
            nope=10
         elseif(lakon(i)(4:5).eq.'15') then
            nope=15
         elseif(lakon(i)(4:4).eq.'2') then
            nope=20
         elseif(lakon(i)(1:1).eq.'E') then
            read(lakon(i)(8:8),'(i1)') nope
            nope=nope+1
         else
            cycle
         endif
!
         do l=1,nope
            node=kon(indexes+l)
            if(node.le.iponoelmax) then
               if(rig(node).eq.0) then
                  index2=iponoel(node)
                  if(index2.eq.0) cycle
                  ielem=inoel(1,index2)
                  indexe=ipkon(ielem)
                  j=inoel(2,index2)
                  indexk=iponor(2,indexe+j)
!
!                 2d shell element: the exterior expanded nodes
!                 are connected to the non-expanded node
!
                  if(lakon(ielem)(7:7).eq.'L') then
                     newnode=knor(indexk+1)
                     do idir=0,3
                        idof=8*(newnode-1)+idir
                        call nident(ikmpc,idof,nmpc,id)
                        if((id.le.0).or.(ikmpc(id).ne.idof)) then
                           nmpc=nmpc+1
                           if(nmpc.gt.nmpc_) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           labmpc(nmpc)='                    '
                           ipompc(nmpc)=mpcfree
                           do j=nmpc,id+2,-1
                              ikmpc(j)=ikmpc(j-1)
                              ilmpc(j)=ilmpc(j-1)
                           enddo
                           ikmpc(id+1)=idof
                           ilmpc(id+1)=nmpc
                           nodempc(1,mpcfree)=newnode
                           nodempc(2,mpcfree)=idir
                           coefmpc(mpcfree)=1.d0
                           mpcfree=nodempc(3,mpcfree)
                           if(mpcfree.eq.0) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           nodempc(1,mpcfree)=knor(indexk+3)
                           nodempc(2,mpcfree)=idir
                           coefmpc(mpcfree)=1.d0
                           mpcfree=nodempc(3,mpcfree)
                           if(mpcfree.eq.0) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           nodempc(1,mpcfree)=node
                           nodempc(2,mpcfree)=idir
                           coefmpc(mpcfree)=-2.d0
                           mpcfreenew=nodempc(3,mpcfree)
                           if(mpcfreenew.eq.0) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           nodempc(3,mpcfree)=0
                           mpcfree=mpcfreenew
                        endif
                     enddo
                  elseif(lakon(ielem)(7:7).eq.'B') then
!
!                    1d beam element: corner nodes are connected to
!                    the not-expanded node
!
                     newnode=knor(indexk+1)
                     do idir=0,3
                        idof=8*(newnode-1)+idir
                        call nident(ikmpc,idof,nmpc,id)
                        if((id.le.0).or.(ikmpc(id).ne.idof)) then
                           nmpc=nmpc+1
                           if(nmpc.gt.nmpc_) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           labmpc(nmpc)='                    '
                           ipompc(nmpc)=mpcfree
                           do j=nmpc,id+2,-1
                              ikmpc(j)=ikmpc(j-1)
                              ilmpc(j)=ilmpc(j-1)
                           enddo
                           ikmpc(id+1)=idof
                           ilmpc(id+1)=nmpc
                           nodempc(1,mpcfree)=newnode
                           nodempc(2,mpcfree)=idir
                           coefmpc(mpcfree)=1.d0
                           mpcfree=nodempc(3,mpcfree)
                           if(mpcfree.eq.0) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           do k=2,4
                              nodempc(1,mpcfree)=knor(indexk+k)
                              nodempc(2,mpcfree)=idir
                              coefmpc(mpcfree)=1.d0
                              mpcfree=nodempc(3,mpcfree)
                              if(mpcfree.eq.0) then
                                 write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                                 stop
                              endif
                           enddo
                           nodempc(1,mpcfree)=node
                           nodempc(2,mpcfree)=idir
                           coefmpc(mpcfree)=-4.d0
                           mpcfreenew=nodempc(3,mpcfree)
                           if(mpcfreenew.eq.0) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           nodempc(3,mpcfree)=0
                           mpcfree=mpcfreenew
                        endif
                     enddo
                  else
!     
!                    2d plane stress, plane strain or axisymmetric
!                    element: the expanded middle node (this is the
!                    "governing" node for these elements) is connected to
!                    the non-expanded node
!
                     newnode=knor(indexk+2)
                     do idir=0,2
                        idof=8*(newnode-1)+idir
                        call nident(ikmpc,idof,nmpc,id)
                        if((id.le.0).or.(ikmpc(id).ne.idof)) then
                           nmpc=nmpc+1
                           if(nmpc.gt.nmpc_) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           labmpc(nmpc)='                    '
                           ipompc(nmpc)=mpcfree
                           do j=nmpc,id+2,-1
                              ikmpc(j)=ikmpc(j-1)
                              ilmpc(j)=ilmpc(j-1)
                           enddo
                           ikmpc(id+1)=idof
                           ilmpc(id+1)=nmpc
                           nodempc(1,mpcfree)=newnode
                           nodempc(2,mpcfree)=idir
                           coefmpc(mpcfree)=1.d0
                           mpcfree=nodempc(3,mpcfree)
                           if(mpcfree.eq.0) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           nodempc(1,mpcfree)=node
                           nodempc(2,mpcfree)=idir
                           coefmpc(mpcfree)=-1.d0
                           mpcfreenew=nodempc(3,mpcfree)
                           if(mpcfreenew.eq.0) then
                              write(*,*) 
     &                          '*ERROR in gen3dconnect: increase nmpc_'
                              stop
                           endif
                           nodempc(3,mpcfree)=0
                           mpcfree=mpcfreenew
                        endif
                     enddo
                  endif
               endif
            endif
         enddo
      enddo
!
      return
      end


