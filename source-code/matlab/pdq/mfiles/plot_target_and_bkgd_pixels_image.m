function plot_target_and_bkgd_pixels_image(pdqInputStruct, listOfModOuts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% functionplot_target_and_bkgd_pixels_image(pdqInputStruct, listOfModOuts)
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


nCadences = length(pdqInputStruct.cadenceTimes);
close all;
if(~exist('listOfModOuts', 'var'))
    listOfModOuts = (1:84);
end

% plot one modout at a time

for currentModOut = listOfModOuts
    
    j = currentModOut;
    
    [module, output] = convert_to_module_output(j);
    
    fprintf('[%d, %d]\n', module, output);
    
    stellarIndex = find(stellarCcdModules == module & stellarCcdOutputs == output);
    
    if(isempty(stellarIndex))
        continue;
    end
    
    ccdImage = zeros(1070,1132);
    
    bkgdIndex = find(bkgdCcdModules == module & bkgdCcdOutputs == output);
    
    starsForThisModOut      = pdqInputStruct.stellarPdqTargets(stellarIndex);
    
    if(~isempty(stellarIndex))
        
        textCoordinates = zeros(length(stellarIndex),2);
        count = 0;
        for k =1:length(stellarIndex)
            
            targetPixelRows = cat(1,starsForThisModOut(k).referencePixels.row);
            targetPixelColumns  = cat(1,starsForThisModOut(k).referencePixels.column);
            pixelValues = cat(2,starsForThisModOut(k).referencePixels.timeSeries);
            pixelValues = pixelValues';
            indexTargetPixels = sub2ind([1070,1132], targetPixelRows, targetPixelColumns);
            %ccdImage(indexTargetPixels) = mean(pixelValues,2); % average across cadences
            ccdImage(indexTargetPixels) = pixelValues(:,end); % average across cadences
            textCoordinates(k, :) = [max(targetPixelColumns), max(targetPixelRows)];
            count = count + length(targetPixelRows);
            
        end
        
        allRows = zeros(count,1);
        allColumns = zeros(count,1);
        allPixels = zeros(count,nCadences);
        startIndex  = 1;
        
        for k =1:length(stellarIndex)
            
            targetPixelRows = cat(1,starsForThisModOut(k).referencePixels.row);
            targetPixelColumns  = cat(1,starsForThisModOut(k).referencePixels.column);
            pixelValues = cat(2,starsForThisModOut(k).referencePixels.timeSeries);
            pixelValues = pixelValues';
            
            
            endIndex = startIndex +length(targetPixelRows) -1;
            allRows(startIndex:endIndex)  = targetPixelRows;
            allColumns(startIndex:endIndex)  = targetPixelColumns;
            allPixels(startIndex:endIndex, :)  = pixelValues;
            startIndex  = endIndex +1;
            
            
        end
        
        fprintf('');
        
    end
    
    bkgdsForThisModOut = pdqInputStruct.backgroundPdqTargets(bkgdIndex);
    if(~isempty(bkgdsForThisModOut))
        
        for k =1:length(bkgdIndex)
            
            bkgdPixelRows = cat(1,bkgdsForThisModOut(k).referencePixels.row);
            bkgdPixelColumns  = cat(1,bkgdsForThisModOut(k).referencePixels.column);
            
            pixelValues = cat(2,bkgdsForThisModOut(k).referencePixels.timeSeries);
            pixelValues = pixelValues';
            
            indexBkgdPixels = sub2ind([1070,1132], bkgdPixelRows,bkgdPixelColumns);
            %ccdImage(indexBkgdPixels) = mean(pixelValues,2); % average across cadences
            ccdImage(indexBkgdPixels) = pixelValues(:,end); % average across cadences
        end
    end
    %colormap hot;
    colormap jet;
    imagesc(ccdImage);
    colorbar;
    set(gca, 'fontsize', 8);
    hold on;
    for k =1:length(stellarIndex)
        text(textCoordinates(k, 1),textCoordinates(k, 2), num2str(k),'color', 'w',  'fontsize', 15, 'fontweight', 'bold');
    end
    
    fileNameStr = ['image pixels on module '  num2str(module) ' output ' num2str(output) ' modout ' num2str(currentModOut)];
    title(fileNameStr);
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;
    fileNameStr = ['image_pixels_on_module_'  num2str(module) '_output_' num2str(output) '_modout_' num2str( currentModOut) ];
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;
    
end

return;



