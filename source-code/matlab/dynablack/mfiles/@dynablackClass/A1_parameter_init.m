function [ initInfo, inputs ] = A1_parameter_init( dynablackObject )
%
% function [ initInfo, inputs ] = A1_parameter_init( dynablackObject )
% 
% Initialize linear fit parameters for vertical spatial fitting. Identify scene dependent regions from ffi data and explicitly exclude these
% pixels from the fits.
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


% hard coded
minGoodRows = 5;
nSegmentRows = 50;

% extract parameters from dynablack object and set up control structure for A1 fits
module = dynablackObject.ccdModule;
output = dynablackObject.ccdOutput;
channel = convert_from_module_output( module, output );

moduleParameters                = dynablackObject.dynablackModuleParameters;
removeStatic2DBlack             = moduleParameters.removeStatic2DBlack; 
NUM_PREDICTOR_ROWS              = moduleParameters.a1NumPredictorRows;
NUM_NONLINEAR_PREDICTOR_ROWS    = moduleParameters.a1NumNonlinearPredictorRows;
NUM_FFI_PREDICTOR_ROWS          = moduleParameters.a1NumFfiPredictorRows;

fcConstants         = dynablackObject.fcConstants;
NUM_ROWS            = fcConstants.CCD_ROWS;
NUM_COLUMNS         = fcConstants.CCD_COLUMNS;
maxMaskedSmearRow   = fcConstants.MASKED_SMEAR_END+1;  %JK111006

% find the masked smear rows used
cmObj = configMapClass(dynablackObject.spacecraftConfigMap);
msStartRow = median(get_masked_smear_start_row(cmObj));
msEndRow = median(get_masked_smear_end_row(cmObj));
msRows = msStartRow:msEndRow;

validCadenceIndices = find(~dynablackObject.cadenceTimes.gapIndicators);

[CONTROLS, BOUNDS] = extract_dynablack_controls_and_bounds(dynablackObject);

inputs = struct('channel_list', channel,...
                'ffi_list',     1:length(dynablackObject.rawFfis),...
                'FCLC_list',    validCadenceIndices,...
                'controls',     CONTROLS,...
                'bounds',       BOUNDS); 
    
% load pre-fit long and short exponential time constants for conditional 1D black two exponential fit
rowTimeConstants = load_row_time_constants();
idx = find(rowTimeConstants(:,1) == channel);
shortTimeConstant = rowTimeConstants(idx,3);
longTimeConstant = rowTimeConstants(idx,2); 
rowTimeConstant = shortTimeConstant;
           
% initialize constants structure
constants = struct('FCLC_count',                       length(inputs.FCLC_list), ...
                   'FFI_count',                        length(dynablackObject.rawFfis), ...
                   'channel_count',                    1, ...
                   'FCLC_list',                        inputs.FCLC_list, ...
                   'FFI_list',                         inputs.ffi_list, ...
                   'channel_list',                     inputs.channel_list, ...
                   'ffi_row_count',                    NUM_ROWS, ...
                   'ffi_column_count',                 NUM_COLUMNS, ...
                   'row_predictor_count',              NUM_PREDICTOR_ROWS, ...
                   'nl_row_predictor_count',           NUM_NONLINEAR_PREDICTOR_ROWS, ...
                   'ffi_row_predictor_count',          NUM_FFI_PREDICTOR_ROWS,...
                   'longTimeConstant',                 longTimeConstant, ...
                   'shortTimeConstant',                shortTimeConstant, ...
                   'maxMaskedSmearRow',                maxMaskedSmearRow);
               
            
% Note: In pipeline implementation, channel_count will always == 1, channel_list will have a single entry
            
