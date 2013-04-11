      subroutine anisonl(w,vo,elas,s,ii1,jj1,weight)
!
!     This routine replaces the following lines in e_c3d.f for
!     an anisotropic material
!
!                      do i1=1,3
!                        iii1=ii1+i1-1
!                        do j1=1,3
!                          jjj1=jj1+j1-1
!                          do k1=1,3
!                            do l1=1,3
!                              s(iii1,jjj1)=s(iii1,jjj1)
!     &                              +anisox(i1,k1,j1,l1)*w(k1,l1)
!                              do m1=1,3
!                                s(iii1,jjj1)=s(iii1,jjj1)
!     &                              +anisox(i1,k1,m1,l1)*w(k1,l1)
!     &                                 *vo(j1,m1)
!     &                              +anisox(m1,k1,j1,l1)*w(k1,l1)
!     &                                 *vo(i1,m1)
!                                do n1=1,3
!                                  s(iii1,jjj1)=s(iii1,jjj1)
!     &                                  +anisox(m1,k1,n1,l1)
!     &                                  *w(k1,l1)*vo(i1,m1)*vo(j1,n1)
!                                enddo
!                              enddo
!                            enddo
!                          enddo
!                        enddo
!                      enddo
!
      integer ii1,jj1
      real*8 w(3,3),vo(3,3),elas(21),s(60,60),weight
