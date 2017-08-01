function construct_pdq_monte_carlo_validation_plots(pdqTempStruct, truth, modOut, nRealizations, s)

% plot(pdqTempStruct.rawBlackPixels(:,1)-419405+724*270)
% plot([pdqTempStruct.rawBlackPixels(:,1)-419405+724*270,pdqTempStruct.black2DForBlackPixels(:,1)])
% plot([pdqTempStruct.rawBlackPixels(:,1)-419405+724*270-pdqTempStruct.black2DForBlackPixels(:,1)])
% black4black = pdqTempStruct.black2DForBlackPixels(:,1);
% blackPix = pdqTempStruct.rawBlackPixels(:,1)-419405+724*270;
% c = black4black'*blackPix/(black4black'*black4black);
% plot([pdqTempStruct.rawBlackPixels(:,1)-419405+724*270-1.0087*pdqTempStruct.black2DForBlackPixels(:,1)])
%
%
% blackPix = pdqTempStruct.rawBlackPixels-419405+724*270;
%
% black4black = pdqTempStruct.black2DForBlackPixels;
%
% c = black4black'*blackPix/(black4black'*black4black);
%
% plot([pdqTempStruct.rawBlackPixels-419405+724*270 - pdqTempStruct.black2DForBlackPixels])
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





%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% construct_pdq_monte_carlo_validation_plots.m
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

close all
% plot to file parameters
isLandscapeOrientationFlag = true;
includeTimeFlag = false;
printJpgFlag = true;


numberOfExposuresPerLongCadence = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence; % for all cadences
ccdReadTime = pdqTempStruct.configMapStruct.ccdReadTime; % for all cadences
ccdExposureTime = pdqTempStruct.configMapStruct.ccdExposureTime; % for all cadences


%ground truth should collect original bkgd pixels columns

warning off all;
pdqScienceObject = pdqScienceClass(s);
[zStruct] = determine_available_stellar_pixels(pdqScienceObject,   modOut);
[zStruct] = determine_available_bkgd_pixels(pdqScienceObject, zStruct,  modOut);
warning on all;


% need to know how many of the target pixel {row,column} made into bkgd pixel
% {row, colum}






addedUniqueBkgdPixelRowColumns = setxor([zStruct.bkgdPixelRows, zStruct.bkgdPixelColumns], [pdqTempStruct.bkgdPixelRows, pdqTempStruct.bkgdPixelColumns], 'rows');

% addedBkgdPixelColumnsIndex = find(ismember([pdqTempStruct.bkgdPixelRows, pdqTempStruct.bkgdPixelColumns],...
%     [addedUniqueBkgdPixelRowColumns(:,1), addedUniqueBkgdPixelRowColumns(:,2)],'rows')); % these come from target pixels


bkgdPixelsFromTargetPixelsIndex = find(ismember([pdqTempStruct.targetPixelRows, pdqTempStruct.targetPixelColumns], ...
    [addedUniqueBkgdPixelRowColumns(:,1), addedUniqueBkgdPixelRowColumns(:,2)],'rows'));


%-------------------------------------------------------------------------
% preliminaries
%-------------------------------------------------------------------------
%

gain = pdqTempStruct.gainForAllCadencesAllModOuts(1,modOut);
nCadences = pdqTempStruct.numCadences;
nBinnedColumns = size(pdqTempStruct.blackPixels,1)/size(pdqTempStruct.binnedBlackPixels,1);
nBinnedRows = size(pdqTempStruct.vsmearPixels,1)/size(pdqTempStruct.binnedVsmearPixels,1);

%nExposures = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence(1);

% fixedOffset = pdqTempStruct.requantTableStruct.requantizationTableFixedOffset(1);
% meanBlack = pdqTempStruct.requantTableStruct.meanBlackEntries(modOut,1);
%
readNoiseSigmaPerLongCadence = truth.readNoiseSigmaPerLongCadence;
quantizationNoiseSigmaPerLongCadence = truth.quantizationNoiseSigmaPerLongCadence;

