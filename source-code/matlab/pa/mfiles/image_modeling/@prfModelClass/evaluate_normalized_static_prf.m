function [valueArray, rowArray, columnArray] = ...
    evaluate_normalized_static_prf(prfObject, ...
        starRow, starColumn, pixelRows, pixelColumns)
%**************************************************************************
% [valueArray, rowArray, columnArray] = ...
%    evaluate_normalized_static_prf(prfObject, ...
%        starRow, starColumn, pixelRows, pixelColumns)
%**************************************************************************
% Evaluate the normalized static PRF model at the specified pixel
% locations.  
%
% INPUTS
%     starRow        : Subpixel row position (1-based) of the PRF center.
%     starColumn     : Subpixel column position (1-based) of the PRF center.
%     pixelRows      : nPoints-by-1 array of 1-based integer row positions.
%                      (optional)
%     pixelColumns   : nPoints-by-1 array of 1-based integer column 
%                      positions. (optional)
%
% OUTPUTS
%     valueArray     : An nPoints-by-1 matrix of normalized PRF values.
%                      Normalization consists of dividing the value at
%                      each pixel by the sum of values over the full
%                      extent of the PRF. 
%     rowArray       : Same as the input pixelRows if it was specified.
%                      Otherwise this array contains the row positions of
%                      the set of pixels comprising the full PRF.
%     columnArray    : Same as the input pixelColumns if it was specified.
%                      Otherwise this array contains the column positions 
%                      of the set of pixels comprising the full PRF.
%
% NOTES
%     - Currently this function will clip negative values returned by
%       prfCollectionClass.evaluate().
%     - If pixelRows and pixelColumns arguments are not provided, then a
%       normalized PRF will be returned in an array (typically 11x11 or
%       15x15) that captures its full extent.
%**************************************************************************
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
            
    % Evaluate the full PRF for the specified point source. Note that
    % calling prfClass.evaluate() without specifying pixels will return the
    % sampled PRF in the 11x11 or 15x15 region around the star.
    [fullValueArray, fullRowArray, fullColumnArray] = ...
        evaluate(prfObject, starRow, starColumn);
    
    % Clip negative values:
    fullValueArray(fullValueArray < 0) = 0;
    
    % Note that the sum of the full PRF is assumed to be non-zero. 
    fullPrfSum = sum(fullValueArray(:));
    
    if exist('pixelRows', 'var')
        
        % Identify any of the requested pixels that are in the set returned
        % by the full evaluation. All other pixels are assumed to be zero.
        [inFullValueArray, ind] = ismember( [pixelRows(:), pixelColumns(:)], ...
            [fullRowArray(:), fullColumnArray(:)], 'rows');
        
        % Ensure valueArray has same dimensions as pixelRows.
        valueArray = zeros(size(pixelRows)); 
        
        valueArray(inFullValueArray) = ...
            fullValueArray(ind(inFullValueArray)) / fullPrfSum;    
        rowArray    = pixelRows;
        columnArray = pixelColumns;
    else
        valueArray  = fullValueArray / fullPrfSum;
        rowArray    = fullRowArray;
        columnArray = fullColumnArray;
    end
end

