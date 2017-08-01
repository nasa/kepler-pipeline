function [calObject, calIntermediateStruct, calTransformStruct] = get_smear_and_dark_levels(calObject, calIntermediateStruct, calTransformStruct)
%function [calObject, calIntermediateStruct, calTransformStruct] = get_smear_and_dark_levels(calObject, calIntermediateStruct, calTransformStruct)
% 
% This calClass method deermines the smear and dark current corrections to be applied to all collateral and photometric pixels from the
% collateral smear data.
%
% Smear is a measure of the error introduced by transferring charge through an illuminated pixel in shutterless operation. It is equivalent
% to the ratio of the single-pixel transfer time to the exposure time.  This function computes the smear level estimate, which will be saved
% for target and background pixel calibration (subracting the smear levels corrects the pixels for image streaks due to lack of a shutter).
%
% Dark current meaures the thermal noise in a CCD - it can also give us information about bad or hot pixels that exist as well as provide
% information about an estimate of the rate of cosmic ray hits. Subtracting the dark current level from pixel values corrects them for
% signal not due to photons striking the detector.
%
% Ideally, both virtual smear and masked smear are used for the smear level and dark current estimation, but only one type (masked or
% virtual) is needed to make a smear estimate, dark current may be inferred from nearby pixels (in space or time). Depending on which pixels
% are available, the following cases arise on a column by column and cadence by cadence basis:  
%
%     case 1: Both virtual and masked smear pixels available. 
%             Smear and dark levels are directly computed from masked and virtual smear pixels.
%
%     case 2: Only virtual smear pixels are available.
%             Use dark level value from adjacent column to estimate smear (or use temporally interpolated dark if not
%             available for a particular cadence).
%
%     case 3: Only masked smear pixels are available.
%             Use dark level value from adjacent column to estimate smear (or use temporally interpolated dark if not
%             available for a particular cadence)
%
%     case 4: No smear pixels are available.
%             Smear/dark correction is not possible. Photometric pixels will be declared as data gaps.
%
% The dark level is estimated for the current mod/out by taking a robust average of the available dark current measurements provided by the 
% available smear pixels according to case 1. The dark level is interpolated for cadences where dark level estimation is not possible.
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


% extract flags
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;
stateFilePath = calObject.localFilenames.stateFilePath;
isAvailableMaskedSmearPix = calObject.dataFlags.isAvailableMaskedSmearPix; % nCad x 1 array
isAvailableVirtualSmearPix = calObject.dataFlags.isAvailableVirtualSmearPix; % nCad x 1 array

% get config map parameters
numberOfExposures = calIntermediateStruct.numberOfExposures;
ccdReadTime     = calIntermediateStruct.ccdReadTime;
ccdExposureTime = calIntermediateStruct.ccdExposureTime;

nCadences       = calIntermediateStruct.nCadences;

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestampGapIndicators = cadenceTimes.gapIndicators;

nCcdColumns = calIntermediateStruct.nCcdColumns;

% extract default dark current
defaultDarkCurrentElectronsPerSec = calObject.moduleParametersStruct.defaultDarkCurrentElectronsPerSec;
	

%--------------------------------------------------------------------------
% extract smear pixels that have been corrected for black, linearity,
% undershoot, and cosmic rays (each is nPixels x nCadence array)
mSmearPixels =  calIntermediateStruct.mSmearPixels;
vSmearPixels =  calIntermediateStruct.vSmearPixels;


if isAvailableMaskedSmearPix
    mSmearGaps = calIntermediateStruct.mSmearGaps;            % nPix x nCad
    mSmearColumns = calIntermediateStruct.mSmearColumns;      % nPix x 1
    validMsmearIndicatorsArray = ~(mSmearGaps);               % nPix x nCad
end

if isAvailableVirtualSmearPix
    vSmearGaps = calIntermediateStruct.vSmearGaps;            % nPix x nCad
    vSmearColumns = calIntermediateStruct.vSmearColumns;      % nPix x 1
    validVsmearIndicatorsArray = ~(vSmearGaps);               % nPix x nCad
