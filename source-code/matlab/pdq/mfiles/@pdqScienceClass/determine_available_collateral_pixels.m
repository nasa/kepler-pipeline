function [pdqTempStruct] = determine_available_collateral_pixels(pdqScienceObject, pdqTempStruct,  currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqTempStruct] = ...
% determine_available_collateral_pixels(pdqScienceObject, pdqTempStruct,  currentModOut)
%
% The pdqScienceObject contains a list of collateral targets (black and
% smear collaterals) for all the module outputs. This function selects the
% black collateral targets, smear collateral stellar targets that belong to
% the current module output. This function further separates the smear
% collateral targets into virtual smear and masked smear targets.
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
[currentModule currentOutput] = convert_to_module_output(currentModOut);


% check to see if there are no collateral targets
if(isempty(pdqScienceObject.collateralPdqTargets))

    % no collateral targets, return to process next modout
    warning('PDQ:determineAvailableCollateralPixels',...
        ['No collateral pixels for module = ' num2str(currentModule) ' output = ' num2str(currentOutput)] );

    pdqTempStruct.collateralPixelsAvailable = false;
    return;
end




numCadences     = pdqTempStruct.numCadences;

% Collateral data is present - separate into black, masked smear, and
% virtual smear
nRowsImaging    = pdqScienceObject.fcConstants.nRowsImaging;
nColsImaging    = pdqScienceObject.fcConstants.nColsImaging;
nLeadingBlack   = pdqScienceObject.fcConstants.nLeadingBlack;
nMaskedSmear    = pdqScienceObject.fcConstants.nMaskedSmear;

output          = cat(1,pdqScienceObject.collateralPdqTargets.ccdOutput);
module          = cat(1,pdqScienceObject.collateralPdqTargets.ccdModule);

modOuts         = convert_from_module_output(module, output);


indexOfCollTargetsForThisModOut         = find(modOuts == currentModOut);

pdqTempStruct.blackPixelsAvailable      = false;
pdqTempStruct.vsmearPixelsAvailable     = false;
pdqTempStruct.msmearPixelsAvailable     = false;
pdqTempStruct.collateralPixelsAvailable = true;

if(isempty(indexOfCollTargetsForThisModOut))

    warning('PDQ:determineAvailableCollateralPixels',...
        ['No collateral pixels for module = ' num2str(currentModule) ' output = ' num2str(currentOutput)] );

    pdqTempStruct.collateralPixelsAvailable = false;
    return;
end

%--------------------------------------------------------------------------
% collect black collateral targets
%--------------------------------------------------------------------------

pdqTempStruct.validCollTargetsForThisModOut = indexOfCollTargetsForThisModOut;

% Determine how many collateral pixels are present
collateralTargetsForThisModOut  = pdqScienceObject.collateralPdqTargets(indexOfCollTargetsForThisModOut);


labels      = cat(1,collateralTargetsForThisModOut.labels);
blackIndices  = find(strcmp(labels, 'PDQ_BLACK_COLLATERAL'));

