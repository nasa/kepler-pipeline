%*************************************************************************************************************
%% function [targetDataStruct] = pdc_correct_attitude_tweaks (targetDataStruct, cadencetimes)
%
% Shifts the data after attitude tweaks to make the data continuous over the tweaks. See fix_this_tweak for details of the method.
%
% Note: this should only be called on gap-filled data!
%
%*************************************************************************************************************
%%
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

function [targetDataStruct] = pdc_correct_attitude_tweaks (targetDataStruct, attitudeTweakIndicators, gapFilledCadenceMidTimestamps)

% Turn on debugging to generate diagnostic plots (with pauses)
debugEnabled = false;
if (debugEnabled) 
    % Save inputs targetDataStruct for comparison plots
    targetDataStructSave = targetDataStruct;
    waitBarHandle = waitbar(0, 'Fixing Attitude Tweaks');
end

nTargets = length(targetDataStruct);
attitudeTweakLocations = find(attitudeTweakIndicators);
nAttitudeTweakLocations = length(attitudeTweakLocations);

% We want to use the transit removed flux for the tweak detection step so that the transits do not produce a strong reponse by the filter
transitRemovedValues = pdcTransitClass.create_transit_removed_flux_values (targetDataStruct, gapFilledCadenceMidTimestamps);

for iTarget = 1 : nTargets
    % Start at the first tweak and work our way down shifting all trailing data as we go.
    for iTweak = 1 : nAttitudeTweakLocations 
        [targetDataStruct(iTarget), transitRemovedValues(:,iTarget)] = ...
                    fix_this_tweak (targetDataStruct(iTarget), attitudeTweakLocations(iTweak), transitRemovedValues(:,iTarget), gapFilledCadenceMidTimestamps);
    end
    if (debugEnabled) 
        waitbar(iTarget/nTargets, waitBarHandle);
    end
end
if (debugEnabled) 
    close(waitBarHandle);
end

% Plot some diagnostic plots
nPlots = min(40, nTargets);
if (debugEnabled)
    % pick some random plots
    targetsToPlot = randperm(nTargets);
    targetsToPlot = targetsToPlot(1:nPlots);
    % Add in specific targets
    targetsToPlot = [specialTargets targetsToPlot];
    attitudeTweakFigure = figure;
    for iTarget = 1 : nPlots
        figure(attitudeTweakFigure);
        hold off;
        plot(targetDataStructSave(targetsToPlot(iTarget)).values, '-b')
        hold on;
        plot(targetDataStruct(targetsToPlot(iTarget)).values, '-r')
        % Plot the attitude tweak markers above the original flux values
        markerFluxValue = nanmedian(targetDataStructSave(targetsToPlot(iTarget)).values) + 2*nanstd(targetDataStructSave(targetsToPlot(iTarget)).values);
        plot(attitudeTweakLocations, markerFluxValue,  'pk', 'MarkerSize', 15)
        plot(attitudeTweakLocations, targetDataStructSave(targetsToPlot(iTarget)).values(attitudeTweakLocations),  'pk', 'MarkerSize', 10)
        
        legend('Flux before adustments', 'Flux After Adjustments', 'Attitude Tweak', 'Location', 'SouthEast')
        title (['Adjusting Flux About Attitude Tweaks for target index ', num2str(targetsToPlot(iTarget))]);

        pause;
    end
    clear targetDataStructSave;
end


return;
        
%%************************************************************************************************************* 
% This function first test the tweak location to see if a tweak is actually present. A simple step function filter is used to detect the tweak. If the response
% to the step function is not larger than 4 sigma compared to the neighbourhood about the tweak then a tweak is not detected and no correction is performed. The
% main point of this test is because targets with fast oscillating stellar signals can look like steps at the tweak. The tweak correction then tries to remove
% both the actual tweak (if it exists) and the oscillation at the tweak. So, with the filter test only tweaks that appear large compared to the oscillation
% signals about the tweak are attempted to be remove. This means for many highly oscillating targets the tweaks will not be remove. 
%
% An improvement to this function would be to try to disentangle the tweak from the local oscillation.
%
% Another issue is giant transits. If there are giant transits near the tweak then the filter detector will also falsely not detect the legitimate tweak. Yet,
% another area where this function could be improved.
%
% For those tweaks that pass the filter the following two steps are used to fix the attitude tweak:
%
% 1) Apply a Savitsky-Golay filter to smooth the data before and after the tweak (separately in two stages so not to smooth out the tweak!). This is to find the
%       offset due to the tweak. The smoothing is not saved to the flux, it's just to find the offset.
%
% 2) Applies the found offset to line up the ends about the attitude tweak.
%
% NOTE: this algorithm assumes gap-filled data.
%

