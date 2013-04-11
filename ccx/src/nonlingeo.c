/*     CalculiX - A 3-dimensional finite element program                 */
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
#include "CalculiX.h"
#ifdef SPOOLES
   #include "spooles.h"
#endif
#ifdef SGI
   #include "sgi.h"
#endif
#ifdef TAUCS
   #include "tau.h"
#endif


void nonlingeo(double **cop, int *nk, int **konp, int **ipkonp, char **lakonp,
	     int *ne, 
	     int *nodeboun, int *ndirboun, double *xboun, int *nboun, 
	     int *ipompc, int **nodempcp, double **coefmpcp, char *labmpc,
             int *nmpc, 
	     int *nodeforc, int *ndirforc,double *xforc, int *nforc, 
	     int *nelemload, char *sideload, double *xload,int *nload, 
	     double *ad, double *au, double *b, int *nactdof, 
	     int **icolp, int *jq, int **irowp, int *neq, int *nzl, 
	     int *nmethod, int *ikmpc, int *ilmpc, int *ikboun, 
	     int *ilboun,
             double *elcon, int *nelcon, double *rhcon, int *nrhcon,
	     double *alcon, int *nalcon, double *alzero, int **ielmatp,
	     int **ielorienp, int *norien, double *orab, int *ntmat_,
	     double *t0, double *t1, double *t1old, 
	     int *ithermal,double *prestr, int *iprestr, 
	     double **voldp,int *iperturb, double *sti, int *nzs,  
	     int *kode, double *adb, double *aub,char *filab, 
             int *idrct, int *jmax, int *jout, double *tinc,
             double *tper, double *tmin, double *tmax, double *eme,
	     double *xbounold, double *xforcold, double *xloadold,
             double *veold, double *accold,
	     char *amname, double *amta, int *namta, int *nam,
             int *iamforc, int *iamload,
             int *iamt1, double *alpha, int *iexpl,
	     int *iamboun, double *plicon, int *nplicon, double *plkcon,
             int *nplkcon,
             double *xstate, int *npmat_, int *istep, double *ttime,
             char *matname, double *qaold, int *mint_,
             int *isolver, int *ncmat_, int *nstate_, int *iumat,
             double *cs, int *mcs, int *nkon, double *ener, int *mpcinfo,
             int *nnn, char *output,
             double *shcon, int *nshcon, double *cocon, int *ncocon,
             double *physcon, int *nflow, double *ctrl, 
             char *set, int *nset, int *istartset,
             int *iendset, int *ialset, int *nprint, char *prlab,
             char *prset, int *nener,int *ikforc,int *ilforc, double *trab, 
             int *inotr, int *ntrans, double *fmpc, char *cbody,
             int *ibody, double *xbody, int *nbody, double *xbodyold,
             int *ielprop, double *prop, int *ntie, char *tieset,
             int *itpamp, int *iviewfile, char *jobnamec){
  char description[13]="            ",*lakon=NULL,jobnamef[264]="";  
  int *inum=NULL,k,iout=0,icntrl,iinc=0,jprint=0,iit=-1,jnz=0,
       icutb=0,istab=0,nmethodact=1,ifreebody,
       iperturb_sav,ilin,*icol=NULL,*irow=NULL,ielas=0,icmd=0,
       memmpc_,mpcfree,icascade,maxlenmpc,*nodempc=NULL,*iaux=NULL,
       *nodempcref=NULL,nmpcref,memmpcref_,mpcfreeref,*itg=NULL,
       *ieg=NULL,ntg=0,ntr,ntm,*iptri=NULL,*kontri=NULL,*nloadtr=NULL,
       *ipiv=NULL,*idist=NULL,ntri,newstep,mode=-1,noddiam=-1,
       ntrit,*inocs=NULL,inewton=0,*ipobody=NULL,*nacteq=NULL,
       *nactdog=NULL,nteq,network,*itietri=NULL,*koncont=NULL,
       ncont,ne0,nkon0,*ipkon=NULL,*kon=NULL,*ielorien=NULL,
       *ielmat=NULL,ncone,inext,itp=0,symmetryflag=0,inputformat=0;
  int mass[2]={0,0}, stiffness=1, buckling=0, rhsi=1, intscheme=0,idiscon=0,
    coriolis=0,*ipogn=NULL,*ign=NULL;
  double *stn=NULL,*v=NULL,*een=NULL,cam[2],*epn=NULL,*cg=NULL,
         *f=NULL,*fn=NULL,qa[2],qam[2],dtheta,theta,err,ram[2]={0.,0.},
         ram1[2]={0.,0.},ram2[2]={0.,0.},
         uam[2]={0.,0.},*vini=NULL,*ac=NULL,qa0,qau,ea,*straight=NULL,
         *t1act=NULL,qamold[2],*xbounact=NULL,*bc=NULL,
         *xforcact=NULL,*xloadact=NULL,*fext=NULL,
         reltime,time,bet=0.,gam=0.,*aux1=NULL,*aux2=NULL,dtime,*fini=NULL,
         *fextini=NULL,*veini=NULL,*accini=NULL,*xstateini=NULL,
         *ampli=NULL,scal1,*eei=NULL,*t1ini=NULL,
         *xbounini=NULL,dev,*xstiff=NULL,*stx=NULL,*stiini=NULL,
         *enern=NULL,*coefmpc=NULL,*aux=NULL,*xstaten=NULL,
         *coefmpcref=NULL,*enerini=NULL,*area=NULL,
         *tarea=NULL,*tenv=NULL,*dist=NULL,*erad=NULL,*pmid=NULL,
         *fij=NULL,*e1=NULL,*e2=NULL,*e3=NULL, *qfx=NULL,
         *qfn=NULL,*co=NULL,*vold=NULL,*fenv=NULL,sigma=0.,
         *xbodyact=NULL,*cgr=NULL,*voldgas=NULL,dthetaref;

  int *ipneigh=NULL,*neigh=NULL;

#ifdef SGI
  int token;
#endif
  strcpy1(jobnamef,jobnamec,132);
  strcpy1(&jobnamef[132],&jobnamec[132],132);

  qa0=ctrl[20];qau=ctrl[21];ea=ctrl[23];

  memmpc_=mpcinfo[0];mpcfree=mpcinfo[1];icascade=mpcinfo[2];
  maxlenmpc=mpcinfo[3];

  icol=*icolp;irow=*irowp;co=*cop;vold=*voldp;
  ipkon=*ipkonp;lakon=*lakonp;kon=*konp;ielorien=*ielorienp;
  ielmat=*ielmatp;

  nodempc=*nodempcp;coefmpc=*coefmpcp;
  if(icascade==2){
      nmpcref=*nmpc;memmpcref_=memmpc_;mpcfreeref=mpcfree;
      nodempcref=NNEW(int,3*memmpc_);
      for(k=0;k<3*memmpc_;k++){nodempcref[k]=nodempc[k];}
      coefmpcref=NNEW(double,memmpc_);
      for(k=0;k<memmpc_;k++){coefmpcref[k]=coefmpc[k];}
  }

  /* allocating a field for the stiffness matrix */

  xstiff=NNEW(double,27**mint_**ne);

  /* allocating force fields */

  f=NNEW(double,neq[1]);
  fext=NNEW(double,neq[1]);

  b=NNEW(double,neq[1]);
  vini=NNEW(double,4**nk);

  aux=NNEW(double,7*maxlenmpc);
  iaux=NNEW(int,maxlenmpc);

  /* allocating fields for the actual external loading */

  xbounact=NNEW(double,*nboun);
  xbounini=NNEW(double,*nboun);
  for(k=0;k<*nboun;++k){xbounact[k]=xbounold[k];}
  xforcact=NNEW(double,*nforc);
  xloadact=NNEW(double,2**nload);
  xbodyact=NNEW(double,7**nbody);
  /* copying the rotation axis and/or acceleration vector */
  for(k=0;k<7**nbody;k++){xbodyact[k]=xbody[k];}
  
  /* assigning the body forces to the elements */ 

  if(*nbody>0){
      ifreebody=*ne+1;
      ipobody=NNEW(int,2*ifreebody);
      for(k=1;k<=*nbody;k++){
	  FORTRAN(bodyforce,(cbody,ibody,ipobody,nbody,set,istartset,
			     iendset,ialset,&inewton,nset,&ifreebody,&k));
	  RENEW(ipobody,int,2*(*ne+ifreebody));
      }
      RENEW(ipobody,int,2*(ifreebody-1));
      if(inewton==1){cgr=NNEW(double,4**ne);}
  }

  /* for mechanical calculations: updating boundary conditions
     calculated in a previous thermal step */

  if(*ithermal<2) FORTRAN(gasmechbc,(vold,nload,sideload,
				     nelemload,xload));

  /* for thermal calculations: forced convection and cavity
     radiation*/

  if(*ithermal>1){
      itg=NNEW(int,*nload+3**nflow);
      ieg=NNEW(int,*nflow);
      iptri=NNEW(int,*nload);
      kontri=NNEW(int,18**nload);
      nloadtr=NNEW(int,*nload);
      nacteq=NNEW(int,4**nk);
      nactdog=NNEW(int,4**nk);
      voldgas=NNEW(double,4**nk);
      ipogn=NNEW(int,*nload+2**nflow);
      ign=NNEW(int,4**nk);
      FORTRAN(envtemp,(itg,ieg,&ntg,&ntr,sideload,nelemload,
		       ipkon,kon,lakon,ielmat,ne,nload,iptri,
                       kontri,&ntri,nloadtr,nflow,ndirboun,nactdog,
                       nodeboun,xbounact,nacteq,nboun,ielprop,prop,&nteq,
                       voldgas,&network,physcon,shcon,ntmat_,co,ipogn,ign,
                       vold));
      free(ign);free(ipogn);
      if((*mcs>0)&&(ntr>0)){
        inocs=NNEW(int,*nk);
        radcyc(nk,kon,ipkon,lakon,ne,cs,mcs,nkon,ialset,istartset,
               iendset,&kontri,&ntri,&co,&vold,&ntrit,inocs);
      }
      else{ntrit=ntri;}

      RENEW(itg,int,ntg);
      RENEW(iptri,int,ntri);
      RENEW(kontri,int,3*ntrit);
      RENEW(nloadtr,int,ntr);

      area=NNEW(double,ntrit);
      pmid=NNEW(double,3*ntrit);
      e1=NNEW(double,3*ntrit);
      e2=NNEW(double,3*ntrit);
      e3=NNEW(double,4*ntrit);
      dist=NNEW(double,ntrit);
      idist=NNEW(int,ntrit);

      fij=NNEW(double,ntr*ntr);
      tarea=NNEW(double,ntr);
      tenv=NNEW(double,ntr);
      fenv=NNEW(double,ntr);
      erad=NNEW(double,ntr);
      if(nteq>ntr){
	  ntm=nteq;}
      else{
	  ntm=ntr;}
      ac=NNEW(double,ntm*ntm);
      bc=NNEW(double,ntm);
      ipiv=NNEW(int,ntm);
  }

  /* contact conditions */

  inicont(&ncont,ntie,tieset,nset,set,istartset,iendset,ialset,&itietri,
	  lakon,ipkon,kon,&koncont,&ncone);

  if(ncont!=0){
      RENEW(ipkon,int,*ne+ncone);
      RENEW(lakon,char,8*(*ne+ncone));
      RENEW(kon,int,*nkon+9*ncone);
      if(*norien>0){
	  RENEW(ielorien,int,*ne+ncone);
	  for(k=*ne;k<*ne+ncone;k++) ielorien[k]=0;
      }
      RENEW(ielmat,int,*ne+ncone);
      for(k=*ne;k<*ne+ncone;k++) ielmat[k]=1;
      cg=NNEW(double,3*ncont);
      straight=NNEW(double,16*ncont);
  }

  if((*ithermal==1)||(*ithermal==3)){
    t1ini=NNEW(double,*nk);
    t1act=NNEW(double,*nk);
    for(k=0;k<*nk;++k){t1act[k]=t1old[k];}
  }

  /* allocating a field for the instantaneous amplitude */

  ampli=NNEW(double,*nam);

  /* allocating fields for nonlinear dynamics */

  fini=NNEW(double,neq[1]);
  if(*nmethod==4){
    mass[0]=1;
    mass[1]=1;
    aux2=NNEW(double,neq[1]);
    fextini=NNEW(double,neq[1]);
    veini=NNEW(double,4**nk);
    accini=NNEW(double,4**nk);
    adb=NNEW(double,neq[1]);
    aub=NNEW(double,nzs[1]);
  }

  if(*nstate_!=0){
    xstateini=NNEW(double,*nstate_**mint_**ne);
    for(k=0;k<*nstate_**mint_**ne;++k){
      xstateini[k]=xstate[k];
    }
  }
  eei=NNEW(double,6**mint_**ne);
  stiini=NNEW(double,6**mint_**ne);
  if(*nener==1)
      enerini=NNEW(double,*mint_**ne);

  qa[0]=qaold[0];
  qa[1]=qaold[1];

  /* normalizing the time */

  FORTRAN(checktime,(itpamp,namta,tinc,ttime,amta,tmin,&inext,&itp));
  dtheta=(*tinc)/(*tper);
  dthetaref=dtheta;
  if((dtheta<=1.e-6)&&(*iexpl==0)){
    printf("\n *ERROR in nonlingeo\n");
    printf(" increment size smaller than one millionth of step size\n");
    printf(" increase increment size\n\n");
    }
  *tmin=*tmin/(*tper);
  *tmax=*tmax/(*tper);
  theta=0.;

  /* calculating an initial flux norm */

  if(*ithermal!=2){
      if(qau>1.e-10){qam[0]=qau;}
      else if(qa0>1.e-10){qam[0]=qa0;}
      else if(qa[0]>1.e-10){qam[0]=qa[0];}
      else {qam[0]=1.e-2;}
  }
  if(*ithermal>1){
      if(qau>1.e-10){qam[1]=qau;}
      else if(qa0>1.e-10){qam[1]=qa0;}
      else if(qa[1]>1.e-10){qam[1]=qa[1];}
      else {qam[1]=1.e-2;}
  }

  /* storing the element and topology information before introducing 
     contact elements */

  ne0=*ne;nkon0=*nkon;

  /* calculating the initial acceleration at the start of the step
     for dynamic calculations */

  #include "initialaccel.c"

  if(*iexpl!=0) icmd=3;

  /**************************************************************/
  /* starting the loop over the increments                      */
  /**************************************************************/

  newstep=1;

  /* storing the element and topology information before introducing 
     contact elements */

  /*ne0=*ne;nkon0=*nkon;*/

  while(dtheta>1.e-6){

    if(icutb==0){
    
      /* previous increment converged: update the initial values */

      iinc++;
      jprint++;

      if(*ithermal<2){
	for(k=1;k<4**nk;k=k+4){vini[k]=vold[k];vini[k+1]=vold[k+1];vini[k+2]=vold[k+2];}
      }else if(*ithermal==2){
	for(k=0;k<4**nk;k=k+4){vini[k]=vold[k];vini[k+1]=vold[k+1];vini[k+2]=vold[k+2];}
      }else{for(k=0;k<4**nk;++k){vini[k]=vold[k];}}
      for(k=0;k<*nboun;++k){xbounini[k]=xbounact[k];}
      if((*ithermal==1)||(*ithermal==3)){
	for(k=0;k<*nk;++k){t1ini[k]=t1act[k];}
      }
	for(k=0;k<neq[1];++k){
	  fini[k]=f[k];
	}
      if(*nmethod==4){
	for(k=0;k<4**nk;++k){
	  veini[k]=veold[k];
	  accini[k]=accold[k];
	}
	for(k=0;k<neq[1];++k){
	    /*  fini[k]=f[k];*/
	  fextini[k]=fext[k];
	}
      }
      if(*ithermal!=2){
	  for(k=0;k<6**mint_*ne0;++k){
	      stiini[k]=sti[k];
	  }
      }
      if(*nener==1)
	  for(k=0;k<*mint_*ne0;++k){enerini[k]=ener[k];}
      if(*nstate_!=0){
	for(k=0;k<*nstate_**mint_*ne0;++k){
	  xstateini[k]=xstate[k];
	}
      }	
    }

    /* check for max. # of increments */

    if(iinc>*jmax){
      printf(" *ERROR: max. # of increments reached\n\n");
      FORTRAN(stop,());
    }
    printf(" increment %d attempt %d \n",iinc,icutb+1);
    printf(" increment size= %e\n",dtheta**tper);
    printf(" sum of previous increments=%e\n\n",theta**tper);

    printf(" iteration 1\n\n");

    qamold[0]=qam[0];
    qamold[1]=qam[1];

    /* determining the actual loads at the end of the new increment*/

    reltime=theta+dtheta;
    time=reltime**tper;
    dtime=dtheta**tper;

    FORTRAN(tempload,(xforcold,xforc,xforcact,iamforc,nforc,xloadold,xload,
	      xloadact,iamload,nload,ibody,xbody,nbody,xbodyold,xbodyact,
	      t1old,t1,t1act,iamt1,nk,amta,
	      namta,nam,ampli,&time,&reltime,ttime,&dtime,ithermal,nmethod,
              xbounold,xboun,xbounact,iamboun,nboun,
              nodeboun,ndirboun,nodeforc,ndirforc,istep,&iinc,
              co,vold,itg,&ntg));

    cam[0]=0.;cam[1]=0.;
    if(*ithermal>1){radflowload(itg,ieg,&ntg,&ntr,&ntm,
       ac,bc,nload,sideload,nelemload,xloadact,lakon,ipiv,ntmat_,vold,
       shcon,nshcon,ipkon,kon,co,pmid,e1,e2,e3,iptri,
       kontri,&ntri,nloadtr,tarea,tenv,physcon,erad,fij,
       dist,idist,area,nflow,ikboun,xbounact,nboun,ithermal,&iinc,&iit,
       cs,mcs,inocs,&ntrit,nk,fenv,istep,&dtime,ttime,&time,ilboun,
       ikforc,ilforc,xforcact,nforc,cam,ielmat,&nteq,prop,ielprop,
       nactdog,nacteq,nodeboun,ndirboun,voldgas,&network,
       rhcon,nrhcon,ipobody,ibody,xbodyact,nbody,iviewfile,jobnamef,
       ctrl);
    }

    if(ncont!=0){
	*ne=ne0;*nkon=nkon0;
	contact(&ncont,ntie,tieset,nset,set,istartset,iendset,
             ialset,itietri,lakon,ipkon,kon,koncont,ne,cg,straight,nkon,
             co,vold,ielmat,cs);
	icascade=1;
    }

    /*  updating the nonlinear mpc's (also affects the boundary
	conditions through the nonhomogeneous part of the mpc's) */

    if(icascade==2){
	*nmpc=nmpcref;memmpc_=memmpcref_;mpcfree=mpcfreeref;
	RENEW(nodempc,int,3*memmpcref_);
	for(k=0;k<3*memmpcref_;k++){nodempc[k]=nodempcref[k];}
	RENEW(coefmpc,double,memmpcref_);
	for(k=0;k<memmpcref_;k++){coefmpc[k]=coefmpcref[k];}
    }
    FORTRAN(nonlinmpc,(co,vold,ipompc,nodempc,coefmpc,labmpc,
		       nmpc,ikboun,ilboun,nboun,xbounact,aux,iaux,
		       &maxlenmpc,ikmpc,ilmpc,&icascade,
		       kon,ipkon,lakon,ne,&reltime,&newstep,xboun,fmpc,
                       &iit,&idiscon,&ncont));
    if(icascade==2){
	nmpcref=*nmpc;memmpcref_=memmpc_;mpcfreeref=mpcfree;
	RENEW(nodempcref,int,3*memmpc_);
	for(k=0;k<3*memmpc_;k++){nodempcref[k]=nodempc[k];}
	RENEW(coefmpcref,double,memmpc_);
	for(k=0;k<memmpc_;k++){coefmpcref[k]=coefmpc[k];}
    }

    if(icascade>0) remastruct(ipompc,&coefmpc,&nodempc,nmpc,
	  &mpcfree,nodeboun,ndirboun,nboun,ikmpc,ilmpc,ikboun,ilboun,
	  labmpc,nk,&memmpc_,&icascade,&maxlenmpc,
	  kon,ipkon,lakon,ne,nnn,nactdof,icol,jq,&irow,isolver,
	  neq,nzs,nmethod,&f,&fext,&b,&aux2,&fini,&fextini,
	  &adb,&aub,ithermal,iperturb);

    /* check whether the forced displacements changed; if so, and
       if the procedure is static, the first iteration has to be
       purely linear elastic, in order to get an equilibrium
       displacement field; otherwise huge (maybe nonelastic)
       stresses may occur, jeopardizing convergence */

    ilin=0;

    /* only for iinc=1 a linearized calculation is performed, since
       for iinc>1 a reasonable displacement field is predicted by using the
       initial velocity field at the end of the last increment */

    if((iinc==1)&&(*ithermal<2)){
	dev=0.;
	for(k=0;k<*nboun;++k){
	    err=fabs(xbounact[k]-xbounini[k]);
	    if(err>dev){dev=err;}
	}
	if(dev>1.e-5) ilin=1;
        /*	if(dev>1.e-10) ilin=1;*/
    }

    /* prediction of the kinematic vectors  */

    v=NNEW(double,4**nk);

    prediction(uam,nmethod,&bet,&gam,&dtime,ithermal,nk,veold,accold,v,
               &iinc,&idiscon,vold,nactdof);

    fn=NNEW(double,4**nk);
    stx=NNEW(double,6**mint_*ne0);
    if(*ithermal>1) qfx=NNEW(double,3**mint_*ne0);

    /* determining the internal forces at the start of the increment

       for a static calculation with increased forced displacements
       the linear strains are calculated corresponding to

       the displacements at the end of the previous increment, extrapolated
       if appropriate (for nondispersive media) +
       the forced displacements at the end of the present increment +
       the temperatures at the end of the present increment (this sum is
       v) -
       the displacements at the end of the previous increment (this is vold)

       these linear strains are converted in stresses by multiplication
       with the tangent element stiffness matrix and converted into nodal
       forces. 

       this boils down to the fact that the effect of forced displacements
       should be handled in a purely linear way at the
       start of a new increment, in order to speed up the convergence and
       (for dissipative media) guarantee smooth loading within the increment.

       for all other cases the nodal force calculation is based on
       the true stresses derived from the appropriate strain tensor taking
       into account the extrapolated displacements at the end of the 
       previous increment + the forced displacements and the temperatures
       at the end of the present increment */

    iout=-1;
    iperturb_sav=*iperturb;

    /* first iteration in first increment: elastic tangent */

    ielas=1;

    if((*nmethod!=4)&&(ilin==1)){
      *iperturb=-1;

      for(k=0;k<neq[1];++k){b[k]=f[k];}
      FORTRAN(results,(co,nk,kon,ipkon,lakon,ne,v,stn,inum,stx,
	       elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,ielmat,
	       ielorien,norien,orab,ntmat_,t1ini,t1act,ithermal,
	       prestr,iprestr,filab,eme,een,iperturb,
	       f,fn,nactdof,&iout,qa,vold,b,nodeboun,
	       ndirboun,xbounact,nboun,ipompc,
	       nodempc,coefmpc,labmpc,nmpc,nmethod,cam,&neq[1],veold,accold,
	       &bet,&gam,&dtime,&time,ttime,plicon,nplicon,plkcon,nplkcon,
	       xstateini,xstiff,xstate,npmat_,epn,matname,mint_,&ielas,
               &icmd, ncmat_,nstate_,stiini,vini,ikboun,ilboun,ener,enern,
               sti,xstaten,eei,enerini,cocon,ncocon,set,nset,istartset,
               iendset,ialset,nprint,prlab,prset,qfx,qfn,trab,inotr,ntrans,
               fmpc,nelemload,nload));
      *iperturb=0;
      
      /* check whether any displacements or temperatures are changed
	 in the new increment */
      
      for(k=0;k<neq[1];++k){f[k]=f[k]+b[k];}

    }
    else{

      FORTRAN(results,(co,nk,kon,ipkon,lakon,ne,v,stn,inum,stx,
	       elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,ielmat,
	       ielorien,norien,orab,ntmat_,t0,t1act,ithermal,
	       prestr,iprestr,filab,eme,een,iperturb,
	       f,fn,nactdof,&iout,qa,vold,b,nodeboun,
	       ndirboun,xbounact,nboun,ipompc,
	       nodempc,coefmpc,labmpc,nmpc,nmethod,cam,&neq[1],veold,accold,
	       &bet,&gam,&dtime,&time,ttime,plicon,nplicon,plkcon,nplkcon,
	       xstateini,xstiff,xstate,npmat_,epn,matname,mint_,&ielas,
               &icmd,ncmat_,nstate_,stiini,vini,ikboun,ilboun,ener,enern,
               sti,xstaten,eei,enerini,cocon,ncocon,set,nset,istartset,
               iendset,ialset,nprint,prlab,prset,qfx,qfn,trab,inotr,ntrans,
               fmpc,nelemload,nload));

      if(*ithermal<2){
	for(k=1;k<4**nk;k=k+4){vold[k]=v[k];vold[k+1]=v[k+1];vold[k+2]=v[k+2];}
      }else if(*ithermal==2){
	for(k=0;k<4**nk;k=k+4){vold[k]=v[k];vold[k+1]=v[k+1];vold[k+2]=v[k+2];}
      }else{for(k=0;k<4**nk;++k){vold[k]=v[k];}}

      if(*ithermal!=2){
	  for(k=0;k<6**mint_*ne0;++k){
	      sti[k]=stx[k];
	  }
      }

    }

    ielas=0;
    iout=0;

    free(fn);free(stx);if(*ithermal>1)free(qfx);free(v);

    /***************************************************************/
    /* iteration counter and start of the loop over the iterations */
    /***************************************************************/

    iit=1;
    icntrl=0;

    while(icntrl==0){

    /*  updating the nonlinear mpc's (also affects the boundary
	conditions through the nonhomogeneous part of the mpc's) */

      if(iit!=1){

	  printf(" iteration %d\n\n",iit);

          FORTRAN(tempload,(xforcold,xforc,xforcact,iamforc,nforc,
              xloadold,xload,
	      xloadact,iamload,nload,ibody,xbody,nbody,xbodyold,xbodyact,
	      t1old,t1,t1act,iamt1,nk,amta,
	      namta,nam,ampli,&time,&reltime,ttime,&dtime,ithermal,nmethod,
              xbounold,xboun,xbounact,iamboun,nboun,
              nodeboun,ndirboun,nodeforc,ndirforc,istep,&iinc,
              co,vold,itg,&ntg));

	  cam[0]=0.;cam[1]=0.;
	  if(*ithermal>1){radflowload(itg,ieg,&ntg,&ntr,&ntm,
	     ac,bc,nload,sideload,nelemload,xloadact,lakon,ipiv,
             ntmat_,vold,shcon,nshcon,ipkon,kon,co,pmid,e1,e2,e3,
             iptri,kontri,&ntri,nloadtr,tarea,tenv,physcon,erad,fij,
	     dist,idist,area,nflow,ikboun,xbounact,nboun,ithermal,&iinc,&iit,
             cs,mcs,inocs,&ntrit,nk,fenv,istep,&dtime,ttime,&time,ilboun,
	     ikforc,ilforc,xforcact,nforc,cam,ielmat,&nteq,prop,ielprop,
	     nactdog,nacteq,nodeboun,ndirboun,voldgas,&network,
             rhcon,nrhcon,ipobody,ibody,xbodyact,nbody,iviewfile,jobnamef,
             ctrl);
	  }

	  if(ncont!=0){
	      *ne=ne0;*nkon=nkon0;
	      contact(&ncont,ntie,tieset,nset,set,istartset,iendset,
		      ialset,itietri,lakon,ipkon,kon,koncont,ne,cg,
                      straight,nkon,co,vold,ielmat,cs);
	      icascade=1;
	  }
	  
	  if(*ithermal==3){
	      for(k=0;k<*nk;++k){t1act[k]=vold[4*k];}
	  }

	  if(icascade==2){
	      *nmpc=nmpcref;memmpc_=memmpcref_;mpcfree=mpcfreeref;
	      RENEW(nodempc,int,3*memmpcref_);
	      for(k=0;k<3*memmpcref_;k++){nodempc[k]=nodempcref[k];}
	      RENEW(coefmpc,double,memmpcref_);
	      for(k=0;k<memmpcref_;k++){coefmpc[k]=coefmpcref[k];}
	  }
	  FORTRAN(nonlinmpc,(co,vold,ipompc,nodempc,coefmpc,labmpc,
		nmpc,ikboun,ilboun,nboun,xbounact,aux,iaux,
	        &maxlenmpc,ikmpc,ilmpc,&icascade,
	        kon,ipkon,lakon,ne,&reltime,&newstep,xboun,fmpc,&iit,
                &idiscon,&ncont));
	  if(icascade==2){
	      nmpcref=*nmpc;memmpcref_=memmpc_;mpcfreeref=mpcfree;
	      RENEW(nodempcref,int,3*memmpc_);
	      for(k=0;k<3*memmpc_;k++){nodempcref[k]=nodempc[k];}
	      RENEW(coefmpcref,double,memmpc_);
	      for(k=0;k<memmpc_;k++){coefmpcref[k]=coefmpc[k];}
	  }

	  if(icascade>0){
	      remastruct(ipompc,&coefmpc,&nodempc,nmpc,
		&mpcfree,nodeboun,ndirboun,nboun,ikmpc,ilmpc,ikboun,ilboun,
		labmpc,nk,&memmpc_,&icascade,&maxlenmpc,
		kon,ipkon,lakon,ne,nnn,nactdof,icol,jq,&irow,isolver,
		neq,nzs,nmethod,&f,&fext,&b,&aux2,&fini,&fextini,
		&adb,&aub,ithermal,iperturb);
	      
	      v=NNEW(double,4**nk);
	      stx=NNEW(double,6**mint_*ne0);
	      if(*ithermal>1) qfx=NNEW(double,3**mint_*ne0);
	      fn=NNEW(double,4**nk);
      
	      for(k=0;k<4**nk;++k){
		  v[k]=vold[k];
	      }
	      iout=-1;
	      
	      FORTRAN(results,(co,nk,kon,ipkon,lakon,ne,v,stn,inum,stx,
	        elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,ielmat,
		ielorien,norien,orab,ntmat_,t0,t1act,ithermal,
		prestr,iprestr,filab,eme,een,iperturb,
		f,fn,nactdof,&iout,qa,vold,b,nodeboun,
		ndirboun,xbounact,nboun,ipompc,
		nodempc,coefmpc,labmpc,nmpc,nmethod,cam,&neq[1],veold,accold,
		&bet,&gam,&dtime,&time,ttime,plicon,nplicon,plkcon,nplkcon,
		xstateini,xstiff,xstate,npmat_,epn,matname,mint_,&ielas,&icmd,
		ncmat_,nstate_,stiini,vini,ikboun,ilboun,ener,enern,sti,
		xstaten,eei,enerini,cocon,ncocon,set,nset,istartset,iendset,
	        ialset,nprint,prlab,prset,qfx,qfn,trab,inotr,ntrans,fmpc,
		nelemload,nload));

	      /*for(k=0;k<neq[1];++k){printf("f=%d,%f\n",k,f[k]);}*/
	      
	      free(v);free(stx);free(fn);if(*ithermal>1)free(qfx);
	      iout=0;
	      
	  }else{

	      /*for(k=0;k<neq[1];++k){printf("f=%d,%f\n",k,f[k]);}*/
	  }
      }
      
      if(*iexpl==0){

	/* calculating the local stiffness matrix and external loading */

	ad=NNEW(double,neq[1]);
	au=NNEW(double,nzs[1]);

	nmethodact=1;

	FORTRAN(mafillsm,(co,nk,kon,ipkon,lakon,ne,nodeboun,ndirboun,xbounact,nboun,
		  ipompc,nodempc,coefmpc,nmpc,nodeforc,ndirforc,xforcact,
		  nforc,nelemload,sideload,xloadact,nload,xbodyact,ipobody,
		  nbody,cgr,ad,au,fext,nactdof,icol,jq,irow,neq,nzl,
		  &nmethodact,ikmpc,ilmpc,ikboun,ilboun,
		  elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,
		  ielmat,ielorien,norien,orab,ntmat_,
		  t0,t1act,ithermal,prestr,iprestr,vold,iperturb,sti,
		  nzs,stx,adb,aub,iexpl,plicon,nplicon,plkcon,nplkcon,
		  xstiff,npmat_,&dtime,matname,mint_,
                  ncmat_,mass,&stiffness,&buckling,&rhsi,&intscheme,
                  physcon,shcon,nshcon,cocon,ncocon,ttime,&time,istep,&iinc,
                  &coriolis,ibody));

/*	if(ncont!=0){
	    RENEW(au,double,2*nzs[1]);
	    symmetryflag=2;
	    inputformat=1;

	    FORTRAN(mafillsmas,(co,nk,kon,ipkon,lakon,ne,nodeboun,ndirboun,xbounact,nboun,
		  ipompc,nodempc,coefmpc,nmpc,nodeforc,ndirforc,xforcact,
		  nforc,nelemload,sideload,xloadact,nload,xbodyact,ipobody,
		  nbody,cgr,ad,au,fext,nactdof,icol,jq,irow,neq,nzl,
		  &nmethodact,ikmpc,ilmpc,ikboun,ilboun,
		  elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,
		  ielmat,ielorien,norien,orab,ntmat_,
		  t0,t1act,ithermal,prestr,iprestr,vold,iperturb,sti,
		  nzs,stx,adb,aub,iexpl,plicon,nplicon,plkcon,nplkcon,
		  xstiff,npmat_,&dtime,matname,mint_,
                  ncmat_,mass,&stiffness,&buckling,&rhsi,&intscheme,
                  physcon,shcon,nshcon,cocon,ncocon,ttime,&time,istep,&iinc,
                  &coriolis,ibody));
	    symmetryflag=0;
	    inputformat=0;
	    }*/
	    

	*iperturb=iperturb_sav;

      }else{

	/* calculating the external loading 

	   This is only done once per increment. In reality, the
           external loading is a function of vold (specifically,
           the body forces and surface loading). This effect is
           neglected, since the increment size in dynamic explicit
           calculations is usually small */

	/*if(iit==1){ */
	  FORTRAN(rhs,(co,nk,kon,ipkon,lakon,ne,
		  ipompc,nodempc,coefmpc,nmpc,nodeforc,ndirforc,xforcact,
		  nforc,nelemload,sideload,xloadact,nload,xbodyact,ipobody,
		  nbody,cgr,fext,nactdof,&neq[1],
		  &nmethodact,ikmpc,ilmpc,
		  elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,
		  ielmat,ielorien,norien,orab,ntmat_,
		  t0,t1act,ithermal,iprestr,vold,iperturb,
		  iexpl,plicon,nplicon,plkcon,nplkcon,
		  npmat_,ttime,&time,istep,&iinc,&dtime,physcon,ibody));
	  /*}*/
      }

	/* residual for a static analysis (only for first iteration
           in a new increment); in all other cases the residual is
           determined after calling results.f */

      /*   if((iit==1)||(*ithermal>1)||(icascade>0)){*/
      
      /*  for(k=0;k<neq[1];++k){printf("f=%d,%f\n",k,f[k]);}
      for(k=0;k<neq[1];++k){printf("fext=%d,%f\n",k,fext[k]);}
      for(k=0;k<neq[1];++k){printf("ad=%d,%f\n",k,ad[k]);}
      for(k=0;k<nzs[1];++k){printf("au=%d,%f\n",k,au[k]);}*/

      /* calculating the residual */

      calcresidual(nmethod,neq,b,fext,f,iexpl,nactdof,aux1,aux2,vold,
	 vini,&dtime,accold,nk,adb,aub,icol,irow,nzl,alpha,fextini,fini);

      /*     }*/

      newstep=0;

      if((nmethodact==0)||(*nmethod==0)){

	/* error occurred in mafill: storing the geometry in frd format */

	*nmethod=0;
	++*kode;
	inum=NNEW(int,*nk);for(k=0;k<*nk;k++) inum[k]=1;
	ipneigh=NNEW(int,*nk);neigh=NNEW(int,40**ne);
	FORTRAN(out,(co,nk,kon,ipkon,lakon,ne,v,stn,inum,nmethod,kode,filab,
          een,t1,fn,ttime,epn,ielmat,matname,enern,xstaten,nstate_,istep,&iinc,
	  iperturb,ener,mint_,output,ithermal,qfn,&mode,&noddiam,
          trab,inotr,ntrans,orab,ielorien,norien,description,
                     ipneigh,neigh,sti));free(ipneigh);free(neigh);
	free(inum);FORTRAN(stop,());

      }

      /* implicit step (static or dynamic */

      if(*iexpl==0){
	  if(*nmethod==4){
	      
	      /* mechanical part */
	      
	      scal1=bet*dtime*dtime*(1.+*alpha);
	      for(k=0;k<neq[0];++k){
		  ad[k]=adb[k]+scal1*ad[k];
	      }
	      for(k=0;k<nzs[0];++k){
		  au[k]=aub[k]+scal1*au[k];
	      }

	      /* thermal part */
	      
	      for(k=neq[0];k<neq[1];++k){
		  ad[k]=adb[k]/dtime+ad[k];
	      }
	      for(k=nzs[0];k<nzs[1];++k){
		  au[k]=aub[k]/dtime+au[k];
	      }
	  }
	  
	  if(*isolver==0){
#ifdef SPOOLES
	      spooles(ad,au,adb,aub,&sigma,b,icol,irow,&neq[1],&nzs[1],
                      &symmetryflag,&inputformat);
#else
	      printf(" *ERROR in nonlingeo: the SPOOLES library is not linked\n\n");
	      FORTRAN(stop,());
#endif
	  }
          else if((*isolver==2)||(*isolver==3)){
	      preiter(ad,&au,b,&icol,&irow,&neq[1],&nzs[1],isolver,iperturb);
	  }
          else if(*isolver==4){
#ifdef SGI
	      token=1;
	      sgi_main(ad,au,adb,aub,&sigma,b,icol,irow,&neq[1],&nzs[1],token);
#else
	      printf(" *ERROR in nonlingeo: the SGI library is not linked\n\n");
	      FORTRAN(stop,());
#endif
          }
          else if(*isolver==5){
#ifdef TAUCS
	      tau(ad,&au,adb,aub,&sigma,b,icol,&irow,&neq[1],&nzs[1]);
#else
	      printf(" *ERROR in nonlingeo: the TAUCS library is not linked\n\n");
	      FORTRAN(stop,());
#endif
          }
	  
	  free(ad);free(au); 
      }
      
      /* explicit dynamic step */
      
      else{
	  for(k=0;k<neq[0];++k){
	      b[k]=b[k]/adb[k];
	  }
	  for(k=neq[0];k<neq[1];++k){
	      b[k]=b[k]*dtime/adb[k];
	  }
      }
      
	  /* calculating the displacements, stresses and forces */
      
      v=NNEW(double,4**nk);
      stx=NNEW(double,6**mint_*ne0);
      if(*ithermal>1) qfx=NNEW(double,3**mint_*ne0);
      fn=NNEW(double,4**nk);
      
      FORTRAN(results,(co,nk,kon,ipkon,lakon,ne,v,stn,inum,stx,
	 elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,ielmat,
	 ielorien,norien,orab,ntmat_,t0,t1act,ithermal,
	 prestr,iprestr,filab,eme,een,iperturb,
	 f,fn,nactdof,&iout,qa,vold,b,nodeboun,
	 ndirboun,xbounact,nboun,ipompc,
	 nodempc,coefmpc,labmpc,nmpc,nmethod,cam,&neq[1],veold,accold,
	 &bet,&gam,&dtime,&time,ttime,plicon,nplicon,plkcon,nplkcon,
	 xstateini,xstiff,xstate,npmat_,epn,matname,mint_,&ielas,
	 &icmd,ncmat_,nstate_,stiini,vini,ikboun,ilboun,ener,enern,
	 sti,xstaten,eei,enerini,cocon,ncocon,set,nset,istartset,
	 iendset,ialset,nprint,prlab,prset,qfx,qfn,trab,inotr,ntrans,
	 fmpc,nelemload,nload));

      if(*ithermal!=2){
	  if(cam[0]>uam[0]){uam[0]=cam[0];}      
	  if(qau<1.e-10){
	      if(qa[0]>ea*qam[0]){qam[0]=(qamold[0]*jnz+qa[0])/(jnz+1);}
	      else {qam[0]=qamold[0];}
	  }
      }
      if(*ithermal>1){
	  if(cam[1]>uam[1]){uam[1]=cam[1];}      
	  if(qau<1.e-10){
	      if(qa[1]>ea*qam[1]){qam[1]=(qamold[1]*jnz+qa[1])/(jnz+1);}
	      else {qam[1]=qamold[1];}
	  }
      }

      if(*ithermal<2){
	for(k=1;k<4**nk;k=k+4){vold[k]=v[k];vold[k+1]=v[k+1];vold[k+2]=v[k+2];}
      }else if(*ithermal==2){
	for(k=0;k<4**nk;k=k+4){vold[k]=v[k];vold[k+1]=v[k+1];vold[k+2]=v[k+2];}
      }else{for(k=0;k<4**nk;++k){vold[k]=v[k];}}
      if(*ithermal!=2){
	  for(k=0;k<6**mint_*ne0;++k){
	      sti[k]=stx[k];
	  }
      }
      
      free(v);free(stx);free(fn);if(*ithermal>1)free(qfx);
      
      /* calculating the residual */
      
      calcresidual(nmethod,neq,b,fext,f,iexpl,nactdof,aux1,aux2,vold,
		   vini,&dtime,accold,nk,adb,aub,icol,irow,nzl,alpha,fextini,fini);
      
      /* calculating the maximum residual */

      for(k=0;k<2;++k){
	  ram2[k]=ram1[k];
	  ram1[k]=ram[k];
	  ram[k]=0.;
      }
      for(k=0;k<neq[0];++k){
	  err=fabs(b[k]);
	  if(err>ram[0]){ram[0]=err;}
      }
      for(k=neq[0];k<neq[1];++k){
	  err=fabs(b[k]);
	  if(err>ram[1]){ram[1]=err;}
      }
      
      /* next line is inserted to cope with stress-less
	 temperature calculations */
      
      if(*ithermal!=2){
	  if(ram[0]<1.e-6) ram[0]=0.;      
	  printf(" average force= %f\n",qa[0]);
	  printf(" time avg. forc= %f\n",qam[0]);
	  printf(" largest residual force= %f\n",ram[0]);
	  printf(" largest increment of disp.= %e\n",uam[0]);
	  printf(" largest correction to disp= %e\n\n",cam[0]);
      }
      if(*ithermal>1){
	  if(ram[1]<1.e-6) ram[1]=0.;      
	  printf(" average flux= %f\n",qa[1]);
	  printf(" time avg. flux= %f\n",qam[1]);
	  printf(" largest residual flux= %f\n",ram[1]);
	  printf(" largest increment of temp.= %e\n",uam[1]);
	  printf(" largest correction to temp= %e\n\n",cam[1]);
      }
      
      checkconvergence(co,nk,kon,ipkon,lakon,ne,v,stn,nmethod, 
	  kode,filab,een,t1act,&time,epn,ielmat,matname,enern, 
	  xstaten,nstate_,istep,&iinc,iperturb,ener,mint_,output,
          ithermal,qfn,&mode,&noddiam,trab,inotr,ntrans,orab,
	  ielorien,norien,description,sti,&icutb,&iit,&dtime,qa,
	  vold,qam,ram1,ram2,ram,cam,uam,&ntg,ttime,&icntrl,
	  &theta,&dtheta,veold,vini,idrct,tper,&istab,tmax, 
	  nactdof,b,tmin,ctrl,amta,namta,itpamp,&inext,&dthetaref,
          &itp,&jprint,jout);
    }

    /*********************************************************/
    /*   end of the iteration loop                          */
    /*********************************************************/

    /* icutb=0 means that the iterations in the increment converged,
       icutb!=0 indicates that the increment has to be reiterated with
                another increment size (dtheta) */

    if(((qa[0]>ea*qam[0])||(qa[1]>ea*qam[1]))&&(icutb==0)){jnz++;}
    iit=0;

    if(icutb!=0){
      if(*ithermal<2){
	for(k=1;k<4**nk;k=k+4){vold[k]=vini[k];vold[k+1]=vini[k+1];vold[k+2]=vini[k+2];}
      }else if(*ithermal==2){
	for(k=0;k<4**nk;k=k+4){vold[k]=vini[k];vold[k+1]=vini[k+1];vold[k+2]=vini[k+2];}
      }else{for(k=0;k<4**nk;++k){vold[k]=vini[k];}}
      for(k=0;k<*nboun;++k){xbounact[k]=xbounini[k];}
      if((*ithermal==1)||(*ithermal==3)){
	for(k=0;k<*nk;++k){t1act[k]=t1ini[k];}
      }
	for(k=0;k<neq[1];++k){
	  f[k]=fini[k];
	}
      if(*nmethod==4){
	for(k=0;k<4**nk;++k){
	  veold[k]=veini[k];
	  accold[k]=accini[k];
	}
	for(k=0;k<neq[1];++k){
	    /*  f[k]=fini[k];*/
	  fext[k]=fextini[k];
	}
      }
      if(*ithermal!=2){
	  for(k=0;k<6**mint_*ne0;++k){
	      sti[k]=stiini[k];
	  }
      }
      if(*nener==1)
	  for(k=0;k<*mint_*ne0;++k){ener[k]=enerini[k];}
      if(*nstate_!=0){
	for(k=0;k<*nstate_**mint_*ne0;++k){
	  xstate[k]=xstateini[k];
	}	
      }

      qam[0]=qamold[0];
      qam[1]=qamold[1];
    }
    else{
      /*      if(*ithermal==1){
	for(k=0;k<*nk;++k){t1old[k]=t1act[k];}
      }*/
    }
    
    if((*jout==jprint)&&(icutb==0)){

      jprint=0;

      /* calculating the displacements and the stresses and storing */
      /* the results in frd format  */
	
      v=NNEW(double,4**nk);
      fn=NNEW(double,4**nk);
      stn=NNEW(double,6**nk);
      if(*ithermal>1) qfn=NNEW(double,3**nk);
      inum=NNEW(int,*nk);
      stx=NNEW(double,6**mint_*ne0);
      if(*ithermal>1) qfx=NNEW(double,3**mint_*ne0);
      
      if(strcmp1(&filab[18],"E   ")==0) een=NNEW(double,6**nk);
      if(strcmp1(&filab[30],"PE  ")==0) epn=NNEW(double,*nk);
      if(strcmp1(&filab[36],"ENER")==0) enern=NNEW(double,*nk);
      if(strcmp1(&filab[42],"SDV ")==0) xstaten=NNEW(double,*nstate_**nk);
      
      for(k=0;k<4**nk;++k){
	v[k]=vold[k];
      }
      iout=2;
      icmd=3;
      
      FORTRAN(results,(co,nk,kon,ipkon,lakon,ne,v,stn,inum,stx,
	      elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,ielmat,
	      ielorien,norien,orab,ntmat_,t0,t1act,ithermal,
	      prestr,iprestr,filab,eme,een,iperturb,
	      f,fn,nactdof,&iout,qa,vold,b,nodeboun,
	      ndirboun,xbounact,nboun,ipompc,
	      nodempc,coefmpc,labmpc,nmpc,nmethod,cam,&neq[1],veold,accold,
              &bet,&gam,&dtime,&time,ttime,plicon,nplicon,plkcon,nplkcon,
	      xstateini,xstiff,xstate,npmat_,epn,matname,mint_,&ielas,&icmd,
	      ncmat_,nstate_,stiini,vini,ikboun,ilboun,ener,enern,sti,
              xstaten,eei,enerini,cocon,ncocon,set,nset,istartset,iendset,
              ialset,nprint,prlab,prset,qfx,qfn,trab,inotr,ntrans,fmpc,
              nelemload,nload));

      if(*ithermal<2){
	for(k=1;k<4**nk;k=k+4){vold[k]=v[k];vold[k+1]=v[k+1];vold[k+2]=v[k+2];}
      }else if(*ithermal==2){
	for(k=0;k<4**nk;k=k+4){vold[k]=v[k];vold[k+1]=v[k+1];vold[k+2]=v[k+2];}
      }else{for(k=0;k<4**nk;++k){vold[k]=v[k];}}
      if(*ithermal!=2){
	  for(k=0;k<6**mint_*ne0;++k){
	      sti[k]=stx[k];
	  }
      }

      iout=0;
      if(*iexpl==0) icmd=0;
      
      ++*kode;
      if(*mcs!=0){
	frdcyc(co,nk,kon,ipkon,lakon,ne,v,stn,inum,nmethod,kode,filab,een,
	       t1act,fn,ttime,epn,ielmat,matname,cs,mcs,nkon,enern,xstaten,
               nstate_,istep,&iinc,iperturb,ener,mint_,output,ithermal,qfn,
               ialset,istartset,iendset,trab,inotr,ntrans,orab,ielorien,
	       norien,sti);
      }
      else{
	  ipneigh=NNEW(int,*nk);neigh=NNEW(int,40**ne);
	  FORTRAN(out,(co,nk,kon,ipkon,lakon,ne,v,stn,inum,nmethod,kode,
		     filab,een,t1act,fn,ttime,epn,ielmat,matname,enern,
		     xstaten,nstate_,istep,&iinc,iperturb,ener,mint_,output,
                     ithermal,qfn,&mode,&noddiam,
                     trab,inotr,ntrans,orab,ielorien,norien,description,
                     ipneigh,neigh,sti));free(ipneigh);free(neigh);
      }
      
      free(v);
free(fn);
free(stn);
free(inum);
free(stx);
      if(*ithermal>1){free(qfx);free(qfn);}
      
      if(strcmp1(&filab[18],"E   ")==0) free(een);
      if(strcmp1(&filab[30],"PE  ")==0) free(epn);
      if(strcmp1(&filab[36],"ENER")==0) free(enern);
       if(strcmp1(&filab[42],"SDV ")==0) free(xstaten);
   }
    
  }

  /*********************************************************/
  /*   end of the increment loop                          */
  /*********************************************************/

  if(jprint!=0){

  /* calculating the displacements and the stresses and storing  
     the results in frd format */
  
    v=NNEW(double,4**nk);
    fn=NNEW(double,4**nk);
    stn=NNEW(double,6**nk);
    if(*ithermal>1) qfn=NNEW(double,3**nk);
    inum=NNEW(int,*nk);
    stx=NNEW(double,6**mint_*ne0);
    if(*ithermal>1) qfx=NNEW(double,3**mint_*ne0);
  
    if(strcmp1(&filab[18],"E   ")==0) een=NNEW(double,6**nk);
    if(strcmp1(&filab[30],"PE  ")==0) epn=NNEW(double,*nk);
    if(strcmp1(&filab[36],"ENER")==0) enern=NNEW(double,*nk);
    if(strcmp1(&filab[42],"SDV ")==0) xstaten=NNEW(double,*nstate_**nk);
    
    for(k=0;k<4**nk;++k){
      v[k]=vold[k];
    }
    iout=2;
    icmd=3;

    FORTRAN(results,(co,nk,kon,ipkon,lakon,ne,v,stn,inum,stx,
	    elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,ielmat,
	    ielorien,norien,orab,ntmat_,t0,t1,ithermal,
	    prestr,iprestr,filab,eme,een,iperturb,
	    f,fn,nactdof,&iout,qa,vold,b,nodeboun,
	    ndirboun,xbounact,nboun,ipompc,
	    nodempc,coefmpc,labmpc,nmpc,nmethod,cam,&neq[1],veold,accold,
            &bet,&gam,&dtime,&time,ttime,plicon,nplicon,plkcon,nplkcon,
	    xstateini,xstiff,xstate,npmat_,epn,matname,mint_,&ielas,&icmd,
            ncmat_,nstate_,stiini,vini,ikboun,ilboun,ener,enern,sti,
            xstaten,eei,enerini,cocon,ncocon,set,nset,istartset,iendset,
            ialset,nprint,prlab,prset,qfx,qfn,trab,inotr,ntrans,fmpc,
            nelemload,nload));

    if(*ithermal<2){
      for(k=1;k<4**nk;k=k+4){vold[k]=v[k];vold[k+1]=v[k+1];vold[k+2]=v[k+2];}
    }else if(*ithermal==2){
      for(k=0;k<4**nk;k=k+4){vold[k]=v[k];vold[k+1]=v[k+1];vold[k+2]=v[k+2];}
    }else{for(k=0;k<4**nk;++k){vold[k]=v[k];}}
    if(*ithermal!=2){
      for(k=0;k<6**mint_*ne0;++k){
	sti[k]=stx[k];
      }
    }
    
    iout=0;
    if(*iexpl==0) icmd=0;
    
    ++*kode;
    if(*mcs>0){
      frdcyc(co,nk,kon,ipkon,lakon,ne,v,stn,inum,nmethod,kode,filab,een,
	     t1act,fn,ttime,epn,ielmat,matname,cs,mcs,nkon,enern,xstaten,
             nstate_,istep,&iinc,iperturb,ener,mint_,output,ithermal,qfn,
             ialset,istartset,iendset,trab,inotr,ntrans,orab,ielorien,
	     norien,sti);
    }
    else{
	ipneigh=NNEW(int,*nk);neigh=NNEW(int,40**ne);
	FORTRAN(out,(co,nk,kon,ipkon,lakon,ne,v,stn,inum,nmethod,kode,filab,
		   een,t1act,fn,ttime,epn,ielmat,matname,enern,xstaten,
		   nstate_,istep,&iinc,iperturb,ener,mint_,output,ithermal,
                   qfn,&mode,&noddiam,
                     trab,inotr,ntrans,orab,ielorien,norien,description,
                     ipneigh,neigh,sti));free(ipneigh);free(neigh);
    }
    
    free(v);free(fn);free(stn);free(inum);free(stx);
    if(*ithermal>1){free(qfx);free(qfn);}
    
    if(strcmp1(&filab[18],"E   ")==0) free(een);
    if(strcmp1(&filab[30],"PE  ")==0) free(epn);
    if(strcmp1(&filab[36],"ENER")==0) free(enern);
    if(strcmp1(&filab[42],"SDV ")==0) free(xstaten);

  }

  /* setting the velocity to zero at the end of a quasistatic or stationary
     step */

  if(*nmethod==1){
    for(k=0;k<4**nk;++k){veold[k]=0.;}
  }

  /* updating the loading at the end of the step; 
     important in case the amplitude at the end of the step
     is not equal to one */

  for(k=0;k<*nboun;++k){xbounold[k]=xbounact[k];}
  for(k=0;k<*nforc;++k){xforcold[k]=xforcact[k];}
  for(k=0;k<2**nload;++k){xloadold[k]=xloadact[k];}
  for(k=0;k<7**nbody;k=k+7){xbodyold[k]=xbodyact[k];}
  if(*ithermal==1){
    for(k=0;k<*nk;++k){t1old[k]=t1act[k];}
  }
  else if(*ithermal>1){
    for(k=0;k<*nk;++k){t1[k]=vold[4*k];}
    if(*ithermal==3){
	for(k=0;k<*nk;++k){t1old[k]=t1act[k];}
    }
  }

  qaold[0]=qa[0];
  qaold[1]=qa[1];

  free(f);
  free(b);
  free(xbounact);free(xforcact);free(xloadact);free(xbodyact);
  if(*nbody>0) free(ipobody);if(inewton==1){free(cgr);}
  free(fext);free(ampli);free(xbounini);free(xstiff);
  if((*ithermal==1)||(*ithermal==3)){free(t1act);free(t1ini);}

  if(*ithermal>1){
      free(itg);free(ieg);free(iptri);free(kontri);free(nloadtr);
      free(area);
      free(pmid);
      free(nactdog);
      free(voldgas);
      free(nacteq);
      free(dist);free(idist);free(fij);free(tarea);free(tenv);free(fenv);
      free(erad);free(ac);free(bc);free(ipiv);free(e1);free(e2);free(e3);
      if((*mcs>0)&&(ntr>0)){free(inocs);}
  }

  free(fini);  
  if(*nmethod==4){
    free(aux2);free(fextini);free(veini);free(accini);
    free(adb);free(aub);
  }
  free(eei);free(stiini);
  if(*nener==1)
      free(enerini);
  if(*nstate_!=0){free(xstateini);}

  free(aux);free(iaux);free(vini);

  if(icascade==2){
      *nmpc=nmpcref;memmpc_=memmpcref_;mpcfree=mpcfreeref;
      RENEW(nodempc,int,3*memmpcref_);
      for(k=0;k<3*memmpcref_;k++){nodempc[k]=nodempcref[k];}
      RENEW(coefmpc,double,memmpcref_);
      for(k=0;k<memmpcref_;k++){coefmpc[k]=coefmpcref[k];}
      free(nodempcref);free(coefmpcref);
  }

  if(ncont!=0){
      *ne=ne0;*nkon=nkon0;
      RENEW(ipkon,int,*ne);
      RENEW(lakon,char,8**ne);
      RENEW(kon,int,*nkon);
      if(*norien>0){
	  RENEW(ielorien,int,*ne);
      }
      RENEW(ielmat,int,*ne);
      free(cg);free(straight);
  }

  mpcinfo[0]=memmpc_;mpcinfo[1]=mpcfree;mpcinfo[2]=icascade;
  mpcinfo[3]=maxlenmpc;

  *icolp=icol;*irowp=irow;*cop=co;*voldp=vold;
  *nodempcp=nodempc;*coefmpcp=coefmpc;
  *ipkonp=ipkon;*lakonp=lakon;*konp=kon;*ielorienp=ielorien;
  *ielmatp=ielmat;
  
  return;
}
