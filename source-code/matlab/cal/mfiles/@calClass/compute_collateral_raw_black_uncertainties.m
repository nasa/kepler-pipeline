function [calObject, calIntermediateStruct, calTransformStruct] = ...
    compute_collateral_raw_black_uncertainties(calObject, calIntermediateStruct, calTransformStruct)
% function [calObject, calIntermediateStruct] = ...
%    compute_collateral_raw_black_uncertainties(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass method computes the uncertainties for the raw black pixels (the random variable/uncertainty associated with the measurement,
% in ADU for all cadences for current mod/out.  The raw pixel uncertainties are computed from the read noise and quantizaton step size.
%
% INPUT
%  calObject is a calClass object
%  calIntermediateStruct is a structure containing calibrated data at intermediate steps
%  calTransformStruct is a structure containing CAL transforms, primitive and meta data
%
% OUTPUT:
%  calObject is a calClass object:
%       (Note calObject is not modified within this method so there is really no reason to return it other than it is expected in the return
%       argument list when called from other CAL methods and function e.g. calibrate_collateral_data. The calObject was most likely altered
%       with this method in some previous version of the code and the output argument list and calls to this method were never updated when
%       that modification was removed. It does no harm to leave calObject in the output argument list.)
%  calIntermediateStruct is updated to include the following subfields:
%       blackUncertaintyStruct.deltaRawBlack
%       blackUncertaintyStruct.deltaRawMblack
%       blackUncertaintyStruct.deltaRawVblack
%  calTransformStruct
%       This structure is updated to include the black uncertainties on the black primitive data
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


tic;
debugLevel = calObject.debugLevel;

% define constant for gaps in requant table lookup
NAN_VALUE = -1;

% extract data flags
processLongCadence  = calObject.dataFlags.processLongCadence;
processShortCadence = calObject.dataFlags.processShortCadence;
dynamic2DBlackEnabled = calObject.dataFlags.dynamic2DBlackEnabled;
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;

% extract timestamp (mjds), number of exposures, nRows, nCadences
cadenceTimes = calObject.cadenceTimes;
numberOfExposures = calIntermediateStruct.numberOfExposures;
nCcdRows  = calIntermediateStruct.nCcdRows;
nCadences = calIntermediateStruct.nCadences;

% get the read noise
readNoiseInADU = calIntermediateStruct.readNoiseInADU;   % nCadences x 1, or scalar

% compute read noise squared
readNoiseSquared = readNoiseInADU.^2;

% add quantization noise from 14-bit ADC
originalQuantizationNoiseSquaredInADU = 1/12; % 1/12 is the variance of a unit-wide uniform random process
readNoiseSquared = readNoiseSquared + originalQuantizationNoiseSquaredInADU;

% scale readNoise for black pixels based on number of exposures per cadence and number of black columns in each measurement
numberOfBlackColumns = calIntermediateStruct.numberOfBlackColumns;
readNoiseSquaredForBlackPixels = readNoiseSquared.*numberOfBlackColumns.*numberOfExposures;
if processShortCadence
    numberOfMaskedBlackPixels  = calIntermediateStruct.numberOfMaskedBlackPixels;
    numberOfVirtualBlackPixels = calIntermediateStruct.numberOfVirtualBlackPixels;
    readNoiseSquaredForMaskedBlackPixels = readNoiseSquared.*numberOfMaskedBlackPixels.*numberOfExposures;
    readNoiseSquaredForVirtualBlackPixels = readNoiseSquared.*numberOfVirtualBlackPixels.*numberOfExposures;
end

%--------------------------------------------------------------------------
% extract the raw black pixels and gap arrays
%--------------------------------------------------------------------------

% logical flags for existence of black pixel types:
isAvailableBlackPix         = calObject.dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix   = calObject.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = calObject.dataFlags.isAvailableVirtualBlackPix;

if isAvailableBlackPix

    % extract *raw* pixels to find quantization step size
    blackRawPixels = [calObject.blackPixels.values]';
    blackRawGaps   = [calObject.blackPixels.gapIndicators]';
    blackRawRows   = [calObject.blackPixels.row]'; % may be subset of 1070 x 1

    % set gaps to -1 for requant table lookup
    blackRawPixels(blackRawGaps) = NAN_VALUE;
else
    blackRawPixels = [];
end

if processShortCadence
    if isAvailableMaskedBlackPix

        % extract *raw* pixels to find quantization step size
        mBlackRawPixels = [calObject.maskedBlackPixels.values];
        mBlackRawGaps   = [calObject.maskedBlackPixels.gapIndicators];

        % set gaps to -1 for requant table lookup
        mBlackRawPixels(mBlackRawGaps) = NAN_VALUE;
    else
        mBlackRawPixels = [];
    end

    if isAvailableVirtualBlackPix

        % extract *raw* pixels to find quantization step size
        vBlackRawPixels = [calObject.virtualBlackPixels.values];
        vBlackRawGaps   = [calObject.virtualBlackPixels.gapIndicators];

        % set gaps to -1 for requant table lookup
        vBlackRawPixels(vBlackRawGaps) = NAN_VALUE;
    else
        vBlackRawPixels = [];
    end
else
    mBlackRawPixels = [];
    vBlackRawPixels = [];
end

%--------------------------------------------------------------------------
% compute raw black uncertainties for each cadence if pixels are available
%--------------------------------------------------------------------------

% extract requantization tables (used to find quantization step size in ADU)
requantTables = calObject.requantTables;

lastDuration = 0;
tic

for cadenceIndex = 1:nCadences

    %------------------------------------------------------------------
    % check dimensions of configmap parameters
    %------------------------------------------------------------------
    if numel(numberOfBlackColumns) > 1
        numberOfBlackColumns = numberOfBlackColumns(cadenceIndex);
    end

    if processShortCadence && numel(numberOfMaskedBlackPixels) > 1
        numberOfMaskedBlackPixels = numberOfMaskedBlackPixels(cadenceIndex);
    end

    if processShortCadence && numel(numberOfVirtualBlackPixels) > 1
        numberOfVirtualBlackPixels = numberOfVirtualBlackPixels(cadenceIndex);
    end

    %------------------------------------------------------------------
    % initialize deltaRawBlack for full ccdRows
    %------------------------------------------------------------------
    if ~pouEnabled
        if processLongCadence
            calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).deltaRawBlack = zeros(nCcdRows,1);
        else
            calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).deltaRawBlack = sparse(zeros(nCcdRows,1));
        end
    end

    if isAvailableBlackPix

        %------------------------------------------------------------------
        % compute the quant noise squared for blackPixels
        %------------------------------------------------------------------
        if calObject.cadenceTimes.requantEnabled(cadenceIndex)

            quantizationStepSizeInADU = get_quant_step_size(requantTables, blackRawPixels, cadenceTimes, cadenceIndex);
        else
            quantizationStepSizeInADU = 0;
        end

        % compute the quant noise squared (see KADN-26081 for the factor of 12 discussion)
        quantizationNoiseSquared = quantizationStepSizeInADU.^2 ./ 12;

        %------------------------------------------------------------------
        % compute deltaRawBlack: add read noise and quantization noise in quadrature
        %------------------------------------------------------------------
        if numel(readNoiseSquaredForBlackPixels) > 1
            readNoiseSquaredForBlackPixels = readNoiseSquaredForBlackPixels(cadenceIndex);
        end

        deltaRawBlack = sqrt(readNoiseSquaredForBlackPixels + quantizationNoiseSquared);

        % account for the number of columns summed
        deltaRawBlack = deltaRawBlack / numberOfBlackColumns;

        % preallocate to full ccd rows (1070 x 1)
        if processLongCadence
            deltaRawBlackFullArray = zeros(nCcdRows, 1);
        else
            deltaRawBlackFullArray = sparse(nCcdRows, 1);
        end

        % fill in valid delta values into valid rows
        deltaRawBlackFullArray(blackRawRows) = deltaRawBlack;
        
        if pouEnabled
            
            % Start transformation chain for residualBlack with only the uncertainties (pixel values to be filled in later)
            tempPixels = zeros(size(deltaRawBlackFullArray));
            CblackPixels = deltaRawBlackFullArray.^2;
            gapList = [];

            calTransformStruct(:,cadenceIndex) = ...
                append_transformation(calTransformStruct(:,cadenceIndex), 'eye', 'residualBlack', [], tempPixels, CblackPixels, gapList,[],[]);
            
            % start bias term with dummy values
            if processShortCadence && dynamic2DBlackEnabled
                
                % bias for black pixels
                calTransformStruct(:,cadenceIndex) = ...
                    append_transformation(calTransformStruct(:,cadenceIndex), 'eye', 'fittedBlackBias', [], 0, 0 ,gapList,[],[]);
