function pixelSeries = get_cal_pixel_time_series_fixed_offset_corrected(location, type, quantize, cosmicRays)
% function timeSeries = get_quantized_pixel_time_series(location, type, quantize, cosmicRays)
%
% type: optional argument, defaults to 'targets'.
% pixelSeries depends on the tpye:
% 'targets': an nTargets x 1 struct array with the field
%   .pixelvalues an nCadences x nPixels array
% 'background': an nPixels x nCadences array
% 'black': a 1 x 1070 array with summed black values
% 'maskedSmear': a 1 x 1100 array with summed masked smear values
% 'virtualSmear': a 1 x 1100 array with summed virtual smear values
% 'reference': an nTargets x 1 struct array with the field
%   .pixelvalues an nCadences x nPixels array
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

% quantize: optional argument, defaults to 1. set quantize = 0 to get
% non-requantized numbers, = 1 to get requantized numbers.
%
%
% implements FS-GS ICD section 5.3.1.3.1 
%

%%%%%%%%%%  MODIFIED FOR CAL BY NOT CORRECTING FOR FIXED OFFSET/MEAN BLACK
%%%%%%%%%%  HERE!!!!!!!!!!    9/2/2008

if nargin < 4
    cosmicRays = 1;
end
if nargin < 3
    quantize = 1;
end
if nargin < 2
    type = 'targets';
end

switch type
	case 'reference'
		pixelSeries = get_reference_pixel_time_series(location, cosmicRays);
		
	otherwise
		pixelSeries = get_pixels(location, type, quantize, cosmicRays);
		
end

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

function pixelSeries = get_pixels(location, type, quantize, cosmicRays)

% get the file produced by every etem2 run that gives location and byte
% specifications
load([location filesep 'ssrFileMap.mat']);
ssrOutputDirectory = [location filesep ssrFileStruct.ssrOutputDirectory];
load([location filesep 'tadInputStruct.mat']);

[module output channel] = infer_mod_out_from_location(location);

load([location filesep 'requantizationTable.mat']);
requantOffset = 419405; % fixed value
if quantize
    % get the requantization table
    valueSize = 2;
    if cosmicRays
        filename = [ssrOutputDirectory filesep ssrFileStruct.quantizedCadenceFilename];
    else
        filename = [ssrOutputDirectory filesep ssrFileStruct.quantizedCadenceNoCrFilename];
    end
else
    valueSize = 4;
    if cosmicRays
        filename = [ssrOutputDirectory filesep ssrFileStruct.scienceCadenceFilename];
    else
        filename = [ssrOutputDirectory filesep ssrFileStruct.scienceCadenceNoCrFilename];
    end
end
filename

load([location filesep 'inputStructs.mat']);
numExposuresPerCadence = runParamsData.keplerData.exposuresPerShortCadence ...
    * runParamsData.keplerData.shortsPerLongCadence;
nBlackCoAddCols = length(runParamsData.keplerData.blackCoAddCols);
nMaskedSmearCoAddRow = length(runParamsData.keplerData.maskedSmearCoAddRows);
nVirtualSmearCoAddRow = length(runParamsData.keplerData.virtualSmearCoAddRows);

% we have to make a map of a cadence of bytes (no cheating by looking at
% ETEM variables!)

targetMaskTable = get_mask_definitions(location, 'targets');
targetDefinitions = get_target_definitions(location, 'targets');
backgroundMaskTable = get_mask_definitions(location, 'background');
backgroundDefinitions = get_target_definitions(location, 'background');

% count the number of target pixels
nTargets = length(targetDefinitions);
nTargetPixels = 0;
for t=1:nTargets
    targetPixelOffset(t) = nTargetPixels + 1;
    nTargetPixels = nTargetPixels ...
        + length(targetMaskTable(targetDefinitions(t).maskIndex).offsets);
end
% count the number of background pixels
nBackTargets = length(backgroundDefinitions);
nBackgroundPixels = 0;
for t=1:nBackTargets
    backgroundPixelOffset(t) = nBackgroundPixels + 1;
    nBackgroundPixels = nBackgroundPixels ...
        + length(backgroundMaskTable(backgroundDefinitions(t).maskIndex).offsets);
