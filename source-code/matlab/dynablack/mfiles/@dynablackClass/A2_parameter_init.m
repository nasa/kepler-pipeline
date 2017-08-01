function [initInfo, inputs] = A2_parameter_init( dynablackObject )
%
% function [initInfo, inputs] = A2_parameter_init( dynablackObject )
%  
% Initializes linear fit parameters for RCLC & FCLC horizontal spatial fitting.
% Called by A2_main.
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


% extract parameters from dynablack object
SKIP_DIFF                   = dynablackObject.dynablackModuleParameters.a2SkipDiff;
COLUMN_PREDICTOR_COUNT      = dynablackObject.dynablackModuleParameters.a2ColumnPredictorCount;
LEAD_COLUMN_PREDICTOR_COUNT = dynablackObject.dynablackModuleParameters.a2LeadColumnPredictorCount;
SMEAR_PREDICTOR_COUNT       = dynablackObject.dynablackModuleParameters.a2SmearPredictorCount;
SOL_RANGE                   = dynablackObject.dynablackModuleParameters.a2SolRange;
SOL_START                   = dynablackObject.dynablackModuleParameters.a2SolStart;
reverseClockedEnabled       = dynablackObject.dynablackModuleParameters.reverseClockedEnabled;

% build relative cadence lists
fcRelativeCadenceList = find(~dynablackObject.cadenceTimes.gapIndicators);
fcValidCadenceNumbers = dynablackObject.cadenceTimes.cadenceNumbers(fcRelativeCadenceList);
if reverseClockedEnabled
    rcRelativeCadenceList = find(~dynablackObject.reverseClockedCadenceTimes.gapIndicators);
    rcCadenceNumbers      = dynablackObject.reverseClockedCadenceTimes.cadenceNumbers(rcRelativeCadenceList);
else
    rcRelativeCadenceList = [];
    rcCadenceNumbers = [];
end

% SET UP RC AND FC GROUPS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Form RC groups from rc cadence number list - these are rc cadences at most one cadence number away from their nearest neighbor
rcBreakpoints = [find(diff(rcCadenceNumbers) > 1); length(rcCadenceNumbers)];
RC_groups = repmat(cell(1),length(rcBreakpoints),1);
initialIndex = 1;
for iBP = 1:length(rcBreakpoints)
    RC_groups(iBP) = {initialIndex:rcBreakpoints(iBP)};
    initialIndex = rcBreakpoints(iBP) + 1;
end

% For each RC group find the group of FC cadences that are closest to the mean RC cadence number and form a FC group of the same
% size as the corresponding RC group
FC_groups = repmat(cell(1),length(rcBreakpoints),1);
for iBP = 1:length(rcBreakpoints)
    temp = RC_groups(iBP);
    rcGroupIndices = temp{1};
    meanRcCadenceNumber = mean(rcCadenceNumbers(rcGroupIndices));    
    deltaFromFc = abs( fcValidCadenceNumbers - meanRcCadenceNumber );    
    sortedDeltaArray = sortrows([ fcRelativeCadenceList(:), deltaFromFc(:)], 2);    
    FC_groups(iBP) = { rowvec(sort(find(ismember(fcRelativeCadenceList(:), sortedDeltaArray(1:length(rcGroupIndices),1))))) };
end

% build group structure of RC groups and nearest FCs
RC_FC_groups = struct('RC_groups',RC_groups,'FC_groups',FC_groups);

% construct return data structure
inputs = struct('RCLC_list',    rcRelativeCadenceList, ...
                'FCLC_list',    fcRelativeCadenceList, ...
                'skipDiff',     SKIP_DIFF, ...
                'channel_list', convert_from_module_output( dynablackObject.ccdModule, dynablackObject.ccdOutput ), ...
                'RC_FC_groups', RC_FC_groups);    

% extract instrument configuration constants from dynablackObject
NUM_ROWS    = dynablackObject.fcConstants.CCD_ROWS;
NUM_COLUMNS = dynablackObject.fcConstants.CCD_COLUMNS;
NUM_SMEAR_COLUMNS = dynablackObject.fcConstants.nColsImaging;

% extract masked and virtual smear collateral regions from config map
configMapObject = configMapClass(dynablackObject.spacecraftConfigMap);

