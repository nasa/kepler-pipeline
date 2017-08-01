% make_tps_input_structure.m
% script to make PRF algorithm input structures from ETEM2 data.
% assumes the ETEM2 data was created with clean flag on.
% creates background-removed data appropriate for input directly to the PRF
% algorithm
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

%location = 'tpsProblem/run_long_m18o1s3';
location = pwd;
[module output channel] = infer_mod_out_from_location(location);
load([location filesep 'inputStructs.mat']);

keplerData = runParamsData.keplerData;
secondsPerLongCadence = keplerData.exposuresPerShortCadence*keplerData.shortsPerLongCadence ...
    * (keplerData.integrationTime + keplerData.transferTime);

runStartDate = runParamsData.simulationData.runStartDate;
duration = runParamsData.simulationData.runDuration;
startDateMjd = datestr2mjd(runStartDate);
endDateMjd = startDateMjd + duration;

tpsInputStruct.module = module;
tpsInputStruct.output = output;
tpsInputStruct.cadenceTimes = [];
tpsInputStruct.fcConstants = convert_fc_constants_java_2_struct();
tpsInputStruct.configMaps = retrieve_config_map();

backgroundConfigurationStruct = build_background_configuration_struct();

%%
% get the pixel data
pixStruct = get_pixel_time_series(location, 'targets', 1, 1); % setting the option to 1,0 leads to problems; possible bug in get_pixel_time-series when no CR  
% get the target mask definitions
targetMaskDefinitions = get_mask_definitions(location, 'targets');
% get the background data
backgroundData = get_pixel_time_series(location, 'background', 1, 1);
% get the target definitions
backgroundDefinitionStruct = get_target_definitions(location, 'background');
% get the background mask definitions
backMaskDefinitions = get_mask_definitions(location, 'background');

%
for i=1:size(pixStruct(1).pixelValues, 1)
    tpsInputStruct.cadenceTimes.startTimeStamps(i) = startDateMjd + (i-1)*secondsPerLongCadence; % start of period
    tpsInputStruct.cadenceTimes.midTimeStamps(i) = startDateMjd + (i-0.5)*secondsPerLongCadence; % halfway through first half
    tpsInputStruct.cadenceTimes.endTimeStamps(i) = startDateMjd + (i)*secondsPerLongCadence; % end of 15 minutes of period
    tpsInputStruct.cadenceTimes.gapIndicators = false;
    tpsInputStruct.cadenceTimes.requantEnabled = false;
end

% make the background pixel structure expected by the old PA background
% routines
nBackPixels = size(backgroundData, 2);
for p=1:nBackPixels
    % we have to group these into targets of 4 pixels each
    backTargetDef = backgroundDefinitionStruct(floor((p-1)/4) + 1);
    backTargetPixel = mod(p, 4) + 1;
    mask = backMaskDefinitions(backTargetDef.maskIndex);
    backgroundStruct(p).row = backTargetDef.referenceRow + 1 ...
        + mask.offsets(backTargetPixel).row;
    backgroundStruct(p).column = backTargetDef.referenceColumn + 1 ...
        + mask.offsets(backTargetPixel).column;
    backgroundStruct(p).timeSeries = backgroundData(:,p);
    backgroundStruct(p).uncertainties = ones(size(backgroundStruct(p).timeSeries));
    backgroundStruct(p).gapList = [];
end

backgroundCoeffStruct = fit_background_by_time_series(backgroundStruct, ...
    backgroundConfigurationStruct);

nTargets = length(pixStruct);
% build the target structure
% assume for now that there is only one target definition per star
if any(diff([pixStruct.keplerId] == 0))
    error('# of targets and # of target definitions not the same');
end

load([location filesep 'tadInputStruct.mat']);
load([location filesep 'catalogData.mat']);
optApData = tadInputStruct.coaResultStruct.optimalApertures;
% make the targetStarStruct with the fields expected by the old PA
% background routines
for t=1:nTargets
    maskIndex = pixStruct(t).maskIndex;
    mask = targetMaskDefinitions(maskIndex);
    
    targetStarStruct(t).keplerId = pixStruct(t).keplerId;
    kicIndex = find(catalogData.kicId == targetStarStruct(t).keplerId);
    tadIndex = find([optApData.keplerId] == targetStarStruct(t).keplerId);
    targetStarStruct(t).keplerMag = catalogData.keplerMagnitude(kicIndex);
    targetStarStruct(t).tadCrowdingMetric = optApData(tadIndex).crowdingMetric;
    targetStarStruct(t).ra = catalogData.ra(kicIndex);
    targetStarStruct(t).dec = catalogData.dec(kicIndex);
    targetStarStruct(t).referenceRow = pixStruct(t).referenceRow + 1;
    targetStarStruct(t).referenceColumn = pixStruct(t).referenceColumn + 1;
    targetStarStruct(t).gapIndices = [];
    
    % build the pixel time series structure for each target
    nPixels = size(pixStruct(t).pixelValues, 2);
    for p=1:nPixels
        targetStarStruct(t).pixelTimeSeriesStruct(p).row = ...
            targetStarStruct(t).referenceRow + mask.offsets(p).row;
        targetStarStruct(t).pixelTimeSeriesStruct(p).column = ...
            targetStarStruct(t).referenceColumn + mask.offsets(p).column;
        targetStarStruct(t).pixelTimeSeriesStruct(p).timeSeries = ...
            pixStruct(t).pixelValues(:,p);
        targetStarStruct(t).pixelTimeSeriesStruct(p).uncertainties = ...
            ones(size(targetStarStruct(t).pixelTimeSeriesStruct(p).timeSeries));
        targetStarStruct(t).pixelTimeSeriesStruct(p).gapList = [];
  
    end
    
    % mark the optimal pixels
    optimalPixelRows = optApData(tadIndex).referenceRow + 1+ [optApData(tadIndex).offsets.row];
    optimalPixelColumns = optApData(tadIndex).referenceColumn + 1 + [optApData(tadIndex).offsets.column];
    optimalPixels = [optimalPixelRows(:), optimalPixelColumns(:)];
    maskPixelRows = [targetStarStruct(t).pixelTimeSeriesStruct.row];
    maskPixelColumns = [targetStarStruct(t).pixelTimeSeriesStruct.column];
    maskPixels = [maskPixelRows(:), maskPixelColumns(:)];
    isInOptimalAperture = ismember(maskPixels, optimalPixels, 'rows');
    for p=1:length(targetStarStruct(t).pixelTimeSeriesStruct)
        targetStarStruct(t).pixelTimeSeriesStruct(p).isInOptimalAperture = isInOptimalAperture(p);
    end
end

% remove the background
% targetStarStruct = remove_background_from_targets(targetStarStruct, ...
%     backgroundCoeffStruct, [], backgroundConfigurationStruct);

% fix the field names to match the PRF spec
for t=1:nTargets
    nPixels = length(targetStarStruct(t).pixelTimeSeriesStruct);
    for p=1:nPixels
        targetStarStruct(t).pixelTimeSeriesStruct(p).values = ...
            targetStarStruct(t).pixelTimeSeriesStruct(p).timeSeries;
        targetStarStruct(t).pixelTimeSeriesStruct(p).gapIndices = ...
            targetStarStruct(t).pixelTimeSeriesStruct(p).gapList;
    end
    targetStarStruct(t).pixelTimeSeriesStruct = ...
        rmfield(targetStarStruct(t).pixelTimeSeriesStruct, ...
        {'timeSeries', 'gapList'});
end

tpsInputStruct.targetStarsStruct = targetStarStruct;

% save the result
save -v7.3 tpsInputStruct.mat tpsInputStruct

