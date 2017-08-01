function [calObject, calIntermediateStruct, calTransformStruct] = ...
    compute_collateral_raw_smear_uncertainties(calObject, calIntermediateStruct, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     compute_collateral_raw_smear_uncertainties(calObject, calIntermediateStruct, calTransformStruct)
%
% This function computes the raw masked and raw virtual smear pixels uncertainties
% for all cadences of a module/output
%
% The raw pixel uncertainties are computed from the read noise, shot noise,
% and quantization step size
%
% INPUT:
%   calObject
%   calIntermediateStruct
%
% OUTPUT:
%  calObject
%  calIntermediateStruct: including the following uncertainties
%       smearUncertaintyStruct.deltaRawMsmear
%       smearUncertaintyStruct.deltaRawVsmear
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


debugLevel = calObject.debugLevel;
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;

% Define constant for gaps in requant table lookup
NAN_VALUE = -1;

% extract flags to determine if long or short cadence pixels are to be processed
processLongCadence = calObject.dataFlags.processLongCadence;
isAvailableMaskedSmearPix = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix = calObject.dataFlags.isAvailableVirtualSmearPix;

% extractnumber of ccd columns
nCcdColumns  = calIntermediateStruct.nCcdColumns;

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamp = cadenceTimes.timestamp;
nCadences = length(timestamp);

% get config map parameters
numberOfMaskedSmearRows  = calIntermediateStruct.numberOfMaskedSmearRows;
numberOfVirtualSmearRows = calIntermediateStruct.numberOfVirtualSmearRows;
numberOfExposures = calIntermediateStruct.numberOfExposures;


% get the gain and read noise
gain = calIntermediateStruct.gain;   % nCadences x 1, or scalar
readNoiseInADU = calIntermediateStruct.readNoiseInADU;   % nCadences x 1, or scalar

% compute read noise squared
readNoiseSquared = readNoiseInADU.^2;

% Add quantization noise from 14-bit ADC
originalQuantizationNoiseSquaredInADU = 1/12; % 1/12 is the variance of a unit-wide uniform random process
readNoiseSquared = readNoiseSquared + originalQuantizationNoiseSquaredInADU;

% extract requantization flag
requantEnabled = calObject.cadenceTimes.requantEnabled;  % nCadences x 1

%--------------------------------------------------------------------------
% scale read noise for smear pixels based on number of exposures per cadence
% and number of smear rows in each measurement
readNoiseSquaredForMaskedSmearPixels = readNoiseSquared.*numberOfMaskedSmearRows.*numberOfExposures;
readNoiseSquaredForVirtualSmearPixels = readNoiseSquared.*numberOfVirtualSmearRows.*numberOfExposures;

%--------------------------------------------------------------------------
% extract masked and virtual pixels and gap arrays

if isAvailableMaskedSmearPix
    % extract calibrated pixels to compute shot noise
    mSmearPixels = calIntermediateStruct.mSmearPixels;    % nCcdColumns x nCadences
    mSmearGaps = calIntermediateStruct.mSmearGaps;        % nCcdColumns x nCadences

    % extract *raw* masked smear pixels to find quantization step size
    mSmearRawPixels = [calObject.maskedSmearPixels.values]';  % nValidPixels (before bleeding cols removed) x nCadences
    mSmearRawColumns = [calObject.maskedSmearPixels.column]'; % nValidPixels (before bleeding cols removed) x 1

    % set gaps to -1 for requant table lookup (use mSmearGaps rather
    % than mSmearRawGaps in order to exclude bleeding columns)
    updatedMsmearGaps = mSmearGaps(mSmearRawColumns, :);

    mSmearRawPixels(updatedMsmearGaps) = NAN_VALUE;
else
    mSmearRawPixels = [];
end

if isAvailableVirtualSmearPix
    % extract calibrated pixels to compute shot noise
    vSmearPixels = calIntermediateStruct.vSmearPixels;    % nCcdColumns x nCadences
    vSmearGaps = calIntermediateStruct.vSmearGaps;        % nCcdColumns x nCadences

    % extract *raw* virtual smear pixels to find quantization step size
    vSmearRawPixels = [calObject.virtualSmearPixels.values]';  % nValidPixels (before bleeding cols removed) x nCadences
    vSmearRawColumns = [calObject.virtualSmearPixels.column]'; % nValidPixels (before bleeding cols removed) x 1

    % set gaps to -1 for requant table lookup (use vSmearGaps rather
    % than vSmearRawGaps in order to exclude bleeding columns)
    updatedVsmearGaps = vSmearGaps(vSmearRawColumns, :);

    vSmearRawPixels(updatedVsmearGaps) = NAN_VALUE;
else
    vSmearRawPixels = [];
end

% extract requantization tables (used to find quantization step size in ADU)
requantTables = calObject.requantTables;

% % track darkLevelEstimate covariance gaps
% darkLevelGapFlag = false(nCadences,1);

%--------------------------------------------------------------------------
% compute raw smear uncertainties for each cadence where pixels are available
tic
lastDuration = 0;

for cadenceIndex = 1:nCadences

    % initialize smear uncertainties
    if pouEnabled
        % copy calTransformStruct into shorter temporary structure
        tStruct = calTransformStruct(:,cadenceIndex);        
    else
        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).deltaRawMsmear = zeros(nCcdColumns,1);
        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).deltaRawVsmear = zeros(nCcdColumns,1);
    end

    %----------------------------------------------------------------------
    % masked smear pixel uncertainties
    %----------------------------------------------------------------------
    validRawMsmearPixelIndicators = ~updatedMsmearGaps(:, cadenceIndex);

    % compute if pixels are available for this cadence
    if isAvailableMaskedSmearPix
        
        % preallocate to full ccd columns (1132 x 1)
        deltaRawMsmearFullArray = zeros(nCcdColumns, 1);  %1132 x 1
        
        if any(validRawMsmearPixelIndicators)
            
            if numel(numberOfMaskedSmearRows) > 1
                numberOfMaskedSmearRows = numberOfMaskedSmearRows(cadenceIndex);
            end
            
            % drop bleeding columns to keep arrays consistent in size
            mSmearRawPixelArray = mSmearRawPixels(validRawMsmearPixelIndicators, :);
            mSmearRawColumnArray = mSmearRawColumns(validRawMsmearPixelIndicators);
            
            %------------------------------------------------------------------
            % compute the quant noise squared for mSmearRawPixels
            %------------------------------------------------------------------
            if requantEnabled(cadenceIndex)
                quantizationStepSizeInADU = get_quant_step_size(requantTables, mSmearRawPixelArray, cadenceTimes, cadenceIndex);
            else
                quantizationStepSizeInADU = 0;
            end
            
            % compute the quant noise squared (see KADN-26081 for the factor of 12 discussion)
            quantizationNoiseSquared = (quantizationStepSizeInADU.^2 ./ 12);
            
            %------------------------------------------------------------------
            % compute the shot noise squared in ADU, which should be calculated
            % for all calibrated pixels that were spatially coadded onboard spacecraft
            %------------------------------------------------------------------
            if numel(gain) > 1
                gain = gain(cadenceIndex);
            end
            
            % KSOC-5120
            % Looks like we are combing quantizationNoiseSquared (in 'raw' indices) with readNoiseSquaredForMaskedSmearPixels and
            % shotNoiseSquaredForMsmear (in sequential indices). Then later, deltaRawMsmear is assumed to be in 'raw' indices as it is read into
            % sequentially indexed deltaRawMsmearFullArray but actually, deltaRawMsmear is a mix of raw and sequential indices. The fix is to
            % make deltaRawMsmear in raw indices by converting readNoiseSquaredForMaskedSmearPixels and shotNoiseSquaredForMsmear into raw
            % indices before combining. Read noise is the same for all pixels so the only adjustment is to the shot noise component.
            
            % Use 'raw' indexed pixels to make shotNoiseSquaredForMsmear
            shotNoiseSquaredForMsmear = mSmearPixels(mSmearRawColumnArray, cadenceIndex) .* numberOfMaskedSmearRows ./(gain.^2);
            
            %------------------------------------------------------------------
            % compute deltaRawMsmear: add read noise, quantization noise, and
            % shot noise in quadrature
            %------------------------------------------------------------------
            if numel(readNoiseSquaredForMaskedSmearPixels) > 1
                readNoiseSquaredForMaskedSmearPixels = readNoiseSquaredForMaskedSmearPixels(cadenceIndex);
            end
            
            deltaRawMsmear = sqrt(readNoiseSquaredForMaskedSmearPixels + quantizationNoiseSquared + shotNoiseSquaredForMsmear);
            
            % renormalize raw uncertainties by number of spatial coadds
            deltaRawMsmear = deltaRawMsmear ./ numberOfMaskedSmearRows;
                        
            % fill in valid delta values into valid columns
            deltaRawMsmearFullArray(mSmearRawColumnArray) = deltaRawMsmear;
        end

        if processLongCadence

            % save in uncertainty structure
            if pouEnabled
                % update tStruct with mSmearEstimate primitive variance
                tStruct = replace_primitive_data(tStruct,'mSmearEstimate',{},deltaRawMsmearFullArray.^2,{});                
            else
                calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).deltaRawMsmear = deltaRawMsmearFullArray;
            end
        else
            % save as sparse array
            deltaRawMsmearSparseArray = sparse(deltaRawMsmearFullArray);

            % save in uncertainty structure
            if pouEnabled
                % update tStruct with mSmearEstimate primitive variance
                tStruct = replace_primitive_data(tStruct,'mSmearEstimate',{}, full(deltaRawMsmearSparseArray).^2,{});                
            else
                calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).deltaRawMsmear = deltaRawMsmearSparseArray;
            end
        end
    end


    %----------------------------------------------------------------------
    % virtual smear pixel uncertainties
    %----------------------------------------------------------------------
    validRawVsmearPixelIndicators = ~updatedVsmearGaps(:, cadenceIndex);

    % compute if pixels are available for this cadence
    if isAvailableVirtualSmearPix
        
        % preallocate to full ccd columns (1132 x 1)
        deltaRawVsmearFullArray = zeros(nCcdColumns, 1);  %1132 x 1        
        
        if any(validRawVsmearPixelIndicators)

            if numel(numberOfVirtualSmearRows) > 1
                numberOfVirtualSmearRows = numberOfVirtualSmearRows(cadenceIndex);
            end

            % drop bleeding columns to keep arrays consistent in size
            vSmearRawPixelArray = vSmearRawPixels(validRawVsmearPixelIndicators, :);
            vSmearRawColumnArray = vSmearRawColumns(validRawVsmearPixelIndicators);

            %------------------------------------------------------------------
            % compute the quant noise squared for vSmearRawPixels
            %------------------------------------------------------------------
            if requantEnabled(cadenceIndex)
                quantizationStepSizeInADU = get_quant_step_size(requantTables, vSmearRawPixelArray, cadenceTimes, cadenceIndex);
            else
                quantizationStepSizeInADU = 0;
            end

            % compute the quant noise squared (see KADN-26081 for the factor of 12 discussion)
            quantizationNoiseSquared = (quantizationStepSizeInADU.^2 ./ 12);

            %------------------------------------------------------------------
            % compute the shot noise squared in ADU, which should be calculated
            % for all calibrated (black, linearity, and undershoot corrected)
            % pixels that were spatially coadded onboard spacecraft
            %------------------------------------------------------------------
            if numel(gain) > 1
                gain = gain(cadenceIndex);
            end

            % KSOC-5120
            % Looks like we are combing quantizationNoiseSquared (in 'raw' indices) with readNoiseSquaredForVirtualSmearPixels and
            % shotNoiseSquaredForVsmear (in sequential indices). Then later, deltaRawVsmear is assumed to be in 'raw' indices as it is read into
            % sequentially indexed deltaRawVsmearFullArray but actually, deltaRawVsmear is a mix of raw and sequential indices. The fix is to
            % make deltaRawVsmear in raw indices by converting readNoiseSquaredForVirtualSmearPixels and shotNoiseSquaredForVsmear into raw
            % indices before combining. Read noise is the same for all pixels so the only adjustment is to the shot noise component.        

            % Use 'raw' indexed pixels to make shotNoiseSquaredForVsmear
            shotNoiseSquaredForVsmear = vSmearPixels(vSmearRawColumnArray, cadenceIndex) .* numberOfVirtualSmearRows ./(gain.^2);

            %------------------------------------------------------------------
            % compute deltaRawVsmear: add read noise, quantization noise, and
            % shot noise in quadrature
            %------------------------------------------------------------------
            if numel(readNoiseSquaredForVirtualSmearPixels) > 1
                readNoiseSquaredForVirtualSmearPixels = readNoiseSquaredForVirtualSmearPixels(cadenceIndex);
            end

            deltaRawVsmear = sqrt(readNoiseSquaredForVirtualSmearPixels + quantizationNoiseSquared + shotNoiseSquaredForVsmear);

            % renormalize raw uncertainties by number of spatial coadds
            deltaRawVsmear = deltaRawVsmear ./ numberOfVirtualSmearRows;

            % fill in valid delta values into valid columns
            deltaRawVsmearFullArray(vSmearRawColumnArray) = deltaRawVsmear;
        end

        if processLongCadence

            % save in uncertainty structure
            if pouEnabled
                % update tStruct with vSmearEstimate primitive variance
                tStruct = replace_primitive_data(tStruct,'vSmearEstimate',{},deltaRawVsmearFullArray.^2,{});                
            else
                calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).deltaRawVsmear = deltaRawVsmearFullArray;
            end

        else
            % save as sparse array
            deltaRawVsmearSparseArray = sparse(deltaRawVsmearFullArray);

            % save in uncertainty structure
            if pouEnabled
                % update tStruct with vSmearEstimate primitive variance
                tStruct = replace_primitive_data(tStruct,'vSmearEstimate',{}, full(deltaRawVsmearSparseArray).^2,{});                
            else
                calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).deltaRawVsmear = deltaRawVsmearSparseArray;
            end

        end
    end

    if pouEnabled
