function plot_mosaic_of_all_calibrated_target_pixels(pdqInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  plot_mosaic_of_all_target_pixels(pdqInputStruct, listOfModOuts)
%
% This script plots stellar pixels on each mod out and provides a visual
% check of the data (this is more useful when ETEM2 parameters, data are
% still in flux)
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

% create a mosaic of postage stamps
% each postage stamp stampSizeInPixels by stampSizeInPixels

stampSizeInPixels = 20; % 20 by 20 square mask
maxStarCount = 5;
nModOuts = 84;

% hard coding the stamp size and the max. star count is asking for trouble
% loop through all the mod/outs to find the max number of stars and max.
% aperture size

ccdModules          = cat(1, pdqInputStruct.stellarPdqTargets.ccdModule);
ccdOutputs          = cat(1, pdqInputStruct.stellarPdqTargets.ccdOutput);
for currentModOut = 1:nModOuts

    validModuleOutputs  = convert_from_module_output(ccdModules, ccdOutputs);
    validTargetIndices  = find(validModuleOutputs == currentModOut);

    if(isempty(validTargetIndices))
        continue;
    end

    nStars  = length(validTargetIndices);

    stellarPdqTargets = pdqInputStruct.stellarPdqTargets(validTargetIndices);

    maxStarCount = max(maxStarCount, nStars);

    for j = 1:nStars

        targetRows = cat(1,stellarPdqTargets(j).referencePixels.row);
        targetColumns = cat(1,stellarPdqTargets(j).referencePixels.column);
        minRow = min(targetRows);
        maxRow = max(targetRows);
        nUniqueRows = maxRow - minRow +1;
        minCol = min(targetColumns);
        maxCol = max(targetColumns);
        nUniqueCols = maxCol - minCol +1;

        stampSizeInPixels = max(stampSizeInPixels,nUniqueRows);
        stampSizeInPixels = max(stampSizeInPixels,nUniqueCols);

    end
end


close all;
warning off all;
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

mosaicImageCalibrated = nan(nModOuts*stampSizeInPixels, maxStarCount*stampSizeInPixels);
mosaicImageRaw = nan(nModOuts*stampSizeInPixels, maxStarCount*stampSizeInPixels);

for j = 1:nModOuts

    sFileName = ['pdqTempStruct_' num2str(j) '.mat'];

    % check to see the existence ofthe .mat file

    if(~exist(sFileName, 'file'))
        continue;
    end

    load(sFileName, 'pdqTempStruct');
    ccdModule           = pdqTempStruct.ccdModule;
    ccdOutput           = pdqTempStruct.ccdOutput;
    currentModOut       = pdqTempStruct.currentModOut;


    [module, output] = convert_to_module_output(j);

    fprintf('%[%d, %d]\n', module, output);

    endPixels = cumsum([pdqTempStruct.numPixels]);
    startPixels = [1;endPixels(1:end-1)+1];


    % find the location of this postage stamp in the mosaic
    startRow = (j-1)*stampSizeInPixels + 1;
    endRow = startRow -1 + stampSizeInPixels;

    nStarsForThisModout = pdqTempStruct.numTargets;

    axesHandle = zeros(nStarsForThisModout,1);
    h = figure('position', [1 1 1680 750]);

    for k = 1:nStarsForThisModout

        scols = pdqTempStruct.targetPixelColumns(startPixels(k):endPixels(k));
        srows  = pdqTempStruct.targetPixelRows(startPixels(k):endPixels(k));

        targetPixelFluxes = pdqTempStruct.targetPixels(startPixels(k):endPixels(k), end);
        targetPixelFluxes = targetPixelFluxes(:);

        rawTargetPixelFluxes = pdqTempStruct.rawTargetPixels(startPixels(k):endPixels(k), end);
        rawTargetPixelFluxes = rawTargetPixelFluxes(:);


        srows = srows - min(srows) +1;
        scols = scols - min(scols) +1;

        postageStamp1 = nan(stampSizeInPixels, stampSizeInPixels);
        indexTargetPixels = sub2ind([stampSizeInPixels, stampSizeInPixels], srows, scols);
        postageStamp1(indexTargetPixels) = targetPixelFluxes(:);

        postageStamp2 = nan(stampSizeInPixels, stampSizeInPixels);
        postageStamp2(indexTargetPixels) = rawTargetPixelFluxes(:);



        % find the location of this postage stamp in the mosaic

        startColumn = (k-1)*stampSizeInPixels +1;
        endColumn = startColumn - 1 +stampSizeInPixels;


        if(max(srows > stampSizeInPixels) || max(scols > stampSizeInPixels))
            continue;
        else
            mosaicImageCalibrated(startRow:endRow, startColumn:endColumn) = postageStamp1;
            mosaicImageRaw(startRow:endRow, startColumn:endColumn) = postageStamp2;
        end


        axesHandle(k) = subplot(2,nStarsForThisModout,k);
        %imagesc(postageStamp);
        imagesc(postageStamp2(1:max(max(srows), 12), 1:max(max(scols), 12)));
        keplerId = pdqTempStruct.keplerIds(k);
        keplerMag = pdqTempStruct.keplerMags(k);
        title({[ num2str(keplerId) ',' num2str(keplerMag)];
            '[in ADU]'});
        colormap(hot);
        colorbar('location', 'eastoutside');
        set(gca, 'fontsize', 7);


        axesHandle(k+nStarsForThisModout) = subplot(2,nStarsForThisModout,k+nStarsForThisModout);
        imagesc(postageStamp1(1:max(max(srows), 12), 1:max(max(scols), 12)));
        keplerId = pdqTempStruct.keplerIds(k);
        keplerMag = pdqTempStruct.keplerMags(k);
        title({[ num2str(keplerId) ',' num2str(keplerMag)];
            '[in e-]'});
        colormap(hot);
        colorbar('location', 'eastoutside');
        set(gca, 'fontsize', 7);

    end
    linkaxes(axesHandle,'xy');
    axis(axesHandle,'image');
    fileNameStr = ['mosaic_of_calibrated_vs_raw_target_pixels_module_' num2str(ccdModule) '_output_' num2str(ccdOutput) '_modout_' num2str(currentModOut)];


    plotCaption = strcat(...
        'The top panel depicts the raw pixels (in ADU) and the bottom panel shows the calibrated pixels (in photo electrons)  \n',...
        'for each target for the last reference pixel set for a given module/output.\n');
    set(h, 'UserData', sprintf(plotCaption));

    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);



    close all;

