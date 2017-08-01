/**************************************************************************
Mex routine for median filtering.  The window size must be odd.

Usage:
m = median_filter(x, windowSize)

Input arguments:
    x          : Input signal
    windowSize : Median filter window size

Output arguments:
    m          Median filtered signal

(c) Max Little, 2010. If you use this code, please cite:
Little, M.A. and Jones, N.S. (2010),
"Sparse Bayesian Step-Filtering for High-Throughput Analysis of Molecular
Machine Dynamics"
in Proceedings of ICASSP 2010, IEEE Publishers: Dallas, USA.
 
Adapted from code written by Nicolas Devillard.

Copyright 2017 United States Government as represented by the
Administrator of the National Aeronautics and Space Administration.
All Rights Reserved.

NASA acknowledges the SETI Institute's primary role in authoring and
producing the Kepler Data Processing Pipeline under Cooperative
Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
NNX11AI14A, NNX13AD01A & NNX13AD16A.

This file is available under the terms of the NASA Open Source Agreement
(NOSA). You should have received a copy of this agreement with the
Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.

No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
AND DISTRIBUTES IT "AS IS."

Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
TERMINATION OF THIS AGREEMENT.
**************************************************************************/

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "mex.h"
#include "matrix.h"

#define SWAP(a,b) { register double t=(a);(a)=(b);(b)=t; }
double quickSelect(double arr[], int n)
{
    long low, high;
    long median;
    long middle, ll, hh;

    low = 0;
    high = n-1;
    median = (low + high) / 2;
    for (;;)
    {
        /* One element only */
        if (high <= low)
            return arr[median];

        /* Two elements only */
        if (high == low + 1)
        {
            if (arr[low] > arr[high])
                SWAP(arr[low], arr[high]);
            return arr[median];
        }

        /* Find median of low, middle and high items; swap to low position */
        middle = (low + high) / 2;
        if (arr[middle] > arr[high])
            SWAP(arr[middle], arr[high]);
        if (arr[low] > arr[high])
            SWAP(arr[low], arr[high]);
        if (arr[middle] > arr[low])
            SWAP(arr[middle], arr[low]);

        /* Swap low item (now in position middle) into position (low+1) */
        SWAP(arr[middle], arr[low+1]);

        /* Work from each end towards middle, swapping items when stuck */
        ll = low + 1;
        hh = high;
        for (;;)
        {
            do
                ll++;
            while (arr[low] > arr[ll]);
            do
                hh--;
            while (arr[hh] > arr[low]);

            if (hh < ll)
                break;

            SWAP(arr[ll], arr[hh]);
        }

        /* Swap middle item (in position low) back into correct position */
        SWAP(arr[low], arr[hh]);

        /* Reset active partition */
        if (hh <= median)
            low = ll;
        if (hh >= median)
            high = hh - 1;
    }
}

/* Perform running median filtering */
static void median_filter(double *xInput, int nSamples, int windowSize, double *mOutput) {
    /* declare variables */
    long i, k, idx;
    double *w;
    
    /* check to make sure the windowSize is odd */
    if (windowSize % 2 == 0){
        windowSize = windowSize--;
    }
    
    /* allocate memory */
    w = (double *)mxCalloc(windowSize, sizeof(double));  

    for (i = 0; i < nSamples; i ++)
    {
        /* Fill up the sliding window */
        for (k = 0; k < windowSize; k++)
        {
            idx = i - (windowSize - 1) / 2 + k;

            if (idx < 0)
            {
                /* Need to get values from the initial condition vector */
                w[k] = 0;
            }
            else if (idx >= nSamples)
            {
                /* Need to get values from the final condition vector */
                w[k] = 0;
            }
            else
            {
                w[k] = xInput[idx];
            }
        }

        /* Select the median of the sliding window */
        mOutput[i] = quickSelect(w, windowSize);
    }

    /* Clean up */
    mxFree(w);
}



/* Main entry point */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    /* Declare variables */ 
    int windowSize;
    double *xInput, *mOutput;               
    
    /* declare matlab typed variables */
    mwSize nSamples;
   
    /* Check for proper number of arguments */
    if ((nrhs != 2) || (nlhs != 1)) {
        mexErrMsgTxt("Incorrect number of parameters in call to median_filter.\n");
    }

    /* Parse the inputs */
    nSamples    = mxGetM(prhs[0]);
    windowSize = mxGetScalar(prhs[1]);
    xInput = mxGetPr(prhs[0]);
    
    /* make sure the window size is less than the size of the data */
    if (windowSize >= nSamples) {
        mexErrMsgTxt("Window size of the median filter can't exceed the number of samples.\n"); 
    }
    
    /* make sure the window size is at least 3 samples */
    if (windowSize < 3) {
        mexErrMsgTxt("Window size of the median filter must be larger than 2 samples.\n"); 
    }
    
    /* allocate storage for output */
    plhs[0] = mxCreateDoubleMatrix(nSamples, 1, mxREAL);
    mOutput = mxGetPr(plhs[0]);

    /* Compute running median */
    median_filter(xInput, nSamples, windowSize, mOutput);
    return;
}