% -------------------------------------------
% See subtract_black2DModel_from_collateral_pixels.m for corresponding changes to POU                
%                
%                 % bias for mSmear pixels
%                 calTransformStruct(:,cadenceIndex) = ...
%                     append_transformation(calTransformStruct(:,cadenceIndex), 'eye', 'fittedMSmearBias', [], 0, 0 ,gapList,[],[]);
%                 % bias for vSmear pixels
%                 calTransformStruct(:,cadenceIndex) = ...
%                     append_transformation(calTransformStruct(:,cadenceIndex), 'eye', 'fittedVSmearBias', [], 0, 0 ,gapList,[],[]);
% -------------------------------------------
            end            
        else
            % save in uncertainty structure
            calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).deltaRawBlack = deltaRawBlackFullArray;
        end
    end


    if processShortCadence

        if ~pouEnabled            
            % intialize delta mBlack and vBlack to zero
            calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).deltaRawMblack = 0;
            calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).deltaRawVblack = 0;
        end

        if isAvailableMaskedBlackPix

            %------------------------------------------------------------------
            % compute the quant noise squared for mBlackPixels, which have
            % one value per cadence (input as row vector for quant step size)
            %------------------------------------------------------------------
            if calObject.cadenceTimes.requantEnabled(cadenceIndex)
                quantizationStepSizeInADU = get_quant_step_size(requantTables, mBlackRawPixels(:)', cadenceTimes, cadenceIndex);
            else
                quantizationStepSizeInADU = 0;
            end

            % compute the quant noise squared (see KADN-26081 for the factor of 12 discussion)
            quantizationNoiseSquared = (quantizationStepSizeInADU.^2 ./ 12);

            %------------------------------------------------------------------
            % compute deltaRawMblack: add read noise and quantization noise in quadrature
            %------------------------------------------------------------------
            if numel(readNoiseSquaredForMaskedBlackPixels) > 1
                readNoiseSquaredForMaskedBlackPixels = readNoiseSquaredForMaskedBlackPixels(cadenceIndex);
            end

            deltaRawMblack = sqrt(readNoiseSquaredForMaskedBlackPixels + quantizationNoiseSquared);

            % account for the number of rows and columns summed
            deltaRawMblack = deltaRawMblack / numberOfMaskedBlackPixels;
            
            if pouEnabled
                
                % Start transformation chain for residualBlack with only the uncertainties (pixel values to be filled in later)
                tempPixels = zeros(size(deltaRawMblack));
                CblackPixels = deltaRawMblack.^2;
                gapList = [];

                calTransformStruct(:,cadenceIndex) = ...
                    append_transformation(calTransformStruct(:,cadenceIndex), 'eye', 'mBlackEstimate', [], tempPixels, CblackPixels, gapList,[],[]);
% -------------------------------------------                
% See subtract_black2DModel_from_collateral_pixels.m for corresponding changes to POU                
%  
%                 if dynamic2DBlackEnabled
%                     % bias for mBlack pixels
%                     calTransformStruct(:,cadenceIndex) = ...
%                         append_transformation(calTransformStruct(:,cadenceIndex), 'eye', 'fittedMBlackBias', [], 0, 0 ,gapList,[],[]);
%                 end
% -------------------------------------------                
            else
                % save in uncertainty structure
                calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).deltaRawMblack = deltaRawMblack;
            end
        end

        if isAvailableVirtualBlackPix

            %------------------------------------------------------------------
            % compute the quant noise squared for vBlackPixels, which have
            % one value per cadence (input as row vector for quant step size)
            %------------------------------------------------------------------
            if calObject.cadenceTimes.requantEnabled(cadenceIndex)

                quantizationStepSizeInADU = get_quant_step_size(requantTables, ...
                    vBlackRawPixels(:)', cadenceTimes, cadenceIndex);
            else
                quantizationStepSizeInADU = 0;
            end

            % compute the quant noise squared (see KADN-26081 for the factor of 12 discussion)
            quantizationNoiseSquared = (quantizationStepSizeInADU.^2 ./ 12);


            %------------------------------------------------------------------
            % compute deltaRawVblack: add read noise and quantization noise in quadrature
            %------------------------------------------------------------------
            if numel(readNoiseSquaredForVirtualBlackPixels) > 1
                readNoiseSquaredForVirtualBlackPixels = readNoiseSquaredForVirtualBlackPixels(cadenceIndex);
            end

            deltaRawVblack = sqrt(readNoiseSquaredForVirtualBlackPixels + quantizationNoiseSquared);

            % account for the number of rows and columns summed
            deltaRawVblack = deltaRawVblack / numberOfVirtualBlackPixels;

            if pouEnabled
                
                % Start transformation chain for residualBlack with only the uncertainties (pixel values to be filled in later)
                tempPixels = zeros(size(deltaRawVblack));
                CblackPixels = deltaRawMblack.^2;
                gapList = [];

                calTransformStruct(:,cadenceIndex) = ...
                    append_transformation(calTransformStruct(:,cadenceIndex), 'eye', 'vBlackEstimate', [], tempPixels, CblackPixels, gapList,[],[]);
% -------------------------------------------                
% See subtract_black2DModel_from_collateral_pixels.m for corresponding changes to POU                
%                  
%                 if dynamic2DBlackEnabled
%                     % bias for vBlack pixels
%                     calTransformStruct(:,cadenceIndex) = ...
%                         append_transformation(calTransformStruct(:,cadenceIndex), 'eye', 'fittedVBlackBias', [], 0, 0 ,gapList,[],[]);
%                 end
% -------------------------------------------
            else            
                % save in uncertainty structure
                calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).deltaRawVblack = deltaRawVblack;
            end
        end
    end

    duration = toc;
    if debugLevel>=0 && duration > 10+lastDuration
        lastDuration = duration;
        display(['CAL:compute_collateral_raw_black_uncertainties: raw black pixel uncertainties computed for cadence = ',...
            num2str(cadenceIndex), ', cumulative duration: ', num2str(duration/60), ' minutes']);
    end
end

return;
