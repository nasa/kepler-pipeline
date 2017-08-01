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
#ifdef __linux__
#include <omp.h>
#endif
#include <stdio.h>
#include <gmp.h>
#include <math.h>
#include <stdlib.h>

/* Usage: mex -g bootstrap.c*/

/* Function  declarations */
static void initialize_counter(unsigned long int *counter, unsigned long int nTransits);

static int increment_counter(unsigned long int *counter, unsigned long int nTransits, unsigned long int lengthSES);

static void get_combination(unsigned long int *counter, unsigned long int nTransits, mpz_t *combination);

static unsigned int unique(unsigned long int *counter, unsigned long int nTransits);

static double compute_detection_statistics(unsigned long int *counter, unsigned long int nTransits,
        double *correlationTimeSeries, double *normalizationTimeSeries, unsigned long int startIndex,
        double *partialSumNumerator, double *partialSumDenominator, int partialSumUpdateLevel);

static void update_histogram_with_combination(double *statistics, mpz_t *histogramCount,
        mpz_t *combination, double detStat, int nStatistics);

static void increment_counter_by_skip_count(unsigned long int *counter, unsigned long int *oldCounter,
        unsigned long int nTransits, unsigned int skipCount, double detStat,
        double bootstrapThreshold, unsigned long int lengthSES);

static unsigned int generate_histogram_counts( unsigned long int lengthSES, double *iterations, unsigned long int nTransits,
        unsigned long int startIndex, double *correlationTimeSeries, double *normalizationTimeSeries, 
        int upperLimitFactor, double maxIterations, int nStatistics, double *statistics,
        unsigned int skipCount, mpz_t *histogramCount, double bootstrapThreshold, unsigned int pulseNum, int debugLevel);

static double is_histogram_smooth(mpz_t *histogramCount, double threshold, 
        double *statistics, int nStatistics, unsigned int pulseNum);

static void compute_probabilities_pulse(double *probabilitiesPulse, mpz_t *histogramCount, unsigned long int lengthSES, 
        unsigned long int nTransits, int nStatistics, unsigned int skipCount);

static void compute_probabilities_combined(double *probabilitiesCombined, mpz_t *histogramCount, unsigned long int *lengthSES, 
        unsigned long int nTransits, int nStatistics, int nPulses);


/* printf macro since mexPrintf is not thread safe */
#ifdef __linux__
static omp_lock_t* lock; 
static void init_lock() {
    lock = malloc( sizeof(omp_lock_t) );
    omp_init_lock( lock );
}
static void lock_thread() {
    omp_set_lock( lock );
}
static int unlock_thread( int safeReturnValue ) {
    omp_unset_lock( lock );
    return safeReturnValue;
}

#define mt_printf(fmt,...) \
	  ( lock_thread(), \
	  unlock_thread( printf((fmt), __VA_ARGS__)) )
      
#define mt_printf_na(fmt) \
	  ( lock_thread(), \
	  unlock_thread( printf((fmt))) )
#else

#define mt_printf printf
#define mt_printf_na printf

#endif

