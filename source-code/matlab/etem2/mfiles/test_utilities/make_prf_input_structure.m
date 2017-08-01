% script to make PRF algorithm input structures from ETEM2 data.
% assumes the ETEM2 data was created with clean flag on.
% creates background-removed data appropriate for input directly to the PRF
% algorithm
% 
% output of this script uses 0-based indexing
% 
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

clear;

fixIndexBase = 0; % set if using pre-index base fix ETEM data
calibrateData = 1; % set for prf noise study

channelStr = 'm14o4';
caseStr = '_source'; % set for prf noise study
% prfStr = 'z5f5F1';
% inputDirectory = ['output/prfData/assembled_' channelStr '_' prfStr];
inputDirectory = ['output/prf_noise_study/assembled_' channelStr caseStr];
location = [inputDirectory '/run_long_' channelStr 's1'];

[module output channel] = infer_mod_out_from_location(location);

nDithers = 121;
nCadencesPerDither = 2 ; % one without motion followed by one with motion
nCadences = nDithers*nCadencesPerDither ;
load([inputDirectory '/prfOffsetPattern.mat'], 'prfRa', 'prfDec', 'prfRoll', 'prfRaOffset', 'prfDecOffset', 'startDate');

startDateStr = startDate;
startDateMjd = datestr2mjd(startDateStr);
timePerDither = 1/48; % days at 30 minutes per dither
timePerCadence = timePerDither / 2 ;
duration = nCadences ;
endDateMjd = startDateMjd + duration;

prfInputStruct.ccdModule = module;
prfInputStruct.ccdOutput = output;
prfInputStruct.startCadence = 0;
prfInputStruct.endCadence = nDithers * nCadencesPerDither - 1;
prfInputStruct.cadenceTimes = [];
prfInputStruct.fcConstants = convert_fc_constants_java_2_struct();
prfInputStruct.geometryModelBlob = [];
prfInputStruct.calUncertaintyBlobsStruct.blobIndices = []; % get from paOutputs
prfInputStruct.configMaps = retrieve_config_map(startDateMjd, endDateMjd);

prfInputStruct.prfConfigurationStruct.numPrfsPerChannel = 1;
prfInputStruct.prfConfigurationStruct.prfOverlap = 0.1;
prfInputStruct.prfConfigurationStruct.subPixelRowResolution = 6;
prfInputStruct.prfConfigurationStruct.subPixelColumnResolution = 6;
prfInputStruct.prfConfigurationStruct.pixelArrayRowSize = 11;
prfInputStruct.prfConfigurationStruct.pixelArrayColumnSize = 11;
prfInputStruct.prfConfigurationStruct.maximumPolyOrder = 8;
prfInputStruct.prfConfigurationStruct.magnitudeRange = [12 12.5];
prfInputStruct.prfConfigurationStruct.crowdingThreshold = 0.5;
prfInputStruct.prfConfigurationStruct.contourCutoff = 1e-3;
prfInputStruct.prfConfigurationStruct.prfPolynomialType = 'not_scaled'; % 'standard' or 'not-scaled'
prfInputStruct.prfConfigurationStruct.debugLevel = 1;
prfInputStruct.prfConfigurationStruct.rowLimit = ...
    prfInputStruct.fcConstants.nMaskedSmear ...
    + [1 prfInputStruct.fcConstants.nRowsImaging];
prfInputStruct.prfConfigurationStruct.columnLimit = ...
    prfInputStruct.fcConstants.nLeadingBlack ...
    + [1 prfInputStruct.fcConstants.nColsImaging];
prfInputStruct.prfConfigurationStruct.regionMinSize = 0.3;
prfInputStruct.prfConfigurationStruct.regionStepSize = 0.05;
prfInputStruct.prfConfigurationStruct.minStars = 10;

