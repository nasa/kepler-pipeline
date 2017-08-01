function [pixelCoordinates, pixelGaps, nValidPixels] = ...
update_pixel_coordinates_and_gaps(pixelCoordinates, pixelGaps, ccdRows, ...
ccdColumns, gapArray)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  [pixelCoordinates, gapArray] = ...
%     update_pixel_coordinates_and_gaps(pixelCoordinates, pixelGaps,  ...
%                                       ccdRows, ccdColumns, gapArray, )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Update the the list of pixel coordinates and associated gap indicators
% for the unit of work. The pixels counts are used for computation of the
% cosmic ray hit rate.
%
% INPUTS
%     pixelCoordinates
%         A nPriorPixels x 2 double array, each row containing the (row,
%         column) coordinates of a pixel.
%     pixelGaps
%         An nCadences x nPriorPixels array of gap indicators, one column
%         for each row in pixelCoordinates.
%     ccdRows
%         A nCurrentPixels x 1 double array containing row coordinates of
%         all pixels being processed in the current PA invocation.
%     ccdColumns
%         A nCurrentPixels x 1 double array containing corresponding column
%         coordinates of all pixels being processed in the current PA
%         invocation.
%     gapArray
%         An nCadences x nCurrentPixels array of gap indicators for each
%         pixel being processed in the current PA invocation.
%
% OUTPUTS
%     pixelCoordinates
%         A nUniquePixels x 2 double array, each row containing the (row,
%         column) coordinates of a pixel. Each row is unique.
%     pixelGaps
%         An nCadences x nCurrentPixels sparse array of logical gap 
%         indicators, one column for each row in pixelCoordinates.
%     nValidPixels
%         A nCadences-by-1 double array containing the number of valid
%         pixels per cadence. 
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

% Identify the unique input pixels.
[uniqueInputCoordinates, idxUniqueInputCoordinates] = ...
    unique([ccdRows, ccdColumns], 'rows', 'first');
gapArray = gapArray( : , idxUniqueInputCoordinates);

% Ensure that gap arrays are logical.
if ~islogical(gapArray)
    gapArray = logical(gapArray);
end
if ~islogical(pixelGaps)
    pixelGaps = logical(pixelGaps);
end

% Identify new pixels.
isNewPixel = ~ismember(uniqueInputCoordinates, pixelCoordinates, 'rows');

% If any new pixels, update.
if any(isNewPixel)
    newCoordinates = uniqueInputCoordinates(isNewPixel, :);
    
    % Update the pixel coordinates.
    pixelCoordinates = unique([pixelCoordinates; newCoordinates], 'rows');

    % Update the gap indicators for each unique pixel.
    pixelGaps = [pixelGaps, gapArray( : , isNewPixel)];
end

% Determine the number of valid pixels per cadence.
nValidPixels = sum(~pixelGaps, 2);

% Make sure pixel gap matrix is sparse.
if ~issparse(pixelGaps)
    pixelGaps = sparse(pixelGaps);
end

% Return
return