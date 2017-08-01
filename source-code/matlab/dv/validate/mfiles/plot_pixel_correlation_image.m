function [dvResultsStruct] = plot_pixel_correlation_image( targetStruct, dvResultsStruct, pixelCorrelationConfigurationStruct, kics, targetTableDataStruct )

% function [dvResultsStruct] = plot_pixel_correlation_image( targetStruct, dvResultsStruct, pixelCorrelationConfigurationStruct, kics, targetTableDataStruct)
% 
% This is a helper function called by perform_dv_pixel_correlation_tests to
% plot the correlation statistic for all the pixels in a target as an
% image. The image is then saved as a MATLAB .fig file in the pixel
% correlation test output directory for the target being processed. If
% correlation data is available, an image is produced for each planet
% candidate and each target table Id. If insufficent data is available an
% alert is issued. 
%
% INPUT:
% targetStruct                          = target data struct from the dvDataObject for a single
%                                           target. e.g. dvDataObject.targetStruct(iTarget);
% dvResultsStruct                       = dv results struct for all targets
% pixelCorrelationConfigurationStruct   = configuration parameters
% kics                                  = kic parameters for DV target(s) and nearby objects in skygroup
% targetTableDataStruct                 = includes motion polynomials for each target table
%
% OUTPUT:
% dvResultsStruct                       = dv results struct for all targets with alerts
%                                         field modified if any alerts were generated
%
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


% hard coded constants
pixelCorrelationSubdirectory = 'pixel-correlation-test-results';

HALO_PIXELS = 1;
PIXELS_TO_PAD = 0.5;

% unpack parameters
COLOR_MAP               = pixelCorrelationConfigurationStruct.colorMap;
C_AXIS                  = [0, pixelCorrelationConfigurationStruct.maxColorAxis];
SIGNIFICANCE_THRESHOLD  = pixelCorrelationConfigurationStruct.significanceThreshold;
APERTURE_SYMBOL         = pixelCorrelationConfigurationStruct.apertureSymbol;
OPTIMAL_APERTURE_SYMBOL = pixelCorrelationConfigurationStruct.optimalApertureSymbol;
SIGNIFICANCE_SYMBOL     = pixelCorrelationConfigurationStruct.significanceSymbol;

% unpack variables
dvFiguresRootDirectory = dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).dvFiguresRootDirectory; 
keplerId = dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).keplerId;
nPlanets = length(dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct);
targetIndex = targetStruct.targetIndex;

FIGURE_CAPTION = ['Pixel correlation statistics for target %d, ',...
                    'planet candidate %d, quarter %d, target table %d. ',...
                    'This figure displays the pixel correlation statistic ',...
                    'for all pixels in the target mask. The optimal aperture is outlined ',...
                    'with a white dash-dotted line and the target mask is outlined with a solid white line. ',...
                    'Symbol key: ', ...
                    'x: target position from KIC RA and Dec converted to CCD coordinates via motion polynomials; ',...
                    '*: position of nearby KIC objects converted to CCD coordinates via motion polynomials (objects in the UKIRT extension ', ...
                    'to the KIC have IDs between 15,000,000 and 30,000,000); ', ...
                    '+: PRF-fit location of target from out-of-transit image; ',...
                    'triangle: PRF-fit location of transit source from the pixel correlation image; ',...
                    'square: pixels with a correlation significance above the threshold of %g; ',...
                    'filled circle: pixels for which the iterative whitener did not converge and there is no correlation statistic. ', ...
                    'CCD row and column coordinates are 0-based.'];

% loop over planets
tableIds = [targetTableDataStruct.targetTableId];

