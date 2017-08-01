function  [pdqTempStruct] = collect_additional_bkgd_pixels_from_target_aperture(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  [pdqTempStruct] = collect_additional_bkgd_pixels_from_target_aperture(pdqTempStruct)
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

numCadences         = pdqTempStruct.numCadences;

bkgdGapIndicators   = pdqTempStruct.bkgdGapIndicators;
targetGapIndicators = pdqTempStruct.targetGapIndicators;

%------------------------------------------------------------------------
% need to collect additional background pixels from the large mask/aperture
% assigned to the target pixels .... the complication is, background pixels
% chosen from the mask can change from cadence to cadence; % treat all the
% target pixels as potential background pixel candidates which serves as a
% master list; treat all the pixels as gaps; they make the inclusion list
% only if these pixels meet certain criteria like (1) not being in the
% optimal aperture (2) pixel values < median(bkgd pixel for all cadences)
%------------------------------------------------------------------------

pdqTempStruct.potentialBkgdPixels = pdqTempStruct.targetPixels; % undershoot corrected

pdqTempStruct.potentialBkgdRows = pdqTempStruct.targetPixelRows;
pdqTempStruct.potentialBkgdColumns = pdqTempStruct.targetPixelColumns;
pdqTempStruct.potentialBkgdGapIndicators = true(size(pdqTempStruct.targetGapIndicators));


for iCadence = 1:numCadences

    % we can not derive median from all bkgd pixels available since this
    % makes the median level dependent on the number of cadences and hence
    % the number of background pixels avaialble - makes it difficult to
    % varify the requirement that PDQ will produce identical results when
    % processing 4 cadences at a time for  m reference pixel files and when
    % reprocessing all the 'n' (= 4*m) cadence stogether.

    bkgdGapIndicatorsForThisCadence = bkgdGapIndicators(:,iCadence);

    bkgdPixelsForThisCadence        = pdqTempStruct.bkgdPixels(:,iCadence);

    targetPixelsForThisCadence      = pdqTempStruct.targetPixels(:,iCadence);

    nBkgdPixelsForThisCadence = sum(~bkgdGapIndicatorsForThisCadence);
    if(nBkgdPixelsForThisCadence == 0)
        continue;
    end


    if(nBkgdPixelsForThisCadence > 2)

        medianBkgdLevelForThisCadence = median(bkgdPixelsForThisCadence(~bkgdGapIndicatorsForThisCadence)); % mean instead of median just in case of outliers
        medianBkgdLevelForThisCadence = fix(medianBkgdLevelForThisCadence);

        medianAbsoluteDeviation = ceil(median(abs(bkgdPixelsForThisCadence(~bkgdGapIndicatorsForThisCadence) - medianBkgdLevelForThisCadence)));

        medianBkgdLevel = medianBkgdLevelForThisCadence + medianAbsoluteDeviation ; % slightly above the median level

    else
        medianBkgdLevel = median(bkgdPixelsForThisCadence(~bkgdGapIndicatorsForThisCadence)); % median instead of mean just in case of outliers
    end
    %------------------------------------------------------------------------
    % collect additional background pixels from the large mask/aperture assigned to
    % the target pixels
    %------------------------------------------------------------------------

    medianBkgdLevel         = fix(medianBkgdLevel);
    validTargetPixelIndex   = find(~targetGapIndicators(:,iCadence));
    candidateBkgdPixelIndex = find(targetPixelsForThisCadence(validTargetPixelIndex) < medianBkgdLevel);

    if(~isempty(candidateBkgdPixelIndex))

        % include these pixels since target pixel values < median(bkgd
        % pixel) for this cadence
        pdqTempStruct.potentialBkgdGapIndicators(validTargetPixelIndex(candidateBkgdPixelIndex), iCadence) = false;

    end

end


% now remove the gap indicators locations corresponding to optimal aperture
% pixel locations
inOptimalApertureIndex = find(pdqTempStruct.isInOptimalAperture);
pdqTempStruct.potentialBkgdGapIndicators(inOptimalApertureIndex, :) = [];
pdqTempStruct.potentialBkgdPixels(inOptimalApertureIndex, :) = [];

pdqTempStruct.potentialBkgdRows(inOptimalApertureIndex) = [];
pdqTempStruct.potentialBkgdColumns(inOptimalApertureIndex) = [];

% also remove those pixels that are gapped for all the cadences (did not
% make the list as potential bkgd pixel)

nPotentialBkgdPixels = length(pdqTempStruct.potentialBkgdGapIndicators(:,1));
removeFromPotentialListIndex = false(nPotentialBkgdPixels,1);
for j=1:nPotentialBkgdPixels

    allCadencesNotChosen = (sum(pdqTempStruct.potentialBkgdGapIndicators(j, :)) == numCadences);
    removeFromPotentialListIndex(j) = allCadencesNotChosen;

end
indexOfPotentialBkgdPixelsToRemove = find(removeFromPotentialListIndex);

pdqTempStruct.potentialBkgdGapIndicators(indexOfPotentialBkgdPixelsToRemove, :) = [];
pdqTempStruct.potentialBkgdPixels(indexOfPotentialBkgdPixelsToRemove, :) = [];

pdqTempStruct.potentialBkgdRows(indexOfPotentialBkgdPixelsToRemove) = [];
pdqTempStruct.potentialBkgdColumns(indexOfPotentialBkgdPixelsToRemove) = [];

if(~isempty(pdqTempStruct.potentialBkgdPixels))
    %---------------------------------------------------------------------------
    % collect indices of  target pixels that made their way into bkgd pixel
    % list as we need to keep track of raw values for propagating uncertainties

    % original bkgd pixels occasionally are in the target aperture (not in the optimal aperture though!)
    %---------------------------------------------------------------------------
    % sometimes the bkgd pixels come from target aperture
    bkgdPixelsFromTargetPixelsRowColumns = intersect([pdqTempStruct.potentialBkgdRows, pdqTempStruct.potentialBkgdColumns],...
        [pdqTempStruct.bkgdPixelRows, pdqTempStruct.bkgdPixelColumns], 'rows');

    if(~isempty(bkgdPixelsFromTargetPixelsRowColumns))

        addedBkgdPixelRowColumns = setxor([pdqTempStruct.potentialBkgdRows, pdqTempStruct.potentialBkgdColumns],...
            [bkgdPixelsFromTargetPixelsRowColumns(:,1), bkgdPixelsFromTargetPixelsRowColumns(:,2)], 'rows');
    else
        addedBkgdPixelRowColumns = [pdqTempStruct.potentialBkgdRows, pdqTempStruct.potentialBkgdColumns];
    end


    bkgdPixelsFromTargetPixelsIndex = find(ismember([pdqTempStruct.targetPixelRows, pdqTempStruct.targetPixelColumns], ...
        [addedBkgdPixelRowColumns(:,1), addedBkgdPixelRowColumns(:,2)],'rows'));


    pdqTempStruct.bkgdPixelsFromTargetPixelsIndex = bkgdPixelsFromTargetPixelsIndex;

    inBkgdIndex = bkgdPixelsFromTargetPixelsIndex;


    %---------------------------------------------------------------------------
    % for validation/plotting purposes only
    %---------------------------------------------------------------------------
    pdqTempStruct.rawBkgdPixels  = [pdqTempStruct.rawBkgdPixels; pdqTempStruct.rawTargetPixels(inBkgdIndex,:)];

    % sort so that the pixel values correspond to sorted [bkgdRows,
    % bkgdColumns] order
    combinedBkgdPixelRows = [pdqTempStruct.bkgdPixelRows; pdqTempStruct.targetPixelRows(inBkgdIndex) ];

    combinedBkgdPixelColumns = [pdqTempStruct.bkgdPixelColumns; pdqTempStruct.targetPixelColumns(inBkgdIndex) ];

    % need this unique order
    [uniqueRowsColumns, uniqueBkgdPixelsIndex] = unique([combinedBkgdPixelRows, combinedBkgdPixelColumns], 'rows');
    
    pdqTempStruct.rawBkgdPixels = pdqTempStruct.rawBkgdPixels(uniqueBkgdPixelsIndex,:);



    %--------------------------------------------------------------------------------------
    % update the previous bkgdPixelsBlackCorrected now that we have added more bkgd pixels
    %--------------------------------------------------------------------------------------

    pdqTempStruct.bkgdPixelsBlackCorrected = [pdqTempStruct.bkgdPixelsBlackCorrected; pdqTempStruct.targetPixelsBlackCorrected(inBkgdIndex,:)];

    pdqTempStruct.bkgdPixelsBlackCorrected = pdqTempStruct.bkgdPixelsBlackCorrected(uniqueBkgdPixelsIndex,:);

    %--------------------------------------------------------------------------------------
    % get background flat field again so it includes the newly added bkgd pixels too...
    %--------------------------------------------------------------------------------------

    pdqTempStruct.bkgdFlatField = [pdqTempStruct.bkgdFlatField; pdqTempStruct.targetFlatField(inBkgdIndex,:)];

    pdqTempStruct.bkgdFlatField = pdqTempStruct.bkgdFlatField(uniqueBkgdPixelsIndex,:);


    %--------------------------------------------------------------------------------------
    % get background flat field again so it includes the newly added bkgd pixels too...
    %--------------------------------------------------------------------------------------

    pdqTempStruct.smearCorrectedBkgdPixels = [pdqTempStruct.smearCorrectedBkgdPixels; pdqTempStruct.smearCorrectedTargetPixels(inBkgdIndex,:)];
    pdqTempStruct.smearCorrectedBkgdPixels = pdqTempStruct.smearCorrectedBkgdPixels(uniqueBkgdPixelsIndex,:);


    pdqTempStruct.darkCorrectedBkgdPixels = [pdqTempStruct.darkCorrectedBkgdPixels; pdqTempStruct.darkCorrectedTargetPixels(inBkgdIndex,:)];
    pdqTempStruct.darkCorrectedBkgdPixels = pdqTempStruct.darkCorrectedBkgdPixels(uniqueBkgdPixelsIndex,:);

    %---------------------------------------------------------------------------
    % now concatenate the potential background pixels to the already existing
    % bkgd pixels structure
    %---------------------------------------------------------------------------

    pdqTempStruct.bkgdPixels = [pdqTempStruct.bkgdPixels; pdqTempStruct.potentialBkgdPixels];


    pdqTempStruct.bkgdPixelRows = [pdqTempStruct.bkgdPixelRows; pdqTempStruct.potentialBkgdRows ];

    pdqTempStruct.bkgdPixelColumns = [pdqTempStruct.bkgdPixelColumns; pdqTempStruct.potentialBkgdColumns ];


    pdqTempStruct.bkgdGapIndicators = [pdqTempStruct.bkgdGapIndicators; pdqTempStruct.potentialBkgdGapIndicators];

    % make sure the bkgd pixel rows and columns are unique

    [uniqueRowsColumns, indexIntoBkgdRows] = unique([pdqTempStruct.bkgdPixelRows, pdqTempStruct.bkgdPixelColumns], 'rows');


    pdqTempStruct.bkgdPixelRows = uniqueRowsColumns(:,1);

    pdqTempStruct.bkgdPixelColumns = uniqueRowsColumns(:,2);

    pdqTempStruct.bkgdPixels = pdqTempStruct.bkgdPixels(indexIntoBkgdRows,:);

    pdqTempStruct.bkgdGapIndicators = pdqTempStruct.bkgdGapIndicators(indexIntoBkgdRows,:);


else

    warning('PDQ:collect_additional_bkgd_pixels_from_target_pixels:NoAdditionalPixelsFound', ...
        'collect_additional_bkgd_pixels_from_target_pixels: couldn''t find any background additional pixels from target pixels');
end

return
