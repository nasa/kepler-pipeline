function [calObject, calIntermediateStruct, calTransformStruct] = ...
    correct_collateral_pix_nonlinearity(calObject, calIntermediateStruct, calTransformStruct)
%function [calObject, calIntermediateStruct, calTransformStruct] = ...
%    correct_collateral_pix_nonlinearity(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass method corrects collateral pixels for the nonlinear response of the focal plane readout electronics to the input signal on a
% per mod/out basis. Linearity describes how the conversion factor from e- to DN varies as a function of the input number of e-.  It is
% measured as the percent deviation from a linear transfer function at a given signal level.
%
% Steps for collateral pixel linearity correction:
%
% (1) pixels are divided by number of exposures
%
% (2) linearity correction model (polynomial coeffts) is extracted from FC
%
% (3) linearity correction and its derivative are computed via get_weighted_polyval,
% and saved (both are required for the nonlinearity transform for error propagation)
%
% (4) pixels are multiplied by linearity correction, and rescaled by number of coadds
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
processLongCadence  = calObject.dataFlags.processLongCadence;
pouOK = calObject.pouModuleParametersStruct.pouEnabled;

isAvailableMaskedSmearPix  = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix = calObject.dataFlags.isAvailableVirtualSmearPix;

numberOfExposures = calIntermediateStruct.numberOfExposures;
nCadences = calIntermediateStruct.nCadences;

% extract current module/output
ccdModule = calObject.ccdModule;
ccdOutput = calObject.ccdOutput;

% extract timestamps
cadenceTimes  = calObject.cadenceTimes;
timestamp     = cadenceTimes.timestamp;
timestampGapIndicators = cadenceTimes.gapIndicators;

% retrieve linearity model
linearityModel = calObject.linearityModel;

% create the linearity object
linearityObject = linearityClass(linearityModel);

clear linearityModel

% extract the (5th order) polynomial coeffts from FC to correct for the nonlinearity
% for this mod/out/cadence.
polyStruct = repmat(struct('coeffs', [], 'covariance', [], 'order', [], ...
    'type', [], 'offsetx', [], 'scalex', [], 'originx', []), length(timestamp), 1);

polyStruct(~timestampGapIndicators) = get_weighted_polyval_struct(linearityObject, ...
    timestamp(~timestampGapIndicators), ccdModule, ccdOutput);


%--------------------------------------------------------------------------
% calibrate masked smear pixels for nonlinearity
%--------------------------------------------------------------------------
if isAvailableMaskedSmearPix

    % extract black-corrected masked smear pixels
    mSmearPixels    = calIntermediateStruct.mSmearPixels;
    missingCadences = calIntermediateStruct.missingMsmearCadences;

    % correct all pixels for nonlinearity
    [correctedPixels, uncertaintyStruct, calIntermediateStruct, calTransformStruct] = ...
        correct_for_nonlinearity(mSmearPixels, polyStruct, numberOfExposures, ...
        nCadences, missingCadences, calIntermediateStruct, calTransformStruct, 'mSmearEstimate', pouOK);

    %--------------------------------------------------------------------------
    % save corrected pixels, uncertainty struct for linearity (which contains
    % linearity correction parameters and transforms)
    %--------------------------------------------------------------------------
    if processLongCadence
        calIntermediateStruct.mSmearPixels = correctedPixels;
    else
        calIntermediateStruct.mSmearPixels = sparse(correctedPixels);
    end
   
    clear correctedPixels uncertaintyStruct
end


%--------------------------------------------------------------------------
% calibrate virtual smear pixels for nonlinearity
%--------------------------------------------------------------------------
if isAvailableVirtualSmearPix

    % extract black-corrected virtual smear pixels
    vSmearPixels    = calIntermediateStruct.vSmearPixels;

    missingCadences = calIntermediateStruct.missingVsmearCadences;


    % correct all pixels for nonlinearity
    [correctedPixels, uncertaintyStruct, calIntermediateStruct, calTransformStruct] = ...
        correct_for_nonlinearity(vSmearPixels, polyStruct, numberOfExposures, ...
        nCadences, missingCadences, calIntermediateStruct, calTransformStruct, 'vSmearEstimate', pouOK);

    %--------------------------------------------------------------------------
    % save corrected pixels, uncertainty struct for linearity (which contains
    % linearity correction parameters and transforms)
    %--------------------------------------------------------------------------
    if processLongCadence
        calIntermediateStruct.vSmearPixels = correctedPixels;
    else
        calIntermediateStruct.vSmearPixels = sparse(correctedPixels);
    end
   
    clear correctedPixels uncertaintyStruct
end

return;
