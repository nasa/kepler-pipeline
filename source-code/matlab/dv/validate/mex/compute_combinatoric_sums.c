/************************************************************************** 
 * This function computes sums of all the combinations of sumComponents
 * taken subsetSize at a time and outputs them in combinatoricSums.
 * 
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
 *************************************************************************/

/* Usage: mex -g bootstrap.c*/

/* included files */

#include "mex.h"
#include "matrix.h"
#include <stdio.h>
#include <gmp.h>
#include <math.h>
#include <stdlib.h>

/* function declarations */

void initialize_counter (unsigned long int *counter, unsigned long int subsetSize);

void initialize_partial_sums(double *sumComponents, unsigned long int subsetSize, 
        double *partialSum);

int increment_counter(unsigned long int *counter, unsigned long int subsetSize, 
        unsigned long int setSize);

double compute_sum(unsigned long int *counter, unsigned long int subsetSize,
        double *sumComponents, double *partialSum, int partialSumUpdateLevel);


/* Main function */
void compute_combinatoric_sums( unsigned long int setSize, unsigned long int subsetSize, 
    unsigned long int nCombinations, double* sumComponents, double* combinatoricSums) {

/* declare variables */
    
unsigned long int *counter;
double *partialSum;
int i,j;
int partialSumUpdateLevel;


/* initialize variables */

counter = calloc(subsetSize, sizeof(unsigned long int));
if (counter == NULL){
    mexPrintf("\t Unable to allocate memory for counter.\n");
    return;
}
initialize_counter(counter, subsetSize);

/* only store partial sums if setSize > 2 */
if (subsetSize > 2){
    partialSum = calloc(subsetSize - 2, sizeof(double));
    if (partialSum == NULL){
        mexPrintf("\t Unable to allocate memory for partial sum.\n");
        return;
    }
}

/* initialize partialSum */
initialize_partial_sums( sumComponents, subsetSize, partialSum);

i = 0;
partialSumUpdateLevel = -1;

for(i = 0; i < nCombinations; i++){
    
    /*for(j=0;j<subsetSize;j++){
        if(j == (subsetSize-1)){
            mexPrintf("%ld\n",counter[j]);
        } else {
            mexPrintf("%ld ",counter[j]);
        }
    }*/
    
    /* compute the sum */
    combinatoricSums[i] = compute_sum(counter, subsetSize, sumComponents, partialSum, partialSumUpdateLevel);
    
    /* increment counter */
    partialSumUpdateLevel = increment_counter(counter, subsetSize, setSize);
    
}

/* free memory where necessary */
free(counter);
if (subsetSize > 2){
    free(partialSum);
}


} /* end main function */

/* Private Functions */

void initialize_counter (unsigned long int *counter, unsigned long int subsetSize){
    int i;
    for (i = 0; i < subsetSize; i++) {
        counter[i] = i;
    }
}

void initialize_partial_sums(double *sumComponents, unsigned long int subsetSize, double *partialSum){
    int i;
    if (subsetSize > 2){
        partialSum[0] = sumComponents[0] + sumComponents[1];
        for (i = 1; i < subsetSize - 2; i++) {
            partialSum[i] = partialSum[i-1] + sumComponents[i+1];
        } 
    }
    else {
        partialSum = NULL;
    }
}

int increment_counter(unsigned long int *counter, unsigned long int subsetSize, 
    unsigned long int setSize){
    
    int i, j, k;
    int partialSumUpdateLevel;
    partialSumUpdateLevel = -1;
    k = 0;
    i = 1;
    
    if (subsetSize > 2){
        for(i=subsetSize-1;i>=0;i--){
            if( counter[i] < (setSize - subsetSize + i) ){
                counter[i]++;
                for(j=i+1;j<subsetSize;j++){
                    counter[j] = counter[j-1] + 1;
                }
                if ( (i-2) > 0 ){
                    partialSumUpdateLevel = i - 2;
                } else {
                    partialSumUpdateLevel = 0;
                }
                i = -1;
            }
        }
    } else {
        for(i=subsetSize-1;i>=0;i--){
            if( counter[i] < (setSize - subsetSize + i) ){
                counter[i]++;
                for(j=i+1;j<subsetSize;j++){
                    counter[j] = counter[j-1] + 1;
                }
                i = -1;
            }
        }
    }
    
    
    return partialSumUpdateLevel;
}

double compute_sum(unsigned long int *counter, unsigned long int subsetSize,
        double *sumComponents, double *partialSum, int partialSumUpdateLevel) {
    int i;
    double summedValues = 0;
    
    if (subsetSize < 3){
        for (i = 0; i < subsetSize; i++) {
            summedValues += sumComponents[counter[i]];
        }
    } else {
    
        /* check if any partial sums need updated */
        if (partialSumUpdateLevel != -1){
            for (i=partialSumUpdateLevel; i < subsetSize - 2; i++){
                if (i==0){
                    partialSum[i] = sumComponents[counter[0]] + sumComponents[counter[1]] ;      
                } else {
                    partialSum[i] = partialSum[i-1] + sumComponents[counter[i+1]];
                }
            }
        }
        summedValues = partialSum[subsetSize - 3] + sumComponents[counter[subsetSize - 1]];
    }
    return summedValues;
}




void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    /* Declare variables */ 
    double *combinatoricSums, *sumComponents;
    unsigned long int setSize, subsetSize, nCombinations;
    mwSize nRows, nColumns;
    

    /* Check number of input  and output arguments */
    if (nrhs != 4)
        mexErrMsgTxt("Wrong number of input arguments: 4 required");
    
    if (nlhs != 1)
        mexErrMsgTxt("Wrong number of output arguments: 1 required");
    
    /* Parse the inputs */
    sumComponents = mxGetPr(prhs[0]);
    setSize = mxGetScalar(prhs[1]);
    subsetSize = mxGetScalar(prhs[2]); 
    nCombinations = mxGetScalar(prhs[3]);
    nRows = nCombinations;
    nColumns = 1;

    
    /* make sure the set is larger than the subset */
    if( setSize < subsetSize )
        mexErrMsgTxt("The set size must be larger than the subset size!");
    
    /* create outputs */
    plhs[0] = mxCreateDoubleMatrix(nRows, nColumns, mxREAL);
    combinatoricSums = mxGetPr(plhs[0]);
        
    /* Call bootstrap */
    compute_combinatoric_sums( setSize, subsetSize, nCombinations, sumComponents, combinatoricSums );
    
}