end

%--------------------------------------------------------------------------
% loop over cadences to compute dark level estimate.  If dark level cannot
% be computed for a cadence, interpolate over time in order to have a dark
% level estimate for all cadences

% record cadences with available dark levels for interpolation
darkLevelAvailableCadences = zeros(nCadences, 1);

% initialize dark current levels array
darkCurrentLevels = zeros(nCadences, 1);

% correct only for cadences with valid pixels
missingMsmearCadences = calIntermediateStruct.missingMsmearCadences;
missingVsmearCadences = calIntermediateStruct.missingVsmearCadences;
missingCadences = union(missingMsmearCadences, missingVsmearCadences);


for cadenceIndex = 1:nCadences

    if numel(numberOfExposures) > 1
        numberOfExposures = numberOfExposures(cadenceIndex);
    end

    if numel(ccdReadTime) > 1
        ccdReadTime = ccdReadTime(cadenceIndex);
    end

    if numel(ccdExposureTime) > 1
        ccdExposureTime = ccdExposureTime(cadenceIndex);
    end


    if isempty(missingCadences) || (~isempty(missingCadences) && ~any(ismember(missingCadences, cadenceIndex)))

        % find valid mSmear indices where data are present (buffer pixel values
        % in the leading/trailing black columns are treated as gaps)
        validMsmearPixelIndicators = ~(mSmearGaps(:, cadenceIndex));  % 1132x1 logical

        % find valid vSmear indices where data are present (buffer pixel values
        % in the leading/trailing black columns are treated as gaps)
        validVsmearPixelIndicators = ~(vSmearGaps(:, cadenceIndex));  % 1132x1 logical

        %----------------------------------------------------------------------
        % find masked and virtual smear columns with valid data for this cadence
        %----------------------------------------------------------------------
        colMsmearValid = mSmearColumns(validMsmearPixelIndicators);
        colVsmearValid = vSmearColumns(validVsmearPixelIndicators);

        % find columns with both valid masked smear and valid virtual smear pixels
        commonSmearCols = intersect(colMsmearValid, colVsmearValid);

        %----------------------------------------------------------------------
        % case 1 : Both virtual and masked smear pixels are available, compute
        % dark level estimate from columns with both masked and virtual pixels
        %----------------------------------------------------------------------
        if ~isempty(commonSmearCols)

            % extract masked and virtual smear pixel values in common columns
            mSmear = mSmearPixels(commonSmearCols, cadenceIndex);
            vSmear = vSmearPixels(commonSmearCols, cadenceIndex);

            %------------------------------------------------------------------
            % compute dark level estimate for current mod/out
            %
            % masked smear collects dark current during ccdExposureTime + ccdReadTime
            % whereas virtual smear collects dark current during ccdReadTime only
            %------------------------------------------------------------------

            darkCurrent = (mSmear - vSmear) ./ (numberOfExposures * ccdExposureTime);

            % compute the dark current level
            darkLevelEstimate = darkCurrent * numberOfExposures * (ccdExposureTime + ccdReadTime);

            % take a robust average if more than one available dark level value
            if length(darkLevelEstimate) > 1

                [darkLevelEstimate, darkLevelRobustFitStats] = robustfit(ones(length(full(darkLevelEstimate)), 1), ...
                    full(darkLevelEstimate), [], [], 'off');
            end


            %------------------------------------------------------------------
            % save dark level estimate
            %------------------------------------------------------------------
            darkCurrentLevels(cadenceIndex) = darkLevelEstimate;

            % record cadences with available dark levels for interpolation
            darkLevelAvailableCadences(cadenceIndex) = cadenceIndex;


            if pouEnabled
                % copy calTransformStruct into shorter temporary structure
                tStruct = calTransformStruct(:,cadenceIndex);

                % save darkLevelEstimate transformations

                % build up dark level estimate
                % darkLevelEstimate =  ((mSmearPixels - vSmearPixels)/ccdExposureTime)*(ccdExposureTime + ccdReadTime)
                tStruct = append_transformation(tStruct, 'eye', 'darkLevelEstimate', [], 'mSmearEstimate',[],[],[],[]);
                tStruct = append_transformation(tStruct, 'diffV', 'darkLevelEstimate', [], 'vSmearEstimate', []);
                tStruct = append_transformation(tStruct, 'scale', 'darkLevelEstimate', [],...
                    (ccdExposureTime + ccdReadTime)/ccdExposureTime);

                % emulate robust mean using weights from stats.w
                weights = zeros(size(mSmearPixels(:,cadenceIndex)));

                if (length(commonSmearCols) > 1)
                    weights(commonSmearCols) = darkLevelRobustFitStats.w;
                else
                    weights(commonSmearCols) = 1;
                end

                tStruct = append_transformation(tStruct, 'wSum', 'darkLevelEstimate', [], weights);

                % divide by length of non-zero weights
                tStruct = append_transformation(tStruct, 'scale', 'darkLevelEstimate', [],...
                    1/length( find(weights ~= 0)) );

                % expand scalar result across all columns as 'darkColumns'
                tStruct = append_transformation(tStruct, 'eye', 'darkColumns', [], 'darkLevelEstimate',[],[],[],[]);
                tStruct = append_transformation(tStruct, 'userM', 'darkColumns', [],...
                    ['ones(',num2str(nCcdColumns),',1)']);

                % copy shorter temporary structure into calTransformStruct
                calTransformStruct(:,cadenceIndex) = tStruct;
            end

        else

            % insert POU cadences gaps for variables 'darkLevelEstimate', 'darkColumns'
            if pouEnabled
                variableList = {'darkLevelEstimate','darkColumns'};
                calTransformStruct(:,cadenceIndex) = ...
                    insert_POU_cadence_gaps(calTransformStruct(:,cadenceIndex),variableList);
            end
        end
    else
        % insert POU cadences gaps for variables 'darkLevelEstimate', 'darkColumns'
        if pouEnabled
            variableList = {'darkLevelEstimate','darkColumns'};
            calTransformStruct(:,cadenceIndex) = ...
                insert_POU_cadence_gaps(calTransformStruct(:,cadenceIndex),variableList);
        end
    end
