!
!     CalculiX - A 3-dimensional finite element program
!     Copyright (C) 1998-2005 Guido Dhondt
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
!     This subroutine enable to compuite the different zeta exponents for
!     the different partial total head loss restrictors. The values of the
!     'zetas' have been found in the following published works
!
!     I.E. IDEL'CHIK 'HANDBOOK OF HYDRAULIC RESISTANCE'
!     2nd edition 1986,HEMISPHERE PUBLISHING CORP.
!     ISBN 0-899116-284-4
! 
!     D.S. MILLER 'INTERNAL FLOW SYSTEMS'
!     1978,vol.5 B.H.R.A FLUID ENGINEERING 
!     ISBN 0-900983-78-7
!
      subroutine zeta_calc(nelem,prop,ielprop,lakon,reynolds,zeta,
     &     isothermal,kon,ipkon,R,kappa,v,mi)
!
      implicit none
!
      logical isothermal
!
      character*8 lakon(*)
! 
      integer ielprop(*),nelem,iexp(2),i,j,ier,write1,iexp3(2),
     &     write2,nelem_ref,ipkon(*),kon(*),nelem0,nelem1,nelem2,node10,
     &     node20,nodem0,node11,node21,nodem1,node12,node22,nodem2,
     &     iexpbr1(2) /11,11/,icase,node0,node1,node2,mi(2)
!
      real*8 zeta,prop(*),lzd,reynolds,ereo,fa2za1,zetap,zeta0,
     &     lambda,thau,a1,a2,dh,l,a2za1,ldumm,dhdumm,ks,
     &     form_fact,zeta01,zeta02,alpha,rad,delta,a0,b0,azb,rzdh,
     &     A,C,rei,lam,ai,b1,c1,b2,c2,zeta1,re_val,k,ldre,
     &     zetah,cd,cdu,km,Tt0,Ts0,Tt1,Ts1,Tt2,Ts2,
     &     rho0,rho1,rho2,V0,V1,v2,a0a1,a0a2,zetlin,lam10,lam20,pi,
     &     alpha1,alpha2,R,kappa,ang1s,ang2s,cang1s,cang2s,
     &     v(0:mi(2),*),V1V0,V2V0,z1_60,z1_90,
     &     z2_60,z2_90,afakt,V2V0L,kb,ks2,a2a0,Z90LIM11,Z90LIM51,
     &     lam11,lam12,lam21,lam22,W2W0,W1W0,dh0,dh2,hq,z2d390,
     &     z1p090,z90,z60,pt0,pt2,pt1,M0,M1,M2,W0W1,W0W2,
     &     xflow0,xflow1,xflow2,Qred_0, Qred_1, Qred_2,Qred_crit
!
!     THICK EDGED ORIFICE IN STRAIGHT CONDUIT (L/DH > 0.015)
!     I.E. IDEL' CHIK (SECTION III PAGE 140)
!
!     I.E. IDEL'CHIK 'HANDBOOK OF HYDRAULIC RESISTANCE'
!     2nd edition 1986,HEMISPHERE PUBLISHING CORP.
!     ISBN 0-899116-284-4
!
!        ***** long orifice *****
!
!        DIAGRAMS 4-19 p 175 - Reynolds R:epsilon^-_oRe
!
      real*8 XRE (14), YERE (14)
      data XRE / 25.,40.,60.0,100.,200.,400.,1000.,2000.,4000.,
     &     10000.,20000.,100000.,200000.,1000000./
      data YERE/ 0.34,0.36,0.37,0.40,0.42,0.46,0.53,0.59,
     &     0.64,0.74,0.81,0.94,0.95,0.98/
!     
!     Diagram 4-19 p 175 - Reynolds | A1/A2 R: zeta_phi
!     
      real*8 zzeta (15,11)
      data ((zzeta(i,j),i=1,15),j=1,11) 
     &     /15.011  ,25.0,40.0,60.0,100.0,200.0,400.0,1000.0,2000.0,
     &     4000.0,10000.0,20000.0,100000.0,200000.0,1000000.0,
     &        0.00   ,1.94,1.38,1.14,0.89,0.69,0.64,0.39,0.30,0.22,0.15,
     &                0.11,0.04,0.01,0.00,
     &        0.20   ,1.78,1.36,1.05,0.85,0.67,0.57,0.36,0.26,0.20,0.13,
     &                0.09,0.03,0.01,0.00,
     &        0.30   ,1.57,1.16,0.88,0.75,0.57,0.43,0.30,0.22,0.17,0.10,
     &                0.07,0.02,0.01,0.00,
     &        0.40   ,1.35,0.99,0.79,0.57,0.40,0.28,0.19,0.14,0.10,0.06,
     &                0.04,0.02,0.01,0.00,
     &        0.50   ,1.10,0.75,0.55,0.34,0.19,0.12,0.07,0.05,0.03,0.02,
     &                0.01,0.01,0.01,0.00,
     &        0.60   ,0.85,0.56,0.30,0.19,0.10,0.06,0.03,0.02,0.01,0.01,
     &                0.00,0.00,0.00,0.00,
     &        0.70   ,0.58,0.37,0.23,0.11,0.06,0.03,0.02,0.01,0.00,0.00,
     &                0.00,0.00,0.00,0.00,
     &        0.80   ,0.40,0.24,0.13,0.06,0.03,0.02,0.01,0.00,0.00,0.00,
     &                0.00,0.00,0.00,0.00,
     &        0.90   ,0.20,0.13,0.08,0.03,0.01,0.00,0.00,0.00,0.00,0.00,
     &                0.00,0.00,0.00,0.00,
     &        0.95   ,0.03,0.03,0.02,0.00,0.00,0.00,0.00,0.00,0.00,0.00,
     &                0.00,0.00,0.00,0.00/
!
!     Diagram 4-12 p 169 - l/Dh R: tau
!     
      real*8 XLZD (10), YTOR (10)
      data XLZD / 0.0,0.2,0.4,0.6,0.8,1.0,1.2,1.6,2.0,2.4/
      data YTOR / 1.35,1.22,1.10,0.84,0.42,0.24,0.16,0.07,0.02,0.0/
      data IEXP / 10, 1/
!     
!     ***** wall orifice *****
!     
!     THICK-WALLED ORIFICE IN LARGE WALL (L/DH > 0.015)
!     I.E. IDL'CHIK (page 174)
!     
!     DIAGRAM 4-18 A - l/Dh R: zeta_o
!     
      real*8 XLQD(12)
      DATA XLQD /
     &     0.,0.2,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,10.0/
      real*8 YZETA1(12)
      DATA YZETA1 /
     &     2.85,2.72,2.6,2.34,1.95,1.76,1.67,1.62,1.6,1.58,1.55,1.55/
!     
!     DIAGRAM 4-19 p175 first line - Re (A1/A2=0) R: zeta_phi
!     
      real*8 XRE2(14)
      DATA XRE2 /
     &     25.,40.,60.,100.,200.,400.,1000.,2000.,4000.,10000.,
     &     20000.,50000.,100000.,1000000./
      real*8 YZETA2(14)
      DATA YZETA2 /
     &     1.94,1.38,1.14,.89,.69,.54,.39,.3,.22,.15,.11,.04,.01,0./
!     
!     Diagram 4-18 p174 first case * (=multiplication) epsilon^-_oRe p 175
!     
      real*8 YERE2(14)
      DATA YERE2 /
     &     1.,1.05,1.09,1.15,1.23,1.37,1.56,1.71,1.88,2.17,2.38,2.56,
     &     2.72,2.85/
