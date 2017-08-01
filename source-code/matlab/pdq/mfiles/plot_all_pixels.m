function plot_all_pixels(pdqInputStruct, listOfModOuts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function perform_sanity_check_on_pixels(pdqInputStruct)
%
% This script plots stellar pixels, background pixels, and collateral
% pixels on each mod out and provides a visual check of the data (this is
% more useful when ETEM2 parameters, data are still in flux)
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


% ccd = zeros(1070,1132);
% for j =106:112,
%     rows = cat(1,s.stellarPdqTargets(j).referencePixels.row);
%     cols = cat(1,s.stellarPdqTargets(j).referencePixels.column);
%     vals = cat(2,s.stellarPdqTargets(j).referencePixels.timeSeries);
%     vals = vals';
%
%     % convert to linear index
%
%     index = sub2ind(size(ccd), rows,cols);
%
%     ccd(index) = vals(:,1);
% end;
% imagesc(ccd, [1.8e5 4e5]);
% colormap('hot')



stellarCcdModules =cat(1,pdqInputStruct.stellarPdqTargets.ccdModule);
stellarCcdOutputs =cat(1,pdqInputStruct.stellarPdqTargets.ccdOutput);

bkgdCcdModules =cat(1,pdqInputStruct.backgroundPdqTargets.ccdModule);
bkgdCcdOutputs =cat(1,pdqInputStruct.backgroundPdqTargets.ccdOutput);

collateralCcdModules =cat(1,pdqInputStruct.collateralPdqTargets.ccdModule);
collateralCcdOutputs =cat(1,pdqInputStruct.collateralPdqTargets.ccdOutput);


if(~exist('listOfModOuts', 'var'))
    listOfModOuts = (1:84);
end

% plot one modout at a time

for currentModOut = listOfModOuts

    j = currentModOut;

    [module, output] = convert_to_module_output(j);

    stellarIndex = find(stellarCcdModules == module & stellarCcdOutputs == output);
    if(isempty(stellarIndex))
        continue;
    end

    figure;
    bkgdIndex = find(bkgdCcdModules == module & bkgdCcdOutputs == output);

    collateralIndex = find(collateralCcdModules == module & collateralCcdOutputs == output);

    starsForThisModOut      = pdqInputStruct.stellarPdqTargets(stellarIndex);

    if(~isempty(stellarIndex))
        for k =1:length(stellarIndex)

            srows = cat(1,starsForThisModOut(k).referencePixels.row);
            scols  = cat(1,starsForThisModOut(k).referencePixels.column);
            h1 = plot(scols, srows, 'mo');
            hold on;
            isInOptimalAperture = cat(1,starsForThisModOut(k).referencePixels.isInOptimalAperture);
            h2 = plot(scols(isInOptimalAperture), srows(isInOptimalAperture),  'k.');
            text(max(scols), max(srows), num2str(k), 'fontsize', 15, 'fontweight', 'bold')

        end
    else
        h1 = plot([], [], 'mo', 'MarkerSize', 5);
        hold on;

    end

    bkgdsForThisModOut       = pdqInputStruct.backgroundPdqTargets(bkgdIndex);
    if(~isempty(bkgdsForThisModOut))

        for k =1:length(bkgdIndex)

            brows = cat(1,bkgdsForThisModOut(k).referencePixels.row);
            bcols  = cat(1,bkgdsForThisModOut(k).referencePixels.column);
            h3 = plot(bcols, brows, 'bo');
            hold on;
        end
    else
        h3 = plot([], [], 'bo');
        hold on;
    end
    collateralsForThisModOut  = pdqInputStruct.collateralPdqTargets(collateralIndex);

    if(~isempty(collateralsForThisModOut))
        for k =1:length(collateralIndex)

            crows = cat(1,collateralsForThisModOut(k).referencePixels.row);
            ccols  = cat(1,collateralsForThisModOut(k).referencePixels.column);
            h4 = plot(ccols, crows, 'bp');
            hold on;
        end
    else
        h4 = plot([], [], 'bp');
        hold on;
    end

    % make sure that the black2D models were retrieved correctly
    %     h5 = plot(pdqInputStruct.twoDBlackModels(j).columns, pdqInputStruct.twoDBlackModels(j).rows, 'ms');
    %     h6 = plot(pdqInputStruct.flatFieldModels(j).columns, pdqInputStruct.flatFieldModels(j).rows, '.', 'color', [.5 .6 0]);
    %
    %     legend([h1 h2 h3 h4 h5 h6], {'Stellar', 'Background', 'collateral', 'Black 2D', 'flat field'});

    legend([h1 h2 h3 h4], {'Stellar',  'in optimal aperture','Background', 'collateral'}, 'Location', 'Best');

    title(['Module Output ' num2str(j)])
    ylabel('rows');
    xlabel('columns');
    %pause(0.5);
    fileNameStr = ['all_pixels_module_'  num2str(module) '_output_', num2str(output) '_modout_' num2str(currentModOut)];
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;



end

return;



