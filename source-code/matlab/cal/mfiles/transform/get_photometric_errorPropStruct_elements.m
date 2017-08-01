function [pouStructIndices, pixelIndices, foundRows, foundCols] = ...
    get_photometric_errorPropStruct_elements(rows, cols, pouStruct)
%
% This function identifies the errorPropStruct elements and indices into 
% those elelments corresponding to the photometic pixels row and column
% indices provided. It polls each of the photometric elements of 
% errorPropStruct and returns a list of errorPropStruct indices (variable
% index into the errorPropStruct) and a corresponding cell array whose 
% elements are vectors of linear indices into the primitive data. The row
% and column corresponding to each index are also returned.
%
% INPUT:    rows                = vector of row indices of photometric pixels
%                                 of interest
%           cols                = vector of cloumn indices of photometric pixels
%                                 of interest
%           pouStruct           = any error propagation structure from CAL
%                                 for any number of cadences. Can be
%                                 uncompressed and maximized, minimized but
%                                 not compressed or minimized and compressed
% OUTPUT:   pouStructIndices    = vector of pouStruct array indices where
%                                 matching row-col pairs were found.
%           pixelIndices        = cell array of vectors containing the
%                                 indices into the pouStruct photometric
%                                 elements where the matches occured.
%           foundRows           = row value corresponding to the pixel
%                                 index.
%           foundCols           = column value corresponding to the pixel
%                                 index.
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

% prefix to calibrated pixel errorPropStruct variables
photoName = 'calibratedPixels';


% find the calibratedPixels# indices
[varIndices, varList] = iserrorPropStructVariable(pouStruct,'');
photoIndices = strmatch(photoName, varList);
photoIndices = sort(photoIndices);

% preallocate memory
pouStructIndices = zeros(length(photoIndices),1);
pixelIndices = cell(length(photoIndices),1);
foundRows = cell(length(photoIndices),1);
foundCols = cell(length(photoIndices),1);

% build input row-col pair matrix
rowsCols = [rows(:),cols(:)];
numPairsInput = size(rowsCols,1);

% loop through photometric elements checking for row-col pair matches
numPairsFound = 0;
outIndex = 1;
i = 0;
done = false;

while(~done && i <length(photoIndices))
    i = i + 1;

    % build photometric element row-col pair
    photoRowsCols = [pouStruct(photoIndices(i)).row(:), pouStruct(photoIndices(i)).col(:)];
    
    % find the row indices of the input pairs that match those in the photometric element
    [TF, LOC] = ismember(rowsCols, photoRowsCols, 'rows');
    index = LOC(TF);
    
    % store the indices needed for output
    if(~isempty(index))        
        pouStructIndices(outIndex) = photoIndices(i);
        pixelIndices{outIndex} = index;
        foundRows{outIndex} = pouStruct(photoIndices(i)).row(index);
        foundCols{outIndex} = pouStruct(photoIndices(i)).col(index);

        % I like column vectors
        pixelIndices{outIndex} = pixelIndices{outIndex}(:);
        foundRows{outIndex} = foundRows{outIndex}(:);
        foundCols{outIndex} = foundCols{outIndex}(:);
        
        numPairsFound = numPairsFound + length(foundRows{outIndex});
        outIndex = outIndex + 1;        
    end
    
    %  stop looking if all the input pairs are found
    if(numPairsFound == numPairsInput); done = true;    end
end

outIndex = outIndex - 1;

% set null output if no pair found, otherwise trim empty elements
if(~outIndex)
    pouStructIndices = [];
    pixelIndices = {};
    foundRows = {};
    foundCols = {};
else
    pouStructIndices = pouStructIndices(1:outIndex);
    pixelIndices = pixelIndices(1:outIndex);
    foundRows = foundRows(1:outIndex);
    foundCols = foundCols(1:outIndex);
end
    