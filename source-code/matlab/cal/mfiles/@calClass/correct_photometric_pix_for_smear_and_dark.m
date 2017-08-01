function [calObject, calIntermediateStruct, calTransformStruct] = ...
    correct_photometric_pix_for_smear_and_dark(calObject, calIntermediateStruct, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     correct_photometric_pix_for_smear_and_dark(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass method corrects photometric pixels for smear and dark levels. Smear is a measure of the error introduced by transferring
% charge through an illuminated pixel in shutterless operation. It is equivalent to the ratio of the single-pixel transfer time to the
% exposure time.  This function computes the smear level estimate, which will be saved for target and background pixel calibration
% (subracting the smear levels corrects the pixels for image streaks due to lack of a shutter).
%
% Dark current meaures the thermal noise in a CCD - it can also give us information about bad or hot pixels that exist as well as provide
% information about an estimate of the rate of cosmic ray hits. Subtracting the dark current level from pixel values corrects them for
% signal not due to photons striking the detector. 
%
% The smear and dar corrections are computed prior to photometric pixel processing in get_smear_and_dark_levels. Those results are simply
% read in heare and applied. As a reminder, here are the four cases considered in developing the smear and dark estimates.
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


% get items from object
stateFilePath = calObject.localFilenames.stateFilePath;
nCadences = length(calObject.cadenceTimes.timestamp);
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;

% get values of desired fcConstants
fcConstants     = calObject.fcConstants;
nLeadingBlack   = fcConstants.nLeadingBlack;
nColsImaging    = fcConstants.nColsImaging;
virtualSmearStartRow = fcConstants.VIRTUAL_SMEAR_START;

% get exposure and read times
ccdExposureTimes = calIntermediateStruct.ccdExposureTime;
ccdReadTimes     = calIntermediateStruct.ccdReadTime;
timestampGapIndicators = calObject.cadenceTimes.gapIndicators;

% extract photometric pixels, which have already been corrected for black, linearity, and undershoot
photometricPixels  = calIntermediateStruct.photometricPixels;
photometricGaps    = calIntermediateStruct.photometricGaps;
photometricColumns = calIntermediateStruct.photometricColumns;
photometricRows    = calIntermediateStruct.photometricRows;

% load smear level estimates and dark currents, which were computed in first invocation of CAL and saved to a local .mat file
load([stateFilePath, 'cal_smear_and_dark_levels.mat'], 'smearLevels', 'validSmearColumns', 'darkCurrentLevels');

% Extract smearLevels, validSmearColumns, and darkCurrentLevels. 
% Target pixels in black regions are not gapped. 
% There is no dark current correction in the black regions and that the dark current correction is scaled by the duty cycle in the
% virtual smear region. 
smearCorrections = smearLevels(photometricColumns, :);                                  %#ok<NODEF>

visibleColumns  = nLeadingBlack + (1 : nColsImaging);
isVisibleColumn = false(size(smearLevels, 1), 1);
isVisibleColumn(visibleColumns) = true;

validSmearColumns(~isVisibleColumn, :) = true;
smearCorrectionGaps = ~validSmearColumns(photometricColumns, :);

isVirtualPhotometricRow = photometricRows > virtualSmearStartRow;
nVirtualPhotometricRows = sum(isVirtualPhotometricRow);

darkCurrentLevelsByColumn = repmat(darkCurrentLevels(:)', size(smearLevels, 1), 1);     %#ok<NODEF>
darkCurrentLevelsByColumn(~isVisibleColumn, :) = 0;
darkCorrections     = darkCurrentLevelsByColumn(photometricColumns, :);

dutyCycles = zeros(size(ccdReadTimes));

if numel(ccdReadTimes) > 1
    ccdReadTimes = ccdReadTimes(~timestampGapIndicators);
end

if numel(ccdExposureTimes) > 1
    ccdExposureTimes = ccdExposureTimes(~timestampGapIndicators);
end

if numel(ccdReadTimes) > 1 || numel(ccdExposureTimes) > 1
    dutyCycles(~timestampGapIndicators) = ccdReadTimes ./ (ccdReadTimes + ccdExposureTimes);    
    darkCorrections(isVirtualPhotometricRow, :) = darkCorrections(isVirtualPhotometricRow, :) .* ...
        repmat(dutyCycles(:)', nVirtualPhotometricRows, 1);    
else
    dutyCycles = ccdReadTimes ./ (ccdReadTimes + ccdExposureTimes);    
    darkCorrections(isVirtualPhotometricRow, :) = darkCorrections(isVirtualPhotometricRow, :) .* dutyCycles;
end

% correct pixels for smear levels and dark currents
smearAndDarkCorrectedPixels = photometricPixels - smearCorrections - darkCorrections;

% save transformation for POU
if pouEnabled
    for cadenceIndex=1:nCadences
        
        % compute only for cadences with valid pixels
        missingPhotometricCadences = calIntermediateStruct.missingPhotometricCadences;
        
        if isempty(missingPhotometricCadences) || (~isempty(missingPhotometricCadences) && ~any(ismember(missingPhotometricCadences, cadenceIndex)))
            
            % save the transformation:
            % calibratedPixels = calibratedPixels - smearLevelEstimate - darkLevelEstimate
            varName = calIntermediateStruct.pixelVariableName;
            disableLevel = 0;
            
            tStruct = calTransformStruct(:,cadenceIndex);
            
            tStruct = append_transformation(tStruct, 'diffV', varName , disableLevel,...
                'smearLevelEstimate', photometricColumns(:) );
            
            tStruct = append_transformation(tStruct, 'diffV', varName, disableLevel,...
                'darkColumns', photometricColumns(:) );
            
            calTransformStruct(:,cadenceIndex) = tStruct;
        end
    end
end

% issue a message if any smear and dark corrected pixels are now negative
if any(any( smearAndDarkCorrectedPixels <= 0 ))
    warning('CAL:correct_photometric_pix_for_smear_dark:NegativePhotometricPixelValues',...
        'Subtracting smear and dark level leads to negative photometric pixel values..')
end

% save updated pixels and gaps
calIntermediateStruct.photometricPixels = smearAndDarkCorrectedPixels;
calIntermediateStruct.photometricGaps   = photometricGaps | smearCorrectionGaps;

return;
