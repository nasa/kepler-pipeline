function plot_target_centroids(outputTargetStruct, cadences)
%**************************************************************************
% function plot_target_centroids(outputTargetStruct, cadences)
%**************************************************************************
% Plot the output flux-weighted centroids of PA targets. 
%
% INPUTS
%     outputTargetStruct : An array of corresponding output target results 
%                          structures.
%     cadences           : An array of cadence indices to plot. If empty,
%                          plot all available cadences (default = []). 
%
% OUTPUTS
%     There are two sub-plots in the figure:
%
%     Left:  An XY scatter plot of the centroid migration on the focal
%            plane.
%     Right: Row and column centroid time series.
%
% USAGE EXAMPLES
%
% NOTES
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
    YSTRETCH = 0.4;
    
    nCadences = length(outputTargetStruct(1).fluxWeightedCentroids.rowTimeSeries.values);
    
    % Check arguments.
    if ~exist('cadences', 'var')
        cadences = 1:nCadences;
    end       
              
    nTargets = numel(outputTargetStruct);
    
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
        haOutMask = subplot(1, 4, 1);
        haOutTs   = subplot(1, 4, 2:4);
        
            
        disp('Output Target Results Struct:');
        disp(outputTargetStruct(iTarget));

        axes( haOutMask );
        hold off
        optimalAperture = outputTargetStruct(iTarget).optimalAperture;

        hold on
        % Plot optimal aperture.
        oaRows = optimalAperture.referenceRow    + [optimalAperture.offsets.row];
        oaCols = optimalAperture.referenceColumn + [optimalAperture.offsets.column];
        plot_aperture_outline(oaRows, oaCols, true(size(oaRows)), '-');
        grid on;
        
        % Aperture plot.
        fwCentroids   = outputTargetStruct(iTarget).fluxWeightedCentroids;
        gapIndicators = fwCentroids.rowTimeSeries.gapIndicators | fwCentroids.columnTimeSeries.gapIndicators;
        fwCentroidRow = fwCentroids.rowTimeSeries.values;
        fwCentroidRow(gapIndicators) = NaN;
        fwCentroidCol = fwCentroids.columnTimeSeries.values;
        fwCentroidCol(gapIndicators) = NaN;
        
        scatter(fwCentroidCol, fwCentroidRow, 'r');   
        title('Flux-Weighted Centroid Migration', 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('CCD Column','FontSize', 12);
        ylabel('CCD Row','FontSize', 12);
        axis xy
        set(haOutMask, 'Box', 'on');
        set(haOutMask, 'Box', 'on');
        
        xRange = [nanmin(fwCentroidCol) nanmax(fwCentroidCol)];
        yRange = [nanmin(fwCentroidRow) nanmax(fwCentroidRow)];
        
        xStart = floor(xRange(1)*100)/100;
        xStop  = ceil(xRange(2)*100)/100;
        xTicks = [xStart:0.01:xStop];
        set(haOutMask, 'XTick', xTicks);
        yStart = floor(yRange(1)*100)/100;
        yStop  = ceil(yRange(2)*100)/100;
        yTicks = [yStart:0.01:yStop];
        set(haOutMask, 'YTick', yTicks);

        xlim([xStart, xStop]);
        ylim([yStart, yStop]);
        
        % Time series plot.
        axes( haOutTs );
        [ax, h1, h2] = plotyy(cadences, fwCentroidRow, cadences, fwCentroidCol);
        set(h1,'LineStyle','--','LineWidth', 2.0);
        set(h2,'LineStyle','-','LineWidth', 2.0);
        set(get(ax(1),'Xlabel'),'String','Cadence','FontSize', 12);
        set(get(ax(1),'Ylabel'),'String','CCD Row','FontSize', 12);
        set(get(ax(2),'Ylabel'),'String','CCD Column','FontSize', 12);
        grid on
        title('Flux-Weighted Centroid Time Series', 'FontSize', 12, 'FontWeight', 'bold');
        legend('Centroid Row', 'Centroid Column');
        
        % Wait for user input.
        reply = input('Press ''q'' to QUIT. Any other key to continue: ', 's');
        if strcmpi(reply, 'q')
            break
        end
    end
   
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
            'LineWidth', 2, 'color', 'k');
    end % if

end