end


%--------------------------------------------------------------------------
% interpolate dark level values over time to ensure a dark level is
% available for all cadences
%--------------------------------------------------------------------------
availableCadences = darkLevelAvailableCadences(darkLevelAvailableCadences > 0);
pouIdx = [];
interpCadences = (1:nCadences)';

if length(availableCadences) > 1 
    % Interpolate if there is more than 1 valid cadence.    
        
    % interpolate linearly across internal gaps
    internalCadenceLogical = interpCadences >= min(availableCadences) & interpCadences <= max(availableCadences);
    darkCurrentLevels(internalCadenceLogical) = ...
        interp1(availableCadences, darkCurrentLevels(availableCadences), interpCadences(internalCadenceLogical), 'linear');
    
    % fill end gaps with nearest neighbor
    externalCadenceLogical = interpCadences < min(availableCadences) | interpCadences > max(availableCadences);
    darkCurrentLevels(externalCadenceLogical) = ...
        interp1(availableCadences, darkCurrentLevels(availableCadences), interpCadences(externalCadenceLogical), 'nearest','extrap');
    
elseif length(availableCadences) == 1
    % If there is exactly one valid cadence use that dark level for all cadences.
    
    darkCurrentLevels(interpCadences) = darkCurrentLevels(availableCadences);
    display(['CAL:get_smear_and_dark_levels: Not able to determine dark current from masked and virtual smear for',...
        ' all but one cadence. Using dark level from relative cadence ',num2str(availableCadences),' for all cadences']);
