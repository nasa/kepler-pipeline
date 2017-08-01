function pixelSeries = get_cal_SC_pixel_time_series(location, quantize, cosmicRays, requantTableID)
% function pixelSeries = get_cal_SC_pixel_time_series(location, quantize, cosmicRays)
%
% quantize: optional argument, defaults to 1. set quantize = 0 to get
% non-requantized numbers, = 1 to get requantized numbers.
%
% implements FS-GS ICD section 5.3.1.3.1 
%
%
%%%%%%%%%%  MODIFIED FOR CAL !!!!!!!!!!    4/3/2009
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

if nargin < 2
    quantize = 1;
end
if nargin < 3
    cosmicRays = 1;
end

% get the file produced by every etem2 run that gives location and byte
% specifications
load([location filesep 'ssrFileMap.mat']);
ssrOutputDirectory = [location filesep ssrFileStruct.ssrOutputDirectory];
load([location filesep 'tadInputStruct.mat']);

if quantize
    % get the requantization table
    [requantizationTable, meanBlackEntries] = retrieve_requant_table(requantTableID);

    %load([location filesep 'runParamsObject.mat']);    
    %requantOffset = runParamsObject.keplerData.requantTableScFixedOffset;
    
    %[requantizationTable, meanBlackTable, requantOffset] ...
    %    = fake_requant_table(1);
    
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

% we have to make a map of a cadence of bytes (no cheating by looking at
% ETEM variables!)

targetMaskTable = get_mask_definitions(location, 'targets');
targetDefinitions = get_target_definitions(location, 'targets');

% count the number of target pixels
% and the number of rows and columns per target
nTargets = length(targetDefinitions);
nTargetPixels = zeros(nTargets, 1);
nTargetRows = zeros(nTargets, 1);
nTargetCols = zeros(nTargets, 1);
nValuesPerTarget = zeros(nTargets, 1);
nValuesPerCadence = 0;
for t=1:nTargets
    mask = targetMaskTable(targetDefinitions(t).maskIndex);
    nTargetPixels(t) = length(mask.offsets);
    nTargetRows(t) = length(unique([mask.offsets.row]));
    nTargetCols(t) = length(unique([mask.offsets.column]));
    nValuesPerTarget(t) = nTargetPixels(t) + nTargetRows(t) + 2*nTargetCols(t) + 2;
    nValuesPerCadence = nValuesPerCadence + nValuesPerTarget(t);
end

fid = fopen(filename, 'r', 'ieee-be');
% find the length of the file to estimate the number of cadences
fseek(fid, 0, 'eof'); % seek to the end of the file
fileSize = ftell(fid); % find out where we are
nCadences = fileSize/(valueSize*nValuesPerCadence);
if nCadences ~= fix(nCadences)
    error('the quantized short cadence file length is not an integer number of cadences');
end
fseek(fid, 0, 'bof');

pixelSeries = repmat(struct('pixelValues',  [], 'pixelRows',  [], 'pixelCols',  [], ...
    'blackValues', [], ...
    'maskedSmearValues',  [], 'virtualSmearValues', [], ...
    'blackMaskedValue', 0, 'blackVirtualValue', 0), 1, nTargets);

% read in all pixel values by cadence
pixelData = zeros(nCadences, nValuesPerCadence);
for cadence = 1:nCadences
    if quantize
        pixelData(cadence, :) = requantizationTable(fread(fid, nValuesPerCadence, 'uint16')+1);
%         pixelData(cadence, :) = fread(fid, nValuesPerCadence, 'uint16');
    else
        pixelData(cadence, :) = fread(fid, nValuesPerCadence, 'float32');
    end
end

targetPixelOffset = 1;
for t = 1:nTargets
    mask = targetMaskTable(targetDefinitions(t).maskIndex);
    pixelSeries(t).pixelValues ...
        = pixelData(:, targetPixelOffset:targetPixelOffset + nTargetPixels(t) - 1);
    pixelSeries(t).pixelRows = targetDefinitions(t).referenceRow + [mask.offsets.row];
    pixelSeries(t).pixelCols = targetDefinitions(t).referenceColumn + [mask.offsets.column];
    targetPixelOffset = targetPixelOffset + nTargetPixels(t);
    pixelSeries(t).blackValues ...
        = pixelData(:, targetPixelOffset:targetPixelOffset + nTargetRows(t) - 1);
    pixelSeries(t).blackRows = sort(unique(pixelSeries(t).pixelRows));
    targetPixelOffset = targetPixelOffset + nTargetRows(t);
    pixelSeries(t).maskedSmearValues ...
        = pixelData(:, targetPixelOffset:targetPixelOffset + nTargetCols(t) - 1);
    pixelSeries(t).maskedCols = sort(unique(pixelSeries(t).pixelCols));
    targetPixelOffset = targetPixelOffset + nTargetCols(t);
    pixelSeries(t).virtualSmearValues ...
        = pixelData(:, targetPixelOffset:targetPixelOffset + nTargetCols(t) - 1);
    pixelSeries(t).virtualCols = sort(unique(pixelSeries(t).pixelCols));
    targetPixelOffset = targetPixelOffset + nTargetCols(t);
    pixelSeries(t).blackMaskedValue = pixelData(:, targetPixelOffset);
    targetPixelOffset = targetPixelOffset + 1;
    pixelSeries(t).blackVirtualValue = pixelData(:, targetPixelOffset);
    targetPixelOffset = targetPixelOffset + 1;

    pixelSeries(t).maskIndex = targetDefinitions(t).maskIndex;
    pixelSeries(t).referenceRow = targetDefinitions(t).referenceRow;
    pixelSeries(t).referenceColumn = targetDefinitions(t).referenceColumn;
    pixelSeries(t).keplerId = tadInputStruct.targetDefinitions(t).keplerId;
end
