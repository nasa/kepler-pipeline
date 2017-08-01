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
#include <stdlib.h>
#include <math.h>
#include <stdio.h>


/* Usage: mex -g bootstrap.c*/

/* Global declaration for factorial*/
static const unsigned long long int fact[] = {1, 1, 2, 6, 24, 120, 720, 5040, 40320,
    362880,3628800, 39916800, 479001600, 6227020800, 87178291200,
    1307674368000, 20922789888000, 355687428096000, 6402373705728000,
    121645100408832000, 2432902008176640000};

/* Function  declarations */
static void initialize_counter(unsigned long int *counter, unsigned int observedTransitCount);

static void increment_counter(unsigned long int *counter, unsigned int observedTransitCount, unsigned long int lengthSES);

static unsigned long int get_combination(unsigned long int *counter, unsigned int observedTransitCount);

static unsigned long long int factorial(unsigned int n);

static unsigned int unique(unsigned long int *counter, unsigned int observedTransitCount);

static double compute_detection_statistics(unsigned long int *counter, unsigned int observedTransitCount,
        double *SES_numerator, double *SES_denominator);

static void update_histogram_with_combination(double *statistics, double *histogramCount,
        unsigned long int combination, double detStat, int lengthProbabilities);

static void increment_counter_by_skip_count(unsigned long int *counter, unsigned long int *oldCounter,
        unsigned int observedTransitCount, unsigned long int bootstrapSkipCount, double detStat,
        double searchTransitThreshold, unsigned long int lengthSES);



/* Main function */
void bootstrap(double searchTransitThreshold, unsigned long int bootstrapSkipCount,
        unsigned int observedTransitCount, unsigned long int lengthSES, double* SES_numerator,
        double* SES_denominator, double* statistics, int debugLevel, 
        unsigned long long int bootstrapMaxIterations, 
        int bootstrapUpperLimitFactor, int lengthProbabilities,
        double* histogramCount, double* loop) {
    
    /* Declare variables */
    int j;
    unsigned long int *counter, *oldCounter, combinations;
    unsigned long long int printFlag, everyIteration = 10000000;
    unsigned long long int localLoop = 0;
    
    double detStat;
    
    counter = mxCalloc(observedTransitCount, sizeof(unsigned long int));
    if (counter == NULL){
        mexPrintf("\t Unable to allocate memory for counter.\n");
        return;
    }
    
    oldCounter = mxCalloc(observedTransitCount, sizeof(unsigned long int));
    if (oldCounter == NULL){
        mexPrintf("\t Unable to allocate memory for oldCounter.\n");
        return;
    }

    initialize_counter(counter, observedTransitCount);
    
    while(counter[0]<lengthSES){
        localLoop++;
        printFlag = (0 == localLoop % everyIteration);
        for (j=0; j<observedTransitCount; j++){
            oldCounter[j]=counter[j];
        }
        
        increment_counter(counter, observedTransitCount, lengthSES);
        combinations = get_combination(counter, observedTransitCount);
        
        if (combinations == 0){return;}
        
        detStat = compute_detection_statistics(counter, observedTransitCount, SES_numerator, SES_denominator);
        
        if (detStat <= statistics[0]){ break;}
        
        if (localLoop > bootstrapUpperLimitFactor * bootstrapMaxIterations){    
            mexPrintf("\t Terminating bootstrap. Number of iterations has exceeded %d x bootstrapMaxIterations\n", bootstrapUpperLimitFactor);
            mxFree(counter);
            mxFree(oldCounter);
            return;
        }
        
        update_histogram_with_combination(statistics, histogramCount, combinations, detStat, lengthProbabilities);
        
        increment_counter_by_skip_count(counter, oldCounter, observedTransitCount,
        bootstrapSkipCount, detStat, searchTransitThreshold, lengthSES);

        
         /* Print statements */
        if (debugLevel==1 && printFlag) {
            mexPrintf("\t iteration # %1.1e\t", (double)localLoop);
            mexPrintf("\t counter:\t");
            for(j=0; j<observedTransitCount; ++j)
            {
                mexPrintf("%llu\t", counter[j]);
            }
            mexPrintf("combination = %llu\t", combinations);
            mexPrintf("detStat = %f\n", detStat);
            
        } else if (debugLevel ==2) {
            mexPrintf("\t iteration # %1.1e\t", (double)localLoop);
            mexPrintf("\t counter:\t");
            for(j=0; j<observedTransitCount; ++j)
            {
                mexPrintf("%llu\t", counter[j]);
            }
            mexPrintf("combination = %llu\t", combinations);
            mexPrintf("detStat = %f\n", detStat);
        }
        
    }
    
    
    mxFree(counter);
    mxFree(oldCounter);
    
    *loop = (double)localLoop;
}



/* Functions */

void initialize_counter (unsigned long int *counter, unsigned int observedTransitCount) {
    int i;
    for (i = 0; i < observedTransitCount - 1; i++) {
        counter[i] = 1;
    }
    counter[observedTransitCount - 1] = 0;
}