%         % check for unfilled gaps in darkLevelEstimate and set flag
%         
% %         % check for gap in darkLevelEstimate covariance on this cadence
% %         % if primitive data (x) is numeric then this is a filled gap and the
% %         % covariance must be calculated and filled.
%         
%         idx = iserrorPropStructVariable(tStruct,'darkLevelEstimate');
%         darkLevelGapFlag(cadenceIndex) = tStruct(idx).cadenceGapped && ~tStruct(idx).cadenceGapFilled;
%         
% %         if tStruct(idx).cadenceGapped && ~tStruct(idx).cadenceGapFilled
% %             darkLevelGapFlag(cadenceIndex) = true;
% %         end
%         
% %         x = get_primitive_data(tStruct,'darkLevelEstimate');
% %         if(isnumeric(x))
% %             darkLevelGapFlag(cadenceIndex) = true;
% %         end
% 
        % copy shorter temporary structure into calTransformStruct
        calTransformStruct(:,cadenceIndex) = tStruct;
    end

    % update message to stdout
    duration = toc;
    if debugLevel && duration > 10 + lastDuration
        lastDuration = duration;
        display(['CAL:compute_collateral_raw_smear_uncertainties: raw smear pixel uncertainties computed for cadence = ',...
            num2str(cadenceIndex), '   cumulative duration: ', num2str(duration/60), ' minutes']);
    end