prfInputStruct.pouConfigurationStruct.pouEnabled = false;
prfInputStruct.pouConfigurationStruct.compressionEnabled = true;
prfInputStruct.pouConfigurationStruct.numErrorPropVars = 30;
prfInputStruct.pouConfigurationStruct.maxSvdOrder = 10;
prfInputStruct.pouConfigurationStruct.pixelChunkSize = 2500;
prfInputStruct.pouConfigurationStruct.cadenceChunkSize = 240;
prfInputStruct.pouConfigurationStruct.interpDecimation = 24;
prfInputStruct.pouConfigurationStruct.interpMethod = 'linear';

prfInputStruct.motionConfigurationStruct.fitLowOrder = 3;
prfInputStruct.motionConfigurationStruct.aicOrderSelectionEnabled = true;
prfInputStruct.motionConfigurationStruct.fitMaxOrder = 8;
prfInputStruct.motionConfigurationStruct.rowFitOrder = 3;
prfInputStruct.motionConfigurationStruct.columnFitOrder = 3;
prfInputStruct.motionConfigurationStruct.fitMinPoints = 20;

backgroundConfigurationStruct = build_background_configuration_struct();
backgroundConfigurationStruct.fitOrder = 2;

cosmicRayConfigurationStruct = build_cr_configuration_struct();
prfInputStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model();
prfInputStruct.motionBlobsStruct = [];

%%
for i=1:length(prfRaOffset)
    prfInputStruct.spacecraftAttitudeStruct.ra.values(i) = prfRa(i);
    prfInputStruct.spacecraftAttitudeStruct.ra.uncertainties(i) = 1;
    prfInputStruct.spacecraftAttitudeStruct.ra.gapIndices = [];
    
    prfInputStruct.spacecraftAttitudeStruct.dec.values(i) = prfDec(i);
    prfInputStruct.spacecraftAttitudeStruct.dec.uncertainties(i) = 1;
    prfInputStruct.spacecraftAttitudeStruct.dec.gapIndices = [];
    
    prfInputStruct.spacecraftAttitudeStruct.roll.values(i) = prfRoll(i);
    prfInputStruct.spacecraftAttitudeStruct.roll.uncertainties(i) = 1;
    prfInputStruct.spacecraftAttitudeStruct.roll.gapIndices = [];
end

% add pointings for the 121 cadences with motion, and set their gap indicators; the gap
% indicator is zero-based, and the first cadence is good, so it's all odd numbers between
% 0 and (nCadences-1) ; all the bad cadences are set identical to the
% first cadence

v = prfInputStruct.spacecraftAttitudeStruct.ra.values ;
v1 = repmat(v(1),size(v)) ; v = [v ; v1] ; v = v(:)' ;
s = prfInputStruct.spacecraftAttitudeStruct.ra.uncertainties ;
s1 = repmat(s(1),size(s)) ; s = [s ; s1] ; s = s(:)' ;
gapList = 1:2:(nCadences-1) ; % gap every other cadence, first not gapped
prfInputStruct.spacecraftAttitudeStruct.ra.values = v ;
prfInputStruct.spacecraftAttitudeStruct.ra.uncertainties = s ;
prfInputStruct.spacecraftAttitudeStruct.ra.gapIndices = gapList ;

v = prfInputStruct.spacecraftAttitudeStruct.dec.values ;
v1 = repmat(v(1),size(v)) ; v = [v ; v1] ; v = v(:)' ;
s = prfInputStruct.spacecraftAttitudeStruct.dec.uncertainties ;
s1 = repmat(s(1),size(s)) ; s = [s ; s1] ; s = s(:)' ;
prfInputStruct.spacecraftAttitudeStruct.dec.values = v ;
prfInputStruct.spacecraftAttitudeStruct.dec.uncertainties = s ;
prfInputStruct.spacecraftAttitudeStruct.dec.gapIndices = gapList ;

v = prfInputStruct.spacecraftAttitudeStruct.roll.values ;
v1 = repmat(v(1),size(v)) ; v = [v ; v1] ; v = v(:)' ;
s = prfInputStruct.spacecraftAttitudeStruct.roll.uncertainties ;
s1 = repmat(s(1),size(s)) ; s = [s ; s1] ; s = s(:)' ;
prfInputStruct.spacecraftAttitudeStruct.roll.values = v ;
prfInputStruct.spacecraftAttitudeStruct.roll.uncertainties = s ;
prfInputStruct.spacecraftAttitudeStruct.roll.gapIndices = gapList ;