/* Main function */
void bootstrap(double threshold, double lowerMarginSigma, unsigned int* skipCountArray,
        unsigned long int nTransits, unsigned long int* lengthSES, double* correlationTimeSeries,
        double* normalizationTimeSeries, double* statistics, int debugLevel, 
        double maxIterations, int upperLimitFactor, 
        unsigned long int* startIndices, unsigned int* pulseOrder, float* pulseDurations, 
        double* nIterationsArray, int nStatistics, int nPulses, double* probabilitiesPulse,
        double* probabilitiesCombined, double* iterations, double* finalSkipCount,
        double* isHistSmooth) {
      
    
    /* Declare variables */
    int i,iPulse,jPulse,iSkipCount, abortFlag;
    double bootstrapThreshold, histSmooth;
    unsigned int skipCount, haveCounts;
    unsigned long int startIndex = 0;    
    mpz_t *histogramCount;
    
    histogramCount = calloc(nPulses*nStatistics, sizeof(mpz_t));
    if (histogramCount == NULL){
        mt_printf_na("\t Unable to allocate memory for histogramCount.\n");
        return;
    }
    
    for(iPulse = 0; iPulse < nPulses; iPulse++){
        for(i = 0; i < nStatistics; i++){
             mpz_init(histogramCount[iPulse*nStatistics + i]);
         }    
    }
    
     
    
    /************************* CHECK INPUTS ******************************/
    /*mexPrintf("threshold=%f\n",threshold);
    mexPrintf("lowerMarginSigma=%f\n",lowerMarginSigma);
    mexPrintf("nTransits=%lu\n",nTransits);
    mexPrintf("debugLevel=%d\n",debugLevel);
    mexPrintf("maxIterations=%llu\n",maxIterations);
    mexPrintf("upperLimitFactor=%d\n",upperLimitFactor);
    mexPrintf("nStatistics=%d\n",nStatistics);
    mexPrintf("nPulses=%d\n",nPulses);
    
    mexPrintf("skipCountArray:\n");
    for(i=0;i<nPulses;i++){
        mexPrintf("\t %u \t %u \t %u \n",skipCountArray[i],skipCountArray[i+nPulses],skipCountArray[i+2*nPulses]);   
    }
    mexPrintf("lengthSES: \t startIndices: \t pulseOrder: \t pulseDurations: \n");
    for(i=0;i<nPulses;i++){
        mexPrintf("\t %lu \t %lu \t %u \t %f \n",lengthSES[i], startIndices[i], pulseOrder[i], pulseDurations[i]);   
    }*/
    /*********************************************************************/
    
    bootstrapThreshold = threshold - lowerMarginSigma;
    abortFlag = 0;
    
#ifdef __linux__
    init_lock();
#endif

#pragma omp parallel shared(correlationTimeSeries, normalizationTimeSeries, threshold, \
lowerMarginSigma, skipCountArray, nTransits, lengthSES, statistics, debugLevel, maxIterations, \
upperLimitFactor, startIndices, pulseOrder, pulseDurations, nIterationsArray, nStatistics, \
nPulses, probabilitiesPulse, iterations, finalSkipCount, isHistSmooth, abortFlag, histogramCount, \
bootstrapThreshold, lock) \
private(iPulse, iSkipCount, histSmooth, skipCount, haveCounts, startIndex)
	{
#pragma omp for
    
    for(iPulse = 0; iPulse < nPulses; iPulse++){
       
        startIndex = startIndices[iPulse];
        startIndex--; /* convert to 0-base */
        isHistSmooth[iPulse] = 0.0;
        iSkipCount = 2;
        haveCounts = 0;
        histSmooth = 0;
        skipCount = 0;
        
        #pragma omp flush(abortFlag)
        
        if(abortFlag == 0){
            
            /*#pragma omp flush(abortFlag)*/    
            
            while( ((int)histSmooth == 0 ) && (abortFlag == 0) ) { 

                skipCount = skipCountArray[iPulse + iSkipCount*nPulses];
                iterations[iPulse] = nIterationsArray[iPulse + iSkipCount*nPulses];
                
                mt_printf("Bootstrapping pulse %2u of %f hrs with skipCount=%u and estimated #Iterations=%f\n",
                    pulseOrder[iPulse], pulseDurations[iPulse], skipCount, iterations[iPulse]);
                
                haveCounts = generate_histogram_counts( lengthSES[iPulse], iterations+iPulse+nPulses, 
                    nTransits, startIndex, correlationTimeSeries, normalizationTimeSeries, 
                    upperLimitFactor, maxIterations, nStatistics, statistics, skipCount, 
                    histogramCount + iPulse*nStatistics, bootstrapThreshold, pulseOrder[iPulse], debugLevel );

                if( haveCounts == 0){
                    histSmooth = 1.0;
                    abortFlag = 1;
                    #pragma omp flush(abortFlag)
                }
                if( haveCounts != 0){
                    /* check for histogram smoothness */
                    histSmooth = is_histogram_smooth(histogramCount + iPulse*nStatistics, bootstrapThreshold, 
                        statistics, nStatistics, pulseOrder[iPulse]);
                    isHistSmooth[iPulse] = histSmooth;

                    if( iSkipCount == 0 ){
                        histSmooth = 1.0;
                    }           
                    if( (int)histSmooth == 1) {
                       compute_probabilities_pulse(probabilitiesPulse + iPulse*nStatistics, histogramCount + iPulse*nStatistics, 
                           lengthSES[iPulse], nTransits, nStatistics, skipCount);

                       finalSkipCount[iPulse] = skipCount;
                    }  
                    if( ((int)histSmooth == 0) && (iSkipCount != 0) ){
                        iSkipCount--;
                        mt_printf("Histogram generated for pulse %u of %f hrs with skipCount=%u not smooth.  Lowering skipCount.\n",
                            pulseOrder[iPulse], pulseDurations[iPulse], skipCount); 
                    }
                }
                
                /*#pragma omp flush(abortFlag)*/

            } /* while( isHistSmooth[iPulse ... */ 
            
        } /* if(abortFlag==0) */
        
    } /* for(iPulse... */

} /* end of parallelization block */

    if( abortFlag == 1 ){
        for(jPulse = 0; jPulse < nPulses; jPulse++){
            for(i = 0; i < nStatistics; i++){
                mpz_clear(histogramCount[jPulse*nStatistics + i]);
            }
        }
        free( histogramCount );
        return;
    }
    
    /* combine counts for full histogram */
    compute_probabilities_combined(probabilitiesCombined, histogramCount, lengthSES, 
        nTransits, nStatistics, nPulses);
    
     /* clear histogramCount */
    for(jPulse = 0; jPulse < nPulses; jPulse++){
        for(i = 0; i < nStatistics; i++){
            mpz_clear(histogramCount[jPulse*nStatistics + i]);
        }
    }
    free( histogramCount );
    
} /* end main function */



