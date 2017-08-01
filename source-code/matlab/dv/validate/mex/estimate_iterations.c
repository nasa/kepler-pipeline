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
#include <time.h>

/* Function Declarations */
static unsigned long long int determine_sample_size( double meanEstimateTolerance, double mesStd ) ;
static double compute_random_mes( double *correlationTimeSeries, double *normalizationTimeSeries, 
        unsigned int nTransits, unsigned int lengthSES ) ;
static void estimate_mes_distribution_parameters( double *correlationTimeSeries, 
        double *normalizationTimeSeries, unsigned int nTransits, 
        unsigned int lengthSES, unsigned long long int nSamples, 
        double threshold, double *nIterations ) ;

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

/* Main Function */
void estimate_iterations( double* correlationTimeSeries, double* normalizationTimeSeries, 
        int nPulses, unsigned int nTransits, double meanEstimateTolerance, unsigned int* lengthSES,
        double threshold, unsigned int* startIndices, double* nIterations ) {
    
    /* declare variables */
    int iPulse;
    unsigned long long int nSamples;
    double mesStd;
    
    /* initialize variables */
    iPulse = 0;
    nSamples = 0;
    mesStd = 1.25; /* just use 1.25 to get an estimate of the sample size needed */
    srand( rand() );
    
    /* determine sample size */
    nSamples = determine_sample_size( meanEstimateTolerance, mesStd ) ;
    
#ifdef __linux__
    init_lock();
#endif
    
#pragma omp parallel shared( lock, nSamples, correlationTimeSeries, normalizationTimeSeries, \
nTransits, lengthSES, nIterations, nPulses ) \
private( iPulse )
    {
#pragma omp for
    
    for(iPulse = 0; iPulse < nPulses; iPulse++){
        
        /* estimate the number of iterations for each pulse */
        estimate_mes_distribution_parameters( correlationTimeSeries, normalizationTimeSeries, 
                nTransits, lengthSES[iPulse], nSamples, threshold, nIterations+iPulse ) ;
    
    } /* end for(iPulse ...) */
} /* end parallel block */
        
} /* end main function */


unsigned long long int determine_sample_size( double meanEstimateTolerance, double mesStd ) {
    
    /* declare */
    double sizeFull ;
    double sigmaMultiplier ;
    unsigned long long int sampleSize;
    
    /* initialize */
    sizeFull = 0.0 ;
    sigmaMultiplier = 6.0 ;
    sampleSize = 0;
    
    /* calculate sample size */
    sizeFull = sigmaMultiplier * mesStd / meanEstimateTolerance ; 
    sizeFull = pow( sizeFull, 2 ) ;
    sampleSize = (unsigned long long int)(sizeFull + 0.5) ;
    
    /* set an upper limit */
    if( sampleSize > 500000000 ){
       sampleSize = 500000000;
       mt_printf("The estimateTolerance of %f results in too many samples.  Setting nSamples = 5e8.\n",meanEstimateTolerance);
    }
    return sampleSize ;
}

double compute_random_mes( double *correlationTimeSeries, 
        double *normalizationTimeSeries, unsigned int nTransits, 
        unsigned int lengthSES) {
    
    /* Declare */
    int i, index ;
    double detStat, numerator, denominator ;
    
    /* Initialize */
    i = 0 ;
    index = 0 ;
    detStat = 0.0 ;
    numerator = 0.0 ;
    denominator = 0.0 ;

    /* compute random detection statistic */
    for(i=0 ; i<nTransits ; i++) {
        /* get a random index */
        index = (int) (rand() % (lengthSES + 1)) ;
        numerator += correlationTimeSeries[index] ;
        denominator += normalizationTimeSeries[index] ;
    }
    detStat = numerator / sqrt(denominator) ;
    return detStat;
}