end
nBlackValues = 1070; % we can assume we know this
nMaskedSmearValues = 1100; % we can assume we know this
nVirtualSmearValues = 1100; % we can assume we know this
nCollateralValues = nBlackValues + nMaskedSmearValues + nVirtualSmearValues;

nValuesPerCadence = nTargetPixels + nBackgroundPixels + nCollateralValues;

fid = fopen(filename, 'r', 'ieee-be');
% find the length of the file to estimate the number of cadences
fseek(fid, 0, 'eof'); % seek to the end of the file
fileSize = ftell(fid); % find out where we are
nCadences = fileSize/(valueSize*nValuesPerCadence);
if nCadences ~= fix(nCadences)
    error('the long cadence file length is not an integer number of cadences');
end
fseek(fid, 0, 'bof');

switch type
    case 'targets'
        pixelSeries = repmat(struct('pixelValues',  [], ...
            'referenceRow', 0, 'referenceColumn', 0), 1, nTargets);
        
        pixelData = zeros(nCadences, nTargetPixels);
        cadenceStride = valueSize*(nValuesPerCadence - nTargetPixels);
        for cadence = 1:nCadences
            if quantize
                pixelData(cadence, :) = ...
                    requantizationTable(fread(fid, nTargetPixels, 'uint16') + 1); 
%                 pixelData(cadence, :) = fread(fid, nTargetPixels, 'uint16');
            else
                pixelData(cadence, :) = ...
                    fread(fid, nTargetPixels, 'float32');
            end
                
            fseek(fid, cadenceStride, 'cof');
        end
        pixelData = pixelData - double(requantOffset);   % + numExposuresPerCadence*double(meanBlackTable(channel));
        
        for t = 1:nTargets-1
            pixelSeries(t).pixelValues ...
                = pixelData(:, targetPixelOffset(t):targetPixelOffset(t+1)-1);
        end
        pixelSeries(nTargets).pixelValues ...
            = pixelData(:, targetPixelOffset(nTargets):end);

        for t = 1:nTargets
            pixelSeries(t).maskIndex = targetDefinitions(t).maskIndex;
            pixelSeries(t).referenceRow = targetDefinitions(t).referenceRow;
            pixelSeries(t).referenceColumn = targetDefinitions(t).referenceColumn;
            pixelSeries(t).keplerId = tadInputStruct.targetDefinitions(t).keplerId;
        end
        
    case 'background'
        pixelSeries = zeros(nCadences, nBackgroundPixels);
        cadenceStride = valueSize*(nValuesPerCadence - nBackgroundPixels);
        % jump over the first target set
        fseek(fid, valueSize*nTargetPixels, 'cof');
        for cadence = 1:nCadences
            if quantize
                pixelSeries(cadence, :) = ...
                    requantizationTable(fread(fid, nBackgroundPixels, 'uint16') + 1);
            else
                pixelSeries(cadence, :) = ...
                    fread(fid, nBackgroundPixels, 'float32');
            end
            fseek(fid, cadenceStride, 'cof');
        end
        pixelSeries = pixelSeries - double(requantOffset); % + numExposuresPerCadence*double(meanBlackTable(channel));
        
    case 'black'
        pixelSeries = zeros(nCadences, nBlackValues);
        cadenceStride = valueSize*(nValuesPerCadence - nBlackValues);
        % jump over the first target and background set
        fseek(fid, valueSize*(nTargetPixels + nBackgroundPixels), 'cof');
        for cadence = 1:nCadences
            if quantize
                pixelSeries(cadence, :) = ...
                    requantizationTable(fread(fid, nBlackValues, 'uint16') + 1);
            else
                pixelSeries(cadence, :) = ...
                    fread(fid, nBlackValues, 'float32');
            end
            fseek(fid, cadenceStride, 'cof');
        end
        pixelSeries = pixelSeries - double(requantOffset);   % ...
            %+ nBlackCoAddCols*numExposuresPerCadence*double(meanBlackTable(channel));

    case 'maskedSmear'
        pixelSeries = zeros(nCadences, nMaskedSmearValues);
        cadenceStride = valueSize*(nValuesPerCadence - nMaskedSmearValues);
        % jump over the first target and background and black set
        fseek(fid, valueSize*(nTargetPixels + nBackgroundPixels + nBlackValues), 'cof');
        for cadence = 1:nCadences
            if quantize
                pixelSeries(cadence, :) = ...
                    requantizationTable(fread(fid, nMaskedSmearValues, 'uint16') + 1);
            else
                pixelSeries(cadence, :) = ...
                    fread(fid, nMaskedSmearValues, 'float32');
            end
            fseek(fid, cadenceStride, 'cof');
        end
        pixelSeries = pixelSeries - double(requantOffset); % ...
            %+ nMaskedSmearCoAddRow*numExposuresPerCadence*double(meanBlackTable(channel));

    case 'virtualSmear'
        pixelSeries = zeros(nCadences, nVirtualSmearValues);
        cadenceStride = valueSize*(nValuesPerCadence - nVirtualSmearValues);
        % jump over the first target and background and black and masked
        % smear set
        fseek(fid, valueSize*(nTargetPixels + nBackgroundPixels + nBlackValues + nMaskedSmearValues), 'cof');
        for cadence = 1:nCadences
            if quantize
                pixelSeries(cadence, :) = ...
                    requantizationTable(fread(fid, nVirtualSmearValues, 'uint16') + 1);
            else
                pixelSeries(cadence, :) = ...
                    fread(fid, nVirtualSmearValues, 'float32');
            end
            fseek(fid, cadenceStride, 'cof');
        end
        pixelSeries = pixelSeries - double(requantOffset); % ...
            %+ nVirtualSmearCoAddRow*numExposuresPerCadence*double(meanBlackTable(channel));

   otherwise
        display([type ' not implemented']);
        pixelSeries = [];
