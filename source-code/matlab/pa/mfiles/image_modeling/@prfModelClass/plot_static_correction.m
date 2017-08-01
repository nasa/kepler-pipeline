function plot_static_correction(obj, row, column)    
%**************************************************************************
% Plot the difference between the static PRF and the corrected static PRF
% mdoels.
%
% INPUTS
%     row     : Fractional row position at which to evaluate the PRF model. 
%     column  : Fractional column position at which to evaluate the PRF
%               model.
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
    if isempty(obj.staticKernelObject) 
        warning('No static correction available.');
        return;
    end        
    
    %----------------------------------------------------------------------
    % Evaluate the static and corrected PRFs at bot pixel and sub-pixel
    % resolution. 
    %----------------------------------------------------------------------
    
    % Get pixel-resolution static PRF.       
    pixelPrfStruct = obj.evaluate_static(row, column);
    pixelRows    = pixelPrfStruct.pixelRows;
    pixelColumns = pixelPrfStruct.pixelColumns;
    
    % Get subpixel-resolution static PRF        
    subPixelPrfStruct = ...
        obj.get_subsampled_static_prf_grid(row, column, ...
        pixelRows, pixelColumns);

    % Apply static correction        
    subPixelCorrectedPrfStruct = ...
                obj.apply_static_correction(subPixelPrfStruct);
    
    % Resample the result at pixel resolution.
    pixelCorrectedPrfStruct = obj.subsampled_grid_to_sampled_prf( ...
            subPixelCorrectedPrfStruct);        
            
    pixelResolutionDifferenceStruct = pixelPrfStruct;
    pixelResolutionDifferenceStruct.values = ...
        pixelPrfStruct.values - pixelCorrectedPrfStruct.values;
    subPixelResolutionDifferenceStruct = subPixelPrfStruct;
    subPixelResolutionDifferenceStruct.valueGrid = ...
        subPixelPrfStruct.valueGrid - subPixelCorrectedPrfStruct.valueGrid;
        
    %----------------------------------------------------------------------
    % Plot
    %----------------------------------------------------------------------
%     scrsz = get(0,'ScreenSize');
%     set(gcf, 'Position',[1 scrsz(4) 0.9*scrsz(3) scrsz(4)/3]);        
% 
%     % Plot the kernel.
%     subplot(1, 3, 1);
%     obj.staticKernelObject.plot_kernel(row, column);
% 
%     % Plot difference at sub-pixel resolution.
%     hAxes = subplot(1, 3, 2);
%     plot_subsampled_grid(hAxes, subPixelResolutionDifferenceStruct);
%     title('Subsampled Static - Corrected Static PRF');    
% 
%     % Plot difference at pixel resolution.
%     hAxes = subplot(1, 3, 3);
%     plot_sampled_prf(hAxes, pixelResolutionDifferenceStruct);
%     title('Static - Corrected Static PRF'); 
       
    % Plot the kernel.
    figure
    obj.staticKernelObject.plot_kernel(row, column);

    % Plot difference at sub-pixel resolution.
    figure;
    plot_subsampled_grid(gca, subPixelResolutionDifferenceStruct);
    title('Subsampled Static - Corrected Static PRF');    

    % Plot difference at pixel resolution.
    figure;
    plot_sampled_prf(gca, pixelResolutionDifferenceStruct);
    title('Static - Corrected Static PRF'); 
end


%**************************************************************************
function plot_sampled_prf(hAxes, sampledPrfStruct)
    [valueGrid, rowGrid, colGrid] = ...
        pixel_array_to_grid(sampledPrfStruct.values, ...
            sampledPrfStruct.pixelRows, sampledPrfStruct.pixelColumns);
        
    mesh(hAxes, colGrid, rowGrid, valueGrid, 'edgealpha', 0.3);

end


%**************************************************************************
function plot_subsampled_grid(hAxes, subsampledGridStruct)
    pixelRows    = subsampledGridStruct.pixelRows;
    pixelColumns = subsampledGridStruct.pixelColumns;
    spp          = subsampledGridStruct.samplesPerPix;
    subSamplingStep = 1.0/spp;
    
    % Determine the sub-row and sub-column mesh grids.
    pixelRowRange = min(subsampledGridStruct.pixelRows):max(pixelRows);
    ccdSubRows = repmat(rowvec(pixelRowRange), [spp, 1]) + ...
        subSamplingStep * repmat(colvec(0:spp-1), [1, length(pixelRowRange)]);
    ccdSubRows = ccdSubRows(:);

    pixelColRange = min(pixelColumns):max(pixelColumns);
    ccdSubCols = repmat(rowvec(pixelColRange), [spp, 1]) + ...
        subSamplingStep * repmat(colvec(0:spp-1), [1, length(pixelColRange)]);
    ccdSubCols = ccdSubCols(:);

    [ccdSubColGrid, ccdSubRowGrid] = meshgrid(ccdSubCols, ccdSubRows);

    mesh(hAxes, ccdSubColGrid, ccdSubRowGrid, ...
        subsampledGridStruct.valueGrid, 'edgealpha', 0.3);

end


%**************************************************************************
function [valueGrid, rowGrid, colGrid] = pixel_array_to_grid(pixVals, pixRows, pixCols)
% pixRows and pixCols are arrays of integer pixel locations.
%
    maxRow = max(pixRows(:));
    minRow = min(pixRows(:));
    maxCol = max(pixCols(:));
    minCol = min(pixCols(:));
    [colGrid, rowGrid] = meshgrid(minCol:maxCol, minRow:maxRow);

    nRows = maxRow - minRow + 1;
    nCols = maxCol - minCol + 1;        
    valueGrid = zeros(nRows, nCols);
    ind = sub2ind( size(valueGrid), pixRows - minRow + 1, pixCols - minCol + 1);    
    valueGrid(ind) = pixVals; 
end

%********************************** EOF ***********************************