clear v v1 s s1

prfInputStruct.baseAttitudeIndex = find(prfRaOffset == 0 & prfDecOffset == 0) - 1;

% convert the baseAttitudeIndex to include the motion-contaminated cadences (should it be
% zero-based?)

prfInputStruct.baseAttitudeIndex = 2*prfInputStruct.baseAttitudeIndex;

%%

% set times for all cadences and set the gap indicators for the even-indexed ones
% (movement contaminated)

for i=1:nCadences
    prfInputStruct.cadenceTimes.startTimestamps(i) = startDateMjd + (i-1)*timePerCadence; % start of cadence
    prfInputStruct.cadenceTimes.midTimestamps(i) = startDateMjd + (i-0.5)*timePerCadence; % halfway through
    prfInputStruct.cadenceTimes.endTimestamps(i) = startDateMjd + (i-0.5)*timePerCadence; % end of cadence
    prfInputStruct.cadenceTimes.gapIndicators(i) = (mod(i,2)==0);
    prfInputStruct.cadenceTimes.requantEnabled(i) = false;
    prfInputStruct.cadenceTimes.cadenceNumbers(i) = i;
end
prfInputStruct.cadenceTimes.startTimestamps(prfInputStruct.cadenceTimes.gapIndicators) = 0;
prfInputStruct.cadenceTimes.midTimestamps(prfInputStruct.cadenceTimes.gapIndicators) = 0;
prfInputStruct.cadenceTimes.endTimestamps(prfInputStruct.cadenceTimes.gapIndicators) = 0;

prfInputStruct.cadenceTimes.startTimestamps = prfInputStruct.cadenceTimes.startTimestamps(:);
prfInputStruct.cadenceTimes.midTimestamps = prfInputStruct.cadenceTimes.midTimestamps(:); % halfway through
prfInputStruct.cadenceTimes.endTimestamps = prfInputStruct.cadenceTimes.endTimestamps(:); % end of cadence
prfInputStruct.cadenceTimes.gapIndicators = prfInputStruct.cadenceTimes.gapIndicators(:);
prfInputStruct.cadenceTimes.requantEnabled = prfInputStruct.cadenceTimes.requantEnabled(:);
prfInputStruct.cadenceTimes.cadenceNumbers = prfInputStruct.cadenceTimes.cadenceNumbers(:);


%%
% get the pixel data
pixStruct = get_pixel_time_series(location, 'targets');
nTargets = length(pixStruct);
% get the target mask definitions
targetMaskDefinitions = get_mask_definitions(location, 'targets');
% get the background data
backgroundData = get_pixel_time_series(location, 'background');
nBackPixels = size(backgroundData, 2);
% get the target definitions
backgroundDefinitionStruct = get_target_definitions(location, 'background');
% get the background mask definitions
backMaskDefinitions = get_mask_definitions(location, 'background');

%%
% make the calibration data
if calibrateData
	load([location filesep 'inputStructs.mat']);
	pluginList = defined_plugin_classes();
	runParamsObject = runParamsClass(runParamsData);
	dynamicNoiseObject = dynamicNoiseClass(pluginList.dynamicNoiseData, runParamsObject);
	[calibrationBlack, calibrationTemp] = get_black_values(dynamicNoiseObject, -1);

	for t=1:nTargets
    	mask = targetMaskDefinitions(pixStruct(t).maskIndex);
		rows = pixStruct(t).referenceRow + [mask.offsets.row];
		cols = pixStruct(t).referenceColumn + [mask.offsets.column];
		for p=1:length(mask.offsets)
			pixStruct(t).calibData(p) = calibrationBlack(rows(p), cols(p));
		end
	end

	for p=1:nBackPixels
    	backTargetDef = backgroundDefinitionStruct(floor((p-1)/4) + 1);
    	backTargetPixel = mod(p, 4) + 1;
    	mask = backMaskDefinitions(backTargetDef.maskIndex);
    	row = backTargetDef.referenceRow + 1 + mask.offsets(backTargetPixel).row;
    	col = backTargetDef.referenceColumn + 1 + mask.offsets(backTargetPixel).column;
		backgroundCalibrationData(p) = calibrationBlack(row, col);
	end

