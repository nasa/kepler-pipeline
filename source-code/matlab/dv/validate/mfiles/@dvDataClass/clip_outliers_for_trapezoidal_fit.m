function [trapezoidalModelFitData] = clip_outliers_for_trapezoidal_fit(dvDataObject, trapezoidalModelFitData)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%

gapIndicators           = trapezoidalModelFitData.detrendInputs.gapIndicators;
midTimestampsBjd        = trapezoidalModelFitData.detrendInputs.midTimestampsBkjd(~gapIndicators);
cadenceNumbers          = dvDataObject.dvCadenceTimes.cadenceNumbers(~gapIndicators);
quarters                = dvDataObject.dvCadenceTimes.quarters(~gapIndicators);

epochBkjd               = trapezoidalModelFitData.thresholdCrossingEvent.epochBkjd;
orbitalPeriodDays       = trapezoidalModelFitData.thresholdCrossingEvent.orbitalPeriodDays;
transitDurationHours    = trapezoidalModelFitData.thresholdCrossingEvent.transitDurationHours;
maxMultipleEventSigma   = trapezoidalModelFitData.thresholdCrossingEvent.maxMultipleEventSigma;
ratioDurationToPeriod   = transitDurationHours/24/orbitalPeriodDays;

newFluxValues           = trapezoidalModelFitData.intermediateDetrendOutputs.newFluxValuesInTransitDataGappedUpdated;

trapezoidalModelFitData.detrendOutputs.originalFluxValues     = [];
trapezoidalModelFitData.detrendOutputs.originalTimestampsBkjd = [];
trapezoidalModelFitData.detrendOutputs.newFluxValues          = [];
trapezoidalModelFitData.detrendOutputs.midTimestampsBkjd      = [];
trapezoidalModelFitData.detrendOutputs.cadenceNumbers         = [];
trapezoidalModelFitData.detrendOutputs.currentQuarters        = [];
trapezoidalModelFitData.detrendOutputs.madSigmas              = [];

