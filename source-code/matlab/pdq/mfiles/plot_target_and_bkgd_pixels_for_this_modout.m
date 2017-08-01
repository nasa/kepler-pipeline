
function plot_target_and_bkgd_pixels_for_this_modout(pdqTempStruct)


%-------------------------------------------------------------------------
% plot 1
% plot of PDQ reference pixels
% pixles in the optimal aperture and the additional background collected
% clealry marked
%-------------------------------------------------------------------------
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
set(gca, 'fontsize', 8);

ccdModule = pdqTempStruct.ccdModule;
ccdOutput = pdqTempStruct.ccdOutput;
currentModOut = pdqTempStruct.currentModOut;


h1 = plot(pdqTempStruct.targetPixelColumns, pdqTempStruct.targetPixelRows, 'b.');
isInOptimalAperture =  pdqTempStruct.isInOptimalAperture;
hold on;
h2 = plot(pdqTempStruct.targetPixelColumns(isInOptimalAperture), pdqTempStruct.targetPixelRows(isInOptimalAperture), 'ms');

h3 = plot(pdqTempStruct.bkgdPixelColumns, pdqTempStruct.bkgdPixelRows, 'o','color', [0.5 0.2 0.6]);

h4 = plot(pdqTempStruct.msmearColumns, pdqTempStruct.msmearRows, 'k.');
h5 = plot(pdqTempStruct.vsmearColumns, pdqTempStruct.vsmearRows, 'k.');
h6 = plot(pdqTempStruct.blackColumns, pdqTempStruct.blackRows, 'k.');
legend([h1 h2 h3 h4 h5 h6], {'Stellar', 'Stellar in optimal aperture', 'Background', 'Masked smear', 'Virtual Smear', 'Black'}, 'Location', 'Best');
title(['Module Output ' num2str( currentModOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']);
ylabel('rows');
xlabel('columns');

endPixels = cumsum([pdqTempStruct.numPixels]);
startPixels = [1;endPixels(1:end-1)+1];
for j = 1:pdqTempStruct.numTargets
    scols = pdqTempStruct.targetPixelColumns(startPixels(j):endPixels(j));
    srows  = pdqTempStruct.targetPixelRows(startPixels(j):endPixels(j));
    
    text(max(scols), max(srows), num2str(j), 'fontsize', 12, 'fontweight', 'bold');
end
set(gca,'YDir','reverse'); % so the origin is at the top left hand corner as it is for images
hold off;

% add figure caption as user data
plotCaption = strcat(...
    'In this plot, PDQ stellar pixels, background pixels (some chosen by RPTS, others collected from the target \n',...
    'aperture), and collateral pixels are plotted. The Kepler magnitude and pixel flux values can be read from \n',...
    'earlier plots. Click on the link to open the figure in Matlab to examine the pixels closely. \n');

set(h, 'UserData', sprintf(plotCaption));
fileNameStr = ['pixels_on_module_'  num2str(ccdModule) '_output_' num2str(ccdOutput) '_modout_' num2str(currentModOut)];
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
close all;

%-------------------------------------------------------------------------
% plot 2
% image of PDQ reference pixels with pixles in the optimal aperture and the
% additional background collected clealry marked
%-------------------------------------------------------------------------

IMAGE_SCALING_FACTOR = 50; % scale the image so background pixels are seen clearly
IMAGE_BACKGROUND_FLOOR = 1000;


indexBkgdPixels = sub2ind([1070,1132], pdqTempStruct.bkgdPixelRows,pdqTempStruct.bkgdPixelColumns);

indexTargetPixels = sub2ind([1070,1132], pdqTempStruct.targetPixelRows,pdqTempStruct.targetPixelColumns);

ccdImage = zeros(1070,1132) + IMAGE_BACKGROUND_FLOOR;

% ccdImage(indexTargetPixels) = mean(pdqTempStruct.targetPixelsBlackCorrected,2); % average across cadences
% ccdImage(indexBkgdPixels) = mean(pdqTempStruct.bkgdPixelsBlackCorrected,2);

ccdImage(indexTargetPixels) = pdqTempStruct.targetPixelsBlackCorrected(:, end); % plot only the latest ref pix cadence
ccdImage(indexBkgdPixels) = pdqTempStruct.bkgdPixelsBlackCorrected(:,end);

colormap hot;
h = gcf;
set(gca, 'fontsize', 8);

if(max(ccdImage(:))/IMAGE_SCALING_FACTOR <= min(ccdImage(:)))
    imagesc(ccdImage);
else
    imagesc(ccdImage,[min(ccdImage(:)),max(ccdImage(:))/IMAGE_SCALING_FACTOR]);
end
colorbar;
set(gca, 'fontsize', 8);

for j = 1:pdqTempStruct.numTargets
    scols = pdqTempStruct.targetPixelColumns(startPixels(j):endPixels(j));
    srows  = pdqTempStruct.targetPixelRows(startPixels(j):endPixels(j));
    
    text(max(scols), max(srows), num2str(j),'color',[1 1 1], 'fontsize', 12, 'fontweight', 'bold');
end

%pause(0.5);
fileNameStr = ['image pixels on module '  num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(currentModOut)];
title(fileNameStr);
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
fileNameStr = ['image_pixels_on_module_'  num2str(ccdModule) '_output_' num2str(ccdOutput) '_modout_' num2str( currentModOut) ];


% add figure caption as user data
plotCaption = strcat(...
    'In this plot, PDQ stellar pixels and background pixels (chosen by RPTS, and also collected from the target \n',...
    'aperture) are plotted. The pixel values are artificially restricted to a particular range and the background \n',...
    'floor is raised for better visual contrast. The kepler magnitude and pixel flux values can be read from \n',...
    'subsequent plots. Click on the link to open the figure in Matlab to examine the pixels closely. \n');

set(h, 'UserData', sprintf(plotCaption));


plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
close all;


%-------------------------------------------------------------------------
% plot 3
% mesh plot of stellar pixels
%-------------------------------------------------------------------------
numTargets = pdqTempStruct.numTargets;
nRows = round(numTargets/2);

h = figure(1);

nCadences = pdqTempStruct.numCadences;
for j = 1:numTargets
    
    [targetPixelFluxes, CtargetPixel, targetRows, targetColumns] = extract_target_pixels_and_uncertainties(pdqTempStruct, nCadences, j);
    
    if(isempty(targetRows)) % target gapped perhaps!
        continue;
    end
    
    % meshplot for a visual check
    minRow = min(targetRows);
    maxRow = max(targetRows);
    nUniqueRows = maxRow - minRow +1;
    minCol = min(targetColumns);
    maxCol = max(targetColumns);
    nUniqueCols = maxCol - minCol +1;
    
    X = repmat((minRow:maxRow)',1, nUniqueCols);
    Y = repmat((minCol:maxCol), nUniqueRows,1);
    
    Z = zeros(size(X));
    idx = sub2ind(size(X), targetRows-minRow+1,targetColumns-minCol+1);
    %Z(idx) = targetPixelFluxes(:,1);
    Z(idx) = targetPixelFluxes(:,end);
    
    set(0,'CurrentFigure',h);
    
    subplot(nRows,2, j);
    set(gca, 'fontsize', 8);
    
    mesh(X,Y,Z);
    
    titleString = sprintf('    mag = %5.2f ccd = %d  Output = %d', ...
        pdqTempStruct.keplerMags(j), ccdModule, ccdOutput);
    title(titleString)
    xlabel('rows');
    ylabel('columns');
    
end
% add figure caption as user data
plotCaption = strcat(...
    'In this plot, calibrated PDQ stellar pixels are plotted. \n',...
    'This figure is useful for identifying targets that are not centered \n',...
    'in the aperture and also for identifying the masks that are larger \n',...
    'than necessary (which allow non-PDQ targets crowd the aperture) \n',...
    'The Kepler magnitude and pixel flux values can be read from \n',...
    'subsequent plots. Click on the link to open the figure in \n',...
    'Matlab to examine the pixels closely. \n');

set(h, 'UserData', sprintf(plotCaption));



fileNameStr = ['mesh_plot_stellar_pixels_module_'  num2str(ccdModule) '_output_' num2str(ccdOutput) '_modout_' num2str(currentModOut)];

paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
close all;

%-------------------------------------------------------------------------
% plot 4
% Row view of target pixels bkgd pixels
%-------------------------------------------------------------------------

h = figure;
set(gca, 'fontsize', 8);

hold off;
h1 = plot(pdqTempStruct.targetPixelRows,pdqTempStruct.smearCorrectedTargetPixels,'bo');
hold on;
h2 = plot(pdqTempStruct.bkgdPixelRows,pdqTempStruct.smearCorrectedBkgdPixels,'xr','markersize',10);

titleStr = (['Row view of target pixels, bkgd pixels for modout ' num2str( currentModOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']);
title(titleStr);
ylabel('pixel values in e-');
xlabel('rows');
legend([h1(1) h2(1)], { 'smear corrected target pixels', 'smear corrected bkgd pixels'}, 'Location', 'Best');
titleStr = (['row view of target pixels bkgd pixels for module ' num2str(ccdModule) '_output_' num2str(ccdOutput) '_modout_' num2str( currentModOut) ]);
grid on;


% add figure caption as user data
plotCaption = strcat(...
    'In this plot, row view of PDQ stellar pixels after smear correction is plotted. \n',...
    'Click on the link to open the figure in Matlab to examine the pixels closely. \n');

set(h, 'UserData', sprintf(plotCaption));



plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
close all;


%-------------------------------------------------------------------------
% plot 4
% column view of target pixels bkgd pixels - useful for identifying
% undershoot/overshoot
%-------------------------------------------------------------------------

h = figure;
set(gca, 'fontsize', 8);

hold off;
h1 = plot(pdqTempStruct.targetPixelColumns,pdqTempStruct.smearCorrectedTargetPixels,'bo');
hold on;
h2 = plot(pdqTempStruct.bkgdPixelColumns,pdqTempStruct.smearCorrectedBkgdPixels,'xr','markersize',10);

titleStr = (['Column view of target pixels, bkgd pixels for modout ' num2str( currentModOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']);
title(titleStr);
ylabel('pixel values in e-');
xlabel('columns');
legend([h1(1) h2(1)], { 'smear corrected target pixels','smear corrected bkgd pixels'});
titleStr = (['column view of target pixels bkgd pixels for module ' num2str(ccdModule) '_output_' num2str(ccdOutput) '_modout_' num2str( currentModOut) ]);
grid on;

% add figure caption as user data
plotCaption = strcat(...
    'In this plot, column view of PDQ stellar pixels after smear correction is plotted. \n',...
    'This plot is useful for studying the effects of undershoot correction as the \n',...
    'undershoot correction is carried out prior to smear correction.\n',...
    'Click on the link to open the figure in Matlab to examine the pixels closely. \n');

set(h, 'UserData', sprintf(plotCaption));



plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
close all;


return