void estimate_mes_distribution_parameters( double *correlationTimeSeries, 
        double *normalizationTimeSeries, unsigned int nTransits, 
        unsigned int lengthSES, unsigned long long int nSamples, 
        double threshold, double *nIterations ) {
    
    /* declare */
    unsigned long long int i ;
    double mes, mesSum, mesSumSq, mesMean, mesStd, probability;
    mpz_t nPermutations;
    mpf_t nPermutationsFloat;
    mpf_t mpProbability;
    
    /* initialize */
    i = 0;
    mes = 0.0;
    mesSum = 0.0;
    mesSumSq = 0.0;
    mesMean = 0.0;
    mesStd = 0.0;
    probability = 0.0;
    mpz_init(nPermutations);
    mpf_init(nPermutationsFloat);
    mpf_init(mpProbability);
    
    srand( rand() );
    
    /* estimate MES mean and std by random sampling */
    for (i = 0 ; i < nSamples ; i++ ){

        mes = compute_random_mes( correlationTimeSeries, normalizationTimeSeries,
                nTransits, lengthSES) ;
        mesSum += mes ;
        mesSumSq += mes * mes ;
    }
    
    mesMean = mesSum / nSamples ;
    mesStd = mesSumSq / (nSamples - 1) - pow(mesMean,2.0) ;
    mesStd = sqrt(mesStd) ;
    
    /* compute the number of permutations in multiple precision */
    mpz_ui_pow_ui(nPermutations, (unsigned long int)lengthSES, (unsigned long int)nTransits);

    /* convert from MP integer to MP double */
    mpf_set_z( nPermutationsFloat, nPermutations );

    /* compute probability that mes is above threshold */
    probability = erfcl( (threshold - mesMean) / (mesStd * sqrt(2.0)) ) ; 

    /* convert double to MP */
    mpf_set_d(mpProbability, probability);

    /* multiply probability by nPermutations */
    mpf_mul(mpProbability, mpProbability, nPermutationsFloat);    
    *nIterations = mpf_get_d(mpProbability);
    *nIterations = *nIterations * 0.5;

    /* clear arbitrary precision variables */
    mpf_clear(nPermutationsFloat);
    mpf_clear(mpProbability);
    mpz_clear(nPermutations);
    
}





/* Gateway Function */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    double *correlationTimeSeries, *normalizationTimeSeries ;
    double *nIterations ;
    double meanEstimateTolerance, threshold ;
    unsigned int nTransits ;
    unsigned int *lengthSES, *startIndices;
    
    /* declare matlab typed variables */
    mwSize nColumns, nPulses ;
    
    /* Initialize */
    nTransits = 0 ;
    meanEstimateTolerance = 0.0 ;
    threshold = 0.0 ;
    nColumns = 1;
    nPulses = 0;
    
    /*	arguments for the squaring of the normalization  */	
	mxArray *normSquaredArray[1] ;
	mxArray *squaringRhs[2] ;
    
    /* Check number of input  and output arguments */
    if (nrhs != 7)
        mexErrMsgTxt("Wrong number of input arguments: 7 required");
    
    if (nlhs != 1)
        mexErrMsgTxt("Wrong number of output arguments: 1 required");
    
    /* extract inputs */
    threshold = mxGetScalar( prhs[0] ) ;
    nTransits = (unsigned int)(mxGetScalar( prhs[1] )) ;
    lengthSES = (unsigned int *)mxGetPr(prhs[2]);
    correlationTimeSeries = mxGetPr( prhs[3] ) ;
    startIndices = (unsigned int *)mxGetPr(prhs[5]);
    meanEstimateTolerance = mxGetScalar( prhs[6] ) ;
    nPulses = mxGetM(prhs[2]);
    
    /*  vector-square the normalization time series (which is arg 2)  */
	squaringRhs[0] = prhs[4] ;
	squaringRhs[1] = mxCreateDoubleScalar(2.0) ;
	mexCallMATLAB(1,normSquaredArray,2,squaringRhs,"power") ;
    normalizationTimeSeries = mxGetPr(normSquaredArray[0]) ;
    
    /*  perform assignments of double pointers  */
    plhs[0] = mxCreateDoubleMatrix(nPulses, nColumns, mxREAL);
    nIterations = mxGetPr( plhs[0] ) ;

    estimate_iterations( correlationTimeSeries, normalizationTimeSeries, nPulses, nTransits, 
            meanEstimateTolerance, lengthSES, threshold, startIndices, nIterations ) ;
     
} /* End gateway function */
