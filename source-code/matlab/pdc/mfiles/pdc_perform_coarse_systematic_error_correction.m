% Note from JCS: Don't you love complex functions that don't have even the most basic of a header? If you spent this much time writing a function you could have
% at-least written a short paragraph explaining what the function does!
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

function [correctedFluxArray, correctedFluxUncertaintiesArray, modOutCenterEvolutionArray] = ...
    pdc_perform_coarse_systematic_error_correction(targetFluxArray, targetFluxUncertaintiesArray, gapIndicatorsArray, coarsePdcParameters, ...
    modOutCenterEvolutionArray, indexOfGiantTransits, debugFlag)





if(isempty(targetFluxArray))
    fprintf('Input time series empty; nothing to do    \n');
    correctedFluxArray = [];
    correctedFluxUncertaintiesArray = [];
    return
end


[nCadences, nTargets]  = size(targetFluxArray);
dvaTrendAvailable = false;



dataAnomalyTypeStruct = coarsePdcParameters.cadenceTimes.dataAnomalyFlags;

raDec2PixObject = coarsePdcParameters.raDec2PixObject;
cadenceTimesStruct = coarsePdcParameters.cadenceTimes;
module = coarsePdcParameters.ccdModule;
output = coarsePdcParameters.ccdOutput;
gapFillParametersStruct = coarsePdcParameters.gapFillConfigurationStruct;

harmonicsIdentificationParameters = coarsePdcParameters.harmonicsIdentificationConfigurationStruct;

