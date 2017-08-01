function [calObject, calIntermediateStruct, calTransformStruct] = correct_photometric_pix_black_level(calObject, calIntermediateStruct, calTransformStruct)
%function [calObject, calIntermediateStruct] = correct_photometric_pix_black_level(calObject, calIntermediateStruct)
%
% This calClass method corrects black level for photometric pixel data for each cadence on a module/output.  For each cadence, the following
% steps are performed: 
%   (1) Subtract 2D black on per cadence basis. If dynamic2DBlackEnabled = false, use static 2D black, otherwise use dynamic 2D black.
%   (2) If dynamic2DBlackEnabled = false, subtract black correction (which was computed in the first invocation of CAL)
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

% extract stuff from calClass object
debugLevel          = calObject.debugLevel;
pouEnabled          = calObject.pouModuleParametersStruct.pouEnabled;
enableFfiInform     = calObject.moduleParametersStruct.enableFfiInform;
stateFilePath       = calObject.localFilenames.stateFilePath;
cadenceTimes        = calObject.cadenceTimes;
timestamp           = cadenceTimes.timestamp;
nCadences           = length(timestamp);

dataFlags           = calObject.dataFlags;
processShortCadence = dataFlags.processShortCadence;
isAvailableFfiPix   = dataFlags.isAvailableFfiPix;
dynamic2DBlackEnabled = dataFlags.dynamic2DBlackEnabled;


%--------------------------------------------------------------------------
% extract all 2D black pixels
%--------------------------------------------------------------------------
if dynamic2DBlackEnabled
    
    display('CAL:correct_photometric_pix_black_level: Applying dynamic 2D black correction to photometric pixels.');
    
    % retrieve blacks  for these photometric pixels for all cadences
    [dynamicPhotometricTwoDBlackStruct, partialFfiTwoDBlackStruct] = ...
        retrieve_dynamic_2d_black_for_photometric_data(calObject, calIntermediateStruct);    
else
    
    display('CAL:correct_photometric_pix_black_level: Applying static 2D black correction to photometric pixels.');

    % extract 2D black model from cal object
    twoDBlackModel = calObject.twoDBlackModel;

    % create the 2D black object
    twoDBlackObject = twoDBlackClass(twoDBlackModel);

    clear twoDBlackModel
end

%--------------------------------------------------------------------------
% perform black level corrections on a per cadence basis
%--------------------------------------------------------------------------

% set up variable name for calibrated pixels tagged with current invocation number
% save in intermediate struct for the rest of this invocation

% load cal_comp_eff_state nInvocations
invocation = calObject.calInvocationNumber;
pixelVariableName = ['calibratedPixels',num2str(invocation)];
calIntermediateStruct.pixelVariableName = pixelVariableName;

% load the short cadence bias corrections
if dynamic2DBlackEnabled && processShortCadence
    load([stateFilePath, 'cal_black_levels.mat'], 'dynablackScBias', 'CdynablackScBias');
    calIntermediateStruct.dynablackScBias = dynablackScBias;                                    %#ok<NODEF>
    calIntermediateStruct.CdynablackScBias = CdynablackScBias;
end

lastDuration = 0;
tic

for cadenceIndex = 1:nCadences

    % correct only for cadences with valid pixels
    missingPhotometricCadences = calIntermediateStruct.missingPhotometricCadences;

    if isempty(missingPhotometricCadences) || (~isempty(missingPhotometricCadences) && ~any(ismember(missingPhotometricCadences, cadenceIndex)))

        %----------------------------------------------------------------------
        % subtract 2D black model from valid photometric pixels
        %----------------------------------------------------------------------
        
        % get twoDBlack pixels for this cadence
        if dynamic2DBlackEnabled
            
            % build 2D array for this cadence; size(twoDBlackArray) = [1070, 1132]
            twoDBlackArray = build_two_d_black_photometric_for_cadence(calIntermediateStruct, dynamicPhotometricTwoDBlackStruct, cadenceIndex);
            
            if processShortCadence
                % extract stuff from intermediate struct
                numberOfExposures   = calIntermediateStruct.numberOfExposures;
                dynablackScBias     = calIntermediateStruct.dynablackScBias(cadenceIndex);                
                % correct per read 2D black for bias using per cadence bias estimate
                twoDBlackArray = twoDBlackArray + dynablackScBias/numberOfExposures;
            end

        else            
            % use static 2D black - retrieve full array using get method in twoDBlackClass; size = 1070x1132
            twoDBlackArray = get_two_d_black(twoDBlackObject, timestamp(cadenceIndex));             
        end

        % subtract 2D black
        [calObject, calIntermediateStruct] = ...
            subtract_black2DModel_from_photometric_pixels(calObject, calIntermediateStruct, twoDBlackArray, cadenceIndex);

        % update calTransformStruct with 2D black correction
        if pouEnabled
            % initialize temporary tranformStruct for this cadence
            tStruct = calTransformStruct(:,cadenceIndex);
            
            % unpack stuff from intermediate struct
            pixelVariableName   = calIntermediateStruct.pixelVariableName;
            photometricRows     = calIntermediateStruct.photometricRows(:);
            photometricColumns  = calIntermediateStruct.photometricColumns(:);

            % start transformation chain for calibratedPixels with primitive data
            rawPixels = calIntermediateStruct.photometricPixels(:,cadenceIndex);
            
            % add bias back into raw pixels if SC dynablack - we want to propagate the covariance for the bias subtraction operation
            if dynamic2DBlackEnabled && processShortCadence
                dynablackScBias = calIntermediateStruct.dynablackScBias(cadenceIndex);
                rawPixels = rawPixels + dynablackScBias;
            end
            
            % use covariance place holder until shot noise can be calculated
            CrawPixels = ones(size(rawPixels));
            gapList = [];
            
            tStruct = append_transformation(tStruct,'eye',pixelVariableName, [], rawPixels, CrawPixels, gapList, photometricRows, photometricColumns);
            
