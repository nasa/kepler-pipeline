function plot_pa_targets(inputTargetStruct, outputTargetStruct, cadences, ...
    inputApertureType, motionPolyStruct)
%**************************************************************************
% function plot_pa_targets(inputTargetStruct, outputTargetStruct, cadences, ...
%     inputApertureType, motionPolyStruct)
%**************************************************************************
% Plot the input and output time series and apertures of PA targets. If
% motion polynomials are provided, plot star positions within the
% apertures.
%
% INPUTS
%     inputTargetStruct  : An array target data structures (may be empty).
%     outputTargetStruct : An array of corresponding output target results 
%                          structures (may be empty).
%     cadences           : An array of cadence indices to plot. If empty,
%                          plot all available cadences (default = []). 
%     inputApertureType  : Plot the sum of input pixels within the
%                          specified aperture. Valid values are 'tad',
%                          'mask', and '' (default = '').
%     motionPolyStruct   : If provided, the locations of all KIC objects
%                          will be plotted along with the input mask.
%
% OUTPUTS
%     There are four sub-plots in the figure:
%
%     Upper left:  Median (in time) input pixel values are shown for the 
%                  entire target mask with the border of the TAD optimal
%                  aperture shown in white. The median target position is
%                  plotted as a green circle with black interior. Median
%                  positions of background stars in the mask are plotted as
%                  white circles. The spread of each star's position,
%                  representing its motion over all cadences, is
%                  shown as a gray cloud of points under the median
%                  position marker.  
%     Upper right: The sum of input pixels (before cosmic ray cleaning or
%                  background subtraction) over the specified aperture
%                  (either the TAD optimal aperture or the entire mask). 
%     Lower left:  Valid pixels in the target mask are shown along with the
%                  borde, in white, of the photometric aperture used to
%                  obtain the raw light curve. If input pixels were
%                  provided their median values are also displayed,
%                  otherwise pixel values are set to zero.
%     Lower right: The raw light curve delivered by PA for the target.
%
% USAGE EXAMPLES
%     Plot input and output for target index 7. Display sum of input pixels
%     within the TAD optimal aperture at each cadence and show median
%     positions and spread for all known stars within the aperture.
%     >> plot_pa_targets(inputsStruct.targetStarDataStruct(7), ...
%        outputsStruct.targetStarResultsStruct(7), 'tad', motionPolyStruct)
%
%     Plot output apertures and raw light curves for each target in the
%     output structure. In this case individual pixels are unavailable and
%     cannot be plotted.
%     >> plot_pa_targets([], outputsStruct.targetStarResultsStruct)
%
%     Plot the sum of the input pixels over the entire target mask for
%     cadences 1:50 and 1000:2000.
%     >> plot_pa_targets(inputsStruct.targetStarDataStruct, [], ...
%        [1:500, 1000:2000], 'mask')
%
% NOTES
%   - If both inputTargetStruct and outputTargetStruct are non-empty, they
%     must be aligned (same Kepler IDs in the same order) or an error will
%     be thrown.
%   - Note that motion polynomials operate in 1-based coordinates, while
%     the target data structs in pa-inputs-0.mat and pa-outputs-0.mat are
%     0-based. Motion polynomial-derived row and column positions are
%     converted to 0-based coordinates before being used in plotting.
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
    
    % Initialize.
    XSTRETCH = 0.7;
    YSTRETCH = 0.7;
    
    nInputTargets  = 0;
    nOutputTargets = 0;
    
    % Check arguments.
    if ~exist('cadences', 'var')
        cadences = [];
    end
    
    if exist('inputTargetStruct',  'var')
        nInputTargets = numel(inputTargetStruct);
    end
    if exist('outputTargetStruct', 'var')
        nOutputTargets = numel(outputTargetStruct);    
    end
    if ~exist('inputApertureType', 'var')
        inputApertureType = 'tad';    
    end
    if ~exist('motionPolyStruct', 'var')
        motionPolyStruct = [];    
    end
    
    
    if nInputTargets > 0 && nOutputTargets > 0
        if ~isequal([inputTargetStruct.keplerId], [outputTargetStruct.keplerId])
            error('Input and output targets must agree in number and order.');
        end
    end
          
    nTargets = max([nInputTargets, nOutputTargets]);
    
    % Loop over targets.
    for iTarget = 1:nTargets
        fprintf('Plotting target %d of %d ...\n', iTarget, nTargets);
        fprintf('------------------------------------\n');
       
        % Create figures.
        if exist('hf', 'var')
            close(hf);
        end
        hf = figure('color', 'white');
        scrsz = get(0,'ScreenSize');
        set(hf, 'Position',[1 YSTRETCH*scrsz(4) XSTRETCH*scrsz(3) YSTRETCH*scrsz(4)]);    
        haInMask = subplot(2, 4, 1);
        haInTimeSeries = subplot(2, 4, 2:4);
        haOutMask = subplot(2, 4, 5);
        haOutRaw = subplot(2, 4, 6:8);
        
        if nInputTargets > 0
            
            disp('Input Target Data Struct:');
            disp(inputTargetStruct(iTarget));
            
            axes( haInMask );
            hold off
            medianPixelValues = plot_median_aperture(inputTargetStruct(iTarget).pixelDataStruct, 'TAD Optimal Aperture', cadences);

            hold on
            if ~isempty(motionPolyStruct)
                 plot_star_positions( gca, inputTargetStruct(iTarget), motionPolyStruct);
            end
            axes( haInTimeSeries );
            hold off
            switch inputApertureType
                case 'mask'
                    titleStr = sprintf('Summed Input Pixels (full mask): KIC %d, kmag= %0.2f', ...
                        inputTargetStruct(iTarget).keplerId, inputTargetStruct(iTarget).keplerMag);
                    plot_summed_time_series(inputTargetStruct(iTarget).pixelDataStruct, titleStr, cadences);
                case 'tad'
                    titleStr = sprintf('Summed Input Pixels (TAD aperture): KIC %d, kmag= %0.2f', ...
                        inputTargetStruct(iTarget).keplerId, inputTargetStruct(iTarget).keplerMag);
                    inAperture = [inputTargetStruct(iTarget).pixelDataStruct.inOptimalAperture];
                    plot_summed_time_series(inputTargetStruct(iTarget).pixelDataStruct(inAperture), titleStr, cadences);
                otherwise
                    titleStr = sprintf('Input Pixel Time Series: KIC %d, kmag= %0.2f', ...
                        inputTargetStruct(iTarget).keplerId, inputTargetStruct(iTarget).keplerMag);
                    plot_time_series(inputTargetStruct(iTarget).pixelDataStruct, titleStr, cadences);
            end
        end

        if nOutputTargets > 0
            
            disp('Output Target Results Struct:');
            disp(outputTargetStruct(iTarget));
            
            axes( haOutMask );
            hold off
            apertureStruct  = outputTargetStruct(iTarget).pixelApertureStruct;
            optimalAperture = outputTargetStruct(iTarget).optimalAperture;
            pixRows = [apertureStruct.ccdRow];
            pixCols = [apertureStruct.ccdColumn];
            if nInputTargets < 1 || ~exist('medianPixelValues','var') || length(medianPixelValues) ~= length(pixRows)
                medianPixelValues = zeros(size(pixRows));
                outputApertureSubtitle = '(pixel values unavailable)';
            else
                outputApertureSubtitle = '(median pixel values)';
            end
            display_pixel_image(medianPixelValues, pixRows, pixCols, {'Used Optimal Aperture', outputApertureSubtitle});
            hold on
            oaRows = optimalAperture.referenceRow    + [optimalAperture.offsets.row];
            oaCols = optimalAperture.referenceColumn + [optimalAperture.offsets.column];
            plot_aperture_outline(oaRows, oaCols, true(size(oaRows)), '-');
            
            hold on
            if ~isempty(motionPolyStruct) && ~isempty(inputTargetStruct)
                 plot_star_positions( gca, inputTargetStruct(iTarget), motionPolyStruct);
            end
            
            axes( haOutRaw );
            hold off
            titleStr = sprintf('Raw Light Curve (used aperture): KIC %d, kmag= %0.2f', ...
                outputTargetStruct(iTarget).keplerId, outputTargetStruct(iTarget).keplerMag);
            plot_time_series(outputTargetStruct(iTarget).fluxTimeSeries, titleStr, cadences);
        end
                
        linkaxes([haInTimeSeries, haOutRaw], 'x');
        
        % Wait for user input.
        reply = input('Press ''q'' to QUIT. Any other key to continue: ', 's');
        if strcmpi(reply, 'q')
            break
        end
    end
   