readNoiseQuantizationNoiseSigmaPerLongCadence = truth.readNoiseQuantizationNoiseSigmaPerLongCadence;
titleStr1 = ['read noise + quantization noise sigma = ' num2str(readNoiseQuantizationNoiseSigmaPerLongCadence)];
titleStr2 = ['read noise + quantization noise sigma = ' num2str(readNoiseQuantizationNoiseSigmaPerLongCadence/gain)];



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% propagation of uncertainty verification for black pixels
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

figure;
binnedBlackRows = pdqTempStruct.binnedBlackRows(:,1);

% blackCorrection = pdqTempStruct.blackCorrection(pdqTempStruct.binnedBlackRows(:,1), :);
trueBlack = truth.blackLevelAllRows(binnedBlackRows);
trueBlack = trueBlack(:)/gain;


%residualsInCorrectedBlack = pdqTempStruct.blackResiduals;

residualsInCorrectedBlack = zeros(size(pdqTempStruct.blackResiduals));

for j = 1:nRealizations

    blackCorrection = pdqTempStruct.blackCorrection(:,j);
    binnedBlackRows = pdqTempStruct.binnedBlackRows(:,j);

    residualsInCorrectedBlack(:,j) = blackCorrection(binnedBlackRows) - pdqTempStruct.binnedBlackPixels(:,j);

end

stdOfBlackPixelsResiduals = std(residualsInCorrectedBlack, [],2);

h1 = plot(trueBlack, stdOfBlackPixelsResiduals, 'bp');

hold on;

rmsEstimateOfTotalNoiseInBlackPixels = sqrt((readNoiseSigmaPerLongCadence/gain)^2 + (quantizationNoiseSigmaPerLongCadence/gain)^2)/sqrt(nBinnedColumns);

h2 = plot(sort(trueBlack), rmsEstimateOfTotalNoiseInBlackPixels , 'r.-');

allBestBlackPolyOrder = cat(1,pdqTempStruct.blackUncertaintyStruct.bestBlackPolyOrder);
mlBlackPolyOrder = mode(allBestBlackPolyOrder);
medianIndex = fix(median(find(allBestBlackPolyOrder == mlBlackPolyOrder)));

bestBlackPolyOrder = pdqTempStruct.blackUncertaintyStruct(medianIndex).bestBlackPolyOrder;

nCcdRows = pdqTempStruct.nCcdRows;
A = weighted_design_matrix(binnedBlackRows./nCcdRows, 1, bestBlackPolyOrder, 'standard');

CblackPolyFit = pdqTempStruct.blackUncertaintyStruct(medianIndex).CblackPolyFit;
Cblack2DcorrectedToBinned = pdqTempStruct.blackUncertaintyStruct(medianIndex).Cblack2DcorrectedToBinned;

CblackFitted    = A*CblackPolyFit*A'; % 1070x1070 - so create, use, and discard


blackPixelsUncertainty = sqrt(diag(CblackFitted+Cblack2DcorrectedToBinned));

h3 = plot(trueBlack,  blackPixelsUncertainty, 'o', 'color', [0 0.5 0]);

xlabel('Black pixels (ground truth) value in ADU'); 
ylabel('Black pixels uncertainty (after 2D black subtraction) in ADU');


legend([h1(1) h2(1) h3(1)], {'std of residuals (calibrated - raw) across realizations'; 'total noise (back of the envelope)'; 'through propagation of uncertainty'}, ...
    'Location', 'Best');

titleStr = ['Validation of propagation of uncertainties for black pixels after 2D black subtraction for modout ' num2str(modOut) ];
title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% propagation of uncertainty verification for smear pixels
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

figure;

calibratedSmearPixels = cat(2,pdqTempStruct.smearUncertaintyStruct.smear);

%validSmearColumns = pdqTempStruct.smearUncertaintyStruct(1).validSmearColumns;
allVisibleColumns = [zStruct.targetPixelColumns; zStruct.bkgdPixelColumns];

[uniqueSmearColumns, uniqueSmearIndex] = unique(allVisibleColumns);

smearPixelValues = [truth.smearForTargetColumns; truth.smearForBkgdColumns]; % truth bkgd pixels are ony 5 or so per target; pdq gathers additional bkgd

