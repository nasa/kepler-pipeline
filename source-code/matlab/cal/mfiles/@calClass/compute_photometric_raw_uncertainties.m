function [calObject, calIntermediateStruct, calTransformStruct] = ...
    compute_photometric_raw_uncertainties(calObject, calIntermediateStruct, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     compute_photometric_raw_uncertainties(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass object computes the raw photometric pixels uncertainties from the read noise, quantization noise, and pixel shot noise.
% Uncertainty structures in calTransformStruct and calIntermediateStruct are updated with primitive uncertainties.
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

% Define constant for gaps in requant table lookup
NAN_VALUE = -1;

% get flags
debugLevel = calObject.debugLevel;
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamp    = cadenceTimes.timestamp;
nCadences    = length(timestamp);

% get scale factor for long or short cadence collateral pixels
numberOfExposures = calIntermediateStruct.numberOfExposures;

% get the gain
gain = calIntermediateStruct.gain;   % nCadences x 1, or scalar

% get the read noise
readNoiseInADU = calIntermediateStruct.readNoiseInADU;   % nCadences x 1, or scalar

% compute read noise squared
readNoiseSquared = readNoiseInADU.^2;

% Add quantization noise from 14-bit ADC
originalQuantizationNoiseSquaredInADU = 1/12; % 1/12 is the variance of a unit-wide uniform random process
readNoiseSquared = readNoiseSquared + originalQuantizationNoiseSquaredInADU;

% scale readNoise for pixels based on number of exposures per cadence
readNoiseSquaredForPhotometricPixels = readNoiseSquared.*numberOfExposures;

% extract requantization tables (used to find quantization step size in ADU)
requantTables = calObject.requantTables;

%--------------------------------------------------------------------------
% extract calibrated and raw photometric pixels and gap arrays
%--------------------------------------------------------------------------
% extract calibrated pixels to compute shot noise
photometricPixels   = calIntermediateStruct.photometricPixels;        % nPixels x nCadences
photometricGaps     = calIntermediateStruct.photometricGaps;          % nPixels x nCadences logical
photometricRows     = calIntermediateStruct.photometricRows;          %#ok<NASGU> % nPixels x 1
photometricColumns  = calIntermediateStruct.photometricColumns;       %#ok<NASGU> % nPixels x 1
nPixels = size(photometricPixels,1);

% extract *raw* pixels to find quantization step size
photometricRawPixels  = [calObject.targetAndBkgPixels.values]';
photometricRawGaps    = [calObject.targetAndBkgPixels.gapIndicators]';
photometricRawRows    = [calObject.targetAndBkgPixels.row]';          %#ok<NASGU>
photometricRawColumns = [calObject.targetAndBkgPixels.column]';       %#ok<NASGU>

% set gaps to -1 for requant table lookup
photometricRawPixels(photometricRawGaps == 1) = NAN_VALUE;

% compute raw photometric uncertainties for each cadence if pixels are available
tic
lastDuration = 0;
for cadenceIndex = 1:nCadences

    % initialize deltaRawPhotometric vector to all zeros
    deltaRawPhotometric = zeros(nPixels,1);

    % compute only for cadences with valid pixels
    missingPhotometricCadences = calIntermediateStruct.missingPhotometricCadences;

    if isempty(missingPhotometricCadences) || (~isempty(missingPhotometricCadences) && ~any(ismember(missingPhotometricCadences, cadenceIndex)))

        %----------------------------------------------------------------------
        % masked smear pixel uncertainties
        %----------------------------------------------------------------------
        validPhotometricPixelIndicators = ~photometricGaps(:, cadenceIndex);

        % compute if pixels are available for this cadence
        if ~isempty(validPhotometricPixelIndicators)

            %------------------------------------------------------------------
            % compute the quant noise squared for photometricRawPixels
            %------------------------------------------------------------------
            if (calObject.cadenceTimes.requantEnabled(cadenceIndex))

                quantizationStepSizeInADU = ...
                    get_quant_step_size(requantTables, photometricRawPixels, cadenceTimes, cadenceIndex);
            else
                quantizationStepSizeInADU = 0;
            end

            % compute the quant noise squared (see KADN-26081 for the factor of 12 discussion)
            quantizationNoiseSquared = quantizationStepSizeInADU.^2 ./ 12;

            %------------------------------------------------------------------
            % compute the shot noise squared in ADU
            %------------------------------------------------------------------
            if numel(gain) > 1
                gain = gain(cadenceIndex);
            end
            shotNoiseSquaredForPhotometric = photometricPixels(:, cadenceIndex)./ gain.^2;

            %------------------------------------------------------------------
            % compute deltaRawPhotometric: add read noise, quantization noise, and
            % shot noise in quadrature
            %------------------------------------------------------------------
            if numel(readNoiseSquaredForPhotometricPixels) > 1
                readNoiseSquaredForPhotometricPixels = readNoiseSquaredForPhotometricPixels(cadenceIndex);
            end

            deltaRawPhotometric = sqrt(readNoiseSquaredForPhotometricPixels + quantizationNoiseSquared + shotNoiseSquaredForPhotometric);

        end

        duration = toc;
        if debugLevel && duration > 10+lastDuration
            lastDuration = duration;
            display(['CAL:compute_photometric_raw_uncertainties: raw photometric pixel uncertainties computed for cadence = '...
                num2str(cadenceIndex) '   cumulative duration: ' num2str(duration/60) ' minutes']);
        end
    end
    
    % save in uncertainty structure
    if ~pouEnabled
        calIntermediateStruct.photometricUncertaintyStruct(cadenceIndex).deltaRawPhotometric = deltaRawPhotometric;
    else
        % save the transformation for this cadence
        tStruct = calTransformStruct(:,cadenceIndex);
        
        % update tStruct with calibratedPixels# primitive variance
        tStruct = replace_primitive_data(tStruct,calIntermediateStruct.pixelVariableName,...
            {},deltaRawPhotometric.^2,{});
        
        % copy  shorter temporary structure into calTransformStruct
        calTransformStruct(:,cadenceIndex) = tStruct;
    end
    
end


return;
