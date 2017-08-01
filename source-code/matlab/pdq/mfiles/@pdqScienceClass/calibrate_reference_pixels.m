function [pdqTempStruct, pdqOutputStruct] = calibrate_reference_pixels(pdqScienceObject, pdqTempStruct, pdqOutputStruct, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqTempStruct, pdqOutputStruct] = ...
% calibrate_reference_pixels(pdqScienceObject, pdqTempStruct, pdqOutputStruct, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method takes an object 'pdqScienceObject' of type
% 'pdqScienceClass' as input and calls several private class methods to
% perform pixel level calibration.
%
% Summary of pixel level calibration:
%   1) Subtract black 2d level from black, vrtual and masked smear, target,
%   and background pixel values
%   2) Fit the 2D corrected black with a polynomial and to model the black.
%   Subtract black level from virtual and masked smear,  target, and
%   background pixel valuespixel values
%   3) estimate smear and subtract smear signal from black corrected target
%   and background pixels from step 3
%   4) Subtract dark current level from the result of step 3
%   5) Correct target and background pixels from step 4 for flat field
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

%--------------------------------------------------------------------------
% Calibrate reference pixels for black 2D, black level
%--------------------------------------------------------------------------

fprintf('PDQ: Calibrating pixels: black level correction  ...\n');

[pdqTempStruct, pdqOutputStruct]    = correct_for_black_level_main(pdqScienceObject, pdqTempStruct, pdqOutputStruct);

%--------------------------------------------------------------------------
% Calibrate reference pixels for ADC Gain
%--------------------------------------------------------------------------

fprintf('PDQ: Calibrating pixels: gain correction  ...\n');

pdqTempStruct       = correct_for_gain(pdqTempStruct);


%--------------------------------------------------------------------------
% Calibrate reference pixels for undershoot/overshoot artifact
%--------------------------------------------------------------------------

fprintf('PDQ: Calibrating pixels: undershoot correction  ...\n');

pdqTempStruct       = correct_for_undershoot(pdqTempStruct);



%--------------------------------------------------------------------------
% Calibrate reference pixels for smear and dark
%--------------------------------------------------------------------------

% NOTE: median smear values are computed in background_correction
% NOTE: median dark current level values are computed in background_correction

% Read in existing dark current level time series
if(~isempty(pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData))
    if(~isempty(pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).darkCurrents))
        pdqTempStruct.pdqModuleOutputTsData.darkCurrentsUncertainties  = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).darkCurrents.uncertainties;
        pdqTempStruct.pdqModuleOutputTsData.darkCurrentLevels     = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).darkCurrents.values;
    else
        pdqTempStruct.pdqModuleOutputTsData.darkCurrentsUncertainties = [];
        pdqTempStruct.pdqModuleOutputTsData.darkCurrentLevels = [];
    end
else
    pdqTempStruct.pdqModuleOutputTsData.darkCurrentsUncertainties = [];
    pdqTempStruct.pdqModuleOutputTsData.darkCurrentLevels = [];
end


% Calibrate reference pixels for smear and dark

fprintf('PDQ: Calibrating pixels: smear and dark correction  ...\n');

[pdqTempStruct]     = correct_for_smear_and_dark(pdqTempStruct);


%--------------------------------------------------------------------------
% Calibrate reference pixels for flat field
%--------------------------------------------------------------------------

fprintf('PDQ: Calibrating pixels: flat field correction  ...\n');

pdqTempStruct       = correct_for_flat_field(pdqTempStruct); % currentModOut is not used at all


%--------------------------------------------------------------------------
% Collect additional background pixels from the target aperture
%--------------------------------------------------------------------------

pdqTempStruct = collect_additional_bkgd_pixels_from_target_aperture(pdqTempStruct);


%--------------------------------------------------------------------------
% Calibrate reference pixels for background
%--------------------------------------------------------------------------

fprintf('PDQ: Calibrating pixels: background correction  ...\n');

pdqTempStruct       = correct_for_background(pdqTempStruct);





return