!
!     ***** expansion *****
!     
!     SUDDEN EXPANSION OF A STREAM WITH UNIFORM VELOCITY DISTRIBUTION
!     I.E. IDL'CHIK (page 160)
!
!     DIAGRAM 4-1 - Re | A1/A2 R:zeta
!
      real*8 ZZETA3(14,8)
      DATA ZZETA3 /
     &     14.008, 10.000,15.0,20.0,30.0,40.0,50.0,100.0,200.0,500.0,
     &          1000.0,2000.0,3000.0,3500.0,
     &  .01    ,3.10,3.20,3.00,2.40,2.15,1.95,1.70,1.65,1.70,2.00,
     &          1.60,1.00,1.00,
     &  0.1    ,3.10,3.20,3.00,2.40,2.15,1.95,1.70,1.65,1.70,2.00,
     &          1.60,1.00,0.81,
     &  0.2    ,3.10,3.20,2.80,2.20,1.85,1.65,1.40,1.30,1.30,1.60,
     &          1.25,0.70,0.64,
     &  0.3    ,3.10,3.10,2.60,2.00,1.60,1.40,1.20,1.10,1.10,1.30,
     &          0.95,0.60,0.50,
     &  0.4    ,3.10,3.00,2.40,1.80,1.50,1.30,1.10,1.00,0.85,1.05,
     &          0.80,0.40,0.36,
     &  0.5    ,3.10,2.80,2.30,1.65,1.35,1.15,0.90,0.75,0.65,0.90,
     &          0.65,0.30,0.25,
     &  0.6    ,3.10,2.70,2.15,1.55,1.25,1.05,0.80,0.60,0.40,0.60,
     &          0.50,0.20,0.16/
!     
      DATA IEXP3 /0,0/
!     
!     ***** contraction *****
!
!     SUDDEN CONTRACTION WITH & WITHOUT CONICAL BELLMOUTH ENTRY
!     I.E. IDL'CHIK  p 168
! 
!     DIAGRAM 4-10 - Re | A1/A2 R: zeta
!
      real*8 ZZETA41(14,7)
      DATA ZZETA41 /
     & 14.007 ,10.0,20.0,30.0,40.0,50.0,100.0,200.0,500.0,1000.0,
     &         2000.0,4000.0,5000.0,10000.0,
     &0.1    ,5.00,3.20,2.40,2.00,1.80,1.30,1.04,0.82,0.64,0.50,
     &         0.80,0.75,0.50,
     &0.2     ,5.00,3.10,2.30,1.84,1.62,1.20,0.95,0.70,0.50,0.40,
     &         0.60,0.60,0.40,
     &0.3     ,5.00,2.95,2.15,1.70,1.50,1.10,0.85,0.60,0.44,0.30,
     &         0.55,0.55,0.35,
     &0.4     ,5.00,2.80,2.00,1.60,1.40,1.00,0.78,0.50,0.35,0.25,
     &         0.45,0.50,0.30,
     &0.5     ,5.00,2.70,1.80,1.46,1.30,0.90,0.65,0.42,0.30,0.20,
     &         0.40,0.42,0.25,
     &0.6     ,5.00,2.60,1.70,1.35,1.20,0.80,0.56,0.35,0.24,0.15,
     &         0.35,0.35,0.20/
!
!      Diagram 3-7 p128  - alpha | l/Dh R: zeta
!
      real*8 ZZETA42(10,7)
      DATA ZZETA42 /
     & 10.007   ,0.,10.0,20.0,30.0,40.0,60.0,100.0,140.0,180.0,
     &  0.025   ,0.50,0.47,0.45,0.43,0.41,0.40,0.42,0.45,0.50,
     &  0.050   ,0.50,0.45,0.41,0.36,0.33,0.30,0.35,0.42,0.50,
     &  0.075   ,0.50,0.42,0.35,0.30,0.26,0.23,0.30,0.40,0.50,
     &  0.100   ,0.50,0.39,0.32,0.25,0.22,0.18,0.27,0.38,0.50,
     &  0.150   ,0.50,0.37,0.27,0.20,0.16,0.15,0.25,0.37,0.50,
     &  0.600   ,0.50,0.27,0.18,0.13,0.11,0.12,0.23,0.36,0.50/
!
!     ***** bends *****
!     
!     SHARP ELBOW (R/DH = 0) AT 0 < DELTA < 180
!     I.E. IDL'CHIK page 294
!     DIAGRAM 6-5  - a0/b0 R: C1
!     
      real*8  XAQB(12)
      DATA XAQB /
     &     0 .25,0.50,0.75,1.00,1.50,2.00,3.00,4.00,5.00,6.00,7.00,8.00/
!     
      real*8 YC(12)
      DATA YC /
     &     1.10,1.07,1.04,1.00,0.95,0.90,0.83,0.78,0.75,0.72,0.71,0.70/
!
!     DIAGRAM 6-5 - delta R: A
!
      real*8 XDELTA(10)
      DATA XDELTA /
     &     20.0,30.0,45.0,60.0,75.0,90.0,110.,130.,150.,180./
!     
      real*8 YA(10)
      DATA YA /
     &     2.50,2.22,1.87,1.50,1.28,1.20,1.20,1.20,1.20,1.20/
!     
!     SHARP BENDS 0.5 < R/DH < 1.5 AND 0 < DELTA < 180
!     I.E. IDL'CHIK page 289-290
!     DIAGRAM 6-1  (- delta from diagram 6-5) R: A1
!     
      real*8 YA1(10)
      DATA YA1 /
     &     0.31,0.45,0.60,0.78,0.90,1.00,1.13,1.20,1.28,1.40/
!     
!     DIAGRAM 6-1 - R0/D0 R: B1
!     
      real*8 XRQDH(8)
      DATA XRQDH /
     &     0.50,0.60,0.70,0.80,0.90,1.00,1.25,1.50/
!     
      real*8 YB1(8)
      DATA YB1 /
     &     1.18,0.77,0.51,0.37,0.28,0.21,0.19,0.17/
!     
!     DIAGRAM 6-1 (- a0/b0 from diagram 6-5) R: C1
!     
      real*8 YC1(12)
      DATA YC1 /
     &     1.30,1.17,1.09,1.00,0.90,0.85,0.85,0.90,095,0.98,1.00,1.00/
!     
!     SMOOTH BENDS (R/DH > 1.5) AT 0 < DELTA < 180
!     I.E. IDL'CHIK 
!     
!     DIAGRAM 6-1  - R0/D0 R: B1 (continuation of XRQDH)
!
      real*8 XRZDH(14)
      DATA XRZDH/
     &     1.00,2.00,4.00,6.00,8.00,10.0,15.0,20.0,25.0,30.0,35.0,40.0,
     &     45.0,50.0/
!     
      real*8 YB2(14)
      DATA YB2 /
     &     0.21,0.15,0.11,0.09,0.07,0.07,0.06,0.05,0.05,0.04,0.04,0.03,
     &     0.03,0.03/
!
!     (- a0/b0 from Diagram 6-5) R: C2
!
      real*8 YC2(12)
      DATA YC2 /
     &     1.80,1.45,1.20,1.00,0.68,0.45,0.40,0.43,0.48,0.55,0.58,0.60/
