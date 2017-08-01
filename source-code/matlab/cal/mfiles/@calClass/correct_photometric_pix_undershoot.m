function [calObject, calIntermediateStruct, calTransformStruct] = ...
    correct_photometric_pix_undershoot(calObject, calIntermediateStruct, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     correct_photometric_pix_undershoot(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass method corrects for undershoot/overshoot artifacts caused by the LDE electronics chain.  Based on Ball tests, these
% artifacts can be modeled as a linear, shift-invariant (LSI) distortion (see notes by J.Jenkins in svn)
%
% The undershoot model is extracted from FC for all cadences, and an inverse filter is applied to the pixel rows of interest.
%
% additional notes from J.J.:
% The inverse filter may tend to correlate read noise after the distortion. The distortion does not alter the shot noise nor other ccd noise
% in image. To examine the effect of the inverse filtering on post-distortion additive noise, note that the filtering operation is linear so
% that the effective gain factor is the magnitude of the inverse filter's coeffts. 
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


% extract current module/output
ccdModule = calObject.ccdModule;
ccdOutput = calObject.ccdOutput;
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;
isAvailableFfiPix = calObject.dataFlags.isAvailableFfiPix;
enableFfiInform = calObject.moduleParametersStruct.enableFfiInform;

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamp    = cadenceTimes.timestamp;
numberOfExposures   = calIntermediateStruct.numberOfExposures;
nCadences           = calIntermediateStruct.nCadences;

% extract ccd row/col information for re-constructing pixel rows
nCcdColumns   = calIntermediateStruct.nCcdColumns;
ccdColumns   = (1:nCcdColumns)';

% create the undershoot object
undershootObject = undershootClass(calObject.undershootModel);

% get the coefficients of the undershoot filter
undershootCoeffts = get_undershoot_CAL(undershootObject, timestamp, ccdModule, ccdOutput);

% get pixels and indices
photometricPixels  = calIntermediateStruct.photometricPixels;       % nPixels x nCadences  double
photometricGaps    = calIntermediateStruct.photometricGaps;         % nPixels x nCadences logical
photometricRows    = calIntermediateStruct.photometricRows;         % nPixels x 1
photometricColumns = calIntermediateStruct.photometricColumns;      % nPixels x 1
nPixels = length(photometricColumns);
rowsNotCorrected = -1*ones(nPixels, nCadences);

% get needed parameters for partial ffi data
if isAvailableFfiPix && enableFfiInform
    ffiTimestamps = [calIntermediateStruct.ffiStruct.timestamp];
    numFfiReads = calIntermediateStruct.numberOfExposuresFfi;
    nFfis = length(calIntermediateStruct.ffiStruct);
end


for cadenceIndex = 1:nCadences

    % correct only for cadences with valid pixels
    missingPhotometricCadences = calIntermediateStruct.missingPhotometricCadences;

    if isempty(missingPhotometricCadences) || (~isempty(missingPhotometricCadences) && ~any(ismember(missingPhotometricCadences, cadenceIndex)))

        validPixelIndicators = ~photometricGaps(:, cadenceIndex);
        pixelValuesToCorrect = photometricPixels(validPixelIndicators, cadenceIndex);

        if isempty(pixelValuesToCorrect) || length(pixelValuesToCorrect) < 2
            warning('CAL:correct_photometric_pix_undershoot:NoValidData', ...
                ['Less than two valid pixels are available; cannot perform undershoot correction for cadence = ' num2str(cadenceIndex)]);

            % POU: Disable transformations
            % disableLevel = 3 --> transformation = I for both x and Cx
            disableLevel = 3;
            linearColumns = ccdColumns;
            validLinearIndex = ccdColumns;
            validLinearColumns = ccdColumns;

        else

            % POU: Operate on underlying data only
            % disableLevel = 1 --> transformation = I for Cx
            disableLevel = 1;

            pixelRowsToCorrect    = photometricRows(validPixelIndicators);
            pixelColumnsToCorrect = photometricColumns(validPixelIndicators);

            uniqueValidRows = unique(pixelRowsToCorrect(:, 1));
            numValidRows    = length(uniqueValidRows);

            % POU: Make linear column index from unique rows list
            [uniqueRows, ~, iUniqueRows] = unique(photometricRows);
            linearColumns = (iUniqueRows - 1) .* nCcdColumns + photometricColumns;

            % POU: Define range of linear columns to interpolate over
            totalInterpColumns = nCcdColumns * length(uniqueRows);

            % POU: Find unique Row-Column pairs
            RC = [photometricRows(:), photometricColumns(:)];
            [~, iRC] = unique(RC,'rows');

            % POU: Valid linear columns are those which are not gapped and are unique
            validColIndicators = false(size(validPixelIndicators));
            validColIndicators(iRC) = true;
            validColIndicators = validColIndicators & validPixelIndicators;

            % POU: define validLinearColumns and its index into linearColumns
            validLinearColumns = linearColumns(validColIndicators);
            validLinearIndex   = find(validColIndicators);

            % loop over unique rows
            for rowIndex = 1:numValidRows
                
                % select row
                pixelRow = uniqueValidRows(rowIndex);
                
                % initialize logical
                interpFfiAvailable = false;
                
                if isAvailableFfiPix && enableFfiInform
                    
                    % initialize
                    ffiData = zeros(nFfis,nCcdColumns);
                    ffiValid = false(nFfis,1);
                    
                    % extract correct row data from ffis and normalize per read
                    for iFfi = 1:nFfis
                        rowLogical = calIntermediateStruct.ffiStruct(iFfi).rows == pixelRow;
                        if any(rowLogical)
                            ffiData(iFfi,:) = calIntermediateStruct.ffiStruct(iFfi).image(:,rowLogical)' ./ numFfiReads(iFfi);
                        	ffiValid(iFfi) = true;                            
                        end
                    end
                    
                    if any(ffiValid)
                        % interpolate if more than 1 valid ffi
                        if numel(find(ffiValid)) > 1
                            % use nearest neighbor interpolation onto cadence timestamp
                            ffiInterpRow = interp1(ffiTimestamps(ffiValid), ffiData(ffiValid,:), timestamp(cadenceIndex), 'nearest', 'extrap');
                        else
                            % use the only ffi row available
                            ffiInterpRow = ffiData(ffiValid,:);
                        end

                        % scale data up for number of reads for current cadence type and make column vector
                        ffiInterpRow = ffiInterpRow' .* numberOfExposures;

                        % set flag
                        interpFfiAvailable = true;
                    else
                        % throw warning if can't fill row with ffi data
                        warnId = 'CAL:correct_photometric_pix_undershoot:NoValidFfiData';
                        warnMsg = 'Rows not filled with ffi data for undershoot. Will use linear interpolation.';
                        warning( warnId, warnMsg );
                    end
                end

                % grab pixel values for this row
                pixelValuesInRow = pixelValuesToCorrect(pixelRowsToCorrect == pixelRow);

                % check to ensure there are enough pixels in row for interpolation or the ffi row is available
                if interpFfiAvailable || (~isempty(pixelValuesInRow) && length(pixelValuesInRow) >= 2)

                    pixelCols = pixelColumnsToCorrect(pixelRowsToCorrect == pixelRow);

                    % get unique columns, in case there is overlap with background and target pixels
                    [uniquePixelCols, indexIntoPixelCols] =  unique(pixelCols);
                    
                    
                    if interpFfiAvailable
                        % use ffi data to fill gaps
                        % find bias from common columns
                        if length(pixelValuesInRow) > 2
                            bias = robust_mean_std(ffiInterpRow(uniquePixelCols) - pixelValuesInRow(indexIntoPixelCols));
                        else
                            bias = mean(pixelValuesInRow);
                        end
                        
                        % remove bias from ffi iterp row and set up input for filter
                        entireRowInterp = ffiInterpRow - bias;
                        
                        % substitute ungapped pixel values
                        entireRowInterp(uniquePixelCols) = pixelValuesInRow(indexIntoPixelCols);
                    else
                        % interpolate cadence data to fill gaps
                        % this clips the columns to range of populated ones
                        interpColumns = max(min(ccdColumns, max(uniquePixelCols)), min(uniquePixelCols));
                        interpColumns = interpColumns(:);
                        entireRowInterp = interp1(uniquePixelCols, pixelValuesInRow(indexIntoPixelCols), interpColumns, 'linear');
                    end

                    
                    % apply undershoot correction filter to row
                    undershootCorrectedRow = filter(1, undershootCoeffts(cadenceIndex, :), entireRowInterp);    % 1132 x 1

                    % save the undershoot corrected pixels
                    correctedPixelValues = undershootCorrectedRow(pixelCols);

                    pixelValuesToCorrect(pixelRowsToCorrect == pixelRow) = correctedPixelValues;

                else
                    % record rows with too few pixels to perform correction
                    rowsNotCorrected(rowIndex, cadenceIndex) = pixelRow;
                end

            end

            % save the undershoot corrected pixels
            photometricPixels(validPixelIndicators, cadenceIndex) = pixelValuesToCorrect;
            rowsNotCorrectedThisCadence = rowsNotCorrected(rowsNotCorrected(:, cadenceIndex) ~= -1, cadenceIndex);
            rowsNotCorrectedThisCadence = unique(rowsNotCorrectedThisCadence);

            if ~isempty(rowsNotCorrectedThisCadence)
                warnId = 'CAL:correct_photometric_pix_undershoot:NoValidData';
                warnMsg = ['Rows not corrected for undershoot due to lack of sufficient number pixels  ',...
                    mat2str(rowsNotCorrectedThisCadence(:)')];
                [lastMsg, lastId] = lastwarn;

                % throw warning if not dulplicate of last
                if( ~strcmpi(warnId,lastId) && ~strcmpi(warnMsg, lastMsg) )
                    warning( warnId, warnMsg );
                end
            end
        end

        if pouEnabled
            % get transformStruct for this cadence
            tStruct = calTransformStruct(:,cadenceIndex);

            % select valid indices
            tStruct = append_transformation(tStruct, 'selectIndex', calIntermediateStruct.pixelVariableName,...
                disableLevel, validLinearIndex);

            % interpolate on linear index - store interpolated indices
            % as eval string to save space - this is not quite the same
            % interpolated value set used in the body of CAL above
            tStruct = append_transformation(tStruct, 'interpLinear', calIntermediateStruct.pixelVariableName,...
                disableLevel, validLinearColumns, ['(1:',num2str(totalInterpColumns),')']);

            % pixels =  filter(b, a, pixels)  --> type 'filter'
            tStruct = append_transformation(tStruct, 'filter', calIntermediateStruct.pixelVariableName,...
                disableLevel, 1, undershootCoeffts(cadenceIndex, :));

            % select original total indices from interpolated result
            tStruct = append_transformation(tStruct, 'selectIndex', calIntermediateStruct.pixelVariableName,...
                disableLevel, linearColumns);

            % copy  shorter temporary structure into calTransformStruct
            calTransformStruct(:,cadenceIndex) = tStruct;
        end
    end
end

% save to intermediate struct
calIntermediateStruct.photometricPixels = photometricPixels;


return;
