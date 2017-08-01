function outputsStruct = dynablack_convert_80_output_to_81(outputsStruct, calInputsStruct)
% function outputsStruct = dynablack_convert_80_output_to_81(outputsStruct, calInputsStruct)
%
% Update dynablack results struct from that produced in SOC 8.0 to that produced in SOC 8.1
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

DEFAULT_MASKED_SMEAR_ROW = 20;
validDynablackFit = true;
removeFixedOffset = false;
removeStatic2DBlack = false;


% set default valid fit to true
if ~isfield(outputsStruct,'validDynablackFit')
    outputsStruct.validDynablackFit = validDynablackFit;
end
     
if ~isfield(outputsStruct.A1ModelDump.Constants,'maxMaskedSmearRow')
    outputsStruct.A1ModelDump.Constants.maxMaskedSmearRow = DEFAULT_MASKED_SMEAR_ROW;
end

% add static 2D black image from cal inputsStruct if needed
if ~isfield(outputsStruct,'staticTwoDBlackImage')
    % get static 2D black - nCcdRows x nCcdColumns
    twoDBlackObject = twoDBlackClass(calInputsStruct.twoDBlackModel);
    outputsStruct.staticTwoDBlackImage = get_two_d_black(twoDBlackObject);
end

% add dynablackModuleParameters
if ~isfield(outputsStruct,'dynablackModuleParameters')
    outputsStruct.dynablackModuleParameters = seed_dynablack_module_parameters_with_defaults;
end


% update field names in dynablackResultsStruct.A1_fit_results.LC
LC = outputsStruct.A1_fit_results.LC;
if isfield(LC,'thermal_row_offset')
    LC.thermalRowOffset = LC.thermal_row_offset;
    LC = rmfield(LC,'thermal_row_offset');
end
outputsStruct.A1_fit_results.LC = LC;

% update field names in dynablackResultsStruct.A1_fit_results.FFI
FFI = outputsStruct.A1_fit_results.FFI;
if isfield(FFI,'thermal_row_offset')
    FFI.thermalRowOffset = FFI.thermal_row_offset;
    FFI = rmfield(FFI,'thermal_row_offset');
end
outputsStruct.A1_fit_results.FFI = FFI;

% update field names in dynablackResultsStruct.A1ModelDump.Inputs.controls
controls = outputsStruct.A1ModelDump.Inputs.controls;
removeList = {};
if isfield(controls,'parallel_pixel_select')
    controls.parallelPixelSelect = controls.parallel_pixel_select;
    removeList{length(removeList)+1} = 'parallel_pixel_select';
end
if isfield(controls,'frame_pixel_select')    
    controls.framePixelSelect = controls.frame_pixel_select;
    removeList{length(removeList)+1} = 'frame_pixel_select';
end
if isfield(controls,'leading_column_select')    
    controls.leadingColumnSelect = controls.leading_column_select;
    removeList{length(removeList)+1} = 'leading_column_select';
end
if isfield(controls,'thermal_row_offset')    
    controls.thermalRowOffset = controls.thermal_row_offset;
    removeList{length(removeList)+1} = 'thermal_row_offset';
end
if isfield(controls,'default_row_time_constant')    
    controls.defaultRowTimeConstant = controls.default_row_time_constant;
    removeList{length(removeList)+1} = 'default_row_time_constant';
end
if isfield(controls,'min_undershoot_row')    
    controls.minUndershootRow = controls.min_undershoot_row;
    removeList{length(removeList)+1} = 'min_undershoot_row';
end
if isfield(controls,'max_undershoot_row')    
    controls.maxUndershootRow = controls.max_undershoot_row;
    removeList{length(removeList)+1} = 'max_undershoot_row';
end
if isfield(controls,'undershoot_span_0')    
    controls.undershootSpan0 = controls.undershoot_span_0;
    removeList{length(removeList)+1} = 'undershoot_span_0';
end
if isfield(controls,'undershoot_span')    
    controls.undershootSpan = controls.undershoot_span;
    removeList{length(removeList)+1} = 'undershoot_span';
end
if isfield(controls,'ScDPix_threshold')    
    controls.scDPixThreshold = controls.ScDPix_threshold;
    removeList{length(removeList)+1} = 'ScDPix_threshold';
end
if isfield(controls,'nearTB_Minpix')    
    controls.nearTbMinpix = controls.nearTB_Minpix;
    removeList{length(removeList)+1} = 'nearTB_Minpix';
end

controls = rmfield(controls,removeList);
outputsStruct.A1ModelDump.Inputs.controls = controls;                            