!
      s(ii1,jj1)=s(ii1,jj1)+((elas( 1)+elas( 1)*vo(1,1)
     &+elas( 7)*vo(1,2)+elas(11)*vo(1,3)+(elas( 1)+elas( 1)*vo(1,1)+
     &elas( 7)*vo(1,2)+elas(11)*vo(1,3))*vo(1,1)+(elas( 7)+elas( 7)*
     &vo(1,1)+elas(10)*vo(1,2)+elas(14)*vo(1,3))*vo(1,2)+(elas(11)+
     &elas(11)*vo(1,1)+elas(14)*vo(1,2)+elas(15)*vo(1,3))*vo(1,3))*
     &w(1,1)
     &+(elas( 7)+elas( 7)*vo(1,1)
     &+elas( 2)*vo(1,2)+elas(16)*vo(1,3)+(elas( 7)+elas( 7)*vo(1,1)+
     &elas( 2)*vo(1,2)+elas(16)*vo(1,3))*vo(1,1)+(elas(10)+elas(10)*
     &vo(1,1)+elas( 8)*vo(1,2)+elas(19)*vo(1,3))*vo(1,2)+(elas(14)+
     &elas(14)*vo(1,1)+elas(12)*vo(1,2)+elas(20)*vo(1,3))*vo(1,3))*
     &w(1,2)
     &+(elas(11)+elas(11)*vo(1,1)
     &+elas(16)*vo(1,2)+elas( 4)*vo(1,3)+(elas(11)+elas(11)*vo(1,1)+
     &elas(16)*vo(1,2)+elas( 4)*vo(1,3))*vo(1,1)+(elas(14)+elas(14)*
     &vo(1,1)+elas(19)*vo(1,2)+elas( 9)*vo(1,3))*vo(1,2)+(elas(15)+
     &elas(15)*vo(1,1)+elas(20)*vo(1,2)+elas(13)*vo(1,3))*vo(1,3))*
     &w(1,3)
     &+(elas( 7)+elas( 7)*vo(1,1)
     &+elas(10)*vo(1,2)+elas(14)*vo(1,3)+(elas( 7)+elas( 7)*vo(1,1)+
     &elas(10)*vo(1,2)+elas(14)*vo(1,3))*vo(1,1)+(elas( 2)+elas( 2)*
     &vo(1,1)+elas( 8)*vo(1,2)+elas(12)*vo(1,3))*vo(1,2)+(elas(16)+
     &elas(16)*vo(1,1)+elas(19)*vo(1,2)+elas(20)*vo(1,3))*vo(1,3))*
     &w(2,1)
     &+(elas(10)+elas(10)*vo(1,1)
     &+elas( 8)*vo(1,2)+elas(19)*vo(1,3)+(elas(10)+elas(10)*vo(1,1)+
     &elas( 8)*vo(1,2)+elas(19)*vo(1,3))*vo(1,1)+(elas( 8)+elas( 8)*
     &vo(1,1)+elas( 3)*vo(1,2)+elas(17)*vo(1,3))*vo(1,2)+(elas(19)+
     &elas(19)*vo(1,1)+elas(17)*vo(1,2)+elas(21)*vo(1,3))*vo(1,3))*
     &w(2,2)
     &+(elas(14)+elas(14)*vo(1,1)
     &+elas(19)*vo(1,2)+elas( 9)*vo(1,3)+(elas(14)+elas(14)*vo(1,1)+
     &elas(19)*vo(1,2)+elas( 9)*vo(1,3))*vo(1,1)+(elas(12)+elas(12)*
     &vo(1,1)+elas(17)*vo(1,2)+elas( 5)*vo(1,3))*vo(1,2)+(elas(20)+
     &elas(20)*vo(1,1)+elas(21)*vo(1,2)+elas(18)*vo(1,3))*vo(1,3))*
     &w(2,3)
     &+(elas(11)+elas(11)*vo(1,1)
     &+elas(14)*vo(1,2)+elas(15)*vo(1,3)+(elas(11)+elas(11)*vo(1,1)+
     &elas(14)*vo(1,2)+elas(15)*vo(1,3))*vo(1,1)+(elas(16)+elas(16)*
     &vo(1,1)+elas(19)*vo(1,2)+elas(20)*vo(1,3))*vo(1,2)+(elas( 4)+
     &elas( 4)*vo(1,1)+elas( 9)*vo(1,2)+elas(13)*vo(1,3))*vo(1,3))*
     &w(3,1)
     &+(elas(14)+elas(14)*vo(1,1)
     &+elas(12)*vo(1,2)+elas(20)*vo(1,3)+(elas(14)+elas(14)*vo(1,1)+
     &elas(12)*vo(1,2)+elas(20)*vo(1,3))*vo(1,1)+(elas(19)+elas(19)*
     &vo(1,1)+elas(17)*vo(1,2)+elas(21)*vo(1,3))*vo(1,2)+(elas( 9)+
     &elas( 9)*vo(1,1)+elas( 5)*vo(1,2)+elas(18)*vo(1,3))*vo(1,3))*
     &w(3,2)
     &+(elas(15)+elas(15)*vo(1,1)
     &+elas(20)*vo(1,2)+elas(13)*vo(1,3)+(elas(15)+elas(15)*vo(1,1)+
     &elas(20)*vo(1,2)+elas(13)*vo(1,3))*vo(1,1)+(elas(20)+elas(20)*
     &vo(1,1)+elas(21)*vo(1,2)+elas(18)*vo(1,3))*vo(1,2)+(elas(13)+
     &elas(13)*vo(1,1)+elas(18)*vo(1,2)+elas( 6)*vo(1,3))*vo(1,3))*
     &w(3,3))*weight
      s(ii1,jj1+1)=s(ii1,jj1+1)+((elas( 7)+elas( 1)*vo(2,1)
     &+elas( 7)*vo(2,2)+elas(11)*vo(2,3)+(elas( 7)+elas( 1)*vo(2,1)+
     &elas( 7)*vo(2,2)+elas(11)*vo(2,3))*vo(1,1)+(elas(10)+elas( 7)*
     &vo(2,1)+elas(10)*vo(2,2)+elas(14)*vo(2,3))*vo(1,2)+(elas(14)+
     &elas(11)*vo(2,1)+elas(14)*vo(2,2)+elas(15)*vo(2,3))*vo(1,3))*
     &w(1,1)
     &+(elas( 2)+elas( 7)*vo(2,1)
     &+elas( 2)*vo(2,2)+elas(16)*vo(2,3)+(elas( 2)+elas( 7)*vo(2,1)+
     &elas( 2)*vo(2,2)+elas(16)*vo(2,3))*vo(1,1)+(elas( 8)+elas(10)*
     &vo(2,1)+elas( 8)*vo(2,2)+elas(19)*vo(2,3))*vo(1,2)+(elas(12)+
     &elas(14)*vo(2,1)+elas(12)*vo(2,2)+elas(20)*vo(2,3))*vo(1,3))*
     &w(1,2)
     &+(elas(16)+elas(11)*vo(2,1)
     &+elas(16)*vo(2,2)+elas( 4)*vo(2,3)+(elas(16)+elas(11)*vo(2,1)+
     &elas(16)*vo(2,2)+elas( 4)*vo(2,3))*vo(1,1)+(elas(19)+elas(14)*
     &vo(2,1)+elas(19)*vo(2,2)+elas( 9)*vo(2,3))*vo(1,2)+(elas(20)+
     &elas(15)*vo(2,1)+elas(20)*vo(2,2)+elas(13)*vo(2,3))*vo(1,3))*
     &w(1,3)
     &+(elas(10)+elas( 7)*vo(2,1)
     &+elas(10)*vo(2,2)+elas(14)*vo(2,3)+(elas(10)+elas( 7)*vo(2,1)+
     &elas(10)*vo(2,2)+elas(14)*vo(2,3))*vo(1,1)+(elas( 8)+elas( 2)*
     &vo(2,1)+elas( 8)*vo(2,2)+elas(12)*vo(2,3))*vo(1,2)+(elas(19)+
     &elas(16)*vo(2,1)+elas(19)*vo(2,2)+elas(20)*vo(2,3))*vo(1,3))*
     &w(2,1)
     &+(elas( 8)+elas(10)*vo(2,1)
     &+elas( 8)*vo(2,2)+elas(19)*vo(2,3)+(elas( 8)+elas(10)*vo(2,1)+
     &elas( 8)*vo(2,2)+elas(19)*vo(2,3))*vo(1,1)+(elas( 3)+elas( 8)*
     &vo(2,1)+elas( 3)*vo(2,2)+elas(17)*vo(2,3))*vo(1,2)+(elas(17)+
     &elas(19)*vo(2,1)+elas(17)*vo(2,2)+elas(21)*vo(2,3))*vo(1,3))*
     &w(2,2)
     &+(elas(19)+elas(14)*vo(2,1)
     &+elas(19)*vo(2,2)+elas( 9)*vo(2,3)+(elas(19)+elas(14)*vo(2,1)+
     &elas(19)*vo(2,2)+elas( 9)*vo(2,3))*vo(1,1)+(elas(17)+elas(12)*
     &vo(2,1)+elas(17)*vo(2,2)+elas( 5)*vo(2,3))*vo(1,2)+(elas(21)+
     &elas(20)*vo(2,1)+elas(21)*vo(2,2)+elas(18)*vo(2,3))*vo(1,3))*
     &w(2,3)
     &+(elas(14)+elas(11)*vo(2,1)
     &+elas(14)*vo(2,2)+elas(15)*vo(2,3)+(elas(14)+elas(11)*vo(2,1)+
     &elas(14)*vo(2,2)+elas(15)*vo(2,3))*vo(1,1)+(elas(19)+elas(16)*
     &vo(2,1)+elas(19)*vo(2,2)+elas(20)*vo(2,3))*vo(1,2)+(elas( 9)+
     &elas( 4)*vo(2,1)+elas( 9)*vo(2,2)+elas(13)*vo(2,3))*vo(1,3))*
     &w(3,1)
     &+(elas(12)+elas(14)*vo(2,1)
     &+elas(12)*vo(2,2)+elas(20)*vo(2,3)+(elas(12)+elas(14)*vo(2,1)+
     &elas(12)*vo(2,2)+elas(20)*vo(2,3))*vo(1,1)+(elas(17)+elas(19)*
     &vo(2,1)+elas(17)*vo(2,2)+elas(21)*vo(2,3))*vo(1,2)+(elas( 5)+
     &elas( 9)*vo(2,1)+elas( 5)*vo(2,2)+elas(18)*vo(2,3))*vo(1,3))*
     &w(3,2)
     &+(elas(20)+elas(15)*vo(2,1)
     &+elas(20)*vo(2,2)+elas(13)*vo(2,3)+(elas(20)+elas(15)*vo(2,1)+
     &elas(20)*vo(2,2)+elas(13)*vo(2,3))*vo(1,1)+(elas(21)+elas(20)*
     &vo(2,1)+elas(21)*vo(2,2)+elas(18)*vo(2,3))*vo(1,2)+(elas(18)+
     &elas(13)*vo(2,1)+elas(18)*vo(2,2)+elas( 6)*vo(2,3))*vo(1,3))*
     &w(3,3))*weight
      s(ii1,jj1+2)=s(ii1,jj1+2)+((elas(11)+elas( 1)*vo(3,1)
     &+elas( 7)*vo(3,2)+elas(11)*vo(3,3)+(elas(11)+elas( 1)*vo(3,1)+
     &elas( 7)*vo(3,2)+elas(11)*vo(3,3))*vo(1,1)+(elas(14)+elas( 7)*
     &vo(3,1)+elas(10)*vo(3,2)+elas(14)*vo(3,3))*vo(1,2)+(elas(15)+
     &elas(11)*vo(3,1)+elas(14)*vo(3,2)+elas(15)*vo(3,3))*vo(1,3))*
     &w(1,1)
     &+(elas(16)+elas( 7)*vo(3,1)
     &+elas( 2)*vo(3,2)+elas(16)*vo(3,3)+(elas(16)+elas( 7)*vo(3,1)+
     &elas( 2)*vo(3,2)+elas(16)*vo(3,3))*vo(1,1)+(elas(19)+elas(10)*
     &vo(3,1)+elas( 8)*vo(3,2)+elas(19)*vo(3,3))*vo(1,2)+(elas(20)+
     &elas(14)*vo(3,1)+elas(12)*vo(3,2)+elas(20)*vo(3,3))*vo(1,3))*
     &w(1,2)
     &+(elas( 4)+elas(11)*vo(3,1)
     &+elas(16)*vo(3,2)+elas( 4)*vo(3,3)+(elas( 4)+elas(11)*vo(3,1)+
     &elas(16)*vo(3,2)+elas( 4)*vo(3,3))*vo(1,1)+(elas( 9)+elas(14)*
     &vo(3,1)+elas(19)*vo(3,2)+elas( 9)*vo(3,3))*vo(1,2)+(elas(13)+
     &elas(15)*vo(3,1)+elas(20)*vo(3,2)+elas(13)*vo(3,3))*vo(1,3))*
     &w(1,3)
     &+(elas(14)+elas( 7)*vo(3,1)
     &+elas(10)*vo(3,2)+elas(14)*vo(3,3)+(elas(14)+elas( 7)*vo(3,1)+
     &elas(10)*vo(3,2)+elas(14)*vo(3,3))*vo(1,1)+(elas(12)+elas( 2)*
     &vo(3,1)+elas( 8)*vo(3,2)+elas(12)*vo(3,3))*vo(1,2)+(elas(20)+
     &elas(16)*vo(3,1)+elas(19)*vo(3,2)+elas(20)*vo(3,3))*vo(1,3))*
     &w(2,1)
     &+(elas(19)+elas(10)*vo(3,1)
     &+elas( 8)*vo(3,2)+elas(19)*vo(3,3)+(elas(19)+elas(10)*vo(3,1)+
     &elas( 8)*vo(3,2)+elas(19)*vo(3,3))*vo(1,1)+(elas(17)+elas( 8)*
     &vo(3,1)+elas( 3)*vo(3,2)+elas(17)*vo(3,3))*vo(1,2)+(elas(21)+
     &elas(19)*vo(3,1)+elas(17)*vo(3,2)+elas(21)*vo(3,3))*vo(1,3))*
     &w(2,2)
     &+(elas( 9)+elas(14)*vo(3,1)
     &+elas(19)*vo(3,2)+elas( 9)*vo(3,3)+(elas( 9)+elas(14)*vo(3,1)+
     &elas(19)*vo(3,2)+elas( 9)*vo(3,3))*vo(1,1)+(elas( 5)+elas(12)*
     &vo(3,1)+elas(17)*vo(3,2)+elas( 5)*vo(3,3))*vo(1,2)+(elas(18)+
     &elas(20)*vo(3,1)+elas(21)*vo(3,2)+elas(18)*vo(3,3))*vo(1,3))*
     &w(2,3)
     &+(elas(15)+elas(11)*vo(3,1)
     &+elas(14)*vo(3,2)+elas(15)*vo(3,3)+(elas(15)+elas(11)*vo(3,1)+
     &elas(14)*vo(3,2)+elas(15)*vo(3,3))*vo(1,1)+(elas(20)+elas(16)*
     &vo(3,1)+elas(19)*vo(3,2)+elas(20)*vo(3,3))*vo(1,2)+(elas(13)+
     &elas( 4)*vo(3,1)+elas( 9)*vo(3,2)+elas(13)*vo(3,3))*vo(1,3))*
     &w(3,1)
     &+(elas(20)+elas(14)*vo(3,1)
     &+elas(12)*vo(3,2)+elas(20)*vo(3,3)+(elas(20)+elas(14)*vo(3,1)+
     &elas(12)*vo(3,2)+elas(20)*vo(3,3))*vo(1,1)+(elas(21)+elas(19)*
     &vo(3,1)+elas(17)*vo(3,2)+elas(21)*vo(3,3))*vo(1,2)+(elas(18)+
     &elas( 9)*vo(3,1)+elas( 5)*vo(3,2)+elas(18)*vo(3,3))*vo(1,3))*
     &w(3,2)
     &+(elas(13)+elas(15)*vo(3,1)
     &+elas(20)*vo(3,2)+elas(13)*vo(3,3)+(elas(13)+elas(15)*vo(3,1)+
     &elas(20)*vo(3,2)+elas(13)*vo(3,3))*vo(1,1)+(elas(18)+elas(20)*
     &vo(3,1)+elas(21)*vo(3,2)+elas(18)*vo(3,3))*vo(1,2)+(elas( 6)+
     &elas(13)*vo(3,1)+elas(18)*vo(3,2)+elas( 6)*vo(3,3))*vo(1,3))*
     &w(3,3))*weight
      s(ii1+1,jj1)=s(ii1+1,jj1)+((elas( 7)+elas( 7)*vo(1,1)
     &+elas(10)*vo(1,2)+elas(14)*vo(1,3)+(elas( 1)+elas( 1)*vo(1,1)+
     &elas( 7)*vo(1,2)+elas(11)*vo(1,3))*vo(2,1)+(elas( 7)+elas( 7)*
     &vo(1,1)+elas(10)*vo(1,2)+elas(14)*vo(1,3))*vo(2,2)+(elas(11)+
     &elas(11)*vo(1,1)+elas(14)*vo(1,2)+elas(15)*vo(1,3))*vo(2,3))*
     &w(1,1)
     &+(elas(10)+elas(10)*vo(1,1)
     &+elas( 8)*vo(1,2)+elas(19)*vo(1,3)+(elas( 7)+elas( 7)*vo(1,1)+
     &elas( 2)*vo(1,2)+elas(16)*vo(1,3))*vo(2,1)+(elas(10)+elas(10)*
     &vo(1,1)+elas( 8)*vo(1,2)+elas(19)*vo(1,3))*vo(2,2)+(elas(14)+
     &elas(14)*vo(1,1)+elas(12)*vo(1,2)+elas(20)*vo(1,3))*vo(2,3))*
     &w(1,2)
     &+(elas(14)+elas(14)*vo(1,1)
     &+elas(19)*vo(1,2)+elas( 9)*vo(1,3)+(elas(11)+elas(11)*vo(1,1)+
     &elas(16)*vo(1,2)+elas( 4)*vo(1,3))*vo(2,1)+(elas(14)+elas(14)*
     &vo(1,1)+elas(19)*vo(1,2)+elas( 9)*vo(1,3))*vo(2,2)+(elas(15)+
     &elas(15)*vo(1,1)+elas(20)*vo(1,2)+elas(13)*vo(1,3))*vo(2,3))*
     &w(1,3)
     &+(elas( 2)+elas( 2)*vo(1,1)
     &+elas( 8)*vo(1,2)+elas(12)*vo(1,3)+(elas( 7)+elas( 7)*vo(1,1)+
     &elas(10)*vo(1,2)+elas(14)*vo(1,3))*vo(2,1)+(elas( 2)+elas( 2)*
     &vo(1,1)+elas( 8)*vo(1,2)+elas(12)*vo(1,3))*vo(2,2)+(elas(16)+
     &elas(16)*vo(1,1)+elas(19)*vo(1,2)+elas(20)*vo(1,3))*vo(2,3))*
     &w(2,1)
     &+(elas( 8)+elas( 8)*vo(1,1)
     &+elas( 3)*vo(1,2)+elas(17)*vo(1,3)+(elas(10)+elas(10)*vo(1,1)+
     &elas( 8)*vo(1,2)+elas(19)*vo(1,3))*vo(2,1)+(elas( 8)+elas( 8)*
     &vo(1,1)+elas( 3)*vo(1,2)+elas(17)*vo(1,3))*vo(2,2)+(elas(19)+
     &elas(19)*vo(1,1)+elas(17)*vo(1,2)+elas(21)*vo(1,3))*vo(2,3))*
     &w(2,2)
     &+(elas(12)+elas(12)*vo(1,1)
     &+elas(17)*vo(1,2)+elas( 5)*vo(1,3)+(elas(14)+elas(14)*vo(1,1)+
     &elas(19)*vo(1,2)+elas( 9)*vo(1,3))*vo(2,1)+(elas(12)+elas(12)*
     &vo(1,1)+elas(17)*vo(1,2)+elas( 5)*vo(1,3))*vo(2,2)+(elas(20)+
     &elas(20)*vo(1,1)+elas(21)*vo(1,2)+elas(18)*vo(1,3))*vo(2,3))*
     &w(2,3)
     &+(elas(16)+elas(16)*vo(1,1)
     &+elas(19)*vo(1,2)+elas(20)*vo(1,3)+(elas(11)+elas(11)*vo(1,1)+
     &elas(14)*vo(1,2)+elas(15)*vo(1,3))*vo(2,1)+(elas(16)+elas(16)*
     &vo(1,1)+elas(19)*vo(1,2)+elas(20)*vo(1,3))*vo(2,2)+(elas( 4)+
     &elas( 4)*vo(1,1)+elas( 9)*vo(1,2)+elas(13)*vo(1,3))*vo(2,3))*
     &w(3,1)
     &+(elas(19)+elas(19)*vo(1,1)
     &+elas(17)*vo(1,2)+elas(21)*vo(1,3)+(elas(14)+elas(14)*vo(1,1)+
     &elas(12)*vo(1,2)+elas(20)*vo(1,3))*vo(2,1)+(elas(19)+elas(19)*
     &vo(1,1)+elas(17)*vo(1,2)+elas(21)*vo(1,3))*vo(2,2)+(elas( 9)+
     &elas( 9)*vo(1,1)+elas( 5)*vo(1,2)+elas(18)*vo(1,3))*vo(2,3))*
     &w(3,2)
     &+(elas(20)+elas(20)*vo(1,1)
     &+elas(21)*vo(1,2)+elas(18)*vo(1,3)+(elas(15)+elas(15)*vo(1,1)+
     &elas(20)*vo(1,2)+elas(13)*vo(1,3))*vo(2,1)+(elas(20)+elas(20)*
     &vo(1,1)+elas(21)*vo(1,2)+elas(18)*vo(1,3))*vo(2,2)+(elas(13)+
     &elas(13)*vo(1,1)+elas(18)*vo(1,2)+elas( 6)*vo(1,3))*vo(2,3))*
     &w(3,3))*weight
      s(ii1+1,jj1+1)=s(ii1+1,jj1+1)+((elas(10)+elas( 7)*vo(2,1)
     &+elas(10)*vo(2,2)+elas(14)*vo(2,3)+(elas( 7)+elas( 1)*vo(2,1)+
     &elas( 7)*vo(2,2)+elas(11)*vo(2,3))*vo(2,1)+(elas(10)+elas( 7)*
     &vo(2,1)+elas(10)*vo(2,2)+elas(14)*vo(2,3))*vo(2,2)+(elas(14)+
     &elas(11)*vo(2,1)+elas(14)*vo(2,2)+elas(15)*vo(2,3))*vo(2,3))*
     &w(1,1)
     &+(elas( 8)+elas(10)*vo(2,1)
     &+elas( 8)*vo(2,2)+elas(19)*vo(2,3)+(elas( 2)+elas( 7)*vo(2,1)+
     &elas( 2)*vo(2,2)+elas(16)*vo(2,3))*vo(2,1)+(elas( 8)+elas(10)*
     &vo(2,1)+elas( 8)*vo(2,2)+elas(19)*vo(2,3))*vo(2,2)+(elas(12)+
     &elas(14)*vo(2,1)+elas(12)*vo(2,2)+elas(20)*vo(2,3))*vo(2,3))*
     &w(1,2)
     &+(elas(19)+elas(14)*vo(2,1)
     &+elas(19)*vo(2,2)+elas( 9)*vo(2,3)+(elas(16)+elas(11)*vo(2,1)+
     &elas(16)*vo(2,2)+elas( 4)*vo(2,3))*vo(2,1)+(elas(19)+elas(14)*
     &vo(2,1)+elas(19)*vo(2,2)+elas( 9)*vo(2,3))*vo(2,2)+(elas(20)+
     &elas(15)*vo(2,1)+elas(20)*vo(2,2)+elas(13)*vo(2,3))*vo(2,3))*
     &w(1,3)
     &+(elas( 8)+elas( 2)*vo(2,1)
     &+elas( 8)*vo(2,2)+elas(12)*vo(2,3)+(elas(10)+elas( 7)*vo(2,1)+
     &elas(10)*vo(2,2)+elas(14)*vo(2,3))*vo(2,1)+(elas( 8)+elas( 2)*
     &vo(2,1)+elas( 8)*vo(2,2)+elas(12)*vo(2,3))*vo(2,2)+(elas(19)+
     &elas(16)*vo(2,1)+elas(19)*vo(2,2)+elas(20)*vo(2,3))*vo(2,3))*
     &w(2,1)
     &+(elas( 3)+elas( 8)*vo(2,1)
     &+elas( 3)*vo(2,2)+elas(17)*vo(2,3)+(elas( 8)+elas(10)*vo(2,1)+
     &elas( 8)*vo(2,2)+elas(19)*vo(2,3))*vo(2,1)+(elas( 3)+elas( 8)*
     &vo(2,1)+elas( 3)*vo(2,2)+elas(17)*vo(2,3))*vo(2,2)+(elas(17)+
     &elas(19)*vo(2,1)+elas(17)*vo(2,2)+elas(21)*vo(2,3))*vo(2,3))*
     &w(2,2)
     &+(elas(17)+elas(12)*vo(2,1)
     &+elas(17)*vo(2,2)+elas( 5)*vo(2,3)+(elas(19)+elas(14)*vo(2,1)+
     &elas(19)*vo(2,2)+elas( 9)*vo(2,3))*vo(2,1)+(elas(17)+elas(12)*
     &vo(2,1)+elas(17)*vo(2,2)+elas( 5)*vo(2,3))*vo(2,2)+(elas(21)+
     &elas(20)*vo(2,1)+elas(21)*vo(2,2)+elas(18)*vo(2,3))*vo(2,3))*
     &w(2,3)
     &+(elas(19)+elas(16)*vo(2,1)
     &+elas(19)*vo(2,2)+elas(20)*vo(2,3)+(elas(14)+elas(11)*vo(2,1)+
     &elas(14)*vo(2,2)+elas(15)*vo(2,3))*vo(2,1)+(elas(19)+elas(16)*
     &vo(2,1)+elas(19)*vo(2,2)+elas(20)*vo(2,3))*vo(2,2)+(elas( 9)+
     &elas( 4)*vo(2,1)+elas( 9)*vo(2,2)+elas(13)*vo(2,3))*vo(2,3))*
     &w(3,1)
     &+(elas(17)+elas(19)*vo(2,1)
     &+elas(17)*vo(2,2)+elas(21)*vo(2,3)+(elas(12)+elas(14)*vo(2,1)+
     &elas(12)*vo(2,2)+elas(20)*vo(2,3))*vo(2,1)+(elas(17)+elas(19)*
     &vo(2,1)+elas(17)*vo(2,2)+elas(21)*vo(2,3))*vo(2,2)+(elas( 5)+
     &elas( 9)*vo(2,1)+elas( 5)*vo(2,2)+elas(18)*vo(2,3))*vo(2,3))*
     &w(3,2)
     &+(elas(21)+elas(20)*vo(2,1)
     &+elas(21)*vo(2,2)+elas(18)*vo(2,3)+(elas(20)+elas(15)*vo(2,1)+
     &elas(20)*vo(2,2)+elas(13)*vo(2,3))*vo(2,1)+(elas(21)+elas(20)*
     &vo(2,1)+elas(21)*vo(2,2)+elas(18)*vo(2,3))*vo(2,2)+(elas(18)+
     &elas(13)*vo(2,1)+elas(18)*vo(2,2)+elas( 6)*vo(2,3))*vo(2,3))*
     &w(3,3))*weight
      s(ii1+1,jj1+2)=s(ii1+1,jj1+2)+((elas(14)+elas( 7)*vo(3,1)
     &+elas(10)*vo(3,2)+elas(14)*vo(3,3)+(elas(11)+elas( 1)*vo(3,1)+
     &elas( 7)*vo(3,2)+elas(11)*vo(3,3))*vo(2,1)+(elas(14)+elas( 7)*
     &vo(3,1)+elas(10)*vo(3,2)+elas(14)*vo(3,3))*vo(2,2)+(elas(15)+
     &elas(11)*vo(3,1)+elas(14)*vo(3,2)+elas(15)*vo(3,3))*vo(2,3))*
     &w(1,1)
     &+(elas(19)+elas(10)*vo(3,1)
     &+elas( 8)*vo(3,2)+elas(19)*vo(3,3)+(elas(16)+elas( 7)*vo(3,1)+
     &elas( 2)*vo(3,2)+elas(16)*vo(3,3))*vo(2,1)+(elas(19)+elas(10)*
     &vo(3,1)+elas( 8)*vo(3,2)+elas(19)*vo(3,3))*vo(2,2)+(elas(20)+
     &elas(14)*vo(3,1)+elas(12)*vo(3,2)+elas(20)*vo(3,3))*vo(2,3))*
     &w(1,2)
     &+(elas( 9)+elas(14)*vo(3,1)
     &+elas(19)*vo(3,2)+elas( 9)*vo(3,3)+(elas( 4)+elas(11)*vo(3,1)+
     &elas(16)*vo(3,2)+elas( 4)*vo(3,3))*vo(2,1)+(elas( 9)+elas(14)*
     &vo(3,1)+elas(19)*vo(3,2)+elas( 9)*vo(3,3))*vo(2,2)+(elas(13)+
     &elas(15)*vo(3,1)+elas(20)*vo(3,2)+elas(13)*vo(3,3))*vo(2,3))*
     &w(1,3)
     &+(elas(12)+elas( 2)*vo(3,1)
     &+elas( 8)*vo(3,2)+elas(12)*vo(3,3)+(elas(14)+elas( 7)*vo(3,1)+
     &elas(10)*vo(3,2)+elas(14)*vo(3,3))*vo(2,1)+(elas(12)+elas( 2)*
     &vo(3,1)+elas( 8)*vo(3,2)+elas(12)*vo(3,3))*vo(2,2)+(elas(20)+
     &elas(16)*vo(3,1)+elas(19)*vo(3,2)+elas(20)*vo(3,3))*vo(2,3))*
     &w(2,1)
     &+(elas(17)+elas( 8)*vo(3,1)
     &+elas( 3)*vo(3,2)+elas(17)*vo(3,3)+(elas(19)+elas(10)*vo(3,1)+
     &elas( 8)*vo(3,2)+elas(19)*vo(3,3))*vo(2,1)+(elas(17)+elas( 8)*
     &vo(3,1)+elas( 3)*vo(3,2)+elas(17)*vo(3,3))*vo(2,2)+(elas(21)+
     &elas(19)*vo(3,1)+elas(17)*vo(3,2)+elas(21)*vo(3,3))*vo(2,3))*
     &w(2,2)
     &+(elas( 5)+elas(12)*vo(3,1)
     &+elas(17)*vo(3,2)+elas( 5)*vo(3,3)+(elas( 9)+elas(14)*vo(3,1)+
     &elas(19)*vo(3,2)+elas( 9)*vo(3,3))*vo(2,1)+(elas( 5)+elas(12)*
     &vo(3,1)+elas(17)*vo(3,2)+elas( 5)*vo(3,3))*vo(2,2)+(elas(18)+
     &elas(20)*vo(3,1)+elas(21)*vo(3,2)+elas(18)*vo(3,3))*vo(2,3))*
     &w(2,3)
     &+(elas(20)+elas(16)*vo(3,1)
     &+elas(19)*vo(3,2)+elas(20)*vo(3,3)+(elas(15)+elas(11)*vo(3,1)+
     &elas(14)*vo(3,2)+elas(15)*vo(3,3))*vo(2,1)+(elas(20)+elas(16)*
     &vo(3,1)+elas(19)*vo(3,2)+elas(20)*vo(3,3))*vo(2,2)+(elas(13)+
     &elas( 4)*vo(3,1)+elas( 9)*vo(3,2)+elas(13)*vo(3,3))*vo(2,3))*
     &w(3,1)
     &+(elas(21)+elas(19)*vo(3,1)
     &+elas(17)*vo(3,2)+elas(21)*vo(3,3)+(elas(20)+elas(14)*vo(3,1)+
     &elas(12)*vo(3,2)+elas(20)*vo(3,3))*vo(2,1)+(elas(21)+elas(19)*
     &vo(3,1)+elas(17)*vo(3,2)+elas(21)*vo(3,3))*vo(2,2)+(elas(18)+
     &elas( 9)*vo(3,1)+elas( 5)*vo(3,2)+elas(18)*vo(3,3))*vo(2,3))*
     &w(3,2)
     &+(elas(18)+elas(20)*vo(3,1)
     &+elas(21)*vo(3,2)+elas(18)*vo(3,3)+(elas(13)+elas(15)*vo(3,1)+
     &elas(20)*vo(3,2)+elas(13)*vo(3,3))*vo(2,1)+(elas(18)+elas(20)*
     &vo(3,1)+elas(21)*vo(3,2)+elas(18)*vo(3,3))*vo(2,2)+(elas( 6)+
     &elas(13)*vo(3,1)+elas(18)*vo(3,2)+elas( 6)*vo(3,3))*vo(2,3))*
     &w(3,3))*weight
      s(ii1+2,jj1)=s(ii1+2,jj1+0)+((elas(11)+elas(11)*vo(1,1)
     &+elas(14)*vo(1,2)+elas(15)*vo(1,3)+(elas( 1)+elas( 1)*vo(1,1)+
     &elas( 7)*vo(1,2)+elas(11)*vo(1,3))*vo(3,1)+(elas( 7)+elas( 7)*
     &vo(1,1)+elas(10)*vo(1,2)+elas(14)*vo(1,3))*vo(3,2)+(elas(11)+
     &elas(11)*vo(1,1)+elas(14)*vo(1,2)+elas(15)*vo(1,3))*vo(3,3))*
     &w(1,1)
     &+(elas(14)+elas(14)*vo(1,1)
     &+elas(12)*vo(1,2)+elas(20)*vo(1,3)+(elas( 7)+elas( 7)*vo(1,1)+
     &elas( 2)*vo(1,2)+elas(16)*vo(1,3))*vo(3,1)+(elas(10)+elas(10)*
     &vo(1,1)+elas( 8)*vo(1,2)+elas(19)*vo(1,3))*vo(3,2)+(elas(14)+
     &elas(14)*vo(1,1)+elas(12)*vo(1,2)+elas(20)*vo(1,3))*vo(3,3))*
     &w(1,2)
     &+(elas(15)+elas(15)*vo(1,1)
     &+elas(20)*vo(1,2)+elas(13)*vo(1,3)+(elas(11)+elas(11)*vo(1,1)+
     &elas(16)*vo(1,2)+elas( 4)*vo(1,3))*vo(3,1)+(elas(14)+elas(14)*
     &vo(1,1)+elas(19)*vo(1,2)+elas( 9)*vo(1,3))*vo(3,2)+(elas(15)+
     &elas(15)*vo(1,1)+elas(20)*vo(1,2)+elas(13)*vo(1,3))*vo(3,3))*
     &w(1,3)
     &+(elas(16)+elas(16)*vo(1,1)
     &+elas(19)*vo(1,2)+elas(20)*vo(1,3)+(elas( 7)+elas( 7)*vo(1,1)+
     &elas(10)*vo(1,2)+elas(14)*vo(1,3))*vo(3,1)+(elas( 2)+elas( 2)*
     &vo(1,1)+elas( 8)*vo(1,2)+elas(12)*vo(1,3))*vo(3,2)+(elas(16)+
     &elas(16)*vo(1,1)+elas(19)*vo(1,2)+elas(20)*vo(1,3))*vo(3,3))*
     &w(2,1)
     &+(elas(19)+elas(19)*vo(1,1)
     &+elas(17)*vo(1,2)+elas(21)*vo(1,3)+(elas(10)+elas(10)*vo(1,1)+
     &elas( 8)*vo(1,2)+elas(19)*vo(1,3))*vo(3,1)+(elas( 8)+elas( 8)*
     &vo(1,1)+elas( 3)*vo(1,2)+elas(17)*vo(1,3))*vo(3,2)+(elas(19)+
     &elas(19)*vo(1,1)+elas(17)*vo(1,2)+elas(21)*vo(1,3))*vo(3,3))*
     &w(2,2)
     &+(elas(20)+elas(20)*vo(1,1)
     &+elas(21)*vo(1,2)+elas(18)*vo(1,3)+(elas(14)+elas(14)*vo(1,1)+
     &elas(19)*vo(1,2)+elas( 9)*vo(1,3))*vo(3,1)+(elas(12)+elas(12)*
     &vo(1,1)+elas(17)*vo(1,2)+elas( 5)*vo(1,3))*vo(3,2)+(elas(20)+
     &elas(20)*vo(1,1)+elas(21)*vo(1,2)+elas(18)*vo(1,3))*vo(3,3))*
     &w(2,3)
     &+(elas( 4)+elas( 4)*vo(1,1)
     &+elas( 9)*vo(1,2)+elas(13)*vo(1,3)+(elas(11)+elas(11)*vo(1,1)+
     &elas(14)*vo(1,2)+elas(15)*vo(1,3))*vo(3,1)+(elas(16)+elas(16)*
     &vo(1,1)+elas(19)*vo(1,2)+elas(20)*vo(1,3))*vo(3,2)+(elas( 4)+
     &elas( 4)*vo(1,1)+elas( 9)*vo(1,2)+elas(13)*vo(1,3))*vo(3,3))*
     &w(3,1)
     &+(elas( 9)+elas( 9)*vo(1,1)
     &+elas( 5)*vo(1,2)+elas(18)*vo(1,3)+(elas(14)+elas(14)*vo(1,1)+
     &elas(12)*vo(1,2)+elas(20)*vo(1,3))*vo(3,1)+(elas(19)+elas(19)*
     &vo(1,1)+elas(17)*vo(1,2)+elas(21)*vo(1,3))*vo(3,2)+(elas( 9)+
     &elas( 9)*vo(1,1)+elas( 5)*vo(1,2)+elas(18)*vo(1,3))*vo(3,3))*
     &w(3,2)
     &+(elas(13)+elas(13)*vo(1,1)
     &+elas(18)*vo(1,2)+elas( 6)*vo(1,3)+(elas(15)+elas(15)*vo(1,1)+
     &elas(20)*vo(1,2)+elas(13)*vo(1,3))*vo(3,1)+(elas(20)+elas(20)*
     &vo(1,1)+elas(21)*vo(1,2)+elas(18)*vo(1,3))*vo(3,2)+(elas(13)+
     &elas(13)*vo(1,1)+elas(18)*vo(1,2)+elas( 6)*vo(1,3))*vo(3,3))*
     &w(3,3))*weight
      s(ii1+2,jj1+1)=s(ii1+2,jj1+1)+((elas(14)+elas(11)*vo(2,1)
     &+elas(14)*vo(2,2)+elas(15)*vo(2,3)+(elas( 7)+elas( 1)*vo(2,1)+
     &elas( 7)*vo(2,2)+elas(11)*vo(2,3))*vo(3,1)+(elas(10)+elas( 7)*
     &vo(2,1)+elas(10)*vo(2,2)+elas(14)*vo(2,3))*vo(3,2)+(elas(14)+
     &elas(11)*vo(2,1)+elas(14)*vo(2,2)+elas(15)*vo(2,3))*vo(3,3))*
     &w(1,1)
     &+(elas(12)+elas(14)*vo(2,1)
     &+elas(12)*vo(2,2)+elas(20)*vo(2,3)+(elas( 2)+elas( 7)*vo(2,1)+
     &elas( 2)*vo(2,2)+elas(16)*vo(2,3))*vo(3,1)+(elas( 8)+elas(10)*
     &vo(2,1)+elas( 8)*vo(2,2)+elas(19)*vo(2,3))*vo(3,2)+(elas(12)+
     &elas(14)*vo(2,1)+elas(12)*vo(2,2)+elas(20)*vo(2,3))*vo(3,3))*
     &w(1,2)
     &+(elas(20)+elas(15)*vo(2,1)
     &+elas(20)*vo(2,2)+elas(13)*vo(2,3)+(elas(16)+elas(11)*vo(2,1)+
     &elas(16)*vo(2,2)+elas( 4)*vo(2,3))*vo(3,1)+(elas(19)+elas(14)*
     &vo(2,1)+elas(19)*vo(2,2)+elas( 9)*vo(2,3))*vo(3,2)+(elas(20)+
     &elas(15)*vo(2,1)+elas(20)*vo(2,2)+elas(13)*vo(2,3))*vo(3,3))*
     &w(1,3)
     &+(elas(19)+elas(16)*vo(2,1)
     &+elas(19)*vo(2,2)+elas(20)*vo(2,3)+(elas(10)+elas( 7)*vo(2,1)+
     &elas(10)*vo(2,2)+elas(14)*vo(2,3))*vo(3,1)+(elas( 8)+elas( 2)*
     &vo(2,1)+elas( 8)*vo(2,2)+elas(12)*vo(2,3))*vo(3,2)+(elas(19)+
     &elas(16)*vo(2,1)+elas(19)*vo(2,2)+elas(20)*vo(2,3))*vo(3,3))*
     &w(2,1)
     &+(elas(17)+elas(19)*vo(2,1)
     &+elas(17)*vo(2,2)+elas(21)*vo(2,3)+(elas( 8)+elas(10)*vo(2,1)+
     &elas( 8)*vo(2,2)+elas(19)*vo(2,3))*vo(3,1)+(elas( 3)+elas( 8)*
     &vo(2,1)+elas( 3)*vo(2,2)+elas(17)*vo(2,3))*vo(3,2)+(elas(17)+
     &elas(19)*vo(2,1)+elas(17)*vo(2,2)+elas(21)*vo(2,3))*vo(3,3))*
     &w(2,2)
     &+(elas(21)+elas(20)*vo(2,1)
     &+elas(21)*vo(2,2)+elas(18)*vo(2,3)+(elas(19)+elas(14)*vo(2,1)+
     &elas(19)*vo(2,2)+elas( 9)*vo(2,3))*vo(3,1)+(elas(17)+elas(12)*
     &vo(2,1)+elas(17)*vo(2,2)+elas( 5)*vo(2,3))*vo(3,2)+(elas(21)+
     &elas(20)*vo(2,1)+elas(21)*vo(2,2)+elas(18)*vo(2,3))*vo(3,3))*
     &w(2,3)
     &+(elas( 9)+elas( 4)*vo(2,1)
     &+elas( 9)*vo(2,2)+elas(13)*vo(2,3)+(elas(14)+elas(11)*vo(2,1)+
     &elas(14)*vo(2,2)+elas(15)*vo(2,3))*vo(3,1)+(elas(19)+elas(16)*
     &vo(2,1)+elas(19)*vo(2,2)+elas(20)*vo(2,3))*vo(3,2)+(elas( 9)+
     &elas( 4)*vo(2,1)+elas( 9)*vo(2,2)+elas(13)*vo(2,3))*vo(3,3))*
     &w(3,1)
     &+(elas( 5)+elas( 9)*vo(2,1)
     &+elas( 5)*vo(2,2)+elas(18)*vo(2,3)+(elas(12)+elas(14)*vo(2,1)+
     &elas(12)*vo(2,2)+elas(20)*vo(2,3))*vo(3,1)+(elas(17)+elas(19)*
     &vo(2,1)+elas(17)*vo(2,2)+elas(21)*vo(2,3))*vo(3,2)+(elas( 5)+
     &elas( 9)*vo(2,1)+elas( 5)*vo(2,2)+elas(18)*vo(2,3))*vo(3,3))*
     &w(3,2)
     &+(elas(18)+elas(13)*vo(2,1)
     &+elas(18)*vo(2,2)+elas( 6)*vo(2,3)+(elas(20)+elas(15)*vo(2,1)+
     &elas(20)*vo(2,2)+elas(13)*vo(2,3))*vo(3,1)+(elas(21)+elas(20)*
     &vo(2,1)+elas(21)*vo(2,2)+elas(18)*vo(2,3))*vo(3,2)+(elas(18)+
     &elas(13)*vo(2,1)+elas(18)*vo(2,2)+elas( 6)*vo(2,3))*vo(3,3))*
     &w(3,3))*weight
      s(ii1+2,jj1+2)=s(ii1+2,jj1+2)+((elas(15)+elas(11)*vo(3,1)
     &+elas(14)*vo(3,2)+elas(15)*vo(3,3)+(elas(11)+elas( 1)*vo(3,1)+
     &elas( 7)*vo(3,2)+elas(11)*vo(3,3))*vo(3,1)+(elas(14)+elas( 7)*
     &vo(3,1)+elas(10)*vo(3,2)+elas(14)*vo(3,3))*vo(3,2)+(elas(15)+
     &elas(11)*vo(3,1)+elas(14)*vo(3,2)+elas(15)*vo(3,3))*vo(3,3))*
     &w(1,1)
     &+(elas(20)+elas(14)*vo(3,1)
     &+elas(12)*vo(3,2)+elas(20)*vo(3,3)+(elas(16)+elas( 7)*vo(3,1)+
     &elas( 2)*vo(3,2)+elas(16)*vo(3,3))*vo(3,1)+(elas(19)+elas(10)*
     &vo(3,1)+elas( 8)*vo(3,2)+elas(19)*vo(3,3))*vo(3,2)+(elas(20)+
     &elas(14)*vo(3,1)+elas(12)*vo(3,2)+elas(20)*vo(3,3))*vo(3,3))*
     &w(1,2)
     &+(elas(13)+elas(15)*vo(3,1)
     &+elas(20)*vo(3,2)+elas(13)*vo(3,3)+(elas( 4)+elas(11)*vo(3,1)+
     &elas(16)*vo(3,2)+elas( 4)*vo(3,3))*vo(3,1)+(elas( 9)+elas(14)*
     &vo(3,1)+elas(19)*vo(3,2)+elas( 9)*vo(3,3))*vo(3,2)+(elas(13)+
     &elas(15)*vo(3,1)+elas(20)*vo(3,2)+elas(13)*vo(3,3))*vo(3,3))*
     &w(1,3)
     &+(elas(20)+elas(16)*vo(3,1)
     &+elas(19)*vo(3,2)+elas(20)*vo(3,3)+(elas(14)+elas( 7)*vo(3,1)+
     &elas(10)*vo(3,2)+elas(14)*vo(3,3))*vo(3,1)+(elas(12)+elas( 2)*
     &vo(3,1)+elas( 8)*vo(3,2)+elas(12)*vo(3,3))*vo(3,2)+(elas(20)+
     &elas(16)*vo(3,1)+elas(19)*vo(3,2)+elas(20)*vo(3,3))*vo(3,3))*
     &w(2,1)
     &+(elas(21)+elas(19)*vo(3,1)
     &+elas(17)*vo(3,2)+elas(21)*vo(3,3)+(elas(19)+elas(10)*vo(3,1)+
     &elas( 8)*vo(3,2)+elas(19)*vo(3,3))*vo(3,1)+(elas(17)+elas( 8)*
     &vo(3,1)+elas( 3)*vo(3,2)+elas(17)*vo(3,3))*vo(3,2)+(elas(21)+
     &elas(19)*vo(3,1)+elas(17)*vo(3,2)+elas(21)*vo(3,3))*vo(3,3))*
     &w(2,2)
     &+(elas(18)+elas(20)*vo(3,1)
     &+elas(21)*vo(3,2)+elas(18)*vo(3,3)+(elas( 9)+elas(14)*vo(3,1)+
     &elas(19)*vo(3,2)+elas( 9)*vo(3,3))*vo(3,1)+(elas( 5)+elas(12)*
     &vo(3,1)+elas(17)*vo(3,2)+elas( 5)*vo(3,3))*vo(3,2)+(elas(18)+
     &elas(20)*vo(3,1)+elas(21)*vo(3,2)+elas(18)*vo(3,3))*vo(3,3))*
     &w(2,3)
     &+(elas(13)+elas( 4)*vo(3,1)
     &+elas( 9)*vo(3,2)+elas(13)*vo(3,3)+(elas(15)+elas(11)*vo(3,1)+
     &elas(14)*vo(3,2)+elas(15)*vo(3,3))*vo(3,1)+(elas(20)+elas(16)*
     &vo(3,1)+elas(19)*vo(3,2)+elas(20)*vo(3,3))*vo(3,2)+(elas(13)+
     &elas( 4)*vo(3,1)+elas( 9)*vo(3,2)+elas(13)*vo(3,3))*vo(3,3))*
     &w(3,1)
     &+(elas(18)+elas( 9)*vo(3,1)
     &+elas( 5)*vo(3,2)+elas(18)*vo(3,3)+(elas(20)+elas(14)*vo(3,1)+
     &elas(12)*vo(3,2)+elas(20)*vo(3,3))*vo(3,1)+(elas(21)+elas(19)*
     &vo(3,1)+elas(17)*vo(3,2)+elas(21)*vo(3,3))*vo(3,2)+(elas(18)+
     &elas( 9)*vo(3,1)+elas( 5)*vo(3,2)+elas(18)*vo(3,3))*vo(3,3))*
     &w(3,2)
     &+(elas( 6)+elas(13)*vo(3,1)
     &+elas(18)*vo(3,2)+elas( 6)*vo(3,3)+(elas(13)+elas(15)*vo(3,1)+
     &elas(20)*vo(3,2)+elas(13)*vo(3,3))*vo(3,1)+(elas(18)+elas(20)*
     &vo(3,1)+elas(21)*vo(3,2)+elas(18)*vo(3,3))*vo(3,2)+(elas( 6)+
     &elas(13)*vo(3,1)+elas(18)*vo(3,2)+elas( 6)*vo(3,3))*vo(3,3))*
     &w(3,3))*weight
!
      return
      end
