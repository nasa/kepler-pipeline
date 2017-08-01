function [calObject, calIntermediateStruct, calTransformStruct] = ...
    correct_photometric_pix_flat_field(calObject, calIntermediateStruct, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     correct_photometric_pix_flat_field(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass method corrects pixels for flat field on a per cadence basis.  The flat field correction is extracted from FC, and the
% pixels have already been black corrected, averaged, and corrected for nonlinearity, gain, undershoot, smear, and dark current. Although
% the uncertainties in the flat field model are available, they are essentially a bias term when propagating errors, and are therefore
% neglected in the CAL pipeline (see KADN-26185).  An uncertainty structure may be output, however, if the debugLevel is set to 3.
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

% hard coded limit factor
JTfactor = 4;

% extract flags
isAvailableTargetAndBkgPix = calObject.dataFlags.isAvailableTargetAndBkgPix;
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamp    = cadenceTimes.timestamp;
nCadences    = length(timestamp);

% retrieve flat field model from object
flatFieldModel  = calObject.flatFieldModel;
photometricRows    = calIntermediateStruct.photometricRows;                     %nPixels x 1
photometricColumns = calIntermediateStruct.photometricColumns;                  %nPixels x 1

% create the flat field object with specified 0-based rows/columns
flatFieldModel.rows = photometricRows - 1;
flatFieldModel.columns = photometricColumns - 1;
flatFieldObject = flatFieldClass(flatFieldModel);


if isAvailableTargetAndBkgPix

    % loop over cadences, get flat field array on per cadence basis
    for cadenceIndex = 1:nCadences

        % correct only for cadences with valid pixels
        missingPhotometricCadences = calIntermediateStruct.missingPhotometricCadences;

        if isempty(missingPhotometricCadences) || (~isempty(missingPhotometricCadences) && ~any(ismember(missingPhotometricCadences, cadenceIndex)))

            %------------------------------------------------------------------
            % extract photometric pixels for this cadence, which have already
            % been black corrected, averaged, and corrected for nonlinearity,
            % gain, undershoot, smear, and dark
            %------------------------------------------------------------------
            photometricPixels  = calIntermediateStruct.photometricPixels(:, cadenceIndex);   %nPixels x nCadences
            photometricGaps    = calIntermediateStruct.photometricGaps(:, cadenceIndex);     %nPixels x nCadences            

            % logical array of valid pixel indices:
            validPhotometricPixelIndicators = ~photometricGaps; %nPixels x nCadences

            % calibrate pixels for flat field
            if ~isempty(validPhotometricPixelIndicators)

                % pixel array to correct
                pixelArrayToCorrect = photometricPixels(validPhotometricPixelIndicators);

                % get subset of flat field model
                validRows = photometricRows(validPhotometricPixelIndicators);
                validColumns = photometricColumns(validPhotometricPixelIndicators);

                % extract flat field model from FC for this cadence and input
                % row/col subset
                flatFieldArrayValidIdx = get_flat_field(flatFieldObject, timestamp(cadenceIndex), validRows, validColumns);

                % clip zero-values and also unreasonably high entries
                flatFieldArrayValidIdx(flatFieldArrayValidIdx <= 1/JTfactor) = 1/JTfactor;
                flatFieldArrayValidIdx(flatFieldArrayValidIdx >= JTfactor)   = JTfactor;

                % use full array (not just valid indices) for transform storage
                fullFlatFieldArray = get_flat_field(flatFieldObject, timestamp(cadenceIndex), photometricRows, photometricColumns);

                % clip zero-values and also unreasonably high entries
                fullFlatFieldArray(fullFlatFieldArray <= 1/JTfactor) = 1/JTfactor;
                fullFlatFieldArray(fullFlatFieldArray >= JTfactor)   = JTfactor;

                % correct pixels for flat field
                calIntermediateStruct.photometricPixels(validPhotometricPixelIndicators, cadenceIndex) = pixelArrayToCorrect ./ flatFieldArrayValidIdx;

                % propagate uncertainties
                if pouEnabled
                    % save the flat field transformation:
                    % calibratedPixels = calibratedPixels ./ flatField
                    varName = calIntermediateStruct.pixelVariableName;
                    disableLevel = 0;
                    tStruct = calTransformStruct(:,cadenceIndex);
                    tStruct = append_transformation(tStruct, 'scaleV', varName , disableLevel, 1./fullFlatFieldArray);
                    calTransformStruct(:,cadenceIndex) = tStruct;
                end
            end
        end
    end
end

return;
