function plot_mosaic_of_all_target_pixels(pdqInputStruct, listOfModOuts)
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

nModOuts = 84;
stampSizeInPixels = 20;


paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

stellarCcdModules =cat(1,pdqInputStruct.stellarPdqTargets.ccdModule);
stellarCcdOutputs =cat(1,pdqInputStruct.stellarPdqTargets.ccdOutput);

close all;

if(~exist('listOfModOuts', 'var'))

    modOutsPresent = true(nModOuts,1);
    listOfModOuts = (1:nModOuts);
else
    modOutsPresent = false(nModOuts,1);
    modOutsPresent(listOfModOuts) = true;

end

% find the modouts present in the data
% find out max. number of stars
maxStarCount = 0;
for currentModOut = listOfModOuts

    j = currentModOut;

    [module, output] = convert_to_module_output(j);

    stellarIndex = find(stellarCcdModules == module & stellarCcdOutputs == output);

    if(length(stellarIndex) > maxStarCount)
        maxStarCount = length(stellarIndex);
    end

    if(isempty(stellarIndex))
        modOutsPresent(j) = false;
    end
end


% create a mosaic of postage stamps
% each postage stamp stampSizeInPixels by stampSizeInPixels


mosaicImage = nan(nModOuts*stampSizeInPixels, maxStarCount*stampSizeInPixels);

for j = 1:nModOuts

    if(~modOutsPresent(j))
        continue;
    end


    [module, output] = convert_to_module_output(j);

    %fprintf('[%d, %d]\n', module, output);


    stellarIndex = find(stellarCcdModules == module & stellarCcdOutputs == output);

    starsForThisModOut  = pdqInputStruct.stellarPdqTargets(stellarIndex);

    nStarsForThisModout = length(starsForThisModOut);

    % find the location of this postage stamp in the mosaic
    startRow = (j-1)*stampSizeInPixels + 1;
    endRow = startRow -1 + stampSizeInPixels;


    if(~isempty(stellarIndex))
        axesHandle = zeros( nStarsForThisModout,1);
        figure('position', [1 1 1000 250]);
        for k = 1:nStarsForThisModout

            srows = cat(1,starsForThisModOut(k).referencePixels.row);
            scols  = cat(1,starsForThisModOut(k).referencePixels.column);
            targetPixelFluxes = cat(2,starsForThisModOut(k).referencePixels.timeSeries);
            targetPixelFluxes = mean(targetPixelFluxes,1);

            srows = srows - min(srows) +1;
            scols = scols - min(scols) +1;

            postageStamp = zeros(stampSizeInPixels, stampSizeInPixels);
            indexTargetPixels = sub2ind([stampSizeInPixels, stampSizeInPixels], srows, scols);
            postageStamp(indexTargetPixels) = targetPixelFluxes(:) - min(targetPixelFluxes(:));

            % find the location of this postage stamp in the mosaic


            startColumn = (k-1)*stampSizeInPixels +1;
            endColumn = startColumn - 1 +stampSizeInPixels;

            if(max(srows > stampSizeInPixels) || max(scols > stampSizeInPixels))
                continue;
            else
                mosaicImage(startRow:endRow, startColumn:endColumn) = postageStamp;
            end


            axesHandle(k) = subplot(1,nStarsForThisModout,k);
            %imagesc(postageStamp);
            imagesc(postageStamp(1:max(max(srows), 12), 1:max(max(scols), 12)));
            keplerId = starsForThisModOut(k).keplerId;
            keplerMag = starsForThisModOut(k).keplerMag;
            title([ num2str(keplerId) ',' num2str(keplerMag)]);
            colormap(hot);
            colorbar('location', 'southoutside');
            set(gca, 'fontsize', 7);


        end
        linkaxes(axesHandle,'xy');
        axis(axesHandle,'image');


        fileNameStr = ['mosaic_of_raw_target_pixels_module_' num2str(module) '_output_' num2str(output) '_modout_' num2str(j)];
        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
        close all;
    end

end

save mosaicImageRawPixels.mat mosaicImage;
imagesc(mosaicImage, [1e3, max(mosaicImage(:))]./maxStarCount); axis equal; colormap hot; colorbar;

set(gca,'YTick',(fix(stampSizeInPixels/2):stampSizeInPixels:nModOuts*stampSizeInPixels-fix(stampSizeInPixels/2))', 'YTickLabel', num2str((1:nModOuts)'));


fileNameStr = 'mosaic_of_raw_target_pixels';
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);


return;