function [singleTargetDataStruct, transitRemovedValues] = fix_this_tweak (singleTargetDataStruct, attitudeIndex, transitRemovedValues, gapFilledCadenceMidTimestamps)

    nCadences = length(singleTargetDataStruct.values);

    nCadencesAboutTweakToSmooth = 200; % For the Savitsgy-Golay filter.
    nCadencesAboutTweakForDetectionFilter = 200; % For the step response filter

    detectionThreshold = 4.0; % The threshold response from the step filter (in MAD sigma).
    
    %*******************
    % The step filter response detection step

    % Use transit removed flux so that transits do not produce a strong response with the filter
    fluxAboutTweakForStepFilter = ...
        transitRemovedValues(max(attitudeIndex-nCadencesAboutTweakForDetectionFilter,1):min(attitudeIndex+nCadencesAboutTweakForDetectionFilter,end));
    b = filter_response (fluxAboutTweakForStepFilter);
    % If the response is above a detectionThreshold then this looks like a tweak
    tweakLocation = min(attitudeIndex, nCadencesAboutTweakForDetectionFilter);
    response = max(abs(b(  max(tweakLocation-5,1) : min(tweakLocation+5,length(b)) ))) / mad(b); % Find the max response on both sides of attitude tweak
    if (abs(response) < detectionThreshold)
        return; % not strong enough signal so skip this tweak location
    end

    %*******************
    % Do not fix a tweak if there are not non-gapped cadences on both sides of the tweak
    if (all(singleTargetDataStruct.gapIndicators(1:attitudeIndex-1)) || all(singleTargetDataStruct.gapIndicators(attitudeIndex+1:end)))
        return;
    end

    %*******************
    % Smooth the data about the tweak but NOT over the attitude tweak, otherwise we would smooth out the jump!
    sgPolyOrder = 3;
    % Window is fraction of full data set of nCadencesAboutTweakToSmooth 
    sgWindow = round(nCadencesAboutTweakToSmooth / 2);
    % The window cannot be longer than the data we are smoothing, we smooth in two parts, before and after the tweak
    sgWindowBeforeTweak = min([sgWindow, attitudeIndex-1, nCadencesAboutTweakToSmooth]);
    sgWindowAfterTweak  = min([sgWindow, nCadences - (attitudeIndex + 1), nCadencesAboutTweakToSmooth]);
    % Window must be odd
    if (mod(sgWindowBeforeTweak,2) == 0)
        sgWindowBeforeTweak = sgWindowBeforeTweak - 1;
    end
    if (mod(sgWindowAfterTweak,2) == 0)
        sgWindowAfterTweak = sgWindowAfterTweak - 1;
    end

    % Use transit removed flux so that transits do not skew the smoothing
    smoothedFluxValues = transitRemovedValues;


    % Note: a median filter can also work but not as well as the sgolay filter. The median filter has boundary issues so the data must be properly reflected
    % about the tweak.
    
    % Only smooth if smoothWindow > polyOrder
    % Speed this up by only smoothing in the regions right about the tweak
    if (sgWindowBeforeTweak > sgPolyOrder)
        firstCadenceToSmooth = max(1,attitudeIndex-1-nCadencesAboutTweakToSmooth);
        smoothedFluxValues(firstCadenceToSmooth:attitudeIndex-1) = ...
                    sgolayfilt(smoothedFluxValues (firstCadenceToSmooth:attitudeIndex-1), sgPolyOrder , sgWindowBeforeTweak);
    end
    if (sgWindowAfterTweak > sgPolyOrder)
        lastCadenceToSmooth = min(nCadences,attitudeIndex+1+nCadencesAboutTweakToSmooth);
        smoothedFluxValues(attitudeIndex+1:lastCadenceToSmooth) = ...
                    sgolayfilt(smoothedFluxValues (attitudeIndex+1:lastCadenceToSmooth), sgPolyOrder , sgWindowAfterTweak);
    end

    %***
    % Since we've already smoothed the data just offset to line up the ends
    offset = smoothedFluxValues(attitudeIndex-1) - smoothedFluxValues(attitudeIndex+1);

    % NOTE: this is turned off but I can't decide if I want it so keeping the code in as a reminder.
    % Only correct if offset is greater than uncertainty in data
    % Ignore when uncertainty is zero
   %uncertaintiyAboutTweak = singleTargetDataStruct.uncertainties(firstCadenceToSmooth:lastCadenceToSmooth);
   %medianUnceertaintyAboutTweak = nanmedian(uncertaintiyAboutTweak(uncertaintiyAboutTweak ~= 0.0));
   %if (abs(offset) < medianUnceertaintyAboutTweak)
   %    offset = 0.0;
   %end

    % Add in the offset
    singleTargetDataStruct.values(attitudeIndex+1:end) = singleTargetDataStruct.values(attitudeIndex+1:end) + offset;
    transitRemovedValues(attitudeIndex+1:end) = transitRemovedValues(attitudeIndex+1:end) + offset;

    % The attitude tweak cadence itself can have some intermediate flux value between the before and after values. Re-interpolate over the tweak. 
    % Simply linear interpolate over the single tweak cadence (ignoring gaps)
    % Need to use gapFilledCadenceMidTimestamps becuase I need the cadence time at the coarse point, which may not have a legit cadence time on PDC input
    % An attitude tweak can occur with no non-gapped cadences on one side, so, we need to use the interpolator -- it's just one cadence so probably safe to
    % interpolate.
    singleTargetDataStruct.values(attitudeIndex) = interp1(gapFilledCadenceMidTimestamps(~singleTargetDataStruct.gapIndicators), ...
                singleTargetDataStruct.values(~singleTargetDataStruct.gapIndicators), gapFilledCadenceMidTimestamps(attitudeIndex), 'linear', 'extrap');
    transitRemovedValues(attitudeIndex) = interp1(gapFilledCadenceMidTimestamps(~singleTargetDataStruct.gapIndicators), ...
                transitRemovedValues(~singleTargetDataStruct.gapIndicators), gapFilledCadenceMidTimestamps(attitudeIndex), 'linear', 'extrap');

