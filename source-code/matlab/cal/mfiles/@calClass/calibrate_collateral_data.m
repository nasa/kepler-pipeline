function [calOutputStruct, calTransformStruct, blackCorrectionStructLC, smearCorrectionStructLC] = ...
    calibrate_collateral_data(calObject, calTransformStruct)
% function [calOutputStruct, calTransformStruct, blackCorrectionStructLC, smearCorrectionStructLC] = ...
%     calibrate_collateral_data(calObject, calTransformStruct)
%
% This calClass method calibrates collateral pixels for all cadences per module/output. The input calObject has been instantiated in the
% matlab controller from the calInputStruct, the contents of which are defined in the controller header.  Note that relevant row/column
% fields have already been converted to matlab 1-base.
%
% Summary of collateral calibration for each mod/out invocation:
%
%  - Repackage the input data from structs into 2D arrays to take full advantage of MATLAB's vectorization.  All data is saved into an
%    intermediate struct, which is passed into all subsequent functions along with the input CAL object.
%
%  - If propagating uncertainties, include the transform struct in the intermediate struct.
%
%  - Allocate memory for structs/arrays that will be collected in CAL, including intermediate products and the final output structures.
%
%  - Extract the relevant parameters from the spacecraft config map.
%
%  - Compute the raw black pixel uncertainties for all cadences.
%
%  - Correct all pixels for the fixed offset (skipped for FFIs).
%
%  - Correct all pixels for the mean black value (skipped for FFIs).
%
%  - Correct pixels for the number of spatial coadds (number of black columns, and/or smear rows that were summed onboard the spacecraft to
%    yield the input collateral pixel row/columns).
%
%  - Calibrate all pixels for black by first removing the 2D black, then fitting the black residual to a polynomial for the black
%    correction.  Cosmic rays are removed from black pixels (skipped for FFIs), and the black-corrected black pixels are saved for the
%    output.  The black-corrected smear pixels are saved in the intermediate struct for further calibration.  The black correction is saved
%    to a local .mat file for the calibration of photometric pixels.  If the POU (propagation of uncertainies) flag is enabled, the
%    uncertainties will be propagated throughout. 
%
%  - Correct for nonlinearity (if the linearity correction flag is enabled in the module parameters struct), and collect terms for
%    uncertainty propagation (if the POU flag is enabled). 
%
%  - Correct for gain and collect terms for uncertainty propagation (if the POU flag is enabled).
%
%  - Correct for LDE (local detector electronics) undershoot (if the undershoot correction flag is enabled) and collect terms for
%    uncertainty propagation (if the POU flag is enabled).
%
%  - Remove cosmic rays from masked and virtual smear pixels (if the cr correction flag is enabled), compute the cosmic ray metrics, and
%    collect terms for uncertainty propagation (if the POU flag is enabled).  For FFI calibration, outliers are removed in
%    coadd_ffi_collateral_data. 
%
%  - Estimate the smear and dark current levels, and save results to a local .mat file for the calibration of photometric pixels.  The
%    collateral pixels corrected for smear and dark current levels (residuals) can be saved.
%
%  - Compute the raw smear uncertainties (the shot noise needs to be computed after the undershoot correction is performed).
%
%  - Compute and return collateral (black, smear, and dark level) metrics.
%
%  - Create the CAL output structure from fields in the intermediate struct and the CAL object.  Output the transform struct if POU flag is
%    enabled. Output LC black correction struct if processLongCadence and performExpLc1DblackFit flags are enabled (except FFI).
%
%
% INPUT:
%       calObject (see cal_matlab_controller for field definitions)
%       calTransformStruct
%
% OUTPUT:
%       calOutputStruct
%       calTransformStruct
%       blackCorrectionStructLC
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

% extract flags
processFFI              = calObject.dataFlags.processFFI;
processShortCadence     = calObject.dataFlags.processShortCadence;
processLongCadence      = calObject.dataFlags.processLongCadence;
performExpLc1DblackFit  = calObject.dataFlags.performExpLc1DblackFit; 
dynamic2DBlackEnabled   = calObject.dataFlags.dynamic2DBlackEnabled;

%--------------------------------------------------------------------------
% all pixels are passed into CAL in structs or arrays of structs; save pixels,
% gaps, and row/column information into (nPixels x nCadences) arrays
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

calIntermediateStruct = repackage_data_for_calibration(calObject);