smearPixelValues = smearPixelValues(uniqueSmearIndex);

stdOfSmearPixelsResiduals = std(calibratedSmearPixels, [],2);

h1 = plot(smearPixelValues, stdOfSmearPixelsResiduals, 'bp');

hold on;


rmsEstimateOfTotalNoiseInSmearPixels = sqrt(sort(smearPixelValues) + readNoiseSigmaPerLongCadence^2 + quantizationNoiseSigmaPerLongCadence^2)/sqrt(nBinnedRows);

h2 = plot(sort(smearPixelValues ), rmsEstimateOfTotalNoiseInSmearPixels, 'r.-');

% get the mean
% find the first valid cadence
validCadence = -1;
for j = 1:nRealizations
    if(~isempty(pdqTempStruct.smearUncertaintyStruct(j).CsmearEstimate))
        validCadence = j;
        break;
    end
end

smearPixelsUncertainty = zeros(size(sqrt(diag(pdqTempStruct.smearUncertaintyStruct(validCadence).CsmearEstimate))));

for j = 1:nRealizations
    if(~isempty(pdqTempStruct.smearUncertaintyStruct(j).CsmearEstimate))
        smearPixelsUncertainty = smearPixelsUncertainty + sqrt(diag(pdqTempStruct.smearUncertaintyStruct(j).CsmearEstimate));
    else
        smearPixelsUncertainty = smearPixelsUncertainty + sqrt(diag(pdqTempStruct.smearUncertaintyStruct(validCadence).CsmearEstimate));
    end

end
smearPixelsUncertainty = smearPixelsUncertainty./nRealizations;



h3 = plot(smearPixelValues,  smearPixelsUncertainty, 'o', 'color', [0 0.5 0]);

xlabel('Smear pixels (ground truth) value in photoelectrons');   
ylabel('Smear pixels uncertainty in photoelectrons');   

titleStr = ['Validation of propagation of uncertainties for smear pixels after black correction for modout ' num2str(modOut) ];

legend([h1(1) h2(1) h3(1)], {'std of calibrated smear pixels across realizations'; 'total noise (back of the envelope)'; 'through propagation of uncertainty'}, ...
    'Location', 'Best');

title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% propagation of uncertainty verification for background pixels
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

figure;

calibratedBkgdPixels = pdqTempStruct.bkgdPixels;
bkgdPixelValues = truth.bkgdPixelValues;


% get the mean
bkgdPixelsUncertainty = zeros(size(pdqTempStruct.bkgdPixels,1), 1);

stdOfBkgdPixels = zeros(size(bkgdPixelsUncertainty));
bkgdGapIndicators   = pdqTempStruct.bkgdGapIndicators;

for j = 1:nRealizations

    validBkgdPixelIndices = find(~bkgdGapIndicators(:,j));

    if(~isempty(pdqTempStruct.bkgdPixelsUncertaintyStruct(j).Cbkgd))
        bkgdPixelsUncertainty(validBkgdPixelIndices) = bkgdPixelsUncertainty(validBkgdPixelIndices) + ...
            sqrt(diag(pdqTempStruct.bkgdPixelsUncertaintyStruct(j).Cbkgd));
    end

end
bkgdPixelsUncertainty = bkgdPixelsUncertainty./(sum(~bkgdGapIndicators,2));

for k = 1:length(bkgdPixelsUncertainty)

    validBkgdPixelIndices = find(~bkgdGapIndicators(k,:));

    stdOfBkgdPixels(k) = std(calibratedBkgdPixels(k, validBkgdPixelIndices));

end

h1 = plot(bkgdPixelValues, stdOfBkgdPixels, 'bp');

hold on;


rmsEstimateOfTotalNoiseInBkgdPixels = sqrt(sort(bkgdPixelValues) + readNoiseSigmaPerLongCadence^2 + quantizationNoiseSigmaPerLongCadence^2);

h2 = plot(sort(bkgdPixelValues), rmsEstimateOfTotalNoiseInBkgdPixels, 'r.-');


h3 = plot(bkgdPixelValues, bkgdPixelsUncertainty, 'o', 'color', [0 0.5 0]);

