/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 *
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

/*fold_periods.c **/
#include "mex.h"
#include <math.h>
#include <omp.h>


static void  fold_periods(double* trialPeriodsInCadences, double* correlationTimeSeries, double* normalizationTimeSeries, double deltaLag, \
        double nPeriods, double nCadences, double minSesCount, double* maxStatistic, double* minStatistic, \
        double* phaseLagForMaxStatisticInCadences, double* phaseLagForMinStatisticInCadences) {
    
    int i, kk;
    int nSesInMes ;
    double fNum, fDen, fPhaseLag, fPeriod, fFoldCadence ;

    /* Fork a team of threads */
#pragma omp parallel shared(trialPeriodsInCadences, correlationTimeSeries, normalizationTimeSeries, nPeriods, nCadences, maxStatistic, minStatistic, phaseLagForMaxStatisticInCadences, minSesCount, phaseLagForMinStatisticInCadences) \
  private(i, kk, fNum, fDen, fPhaseLag, fPeriod, nSesInMes, fFoldCadence)

    {

    #pragma omp for
    
    for(i = 0; i < nPeriods; i++) {
        fPeriod = trialPeriodsInCadences[i]; /* floating point array*/
        maxStatistic[i] = -10000000.0;
        minStatistic[i] = 10000000.0;
        phaseLagForMaxStatisticInCadences[i] = -1.0;
        phaseLagForMinStatisticInCadences[i] = -1.0;
        
        for(fPhaseLag = 0; fPhaseLag <= (fPeriod-1); fPhaseLag = fPhaseLag+deltaLag) {
            fNum = 0.0;
            fDen = 0.0;
            nSesInMes = 0 ;
            
            for(fFoldCadence = fPhaseLag; fFoldCadence <= (nCadences-1); fFoldCadence = fFoldCadence+fPeriod) { /* fFoldCadence becomes a float since the step size fPeriod is a float*/
                /*kk = floor(fFoldCadence+0.5);*/
                kk = (int)(fFoldCadence+0.5);
                fNum += correlationTimeSeries[kk];
                fDen += normalizationTimeSeries[kk];
                if (correlationTimeSeries[kk] != 0.0 || normalizationTimeSeries[kk] != 0.0) {
                    nSesInMes++ ;
                }
            }
            if(fDen > 0.0 && nSesInMes >= minSesCount) {
                fNum = fNum/sqrt(fDen);
            }
            else {
                fNum = 0.0 ;
            }
            if(fNum > maxStatistic[i]) {
                maxStatistic[i] = fNum;
                phaseLagForMaxStatisticInCadences[i] = fPhaseLag;
            }
            if(fNum < minStatistic[i]) {
                minStatistic[i] = fNum;
                phaseLagForMinStatisticInCadences[i] = fPhaseLag;
            }
        }
    }

  } /* end openmp init pragma */
    
}





/* The gateway routine */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    double *correlationTimeSeries, *normalizationTimeSeries, *trialPeriodsInCadences, \
            *maxStatistic, *minStatistic, *phaseLagForMaxStatisticInCadences, *phaseLagForMinStatisticInCadences;
    double nPeriods, nCadences, mRows, nColumns, deltaLag, minSesCount;
    
    /*  Check for proper number of arguments. */
    /* NOTE: You do not need an else statement when using
     * mexErrMsgTxt within an if statement. It will never
     * get to the else statement if mexErrMsgTxt is executed.
     * (mexErrMsgTxt breaks you out of the MEX-file.)
     */
    if (nrhs != 7)
        mexErrMsgTxt("Six inputs required.");
    if (nlhs != 4)
        mexErrMsgTxt("Four outputs required.");
    
    
    /* Create a pointer to the input matrix Trial periods. */
    trialPeriodsInCadences = mxGetPr(prhs[0]);
    
    /* Create a pointer to the input matrix correlationTimeSeries */
    correlationTimeSeries = mxGetPr(prhs[1]);
    
    /* Create a pointer to the input matrix correlationTimeSeries */
    normalizationTimeSeries = mxGetPr(prhs[2]);
    
    /* Get the deltalag */
    deltaLag = mxGetScalar(prhs[3]);
    
    /* Get the deltalag */
    nPeriods = mxGetScalar(prhs[4]);
    
    /* Get the nCadences */
    nCadences = mxGetScalar(prhs[5]);

   /* Get the minSesCount */
   minSesCount = mxGetScalar(prhs[6]) ;
    
    
    /* Get the dimensions of the matrix input y. */
    mRows = mxGetM(prhs[0]);
    nColumns = 1;
    
    /* Set the output pointer to the maxStatistic */
    plhs[0] = mxCreateDoubleMatrix(mRows, nColumns, mxREAL);
    
    /* Create a C pointer to a copy of the output matrix. */
    maxStatistic = mxGetPr(plhs[0]);
    
    /* Set the output pointer to the minStatistic */
    plhs[1] = mxCreateDoubleMatrix(mRows, nColumns, mxREAL);
    
    /* Create a C pointer to a copy of the output matrix. */
    minStatistic = mxGetPr(plhs[1]);
    
    /* Set the output pointer to the phaseLagForMaxStatisticInCadences */
    plhs[2] = mxCreateDoubleMatrix(mRows, nColumns, mxREAL);
    
    /* Create a C pointer to a copy of the output matrix. */
    phaseLagForMaxStatisticInCadences = mxGetPr(plhs[2]);
    
    
    /* Set the output pointer to the phaseLagForMinStatisticInCadences */
    plhs[3] = mxCreateDoubleMatrix(mRows, nColumns, mxREAL);
    
    /* Create a C pointer to a copy of the output matrix. */
    phaseLagForMinStatisticInCadences = mxGetPr(plhs[3]);
    
    
    /* Call the C subroutine. */
    fold_periods(trialPeriodsInCadences, correlationTimeSeries, normalizationTimeSeries, deltaLag, nPeriods, nCadences, minSesCount, \
            maxStatistic, minStatistic, phaseLagForMaxStatisticInCadences, phaseLagForMinStatisticInCadences);
    
}
