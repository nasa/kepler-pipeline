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

/*	all-in-one function which is tailored, via conditional compilation, 
	to operate in several different use-cases with acceptable maintainability
	and performance */



void fold_time_series( 
/*	input parameters */
	double* correlationTimeSeries, double* normalizationTimeSeries, int nCadences, 
	double* periodInCadences, int nPeriods, double phaseLagOrStepInCadences, 
	int minSesCount, double mesHistogramMinBin, double mesHistogramMaxBin, 
        double mesHistogramBinSize, int nBins,
/*	output parameters */
	double* multipleEventStatistic, double* maxMes, double* minMes, 
	double* maxMesPhaseLagCadences, double* minMesPhaseLagCadences, 
	double* phaseLagCadences, int* nTransits, int* numSesInMes, 
	double* indexOfSesInMes, double* sesCombinedToYieldMes, 
    double* meanMesEstimate, double* validPhaseSpaceFraction, double* mesHistogram)
{
/*	local variables */
	int iPeriod, nPhases, nValidPhases ;
	double fPeriod, currentPhaseLag ;
	double mesForMinMax, mes ;
	int kk, iLag, nTransitsLocal, nSesLocal ;
	double num, den, cadenceNumber ;
	double initialPhaseInCadences, phaseStepInCadences ;

#ifdef FOLD_ALL_PERIODS_ALL_PHASES
        
    unsigned long long int *mesHistogramCounts ;
	unsigned long long int nHistPoints ;
	int histIndex, iHist ;

    nHistPoints = 0;
	histIndex = 0;
	iHist = 0;

 /* allocate mesHistogramCounts */

	mesHistogramCounts = calloc(nBins, sizeof(unsigned long long int));
	if(mesHistogramCounts == NULL)
	{
	  printf("\t Unable to allocate memory for mesHistogramCounts.\n");
	  return;
	}

	for(iHist = 0; iHist < nBins; iHist++)
	{
	    mesHistogramCounts[iHist] = 0 ;
	}

#endif
	
/*	define the variables which are shared and private to each thread; as a general matter,
 * 	argument variables are shared, local variables private */

/*	we only want to parallelize the folding across all periods, all phases; we can do that
 * 	with an ifdef around each of the OMP pragmas */

#ifdef FOLD_ALL_PERIODS_ALL_PHASES

#pragma omp parallel shared(correlationTimeSeries, normalizationTimeSeries, nCadences, \
periodInCadences, nPeriods, phaseLagOrStepInCadences, minSesCount, \
multipleEventStatistic, maxMes, minMes, maxMesPhaseLagCadences, minMesPhaseLagCadences, \
phaseLagCadences, nTransits, numSesInMes, indexOfSesInMes, sesCombinedToYieldMes, mesHistogramCounts, \
mesHistogramMinBin, mesHistogramBinSize, nBins, meanMesEstimate, validPhaseSpaceFraction) \
private(iPeriod, fPeriod, currentPhaseLag, mesForMinMax, mes, kk, num, den, cadenceNumber, \
iLag, nTransitsLocal, nSesLocal, initialPhaseInCadences, phaseStepInCadences, histIndex, nPhases, nValidPhases) \
reduction(+:nHistPoints)