xlabel('Background pixels (ground truth) value in photoelectrons');   
ylabel('Background pixels uncertainty in photoelectrons');   

legend([h1(1) h2(1) h3(1)], {'std of calibrated bkgd pixels across realizations'; 'total noise (back of the envelope)'; 'through propagation of uncertainty'}, ...
    'Location', 'Best');

titleStr = ['Validation of propagation of uncertainties for bkgd pixels after smear correction for modout ' num2str(modOut) ];
title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% propagation of uncertainty verification for target pixels
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
figure;

calibratedTargetPixels = pdqTempStruct.targetPixels;
truthTargetPixels = repmat(truth.targetPixelValues, 1, nCadences);


hold on;


rmsEstimateOfTotalNoiseInTargetPixels = sqrt(sort(truthTargetPixels) + readNoiseSigmaPerLongCadence^2 + quantizationNoiseSigmaPerLongCadence^2);

h2 = plot(sort(truthTargetPixels), rmsEstimateOfTotalNoiseInTargetPixels, 'r.-');


% get the mean
% get the mean
targetPixelsUncertainty = zeros(size(pdqTempStruct.targetPixels,1), 1);

targetGapIndicators   = pdqTempStruct.targetGapIndicators;

for j = 1:nRealizations

    validTargetPixelIndices = find(~targetGapIndicators (:,j));
    if(~isempty(validTargetPixelIndices))
        targetPixelsUncertainty(validTargetPixelIndices) = targetPixelsUncertainty(validTargetPixelIndices) + ...
            sqrt(diag(pdqTempStruct.targetPixelsUncertaintyStruct(j).CtargetPixels));
    end

end
targetPixelsUncertainty = targetPixelsUncertainty./(sum(~targetGapIndicators,2));


stdOfTargetPixels = zeros(size(targetPixelsUncertainty));
for k = 1:length(targetPixelsUncertainty)

    validTargetPixelIndices = find(~targetGapIndicators(k,:));

    stdOfTargetPixels(k) = std(calibratedTargetPixels(k, validTargetPixelIndices));

end


h1 = plot(truthTargetPixels, stdOfTargetPixels, 'mp');

h3 = plot(truthTargetPixels, targetPixelsUncertainty, 'o', 'color', [0 0.5 0]);

xlabel('Target pixels (ground truth) value in photoelectrons');   
ylabel('Target pixels uncertainty in photoelectrons');   


legend([h1(1) h2(1) h3(1)], {'std of calibrated target pixels across realizations'; 'total noise (back of the envelope)'; 'through propagation of uncertainty'}, ...
    'Location', 'Best');

titleStr = ['Validation of propagation of uncertainties for target pixels after bkgd correction for modout ' num2str(modOut) ];
title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

%-------------------------------------------------------------------------
% target pixels calibration, background estimation step verification
%
% 1. after black2D , black level subtraction
% 2. after smear and dark subtraction
% 2. background level estimated should match the ground truth to within
%    read + quantization + shot noise
%-------------------------------------------------------------------------

figure;
h1 = plot(pdqTempStruct.targetPixels, 'b.-');

hold on;

h2 = plot(truth.targetPixelValues, 'rp-');

h3 = plot(pdqTempStruct.smearCorrectedTargetPixels, 'k:');
h4 = plot(pdqTempStruct.targetPixelsBlackCorrected*gain, 'm:');

legend([h1(1) h2 h3(1) h4(1)], {'calibrated taget pixels'; 'target pixels truth'; ...
    'smear corrected'; 'black corrected, gain adjusted '});
title({'Taget pixels after different stages of calibration'; titleStr1});
xlabel('Target pixel number');   
ylabel('Target pixels in photoelectrons');   

titleStr = ['Taget pixels after different stages of calibration for modout ' num2str(modOut) ];
title(titleStr);
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);




%-------------------------------------------------------------------------
% background pixels calibration, background estimation step verification
%
% 1. after black2D , black level subtraction
% 2. after smear and dark subtraction
% 2. background level estimated should match the ground truth to within
%    read + quantization + shot noise
%-------------------------------------------------------------------------

figure;

