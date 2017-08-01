function pdqTempStruct = correct_for_background(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = correct_for_background(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function estimates the background level in the neighborhood of each
% target star.
%
% step 1: get the distances from each bkgd pixel to the aperture
% center
%
% step2 : determine weights according to distance from aperture center
%
% step 3: Take the weighted mean to determine background for each target
% (use robust fit here to reject any outliers in the background pixels.
% outliers might occur if the background pixels happen to be a neighboring
% target pixel...)
%
% step 4: subtract background levels only from pixels containing data
% leave the gaps alone
%
% Propagate uncertainties along the way....
%  Calculate the median smear, median dark level, median background level
%  (suitable for tracking & trending)
%  Generate a bootstrap uncertainty estimate for the median smear, median
%  dark leve, median background level
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
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


sigmaForRejectingBadTargets = pdqTempStruct.sigmaForRejectingBadTargets;
% Obtain necessary input data from pdqTempStruct
numberOfExposuresPerLongCadence = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence; % for all cadences

sigmaGaussianRollOff                = pdqTempStruct.sigmaGaussianRollOff;
immediateNeighborhoodRadiusInPixel  = pdqTempStruct.immediateNeighborhoodRadiusInPixel;


targetPixels            = pdqTempStruct.targetPixels;
targetGapIndicators     = pdqTempStruct.targetGapIndicators;


bkgdPixels              = pdqTempStruct.bkgdPixels;
bkgdPixelColumns        = pdqTempStruct.bkgdPixelColumns;
bkgdPixelRows           = pdqTempStruct.bkgdPixelRows;
bkgdGapIndicators       = pdqTempStruct.bkgdGapIndicators;

% Find out how many cadences and targets we are processing
numCadences             = pdqTempStruct.numCadences;
numTargets              = length(pdqTempStruct.keplerIds);
numPixels               = pdqTempStruct.numPixels;

pdqTempStruct.medianBkgds                             = zeros(numCadences, 1);
pdqTempStruct.medianBkgdsUncertainties                = zeros(numCadences, 1);

pdqTempStruct.medianSmears                            = zeros(numCadences, 1);
pdqTempStruct.medianSmearsUncertainties               = zeros(numCadences, 1);

pdqTempStruct.medianDarkCurrentLevels                 = zeros(numCadences, 1);
pdqTempStruct.medianDarkCurrentLevelsUncertainties    = zeros(numCadences, 1);


pdqTempStruct.bkgdLevels                = zeros(numTargets, numCadences);
pdqTempStruct.bkgdLevelsUncertainties   = zeros(numTargets, numCadences);

pdqTempStruct.backgroundPixelsAvailableFlag = true(numCadences,1);


ccdReadTime = pdqTempStruct.configMapStruct.ccdReadTime; % for all cadences
ccdExposureTime = pdqTempStruct.configMapStruct.ccdExposureTime; % for all cadences


for cadenceIndex = 1 : numCadences

    totalBkgdPixels = length(bkgdPixels(:,1));
    totalTargetPixels = length(targetPixels(:,1));

    targetPixelsUncertaintyStruct = struct('CtargetPixels', zeros(totalTargetPixels, totalTargetPixels), ...
        'bkgdWeights', zeros(totalTargetPixels, totalBkgdPixels));
    bkgdPixelsUncertaintyStruct = struct('Cbkgd', zeros(totalBkgdPixels, totalBkgdPixels));

    pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex) = targetPixelsUncertaintyStruct;
    pdqTempStruct.bkgdPixelsUncertaintyStruct(cadenceIndex) = bkgdPixelsUncertaintyStruct;

end

for cadenceIndex = 1 : numCadences

    validBkgdPixelIndices = find(~bkgdGapIndicators(:,cadenceIndex));
    availableBkgdRows =  bkgdPixelRows(validBkgdPixelIndices);
    availableBkgdColumns = bkgdPixelColumns(validBkgdPixelIndices);

    % black 2D, black fit uncertainties are already available
    % in pdqTempStruct

    % may need to save CsmearEstimate, CmsmearGainCorrected, CvsmearGainCorrected in the smear
    % uncertainty struture

    try
        [CsmearEstimate, CmsmearGainCorrected, CvsmearGainCorrected, pdqTempStruct] ...
            = compute_smear_pixels_uncertainties(pdqTempStruct, cadenceIndex);
        pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CsmearEstimate = CsmearEstimate;
        pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CmsmearGainCorrected = CmsmearGainCorrected;
        pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CvsmearGainCorrected = CvsmearGainCorrected;

    catch

        warning('PDQ:backgroundCorrection:smearPixelsUncertainty', ...
            ['backgroundCorrection: invalid CsmearEstimate for cadence ' num2str(cadenceIndex) '; skipping this cadence']);
        pdqTempStruct = set_uncertainty_structs_to_empty(pdqTempStruct, cadenceIndex);
        continue;

    end


    try
        % may need to save CdarkCorrection in the dark currents
        % uncertainty struture
        [CdarkCorrection, pdqTempStruct]   = compute_dark_currents_uncertainties(CmsmearGainCorrected, ...
            CvsmearGainCorrected, pdqTempStruct, cadenceIndex);
        pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).CdarkCorrection = CdarkCorrection;

    catch

        warning('PDQ:backgroundCorrection:darkCurrentsUncertainty', ...
            ['backgroundCorrection: invalid CdarkCorrection for cadence ' num2str(cadenceIndex) '; skipping this cadence']);
        pdqTempStruct = set_uncertainty_structs_to_empty(pdqTempStruct, cadenceIndex);
        continue;

    end


    % First test for the presence of gaps in the data
    if (isempty(validBkgdPixelIndices))

        % not clear what else needs to be set to zero or -1
        % gap introduced by not having background pixels
        % need to revisit this segment

        warning('PDQ:backgroundCorrection:backgroundPixels', ...
            ['backgroundCorrection: no background pixels available for cadence ' num2str(cadenceIndex) '; skipping this cadence']);
        pdqTempStruct = set_uncertainty_structs_to_empty(pdqTempStruct, cadenceIndex);

    else

        % may need to save Cbkgd in the background level
        % uncertainty struture
        try

            Cbkgd = compute_background_pixels_uncertainties(CsmearEstimate, CdarkCorrection, pdqTempStruct, cadenceIndex);
            pdqTempStruct.bkgdPixelsUncertaintyStruct(cadenceIndex).Cbkgd = Cbkgd;

        catch

            warning('PDQ:backgroundCorrection:CovarianceMatrix', ...
                ['backgroundCorrection: invalid background pixels covariance matrix for cadence ' num2str(cadenceIndex) '; skipping this cadence']);
            pdqTempStruct = set_uncertainty_structs_to_empty(pdqTempStruct, cadenceIndex);
            continue;

        end

        pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).bkgdWeights = zeros(totalTargetPixels, length(validBkgdPixelIndices));
        % Aperture centers are the approximate (row, column) center of each
        % target
        [rowCenters colCenters] = get_aperture_center(pdqTempStruct, cadenceIndex);

        startIndex  = 1;
        for targetIndex = 1 : numTargets
            % Get index range corresponding to each target in targetPixels
            % array

            stopIndex = startIndex + numPixels(targetIndex)- 1;
            currentTargetPixelIndices = (startIndex:stopIndex)';
            currentTargetGapIndicators = targetGapIndicators(currentTargetPixelIndices,cadenceIndex);
            validPixelIndices = currentTargetPixelIndices(~currentTargetGapIndicators);

            % pixels negative even before background subtraction, gap the entire target
            if(any(targetPixels(validPixelIndices, cadenceIndex) <= 0))

                nPixelsBelowZero = length(find(targetPixels(validPixelIndices, cadenceIndex) < 0));

                warning('PDQ:backgroundCorrection:targetPixels', ...
                    ['backgroundCorrection: target [' num2str(targetIndex) '] has ' num2str(nPixelsBelowZero) ' pixels below zero even before background subtraction; gapping the entire target for this cadence ' num2str(cadenceIndex) ]);

                targetGapIndicators(currentTargetPixelIndices,cadenceIndex) = true;
                pdqTempStruct.targetGapIndicators = targetGapIndicators;
                currentTargetGapIndicators = targetGapIndicators(currentTargetPixelIndices,cadenceIndex);
                validPixelIndices = currentTargetPixelIndices(~currentTargetGapIndicators);
            end

            % make sure the target has pixels to process
            if(~isempty(validPixelIndices))

                % These are the distances from each bkgd pixel to the aperture
                % center
                residualRadius = sqrt((rowCenters(targetIndex) - availableBkgdRows).^2 + ...
                    (colCenters(targetIndex) - availableBkgdColumns).^2);

                % Determine weights according to distance from aperture center
                weights     = compute_weights(residualRadius, immediateNeighborhoodRadiusInPixel, sigmaGaussianRollOff);


                % Take the weighted mean to determine background for each target
                % Vectorize this
                bkgdLevelsAll   = bkgdPixels(validBkgdPixelIndices, cadenceIndex) .* weights;

                nonZeroBkgdIndex = find(weights > 0);

                bkgdLevelsForThisTarget  = bkgdLevelsAll(nonZeroBkgdIndex);

                if(length(bkgdLevelsForThisTarget) > 2) % can do robust  fit

                    warning off all;
                    % use robust fit here...
                    designMatrixA = ones(length(bkgdLevelsForThisTarget),1);
                    [brob, stats] = robustfit(designMatrixA,bkgdLevelsForThisTarget);

                    if(any(stats.w == 0))

                        outlierIndex = find(stats.w ==0);
                        bkgdLevelsForThisTarget(outlierIndex) = [];
                        designMatrixA(outlierIndex) = [];
                        usedBkgdIndex = setxor(nonZeroBkgdIndex, nonZeroBkgdIndex(outlierIndex));
                        % rows, columns corresponding to the  outliers must be
                        % removed from Cbkgd
                        % also use weights from the robust fit

                        [brob, stats] = robustfit(designMatrixA,bkgdLevelsForThisTarget);

                        robustWeights = (stats.w).* (weights(usedBkgdIndex)) ; % what if all robust weights are zeros?
                    else

                        usedBkgdIndex = nonZeroBkgdIndex;
                        robustWeights = (stats.w).* (weights(usedBkgdIndex)) ;

                    end

                    warning on all;
                else
                    % not clear what else needs to be set to zero or -1
                    % gap introduced by not having enough background pixels, some of them having been eliminated by robustfit
                    % need to revisit this segment

                    warning('PDQ:backgroundCorrection:backgroundPixels', ...
                        ['backgroundCorrection: target [' num2str(targetIndex) '] has only one background pixel on this ccd module' num2str(pdqTempStruct.ccdModule) ' ccd output ' num2str(pdqTempStruct.ccdOutput)]);

                    usedBkgdIndex = nonZeroBkgdIndex;
                    robustWeights = weights(nonZeroBkgdIndex);

                end

                % save the weights for propagation of uncertainty
                bkgdWeights = zeros(size(weights));
                bkgdWeights(usedBkgdIndex) = robustWeights;

                % Take the weighted mean to determine background for each target
                % Vectorize this
                bkgdLevel   = sum(bkgdPixels(validBkgdPixelIndices, cadenceIndex) .* bkgdWeights)/sum(bkgdWeights);

                % save the weights for propagation of uncertainty
                normalizedWeights = bkgdWeights./sum(bkgdWeights);

                % Save the background levels for later use
                % Vectorize this

                pdqTempStruct.bkgdLevels(targetIndex, cadenceIndex)  = bkgdLevel;
                pdqTempStruct.bkgdLevelsUncertainties(targetIndex, cadenceIndex)  = sqrt(normalizedWeights' * Cbkgd * normalizedWeights);

                pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).bkgdWeights(startIndex:stopIndex,:) = ...
                    repmat(normalizedWeights', numPixels(targetIndex),1);

                % subtract background levels only from pixels containing data
                % leave the gaps alone


                targetPixels(validPixelIndices, cadenceIndex) = targetPixels(validPixelIndices, cadenceIndex) - bkgdLevel;

                if(any(targetPixels(validPixelIndices, cadenceIndex) <=  (-0.5*bkgdLevel)))

                    nPixelsBelowBkgdLevel = length(find(targetPixels(validPixelIndices, cadenceIndex) < 0));
                    warning('PDQ:backgroundCorrection:targetPixels', ...
                        ['backgroundCorrection: ' num2str(nPixelsBelowBkgdLevel) ' pixels(s) of this target [' num2str(targetIndex) '] is/are negative after background subtraction on this ccd module' num2str(pdqTempStruct.ccdModule) ' ccd output ' num2str(pdqTempStruct.ccdOutput)]);
                end

            else % entire target is empty or gapped

                pdqTempStruct.bkgdLevels(targetIndex, cadenceIndex)  = -1;
                pdqTempStruct.bkgdLevelsUncertainties(targetIndex, cadenceIndex)  = -1;
            end

            startIndex  = stopIndex + 1;

        end

        % remove the rows corresponding to the data gaps in the target
        % pixels
        gapLocations = find(targetGapIndicators(:, cadenceIndex));
        pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).bkgdWeights(gapLocations,:) = [];
        %
        % propagate uncertainties now
        try

            CtargetPixels = compute_target_pixels_uncertainties(CsmearEstimate, CdarkCorrection, Cbkgd,...
                pdqTempStruct, cadenceIndex);

            validPixelIndices = ~targetGapIndicators(:,cadenceIndex);
            indexToReject  = find((targetPixels(validPixelIndices,cadenceIndex)./(diag(CtargetPixels))) < -sigmaForRejectingBadTargets);
            if(~isempty(indexToReject))
                % see whether a particular target is bad....and reject the
                % entire target
                startIndex = 1;
                for targetIndex = 1 : numTargets
                    % Get index range corresponding to each target in targetPixels
                    % array

                    stopIndex = startIndex + numPixels(targetIndex)- 1;
                    currentTargetPixelIndices = (startIndex:stopIndex)';
                    currentTargetGapIndicators = targetGapIndicators(currentTargetPixelIndices,cadenceIndex);
                    validPixelIndices = currentTargetPixelIndices(~currentTargetGapIndicators);

                    intersectPixels = intersect(validPixelIndices, indexToReject);
                    if(~isempty(intersectPixels))
                        pdqTempStruct.targetGapIndicators(currentTargetPixelIndices,cadenceIndex) = true;
                    end

                    startIndex  = stopIndex + 1;
                end

                warning('PDQ:backgroundCorrection:targetPixels', ...
                    ['backgroundCorrection: ' num2str(length(indexToReject)) ' pixels(s) are rejected after background subtraction on this ccd module' num2str(pdqTempStruct.ccdModule) ' ccd output ' num2str(pdqTempStruct.ccdOutput)]);

                CtargetPixels = compute_target_pixels_uncertainties(CsmearEstimate, CdarkCorrection, Cbkgd,...
                    pdqTempStruct, cadenceIndex);
            end



            pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).CtargetPixels = CtargetPixels;
            pdqTempStruct.targetPixels(:,cadenceIndex) = targetPixels(:,cadenceIndex) ;

            % Calculate the median background for the entire module/output
            pdqTempStruct.medianBkgds(cadenceIndex) = median(pdqTempStruct.bkgdLevels(:, cadenceIndex));
            pdqTempStruct.medianBkgdsUncertainties(cadenceIndex) = generate_montecarlo_uncertainty_of_median(length(pdqTempStruct.bkgdLevels(:, cadenceIndex)),...
                diag(pdqTempStruct.bkgdLevelsUncertainties(:, cadenceIndex).^2) );
        catch
            warning('PDQ:backgroundCorrection:invalidTargetPixelsCovarianceMatrix', ...
                ['backgroundCorrection: target pixels covariance matrix invalid for cadence ' num2str(cadenceIndex) '; skipping this cadence']);
            pdqTempStruct = set_uncertainty_structs_to_empty(pdqTempStruct, cadenceIndex);
            continue;

        end

    end

    smearvalues  = pdqTempStruct.smearUncertaintyStruct(cadenceIndex).smear;

    if(~isempty(smearvalues))
        pdqTempStruct.medianSmears(cadenceIndex)                          = median(smearvalues);
        pdqTempStruct.medianSmearsUncertainties(cadenceIndex)             = generate_montecarlo_uncertainty_of_median(length(smearvalues), CsmearEstimate);
    else

        pdqTempStruct.medianSmears(cadenceIndex)                          = -1;
        pdqTempStruct.medianSmearsUncertainties(cadenceIndex)             = -1;

    end


    darkCurrentLevels =  pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).darkCurrentLevels;

    if(~isempty(darkCurrentLevels))

        % during PDQ requirements verification, Doug Caldwell suggested that
        % darkCurrentlevel shoud be in units of electrons/sec rather than the photoelectrons
        exposurePlusReadTimeInSec  = numberOfExposuresPerLongCadence(cadenceIndex)*(ccdExposureTime(cadenceIndex) + ccdReadTime(cadenceIndex));

        pdqTempStruct.medianDarkCurrentLevels(cadenceIndex)               = median(darkCurrentLevels);
        pdqTempStruct.medianDarkCurrentLevelsUncertainties(cadenceIndex)  = generate_montecarlo_uncertainty_of_median(length(darkCurrentLevels), CdarkCorrection./(exposurePlusReadTimeInSec^2));
    else
        pdqTempStruct.medianDarkCurrentLevels(cadenceIndex)               = -1;
        pdqTempStruct.medianDarkCurrentLevelsUncertainties(cadenceIndex)  = -1;

    end


