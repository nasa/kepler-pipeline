%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [outlierStruct, targetDataStruct, eventsStruct] = ...
% pdc_detect_outliers(targetDataStruct, pdcModuleParameters, ...
% gapFillParameters)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This PDC function detects outliers in the target flux time series by
% making successive calls to identify_giant_transits to identify first
% negative-going and then positive-going outliers. The detection threshold
% is specified by a PDC module parameter. Multiple-cadence events are
% excluded and hence not identified as outliers; these are considered to be
% likely astrophysical in nature (i.e. transits, eclipses, flares). Single
% cadence outliers separated by a single cadence data gap from any other
% event that exceeds the detection threshold are considered to be part of a
% multiple cadence event and are also excluded from identification as
% outliers.
%
% The resulting negative- and positive-going single cadence outliers are
% merged into a single chronological outlier set. On the off chance that
% any of these single cadence outliers were identified as both negative-
% and positive-going events, such outliers are also excluded from detection
% as outliers.
%
% For targets with known KOIs or eclipsing binaries the known transits are 
% recorded in the targetDataStruct (see pdcTransitClass). These cadences are
% also excluded from detection as outliers. This is to protect from the 
% problem where cadences in transits are sometimes incorrectly flagged as
% outliers.
%
% For each target with detected single cadence outliers, the indices of the
% outliers are returned along with the outlying target flux values and
% associated uncertainties. The outlying values of the target flux time
% series and associated uncertainties are set to 0 and the respective gap
% indicators set to true. The updated target flux time series are then
% returned in addition to the outlier details. The newly gapped values are
% subsequently filled in PDC.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Inputs:
%
% 1. targetDataStruct: [struct array]  time series for outlier identification,
%                                          with one element per target as defined
%                                          below
%
%      values: [double array]              time series values for the given target
%      uncertainties: [double array]       time series uncertainties for given
%                                          target
%      gapIndicators: [logical array]      time series gap indicators for the given
%                                          target
%      transit: [struct array]             list of known eclipsing binaries and KOIs 
%                                          associated with this target.
%                                          (see pdcTransitClass.m)
%
% 2. pdcModuleParameters: [struct]         see comments in pdc_matlab_controller
%                                          header
%
% 3. gapFillParameters: [struct]           see comments in pdc_matlab_controller
%                                          header
%
%
% Outputs:
%
% 1. outlierStruct: [struct array]         outlier details, with one element per
%                                          target as defined below
%
%      values: [double array]              values of detected outliers, with one
%                                          element per outlier
%      uncertainties: [double array]       uncertainties of detected outliers, with
%                                          one element per outlier
%      indices: [int array]                one-based indices of detected outliers,
%                                          with one element per outlier; converted
%                                          to zero-based indexing when the PDC
%                                          output structure is populated and
%                                          returned to Java
%
% 2. targetDataStruct: [struct array]  same as defined above, where values and
%                                          uncertainties of identified outliers are
%                                          set to 0 and associated gapIndicators are
%                                          set to true
%
% 3. eventStruct: [struct array]           giant transit details, with one element
%                                          per target as defined below
%
%         indexOfAstroEvents: [int array]  cadences of astrophysical events
%      indexOfNegativeEvents: [int array]  cadences of negative-going giant transits
%      indexOfPositiveEvents: [int array]  cadences of positive-going "giant transits"
%
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
function [outlierStruct, targetDataStruct, eventStruct] = pdc_detect_outliers( ...
                            targetDataStruct, pdcModuleParameters, gapFillParameters)

% Define constant.
MADS_PER_GAUSSIAN_SIGMA = 1.4826;

% Get and set the parameter values for outlier detection. Note that the
% outlierThresholdXFactor has historically been defined as the multiplier
% for standard deviations rather than the multiplier for MADs.
outlierThresholdXFactor = pdcModuleParameters.outlierThresholdXFactor;
debugLevel = pdcModuleParameters.debugLevel;

gapFillParameters.madXFactor = ...
    outlierThresholdXFactor * MADS_PER_GAUSSIAN_SIGMA;

% Get number of targets.
nTargets = length(targetDataStruct);

% Initialize the output structures.
outlierStruct = repmat(struct( ...
    'values', [], ...
    'uncertainties', [], ...
    'indices', [] ), [1, nTargets]);

eventStruct = repmat(struct( ...
    'indexOfAstroEvents', [], ...
    'indexOfNegativeEvents', [], ...
    'indexOfPositiveEvents', [] ), [1, nTargets]);
    