bkgdLevels = (pdqTempStruct.bkgdLevels);
nTargets = size(bkgdLevels,1);
nBkgdPixels = length(pdqTempStruct.bkgdPixelColumns);

z = zeros(nBkgdPixels,nCadences);

bkgdPixelsPerTarget = fix(nBkgdPixels/nTargets);
startIndex = 1;

for j = 1: nTargets

    stopIndex = startIndex -1 + bkgdPixelsPerTarget;
    if(j ~= nTargets)
        z(startIndex:stopIndex,:) = repmat(bkgdLevels(j,:),bkgdPixelsPerTarget,1);
        
    else
        nLeftOverPixels = length(startIndex:nBkgdPixels);
        z(startIndex:end,:) = repmat(bkgdLevels(j,:),nLeftOverPixels,1);
    end
    startIndex = stopIndex +1;
end

hold on;



h1 = plot(pdqTempStruct.bkgdPixelsBlackCorrected*gain, 'm-');


[uniqueRowsColumns, sortIndex] = unique([[zStruct.bkgdPixelRows, zStruct.bkgdPixelColumns]; ...
    [pdqTempStruct.targetPixelRows(bkgdPixelsFromTargetPixelsIndex), pdqTempStruct.targetPixelColumns(bkgdPixelsFromTargetPixelsIndex)]], 'rows');

truth.combinedSmearForBkgd = [truth.smearForBkgdColumns ; truth.smearForTargetColumns(bkgdPixelsFromTargetPixelsIndex)];

truth.combinedSmearForBkgd = truth.combinedSmearForBkgd(sortIndex);

h1t = plot((truth.combinedSmearForBkgd + truth.darkCurrentValueForMsmear)+(truth.bkgdPixelValues .*pdqTempStruct.bkgdFlatField(:,1)), 'ko-');


h2 = plot(pdqTempStruct.smearCorrectedBkgdPixels, 'g:');
h2t = plot((truth.bkgdPixelValues .*pdqTempStruct.bkgdFlatField(:,1))+ truth.darkCurrentValueForMsmear, 'ko-');


h3 = plot(pdqTempStruct.bkgdPixels,'color', [0.5 0.5 0.5 ], 'LineStyle', '-'); % after FF
h3e = plot(z, 'bo-');
h3t = plot(repmat(truth.bkgdPixelValues, nBkgdPixels,1), 'rp-', 'MarkerSize', 12);

xlabel('Background pixel number');   
ylabel('Background pixel value in photoelectrons');   

legend([h1t(1) h1(1) h2t(1) h2(1) h3(1) h3e(1) h3t(1)], {'black corrected, gain adjusted truth';'black corrected, gain adjusted ';
    'smear corrected background truth';'smear corrected background';  'after flatfield correction';
    'estimated background level'; 'background truth'}, 'Location', 'Best');
title({'Background pixels after different stages of calibration'; titleStr1});

titleStr = ['Background pixels after different stages of calibration for modout ' num2str(modOut) ];
title({titleStr; titleStr1});
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

%-------------------------------------------------------------------------
% dark current estimation step verification
%
% 1. after black2D , black level subtraction
% 2. dark level estimated should match the ground truth to within
%    read + quantization + shot noise
%-------------------------------------------------------------------------


gtDarkCurrent = truth.darkCurrentValueForMsmear./(numberOfExposuresPerLongCadence(1)*(ccdExposureTime(1) + ccdReadTime(1)));

nSmearColumns = length(pdqTempStruct.darkCurrentUncertaintyStruct(1).darkCurrentLevels);

figure;
darkCurrentLevel = [pdqTempStruct.darkCurrentUncertaintyStruct.darkCurrentLevels]; % nRealizations cadences of MC run
h1 = plot(darkCurrentLevel, 'b.');
hold on;
h2 = plot(repmat(gtDarkCurrent,nSmearColumns,1), 'rp-');

legend([h1(1) h2], {'estimated dark current level '; 'dark current level (truth) '}, 'Location', 'Best');

xlabel('Smear pixel number');   
ylabel('Dark current in photoelectrons/sec');