!     
!     D.S. MILLER 'INTERNAL FLOW SYSTEMS'
!     1978,vol.5 B.H.R.A FLUID ENGINEERING SERIES
!     ISBN 0-900983-78-7     
!
!        SMOOTH BENDS B.H.R.A HANDBOOK P.141 
!
      REAL*8 ZZETAO(14,15)
      DATA((ZZETAO(I,J),I=1,14),J=1,8) /
     & 14.015,0.5,0.6,0.8,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.,
     & 10.00, 0.030,0.025,0.021,0.016,0.022,0.030,0.034,0.036,0.040,
     &        0.042,0.043,0.044,0.044,
     & 15.00, 0.036,0.035,0.025,0.025,0.033,0.042,0.045,0.050,0.055,
     &        0.055,0.058,0.060,0.063,
     & 20.00, 0.056,0.046,0.034,0.034,0.045,0.054,0.056,0.062,0.066,
     &        0.067,0.072,0.075,0.080,
     & 30.00, 0.122,0.094,0.063,0.056,0.063,0.071,0.075,0.082,0.087,
     &        0.089,0.097,0.101,0.110,
     & 40.00, 0.220,0.160,0.100,0.085,0.080,0.086,0.092,0.100,0.106,
     &        0.122,0.121,0.126,0.136,
     & 50.00, 0.340,0.245,0.148,0.117,0.097,0.100,0.108,0.116,0.123,
     &        0.133,0.144,0.150,0.159,
     & 60.00, 0.480,0.350,0.196,0.150,0.115,0.116,0.122,0.131,0.140,
     &        0.153,0.164,0.171,0.181/
      DATA((ZZETAO(I,J),I=1,14),J=9,15) /
     & 70.00, 0.645,0.466,0.243,0.186,0.132,0.130,0.136,0.148,0.160,
     &        0.172,0.185,0.191,0.200,
     & 80.00, 0.827,0.600,0.288,0.220,0.147,0.142,0.150,0.166,0.180,
     &        0.191,0.203,0.209,0.218,
     & 90.00, 1.000,0.755,0.333,0.247,0.159,0.155,0.166,0.185,0.197,
     &        0.209,0.220,0.227,0.236,
     & 100.0, 1.125,0.863,0.375,0.264,0.167,0.166,0.183,0.202,0.214,
     &        0.225,0.238,0.245,0.255,
     & 120.0, 1.260,0.983,0.450,0.281,0.180,0.188,0.215,0.234,0.247,
     &        0.260,0.273,0.282,0.291,
     & 150.0, 1.335,1.060,0.536,0.289,0.189,0.214,0.251,0.272,0.297,
     &        0.312,0.325,0.336,0.346,
     & 180.0, 1.350,1.100,0.600,0.290,0.190,0.225,0.280,0.305,0.347,
     &        0.364,0.378,0.390,0.400/
!       
      REAL*8 KRE(22,4)
      DATA KRE  /
     & 22.004,1.E+3,2.E+3,3.E+3,4.E+3,5.E+3,6.E+3,7.E+3,8.E+3,9.E+3,
     &        1.E+4,2.E+4,3.E+4,4.E+4,6.E+4,8.E+4,1.E+5,2.E+5,3.E+5,
     &        5.E+5,7.E+5,1.E+6,
     & 1.0,   3.88,3.06,2.77,2.60,2.49,2.40,2.33,2.27,2.22,2.18,
     &        1.86,1.69,1.57,1.41,1.30,1.22,5*1.00,
     & 1.5,   3.88,3.06,2.77,2.60,2.49,2.40,2.33,2.27,2.22,2.18,
     &        1.90,1.76,1.67,1.54,1.46,1.40,1.22,1.12,3*1.00,
     & 2.0,   3.88,3.06,2.77,2.60,2.49,2.40,2.33,2.27,2.22,2.18,
     &        1.93,1.80,1.71,1.60,1.53,1.47,1.32,1.23,1.13,1.06,1.00/
!
      integer iexp6(2)
      DATA iexp6 /0,0/
!
!     Campbell, Slattery
!     "Flow in the entrance of a tube"
!     Journal of Basic Engineering, 1963
!
!     EXIT LOSS COEFFICIENT FOR LAMINAR FLOWS DEPENDING ON THE
!     ACTUAL VELOCITY DISTRIBUTION AT THE EXIT
!
      real*8 XDRE(12)
      DATA XDRE /
     &        0.000,0.001,0.0035,0.0065,0.010,0.0150,0.020,
     &        0.025,0.035,0.045,0.056,0.065/
!
      real*8 ZETAEX(12)
      DATA ZETAEX /
     &        1.00,1.200,1.40,1.54,1.63,1.73,1.80,1.85,1.93,
     &        1.97,2.00,2.00/
!
!     Branch Joint Genium 
!     Branching Flow Part IV - TEES
!     Fluid Flow Division
!     Section 404.2 page 4 December 1986
!     Genium Publishing (see www.genium.com)
!
!     n.b: the values of this table have been scaled by a factor 64.
!
      real*8 XANG(11),YANG(11)
      data (XANG(i),YANG(i),i=1,11)
     &       /0.0d0,62.d0,
     &        15.d0,62.d0,
     &        30.d0,61.d0,
     &        45.d0,61.d0,
     &        60.d0,58.d0,
     &        75.d0,52.d0,
     &        90.d0,40.d0,
     &        105.d0,36.d0,
     &        120.d0,34.d0,
     &        135.d0,33.d0,
     &        150.d0,32.5d0/
!
!     Branch Joint Idelchik 1
!     Diagrams of resistance coefficients 
!     I.E. IDEL'CHIK 'HANDBOOK OF HYDRAULIC RESISTANCE'
!     2nd edition 1986,HEMISPHERE PUBLISHING CORP.
!     ISBN 0-899116-284-4
!
      real*8 TA2A0(12),TAFAKT(12)
      data (TA2A0(i),TAFAKT(i),i=1,12)
     &        /0.d0  ,1.d0  ,
     &        0.16d0 ,1.d0  ,
     &        0.20d0 ,0.99d0,
     &        0.25d0 ,0.95d0,
     &        0.29d0 ,0.90d0,
     &        0.31d0 ,0.85d0,
     &        0.33d0 ,0.80d0,
     &        0.35d0 ,0.78d0,
     &        0.4d0  ,0.75d0,
     &        0.6d0  ,0.70d0,
     &        0.8d0  ,0.65d0,
     &        1.d0   ,0.60d0/   
!
!     Branch Joint Idelchik 2
!     Diagrams of resistance coefficients p348-351 section VII
!     I.E. IDEL'CHIK 'HANDBOOK OF HYDRAULIC RESISTANCE'
!     2nd edition 1986,HEMISPHERE PUBLISHING CORP.
!     ISBN 0-899116-284-4
!
!     page 352 diagram 7-9 - alpha | Fs/Fc
!
      real*8 KBTAB(6,7),KSTAB(6,6)
      data ((KBTAB(i,j),j=1,7),i=1,6)
     &        /6.007d0 ,0.d0,15.d0,30.d0,45.d0,60.d0  ,90.d0  ,
     &           0.d0  ,0.d0, 0.d0, 0.d0, 0.d0, 0.d0  , 0.d0  ,
     &           0.1d0 ,0.d0, 0.d0, 0.d0, 0.d0, 0.d0  , 0.d0  ,
     &           0.2d0 ,0.d0, 0.d0, 0.d0, 0.d0, 0.d0  , 0.1d0 ,
     &           0.33d0,0.d0, 0.d0, 0.d0, 0.d0, 0.d0  , 0.2d0 ,
     &           0.5d0 ,0.d0, 0.d0, 0.d0, 0.d0, 0.1d0 , 0.25d0/
!
!     page 348-351 diagrams 7-5 to 7-8 - alpha | Fs/Fc
!
      data ((KSTAB(i,j),j=1,6),i=1,6)
     &        /6.006d0 ,0.d0,15.d0  ,30.d0  ,45.d0  , 60.d0  ,
     &           0.d0  ,0.d0, 0.d0  , 0.d0  , 0.d0  , 0.d0   , 
     &           0.1d0 ,0.d0, 0.d0  , 0.d0  , 0.05d0, 0.d0   ,
     &           0.2d0 ,0.d0, 0.d0  , 0.d0  , 0.14d0, 0.d0   ,
     &           0.33d0,0.d0, 0.14d0, 0.17d0, 0.14d0, 0.1d0  ,
     &           0.5d0 ,0.d0, 0.4d0 , 0.4d0 , 0.3d0 , 0.25d0/ 
