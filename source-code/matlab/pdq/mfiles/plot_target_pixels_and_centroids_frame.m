function plot_target_pixels_and_centroids_frame(pdqTempStruct)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% plot_target_pixels_and_centroids_frame.m
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  Eventually this will go into PDQ reports. Run after a succesful PDQ run.
%  Currently written as a stand alone script - expects certain mat files in
%  the workspace - attitudeSolution Structure, pdqoutputStructure,
%  raDec2PixObject
%
%  Maps the centroid bias over the entire focal plane (assuming PDQ
%  succesfully computed centroid metric for all th e84 modouts) as a quiver
%  plot. Modouts that didn't have any stars/centroids will be empty in the
%  plot.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
close all;
h = figure;
module = pdqTempStruct.ccdModule;
output = pdqTempStruct.ccdOutput;
currentModOut = pdqTempStruct.currentModOut;
set(gca, 'fontsize', 8);

nCadences = pdqTempStruct.numCadences;
for jCadence = nCadences:nCadences

    centroidCols        = pdqTempStruct.centroidCols;
    centroidRows        = pdqTempStruct.centroidRows;


    nStarsOnThisModout = length(centroidCols(:,jCadence));

    startPixel = 1;
    for kStar = 1:nStarsOnThisModout

        subplot(nStarsOnThisModout ,1,kStar);
        set(gca, 'fontsize', 8);

        endPixel = pdqTempStruct.numPixels(kStar) + startPixel -1;

        targetPixelRows     = pdqTempStruct.targetPixelRows(startPixel:endPixel);
        targetPixelColumns  = pdqTempStruct.targetPixelColumns(startPixel:endPixel);

        targetPixelFluxes   = pdqTempStruct.targetPixels(startPixel:endPixel,jCadence);

        % ref. pixel target aperture might contain holes (discontiguous
        % mask)
        %so commenting out this line
        %ccdImage = zeros(length(unique(targetPixelRows)), length(unique(targetPixelColumns)));

        ccdImage = zeros(max(targetPixelRows)-min(targetPixelRows)+1, max(targetPixelColumns)-min(targetPixelColumns)+1);


        linearTargetPixelsIndex = sub2ind( size(ccdImage), targetPixelRows - min(targetPixelRows) +1 ,...
            targetPixelColumns - min(targetPixelColumns) + 1);
        ccdImage(linearTargetPixelsIndex ) = targetPixelFluxes;

        % imagesc(ccdImage, [min(min(ccdImage)), max(max(ccdImage))/100]);
        imagesc(ccdImage);
        colorbar;
        set(gca, 'fontsize', 8);
        %axis equal;

        line(centroidCols(kStar,jCadence) - min(targetPixelColumns) + 1,  ...
            centroidRows(kStar, jCadence) - min(targetPixelRows) +1,'Color','k','Marker', 'o', 'MarkerSize', 5)


        titleString = sprintf( 'Module %d, Output %d, ModOut %d, Centroid Row  %.3f, Centroid column  %.3f', ...
            module, output,currentModOut,centroidRows(kStar, jCadence), centroidCols(kStar,jCadence));
        %colormap hot;
        title(titleString);
        startPixel = endPixel +1;

    end

    fileNameStr = ['false_color_image_stellar_pixels_centroids_module_'  num2str(module) '_output_' num2str(output)  '_modout_' num2str(currentModOut)];


    % add figure caption as user data
    plotCaption = strcat(...
        'In this plot, calibrated target pixles for each star along with the \n',...
        'centroid (computed by PRF based centroid estimation algorithm) are plotted. \n',...
        'Click on the link to open the figure in Matlab to examine the pixels closely. \n');

    set(h, 'UserData', sprintf(plotCaption));

    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

end
close all;
return
