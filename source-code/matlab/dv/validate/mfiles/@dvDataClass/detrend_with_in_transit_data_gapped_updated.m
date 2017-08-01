function [trapezoidalModelFitData] = detrend_with_in_transit_data_gapped_updated(dvDataObject, trapezoidalModelFitData)
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
fluxValues              = trapezoidalModelFitData.detrendInputs.fluxValues(~gapIndicators);
midTimestampsBkjd       = trapezoidalModelFitData.detrendInputs.midTimestampsBkjd(~gapIndicators);
cadenceNumbers          = dvDataObject.dvCadenceTimes.cadenceNumbers(~gapIndicators);
quarters                = dvDataObject.dvCadenceTimes.quarters(~gapIndicators);

epochBkjd               = trapezoidalModelFitData.thresholdCrossingEvent.epochBkjd;
orbitalPeriodDays       = trapezoidalModelFitData.thresholdCrossingEvent.orbitalPeriodDays;
transitDurationHours    = trapezoidalModelFitData.thresholdCrossingEvent.transitDurationHours;
maxMultipleEventSigma   = trapezoidalModelFitData.thresholdCrossingEvent.maxMultipleEventSigma;
ratioDurationToPeriod   = transitDurationHours/24/orbitalPeriodDays;

smoothLightCurve        = trapezoidalModelFitData.intermediateDetrendOutputs.smoothLightCurveInTransitDataGapped;
newFluxValues           = trapezoidalModelFitData.intermediateDetrendOutputs.newFluxValuesInTransitDataGapped;