% DEFINE REGIONS OF INTEREST (ROI)
% Regions of interest are rectangular regions of an image which have information which is useful to the fit algorithm.
% Also, a three character identifier is specified for each ROI. 
ROI = struct('leadingArp',       DataSubset( inputs.bounds.leadingArp.Rmin, inputs.bounds.leadingArp.Rmax, ...
                                                  inputs.bounds.leadingArp.Cmin, inputs.bounds.leadingArp.Cmax, 'LA1' ), ...
             'trailingArp',      DataSubset( inputs.bounds.trailingArp.Rmin, inputs.bounds.trailingArp.Rmax, ...
                                                  inputs.bounds.trailingArp.Cmin, inputs.bounds.trailingArp.Cmax, 'TA1' ), ...
             'trailingArpUs',   DataSubset( inputs.bounds.trailingArpUs.Rmin, inputs.bounds.trailingArpUs.Rmax, ...
                                                  inputs.bounds.trailingArpUs.Cmin, inputs.bounds.trailingArpUs.Cmax, 'TA2' ), ...
             'trailingCollat',   DataSubset( inputs.bounds.trailingCollat.Rmin, inputs.bounds.trailingCollat.Rmax, ...
                                                  inputs.bounds.trailingCollat.Cmin, inputs.bounds.trailingCollat.Cmax, 'TC1' ), ...
             'neartrailingArp',  DataSubset( inputs.bounds.neartrailingArp.Rmin, inputs.bounds.neartrailingArp.Rmax, ...
                                                  inputs.bounds.neartrailingArp.Cmin, inputs.bounds.neartrailingArp.Cmax, 'NA1' ), ...
             'trailingFfi',      DataSubset( inputs.bounds.trailingFfi.Rmin, inputs.bounds.trailingFfi.Rmax, ...
                                                  inputs.bounds.trailingFfi.Cmin, inputs.bounds.trailingFfi.Cmax, 'TF1' ));

% initialize spatial constants
fgsClockStates = get_fgs_clock_states;
frameImage = fgsClockStates.Frame;
parallelImage = fgsClockStates.Parallel;

% get arp pixels on-baed row/column coordinates from object
% ARP pixels are the only target and background FC pixels used
pixelStructArray = dynablackObject.arpTargetPixels;
pixelRow = [pixelStructArray.row]';
pixelCol = [pixelStructArray.column]';

% INITIALIZE LEADING BLACK ARP ROI
% Determines pixel count in ROI and initilizes arrays (to zeros)
ROI.leadingArp = initialize(ROI.leadingArp, 1, length(find(pixelRow >= ROI.leadingArp.Row_min & ...
                                                             pixelRow <= ROI.leadingArp.Row_max & ...
                                                             pixelCol >= ROI.leadingArp.Column_min & ...
                                                             pixelCol <= ROI.leadingArp.Column_max)), 0);

% INITIALIZE TRAILING BLACK ARP ROI: PART1
% Determines pixel count in ROI and initilizes arrays (to zeros)
ROI.trailingArp = initialize(ROI.trailingArp, 1, length(find(pixelRow >= ROI.trailingArp.Row_min & ...
                                                               pixelRow <= ROI.trailingArp.Row_max & ...
                                                               pixelCol >= ROI.trailingArp.Column_min & ...
                                                               pixelCol <= ROI.trailingArp.Column_max)), ROI.leadingArp.Last);

% INITIALIZE TRAILING BLACK ARP ROI: PART2 FOR VIRT. SMEAR/UNDERSHOOT
% Determines pixel count in ROI and initilizes arrays (to zeros)
ROI.trailingArpUs = initialize(ROI.trailingArpUs, 1, length(find(pixelRow >= ROI.trailingArpUs.Row_min & ...
                                                                     pixelRow <= ROI.trailingArpUs.Row_max & ...
                                                                     pixelCol >= ROI.trailingArpUs.Column_min & ...
                                                                     pixelCol <= ROI.trailingArpUs.Column_max)), ROI.trailingArp.Last);

% INITIALIZE TRAILING BLACK COLLATERAL ROI
% Determines pixel count in ROI and initilizes arrays (to zeros)
% Determines which collateral rows consist of entirely of ARP pixels (these are excluded since they contain no new information)
trailingCollateralRows = ROI.trailingCollat.Row_min:ROI.trailingCollat.Row_max;
trailingCollateralCols = ROI.trailingCollat.Column_min:ROI.trailingCollat.Column_max;