else
	for t=1:nTargets
		for p=1:length(mask.offsets)
			pixStruct(t).calibData = zeros(1, size(pixStruct.pixelValues, 2));
		end
	end
	backgroundCalibrationData = zeros(1, nBackPixels);
end

% make the background pixel structure expected by the old PA background
% routines
% this data is for internal use to this script and so is 1-based.
for p=1:nBackPixels
    % we have to group these into targets of 4 pixels each
    backTargetDef = backgroundDefinitionStruct(floor((p-1)/4) + 1);
    backTargetPixel = mod(p, 4) + 1;
    mask = backMaskDefinitions(backTargetDef.maskIndex);
    backgroundStruct(p).row = backTargetDef.referenceRow + 1 ...
        + mask.offsets(backTargetPixel).row;
    backgroundStruct(p).column = backTargetDef.referenceColumn + 1 ...
        + mask.offsets(backTargetPixel).column;
%    backgroundStruct(p).timeSeries = backgroundData(:,p);
    
%   put in dummy values for the background pixels on the motion-contaminated cadences
    
    b = backgroundData(:,p) - backgroundCalibrationData(p) ; b = b(:)' ;
    b = [b ; zeros(size(b))] ; b = b(:) ;
    backgroundStruct(p).timeSeries = b ;
    clear b b1 ;
    
    backgroundStruct(p).uncertainties = ones(size(backgroundStruct(p).timeSeries));
    backgroundStruct(p).gapList = gapList(:) + 1;
end

if fixIndexBase
    for p=1:nBackPixels
        % we have to group these into targets of 4 pixels each
        backgroundStruct(p).row = backgroundStruct(p).row + 1;
        backgroundStruct(p).column = backgroundStruct(p).column + 1;
    end
end

backgroundCoeffStruct = fit_background_by_time_series(backgroundStruct, ...
    backgroundConfigurationStruct);

backgroundPolyStruct = repmat(struct( ...
    'cadence', -1, ...
    'mjdStartTime', -1, ...
    'mjdMidTime', -1, ...
    'mjdEndTime', -1, ...
    'module', -1, ...
    'output', -1, ...
    'backgroundPoly', [], ...
    'backgroundPolyStatus', -1), [1, nCadences]);

for cadence = 1 : nCadences
    polyStruct.cadence = cadence;
    polyStruct.mjdStartTime = prfInputStruct.cadenceTimes.startTimestamps(cadence);
    polyStruct.mjdMidTime = prfInputStruct.cadenceTimes.midTimestamps(cadence);
    polyStruct.mjdEndTime = prfInputStruct.cadenceTimes.endTimestamps(cadence);
    polyStruct.module = module;
    polyStruct.output = output;
    polyStruct.backgroundPoly = backgroundCoeffStruct(cadence);
    polyStruct.backgroundPolyStatus = ~prfInputStruct.cadenceTimes.gapIndicators(cadence);
    backgroundPolyStruct(cadence) = polyStruct;
end % for cadence

prfInputStruct.backgroundBlob = struct_to_blob(backgroundPolyStruct);

% build the target structure
% assume for now that there is only one target definition per star
if any(diff([pixStruct.keplerId] == 0))
    error('# of targets and # of target definitions not the same');
end