titleStr = ['Estimated dark level for modout ' num2str(modOut)];
title({titleStr;  titleStr1});
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

%-------------------------------------------------------------------------
% smear pixels calibration step verification
%
% 1. after black2D , black level subtraction
% 2. smear level estimated should match the ground truth to within
%    read + quantization + shot noise
%-------------------------------------------------------------------------



allVisibleColumns = [zStruct.targetPixelColumns; zStruct.bkgdPixelColumns];

[uniqueSmearColumns, uniqueSmearIndex] = unique(allVisibleColumns);

smearPixelValues = [truth.smearForTargetColumns; truth.smearForBkgdColumns]; % truth bkgd pixels are ony 5 or so per target; pdq gathers additional bkgd

gtSmear = smearPixelValues(uniqueSmearIndex);


figure;
smear = [pdqTempStruct.smearUncertaintyStruct.smear]; % nRealizations cadences of MC run
h1 = plot(smear, 'b.-');
hold on;
h2 = plot(gtSmear, 'rp-');
legend([h1(1) h2], {'estimated smear in photo electrons(MC)'; 'smear truth'}, 'Location', 'Best');
title({['estimated smear level for modout ' num2str(modOut) ]; titleStr1});

xlabel('Smear pixel (binned) number');   
ylabel('Estimated smear value in photoelectrons');   

titleStr = ['Estimated smear level for modout ' num2str(modOut)];
title({titleStr; titleStr2});
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);


%-------------------------------------------------------------------------
% black pixels calibration step verification
%
% 1. after black2D subtraction
% 2. black level estimation - polynomial order should match what was put in
%    Monte Carlo data generation
% 3. black level estimated should match the ground truth to within
%    read + quantization + shot noise
%-------------------------------------------------------------------------

blackRows = pdqTempStruct.blackRows;
blackColumns = pdqTempStruct.blackColumns;
uniqueBlackColumns = unique(blackColumns);
uniqueBlackRows = unique(blackRows);

figure

for j = 1:length(uniqueBlackColumns)

    bColumnIndex = find(blackColumns == uniqueBlackColumns(j));
    [blackRowsForThisColumn, sortedRowIndex] = sort(blackRows(bColumnIndex));
    h1 = plot(uniqueBlackRows, pdqTempStruct.blackPixels(sortedRowIndex), 'b.-'); % all the nRealizations cadences

    hold on;

end

