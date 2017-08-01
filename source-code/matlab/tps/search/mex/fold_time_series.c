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

/* fold_time_series.c -- library functions for performing folding of single 
   event statistics into multiple event statistics.  This file contains 3 functions:
   -> fold_one_period_one_phase:  folds the time series at a selected period and phase
   -> fold_one_period_all_phases:  folds the time series at a selected period across
         all phases, returning a vector of phase offsets and a vector of MES values
   -> fold_all_periods_all_phases:  folds the time series at all periods and all phases,
         returning a vector of MES values (one at each period, the max at that period)
         and a vector of phase lags (one at each period); actually, both max and min are
         returned.
   These functions are used by the TPS mexfiles, and the code is located here and organized
   in this manner so that there is one, and only one, folder which is consistently used by
   all users which need MES information.  */ 

#include <math.h>
#include <omp.h>
#include <stdio.h>
#include "fold_time_series.h"

/*	lowest level functionality is to perform one folding, at a specified phase lag and
 *	period.  If the caller sends in arrays to contain the locations and values of the SES
 *	combined into the MES, these will be filled as well.  Note that the caller is responsible
 *	for making sure that the arrays for this purpose are large enough to hold all the values. */

void fold_one_period_one_phase( 
/*	input parameters */
	double correlationTimeSeries[], double normalizationTimeSeries[], int nCadences, 
	double periodInCadences, double phaseLagInCadences, 
/*	output parameters */
	double* multipleEventStatistic, int* numTransits, int* numSesInMes, double indexOfSesInMes[], 
	double sesCombinedInMes[] )
{
  
	int kk, iTransit ;
	double num, den, cadenceNumber ;
  
		*numSesInMes = 0 ; 
		*numTransits = 0 ;
		num = 0.0 ; den = 0.0 ;

/*		loop over cadences -- note that here cadenceNumber can be fractional, but kk,
 *		which is the actual cadence index to use, must be the nearest integer */

		for ( cadenceNumber = phaseLagInCadences ;
			 cadenceNumber <= (nCadences - 1.0) ;
			cadenceNumber += periodInCadences )
		{
			kk = (int)(cadenceNumber+0.5) ;
/*			initialize the current value of indexOfSesInMes to -1  */
			if (indexOfSesInMes != NULL) {
				 indexOfSesInMes[*numTransits] = -1 ;
			 }
/*			increment the values of numerator and denominator portions of the MES */ 
		 
			num += correlationTimeSeries[kk] ;
			den += normalizationTimeSeries[kk] ;
		 
/*			if this cadence isn't gapped, filled, or fully deweighted, increment
 *			the numSesInMes counter, and fill the current SES value if the return
 *			arrays are defined */
		 
			if ( correlationTimeSeries[kk] != 0 || normalizationTimeSeries[kk] != 0)
			{
				if (indexOfSesInMes != NULL) {
					indexOfSesInMes[*numTransits] = (double)(kk) ;
				}
				if (sesCombinedInMes != NULL) {
					sesCombinedInMes[*numSesInMes] = 
					correlationTimeSeries[kk] / sqrt( normalizationTimeSeries[kk] ) ;
				}
				(*numSesInMes)++ ;
			}
		 
			(*numTransits)++ ;
		 
		} /* end of for-loop */

/*		compute and return the multiple event statistic */

		*multipleEventStatistic = num / sqrt( den ) ;
	     
    
} /* end of fold_one_period_one_phase function */

/*=================================================================================*/
/*=================================================================================*/
/*=================================================================================*/

/*	next level of functionality is to perform folding at one period but across all phases,
 *	returning a vector of phase lags, a vector of MES values, max MES, max MES lag,
 *	min MES, min MES lag */

void fold_one_period_all_phases( 
/*  input parameters */
	double correlationTimeSeries[], double normalizationTimeSeries[], int nCadences, 
	double periodInCadences, double phaseStepInCadences,
	int minSesCount, 
/*  output parameters */
	double multipleEventStatistic[], double phaseLagInCadences[], double* maxMes, 
	double* minMes, double* maxMesLagCadences, double* minMesLagCadences )
{
	
	int iLag, numSesInMes, numTransits ;
	double mes, mesForMinMax, currentPhaseLag ;
	double localMaxMes, localMinMes, localMaxMesLagCadences, localMinMesLagCadences ;
    

/*		initialize */

		localMaxMes = -10000000.0 ;
		localMinMes =  10000000.0 ;
		localMaxMesLagCadences = -1.0 ;
		localMinMesLagCadences = -1.0 ;
		iLag = -1 ;
	
/*		loop over phase lags and compute the MES at each value */

		for ( currentPhaseLag = 0 ;
			 currentPhaseLag < periodInCadences ;
			currentPhaseLag += phaseStepInCadences )
		{
			iLag += 1 ;
			if (phaseLagInCadences != NULL) {
				phaseLagInCadences[iLag] = currentPhaseLag ;
			}
			
			fold_one_period_one_phase( correlationTimeSeries, normalizationTimeSeries, 
				nCadences, periodInCadences, currentPhaseLag, &mes, &numTransits, &numSesInMes, 
				NULL, NULL ) ;

/*			if the MES is NaN, or if the # of SES in MES is too small, treat it as zero
 *			for the purposes of latching max/min values */

			if (isnan(mes) || numSesInMes < minSesCount) {
				mesForMinMax = 0 ;
			}
			else {
				mesForMinMax = mes ;
			}
	     
/*	     now do the comparisons and latching of min/max values */

			if (mesForMinMax > localMaxMes) {
				localMaxMes = mesForMinMax ;
				localMaxMesLagCadences = currentPhaseLag ;
			}
			if (mesForMinMax < localMinMes) {
				localMinMes = mesForMinMax ;
				localMinMesLagCadences = currentPhaseLag ;
			}
	     
/*	     if there's a vector to catch the returned MES, populate it now; note that
 * 	     if MES is NaN, we report it as NaN no matter the value of numSesInMes; however,
 * 	     if numSesInMes < minSesCount, we replace the value with zero */

			if (multipleEventStatistic != NULL) {
				multipleEventStatistic[iLag] = mes ;
				if (numSesInMes < minSesCount) {
					multipleEventStatistic[iLag] = 0 ;
				}
			}
	     
		} /* loop over lags */
	
/*		if there are variables for the min/max MES and their lags, populate now */

		if (maxMes != NULL) {
			*maxMes = localMaxMes ;
		}
		if (minMes != NULL) {
			*minMes = localMinMes ;
		}
		if (maxMesLagCadences != NULL) {
			*maxMesLagCadences = localMaxMesLagCadences ;
		}
		if (minMesLagCadences != NULL) {
			*minMesLagCadences = localMinMesLagCadences ;
		}
	
    
} /* end of function fold_one_period_all_phases */

