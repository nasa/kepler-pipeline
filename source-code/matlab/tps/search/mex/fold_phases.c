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
#ifdef __linux__
#include <omp.h>
#endif
#include <stdio.h>
#include "fold_time_series.h"
#define FOLD_ONE_PERIOD_ALL_PHASES
#include "fold_time_series_algorithm.h"


void mexFunction( int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] )
{

/*  input variables  */

    double *correlationTimeSeries, *normalizationTimeSeries ;
    double periodInCadences, phaseStepInCadences, minSesCount ;

/*  output variables  */

    double *mesVector, *phaseLagVector ;

/*  vector lengths  */

    int nCadences, nMultipleEventStatistics, mexReturn ;
	
/*	arguments for the squaring of the normalization  */
	
	mxArray *normSquaredArray[1] ;
	mxArray *squaringRhs[2] ;
	
/* check # of input and output arguments */

    if (nrhs != 5)
	mexErrMsgTxt("Five inputs required.") ;
    if (nlhs != 2)
	mexErrMsgTxt("Two outputs required") ;

/*  unpack inputs  */

    correlationTimeSeries   = mxGetPr(prhs[0]) ;
    periodInCadences        = mxGetScalar(prhs[2]) ;
    phaseStepInCadences     = mxGetScalar(prhs[3]) ;
    minSesCount             = mxGetScalar(prhs[4]) ;

    nCadences               = mxGetM(prhs[0]) * mxGetN(prhs[0]) ;

/*  vector-square the normalization time series (which is arg 2)  */

	squaringRhs[0] = prhs[1] ;
	squaringRhs[1] = mxCreateDoubleScalar(2.0) ;
	mexReturn = mexCallMATLAB(1,normSquaredArray,2,squaringRhs,"power") ;
	normalizationTimeSeries = mxGetPr(normSquaredArray[0]) ;
	
/*  prepare outputs  */

	nMultipleEventStatistics = (int)ceil( periodInCadences / phaseStepInCadences ) ;
	plhs[0] = mxCreateDoubleMatrix( nMultipleEventStatistics, 1, mxREAL ) ;
	mesVector = mxGetPr( plhs[0] ) ;
	plhs[1] = mxCreateDoubleMatrix( nMultipleEventStatistics, 1, mxREAL ) ;
	phaseLagVector = mxGetPr( plhs[1] ) ;

/*  call the C-function  */

	fold_time_series( correlationTimeSeries, normalizationTimeSeries, (int)nCadences,
	     &periodInCadences, 1, phaseStepInCadences, minSesCount, 0, 0, 0, 0, 
	     mesVector, NULL, NULL, NULL, NULL, phaseLagVector, NULL, NULL, NULL, NULL, NULL, NULL, NULL ) ;
		
} /* end of gateway function */



