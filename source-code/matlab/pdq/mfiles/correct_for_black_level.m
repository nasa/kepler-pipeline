function pdqTempStruct = correct_for_black_level(pdqTempStruct, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = correct_for_black_level(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function calibrates all pixels for black2D and black.
%
% Step 1: subtract 2D black model from all types of pixels
%
% Step 2: combine virtual smear, masked smear, black measurements into
% one column / one row each
%
% Step 3: choose a polynomial model order to fit the residual black
% use binned black, vsmear, msmear pixels for fitting polynomials
% collect terms for propagation of uncertainties
%
% Step 4: apply black correction to all types of pixels
%
% Step 5: apply correction to cadences with missing black pixels if no
% black pixels are available for the first cadence, then it would be
% impossible to fill the structure with the data from the nearest cadence;
% so we have to iterate through all the cadences before we can fill the
% missing cadence
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


numCadences             = pdqTempStruct.numCadences;

blackUncertaintyStruct  = repmat(struct('bestBlackPolyOrder', [],...
    'CblackPolyFit',[]), numCadences,1);


% PDQ software allows for the possibility that reference pixels can change
% generally we want the target & aperture definitions to remain the same
% for an entire quarter - but there is no guarantee of this happening.
% At some point during the quarter the target & aperture definitions can
% change, or the total number of pixels may change (typically decrease)

% Loop through all cadences
% Correct target reference pixels for black level
% Correct background reference pixels for black level
% Calculate mean black level per CCD module/ouput

blackGapIndicators                          = pdqTempStruct.blackGapIndicators; % gaps are indicated by 1
pdqTempStruct.blackAvailable                = ~logical(prod(double(blackGapIndicators),1)); % check for whole cadence missing
pdqTempStruct.blackAvailable                = pdqTempStruct.blackAvailable(:);

pdqTempStruct.blackUncertaintyStruct        = blackUncertaintyStruct;

% allocate memory to preserve target pixels and bkgd pixels right after
% black correction
pdqTempStruct.targetPixelsBlackCorrected    = zeros(size(pdqTempStruct.targetPixels));
pdqTempStruct.bkgdPixelsBlackCorrected      = zeros(size(pdqTempStruct.bkgdPixels));

pdqTempStruct.black2DForBlackPixels         = zeros(size(pdqTempStruct.blackPixels));
pdqTempStruct.black2DForTargetPixels        = zeros(size(pdqTempStruct.targetPixels));
pdqTempStruct.black2DForBkgdPixels          = zeros(size(pdqTempStruct.bkgdPixels));
pdqTempStruct.black2DForMsmearPixels        = zeros(size(pdqTempStruct.msmearPixels));
pdqTempStruct.black2DForVsmearPixels        = zeros(size(pdqTempStruct.vsmearPixels));


for cadenceIndex = 1 : numCadences

    %------------------------------------------------------------------
    % Step 1: subtract 2D black model from all types of pixels
    %------------------------------------------------------------------

    pdqTempStruct = subtract_black2DModel_from_pixels(pdqTempStruct, cadenceIndex, currentModOut);
end

for cadenceIndex = 1 : numCadences
    %------------------------------------------------------------------
    % Step 2: combine virtual smear, masked smear, black measurements into
    % one column / one row each
    %------------------------------------------------------------------

    pdqTempStruct = bin_collateral_measurements(pdqTempStruct, cadenceIndex);

end

for cadenceIndex = 1 : numCadences
    %------------------------------------------------------------------
    % Step 3: choose a polynomial model order to fit the residual black
    % use binned black, vsmear, msmear pixels for fitting polynomials
    % collect terms for propagation of uncertainties
    %------------------------------------------------------------------

    pdqTempStruct = fit_2D_corrected_black_with_best_polynomial(pdqTempStruct, cadenceIndex);

end

for cadenceIndex = 1 : numCadences
    if(pdqTempStruct.blackAvailable(cadenceIndex))

        %------------------------------------------------------------------
        % Step 4: apply black correction to all types of pixels
        %------------------------------------------------------------------

        pdqTempStruct = apply_black_correction_to_pixels(pdqTempStruct, cadenceIndex);

    end
end

%------------------------------------------------------------------
% Step 5: apply correction to cadences with missing black pixels if no
% black pixels are available for the first cadence, then it would be
% impossible to fill the structure with the data from the nearest cadence;
% so we have to iterate through all the cadences before we can fill the
% missing cadence
%------------------------------------------------------------------
anyMissingCadences = find(~pdqTempStruct.blackAvailable);
if(~isempty(anyMissingCadences))

    if(length(anyMissingCadences) == numCadences) % this can never happen as this condition has already been taken care of...

        warning('PDQ:correctBlackLevel:NoBlackLevelsAvailable', ...
            ['correct_for_black_level: no black levels available for ' num2str(numCadences) ' cadences - can''t do black correction!']);

    else

        for mCadence = 1:length(anyMissingCadences)

            availableCadences = setxor(anyMissingCadences, (1:numCadences)');

            % use the black levels of the nearest non-missing cadence
            missingCadence = anyMissingCadences(mCadence);

            [minDist, minIndex] = min(abs(availableCadences - missingCadence));
            nearestAvailableCadence = availableCadences(minIndex);

            warning('PDQ:correctBlackLevel:MissingBlackLevels', ...
                ['correct_for_black_level: no black levels available for ' ...
                num2str(missingCadence) ' cadence - using the next nearest cadence to fill ' num2str(nearestAvailableCadence)]);

            % but what about uncertainties for the missing cadence
            pdqTempStruct.blackUncertaintyStruct(missingCadence) = ...
                pdqTempStruct.blackUncertaintyStruct(nearestAvailableCadence);

            pdqTempStruct.binnedBlackGapIndicators(:, missingCadence) = ...
                pdqTempStruct.binnedBlackGapIndicators(:, nearestAvailableCadence);

            pdqTempStruct.binnedBlackPixels(:, missingCadence) = ...
                pdqTempStruct.binnedBlackPixels(:, nearestAvailableCadence);

            pdqTempStruct.blackPixelsInRowBin(:, missingCadence) = ...
                pdqTempStruct.blackPixelsInRowBin(:, nearestAvailableCadence);

            pdqTempStruct.binnedBlackRows(:, missingCadence) = ...
                pdqTempStruct.binnedBlackRows(:, nearestAvailableCadence);

            pdqTempStruct.binnedBlackColumn(missingCadence) = ...
                pdqTempStruct.binnedBlackColumn(nearestAvailableCadence);

            pdqTempStruct.blackCorrection(:, missingCadence) = ...
                pdqTempStruct.blackCorrection(:, nearestAvailableCadence);

            pdqTempStruct.blackAvailable(cadenceIndex) = false;

            % if a cadence is missing, then the metric not calculated for
            % that cadence
            pdqTempStruct.meanBlack(missingCadence) = -1;
            pdqTempStruct.meanBlackUncertainties(missingCadence) = -1;

            %------------------------------------------------------------------
            % Step 4: apply black correction to all types of pixels
            %------------------------------------------------------------------

            pdqTempStruct = apply_black_correction_to_pixels(pdqTempStruct, missingCadence);

        end
    end
end

return