for iPlanet = 1:nPlanets
    
    nTables = length(dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults);
    
    % loop over target tables
    for iTable = 1:nTables
        
        quarter  = dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).quarter;
        tableId  = dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).targetTableId;

        pixelDataFileName = targetStruct.targetDataStruct(iTable).pixelDataFileName;
        [pixelMetaDataStruct, status, path, name, ext] = ...
            file_to_struct(pixelDataFileName, 'pixelMetaDataStruct');                       %#ok<ASGLU>
        if ~status
            error('DV:plotPixelCorrelationImage:unknownDataFileType', ...
                'unknown pixel data file type (%s%s)', ...
                name, ext);
        end % if
        row = [pixelMetaDataStruct.ccdRow];
        col = [pixelMetaDataStruct.ccdColumn];
        inOptimalAperture = [pixelMetaDataStruct.inOptimalAperture];
        clear pixelMetaDataStruct

        val = [dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct.value];
        sig = [dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct.significance];

        % create logical indexing and set invalid values to NaN
        validSignificance = (sig ~= -1);
        val(~validSignificance) = NaN;

        if( ~all(isnan(val)) )
            
            % set up image array dims
            minRow = min(row) - HALO_PIXELS;
            maxRow = max(row) + HALO_PIXELS;
            nRows = maxRow - minRow + 1;
            minCol = min(col) - HALO_PIXELS;
            maxCol = max(col) + HALO_PIXELS;
            nCols = maxCol - minCol + 1;

            % populate values image (V) array
            V = nan( nRows, nCols );
            V( (row-minRow+1) + (col-minCol)*nRows ) = val;

            % find pixels w/significant correlation statistic ( e.g. > 0.99 significance)
            significanceLogical = sig > SIGNIFICANCE_THRESHOLD;        
        
            % plot correlation statistic image
            h = figure;
            imagesc( (minCol:maxCol)-1, (minRow:maxRow)-1, V );
            axis xy;
            % set colormap - default == 'hot'
            if( ~isempty(COLOR_MAP) )
                colormap(COLOR_MAP);
            else
                colormap('jet');
            end
            % set c-axis - default clips at min and max valid points
            if( isequal(C_AXIS, [0,0]) )
                caxis([min(val(validSignificance)), max(val(validSignificance))]);
            else
                caxis(C_AXIS);
            end             
            colorbar;

            % overlay symbols marking statistically significant pixels, and
            % outline the optimal aperture and pixel mask
            hold on;
            
            plot(col(inOptimalAperture & ~validSignificance)-1, row(inOptimalAperture & ~validSignificance)-1, ...
                [OPTIMAL_APERTURE_SYMBOL,'w'], 'MarkerSize', 10, 'MarkerFaceColor', 'white');
            
            plot(col(~inOptimalAperture & ~validSignificance)-1, row(~inOptimalAperture & ~validSignificance)-1, ...
                [APERTURE_SYMBOL,'w'], 'MarkerSize', 10, 'MarkerFaceColor', 'white');
            
            plot(col(significanceLogical)-1, row(significanceLogical)-1, ...
                [SIGNIFICANCE_SYMBOL,'w'], 'MarkerSize', 10, 'LineWidth', 1);
            
            plot_aperture_outline(row-1, col-1, inOptimalAperture, '-.w');
            plot_aperture_outline(row-1, col-1, true(size(inOptimalAperture)), '-w');
            
            % overlay kic reference position and positions of nearby KIC
            % objects; note that row and column ranges and coordinates are
            % zero-based
            kicReferenceCentroid = ...
                dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).kicReferenceCentroid;
            motionPolyStruct = ...
                targetTableDataStruct(tableIds == tableId).motionPolyStruct;
            [locationOfObjectsInBoundingBox] = ...
                locate_nearby_kic_objects(keplerId, kics, ...
                motionPolyStruct, kicReferenceCentroid, ...
                [minRow; maxRow]-1, [minCol; maxCol]-1);
            
            zeroBasedMinRow = minRow - 1;
            zeroBasedMaxRow = maxRow - 1;
            zeroBasedMinColumn = minCol - 1;
            zeroBasedMaxColumn = maxCol - 1;
            
            for iKic = 1 : length(locationOfObjectsInBoundingBox)

                objectId = locationOfObjectsInBoundingBox(iKic).keplerId;
                objectMag = locationOfObjectsInBoundingBox(iKic).keplerMag;
                isPrimaryTarget = locationOfObjectsInBoundingBox(iKic).isPrimaryTarget;
                kicRow = locationOfObjectsInBoundingBox(iKic).zeroBasedRow;
                kicColumn = locationOfObjectsInBoundingBox(iKic).zeroBasedColumn;

                if kicRow >= zeroBasedMinRow-PIXELS_TO_PAD && kicRow <= zeroBasedMaxRow+PIXELS_TO_PAD && ...
                        kicColumn >= zeroBasedMinColumn-PIXELS_TO_PAD && kicColumn <= zeroBasedMaxColumn+PIXELS_TO_PAD && ...
                        objectId >= 0
                    if isPrimaryTarget
                        plot(kicColumn, kicRow, 'xw', 'MarkerSize', 10, 'LineWidth', 1);
                    else
                        plot(kicColumn, kicRow, '*w', 'MarkerSize', 10, 'LineWidth', 1)
                    end
                    text(kicColumn, kicRow, [' ', num2str(objectId), ', ', num2str(objectMag, '%.3f')], 'Color', 'w');
                end % if

            end % for iKic
            
            % overlay out of transit and pixel correlation image centroids if valid
            controlCentroidRow = ...
                dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).controlImageCentroid.row.value;
            controlCentroidColumn = ...
                dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).controlImageCentroid.column.value;
            if controlCentroidRow >= minRow-PIXELS_TO_PAD && controlCentroidRow <= maxRow+PIXELS_TO_PAD && ...
                    controlCentroidColumn >= minCol-PIXELS_TO_PAD && controlCentroidColumn <= maxCol+PIXELS_TO_PAD
                plot(controlCentroidColumn-1, controlCentroidRow-1, '+w', 'MarkerSize', 10, 'Linewidth', 1);
            end
            
            correlationCentroidRow = ...
                dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).correlationImageCentroid.row.value;
            correlationCentroidColumn = ...
                dvResultsStruct.targetResultsStruct(targetStruct.targetIndex).planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).correlationImageCentroid.column.value;
            if correlationCentroidRow >= minRow-PIXELS_TO_PAD && correlationCentroidRow <= maxRow+PIXELS_TO_PAD && ...
                    correlationCentroidColumn >= minCol-PIXELS_TO_PAD && correlationCentroidColumn <= maxCol+PIXELS_TO_PAD
                plot(correlationCentroidColumn-1, correlationCentroidRow-1, '^w', 'MarkerSize', 8, 'LineWidth', 1);
            end
            
            % overlay the N and E celestial axis markers
            plot_celestial_axis(locationOfObjectsInBoundingBox, -1, 'N', [minRow; maxRow]-1, [minCol; maxCol]-1);
            plot_celestial_axis(locationOfObjectsInBoundingBox, -2, 'E', [minRow; maxRow]-1, [minCol; maxCol]-1);
            
            hold off;

            % add labels
            xlabel('CCD Column');
            ylabel('CCD Row');
            title({'Pixel Correlation Statistic',...
                    ['Planet Candidate ',num2str(iPlanet),' / Quarter ',num2str(quarter),' / Target Table ',num2str(tableId)]});
                
            % adjust axis ticks to integer column and row (zero based)    
            plotChildren = get(gcf,'Children');
            set(plotChildren(2),'YTick',(minRow:maxRow)-1);
            set(plotChildren(2),'XTick',(minCol:maxCol)-1);
            
            % add caption
            set(gcf,'UserData',sprintf(FIGURE_CAPTION, ...
                keplerId, iPlanet, quarter, tableId, SIGNIFICANCE_THRESHOLD));
            
            % save to pixel correlation output directory
            figurePath = [dvFiguresRootDirectory,filesep,'planet-',num2str(iPlanet, '%02d'),...
                            filesep,pixelCorrelationSubdirectory,filesep];
                        
            figureFilename = [num2str(keplerId,'%09d'),'-',...
                                num2str(iPlanet,'%02d'),'-',...
                                'pixel-correlation-statistic-',...
                                num2str(quarter,'%02d'),'-',...
                                num2str(tableId,'%03d'),...
                                '.fig'];
            format_graphics_for_dv_report(h);
            saveas(h,[figurePath,figureFilename],'fig');
            close(h);
            
        else
            disp(['     No pixel correlation data available. No pixel correlation plot produced for keplerId ',...
                num2str(keplerId),', planet ',num2str(iPlanet),' quarter ',num2str(quarter),', targetTableId ',num2str(tableId),'.']);
            dvResultsStruct = add_dv_alert(dvResultsStruct, 'Pixel correlation test', 'warning',...
                ['No pixel correlation data available. No pixel correlation plot produced for keplerId ',...
                num2str(keplerId),', planet ',num2str(iPlanet),', quarter ',num2str(quarter),', targetTableId ',num2str(tableId),'.'],...
                targetIndex, keplerId, iPlanet);
        end
    end
end