/*=================================================================================*/
/*=================================================================================*/
/*=================================================================================*/

/*	highest level of functionality -- a loop over all periods, and within that all phases,
 *	looking for the max MES as a function of period. */

/*	NB:  for performance reasons, we have hand-inlined the phase-folder and the
 * 	cadence-folder into this function, and eliminated all extraneous operations.  This
 * 	leaves us with a maintenance nightmare, since there are duplicates of everything!
 * 	Hopefully in the future we will find a better alternative. */

void fold_all_periods_all_phases( 
/*  input parameters:  */
	double correlationTimeSeries[], double normalizationTimeSeries[], int nCadences, 
	double trialPeriodsInCadences[], int nPeriods, double deltaLag, int minSesCount, 
/*  output parameters:  */
	double maxStatistic[], double minStatistic[], double maxStatisticPhaseLagCadences[], 
	double minStatisticPhaseLagCadences[] )

{
	int iPeriod ;
	int numSesInMes, numTransits ;
	double fPeriod, currentPhaseLag ;
	double mesForMinMax, mes ;
	int kk ;
	double num, den, cadenceNumber ;
    
/*	parallelization information  */

#pragma omp parallel shared(correlationTimeSeries, normalizationTimeSeries, nCadences, \
trialPeriodsInCadences, nPeriods, deltaLag, minSesCount, maxStatistic, minStatistic, \
maxStatisticPhaseLagCadences, minStatisticPhaseLagCadences) \
private(iPeriod, fPeriod, currentPhaseLag, numSesInMes, \
mesForMinMax, mes, num, den, kk, cadenceNumber)
	{
#pragma omp for  

        for( iPeriod = 0 ;
	    iPeriod < nPeriods ;
	    iPeriod++ )
		{
			
/*			perform initialization of the period value, and of the array elements which
 * 			capture extreme values and their locations */
			
			fPeriod = trialPeriodsInCadences[iPeriod] ;
			maxStatistic[iPeriod] = -100000000.0 ;
			minStatistic[iPeriod] =  100000000.0 ;
			maxStatisticPhaseLagCadences[iPeriod] = -1.0 ;
			minStatisticPhaseLagCadences[iPeriod] = -1.0 ;
			
/*			fold over phases within this period */
			
			for ( currentPhaseLag = 0 ;
				currentPhaseLag < fPeriod ;
				currentPhaseLag += deltaLag )
			{

/*				perform folding over cadences within this period and phase, and compute
				the cadence-by-cadence contribution to MES */
				
				numSesInMes = 0 ;
				num = 0.0 ; den = 0.0 ;
				for ( cadenceNumber = currentPhaseLag ;
					cadenceNumber <= (nCadences - 1.0) ;
					cadenceNumber += fPeriod )
				{
					kk = (int)(cadenceNumber+0.5) ;
					num += correlationTimeSeries[kk] ;
					den += normalizationTimeSeries[kk] ; 
		 
					if ( correlationTimeSeries[kk] != 0 || normalizationTimeSeries[kk] != 0)
					{
						numSesInMes++ ;
					}
				} 

/*				compute MES and latch extreme values, and their locations */

				mes = num / sqrt(den) ; 
				mesForMinMax = mes ;
				if (den==0 || numSesInMes < minSesCount) {
					mesForMinMax = 0 ;
				} 
				
				if (mesForMinMax > maxStatistic[iPeriod]) {
					maxStatistic[iPeriod] = mesForMinMax ;
					maxStatisticPhaseLagCadences[iPeriod] = currentPhaseLag ;
				}
				
				if (mesForMinMax < minStatistic[iPeriod]) {
					minStatistic[iPeriod] = mesForMinMax ;
					minStatisticPhaseLagCadences[iPeriod] = currentPhaseLag ;
				}
				
			} /* end of inner for-loop */
				
		} /* end of for-loop */
	
	} /* end of parallelization block */
    
} /* end of function fold_all_periods_all_phases */
	    
 