pdcModuleParameters = coarsePdcParameters.pdcModuleParameters;
if(~isempty(raDec2PixObject))
    if(isempty(modOutCenterEvolutionArray))
        gapIndex = find(cadenceTimesStruct.gapIndicators);
        if(~isempty(gapIndex))

            validIndex = find(~cadenceTimesStruct.gapIndicators);
            newMjds = interp1(validIndex, cadenceTimesStruct.midTimestamps(validIndex), (1:nCadences)','linear',  'extrap');
        else
            newMjds = cadenceTimesStruct.midTimestamps;
        end

        [ra, dec] = pix_2_ra_dec(raDec2PixObject, module, output, 500, 500, cadenceTimesStruct.midTimestamps(1));
        [m,o, rows, columns] = ra_dec_2_pix(raDec2PixObject, ra, dec,newMjds);

        modOutCenterEvolutionArray = [rows(:) columns(:)];
    end
    designMatrixForDvaTrend = [modOutCenterEvolutionArray ones(nCadences,1)];
    dvaTrendAvailable = true;
end






%--------------------------------------------------------------------------
% preliminaries still...
% work with a bare minimum of inputs
%--------------------------------------------------------------------------

if(~exist('gapIndicatorsArray', 'var') || isempty(gapIndicatorsArray))
    gapIndicatorsArray = false(size(targetFluxArray));
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

maxDetrendPolyOrder = gapFillParametersStruct.maxDetrendPolyOrder;

if(gapFillParametersStruct.cadenceDurationInMinutes > 15) % LC
    isLongCadence = true;
else
    isLongCadence = false;
end


if(~exist('harmonicsIdentificationParameters', 'var') || isempty(harmonicsIdentificationParameters) )

    harmonicsIdentificationParameters.medianWindowLength = 21; % to ignore strong harmonics
    harmonicsIdentificationParameters.movingAverageWindowLength = 47; % to get a smoothed PSD of noise
    harmonicsIdentificationParameters.chiSquareProbabilityForThreshold = 0.99;
end

if(~exist('pdcModuleParameters', 'var') || isempty(pdcModuleParameters) )

    thermalRecoveryDurationInDays = 5;
    neighborhoodRadiusForAttitudeTweak = 25;
    harmonicDetrendOrder = 3;

elseif (~isfield(pdcModuleParameters, 'thermalRecoveryDurationInDays'))

    thermalRecoveryDurationInDays = 5;
    neighborhoodRadiusForAttitudeTweak = 25;
    harmonicDetrendOrder = pdcModuleParameters.harmonicDetrendOrder;

else

    thermalRecoveryDurationInDays = pdcModuleParameters.thermalRecoveryDurationInDays;
    neighborhoodRadiusForAttitudeTweak = pdcModuleParameters.neighborhoodRadiusForAttitudeTweak;
    harmonicDetrendOrder = pdcModuleParameters.harmonicDetrendOrder;


end

cadencesPerDay = 24*60/gapFillParametersStruct.cadenceDurationInMinutes;
thermalRecoveryDurationInCadences = fix(thermalRecoveryDurationInDays*cadencesPerDay);


if(~exist('dataAnomalyTypeStruct', 'var') || isempty(dataAnomalyTypeStruct) )

    dataAnomalyTypeStruct.attitudeTweakIndicators = false(nCadences,1);
    dataAnomalyTypeStruct.safeModeIndicators = false(nCadences,1);
    dataAnomalyTypeStruct.earthPointIndicators = false(nCadences,1);
    dataAnomalyTypeStruct.coarsePointIndicators = false(nCadences,1);
    dataAnomalyTypeStruct.argabrighteningIndicators = false(nCadences,1);
    dataAnomalyTypeStruct.excludeIndicators = false(nCadences,1);

end

if(~exist('indexOfGiantTransits', 'var') )
    indexOfGiantTransits = [];
end % if

if(~exist('debugFlag', 'var') || isempty(debugFlag) )
    debugFlag = false;
end

%--------------------------------------------------------------------------
% pre-allocate memory for outputs
%--------------------------------------------------------------------------

correctedFluxArray = zeros(nCadences, nTargets);
correctedFluxUncertaintiesArray = zeros(nCadences, nTargets);


%--------------------------------------------------------------------------
% check for safe mode events
%--------------------------------------------------------------------------


% combine the earthPointIndicators with safeModeIndicators as pointing the
% spacecraft towards earth for monthly downlink and returning it back to
% science collection results in a thermal recovery profile similar to the one
% folowing safe mode recovery


earthPointIndicators = dataAnomalyTypeStruct.earthPointIndicators;
safeModeIndicators = dataAnomalyTypeStruct.safeModeIndicators;
safeModeIndicators = safeModeIndicators | earthPointIndicators; % combine logical arrays


[safeModeLocations] = find_datagap_locations(safeModeIndicators);

nSafeModes = size(safeModeLocations,1);

if(nSafeModes > 0)
    for jSafeMode = 1:nSafeModes

        % expand the safemode by an additional 4 days to include thermal gradient
        indexOfSafeMode = (safeModeLocations(jSafeMode,1):safeModeLocations(jSafeMode,2))';
        indexToRight = (indexOfSafeMode(end): indexOfSafeMode(end)+thermalRecoveryDurationInCadences)';

        indexToRight = indexToRight(indexToRight <= nCadences);
        safeModeIndicators(indexToRight) = true;

    end
end

%----------------------------------------------------------------------
% perform coarse systematic error correction in 3 steps:
%   1. correct discontinuities due to attitude tweak
%   2. correct thermal recovery transients
%   3. do a simple global detrending
%----------------------------------------------------------------------

for jTarget = 1:nTargets

    originalTimeSeries = targetFluxArray(:, jTarget);
    gapIndicators = gapIndicatorsArray(:, jTarget);

    if(~isempty(targetFluxUncertaintiesArray))
        originalTimeSeriesUncertainties = targetFluxUncertaintiesArray(:, jTarget);
    end

    if(~isempty(dataAnomalyTypeStruct))

        attitudeTweakCadences = find(dataAnomalyTypeStruct.attitudeTweakIndicators);

        if(~isempty(attitudeTweakCadences))

            %----------------------------------------------------------------------
            % perform coarse systematic error correction in 3 steps:
            %   1. correct discontinuities due to attitude tweak
            %----------------------------------------------------------------------

            if(isLongCadence) % LC
                nTweaks = length(attitudeTweakCadences);
                fluxTimeSeriesTemp = interp1(find(~gapIndicators), originalTimeSeries(~gapIndicators), (1:nCadences)', 'spline', NaN);
            else

                % groups of 30 short cadences will appear as tweaks; treat
                % each group as one tweak
                tweakLocations = find_datagap_locations(dataAnomalyTypeStruct.attitudeTweakIndicators);
                nTweaks = size(tweakLocations,1);

                fluxTimeSeriesTemp = interp1(find(~gapIndicators), originalTimeSeries(~gapIndicators), (1:nCadences)', 'nearest', NaN);
            end

            nanIndicators = isnan(fluxTimeSeriesTemp);

            if(any(nanIndicators))

                fluxTimeSeriesTemp = interp1(find(~nanIndicators),  fluxTimeSeriesTemp(~nanIndicators), (1:nCadences)', 'nearest', 'extrap');

            end

            warning off all;

            for k = 1:nTweaks

                if(isLongCadence) % LC

                    discontinuityStepSizeFromFit = estimate_discontinuity_step_size(attitudeTweakCadences(k)-1, attitudeTweakCadences(k)+1, thermalRecoveryDurationInCadences, ...
                        originalTimeSeries, gapIndicators, gapFillParametersStruct);
                    discontinuityStepSize =  fluxTimeSeriesTemp(attitudeTweakCadences(k)-1) - fluxTimeSeriesTemp(attitudeTweakCadences(k)+1);

                else

                    discontinuityStepSizeFromFit = estimate_discontinuity_step_size(tweakLocations(k,1)-1, tweakLocations(k,2)+1, thermalRecoveryDurationInCadences, ...
                        originalTimeSeries, gapIndicators, gapFillParametersStruct);

                    discontinuityStepSize =  fluxTimeSeriesTemp(tweakLocations(k,1)-1) - fluxTimeSeriesTemp(tweakLocations(k,2)+1);
                end


                % if the star is highly variable, then this method of
                % computing step size at attitude tweak is useless

                measureOfVariability = (std(originalTimeSeries(~gapIndicators))/mean(originalTimeSeries(~gapIndicators)))*100;

                isHighlyVariable = measureOfVariability > 5;
                if(isHighlyVariable && ~isnan(discontinuityStepSizeFromFit))
                    discontinuityStepSize = discontinuityStepSizeFromFit ;
                end

                if(isLongCadence) % LC

                    originalTimeSeries(attitudeTweakCadences(k):end) = ...
                        originalTimeSeries(attitudeTweakCadences(k):end) + discontinuityStepSize;


                    fluxTimeSeriesTemp(attitudeTweakCadences(k):end) = ...
                        fluxTimeSeriesTemp(attitudeTweakCadences(k):end) + discontinuityStepSize;

                else

                    originalTimeSeries(tweakLocations(k,1):end) = ...
                        originalTimeSeries(tweakLocations(k,1):end) + discontinuityStepSize;


                    fluxTimeSeriesTemp(tweakLocations(k,1):end) = ...
                        fluxTimeSeriesTemp(tweakLocations(k,1):end) + discontinuityStepSize;
                end

                if(~isHighlyVariable)
                    % another iteration to check for discontinuity at the tweak
                    % after the adjustment

                    if(isLongCadence) % LC
                        discontinuityStepSize = estimate_discontinuity_step_size(attitudeTweakCadences(k)-1, attitudeTweakCadences(k)+1, neighborhoodRadiusForAttitudeTweak, ...
                            originalTimeSeries, gapIndicators, gapFillParametersStruct);

                    else

                        discontinuityStepSize = estimate_discontinuity_step_size(tweakLocations(k,1)-1, tweakLocations(k,2)+1, neighborhoodRadiusForAttitudeTweak, ...
                            originalTimeSeries, gapIndicators, gapFillParametersStruct);
                    end


                    if(~isnan(discontinuityStepSize))


                        if(isLongCadence) % LC

                            originalTimeSeries(attitudeTweakCadences(k):end) = ...
                                originalTimeSeries(attitudeTweakCadences(k):end) + discontinuityStepSize;


                            fluxTimeSeriesTemp(attitudeTweakCadences(k):end) = ...
                                fluxTimeSeriesTemp(attitudeTweakCadences(k):end) + discontinuityStepSize;

                        else

                            originalTimeSeries(tweakLocations(k,1):end) = ...
                                originalTimeSeries(tweakLocations(k,1):end) + discontinuityStepSize;


                            fluxTimeSeriesTemp(tweakLocations(k,1):end) = ...
                                fluxTimeSeriesTemp(tweakLocations(k,1):end) + discontinuityStepSize;
                        end

                    end
                end
            end
        end
    end



    %------------------------------------------------------------------------
    % check and correct for possible discontinuity introduced by the harmonic
    % fit
    %--------------------------------------------------------------------------
    for jSafeMode = 1:nSafeModes

        indexOfSafeMode = (safeModeLocations(jSafeMode,1):safeModeLocations(jSafeMode,2))';

        discontinuityStepSize = estimate_discontinuity_step_size(indexOfSafeMode(1), indexOfSafeMode(end), thermalRecoveryDurationInCadences, ...
            originalTimeSeries, gapIndicators, gapFillParametersStruct);

        if(isnan(discontinuityStepSize))
            continue;
        end


        originalTimeSeries(safeModeLocations(jSafeMode,1)+1:end) = ...
            originalTimeSeries(safeModeLocations(jSafeMode,1)+1:end) + discontinuityStepSize;

    end



    nSafeModes = size(safeModeLocations,1);

    if(nSafeModes > 0)
        %----------------------------------------------------------------------
        % perform coarse systematic error correction in 3 steps:
        %   2. correct thermal recovery transients
        %----------------------------------------------------------------------

        % if the harmonic fit comes in empty, then do a polynomial fit
        gapIndicators1 = (gapIndicators | safeModeIndicators);

        [harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits] = ...
            identify_and_remove_phase_shifting_harmonics(originalTimeSeries, ...
            gapIndicators1, gapFillParametersStruct, ...
            harmonicsIdentificationParameters, indexOfGiantTransits);

        % do a simple fit trend
        gapIndicators2 = gapIndicators1;
        gapIndicators2(indexOfGiantTransits) = true;
        fittedTrend = fit_trend((1:nCadences)', find(~gapIndicators2),  originalTimeSeries,  maxDetrendPolyOrder) ;

        % choose the best fit
        if(~isempty(harmonicTimeSeries))
            harmonicFitError = sum(harmonicsRemovedTimeSeries(~gapIndicators1).^2)/sum(~gapIndicators1);
        else
            harmonicFitError = Inf;
        end

        trendFitError  = sum((originalTimeSeries(~gapIndicators1) - fittedTrend(~gapIndicators1)).^2)/sum(~gapIndicators1);

        if(trendFitError >  harmonicFitError)
            fittedTrend = harmonicTimeSeries;
        end


        %----------------------------------------------------------------------
        %    plot for debugging/visualization
        %----------------------------------------------------------------------
        if(debugFlag)
            figure;
            plot(find(~gapIndicators), originalTimeSeries(~gapIndicators), 'bo-');
            title(jTarget)
            hold on;
            plot(find(~gapIndicators), fittedTrend(~gapIndicators), 'k.-');
        end

        %------------------------------------------------------------------------
        % model segement pertaining to thermal transients following the safe mode recovery period and apply
        % correction coefficients to reverse the effect
        %--------------------------------------------------------------------------

        for jSafeMode = 1:nSafeModes

            indexOfSafeMode = (safeModeLocations(jSafeMode,1):safeModeLocations(jSafeMode,2))';

            indexToRight = (indexOfSafeMode(end): indexOfSafeMode(end)+thermalRecoveryDurationInCadences)';

            indexToRight = indexToRight(indexToRight <= nCadences);
            if(isempty(indexToRight))
                continue;
            end


            indexToRight1 = indexToRight;

            gapIndicatorsForThisSafeMode = gapIndicators(indexToRight);

            % identify giant transits/flare in this thermal recovery segment before applying correction coeffts

            indexOfGiantTransits1 = identify_giant_transits(originalTimeSeries(indexToRight), gapIndicatorsForThisSafeMode, gapFillParametersStruct);
            indexOfGiantTransits2 = identify_giant_transits(-originalTimeSeries(indexToRight), gapIndicatorsForThisSafeMode, gapFillParametersStruct);

            indexOfGiantTransits = unique([indexOfGiantTransits1; indexOfGiantTransits2]);

            if(~isempty(indexOfGiantTransits))
                indexToRight(indexOfGiantTransits) = [];
                gapIndicatorsForThisSafeMode = gapIndicators(indexToRight);
            end
            if(isempty(indexToRight))
                continue;
            end

            % do a simple fit trend
            [fittedThermalRecoveryTrend, fittedPolyOrderForThermalRecoveryTrend] = ...
                fit_trend((1:length(indexToRight1))', find(~gapIndicatorsForThisSafeMode),  originalTimeSeries(indexToRight),  maxDetrendPolyOrder);

            if(fittedPolyOrderForThermalRecoveryTrend > 0)
                correctionCoeffts = fittedTrend(indexToRight1)./fittedThermalRecoveryTrend;


                correctedSegment  = originalTimeSeries(indexToRight1).*correctionCoeffts;

                if(~isempty(targetFluxUncertaintiesArray))
                    originalTimeSeriesUncertainties(indexToRight1) = originalTimeSeriesUncertainties(indexToRight1).*correctionCoeffts;
                end

                discontinuityStepSize =  correctedSegment(end) - originalTimeSeries(indexToRight1(end));

                correctedSegment = correctedSegment - discontinuityStepSize;

                originalTimeSeries(indexToRight1) = correctedSegment;


            end

        end

    end



    %----------------------------------------------------------------------
    % perform coarse systematic error correction in 3 steps:
    %   3. do a simple detrending limiting the maxDetrendpolyOrder to 2
    % may need to get DVA motion over a quarter from raDec2Pix and remove
    % the DVA trend
    % This way no harmonics will be removed but only the trend due to DVA
    %----------------------------------------------------------------------


    if(~dvaTrendAvailable)
        globalTrend = fit_trend((1:nCadences)', find(~gapIndicators),  originalTimeSeries,  harmonicDetrendOrder) ;

    else
        warning  off all;

        wtCoeffts = lscov(designMatrixForDvaTrend(~gapIndicators, :),originalTimeSeries(~gapIndicators));
        warning  on all;


        globalTrend = zeros(nCadences,1);
        globalTrend(~gapIndicators) = designMatrixForDvaTrend(~gapIndicators,:)*wtCoeffts;


    end



    %----------------------------------------------------------------------
    %    plot for debugging/visualization
    %----------------------------------------------------------------------
    if(debugFlag)
        figure;
        plot(find(~gapIndicators), targetFluxArray(~gapIndicators, jTarget), '.-');
        hold on;
        plot(find(~gapIndicators), originalTimeSeries(~gapIndicators), 'mo-');
        title(jTarget)

    end

    originalTimeSeries(~gapIndicators) = originalTimeSeries(~gapIndicators) - globalTrend(~gapIndicators);


    if(debugFlag)
        plot(find(~gapIndicators),globalTrend(~gapIndicators), 'k-');

        figure;
        plot(find(~gapIndicators), originalTimeSeries(~gapIndicators), 'mo-');

        %         tic
        %         [harmonicsRemovedTimeSeries, harmonicTimeSeries] = ...
        %             identify_and_remove_phase_shifting_harmonics(originalTimeSeries, gapIndicators);
        %         toc
        %
        %         if(~isempty(harmonicTimeSeries))
        %             hold on;
        %             plot(find(~gapIndicators), harmonicTimeSeries(~gapIndicators), 'r.-')
        %
        %             figure;
        %             plot(find(~gapIndicators), harmonicsRemovedTimeSeries(~gapIndicators), 'r.-')
        %
        %         end

        close all;
    end

    correctedFluxArray(~gapIndicators, jTarget) = originalTimeSeries(~gapIndicators);

    if(~isempty(targetFluxUncertaintiesArray))
        correctedFluxUncertaintiesArray(:, jTarget) = originalTimeSeriesUncertainties;
    else
        correctedFluxUncertaintiesArray = [];
    end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function discontinuityStepSize = estimate_discontinuity_step_size(leftIndex, rightIndex, thermalRecoveryDurationInCadences, ...
    originalTimeSeries, gapIndicators, gapFillParametersStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

nCadences  = length(originalTimeSeries);


rightNeighborhoodIndex = (rightIndex:rightIndex+thermalRecoveryDurationInCadences)';

rightNeighborhoodIndex = rightNeighborhoodIndex(rightNeighborhoodIndex <= nCadences);

if(isempty(rightNeighborhoodIndex))
    discontinuityStepSize = NaN;
    return;
end


gapIndicatorsForRightSegment = gapIndicators(rightNeighborhoodIndex);

% identify giant transits/flare in this thermal recovery
% segment

indexOfGiantTransits1 = identify_giant_transits(originalTimeSeries(rightNeighborhoodIndex), gapIndicatorsForRightSegment, gapFillParametersStruct);
indexOfGiantTransits2 = identify_giant_transits(-originalTimeSeries(rightNeighborhoodIndex), gapIndicatorsForRightSegment, gapFillParametersStruct);

indexOfGiantTransits = [indexOfGiantTransits1; indexOfGiantTransits2];

if(~isempty(indexOfGiantTransits))
    rightNeighborhoodIndex(indexOfGiantTransits) = [];
    if(isempty(rightNeighborhoodIndex))
        discontinuityStepSize = NaN;
        return;
    end
end


leftNeighborhoodIndex = (leftIndex-thermalRecoveryDurationInCadences:leftIndex-1)';

leftNeighborhoodIndex = leftNeighborhoodIndex(leftNeighborhoodIndex >= 1);


if(isempty(leftNeighborhoodIndex))
    discontinuityStepSize = NaN;
    return;
end

gapIndicatorsForLeftSegment = gapIndicators(leftNeighborhoodIndex);

indexOfGiantTransits4 = identify_giant_transits(originalTimeSeries(leftNeighborhoodIndex), gapIndicatorsForLeftSegment, gapFillParametersStruct);
indexOfGiantTransits5 = identify_giant_transits(-originalTimeSeries(leftNeighborhoodIndex), gapIndicatorsForLeftSegment, gapFillParametersStruct);

indexOfGiantTransits = [indexOfGiantTransits4; indexOfGiantTransits5];

if(~isempty(indexOfGiantTransits))
    leftNeighborhoodIndex(indexOfGiantTransits) = [];
    if(isempty(leftNeighborhoodIndex))
        discontinuityStepSize = NaN;
        return;
    end
end


gapIndicatorsForLeftNeighborhood = gapIndicators(leftNeighborhoodIndex);
leftNeighborhoodIndex = leftNeighborhoodIndex(~gapIndicatorsForLeftNeighborhood);

gapIndicatorsForRightNeighborhood = gapIndicators(rightNeighborhoodIndex);
rightNeighborhoodIndex = rightNeighborhoodIndex(~gapIndicatorsForRightNeighborhood);


if(isempty(leftNeighborhoodIndex) || isempty(rightNeighborhoodIndex))
    discontinuityStepSize = NaN;
    return;
end



leftNeigborhoodlFitCoeffts = robustfit(leftNeighborhoodIndex,originalTimeSeries(leftNeighborhoodIndex));
rightNeigborhoodlFitCoeffts = robustfit(rightNeighborhoodIndex,originalTimeSeries(rightNeighborhoodIndex));

leftPolyFit = polyval(flipud(leftNeigborhoodlFitCoeffts),leftNeighborhoodIndex);
rightPolyFit = polyval(flipud(rightNeigborhoodlFitCoeffts),rightNeighborhoodIndex);

discontinuityStepSize = leftPolyFit(end) - rightPolyFit(1);

return
