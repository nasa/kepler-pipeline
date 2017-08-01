function pdqTempStruct = determine_available_stellar_pixels(pdqScienceObject, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqTempStruct] =
% determine_available_stellar_pixels(pdqScienceObject, currentModOut)
%
% The pdqScienceObject contains a list of stellar targets for all the module
% outputs. This function selects those stellar target pixels that belong to
% the current module output.
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

% check to see if there are any stellar targets for this modout
if(isempty(pdqScienceObject.stellarPdqTargets))

    % set flags and return to process next modout
    pdqTempStruct.stellarPixelsAvailable        = false;
    pdqTempStruct.dynamicRangeTargetAvailable   = false;
    pdqTempStruct.stellarTargetsAvailable       = false;

    warning('PDQ:determineAvailableStellarPixels',...
        ['No stellar pixels for module = ' num2str(module) ' output = ' num2str(output)] );
    return
end


ccdModules          = cat(1, pdqScienceObject.stellarPdqTargets.ccdModule);
ccdOutputs          = cat(1, pdqScienceObject.stellarPdqTargets.ccdOutput);

validModuleOutputs  = convert_from_module_output(ccdModules, ccdOutputs);

numCadences         = length(pdqScienceObject.cadenceTimes);

validTargetIndices  = find(validModuleOutputs == currentModOut);

pdqTempStruct.stellarPixelsAvailable        = true;
pdqTempStruct.dynamicRangeTargetAvailable   = true;
pdqTempStruct.stellarTargetsAvailable       = true;


if (isempty(validTargetIndices))

    % No data for this module ouput
    warning('PDQ:determineAvailableStellarPixels',...
        ['No stellar pixels for module = ' num2str(module) ' output = ' num2str(output)] );
    pdqTempStruct.stellarPixelsAvailable = false;
    return

end


numTargets                  = length(validTargetIndices);

stellarTargetsForThisModOut = pdqScienceObject.stellarPdqTargets(validTargetIndices);
labels                      = cell(numTargets,2); % labels at the most contain 2 strings
referencePixelsPerTarget    = zeros(numTargets,1);

% can not avoid this loop as dynamic targets have two strings in their
% labels {'PDQ_STELLAR', 'PDQ_DYNAMIC_RANGE'}

for k = 1:numTargets

    nlabels                     = length(stellarTargetsForThisModOut(k).labels);
    labels(k,1:nlabels)         = stellarTargetsForThisModOut(k).labels;
    referencePixelsPerTarget(k) = length(stellarTargetsForThisModOut(k).referencePixels);

end
% without columnNumber, find returns a linear index
[dynamicIndex, columnNumber]    = find(strcmp(labels, 'PDQ_DYNAMIC_RANGE'));

if(~isempty(dynamicIndex))
    numDynamicPixels    = sum(referencePixelsPerTarget(dynamicIndex));
    numTargetPixels     = sum(referencePixelsPerTarget) - numDynamicPixels;
    numValidTargets     = numTargets - length(dynamicIndex);

    if(numValidTargets == 0)
        warning('PDQ:determineAvailableStellarPixels',...
            ['No stellar targets for module = ' num2str(module) ' output = ' num2str(output)] );
        pdqTempStruct.stellarTargetsAvailable = false;

    end

else
    % should we generate a warning if there are no dynamic targets for
    % this module output?
    warning('PDQ:determineAvailableStellarPixels',...
        ['No dynamic range targets for module = ' num2str(module) ' output = ' num2str(output)] );
    pdqTempStruct.dynamicRangeTargetAvailable = false;

    numDynamicPixels    = 0;
    numTargetPixels     = sum(referencePixelsPerTarget);
    numValidTargets     = numTargets;
end


dynamicPixels           = zeros(numDynamicPixels, numCadences);
dynamicRows             = ones(numDynamicPixels, 1);
dynamicColumns          = ones(numDynamicPixels, 1);
dynamicGapIndicators    = false(numDynamicPixels, numCadences);

