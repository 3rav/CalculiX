/*     CalculiX - A 3-dimensional finite element program                   */
/*              Copyright (C) 1998-2007 Guido Dhondt                          */

/*     This program is free software; you can redistribute it and/or     */
/*     modify it under the terms of the GNU General Public License as    */
/*     published by the Free Software Foundation(version 2);    */
/*                    */

/*     This program is distributed in the hope that it will be useful,   */
/*     but WITHOUT ANY WARRANTY; without even the implied warranty of    */ 
/*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the      */
/*     GNU General Public License for more details.                      */

/*     You should have received a copy of the GNU General Public License */
/*     along with this program; if not, write to the Free Software       */
/*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.         */

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "CalculiX.h"
#include "matrixstorage.h"

void matrixstorage(double *ad, double **aup, double *adb, double *aub, 
                double *sigma,int *icol, int **irowp, 
                int *neq, int *nzs, int *ntrans, int *inotr,
                double *trab, double *co, int *nk, int *nactdof,
                char *jobnamec){

  char fsti[132]="",fmas[132]="";
  int i,j,k,l,*irow=NULL,*ai=NULL,*aj=NULL,kflag=2,ndim,jref,kstart,klen,
    *ipoint=NULL,npoint_,npoint,neq3,index,i3l,i3c,i3lo,i3co,idof,n,il,
    ic,id,itrans,ndim2,*ipoindex=NULL;
  double *au=NULL,*aa=NULL,*trans=NULL,*aa3=NULL,a[9];
  FILE *f2,*f3;

  strcpy(fsti,jobnamec);
  strcat(fsti,".sti");

  printf(" Storing the stiffness matrix in file %s \n\n",fsti);
  printf(" *INFO: this routine only works in the absence of SPC's! \n\n");

  if((f2=fopen(fsti,"wb"))==NULL){
    printf("*ERROR in matrixstorage: cannot open %s for writing...\n",fsti);
    FORTRAN(stop,());
  }

  au=*aup;
  irow=*irowp;

  ndim=*neq+*nzs;

  itrans=0;
  if(*ntrans!=0){
    for(i=0;i<*nk;i++){
      if(inotr[2*i]!=0){
        itrans=1;
        break;
      }
    }
  }

  /* stiffness matrix */

  if(itrans==0){
    
    /* no transformation */

    aa=NNEW(double,ndim);
    ai=NNEW(int,ndim);
    aj=NNEW(int,ndim);
    
    k=0;
    for(i=0;i<*neq;i++){
      ai[k]=i+1;
      aj[k]=i+1;
      aa[k]=ad[i];
      k++;
    }
    l=0;
    for(i=0;i<*neq;i++){
      for(j=0;j<icol[i];j++){
        ai[k]=i+1;
        aj[k]=irow[l];
        aa[k]=au[l];
        k++;l++;
      }
    }
  }
  else{
    
    /* transformation: matrices are stored in transformed coordinates */

    ndim2=*neq+2**nzs;

    /* aa contains the linear storage of the individual matrix elements */

    aa=NNEW(double,ndim2);

    /* aa3 contains the linear storage of the 3x3 matrices */

    aa3=NNEW(double,ndim2);
    ai=NNEW(int,ndim2);
    aj=NNEW(int,ndim2);
    
    k=0;
    for(i=0;i<*neq;i++){
      ai[k]=i+1;
      aj[k]=i+1;
      aa[k]=ad[i];
      k++;
    }
    l=0;
    for(i=0;i<*neq;i++){
      for(j=0;j<icol[i];j++){
        ai[k]=i+1;
        aj[k]=irow[l];
        aa[k]=au[l];
        k++;
        ai[k]=irow[l];
        aj[k]=i+1;
        aa[k]=au[l];
        k++;
        l++;
      }
    }

    FORTRAN(isortiid,(aj,ai,aa,&ndim2,&kflag));

    k=0;
    for(i=0;i<*neq;i++){
      jref=aj[k];
      kstart=k;
      do{
        k++;
        if(aj[k]!=jref) break;
      }while(1);
      klen=k-kstart;
      FORTRAN(isortiid,(&ai[kstart],&aj[kstart],&aa[kstart],&klen,&kflag));
    }

    /* npoint is the number of 3x3 matrices
       ipoint contains the two-dimensional location of the matrices 
            (row and column stored as column x neq3 + row)
       ipoindex contains the one-dimensional location of the matrices in
       fields aa3 */

    npoint_=*neq;
    npoint=0;
    ipoint=NNEW(int,npoint_);
    ipoindex=NNEW(int,npoint_);

    neq3=*neq/3;
    index=0;

    /* storing the matrix as a matrix of 3x3 submatrices */

    for(i=0;i<ndim2;i++){
      il=ai[i];
      ic=aj[i];
      i3co=(ic-1)%3;
      i3c=((ic-1)-i3co)/3;
      i3lo=(il-1)%3;
      i3l=((il-1)-i3lo)/3;
      k=i3c*neq3+i3l;
      FORTRAN(nident,(ipoint,&k,&npoint,&id));
      if(npoint==0){
        npoint++;
        ipoint[npoint-1]=k;
        ipoindex[npoint-1]=index;
      }
      else if(ipoint[id-1]!=k){
        npoint++;
        if(npoint>npoint_){
          npoint_=(int)(1.1*npoint_);
          RENEW(ipoint,int,npoint_);
          RENEW(ipoindex,int,npoint_);
        }
        index+=9;
        ipoint[npoint-1]=k;
        ipoindex[npoint-1]=index;
      }
      else{
        index=ipoindex[id-1];
      }
      aa3[index+3*i3co+i3lo]=aa[i];
    }

    /* defining the transformation matrix (diagonal matrix of
       3x3 submatrices */

    trans=NNEW(double,9*neq3);
    for (i=0;i<*nk;i++){
      idof=nactdof[4*i+1];
      if(idof==0) continue;
      itrans=inotr[2*i];
      if(itrans==0){
        for(j=0;j<9;j++){
          trans[3*(idof-1)+j]=0.;
        }
        trans[3*(idof-1)]=1.;
        trans[3*(idof-1)+4]=1.;
        trans[3*(idof-1)+8]=1.;
      }
      else{
        FORTRAN(transformatrix,(&trab[7*itrans-7],&co[3*i],a));
        for(j=0;j<9;j++){
          trans[3*(idof-1)+j]=a[j];
        }
      }
    }

    /* postmultiplying the matrix with the transpose of the
       transformation matrix */

    for(i=0;i<npoint;i++){
      i3l=ipoint[i]%neq3;
      i3c=(ipoint[i]-i3l)/neq3;
      n=2;
      FORTRAN(mult,(&aa3[9*i],&trans[9*i3c],&n));
    }

    /* premultiplying the matrix with the transformation matrix */

    for(i=0;i<npoint;i++){
      i3l=ipoint[i]%neq3;
      n=1;
      FORTRAN(mult,(&aa3[9*i],&trans[9*i3l],&n));
    }

    /* storing the new matrix in a linear format */

    k=-1;
    for(i=0;i<npoint;i++){
      i3l=ipoint[i]%neq3;
      i3c=(ipoint[i]-i3l)/neq3;
      for(j=0;j<9;j++){
        i3lo=j%3;
        i3co=(j-i3lo)/3;
        ic=3*i3c+i3co+1;
        il=3*i3l+i3lo+1;
        if(il>ic) continue;
        k++;
        ai[k]=il;
        aj[k]=ic;
        aa[k]=aa3[9*i+j];
      }
    }
    free(aa3);free(ipoint);free(ipoindex);free(trans);
  }

  FORTRAN(isortiid,(aj,ai,aa,&ndim,&kflag));

  k=0;
  for(i=0;i<*neq;i++){
    jref=aj[k];
    kstart=k;
    do{
      k++;
      if(aj[k]!=jref) break;
    }while(1);
    klen=k-kstart;
    FORTRAN(isortiid,(&ai[kstart],&aj[kstart],&aa[kstart],&klen,&kflag));
  }

  for(i=0;i<ndim;i++){
    fprintf(f2,"%d %d %20.13e\n",ai[i],aj[i],aa[i]);
  }

  fclose(f2);

  free(ai);free(aj);free(aa);

  /* mass matrix */

  strcpy(fmas,jobnamec);
  strcat(fmas,".mas");

  printf(" Storing the mass matrix in file %s \n\n",fmas);
  printf(" *INFO: this routine only works in the absence of SPC's! \n\n");

  if((f3=fopen(fmas,"wb"))==NULL){
    printf("*ERROR in matrixstorage: cannot open %s for writing...\n",fmas);
    FORTRAN(stop,());
  }

  if(itrans==0){
    
    /* no transformation */

    aa=NNEW(double,ndim);
    ai=NNEW(int,ndim);
    aj=NNEW(int,ndim);
    
    k=0;
    for(i=0;i<*neq;i++){
      ai[k]=i+1;
      aj[k]=i+1;
      aa[k]=adb[i];
      k++;
    }
    l=0;
    for(i=0;i<*neq;i++){
      for(j=0;j<icol[i];j++){
        ai[k]=i+1;
        aj[k]=irow[l];
        aa[k]=aub[l];
        k++;l++;
      }
    }
  }
  else{
    
    /* transformation: matrices are stored in transformed coordinates */

    ndim2=*neq+2**nzs;

    /* aa contains the linear storage of the individual matrix elements */

    aa=NNEW(double,ndim2);

    /* aa3 contains the linear storage of the 3x3 matrices */

    aa3=NNEW(double,ndim2);
    ai=NNEW(int,ndim2);
    aj=NNEW(int,ndim2);
    
    k=0;
    for(i=0;i<*neq;i++){
      ai[k]=i+1;
      aj[k]=i+1;
      aa[k]=adb[i];
      k++;
    }
    l=0;
    for(i=0;i<*neq;i++){
      for(j=0;j<icol[i];j++){
        ai[k]=i+1;
        aj[k]=irow[l];
        aa[k]=aub[l];
        k++;
        ai[k]=irow[l];
        aj[k]=i+1;
        aa[k]=aub[l];
        k++;
        l++;
      }
    }

    FORTRAN(isortiid,(aj,ai,aa,&ndim2,&kflag));

    k=0;
    for(i=0;i<*neq;i++){
      jref=aj[k];
      kstart=k;
      do{
        k++;
        if(aj[k]!=jref) break;
      }while(1);
      klen=k-kstart;
      FORTRAN(isortiid,(&ai[kstart],&aj[kstart],&aa[kstart],&klen,&kflag));
    }

    /* npoint is the number of 3x3 matrices
       ipoint contains the two-dimensional location of the matrices 
            (row and column stored as column x neq3 + row)
       ipoindex contains the one-dimensional location of the matrices in
       fields aa3 */

    npoint_=*neq;
    npoint=0;
    ipoint=NNEW(int,npoint_);
    ipoindex=NNEW(int,npoint_);

    neq3=*neq/3;
    index=0;

    /* storing the matrix as a matrix of 3x3 submatrices */

    for(i=0;i<ndim2;i++){
      il=ai[i];
      ic=aj[i];
      i3co=(ic-1)%3;
      i3c=((ic-1)-i3co)/3;
      i3lo=(il-1)%3;
      i3l=((il-1)-i3lo)/3;
      k=i3c*neq3+i3l;
      FORTRAN(nident,(ipoint,&k,&npoint,&id));
      if(npoint==0){
        npoint++;
        ipoint[npoint-1]=k;
        ipoindex[npoint-1]=index;
      }
      else if(ipoint[id-1]!=k){
        npoint++;
        if(npoint>npoint_){
          npoint_=(int)(1.1*npoint_);
          RENEW(ipoint,int,npoint_);
          RENEW(ipoindex,int,npoint_);
        }
        index+=9;
        ipoint[npoint-1]=k;
        ipoindex[npoint-1]=index;
      }
      else{
        index=ipoindex[id-1];
      }
      aa3[index+3*i3co+i3lo]=aa[i];
    }

    /* defining the transformation matrix (diagonal matrix of
       3x3 submatrices */

    trans=NNEW(double,9*neq3);
    for (i=0;i<*nk;i++){
      idof=nactdof[4*i+1];
      if(idof==0) continue;
      itrans=inotr[2*i];
      if(itrans==0){
        for(j=0;j<9;j++){
          trans[3*(idof-1)+j]=0.;
        }
        trans[3*(idof-1)]=1.;
        trans[3*(idof-1)+4]=1.;
        trans[3*(idof-1)+8]=1.;
      }
      else{
        FORTRAN(transformatrix,(&trab[7*itrans-7],&co[3*i],a));
        for(j=0;j<9;j++){
          trans[3*(idof-1)+j]=a[j];
        }
      }
    }

    /* postmultiplying the matrix with the transpose of the
       transformation matrix */

    for(i=0;i<npoint;i++){
      i3l=ipoint[i]%neq3;
      i3c=(ipoint[i]-i3l)/neq3;
      n=2;
      FORTRAN(mult,(&aa3[9*i],&trans[9*i3c],&n));
    }

    /* premultiplying the matrix with the transformation matrix */

    for(i=0;i<npoint;i++){
      i3l=ipoint[i]%neq3;
      n=1;
      FORTRAN(mult,(&aa3[9*i],&trans[9*i3l],&n));
    }

    /* storing the new matrix in a linear format */

    k=-1;
    for(i=0;i<npoint;i++){
      i3l=ipoint[i]%neq3;
      i3c=(ipoint[i]-i3l)/neq3;
      for(j=0;j<9;j++){
        i3lo=j%3;
        i3co=(j-i3lo)/3;
        ic=3*i3c+i3co+1;
        il=3*i3l+i3lo+1;
        if(il>ic) continue;
        k++;
        ai[k]=il;
        aj[k]=ic;
        aa[k]=aa3[9*i+j];
      }
    }
    free(aa3);free(ipoint);free(ipoindex);free(trans);
  }

  FORTRAN(isortiid,(aj,ai,aa,&ndim,&kflag));

  k=0;
  for(i=0;i<*neq;i++){
    jref=aj[k];
    kstart=k;
    do{
      k++;
      if(aj[k]!=jref) break;
    }while(1);
    klen=k-kstart;
    FORTRAN(isortiid,(&ai[kstart],&aj[kstart],&aa[kstart],&klen,&kflag));
  }

  for(i=0;i<ndim;i++){
    fprintf(f3,"%d %d %20.13e\n",ai[i],aj[i],aa[i]);
  }

  fclose(f3);

  free(ai);free(aj);free(aa);

  *aup=au;
  *irowp=irow;

  FORTRAN(stop,());

  return;
}