return

%%*************************************************************************************************************
% This is the filter response function. It's really simple. It just takes a very simple step function and passes it along the flux about the tweak -- simple
% travelling window detection. A least-squares fit of the window to the filter is then used to finc the fit coefficient (I.E. the filter response at each
% cadence). We only want the response to the filter and not the DC offset so ignore the reponse to the offset.
%
% Robustfit could be used but is a lot slower to run. Likewise, regress is a pre-packaged function but we need to call the fitter many times so just use a very
% basic least-squares fit based on the code in regress.
%
% Fill specified gaps. This code is all run after the gap filling however, giant transits result in very large responses to the filter so all transits should be
% decalred gaps so that they can be filled here.

function [b] = filter_response (flux, gaps)

    filterLength = 16; % must be even!

    b = zeros(length(flux),2);

    filt = [repmat(0, [1,filterLength/2]) repmat(1, [1,filterLength/2])]';
    % Add ones to filter
    X = [ones(length(filt),1) filt];

    for i = filterLength : length(flux)-filterLength

        % Use simple linear least-squares fitting
        y = flux(i-filterLength/2:i+(filterLength/2)-1);
        % Use the rank-revealing QR to remove dependent columns of X.
        [Q,R,perm] = qr(X,0);
        b(i,perm) = R \ (Q'* y);

    end

    % Want response to the filter not ones
    b = b(:,2);

return

