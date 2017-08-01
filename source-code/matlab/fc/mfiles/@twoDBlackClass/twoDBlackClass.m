
function twoDBlackObject = twoDBlackClass(twoDBlackData, interpolation_method)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function twoDBlackObject = twoDBlackClass(twoDBlackData)
% or
% function twoDBlackObject = twoDBlackClass(twoDBlackData, interpolation_method)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Construct a twoDBlackObject from the results of retrieve_two_d_black_model. The get_two_d_black routine extracts the data for the correct timestamp.
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

% Revision record:
% BC - 4/22/14
%       - Repair support for building object with specified rows and columns passed in through twoDBlackData.rows and twoDBlackData.columns.
%       These are assumed to be 0-based.
%       - Move instantiation of twoDBlackObject to end.
%       - Modified error and warning clauses to actually do what they claim to do.

% handle variable input arguments
if nargin < 2
    twoDBlackData.interpolation_method = 'linear';
else
    twoDBlackData.interpolation_method = interpolation_method;
end

% check that model data is actually in input
if isempty(twoDBlackData.blacks)
    error('twoDBlackClass constructor: member variable blacks is empty');
end
if isempty(twoDBlackData.uncertainties)
    error('twoDBlackClass constructor: member variable uncertainties is empty');
end
if isempty(twoDBlackData.mjds)
    error('twoDBlackClass constructor: member variable mjds is empty');
end

% validate input
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'rows';    []; []; []};
fieldsAndBounds(2,:)  = { 'columns';    []; []; []};
if isfield(twoDBlackData,'rows') &&  isfield(twoDBlackData, 'columns')
    if ~isempty(twoDBlackData.rows)
        fieldsAndBounds(1,:)  = { 'rows';    '>= 0'; '<= 1069'; []};
    end
    if ~isempty(twoDBlackData.columns)   
        fieldsAndBounds(2,:)  = { 'columns'; '>= 0'; '<= 1131'; []};
    end
end
validate_structure(twoDBlackData, fieldsAndBounds, 'twoDBlackData');

% perform sanity checks on non-image data members
fc_mjd_check(twoDBlackData.mjds);
if isfield(twoDBlackData, 'rows')
    if length(twoDBlackData.rows) ~= length(twoDBlackData.columns)
        error('Matlab:FC:twoDBlackClass', 'row or columns are not the same length');
    end
    % 0-based pixel addresses, since this is still from-java addresses:
    if any(twoDBlackData.rows > twoDBlackData.ccdRows) || ...
            any(twoDBlackData.rows < 0) || ...
            any(twoDBlackData.columns > twoDBlackData.ccdColumns) || ...
            any(twoDBlackData.columns < 0)
        error('Matlab:FC:twoDBlackClass', 'row or columns arguments are out-of-band');
    end
    fc_nonimage_data_check(twoDBlackData.rows);
    fc_nonimage_data_check(twoDBlackData.columns);
end

% transform from zero-based Java row/cols to one-based MATLAB row/cols
twoDBlackData.rows = twoDBlackData.rows + 1;
twoDBlackData.columns = twoDBlackData.columns + 1;

% make rows/cols indices column vectors
twoDBlackData.rows = twoDBlackData.rows(:);
twoDBlackData.columns = twoDBlackData.columns(:);

% preallocate space
nTimes = length(twoDBlackData.mjds);
nRows = length(twoDBlackData.blacks(1).array);
nCols = length(twoDBlackData.blacks(1).array(1).array);

% set up temp storage for output
blacks = zeros(nTimes, nRows, nCols);
uncertainties = blacks;
if isempty(twoDBlackData.rows)
    newblacks = blacks;
else
    newblacks = zeros(nTimes, length(twoDBlackData.rows));    
end
newuncertainties = zeros(size(newblacks));


% construct images for object
for iTime = 1:nTimes
    
    % need this loop since we must support models where black.array(1).array == [1 x 1132] OR [1132 x 1]. i.e can't use [ ]' concatenation
    % and count on getting a 1070 x 1132 2D array
    for iRow = 1:nRows
        blacks(iTime, iRow, :) = twoDBlackData.blacks(iTime).array(iRow).array;
        uncertainties(iTime, iRow, :) = twoDBlackData.uncertainties(iTime).array(iRow).array;
    end
    
    if isempty(twoDBlackData.rows)
        % create full 1070 x 1132 image
        newblacks(iTime, :, :) = blacks(iTime, : , :);
        newuncertainties(iTime, :, :) = uncertainties(iTime, :, :);
    else
        % create image subset
        thisBlack = squeeze(blacks(iTime, :, :));
        thisUnc = squeeze(uncertainties(iTime, :, :));
        
        if isequal(size(thisBlack),[twoDBlackData.ccdRows,twoDBlackData.ccdColumns])
            % full image black passed in
            pixelIdx = sub2ind(size(thisBlack), twoDBlackData.rows(:)', twoDBlackData.columns(:)');
            newblacks(iTime, :) = thisBlack(pixelIdx);
            newuncertainties(iTime, :) = thisUnc(pixelIdx);
        else
            % subset image black passed in
            newblacks(iTime, :) = thisBlack;
            newuncertainties(iTime, :) = thisUnc;
        end
    end
end

% do a sanity check on prepared inages
fc_image_data_check(newblacks, newuncertainties);

% update fields and make object
twoDBlackData.blacks = newblacks;
twoDBlackData.uncertainties = newuncertainties;
twoDBlackObject = class(twoDBlackData, 'twoDBlackClass');

return