metrics_interval_stop('cal.calibrate_collateral_data.repackage_data_for_calibration.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: Repackaged data from structs to arrays', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% initialize or preallocate memory for calibrated data and save to
% intermediate stucture, which will be passed into subsequenct CAL functions
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

calIntermediateStruct = preallocate_memory_for_calibration(calObject, calIntermediateStruct);

metrics_interval_stop('cal.calibrate_collateral_data.preallocate_memory_for_calibration.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: Memory preallocated to collect data', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% extract relevant parameters from spacecraft config map
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

calIntermediateStruct = get_config_map_parameters(calObject, calIntermediateStruct);

metrics_interval_stop('cal.calibrate_collateral_data.get_config_map_parameters.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: Config map parameters extracted', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% compute raw black pixel uncertainties for all cadences
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct, calTransformStruct] = ...
    compute_collateral_raw_black_uncertainties(calObject, calIntermediateStruct, calTransformStruct);

metrics_interval_stop('cal.calibrate_collateral_data.compute_collateral_raw_black_uncertainties.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: Raw black uncertainties computed', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% correct all pixels for the fixed offset
%--------------------------------------------------------------------------
if ~processFFI
    tic;
    metricsKey = metrics_interval_start;
    
    [calObject, calIntermediateStruct] = correct_data_for_fixed_offset(calObject, calIntermediateStruct);
    
    metrics_interval_stop('cal.calibrate_collateral_data.correct_data_for_fixed_offset.execTimeMillis',metricsKey);
    display_cal_status('CAL:calibrate_collateral_data: Data corrected for fixed offset', 1);
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
    display_cal_status('CAL:calibrate_collateral_data: Data corrected for mean black', 1);
    display_memory(whos);
end

%--------------------------------------------------------------------------
% correct pixels for the number of spatial coadds (number of black columns,
% and/or smear rows that were summed onboard the spacecraft to yield the
% input collateral pixel data)
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct] = correct_collateral_data_for_spatial_coadds(calObject, calIntermediateStruct);

metrics_interval_stop('cal.calibrate_collateral_data.correct_collateral_data_for_spatial_coadds.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: Data corrected for spatial coadds', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% calibrate pixels for black level, remove cosmic rays from black pixels,
% and collect terms for uncertainty propagation
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct, calTransformStruct] = correct_collateral_pix_black_level(calObject, calIntermediateStruct, calTransformStruct);

metrics_interval_stop('cal.calibrate_collateral_data.correct_collateral_pix_black_level.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: Black level correction complete', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% correct for nonlinearity and collect terms for uncertainty propagation
%--------------------------------------------------------------------------
if (calObject.moduleParametersStruct.linearityCorrectionEnabled)
    tic;
    metricsKey = metrics_interval_start;
    
    [calObject, calIntermediateStruct, calTransformStruct] = correct_collateral_pix_nonlinearity(calObject, calIntermediateStruct, calTransformStruct);
    
    metrics_interval_stop('cal.calibrate_collateral_data.correct_collateral_pix_nonlinearity.execTimeMillis',metricsKey);
    display_cal_status('CAL:calibrate_collateral_data: Nonlinearity correction complete', 1);
    display_memory(whos);
end

%--------------------------------------------------------------------------
% correct for gain and collect terms for uncertainty propagation
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct, calTransformStruct] = correct_collateral_pix_for_gain(calObject, calIntermediateStruct, calTransformStruct);

metrics_interval_stop('cal.calibrate_collateral_data.correct_collateral_pix_for_gain.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: Gain correction complete', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% correct for LDE undershoot and collect terms for uncertainty propagation
%--------------------------------------------------------------------------
if (calObject.moduleParametersStruct.undershootEnabled)
    tic;
    metricsKey = metrics_interval_start;
    
    [calObject, calIntermediateStruct, calTransformStruct] = correct_collateral_pix_undershoot(calObject, calIntermediateStruct, calTransformStruct);
    
    metrics_interval_stop('cal.calibrate_collateral_data.correct_collateral_pix_undershoot.execTimeMillis',metricsKey);
    display_cal_status('CAL:calibrate_collateral_data: Undershoot correction complete', 1);
    display_memory(whos);
end

%--------------------------------------------------------------------------
% remove cosmic rays from masked and virtual smear pixel time series, compute
% collateral cosmic ray metrics, and collect terms for uncertainty propagation
%--------------------------------------------------------------------------
if (calObject.moduleParametersStruct.crCorrectionEnabled)
    if (calIntermediateStruct.nCadences > 1)
        tic;
        metricsKey = metrics_interval_start;
        
        [calObject, calIntermediateStruct] = correct_smear_pix_for_cosmic_rays(calObject, calIntermediateStruct);
        
        metrics_interval_stop('cal.calibrate_collateral_data.correct_smear_pix_for_cosmic_rays.execTimeMillis',metricsKey);
        display_cal_status('CAL:calibrate_collateral_data: Smear pixels corrected for cosmic rays', 1);
        display_memory(whos);
    end
end

%--------------------------------------------------------------------------
% determine smear and dark level estimates, and save results to local .mat file
% for the calibration of photometric pixels
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct, calTransformStruct] = get_smear_and_dark_levels(calObject, calIntermediateStruct, calTransformStruct);

metrics_interval_stop('cal.calibrate_collateral_data.get_smear_and_dark_levels.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: Smear and dark level estimation complete', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% propagate uncertainties for smear and dark level correction
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calObject, calIntermediateStruct, calTransformStruct] = compute_collateral_raw_smear_uncertainties(calObject, calIntermediateStruct, calTransformStruct);

metrics_interval_stop('cal.calibrate_collateral_data.compute_collateral_raw_smear_uncertainties.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data:  Raw smear uncertainties computed', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% compute and return collateral metrics
%--------------------------------------------------------------------------
if ~processFFI && ~processShortCadence
    tic;
    metricsKey = metrics_interval_start;
    
    [collateralMetrics] = compute_collateral_metrics(calObject, calIntermediateStruct);
    
    metrics_interval_stop('cal.calibrate_collateral_data.compute_collateral_metrics.execTimeMillis',metricsKey);
    calIntermediateStruct.collateralMetrics = collateralMetrics;
    display_cal_status('CAL:calibrate_collateral_data: Collateral metrics computation complete', 1);
    display_memory(whos);
end

%--------------------------------------------------------------------------
% parse blackCorrectionStructLC from calIntermediateStruct for output
%--------------------------------------------------------------------------
if processLongCadence && performExpLc1DblackFit && ~processFFI && ~dynamic2DBlackEnabled
    blackCorrectionStructLC = calIntermediateStruct.blackCorrectionStructLC;
    calIntermediateStruct = rmfield(calIntermediateStruct, 'blackCorrectionStructLC');
    display('CAL:calibrate_collateral_data: blackCorrectionStructLC parsed from calIntermediateStruct');
    display_memory(whos);
else
    blackCorrectionStructLC = [];
end

%--------------------------------------------------------------------------
% parse smearCorrectionStructLC from calIntermediateStruct for output
%--------------------------------------------------------------------------
if processLongCadence && ~processFFI
    smearCorrectionStructLC = calIntermediateStruct.smearCorrectionStructLC;
    calIntermediateStruct = rmfield(calIntermediateStruct, 'smearCorrectionStructLC');
    display('CAL:calibrate_collateral_data: smearCorrectionStructLC parsed from calIntermediateStruct');
    display_memory(whos);
else
    smearCorrectionStructLC = [];
end

%--------------------------------------------------------------------------
% create output structure with required fields
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calOutputStruct, calIntermediateStruct] = set_cal_output_struct(calObject, calIntermediateStruct, calTransformStruct);                 %#ok<NASGU>

metrics_interval_stop('cal.calibrate_collateral_data.set_cal_output_struct.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: CAL object and intermediate struct converted to CAL output struct', 1);
display_memory(whos);

%--------------------------------------------------------------------------
% validate fields in the output structure
%--------------------------------------------------------------------------
tic;
metricsKey = metrics_interval_start;

[calOutputStruct] = validate_cal_outputs(calOutputStruct, processFFI);

metrics_interval_stop('cal.calibrate_collateral_data.validate_cal_outputs.execTimeMillis',metricsKey);
display_cal_status('CAL:calibrate_collateral_data: CAL outputs validated', 1);

%--------------------------------------------------------------------------
% save figures and intermediate data struct from this invocation into 
% local directories
%--------------------------------------------------------------------------
tic;

% create new directory to save intermediate data
newDataDirectory = [calObject.localFilenames.stateFilePath,'collateral_data'];
mkdir(newDataDirectory);
save([newDataDirectory, '/calCollateralIntermediateDataStruct.mat'], 'calIntermediateStruct');
display_cal_status(['CAL:calibrate_collateral_data: calIntermediateStruct saved to dir: ' newDataDirectory], 1);
clear calIntermediateStruct
display('CAL:calibrate_collateral_data: CAL intermediate struct cleared');
display_memory(whos);

% create figures directory and move figures to this directory which will hold all successive figures in all CAL invocations
newFigureDirectory = [calObject.localFilenames.stateFilePath,'figures'];
eval(['mkdir ' newFigureDirectory]);
figures = dir('*.fig');
if ~isempty(figures)
    movefile('*.fig', newFigureDirectory);
    display_cal_status(['CAL:calibrate_collateral_data: Figures saved to dir: ' newFigureDirectory], 1);
end
