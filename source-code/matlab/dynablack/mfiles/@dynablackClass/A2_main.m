function dynablackResultsStruct = A2_main( dynablackObject, dynablackResultsStruct )
% function dynablackResultsStruct = A2_main( dynablackObject, dynablackResultsStruct )
%
% This dynablackClass method performs RCLC & FCLC horizontal spatial fitting.
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


% hard coded constants
robustWeightThreshold = 0.1;
smearSegmentSize = 100;

% INITIALIZATION
[initInfo, inputs] = A2_parameter_init( dynablackObject );

% extract controls from inputs and initInfo
skipSmearDiff     = inputs.skipDiff;
validFcCadenceIdx = inputs.FCLC_list;
validRcCadenceIdx = inputs.RCLC_list;
constants         = initInfo.Constants;
ROI               = initInfo.ROI;
fclcModel         = initInfo.FCLC_Model;
rclcModel         = initInfo.RCLC_Model;
smearParamIndices = initInfo.smearParamIndices;

reverseClockedEnabled = dynablackObject.dynablackModuleParameters.reverseClockedEnabled;

% get number of valid cadence indices
nFcCadences = length(validFcCadenceIdx);
nRcCadences = length(validRcCadenceIdx);

% seed dummy model if needed
if skipSmearDiff
  FCDiff_spatial_model = 0;
end

% seed model weights
rcModelWeights = [ones(ROI.maskedSmear_collat.Datum_count,1)  ./ sqrt(ROI.maskedSmear_collat.Row_count); ...
                   ones(ROI.virtualSmear_collat.Datum_count,1) ./ sqrt(ROI.virtualSmear_collat.Row_count); ...
                   ones(ROI.rclcTarg.Datum_count,1)];


