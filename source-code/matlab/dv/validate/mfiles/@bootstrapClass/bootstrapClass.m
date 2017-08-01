function bootstrapObject = bootstrapClass(bootstrapInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bootstrapObject = bootstrapClass(bootstrapInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% bootstrapClass.m - Class Constructor
%
% The bootstrap class constructor takes in the module parameters necessary
% to build the null distribution.  Single event statistics for each trial 
% pulse is degapped and sorted in descending order.  Histogram tails are
% dynamically determined based on the distribution of single event
% statistics.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS -
%      bootstrapInputStruct has the following fields:
%           targetNumber                    [int]
%           keplerId                        [int]
%           planetNumber                    [int]
%           histogramBinWidth               [float]
%           binsBelowSearchTransitThreshold [int]
%           searchTransitThreshold          [float]
%           bootstrapSkipCount              [int]
%           bootstrapAutoSkipCountEnabled   [logical]
%           bootstrapMaxIterations          [float]
%           bootstrapMaxNumberBins          [int]
%           bootstrapUpperLimitFactor       [int]
%           observedTransitCount            [float]
%           singleEventStatistics           [struct]
%           dvFiguresRootDirectory          [string]
%           debugLevel                      [logical]
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUTS -
%       bootstrapObject has the following fields:
%           targetNumber                   [int]
%           keplerId                       [int]
%           planetNumber                   [int]
%           histogramBinWidth              [float]
%           binsBelowSearchTransitThreshold[int]
%           nullTailMinSigma               [int]
%           nullTailMaxSigma               [float]
%           searchTransitThreshold         [float]
%           bootstrapSkipCount             [int]
%           bootstrapAutoSkipCountEnabled  [logical]       
%           bootstrapMaxIterations         [float]
%           bootstrapMaxNumberBins         [int]
%           bootstrapUpperLimitFactor      [int]
%           observedTransitCount           [float]
%           degappedSingleEventStatistics  [struct]
%           numberPulseWidths              [int]
%           dvFiguresRootDirectory         [string]
%           debugLevel                     [logical]
%
%           degappedSingleEventStatistics  has the following fields:
%                   trialTransitPulseDuration                       [float]
%                   degappedSortedCorrelationTimeSeries       [float array]
%                   degappedSortedNormalizationTimeSeries     [float array]
%                   lengthSES                                         [int]
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

% extract needed inputs
singleEventStatistics = bootstrapInputStruct.singleEventStatistics;
convolutionMethodEnabled = bootstrapInputStruct.convolutionMethodEnabled;
deemphasizeQuartersWithoutTransits = bootstrapInputStruct.deemphasizeQuartersWithoutTransits;
trialTransitDuration = bootstrapInputStruct.trialTransitDuration;

% Available debugLevels for bootstrap = 0, 1, 2.  Set anything above 
% debugLevel of 2 to 2.
if bootstrapInputStruct.debugLevel > 2
    bootstrapInputStruct.debugLevel = 2;
end

% Fields that need to be appended and populated
bootstrapInputStruct.nullTailMinSigma = 0;
bootstrapInputStruct.nullTailMaxSigma = 0;

% compute the observed number of transits
if convolutionMethodEnabled
    
    % convolution method only supports one pulse
    bootstrapTceTrialPulseOnly = true;
    
    if isequal(bootstrapInputStruct.observedTransitCount,-1)
    
        % parameters specific to this method
        cadenceDurationInMinutes = bootstrapInputStruct.cadenceDurationInMinutes;
        midTimestamp = bootstrapInputStruct.firstMidTimestamp;
        orbitalPeriodInDays = bootstrapInputStruct.orbitalPeriodInDays;
        epochInMjd = bootstrapInputStruct.epochInMjd;
        superResolutionFactor = bootstrapInputStruct.superResolutionFactor;
        deemphasizedNormalizationTimeSeries = bootstrapInputStruct.deemphasizedNormalizationTimeSeries;

        % get the event timing and number of transits
        cadencesPerDay = get_unit_conversion('day2min') / cadenceDurationInMinutes;
        orbitalPeriodInCadences = superResolutionFactor * cadencesPerDay * orbitalPeriodInDays;
        epochInCadences = superResolutionFactor * cadencesPerDay * epochInMjd - superResolutionFactor * cadencesPerDay * midTimestamp ;

        % take care of numerical precision issues
        periodErrorTolerance = 3 * eps(round(orbitalPeriodInCadences));
        epochErrorTolerance = 3 * sqrt( eps(superResolutionFactor * cadencesPerDay * epochInMjd)^2 + ...
            eps(superResolutionFactor * cadencesPerDay * midTimestamp)^2 );
        if abs((round(orbitalPeriodInCadences) - orbitalPeriodInCadences)) <= periodErrorTolerance
            orbitalPeriodInCadences = round(orbitalPeriodInCadences);
        end
        if abs((round(epochInCadences) - epochInCadences)) <= epochErrorTolerance
            % make sure that by rounding we dont end up with a phase that is
            % greater than or equal to the period
            if round(epochInCadences) < orbitalPeriodInCadences
                epochInCadences = round(epochInCadences);
            end
        end

        % if the period was rounded, but the phase wasnt then just make sure
        % the phase is less than the period
        if epochInCadences >= orbitalPeriodInCadences
            epochInCadences = orbitalPeriodInCadences - 1;
        end

        normalizationTimeSeriesHiRes = collect_cadences_to_deemphasize( deemphasizedNormalizationTimeSeries, superResolutionFactor);
        [indexOfSesAdded, ~] = find_ses_in_mes( normalizationTimeSeriesHiRes, ...
            normalizationTimeSeriesHiRes, orbitalPeriodInCadences, epochInCadences ) ;

        bootstrapInputStruct.observedTransitCount = sum( indexOfSesAdded ~= -1 );
    end
    
else
    bootstrapTceTrialPulseOnly = bootstrapInputStruct.bootstrapTceTrialPulseOnly;
end

if bootstrapTceTrialPulseOnly
    pulseIndicator=[singleEventStatistics.trialTransitPulseDuration] == trialTransitDuration;
    singleEventStatistics = singleEventStatistics(pulseIndicator);
end

% Assemble SES gapping information.  Require that correlation and
% normalization time series have same non-gapped datapoints
nPulseWidths = length(singleEventStatistics);
pulsesToRemove = false(nPulseWidths,1);

for iPulse = 1:nPulseWidths
    sesCorrelationGaps   = singleEventStatistics(iPulse).correlationTimeSeries.gapIndicators;
    sesNormalizationGaps = singleEventStatistics(iPulse).normalizationTimeSeries.gapIndicators;

    if ~all(sesCorrelationGaps == sesNormalizationGaps) || (~any(~sesCorrelationGaps))
        pulsesToRemove(iPulse) = true;
    end
end

singleEventStatistics(pulsesToRemove) = [];
nPulses = length( singleEventStatistics );
bootstrapInputStruct.numberPulseWidths = nPulses;

% adjust weights if we are deemphasizing quarters that have no transits
if (deemphasizeQuartersWithoutTransits && convolutionMethodEnabled && nPulses > 0)
    indexOfSesAdded = indexOfSesAdded(indexOfSesAdded ~= -1);
    indexOfSesAdded = indexOfSesAdded + 1; % convert to 1-based
    indexOfSesAdded = ceil( indexOfSesAdded / superResolutionFactor );
    quarters = bootstrapInputStruct.quarters;
    contributingQuarters = unique( quarters(indexOfSesAdded) );
    deemphasisIndicator = ~ismember(quarters, contributingQuarters);
    singleEventStatistics.deemphasisWeights.values(deemphasisIndicator) = 0;
end

if ~convolutionMethodEnabled
% Degap each SES for each pulseWidth 
    bootstrapInputStruct.degappedSingleEventStatistics = degap_ses(singleEventStatistics, convolutionMethodEnabled);
else
    bootstrapInputStruct.singleEventStatistics = singleEventStatistics;
end

% Order the fields to avoid getting error messages
bootstrapObjectFieldOrder = get_bootstrap_object_field_order( convolutionMethodEnabled );

% remove any extra fields that are not needed
allFields = fieldnames( bootstrapInputStruct );
fieldsToRemove = allFields( ~ismember(allFields, bootstrapObjectFieldOrder) );
bootstrapInputStruct = rmfield( bootstrapInputStruct, fieldsToRemove );

% order the fields
bootstrapInputStruct = orderfields(bootstrapInputStruct, bootstrapObjectFieldOrder);

% Instantiate bootstrap object
bootstrapObject = class(bootstrapInputStruct, 'bootstrapClass');

if ~convolutionMethodEnabled
    if ~isempty(bootstrapInputStruct.degappedSingleEventStatistics) && ...
            bootstrapInputStruct.degappedSingleEventStatistics.lengthSES > 0
        % Determine nullTailMin and nullTailMax
        bootstrapObject = get_histogram_bin_limits(bootstrapObject);
    end
end

return


%--------------------------------------------------------------------------
% Subfunction to degap and sort single event statistics structures
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function degappedSingleEventStatistics = degap_ses(structToDegap)

if isempty(structToDegap)
    degappedSingleEventStatistics = [];
    return
end

nPulseWidths = length(structToDegap);

degappedSingleEventStatistics = repmat(struct('trialTransitPulseDuration', [], ...
    'degappedSortedCorrelationTimeSeries', [], 'degappedSortedNormalizationTimeSeries', [], ...
    'lengthSES', -1), 1, nPulseWidths);

for iPulse = 1:nPulseWidths
    
    % Assemble SES gapping information.  Require that correlation and
    % normalization time series have same non-gapped datapoints
    sesCorrelationGaps   = structToDegap(iPulse).correlationTimeSeries.gapIndicators;
    sesNormalizationGaps = structToDegap(iPulse).normalizationTimeSeries.gapIndicators;
    
    % Assemble SES statistics information:
    sesCorrelation   = structToDegap(iPulse).correlationTimeSeries.values;
    sesNormalization = structToDegap(iPulse).normalizationTimeSeries.values;
    deemphasisWeights = structToDegap(iPulse).deemphasisWeights.values;
    
    isForSes = true;

    % Apply the deemphasis weights for the SES time series sorting - This
    % avoids having NaN's in the SES vector during sorting which would throw
    % off the sort and position all the completely deemphasized cadences first
    [sesCorrelation, sesNormalization] = ...
        apply_deemphasis_weights( sesCorrelation, sesNormalization, ...
        deemphasisWeights, isForSes );

    % Generate gap-free SES vectors.
    sesCorrelationDegapped   = sesCorrelation(~sesCorrelationGaps);
    sesNormalizationDegapped = sesNormalization(~sesNormalizationGaps);
    deemphasisWeightsDegapped = deemphasisWeights(~sesCorrelationGaps);

    % remove cadences where the deemphasis weight is zero
    sesCorrelationDegapped = sesCorrelationDegapped(deemphasisWeightsDegapped~=0);
    sesNormalizationDegapped = sesNormalizationDegapped(deemphasisWeightsDegapped~=0);

    % Sort SES.  The sorting index is that of the SES timeseries
    sesTimeseries = sesCorrelationDegapped ./ sesNormalizationDegapped;
    [sesTimeseriesSorted sesSortIndex] = sort(sesTimeseries, 'descend');

    % now apply deemphasis weights for the MES construction that will take
    % place later in the bootstrap
    sesCorrelation   = structToDegap(iPulse).correlationTimeSeries.values;
    sesNormalization = structToDegap(iPulse).normalizationTimeSeries.values;
    isForSes = false;

    [sesCorrelation, sesNormalization] = ...
        apply_deemphasis_weights( sesCorrelation, sesNormalization, ...
        deemphasisWeights, isForSes );

    sesCorrelationDegapped   = sesCorrelation(~sesCorrelationGaps);
    sesNormalizationDegapped = sesNormalization(~sesNormalizationGaps);
    sesCorrelationDegapped = sesCorrelationDegapped(deemphasisWeightsDegapped~=0);
    sesNormalizationDegapped = sesNormalizationDegapped(deemphasisWeightsDegapped~=0);

    sesCorrelationDegappedSorted   = sesCorrelationDegapped(sesSortIndex);
    sesNormalizationDegappedSorted = sesNormalizationDegapped(sesSortIndex);

    % Populate degappedSingleEventStatisticsStruct
    degappedSingleEventStatistics(iPulse).trialTransitPulseDuration = ...
        structToDegap(iPulse).trialTransitPulseDuration;

    degappedSingleEventStatistics(iPulse).degappedSortedCorrelationTimeSeries = ...
        sesCorrelationDegappedSorted;

    degappedSingleEventStatistics(iPulse).degappedSortedNormalizationTimeSeries = ...
        sesNormalizationDegappedSorted;

    degappedSingleEventStatistics(iPulse).lengthSES = length(sesCorrelationDegappedSorted);

end

return

%--------------------------------------------------------------------------
% Subfunction to return the field order
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function bootstrapObjectFieldOrder = get_bootstrap_object_field_order( ...
    convolutionMethodEnabled )

if convolutionMethodEnabled
    bootstrapObjectFieldOrder = { ...
        'targetNumber', ...
        'keplerId', ...
        'planetNumber', ...
        'searchTransitThreshold', ...
        'observedTransitCount', ...
        'singleEventStatistics', ...
        'convolutionMethodEnabled', ...
        'cadenceDurationInMinutes', ...
        'histogramBinWidth', ...
        'bootstrapMaxNumberBins', ...
        'sesZeroCrossingWidthDays', ...
        'sesZeroCrossingDensityFactor', ...
        'nSesPeaksToRemove', ...
        'sesPeakRemovalThreshold', ...
        'sesPeakRemovalFloor', ...
        'bootstrapResolutionFactor', ...
        'nullTailMinSigma', ...
        'nullTailMaxSigma', ...
        'dvFiguresRootDirectory', ...
        'debugLevel' };
else
    bootstrapObjectFieldOrder = { ...
        'targetNumber', ...
        'keplerId', ...
        'planetNumber', ...
        'histogramBinWidth', ...
        'binsBelowSearchTransitThreshold', ...
        'nullTailMinSigma', ...
        'nullTailMaxSigma', ...
        'searchTransitThreshold', ...
        'bootstrapSkipCount', ...
        'bootstrapAutoSkipCountEnabled', ...
        'bootstrapMaxIterations', ...
        'bootstrapMaxNumberBins', ...
        'bootstrapUpperLimitFactor', ...
        'bootstrapMaxAllowedMes', ...
        'bootstrapMaxAllowedTransitCount', ...
        'observedTransitCount', ...
        'degappedSingleEventStatistics', ...
        'numberPulseWidths', ...
        'convolutionMethodEnabled', ...
        'dvFiguresRootDirectory', ...
        'debugLevel' };
end

return



