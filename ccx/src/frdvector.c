/*     CalculiX - A 3-dimensional finite element program                 */
/*              Copyright (C) 1998-2011 Guido Dhondt                          */

/*     This program is free software; you can redistribute it and/or     */
/*     modify it under the terms of the GNU General Public License as    */
/*     published by the Free Software Foundation(version 2);    */
/*                                                                       */

/*     This program is distributed in the hope that it will be useful,   */
/*     but WITHOUT ANY WARRANTY; without even the implied warranty of    */ 
/*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the      */
/*     GNU General Public License for more details.                      */

/*     You should have received a copy of the GNU General Public License */
/*     along with this program; if not, write to the Free Software       */
/*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.         */

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include "CalculiX.h"

void frdvector(double *v,int *iset,int *ntrans,char * filabl,int *nkcoords,
               int *inum,char *m1,int *inotr,double *trab,double *co,
               int *istartset,int *iendset,int *ialset,int *mi,int *ngraph,
               FILE *f1,char *output,char *m3){

  int i,j,k,l,m,nksegment;
      
  int iw;

  float ifl;
  
  double a[9];

  if(*iset==0){
    if((*ntrans==0)||(strcmp1(&filabl[5],"G")==0)){
      for(i=0;i<*nkcoords;i++){
	if(inum[i]<=0) continue;
	if(strcmp1(output,"asc")==0){
	  fprintf(f1,"%3s%10d%12.5E%12.5E%12.5E\n",m1,i+1,v[(mi[1]+1)*i+1],
		  v[(mi[1]+1)*i+2],v[(mi[1]+1)*i+3]);
	}else{
	  iw=(int)(i+1);fwrite(&iw,sizeof(int),1,f1);
	  ifl=(float)v[(mi[1]+1)*i+1];fwrite(&ifl,sizeof(float),1,f1);
	  ifl=(float)v[(mi[1]+1)*i+2];fwrite(&ifl,sizeof(float),1,f1);
	  ifl=(float)v[(mi[1]+1)*i+3];fwrite(&ifl,sizeof(float),1,f1);
	}
      }
    }else{
      for(i=0;i<*nkcoords;i++){
	if(inum[i]<=0) continue;
	if(inotr[2*i]==0){
	  if(strcmp1(output,"asc")==0){
	    fprintf(f1,"%3s%10d%12.5E%12.5E%12.5E\n",m1,i+1,v[(mi[1]+1)*i+1],
		    v[(mi[1]+1)*i+2],v[(mi[1]+1)*i+3]);
	  }else{
	    iw=(int)(i+1);fwrite(&iw,sizeof(int),1,f1);
	    ifl=(float)v[(mi[1]+1)*i+1];fwrite(&ifl,sizeof(float),1,f1);
	    ifl=(float)v[(mi[1]+1)*i+2];fwrite(&ifl,sizeof(float),1,f1);
	    ifl=(float)v[(mi[1]+1)*i+3];fwrite(&ifl,sizeof(float),1,f1);
	  }
	}else{
	  FORTRAN(transformatrix,(&trab[7*(inotr[2*i]-1)],&co[3*i],a));
	  if(strcmp1(output,"asc")==0){
	    fprintf(f1,"%3s%10d%12.5E%12.5E%12.5E\n",m1,i+1,
		    v[(mi[1]+1)*i+1]*a[0]+v[(mi[1]+1)*i+2]*a[1]+v[(mi[1]+1)*i+3]*a[2],
		    v[(mi[1]+1)*i+1]*a[3]+v[(mi[1]+1)*i+2]*a[4]+v[(mi[1]+1)*i+3]*a[5],
		    v[(mi[1]+1)*i+1]*a[6]+v[(mi[1]+1)*i+2]*a[7]+v[(mi[1]+1)*i+3]*a[8]);
	  }else{
	    iw=(int)(i+1);fwrite(&iw,sizeof(int),1,f1);
	    ifl=(float)v[(mi[1]+1)*i+1]*a[0]+v[(mi[1]+1)*i+2]*a[1]+v[(mi[1]+1)*i+3]*a[2];
	    fwrite(&ifl,sizeof(float),1,f1);
	    ifl=(float)v[(mi[1]+1)*i+1]*a[3]+v[(mi[1]+1)*i+2]*a[4]+v[(mi[1]+1)*i+3]*a[5];
	    fwrite(&ifl,sizeof(float),1,f1);
	    ifl=(float)v[(mi[1]+1)*i+1]*a[6]+v[(mi[1]+1)*i+2]*a[7]+v[(mi[1]+1)*i+3]*a[8];
	    fwrite(&ifl,sizeof(float),1,f1);
	  }
	}
      }
    }
  }else{
    nksegment=(*nkcoords)/(*ngraph);
    for(k=istartset[*iset-1]-1;k<iendset[*iset-1];k++){
      if(ialset[k]>0){
	for(l=0;l<*ngraph;l++){
	  i=ialset[k]+l*nksegment-1;
	  if(inum[i]<=0) continue;
	  if((*ntrans==0)||(strcmp1(&filabl[5],"G")==0)||(inotr[2*i]==0)){
	    fprintf(f1,"%3s%10d%12.5E%12.5E%12.5E\n",m1,i+1,v[(mi[1]+1)*i+1],
		    v[(mi[1]+1)*i+2],v[(mi[1]+1)*i+3]);
	  }else{
	    FORTRAN(transformatrix,(&trab[7*(inotr[2*i]-1)],&co[3*i],a));
	    fprintf(f1,"%3s%10d%12.5E%12.5E%12.5E\n",m1,i+1,   
   	    v[(mi[1]+1)*i+1]*a[0]+v[(mi[1]+1)*i+2]*a[1]+v[(mi[1]+1)*i+3]*a[2],
	    v[(mi[1]+1)*i+1]*a[3]+v[(mi[1]+1)*i+2]*a[4]+v[(mi[1]+1)*i+3]*a[5],
	    v[(mi[1]+1)*i+1]*a[6]+v[(mi[1]+1)*i+2]*a[7]+v[(mi[1]+1)*i+3]*a[8]);
	  }
	}
      }else{
	l=ialset[k-2];
	do{
	  l-=ialset[k];
	  if(l>=ialset[k-1]) break;
	  for(m=0;m<*ngraph;m++){
	    i=l+m*nksegment-1;
	    if(inum[i]<=0) continue;
	    if((*ntrans==0)||(strcmp1(&filabl[5],"G")==0)||(inotr[2*i]==0)){
	      fprintf(f1,"%3s%10d%12.5E%12.5E%12.5E\n",m1,i+1,v[(mi[1]+1)*i+1],
		    v[(mi[1]+1)*i+2],v[(mi[1]+1)*i+3]);
	    }else{
	      FORTRAN(transformatrix,(&trab[7*(inotr[2*i]-1)],&co[3*i],a));
	      fprintf(f1,"%3s%10d%12.5E%12.5E%12.5E\n",m1,i+1,   
		      v[(mi[1]+1)*i+1]*a[0]+v[(mi[1]+1)*i+2]*a[1]+
                      v[(mi[1]+1)*i+3]*a[2],
		      v[(mi[1]+1)*i+1]*a[3]+v[(mi[1]+1)*i+2]*a[4]+
                      v[(mi[1]+1)*i+3]*a[5],
		      v[(mi[1]+1)*i+1]*a[6]+v[(mi[1]+1)*i+2]*a[7]+
                      v[(mi[1]+1)*i+3]*a[8]);
	    }
	  }
	}while(1);
      }
    }
  }
      
  if(strcmp1(output,"asc")==0)fprintf(f1,"%3s\n",m3);

  return;

}