!
!     page 352 diagram 7-9 R: zeta_c,st
!
      real*8 Z90TAB(6,13)
      data  ((Z90TAB(i,j),j=1,13),i=1,6)/
     &6.013,0. ,0.03,0.05,0.1 ,0.2 ,0.3 ,0.4 ,0.5 ,0.6 ,0.7 ,0.8 ,1.0 ,
     & .06, .02, .05, .08, .08, .07, .01,-.15,1.E9,1.E9,1.E9,1.E9,1.E9,
     & .10, .04, .08, .10, .20, .26, .20, .05,-.13,1.E9,1.E9,1.E9,1.E9,
     & .20, .08, .12, .18, .25, .34, .32, .26, .16, .02,-.14,1.E9,1.E9,
     & .33, .45, .50, .52, .59, .66, .64, .62, .58, .44, .27, .08,-.34,
     & .50,1.00,1.04,1.06,1.16,1.25,1.25,1.22,1.10, .88, .70, .45,0.  /
!
!     table to check the location of V2V0 in Z90TAB 
!
      real*8 Z90LIMX (5),Z90LIMY(5)
      data Z90LIMX    
     &        /0.06d0,0.1d0,0.2d0,0.33,0.5d0 /
!
      data Z90LIMY
     &    / 0.1d0,0.1d0,0.3d0,0.5d0,0.7d0/
!     
      pi=4.d0*datan(1.d0)
!     
      if ((lakon(nelem)(2:5).eq.'REUS').or.
     &    (lakon(nelem)(2:5).eq.'LPUS')) then
!     
!     user defined zeta
!     
         zeta=prop(ielprop(nelem)+4)
!     
         return
!
      elseif((lakon(nelem)(2:5).eq.'REEN').or.
     &       (lakon(nelem)(2:5).eq.'LPEN')) then
!     
!     entrance 
!     
         zeta=prop(ielprop(nelem)+4)
!     
         return
!     
      elseif((lakon(nelem)(2:7).eq.'RELOID').or.
     &       (lakon(nelem)(2:7).eq.'LPLOID')) then
!     
!     THICK EDGED ORIFICE IN STRAIGHT CONDUIT (L/DH > 0.015)
!     I.E. IDEL'CHIK p175
!     
!     Input parameters
!     
!     Inlet/outlet sections
         a1=prop(ielprop(nelem)+1)
         a2=prop(ielprop(nelem)+2)
!     Hydraulic diameter
         dh=prop(ielprop(nelem)+3)
         if((dh.eq.0).and.(A1.le.A2)) then
            dh=dsqrt(4d0*A1/Pi)
         elseif((dh.eq.0).and.(A1.gt.A2)) then
            dh=dsqrt(4d0*A2/Pi)
         endif
!     Length        
         l=prop(ielprop(nelem)+4)
!         
         lzd=l/dh
         a2za1=min (a1/a2, 1.)
!         
         fa2za1=1.d0-a2za1
!
         write1= 0
         if ( lzd .gt. 2.4 ) write1= 1
!     
         ldumm=1.D0
         dhdumm=-1.D0
         ks=0.d0
         form_fact=1.d0
!
         call friction_coefficient(ldumm,dhdumm,ks,reynolds,
     &        form_fact,lambda)
!
         call onedint(XLZD,YTOR,10,lzd,thau,1,1,0,ier)
         zeta0 = ((0.5+thau*dsqrt(fa2za1))+fa2za1) * fa2za1
!
         if(reynolds .gt. 1.E+05 ) then
            zeta=zeta0 + lambda * dabs(lzd)
         else
            call onedint(XRE,YERE,14,reynolds,ereo,1,1,0,ier)
!
            call twodint(zzeta,15,11,reynolds,
     &           a2za1,zetap,1,IEXP,IER)
            zeta = zetap + ereo * zeta0 + lambda * dabs(lzd)
            IF ( a2za1 .gt. 0.95 ) WRITE1=1
         endif
!     
         if(dabs(lzd) .le. 0.015 )then 
            write(*,*) '*WARNING in zeta_calc: L/DH outside valid' 
            write(*,*) '         range ie less than 0.015 !'
         endif
!
         if( write1 .eq. 1 ) then
            write(*,*) 
     &    'WARNING in zeta_calc: geometry data outside valid range' 
            write(*,*) 
     & '         l/dh greater than 2.4- extrapolated value(s) !'
         endif
!
      elseif((lakon(nelem)(2:7).eq.'REWAOR').or.
     &       (lakon(nelem)(2:7).eq.'LPWAOR'))then
!     
!     THICK-WALLED ORIFICE IN LARGE WALL (L/DH > 0.015)
!     I.E. IDL'CHIK page 174
!
!     Input parameters
!     
!     Inlet/outlet sections
         a1=prop(ielprop(nelem)+1)
         a2=prop(ielprop(nelem)+2)
!     Hydraulic diameter
         dh=prop(ielprop(nelem)+3)
         if((dh.eq.0).and.(A1.le.A2)) then
            dh=dsqrt(4d0*A1/Pi)
         elseif((dh.eq.0).and.(A1.gt.A2)) then
            dh=dsqrt(4d0*A2/Pi)
         endif
!     Length        
         l=prop(ielprop(nelem)+4)
!     
         lzd=l/dh
         ldumm=1.D0
         dhdumm=-1.D0
         ks=0.d0
         form_fact=1.d0
!     
         call friction_coefficient(ldumm,dhdumm,ks,reynolds,
     &        form_fact,lambda)
         call onedint (XLQD,YZETA1,12,lzd,zeta01,1,1,0,IER)
!     
         write1=0
         if (lzd.gt.10.) write1=1
!     
         if(reynolds.le.1.E+05) then
!     
            call onedint (XRE2,YZETA2,14,reynolds,zeta02,1,1,10,IER)
            call onedint (XRE2,YERE2,14,reynolds,EREO,1,1,0,IER)
!     
            zeta=zeta02+0.342*ereo*zeta01+lambda*lzd
!     
         elseif(reynolds.gt.1.E+05) then
            zeta=zeta01+lambda*lzd
         endif
         if(lzd.le.0.015) then
            write(*,*) '*WARNING in zeta_calc' 
            write(*,*) 
     &       '         l/dh outside valid range i.e. less than 0.015 !'
         endif
         if(write1.eq.1) then
            write(*,*) '*WARNING in zeta_calc :extrapolated value(s)!'
         endif
!     
         return         
!     
      elseif((lakon(nelem)(2:7).eq.'REEL').or.
     &       (lakon(nelem)(2:7).eq.'LPEL')) then
!     
!     SUDDEN EXPANSION OF A STREAM WITH UNIFORM VELOCITY DISTRIBUTION
!     I.E. IDL'CHIK page 160      
! 
!     Input parameters
!    
!     Inlet/outlet sections
         a1=prop(ielprop(nelem)+1)
         a2=prop(ielprop(nelem)+2)
c!     Hydraulic diameter
c         dh=prop(ielprop(nelem)+3)
c         if((dh.eq.0).and.(A1.le.A2)) then
c            dh=dsqrt(4d0*A1/Pi)
c         elseif((dh.eq.0).and.(A1.gt.A2)) then
c            dh=dsqrt(4d0*A2/Pi)
c         endif
!     
         a2za1=a1/a2
         write1=0
!     
         if (reynolds.LE.10.) then
            zeta=26.0/reynolds
         elseif (reynolds.gt.10.and.reynolds.le.3.5E+03) then
            call twodint(zzeta3,14,11,reynolds,a2za1,zeta,1,IEXP3,IER)
            if (a2za1.lt.0.01.or.a2za1.gt.0.6) write1=1
         else
            zeta=(1.-a2za1)**2
         endif
!     
         if(write1 .eq. 1) then
            write(*,*) '*WARNING in zeta_calc: extrapolated value(s)!'
         endif
         return
!     
      elseif((lakon(nelem)(2:7).eq.'RECO').or.
     &       (lakon(nelem)(2:7).eq.'LPCO'))then
!     
!     SUDDEN CONTRACTION WITH & WITHOUT CONICAL BELLMOUTH ENTRY
!     I.E. IDL'CHIK p 168
! 
!     Input parameters
!    
!     Inlet/outlet sections
         a1=prop(ielprop(nelem)+1)
         a2=prop(ielprop(nelem)+2)