if(~isempty(blackIndices))

    blackCollateralTargetsForThisModOut = collateralTargetsForThisModOut(blackIndices);
    nBlackCollTargetsForThisModOut = length(blackIndices);

    blackCollateralPixelsPerTarget = zeros(nBlackCollTargetsForThisModOut, 1);

    for j = 1 : nBlackCollTargetsForThisModOut
        blackCollateralPixelsPerTarget(j) = length(blackCollateralTargetsForThisModOut(j).referencePixels);
    end
    numTotalBlackPixels  = sum(blackCollateralPixelsPerTarget);

    % Define arrays of module/output values, row & column indices, and
    % pixel value for all collateral pixels
    blackRows           = zeros(numTotalBlackPixels, 1);
    blackColumns        = zeros(numTotalBlackPixels, 1);
    blackPixels         = zeros(numTotalBlackPixels, numCadences);
    blackGapFlags       = true(numTotalBlackPixels, numCadences);


    startIndex = 1;

    for j = 1:nBlackCollTargetsForThisModOut

        endIndex = startIndex + blackCollateralPixelsPerTarget(j) - 1;

        blackRows(startIndex:endIndex)          = cat(1,blackCollateralTargetsForThisModOut(j).referencePixels.row);
        blackColumns(startIndex:endIndex)       = cat(1,blackCollateralTargetsForThisModOut(j).referencePixels.column);

        blackPixels((startIndex:endIndex),:)    = (cat(2, blackCollateralTargetsForThisModOut(j).referencePixels.timeSeries))';
        blackGapFlags((startIndex:endIndex),:)  = (cat(2, blackCollateralTargetsForThisModOut(j).referencePixels.gapIndicators))';

        startIndex = endIndex +1;

    end

    % do an additional sorting on the blackColumns so the pixels in the same
    % rows (different columns) appear together

    [sortedBlackColumns sortIndex] = sort(blackColumns);

    pdqTempStruct.blackPixels            = blackPixels(sortIndex,:);
    pdqTempStruct.blackGapIndicators     = logical(blackGapFlags(sortIndex,:));
    pdqTempStruct.blackRows              = blackRows(sortIndex);
    pdqTempStruct.blackColumns           = blackColumns(sortIndex);

    pdqTempStruct.blackPixelsAvailable   = true;

    pdqTempStruct.rawBlackPixels          = blackPixels ;
    % if any of the black pixels come from leading black region, issue
    % a warning....

    if(any(blackColumns <= nLeadingBlack))
        warning('PDQ:determine_available_collateral_pixels',...
            ['Leading black pixels found for module = ' num2str(currentModule) ' output = ' num2str(currentOutput)] );
    end

else
    % if no black pixels are available, issue a warning....
    warning('PDQ:determine_available_collateral_pixels',...
        ['No black collateral targets for module = ' num2str(currentModule) ' output = ' num2str(currentOutput)] );

    pdqTempStruct.blackPixelsAvailable   = false;

end

%--------------------------------------------------------------------------
% collect smear collateral targets and separate into virtual smear and
% masked smear pixels
%--------------------------------------------------------------------------

labels      = cat(1,collateralTargetsForThisModOut.labels);
smearIndices  = find(strcmp(labels, 'PDQ_SMEAR_COLLATERAL'));

if(~isempty(smearIndices))

    smearCollateralTargetsForThisModOut = collateralTargetsForThisModOut(smearIndices);
    nSmearCollTargetsForThisModOut = length(smearIndices);

    smearCollateralPixelsPerTarget = zeros(nSmearCollTargetsForThisModOut, 1);

    for j = 1 : nSmearCollTargetsForThisModOut
        smearCollateralPixelsPerTarget(j) = length(smearCollateralTargetsForThisModOut(j).referencePixels);
    end
    numTotalSmearPixels  = sum(smearCollateralPixelsPerTarget);

    % Define arrays of module/output values, row & column indices, and
    % pixel value for all collateral pixels
    allSmearRows           = zeros(numTotalSmearPixels, 1);
    allSmearColumns        = zeros(numTotalSmearPixels, 1);
    allSmearPixels         = zeros(numTotalSmearPixels, numCadences);
    allSmearGapFlags       = true(numTotalSmearPixels, numCadences);

    startIndex = 1;

    for j = 1:nSmearCollTargetsForThisModOut

        endIndex = startIndex + smearCollateralPixelsPerTarget(j) - 1;

        allSmearRows(startIndex:endIndex)          = cat(1,smearCollateralTargetsForThisModOut(j).referencePixels.row);
        allSmearColumns(startIndex:endIndex)       = cat(1,smearCollateralTargetsForThisModOut(j).referencePixels.column);

        allSmearPixels((startIndex:endIndex),:)    = (cat(2, smearCollateralTargetsForThisModOut(j).referencePixels.timeSeries))';
        allSmearGapFlags((startIndex:endIndex),:)  = (cat(2, smearCollateralTargetsForThisModOut(j).referencePixels.gapIndicators))';

        startIndex = endIndex +1;

    end

    % Virtual smear pixels
    vsmearIndices           = find(allSmearRows > (nMaskedSmear + nRowsImaging));

    % Masked smear pixels
    msmearIndices           = find(allSmearRows <= nMaskedSmear);

    if (isempty(msmearIndices))
        msmearPixels        = 0;
        msmearRows          = [];
        msmearColumns       = [];
        msmearGapIndicators = true(1, numCadences);


    else
        msmearPixels        = allSmearPixels(msmearIndices, :);
        msmearGapIndicators = allSmearGapFlags(msmearIndices, :);
        msmearRows          = allSmearRows(msmearIndices);
        msmearColumns       = allSmearColumns(msmearIndices);

        % check to make sure that the smear pixels don't come from the
        % leading/trailing black region
        invalidMsmearIndices = find((msmearColumns <= nLeadingBlack) |(msmearColumns > nLeadingBlack+nColsImaging));
        if(~isempty(invalidMsmearIndices))

            warning('PDQ:determine_available_collateral_pixels',...
                ['Masked smear pixles extend into leading/trailing black region for module = ' num2str(currentModule) ' output = ' num2str(currentOutput)] );

            msmearGapIndicators(invalidMsmearIndices) = true;
        end


        pdqTempStruct.msmearPixelsAvailable     = true;
    end

    % Virtual smear pixels
    if (isempty(vsmearIndices))
        % cannot fing any virtual smear pixels
        vsmearPixels        = 0;
        vsmearRows          = [];
        vsmearColumns       = [];
        vsmearGapIndicators = false(1, numCadences);
    else
        vsmearPixels        = allSmearPixels(vsmearIndices, :);
        vsmearGapIndicators = allSmearGapFlags(vsmearIndices, :);
        vsmearRows          = allSmearRows(vsmearIndices);
        vsmearColumns       = allSmearColumns(vsmearIndices);

        % check to make sure that the smear pixels don't come from the
        % leading/trailing black region
        invalidVsmearIndices = find((vsmearColumns <= nLeadingBlack) |(vsmearColumns > nLeadingBlack+nColsImaging));
        if(~isempty(invalidVsmearIndices))

            warning('PDQ:determine_available_collateral_pixels',...
                ['Virtual smear pixles extend into leading/trailing black region for module = ' num2str(currentModule) ' output = ' num2str(currentOutput)] );

            vsmearGapIndicators(invalidVsmearIndices) = true;
        end
        pdqTempStruct.vsmearPixelsAvailable     = true;

    end


