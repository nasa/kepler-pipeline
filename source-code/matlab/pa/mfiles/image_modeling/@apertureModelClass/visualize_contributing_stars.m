function visualize_contributing_stars(obj, cadence, spp, scalePrfsByCoefs)        
%**************************************************************************
% Plot the weighted PRFs. This shows both the aperture model and the
% surrounding areas. The constant offset term is ignored for the purposes
% of this plot.
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
    if ~exist('cadence', 'var')
        cadence = 1;
    end

    if ~exist('spp', 'var')
        spp = obj.prfModelHandle.samplesPerPixel;
    end

    if ~exist('scalePrfsByCoefs', 'var')
        scalePrfsByCoefs = false;
    end

    pixRows = obj.pixelRows;
    pixCols = obj.pixelColumns;
    
    scrsz = get(0,'ScreenSize');
    set(gcf, 'Position',[1 scrsz(4) 0.7*scrsz(3) scrsz(4)]);   
    hAxes = gca;
    
    %----------------------------------------------------------------------
    % Get normalized full-width PRFs for each contributing star.
    %----------------------------------------------------------------------
    nStars = obj.get_num_contributing_stars();
    for iStar = 1:nStars
        
        starRow    = obj.contributingStars(iStar).centroidRow(cadence);
        starColumn = obj.contributingStars(iStar).centroidCol(cadence);
        
        % Get the CCD row and column ranges.
        [~, rowArray, columnArray] = ...
            prfModelClass.evaluate_normalized_static_prf( ...
                obj.prfModelHandle.staticPrfObject, starRow, starColumn);
            
        subsampledGridStruct(iStar) = ...
                get_subsampled_static_prf_grid_explicit( ...
                    obj.prfModelHandle.staticPrfObject, ...
                    starRow, starColumn, rowArray, columnArray, spp);
    end
    
    %----------------------------------------------------------------------
    % Plot the PRFs of each star and their spatial relationship to the
    % aperture. 
    %----------------------------------------------------------------------
    insideApertureColor  = [1, 0, 0];
    outsideApertureColor = [0.5, 0.5, 0.5];
    peakCoordinates      = zeros(nStars, 3);
    
    for iStar = 1:nStars
        
        % Set up the color coding for inside/outside the aperture.
        m = size(subsampledGridStruct(iStar).ccdSubColGrid, 1);
        n = size(subsampledGridStruct(iStar).ccdSubColGrid, 2);    
        cdata = repmat(reshape(outsideApertureColor, [1,1,3]), [m,n,1]);
        insideIndicators = ismember( ...
            [ colvec(fix(subsampledGridStruct(iStar).ccdSubRowGrid)), ...
              colvec(fix(subsampledGridStruct(iStar).ccdSubColGrid)) ], ...
              [pixRows, pixCols], 'rows');
        [r, c] = ind2sub([m, n], find(insideIndicators));
        cdata(sub2ind([m, n 3], r, c,   ones(size(r)))) = insideApertureColor(1);
        cdata(sub2ind([m, n 3], r, c, 2*ones(size(r)))) = insideApertureColor(2);
        cdata(sub2ind([m, n 3], r, c, 3*ones(size(r)))) = insideApertureColor(3);
        
        % Scale PRFs by the model coefficients, if desired.
        if scalePrfsByCoefs
            coef = obj.coefficients(cadence, iStar);
        else
            coef = 1.0;
        end
        
        % Plot this star's PRF.
        surf(hAxes, ...
             subsampledGridStruct(iStar).ccdSubColGrid, ...
             subsampledGridStruct(iStar).ccdSubRowGrid, ...
             coef * subsampledGridStruct(iStar).valueGrid, ...
             'CData', cdata, 'edgealpha', 0.3);
         
        % Identify the plot coordinates (x,y,z) of this PRF's peak value.
        [~, peakIdx] = max(coef * subsampledGridStruct(iStar).valueGrid(:));
        peakCoordinates(iStar, :) = ...
            [ subsampledGridStruct(iStar).ccdSubColGrid(peakIdx), ...
              subsampledGridStruct(iStar).ccdSubRowGrid(peakIdx), ...
              subsampledGridStruct(iStar).valueGrid(peakIdx) ];
        
        hold(hAxes, 'on');
    end  

    %----------------------------------------------------------------------
    % Add text and formatting.
    %----------------------------------------------------------------------
    if scalePrfsByCoefs
        zStr = 'Log Flux-Weighted Pixel Response';
        set(hAxes, 'zscale', 'log');
    else
        zStr = 'Normalized Pixel Response';
    end

    title( sprintf('Contributing Star PRFs\n(cadence %d)', cadence) );
    xlabel('CCD Column');
    ylabel('CCD Row');
    zlabel(zStr);

    % Label peaks
    for iStar = 1:nStars
        peakLabel = num2str(obj.contributingStars(iStar).keplerId);
        text(peakCoordinates(iStar, 1), ...
             peakCoordinates(iStar, 2), ...
             peakCoordinates(iStar, 3), ...
             peakLabel, 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    h_title = get(hAxes,'Title');
    titleProperties  = struct(...
        'FontName',  'Arial', ...
        'FontUnits', 'points', ...
        'FontSize', 16, ...
        'FontWeight', 'bold' ...
    );
    set(h_title, titleProperties);

    
    h_xlab  = get(hAxes,'XLabel');
    h_ylab  = get(hAxes,'YLabel');
    h_zlab  = get(hAxes,'ZLabel');
    axisLabelProperties = struct(...
        'FontName',  'Arial', ...
        'FontUnits', 'points', ...
        'FontSize', 14, ...
        'FontWeight', 'bold' ...
        );
    set(h_xlab,  axisLabelProperties);
    set(h_ylab,  axisLabelProperties);
    set(h_zlab,  axisLabelProperties);
    
end


function subsampledGridStruct = get_subsampled_static_prf_grid_explicit( prfObj,...
        starRow, starColumn, pixelRows, pixelColumns, spp)
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
%     spp          : Integer number of samples per pixel. If not provided, 
%                    the value of obj.samplesPerPixel is used.
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
                prfObj, starSubRow, starSubCol, ...
                ccdRowGrid(:), ccdColGrid(:));
            
            % prfValues may be empty, so only assign values if it is not.
            if numel(prfValues) == numel(ind)
                subSampledGrid(ind) = prfValues;
            end
            
            % Note the sum of the static PRF evaluated over the set of
            % pixels.
            if i == 1 && j == 1
                valueSum = sum(sum(subSampledGrid(ind)));
            end
        end
    end
    
    % Determine the sub-row and sub-column mesh grids.
    pixelRowRange = min(pixelRows):max(pixelRows);
    ccdSubRows = repmat(rowvec(pixelRowRange), [spp, 1]) + ...
        subSamplingStep * repmat(colvec(0:spp-1), [1, length(pixelRowRange)]);
    ccdSubRows = ccdSubRows(:);

    pixelColRange = min(pixelColumns):max(pixelColumns);
    ccdSubCols = repmat(rowvec(pixelColRange), [spp, 1]) + ...
        subSamplingStep * repmat(colvec(0:spp-1), [1, length(pixelColRange)]);
    ccdSubCols = ccdSubCols(:);

    [ccdSubColGrid, ccdSubRowGrid] = meshgrid(ccdSubCols, ccdSubRows);
    
    % Populate the output struct.
    subsampledGridStruct.starRow       = starRow;
    subsampledGridStruct.starColumn    = starColumn;
    subsampledGridStruct.pixelRows     = pixelRows;
    subsampledGridStruct.pixelColumns  = pixelColumns;
    subsampledGridStruct.valueGrid     = subSampledGrid;
    subsampledGridStruct.valueSum      = valueSum;
    subsampledGridStruct.sampPerPix    = spp;
    subsampledGridStruct.ccdSubRowGrid = ccdSubRowGrid;
    subsampledGridStruct.ccdSubColGrid = ccdSubColGrid;

end

%********************************** EOF ***********************************