referencePixels         = zeros(numTargetPixels, numCadences);
referenceGapIndicators  = false(numTargetPixels, numCadences);

refPixelRows            = ones(numTargetPixels, 1);
refPixelColumns         = ones(numTargetPixels, 1);
isInOptimalAperture     = zeros(numTargetPixels, 1);

raStars                 = zeros(numValidTargets,1);
decStars                = zeros(numValidTargets,1);
keplerIds               = zeros(numValidTargets,1);
keplerMags              = zeros(numValidTargets,1);
numPixels               = zeros(numValidTargets,1);

numPixelsInOptimalAperture  = zeros(numValidTargets,1);


targetIndices           = zeros(numValidTargets,1);
fluxFractionInAperture  = zeros(numValidTargets,1);

startIndexDynamic       = 1;
startIndexTarget        = 1;
kTargetStarCount        = 0;

for k = 1:numTargets

    if(~isempty(dynamicIndex) && (ismember(k, dynamicIndex)))

        nReferencePixels = referencePixelsPerTarget(k);
        endIndexDynamic = startIndexDynamic + nReferencePixels -1;
        dynamicPixels(startIndexDynamic:endIndexDynamic, :)  = (cat(2, stellarTargetsForThisModOut(k).referencePixels.timeSeries))';
        dynamicRows(startIndexDynamic:endIndexDynamic) = cat(1, stellarTargetsForThisModOut(k).referencePixels.row);
        dynamicColumns((startIndexDynamic:endIndexDynamic)) = cat(1, stellarTargetsForThisModOut(k).referencePixels.column);
        dynamicGapIndicators(startIndexDynamic:endIndexDynamic, :)  = (cat(2, stellarTargetsForThisModOut(k).referencePixels.gapIndicators))';

        startIndexDynamic = endIndexDynamic+1;


    else

        nReferencePixels = referencePixelsPerTarget(k);
        endIndexTarget = startIndexTarget + nReferencePixels -1;

        % sort target pixel rows, columns so it is in raster scan order reference
        % pixels structure does not always have the pixels in any particular order
        % - proves to be a problem in computing the transformations in centroid
        % calculation

        tempPixels                  = (cat(2, stellarTargetsForThisModOut(k).referencePixels.timeSeries))';
        tempGapIndicators           = (cat(2, stellarTargetsForThisModOut(k).referencePixels.gapIndicators))';
        tempPixelRows               = cat(1, stellarTargetsForThisModOut(k).referencePixels.row);
        tempPixelColumns            = cat(1, stellarTargetsForThisModOut(k).referencePixels.column);
        tempIsInOptimalAperture     = cat(1, stellarTargetsForThisModOut(k).referencePixels.isInOptimalAperture);


        [sortedValues, sortOrder] = sortrows([tempPixelRows tempPixelColumns]);


        referencePixels(startIndexTarget:endIndexTarget, :)         = tempPixels(sortOrder,:);
        referenceGapIndicators(startIndexTarget:endIndexTarget, :)  = tempGapIndicators(sortOrder,:);
        refPixelRows(startIndexTarget:endIndexTarget)               = tempPixelRows(sortOrder);
        refPixelColumns(startIndexTarget:endIndexTarget)            = tempPixelColumns(sortOrder);
        isInOptimalAperture(startIndexTarget:endIndexTarget)        = tempIsInOptimalAperture(sortOrder);



        kTargetStarCount                = kTargetStarCount + 1;

        raStars(kTargetStarCount)       = stellarTargetsForThisModOut(k).raHours;

        decStars(kTargetStarCount)      = stellarTargetsForThisModOut(k).decDegrees;
        keplerIds(kTargetStarCount)     = stellarTargetsForThisModOut(k).keplerId;
        keplerMags(kTargetStarCount)    = stellarTargetsForThisModOut(k).keplerMag;
        fluxFractionInAperture(kTargetStarCount)        = stellarTargetsForThisModOut(k).fluxFractionInAperture;

        numPixels(kTargetStarCount)                     = referencePixelsPerTarget(k);

        numPixelsInOptimalAperture(kTargetStarCount)    = sum(isInOptimalAperture(startIndexTarget:endIndexTarget));

        targetIndices(kTargetStarCount)                 = validTargetIndices(k);

        startIndexTarget                                = endIndexTarget+1;
    end

    nlabels = length(stellarTargetsForThisModOut(k).labels);
    labels(k,1:nlabels) = stellarTargetsForThisModOut(k).labels;
    referencePixelsPerTarget(k) = length(stellarTargetsForThisModOut(k).referencePixels);
