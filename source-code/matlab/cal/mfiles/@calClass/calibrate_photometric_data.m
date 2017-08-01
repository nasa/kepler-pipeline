function [calOutputStruct, calTransformStruct] = ...
    calibrate_photometric_data(calObject, calTransformStruct)
%function [calOutputStruct, calTransformStruct] = ...
%   calibrate_photometric_data(calObject, calTransformStruct)
%
% This calClass method calibrates photometric pixels for all cadences per module/output. The input calObject has been instantiated in the
% matlab controller from the calInputStruct, the contents of which are defined in the controller header.  Note that relevant row/column
% fields have already been converted to matlab 1-base.
%
% Summary of photometric calibration for each mod/out invocation:
%
%  - Repackage the input data from structs into 2D arrays to take full advantage
%    of MATLAB's vectorization.  All data is saved into an intermediate
%    struct, which is passed into all subsequent functions along with the
%    input CAL object.
%
%  - If propagating uncertainties, include the transform struct in the
%    intermediate struct.
%
%  - Allocate memory for structs/arrays that will be collected in CAL,
%    including intermediate products and the final output structures.
%
%  - Extract the relevant parameters from the spacecraft config map
%
%  - Correct photometric pixels for the fixed offset
%
%  - Correct photometric pixels for the mean black value
%
%  - Calibrate photometric pixels for black by removing the 2D black and applying
%    the black correction, which was computed in the first CAL invocation and
%    saved to a local .mat file  (see note below).  If the POU (propagation of
%    uncertainies) flag is enabled, the uncertainties will be propagated throughout.
%
%  - Correct for nonlinearity (if the linearity correction flag is enabled
%    in the module parameters struct), and collect terms for uncertainty
%    propagation (if the POU flag is enabled).
%
%  - Correct for gain and collect terms for uncertainty propagation (if the
%    POU flag is enabled)
%
%  - Correct for LDE (local detector electronics) undershoot (if the undershoot
%    correction flag is enabled) and collect terms for uncertainty propagation
%    (if the POU flag is enabled)
%
%  - Compute the photometric raw uncertainties (the shot noise needs to be
%    computed after the undershoot correction is performed)
%
%  - Correct for smear and dark current levels, which were computed in the
%    first CAL invocation and saved to a local .mat file (see note below)
%
%  - Correct for the flat field
%
%  - Create the CAL output structure from fields in the intermediate struct
%    and the CAL object.  Output the transform struct if POU flag is enabled.
%
%
% Note: the black correction, smear levels, and dark current levels have been
% computed in first invocation of CAL, and saved to local .mat files.  They
% are loaded and used to calibrate the target/background pixels.
%
% The following black correction parameters are computed in the function
% correct_collateral_pix_black_level and saved to cal_black_levels.mat:
%
%   (1) calBlackOutputStruct.blackCorrection
%   (2) calBlackOutputStruct.blackAvailable
%
% The following smear and dark correction parameters are computed in the
% function get_smear_and_dark_levels and saved to
% cal_smear_and_dark_levels.mat:
%
%   (1) calSmearAndDarkOutputStruct.smearLevels
%   (2) calSmearAndDarkOutputStruct.validSmearColumns
%   (3) calSmearAndDarkOutputStruct.darkCurrentLevels
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

% extract the FFI flag to disable the mean black & fixed offset calibration
processFFI = calObject.dataFlags.processFFI;

%--------------------------------------------------------------------------
% all pixels are passed into CAL in structs or arrays of structs; save pixels,
% gaps, and row/column information into (nPixels x nCadences) arrays
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

calIntermediateStruct = repackage_data_for_calibration(calObject);

