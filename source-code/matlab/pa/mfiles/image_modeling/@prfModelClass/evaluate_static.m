function sampledPrfStruct = ...
    evaluate_static(obj, starRow, starColumn, pixelRows, pixelColumns)
%**************************************************************************
% sampledPrfStruct = ...
%    evaluate_static(obj, starRow, starColumn, pixelRows, pixelColumns)
%**************************************************************************
% Evaluate the normalized static PRF model at the specified pixel
% locations. 
%
% INPUTS
%     starRow      : Subpixel row position (1-based) of the PRF center.
%     starColumn   : Subpixel column position (1-based) of the PRF center.
%     pixelRows    : nPoints-by-1 array of 1-based integer row positions.
%     pixelColumns : nPoints-by-1 array of 1-based integer column positions.
%
% OUTPUTS
%     sampledPrfStruct 
%     |-.starRow       : Same as the input starRow.
%     |-.starColumn    : Same as the input starColumn.
%     |-.pixelRows     : Same as the input pixelRows if it was specified.
%     |                  Otherwise this array contains the row positions of
%     |                  the set of pixels comprising the full PRF.
%     |-.pixelColumns  : Same as the input pixelColumns if it was specified.
%     |                  Otherwise this array contains the column positions 
%     |                  of the set of pixels comprising the full PRF.
%      -.values        : An nPoints-by-1 matrix of normalized PRF values.
%                        Normalization consists of dividing the value at
%                        each pixel by the sum of values over the full
%                        extent of the PRF.
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
    if exist('pixelRows', 'var')
        nPoints = length(pixelRows); % Number of points to evaluate at each cadence.
        staticPrfWidthPixels = obj.get_static_width_in_pixels();

        % Only do the evaluation if there is overlap between the evaluated
        % PRF pixel array and the aperture pixel array. Otherwise the
        % samples are assumed to be all zeros.
        if    min(abs(pixelRows - fix(starRow))) < fix(staticPrfWidthPixels/2) ...
           && min(abs(pixelColumns - fix(starColumn))) < fix(staticPrfWidthPixels/2)

            % Obtain the requested pixels from a normalized static PRF.
            prfValues = prfModelClass.evaluate_normalized_static_prf( ...
                obj.staticPrfObject, starRow, starColumn, ...
                pixelRows, pixelColumns);
        else
            prfValues = zeros(nPoints, 1); 
        end
    else
        % If pixels were not specified, then sample the full extent of the
        % PRF. 
        [prfValues, pixelRows, pixelColumns] = ...
            prfModelClass.evaluate_normalized_static_prf( ...
                obj.staticPrfObject, starRow, starColumn);
        
    end
    
    % Create the output struct
    sampledPrfStruct.starRow        = starRow;
    sampledPrfStruct.starColumn     = starColumn;
    sampledPrfStruct.pixelRows      = pixelRows;
    sampledPrfStruct.pixelColumns   = pixelColumns;
    sampledPrfStruct.values         = prfValues;
end

%********************************** EOF ***********************************
