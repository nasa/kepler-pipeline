function [locationOfObjectsInBoundingBox] = ...
locate_nearby_kic_objects(targetId, kics, motionPolyStruct, ...
kicReferenceCentroid, rowRange, columnRange)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [locationOfObjectsInBoundingBox] = ...
% locate_nearby_kic_objects(targetId, kics, motionPolyStruct, ...
% kicReferenceCentroid, rowRange, columnRange)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Find the targets that are located within the bounding box of the
% difference image. Convert all CCD coordinates to 0-based indexing. Note
% that rowRange and columnRange for bounding box are already 0-based.
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

% Define constants.
ARCSECONDS_PER_DEGREE = 60 * 60;
DEGREES_PER_HOUR = 360 / 24;
PIXELS_TO_PAD = 0.5;
PIXEL_TOLERANCE = 2.0;
GAP_VALUE = -1;

% Append pseudo-targets to end of kics to mark locations one arcsecond
% north and east of target.
if ~isempty(kics)
    
    kic = kics([kics.keplerId] == targetId);
    
    if ~isnan(kic.ra.value) && ~isnan(kic.dec.value)
    
        newKic = kic;
        newKic.keplerId = -1;
        newKic.keplerMag.value = 0;
        newKic.dec.value = newKic.dec.value + 1 / ARCSECONDS_PER_DEGREE;
        kics = [kics, newKic];

        newKic = kic;
        newKic.keplerId = -2;
        newKic.keplerMag.value = 0;
        newKic.ra.value = newKic.ra.value + ...
            (1 / cosd(newKic.dec.value)) / ...
            (ARCSECONDS_PER_DEGREE * DEGREES_PER_HOUR);
        kics = [kics, newKic];
        
    end % if
    
end % if
    
% Loop through the KICs and locate all of the targets that fall within the
% bounding box of the difference image. Save the info needed to mark them
% on the figure. Make a quick initial estimate of the mean position to
% filter out all of the targets that are guaranteed not to fall within the
% bounding box of the difference image.
nKics = length(kics);
isInBoundingBox = false([nKics, 1]);

minRow = min(rowRange);
maxRow = max(rowRange);
minColumn = min(columnRange);
maxColumn = max(columnRange);

locationOfObjectsInBoundingBox = repmat(struct( ...
    'keplerId', 0, ...
    'keplerMag', -1, ...
    'isPrimaryTarget', false, ...
    'zeroBasedRow', 0, ...
    'zeroBasedColumn', 0), [1, nKics]);

transformationCadenceIndices = ...
    kicReferenceCentroid.transformationCadenceIndices;

for iKic = 1 : nKics
    
    kic = kics(iKic);
    keplerId = kic.keplerId;
    keplerMag = kic.keplerMag.value;
    raHours = kic.ra.value;
    raDegrees = raHours * DEGREES_PER_HOUR;
    decDegrees = kic.dec.value;
    
    if keplerId ~= targetId
        if ~isempty(transformationCadenceIndices)
            [rowValue, rowUncertainty, columnValue, columnUncertainty] = ...
                transform_kic_position_to_fpa_coordinates( ...
                raDegrees, decDegrees, motionPolyStruct, ...
                [transformationCadenceIndices(1); transformationCadenceIndices(end)]);
            rowValue = rowValue - 1;
            columnValue = columnValue - 1;
            if rowUncertainty ~= GAP_VALUE && columnUncertainty ~= GAP_VALUE && ...
                    (minRow - rowValue > PIXEL_TOLERANCE || ...
                    rowValue - maxRow > PIXEL_TOLERANCE || ...
                    minColumn - columnValue > PIXEL_TOLERANCE || ...
                    columnValue - maxColumn > PIXEL_TOLERANCE)
                continue;
            end % if
        end % if        
        [rowValue, rowUncertainty, columnValue, columnUncertainty] = ...
            transform_kic_position_to_fpa_coordinates( ...
            raDegrees, decDegrees, motionPolyStruct, ...
            transformationCadenceIndices);
    else
        rowValue = kicReferenceCentroid.row.value;
        rowUncertainty = kicReferenceCentroid.row.uncertainty;
        columnValue = kicReferenceCentroid.column.value;
        columnUncertainty = kicReferenceCentroid.column.uncertainty;
        locationOfObjectsInBoundingBox(iKic).isPrimaryTarget = true;
    end % if / else
    
    if rowUncertainty ~= GAP_VALUE
        rowValue = rowValue - 1;
    end % if
    if columnUncertainty ~= GAP_VALUE
        columnValue = columnValue - 1;
    end % if
    
    if rowUncertainty ~= GAP_VALUE && columnUncertainty ~= GAP_VALUE && ...
            rowValue >= minRow-PIXELS_TO_PAD && rowValue <= maxRow+PIXELS_TO_PAD && ...
            columnValue >= minColumn-PIXELS_TO_PAD && columnValue <= maxColumn+PIXELS_TO_PAD
        isInBoundingBox(iKic) = true;
        locationOfObjectsInBoundingBox(iKic).keplerId = keplerId;
        locationOfObjectsInBoundingBox(iKic).keplerMag = keplerMag;
        locationOfObjectsInBoundingBox(iKic).zeroBasedRow = rowValue;
        locationOfObjectsInBoundingBox(iKic).zeroBasedColumn = columnValue;
    end % if
            
end % for iKic

% Squeeze out the struct array elements for targets that do not fall in the
% bounding box.
locationOfObjectsInBoundingBox = locationOfObjectsInBoundingBox(isInBoundingBox);

% Return.
return
