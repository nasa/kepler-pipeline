function [calObject, calIntermediateStruct, calTransformStruct] = ...
    correct_collateral_pix_for_gain(calObject, calIntermediateStruct, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     correct_collateral_pix_for_gain(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass method corrects collateral pixels for the gain, which is the conversion from DN units (or ADUs) to photoelectrons.  The gain
% is determined such that the full well (~1.3*10^6 electrons) does not exceed the max ADC value of 16,383 (2^14-1), and is of order
% ~100e-/DN.  It is possible that the gain may vary with time, so it is extracted from an FC model for all cadences.  
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


% extract data flags
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;
isAvailableMaskedSmearPix  = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix = calObject.dataFlags.isAvailableVirtualSmearPix;

nCadences = calIntermediateStruct.nCadences;

% get gain for this mod/out
gain = calIntermediateStruct.gain;   % nCadences x 1, or scalar


%--------------------------------------------------------------------------
% correct masked smear pixels for gain
%--------------------------------------------------------------------------
if isAvailableMaskedSmearPix

    % extract masked smear pixels
    mSmearPixels = calIntermediateStruct.mSmearPixels;   % nPixels x nCadences
    mSmearGaps   = calIntermediateStruct.mSmearGaps;     % nPixels x nCadences

    % find valid pixel indices
    validMsmearPixelIndicators = ~mSmearGaps;

    if numel(gain) > 1
        gain = repmat(gain(:)', length(mSmearPixels(:, 1)), 1);
        gain = gain(validMsmearPixelIndicators);
    end

    %--------------------------------------------------------------------------
    % correct pixels for gain
    %--------------------------------------------------------------------------
    mSmearPixels(validMsmearPixelIndicators) = mSmearPixels(validMsmearPixelIndicators) .* gain;

    % save corrected pixels
    calIntermediateStruct.mSmearPixels = mSmearPixels;
end


%--------------------------------------------------------------------------
% correct virtual smear pixels for gain
%--------------------------------------------------------------------------
if isAvailableVirtualSmearPix

    % extract virtual smear pixels
    vSmearPixels = calIntermediateStruct.vSmearPixels;   % nPixels x nCadences
    vSmearGaps   = calIntermediateStruct.vSmearGaps;     % nPixels x nCadences

    % find valid pixel indices
    validVsmearPixelIndicators = ~vSmearGaps;

    if numel(gain) > 1
        gain = repmat(gain(:)', length(vSmearPixels(:, 1)), 1);
        gain = gain(validVsmearPixelIndicators);
    end

    %--------------------------------------------------------------------------
    % correct pixels for gain
    %--------------------------------------------------------------------------
    vSmearPixels(validVsmearPixelIndicators) = vSmearPixels(validVsmearPixelIndicators) .* gain;

    % save corrected pixels
    calIntermediateStruct.vSmearPixels = vSmearPixels;
end


if pouEnabled
    % append transformations
    for cadenceIndex = 1:nCadences

        if numel(gain) > 1
            gain = gain(cadenceIndex);
        end

        % copy calTransformStruct into shorter temporary structure
        tStruct = calTransformStruct(:,cadenceIndex);

        if isAvailableMaskedSmearPix && ~all(mSmearGaps(:,cadenceIndex))
            % variableName = variableName * gain(cadenceIndex) --> type 'scale'
            tStruct = append_transformation(tStruct, 'scale', 'mSmearEstimate', [], gain);
        end

        if isAvailableVirtualSmearPix && ~all(vSmearGaps(:,cadenceIndex))
            % variableName = variableName * gain(cadenceIndex) --> type 'scale'
            tStruct = append_transformation(tStruct, 'scale', 'vSmearEstimate', [], gain);
        end

        % copy  shorter temporary structure into calTransformStruct
        calTransformStruct(:,cadenceIndex) = tStruct;
    end
end


return;