else
    % All cadences gapped. Use the default value for all cadences.
    
    darkCurrentLevels(interpCadences) = defaultDarkCurrentElectronsPerSec .*...
        ( numberOfExposures .* ( ccdExposureTime + ccdReadTime ));
    display(['CAL:get_smear_and_dark_levels: Not able to determine dark current from masked and virtual smear for',...
        ' any cadence. Using default value ',num2str(defaultDarkCurrentElectronsPerSec),' e-/s']);
    
    % insert a single entry for darkLevelEstimate and darkColumns in calTransformStruct and gap fill later
    if pouEnabled
        
        % parse first cadence from calTransformStruct
        tStruct = calTransformStruct(:,1);
        
        % get indices
        pouIdx = iserrorPropStructVariable(tStruct,{'darkLevelEstimate','darkColumns'});
        
        % first seed darkLevelEstimate with default value - covariance is set to zero - cadence gap flag gets cleared 
        tStruct = replace_primitive_data(tStruct,'darkLevelEstimate', darkCurrentLevels(1), 0, {});        
        
        % update darkColumns primitives and transformation chain
        tStruct = replace_primitive_data(tStruct,'darkColumns', 'darkLevelEstimate', [], {});
        tStruct = append_transformation(tStruct, 'userM', 'darkColumns', [], ['ones(',num2str(nCcdColumns),',1)']);
        
        % reset gap flags so these entries can fill other gapped cadences
        for idx = pouIdx(:)'
            tStruct(idx).cadenceGapped = false;
        end
                
        % write first cadence back into calTransformStruct
        calTransformStruct(:,1) = tStruct;
    end
end

% fill POU cadence gaps with nearest neighbor
if pouEnabled    
    if ~isempty(pouIdx)
        calTransformStruct(pouIdx,:) = fill_cadence_gaps_in_calTransformStruct(calTransformStruct(pouIdx,:));
    end
end

% store in intermediateStruct
calIntermediateStruct.darkCurrentLevels = darkCurrentLevels;