!     Hydraulic diameter
         dh=prop(ielprop(nelem)+3)
         if((dh.eq.0).and.(A1.le.A2)) then
            dh=dsqrt(4d0*A1/Pi)
         elseif((dh.eq.0).and.(A1.gt.A2)) then
            dh=dsqrt(4d0*A2/Pi)
         endif
!     Length
         l=prop(ielprop(nelem)+4)
!     Angle
         alpha=prop(ielprop(nelem)+5)
!     
         a2za1=a2/a1
         write1=0
         l=abs(l)
         lzd=l/dh
!     
         if (l.eq.0.) then
            if (reynolds.le.10.) then
               zeta=27.0/reynolds
            elseif(reynolds.gt.10.and.reynolds.le.1.E+04) then
              call twodint(ZZETA41,14,11,reynolds,a2za1,zeta,1,IEXP,IER)
               if (a2za1.le.0.1.or.a2za1.gt.0.6) write1=1
            elseif (reynolds.gt.1.E+04) then
               zeta=0.5*(1.-a2za1)
            endif
         elseif(l.gt.0.) then
            call twodint(ZZETA42,10,0,alpha,lzd,zeta0,1,IEXP,IER)
            zeta=zeta0*(1.-a2za1)
            if (lzd .lt. 0.025  .or.  lzd .gt. 0.6) write1=1
            if (reynolds  .le. 1.E+04) then
               write(*,*) '*WARNING in zeta_calc: reynolds outside valid
     & range i.e. < 10 000 !'
            endif   
         endif
!     
         if ( write1 .eq. 1 ) then
            WRITE(*,*) '*WARNING in zeta_calc: extrapolierte Werte!'
         endif
!     
         return
!
      elseif((lakon(nelem)(2:7).eq.'REBEID').or.
     &       (lakon(nelem)(2:7).eq.'LPBEID')) then
!
!
!        SHARP ELBOW (R/DH = 0) AT 0 < DELTA < 180
!        I.E. IDL'CHIK page 294
!     
!        SHARP BENDS 0.5 < R/DH < 1.5 AND 0 < DELTA < 180
!        I.E. IDL'CHIK page 289-290
!
!        SMOOTH BENDS (R/DH > 1.5) AT 0 < DELTA < 180
!        I.E. IDL'CHIK page 289-290
!
!     Input parameters
!     
!     Inlet/outlet sections
         a1=prop(ielprop(nelem)+1)
         a2=prop(ielprop(nelem)+2)
!     Hydraulic diameter
         dh=prop(ielprop(nelem)+3)
         if((dh.eq.0).and.(A1.le.A2)) then
            dh=dsqrt(4d0*A1/Pi)
         elseif((dh.eq.0).and.(A1.gt.A2)) then
            dh=dsqrt(4d0*A2/Pi)
         endif
!     radius
         rad=prop(ielprop(nelem)+4)
!     angle
         delta=prop(ielprop(nelem)+5)
!     heigth/width (square section)
         a0=prop(ielprop(nelem)+6)
         b0=prop(ielprop(nelem)+7)
!
      write1=0
      write2=0
      rzdh=rad/dh
      if(a0.eq.0.)  azb=1.0
      if(a0.gt.0.) azb=a0/b0
!
      if (rzdh.le.0.5) then
         call onedint(XAQB,YC,12,azb,C,1,1,0,IER)
         zeta1=0.95*(SIN(delta*0.0087))**2+2.05*(SIN(delta*0.0087))**4
         call onedint(XDELTA,YA,10,delta,A,1,1,10,IER)
         zeta=c*a*zeta1
         if (azb.le.0.25.or.azb.gt.8.0) write2=1
         if (reynolds.lt.4.E+04) then
            if (reynolds.le.3.E+03) write1=1
            REI=MAX(2999.,reynolds)
            ldumm=1.D0
            dhdumm=-1.D0
            ks=0.d0
            form_fact=1.d0
            call friction_coefficient(ldumm,dhdumm,ks,REI,form_fact
     &           ,lambda)
            re_val=4.E+04
            call friction_coefficient(ldumm,dhdumm,ks,re_val,form_fact
     &           , lam)
            zeta=zeta*lambda/lam
         endif
!
      elseif (rzdh.gt.0.5.and.rzdh.lt.1.5) then
         call onedint(XDELTA,YA1,10,delta,AI,1,1,10,IER)
         call onedint(XRQDH,YB1,8,rzdh,B1,1,1,10,IER)
         call onedint(XAQB,YC1,12,azb,C1,1,1,10,IER)
         REI=MAX(2.E5,reynolds)
         ldumm=1.D0
         dhdumm=-1.D0
         ks=0.d0
         form_fact=1.d0
         call friction_coefficient(ldumm,dhdumm,ks,REI,form_fact
     &        , lambda)
         zeta=AI*B1*C1+0.0175*delta*rzdh*lambda
         if (azb.lt.0.25.or.azb.gt.8.0) write2=1
         if (reynolds.lt.2.E+05) then
            IF (reynolds.lt.3.E+03) write1=1
            REI=MAX(2999.,reynolds)
            call friction_coefficient(ldumm,dhdumm,ks,REI,form_fact
     &           ,lambda)
            re_val=2.E+05
            call friction_coefficient(ldumm,dhdumm,ks,re_val,form_fact
     &           , lam)
            zeta=zeta*lambda/lam
         endif
!
      elseif (rzdh.ge.1.5.and.rzdh.lt.50.) then
         call onedint(XDELTA,YA1,10,delta,AI,1,1,10,IER)
         call onedint(XAQB,YC2,12,azb,C2,1,1,10,IER)
         call onedint(XRZDH,YB2,8,rzdh,B2,1,1,0,IER)
         REI=MAX(2.E5,reynolds)
         ldumm=1.D0
         dhdumm=-1.D0
         ks=0.d0
         form_fact=1.d0
         call friction_coefficient(ldumm,dhdumm,ks,REI,form_fact
     &        ,lambda)
         zeta=AI*B2*C2+0.0175*delta*rzdh*lambda
         if (azb.lt.0.25.or.azb.gt.8.0) write2=1
         if (reynolds.lt.2.E+05) then
            if (reynolds.lt.3.E+03) write1=1
            REI=MAX(2999.,reynolds)
             call friction_coefficient(ldumm,dhdumm,ks,REI,form_fact
     &           ,lambda)
             re_val=2.E+05
            call friction_coefficient(ldumm,dhdumm,ks,re_val,form_fact
     &           , lam)
            zeta=zeta*lambda/lam
         endif
!
      elseif(rzdh.ge.50.) then
         zeta=0.0175*rzdh*delta*lambda
         if (reynolds .lt. 2.E+04) then
             write (*,*)'Reynolds outside valid range i.e. < 20 000!'
         endif
      endif
!
      if (write1 .eq. 1) then
!     
         write (*,*) 'Reynolds outside valid range i.e. < 3 000!'
      endif
!
      if(write2 .eq. 1) then
         write(*,*) '*WARNING in zeta_calc: extrapolated value(s)!'
      endif
      return
!
      elseif((lakon(nelem)(2:7).eq.'REBEMI').or.
     &       (lakon(nelem)(2:7).eq.'LPBEMI')) then
!
!     SMOOTH BENDS B.H.R.A HANDBOOK
!
!     Input parameters
!
!     Inlet/outlet sections
         a1=prop(ielprop(nelem)+1)
         a2=prop(ielprop(nelem)+2)
!     Hydraulic diameter
         dh=prop(ielprop(nelem)+3)
!     Radius:
         rad=prop(ielprop(nelem)+4)
!     angle delta:
         delta=prop(ielprop(nelem)+5)
!     
         rzdh = Rad / DH
!     
         write1 = 0
         if ( delta .lt. 10.  .or.  delta .gt. 180.  .or.
     &        rzdh  .lt. 0.5  .or.  rzdh.  gt. 10.        ) write1 = 1
