function [trapezoidalModelFitData] = detrend_with_in_transit_data_ungapped(dvDataObject, trapezoidalModelFitData)
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

gapIndicators       = trapezoidalModelFitData.detrendInputs.gapIndicators;
fluxValues          = trapezoidalModelFitData.detrendInputs.fluxValues(~gapIndicators);
cadenceNumbers      = dvDataObject.dvCadenceTimes.cadenceNumbers(~gapIndicators);
quarters            = dvDataObject.dvCadenceTimes.quarters(~gapIndicators);

newFluxValues       = ones(size(fluxValues));
smoothLightCurve    = ones(size(fluxValues));

for i = 1:length(trapezoidalModelFitData.quarters.quarterNumber)
    
    currentQuarter              = trapezoidalModelFitData.quarters.quarterNumber(i);
    indexCurrentQuarter         = find( quarters == currentQuarter );
   
    xVector                     = ( 1 : length(indexCurrentQuarter) )';               
    fluxValuesCurrentQuarter    = fluxValues(indexCurrentQuarter);                    
    
    linearModelCurrentQuarter   = polyval(polyfit(xVector, fluxValuesCurrentQuarter, 1), xVector);
    fluxValuesNormalized        = fluxValuesCurrentQuarter ./ linearModelCurrentQuarter;

    fluxValuesMedianFiltered        = 1 + medfilt1_soc(fluxValuesNormalized - 1, trapezoidalModelFitData.detrendParameters.medianFilterLength);                                              
    [ignored, smoothingParameter]   = smoothn(fluxValuesMedianFiltered, ones(size(fluxValuesMedianFiltered)),  [], 'TolZ', 1e-6, 'MaxIter', 500, 'robust');        
 
    filterCircularShift = round(trapezoidalModelFitData.detrendParameters.filterCircularShift);
    smoothingParameter  = ( var( diff( circshift(fluxValuesNormalized, filterCircularShift) ) ) / var( diff(fluxValuesMedianFiltered) ) ) * smoothingParameter; 
    
    if isnan(smoothingParameter) || ~isfinite(smoothingParameter)
        
        display(' ');
        display(['Warning: @dvDataClass/detrend_with_in_transit_data_ungapped : calculated smoothingParameter is NaN or infinite for Quarter #' num2str(currentQuarter) '. Set to default smoothingParameter.']);
        display(' ');
        
        trapezoidalModelFitData.quarters.smoothingParameter(i) = trapezoidalModelFitData.detrendParameters.defaultSmoothingParameter;
        
    else
        
        trapezoidalModelFitData.quarters.smoothingParameter(i) = smoothingParameter;
        
    end

    cadenceNumbersCurrentQuarter    = cadenceNumbers(indexCurrentQuarter);
    indexGaps                       = find( diff(cadenceNumbersCurrentQuarter) > trapezoidalModelFitData.detrendParameters.gapThreshold );      
    if ( ~isempty(indexGaps) )
        
        indexGapsStart = [ 1;          indexGaps + 1                        ];
        indexGapsEnd   = [ indexGaps;  length(cadenceNumbersCurrentQuarter) ];
        
        trapezoidalModelFitData.quarters.gaps(i).startCadence = cadenceNumbersCurrentQuarter(indexGapsStart);
        trapezoidalModelFitData.quarters.gaps(i).endCadence   = cadenceNumbersCurrentQuarter(indexGapsEnd);
        
        
        for j = 1 : ( length(indexGaps) + 1 )
            
            indexCurrentSection                     = indexGapsStart(j) : indexGapsEnd(j);
            fluxValuesNormalizedCurrentSection      = fluxValuesNormalized(indexCurrentSection);
            fluxValuesSmoothedCurrentSection        = ...
                smoothn(fluxValuesNormalizedCurrentSection, ones(size(fluxValuesNormalizedCurrentSection)), smoothingParameter, 'TolZ', 1.0e-6, 'MaxIter', 500, 'robust'); 
            
            indexInfinite                                               = isnan(fluxValuesSmoothedCurrentSection) | ~isfinite(fluxValuesSmoothedCurrentSection);
            if sum(indexInfinite) > 0
            
                display(' ');
                display(['Warning: @dvDataClass/detrend_with_in_transit_data_ungapped : ' num2str(sum(indexInfinite)) ...
                         ' NaNs/infinite numbers were identified in smoothed flux values in Quarter #' num2str(currentQuarter) ' Section #' num2str(j) ' of length ' num2str(length(indexCurrentSection)) ...
                         '. Set to original flux values.']);
                display(' ');
                
                fluxValuesSmoothedCurrentSection(indexInfinite)         = fluxValuesNormalizedCurrentSection(indexInfinite);
                
            end
            
            smoothLightCurve(indexCurrentQuarter(indexCurrentSection))  = linearModelCurrentQuarter(indexCurrentSection) .* fluxValuesSmoothedCurrentSection;
            newFluxValues(indexCurrentQuarter(indexCurrentSection))     = fluxValuesCurrentQuarter(indexCurrentSection)  ./ smoothLightCurve(indexCurrentQuarter(indexCurrentSection));
            
        end
        
    else
        
        trapezoidalModelFitData.quarters.gaps(i).startCadence = cadenceNumbersCurrentQuarter(1);
        trapezoidalModelFitData.quarters.gaps(i).endCadence   = cadenceNumbersCurrentQuarter(end);

        
        fluxValuesSmoothed  = smoothn(fluxValuesNormalized, ones(size(fluxValuesNormalized)), smoothingParameter, 'TolZ', 1e-6, 'MaxIter', 500, 'robust');               
        
        indexInfinite                           = isnan(fluxValuesSmoothed) | ~isfinite(fluxValuesSmoothed);
        if sum(indexInfinite) > 0
            
            display(' ');
            display(['Warning: @dvDataClass/detrend_with_in_transit_data_ungapped : ' num2str(sum(indexInfinite)) ...
                     ' NaNs/infinite numbers were identified in smoothed flux values in Quarter #' num2str(currentQuarter) ' of length ' num2str(length(indexCurrentQuarter)) ...
                     '. Set to original flux values.']);
            display(' ');
                
            fluxValuesSmoothed(indexInfinite) = fluxValuesNormalized(indexInfinite);
               
        end
        
        smoothLightCurve(indexCurrentQuarter)  = linearModelCurrentQuarter .* fluxValuesSmoothed;
        newFluxValues(indexCurrentQuarter)     = fluxValuesCurrentQuarter  ./ smoothLightCurve(indexCurrentQuarter);
        
    end

end
                                                                
trapezoidalModelFitData.intermediateDetrendOutputs.newFluxValuesInTransitDataNotGapped    = newFluxValues;
trapezoidalModelFitData.intermediateDetrendOutputs.smoothLightCurveInTransitDataNotGapped = smoothLightCurve;

return
