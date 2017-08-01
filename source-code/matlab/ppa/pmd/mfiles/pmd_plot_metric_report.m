function scaleExponent = pmd_plot_metric_report(metricTs, metricTempData, fixedLowerBound, ...
    fixedUpperBound, timestamps, cadenceGapIndicators, scale)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function scaleExponent = pmd_plot_metric_report(metricTs, metricTempData, fixedLowerBound, ...
%    fixedUpperBound, timestamps, cadenceGapIndicators, scale)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function generates plots of PMD metric time seires.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


if ( isempty(metricTs.values) || length(metricTs.values)~=length(timestamps) )
    return;
end

metricTs.gapIndicators = metricTs.gapIndicators(:) | cadenceGapIndicators(:);

startTime = timestamps(1);
endTime   = timestamps(end);

% Get the time series values and uncertainties, and remove the gaps. Remove
% the gaps from the cadence times as well.
metricValuesRaw             = metricTs.values;
metricGapIndicators         = metricTs.gapIndicators;

metricValuesLevel1          = metricValuesRaw(~metricGapIndicators);
cadenceTimesLevel1          = timestamps(~metricGapIndicators);

% Check the full series against the fixed bounds
isOutOfFixedUpperBound      = (metricValuesLevel1 > fixedUpperBound);
isOutOfFixedLowerBound      = (metricValuesLevel1 < fixedLowerBound);

estimatesGapIndicators      = metricTempData.estimatesGapIndicators;
cadenceTimesLevel2          = timestamps(~estimatesGapIndicators);
metricValuesLevel2          = metricValuesRaw(~estimatesGapIndicators);

metricMeanEstimates         = metricTempData.meanEstimates(~estimatesGapIndicators);
metricUncertaintyEstimates  = metricTempData.uncertaintyEstimates(~estimatesGapIndicators);
adaptiveBoundsXFactor       = metricTempData.adaptiveBoundsXFactor;

adaptiveUpperBounds         = metricMeanEstimates      + adaptiveBoundsXFactor * metricUncertaintyEstimates;
adaptiveLowerBounds         = metricMeanEstimates      - adaptiveBoundsXFactor * metricUncertaintyEstimates;

% Check the full series against the adaptive bounds
isOutOfAdaptiveUpperBound   = (metricValuesLevel2 > adaptiveUpperBounds);
isOutOfAdaptiveLowerBound   = (metricValuesLevel2 < adaptiveLowerBounds);

scaleExponent = 0 ;
if (scale)
    outBounds1 = metricValuesLevel1(isOutOfFixedUpperBound) ;
    outBounds2 = metricValuesLevel1(isOutOfFixedLowerBound) ;
    biggestValue = max(abs([metricValuesLevel2(:) ; ...
                            metricMeanEstimates(:) ; ...
                            adaptiveUpperBounds(:) ; ...
                            adaptiveLowerBounds(:) ; ...
                            outBounds1(:) ; ...
                            outBounds2(:)])) ;
    scaleExponent = floor(log10(biggestValue)) ;
    if (isempty(scaleExponent))
        scaleExponent = 0 ;
    elseif (scaleExponent <= 1 && scaleExponent >= -1)
        scaleExponent = 0 ;
    end
end
scaleFactor = 10^scaleExponent ;
    

hold off
plot(cadenceTimesLevel2 - startTime, metricValuesLevel2/scaleFactor, 'b.-');
hold on
plot(cadenceTimesLevel2 - startTime, metricMeanEstimates/scaleFactor, 'g.-');
plot(cadenceTimesLevel2 - startTime, adaptiveUpperBounds/scaleFactor, 'r.-');
plot(cadenceTimesLevel2 - startTime, adaptiveLowerBounds/scaleFactor, 'r.-');
plot(cadenceTimesLevel2(isOutOfAdaptiveUpperBound) - startTime, ...
    metricValuesLevel2(isOutOfAdaptiveUpperBound)/scaleFactor, 'xr');
plot(cadenceTimesLevel2(isOutOfAdaptiveLowerBound) - startTime, ...
    metricValuesLevel2(isOutOfAdaptiveLowerBound)/scaleFactor, 'xr');

t = [startTime; endTime];
if any(isOutOfFixedUpperBound) 
    plot(t - startTime, [fixedUpperBound; fixedUpperBound], '--k');
    plot(cadenceTimesLevel1(isOutOfFixedUpperBound) - startTime, ...
        metricValuesLevel1(isOutOfFixedUpperBound)/scaleFactor, 'xk');
end
if any(isOutOfFixedLowerBound) 
    plot(t - startTime, [fixedLowerBound; fixedLowerBound], '--k');
    plot(cadenceTimesLevel1(isOutOfFixedLowerBound) - startTime, ...
        metricValuesLevel1(isOutOfFixedLowerBound)/scaleFactor, 'xk');
end
    
return