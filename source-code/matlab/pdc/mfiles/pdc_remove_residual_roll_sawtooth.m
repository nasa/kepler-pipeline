%*************************************************************************************************************
% function [targetDataStruct, fluxCorrectionStruct] = pdc_remove_residual_roll_sawtooth (targetDataStruct, fluxCorrectionStruct);
%
% Finds any residual spikes after MAP and gaps them.
%
% First uses the standard outlier detector to gap outliers.
%
% Then uses a response to a simpel exponential filter to identify the residual sawtooth.
%
%*************************************************************************************************************
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
function [targetDataStruct, fluxCorrectionStruct] = pdc_remove_residual_roll_sawtooth (targetDataStruct, pdcInputObject, fluxCorrectionStruct);

    debugEnabled = false;

    thrusterFiringFlag = any(pdcInputObject.thrusterFiringDataStruct.thrusterFiringFlag')';
    thrusterFiringCadences = find(thrusterFiringFlag);

    % The threshold response from the step filter (in Median Absolute Deviation based sigma).
    detectionThreshold = pdcInputObject.pdcModuleParameters.thrusterSawtoothRemovalDetectionThreshold;

    % Set a maximum detection threshold. If the response is greater than this then this is hihgly suspected to not be a residual sawtooth but somethign
    % completely different perhaps a giant transit.
    maxDetectionThreshold = pdcInputObject.pdcModuleParameters.thrusterSawtoothRemovalMaxDetectionThreshold;

    % The maximum number of iterations to remove residual exponential spikes
    % Set to half the average distance between thruster firings.
    nMaxIterations = pdcInputObject.pdcModuleParameters.thrusterSawtoothRemovalMaxIterations;
    
    if (debugEnabled)
        responseFigure = figure;
    end

    pdctic = tic;
    disp('presearch_data_conditioning: identifying and removing residual spikes...');
    

    %******************************
    % Detect outliers and gap them
    % Do this before exponential thresholding so that the exponential does not detect on single outlier cadences.

    [ outliers, targetDataStruct ] = pdc_detect_outliers(targetDataStruct, pdcInputObject.pdcModuleParameters, pdcInputObject.gapFillConfigurationStruct);
    

    % Fill the gaps.
    % -- using simple (but fast!) gap filling
    [targetDataStruct, ~] = pdc_fill_gaps(targetDataStruct, pdcInputObject.cadenceTimes);
    
    % TODO:  decide if these should be flagged as outliers.

    %******************************
    % Identify exponential spikes right before each thruster firing using an exponential filter
    % Iterate using the following method:
    % 1) Identify the threshold crossing events via exponential filter.
    % 2) If no threshold crossing events then exit
    % 3) Gap and fill the first ungapped cadence before each thruster firing event identified in 1)
    % 4) Goto to 1)
    % What this does is work it's way down each residual spike, gaping progressively more and more cadences until the residual spike disappears. 

    nCadences = length(targetDataStruct(1).values);
    cadences = 1 : nCadences;
    for iTarget = 1 : length(targetDataStruct)

        for iIter = 1 : nMaxIterations
            % Gaps should be filled
            flux = targetDataStruct(iTarget).values;
            gaps = targetDataStruct(iTarget).gapIndicators;
            response = exponential_filter_response (flux, thrusterFiringFlag);
            response = abs(response);
            
            thresholdThisTarget     = detectionThreshold * 1.4826*mad(response(thrusterFiringFlag),1);
            maxThresholdThisTarget  = maxDetectionThreshold * 1.4826*mad(response(thrusterFiringFlag),1);
           %responseAboveThreshold  = find(response > thresholdThisTarget ); 
            responseAboveThreshold  = find(response > thresholdThisTarget & response < maxThresholdThisTarget); 
            
            % debug plotting
            if (debugEnabled)
                % Plot the Light Curve
                subplot(2,1,1);
                plot(flux, '-*');
                hold on;
                plot(cadences(gaps), flux(gaps), 'dk', 'MarkerSize', 10');
                plot(cadences(thrusterFiringCadences), flux(thrusterFiringCadences), 'oc', 'MarkerSize', 10');
                plot(cadences(responseAboveThreshold-1), flux(responseAboveThreshold-1), 'or', 'MarkerSize', 10');
                legend('Flux', 'Gap Indicators', 'Thruster Firing', 'Cadence Before Response Above Threshold', 'Location', 'Best');
                title(['Filter Response to target ', num2str(iTarget), ' of ', num2str(length(targetDataStruct)), ...
                        '; iteration = ', num2str(iIter), ' of ' , num2str(nMaxIterations)]);
                hold off;
            
                % Plot the response
                subplot(2,1,2);
                plot(response, '*r');
                hold on;
                plot(cadences(responseAboveThreshold), response(responseAboveThreshold), 'or', 'MarkerSize', 10');
                plot(cadences, repmat(thresholdThisTarget, [nCadences,1]), '-m');
                if (any(response  > maxThresholdThisTarget))
                    plot(cadences, repmat(maxThresholdThisTarget, [nCadences,1]), '-c');
                    legend('Filter Response', 'Response Above Threshold', 'Threshold', 'Maximum Threshold', 'Location', 'Best');
                else
                    legend('Filter Response', 'Response Above Threshold', 'Threshold', 'Location', 'Best');
                end
                hold off;
                pause;
            end

            if (debugEnabled && any(response  > maxThresholdThisTarget))
                display(['Spike detection hit max threshold for target index ', num2str(iTarget)]);
            end

            % If no found threshold corssing events then exit and continue to the next target
            if (isempty(responseAboveThreshold))
                break;
            end
            
            % Remove the residual
            % Begin by gapping and filling the first cadence before each thruster firing that resulted in a threshold crossing event
            targetDataStruct(iTarget).gapIndicators(responseAboveThreshold-iIter) = true;
            [targetDataStruct(iTarget), ~] = pdc_fill_gaps(targetDataStruct(iTarget), pdcInputObject.cadenceTimes);
        end

    end

    if (debugEnabled)
        close(responseFigure);
%       error('REMOVE THIS!');
    end
    
    duration = toc(pdctic);
    disp(['Residual Spikes detected and removed: ' num2str(duration) ' seconds = '  num2str(duration/60) ' minutes']);

end

%%*************************************************************************************************************
% This is the filter response function. It's really simple. It just takes a very simple exponential function and passes it along the flux about each 
% thruster firing -- simple travelling window detection. 
% A least-squares fit of the window to the filter is then used to find the fit coefficient (I.E. the filter response at each
% cadence). We only want the response to the filter and not the DC offset so ignore the reponse to the offset.
%
% Robustfit could be used but is a lot slower to run. Likewise, regress is a pre-packaged function but we need to call the fitter many times so instead we 
% just use a very basic least-squares fit based on the code in the Matlab function 'regress'.
%

function [response] = exponential_filter_response (flux, thrusterFiringFlag)

    % Filter length should be up to the average distance between thruster
    % firings
    thrusterFiringCadences = find(thrusterFiringFlag);
    filterLength = median(diff(thrusterFiringCadences));

    b = zeros(length(flux),2);

    % A simple exponential function filter normalized to 1
    filt = [exp([1:filterLength]) / exp(filterLength)]';


    % Add ones to filter
    X = [ones(length(filt),1) filt]; 

    nCadences = length(flux);
    nThrusterFirings = length(thrusterFiringCadences);
    for i = 1 : nThrusterFirings

        thrusterFiringCadence = thrusterFiringCadences(i);

        % Cannot search within a filterlength of the edge
        if (thrusterFiringCadence  < filterLength+1 || thrusterFiringCadence  > nCadences - filterLength)
            continue;
        end

        % Use simple linear least-squares fitting
        y = flux(thrusterFiringCadence - filterLength: thrusterFiringCadence - 1);
        % Use the rank-revealing QR to remove dependent columns of X.
        [Q,R,perm] = qr(X,0);
        b(thrusterFiringCadence ,perm) = R \ (Q'* y);

    end

    % Want response to the filter, not the ones
    response = b(:,2);

end