maskedSmearRowStart     = min(get_masked_smear_start_row(configMapObject));
maskedSmearRowEnd       = max(get_masked_smear_end_row(configMapObject));
virtualSmearRowStart    = min(get_virtual_smear_start_row(configMapObject));
virtualSmearRowEnd      = max(get_virtual_smear_end_row(configMapObject));
maskedSmearColumnStart  = min(get_masked_smear_start_column(configMapObject));
maskedSmearColumnEnd    = max(get_masked_smear_end_column(configMapObject));
virtualSmearColumnStart = min(get_virtual_smear_start_column(configMapObject));
virtualSmearColumnEnd   = max(get_virtual_smear_end_column(configMapObject));

% extract number of reads per long cadence - use median over all config maps
readsPerLongCadence     = median(get_number_of_exposures_per_long_cadence_period(configMapObject));

% get controls and bounds from dynablack object
[uberControls, uberBounds] = extract_dynablack_controls_and_bounds(dynablackObject);

% build control parameters structure for A2 fits
Controls.parallel_pixel_select = uberControls.a2ParallelPixelSelect;
Controls.frame_pixel_select    = uberControls.a2FramePixelSelect;
Controls.leading_column_select = uberControls.a2LeadingColumnSelect;

% build constants structure
Constants= struct('RCLC_count',                   length(inputs.RCLC_list), ...
                    'FCLC_count',                   length(inputs.FCLC_list), ...
                    'channel_count',                1, ...
                    'RCLC_list',                    inputs.RCLC_list, ...
                    'FCLC_list',                    inputs.FCLC_list, ...
                    'channel_list',                 inputs.channel_list, ...
                    'ffi_row_count',                NUM_ROWS, ...
                    'ffi_column_count',             NUM_COLUMNS, ...
                    'column_predictor_count',       COLUMN_PREDICTOR_COUNT, ...
                    'leadColumn_predictor_count',   LEAD_COLUMN_PREDICTOR_COUNT, ...
                    'smear_predictor_count',        SMEAR_PREDICTOR_COUNT, ...
                    'SOL_range',                    SOL_RANGE, ...
                    'SOL_start',                    SOL_START, ...
                    'group_count',                  length(inputs.RC_FC_groups), ...
                    'RC_FC_groups',                 inputs.RC_FC_groups,...
                    'readsPerLongCadence',          readsPerLongCadence);   
                
% Note: In pipeline version, channel_count always == 1, channel_list will have only one element.

% construct regions of interest
ROI = struct('maskedSmear_collat',DataSubset(maskedSmearRowStart,...
                                              maskedSmearRowEnd,...
                                              maskedSmearColumnStart,...
                                              maskedSmearColumnEnd,...
                                              'MSC'), ...
             'virtualSmear_collat',DataSubset(virtualSmearRowStart,...
                                              virtualSmearRowEnd,...
                                              virtualSmearColumnStart,...
                                              virtualSmearColumnEnd,...
                                              'VSC'), ...
             'rclcTarg',DataSubset(uberBounds.rclcTarg.Rmin,...
                                      uberBounds.rclcTarg.Rmax,...
                                      uberBounds.rclcTarg.Cmin,...
                                      uberBounds.rclcTarg.Cmax,...
                                      'RCT'));   

% load clock state mask
fgsClockStates     = get_fgs_clock_states;
framePixelImage    = fgsClockStates.Frame;
parallelPixelImage = fgsClockStates.Parallel;

% parse RC rows and columns from dynablackObject - already converted to one-based in convert_dynablack_inputs
if reverseClockedEnabled
    reverseClockedRows = [dynablackObject.reverseClockedTargetPixels.row]';
    reverseClockedCols = [dynablackObject.reverseClockedTargetPixels.column]';
else
    reverseClockedRows = [];
    reverseClockedCols = [];
end
numReverseClockedPixels = length(reverseClockedRows);

% load SOL ringing parameters from the dynablackObject
solCoefficients = dynablackObject.startOfLineRingingModel;
solComponents = evaluate_sol_model(solCoefficients, Constants.SOL_range, Constants.channel_list); 
solMaxColumn = max(Constants.SOL_range);