!     
         call twodint(ZZETAO,14,11,rzdh,delta,zeta0,1,IEXP6,IER)
         call twodint(KRE, 22,11,reynolds,rzdh, k,1,IEXP6,IER)
         zeta = zeta0 * k
!     
         if ( reynolds .lt. 1.E+3  .or.  reynolds .gt. 1.E+6 ) then 
            write (*,*)'Reynolds outside valid range <1.E+3 or >1.0E+6'
         endif
!     
         if ( write1 .eq. 1 ) then
            write (*,*)': geometry data outside valid range '
            write (*,*)' - extrapolated value(s)!'
         endif
         RETURN
!
      elseif((lakon(nelem)(2:7).eq.'REBEMA').or.
     &       (lakon(nelem)(2:7).eq.'LPBEMA')) then
!            
!     Own tables and formula to be included
!
         Write(*,*) '*WARNING in zeta_calc: ZETA implicitly equal 1'
         zeta=1.d0
           
      RETURN
!
      elseif((lakon(nelem)(2:7).eq.'REEX').or.
     &       (lakon(nelem)(2:7).eq.'LPEX')) then
!
!     EXIT LOSS COEFFICIENT FOR LAMINAR FLOWS DEPENDING ON THE
!     ACTUAL VELOCITY DISTRIBUTION AT THE EXIT
!
!     Input parameters
!     
!     Inlet/outlet sections
         a1=prop(ielprop(nelem)+1)
         a2=prop(ielprop(nelem)+2)
!     Hydraulic diameter
         dh=prop(ielprop(nelem)+3)
         if((dh.eq.0).and.(A1.le.A2)) then
            dh=dsqrt(4d0*A1/Pi)
         elseif((dh.eq.0).and.(A1.gt.A2)) then
            dh=dsqrt(4d0*A2/Pi)
         endif
!     Reference element
         nelem_ref=int(prop(ielprop(nelem)+4))
!
         if (lakon(nelem_ref)(2:5).ne.'GAPF') then
            write(*,*) '*ERROR in zeta_calc :the reference element is no
     &t of type GASPIPE'
           stop
         endif
!
         if(lakon(nelem_ref)(2:6).eq.'GAPFI') then
            isothermal=.true.
         endif
!     Length of the previous pipe element
         l=abs(prop(ielprop(nelem_ref)+3))
!    
         if (reynolds .le. 2300.) then
!     (LAMINAR FLOW)
            ldre=l/dh/reynolds
            call onedint (XDRE,ZETAEX,12,ldre,zeta,1,1,0,IER)
         elseif ((reynolds .gt. 2300) .and. (reynolds .lt. 3000)) then
!     (TRANSITION LAMINAR-TURBULENT)
            ldre=l/DH/2300.
            call onedint (XDRE,ZETAEX,12,ldre,zetah,1,1,0,IER)
            zeta=zetah-(zetah-1.)*((reynolds-2300.)/700.)
         else
!     (TURBULENT FLOW, RE .GT. 3000)
            zeta=1.
       endif
!     
      RETURN
!
      elseif((lakon(nelem)(2:7).eq.'RELOLI').or.
     &       (lakon(nelem)(2:7).eq.'LPLOLI')) then 
!     
!     'METHOD OF LICHTAROWICZ'
!     "Discharge coeffcients for incompressible non-cavitating 
!     flow through long orifices"
!     A. Lichtarowicz, R.K duggins and E. Markland
!     Journal  Mechanical Engineering Science , vol 7, No. 2, 1965
!
!     TOTAL PRESSURE LOSS COEFFICIENT FOR LONG ORIFICES AND LOW REYNOLDS
!     NUMBERS ( RE < 2.E04 )
!
!     Input parameters
!     
!     Inlet/outlet sections
         a1=prop(ielprop(nelem)+1)
         a2=prop(ielprop(nelem)+2)
!     Hydraulic diameter
         dh=prop(ielprop(nelem)+3)
         if((dh.eq.0).and.(A1.le.A2)) then
            dh=dsqrt(4d0*A1/Pi)
         elseif((dh.eq.0).and.(A1.gt.A2)) then
            dh=dsqrt(4d0*A2/Pi)
         endif
!     Length
         l=prop(ielprop(nelem)+4)
!     Isotermal
!
         lzd=dabs(l)/dh
!     
         cdu=0.827-0.0085*lzd
         km=a1/a2
         call  cd_lichtarowicz(cd,cdu,reynolds,km,lzd)
         if (reynolds .gt. 2.E04) then
            write(*,*) 
     &        '*WARNING in zeta_calc: range of application exceeded !'
         endif
!     
         zeta=1./cd**2
!     
         return
!     
!     Branch
!     
      elseif((lakon(nelem)(2:5).eq.'REBR').or.
     &       (lakon(nelem)(2:5).eq.'LPBR')) then 
         nelem0=prop(ielprop(nelem)+1)
         nelem1=prop(ielprop(nelem)+2)
         nelem2=prop(ielprop(nelem)+3)
         A0=prop(ielprop(nelem)+4)
         A1=prop(ielprop(nelem)+5)
         A2=prop(ielprop(nelem)+6)
         alpha1=prop(ielprop(nelem)+7)
         alpha2=prop(ielprop(nelem)+8)
!     
!     node definition
!     
         node10=kon(ipkon(nelem0)+1)
         node20=kon(ipkon(nelem0)+3)
         nodem0=kon(ipkon(nelem0)+2)
!     
         node11=kon(ipkon(nelem1)+1)
         node21=kon(ipkon(nelem1)+3)
         nodem1=kon(ipkon(nelem1)+2)
!     
         node12=kon(ipkon(nelem2)+1)
         node22=kon(ipkon(nelem2)+3)
         nodem2=kon(ipkon(nelem2)+2)
!     
!     determining the nodes which are not in common
!     
         if(node10.eq.node11) then
            node0=node10 
            node1=node21
            if(node11.eq.node12) then
               node2=node22
            elseif(node11.eq.node22) then
               node2=node12
            endif
         elseif(node10.eq.node21) then
            node0=node10
            node1=node11
            if(node21.eq.node12) then
               node0=node22
            elseif(node21.eq.node22) then
               node2=node12
            endif
         elseif(node20.eq.node11) then
            node0=node20
            node1=node21
            if(node11.eq.node12) then
               node2=node22
            elseif(node11.eq.node22) then
               node2=node12 
            endif
         elseif(node20.eq.node21) then
            node0=node20
            node1=node11
            if(node11.eq.node21) then
               node2=node22
           elseif(node21.eq.node22) then
               node2=node12
            endif
         endif
!     
!     density
!     
         if(lakon(nelem)(2:3).eq.'RE') then
!
!           for gases
!            
            qred_crit=dsqrt(kappa/R)*
     &           (1+0.5d0*(kappa-1))**(-0.5d0*(kappa+1)/(kappa-1))
!     
            icase=0
!     
            Tt0=v(0,node0)
            xflow0=v(1,nodem0)
            pt0=v(2,node0)
!     
            Qred_0=dabs(xflow0)*dsqrt(Tt0)/(A0*pt0)
            if(Qred_0.gt.qred_crit)
     &           then
               xflow0=qred_crit*(A0*pt0)/dsqrt(Tt0)
            endif
!     
            call ts_calc(xflow0,Tt0,Pt0,kappa,r,a0,Ts0,icase)
            M0=dsqrt(2/(kappa-1)*(Tt0/Ts0-1))
!     
            rho0=pt0/(R*Tt0)*(Tt0/Ts0)**(-1/(kappa-1))
!     
            Tt1=v(0,node1)
            xflow1=v(1,nodem1)
            pt1=v(2,node0)
!     
            Qred_1=dabs(xflow1)*dsqrt(Tt1)/(A1*pt1)
            if(Qred_1.gt.qred_crit)
     &           then
               xflow1=qred_crit*(A1*pt1)/dsqrt(Tt1)
            endif