/* Private Functions */

void initialize_counter (unsigned long int *counter, unsigned long int nTransits){
    int i;
    for (i = 0; i < nTransits - 1; i++) {
        counter[i] = 1;
    }
    counter[nTransits - 1] = 0;
}

void initialize_partial_sums(double correlationTimeSeriesMax, double normalizationTimeSeriesMax,
            unsigned long int nTransits, double *partialSumNumerator, double *partialSumDenominator){
    int i;
    if (nTransits > 2){
        partialSumNumerator[0] = 2.0 * correlationTimeSeriesMax;
        partialSumDenominator[0] = 2.0 * normalizationTimeSeriesMax;
        for (i = 1; i < nTransits - 2; i++) {
            partialSumNumerator[i] = partialSumNumerator[i-1] + correlationTimeSeriesMax;
            partialSumDenominator[i] = partialSumDenominator[i-1] + normalizationTimeSeriesMax;
        } 
    }
    else {
        partialSumNumerator = NULL;
        partialSumDenominator = NULL;
    }
}

int increment_counter(unsigned long int *counter, unsigned long int nTransits, 
        unsigned long int lengthSES){
    int i, j, k;
    int partialSumUpdateLevel;
    partialSumUpdateLevel = -1;
    k = 0;
    ++counter[nTransits-1];
    if (nTransits > 2){
        for(i=nTransits-1; i>0; i--){
            if (counter[i]>lengthSES){
                ++counter[i-1];
                if ( (i-2) > 0 ){
                    k = i - 2;
                } else {
                    k = 0;
                }
                partialSumUpdateLevel = k;
                for (j=i; j<nTransits; j++){
                    counter[j]= counter[j-1];
                }
            }
        }
    }
    else {
        for(i=nTransits-1; i>0; i--){
            if (counter[i]>lengthSES){
                ++counter[i-1];
                for (j=i; j<nTransits; j++){
                    counter[j]= counter[j-1];
                }
            }
        }
    }
    return partialSumUpdateLevel;
}