% collateral masked smear constants
parallel_pixel_image_maskedSmear = parallelPixelImage(ROI.maskedSmear_collat.Row_min:ROI.maskedSmear_collat.Row_max, ROI.maskedSmear_collat.Column_min:ROI.maskedSmear_collat.Column_max);
ROI.maskedSmear_collat = initialize( ROI.maskedSmear_collat, 1, ROI.maskedSmear_collat.Column_max - ROI.maskedSmear_collat.Column_min + 1, 0 );                                    
maskedSmear_collat_infile_offset = NUM_ROWS;

% collateral virtual smear constants
parallel_pixel_image_virtualSmear = parallelPixelImage(ROI.virtualSmear_collat.Row_min:ROI.virtualSmear_collat.Row_max, ROI.virtualSmear_collat.Column_min:ROI.virtualSmear_collat.Column_max);
ROI.virtualSmear_collat = initialize( ROI.virtualSmear_collat, 1, ROI.virtualSmear_collat.Column_max-ROI.virtualSmear_collat.Column_min+1, ROI.maskedSmear_collat.Last );
virtualSmear_collat_infile_offset = NUM_ROWS + NUM_SMEAR_COLUMNS;


% RCLC model constants
if Constants.RCLC_count  > 0 && reverseClockedEnabled
    ROI.rclcTarg = initialize(ROI.rclcTarg, 1, length(find(reverseClockedRows >= ROI.rclcTarg.Row_min & ...
                                                             reverseClockedRows <= ROI.rclcTarg.Row_max & ...
                                                             reverseClockedCols >= ROI.rclcTarg.Column_min & ...
                                                             reverseClockedCols <= ROI.rclcTarg.Column_max)), ...
                                                             ROI.virtualSmear_collat.Last);
end


% FCLC model constants
pixCount    = ROI.maskedSmear_collat.Datum_count + ROI.virtualSmear_collat.Datum_count;
FCLC_Model  = struct('pixel_count',     pixCount, ...
                     'parallel_pixels', ModelComponent(length(Controls.parallel_pixel_select), pixCount,'PP'),...
                     'parallel_delta',  ModelComponent(length(Controls.parallel_pixel_select), pixCount,'PD'),...
                     'serial_pixels',   ModelComponent(Constants.column_predictor_count, pixCount,'CL'),...
                     'sol_all',         zeros(pixCount,1),...
                     'sol_delta',       zeros(pixCount,1));

ROI.maskedSmear_collat.Index    = (1:ROI.maskedSmear_collat.Datum_count) + maskedSmear_collat_infile_offset;
ROI.virtualSmear_collat.Index   = (1:ROI.virtualSmear_collat.Datum_count) + virtualSmear_collat_infile_offset;                            
ROI.maskedSmear_collat.Columns  = (ROI.maskedSmear_collat.Index - maskedSmear_collat_infile_offset + ROI.maskedSmear_collat.Column_min-1)';
ROI.virtualSmear_collat.Columns = (ROI.virtualSmear_collat.Index - virtualSmear_collat_infile_offset + ROI.virtualSmear_collat.Column_min-1)';
 

% RCLC model constants
pixCount = ROI.maskedSmear_collat.Datum_count + ROI.virtualSmear_collat.Datum_count + ROI.rclcTarg.Datum_count;
RCLC_Model= struct('pixel_count',      pixCount, ...
                   'frame_pixels',     ModelComponent(length(Controls.frame_pixel_select), pixCount,'FP'),...
                   'frame_delta',      ModelComponent(length(Controls.frame_pixel_select), pixCount,'FD'),...
                   'parallel_pixels',  ModelComponent(length(Controls.parallel_pixel_select), pixCount,'PP'),...
                   'parallel_deltaMS', ModelComponent(length(Controls.parallel_pixel_select), pixCount,'PM'),...
                   'parallel_deltaVS', ModelComponent(length(Controls.parallel_pixel_select), pixCount,'PV'),...
                   'serial_pixels',    ModelComponent(Constants.column_predictor_count, pixCount,'CL'),...
                   'lead_columns',     ModelComponent(Constants.leadColumn_predictor_count, pixCount,'CS'),...
                   'sol_all',          zeros(pixCount,1),...
                   'sol_delta',        zeros(pixCount,1));

% identify pixels in ROI
validPixelIndicators  = reverseClockedRows >= ROI.rclcTarg.Row_min & ...
                        reverseClockedRows <= ROI.rclcTarg.Row_max & ...
                        reverseClockedCols >= ROI.rclcTarg.Column_min & ...
                        reverseClockedCols <= ROI.rclcTarg.Column_max;