for i = 1 : length(trapezoidalModelFitData.quarters.quarterNumber)
    
    currentQuarter          = trapezoidalModelFitData.quarters.quarterNumber(i);
    indexCurrentQuarter     = find( quarters == currentQuarter );
    
    if ( trapezoidalModelFitData.quarters.snrEstimate(i) >= trapezoidalModelFitData.detrendParameters.snrThreshold )         
        
        newFluxValuesCurrentQuarter     = newFluxValues(indexCurrentQuarter);
        
        phaseCurrentQuarter             = mod( ( midTimestampsBkjd(indexCurrentQuarter) - epochBkjd ), orbitalPeriodDays ) ./ orbitalPeriodDays;
        indexBuf                        = phaseCurrentQuarter > 0.5;
        phaseCurrentQuarter(indexBuf)   = phaseCurrentQuarter(indexBuf) - 1.0;                                          
       
        [sortedPhaseCurrentQuarter, sortedIndexCurrentQuarter] = sort(phaseCurrentQuarter);

        structBuf.timestamps            = sortedPhaseCurrentQuarter;
        structBuf.values                = newFluxValuesCurrentQuarter(sortedIndexCurrentQuarter);
        structBuf.uncertainties         = ones(size(structBuf.values));
        
        midTimestampsBkjdCurrentQuarter = midTimestampsBkjd(indexCurrentQuarter);
        nTransitsExpected               = floor( (max(midTimestampsBkjdCurrentQuarter) - min(midTimestampsBkjdCurrentQuarter) ) / orbitalPeriodDays );
        if nTransitsExpected < 1
            nTransitsExpected = 1;
        elseif nTransitsExpected > 4
            nTransitsExpected = 4;
        end
        
        bins                                        = sortedPhaseCurrentQuarter(1) : ...
                                                      ratioDurationToPeriod/(0.20*transitDurationHours*nTransitsExpected*log10(max([4.0; maxMultipleEventSigma]))) : ...
                                                      sortedPhaseCurrentQuarter(end);
        phaseMidBins                                = bins(1 : end-1) + 0.5*diff(bins);                      
        [binnedFlux, ignored, binnedGapIndicators]  = bin_ancillary_data(structBuf, bins); 

        
        indexBuf                = find( binnedGapIndicators == 0 );
        phaseMidBins            = phaseMidBins(indexBuf);
        binnedFlux              = binnedFlux(indexBuf);
        
        if sum( isnan(binnedFlux) | ~isfinite(binnedFlux) ) > 0
            error('dv:detrendWithInTransitDataGappedUpdated:NaNs_in_binnedFluxValues', 'NaNs/Infinite numbers found in the binned flux values for the interpolation');
        end
        
        linearModelPhased       = interp1(phaseMidBins, binnedFlux, phaseCurrentQuarter, 'linear', 1.0);
        
        indexInTransit          = find( abs(phaseMidBins) < min( [ratioDurationToPeriod*5.0; 0.2]) ); 
        
        if isempty( indexInTransit )
            
            ratioDurationToPeriodUpdated = ratioDurationToPeriod;
            
        else
            
            phaseMidBinsInTransit  = phaseMidBins(indexInTransit);
            binnedFluxInTransit    = binnedFlux(indexInTransit);
            
            [ignored, minIndex]     = min(binnedFluxInTransit);
            
            inTransitFlagNominal    = abs(phaseCurrentQuarter) < ratioDurationToPeriod / 2.0 * 1.5;
            sigMad                  = 1.4826 * mad(newFluxValuesCurrentQuarter(~inTransitFlagNominal) ./ linearModelPhased(~inTransitFlagNominal) - 1.0,  1);
            
            snrEstimate             = trapezoidalModelFitData.quarters.snrEstimate(i);
            
            j = -1;
            while ( (minIndex+j) > 0 && ...
                    binnedFluxInTransit(minIndex+j)   < 1.0 - sigMad/sqrt(nTransitsExpected)*log2(snrEstimate)  && ...
                    binnedFluxInTransit(minIndex+j)   < 1.0 - 0.075*(1.0-trapezoidalModelFitData.quarters.minDepthPpm(i)./1.0e6) )
                j = j - 1;
            end
            phaseLeftEdge  = phaseMidBinsInTransit(minIndex + j + 1);
            
            j =  1;
            while ( (minIndex+j-1) < length(binnedFluxInTransit) && ...
                    binnedFluxInTransit(minIndex+j-1) < 1.0 - sigMad/sqrt(nTransitsExpected)*log2(snrEstimate)  &&  ...
                    binnedFluxInTransit(minIndex+j-1) < 1.0 - 0.075*(1.0-trapezoidalModelFitData.quarters.minDepthPpm(i)./1.0e6) )
                j = j + 1;
            end
            phaseRightEdge = phaseMidBinsInTransit(minIndex + j - 1);
            
            ratioDurationToPeriodUpdated  = max([ratioDurationToPeriod; phaseRightEdge - phaseLeftEdge]);
            display( sprintf('Old Duration to Period Ratio:    %f      Updated Duration to Period Ratio:    %f', ratioDurationToPeriod, ratioDurationToPeriodUpdated));
            
        end
        
        phaseOffset = trapezoidalModelFitData.quarters.phaseOffset(i);
        epochBkjdUpdated = epochBkjd + phaseOffset * orbitalPeriodDays;
        display( sprintf('Phase Offset:    %f      Old Epoch (BKJD):    %f      New Epoch (BKJD):    %f', phaseOffset, epochBkjd, epochBkjdUpdated) );    
        trapezoidalModelFitData.quarters.epochBkjd(i)               = epochBkjdUpdated;
        trapezoidalModelFitData.quarters.transitDurationHours(i)    = ratioDurationToPeriodUpdated * orbitalPeriodDays * 24.0;
        
        
        phaseCurrentQuarter             = mod( midTimestampsBkjdCurrentQuarter - epochBkjdUpdated, orbitalPeriodDays ) ./ orbitalPeriodDays;
        indexBuf                        = phaseCurrentQuarter > 0.5;
        phaseCurrentQuarter(indexBuf)   = phaseCurrentQuarter(indexBuf) - 1.0;                                          
    
  
        inTransitFlagNominal            = abs(phaseCurrentQuarter) < ratioDurationToPeriodUpdated / 2.0 * 1.5;                         

        xVector                         = (1 : length(indexCurrentQuarter))';                            
        fluxValuesCurrentQuarter        = fluxValues(indexCurrentQuarter);                               
        cadenceNumbersCurrentQuarter    = cadenceNumbers(indexCurrentQuarter);   

        linearModelCurrentQuarter       = polyval( polyfit(xVector(~inTransitFlagNominal), fluxValuesCurrentQuarter(~inTransitFlagNominal), 1), xVector );
        fluxValuesNormalized            = fluxValuesCurrentQuarter ./ linearModelCurrentQuarter;
        
        roughMad                        = 1.4826 * mad( fluxValuesNormalized(~inTransitFlagNominal) );  
        suspiciousDataFlag              = abs( 1.0 - fluxValuesNormalized ) > 4.0*roughMad;          
        indexBuf                        = find( ~inTransitFlagNominal & ~suspiciousDataFlag );
        
        fluxValuesNormalizedCleaned     = fluxValuesNormalized(indexBuf);
        if sum( isnan(fluxValuesNormalizedCleaned) | ~isfinite(fluxValuesNormalizedCleaned) ) > 0
            error('dv:detrendWithInTransitDataGappedUpdated:NaNs_in_normalizedFluxValues', 'NaNs/Infinite numbers found in the normalized flux values for the interpolation');
        end

        fluxValuesNormalized            = interp1( xVector(indexBuf), fluxValuesNormalizedCleaned, xVector, 'linear', 1.0 );
        
        nSections = length(trapezoidalModelFitData.quarters.gaps(i).startCadence);
        if nSections > 1
        
            for j = 1 : nSections
                
                indexCurrentSection                     = find( cadenceNumbersCurrentQuarter >= trapezoidalModelFitData.quarters.gaps(i).startCadence(j) & ...
                                                                cadenceNumbersCurrentQuarter <= trapezoidalModelFitData.quarters.gaps(i).endCadence(j) );
                fluxValuesNormalizedCurrentSection      = fluxValuesNormalized(indexCurrentSection);
                fluxValuesSmoothedCurrentSection        = smoothn(fluxValuesNormalizedCurrentSection, real(~inTransitFlagNominal(indexCurrentSection)), ...
                                                              trapezoidalModelFitData.quarters.smoothingParameter(i), 'TolZ', 1.0e-6, 'MaxIter', 500, 'robust');

                indexInfinite                                               = isnan(fluxValuesSmoothedCurrentSection) | ~isfinite(fluxValuesSmoothedCurrentSection);
                if sum(indexInfinite) > 0
            
                    display(' ');
                    display(['Warning: @dvDataClass/detrend_with_in_transit_data_gapped_updated : ' num2str(sum(indexInfinite)) ...
                             ' NaNs/infinite numbers were identified in smoothed flux values in Quarter #' num2str(currentQuarter) ' Section #' num2str(j) ' of length ' num2str(length(indexCurrentSection)) ...
                             '. Set to original flux values.']);
                    display(' ');
                
                    fluxValuesSmoothedCurrentSection(indexInfinite)         = fluxValuesNormalizedCurrentSection(indexInfinite);
                
                end
                                                        
                smoothLightCurve(indexCurrentQuarter(indexCurrentSection))  = linearModelCurrentQuarter(indexCurrentSection) .* fluxValuesSmoothedCurrentSection;
                newFluxValues(indexCurrentQuarter(indexCurrentSection))     = fluxValuesCurrentQuarter(indexCurrentSection)  ./ ...
                                                                                smoothLightCurve(indexCurrentQuarter(indexCurrentSection));
               
            end
            
        else
            
            fluxValuesSmoothed  = smoothn(fluxValuesNormalized, real(~inTransitFlagNominal), ...
                                            trapezoidalModelFitData.quarters.smoothingParameter(i), 'TolZ', 1e-6, 'MaxIter', 500, 'robust');                        

            indexInfinite                           = isnan(fluxValuesSmoothed) | ~isfinite(fluxValuesSmoothed);
            if sum(indexInfinite) > 0
            
                display(' ');
                display(['Warning: @dvDataClass/detrend_with_in_transit_data_gapped_updated : ' num2str(sum(indexInfinite)) ...
                         ' NaNs/infinite numbers were identified in smoothed flux values in Quarter #' num2str(currentQuarter) ' of length ' num2str(length(indexCurrentQuarter)) ...
                         '. Set to original flux values.']);
                display(' ');
                
                fluxValuesSmoothed(indexInfinite)   = fluxValuesNormalized(indexInfinite);
               
            end

            smoothLightCurve(indexCurrentQuarter)   = linearModelCurrentQuarter .* fluxValuesSmoothed;
            newFluxValues(indexCurrentQuarter)      = fluxValuesCurrentQuarter  ./ smoothLightCurve(indexCurrentQuarter);
            
        end
        
    end
    
end

trapezoidalModelFitData.intermediateDetrendOutputs.newFluxValuesInTransitDataGappedUpdated    = newFluxValues;
trapezoidalModelFitData.intermediateDetrendOutputs.smoothLightCurveInTransitDataGappedUpdated = smoothLightCurve;

return

