function h = plot_star_locations_on_image( obj, cadenceIndex, keplerIds )
%**************************************************************************
% plot_star_locations_on_image( obj, cadenceIndex, keplerIds  )
%**************************************************************************
% Plot the modeled star positions (sky coordinates + motion model) on the
% image of observed pixels at the specified cadence.
%
% INPUTS
%     cadenceIndex : A valid index of one of the aperture model cadences.
%     keplerIds    : An array of selected kepler ID to be highlighted in
%                    the plot. 
%
% OUTPUTS
%     h            : A handle to the graphics object created.
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
    MARKER_SIZE = 7.0;
    
    if ~exist('cadenceIndex', 'var')
        cadenceIndex = 1;
    end
    
    if ~exist('keplerIds', 'var')
        keplerIds = [];
    end
    
    if obj.configStruct.raDecFittingEnabled
        legendLabels = {'Catalog RA/Dec', 'Fitted RA/Dec'};
    else
        legendLabels = {'Catalog RA/Dec'};
    end    

    nStars = obj.get_num_contributing_stars();
    motionPolyStruct = obj.motionModelHandle.get_motion_polynomials();
    
    %----------------------------------------------------------------------
    % Plot pixel image
    %----------------------------------------------------------------------
    pixRows = colvec([obj.observedPixels(:).ccdRow]);
    pixCols = colvec([obj.observedPixels(:).ccdColumn]);

    pixelValueMat = [obj.observedPixels(:).values]';
    pixelValueMat = pixelValueMat(:, cadenceIndex);
    
    hold off
    h = display_pixel_image(pixelValueMat, pixRows, pixCols, {'Modeled Star Locations', '(sky coordinates + motion model)'});
    hold on
    
    %----------------------------------------------------------------------
    % Plot the projected catalog and fitted star positions on the pixel
    % image.
    %----------------------------------------------------------------------
    quiverMat = [];
    for iStar = 1:nStars
        
        % Set marker face color.
        if obj.contributingStars(iStar).lockRaDec
            MarkerFaceColor = 'k';
        else
            MarkerFaceColor = 'r';
        end
        
        % Set marker edge color.
        if ismember(obj.contributingStars(iStar).keplerId, keplerIds)
            MarkerEdgeColor = 'g';
            MarkerEdgeWidth = 3.0;
        else
            MarkerEdgeColor = 'w';
            MarkerEdgeWidth = 1.1;
        end
        
        % Mark the position of the star predicted by the motion model and
        % catalog position. 
        catalogStarRow = weighted_polyval2d(obj.contributingStars(iStar).catalogRaDegrees, ...
            obj.contributingStars(iStar).catalogDecDegrees, motionPolyStruct(cadenceIndex).rowPoly);
        catalogStarCol = weighted_polyval2d(obj.contributingStars(iStar).catalogRaDegrees, ...
            obj.contributingStars(iStar).catalogDecDegrees, motionPolyStruct(cadenceIndex).colPoly);             
        plot(catalogStarCol, catalogStarRow, ...
             'LineStyle',       'none', ...
             'LineWidth',       MarkerEdgeWidth, ...
             'Marker',          's', ...
             'MarkerSize',      MARKER_SIZE, ...
             'MarkerEdgeColor', MarkerEdgeColor, ...
             'MarkerFaceColor', MarkerFaceColor); 

        % Mark the position of the star predicted by the motion model and
        % model position, which may differ from the catalog position if
        % RA/Dec fitting is enabled. 
        if obj.configStruct.raDecFittingEnabled && ~obj.contributingStars(iStar).lockRaDec
            modelStarRow = obj.contributingStars(iStar).centroidRow(cadenceIndex);
            modelStarCol = obj.contributingStars(iStar).centroidCol(cadenceIndex);
            plot(modelStarCol, modelStarRow, ...
                 'LineStyle',      'none', ...
                 'LineWidth',       MarkerEdgeWidth, ...
                 'Marker',          'o', ...
                 'MarkerSize',      MARKER_SIZE, ...
                 'MarkerEdgeColor', MarkerEdgeColor, ...
                 'MarkerFaceColor', MarkerFaceColor); 

             quiverMat = [quiverMat; [catalogStarCol, catalogStarRow, ...
                 modelStarCol - catalogStarCol, modelStarRow - catalogStarRow]];
        end
        
        % Create a legend after plotting predicted centroids for the first
        % star. 
        if iStar == 1
           hLeg = legend(legendLabels);
           set(hLeg, 'EdgeColor', 'k', 'LineWidth', 1, 'Location', 'Northeast');
        end
        
    end % for iStar = 1:nStars
    
    %----------------------------------------------------------------------
    % Plot arrows for stars whose positions have been updated.
    %----------------------------------------------------------------------
    if ~isempty(quiverMat)
        quiver(quiverMat(:,1), quiverMat(:,2), quiverMat(:,3), quiverMat(:,4), ...
            0, 'Color', 'r', 'MaxHeadSize', 0)
    end
end


%**************************************************************************
function h = display_pixel_image(pixVals, pixRows, pixCols, titleStr)
    if ~exist('titleStr', 'var')
        titleStr = '';
    end

    % Construct the image matrix.
    ccdRows     = colvec( min(pixRows) : max(pixRows) );
    ccdColumns  = colvec( min(pixCols) : max(pixCols) );

    M = length(ccdRows);
    N = length(ccdColumns);

    img = zeros(M, N);
    ind = sub2ind( size(img), pixRows-min(pixRows) + 1, pixCols-min(pixCols) + 1);
    img(ind) = pixVals;

    xRange = [min(pixCols), max(pixCols)];
    yRange = [min(pixRows), max(pixRows)];
        
    % Display the image.
    h = imagesc(xRange, yRange, img);
    title(titleStr, 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('pixel column');
    ylabel('pixel row');
    axis xy
    colorbar
end