end

warning on all;

return

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%function pdqTempStruct = set_uncertainty_structs_to_empty(pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function pdqTempStruct = set_uncertainty_structs_to_empty(pdqTempStruct, cadenceIndex)


pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CsmearEstimate = [];
pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CmsmearGainCorrected = [];
pdqTempStruct.smearUncertaintyStruct(cadenceIndex).CvsmearGainCorrected = [];


pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).CdarkCorrection = [];

pdqTempStruct.bkgdPixelsUncertaintyStruct(cadenceIndex).Cbkgd = [];


pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).CtargetPixels =[];
pdqTempStruct.targetPixels(:,cadenceIndex) = -1;
pdqTempStruct.targetGapIndicators(:,cadenceIndex) = true;
pdqTempStruct.targetPixelsUncertaintyStruct(cadenceIndex).bkgdWeights = [];

pdqTempStruct.bkgdLevels(:, cadenceIndex)  = -1;
pdqTempStruct.bkgdLevelsUncertainties(:, cadenceIndex)  = -1;

pdqTempStruct.backgroundPixelsAvailableFlag(cadenceIndex) = false;
% Calculate the median background for the entire module/output
pdqTempStruct.medianBkgds(cadenceIndex) = -1;
pdqTempStruct.medianBkgdsUncertainties(cadenceIndex) = -1;



pdqTempStruct.medianSmears(cadenceIndex) = -1;
pdqTempStruct.medianSmearsUncertainties(cadenceIndex) = -1;


pdqTempStruct.medianDarkCurrentLevels(cadenceIndex) = -1;
pdqTempStruct.medianDarkCurrentLevelsUncertainties(cadenceIndex) = -1;

pdqTempStruct.medianBkgds(cadenceIndex) = -1;
pdqTempStruct.medianBkgdsUncertainties(cadenceIndex) = -1;

return