end


%**************************************************************************
function plot_time_series(tsArray, titleStr, cadences )
    nPixels   = numel(tsArray);
    nCadences = length(tsArray(1).values);
    cadenceIndicators = false(nCadences, 1);
    
    if ~exist('cadences', 'var') || isempty(cadences)
        cadences = 1:nCadences;
    end
        
    cadenceIndicators(cadences) = true;
    
    valMat = [tsArray.values];
    gapMat = [tsArray.gapIndicators];
    valid  = ~gapMat & repmat(cadenceIndicators, [1, nPixels]);
    valMat(~valid) = NaN;
    
    plot(valMat);
    grid on
    title(titleStr, 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Cadence');
    ylabel('Flux (e-/sec)');
    xlim([min(cadences), max(cadences)]);
    ylim([nanmin(colvec(valMat(valid))), nanmax(colvec(valMat(valid)))]);
end


%**************************************************************************
function plot_summed_time_series(tsArray, titleStr, cadences )
    nPixels   = numel(tsArray);
    nCadences = length(tsArray(1).values);
    cadenceIndicators = false(nCadences, 1);
    
    if ~exist('cadences', 'var') || isempty(cadences)
        cadences = 1:nCadences;
    end
    
    cadenceIndicators(cadences) = true;
    
    valMat = [tsArray.values];
    gapMat = [tsArray.gapIndicators];
    valid  = ~gapMat & repmat(cadenceIndicators, [1, nPixels]);
    valMat(~valid) = NaN;
    
    valSum = nansum(valMat, 2);
    valid = any(valid, 2);
    valSum(~valid) = nan;
    
    plot(valSum);
    grid on
    title(titleStr, 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Cadence');
    ylabel('Flux (e-/sec)');
    xlim([min(cadences), max(cadences)]);
    ylim([prctile(valSum, 1.0), prctile(valSum, 99.0)]);
end

%**************************************************************************
function medianValueArray = plot_median_aperture(pixelArray, titleStr, cadences)

    nPixels   = numel(pixelArray);
    nCadences = length(pixelArray(1).values);
    medianValueArray = nan(nPixels, 1);
    
    if ~exist('cadences', 'var') || isempty(cadences)
        cadenceIndicators = true(nCadences, 1);        
    else
        cadenceIndicators = false(nCadences, 1);
        cadenceIndicators(cadences) = true;
    end
    
    for iPixel = 1:numel(pixelArray)
        validCadences = cadenceIndicators & ~pixelArray(iPixel).gapIndicators;
        medianValueArray(iPixel) = nanmedian(pixelArray(iPixel).values(validCadences));
    end
    
    rowArray   = colvec([pixelArray.ccdRow]);
    colArray   = colvec([pixelArray.ccdColumn]);
    inAperture = colvec([pixelArray.inOptimalAperture]);
    
    display_pixel_image(medianValueArray, rowArray, colArray, {titleStr, '(median pixel values)'});
    hold on
    plot_aperture_outline(rowArray, colArray, inAperture, '-');
    hold off
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

    img = nan(M, N);
    ind = sub2ind( size(img), pixRows-min(pixRows) + 1, pixCols-min(pixCols) + 1);
    img(ind) = pixVals;

    xRange = [min(pixCols), max(pixCols)];
    yRange = [min(pixRows), max(pixRows)];
        
    % Display the image.
    h = imagesc(xRange, yRange, img);
    set(h, 'AlphaData', ~isnan(img)); % Set alpha=1 fro data and 0 for NaN.

    title(titleStr, 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('pixel column');
    ylabel('pixel row');
    axis xy
    colorbar
    
end

function plot_aperture_outline(ccdRows, ccdColumns, inAperture, lineStyle)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_aperture_outline(ccdRows, ccdColumns, inAperture, lineStyle)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the outline of the pixels in the given aperture. Cycle through the
% pixels that are identified as included in the specified aperture, save
% the new line segments that outline them and remove any segments between
% them.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    % Loop through the pixels and iteratively save the aperture outline.
    mergedSegments = [];

    for iPixel = find(inAperture(:)')

        ccdRow = ccdRows(iPixel);
        ccdColumn = ccdColumns(iPixel);

        pixelSegments = ( ...
            [ccdColumn-0.5, ccdColumn+0.5, ccdRow-0.5, ccdRow-0.5; ...
             ccdColumn+0.5, ccdColumn+0.5, ccdRow-0.5, ccdRow+0.5; ...
             ccdColumn-0.5, ccdColumn+0.5, ccdRow+0.5, ccdRow+0.5; ...
             ccdColumn-0.5, ccdColumn-0.5, ccdRow-0.5, ccdRow+0.5]);
         commonSegments = intersect(mergedSegments, pixelSegments, 'rows');
         mergedSegments = ...
             setdiff([mergedSegments; pixelSegments], commonSegments, 'rows');

    end % for iPixel

    % Plot the segments with the given line style.
    if ~isempty(mergedSegments)
        plot(mergedSegments( : , 1 : 2)', mergedSegments( : , 3 : 4)', lineStyle, ...
            'LineWidth', 2, 'color', 'w');
    end % if

end


%**************************************************************************
% plot_star_locations_on_image( haxes, targetStruct, motionPolyStruct, cadenceIndicators )
%**************************************************************************
% Plot the modeled star positions (sky coordinates + motion model) on the
% image of observed pixels at the specified cadence.
%
% NOTES
%   - Note that motion polynomials operate in 1-based coordinates, while
%     the target data structs in pa-inputs-0.mat and pa-outputs-0.mat are
%     0-based.
%**************************************************************************
function plot_star_positions( haxes, targetStruct, motionPolyStruct, cadenceIndicators)

    MARKER_SIZE = 7^2; %7.0;
    SPREAD_MARKER_COLOR = [0.7 0.7 0.7];
    DEGREES_PER_HOUR = 15;
    
    nCadences = length(targetStruct(1).pixelDataStruct(1).values);
    
    if ~exist('cadenceIndicators', 'var') || isempty(cadenceIndicators)
        cadenceIndicators = true(nCadences, 1);
    end
        
    targetId = targetStruct.keplerId;
    
    [kepIdArray, kepMagArray, raHoursArray, decDegreesArray] = ...
    apertureModelClass.get_attribute_arrays_from_catalog_struct(targetStruct.kics);

    starStruct = struct( ...
        'keplerId',            num2cell(kepIdArray), ...
        'keplerMag',           num2cell(kepMagArray), ...
        'raDegrees',           num2cell(DEGREES_PER_HOUR*raHoursArray), ...
        'decDegrees',          num2cell(decDegreesArray) ...
    );
                   
    %----------------------------------------------------------------------
    % Plot the motion poly-predicted catalog positions on the pixel image.
    %----------------------------------------------------------------------
    nStars = numel(starStruct);
    for iStar = 1:nStars
        % Get KIC parameters
        keplerId      = starStruct(iStar).keplerId;
        keplerMag     = starStruct(iStar).keplerMag;
        kicRaDegrees  = starStruct(iStar).raDegrees;
        kicDecDegrees = starStruct(iStar).decDegrees;
                
        % skip custom targets.
        if is_valid_id(keplerId, 'custom')
            continue;
        end
        
        MarkerFaceColor = 'k';
        
        % Set marker edge color. Highlight the target star in green.
        if keplerId == targetId
            MarkerEdgeColor = 'g';
            MarkerEdgeWidth = 2.5;
        elseif is_valid_id(keplerId, 'ukirt')
            MarkerEdgeColor = 'y';
            MarkerEdgeWidth = 2.5;
        else
            MarkerEdgeColor = 'w';
            MarkerEdgeWidth = 2.5;
        end
        
        % Mark the median position of the star predicted by the motion 
        % model and catalog position.
        starRow = zeros(nCadences, 1);
        starCol = zeros(nCadences, 1);
        for iCadence = 1:nCadences
            if cadenceIndicators(iCadence)
                starRow(iCadence) = weighted_polyval2d(...
                    kicRaDegrees, kicDecDegrees, ...
                    motionPolyStruct(iCadence).rowPoly);
                starCol(iCadence) = weighted_polyval2d( ...
                    kicRaDegrees, kicDecDegrees, ...
                    motionPolyStruct(iCadence).colPoly);
            end
        end
        medianCatalogStarRow = median(starRow(cadenceIndicators));
        medianCatalogStarCol = median(starCol(cadenceIndicators));
                                  

        % Plot the spread of the current star's position over time.
        h2 = scatter(haxes, starCol - 1, starRow -1, 1.0, ...
             'LineWidth',       1.0, ...
             'Marker',          '.', ...
             'MarkerEdgeColor', SPREAD_MARKER_COLOR, ...
             'MarkerFaceColor', SPREAD_MARKER_COLOR); 
         
        % Plot the median position of the current star.
        h1 = scatter(haxes, medianCatalogStarCol - 1, medianCatalogStarRow - 1, MARKER_SIZE, ...
             'LineWidth',       MarkerEdgeWidth, ...
             'Marker',          'o', ...
             'MarkerEdgeColor', MarkerEdgeColor, ...
             'MarkerFaceColor', MarkerFaceColor); 
         
        % Print the kepler magnitudes next to each point.
        if ~isempty(keplerMag) && isfinite(keplerMag)
            x = medianCatalogStarCol - 1;
            y = medianCatalogStarRow - 1;
            xWindowLimits = xlim;
            yWindowLimits = ylim;
            if x >= xWindowLimits(1) && x <= xWindowLimits(2) && y >= yWindowLimits(1) && y <= yWindowLimits(2)
                offset = 0.25 * diff(xWindowLimits) / sqrt(MARKER_SIZE);
                text(x + offset, y, sprintf('%2.1f', keplerMag), 'horizontalalignment','left', ...
                'verticalalignment','top', 'FontSize', 10, 'FontWeight', 'bold', 'color','m');
            end
        end
    end % for iStar = 1:nStars
    
end