% -- INITIALIZE MODEL PARAMETERS
channelIdx = constants.channel_list;
rclcModel0 = [rclcModel.serial_pixels.Matrix(rclcModel.serial_pixels.Subset_predictor_index,:)' ...
                rclcModel.lead_columns.Matrix(rclcModel.lead_columns.Subset_predictor_index,:)' ...
                rclcModel.frame_pixels.Matrix(rclcModel.frame_pixels.Subset_predictor_index,:)' ...
                rclcModel.parallel_pixels.Matrix(rclcModel.parallel_pixels.Subset_predictor_index,:)' ...
                rclcModel.frame_delta.Matrix(rclcModel.frame_delta.Subset_predictor_index,:)' ...
                rclcModel.parallel_deltaMS.Matrix(rclcModel.parallel_deltaMS.Subset_predictor_index,:)' ...
                rclcModel.parallel_deltaVS.Matrix(rclcModel.parallel_deltaVS.Subset_predictor_index,:)'];

nRcCoeffs             = size(rclcModel0,2);
rclcSpatialModel      = rclcModel0 .* rcModelWeights(:,ones(nRcCoeffs,1));
coeffs_and_errors_xRC = zeros(nRcCadences,3*nRcCoeffs);
residuals_xRC         = zeros(nRcCadences,2*rclcModel.serial_pixels.Subset_datum_count);
                

% grab stuff from object
channel     = convert_from_module_output(dynablackObject.ccdModule, dynablackObject.ccdOutput);
season      = dynablackObject.season;
nCcdColumns = dynablackObject.fcConstants.nColsImaging;

% ---- EXTRACT PIXEL DATA
if reverseClockedEnabled
    % Parse RC target pixel data from dynablackObject
    % Make it nPixels x nCadences - valid cadences only
    rcTargetPixels = [dynablackObject.reverseClockedTargetPixels.values]';
    rcTargetPixels = rcTargetPixels(:,validRcCadenceIdx);
    
    % Parse RC collateral data from dynablackObject
    % Set gaps to NaN
    % Make it nPixels x nCadences - valid cadences only
    rcCollateralPixels = [[dynablackObject.reverseClockedBlackPixels.values],...
        [dynablackObject.reverseClockedMaskedSmearPixels.values],...
        [dynablackObject.reverseClockedVirtualSmearPixels.values]]';
    rcCollateralGaps = [[dynablackObject.reverseClockedBlackPixels.gapIndicators],...
        [dynablackObject.reverseClockedMaskedSmearPixels.gapIndicators],...
        [dynablackObject.reverseClockedVirtualSmearPixels.gapIndicators]]';
    rcCollateralPixels(rcCollateralGaps) = NaN;
    rcCollateralPixels = rcCollateralPixels(:,validRcCadenceIdx);
end

% Parse FC collateral data from dynablackObject
% Set gaps to NaN
% Make it nCadences x nPixels - valid cadences only
fcCollateralPixels = [[dynablackObject.blackPixels.values],...
                        [dynablackObject.maskedSmearPixels.values],...
                        [dynablackObject.virtualSmearPixels.values]];
fcCollateralGaps = [[dynablackObject.blackPixels.gapIndicators],...
                        [dynablackObject.maskedSmearPixels.gapIndicators],...
                        [dynablackObject.virtualSmearPixels.gapIndicators]];                    
fcCollateralPixels(fcCollateralGaps) = NaN;
fcCollateralPixels = fcCollateralPixels(validFcCadenceIdx,:);


% extract smear pixels
fcMaskedSmear  = fcCollateralPixels(:,ROI.maskedSmear_collat.Index)';
fcVirtualSmear = fcCollateralPixels(:,ROI.virtualSmear_collat.Index)';

% retrieve bleeding columns and replace smear values with nans
maskedBleedingIndices = get_masked_smear_columns_to_exclude(season, channel) - ROI.maskedSmear_collat.Column_min + 1;
virtualBleedingIndices = get_virtual_smear_columns_to_exclude(season, channel) - ROI.virtualSmear_collat.Column_min + 1;
fcMaskedSmear(maskedBleedingIndices,:) = NaN;
fcVirtualSmear(virtualBleedingIndices,:) = NaN;

% compute smear difference
fcSmearDiff = fcVirtualSmear - fcMaskedSmear;


% -- RC LOOP: FIT EACH RC
if reverseClockedEnabled
    for rcIdx = 1:nRcCadences

        % get target data for one rclc 
        thisRc = rcTargetPixels(:,rcIdx);

        % get collateral data for one rclc 
        thisRcCollateral = rcCollateralPixels(:,rcIdx);

        subInputs.ROI = ROI;
        subInputs.RCLC_Model = rclcModel;

        [ full_RC_data  RC_data ] = build_RC_response(thisRc, thisRcCollateral, rcModelWeights, subInputs);                             %#ok<ASGLU>

        [regress_coefficient_list,...
            regress_coeff_CI,...
            regress_residuals] = regress(RC_data,rclcSpatialModel,.32);

        coeffs_and_errors_xRC(rcIdx,:) = [regress_coefficient_list; ... 
                                            regress_coeff_CI(:,2); ...
                                            regress_coeff_CI(:,1);]';

        residuals_xRC(rcIdx,:) = [regress_residuals; RC_data]';
    end
end

% VIRTUAL-MASKED SMEAR DIFFERENCE MODEL
if ~skipSmearDiff,
    column_model            = rclcModel.lead_columns.Matrix(rclcModel.lead_columns.Subset_predictor_index,1:nCcdColumns)';
    FCDiff_spatial_model0   = [fclcModel.serial_pixels.Matrix(rclcModel.serial_pixels.Subset_predictor_index(1:5),1:nCcdColumns)' ...
                                column_model(:,11:end) ...
                                rclcModel.parallel_pixels.Matrix(rclcModel.parallel_pixels.Subset_predictor_index,nCcdColumns + (1:nCcdColumns))'- ...
                                rclcModel.parallel_pixels.Matrix(rclcModel.parallel_pixels.Subset_predictor_index,1:nCcdColumns)'];

    FCDiff_spatial_model = FCDiff_spatial_model0(:,2:end);
    FCDiffcoeff_count    = size(FCDiff_spatial_model,2);

    % INITIALIZE OUTPUT VARIABLES
    diffCoeffs_and_errors_xLC = zeros(nFcCadences,3*FCDiffcoeff_count+4);
    diffResiduals_xLC         = zeros(nFcCadences,2*fclcModel.serial_pixels.Subset_datum_count/2);
    diffRobust_weights_xLC    = zeros(nFcCadences,fclcModel.serial_pixels.Subset_datum_count/2);
    
    % disable robustfit warnings
    warning('off','stats:statrobustfit:IterationLimit');    

    % VIRTUAL-MASKED SMEAR DIFFERENCE FITS
    for lcIdx = 1:nFcCadences

        [robustCoeffs, robustStats] = robustfit(FCDiff_spatial_model,fcSmearDiff(:,lcIdx),'bisquare',4.685,'off');

        diffCoeffs_and_errors_xLC(lcIdx,:) = [ robustCoeffs; ...
                                                robustStats.se; ...
                                                robustStats.p;
                                                robustStats.s;
                                                robustStats.ols_s;
                                                robustStats.robust_s;
                                                robustStats.mad_s]';

        diffResiduals_xLC(lcIdx,:)      = [robustStats.resid; fcSmearDiff(:,lcIdx)]';
        diffRobust_weights_xLC(lcIdx,:) = robustStats.w';       
    end
end

% ROBUST FIT FOR OUTLIER REMOVAL
[coeffs,robustStats] = robustfit(fcMaskedSmear(:),fcVirtualSmear(:),'bisquare',4.685,'on');

% enable all warnings
warning on all;

dataOk          = double( robustStats.w > robustWeightThreshold );
selectedWeights = dataOk + robustStats.w .* (1 - dataOk);
cleanResidual   = reshape( (robustStats.resid .* selectedWeights), nCcdColumns, nFcCadences );
cleanSmear      = reshape( (fcVirtualSmear(:) + coeffs(1) + coeffs(2)*fcMaskedSmear(:) ) /2 .* dataOk + ...
                            min( fcVirtualSmear(:), coeffs(1) + coeffs(2)*fcMaskedSmear(:)) .* (1-dataOk), nCcdColumns, nFcCadences );

% SELECT REFERENCE COLUMNS
% Per the original dynablack prototype, a single reference column for each segment should meet the following criteria simultaneously:
% variability in smear < VARIABILITY_QUANTILE ( 0.5 prototype )
% noise level in smear < NOISE_QUANTILE ( 0.1 prototype )
% fraction of robust weights in fit across cadences > ROBUST_WEIGHT_FRACTION_MINIMUM ( 0.95 prototype )
% median smear < SMEAR_QUANTILE ( 0.25 prototype )of above subset
% Then we take the column with the minimum median smear value (Why do the above step?)
%
% In response to KSOC-3745 I have made the following changes:
% Decrease the ROBUST_WEIGHT_FRACTION_MINIMUM from 0.95 to 0.90
% Require the selectedColumns matrix produced to be of rank MIN_SELECTED_COLUMNS minimum. This value was set at 4 since the spatial model to
% which selected_smear is eventually fit to has rank 3 (hard coded). If the selectedColumns matrix produced using the above variability,
% noise, robust weight and smear value criteria has rank < MIN_SELECTED_COLUMNS a default selectedColumns matrix is substituted in which
% the reference columns for each segment are the ones with the minimum median smear value.

% hard coded bounds
MIN_SELECTED_COLUMNS = 4;

VARIABILITY_QUANTILE = 0.50;
NOISE_QUANTILE = 0.10;
SMEAR_QUANTILE = 0.25;
ROBUST_WEIGHT_FRACTION_MINIMUM = 0.90;

selectionCriteria = [1:nCcdColumns; ...
                        abs(log(nanstd(cleanSmear,0,2))-log(nanstd(cleanResidual,0,2)))'; ...               % variability in smear
                        nanstd((cleanSmear - (ones(nCcdColumns,1)*nanmedian(cleanSmear,1))),0,2)'; ...      % noise level in smear
                        nanmedian(cleanSmear,2)'; ...                                                       % median smear value
                        nansum( reshape( dataOk, nCcdColumns, nFcCadences), 2 )' ./ nFcCadences ]';         % fraction with robust weight above robust threshold

selectedColumns = [];
defaultSelectedColumns = [];
nSegments = nCcdColumns / smearSegmentSize;

for iSegment = 1:nSegments
    
    % extract columns in segment
    columnIndex = (iSegment-1)*smearSegmentSize+1:iSegment*smearSegmentSize;    
    
    % extract continuous subset of column criteria
    selectionCriteriaSegment = selectionCriteria(columnIndex,:);
    
    % select column with minimum median smear value overall as default reference column
    [~, defaultColumnIndex] = min(selectionCriteriaSegment(4,:));
        
    % establish valid data based on this data segment and on the robust fit results
    varibilityValid           = selectionCriteriaSegment(:,2) < quantile(selectionCriteriaSegment(:,2), VARIABILITY_QUANTILE);
    noiseValid                = selectionCriteriaSegment(:,3) < quantile(selectionCriteriaSegment(:,3), NOISE_QUANTILE);
    robustWeightFractionValid = selectionCriteriaSegment(:,5) > ROBUST_WEIGHT_FRACTION_MINIMUM;
    
    % select valid data subset
    selectedInSegment = selectionCriteriaSegment(varibilityValid & noiseValid & robustWeightFractionValid, :);

    % establish bounds based on selected data subset - Do we really need to select out the lower SMEAR_QUANTILE before taking the minimum logical index?
    smearValid = selectedInSegment(:,4) <= quantile(selectedInSegment(:,4), SMEAR_QUANTILE);
    
    % select minimum smear value to add
    addThisColumn = selectedInSegment(smearValid,4) == min(selectedInSegment(smearValid,4));                       
    columnsToAdd = selectedInSegment(addThisColumn,:);
    
    % update selected columns matrix and default
    selectedColumns = [selectedColumns; columnsToAdd];                                                      %#ok<AGROW>
    defaultSelectedColumns = [defaultSelectedColumns; selectionCriteriaSegment(defaultColumnIndex,:)];      %#ok<AGROW>
end

% replace selected columns matrix with default if not enough columns were selected
if size(selectedColumns,1) < MIN_SELECTED_COLUMNS
    disp('     Selecting segment reference columns based on minimum median smear only.');
    selectedColumns = defaultSelectedColumns;    
end

selected_count = size(selectedColumns,1);
selected_smear = cleanSmear(selectedColumns(:,1),:);



% REFERENCE COLUMN MODEL
% select 'rows' of serial_pixels model to fit
% 1 == constant
% 4 == linear in column number (includes spatial coadd normalization)
% 5 == quadradic in column number (includes spatial coadd normalization)
selectedRows   = [1,4,5];
fcSpatialModel = fclcModel.serial_pixels.Matrix(selectedRows,selectedColumns(:,1))';
fcCoeffCount   = size(fcSpatialModel,2);


% REFERENCE COLUMN FITS
smearCoeffs_and_errors_xLC = zeros(nFcCadences, 3*fcCoeffCount);
smearResiduals_xLC         = zeros(nFcCadences, 2*selected_count);   

for lcIdx = 1:nFcCadences

    [regress_coefficient_list,...
        regress_coeff_CI,...
        regress_residuals] = regress(selected_smear(:,lcIdx), fcSpatialModel,.32);

    smearCoeffs_and_errors_xLC(lcIdx,:) = [regress_coefficient_list; ... 
                                            regress_coeff_CI(:,2); ...
                                            regress_coeff_CI(:,1);]';

    smearResiduals_xLC(lcIdx,:) = [regress_residuals; selected_smear(:,lcIdx)]';
end

if ~skipSmearDiff
    dynablackResultsStruct.A2_fit_results.diffCoeffs_and_errors_xLC = diffCoeffs_and_errors_xLC;
    dynablackResultsStruct.A2_fit_results.diffRobust_weights_xLC    = diffRobust_weights_xLC;
    dynablackResultsStruct.A2_fit_residInfo.diffResiduals_xLC       = diffResiduals_xLC;
end

% save outputs to resultsStruct
dynablackResultsStruct.A2_fit_results.coeffs_and_errors_xRC      = coeffs_and_errors_xRC;
dynablackResultsStruct.A2_fit_results.smearCoeffs_and_errors_xLC = smearCoeffs_and_errors_xLC;
dynablackResultsStruct.A2_fit_results.fit_results                = {channelIdx, coeffs};
dynablackResultsStruct.A2_fit_residInfo.residuals_xRC            = residuals_xRC;
dynablackResultsStruct.A2_fit_residInfo.smearResiduals_xLC       = smearResiduals_xLC;

dynablackResultsStruct.A2ModelDump.Inputs               = inputs;
dynablackResultsStruct.A2ModelDump.Constants            = constants;
dynablackResultsStruct.A2ModelDump.RCLC_Model           = rclcModel;
dynablackResultsStruct.A2ModelDump.FCLC_Model           = fclcModel;
dynablackResultsStruct.A2ModelDump.ROI                  = ROI;
dynablackResultsStruct.A2ModelDump.RCLC_spatial_model   = rclcSpatialModel;
dynablackResultsStruct.A2ModelDump.FCDiff_spatial_model = FCDiff_spatial_model;
dynablackResultsStruct.A2ModelDump.FC_spatial_model     = fcSpatialModel;
dynablackResultsStruct.A2ModelDump.smearParamIndices    = smearParamIndices;