%             % -------------------------------------------
%             %   UNTESTED - Add short cadence bias correction term to POU struct for SC/dynablackEnabled
%             %              KSOC-4941 covers the code changes to correctly include the percadence bias correction to the raw pixels using
%             %              dynablackScBias. This commented out piece which adds the bias correction to the POU transformation structure
%             %              was inserted at the time of the KSOC-4941 code change but was not fully tested because code changes beyond
%             %              those to fix the sc bias bug were not specifically included in the scope of KSOC-4941.
%
%             if processShortCadence && dynamic2DBlackEnabled
%                 
%                 % start the bias term
%                 pixelBiasName = ['fittedBias',num2str(invocation)];
%                 tStruct = append_transformation(tStruct, 'eye', pixelBiasName, [], dynablackScBias, CdynablackScBias, gapList, [], []);
%                 
%                 % expand bias term to full length of x vector
%                 tStruct = append_transformation(tStruct, 'userM', pixelBiasName, [], ['ones(',num2str(length(rawPixels)),',1)']);
%                 
%                 % subtract bias term from 2D black corrected pixels
%                 tStruct = append_transformation(tStruct, 'diffV', pixelVariableName, [], pixelBiasName,[]);
%                 
%             end
%             % -------------------------------------------
            
            % add back to calTransformStruct
            calTransformStruct(:,cadenceIndex) = tStruct;
        end
        
    else
        % gap POU for this cadence
        if pouEnabled
            tStruct = calTransformStruct(:,cadenceIndex);
            tStruct = insert_POU_cadence_gaps(tStruct, {pixelVariableName});
            
%             % -------------------------------------------
%             %   UNTESTED - Add short cadence bias correction term to POU struct for SC/dynablackEnabled
%             %              KSOC-4941 covers the code changes to correctly include the percadence bias correction to the raw pixels using
%             %              dynablackScBias. This commented out piece which gaps the bias correction in the POU transformation structure
%             %              was inserted at the time of the KSOC-4941 code change but was not fully tested because code changes beyond
%             %              those to fix the sc bias bug were not specifically included in the scope of KSOC-4941.
%
%             if processShortCadence && dynamic2DBlackEnabled
%                 pixelBiasName = ['fittedBias',num2str(invocation)];
%                 tStruct = insert_POU_cadence_gaps(tStruct, {pixelBiasName});
%             end
%             % -------------------------------------------
            
            calTransformStruct(:,cadenceIndex) = tStruct;
        end
    end

    duration = toc;
    if debugLevel && duration > 10 + lastDuration
        lastDuration = duration;
        display(['CAL:correct_photometric_pix_black_level:correcting black for cadence: ' num2str(cadenceIndex) ' : ' num2str(duration/60) ' minutes']);
    end
end



%----------------------------------------------------------------------
% subtract 2D black model from partial ffi pixels if available
%----------------------------------------------------------------------
if isAvailableFfiPix && enableFfiInform    
    nFfis = length(calIntermediateStruct.ffiStruct);    
    for iFfi = 1:nFfis        
        % get ffi timestamp
        timestamp = calIntermediateStruct.ffiStruct(iFfi).timestamp;        
        % select correct timestamp in dynamicPhotometricTwoDBlackStruct
        cadenceIndex = iFfi;
        % get twoDBlack pixels for this cadence
        if dynamic2DBlackEnabled            
            % build 2D array for this cadence; size(twoDBlackArray) = [1070, 1132]
            twoDBlackArray = build_two_d_black_photometric_for_cadence(calIntermediateStruct, partialFfiTwoDBlackStruct, cadenceIndex);
        else            
            % use static 2D black - retrieve full array using get method in twoDBlackClass; size = 1070x1132
            twoDBlackArray = get_two_d_black(twoDBlackObject, timestamp);             
        end
        [calObject, calIntermediateStruct] = subtract_black2DModel_from_partial_ffi_pixels(calObject, calIntermediateStruct, twoDBlackArray, iFfi);

    end
end

%--------------------------------------------------------------------------
% if not dynamic 2D black correction, apply black level correction (1D black correction)
%--------------------------------------------------------------------------
if ~dynamic2DBlackEnabled
    [calObject, calIntermediateStruct, calTransformStruct] = apply_black_correction_to_photometric_pixels(calObject, calIntermediateStruct, calTransformStruct);    
    duration = toc;
    if debugLevel >= 0
        display(['CAL:correct_photometric_pix_black_level:correcting 1D black for all cadences: ' num2str(duration/60) ' minutes']);
    end
end

return;