void increment_counter_by_skip_count(unsigned long int *counter, unsigned long int *oldCounter,
        unsigned long int nTransits, unsigned int skipCount, double detStat,
        double bootstrapThreshold, unsigned long int lengthSES) {
    int i;
    if (detStat >= bootstrapThreshold) {
        counter[nTransits - 1] += skipCount;
    } else {
        for (i = 1; i < nTransits; i++) {
            if (oldCounter[i] == lengthSES) {
                counter[i - 1] = lengthSES;
            }
        }
        counter[nTransits - 1] = lengthSES;
    }
}

unsigned int unique(unsigned long int *counter, unsigned long int nTransits) {
    int i;
    unsigned int k = 1;
    for (i = 0; i < nTransits - 1; i++) {
        if (counter[i] != counter[i + 1]) {
            k++;
        }
    }
    return k;
}

void get_combination(unsigned long int *counter, unsigned long int nTransits, mpz_t *combination){
    mpz_t denominatorFact;
    mpz_t tempFactorial;
    int u;
    unsigned long int *repeat;
    int i = 0, j = 1, r = 0;
    u = unique(counter, nTransits);
    
    mpz_init(denominatorFact);
    mpz_init(tempFactorial);
    
    repeat = calloc(u, sizeof(unsigned long));
    if (repeat == NULL){
        mt_printf_na("\t Unable to allocate memory for repeat.\n");
        return;
    }

    while (i < nTransits - 1) {
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
    mpz_fac_ui(denominatorFact, repeat[0]);
    for (i = 1; i < u; i++) {
        mpz_fac_ui(tempFactorial, repeat[i]);
        mpz_mul(denominatorFact,tempFactorial,denominatorFact);
    }
    mpz_fac_ui(tempFactorial,nTransits);
    mpz_cdiv_q(*combination,tempFactorial,denominatorFact);
    mpz_clear(tempFactorial);
    mpz_clear(denominatorFact); 
    free(repeat);
}

double compute_detection_statistics(unsigned long int *counter, unsigned long int nTransits,
        double *correlationTimeSeries, double *normalizationTimeSeries, unsigned long int startIndex,
        double *partialSumNumerator, double *partialSumDenominator, int partialSumUpdateLevel) {
    int i;
    double numeratorTotal = 0.0, denominatorTotal = 0.0, MES = 0.0;
    
    if (nTransits < 3){
        for (i = 0; i < nTransits; i++) {
            numeratorTotal += correlationTimeSeries[startIndex + counter[i] - 1];
            denominatorTotal += normalizationTimeSeries[startIndex + counter[i] - 1];
        }
    } else {
    
        /* check if any partial sums need updated */
        if (partialSumUpdateLevel != -1){
            for (i=partialSumUpdateLevel; i < nTransits - 2; i++){
                if (i==0){
                    partialSumNumerator[i] = correlationTimeSeries[startIndex + counter[0] - 1] + correlationTimeSeries[startIndex + counter[1] - 1] ;
                    partialSumDenominator[i] = normalizationTimeSeries[startIndex + counter[0] - 1] + normalizationTimeSeries[startIndex + counter[1] - 1] ;
                } else {
                    partialSumNumerator[i] = partialSumNumerator[i-1] + correlationTimeSeries[startIndex + counter[i+1] - 1];
                    partialSumDenominator[i] = partialSumDenominator[i-1] + normalizationTimeSeries[startIndex + counter[i+1] - 1];
                }
            }
        }
        numeratorTotal = partialSumNumerator[nTransits - 3] + correlationTimeSeries[startIndex + counter[nTransits - 1] - 1];
        denominatorTotal = partialSumDenominator[nTransits - 3] + normalizationTimeSeries[startIndex + counter[nTransits - 1] - 1];
    }

    MES = numeratorTotal / sqrt(denominatorTotal);
    return MES;
}

void update_histogram_with_combination(double *statistics, mpz_t *histogramCount,
        mpz_t *combination, double detStat, int nStatistics) {
    int i;
    for (i = nStatistics - 1; i >= 0; i--) {
        if (detStat >= statistics[i]) {
            mpz_add(histogramCount[i],histogramCount[i],*combination);
            break;
        }
    }
}

unsigned int generate_histogram_counts( unsigned long int lengthSES, double *iterations, unsigned long int nTransits,
    unsigned long int startIndex, double *correlationTimeSeries, double *normalizationTimeSeries, 
    int upperLimitFactor, double maxIterations, int nStatistics, double *statistics,
    unsigned int skipCount, mpz_t *histogramCount, double bootstrapThreshold, unsigned int pulseNum, int debugLevel ) {
    
    /* declare variables */
    int j;
    double detStat;
    unsigned long long int printFlag, everyIteration = 50000000;
    unsigned long int *counter, *oldCounter;
    unsigned long long int localLoop = 0;
    mpz_t *combination;
    double *partialSumNumerator;
    double *partialSumDenominator;
    int partialSumUpdateLevel = -1;
   
    /* allocate memory */
    counter = calloc(nTransits, sizeof(unsigned long int));
    if (counter == NULL){
        mt_printf_na("\t Unable to allocate memory for counter.\n");
        return 0;
    }
    oldCounter = calloc(nTransits, sizeof(unsigned long int));
    if (oldCounter == NULL){
        mt_printf_na("\t Unable to allocate memory for oldCounter.\n");
        return 0;
    }
    combination = calloc(1,sizeof(mpz_t));
    if (combination == NULL){
        mt_printf_na("\t Unable to allocate memory for combination.\n");
        return 0;
    }
    
    /* only store partial sums if nTransits > 2 */
    if (nTransits > 2){
        partialSumNumerator = calloc(nTransits - 2, sizeof(double));
        if (partialSumNumerator == NULL){
            mt_printf_na("\t Unable to allocate memory for partial sum.\n");
            return 0;
        }
        partialSumDenominator = calloc(nTransits - 2, sizeof(double));
        if (partialSumDenominator == NULL){
            mt_printf_na("\t Unable to allocate memory for partial sum.\n");
            return 0;
        }
    }
   
    mpz_init(*combination);
    initialize_counter(counter, nTransits);
    initialize_partial_sums(correlationTimeSeries[startIndex], normalizationTimeSeries[startIndex],
            nTransits, partialSumNumerator, partialSumDenominator);
    
    while(counter[0] < lengthSES){
        
        localLoop++;
        printFlag = (0 == localLoop % everyIteration);
        for (j = 0; j < nTransits; j++){
            oldCounter[j]=counter[j];
        }

        partialSumUpdateLevel = increment_counter(counter, nTransits, lengthSES);
        get_combination(counter, nTransits, combination);
 
        detStat = compute_detection_statistics(counter, nTransits, correlationTimeSeries, 
                normalizationTimeSeries, startIndex, partialSumNumerator, partialSumDenominator, partialSumUpdateLevel);

        /*if (detStat <= statistics[0]){ break;}*/

        if ((double)localLoop > upperLimitFactor * maxIterations){  
            mt_printf("\t Terminating bootstrap for pulse number %2u. Number of iterations has exceeded %d x bootstrapMaxIterations\n", pulseNum, upperLimitFactor);
            free(counter);
            free(oldCounter);
            mpz_clear(*combination);
            free(combination);
            free(partialSumNumerator);
            free(partialSumDenominator);
            /*histogramCount = NULL;*/
            return 0;
        }

        update_histogram_with_combination(statistics, histogramCount, combination, detStat, nStatistics);

        increment_counter_by_skip_count(counter, oldCounter, nTransits,
            skipCount, detStat, bootstrapThreshold, lengthSES);
        

        if (debugLevel==1 && printFlag) {
            mt_printf("\t iteration # %1.1e\t", (double)localLoop);
            mt_printf_na("\t counter:\t");
            for(j=0; j<nTransits; ++j)
            {
                mt_printf("%llu\t", counter[j]);
            }
            long int sizeCombination = 0;
            char *combinationOut;
            sizeCombination = 2*mpz_sizeinbase(*combination,10) + 1;
            combinationOut = (char *)malloc(sizeCombination);
            gmp_snprintf(combinationOut,sizeCombination,"%Zd\n",combination);
            mt_printf("combination = %s\t", combinationOut);
            mt_printf("detStat = %f\n", detStat);
            free(combinationOut);

        } else if (debugLevel ==2) {
            mt_printf("\t iteration # %1.1e\t", (double)localLoop);
            mt_printf_na("\t counter:\t");
            for(j=0; j<nTransits; ++j)
            {
                mt_printf("%llu\t", counter[j]);
            }
            long int sizeCombination = 0;
            char *combinationOut;
            sizeCombination = 2*mpz_sizeinbase(*combination,10) + 1;
            combinationOut = (char *)malloc(sizeCombination);
            gmp_snprintf(combinationOut,sizeCombination,"%Zd\n",combination);
            mt_printf("combination = %s\t", combinationOut);
            mt_printf("detStat = %f\n", detStat);
            free(combinationOut);
        }

    } /* while(counter */

    *iterations = (double)localLoop;
    
    mpz_clear(*combination);    
    free(counter);
    free(oldCounter);
    free(combination);
    free(partialSumNumerator);
    free(partialSumDenominator);
    
    return 1;    
}


double is_histogram_smooth(mpz_t *histogramCount, double threshold, 
        double *statistics, int nStatistics, unsigned int pulseNum) {
    
    int i, thresholdIndex, maxCountIndex, decreaseFlag, cmpFlag, cmpFlag2;
    mpz_t tempCount;
    double isHistSmooth;
    
    thresholdIndex = 0;
    maxCountIndex = 0;
    decreaseFlag = 1;
    cmpFlag = 0;
    cmpFlag2 = 0;
    mpz_init(tempCount);    
    isHistSmooth = 0.0;
    
    /* check that the max counts is at the bin corresponding to the threshold */
    for(i = 0; i < nStatistics; i++) {
        if( (statistics[i] >= threshold) && (thresholdIndex == 0) ){
            thresholdIndex = i;
        }
        cmpFlag = mpz_cmp(histogramCount[i],tempCount);
        if( cmpFlag > 0) {
            maxCountIndex = i;
            mpz_set(tempCount,histogramCount[i]);
        }
    }
    
    /* check that the vicinity of tail max is decreasing */
    for(i = maxCountIndex; i < nStatistics; i++) {
        cmpFlag = mpz_cmp_ui( histogramCount[i], 0 );
        cmpFlag2 = mpz_cmp(histogramCount[i], tempCount);
        if((cmpFlag != 0) && (cmpFlag2 > 0)) {
            decreaseFlag = 0;    
        }
        if( cmpFlag != 0 ) {
            mpz_set(tempCount, histogramCount[i]);
        }
    }
    
    if( (decreaseFlag == 1) && (thresholdIndex == maxCountIndex) ){
        isHistSmooth = 1.0;    
    }
    
    if( decreaseFlag == 0 ){
        mt_printf("Pulse number %2u histogram tail does not decrease uniformly\n", pulseNum); 
    }
    if( thresholdIndex != maxCountIndex ){
        mt_printf("Pulse number %2u bin with highest counts not commensurate with threshold\n", pulseNum);
        mt_printf("Pulse number %2u threshold = %f \t maxBin = %f \t thresholdIndex = %d \t maxCountIndex = %d \n", pulseNum, threshold, statistics[maxCountIndex], thresholdIndex, maxCountIndex);
    }
    mpz_clear(tempCount);
    return isHistSmooth;
}

void compute_probabilities_pulse(double *probabilitiesPulse, mpz_t *histogramCount, unsigned long int lengthSES, 
        unsigned long int nTransits, int nStatistics, unsigned int skipCount) {
    int i;
    /* allocate storage for denominator and result */
    mpz_t denominator;
    mpf_t numeratorFloat;
    mpf_t denominatorFloat;
    mpf_t probFloat;
    
    mpz_init(denominator);
    mpf_init(numeratorFloat);
    mpf_init(denominatorFloat);
    mpf_init(probFloat);
    
    skipCount++;
    
    mpz_ui_pow_ui(denominator, lengthSES, nTransits);
    for (i = 0; i < nStatistics; i++ ) {
        mpz_mul_ui(histogramCount[i],histogramCount[i],skipCount);
        mpf_set_z(numeratorFloat,histogramCount[i]);
        mpf_set_z(denominatorFloat,denominator);
        mpf_div(probFloat,numeratorFloat,denominatorFloat);
        probabilitiesPulse[i] = mpf_get_d(probFloat);
    }
    
    mpz_clear(denominator);
    mpf_clear(numeratorFloat);
    mpf_clear(denominatorFloat);
    mpf_clear(probFloat);
}

void compute_probabilities_combined(double *probabilitiesCombined, mpz_t *histogramCount, unsigned long int *lengthSES, 
    unsigned long int nTransits, int nStatistics, int nPulses) {
    
    int iStats, iPulse;
    /* allocate storage for denominator and result */
    mpz_t denominator;
    mpz_t denominatorPulse;
    mpz_t histogramCountSum[nStatistics];
    mpf_t numeratorFloat;
    mpf_t denominatorFloat;
    mpf_t probFloat;
    
    mpz_init(denominator);
    mpz_init(denominatorPulse);
    mpf_init(numeratorFloat);
    mpf_init(denominatorFloat);
    mpf_init(probFloat);
    for(iStats = 0; iStats < nStatistics; iStats++ ) {
        mpz_init(histogramCountSum[iStats]);
    }
     
    /* add up all the permutations for denominator and all the counts in each bin, skipCounts were adjusted for already */
    for( iPulse = 0; iPulse < nPulses; iPulse++) {
        mpz_ui_pow_ui(denominatorPulse, lengthSES[iPulse], nTransits);
        mpz_add( denominator, denominator, denominatorPulse);
        for (iStats = 0; iStats < nStatistics; iStats++ ) {
            mpz_add(histogramCountSum[iStats],histogramCountSum[iStats],histogramCount[iPulse*nStatistics+iStats]);
        }
    }
    
    /* divide counts by permutations to get probabilities */
    for (iStats = 0; iStats < nStatistics; iStats++ ) {
        mpf_set_z(numeratorFloat,histogramCountSum[iStats]);
        mpf_set_z(denominatorFloat,denominator);
        mpf_div(probFloat,numeratorFloat,denominatorFloat);
        probabilitiesCombined[iStats] = mpf_get_d(probFloat);
    }
    
    mpz_clear(denominator);
    mpz_clear(denominatorPulse);
    mpf_clear(numeratorFloat);
    mpf_clear(denominatorFloat);
    mpf_clear(probFloat);
    for(iStats = 0; iStats < nStatistics; iStats++ ) {
        mpz_clear(histogramCountSum[iStats]);
    }
    
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    /* Declare variables */ 
    double threshold, lowerMarginSigma;
    unsigned long int nTransits;
    unsigned long long int maxIterations;
    int upperLimitFactor, debugLevel;
    
    /* Declare pointers */
    double *correlationTimeSeries, *normalizationTimeSeries;
    double *iterations, *statistics, *probabilitiesPulse, *nIterationsArray;
    double *probabilitiesCombined, *finalSkipCount, *isHistSmooth;
    unsigned int *skipCountArray, *pulseOrder;
    unsigned long int *lengthSES, *startIndices;
    float *pulseDurations;
    
    
    /* declare matlab typed variables */
    mwSize nColumns, nStatistics, nPulses, mColumns;
    
    /*	arguments for the squaring of the normalization  */	
	mxArray *normSquaredArray[1] ;
	mxArray *squaringRhs[2] ;

    /* Check number of input  and output arguments */
    if (nrhs != 15)
        mexErrMsgTxt("Wrong number of input arguments: 15 required");
    
    if (nlhs != 5)
        mexErrMsgTxt("Wrong number of output arguments: 5 required");
    
    /* Parse the inputs */
    threshold = mxGetScalar(prhs[0]);
    lowerMarginSigma = mxGetScalar(prhs[1]);
    skipCountArray = (unsigned int *)mxGetPr(prhs[2]);
    nTransits = mxGetScalar(prhs[3]);
    lengthSES = (unsigned long int *)mxGetPr(prhs[4]);
    correlationTimeSeries = mxGetPr(prhs[5]);
    squaringRhs[0] = prhs[6] ;
    statistics = mxGetPr(prhs[7]);
    debugLevel = mxGetScalar(prhs[8]);
    maxIterations = mxGetScalar(prhs[9]);
    upperLimitFactor = mxGetScalar(prhs[10]);
    startIndices = (unsigned long int *)mxGetPr(prhs[11]);
    pulseOrder = (unsigned int *)mxGetPr(prhs[12]);
    pulseDurations = (float *)mxGetPr(prhs[13]);
    nIterationsArray = mxGetPr(prhs[14]);
    
    /*mexPrintf("threshold=%f\n",threshold);
    mexPrintf("lowerMarginSigma=%f\n",lowerMarginSigma);
    mexPrintf("skipCountArray=%u\n",skipCountArray[15]);
    mexPrintf("nTransits=%lu\n",nTransits);
    mexPrintf("lengthSES=%lu\n",lengthSES[0]);
    mexPrintf("debugLevel=%d\n",debugLevel);
    mexPrintf("maxIterations=%llu\n",maxIterations);
    mexPrintf("upperLimitFactor=%d\n",upperLimitFactor);
    mexPrintf("startIndices=%lu\n",startIndices[0]);
    mexPrintf("pulseOrder=%u\n",pulseOrder[0]);
    mexPrintf("pulseDurations=%f\n",pulseDurations[0]);*/
    
     /* vector-square the normalization time series (which is arg 2)  */
	squaringRhs[1] = mxCreateDoubleScalar(2.0) ;
	mexCallMATLAB(1,normSquaredArray,2,squaringRhs,"power") ;
    normalizationTimeSeries = mxGetPr(normSquaredArray[0]) ;
    
    /* get other needed info from inputs */
    nStatistics = mxGetM(prhs[7]);
    nPulses = mxGetM(prhs[13]);
    nColumns = 1;
    mColumns = 2;
    
    plhs[0] = mxCreateDoubleMatrix(nStatistics, nPulses, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nStatistics, nColumns, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(nPulses, mColumns, mxREAL);
    plhs[3] = mxCreateDoubleMatrix(nPulses, nColumns, mxREAL);
    plhs[4] = mxCreateDoubleMatrix(nPulses, nColumns, mxREAL);
    
    probabilitiesPulse = mxGetPr(plhs[0]);
    probabilitiesCombined = mxGetPr(plhs[1]);
    iterations = mxGetPr(plhs[2]);
    finalSkipCount = mxGetPr(plhs[3]);
    isHistSmooth = mxGetPr(plhs[4]);
        
    /* Call bootstrap */
    bootstrap( threshold, lowerMarginSigma, skipCountArray, nTransits, lengthSES, correlationTimeSeries, 
            normalizationTimeSeries, statistics, debugLevel, maxIterations, upperLimitFactor,
            startIndices, pulseOrder, pulseDurations, nIterationsArray, nStatistics, nPulses,
            probabilitiesPulse, probabilitiesCombined, iterations, finalSkipCount, isHistSmooth );
    
}
