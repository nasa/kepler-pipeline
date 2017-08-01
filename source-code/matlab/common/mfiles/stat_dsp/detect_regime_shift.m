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
function [discontinuityStruct, eventStruct] = ...
detect_regime_shift(fluxTimeSeriesAll, gapIndicatorsAll,...
dataAnomalyTypeStruct,discontinuityParametersStruct, ...
gapFillParametersStruct, eventStruct, plotResultsFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%
%
%
%
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%--------------------------------------------------------------------------
% preliminaries
%--------------------------------------------------------------------------
if(~exist('discontinuityParametersStruct', 'var') || isempty(discontinuityParametersStruct) )
    discontinuityParametersStruct.discontinuityModel = [ 0 0 0 0:-0.1:-1  1:-.1:0 0 0 0]';
    discontinuityParametersStruct.medianWindowLength = 49;
    discontinuityParametersStruct.savitzkyGolayFilterLength = 9;
    discontinuityParametersStruct.savitzkyGolayPolyOrder = 2;
    discontinuityParametersStruct.discontinuityThresholdInSigma = 5;
    discontinuityParametersStruct.ruleOutTransitRatio = 0.5;
    discontinuityParametersStruct.varianceWindowLengthMultiplier = 10;
    discontinuityParametersStruct.maxNumberOfUnexplainedDiscontinuities = 4;
end

if(~exist('gapFillParametersStruct', 'var') || isempty(gapFillParametersStruct) )
    gapFillParametersStruct.madXFactor = 10;
    gapFillParametersStruct.maxGiantTransitDurationInHours = 72;
    gapFillParametersStruct.giantTransitPolyFitChunkLengthInHours = 72;
    gapFillParametersStruct.maxDetrendPolyOrder =  25;
    gapFillParametersStruct.maxArOrderLimit = 25;
    gapFillParametersStruct.maxCorrelationWindowXFactor = 5;
    gapFillParametersStruct.gapFillModeIsAddBackPredictionError = true;
    gapFillParametersStruct.waveletFamily = 'daub';
    gapFillParametersStruct.waveletFilterLength = 12;
    gapFillParametersStruct.cadenceDurationInMinutes = 30;
end

if(~exist('plotResultsFlag', 'var') || isempty(plotResultsFlag) )
    plotResultsFlag = false;
end

[nCadences, nTargets] = size(fluxTimeSeriesAll);
removeGiantTransitsFlag = false;

if(~exist('eventStruct', 'var') || isempty(eventStruct) )
    eventStruct = repmat(struct( ...
        'indexOfAstroEvents', [], ...
        'indexOfNegativeEvents', [], ...
        'indexOfPositiveEvents', [] ), 1, nTargets);
    removeGiantTransitsFlag = true;
end
    
maxNumberOfUnexplainedDiscontinuities = discontinuityParametersStruct.maxNumberOfUnexplainedDiscontinuities;
discontinuityTemplate = discontinuityParametersStruct.discontinuityModel;
savitzkyGolayFilterLength = discontinuityParametersStruct.savitzkyGolayFilterLength;
savitzkyGolayPolyOrder = discontinuityParametersStruct.savitzkyGolayPolyOrder;
discontinuityThresholdInSigma = discontinuityParametersStruct.discontinuityThresholdInSigma;

medianWindowLength = discontinuityParametersStruct.medianWindowLength;
varianceWindowLengthMultiplier = discontinuityParametersStruct.varianceWindowLengthMultiplier;
varianceEstimationWindowLength = savitzkyGolayFilterLength*varianceWindowLengthMultiplier;


nWin = savitzkyGolayFilterLength;
knownIndexOfDiscontinuities = collect_known_discontinuities_from_anomaly_data(dataAnomalyTypeStruct, nWin);

discontinuityStruct = repmat(struct( ...
    'foundDiscontinuity', false, ...
    'index', [], ...
    'discontinuityStepSize', [], ...
    'tooManyCadencesInGiantTransits', false, ...
    'tooManyUnexplainedDiscontinuities', false, ...
    'positiveStepDetected', false), nTargets, 1);

for j = 1:nTargets,
    
    %fprintf('%d/%d\n', j, nTargets);
    
    gapIndicators = gapIndicatorsAll(:,j);
    fluxTimeSeries = fluxTimeSeriesAll(:,j);
    
    if(~any(~gapIndicators)) % isempty(find(~gapIndicators))
        continue;
    end
    
    if(plotResultsFlag)
        clf;
        subplot(3,1,1);
        plot(find(~gapIndicators), fluxTimeSeries(~gapIndicators),'.-');
        title(j);
    end
    
    fluxTimeSeries = interp1(find(~gapIndicators), fluxTimeSeries(~gapIndicators), (1:nCadences)', 'nearest', 'extrap');
    giantTransitGapIndicators = false(nCadences,1);
    
    %while true
    % y = medfilt1(x,n) applies an order n one-dimensional median filter to
    % vector x; the function considers the signal to be 0 beyond the end
    % points. Output y has the same length as x
    
    % extrapolate on either side of the flux timeseries to avoid edge
    % conditions
    
    tooManyCadencesInGiantTransits = false;
    
    if removeGiantTransitsFlag
        
        % extend left, right edges in two steps by choosing the correct extrapval
        rightExtrapVal = median(fluxTimeSeries(end-100:end));
        leftExtrapVal = median(fluxTimeSeries(1:100));
        medianFilteredFlux = interp1((1:nCadences)', fluxTimeSeries , [-medianWindowLength+1:1:0 1:nCadences]', 'nearest', leftExtrapVal);
        medianFilteredFlux = interp1((1:length(medianFilteredFlux))', medianFilteredFlux, [1:length(medianFilteredFlux) length(medianFilteredFlux)+1:1:length(medianFilteredFlux)+medianWindowLength+1]', 'nearest', rightExtrapVal);

        medianFilteredFlux = medfilt1(medianFilteredFlux,medianWindowLength);
        medianFilteredFlux = medianFilteredFlux(medianWindowLength+1:medianWindowLength+nCadences);

        indexOfGiantTransits1 = identify_giant_transits(medianFilteredFlux - fluxTimeSeries, giantTransitGapIndicators, gapFillParametersStruct);
        indexOfGiantTransits2 = identify_giant_transits(fluxTimeSeries - medianFilteredFlux, giantTransitGapIndicators, gapFillParametersStruct);
        
        indexOfGiantTransits = [indexOfGiantTransits1; indexOfGiantTransits2];
        indexOfGiantTransits = unique(indexOfGiantTransits(:));

        % Populate the event struct.
        eventStruct(j).indexOfPositiveEvents = ...
            setdiff(indexOfGiantTransits1, find(gapIndicators));
        eventStruct(j).indexOfNegativeEvents = ...
            setdiff(indexOfGiantTransits2, find(gapIndicators));
        eventStruct(j).indexOfAstroEvents = ...
            setdiff(indexOfGiantTransits, find(gapIndicators));
    
    else
        
        indexOfGiantTransits = eventStruct(j).indexOfAstroEvents;
        
    end % if / else
    
    giantTransitGapIndicators(indexOfGiantTransits) = true;
    
    %    fluxTimeSeries = interp1(find(~giantTransitGapIndicators),  fluxTimeSeries(~giantTransitGapIndicators), (1:nCadences)', 'linear', NaN);
    
    if(~isempty(indexOfGiantTransits))
        
        [giantTransitsLocations] = find_datagap_locations(giantTransitGapIndicators);
        
        nGaps = size(giantTransitsLocations,1);
        
        for jGap = 1:nGaps
            
            indexOfGap = (giantTransitsLocations(jGap,1):giantTransitsLocations(jGap,2))';
            
            if(~isempty(intersect(indexOfGap, find(gapIndicators))))
                
                fluxTimeSeries(indexOfGap) = interp1(find(~giantTransitGapIndicators),  fluxTimeSeries(~giantTransitGapIndicators), indexOfGap, 'nearest', NaN);
            else
                fluxTimeSeries(indexOfGap) = interp1(find(~giantTransitGapIndicators),  fluxTimeSeries(~giantTransitGapIndicators), indexOfGap, 'linear', NaN);
                %fluxTimeSeries = interp1(find(~giantTransitGapIndicators),  fluxTimeSeries(~giantTransitGapIndicators), (1:nCadences)', 'linear', NaN);
            end
        end
    end
    
    % see if there are any NaNs corresponding to transits at the ends
    nanIndicators = isnan(fluxTimeSeries);
    
    if(any(nanIndicators))
        fluxTimeSeries = interp1(find(~nanIndicators),  fluxTimeSeries(~nanIndicators), (1:nCadences)', 'nearest', 'extrap');
    end
    
    
    if(sum(giantTransitGapIndicators)/nCadences > 0.1)
        tooManyCadencesInGiantTransits = true;
        discontinuityStruct(j).tooManyCadencesInGiantTransits = true;
    end
    
    if(plotResultsFlag)
        hold on;
        plot(fluxTimeSeries,'ro-');
    end
    
    % Use sgolay to smooth a noisy signal and to obtain the first and
    % second derivatives
    
    [b,g] = sgolay(savitzkyGolayPolyOrder,savitzkyGolayFilterLength);   % Calculate S-G coefficients
    
    fittedTrend = zeros(length(fluxTimeSeries),1);
    
    firstDiff = zeros(length(fluxTimeSeries),1);
    secondDiff = zeros(length(fluxTimeSeries),1);
    
    dx = .2;
    halfWindow  = fix(savitzkyGolayFilterLength/2);
    
    fluxTimeSeries1 = interp1((1:nCadences)', fluxTimeSeries, [-halfWindow+1:1:0 (1:nCadences) nCadences+1:1:nCadences+halfWindow+1]','linear', 'extrap');
    
    for n = (savitzkyGolayFilterLength+1)/2: length(fluxTimeSeries1)-(savitzkyGolayFilterLength+1)/2,
        
        % Zero-th derivative (smoothing only)
        fittedTrend(n) =   dot(g(:,1), fluxTimeSeries1(n - halfWindow: n + halfWindow));
        
        % 1st differential
        firstDiff(n) =   dot(g(:,2), fluxTimeSeries1(n - halfWindow: n + halfWindow));
        
        % 2nd differential
        secondDiff(n) = 2*dot(g(:,3)', fluxTimeSeries1(n - halfWindow: n + halfWindow))';
        
    end
    
    fittedTrend(1:halfWindow) = [];
    
    firstDiff(1:halfWindow) = [];
    firstDerivative = firstDiff/dx;         % Turn differential into derivative
    
    secondDiff(1:halfWindow) = [];
    secondDerivative = secondDiff/(dx*dx);    % and into 2nd derivative
    
    
    fluxTimeSeriesDetrended = fluxTimeSeries - fittedTrend;
    correlationTimeSeries = circfilt(discontinuityTemplate, secondDerivative);
    
    if(plotResultsFlag)
        
        hold off;
        subplot(3,1,2);
        plot(fluxTimeSeries, '.-');
        hold on;
        plot( fittedTrend, 'g-');
        
        subplot(3,1,3);
        plot( fluxTimeSeriesDetrended, '.-');
        subplot(3,1,3);
        plot( correlationTimeSeries, '.-');
        
    end
    
    
    noiseStdTimeSeries = movcircstd(correlationTimeSeries, varianceEstimationWindowLength);
    % correct for edge effect
    noiseStdTimeSeries(1:varianceEstimationWindowLength) = median(noiseStdTimeSeries);
    noiseStdTimeSeries(end-varianceEstimationWindowLength:end) = median(noiseStdTimeSeries);
    
    discontinuityThreshold = discontinuityThresholdInSigma*median(noiseStdTimeSeries);
    
    indexOfDiscontinuity = find(abs(correlationTimeSeries) > discontinuityThreshold);
    
    stdOfSlope  = std(firstDerivative);
    additionalIndexOfDisContinuity =  find(abs(firstDerivative) > discontinuityThresholdInSigma*stdOfSlope);
    indexOfDiscontinuity = unique(indexOfDiscontinuity);
    
    
    % add additional discontinuities from first derivative
    
    if(~isempty(indexOfDiscontinuity)|| ~isempty(additionalIndexOfDisContinuity))
        
        if(~isempty(additionalIndexOfDisContinuity))
            indexOfDiscontinuity = unique([indexOfDiscontinuity; additionalIndexOfDisContinuity]);
        end
        
        if(~isempty(indexOfDiscontinuity))
            indexOfDiscontinuityVetted = check_left_right_of_discontinuity(indexOfDiscontinuity, correlationTimeSeries, discontinuityParametersStruct);
        end
        
        if(~isempty(indexOfDiscontinuityVetted))
            
            if(plotResultsFlag)
                hold off;
                subplot(3,1,3);
                plot(correlationTimeSeries,'.-');
                hold on; plot(indexOfDiscontinuityVetted, correlationTimeSeries(indexOfDiscontinuityVetted),'ro');
            end
            index = indexOfDiscontinuityVetted - fix(length(discontinuityTemplate)/2);
            
            index = index(index > 0);
            
            if(~isempty(knownIndexOfDiscontinuities))
                
                % ignore known discontinuities, excessive discontinuities identified for targets with too many giant
                % transits because of nearest neighbor interpolation
                % pad index of known discontinuities either side by 2
                
                expandedKnownIndexOfDiscontinuities = [knownIndexOfDiscontinuities; knownIndexOfDiscontinuities+1; knownIndexOfDiscontinuities-1];
                expandedKnownIndexOfDiscontinuities = unique(expandedKnownIndexOfDiscontinuities);
                expandedKnownIndexOfDiscontinuities = expandedKnownIndexOfDiscontinuities(expandedKnownIndexOfDiscontinuities > 0);
                expandedKnownIndexOfDiscontinuities = expandedKnownIndexOfDiscontinuities(expandedKnownIndexOfDiscontinuities <= nCadences);
                
                commonDiscontinuityIndex = intersect(expandedKnownIndexOfDiscontinuities, index);
                
                if(~isempty(commonDiscontinuityIndex))
                    index = setxor(commonDiscontinuityIndex, index);
                end
            end
            
            if(~isempty(index))
                
                % proceed only if this condition is *NOT* true
                % too many unexplained discontinuities coupled with too many cadences in giant trasnits
                if(~( (length(index) > maxNumberOfUnexplainedDiscontinuities) && tooManyCadencesInGiantTransits) )
                    % one last check to eliminate if this is an artifact of nearest neighbor interpolation of cadences
                    % identified as giant transits
                    
                    nDiscontinuities = length(index);
                    fluxTimeSeries = fluxTimeSeriesAll(:,j);
                    fluxTimeSeriesTemp = interp1(find(~gapIndicators), fluxTimeSeries(~gapIndicators), (1:nCadences)', 'spline', 'extrap');
                    finalIndex = index;
                    discontinuityStepSize = -ones(length(index),1);
                    
                    for k = 1:nDiscontinuities
                        % check the gradient in the neighborhood
                        neighborhoodRadius = fix(length(discontinuityParametersStruct.discontinuityModel)/2);
                        
                        neighborhoodIndex = index(k) + (-neighborhoodRadius:1:neighborhoodRadius);
                        neighborhoodIndex = neighborhoodIndex(neighborhoodIndex <= nCadences);
                        neighborhoodIndex = neighborhoodIndex(neighborhoodIndex >= 1);
                        gradientInNeighborhood = median(abs(diff(fluxTimeSeriesTemp(neighborhoodIndex))));
                        %gradientInNeighborhood = trimmean(abs(diff(fluxTimeSeriesTemp(neighborhoodIndex))), 25);
                        
                        indexCloseToDiscontinuity = index(k)-5:index(k)+5;
                        indexCloseToDiscontinuity = indexCloseToDiscontinuity(indexCloseToDiscontinuity <= nCadences);
                        indexCloseToDiscontinuity = indexCloseToDiscontinuity(indexCloseToDiscontinuity >= 1);
                        
                        [gradientInDiscontinuity, exactIndex] = max(abs(diff(fluxTimeSeriesTemp(indexCloseToDiscontinuity))));
                        
                        if(gradientInDiscontinuity < 3*gradientInNeighborhood)
                            finalIndex(k) = -1;
                            discontinuityStepSize(k) = -1;
                        else
                            
                            % one more check to weed out giant transits cadences interpolated using 'nearest' appearing
                            % as discontinuities and passing the gradient check
                            %
                            if(~isempty(indexOfGiantTransits) && tooManyCadencesInGiantTransits)
                                [inGiantTransitIndex] = intersect(indexOfGiantTransits,indexCloseToDiscontinuity(exactIndex));
                                if(isempty(inGiantTransitIndex)) % not in giant transit
                                    
                                    [indexFinal, stepSizeFinal] = get_final_index_and_step_size(indexCloseToDiscontinuity, ...
                                        exactIndex,fluxTimeSeriesAll(:,j), gapIndicatorsAll(:,j))                                    ;
                                    finalIndex(k)  = indexFinal;
                                    discontinuityStepSize(k) = stepSizeFinal;
                                else
                                    finalIndex(k) = -1;
                                    discontinuityStepSize(k) = -1;
                                    
                                end
                            else
                                
                                % check the gradient of the point next to discontinuity to rule single point outliers
                                
                                exactIndexOfDiscontinuity = indexCloseToDiscontinuity(exactIndex);
                                % correct the bounds checking; task failed
                                % in Q0 reprocessing, 4/10; also, don't
                                % leave maxIndex undefined as it may be
                                % referenced later
                                if(exactIndexOfDiscontinuity-1 >= 1) && (exactIndexOfDiscontinuity+2 <= nCadences)
                                    [slopeAdjacentToExactIndex, maxIndex] = max([abs(diff(fluxTimeSeriesTemp(exactIndexOfDiscontinuity+1:exactIndexOfDiscontinuity+2))), ...
                                        abs(diff(fluxTimeSeriesTemp(exactIndexOfDiscontinuity-1:exactIndexOfDiscontinuity)))]);
                                else
                                    slopeAdjacentToExactIndex = gradientInNeighborhood;
                                    if(exactIndexOfDiscontinuity-1 >= 1)
                                        maxIndex = 2;
                                    else
                                        maxIndex = 1;
                                    end
                                end
                                
                                % check for transition over multiple cadences
                                if((slopeAdjacentToExactIndex/gradientInDiscontinuity)> 0.5 && ...
                                        (slopeAdjacentToExactIndex/gradientInDiscontinuity) < 1.5) % slopeAdjacentToExactIndex <= (1/3)*gradientInDiscontinuity
                                    
                                    % single point outliers will have opposite gradients at the adjacent  points
                                    % preserve sign
                                    if(maxIndex == 1)
                                        slopeAdjacentToExactIndex = diff(fluxTimeSeriesTemp(exactIndexOfDiscontinuity+1:exactIndexOfDiscontinuity+2));
                                    else
                                        slopeAdjacentToExactIndex =  diff(fluxTimeSeriesTemp(exactIndexOfDiscontinuity-1:exactIndexOfDiscontinuity));
                                        
                                    end
                                    
                                    gradientInDiscontinuity  = diff(fluxTimeSeriesTemp(exactIndexOfDiscontinuity:exactIndexOfDiscontinuity+1));
                                    
                                    if((gradientInDiscontinuity/slopeAdjacentToExactIndex) < 0 ) % adjacent gradients with opposite sign
                                        finalIndex(k) = -1;
                                        discontinuityStepSize(k) = -1;
                                    else
                                        
                                        [indexFinal, stepSizeFinal] = get_final_index_and_step_size(indexCloseToDiscontinuity, ...
                                            exactIndex,fluxTimeSeriesAll(:,j), gapIndicatorsAll(:,j))                                    ;
                                        finalIndex(k)  = indexFinal;
                                        discontinuityStepSize(k) = stepSizeFinal;
                                        % multiple point transition confirmed
                                        % decide later on what to do about this.....
                                    end
                                else
                                    [indexFinal, stepSizeFinal] = get_final_index_and_step_size(indexCloseToDiscontinuity, ...
                                        exactIndex,fluxTimeSeriesAll(:,j), gapIndicatorsAll(:,j))                                    ;
                                    finalIndex(k)  = indexFinal;
                                    discontinuityStepSize(k) = stepSizeFinal;
                                end
                            end
                        end
                    end
                    
                    finalIndex(finalIndex == -1) = [];
                    discontinuityStepSize(discontinuityStepSize == -1) = [];
                    if(~isempty(finalIndex))
                        [uniqueSet] = unique([finalIndex discontinuityStepSize], 'rows');
                        finalIndex = uniqueSet(:,1);
                        discontinuityStepSize = uniqueSet(:,2);
                    end
                    
                    if(length(finalIndex) > maxNumberOfUnexplainedDiscontinuities)
                        discontinuityStruct(j).tooManyUnexplainedDiscontinuities = true;
                    elseif(any(discontinuityStepSize > 0))
                        discontinuityStruct(j).positiveStepDetected = true;
                    elseif(~isempty(finalIndex))
                        discontinuityStruct(j).index = finalIndex;
                        discontinuityStruct(j).foundDiscontinuity = true;
                        discontinuityStruct(j).discontinuityStepSize = discontinuityStepSize; % similar to diff function
                    end
                
                else
                    discontinuityStruct(j).tooManyUnexplainedDiscontinuities = true;
                end
                
            end
            
        end
        
    end
    
end

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [finalIndex, discontinuityStepSize] = get_final_index_and_step_size(indexCloseToDiscontinuity, exactIndex,...
    fluxTimeSeries, gapIndicators)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
finalIndex  = indexCloseToDiscontinuity(exactIndex);
% check to see that finalIndex(k) is not a gap; if it happens to be a gap, find the
% next ungapped index and get the discontinuity step size accordingly

gapIndex = find(gapIndicators);

commonIndex = intersect(gapIndex,  [finalIndex; finalIndex+1]);
if(~isempty(commonIndex))
    
    validIndex = find(~gapIndicators);
    
    validIndexJustBeforeDiscontinuity = validIndex(validIndex <= finalIndex);
    % This conditional added to prevent crash due to final index being before the first valid index.
    % This is not a real fix, it's just covering up the bug by disregarding an incorrectly 
    % identified discontinuity
    if (isempty(validIndexJustBeforeDiscontinuity))
        finalIndex = -1;
        discontinuityStepSize = -1;
        return
    end
    validIndexJustBeforeDiscontinuity = validIndexJustBeforeDiscontinuity(end);
    validIndexJustAfterDiscontinuity = validIndex(validIndex > finalIndex);
    % This conditional added to prevent crash due to final index being the last valid index.
    % This is not a real fix, it's just covering up the bug by disregarding an incorrectly 
    % identified discontinuity
    if (length(validIndexJustAfterDiscontinuity) < 2)
        finalIndex = -1;
        discontinuityStepSize = -1;
        return
    end
    nTimeSteps = validIndexJustAfterDiscontinuity(2) - validIndexJustAfterDiscontinuity(1);
    controlStepSize = ((fluxTimeSeries(validIndexJustAfterDiscontinuity(2)) - ...
                            fluxTimeSeries(validIndexJustAfterDiscontinuity(1)))/nTimeSteps);
    
    
    validIndexJustAfterDiscontinuity = validIndexJustAfterDiscontinuity(1);
    finalIndex = validIndexJustBeforeDiscontinuity;
    discontinuityStepSize = fluxTimeSeries(validIndexJustAfterDiscontinuity) - fluxTimeSeries(validIndexJustBeforeDiscontinuity);
    controlStepSize = controlStepSize*(validIndexJustAfterDiscontinuity - validIndexJustBeforeDiscontinuity);
    % ControlStepSize can be zero. If so then this must be another incorrectly identified
    % discontinuity. Again, not a fix, just covering up a bug.
    if (controlStepSize == 0)
        finalIndex = -1;
        discontinuityStepSize = -1;
        return
    end
    if(abs(discontinuityStepSize/controlStepSize) < 2)
        finalIndex = -1;
        discontinuityStepSize = -1;
    end
else
    % both finalIndex and finalIndex+1 are valid indices
    discontinuityStepSize = fluxTimeSeries(finalIndex+1) - fluxTimeSeries(finalIndex);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function indexOfDiscontinuityVetted = check_left_right_of_discontinuity(indexOfDiscontinuity, correlationTimeSeries, discontinuityParametersStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

discontinuityModel = discontinuityParametersStruct.discontinuityModel;
ruleOutTransitRatio = discontinuityParametersStruct.ruleOutTransitRatio;


discontinuityIndicators = false(length(correlationTimeSeries),1);

discontinuityIndicators(indexOfDiscontinuity) = true;

[discontinuityLocations] = find_datagap_locations(discontinuityIndicators);
discontinuityIndex = find(discontinuityIndicators);

indexOfDiscontinuityVetted = [];

nBreaks = size(discontinuityLocations,1);

for jBreak = 1:nBreaks
    
    indexOfBreak = (discontinuityLocations(jBreak,1):discontinuityLocations(jBreak,2))';
    
    breakLength = max(discontinuityLocations(jBreak,2)-discontinuityLocations(jBreak,1)+1, length(discontinuityModel));
    
    indexToLeft = discontinuityLocations(jBreak,1)-breakLength:discontinuityLocations(jBreak,1)-1;
    
    indexToLeft = setxor(indexToLeft, indexOfBreak(1)-3:indexOfBreak(1)-1);
    indexToLeft = indexToLeft(indexToLeft > 0);
    
    
    % exclude from indexToLeft other discontinuity locations
    
    commonIndexLeft = intersect(indexToLeft, discontinuityIndex);
    indexToLeft = setxor(indexToLeft, commonIndexLeft);
    
    
    indexToRight = discontinuityLocations(jBreak,2)+1:discontinuityLocations(jBreak,2)+breakLength;
    indexToRight = setxor(indexToRight, indexOfBreak(end)+1:indexOfBreak(end)+3);
    
    indexToRight = indexToRight(indexToRight <= length(correlationTimeSeries));
    
    % exclude from indexToRight other discontinuity locations
    
    commonIndexRight = intersect(indexToRight, discontinuityIndex);
    indexToRight = setxor(indexToRight, commonIndexRight);
    
    zeroIndex = find(indexToLeft <= 0);
    indexToLeft(zeroIndex) = [];
    
    lastIndex = find(indexToRight >= length(correlationTimeSeries));
    indexToRight(lastIndex) = [];
    
    % form the condition here
    nextLevelCheckStatus = false;
    
    %    if( (max(abs(correlationTimeSeries(indexOfBreak)))) == abs(min(correlationTimeSeries(indexOfBreak))) ) % possible transit
    if(~isempty(indexToRight) && ~isempty(indexToLeft))
        
        leftRatio = max(abs(correlationTimeSeries(indexToLeft)))/max(abs(correlationTimeSeries(indexOfBreak)));
        rightRatio = max(abs(correlationTimeSeries(indexToRight)))/max(abs(correlationTimeSeries(indexOfBreak)));
        
        nextLevelCheckStatus = (leftRatio < ruleOutTransitRatio) && (rightRatio < ruleOutTransitRatio);
        
    end
    %     else
    %         nextLevelCheckStatus = true;
    %
    %     end
    
    if(nextLevelCheckStatus)
        
        lastLevelCheck = false;
        
        indexForThisBreak = discontinuityLocations(jBreak,1):discontinuityLocations(jBreak,2);
        
        % one more check to ensure that this is not due to an outlier
        positivePeakValue =  max(correlationTimeSeries(indexOfBreak));
        negativePeakValue =  min(correlationTimeSeries(indexOfBreak));
        
        % if both positivePeakValue, negativePeakValue are of the same
        % sign, no need to check for ratio
        
        bothPositive = (positivePeakValue >= 0) || (negativePeakValue >= 0);
        bothNegative = (positivePeakValue <= 0) || (negativePeakValue <= 0);
        
        if(bothPositive || bothNegative)
            lastLevelCheck = true;
        else
            if(abs(positivePeakValue) > abs(negativePeakValue))
                withinBreakRatio = abs(positivePeakValue)/abs(negativePeakValue);
            else
                withinBreakRatio = abs(negativePeakValue)/abs(positivePeakValue);
            end
            if(withinBreakRatio >  1/ruleOutTransitRatio )
                lastLevelCheck = true;
            end
        end
        
        if(lastLevelCheck)
            
            [sigmaAboveNoise, indexMax] = max(abs(correlationTimeSeries(indexForThisBreak)));
            
            indexOfDiscontinuityVetted = [indexOfDiscontinuityVetted indexForThisBreak(indexMax) ];
        end
        
    end
end
indexOfDiscontinuityVetted = indexOfDiscontinuityVetted(:);

% if the discontinuities are closer to the edges, discard them
if(~isempty(indexOfDiscontinuityVetted))
    nLength = length(correlationTimeSeries);
    edgeIndex = (1:length(discontinuityModel))';
    edgeIndex = [edgeIndex; (nLength-length(discontinuityModel):nLength)'];
    
    commonEdgeIndex = intersect(indexOfDiscontinuityVetted, edgeIndex);
    indexOfDiscontinuityVetted = setxor(indexOfDiscontinuityVetted, commonEdgeIndex);
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function knownIndexOfDiscontinuities = collect_known_discontinuities_from_anomaly_data(dataAnomalyTypeStruct, nWin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% dataAnomalyStruct =
%
%       attitudeTweakIndicators: [4354x1 logical]
%            safeModeIndicators: [4354x1 logical]
%          earthPointIndicators: [4354x1 logical]
%         coarsePointIndicators: [4354x1 logical]
%     argabrighteningIndicators: [4354x1 logical]
%             excludeIndicators: [4354x1 logical]

nCadences = length(dataAnomalyTypeStruct.attitudeTweakIndicators);

attitudeTweakIndex = find(dataAnomalyTypeStruct.attitudeTweakIndicators);

if(~isempty(attitudeTweakIndex))
    
    nTweaks = length(attitudeTweakIndex);
    attitudeTweakIndex = repmat(attitudeTweakIndex,1,2*nWin + 1) + repmat((-nWin:nWin),nTweaks,1);
    attitudeTweakIndex = attitudeTweakIndex(attitudeTweakIndex > 0);
    attitudeTweakIndex = attitudeTweakIndex(attitudeTweakIndex <= nCadences);
    attitudeTweakIndex = unique(attitudeTweakIndex(:));
    
end


coarsePointIndex = find(dataAnomalyTypeStruct.coarsePointIndicators);

if(~isempty(coarsePointIndex))
    
    nOffPoints = length(coarsePointIndex);
    coarsePointIndex = repmat(coarsePointIndex,1,2*nWin + 1) + repmat((-nWin:nWin),nOffPoints,1);
    coarsePointIndex = coarsePointIndex(coarsePointIndex > 0);
    coarsePointIndex = coarsePointIndex(coarsePointIndex <= nCadences);
    coarsePointIndex = unique(coarsePointIndex(:));
    
end


% combine the earthPointIndicators with safeModeIndicators as pointing the
% spacecraft towards earth for monthly downlink and returning it back to
% science collection results in a thermal recovery profile similar to the one
% folowing safe mode recovery


earthPointIndicators = dataAnomalyTypeStruct.earthPointIndicators;
safeModeIndicators = dataAnomalyTypeStruct.safeModeIndicators;
safeModeIndicators = safeModeIndicators | earthPointIndicators; % combine logical arrays

safeModeIndex = find(safeModeIndicators);

if(~isempty(safeModeIndex))
    
    nSafeModePoints = length(safeModeIndex);
    safeModeIndex = repmat(safeModeIndex,1,2*nWin + 1) + repmat((-nWin:nWin),nSafeModePoints,1);
    safeModeIndex = safeModeIndex(safeModeIndex > 0);
    safeModeIndex = safeModeIndex(safeModeIndex <= nCadences);
    safeModeIndex = unique(safeModeIndex(:));
    
end



excludeIndex = find(dataAnomalyTypeStruct.excludeIndicators);

if(~isempty(excludeIndex))
    
    nExcludes = length(excludeIndex);
    excludeIndex = repmat(excludeIndex,1,2*nWin + 1) + repmat((-nWin:nWin),nExcludes,1);
    excludeIndex = excludeIndex(excludeIndex > 0);
    excludeIndex = excludeIndex(excludeIndex <= nCadences);
    excludeIndex = unique(excludeIndex(:));
    
end



knownIndexOfDiscontinuities = [attitudeTweakIndex' coarsePointIndex' safeModeIndex' excludeIndex'];
knownIndexOfDiscontinuities = unique(knownIndexOfDiscontinuities);
knownIndexOfDiscontinuities = knownIndexOfDiscontinuities(:);


return
