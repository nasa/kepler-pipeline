function backgroundBinaryObject = backgroundBinaryClass(backgroundBinaryData, ...
    targetData, initialData, runParamsObject)
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

backgroundTargetData.effectiveTemperature = ...
    uniformRandomPickFromRange(backgroundBinaryData.effectiveTemperatureRange);
backgroundTargetData.logSurfaceGravity = ...
    uniformRandomPickFromRange(backgroundBinaryData.logGRange);
backgroundTargetData.ra = targetData.ra;
backgroundTargetData.dec = targetData.dec;

if isempty(initialData)
	% instantiate the background binary star
	transitingStarData = rmfield(backgroundBinaryData, {'pixelOffsetRange', 'magnitudeOffsetRange'});
	backgroundBinaryData.transitingStarObject = transitingStarClass(transitingStarData, ...
    	backgroundTargetData, initialData, runParamsObject);


	% determine the relationship between the background binary and the target
	% star
	% pick pixel offsets for this background binary
	rowOffset = uniformRandomPickFromRange(backgroundBinaryData.pixelOffsetRange);
	colOffset = uniformRandomPickFromRange(backgroundBinaryData.pixelOffsetRange);
	% convert the pixel offset to sub-pixels
	nSubPix = get(runParamsObject, 'nSubPixelLocations');
	rowSubPixOffset = floor(nSubPix*rowOffset);
	colSubPixOffset = floor(nSubPix*colOffset);
	% offset from target sub-pixel position
	targetRowSubPixOffset = targetData.rowFraction + rowSubPixOffset;
	targetColSubPixOffset = targetData.columnFraction + colSubPixOffset;
	% offset from target pixel
	targetRowOffset = fix(targetRowSubPixOffset/nSubPix);
	targetColOffset = fix(targetColSubPixOffset/nSubPix);
	% final sub-pixel position of the background binary
	backgroundBinaryData.subRow = targetRowSubPixOffset - targetRowOffset*nSubPix;
	if backgroundBinaryData.subRow <= 0
    	backgroundBinaryData.subRow = backgroundBinaryData.subRow + nSubPix;
	end
	backgroundBinaryData.subCol = targetColSubPixOffset - targetColOffset*nSubPix;
	if backgroundBinaryData.subCol <= 0
    	backgroundBinaryData.subCol = backgroundBinaryData.subCol + nSubPix;
	end
	% final pixel of the background binary
	backgroundBinaryData.row = targetData.row + targetRowOffset;
	backgroundBinaryData.column = targetData.column + targetRowOffset;

	% set the background binary magnitude
	magnitudeOffset = uniformRandomPickFromRange( ...
    	backgroundBinaryData.magnitudeOffsetRange);
	backgroundBinaryData.magnitude = targetData.keplerMagnitude + magnitudeOffset;
	fluxOfMag12Star = get(runParamsObject, 'fluxOfMag12Star');
	backgroundBinaryData.flux = ...
    	fluxOfMag12Star * mag2b(backgroundBinaryData.magnitude - 12);
else
	transitingStarData = rmfield(backgroundBinaryData, {'pixelOffsetRange', 'magnitudeOffsetRange'});
	if isfield(transitingStarData, 'transitingOrbitObject')
		transitingStarData = rmfield(transitingStarData, 'transitingOrbitObject');
	end
% 	transitingStarData.effectiveTemperature = initialData.primaryPropertiesStruct.effectiveTemperature;
% 	transitingStarData.logSurfaceGravity = initialData.primaryPropertiesStruct.logSurfaceGravity;

	backgroundBinaryData.transitingStarObject = transitingStarClass(transitingStarData, ...
    	backgroundTargetData, initialData, runParamsObject);
	backgroundBinaryData.subRow = initialData.subRow;
	backgroundBinaryData.subCol = initialData.subCol;
	backgroundBinaryData.row = initialData.row;
	backgroundBinaryData.column = initialData.column;
	backgroundBinaryData.magnitude = initialData.magnitude;
	backgroundBinaryData.flux = initialData.flux;
end
backgroundBinaryData.targetData = targetData;

backgroundBinaryData.pixelPolyCoefs = [];
backgroundBinaryData.bgBinPixelPoiPixelIndex = [];
backgroundBinaryData.bgBinPixelIndexInPoi = [];
backgroundBinaryData.bgBinPixelIndexInCcd = [];

% instantiate the backgroundBinaryObject
backgroundBinaryObject = class(backgroundBinaryData, 'backgroundBinaryClass', ...
    runParamsObject);