trailingCollateralFrameImage = frameImage(trailingCollateralRows, trailingCollateralCols);
trailingCollateralParallelImage = parallelImage(trailingCollateralRows, trailingCollateralCols);
          
allFgsRowIndexFrame = any( ~ismember( trailingCollateralFrameImage, inputs.controls.framePixelSelect ), 2 );
allFgsRowIndexParallel = any( ~ismember( trailingCollateralParallelImage, inputs.controls.parallelPixelSelect), 2 );
allFgsRowIndex = min( allFgsRowIndexFrame, allFgsRowIndexParallel );

% Initialize data subsets
ROI.trailingCollat = initialize( ROI.trailingCollat,...
                                   1,...
                                   length( find( allFgsRowIndex == 1 ) ),...
                                   ROI.trailingArpUs.Last);

ROI.neartrailingArp = initialize( ROI.neartrailingArp,...
                                    1,...
                                    length(find(pixelRow >= ROI.neartrailingArp.Row_min & ...
                                                pixelRow <= ROI.neartrailingArp.Row_max & ...
                                                pixelCol >= ROI.neartrailingArp.Column_min & ...
                                                pixelCol <= ROI.neartrailingArp.Column_max)),...
                                    ROI.trailingCollat.Last);

ROI.trailingFfi = initialize( ROI.trailingFfi,...
                                1,...
                                (ROI.trailingFfi.Row_max - ROI.trailingFfi.Row_min + 1) *...
                                    (ROI.trailingFfi.Column_max - ROI.trailingFfi.Column_min + 1),...
                                0);
   

% INITIALIZE MODEL COMPONENTS
% Creates a structure of ModelComponent-class objects representing distinct
% model elements. A 2 character identifier is assigned to each element.

% Determine total number of pixels + collateral points in modeled LC regions (datum = pixels or collateral point)
pixCount = ROI.trailingCollat.Datum_count + ...
           ROI.leadingArp.Datum_count + ...
           ROI.trailingArp.Datum_count +...
           ROI.trailingArpUs.Datum_count;

% Initialize elements of LC model into fclcModel structure
fclcModel = struct('pixel_count',      pixCount, ...
                    'frame_pixels',    ModelComponent(length(inputs.controls.framePixelSelect), pixCount, 'FP'),...
                    'frame_delta',     ModelComponent(length(inputs.controls.framePixelSelect), pixCount, 'FD'),...
                    'parallel_pixels', ModelComponent(length(inputs.controls.parallelPixelSelect), pixCount, 'PP'),...
                    'parallel_delta',  ModelComponent(length(inputs.controls.parallelPixelSelect), pixCount, 'PD'),...
                    'rows',            ModelComponent(constants.row_predictor_count, pixCount, 'RW'),...
                    'columns',         ModelComponent(length(inputs.controls.leadingColumnSelect), pixCount, 'CL'),...
                    'rows_nl',         ModelComponent(constants.nl_row_predictor_count, pixCount, 'RN')); 

% Determine total number of pixels+collateral points in modeled FFI region
ffiPixelCount = ROI.trailingFfi.Datum_count;

% Initialize elements of FFI model into ffiModel structure
ffiModel = struct('pixel_count',       ffiPixelCount, ...
                    'frame_pixels',    ModelComponent(length(inputs.controls.framePixelSelect), ffiPixelCount, 'FP'),...
                    'parallel_pixels', ModelComponent(length(inputs.controls.parallelPixelSelect), ffiPixelCount, 'PP'),...
                    'rows',            ModelComponent(constants.ffi_row_predictor_count, ffiPixelCount, 'RW')); 
                   
% INITIALIZE ROI INDICES, ROWS & COLUMNS FOR LCs
ROI.leadingArp.Index = find(pixelRow >= ROI.leadingArp.Row_min & ...
                             pixelRow <= ROI.leadingArp.Row_max & ...
                             pixelCol >= ROI.leadingArp.Column_min & ...
                             pixelCol <= ROI.leadingArp.Column_max);
