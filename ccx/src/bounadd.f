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
      subroutine bounadd(node,is,ie,val,nodeboun,ndirboun,xboun,
     &  nboun,nboun_,iamboun,iamplitude,nam,ipompc,nodempc,
     &  coefmpc,nmpc,nmpc_,mpcfree,inotr,trab,
     &  ntrans,ikboun,ilboun,ikmpc,ilmpc,co,nk,nk_,labmpc,type,
     &  typeboun,nmethod,iperturb,fixed,vold)
!
!     adds a boundary condition to the data base
!
      implicit none
!
      logical fixed
!
      character*1 type,typeboun(*)
      character*20 labmpc(*)
!
      integer nodeboun(*),ndirboun(*),node,is,ie,nboun,nboun_,i,j,
     &  iamboun(*),iamplitude,nam,ipompc(*),nodempc(3,*),nmpc,nmpc_,
     &  mpcfree,inotr(2,*),ntrans,ikboun(*),ilboun(*),ikmpc(*),
     &  ilmpc(*),itr,idof,newnode,number,id,idofnew,idnew,nk,nk_,
     &  mpcfreenew,nmethod,iperturb,ii
!
      real*8 xboun(*),val,coefmpc(*),trab(7,*),a(3,3),co(3,*),
     &  vold(0:4)
!
      if(ntrans.le.0) then
         itr=0
      elseif(inotr(1,node).eq.0) then
         itr=0
      else
         itr=inotr(1,node)
      endif
!
      if((itr.eq.0).or.(is.eq.0)) then
!
!        no transformation applies: simple SPC
!
         loop: do ii=is,ie
            if(ii.le.3) then
               i=ii
            elseif(ii.eq.4) then
               i=5
            elseif(ii.eq.5) then
               i=6
            elseif(ii.eq.6) then
               i=7
            elseif(ii.eq.8) then
               i=4
            elseif(ii.eq.11) then
               i=0
            else
               write(*,*) '*ERROR in bounadd: unknown DOF: ',
     &              ii
               stop
            endif
            if((fixed).and.(i<5)) then
               val=vold(i)
            elseif(fixed) then
               write(*,*) '*ERROR in bounadd: parameter FIXED cannot'
               write(*,*) '       be used for rotations'
               stop
            endif
            idof=8*(node-1)+i
            call nident(ikboun,idof,nboun,id)
            if(id.gt.0) then
               if(ikboun(id).eq.idof) then
                  j=ilboun(id)
                  xboun(j)=val
                  typeboun(j)=type
                  if(nam.gt.0) iamboun(j)=iamplitude
                  cycle loop
               endif
            endif
            nboun=nboun+1
            if(nboun.gt.nboun_) then
               write(*,*) '*ERROR in bounadd: increase nboun_'
               stop
            endif
            if((nmethod.eq.4).and.(iperturb.le.1)) then
               write(*,*) '*ERROR in bounadd: in a modal dynamic step'
               write(*,*) '       new SPCs are not allowed'
               stop
            endif
            nodeboun(nboun)=node
            ndirboun(nboun)=i
            xboun(nboun)=val
            typeboun(nboun)=type
            if(nam.gt.0) iamboun(nboun)=iamplitude
!
!           updating ikboun and ilboun
!            
            do j=nboun,id+2,-1
               ikboun(j)=ikboun(j-1)
               ilboun(j)=ilboun(j-1)
            enddo
            ikboun(id+1)=idof
            ilboun(id+1)=nboun
         enddo loop
      else
!
!        transformation applies: SPC is MPC in global carthesian
!        coordinates
!
         call transformatrix(trab(1,itr),co(1,node),a)
         do ii=is,ie
            if(ii.le.3) then
               i=ii
            elseif(ii.eq.4) then
               i=5
            elseif(ii.eq.5) then
               i=6
            elseif(ii.eq.6) then
               i=7
            elseif(ii.eq.8) then
               i=4
            elseif(ii.eq.11) then
               i=0
            else
               write(*,*) '*ERROR in bounadd: unknown DOF: ',
     &              ii
               stop
            endif
            if((fixed).and.(i<5)) then
               val=vold(i)
            elseif(fixed) then
               write(*,*) '*ERROR in bounadd: parameter FIXED cannot'
               write(*,*) '       be used for rotations'
               stop
            endif
            if(inotr(2,node).ne.0) then
               newnode=inotr(2,node)
               idofnew=8*(newnode-1)+i
               call nident(ikboun,idofnew,nboun,idnew)
               if(idnew.gt.0) then
                  if(ikboun(idnew).eq.idofnew) then
                     j=ilboun(idnew)
                     xboun(j)=val
                     typeboun(j)=type
                     if(nam.gt.0) iamboun(j)=iamplitude
                     cycle
                  endif
               endif
            else
!
!              new node is generated for the inhomogeneous MPC term
!
               if((nmethod.eq.4).and.(iperturb.le.1)) then
                  write(*,*)'*ERROR in bounadd: in a modal dynamic step'
                  write(*,*) '       new SPCs are not allowed'
                  stop
               endif
               nk=nk+1
               if(nk.gt.nk_) then
                  write(*,*) '*ERROR in bounadd: increase nk_'
                  stop
               endif
               newnode=nk
               inotr(2,node)=newnode
               idofnew=8*(newnode-1)+i
               idnew=nboun
            endif
!
!           new mpc
!
            do number=1,3
               idof=8*(node-1)+number
               call nident(ikmpc,idof,nmpc,id)
               if(id.ne.0) then
                  if(ikmpc(id).eq.idof) cycle
               endif
               if(dabs(a(number,i)).lt.1.d-5) cycle
               nmpc=nmpc+1
               if(nmpc.gt.nmpc_) then
                  write(*,*) '*ERROR in bounadd: increase nmpc_'
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
               exit
            enddo
!
            number=number-1
            do j=1,3
               number=number+1
               if(number.gt.3) number=1
               if(dabs(a(number,i)).lt.1.d-5) cycle
               nodempc(1,mpcfree)=node
               nodempc(2,mpcfree)=number
               coefmpc(mpcfree)=a(number,i)
               mpcfree=nodempc(3,mpcfree)
               if(mpcfree.eq.0) then
                  write(*,*) '*ERROR in bounadd: increase nmpc_'
                  stop
               endif
            enddo
            nodempc(1,mpcfree)=newnode
            nodempc(2,mpcfree)=i
            coefmpc(mpcfree)=-1.d0
            mpcfreenew=nodempc(3,mpcfree)
            if(mpcfreenew.eq.0) then
               write(*,*) '*ERROR in bounadd: increase nmpc_'
               stop
            endif
            nodempc(3,mpcfree)=0
            mpcfree=mpcfreenew
!
!           nonhomogeneous term
!
            nboun=nboun+1
            if(nboun.gt.nboun_) then
               write(*,*) '*ERROR in bounadd: increase nboun_'
               stop
            endif
            nodeboun(nboun)=newnode
            ndirboun(nboun)=i
            xboun(nboun)=val
            typeboun(nboun)=type
            if(nam.gt.0) iamboun(nboun)=iamplitude
!
!           updating ikboun and ilboun
!            
            do j=nboun,idnew+2,-1
               ikboun(j)=ikboun(j-1)
               ilboun(j)=ilboun(j-1)
            enddo
            ikboun(idnew+1)=idofnew
            ilboun(idnew+1)=nboun
!            
         enddo
      endif
!
      return
      end

