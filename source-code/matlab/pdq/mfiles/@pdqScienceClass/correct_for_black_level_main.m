function [pdqTempStruct, pdqOutputStruct]  = ...
    correct_for_black_level_main(pdqScienceObject, pdqTempStruct, pdqOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqTempStruct, pdqOutputStruct]  =
% correct_black_level(pdqScienceObject, pdqTempStruct, pdqOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function corrects the reference target pixels, background pixels,
% and smear pixels for black 2d and black.
%
%   Subtracting the black level from pixel values is the first step in
%   pixel level calibration. This consists of
%     Step 1: subtract 2D black model from all types of pixels
%     Step 2: combine virtual smear, masked smear, black measurements into
%     one column / one row each
%     Step 3: choose a polynomial model order to fit the residual black
%     use binned black, vsmear, msmear pixels for fitting polynomials;
%     collect terms for propagation of uncertainties
%     Step 4: apply black correction to all types of pixels
%     Step 5: apply correction to cadences with missing black pixels
%     if no black pixels are available for the first cadence, then fill the
%     structure with the data from the nearest cadence;
%     Step 6:  Read in existing black level time series (metric consisting of
%     mean black level for each cadence and associated uncertainty) if any;
%     append to it
%
% Inputs
% pdqScienceObject =
%         pdqConfiguration: [1x1 struct]
%              fcConstants: [1x1 struct]
%               configMaps: [1x1 struct]
%             cadenceTimes: [30x1 double]
%                gainModel: [1x1 struct]
%           raDec2PixModel: [1x1 struct]
%          twoDBlackModels: [1x84 struct]
%          flatFieldModels: [1x84 struct]
%           inputPdqTsData: [1x1 struct]
%        stellarPdqTargets: [1x27 struct]
%     backgroundPdqTargets: [1x84 struct]
%     collateralPdqTargets: [1x1260 struct]
%           readNoiseModel: [1x1 struct]
%
% Outputs
% pdqOutputStruct
%                outputPdqTsData: [1x1 struct]
%          attitudeAdjustment: [1x1 struct]
%     centroidsForPlateScales: [1x1 struct]
%               summaryReport: [84x1 struct]
%                       alert: 0
%                alertMessage: 'no alerts'
% pdqTempStruct = (added fields only..)
%                   blackUncertaintyStruct: [4x1 struct]
%               targetPixelsBlackCorrected: [330x4 double]
%                 bkgdPixelsBlackCorrected: [100x4 double]
%                        binnedBlackPixels: [362x4 double]
%                      blackPixelsInRowBin: [362x4 double]
%                 binnedBlackGapIndicators: [362x4 double]
%                          binnedBlackRows: [362x4 double]
%                        binnedBlackColumn: [4x1 double]
%                       binnedMsmearPixels: [370x4 double]
%                  msmearPixelsInColumnBin: [370x4 double]
%                binnedMsmearGapIndicators: [370x4 double]
%                          binnedMsmearRow: [4x1 double]
%                      binnedMsmearColumns: [370x4 double]
%                 numberOfMsmearRowsBinned: [1 1 1 1]
%                       binnedVsmearPixels: [370x4 double]
%                  vsmearPixelsInColumnBin: [370x4 double]
%                binnedVsmearGapIndicators: [370x4 double]
%                          binnedVsmearRow: [4x1 double]
%                      binnedVsmearColumns: [370x4 double]
%                 numberOfVsmearRowsBinned: [1 1 1 1]
%                          blackCorrection: [1070x4 double]
%                                meanBlack: [2.3673e+005 2.3673e+005 2.3673e+005 2.3673e+005]
%                   meanBlackUncertainties: [0.7265 0.7265 0.7265 0.7265]
%
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

pdqTempStruct.ccdRows = (1 : pdqTempStruct.nCcdRows)';

currentModOut         = pdqTempStruct.currentModOut;

pdqTempStruct = correct_for_black_level(pdqTempStruct, currentModOut);

%--------------------------------------------------------------------------
% bleeding stars affect only msmear values and show up as strong
% outliers; detect them now (after black2d, black calibration) and treat them as data gaps
%--------------------------------------------------------------------------

numCadences             = pdqTempStruct.numCadences;
madSigmaThresholdForBleedingColumns = pdqTempStruct.madSigmaThresholdForBleedingColumns;


for jCadence = 1:numCadences

    smearDifference = pdqTempStruct.binnedMsmearPixels(:,jCadence)  - pdqTempStruct.binnedVsmearPixels(:,jCadence);

    medianOfDifference = median(smearDifference);

    medianAbsoluteDeviations = abs(abs(smearDifference) - medianOfDifference);

    % calculate robust std ignoring any outliers due to CR hit
    % Neither the standard deviation nor the variance is robust to outliers.

    [robustCoeffts, robustStat] = robustfit((1:length(medianAbsoluteDeviations))', medianAbsoluteDeviations);
    validSmearIndex = (robustStat.w > 0);
    stdMAD = std(medianAbsoluteDeviations(validSmearIndex));


    % Neither the standard deviation nor the variance is robust to outliers.
    %stdMAD = std(prctile(medianAbsoluteDeviations, 1:98)); % calculate std using upto 98th percentile; ignore extreme values

    if(stdMAD > 0)
        bleedingOrCosmicRayHitColumns = find(medianAbsoluteDeviations >= madSigmaThresholdForBleedingColumns*stdMAD);

        if(~isempty(bleedingOrCosmicRayHitColumns))

            pdqTempStruct.binnedMsmearPixels(bleedingOrCosmicRayHitColumns,jCadence)  = pdqTempStruct.binnedVsmearPixels(bleedingOrCosmicRayHitColumns,jCadence);

            warning('PDQ:determine_available_collateral_pixels',...
                [' binned masked smear column(s) ' num2str(bleedingOrCosmicRayHitColumns') ' detected as bleeding or cosmic ray hit for cadence  = ' num2str(jCadence) ...
                '\n setting binned masked smear = binned virtual smear for  column(s) '  num2str(bleedingOrCosmicRayHitColumns') ' for cadence  = ' num2str(jCadence)]);


        end
    end
end




%--------------------------------------------------------------------------
% Read in existing black level time series (metric consisting of mean black
% level for each cadence and associated uncertainty), if any; append to it
%--------------------------------------------------------------------------

% Read in existing black level time series, if any
blackLevels   = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).blackLevels;

% If black level time series exists, append to it
% If this is a new quarter the time series will not exist
% In that case the constructor has set the time series to all zeros
% Make sure results are in the form of a column vector
nCadences = length(pdqTempStruct.cadenceTimes);


if (isempty(blackLevels.values))

    blackLevels.values = pdqTempStruct.meanBlack(:);
    blackLevels.uncertainties = pdqTempStruct.meanBlackUncertainties(:);


    blackLevels.gapIndicators = false(nCadences,1);

    % set the gap indicators to true wherever the metric = -1;
    metricGapIndex = find(pdqTempStruct.meanBlack(:) == -1);

    if(~isempty(metricGapIndex))
        blackLevels.gapIndicators(metricGapIndex) = true;
    end

else

    blackLevels.values = [blackLevels.values(:); pdqTempStruct.meanBlack(:)];
    blackLevels.uncertainties = [blackLevels.uncertainties(:); pdqTempStruct.meanBlackUncertainties(:)];

    gapIndicators = false(nCadences,1);

    % set the gap indicators to true wherever the metric = -1;
    metricGapIndex = find(pdqTempStruct.meanBlack(:) == -1);

    if(~isempty(metricGapIndex))
        gapIndicators(metricGapIndex) = true;
    end

    blackLevels.gapIndicators = [blackLevels.gapIndicators(:); gapIndicators(:)];

    % Sort time series using the time stamps as a guide
    [allTimes sortedTimeSeriesIndices] = ...
        sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
        pdqScienceObject.cadenceTimes(:)]);

    blackLevels.values = blackLevels.values(sortedTimeSeriesIndices);
    blackLevels.uncertainties = blackLevels.uncertainties(sortedTimeSeriesIndices);
    blackLevels.gapIndicators = blackLevels.gapIndicators(sortedTimeSeriesIndices);

end
%--------------------------------------------------------------------------
% Save results in pdqOutputStruct
% This is a time series for tracking and trending
%--------------------------------------------------------------------------
pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut).blackLevels = blackLevels;


return;