% build array of all rc pixels index, row, column
rcIndexRowColumnArray = [1:numReverseClockedPixels; reverseClockedRows(:)'; reverseClockedCols(:)']';

% select pixels in ROI and sort pixel array by row and column
sortedRcIndexRowColumnArray = sortrows( sortrows( rcIndexRowColumnArray(validPixelIndicators,:), 3 ), 2 );

% extract index, row and column in ROI
ROI.rclcTarg.Index     = sortedRcIndexRowColumnArray(:,1)';
ROI.rclcTarg.Rows      = reverseClockedRows(ROI.rclcTarg.Index);
ROI.rclcTarg.Columns   = reverseClockedCols(ROI.rclcTarg.Index);

            
% FGS-PARALLEL PIXEL MODEL FOR FCLC MODEL
% extract FGS-parallel pixel model elements for collateral masked and virtual smear
for k = 1:FCLC_Model.parallel_pixels.Predictor_count    
    parallel_cols = sum(parallel_pixel_image_maskedSmear == Controls.parallel_pixel_select(k),1)';    
    FCLC_Model.parallel_pixels.Matrix(k,ROI.maskedSmear_collat.First:ROI.maskedSmear_collat.Last) = parallel_cols(:);
    FCLC_Model.parallel_delta.Matrix(k,ROI.maskedSmear_collat.First:ROI.maskedSmear_collat.Last) = parallel_cols(:);    
    parallel_cols = sum(parallel_pixel_image_virtualSmear == Controls.parallel_pixel_select(k),1)';    
    FCLC_Model.parallel_pixels.Matrix(k,ROI.virtualSmear_collat.First:ROI.virtualSmear_collat.Last) = parallel_cols(:);
end

% FGS-PARALLEL PIXEL MODEL FOR RCLC MODEL
% extract FGS-parallel pixel model elements for collateral masked and virtual smear
if Constants.RCLC_count  > 0 && reverseClockedEnabled
    for k = 1:RCLC_Model.parallel_pixels.Predictor_count        
        parallel_cols = sum(parallel_pixel_image_maskedSmear == Controls.parallel_pixel_select(k),1)';
        RCLC_Model.parallel_pixels.Matrix(k,ROI.maskedSmear_collat.First:ROI.maskedSmear_collat.Last)   = parallel_cols(:);
        RCLC_Model.parallel_deltaMS.Matrix(k,ROI.maskedSmear_collat.First:ROI.maskedSmear_collat.Last)  = parallel_cols(:);        
        parallel_cols = sum(parallel_pixel_image_virtualSmear == Controls.parallel_pixel_select(k),1)';
        RCLC_Model.parallel_pixels.Matrix(k,ROI.virtualSmear_collat.First:ROI.virtualSmear_collat.Last)  = parallel_cols(:);
        RCLC_Model.parallel_deltaVS.Matrix(k,ROI.virtualSmear_collat.First:ROI.virtualSmear_collat.Last) = parallel_cols(:);
    end
        
    % extract FGS-parallel pixel model elements for RCLC ROI pixels
    for k = 1:ROI.rclcTarg.Datum_count
        ROI.rclcTarg.FGS_parallel_clockstates(k) = parallelPixelImage(ROI.rclcTarg.Rows(k),ROI.rclcTarg.Columns(k));
    end
    
    for  k= 1:RCLC_Model.parallel_pixels.Predictor_count        
        RCLC_Model.parallel_pixels.Matrix(k,ROI.rclcTarg.First:ROI.rclcTarg.Last) = ...
            ROI.rclcTarg.FGS_parallel_clockstates == Controls.parallel_pixel_select(k);        
        RCLC_Model.parallel_deltaMS.Matrix(k,ROI.rclcTarg.First:ROI.rclcTarg.Last) = ...
            (ROI.rclcTarg.FGS_parallel_clockstates == Controls.parallel_pixel_select(k)) & ...
            (ROI.rclcTarg.Rows<ROI.maskedSmear_collat.Row_max+1);        
        RCLC_Model.parallel_deltaVS.Matrix(k,ROI.rclcTarg.First:ROI.rclcTarg.Last) = ...
            (ROI.rclcTarg.FGS_parallel_clockstates == Controls.parallel_pixel_select(k)) & ...
            (ROI.rclcTarg.Rows>ROI.virtualSmear_collat.Row_min-1);
    end
        
    % FGS-FRAME PIXEL MODEL FOR RCLC MODEL
    % extract FGS-frame pixel model elements for RCLC pixels
    for k = 1:ROI.rclcTarg.Datum_count
        ROI.rclcTarg.FGS_frame_clockstates(k) = framePixelImage(ROI.rclcTarg.Rows(k),ROI.rclcTarg.Columns(k));
    end
    
    for k = 1:RCLC_Model.frame_pixels.Predictor_count        
        RCLC_Model.frame_pixels.Matrix(k,ROI.rclcTarg.First:ROI.rclcTarg.Last) = ...
            ROI.rclcTarg.FGS_frame_clockstates == Controls.frame_pixel_select(k);        
        RCLC_Model.frame_delta.Matrix(k,ROI.rclcTarg.First:ROI.rclcTarg.Last) = ...
            (ROI.rclcTarg.FGS_frame_clockstates == Controls.frame_pixel_select(k)) & ...
            (ROI.rclcTarg.Rows<Constants.ffi_row_count/2+1);
    end