end

% if pouEnabled
%     % if any darkLevelEstimate entries are gapped, fill the gaps by linear interpolation of the value and variance
%     if any(darkLevelGapFlag)
%         
%         % preallocate space
%         dark = zeros(nCadences,1);
%         Cdark = dark;
% 
%         % fill in the ungapped values and covariance
%         for cadenceIndex = 1:nCadences
%             if ~darkLevelGapFlag(cadenceIndex)
%                 % get propagated data from the ungapped cadences
%                 [dark(cadenceIndex), Cdark(cadenceIndex)] =...
%                     cascade_transformations(calTransformStruct(:,cadenceIndex), 'darkLevelEstimate');
%             end
%         end
% 
%         % fill the gaps in Cdark by extrapolating avaiable variances
%         darkLevelAvailableCadences = find(darkLevelGapFlag ~= 1);
%         darkLevelGappedCadences = find(darkLevelGapFlag == 1);        
%         dark = interp1(darkLevelAvailableCadences, dark(darkLevelAvailableCadences),...
%             (1:nCadences)', 'linear', 'extrap', 'nearest');
%         Cdark = interp1(darkLevelAvailableCadences, Cdark(darkLevelAvailableCadences),...
%             (1:nCadences)', 'linear', 'extrap', 'nearest');
% 
%         % load these gap filled values into calTransformStruct as primitive data
%         % set gapFilled flag for each entry
%         for i = 1:length(darkLevelGappedCadences)
%             calTransformStruct(:,darkLevelGappedCadences(i)) = ...
%                 replace_primitive_data(calTransformStruct(:,darkLevelGappedCadences(i)),...
%                 'darkLevelEstimate', dark(darkLevelGappedCadences(i)), Cdark(darkLevelGappedCadences(i)), {});
%         end
%     end
% end

return;