ROI.trailingArp.Index = find(pixelRow >= ROI.trailingArp.Row_min & ...
                              pixelRow <= ROI.trailingArp.Row_max & ...
                              pixelCol >= ROI.trailingArp.Column_min & ...
                              pixelCol <= ROI.trailingArp.Column_max);
ROI.trailingArpUs.Index = find(pixelRow >= ROI.trailingArpUs.Row_min & ...
                                 pixelRow <= ROI.trailingArpUs.Row_max & ...
                                 pixelCol >= ROI.trailingArpUs.Column_min & ...
                                 pixelCol <= ROI.trailingArpUs.Column_max);
ROI.neartrailingArp.Index = find(pixelRow >= ROI.neartrailingArp.Row_min & ...
                                  pixelRow <= ROI.neartrailingArp.Row_max & ...
                                  pixelCol >= ROI.neartrailingArp.Column_min & ...
                                  pixelCol <= ROI.neartrailingArp.Column_max);


% Determine index for collateral files (channel-independent)
ROI.trailingCollat.Index = find(allFgsRowIndex'==1) + ROI.trailingCollat.Row_min - 1;

% Determine rows and columns for the pixels in each ROI (channel-independent)
ROI.leadingArp.Rows         = pixelRow(ROI.leadingArp.Index);
ROI.leadingArp.Columns      = pixelCol(ROI.leadingArp.Index);
ROI.trailingArp.Rows        = pixelRow(ROI.trailingArp.Index);     
ROI.trailingArp.Columns     = pixelCol(ROI.trailingArp.Index);     
ROI.trailingArpUs.Rows      = pixelRow(ROI.trailingArpUs.Index);     
ROI.trailingArpUs.Columns   = pixelCol(ROI.trailingArpUs.Index);     
ROI.neartrailingArp.Rows    = pixelRow(ROI.neartrailingArp.Index);     
ROI.neartrailingArp.Columns = pixelCol(ROI.neartrailingArp.Index);

% ROI.trailingCollat.Columns is not needed
ROI.trailingCollat.Rows = (ROI.trailingCollat.Index)';

% INITIALIZE ROI INDICES, ROWS & COLUMNS FOR FFIs
% Sets ModelComponent-class object values
ffiRowRange             = ROI.trailingFfi.Row_min:ROI.trailingFfi.Row_max;
ffiColumnRange          = ROI.trailingFfi.Column_min:ROI.trailingFfi.Column_max;
ffiRoiRows              = ffiRowRange'*ones(1,length(ffiColumnRange));
ffiRoiColumns           = ones(length(ffiRowRange),1) * ffiColumnRange;
ROI.trailingFfi.Index   = ( ffiRoiColumns(:) - 1 ) * constants.ffi_row_count + ffiRoiRows(:);
ROI.trailingFfi.Rows    = ffiRoiRows(:);
ROI.trailingFfi.Columns = ffiRoiColumns(:);


% INITIALIZE FGS FRAME & PARALLEL CLOCK STATE SEQUENCE NUMBERS FOR FFI ROI AND MODEL
% Sets ModelComponent-class object values

% Extract FGS-frame pixel model elements
framePixelImageFfi = frameImage(ffiRowRange,ffiColumnRange);
ROI.trailingFfi.FGS_frame_clockstates = framePixelImageFfi(:);

% Define model predictor columns (column k acts as Kronecker-delta for kth FGS-frame pixel type)
for k = 1:ffiModel.frame_pixels.Predictor_count
    ffiModel.frame_pixels.Matrix(k,ROI.trailingFfi.First:ROI.trailingFfi.Last) = ...
                ROI.trailingFfi.FGS_frame_clockstates==inputs.controls.framePixelSelect(k);
end

% Extract FGS-parallel pixel model elements
parallel_pixel_imageffi = parallelImage(ffiRowRange,ffiColumnRange);
ROI.trailingFfi.FGS_parallel_clockstates = parallel_pixel_imageffi(:);

% Define model predictor columns (column k acts as Kronecker-delta for kth FGS-parallel pixel type)
for k = 1:ffiModel.parallel_pixels.Predictor_count
    ffiModel.parallel_pixels.Matrix(k,ROI.trailingFfi.First:ROI.trailingFfi.Last) = ...
                ROI.trailingFfi.FGS_parallel_clockstates==inputs.controls.parallelPixelSelect(k);
end

% Define model predictor columns for row dependence of serial pixels (constant term + exponential term + logarithmic term)
ffipix_const  = ones(1,ROI.trailingFfi.Datum_count);
ffipix_exprow = exp(-ROI.trailingFfi.Rows'/rowTimeConstant);
ffipix_logrow = log(ROI.trailingFfi.Rows'/inputs.controls.thermalRowOffset+1);

ffiModel.rows.Matrix = [ ffipix_const; ffipix_logrow; ffipix_exprow];


% INITIALIZE FGS FRAME CLOCK STATE SEQUENCE NUMBERS FOR LC ROI AND MODEL
% Sets ModelComponent-class object values

% extract FGS-frame pixel model elements for leading ARP pixels
for k = 1:ROI.leadingArp.Datum_count
    ROI.leadingArp.FGS_frame_clockstates(k) = ...
        frameImage(ROI.leadingArp.Rows(k),ROI.leadingArp.Columns(k));
end

for k = 1:fclcModel.frame_pixels.Predictor_count
    fclcModel.frame_pixels.Matrix(k,ROI.leadingArp.First:ROI.leadingArp.Last) = ...
                       ROI.leadingArp.FGS_frame_clockstates == inputs.controls.framePixelSelect(k);
    fclcModel.frame_delta.Matrix(k,ROI.leadingArp.First:ROI.leadingArp.Last) = ...
                       ROI.leadingArp.FGS_frame_clockstates == inputs.controls.framePixelSelect(k);
end
    
% extract FGS-frame pixel model elements for trailing ARP pixels
for k = 1:ROI.trailingArp.Datum_count
    ROI.trailingArp.FGS_frame_clockstates(k) = ...
        frameImage(ROI.trailingArp.Rows(k),ROI.trailingArp.Columns(k));
end

for k = 1:fclcModel.frame_pixels.Predictor_count
    fclcModel.frame_pixels.Matrix(k,ROI.trailingArp.First:ROI.trailingArp.Last) = ...
                       ROI.trailingArp.FGS_frame_clockstates == inputs.controls.framePixelSelect(k);
end

for k = 1:ROI.trailingArpUs.Datum_count
    ROI.trailingArpUs.FGS_frame_clockstates(k) = ...
        frameImage(ROI.trailingArpUs.Rows(k),ROI.trailingArpUs.Columns(k));
end
for k = 1:fclcModel.frame_pixels.Predictor_count
    fclcModel.frame_pixels.Matrix(k,ROI.trailingArpUs.First:ROI.trailingArpUs.Last) = ...
                       ROI.trailingArpUs.FGS_frame_clockstates == inputs.controls.framePixelSelect(k);
end

% extract FGS-frame pixel model elements for collateral trailing black
for k = 1:fclcModel.frame_pixels.Predictor_count
    frame_rows = sum( trailingCollateralFrameImage == inputs.controls.framePixelSelect(k),2 );
    fclcModel.frame_pixels.Matrix(k,ROI.trailingCollat.First:ROI.trailingCollat.Last) = frame_rows(allFgsRowIndex);
end


% INITIALIZE FGS PARALLEL CLOCK STATE SEQUENCE NUMBERS FOR LC ROI AND MODEL
% Sets ModelComponent-class object values

% extract FGS-parallel pixel model elements for leading ARP pixels
for k = 1:ROI.leadingArp.Datum_count
    ROI.leadingArp.FGS_parallel_clockstates(k) = ...
        parallelImage(ROI.leadingArp.Rows(k),ROI.leadingArp.Columns(k));
end

for k = 1:fclcModel.parallel_pixels.Predictor_count
    fclcModel.parallel_pixels.Matrix(k,ROI.leadingArp.First:ROI.leadingArp.Last) = ...
                ROI.leadingArp.FGS_parallel_clockstates == inputs.controls.parallelPixelSelect(k);
    fclcModel.parallel_delta.Matrix(k,ROI.leadingArp.First:ROI.leadingArp.Last) = ...
                ROI.leadingArp.FGS_parallel_clockstates == inputs.controls.parallelPixelSelect(k);
end
    
% extract FGS-parallel pixel model elements for trailing ARP pixels
for k = 1:ROI.trailingArp.Datum_count
    ROI.trailingArp.FGS_parallel_clockstates(k) = ...
        parallelImage(ROI.trailingArp.Rows(k),ROI.trailingArp.Columns(k));
end

for k = 1:fclcModel.parallel_pixels.Predictor_count
    fclcModel.parallel_pixels.Matrix(k,ROI.trailingArp.First:ROI.trailingArp.Last) = ...
                ROI.trailingArp.FGS_parallel_clockstates == inputs.controls.parallelPixelSelect(k);
end

for k = 1:ROI.trailingArpUs.Datum_count
    ROI.trailingArpUs.FGS_parallel_clockstates(k) = ...
        parallelImage(ROI.trailingArpUs.Rows(k),ROI.trailingArpUs.Columns(k));
end

for k = 1:fclcModel.parallel_pixels.Predictor_count
    fclcModel.parallel_pixels.Matrix(k,ROI.trailingArpUs.First:ROI.trailingArpUs.Last) = ...
                ROI.trailingArpUs.FGS_parallel_clockstates == inputs.controls.parallelPixelSelect(k);
end

% Extract FGS-parallel pixel model elements for collateral trailing black
for k = 1:fclcModel.parallel_pixels.Predictor_count
    parallel_rows = sum( trailingCollateralParallelImage == inputs.controls.parallelPixelSelect(k),2 );
    fclcModel.parallel_pixels.Matrix(k,ROI.trailingCollat.First:ROI.trailingCollat.Last) = parallel_rows(allFgsRowIndex);
end


% INITIALIZE COLUMN DEPENDENCE FOR LEADING BLACK PIXELS IN MODEL
% Sets ModelComponent-class object values
for k = 1:fclcModel.columns.Predictor_count    
    fclcModel.columns.Matrix(k,ROI.leadingArp.First:ROI.leadingArp.Last) = ...
        ROI.leadingArp.Columns == inputs.controls.leadingColumnSelect(k);
end

% INITIALIZE ROW DEPENDENCE FOR ALL PIXELS IN MODEL
% Sets ModelComponent-class object values. Model includes all-pixel terms plus a delta term for differences between leading and
% trailing black (non-zero for leading black only).

% normalization to the first science row makes the exponential elements consistent with those used in the CAL two exponential 1D black
minScienceRow = maxMaskedSmearRow + 1;

leading_const   = [ones( 1, ROI.leadingArp.Datum_count) ...
                      zeros( 1, ROI.trailingArp.Datum_count) ...
                      zeros( 1, ROI.trailingArpUs.Datum_count) ...
                      zeros( 1, ROI.trailingCollat.Datum_count)];
allpix_const    = [ROI.leadingArp.Rows' > maxMaskedSmearRow  ...
                      ROI.trailingArp.Rows' > maxMaskedSmearRow ...
                      ROI.trailingArpUs.Rows' > maxMaskedSmearRow ...
                      (ROI.trailingCollat.Rows' > maxMaskedSmearRow) .* ROI.trailingCollat.Column_count];
allpix_rownum   = [ROI.leadingArp.Rows' ...
                      ROI.trailingArp.Rows' ...
                      ROI.trailingArpUs.Rows' ...
                      ROI.trailingCollat.Rows'];
leading_exprow  = [exp( -(ROI.leadingArp.Rows' - minScienceRow)./rowTimeConstant ) ...
                      zeros( 1, ROI.trailingArp.Datum_count) ...
                      zeros( 1, ROI.trailingArpUs.Datum_count) ...
                      zeros( 1, ROI.trailingCollat.Datum_count)].*allpix_const;
allpix_exprow   = [exp( -(ROI.leadingArp.Rows' - minScienceRow)./rowTimeConstant ) ...
                      exp( -(ROI.trailingArp.Rows' - minScienceRow)./rowTimeConstant ) ...
                      exp( -(ROI.trailingArpUs.Rows' - minScienceRow)./rowTimeConstant ) ...
                      exp( -(ROI.trailingCollat.Rows' - minScienceRow)./rowTimeConstant )].*allpix_const;
                  
if  removeStatic2DBlack
    
    % a message!
    display('   ');
    display(['Pre fit short row time constant = ',num2str(shortTimeConstant)]);
    display(['Pre fit long row time constant = ',num2str(longTimeConstant)]);
    display('   ');    
    
    leading_long_time_scale  = [exp( -(ROI.leadingArp.Rows' - minScienceRow)./longTimeConstant ) ...
                                  zeros(1,ROI.trailingArp.Datum_count) ...
                                  zeros(1,ROI.trailingArpUs.Datum_count) ...
                                  zeros(1,ROI.trailingCollat.Datum_count)].*allpix_const;
    allpix_long_time_scale   = [exp( -(ROI.leadingArp.Rows' - minScienceRow)./longTimeConstant ) ...
                                   exp( -(ROI.trailingArp.Rows' - minScienceRow)./longTimeConstant ) ...
                                   exp( -(ROI.trailingArpUs.Rows' - minScienceRow)./longTimeConstant ) ...
                                   exp( -(ROI.trailingCollat.Rows' - minScienceRow)./longTimeConstant )].*allpix_const;
else
    
    leading_long_time_scale  = [log( ROI.leadingArp.Rows'./inputs.controls.thermalRowOffset + 1 ) ...
                                  zeros(1,ROI.trailingArp.Datum_count) ...
                                  zeros(1,ROI.trailingArpUs.Datum_count) ...
                                  zeros(1,ROI.trailingCollat.Datum_count)].*allpix_const;
    allpix_long_time_scale   = [log( ROI.leadingArp.Rows'./inputs.controls.thermalRowOffset + 1) ...
                                  log( ROI.trailingArp.Rows'./inputs.controls.thermalRowOffset + 1) ...
                                  log( ROI.trailingArpUs.Rows'./inputs.controls.thermalRowOffset + 1) ...
                                  log( ROI.trailingCollat.Rows'./inputs.controls.thermalRowOffset + 1)].*allpix_const;   
end

maskedSmearRow_const    = [ROI.leadingArp.Rows'<= maxMaskedSmearRow ...
                           ROI.trailingArp.Rows'<= maxMaskedSmearRow ...
                           ROI.trailingArpUs.Rows' <= maxMaskedSmearRow ...
                           (ROI.trailingCollat.Rows'<= maxMaskedSmearRow) .* ROI.trailingCollat.Column_count];
                      
maskedSmearRow_linear = allpix_rownum.*maskedSmearRow_const;

allpix_linear = allpix_rownum.*allpix_const;

fclcModel.rows.Matrix   = [ones(1,fclcModel.rows.Datum_count); ...
                           allpix_const; ...
                           allpix_linear; ...
                           allpix_long_time_scale; ...
                           allpix_exprow; ...
                           leading_const; ...
                           leading_long_time_scale; ...
                           leading_exprow; ...
                           maskedSmearRow_const; ...
                           maskedSmearRow_linear];
                       
% Identify rows in fclcModel.rows.Matrix as containing 'linear' coeffs. 
% These are the rows that participate in the vertical (1D black) fit for dynablack retrieval.
initInfo.rowsModelLinearRows = [2:5,9:10];

fclcModel.rows_nl.Matrix = [allpix_rownum;...
                               ones(1,fclcModel.rows_nl.Datum_count);...
                               allpix_const;...
                               leading_const]; 

% DETERMINE POTENTIALLY SCENE-DEPENDENT-ARTIFACT-AFFECTED ROWS FOR ALL CHANNELS
% Excluderows containing pixels above inputs.controls.scDPixThreshold DN/read level which occur after column: inputs.controls.nearTbMinpix, and any row within 
% +/- inputs.controls.blurPix of such a row.

ffiNames = {dynablackObject.rawFfis.fileName};

% Set up input structure for FlagSceneDependent function
ScDInputs = struct('ffi_list',      {ffiNames},...
                    'channel_list', inputs.channel_list,...
                    'threshold',    inputs.controls.scDPixThreshold);

% Call FlagSceneDependent function
RowxRow_AboveThreshold1 = flag_scene_dependent( dynablackObject, ScDInputs );
    
% Determine list of potentially scene-dependent rows
ScD_rows = find( RowxRow_AboveThreshold1.last_column > inputs.controls.nearTbMinpix );

% Expand +/- to blur image
if inputs.controls.blurPix > 0
    ScD_VBlured_rows = ScD_rows * ones(1,2*inputs.controls.blurPix + 1) + ones(size(ScD_rows)) * (-inputs.controls.blurPix:inputs.controls.blurPix);
    ScD_row_set = unique(ScD_VBlured_rows(:));
else
    ScD_row_set = ScD_rows;
end

% require there are at least minGoodRows non-scene dependent rows in the masked smear region as well as in the nSegmentRows row segments for row 21-1070
nLargeSegments = ceil((NUM_ROWS - maxMaskedSmearRow)/nSegmentRows);

for iSegment = 0:nLargeSegments
    % masked smear region is a special case
    if iSegment == 0
        rowSet = msRows;
    else
        rowSet = (1:nSegmentRows) + maxMaskedSmearRow + (iSegment - 1) * nSegmentRows;
    end        

    % find the good rows
    sdRow = ismember(rowSet,ScD_row_set);
    nGoodRows = numel(find(~sdRow));

    if nGoodRows < minGoodRows
        % select enough of the best of the bad rows to get minGoodRows
        badRows = rowSet(sdRow);
        badValues = RowxRow_AboveThreshold1.last_value(badRows);

        % sort by value low to high
        sortedTable = sortrows([badRows(:), badValues(:)], 2);

        % remove 'the best' rows from ScD_row_set
        if size(sortedTable,1) >= minGoodRows - nGoodRows
            % if there are enough rows to make minGoodRows
            ScD_row_set = setdiff(ScD_row_set, sortedTable(1:(minGoodRows - nGoodRows), 1));
        else
            % if not enough rows to make minGoodRows remove whatever are available
            ScD_row_set = setdiff(ScD_row_set, sortedTable(:, 1));
        end
    end
end
    
% Create index which excludes potentially scene-dependent rows
ScD_index = ~ismember(allpix_rownum,ScD_row_set);


% INITIALIZE INDICES TO EXCLUDE SCENE DEPENDENT ROWS IN MODELS
% Calling model_subset ensures that no model predictor columns are all zero. Does not yet preclude rank deficency.
fclcModel.frame_pixels     = model_subset(fclcModel.frame_pixels, 1, ScD_index);
fclcModel.frame_delta      = model_subset(fclcModel.frame_delta, 1, ScD_index);
fclcModel.parallel_pixels  = model_subset(fclcModel.parallel_pixels, 1, ScD_index);
fclcModel.parallel_delta   = model_subset(fclcModel.parallel_delta, 1, ScD_index);
fclcModel.rows             = model_subset(fclcModel.rows, 1, ScD_index);
fclcModel.columns          = model_subset(fclcModel.columns, 1, ScD_index);
fclcModel.rows_nl          = model_subset(fclcModel.rows_nl, 1, ScD_index & allpix_const~=0);

% no scene-dependent exclusion for FFIs
allIndex                   = true(1,ffiModel.pixel_count);
ffiModel.frame_pixels      = model_subset(ffiModel.frame_pixels, 1, allIndex);
ffiModel.parallel_pixels   = model_subset(ffiModel.parallel_pixels, 1, allIndex);
ffiModel.rows              = model_subset(ffiModel.rows, 1, allIndex);

% assemble return data structure
initInfo.Constants     = constants;
initInfo.ROI           = ROI;
initInfo.FCLC_Model    = fclcModel;
initInfo.FFI_Model     = ffiModel;