void increment_counter(unsigned long int *counter, unsigned int observedTransitCount, unsigned long int lengthSES){
    int i, j;
    ++counter[observedTransitCount-1];
    for(i=observedTransitCount-1; i>0; i--){
        if (counter[i]>lengthSES){
            ++counter[i-1];
            for (j=i; j<observedTransitCount; j++){
                counter[j]= counter[j-1];
            }
        }
    }
}

unsigned long long int factorial(unsigned int n) {
    if (n<=20){
        return fact[n];
    }
}

unsigned int unique(unsigned long int *counter, unsigned int observedTransitCount) {
    int i;
    unsigned int k = 1;
    for (i = 0; i < observedTransitCount - 1; i++) {
        if (counter[i] != counter[i + 1]) {
            k++;
        }
    }
    return k;
}


unsigned long int get_combination(unsigned long int *counter, unsigned int observedTransitCount){
    unsigned long int combo = 0;
    int u, *repeat;
    int i = 0, j = 1, r = 0;
    unsigned long long int denominatorFact;
    u = unique(counter, observedTransitCount);
    repeat = mxCalloc(u, sizeof(int));
    if (repeat == NULL){
        mexPrintf("\t Unable to allocate memory for repeat.\n");
        return;
    }

    while (i < observedTransitCount - 1) {
        if (counter[i] == counter[i + 1]) {
            j++;
            i++;
        } else {
            repeat[r] = j;
            r++;
            i++;
            j = 1;
        }
    }
    repeat[r] = j;
    denominatorFact = factorial(repeat[0]);
    for (i = 1; i < u; i++) {
        denominatorFact = factorial(repeat[i]) * denominatorFact;
    }
    combo = factorial(observedTransitCount) / denominatorFact;
    mxFree(repeat);
    return combo;
    
}

double compute_detection_statistics(unsigned long int *counter, unsigned int observedTransitCount,
        double *SES_numerator, double *SES_denominator) {
    int i;
    double numeratorTotal = 0.0, denominatorTotal = 0.0, MES;

    for (i = 0; i < observedTransitCount; i++) {
        numeratorTotal += SES_numerator[ counter[i] - 1];
        denominatorTotal += pow(SES_denominator[counter[i] - 1], 2);
    }

    MES = numeratorTotal / sqrt(denominatorTotal);
    return MES;
}

void update_histogram_with_combination(double *statistics, double *histogramCount,
        unsigned long int combination, double detStat, int lengthProbabilities) {
    int i;
    for (i = lengthProbabilities - 1; i >= 0; i--) {
        if (detStat >= statistics[i]) {
            histogramCount[i] += combination;
            break;
        }
    }
}

void increment_counter_by_skip_count(unsigned long int *counter, unsigned long int *oldCounter,
        unsigned int observedTransitCount, unsigned long int bootstrapSkipCount, double detStat,
        double searchTransitThreshold, unsigned long int lengthSES) {
    int i;
    if (detStat >= searchTransitThreshold) {
        counter[observedTransitCount - 1] += bootstrapSkipCount;
    } else {
        for (i = 1; i < observedTransitCount; i++) {
            if (oldCounter[i] == lengthSES) {
                counter[i - 1] = lengthSES;
            }
        }
        counter[observedTransitCount - 1] = lengthSES;
    }
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    /* Declare variables */ 
    double searchTransitThreshold;
    unsigned long int bootstrapSkipCount;
    unsigned int observedTransitCount;
    unsigned long int lengthSES;
    double *SES_numerator, *SES_denominator;
    double *loop;
    unsigned long long int bootstrapMaxIterations;
    int bootstrapUpperLimitFactor;
    
    mwSize mRows, nColumns;
    double *statistics, *histogramCount;
    int lengthProbabilities;
    int debugLevel;
    
    /* Check number of input  and output arguments */
    if (nrhs != 10)
        mexErrMsgTxt("Wrong number of input arguments: 9 required");
    
    if (nlhs != 2)
        mexErrMsgTxt("Wrong number of output arguments: 2 required");
    
    searchTransitThreshold = mxGetScalar(prhs[0]);
    bootstrapSkipCount = mxGetScalar(prhs[1]);
    observedTransitCount = mxGetScalar(prhs[2]);
    lengthSES = mxGetScalar(prhs[3]);
    SES_numerator = mxGetPr(prhs[4]);
    SES_denominator = mxGetPr(prhs[5]);
    statistics = mxGetPr(prhs[6]);
    lengthProbabilities = mxGetM(prhs[6]);
    debugLevel = mxGetScalar(prhs[7]);
    bootstrapMaxIterations = mxGetScalar(prhs[8]);
    bootstrapUpperLimitFactor = mxGetScalar(prhs[9]);
    
    /* Get length of statistics*/
    mRows = mxGetM(prhs[6]);
    nColumns = 1;
    
    plhs[0] = mxCreateDoubleMatrix(mRows, nColumns, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    histogramCount = mxGetPr(plhs[0]);
    loop = mxGetPr(plhs[1]);
    
    /* Call bootstrap */
    bootstrap(searchTransitThreshold, bootstrapSkipCount, observedTransitCount, lengthSES,
    SES_numerator, SES_denominator, statistics, debugLevel, bootstrapMaxIterations, bootstrapUpperLimitFactor, lengthProbabilities, histogramCount, loop);
    
}