end




%========== WARNING: ra of stars in the inputs.bin file is in hours
%(straight out of KIC) - multiply by (360/24 = 15) to convert to degrees
pdqTempStruct.raStars                = raStars * 15;


pdqTempStruct.decStars               = decStars;
pdqTempStruct.keplerIds              = keplerIds;
pdqTempStruct.keplerMags             = keplerMags;

pdqTempStruct.numPixelsInAperture    = numPixels;

pdqTempStruct.targetIndices          = targetIndices;
pdqTempStruct.fluxFractionInAperture = fluxFractionInAperture;


pdqTempStruct.targetPixels           = referencePixels; % nPixelvalues X nCadences
pdqTempStruct.targetPixelRows        = refPixelRows;
pdqTempStruct.targetPixelColumns     = refPixelColumns;

pdqTempStruct.isInOptimalAperture    = logical(isInOptimalAperture);
pdqTempStruct.targetGapIndicators    = referenceGapIndicators;


% choose to keep only pixels in the optimal aperture - else there is
% problem with background correction

% indexOfPixelsInOptimalAperture       = find(isInOptimalAperture);

% pdqTempStruct.targetPixels           = referencePixels(indexOfPixelsInOptimalAperture,:);
% pdqTempStruct.targetPixelRows        = refPixelRows(indexOfPixelsInOptimalAperture);
% pdqTempStruct.targetPixelColumns     = refPixelColumns(indexOfPixelsInOptimalAperture);
% pdqTempStruct.isInOptimalAperture    = isInOptimalAperture(indexOfPixelsInOptimalAperture);
% pdqTempStruct.targetGapIndicators    = referenceGapIndicators(indexOfPixelsInOptimalAperture,:);


pdqTempStruct.rawTargetPixels           = referencePixels;


pdqTempStruct.validTargetIndicesForThisModOut     = validTargetIndices; % index into pdqScienceObject stellarPdqTargets
pdqTempStruct.dynamicPixels             = dynamicPixels;
pdqTempStruct.dynamicRows               = dynamicRows;
pdqTempStruct.dynamicColumns            = dynamicColumns;
pdqTempStruct.dynamicGapIndicators      = dynamicGapIndicators;



% pdqTempStruct.numPixels               = numPixelsInOptimalAperture;

pdqTempStruct.numPixels                 = pdqTempStruct.numPixelsInAperture;
pdqTempStruct.numTargets                = length(targetIndices);
pdqTempStruct.numCadences               = numCadences;
pdqTempStruct.cadenceTimes              = pdqScienceObject.cadenceTimes;


% parameters from pdqConfiguration
pdqTempStruct.eeFluxFraction            = pdqScienceObject.pdqConfiguration.eeFluxFraction;
pdqTempStruct.maxBlackPolyOrder         = pdqScienceObject.pdqConfiguration.maxBlackPolyOrder;
pdqTempStruct.madSigmaThresholdForBleedingColumns = pdqScienceObject.pdqConfiguration.madSigmaThresholdForBleedingColumns;
pdqTempStruct.sigmaForRejectingBadTargets = pdqScienceObject.pdqConfiguration.sigmaForRejectingBadTargets;
pdqTempStruct.madThresholdForCentroidOutliers = pdqScienceObject.pdqConfiguration.madThresholdForCentroidOutliers;



