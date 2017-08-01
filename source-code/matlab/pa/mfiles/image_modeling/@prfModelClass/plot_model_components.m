function plot_model_components(obj, row, column, cadence)        
%**************************************************************************
% Plot the static model values alongside the observed values. 
%
% INPUTS
%     row     : Fractional row position at which to evaluate the PRF model. 
%     column  : Fractional column position at which to evaluate the PRF
%               model.  
%     cadence : The cadence index on which to evaluate. If not specified,
%               the dynamic component is not plotted or applied to produce
%               the final PRF. 
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
    useStaticCorrection  = true;
    useDynamicCorrection = true;
    
    if isempty(obj.staticKernelObject) 
        useStaticCorrection = false;
    end
    if ~exist('cadence', 'var') || isempty(obj.dynamicKernelObject)
        useDynamicCorrection = false;
    end
        

    scrsz = get(0,'ScreenSize');
    set(gcf, 'Position',[1 scrsz(4) 0.7*scrsz(3) scrsz(4)]);    
    plotRows = 2 + useStaticCorrection + useDynamicCorrection;
    plotCols = 2;
    axesInd  = 1;
    
    
    % Plot static PRF        
    sampledPrfStruct = obj.evaluate_static(row, column);
    hAxes = subplot(plotRows, plotCols, axesInd);
    plot_sampled_prf(hAxes, sampledPrfStruct);
    title('Static PRF');    
    axesInd = axesInd + 1;

    pixelRows    = sampledPrfStruct.pixelRows;
    pixelColumns = sampledPrfStruct.pixelColumns;

    
    % Plot subsampled static PRF        
    subsampledGridStruct = ...
        obj.get_subsampled_static_prf_grid(row, column, ...
        pixelRows, pixelColumns);
    hAxes = subplot(plotRows, plotCols, axesInd);
    plot_subsampled_grid(hAxes, subsampledGridStruct);
    title('Subsampled Static PRF');    
    axesInd = axesInd + 1;

    
    % Plot static.
    if useStaticCorrection

        % Plot static correction kernel
        hAxes = subplot(plotRows, plotCols, axesInd);
        axes(hAxes);
        obj.staticKernelObject.plot_kernel(row, column);
        axesInd = axesInd + 1;

        % Plot static corrected
        subsampledGridStruct = ...
            obj.apply_static_correction(subsampledGridStruct);
        hAxes = subplot(plotRows, plotCols, axesInd);
        plot_subsampled_grid(hAxes, obj.get_subsampled_static_prf_grid( ...
            row, column, pixelRows, pixelColumns) )
        title('Subsampled Corrected Static PRF');    
        axesInd = axesInd + 1;
    end

    % Plot dynamic
    if useDynamicCorrection

    end

    
    % Plot final evaluated PRF.
    hAxes = subplot(plotRows, plotCols, axesInd);
    sampledPrfStruct = obj.subsampled_grid_to_sampled_prf( ...
        subsampledGridStruct);
    plot_sampled_prf(hAxes, sampledPrfStruct);
    title('Final PRF');    
    
end

function plot_sampled_prf(hAxes, sampledPrfStruct)
    [valueGrid, rowGrid, colGrid] = ...
        pixel_array_to_grid(sampledPrfStruct.values, ...
            sampledPrfStruct.pixelRows, sampledPrfStruct.pixelColumns);
        
    mesh(hAxes, colGrid, rowGrid, valueGrid, 'edgealpha', 0.3);

end

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