end

% FCLC & RCLC FGS-SERIAL PIXEL MODEL
% construct a model for column dependence of serial pixels
allpix_const    = [ones(1,ROI.maskedSmear_collat.Datum_count) * ROI.maskedSmear_collat.Row_count, ...
                      ones(1,ROI.virtualSmear_collat.Datum_count) * ROI.virtualSmear_collat.Row_count, ...
                      ones(1,ROI.rclcTarg.Datum_count)];              
allpix_Columns  =[ROI.maskedSmear_collat.Columns', ...
                      ROI.virtualSmear_collat.Columns', ...
                      ROI.rclcTarg.Columns'];              
allpix_linear0  = (allpix_Columns-1)/(Constants.ffi_column_count-1)-0.5;
allpix_linear   = allpix_linear0 .* allpix_const;
allpix_quad     = ((allpix_linear0*2).^2-1/3) .* allpix_const;
deltaMS_const   = [ones(1,ROI.maskedSmear_collat.Datum_count)*ROI.maskedSmear_collat.Row_count, ...
                      zeros(1,ROI.virtualSmear_collat.Datum_count), ...
                      double(ROI.rclcTarg.Rows<ROI.maskedSmear_collat.Row_max+1)'];                  
deltaMS_linear  = allpix_linear0 .* deltaMS_const;
deltaMS_quad    = ((allpix_linear0*2).^2-1/3) .* deltaMS_const;
deltaVS_const   = [zeros(1,ROI.maskedSmear_collat.Datum_count), ...
                      ones(1,ROI.virtualSmear_collat.Datum_count)*ROI.virtualSmear_collat.Row_count, ...
                      double(ROI.rclcTarg.Rows>ROI.virtualSmear_collat.Row_min-1)'];
                  
deltaVS_linear  = allpix_linear0 .* deltaVS_const;
deltaVS_quad    = ((allpix_linear0*2).^2-1/3) .* deltaVS_const;
delta_const     = [ones(1,ROI.maskedSmear_collat.Datum_count)*ROI.maskedSmear_collat.Row_count, ...
                      zeros(1,ROI.virtualSmear_collat.Datum_count), ...
                      double(ROI.rclcTarg.Rows<Constants.ffi_row_count/2+1)'];
sol_const0      = [double(ROI.maskedSmear_collat.Columns<solMaxColumn+Constants.SOL_start)', ...
                      double(ROI.virtualSmear_collat.Columns<solMaxColumn+Constants.SOL_start)', ...
                      double(ROI.rclcTarg.Columns<solMaxColumn+Constants.SOL_start)'];
sol_const       = sol_const0 .* allpix_const;
notsol_const    = (1-sol_const0) .* allpix_const;
sol_deltaMS     = sol_const0 .* deltaMS_const;
notsol_deltaMS  = (1-sol_const0) .* deltaMS_const;
sol_deltaVS     = sol_const0 .* deltaVS_const;
notsol_deltaVS  = (1-sol_const0) .* deltaVS_const;

if Constants.RCLC_count  > 0 && reverseClockedEnabled
    % LEADING COLUMN MODEL
    % construct a model for column dependence of serial pixels in leading black
    for k = 1:RCLC_Model.lead_columns.Predictor_count        
        RCLC_Model.lead_columns.Matrix(k,ROI.maskedSmear_collat.First:ROI.maskedSmear_collat.Last) = ...
            (ROI.maskedSmear_collat.Columns == Controls.leading_column_select(k)) * ROI.maskedSmear_collat.Row_count;        
        RCLC_Model.lead_columns.Matrix(k,ROI.virtualSmear_collat.First:ROI.virtualSmear_collat.Last) = ...
            (ROI.virtualSmear_collat.Columns == Controls.leading_column_select(k)) * ROI.virtualSmear_collat.Row_count;        
        RCLC_Model.lead_columns.Matrix(k,ROI.rclcTarg.First:ROI.rclcTarg.Last) = ROI.rclcTarg.Columns == Controls.leading_column_select(k);
    end
end

% FCLC & RCLC SOL PIXEL MODEL
% start-of-line-ringing models for column dependence of serial pixels
sol_withOffset = [ zeros(1,Constants.SOL_start - 1), solComponents ];
sol_allrows0   = sol_withOffset( min( allpix_Columns, solMaxColumn + Constants.SOL_start - 1) ) .* sol_const0;
sol_allrows    = colvec(sol_allrows0 .* allpix_const);
sol_deltarows  = colvec(sol_allrows0 .* delta_const);

modelMatrix = [ ones(1,RCLC_Model.pixel_count); ...
    sol_const; ...
    notsol_const; ...
    allpix_linear; ...
    allpix_quad; ...
    sol_deltaMS; ...
    notsol_deltaMS; ...
    deltaMS_linear; ...
    deltaMS_quad; ...
    sol_deltaVS; ...
    notsol_deltaVS; ...
    deltaVS_linear; ...
    deltaVS_quad ];

FCLC_Model.serial_pixels.Matrix = modelMatrix(:,1:FCLC_Model.pixel_count);
FCLC_Model.sol_all              = sol_allrows(1:FCLC_Model.pixel_count);
FCLC_Model.sol_delta            = sol_deltarows(1:FCLC_Model.pixel_count);
FCLC_selection_index            = true( 1, FCLC_Model.pixel_count );

% check matrix rank create index to exclude any all-zero predictor vectors
FCLC_Model.parallel_pixels  = model_subset(FCLC_Model.parallel_pixels, 1, FCLC_selection_index);
FCLC_Model.parallel_delta   = model_subset(FCLC_Model.parallel_delta, 1, FCLC_selection_index);
FCLC_Model.serial_pixels    = model_subset(FCLC_Model.serial_pixels, 1, FCLC_selection_index);

% model components
RCLC_Model.serial_pixels.Matrix = modelMatrix;

% smear components are first two rows of sol_const0 --> first two rows of sol_const --> rows 2,3 of model matrix
% save this info for dynablack retrieval
RCLC_Model.sol_all    = sol_allrows;
RCLC_Model.sol_delta  = sol_deltarows;
RCLC_selection_index  = true( 1, RCLC_Model.pixel_count );
RCLC_Model.frame_pixels     = model_subset(RCLC_Model.frame_pixels, 1, RCLC_selection_index);
RCLC_Model.frame_delta      = model_subset(RCLC_Model.frame_delta, 1, RCLC_selection_index);
RCLC_Model.parallel_pixels  = model_subset(RCLC_Model.parallel_pixels, 1, RCLC_selection_index);
RCLC_Model.parallel_deltaMS = model_subset(RCLC_Model.parallel_deltaMS, 1, RCLC_selection_index);
RCLC_Model.parallel_deltaVS = model_subset(RCLC_Model.parallel_deltaVS, 1, RCLC_selection_index);
RCLC_Model.serial_pixels    = model_subset(RCLC_Model.serial_pixels, 1, RCLC_selection_index);
RCLC_Model.lead_columns     = model_subset(RCLC_Model.lead_columns, 1, RCLC_selection_index);    

% assemble return data structure
initInfo.Constants         = Constants;
initInfo.Controls          = Controls;
initInfo.ROI               = ROI;
initInfo.FCLC_Model        = FCLC_Model;
initInfo.RCLC_Model        = RCLC_Model;
initInfo.smearParamIndices = 2:3;