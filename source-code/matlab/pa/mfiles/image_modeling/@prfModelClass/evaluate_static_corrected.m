function sampledPrfStruct = ...
    evaluate_static_corrected(obj, starRow, starColumn, pixelRows, pixelColumns)
%**************************************************************************
% function corrected = apply_static_correction(obj, sampledStaticPrfStruct)
%**************************************************************************
%
% INPUTS
%     starRow        : Subpixel row position (1-based) of the PRF center.
%     starColumn     : Subpixel column position (1-based) of the PRF center.
%     pixelRows      : nPixels-by-1 array of 1-based INTEGER row positions.
%     pixelColumns   : nPixels-by-1 array of 1-based INTEGER column positions.
%
%
% OUTPUTS
%     sampledPrfStruct
%
% NOTES
%     In order to generate a sub-sampled PRF.
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
    
    ccdRows     = colvec(min(pixelRows):max(pixelRows));
    ccdColumns  = colvec(min(pixelColumns):max(pixelColumns));
    gridRows    = 1:length(ccdRows);
    gridColumns = 1:length(ccdColumns);
    [ccdColGrid, ccdRowGrid] = meshgrid( ccdColumns, ccdRows);
    [colGrid, rowGrid] = meshgrid( gridColumns, gridRows);
    subSampledGrid = zeros( spp * size(rowGrid) );
 
    % Generate the sub-sampled PRF.
    for i = 1:spp
        starSubRow = starRow - (i - 1) * subSamplingStep;
        for j = 1:spp
            starSubCol = starColumn - (j - 1) * subSamplingStep;
            ind = sub2ind( size(subSampledGrid), ...
                           spp * (rowGrid(:) - 1) + i, ...
                           spp * (colGrid(:) - 1) + j);
            subSampledGrid(ind) = evaluate( obj.staticPrfObject, ...
                starSubRow, starSubCol, ccdRowGrid(:), ccdColGrid(:));
        end
    end

    % Obtain the static correction kernel.
    kernel = obj.staticKernelObject.get_kernel(starRow, starColumn);
    
    % Obtain a sampled version of the working PRF by convolving the 
    % adaptive kernel with the sampled static PRF.
    corrected = filter2(kernel, subSampledGrid, 'same');

    % Get the indices of smaples located at pixel centers.
    sampleRows    = pixelRows - min(pixelRows) + 1;
    sampleColumns = pixelColumns - min(pixelColumns) + 1;
    ind =  sub2ind(size(subSampledGrid), ...
                   spp * (sampleRows - 1) + 1, ...
                   spp * (sampleColumns - 1) + 1);

    % Populate the output struct.
    sampledPrfStruct.starRow       = starRow;
    sampledPrfStruct.starColumn    = starColumn;
    sampledPrfStruct.sampleRows    = pixelRows;
    sampledPrfStruct.sampleColumns = pixelColumns;
    sampledPrfStruct.values        = corrected(ind);
end

%********************************** EOF ***********************************