for i = 1 : length(trapezoidalModelFitData.quarters.quarterNumber)
    
    currentQuarter                  = trapezoidalModelFitData.quarters.quarterNumber(i);
    indexCurrentQuarter             = find( quarters == currentQuarter );
    
    midTimestampsBkjdCurrentQuarter = midTimestampsBjd(indexCurrentQuarter);
    cadenceNumbersCurrentQuarter    = cadenceNumbers(indexCurrentQuarter);
    
    newFluxValuesCurrentQuarter     = newFluxValues(indexCurrentQuarter);
    largeDeviationFlag              = true(size(newFluxValuesCurrentQuarter));
    
    phaseCurrentQuarter             = mod( midTimestampsBkjdCurrentQuarter - epochBkjd, orbitalPeriodDays ) ./ orbitalPeriodDays;
    indexBuf                        = phaseCurrentQuarter > 0.5;
    phaseCurrentQuarter(indexBuf)   = phaseCurrentQuarter(indexBuf) - 1.0;
    
    inTransitFlagNominal            = abs(phaseCurrentQuarter) < ratioDurationToPeriod / 2.0 * 1.5;
    
    [sortedPhaseCurrentQuarter, sortedIndexCurrentQuarter] = sort(phaseCurrentQuarter);
    
    structBuf.timestamps            = sortedPhaseCurrentQuarter;
    structBuf.values                = newFluxValuesCurrentQuarter(sortedIndexCurrentQuarter);
    structBuf.uncertainties         = ones(size(structBuf.values));
    
    nTransitsExpected = floor( (max(midTimestampsBkjdCurrentQuarter) - min(midTimestampsBkjdCurrentQuarter) ) / orbitalPeriodDays );
    if  nTransitsExpected < 1
        nTransitsExpected = 1;
    elseif nTransitsExpected > 4
        nTransitsExpected = 4;
    end
    
    stdSigma                        =          std(newFluxValuesCurrentQuarter(~inTransitFlagNominal) - 1.0);
    madSigma                        = 1.4826 * mad(newFluxValuesCurrentQuarter(~inTransitFlagNominal) - 1.0, 1);
    madSigmaInTransit               = 1.4826 * mad(newFluxValuesCurrentQuarter( inTransitFlagNominal) - 1.0, 1 );

    bins                            = sortedPhaseCurrentQuarter(1) : ...
                                      ratioDurationToPeriod / ( 0.20 * transitDurationHours * nTransitsExpected * log10( max([4.0; maxMultipleEventSigma]) ) ) : ...
                                      sortedPhaseCurrentQuarter(end);
                                  
    if length(bins) > 5
        
        phaseMidBins                    = bins(1 : end-1) + 0.5 * diff(bins);
        [binnedFlux, ignored, binnedGapIndicators]   = bin_ancillary_data(structBuf, bins);
        
        indexBuf                        = find( binnedGapIndicators == 0 & isfinite(binnedFlux) );
        phaseMidBins                    = phaseMidBins(indexBuf);
        binnedFlux                      = binnedFlux(indexBuf);
        
        if sum( isnan(binnedFlux) | ~isfinite(binnedFlux) ) > 0
            error('dv:clipOutliersForTrapezoidalFit:NaNs_in_binnedFluxValues', 'NaNs/Infinite numbers found in the binned flux values for the interpolation');
        end
        
        linearModelPhased              = interp1(phaseMidBins, binnedFlux, phaseCurrentQuarter, 'linear', 1.0);
        
        residualAbsolute                            = abs( newFluxValuesCurrentQuarter - linearModelPhased );
        residualSnr                                 = residualAbsolute ./ madSigma;
        residualSnrInTransit                        = residualAbsolute ./ madSigmaInTransit;
        
        largeDeviationFlag                          = ( residualSnr                       > 4.0 );
        largeDeviationFlag(inTransitFlagNominal)    = ( residualSnr(inTransitFlagNominal) > 8.0 ) & ( residualSnrInTransit(inTransitFlagNominal) > 6.0 ) & ...
                                                      ( residualAbsolute(inTransitFlagNominal) > (abs(trapezoidalModelFitData.quarters.minDepthPpm(i)./1.0e6))/5.0 );
        largeDeviationFlag                          = largeDeviationFlag | ~isfinite(newFluxValuesCurrentQuarter);
        
        display( sprintf( 'Out of transit data uncertainty:    std (ppm): %f    mad (ppm): %f', stdSigma*1.0e6, madSigma*1.0e6 ) );
        trapezoidalModelFitData.quarters.stdSigma(i) = stdSigma;
        trapezoidalModelFitData.quarters.madSigma(i) = madSigma;
        
    end
    
    % Clip out the outliers
    
    trapezoidalModelFitData.detrendOutputs.originalFluxValues     = [ trapezoidalModelFitData.detrendOutputs.originalFluxValues;     newFluxValuesCurrentQuarter     ];
    trapezoidalModelFitData.detrendOutputs.originalTimestampsBkjd = [ trapezoidalModelFitData.detrendOutputs.originalTimestampsBkjd; midTimestampsBkjdCurrentQuarter ];
    
    newFluxValuesCurrentQuarterUpdated                            =   newFluxValuesCurrentQuarter(~largeDeviationFlag);
    trapezoidalModelFitData.detrendOutputs.newFluxValues          = [ trapezoidalModelFitData.detrendOutputs.newFluxValues;       newFluxValuesCurrentQuarterUpdated                              ];
    trapezoidalModelFitData.detrendOutputs.midTimestampsBkjd      = [ trapezoidalModelFitData.detrendOutputs.midTimestampsBkjd;   midTimestampsBkjdCurrentQuarter(~largeDeviationFlag)             ];
    trapezoidalModelFitData.detrendOutputs.cadenceNumbers         = [ trapezoidalModelFitData.detrendOutputs.cadenceNumbers;      cadenceNumbersCurrentQuarter(~largeDeviationFlag)                ];
    trapezoidalModelFitData.detrendOutputs.currentQuarters        = [ trapezoidalModelFitData.detrendOutputs.currentQuarters;     currentQuarter * ones(size(newFluxValuesCurrentQuarterUpdated)) ];
    trapezoidalModelFitData.detrendOutputs.madSigmas              = [ trapezoidalModelFitData.detrendOutputs.madSigmas;           madSigma       * ones(size(newFluxValuesCurrentQuarterUpdated)) ];
    
end

averageEpochBkjd                                        = mean( trapezoidalModelFitData.quarters.epochBkjd(trapezoidalModelFitData.quarters.transitsFlag) );
indexEvents                                             = round( ( trapezoidalModelFitData.detrendOutputs.midTimestampsBkjd - averageEpochBkjd ) ./ orbitalPeriodDays );
trapezoidalModelFitData.detrendOutputs.avarageEpochBkjd = averageEpochBkjd;
trapezoidalModelFitData.detrendOutputs.timeZeroPoint    = averageEpochBkjd + round( median(indexEvents) ) * orbitalPeriodDays;
trapezoidalModelFitData.detrendOutputs.madSigma         = mean( trapezoidalModelFitData.quarters.madSigma(trapezoidalModelFitData.quarters.transitsFlag) );

return