else
    warning('PDQ:determine_available_collateral_pixels',...
        ['No smear collateral targets for module = ' num2str(currentModule) ' output = ' num2str(currentOutput)] );

    pdqTempStruct.vsmearPixelsAvailable     = false;
    pdqTempStruct.msmearPixelsAvailable     = false;

end


% do an additional sorting on the msmearRows so the pixels in the same
% rows (different columns) appear together

[sortedMsmearRows sortMindex] = sort(msmearRows);

% Masked smear pixels - save
pdqTempStruct.msmearPixels           = msmearPixels(sortMindex, :);
pdqTempStruct.msmearGapIndicators    = logical(msmearGapIndicators(sortMindex, :));
pdqTempStruct.msmearRows             = msmearRows(sortMindex);
pdqTempStruct.msmearColumns          = msmearColumns(sortMindex);



pdqTempStruct.rawMsmearPixels        = pdqTempStruct.msmearPixels;


% do an additional sorting on the vsmearRows so the pixels in the same
% rows (different columns) appear together

[sortedVsmearRows sortVindex] = sort(vsmearRows);


% Virtual smear pixels - save
pdqTempStruct.vsmearPixels           = vsmearPixels(sortVindex, :);
pdqTempStruct.vsmearGapIndicators    = logical(vsmearGapIndicators(sortVindex, :));
pdqTempStruct.vsmearRows             = vsmearRows(sortVindex);
pdqTempStruct.vsmearColumns          = vsmearColumns(sortVindex);

pdqTempStruct.rawVsmearPixels        = pdqTempStruct.vsmearPixels ;


%-----------------------------------------------------------------------
% set the pixel values to zero if it is gap because moule interface does
% not guarantee that the pixel values will have 0 if they happen to be gaps
%-------------------------------------------------------------------------

pdqTempStruct.vsmearPixels(pdqTempStruct.vsmearGapIndicators) = 0;
pdqTempStruct.rawVsmearPixels(pdqTempStruct.vsmearGapIndicators) = 0;

pdqTempStruct.msmearPixels(pdqTempStruct.msmearGapIndicators) = 0;
pdqTempStruct.rawMsmearPixels(pdqTempStruct.msmearGapIndicators) = 0;


pdqTempStruct.blackPixels(pdqTempStruct.blackGapIndicators) = 0;
pdqTempStruct.rawBlackPixels(pdqTempStruct.blackGapIndicators) = 0;

return

