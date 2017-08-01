function sampledPrfStruct = subsampled_grid_to_sampled_prf(obj, ...
    subsampledGridStruct)
%**************************************************************************
% sampledPrfStruct = subsampled_grid_to_sampled_prf(obj, ...
%    subsampledGridStruct, pixelRows, pixelColumns)
%**************************************************************************
% Retrieve values corresponding to the specified pixel locations from a
% subsampled grid.
%
% INPUTS
%     subsampledGridStruct : 
%     |-.starRow
%     |-.starColumn
%     |-.pixelRows    : nPixels-by-1 array of 1-based INTEGER row positions.
%     |-.pixelColumns : nPixels-by-1 array of 1-based INTEGER column positions.
%     |-.valueGrid    : 
%      -.valueSum     : The sum of the static PRF, when evaluated over
%                       pixelRows and pixelColumns.
%
%
% OUTPUTS
%     sampledPrfStruct
%
% NOTES
%     The resulting value array will have the same sum as the original
%     static PRF evaluated at the star position without any offset applied
%     (see get_subsampled_static_prf_grid_explicit.m). If the PRF for the
%     star in question is contained entirely within the aperture, this sum
%     should be 1.0. In the case of a non-target star near the aperture's
%     perimeter it may not be, which is why we keep track of the sum in the
%     subsampledGridStruct.
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
    
    spp            = obj.get_num_samples_per_pixel();
    subSampledGrid = subsampledGridStruct.valueGrid;
    pixelRows      = subsampledGridStruct.pixelRows;
    pixelColumns   = subsampledGridStruct.pixelColumns;
    valueSum       = subsampledGridStruct.valueSum;
    
    % Get the indices of samples located at pixel centers.
    sampleRows    = pixelRows - min(pixelRows) + 1;
    sampleColumns = pixelColumns - min(pixelColumns) + 1;
    ind =  sub2ind(size(subSampledGrid), ...
                   spp * (sampleRows - 1) + 1, ...
                   spp * (sampleColumns - 1) + 1);

    % If obj.renormalize == true, then make sure the resulting values have
    % the same sum as the original static PRF values.
    values = subSampledGrid(ind);
    if obj.renormalize && valueSum ~= 0 && sum(values) ~= 0
        values = (valueSum / sum(values)) * values;
    end
    
    % Populate the output struct.
    sampledPrfStruct.starRow       = subsampledGridStruct.starRow;
    sampledPrfStruct.starColumn    = subsampledGridStruct.starColumn;
    sampledPrfStruct.pixelRows     = pixelRows;
    sampledPrfStruct.pixelColumns  = pixelColumns;
    sampledPrfStruct.values        = values;
end

%********************************** EOF ***********************************

