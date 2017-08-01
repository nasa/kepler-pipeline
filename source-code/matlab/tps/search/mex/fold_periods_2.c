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

/*  fold_periods_2.c  */
#include "mex.h"
#include <math.h>
#include <omp.h>

static void fold_periods( 
/*  "input" parameters  */
    mxArray* correlationTimeSeries, mxArray* normalizationTimeSeries, double* trialPeriodsInCadences, 
    mxArray* deltaLag, double nPeriods, mxArray* minSesCount, 
/*  "output" parameters  */
    double* maxStatistic, double* minStatistic, double* maxStatisticPhaseLagCadences, 
    double* minStatisticPhaseLagCadences )

{
    int i, mexReturn ;
    double period ;
    mxArray* foldPhasesRhs[5] ;
    mxArray* foldPhasesLhs[4] ;

/*  for parallelization:  */

#pragma omp parallel shared(correlationTimeSeries, normalizationTimeSeries, trialPeriodInCadences, \
    deltaLag, nPeriods, minSesCount, maxStatistic, minStatistic, maxStatisticPhaseLagCadences, \
    minStatisticPhaseLagCadences) \
  private(i, mexReturn foldPhasesRhs, foldPhasesLhs) 

/*  perform static assignments for the RHS of the phases call  */

    {
    #pragma omp for

    for (i=0 ; i < nPeriods ; i++)
      {
	
/*  assign mxArray* values -- though these assignments are the same on all iterations of the loop,
    they have to be done on each iteration for parallelization reasons  */

	foldPhasesRhs[0] = correlationTimeSeries ;
	foldPhasesRhs[1] = normalizationTimeSeries ;
	foldPhasesRhs[3] = deltaLag ;
	foldPhasesRhs[4] = minSesCount ;

/*  set the period  */

        foldPhasesRhs[2] = mxCreateDoubleScalar(trialPeriodsInCadences[i]) ;

/*  perform the call to the phase folder and capture results, if successful  */

	mexReturn = mexCallMATLAB( 4, foldPhasesLhs, 5, foldPhasesRhs, "fold_phases" ) ;
	if (mexReturn == 0)
	{
	    maxStatistic[i]                 = mxGetScalar( foldPhasesLhs[0] ) ;
	    minStatistic[i]                 = mxGetScalar( foldPhasesLhs[1] ) ;
	    maxStatisticPhaseLagCadences[i] = mxGetScalar( foldPhasesLhs[2] ) ;
	    minStatisticPhaseLagCadences[i] = mxGetScalar( foldPhasesLhs[3] ) ;
	    mxDestroyArray( foldPhasesLhs[0] ) ;
	    mxDestroyArray( foldPhasesLhs[1] ) ;
	    mxDestroyArray( foldPhasesLhs[2] ) ;
	    mxDestroyArray( foldPhasesLhs[3] ) ;
	}
	else
	{
	    maxStatistic[i]                 =  0.0 ;
	    minStatistic[i]                 =  0.0 ;
	    maxStatisticPhaseLagCadences[i] = -1.0 ;
	    minStatisticPhaseLagCadences[i] = -1.0 ;
	}
	mxDestroyArray( foldPhasesRhs[2] ) ;
      } /* close of for-loop */
    } /* close of parallelization */
} /* end function */

/*===========================================================================*/

/*  Gateway routine  */

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    double *trialPeriodsInCadences ;
    double nCadences ;

    double *maxStatistic, *minStatistic ;
    double *maxStatisticPhaseLagCadences, *minStatisticPhaseLagCadences ;

    int nPeriods ;

/*  dimensions check  */

    if (nrhs != 5)
	mexErrMsgTxt( "Five inputs required." ) ;
    if (nlhs != 4)
	mexErrMsgTxt( "Four outputs required." ) ;

/*  unpack as needed  */

    trialPeriodsInCadences = mxGetPr( prhs[0] ) ;
    nPeriods = (int)(mxGetM( prhs[0] )*mxGetN( prhs[0] )) ;
    nCadences = mxGetM( prhs[1] ) * mxGetN( prhs[1] ) ;

/*  construct return variables  */

    plhs[0] = mxCreateDoubleMatrix( nPeriods, 1, mxREAL ) ;
    plhs[1] = mxCreateDoubleMatrix( nPeriods, 1, mxREAL ) ;
    plhs[2] = mxCreateDoubleMatrix( nPeriods, 1, mxREAL ) ;
    plhs[3] = mxCreateDoubleMatrix( nPeriods, 1, mxREAL ) ;
  
/*  perform assignments of double pointers  */

    maxStatistic = mxGetPr( plhs[0] ) ;
    minStatistic = mxGetPr( plhs[1] ) ;
    maxStatisticPhaseLagCadences = mxGetPr( plhs[2] ) ;
    minStatisticPhaseLagCadences = mxGetPr( plhs[3] ) ;

/*  perform the call to fold_periods  */

    fold_periods( prhs[1], prhs[2], trialPeriodsInCadences, prhs[3], nPeriods, prhs[4], 
	maxStatistic, minStatistic, maxStatisticPhaseLagCadences, minStatisticPhaseLagCadences ) ;

} /* end gateway function */
