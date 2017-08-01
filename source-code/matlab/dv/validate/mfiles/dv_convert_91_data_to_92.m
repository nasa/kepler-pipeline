%% dv_convert_91_data_to_92
%
% function dvDataStruct = dv_convert_91_data_to_92(dvDataStruct)
%
% Update 9.1-era DV input structures to 9.2. This is useful when testing
% with existing data sets.
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

function dvDataStruct = dv_convert_91_data_to_92(dvDataStruct)

% Add new anomaly flags.
if ~isfield(dvDataStruct.dvCadenceTimes.dataAnomalyFlags, 'planetSearchExcludeIndicators')
    dvDataStruct.dvCadenceTimes.dataAnomalyFlags.planetSearchExcludeIndicators = ...
        false(size(dvDataStruct.dvCadenceTimes.dataAnomalyFlags.excludeIndicators));
end

% Add new TCE fields.
nTargets = length(dvDataStruct.targetStruct);

for iTarget = 1 : nTargets
    nTces = length(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent);
    for iTce = 1 : nTces
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce), 'maxSesInMes')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).maxSesInMes = ...
                dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).maxSingleEventSigma;
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce), ...
                'deemphasizedNormalizationTimeSeries')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).deemphasizedNormalizationTimeSeries = ...
                ones(size(dvDataStruct.dvCadenceTimes.gapIndicators));
        end
    end
end

% Add new DV parameters.
if ~isfield(dvDataStruct.dvConfigurationStruct, 'koiMatchingEnabled')
    dvDataStruct.dvConfigurationStruct.koiMatchingEnabled = true;
end

if ~isfield(dvDataStruct.dvConfigurationStruct, 'koiMatchingThreshold')
    dvDataStruct.dvConfigurationStruct.koiMatchingThreshold = 0.75;
end

% Add new TPS parameter.
if ~isfield(dvDataStruct.tpsConfigurationStruct, 'maxPeriodParameter')
    dvDataStruct.tpsConfigurationStruct.maxPeriodParameter = 0.01696;
end

% Add new planet fit parameter.
if ~isfield(dvDataStruct.planetFitConfigurationStruct, ...
        'deemphasisWeightsEnabled')
    dvDataStruct.planetFitConfigurationStruct.deemphasisWeightsEnabled = false;
end

% Add new difference image parameter.
if ~isfield(dvDataStruct.differenceImageConfigurationStruct, ...
        'overlappedTransitExclusionEnabled')
    dvDataStruct.differenceImageConfigurationStruct.overlappedTransitExclusionEnabled = false;
end

% Add new bootstrap parameters.
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'useTceTrialPulseOnly')
    dvDataStruct.bootstrapConfigurationStruct.useTceTrialPulseOnly = true;
end
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'maxAllowedMes')
    dvDataStruct.bootstrapConfigurationStruct.maxAllowedMes = -1;
end
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'maxAllowedTransitCount')
    dvDataStruct.bootstrapConfigurationStruct.maxAllowedTransitCount = -1;
end
if ~isfield(dvDataStruct.bootstrapConfigurationStruct, 'convolutionMethodEnabled')
    dvDataStruct.bootstrapConfigurationStruct.convolutionMethodEnabled = true;
end

% Add empty transit model descriptions if necessary.
if ~isfield(dvDataStruct, 'transitParameterModelDescription')
    dvDataStruct.transitParameterModelDescription = '';
end
if ~isfield(dvDataStruct, 'transitNameModelDescription')
    dvDataStruct.transitNameModelDescription = '';
end

% Add empty transits array if necessary.
for iTarget = 1 : nTargets
    if ~isfield(dvDataStruct.targetStruct(iTarget), 'transits')
        dvDataStruct.targetStruct(iTarget).transits = [];
    end
end

% Add rolling band target quality flags if necessary.
if ~isfield(dvDataStruct.targetStruct(1), 'rollingBandContamination')
    apertureTimeSeries = struct( ...
        'values', zeros(size(dvDataStruct.dvCadenceTimes.gapIndicators)), ...
        'gapIndicators', true(size(dvDataStruct.dvCadenceTimes.gapIndicators)));
    for iTarget = 1 : nTargets
        dvDataStruct.targetStruct(iTarget).rollingBandContamination.optimalAperture = ...
            apertureTimeSeries;
        dvDataStruct.targetStruct(iTarget).rollingBandContamination.fullAperture = ...
            apertureTimeSeries;
    end
end

if ~isfield( dvDataStruct.tpsConfigurationStruct, 'chiSquareGofThreshold' ) 
    dvDataStruct.tpsConfigurationStruct.chiSquareGofThreshold = 7.5;
end

if ~isfield( dvDataStruct.tpsConfigurationStruct, 'sesProbabilityThreshold' ) 
    dvDataStruct.tpsConfigurationStruct.sesProbabilityThreshold = 5.0;
end

if isfield( dvDataStruct.tpsConfigurationStruct, 'chiSquare1Threshold' ) 
    dvDataStruct.tpsConfigurationStruct = rmfield( ...
        dvDataStruct.tpsConfigurationStruct, 'chiSquare1Threshold');
end

return
