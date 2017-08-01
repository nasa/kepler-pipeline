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
#include <gmp.h>
#include <math.h>
#include <stdlib.h>

/* Main function */
void compute_binomial_coefficient( unsigned long int setSize, unsigned long int subsetSize, unsigned long int* binomialCoefficient) {
    
    /* Declare variables */    
    mpz_t tempFactorial1;
    mpz_t tempFactorial2;
    mpz_t binomialCoeff;
    unsigned long int setSizeDiff;
    
    /* initialize */
    mpz_init(tempFactorial1);
    mpz_init(tempFactorial2);
    mpz_init(binomialCoeff);
    setSizeDiff = setSize - subsetSize;
    
    mpz_fac_ui(binomialCoeff, setSize);
    mpz_fac_ui(tempFactorial1, subsetSize);
    mpz_fac_ui(tempFactorial2, setSizeDiff);
    mpz_mul(tempFactorial1, tempFactorial1, tempFactorial2);
    mpz_cdiv_q(binomialCoeff, binomialCoeff, tempFactorial1);
    
    *binomialCoefficient = mpz_get_ui(binomialCoeff);
    
    mpz_clear(tempFactorial1);
    mpz_clear(tempFactorial2);
    mpz_clear(binomialCoeff);
    
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    /* Declare variables */ 
    unsigned long int *binomialCoefficient;
    unsigned int setSize, subsetSize;

    /* Check number of input  and output arguments */
    if (nrhs != 2)
        mexErrMsgTxt("Wrong number of input arguments: 2 required");
    
    if (nlhs != 1)
        mexErrMsgTxt("Wrong number of output arguments: 1 required");
    
    /* Parse the inputs */
    setSize = mxGetScalar(prhs[0]);
    subsetSize = mxGetScalar(prhs[1]); 
    
    mwSize outputSize[2];
    outputSize[0] = 1;
    outputSize[1] = 1;
    
    /* make sure the set is larger than the subset */
    if( setSize < subsetSize )
        mexErrMsgTxt("The set size must be larger than the subset size!");
    
    /* create outputs */
    plhs[0] = mxCreateNumericArray(2,outputSize,mxUINT64_CLASS,mxREAL);
    binomialCoefficient = mxGetPr(plhs[0]);
        
    /* Call bootstrap */
    compute_binomial_coefficient( setSize, subsetSize, binomialCoefficient );
    
}