!     
            call ts_calc(xflow1,Tt1,Pt1,kappa,r,a1,Ts1,icase)
            M1=dsqrt(2/(kappa-1)*(Tt1/Ts1-1))
!     
            rho1=pt1/(R*Tt1)*(Tt1/Ts1)**(-1/(kappa-1))
!     
            Tt2=v(0,node2)
            xflow2=v(1,nodem2)
            pt2=v(2,node0)
!     
            Qred_2=dabs(xflow2)*dsqrt(Tt2)/(A2*pt2)
            if(Qred_2.gt.qred_crit) then
               xflow2=qred_crit*(A2*pt2)/dsqrt(Tt2)
            endif
!     
            call ts_calc(xflow2,Tt2,Pt2,kappa,r,a2,Ts2,icase)
            M2=dsqrt(2/(kappa-1)*(Tt2/Ts2-1))
            rho2=pt2/(R*Tt2)*(Tt2/Ts2)**(-1/(kappa-1))
         else
!
!           for liquids the density is supposed to be constant
!           across the element
!
            rho0=1.d0
            rho1=1.d0
            rho2=1.d0
         endif
!     
!     volumic flows (positive)
!     
         V0=dabs(v(1,nodem0)/rho0)
         V1=dabs(v(1,nodem1)/rho1)
         V2=dabs(v(1,nodem2)/rho2)
!
         V1V0=V1/V0
         V2V0=V2/V0
! 
         a0a1=a0/a1
         a0a2=a0/a2
         a2a0=1/a0a2
!     
         W0W1=1/(V1V0*a0a1)
         W0W2=1/(V2V0*a0a2)
!     
!     Branch Joint Genium 
!     Branching Flow Part IV - TEES
!     Fluid Flow Division
!     Section 404.2 page 4 December 1986
!     Genium Publishing (see www.genium.com)
!     
         if((lakon(nelem)(2:7).eq.'REBRJG').or.
     &      (lakon(nelem)(2:7).eq.'LPBRJG')) then
!     
            ang1s=(1.41d0-0.00594*alpha1)*alpha1*pi/180
            ang2s=(1.41d0-0.00594*alpha2)*alpha2*pi/180
!     
            cang1s=dcos(ang1s)
            cang2s=dcos(ang2s)
!     
!     linear part
!     
            zetlin=2.d0*(V1V0**2*a0a1*cang1s+V2V0**2*a0a2*cang2s)
!
            if(nelem.eq.nelem1) then
               call onedint(XANG,YANG,11,alpha1,lam10,1,2,22,ier)
               zeta=lam10/64*(V1V0*a0a1)**2-zetlin+1d0
               zeta=zeta*(W0W1)**2
!     
            elseif(nelem.eq.nelem2) then
               call onedint(XANG,YANG,11,alpha2,lam20,1,2,22,ier)
               zeta=lam20/64*(V2V0*a0a2)**2-zetlin+1d0
               zeta=zeta*(W0W2)**2
            endif
            return
!     
         elseif((lakon(nelem)(2:8).eq.'REBRJI1').or.
     &          (lakon(nelem)(2:8).eq.'LPBRJI1')) then
!
!     Branch Joint Idelchik 1
!     Diagrams of resistance coefficients p260-p266 section VII
!     I.E. IDEL'CHIK 'HANDBOOK OF HYDRAULIC RESISTANCE'
!     2nd edition 1986,HEMISPHERE PUBLISHING CORP.
!     ISBN 0-899116-284-4
!     
            a0a2=a0/a2
            if(alpha2.lt.60.) then
               if(nelem.eq.nelem1) then
                  zeta=1.d0-V1V0**2
     &                 -2.d0*a0a2*V2V0**2*dcos(alpha2*pi/180)
                   zeta=zeta*(W0W1)**2
               elseif(nelem.eq.nelem2) then
                  zeta=1.d0-V1V0**2
     &                 -2.d0*a0a2*V2V0**2*dcos(alpha2*pi/180)
     &                 +(a0a2*V2V0)**2-V1V0**2
                  zeta=zeta*(W0W2)**2
               endif
!     
            elseif(alpha2.eq.60) then
!     
!     proceeding as for alpha2<60 with cos(alpha2)=0.5
!     
               if(nelem.eq.nelem1) then
                  zeta=1.d0-V1V0**2-a0a2*V2V0**2
                  zeta=zeta*(W0W1)**2
               elseif(nelem.eq.nelem2) then
                  zeta=1.d0-V1V0**2-a0a2*V2V0**2
     &                 +(a0a2*V2V0)**2-V1V0**2
                  zeta=zeta*(W0W2)**2
               endif
!     
            elseif(alpha2.lt.90) then
!     
!     linear interpolation between alpha2=60 and alpha2=90
!     
               z1_60=1.d0-V1V0**2-a0a2*V2V0**2
               z1_90=(1.55d0-V2V0)*V2V0
               if(nelem.eq.nelem1) then
                  zeta=z1_60+(z1_90-z1_60)*(alpha2-60.d0)/30
                  zeta=zeta*(W0W1)**2
               elseif(nelem.eq.nelem2) then
                  z2_60=z1_60+(a0a2*V2V0)**2-V1V0**2
                  call onedint(TA2A0,TAFAKT,12,a2a0,afakt,
     &                 1,1,11,ier)
                  z2_90=afakt*(1.d0+(a0a2*V2V0)**2-2.d0*V1V0**2)
                  zeta=z2_60+(z2_90-z2_60)*(alpha2-60.d0)/30d0
                  zeta=zeta*(W0W2)**2
               endif
!     
            elseif (alpha2.eq.90) then
               if(nelem.eq.nelem1) then
                  zeta=(1.55d0-V2V0)*V2V0
                  zeta=zeta*(W0W1)**2
               elseif(nelem.eq.nelem2) then
                  call onedint(TA2A0,TAFAKT,12,a2a0,afakt,
     &                 1,1,11,ier) 
                  zeta=afakt*(1.d0+(a0a2*V2V0)**2-2.d0*V1V0**2)
                  zeta=zeta*(W0W2)**2
               endif
            endif
            return
!     
         elseif((lakon(nelem)(2:8).eq.'REBRJI2').or.
     &          (lakon(nelem)(2:8).eq.'LPBRJI2')) then
!     
!     Branch Joint Idelchik 2
!     Diagrams of resistance coefficients page 348-352 
!          I.E. IDEL'CHIK 'HANDBOOK OF HYDRAULIC RESISTANCE'
!     2nd edition 1986,HEMISPHERE PUBLISHING CORP.
!     ISBN 0-899116-284-4 page 348-352 
!     
            if(alpha2.lt.60) then
               if(nelem.eq.nelem1) then
                  zeta=1+a0a1*V1V0**2*(a0a1-2.)
     &                 -2d0*a0a2*V2V0**2*dcos(alpha2*pi/180)
!     correction term
                  call twodint(KSTAB,6,11,a2a0,alpha2,ks2,1
     &                 ,iexpbr1,ier)
                  zeta=zeta+ks2
                  zeta=zeta*(W0W1)**2
               elseif(nelem.eq.nelem2) then
                  zeta=1+a0a1*V1V0**2*(a0a1-2.)
     &                 -2d0*a0a2*V2V0**2*dcos(alpha2*pi/180)
     &                 -(a0a1*V1V0)**2+(a0a2*V2V0)**2
                  call twodint(KBTAB,6,11,a2a0,alpha2,kb,1,
     &                 iexpbr1,ier)
                  zeta=zeta+kb
                  zeta=zeta*(W0W2)**2
               endif
!     
            elseif(alpha2.eq.60) then
