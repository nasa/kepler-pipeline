function [aperture center] = target_definition_to_image(apertureDefinitionStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [aperture center] = target_definition_to_image(apertureDefinitionStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% turn a target definition into a 2D array containing 1 for pixels in
% aperture. 
%
% input: apertureDefinitionStruct aperture structure containing the field 
% 	.offsets array of structures containing the fields
%       .row, column row, column offsets of each offsets entry
%
% outputs:
%   aperture 2D array containing 1 for pixels in aperture. 
%   center center of the aperture, equal to reference pixel location in
%   this aperture
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

% compute the extent of the image relative to the (unspecified) reference
% pixel
minRow = min([apertureDefinitionStruct.offsets.row]);
maxRow = max([apertureDefinitionStruct.offsets.row]);
minCol = min([apertureDefinitionStruct.offsets.column]);
maxCol = max([apertureDefinitionStruct.offsets.column]);
% # of non-zero pixels in this aperture
nOffsets = length([apertureDefinitionStruct.offsets.row]);

% nubmer of rows and columns that have non-zero entries
imageRows = maxRow - minRow + 1;
imageCols = maxCol - minCol + 1;

% pre-define storage for the apreture array as zeros
aperture = zeros(imageRows, imageCols);
% compute logical center so that, e.g., the smallest row offsets gets
% mapped to row 1 in the image and the largest row offsets gets mapped to
% the last row (= imageRows) in the image.
centerRow = -minRow + 1;
centerCol = -minCol + 1;

% set the center output
center = [centerRow centerCol];
% create the image by placing a 1 at each offsets row, column
for i=1:nOffsets
    pixRow = apertureDefinitionStruct.offsets(i).row + centerRow;
    pixCol = apertureDefinitionStruct.offsets(i).column + centerCol;
    if pixRow < 0 || pixCol < 0
        error('TAD:common:target_definition_to_image:negativeLocation',...
            'pixRow or pixCol is negative');
    end
    aperture(pixRow, pixCol) = 1;
end