% Process the targets one by one.
for iTarget = 1 : nTargets
    
    % Get the target flux time series and gap indicators.
    targetFlux = targetDataStruct(iTarget).values;
    targetFluxUncertainties = targetDataStruct(iTarget).uncertainties;
    targetFluxDataGapIndicators = ...
        targetDataStruct(iTarget).gapIndicators;

    % if not enough un-gapped cadences then skip
    % 
    if (~any(~targetFluxDataGapIndicators))
        continue;
    end

    % Get the cadences to mask about transits
    transitGapIndicators = pdcTransitClass.find_cumulative_transit_gaps (targetDataStruct, iTarget);

    %***
    % Detect the negative-going outliers 
    [indexOfNegativeEvents, ~, fittedTrend] = identify_giant_transits(targetFlux, ...
        targetFluxDataGapIndicators, gapFillParameters);
    % Save only the single cadence indicators.
    [negativeEventIndicators] = ...
        set_event_indicators_for_single_cadence_events( ...
        indexOfNegativeEvents, targetFluxDataGapIndicators, true);
    % Save only those not falling on known transits
    negativeEventIndicators = negativeEventIndicators & ~transitGapIndicators;
    
    %***
    % Detect the positive-going outliers but re-use the fitted trend
    [indexOfPositiveEvents] = identify_giant_transits(-targetFlux, ...
        targetFluxDataGapIndicators, gapFillParameters, [], -fittedTrend );
    % Save only the single cadence indicators.
    [positiveEventIndicators] = ...
        set_event_indicators_for_single_cadence_events( ...
        indexOfPositiveEvents, targetFluxDataGapIndicators, true);
    % Save only those not falling on known transits
    positiveEventIndicators = positiveEventIndicators & ~transitGapIndicators;
    
    % Merge the negative- and positive-event indicators, and populate the
    % outlier structure for the given target. Exclude any events which were
    % identified as both negative-going and positive-going.
    indexOfOutliers = ...
        find(negativeEventIndicators | positiveEventIndicators);
    indexOfOutliers = setdiff(indexOfOutliers, ...
        intersect(indexOfNegativeEvents, indexOfPositiveEvents));
    
    if ~isempty(indexOfOutliers)
        outlierStruct(iTarget).indices = indexOfOutliers;
        outlierStruct(iTarget).values = targetFlux(indexOfOutliers);
        outlierStruct(iTarget).uncertainties = ...
            targetFluxUncertainties(indexOfOutliers);
    end % if
    
    % Populate the event struct.
    eventStruct(iTarget).indexOfNegativeEvents = ...
        indexOfNegativeEvents;
    eventStruct(iTarget).indexOfPositiveEvents = ...
        indexOfPositiveEvents;
    eventStruct(iTarget).indexOfAstroEvents = ...
        unique([indexOfNegativeEvents; indexOfPositiveEvents]);
    
    % Plot the results if the debug level is set.
    if debugLevel
        
        clf;
        
        plot(find(~targetFluxDataGapIndicators), ...
            targetFlux(~targetFluxDataGapIndicators), '.-b');
        hold on
        plot(indexOfNegativeEvents, ...
            targetFlux(indexOfNegativeEvents), 'or');
        plot(find(negativeEventIndicators), ...
            targetFlux(negativeEventIndicators), 'og');
        plot(indexOfPositiveEvents, ...
            targetFlux(indexOfPositiveEvents), 'sm');
        plot(find(positiveEventIndicators), ...
            targetFlux(positiveEventIndicators), 'sc');
        str = sprintf('Outlier Detection: Target = %d', iTarget);
        title(str);
        xlabel('Cadence');
        ylabel('Flux (e-/cadence)')
        pause(1)
        
    end % if debugLevel
    
    % Set the appropriate gap indicators in the original target flux time
    % series for the given target if there were any outliers. These time
    % series are also outputs for this function. The gaps are subsequently
    % filled later in PDC.
    if ~isempty(indexOfOutliers)
        targetDataStruct(iTarget).values(indexOfOutliers) = 0;
        targetDataStruct(iTarget).uncertainties(indexOfOutliers) = 0;
        targetDataStruct(iTarget).gapIndicators(indexOfOutliers) = true;
    end
    
end % for iTarget

% Return.
return


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [eventIndicators] = ...
% set_event_indicators_for_single_cadence_events(indexOfEvents, ...
% gapIndicators, bridgeGapsEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Remove events on consecutive cadences and then set cadence indicators for
% remaining single cadence events. Optionally bridge any single cadence
% gaps so that a "single" cadence event separated by a single cadence gap
% from any other event is *not* considered a single cadence outlier.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [eventIndicators] = ...
set_event_indicators_for_single_cadence_events(indexOfEvents, ...
gapIndicators, bridgeGapsEnabled)

% Check optional argument.
if ~exist('bridgeGapsEnabled', 'var')
    bridgeGapsEnabled = false;
end % if

% Initialize event indicators.
eventIndicators = false(size(gapIndicators));
eventIndicators(indexOfEvents) = true;

% Bridge single cadence gaps if desired.
if bridgeGapsEnabled
    eventIndicators = eventIndicators | ...
        gapIndicators & [false; eventIndicators(1 : end-1)] & ...
        [eventIndicators(2 : end); false];
end % if

% Remove events on consecutive cadences.
sequentialEventIndicators = eventIndicators(1 : end-1) & ...
    eventIndicators(2 : end);
eventIndicators([sequentialEventIndicators; false]) = false;
eventIndicators([false; sequentialEventIndicators]) = false;

% Return.
return
