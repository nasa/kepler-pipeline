function [result uncert] = get_flat_field(flatFieldObject, mjd, rows, cols)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [result uncert] = get_flat_field(flatFieldObject, mjd, rows, cols)
% or
% function [result uncert] = get_flat_field(flatFieldObject, mjd)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get the flat field value and associated uncertainty per pixel.  The flat is from an 
% image of the flat field, and the uncertainty is the one-sigma uncertainty of the value
% for the pixels.
%
% The dimensions of the return data is MxN, where M is the length of
% the input argument mjd, and N is the length of the rows/columns
% fields in the flatFieldObject (if the rows/cols args aren't specified)
% or the length of the rows/cols arguments (if the rows/cols args are
% specified).
%
% In the model was constructed with no pixel locations specified, the return
% structures are Mx1070x1132 image cubes of the full frame of the output.
%
% The return data is only for the row/columns specified by the flatFieldObject,
% and only for the the single module/output that the object is valid for.
%
% The input mjd argument need not be sorted.
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
% BC - 4/23/14
%       - Change warnings on inputs checking to errors.
%       - Move columnization of output (if required) to end.


if ~(2 == nargin || 4 == nargin)
    error('MATLAB::FC::flatFieldClass::get_flat_field: get_flat_field takes 2 or 4 args');
end

if 4 == nargin && length(rows) ~= length(cols)
    error('MATLAB:FC:flatFieldClass:get_flat_field','MATLAB:FC:flatFieldClass:get_flat_field: row/column pixel specification args must be the same length');
end


% error if data volume will be large
max_num_of_pixel_returned = 1024^3 / 8; %  one GB in doubles
if ~isempty(flatFieldObject.rows)
    is_data_large = (length(mjd) * length(flatFieldObject.rows)) > max_num_of_pixel_returned;
else
    is_data_large = (length(mjd) * 1070 * 1132) > max_num_of_pixel_returned;
end
if is_data_large
    error('MATLAB:FC:flatFieldClass:get_flat_field', 'Output data volume will exceed %d pixels', max_num_of_pixel_returned);
end

% Interpolate to the correct MJD, and then squeeze the output to a 2D matrix, from a one-element 3D matrix.
if length(get(flatFieldObject, 'mjds')) > 1
    result = linear_interp_soc(flatFieldObject.mjds, flatFieldObject.flats, mjd);
    uncert = linear_interp_soc(flatFieldObject.mjds, flatFieldObject.uncertainties, mjd);
else
    result = repmat(flatFieldObject.flats(        1,:,:), length(mjd), 1);
    uncert = repmat(flatFieldObject.uncertainties(1,:,:), length(mjd), 1);   
end
result = squeeze(result);
uncert = squeeze(uncert);

% Only return the requested pixels, if they have been requested:
%
if 4 == nargin
    if numel(flatFieldObject.rows) > 0
        
        % model was specified with pixels
        rowsColsInputs = [rows(:) cols(:)];
        rowsColsObject = [flatFieldObject.rows(:) flatFieldObject.columns(:)];
        
        % check that object contains the requested pixels
        if any(~ismember(rowsColsInputs,rowsColsObject,'rows'))
           error('MATLAB:FC:flatFieldClass:get_flat_field', 'User-requested pixels are not included in this instance of the flat field model.');
        end             
        
        % Capture if there are any duplicate pixels in the rowsColsInputs list
        [~ , ~, uniqJ] = unique(rowsColsInputs, 'rows');
        
        % find the rows and column in the black2DObject
        [~, indexIntoInputs, indexIntoObject] = intersect(rowsColsInputs, rowsColsObject, 'rows');
        indexIntoInputs = indexIntoInputs(uniqJ, :);
        indexIntoObject = indexIntoObject(uniqJ, :);
        [~, sortedIndex] = sort(indexIntoInputs);
                
        nDims = length(size(result));
        if 3 == nDims
            doIndex = 1 == size(result, 1);
        else
            doIndex = 1 == min(size(result));
        end
        
        if doIndex
            result = result(indexIntoObject);
            uncert = uncert(indexIntoObject);
        else
            result = result(:, indexIntoObject);
            uncert = uncert(:, indexIntoObject);
            
            result = result(:, sortedIndex);
            uncert = uncert(:, sortedIndex);
        end      
        
    else
        % model is full image:
        index = sub2ind([flatFieldObject.ccdRows flatFieldObject.ccdColumns], rows, cols);        
        if size(result, 3) == 1
            result = result(index);
            uncert = uncert(index);
        else
            result = result(:, index);
            uncert = uncert(:, index);
        end
    end
end

% Return data for a single-MJD argument as a column vector, not a row vector
if numel(flatFieldObject.rows) > 0 && 1 == length(mjd)
    result = result(:);
    uncert = uncert(:);
end

% Explicitly cast output to double to prevent accidental downcasting of user data
result = double(result);
uncert = double(uncert);
return