metrics_interval_stop('cal.calibrate_collateral_data.repackage_data_for_calibration.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_photometric_data: Repackaged data from structs to arrays', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% initialize or preallocate memory for calibrated data
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

calIntermediateStruct = preallocate_memory_for_calibration(calObject, calIntermediateStruct);

metrics_interval_stop('cal.calibrate_collateral_data.preallocate_memory_for_calibration.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_photometric_data: Memory preallocated to collect data', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% extract required parameters from spacecraft config map that may vary with
% time, which are added to intermediate struct (along with numCoadds)
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

calIntermediateStruct = get_config_map_parameters(calObject, calIntermediateStruct);

metrics_interval_stop('cal.calibrate_collateral_data.get_config_map_parameters.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_photometric_data: Config map parameters extracted', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% correct all pixels for the fixed offset
%--------------------------------------------------------------------------
if ~processFFI
    tic;
    metricsKey = metrics_interval_start;
    
    [calObject, calIntermediateStruct] = correct_data_for_fixed_offset(calObject, calIntermediateStruct);
    
    metrics_interval_stop('cal.calibrate_collateral_data.correct_data_for_fixed_offset.execTimeMillis',metricsKey);
    display_cal_status('CAL:calibrate_photometric_data: Data corrected for fixed offset', 1);
    display_memory(whos);
end

%--------------------------------------------------------------------------
% correct all pixels for the mean black
%--------------------------------------------------------------------------
if ~processFFI
    tic;
    metricsKey = metrics_interval_start;
    
    [calObject, calIntermediateStruct] = correct_data_for_mean_black(calObject, calIntermediateStruct);
    
    metrics_interval_stop('cal.calibrate_collateral_data.correct_data_for_mean_black.execTimeMillis',metricsKey);
    display_cal_status('CAL:calibrate_photometric_data: Data corrected for mean black', 1);
    display_memory(whos);
end

%--------------------------------------------------------------------------
% calibrate pixels for black level, collect terms for uncertainty propagation
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct, calTransformStruct] = correct_photometric_pix_black_level(calObject, calIntermediateStruct, calTransformStruct);

metrics_interval_stop('cal.calibrate_collateral_data.correct_photometric_pix_black_level.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_photometric_data: Black level correction complete', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% correct for nonlinearity, collect terms for uncertainty propagation
%--------------------------------------------------------------------------
if calObject.moduleParametersStruct.linearityCorrectionEnabled
    tic;
    metricsKey = metrics_interval_start;
    
    [calObject, calIntermediateStruct, calTransformStruct] = correct_photometric_pix_nonlinearity(calObject, calIntermediateStruct, calTransformStruct);
    
    metrics_interval_stop('cal.calibrate_collateral_data.correct_photometric_pix_nonlinearity.execTimeMillis',metricsKey);
    display_cal_status('CAL:calibrate_photometric_data: Nonlinearity correction complete', 1);
    display_memory(whos);
end

%--------------------------------------------------------------------------
% correct for gain, collect terms for uncertainty propagation
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct, calTransformStruct] = correct_photometric_pix_for_gain(calObject, calIntermediateStruct, calTransformStruct);

metrics_interval_stop('cal.calibrate_collateral_data.correct_photometric_pix_for_gain.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_photometric_data: Gain correction complete', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% correct for LD undershoot, collect terms for uncertainty propagation
%--------------------------------------------------------------------------
if calObject.moduleParametersStruct.undershootEnabled
    tic;
    metricsKey = metrics_interval_start;
    
    [calObject, calIntermediateStruct, calTransformStruct] = correct_photometric_pix_undershoot(calObject, calIntermediateStruct, calTransformStruct);
    
    metrics_interval_stop('cal.calibrate_collateral_data.correct_photometric_pix_undershoot.execTimeMillis',metricsKey);
    display_cal_status('CAL:calibrate_photometric_data: Undershoot correction complete', 1);
    display_memory(whos);
end

%--------------------------------------------------------------------------
% compute raw photometric pixel uncertainties for all cadences
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct, calTransformStruct] = compute_photometric_raw_uncertainties(calObject, calIntermediateStruct, calTransformStruct);

metrics_interval_stop('cal.calibrate_collateral_data.compute_photometric_raw_uncertainties.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_photometric_data: Raw photometric pixel uncertainties computed', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% correct for smear and dark levels, and collect terms for uncertainty propagation
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct, calTransformStruct] = correct_photometric_pix_for_smear_and_dark(calObject, calIntermediateStruct, calTransformStruct);

metrics_interval_stop('cal.calibrate_collateral_data.correct_photometric_pix_for_smear_and_dark.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_photometric_data: Smear and dark level correction complete', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% correct for flat field
%--------------------------------------------------------------------------
if calObject.moduleParametersStruct.flatFieldCorrectionEnabled
    tic;
    metricsKey = metrics_interval_start;
    
    [calObject, calIntermediateStruct, calTransformStruct] = correct_photometric_pix_flat_field(calObject, calIntermediateStruct, calTransformStruct);
    
    metrics_interval_stop('cal.calibrate_collateral_data.correct_photometric_pix_flat_field.execTimeMillis',metricsKey);
    display_cal_status('CAL:calibrate_photometric_data: Flat field correction complete', 1);
    display_memory(whos);
end

%--------------------------------------------------------------------------
% create output structure with required fields, and save intermediate
% struct to local mat file for optional analyis
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calOutputStruct, calIntermediateStruct] = set_cal_output_struct(calObject, calIntermediateStruct, calTransformStruct);     %#ok<NASGU>

metrics_interval_stop('cal.calibrate_collateral_data.set_cal_output_struct.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_photometric_data: CAL object and intermediate struct converted to CAL output struct', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% validate fields in the output structure
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calOutputStruct] = validate_cal_outputs(calOutputStruct, processFFI);

metrics_interval_stop('cal.calibrate_collateral_data.validate_cal_outputs.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_photometric_data: CAL outputs validated', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% save intermediate data struct from this invocation into a local directory
%--------------------------------------------------------------------------
tic;

% extract invocation label
invocation = calObject.calInvocationNumber;

% create new directory with date and invocation
newDataDirectory = [calObject.localFilenames.stateFilePath,'photometric_data_part_', num2str(invocation)];
mkdir(newDataDirectory);
save([newDataDirectory, '/calPhotometricIntermediateDataStruct', num2str(invocation), '.mat'], 'calIntermediateStruct');
display_cal_status(['CAL:calibrate_photometric_data: calIntermediateStruct saved to dir: ' newDataDirectory], 1);

clear calIntermediateStruct
display('CAL:calibrate_photometric_data: CAL intermediate struct cleared');
display_memory(whos);

% move any figures into figure directory created in collateral invocation (0)
newFigureDirectory = [calObject.localFilenames.stateFilePath,'figures'];

figures = dir('*.fig');
if ~isempty(figures)
    movefile('*.fig', newFigureDirectory);
    display_cal_status(['CAL:calibrate_collateral_data: Figures saved to dir: ' newFigureDirectory], 1);
end
