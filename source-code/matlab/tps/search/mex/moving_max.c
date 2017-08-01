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

#include "mex.h"
#include "matrix.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

/* Main Function */
void moving_max( double* timeSeries, int windowSize, int nCadences, 
        double* maxTimeSeries, int* indicesOfMaximums ) {

int iCadence, iWindow, iStart, iEnd, hWindowSize, tempIndex;
double tempMax;


hWindowSize = (int)ceil(windowSize/2);

for( iCadence = 0; iCadence < nCadences; iCadence++ ){
    
    iStart = iCadence - hWindowSize;
    iEnd = iCadence + hWindowSize;
    
    /* check boundaries */
    if( iStart < 0 ){
        iStart = 0;
    }
    if( iEnd > (nCadences - 1) ){
        iEnd = nCadences - 1;
    }
    
    for( iWindow = iStart; iWindow <= iEnd; iWindow++ ){
        
        if( iWindow == iStart ){
            tempMax = timeSeries[iWindow];
            tempIndex = iWindow;
        } else if( timeSeries[iWindow] > tempMax ){
            tempMax = timeSeries[iWindow];
            tempIndex = iWindow;
        } else if( iWindow != iStart && timeSeries[iWindow] == tempMax){
            /* the values are equal so keep whatever one is closest to iCadence */
            if ( abs( iWindow - iCadence) < abs( tempIndex - iCadence ) ){
                tempMax = timeSeries[iWindow];
                tempIndex = iWindow;
            }
            
        }
        
    } /* end for( iWindow */
    
    maxTimeSeries[iCadence] = tempMax;
    indicesOfMaximums[iCadence] = tempIndex + 1; /* convert to 1-base */
    
} /* end for( iCadences */

} /* end Main Function */





/* Gateway Routine */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    /* Declare variables */ 
    double *timeSeries, *maxTimeSeries;
    int *indicesOfMaximums;
    int windowSize, nCadences;
    mwSize outputSize[2];

    /* Check number of input  and output arguments */
    if (nrhs != 2)
        mexErrMsgTxt("Wrong number of input arguments: 2 required");
    
    if (nlhs != 1 && nlhs != 2)
        mexErrMsgTxt("Wrong number of output arguments: 1 or 2 required");
    
    /* Parse the inputs */
    timeSeries = mxGetPr( prhs[0] );
    windowSize = mxGetScalar( prhs[1] );
    
    /* get dimensions */
    nCadences = (int)( mxGetM(prhs[0]) );
    outputSize[0] = nCadences;
    outputSize[1] = 1;
    
    /* make sure the nCadences is larger than the window */
    if( nCadences < windowSize )
        mexErrMsgTxt("The number of cadences must be larger than the window size!");
    
    /* set up the outputs */
    plhs[0] = mxCreateDoubleMatrix( nCadences, 1, mxREAL );
    maxTimeSeries = mxGetPr( plhs[0] );
    plhs[1] = mxCreateNumericArray(2,outputSize,mxINT32_CLASS,mxREAL);
    indicesOfMaximums = mxGetPr( plhs[1] );
    
    moving_max( timeSeries, windowSize, nCadences, maxTimeSeries, indicesOfMaximums );
    
}