!     as for alpha2 < 60 , with dcos(alpha2)=0.5
               if(nelem.eq.nelem1) then
                  zeta=1+a0a1*V1V0**2*(a0a1-2.)-a0a2*V2V0**2
                  call twodint(KSTAB,6,11,a2a0,alpha2,ks2,1,
     &                 iexpbr1,ier)
                  zeta=zeta+ks2
                  zeta=zeta*(W0W1)**2
               elseif(nelem.eq.nelem2) then
                  zeta=1+a0a1*V1V0**2*(a0a1-2.)-a0a2*V2V0**2
     &                 -(a0a1*V1V0)**2+(a0a2*V2V0)**2
                  call twodint(KBTAB,6,11,a2a0,alpha2,kb,1,
     &                 iexpbr1,ier)
                  zeta=zeta+kb
                  zeta=zeta*(W0W2)**2
               endif
!     
            elseif(alpha2.lt.90) then
!     linear interpolation between alpha2=60 and alpha2=90
               z1_60=1+a0a1*V1V0**2*(a0a1-2.)-a0a2*V2V0**2
!     correction term
               call twodint(KSTAB,6,11,a2a0,alpha2,ks2,1,
     &              iexpbr1,ier)
               z1_60=z1_60+ks2
               if(nelem.eq.nelem1) then
                  call twodint(Z90TAB,6,11,a2a0,V2V0,z1_90,
     &                 1,iexpbr1,ier)
                  zeta=z1_60+(z1_90-z1_60)*(alpha2-60)/30
                  zeta=zeta*(W0W1)**2
               elseif(nelem.eq.nelem2) then
                  z2_60=z1_60-(a0a1*V1V0)**2+(a0a2*v2v0)**2
                  call twodint(KBTAB,6,11,a2a0,alpha2,kb,1,
     &                 iexpbr1,ier)
                  z2_60=z2_60+kb-ks2
                  z2_90=1.+(a0a2*V2V0)**2-2*a0a1*V1V0**2+kb
                  zeta=z2_60+(z2_90-z2_60)*(alpha2-60)/30
                  zeta=zeta*(W0W2)**2
               endif
            elseif(alpha2.eq.90) then
               if(nelem.eq.nelem2) then
                  call twodint(KBTAB,6,11,a2a0,alpha2,kb,1,
     &                 iexpbr1,ier)
                  zeta=1.+(a0a2*V2V0)**2-2*a0a1*V1V0**2+kb
                  zeta=zeta*(W0W2)**2
               elseif(nelem.eq.nelem1) then
!     table interpolation
                  call twodint(Z90TAB,6,11,a2a0,V2V0,zeta,
     &                 1,iexpbr1,ier)
                  zeta=zeta*(W0W1)**2
!     cheching whether the table eveluation in the eptrapolated domain
!     (This procedure is guessed from the original table)
!     
                  Z90LIM11=Z90LIMX(1)
                  Z90LIM51=Z90LIMX(5)
                  if((a2a0.ge.Z90LIM11)
     &                 .and.(a2a0.le.Z90LIM51))then
                     call onedint(Z90LIMX,Z90LIMY,5,A2A0,
     &                    V2V0L,1,1,11,ier)
                     if(V2V0.gt.V2V0L) then
                        write(*,*) 'WARNING in zeta_calc: in element',
     &                                 nelem
                        write(*,*) 
     &            '        V2V0 in the extrapolated domain'
                        write(*,*) '        for zeta table (branch 1)'
                     endif
                  endif
               endif
            endif
            return
!
         elseif((lakon(nelem)(2:7).eq.'REBRSG').or.
     &          (lakon(nelem)(2:7).eq.'LPBRSG')) then
!
!     Branch Split Genium 
!     Branching Flow Part IV - TEES
!     Fluid Flow Division
!     Section 404.2 page 3 December 1986
!     Genium Publishing (see www.genium.com)
!          
            if(nelem.eq.nelem1) then
!     
               ang1s=(1.41d0-0.00594*alpha1)*alpha1*pi/180
!     
               cang1s=dcos(ang1s)
!     
               if(alpha1.le.22.5) then
                  lam11=0.0712*alpha1**0.7041+0.37
                  lam12=0.0592*alpha1**0.7029+0.37
               else
                  lam11=1.d0
                  lam12=0.9d0
               endif
               zeta=lam11+(2.d0*lam12-lam11)*(V1V0*a0a1)**2
     &              -2d0*lam12*V1V0*a0a1*cang1s
               zeta=zeta*(W0W1)**2
!     
            elseif(nelem.eq.nelem2) then
!     
               ang2s=(1.41d0-0.00594*alpha2)*alpha2*pi/180
! 
               cang2s=dcos(ang2s)
!     
               if(alpha2.le.22.5) then
                  lam21=0.0712*alpha2**0.7041+0.37
                  lam22=0.0592*alpha2**0.7029+0.37
               else
                  lam21=1.d0
                  lam22=0.9d0
               endif
!     
               zeta=lam21+(2.d0*lam22-lam21)*(V2V0*a0a2)**2
     &              -2d0*lam22*V2V0*a0a2*cang2s
               zeta=zeta*(W0W2)**2
!     
            endif
            return 
!     
         elseif((lakon(nelem)(2:8).eq.'REBRSI1').or.
     &          (lakon(nelem)(2:8).eq.'LPBRSI1'))  then 
!
!     Branch Split Idelchik 1
!     Diagrams of resistance coefficients p280,p282 section VII
!     I.E. IDEL'CHIK 'HANDBOOK OF HYDRAULIC RESISTANCE'
!     2nd edition 1986,HEMISPHERE PUBLISHING CORP.
!     ISBN 0-899116-284-4
!          
            W1W0=V1V0*a0a1
            W2W0=V2V0*a0a2
!     
            if(nelem.eq.nelem1) then
               zeta=0.4d0*(1-W1W0)**2
               zeta=zeta*(W0W1)**2
!
            elseif(nelem.eq.nelem2) then
!
               dh0=dsqrt(A0*4d0/Pi)
               if(dh0.eq.0) then
                  dh0=dsqrt(4d0*A0/Pi)
               endif
               dh2=dsqrt(A2*4d0/Pi)
               if(dh2.eq.0) then
                  dh2=dsqrt(4d0*A2/Pi)
               endif
!
               hq=dh2/dh0
               if(alpha2.le.60.or.hq.le.2.d0/3.d0) then
                  zeta=0.95d0*((W2W0-2d0*dcos(alpha2*pi/180))
     &                 *W2W0+1.d0)
                  zeta=zeta*(W0W2)**2
               else
                  z2d390=0.95d0*((W2W0-2d0*dcos(90.d0*pi/180))
     &                 *W2W0+1.d0)
                  z1p090=0.95*(0.34d0+W2W0**2)
                  z90=z2d390+(3*hq-2.d0)*(z1p090-z2d390)
                  Z60=0.95d0*((W2W0-2d0*dcos(60.d0*pi/180))
     &                 *W2W0+1.d0)
                  zeta=z60+(alpha2/30.d0-2.d0)*(z90-z60)
                  zeta=zeta*(W0W2)**2
               endif
            endif
            return
!                 
         elseif((lakon(nelem)(2:8).eq.'REBRSI2').or.
     &          (lakon(nelem)(2:8).eq.'LPBRSI2')) then 
!
!     Branch Split Idelchik 2
!     Diagrams of resistance coefficients p289,section VII
!     I.E. IDEL'CHIK 'HANDBOOK OF HYDRAULIC RESISTANCE'
!     2nd edition 1986,HEMISPHERE PUBLISHING CORP.
!     ISBN 0-899116-284-4
!     
            if(nelem.eq.nelem1) then
               W1W0=V1V0*a0a1
               W0W1=1/W1W0
               zeta=1.d0+0.3d0*W1W0**2
               zeta=zeta*(W0W1)**2
            elseif(nelem.eq.nelem2) then
               W2W0=V2V0*a0a2
               W0W2=1/W2W0
               zeta=1.d0+0.3d0*W2W0**2
               zeta=zeta*(W0W2)**2
            endif
            return
         endif
      endif
!     
      end
      
      