end

save mosaicImage.mat mosaicImageCalibrated mosaicImageRaw maxStarCount stampSizeInPixels nModOuts;
%%
clc;
close all;
nPages = round(nModOuts/maxStarCount);
for iPage = 1:nPages

    %h1 = figure;
    scaleFactor = 10;
    %imagesc(mosaicImageCalibrated, [min(mosaicImageCalibrated(:)), max(mosaicImageCalibrated(:))]);
    imagesc(mosaicImageCalibrated,[min(mosaicImageCalibrated(:)), max(mosaicImageCalibrated(:))]/scaleFactor);
    colormap jet(16384);

    % choose a colormap and set the first (lowest) value to a pleasing
    % white
    cmap = colormap(gca);
    if(any(any(isnan(mosaicImageCalibrated))))
        cmap(1,:)=[1 1 1];
    end
    if(any(any(mosaicImageCalibrated < 0 )))
        cmap(2,:)=[0.7 0.7 0.7];
    end
    % replace the cdata for the image
    axis equal;
    colormap(cmap);
    hbar = colorbar('location', 'SouthOutside');

    xtickValues = get(hbar, 'xtick');
    zString = cell(length(xtickValues),1);
    xtickValues = xtickValues*scaleFactor;
    for jTick = 1:length(xtickValues),
        zString{jTick}  = strrep(strrep(num2str(xtickValues(jTick), '%1.1e'), 'e+0', 'e'), 'e0', '');
    end
    set(hbar, 'xticklabel', zString);

    set(gca,'YTick',(fix(stampSizeInPixels/4):stampSizeInPixels:nModOuts*stampSizeInPixels-fix(stampSizeInPixels/4))', 'YTickLabel', num2str((1:nModOuts)'));

    set(gca, 'ylim', [(iPage-1)*maxStarCount*stampSizeInPixels+1, iPage*maxStarCount*stampSizeInPixels]);

    set(gca, 'xlim', [1, maxStarCount*stampSizeInPixels]);
    set(gca,'fontsize', 7);

    ylabel('Mod/Out number');
    xlabel('Targets in their aperture');
    title('PDQ calibrated target pixels (in e-)');

    startModout = (iPage-1)*maxStarCount +1;
    endModout = min(startModout + maxStarCount - 1, nModOuts);

    fileNameStr = ['mosaic_of_calibrated_target_pixels_focal_plane_set_' num2str(iPage, '%02.0f') '_modouts_' num2str(startModout) '_thru_' num2str(endModout)];

    %     plotCaption = strcat(...
    %         ['This plot depicts the variation of the average ' pdqMetricStruct.name ', which is computed as the mean over all the cadences  \n'],...
    %         ['for the current contact for a given module/output, in ' pdqMetricStruct.units ' across the focal plane.\n']);
    %     set(h, 'UserData', sprintf(plotCaption));

    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;

end

%
nPages = round(nModOuts/maxStarCount);
for iPage = 1:nPages

    scaleFactor = 2;
    imagesc(mosaicImageRaw, [1e3, max(mosaicImageRaw(:))]./scaleFactor);
    colormap jet(16384);

    % choose a colormap and set the first (lowest) value to a pleasing
    % white
    cmap = colormap(gca);
    if(any(any(isnan(mosaicImageRaw))))
        cmap(1,:)=[1 1 1];
    end
    if(any(any(mosaicImageRaw < 0 )))
        cmap(2,:)=[0.7 0.7 0.7];
    end
    % replace the cdata for the image
    axis equal;
    colormap(cmap);
    hbar = colorbar('location', 'EastOutside');

    xtickValues = get(hbar, 'xtick');
    zString = cell(length(xtickValues),1);
    xtickValues = xtickValues*scaleFactor;
    for jTick = 1:length(xtickValues),
        zString{jTick}  = strrep(strrep(num2str(xtickValues(jTick), '%1.1e'), 'e+0', 'e'), 'e0', '');
    end
    set(hbar, 'xticklabel', zString);




    set(gca,'YTick',(fix(stampSizeInPixels/4):stampSizeInPixels:nModOuts*stampSizeInPixels-fix(stampSizeInPixels/4))', 'YTickLabel', num2str((1:nModOuts)'));

    set(gca, 'ylim', [(iPage-1)*maxStarCount*stampSizeInPixels+1, iPage*maxStarCount*stampSizeInPixels]);

    set(gca, 'xlim', [1, maxStarCount*stampSizeInPixels]);
    set(gca,'fontsize', 7);

    ylabel('Mod/Out number');
    xlabel('Targets in their aperture');
    title('PDQ raw target pixels (in ADU)');

    startModout = (iPage-1)*maxStarCount +1;
    endModout = min(startModout + maxStarCount - 1, nModOuts);

    fileNameStr = ['mosaic_of_raw_target_pixels_focal_plane_set_' num2str(iPage, '%02.0f') '_modouts_' num2str(startModout) '_thru_' num2str(endModout)];
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;

end

warning on all;

return;