#endif

	{
		
/*		depending on what kind of folding we are doing, we will want to initialize the
 * 		variables for the initial phase and the phase step differently.  For all-periods,
 * 		all-phases or one-period, all-phases, we want to go from an initial phase of 0
 * 		in steps of the caller-specified phase step. */
		
#ifdef FOLD_ALL_PERIODS_ALL_PHASES
			initialPhaseInCadences = 0.0 ;
			phaseStepInCadences    = phaseLagOrStepInCadences ;
#endif
			
#ifdef FOLD_ONE_PERIOD_ALL_PHASES
			initialPhaseInCadences = 0.0 ;
			phaseStepInCadences    = phaseLagOrStepInCadences ;
#endif
			
/*		if we are doing one-period, one-phase folding, then the initial phase should be
 * 		the user-specifed phase, and the step should be large compared to the period so 
 * 		that when the loop "advances" the phase step, the second step is already past the
 * 		limits of the loop. */
			
#ifdef FOLD_ONE_PERIOD_ONE_PHASE
			initialPhaseInCadences = phaseLagOrStepInCadences ;
			phaseStepInCadences    = periodInCadences[0] + 1.0 ;
#endif
	
#ifdef FOLD_ALL_PERIODS_ALL_PHASES
			
	#pragma omp for
			
#endif

	for (iPeriod=0 ; iPeriod <nPeriods ; iPeriod++)
	{
/*		if we are doing all phases across all periods, then we want to capture the max
 * 		and min MES at each period; so in this case initialize the variables which will
 * 		be used for that capture */

#ifdef FOLD_ALL_PERIODS_ALL_PHASES

/*		for all-periods, all-phases, initialize the this-period accumulators of max and
 * 		min MES, and the corresponding lag values */

		maxMes[iPeriod] = -10000000.0 ;
		minMes[iPeriod] =  10000000.0 ;
		maxMesPhaseLagCadences[iPeriod] = -1.0 ;
		minMesPhaseLagCadences[iPeriod] = -1.0 ;
        meanMesEstimate[iPeriod] = 0;
        validPhaseSpaceFraction[iPeriod] = -1.0;
        nPhases = 0;
        nValidPhases = 0;
#endif
		
#ifdef FOLD_ONE_PERIOD_ALL_PHASES
		
/*		if we are doing one-period, all-phases, initialize the lag counter to zero, since
 * 		we need to return MES vs lag # and phase vs lag # */
		
		iLag = 0 ;
#endif
		fPeriod = periodInCadences[iPeriod] ; 
		
/*		loop over phase lags.  Note that, if we are doing one phase at one period, then
 * 		after the increment by period+1, currentPhaseLag will exceed fPeriod and thus
 * 		this "loop" will execute only once */
		
		for (currentPhaseLag = initialPhaseInCadences ;
			 currentPhaseLag < fPeriod ;
			 currentPhaseLag += phaseStepInCadences)
		{
#ifdef FOLD_ONE_PERIOD_ALL_PHASES

/*			for one-period, all-phases, set the current phase lag into the accumulator */

			phaseLagCadences[iLag] = currentPhaseLag ;
#endif
			num            = 0.0 ;
			den            = 0.0 ;
			nSesLocal      = 0 ;
			nTransitsLocal = 0 ;
			
			for (cadenceNumber = currentPhaseLag ;
				 cadenceNumber <= (nCadences - 1) ;
				 cadenceNumber += fPeriod)
			{
				
/*				set the index pointer into the arrays to the nearest whole number of
 * 				cadences */
				
				kk = (int)(cadenceNumber+0.5) ;
				
/*				if we are returning the vectors of SES values and locations, then 
 * 				initialize the current location to -1 */

#ifdef FOLD_ONE_PERIOD_ONE_PHASE

/*				for one-period, one-phase, initialize the index of the SES value */

				if (indexOfSesInMes != NULL)
				{
					indexOfSesInMes[nTransitsLocal] = -1.0 ; 
				}
#endif
				
/*				increment the numerator and denominator components of the MES */

				num += correlationTimeSeries[kk] ;
				den += normalizationTimeSeries[kk] ;
				
/*				if this cadence isn't gapped, filled, or otherwise excused from the
 * 				MES, set the SES value in the vector provided (if necessary), and
 * 				increment the # SES in MES counter */

				if (correlationTimeSeries[kk] != 0 || normalizationTimeSeries[kk] != 0)
				{
#ifdef FOLD_ONE_PERIOD_ONE_PHASE

/*					for one-period, one-phase folding, capture the location of the current
 * 					SES-in-MES, and its value */

					if (indexOfSesInMes != NULL)
					{
						indexOfSesInMes[nTransitsLocal] = (double)(kk) ;
						/*sesCombinedToYieldMes[nSesLocal] = 
						correlationTimeSeries[kk] / sqrt( normalizationTimeSeries[kk] ) ; */
                        sesCombinedToYieldMes[nTransitsLocal] = 
						correlationTimeSeries[kk] / sqrt( normalizationTimeSeries[kk] ) ; 
					}
#endif
					nSesLocal++ ; 
				}
                
#ifdef FOLD_ONE_PERIOD_ONE_PHASE                
                if (correlationTimeSeries[kk] == 0 && normalizationTimeSeries[kk] == 0)
				{

/*					for one-period, one-phase folding, capture the location of the current
 * 					SES-in-MES, and its value */

					if (indexOfSesInMes != NULL)
					{
						indexOfSesInMes[nTransitsLocal] = (double)(kk) ;
						/*sesCombinedToYieldMes[nSesLocal] = 
						correlationTimeSeries[kk] / sqrt( normalizationTimeSeries[kk] ) ; */
                        sesCombinedToYieldMes[nTransitsLocal] = 0;
					}
				}
#endif
                
#ifdef FOLD_ONE_PERIOD_ONE_PHASE

/*				for one-period, one-phase folding, increment the index into the array of
 * 				transit locations */

				nTransitsLocal++ ;
#endif
				
			} /* end of loop over cadences */
            
			den = sqrt(den) ;
			mes = num / den ;
			
/*			if there are too few transits, we want MES -> 0 for both the all-periods
 * 			all-phases and one-period all-phases cases */

			if (nSesLocal < minSesCount) 
			{
				mes = 0 ;
			} 

#ifdef FOLD_ALL_PERIODS_ALL_PHASES

/*                      capture the mes for the histogram if it was not set to zero */

            if ( mes != 0 )
			{
			    histIndex = (int) ( (mes - mesHistogramMinBin) / mesHistogramBinSize ) ;
			    nHistPoints++ ;

			    if ( histIndex >= 0 && histIndex < nBins )
			    {
			        #pragma omp atomic
			        mesHistogramCounts[histIndex]++ ;
			    }
                
                nValidPhases++ ;
                meanMesEstimate[iPeriod] += den ;
			}

/*			for all-periods, all-phases folding, latch the current MES value and its
 * 			phase if this is a min or max value.  Note that for this purpose we want
 * 			to use MES == 0 instead of MES == NaN */

			if (den == 0)
			{
				mes = 0 ;
			}
			if (mes > maxMes[iPeriod])
			{
				maxMes[iPeriod] = mes ;
				maxMesPhaseLagCadences[iPeriod] = currentPhaseLag ;
			}
			if (mes < minMes[iPeriod])
			{
				minMes[iPeriod] = mes ;
				minMesPhaseLagCadences[iPeriod] = currentPhaseLag ;
			}
            
            nPhases++ ;

#endif

#ifdef FOLD_ONE_PERIOD_ALL_PHASES

/*			for one-period, all-phases, capture the value of MES at this phase */

			multipleEventStatistic[iLag] = mes ; 

/*			for one-period, all-phases folding, increment the phase counter */

			iLag ++ ; 
#endif

		} /* end of loop over phases */
        
#ifdef FOLD_ALL_PERIODS_ALL_PHASES

        if( nValidPhases != 0 )
        {
            meanMesEstimate[iPeriod] = meanMesEstimate[iPeriod] / nValidPhases ;
        }
        if( nPhases != 0 )
        {
            validPhaseSpaceFraction[iPeriod] = (double) nValidPhases / nPhases ;
        }
        
#endif
                
		
	} /* end of loop over periods */
		
	} /* end of parallel block */


/*      get the normalized histogram */

#ifdef FOLD_ALL_PERIODS_ALL_PHASES

	for( iHist = 0; iHist < nBins; iHist++ )
	{
	  mesHistogram[iHist] = ((double)mesHistogramCounts[iHist]) / nHistPoints ;
	}

        free(mesHistogramCounts) ;

#endif
	
#ifdef FOLD_ONE_PERIOD_ONE_PHASE

/*	if we are doing one period, one phase, then we can now set the return variables
 *	 */
	
	*multipleEventStatistic = mes ;
	*nTransits              = nTransitsLocal ;
	*numSesInMes            = nSesLocal ;
#endif	 
	
	
} /* end of function */
					
					