pdqTempStruct.sigmaGaussianRollOff = pdqScienceObject.pdqConfiguration.sigmaGaussianRollOff;
pdqTempStruct.immediateNeighborhoodRadiusInPixel = pdqScienceObject.pdqConfiguration.immediateNeighborhoodRadiusInPixel;


pdqTempStruct.haloAroundOptimalApertureInPixels = pdqScienceObject.pdqConfiguration.haloAroundOptimalApertureInPixels;


pdqTempStruct.maxFzeroIterations = pdqScienceObject.pdqConfiguration.maxFzeroIterations;
pdqTempStruct.encircledEnergyPolyOrderMax = pdqScienceObject.pdqConfiguration.encircledEnergyPolyOrderMax;
pdqTempStruct.debugLevel = pdqScienceObject.pdqConfiguration.debugLevel;


% Module parameters
pdqTempStruct.nCcdRows                  = pdqScienceObject.fcConstants.CCD_ROWS;  % number of rows in full CCD readout
pdqTempStruct.nCcdColumns               = pdqScienceObject.fcConstants.CCD_COLUMNS;  % number of rows in full CCD readout
pdqTempStruct.standardMag12Flux         = pdqScienceObject.fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;
pdqTempStruct.nominalPointing           = pdqScienceObject.fcConstants.NOMINAL_FOV_CENTER_DEGREES; % triad ra, dec, roll

pdqTempStruct.nRowsImaging              = pdqScienceObject.fcConstants.nRowsImaging;  % number of rows in visible CCD readout
pdqTempStruct.nColsImaging              = pdqScienceObject.fcConstants.nColsImaging;  % number of columns visible CCD readout
pdqTempStruct.nLeadingBlackColumns      = pdqScienceObject.fcConstants.nLeadingBlack; % number of leading black columns
pdqTempStruct.nTrailingBlackColumns     = pdqScienceObject.fcConstants.nTrailingBlack;% number of trailing black columns
pdqTempStruct.nVirtualSmearRows         = pdqScienceObject.fcConstants.nVirtualSmear; % number of virtual smear rows
pdqTempStruct.nMaskedSmearRows          = pdqScienceObject.fcConstants.nMaskedSmear;  % number of masked smear rows


pdqTempStruct.ccdModule                 = module;
pdqTempStruct.ccdOutput                 = output;
pdqTempStruct.currentModOut             = currentModOut;

% extract prfModel filename for this mod out
pdqTempStruct.prfFilename               = pdqScienceObject.prfModelFilenames{currentModOut};  % number of masked smear rows

%-----------------------------------------------------------------------
% Note: RPTS sometimes selects pixels outside the visible silicon because
% the n-pixel halo around the targets might extend into the collateral
% region. This creates problem when calibrating the target pixels - we end
% up subtracting smear, background from (say) those pixels that might have
% come from the leading black region
% declare such target pixels extending into the collateral regions as gaps
% check for each and every cadence
%-----------------------------------------------------------------------

for iCadence = 1:numCadences


    % find if any of the target pixels come from the smear regions

    indexInSmearRegions = find(pdqTempStruct.targetPixelRows <= pdqTempStruct.nMaskedSmearRows ...
        | pdqTempStruct.targetPixelRows >= (pdqTempStruct.nMaskedSmearRows + pdqTempStruct.nRowsImaging ));


    indexInBlackRegions = find(pdqTempStruct.targetPixelColumns <= pdqTempStruct.nLeadingBlackColumns ...
        | pdqTempStruct.targetPixelColumns >= (pdqTempStruct.nLeadingBlackColumns + pdqTempStruct.nColsImaging ));

    invalidIndices = [indexInSmearRegions indexInBlackRegions]; % works even if all are empty

    if(~isempty(invalidIndices))
        pdqTempStruct.targetGapIndicators(invalidIndices,iCadence)    = true;  % declare those errant target pixels as gaps
    end

end


return
