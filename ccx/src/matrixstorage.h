/*     CALCULIX - A 3-dimensional finite element program                 */
/*              Copyright (C) 1998 Guido Dhondt                          */
/*     This program is free software; you can redistribute it and/or     */
/*     modify it under the terms of the GNU General Public License as    */
/*     published by the Free Software Foundation; either version 2 of    */
/*     the License, or (at your option) any later version.               */

/*     This program is distributed in the hope that it will be useful,   */
/*     but WITHOUT ANY WARRANTY; without even the implied warranty of    */ 
/*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the      */
/*     GNU General Public License for more details.                      */

/*     You should have received a copy of the GNU General Public License */
/*     along with this program; if not, write to the Free Software       */
/*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.         */


void matrixstorage(double *ad, double **aup, double *adb, double *aub, 
                double *sigma,int *icol, int **irowp, 
                int *neq, int *nzs, int *ntrans, int *inotr,
                double *trab, double *co, int *nk, int *nactdof,
		char *jobnamec, int *mi, int *ipkon, char *lakon,
		int *kon, int *ne, int *mei, int *nboun, int *nmpc);


