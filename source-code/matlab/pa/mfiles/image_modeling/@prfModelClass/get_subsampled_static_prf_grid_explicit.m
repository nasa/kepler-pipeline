function subsampledGridStruct = get_subsampled_static_prf_grid_explicit(obj, ...
        starRow, starColumn, pixelRows, pixelColumns)
%**************************************************************************
% subsampledGridStruct = subsample_static_prf_explicit(obj, ...
%        starRow, starColumn, pixelRows, pixelColumns)
%**************************************************************************
% Evaluate the PRF model on a sub-pixel grid by explicitly calling the
% static PRF Object's evaluate() function. The bounding box of the
% specified pixels along with the property obj.samplesPerPixel determines
% the dimensions and resolution of the sampling grid.
%
% INPUTS
%     starRow      : Subpixel row position (1-based) of the PRF center.
%     starColumn   : Subpixel column position (1-based) of the PRF center.
%     pixelRows    : nPoints-by-1 array of 1-based integer row positions.
%     pixelColumns : nPoints-by-1 array of 1-based integer column positions.
%
% OUTPUTS
%     subsampledGridStruct 
%     |-.starRow       :
%     |-.starColumn    :
%     |-.pixelRows     :
%     |-.pixelColumns  :
%     |-.valueGrid     :  
%      -.valueSum      :
%                        
%                           
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
    spp = obj.get_num_samples_per_pixel();
    subSamplingStep = 1.0/spp;
    
    ccdRows     = colvec( min(pixelRows)    : max(pixelRows) );
    ccdColumns  = colvec( min(pixelColumns) : max(pixelColumns) );
    gridRows    = 1:length(ccdRows);
    gridColumns = 1:length(ccdColumns);
    [ccdColGrid, ccdRowGrid] = meshgrid( ccdColumns,  ccdRows);
    [colGrid, rowGrid]       = meshgrid( gridColumns, gridRows);
    subSampledGrid = zeros( spp * size(rowGrid) );
 
    % Generate the sub-sampled PRF.
    for i = 1:spp
        starSubRow = starRow - (i - 1) * subSamplingStep;
        for j = 1:spp
            starSubCol = starColumn - (j - 1) * subSamplingStep;
            ind = sub2ind( size(subSampledGrid), ...
                           spp * (rowGrid(:) - 1) + i, ...
                           spp * (colGrid(:) - 1) + j);
                       
            prfValues = prfModelClass.evaluate_normalized_static_prf( ...
                obj.staticPrfObject, starSubRow, starSubCol, ...
                ccdRowGrid(:), ccdColGrid(:));
            
%             % prfValues may be empty, so only assign values if it is not.
%             if numel(prfValues) == numel(ind)
%                 subSampledGrid(ind) = prfValues;
%             end
            subSampledGrid(ind) = prfValues;
            
            
            % Note the sum of the static PRF evaluated over the set of
            % pixels.
            if i == 1 && j == 1
                valueSum = sum(sum(subSampledGrid(ind)));
            end
        end
    end
    
    % Populate the output struct.
    subsampledGridStruct.starRow       = starRow;
    subsampledGridStruct.starColumn    = starColumn;
    subsampledGridStruct.pixelRows     = pixelRows;
    subsampledGridStruct.pixelColumns  = pixelColumns;
    subsampledGridStruct.valueGrid     = subSampledGrid;
    subsampledGridStruct.valueSum      = valueSum;
    subsampledGridStruct.samplesPerPix = spp;
end

%********************************** EOF ***********************************
