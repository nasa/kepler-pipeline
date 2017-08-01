function  [pdqTempStruct] = determine_available_bkgd_pixels(pdqScienceObject, pdqTempStruct,  currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  [pdqTempStruct] = ...
% determine_available_bkgd_pixels(pdqScienceObject, pdqTempStruct,currentModOut)
%
% The pdqScienceObject contains a list of background targets  for all the
% module outputs. This function selects those background pixels that belong
% to the current module output.
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
[module, output] = convert_to_module_output(currentModOut);

if(isempty(pdqScienceObject.backgroundPdqTargets))

    warning('PDQ:determineAvailableBackgroundPixels',...
        ['No background pixels for module = ' num2str(module) ' output = ' num2str(output)] );
    pdqTempStruct.backgroundPixelsAvailable = false;
    return

end


ccdModules = cat(1, pdqScienceObject.backgroundPdqTargets.ccdModule);
ccdOutputs = cat(1, pdqScienceObject.backgroundPdqTargets.ccdOutput);

validModuleOutputs  = convert_from_module_output(ccdModules, ccdOutputs);

validIndices   = find(validModuleOutputs == currentModOut);

pdqTempStruct.backgroundPixelsAvailable = true;



if (isempty(validIndices))

    warning('PDQ:determineAvailableBackgroundPixels',...
        ['No background pixels for module = ' num2str(module) ' output = ' num2str(output)] );
    pdqTempStruct.backgroundPixelsAvailable = false;
    return
else

    bkgPixelsForThisModOut = cat(1,pdqScienceObject.backgroundPdqTargets(validIndices).referencePixels);

    bkgdPixels          = (cat(2, bkgPixelsForThisModOut.timeSeries))';
    bkgdGapIndicators   = (cat(2, bkgPixelsForThisModOut.gapIndicators))';
    bkgdPixelRows       = (cat(2, bkgPixelsForThisModOut.row))';
    bkgdPixelColumns    = (cat(2, bkgPixelsForThisModOut.column))';

end

% RPTS should add a check to see whether background pixels overlap target pixels

pdqTempStruct.validBkgdIndicesForThisModOut   = validIndices; % index into pdqScienceObject.backgroundPdqTargets

pdqTempStruct.bkgdPixels             = bkgdPixels;
pdqTempStruct.rawBkgdPixels          = bkgdPixels;

pdqTempStruct.bkgdGapIndicators      = bkgdGapIndicators;

pdqTempStruct.bkgdPixelRows          = bkgdPixelRows;
pdqTempStruct.bkgdPixelColumns       = bkgdPixelColumns;

%------------------------------------------------------------------------
% Note: RPTS sometimes selects pixels outside the visible silicon because
% the n-pixel halo around the targets might extend into the collateral
% region. This creates problem when calibrating the background pixels - we
% end subtracting smear from (say) those pixels that might have come from
% the leading black region
% declare such background pixels extending into the collateral regions as gaps
% check for each and every cadence
%------------------------------------------------------------------------

numCadences         = length(pdqScienceObject.cadenceTimes);

for iCadence = 1:numCadences

    % find if any of the background pixels come from the smear regions

    indexInSmearRegions = find(pdqTempStruct.bkgdPixelRows <= pdqTempStruct.nMaskedSmearRows ...
        | pdqTempStruct.bkgdPixelRows >= (pdqTempStruct.nMaskedSmearRows + pdqTempStruct.nRowsImaging ));

    indexInBlackRegions = find(pdqTempStruct.bkgdPixelColumns <= pdqTempStruct.nLeadingBlackColumns ...
        | pdqTempStruct.bkgdPixelColumns >= (pdqTempStruct.nLeadingBlackColumns + pdqTempStruct.nColsImaging ));

    invalidIndices = [indexInSmearRegions indexInBlackRegions]; % works even if all are empty

    if(~isempty(invalidIndices))
        pdqTempStruct.bkgdGapIndicators(invalidIndices,iCadence)    = true;  % declare those errant bkgd pixels as gaps
    end

    %------------------------------------------------------------------------
    % also see if any of the background pixels overlap the target pixels in
    % the optimal aperture as RPTS sometimes does select background pixels
    % which happen to be target pixels
    %------------------------------------------------------------------------

    isInOptimalAperture = find(pdqTempStruct.isInOptimalAperture);


    [commonRows, indexOverlap] =  intersect([bkgdPixelRows bkgdPixelColumns], ...
        [pdqTempStruct.targetPixelRows(isInOptimalAperture) pdqTempStruct.targetPixelColumns(isInOptimalAperture)], 'rows');

    if(~isempty(indexOverlap))
        warning('PDQ:determineAvailableBackgroundPixels',...
            ['Overlap between background and target pixels for module = ' num2str(module) ' output = ' num2str(output)] );

        pdqTempStruct.bkgdGapIndicators(indexOverlap,iCadence) = true;

    end

end

return
