function pixelNumbers = get_pixel_numbers(location, quantize)
% function timeSeries = get_pixel_numbers(location, quantize)
%
% returns the number of pixels in the long cadence output file
% in the struct pixelNumbers which contains the fields
%   .nPixelsPerTarget array giving the number of science pixels for each
%       target
%   .nTargetPixels
%   .nBackgroundPixels
%   .nBlackValues
%   .nMaskedSmearValues
%   .nVirtualSmearValues
%   .nCollateralValues (= nBlackValues + nMaskedSmearValues + nVirtualSmearValues)
%   .nValuesPerCadence (= nTargetPixels + nBackgroundPixels + nCollateralValues)
%   .valueSize is the size of a data value (2 for quantized, 4 for
%       non-quantized)
%   .nCadences
%   .bytesPerCadence = valueSize*nValuesPerCadence
%	.nReferencePixels
%
% quantize: optional argument, defaults to 1. set quantize = 0 to get
% non-requantized numbers, = 1 to get requantized numbers.
%
% implements FS-GS ICD section 5.3.1.3.1 
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

% get the file produced by every etem2 run that gives location and byte
% specifications
load([location filesep 'ssrFileMap.mat']);
ssrOutputDirectory = [location filesep ssrFileStruct.ssrOutputDirectory];

if quantize
    % get the requantization table
    valueSize = 2;
    filename = [ssrOutputDirectory filesep ssrFileStruct.quantizedCadenceFilename];
else
    valueSize = 4;
    filename = [ssrOutputDirectory filesep ssrFileStruct.scienceCadenceFilename];
end

% we have to make a map of a cadence of bytes (no cheating by looking at
% ETEM variables!)

targetMaskTable = get_mask_definitions(location, 'targets');
targetDefinitions = get_target_definitions(location, 'targets');
backgroundMaskTable = get_mask_definitions(location, 'background');
backgroundDefinitions = get_target_definitions(location, 'background');
refPixTargetDefinitions = get_target_definitions(location, 'reference');

% count the number of target pixels
if isempty(targetDefinitions)
	pixelNumbers.nTargetPixels = 0;
	pixelNumbers.nPixelsPerTarget = [];
else
	nTargets = length(targetDefinitions);
	pixelNumbers.nPixelsPerTarget = zeros(nTargets, 1);
	nTargetPixels = 0;
	for t=1:nTargets
    	pixelNumbers.nPixelsPerTarget(t) = length(targetMaskTable(targetDefinitions(t).maskIndex).offsets);
    	nTargetPixels = nTargetPixels + pixelNumbers.nPixelsPerTarget(t);
	end
	pixelNumbers.nTargetPixels = nTargetPixels;
end

% count the number of background pixels
if isempty(backgroundDefinitions)
	pixelNumbers.nBackgroundPixels = 0;
else
	nBackTargets = length(backgroundDefinitions);
	nBackgroundPixels = 0;
	for t=1:nBackTargets
    	nBackgroundPixels = nBackgroundPixels ...
        	+ length(backgroundMaskTable(backgroundDefinitions(t).maskIndex).offsets);
	end
	pixelNumbers.nBackgroundPixels = nBackgroundPixels;
end

pixelNumbers.nBlackValues = 1070; % we can assume we know this
pixelNumbers.nMaskedSmearValues = 1100; % we can assume we know this
pixelNumbers.nVirtualSmearValues = 1100; % we can assume we know this
pixelNumbers.nCollateralValues = pixelNumbers.nBlackValues + pixelNumbers.nMaskedSmearValues + pixelNumbers.nVirtualSmearValues;

pixelNumbers.nValuesPerCadence = nTargetPixels + nBackgroundPixels + pixelNumbers.nCollateralValues;

fid = fopen(filename, 'r', 'ieee-be');
if fid == -1
	pixelNumbers.nCadences = 0;
	pixelNumbers.valueSize = 0;
	pixelNumbers.bytesPerCadence = 0;
	pixelNumbers.nReferencePixels = 0;
else
	% find the length of the file to estimate the number of cadences
	fseek(fid, 0, 'eof'); % seek to the end of the file
	fileSize = ftell(fid); % find out where we are
	nCadences = fileSize/(valueSize*pixelNumbers.nValuesPerCadence);
	if nCadences ~= fix(nCadences)
    	error('the long cadence file length is not an integer number of cadences');
	end
	bytesPerCadence = valueSize*pixelNumbers.nValuesPerCadence;
	fclose(fid);

	pixelNumbers.nCadences = nCadences;
	pixelNumbers.valueSize = valueSize;
	pixelNumbers.bytesPerCadence = bytesPerCadence;

	% count the number of reference pixels
	nRefTargets = length(refPixTargetDefinitions);
	nRefTargetPixels = 0;
	for t=1:nRefTargets
    	nRefTargetPixels = nRefTargetPixels ...
        	+ length(targetMaskTable(refPixTargetDefinitions(t).maskIndex).offsets);
	end
	pixelNumbers.nReferencePixels = nRefTargetPixels;
end