h2 = plot(blackRows, truth.blackLevelAllRows(blackRows)'/gain, 'rp-');
h3 = plot(blackRows, ((truth.blackLevelAllRows(blackRows)'+readNoiseQuantizationNoiseSigmaPerLongCadence)/gain), 'rp:');
plot(blackRows, ((truth.blackLevelAllRows(blackRows)'-readNoiseQuantizationNoiseSigmaPerLongCadence)/gain), 'rp:');

legend([h1(1) h2(1) h3(1)], {'after black 2D subtraction (MC)'; 'black level truth in ADU'; ' one std ' }, ...
    'Location', 'Best');

xlabel('Row number');   
ylabel('Black level in ADU');

title({['Black level after 2D black subtraction for modout ' num2str(modOut)]; titleStr2});

titleStr = ['Black level after 2D black subtraction for modout ' num2str(modOut) ];
title({titleStr; titleStr2});
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

%.....................................................................

figure

h2 = plot(pdqTempStruct.blackCorrection, 'b-'); % all the nRealizations cadences
hold on;
h1 = plot( truth.blackLevelAllRows'/gain , 'rp-');

legend([h1 h2(1)], {'black level truth '; 'polynomial fitted black  (MC)'}, 'Location', 'Best');

title({['Polynomial fitting of residual black level for modout ' num2str(modOut)]; titleStr2});

xlabel('Row number');   
ylabel('Polynomial fitted black pixel value in ADU');

titleStr = ['Polynomial fitting of residual black level for modout ' num2str(modOut) ];
title({titleStr; titleStr2});
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

%.....................................................................

figure

subplot(2,1,1);

[bRows, bIndex] = unique(blackRows);

h1 = plot(pdqTempStruct.blackResiduals, 'b-'); % all the nRealizations cadences
hold on;
h2 = plot( repmat(readNoiseQuantizationNoiseSigmaPerLongCadence/gain/sqrt(nBinnedColumns),length(bIndex),1) , 'rp:'); % number of binned columns / rows
plot( -repmat(readNoiseQuantizationNoiseSigmaPerLongCadence/gain/sqrt(nBinnedColumns),length(bIndex),1) , 'rp:'); % number of binned columns / rows

legend([h1(1) h2 ], {'black Residuals'; 'read + quantization (MC)'}, 'Location', 'Best');

xlabel('Black pixel number');   
ylabel('Black residual in ADU');
title({['Residual black level for modout ' num2str(modOut)]; titleStr2});

subplot(2,1,2);

hist(pdqTempStruct.blackResiduals);
title('histogram of black residuals');

titleStr = ['Residual  black level for modout ' num2str(modOut)];
title({titleStr; titleStr2});
plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);
return


% plot(truth.targetPixelValues,std(pdqTempStruct.targetPixels-repmat(truth.targetPixelValues,1,nRealizations),[],2),'.');
% hold on;
% plot(sort(truth.targetPixelValues),sqrt(sort(truth.targetPixelValues)+270*(.79*112)^2+112^2/12),sort(truth.targetPixelValues),targetPixelsSig,'.')
%
% plot(truth.targetPixelValues,std(pdqTempStruct.targetPixels-repmat(truth.targetPixelValues,1,nRealizations),[],2),'.');
% hold on;
% plot(sort(truth.targetPixelValues),sqrt(sort(truth.targetPixelValues)+270*(.79*112)^2+112^2/12),truth.targetPixelValues,targetPixelsSig,'.')



% A CCD imager is composed of a two dimensional array of light sensitive
% detectors or pixels. The CCD array is mechanically quite stable with the
% pixels retaining a rigidly fixed geometric relationship. Each pixel
% within the array, however, has its own unique light sensitivity
% characteristics. As these characteristics affect camera performance, they
% must be removed through calibration. The process by which a CCD camera is
% calibrated is known as "Flat Fielding" or "Shading Correction".
%
% Flat fielding can be illustrated in the following equation:
%
% IC = [(IR - IB) * M] / (IF - IB)
%
% Where IC is the calibrated image; IR is the non-calibrated object
% exposure; IB is the bias or dark frame; M is the average pixel value of
% the corrected flat field frame; and IF is the flat field frame.
%
% IB Flat fielding requires the acquisition of two calibration frames.
% First, a bias frame or a dark frame should be taken. Bias clears the
% camera of any accumulated charge and reads out the cleared CCD. The
% resulting image is a low signal value image. In this image, all of the
% pixels have approximately the same value, which consists of the
% electronic offset of the system of the inherent structure of the CCD.
% Dark clears the CCD of charge, allows charge to accumulate for a
% specified amount of time with the shutter closed and then reads out that
% charge (dark current). A dark frame contains the standard bias component
% as well as the dark signal. The dark command is most useful when taking
% long exposures with low light levels.
%
% IF The second calibation image, the flat field frame, measures the
% response of each pixel in the CCD array to illumination and is used to
% correct for any variation in illumination over the field of the array.
% The optical system most likely introduces some variation in the
% illumination pattern over the field of the array. The flat fielding
% process corrects for uneven illumination, if that illumination is a
% stable characteristic of each object exposure. Thus, it is necessary to
% illuminate the CCD with a light pattern that is as representative of the
% background illumination as possible. This illumination should be bright
% enough, or the exposure made long enough, so that the CCD pixels signals
% are at least 25 percent full scale or preferably higher. For a
% Photometrics camera equipped with a 12 bit analog processing card, the
% level should be at least 1000 ADUs.
%
% IR An exposure of the object of interest is acquired.
%
% (IR - IB) The object frame must be corrected for electronic offset by
% subtraction of the bias/dark frame from it.
%
% (IF - IB) The flat field frame must also be corrected for electronic
% offset by subtraction of the bias/dark frame from it. The average pixel
% value of the bias/dark corrected flat field frame must then be
% ascertained (M).
%
%
%
%
%
