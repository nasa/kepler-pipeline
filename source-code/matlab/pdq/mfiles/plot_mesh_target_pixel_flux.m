function plot_mesh_target_pixel_flux(pdqInputStruct, listOfModOuts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_mesh_target_pixel_flux(pdqInputStruct, listOfModOuts)
%
% This script plots each stellar target pixels' flux and
% provides a visual check of the data (this is more useful when ETEM2
% parameters, data are still in flux)
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


if(~exist('listOfModOuts', 'var'))
    listOfModOuts = (1:84);
end

% plot one modout at a time

for currentModOut = listOfModOuts
    
    [module, output] = convert_to_module_output(currentModOut);
    
    % check to see if there are any stellar targets for this modout
    if(isempty(pdqInputStruct.stellarPdqTargets))
        
        warning('PDQ:plotStellarPixels',...
            ['No stellar pixels for module = ' num2str(module) ' output = ' num2str(output)] );
        return
    end
    
    
    ccdModules          = cat(1, pdqInputStruct.stellarPdqTargets.ccdModule);
    ccdOutputs          = cat(1, pdqInputStruct.stellarPdqTargets.ccdOutput);
    
    validModuleOutputs  = convert_from_module_output(ccdModules, ccdOutputs);
    validTargetIndices  = find(validModuleOutputs == currentModOut);
    
    if(isempty(validTargetIndices))
        continue;
    end
    
    
    nStars  = length(validTargetIndices);
    
    stellarPdqTargets = pdqInputStruct.stellarPdqTargets(validTargetIndices);
    
    nRows = round(nStars/2);
    figure;
    
    for j = 1:nStars
        
        targetRows = cat(1,stellarPdqTargets(j).referencePixels.row);
        targetColumns = cat(1,stellarPdqTargets(j).referencePixels.column);
        targetPixelFluxes = cat(2,stellarPdqTargets(j).referencePixels.timeSeries);
        targetPixelFluxes = targetPixelFluxes';
        % meshplot for a visual check
        minRow = min(targetRows);
        maxRow = max(targetRows);
        nUniqueRows = maxRow - minRow +1;
        minCol = min(targetColumns);
        maxCol = max(targetColumns);
        nUniqueCols = maxCol - minCol +1;
        
        Y = repmat((minRow:maxRow)',1, nUniqueCols);
        X = repmat((minCol:maxCol), nUniqueRows,1);
        
        Z = zeros(size(X));
        idx = sub2ind(size(X), targetRows -minRow+1,targetColumns-minCol+1);
        %Z(idx) = targetPixelFluxes(:,1);
        Z(idx) = targetPixelFluxes(:,end);
        
        if(size(Z,1) ~=1)
            
            subplot(nRows,2, j);
            set(gca, 'fontsize', 8);
            mesh(X,Y,Z);
            keplerMag = stellarPdqTargets(j).keplerMag;
            ccdModule = stellarPdqTargets(j).ccdModule;
            ccdOutput = stellarPdqTargets(j).ccdOutput;
            
            titleString = sprintf('Mag = %5.2f ModOut = %d [%d, %d]', ...
                keplerMag,currentModOut,  ccdModule, ccdOutput);
            title(titleString)
            xlabel('columns');
            ylabel('rows');
        end
        
    end
    
    fileNameStr = ['mesh_plot_stellar_pixels_module_'  num2str(module) '_output_' num2str(output)  '_modout_' num2str(currentModOut)];
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;
end
return