end

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

function pixelSeries = get_reference_pixel_time_series(location, cosmicRays)

% get the file produced by every etem2 run that gives location and byte
% specifications
load([location filesep 'ssrFileMap.mat']);
ssrOutputDirectory = [location filesep ssrFileStruct.ssrOutputDirectory];

filename = [ssrOutputDirectory filesep ssrFileStruct.refPixFilename];

% we have to make a map of a cadence of bytes (no cheating by looking at
% ETEM variables!)

targetMaskTable = get_mask_definitions(location, 'targets');
refPixTargetDefinitions = get_target_definitions(location, 'reference');

% count the number of reference pixels
nRefTargets = length(refPixTargetDefinitions);
nRefTargetPixels = 0;
for t=1:nRefTargets
    refTargetPixelOffset(t) = nRefTargetPixels + 1;
    nRefTargetPixels = nRefTargetPixels ...
        + length(targetMaskTable(refPixTargetDefinitions(t).maskIndex).offsets);
end

nValuesPerCadence = nRefTargetPixels;

fid = fopen(filename, 'r', 'ieee-be');
% find the length of the file to estimate the number of cadences
fseek(fid, 0, 'eof'); % seek to the end of the file
fileSize = ftell(fid); % find out where we are
nCadences = fileSize/(4*nValuesPerCadence);
if nCadences ~= fix(nCadences)
    error('the reference pixel file length is not an integer number of cadences');
end
fseek(fid, 0, 'bof');

pixelSeries = repmat(struct('pixelValues',  [], ...
    'referenceRow', 0, 'referenceColumn', 0), 1, nRefTargets);

pixelData = zeros(nCadences, nRefTargetPixels);
for cadence = 1:nCadences
	pixelData(cadence, :) = fread(fid, nRefTargetPixels, 'uint32');
end

for t = 1:nRefTargets-1
    pixelSeries(t).pixelValues ...
        = pixelData(:, refTargetPixelOffset(t):refTargetPixelOffset(t+1)-1);
end
pixelSeries(nRefTargets).pixelValues ...
    = pixelData(:, refTargetPixelOffset(nRefTargets):end);

for t = 1:nRefTargets
    pixelSeries(t).maskIndex = refPixTargetDefinitions(t).maskIndex;
    pixelSeries(t).referenceRow = refPixTargetDefinitions(t).referenceRow;
    pixelSeries(t).referenceColumn = refPixTargetDefinitions(t).referenceColumn;
end

fclose(fid);