% create an array of dark levels that can be subtracted off masked and
% virtual smear arrays; the residuals will be used to estimate the smear levels
meanDarkArray = repmat(darkCurrentLevels(:)', length(mSmearColumns), 1);
mSmearResidual = (mSmearPixels - meanDarkArray) .* validMsmearIndicatorsArray;

if numel(ccdReadTime) > 1 || numel(ccdExposureTime) > 1

    vSmearTime = zeros(size(ccdReadTime));
    vSmearTime(~timestampGapIndicators) = (ccdReadTime(~timestampGapIndicators) ./ ...
        (ccdExposureTime(~timestampGapIndicators) + ccdReadTime(~timestampGapIndicators)));

    vSmearTimeCorrection = repmat(vSmearTime(:)', length(mSmearColumns), 1);
else
    vSmearTime = ccdReadTime ./ (ccdExposureTime + ccdReadTime);
    vSmearTimeCorrection = vSmearTime;
end


vSmearResidual = (vSmearPixels - meanDarkArray .* vSmearTimeCorrection) .* validVsmearIndicatorsArray;

%--------------------------------------------------------------------------
% compute smear level estimate using following logic:
%
%   availableMsmear   availableVsmear     C_Msmear      C_Vsmear
%  ---------------------------------------------------------------
%        T                T                 1/2           1/2
%        T                F                  1             0
%        F                T                  0             1
%        F                F                  0             0
%
%
%   C_Msmear  =  1/2 * availableMsmear  .*  (1 + ~availableVsmear);
%
%   C_Vsmear  =  1/2 * availableVsmear  .*  (1 + ~availableMsmear);


cMsmear = 1/2 * double(validMsmearIndicatorsArray) .* (1 + ~double(validVsmearIndicatorsArray));
cVsmear = 1/2 * double(validVsmearIndicatorsArray) .* (1 + ~double(validMsmearIndicatorsArray));

smearLevels = vSmearResidual .* cVsmear + mSmearResidual .* cMsmear;                                            %#ok<NASGU>

% record columns with valid smear level estimates; note that columns with
% virtual smear but no masked smear (due to bleeding columns) are valid
validSmearColumns = validMsmearIndicatorsArray | validVsmearIndicatorsArray;                                    %#ok<NASGU>


%--------------------------------------------------------------------------
% save smear and dark current levels, and the valid smear columns, to local
% .mat file for photometric pixel calibration
% save full path to file for other functions in collateral invocation
%--------------------------------------------------------------------------
save([stateFilePath,'cal_smear_and_dark_levels.mat'], 'smearLevels', 'darkCurrentLevels', 'validSmearColumns');
display('CAL:get_smear_and_dark_levels: Smear and dark levels saved in cal_smear_and_dark_levels.mat');
calIntermediateStruct.smearAndDarkLevelsFile = [stateFilePath,'cal_smear_and_dark_levels.mat'];

%--------------------------------------------------------------------------
% save and plot masked-minus-virtual smear pixels
%--------------------------------------------------------------------------
plot_smear_difference(calIntermediateStruct, mSmearResidual, vSmearResidual);

%--------------------------------------------------------------------------
% propagation of uncertainties - build up transformation matrices
%--------------------------------------------------------------------------
% correct only for cadences with valid pixels
missingMsmearCadences = calIntermediateStruct.missingMsmearCadences;
missingVsmearCadences = calIntermediateStruct.missingVsmearCadences;
missingCadences = union(missingMsmearCadences, missingVsmearCadences);

if pouEnabled
    for cadenceIndex = 1:nCadences

        if numel(vSmearTime) > 1
            tVirtual = vSmearTime(cadenceIndex);
        else
            tVirtual = vSmearTime;
        end

        % copy calTransformStruct into shorter temporary structure
        tStruct = calTransformStruct(:,cadenceIndex);

        if isempty(missingCadences) || (~isempty(missingCadences) && ~any(ismember(missingCadences, cadenceIndex)))

            % build up smearLevelEstimate = termFrommSmear + termFromvSmear
            s = size(cMsmear);
            cMsmearRows_char = num2str(s(1));

            % termFrommSmear = (mSmearEstimate - darkLevelEstimate) .* cMsmear
            tStruct = append_transformation(tStruct, 'eye', 'termFrommSmear', [], 'darkLevelEstimate',[],[],[],[]);
            tStruct = append_transformation(tStruct, 'userM', 'termFrommSmear', [], ['-1.*ones(',cMsmearRows_char,',1)']);
            tStruct = append_transformation(tStruct, 'addV', 'termFrommSmear', [], 'mSmearEstimate', []);
            tStruct = append_transformation(tStruct, 'scaleV', 'termFrommSmear', [], cMsmear(:,cadenceIndex));

            % smearLevelEstimate =
            %   termFrommSmear + termFromvSmear =
            %   termFrommSmear + (vSmearEstimate - darkLevelEstimate * tVirtual) .* cVsmear
            tStruct = append_transformation(tStruct, 'eye', 'smearLevelEstimate', [], 'darkLevelEstimate',[],[],[],[]);
            tStruct = append_transformation(tStruct, 'userM', 'smearLevelEstimate', [], ['ones(',cMsmearRows_char,',1)']);
            tStruct = append_transformation(tStruct, 'scale', 'smearLevelEstimate', [], -tVirtual);
            tStruct = append_transformation(tStruct, 'addV', 'smearLevelEstimate', [], 'vSmearEstimate', []);
            tStruct = append_transformation(tStruct, 'scaleV', 'smearLevelEstimate', [], cVsmear(:,cadenceIndex));
            tStruct = append_transformation(tStruct, 'addV', 'smearLevelEstimate', [], 'termFrommSmear', []);

        else
            % insert POU cadences gaps for variables 'termFrommSmear', 'smearLevelEstimate'
            variableList = {'termFrommSmear','smearLevelEstimate'};
            tStruct = insert_POU_cadence_gaps(tStruct,variableList);
        end

        % copy shorter temporary structure into calTransformStruct
        calTransformStruct(:,cadenceIndex) = tStruct;
    end
end


return;