load(['../../prf/mfiles/noiseStudy/prf_tadInputStruct_' channelStr '.mat']);
kicData = tadInputStruct.coaResultStruct.kicEntryDataStruct;
optApData = tadInputStruct.coaResultStruct.optimalApertures;
% make the targetStarStruct with the fields expected by the old PA
% background routines
targetNumber = 1;
for t=1:nTargets
   	kicIndex = find([kicData.KICID] == pixStruct(t).keplerId);
	if kicData(kicIndex).magnitude < 13.75 % imitate magnitude limitations of actual target set
    	maskIndex = pixStruct(t).maskIndex;
    	mask = targetMaskDefinitions(maskIndex);

    	targetStarStruct(targetNumber).keplerId = pixStruct(t).keplerId;
     	tadIndex = find([optApData.keplerId] == targetStarStruct(targetNumber).keplerId);
    	targetStarStruct(targetNumber).keplerMag = kicData(kicIndex).magnitude;
    	targetStarStruct(targetNumber).tadCrowdingMetric = optApData(tadIndex).crowdingMetric;
    	targetStarStruct(targetNumber).fluxFractionInAperture = optApData(tadIndex).fluxFractionInAperture;
    	targetStarStruct(targetNumber).prfFlux = [];
    	targetStarStruct(targetNumber).ra = kicData(kicIndex).RA;
    	targetStarStruct(targetNumber).dec = kicData(kicIndex).dec;
    	targetStarStruct(targetNumber).referenceRow = pixStruct(t).referenceRow;
    	targetStarStruct(targetNumber).referenceColumn = pixStruct(t).referenceColumn;
    	targetStarStruct(targetNumber).gapIndices = gapList;

    	% build the pixel time series structure for each target, including dummy vaules for
    	% cadences which are motion-contaminated
    	nPixels = size(pixStruct(t).pixelValues, 2);
    	for p=1:nPixels
        	targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).row = ...
            	targetStarStruct(targetNumber).referenceRow + mask.offsets(p).row;
        	targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).column = ...
            	targetStarStruct(targetNumber).referenceColumn + mask.offsets(p).column;
        	pV = pixStruct(t).pixelValues(:,p) - pixStruct(t).calibData(p) ; pV = pV(:)' ;
        	pV = [pV ; zeros(size(pV))] ; pV = pV(:) ;
        	targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).values = pV ;
        	targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).uncertainties = ...
            	(2e3 + 100*randn(size(targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).values))) ...
                .* ones(size(targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).values));
            targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).uncertainties(gapList) = 0;
        	targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).gapIndices = gapList(:); % gapList is 0-based cadence # of gap
    	end
    	clear pV pV1 ;

    	% mark the optimal pixel
    	optimalPixelRows = optApData(tadIndex).referenceRow + [optApData(tadIndex).offsets.row];
    	optimalPixelColumns = optApData(tadIndex).referenceColumn + [optApData(tadIndex).offsets.column];
    	optimalPixels = [optimalPixelRows(:), optimalPixelColumns(:)];
    	maskPixelRows = [targetStarStruct(targetNumber).pixelTimeSeriesStruct.row];
    	maskPixelColumns = [targetStarStruct(targetNumber).pixelTimeSeriesStruct.column];
    	maskPixels = [maskPixelRows(:), maskPixelColumns(:)];
    	isInOptimalAperture = ismember(maskPixels, optimalPixels, 'rows');
    	for p=1:length(targetStarStruct(targetNumber).pixelTimeSeriesStruct)
        	targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).isInOptimalAperture = isInOptimalAperture(p);
    	end

    	if fixIndexBase
        	targetStarStruct(targetNumber).referenceRow = targetStarStruct(targetNumber).referenceRow + 1;
        	targetStarStruct(targetNumber).referenceColumn = targetStarStruct(targetNumber).referenceColumn + 1;
        	for p=1:nPixels
            	% we have to group these into targets of 4 pixels each
            	targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).row = targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).row + 1;
            	targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).column = targetStarStruct(targetNumber).pixelTimeSeriesStruct(p).column + 1;
        	end
    	end
		targetNumber = targetNumber + 1;
	end
end

prfInputStruct.targetStarsStruct = targetStarStruct;

% save the result
% save prfInputStruct.mat prfInputStruct
% save (['../../prf/mfiles/prfInputStruct_240_' channelStr '_' prfStr '.mat'], 'prfInputStruct');
% 
save (['../../prf/mfiles/prfInputStruct_240_' channelStr caseStr '.mat'], 'prfInputStruct');


