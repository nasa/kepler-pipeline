function dynablackResultsStruct = A1_main( dynablackObject, dynablackResultsStruct )
% function dynablackResultsStruct = A1_main( dynablackObject, dynablackResultsStruct )
%
% This dynablackClass method performs vertical spatial fitting using leading and trailing black.
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
enableNonlinearFit = false;
rowTimeConstantDelta = 25;              % row time constant step size for initial solution when performing non-linear fit to determine rowTimeConstant
nRowTimeConstantTrials = 40;            % number of steps to take when searching for non-linear fit solution

% initialize models and controls
[initInfo, Inputs] = A1_parameter_init( dynablackObject );

% get valid cadence indices
validCadenceIdx = Inputs.FCLC_list;
nCadences = length(validCadenceIdx);

% extract models 
Constants       = initInfo.Constants;
ROI             = initInfo.ROI;
FCLC_Model      = initInfo.FCLC_Model;
FFI_Model       = initInfo.FFI_Model;
linearRows      = initInfo.rowsModelLinearRows;
controls        = Inputs.controls;
thermalRowOffset= controls.thermalRowOffset;
undershootSpan  = controls.undershootSpan;

% define anonymous functions, region of interest (roi) and non-linear model NLmod used for nlinfit
roi     = @(this,range) this(range);
nlModel = @NLModel;

% noise equalization for collateral data
modelWeights = [ ones(ROI.trailingArpUs.Last, 1);...
                  ones(ROI.trailingCollat.Last - ROI.trailingCollat.First + 1, 1) ./ sqrt(ROI.trailingCollat.Column_count) ];

% output labeling 
roi_ID          = [ repmat(ROI.leadingArp.Ref_ID,     ROI.leadingArp.Datum_count,     1); ...
                    repmat(ROI.trailingArp.Ref_ID,    ROI.trailingArp.Datum_count,    1); ...
                    repmat(ROI.trailingArpUs.Ref_ID, ROI.trailingArpUs.Datum_count,   1); ...
                    repmat(ROI.trailingCollat.Ref_ID, ROI.trailingCollat.Datum_count, 1)];     

roi_element     = [ 1:ROI.leadingArp.Datum_count, ...
                    1:ROI.trailingArp.Datum_count, ...
                    1:ROI.trailingArpUs.Datum_count, ...
                    1:ROI.trailingCollat.Datum_count]';                       

% extract constants
channel_num         = Constants.channel_list;
longTimeConstant    = Constants.longTimeConstant;
shortTimeConstant   = Constants.shortTimeConstant;
numFclc             = Constants.FCLC_count;
numFfi              = Constants.FFI_count;

% set up model elements
rowModel            = FCLC_Model.rows.Matrix(FCLC_Model.rows.Subset_predictor_index,:)';
columnModel         = FCLC_Model.columns.Matrix(FCLC_Model.columns.Subset_predictor_index,:)'; 
frameModel          = FCLC_Model.frame_pixels.Matrix(FCLC_Model.frame_pixels.Subset_predictor_index,:)';
parallelModel       = FCLC_Model.parallel_pixels.Matrix(FCLC_Model.parallel_pixels.Subset_predictor_index,:)';
frameDeltaModel     = FCLC_Model.frame_delta.Matrix(FCLC_Model.frame_delta.Subset_predictor_index,:)';
parallelDeltaModel  = FCLC_Model.parallel_delta.Matrix(FCLC_Model.parallel_delta.Subset_predictor_index,:)';

% basic model excluding undershoot
fullModelLessUndershoot = [ rowModel, columnModel, frameModel, parallelModel, frameDeltaModel, parallelDeltaModel ];
numCoeffs = size( fullModelLessUndershoot, 2 ) + abs( undershootSpan ) + 1; 

% -> GET LC DATA FOR FITS
% extract arp data for FC cadences from dynablackObject
% set gapped data to NaNs
pixelStructArray = dynablackObject.arpTargetPixels;
arpData = [pixelStructArray.values];
arpGaps = [pixelStructArray.gapIndicators];
arpData(arpGaps) = NaN;
arpData = arpData(validCadenceIdx,:);

% extract collateral data for FC cadences from dynablackObject
% set gapped data to NaNs
blackPixels         = [dynablackObject.blackPixels.values];
maskedSmearPixels   = [dynablackObject.maskedSmearPixels.values];
virtualSmearPixels  = [dynablackObject.virtualSmearPixels.values];
    
blackGaps           = [dynablackObject.blackPixels.gapIndicators];
maskedSmearGaps     = [dynablackObject.maskedSmearPixels.gapIndicators];
virtualSmearGaps    = [dynablackObject.virtualSmearPixels.gapIndicators];
    
collateralData      = [blackPixels, maskedSmearPixels, virtualSmearPixels];
collateralGaps      = [blackGaps, maskedSmearGaps, virtualSmearGaps];
collateralData(collateralGaps) = NaN;
collateralData      = collateralData(validCadenceIdx,:);


% -> PERFORM INITIAL LINEAR FIT ON MEAN OF LCs
% performs a linear fit to obtain initial parameters for the nonlinear fit

% get mean arp and collateral data over LCs in list (valid LC indices)
thisLongCadence = nanmean(arpData)';
thisCollateral  = nanmean(collateralData)';

% construct undershoot model
configStruct.row_model = FCLC_Model.rows;
configStruct.ROI       = ROI;
configStruct.controls  = controls;
configStruct.constants = Constants;

undershootModel = build_undershoot_model( thisLongCadence, configStruct );

% construct full spatial model
fullSpatialModel = [fullModelLessUndershoot, undershootModel.Matrix(undershootModel.Subset_predictor_index(1,:),:)'] .* repmat(modelWeights,1,numCoeffs);

% exclude scene dependent rows from spatial model
spatialModel = fullSpatialModel(FCLC_Model.rows.Subset_datum_index,:); 

% construct reponse vector
[ fullBlackData  blackData ] = build_black_response( thisLongCadence, thisCollateral, modelWeights, configStruct);


% this is hard coded off until 9.3
if enableNonlinearFit

    % -> PERFORM NON-LINEAR FIT ON MEAN OF LCs
    % performs a nonlinear fit to obtain the low-row exponential time constant
    % this single value for rowTimeConstant is then used in the individual LC fits
    
    rowTimeConstant = controls.defaultRowTimeConstant; %#ok<UNRCH>
    
    % basic model for nonlinear fit
    nlSpatialModel = FCLC_Model.rows_nl.Matrix(FCLC_Model.rows_nl.Subset_predictor_index,FCLC_Model.rows_nl.Subset_datum_index)';
    
    % construct reponse vector which excludes masked smear
    nlConfigStruct.row_model = FCLC_Model.rows_nl;
    nlConfigStruct.ROI       = ROI;
    nlConfigStruct.controls  = controls;
    [ nlFullBlackData  nlBlackData ] = build_black_response( thisLongCadence, thisCollateral, modelWeights, nlConfigStruct);
     
    % nonlinear fit with error-checking -- trying different starting values if errors/warnings occur                    
    % disable all warnings during nlinfit interations
    warning off all;
    disp('     Searching for nonlinear model parameter rowTimeConstant...');
    
    % loop through rowTimeConstant values searching for a successful starting point
    % if no successful nonlinear fit is obtained in nRowTimeConstantTrials set the row time constant to twice the minimum valid row being fit
    for trial = 1:nRowTimeConstantTrials
    
        try
            % update spatial model with trial rowTimeConstant
            [ fullSpatialModel, spatialModel ] = change_time_constant( fullSpatialModel, rowTimeConstant, configStruct ); 
            
            % first perform linear fit to get nlinfit seed point
            linearFitCoeffs = spatialModel\blackData;
            
            % get starting nonlinear values from linear fit
            nonlinearSeed = [linearFitCoeffs(5),...
                                1./rowTimeConstant,...
                                linearFitCoeffs(4),...
                                linearFitCoeffs(1),...
                                linearFitCoeffs(2),...
                                linearFitCoeffs(3)];
                            
            % subtract FGS crosstalk from the response vector to simplify the nonlinear fit
            blackDataMinusFgs = (nlBlackData -...
                           fullSpatialModel(FCLC_Model.rows_nl.Subset_datum_index,FCLC_Model.rows.Subset_predictor_count+1:end) * ...
                           linearFitCoeffs(FCLC_Model.rows.Subset_predictor_count+1:end)) ./ ...
                           modelWeights(FCLC_Model.rows_nl.Subset_datum_index);
            
            % nonlinear fit
            lastwarn('');
            [ nonlinearCoeffs, nonlinearResidual, Jnl, COVBnl, msenl ] = nlinfit( nlSpatialModel, blackDataMinusFgs, nlModel, nonlinearSeed );
            
            % if errors or warning perfrom catch block
            if ~strcmp(lastwarn,'')
                % this line should never execute
                error('*** nonlinear fit warning occurred ***');
            else
                % SUCCESS - set rowTimeConstant to nonlinear fit value and exit try/catch
                rowTimeConstant = 1./nonlinearCoeffs(2);
            end
            break;
    
        catch MErr                                                                                                                                  %#ok<*NASGU>
            
            if trial == nRowTimeConstantTrials
                % on last trial set rowTimeConstant to twice minimum valid row being fit
                rowTimeConstant = 2 * min(FCLC_Model.rows_nl.Matrix(1,FCLC_Model.rows_nl.Subset_datum_index));
                
                % keep away from rowTimeConstant = 592 so model is not degenerate
                % 592 == the effective time constant of the log term in NLModel
                if rowTimeConstant > 500 && rowTimeConstant < 600
                    rowTimeConstant = 500;
                elseif rowTimeConstant > 600 && rowTimeConstant < 700
                    rowTimeConstant = 700;
                end
                
            else
                % increment starting value of rowTimeConstant by delta
                rowTimeConstant = rowTimeConstant + rowTimeConstantDelta;
            end                     
        end
    end 
    
    % re-enable all warnings
    warning on all;
    
    % adjust spatial models for new rowTimeConstant
    [ fullSpatialModel, spatialModel ] = change_time_constant( fullSpatialModel, rowTimeConstant, configStruct );    
            
    % adjust base model for rowTimeConstant for use in per cadence fits
    fullModelLessUndershoot = change_time_constant( fullModelLessUndershoot, rowTimeConstant, configStruct );  
    
    % -> RECORD NONLINEAR FIT RESULTS IN OUTPUT STRUCTURES
    
    LC_fit_results.nonlin.numCoeffs          = length(nonlinearCoeffs);
    LC_fit_results.nonlin.coeff              = nonlinearCoeffs;
    LC_fit_results.nonlin.stats.Jacobian     = Jnl;
    LC_fit_results.nonlin.stats.covar_matrix = COVBnl;
    LC_fit_results.nonlin.statsmean_sqErr    = msenl;
    LC_fit_results.nonlin.resid              = nonlinearResidual;
    LC_fit_results.nonlin.blackDat_minusFGS  = blackDataMinusFgs;
    
else
    % use tabular value loaded during init
    rowTimeConstant = Constants.shortTimeConstant;
end


% -> PERFORM LINEAR MEAN FIT WITH REVISED TIME CONSTANT
% performs a linear fit to obtain coefficients for a revised static 2D black 
    
% ordinary least squares fit w/alpha = 0.32 gives 1 sigma CI
[regressionCoeffs,...
        regress_coeff_CI,...
        regressionResiduals,...
        regress_resid_CI,...
        regress_stats] = regress( blackData, spatialModel, 0.32 );                                                                          %#ok<ASGLU>

% robust fit w/MATLAB default parameters
warning('off','stats:statrobustfit:IterationLimit');
[robust_coefficient_list, robust_stats] = robustfit( spatialModel, blackData, 'bisquare', 4.685, 'off' ); 
warning on all;

% calculate residuals for all pixels ( not just non-scene dependent ones )
full_black_robust_residuals  = fullBlackData - ( fullSpatialModel * robust_coefficient_list ) ./ modelWeights;
full_black_regress_residuals = fullBlackData - ( fullSpatialModel * regressionCoeffs ) ./ modelWeights;
    
% -> RECORD MEAN FIT RESULTS IN OUTPUT STRUCTURES
LC_fit_results.meanfit.numCoeffs                            = length(regressionCoeffs);
LC_fit_results.meanfit.coeffs.regress                       = regressionCoeffs;
LC_fit_results.meanfit.coeffs.robust                        = robust_coefficient_list;
LC_fit_results.meanfit.coeff_errs.regressCI_lo              = regress_coeff_CI(:,1);
LC_fit_results.meanfit.coeff_errs.regressCI_hi              = regress_coeff_CI(:,2);
LC_fit_results.meanfit.coeff_errs.robust_stErr              = robust_stats.se;
LC_fit_results.meanfit.coeff_errs.robust_stats.sigma        = robust_stats.s;
LC_fit_results.meanfit.coeff_errs.robust_stats.ols_sigma   	= robust_stats.ols_s;
LC_fit_results.meanfit.coeff_errs.robust_stats.robust_sigma	= robust_stats.robust_s;
LC_fit_results.meanfit.coeff_errs.robust_stats.mad_sigma    = robust_stats.mad_s;
LC_fit_results.meanfit.resid.regress                        = regressionResiduals;
LC_fit_results.meanfit.resid.robust                         = robust_stats.resid;
LC_fit_results.meanfit.full_resid.regress                   = full_black_regress_residuals;
LC_fit_results.meanfit.full_resid.robust                    = full_black_robust_residuals;
LC_fit_results.meanfit.robust_weights                       = robust_stats.w;
LC_fit_residInfo.SceneDep_mask                              = FCLC_Model.rows.Subset_datum_index;
      

% -> LOOP - FOR EACH LC INDEX IN FCLC_list
absoluteCadence = dynablackObject.cadenceTimes.cadenceNumbers;
disp(['     Processing long cadences ',num2str(absoluteCadence(validCadenceIdx(1))),...
        ' - ',num2str(absoluteCadence(validCadenceIdx(end)))]);
  
for cadenceIndex = 1:nCadences

    % --> PERFORM LINEAR FIT ON ONE LC
    % performs a linear fit to obtain spatial parameters for a single LC

    % get ARP and collateral data for one LC 
    thisLongCadence = arpData(cadenceIndex,:)';
    thisCollateral = collateralData(cadenceIndex,:)';        

    % construct undershoot model for this LC 
    undershootModel = build_undershoot_model( thisLongCadence, configStruct );

    % build model w/undershoot per cadence
    fullSpatialModel = [fullModelLessUndershoot, undershootModel.Matrix(undershootModel.Subset_predictor_index(1,:),:)'].*repmat(modelWeights,1,numCoeffs);                        
    spatialModel = fullSpatialModel(FCLC_Model.rows.Subset_datum_index,:);   
        
    % construct response
    [ fullBlackData  blackData ] = build_black_response( thisLongCadence, thisCollateral, modelWeights, configStruct );
    
    % perform regression fit
    [regressionCoeffs,...
        regress_coeff_CI,...
        regressionResiduals,...
        regress_resid_CI,...
        regress_stats] = regress( blackData, spatialModel, 0.32 );                                                                          %#ok<ASGLU>
    
    % perform robust fit
    warning('off','stats:statrobustfit:IterationLimit');
    [robust_coefficient_list robust_stats] = robustfit( spatialModel, blackData, 'bisquare', 4.685, 'off' );
    warning on all;

    % calculate residuals for all pixels ( not just non-scene dependent ones )
    full_black_robust_residuals  = fullBlackData - (fullSpatialModel * robust_coefficient_list) ./ modelWeights;
    full_black_regress_residuals = fullBlackData - (fullSpatialModel * regressionCoeffs) ./ modelWeights;

    % --> RECORD SINGLE-CADENCE FIT RESULTS IN OUTPUT STRUCTURES
    % LC_fit_results contains coefficients, errors and statistics
    % LC_fit_residInfo contains single-LC residuals, response data and related info
    LC_fit_results.coeffs_xLC.regress(cadenceIndex,:)                      = regressionCoeffs;
    LC_fit_results.coeffs_xLC.robust(cadenceIndex,:)                       = robust_coefficient_list;
    LC_fit_results.coeff_errs_xLC.regressCI_lo(cadenceIndex,:)             = regress_coeff_CI(:,1);
    LC_fit_results.coeff_errs_xLC.regressCI_hi(cadenceIndex,:)             = regress_coeff_CI(:,2);
    LC_fit_results.coeff_errs_xLC.robust_stErr(cadenceIndex,:)             = robust_stats.se;
    LC_fit_results.coeff_errs_xLC.robust_stats.sigma(cadenceIndex)         = robust_stats.s;
    LC_fit_results.coeff_errs_xLC.robust_stats.ols_sigma(cadenceIndex)     = robust_stats.ols_s;
    LC_fit_results.coeff_errs_xLC.robust_stats.robust_sigma(cadenceIndex)  = robust_stats.robust_s;
    LC_fit_results.coeff_errs_xLC.robust_stats.mad_sigma(cadenceIndex)     = robust_stats.mad_s;

    LC_fit_residInfo.fitpix_xLC.regress_resid(cadenceIndex,:)  = regressionResiduals;
    LC_fit_residInfo.fitpix_xLC.robust_resid(cadenceIndex,:)   = robust_stats.resid;
    LC_fit_residInfo.fitpix_xLC.response_data(cadenceIndex,:)  = blackData;
    LC_fit_residInfo.fitpix_xLC.robust_weights(cadenceIndex,:) = robust_stats.w;
    LC_fit_residInfo.full_xLC.regress_resid(cadenceIndex,:)    = full_black_regress_residuals;
    LC_fit_residInfo.full_xLC.robust_resid(cadenceIndex,:)     = full_black_robust_residuals;
    LC_fit_residInfo.full_xLC.response_data(cadenceIndex,:)    = fullBlackData;
end
         

% -> RECORD CHANNEL-DEPENDENT LC INFO IN OUTPUT STRUCTURES
% LC_fit_results contains coefficients, errors and statistics
% LC_fit_residInfo contains single-LC residuals, response data and related info
LC_fit_results.numCoeffs          = length(regressionCoeffs);
LC_fit_results.lc_count           = numFclc;
LC_fit_results.longTimeConstant   = longTimeConstant;
LC_fit_results.shortTimeConstant  = shortTimeConstant;
LC_fit_results.rowTimeConstant    = rowTimeConstant;
LC_fit_results.thermalRowOffset   = thermalRowOffset;
LC_fit_results.component_ID       = [repmat(FCLC_Model.rows.Ref_ID,FCLC_Model.rows.Subset_predictor_count,1); ...
                                        repmat(FCLC_Model.columns.Ref_ID, FCLC_Model.columns.Subset_predictor_count, 1); ...
                                        repmat(FCLC_Model.frame_pixels.Ref_ID, FCLC_Model.frame_pixels.Subset_predictor_count, 1); ...
                                        repmat(FCLC_Model.parallel_pixels.Ref_ID, FCLC_Model.parallel_pixels.Subset_predictor_count, 1); ...
                                        repmat(FCLC_Model.frame_delta.Ref_ID, FCLC_Model.frame_delta.Subset_predictor_count, 1); ...
                                        repmat(FCLC_Model.parallel_delta.Ref_ID, FCLC_Model.parallel_delta.Subset_predictor_count, 1); ...
                                        repmat(undershootModel.Ref_ID, undershootModel.Subset_predictor_count(1), 1)];

LC_fit_results.component_element  = [ roi(1:FCLC_Model.rows.Predictor_count, FCLC_Model.rows.Subset_predictor_index), ...
                                         roi(1:FCLC_Model.columns.Predictor_count, FCLC_Model.columns.Subset_predictor_index), ...
                                         roi(1:FCLC_Model.frame_pixels.Predictor_count, FCLC_Model.frame_pixels.Subset_predictor_index), ...
                                         roi(1:FCLC_Model.parallel_pixels.Predictor_count, FCLC_Model.parallel_pixels.Subset_predictor_index), ...
                                         roi(1:FCLC_Model.frame_delta.Predictor_count, FCLC_Model.frame_delta.Subset_predictor_index), ...
                                         roi(1:FCLC_Model.parallel_delta.Predictor_count, FCLC_Model.parallel_delta.Subset_predictor_index), ...
                                         roi(1:undershootModel.Predictor_count, undershootModel.Subset_predictor_index(1,:)) ]';

LC_fit_residInfo.roi_ID             = roi_ID(FCLC_Model.rows.Subset_datum_index,:);
LC_fit_residInfo.roi_element        = roi_element(FCLC_Model.rows.Subset_datum_index);
LC_fit_residInfo.modelWeights       = modelWeights(FCLC_Model.rows.Subset_datum_index);
LC_fit_results.meanfit.roi_ID       = LC_fit_residInfo.roi_ID;
LC_fit_results.meanfit.roi_element  = LC_fit_residInfo.roi_element;
LC_fit_results.meanfit.modelWeights = LC_fit_residInfo.modelWeights;
     


% -> LOOP - FOR EACH FFI
ffiFilenames = {dynablackObject.rawFfis.fileName};

for ffiIdx = 1:numFfi

    disp(['     Processing FFI ',num2str(ffiFilenames{ffiIdx}),' ...']);

    % --> GET FFI DATA FOR FITS  
    % get 1070 x 1132 image from dynablackObject
    this_image = [dynablackObject.rawFfis(ffiIdx).image.array]';


    % --> PERFORM LINEAR FIT ON ONE FFI
    % performs a linear fit to obtain spatial parameters for a single FFI

    % construct undershoot model for this FFI 
    ffiRowRange     = ROI.trailingFfi.Row_min:ROI.trailingFfi.Row_max;
    ffiColumnRange  = ROI.trailingFfi.Column_min:ROI.trailingFfi.Column_max;
    nModelColumns   = length(ffiColumnRange);
    nModelRows      = length(ffiRowRange);
    undershootModel = zeros(FFI_Model.pixel_count,abs(undershootSpan));
    
    
    for k = 0:nModelColumns - 1        
        model_row_range     = (1:nModelRows) + k * nModelRows;
        image_column_range  = (ROI.trailingFfi.Column_min + undershootSpan:ROI.trailingFfi.Column_min - 1) + k;
        undershootModel(model_row_range,:) = this_image(ffiRowRange,image_column_range);
    end
    
    spatialModel = [ FFI_Model.rows.Matrix(FFI_Model.rows.Subset_predictor_index,:)' ...
                        FFI_Model.frame_pixels.Matrix(FFI_Model.frame_pixels.Subset_predictor_index,:)' ...
                        FFI_Model.parallel_pixels.Matrix(FFI_Model.parallel_pixels.Subset_predictor_index,:)' ...
                        undershootModel ];
                
    % change time constant
    ffipix_exprow       = exp(-ROI.trailingFfi.Rows'/rowTimeConstant) ; 
    row_predictor_range = 1:FFI_Model.rows.Predictor_count;
    
    % 3rd column is exponential term for FFI model
    expRowIndicators = row_predictor_range(FFI_Model.rows.Subset_predictor_index) == 3;
    spatialModel(:,expRowIndicators) = ffipix_exprow';
    coefficient_count = size(spatialModel,2);
    trailing_black_data = reshape(this_image(ffiRowRange,ffiColumnRange),FFI_Model.pixel_count,1);
    
    % perform regression fit
    [regressionCoeffs,...
        regress_coeff_CI,...
        regressionResiduals,...
        regress_resid_CI,...
        regress_stats] = regress(trailing_black_data,spatialModel);                                                                         %#ok<ASGLU>
    
    % perform robust fit
    warning('off','stats:statrobustfit:IterationLimit');
    [robust_coefficient_list, robust_stats] = robustfit(spatialModel(:,2:coefficient_count),trailing_black_data);
    warning on all;

    % --> RECORD SINGLE-FFI FIT RESULTS IN OUTPUT STRUCTURES
    % FFI_fit_results contains coefficients, errors and statistics
    % FFI_fit_residInfo contains single-FFI residuals, response data and related info
    FFI_fit_results.coeffs_xFFI.regress(ffiIdx,:)                       = regressionCoeffs;
    FFI_fit_results.coeffs_xFFI.robust(ffiIdx,:)                        = robust_coefficient_list;
    FFI_fit_results.coeff_errs_xFFI.regressCI_lo(ffiIdx,:)              = regress_coeff_CI(:,1);
    FFI_fit_results.coeff_errs_xFFI.regressCI_hi(ffiIdx,:)              = regress_coeff_CI(:,2);
    FFI_fit_results.coeff_errs_xFFI.robust_stErr(ffiIdx,:)              = robust_stats.se;
    FFI_fit_results.coeff_errs_xFFI.robust_stats.sigma(ffiIdx)          = robust_stats.s;
    FFI_fit_results.coeff_errs_xFFI.robust_stats.ols_sigma(ffiIdx)      = robust_stats.ols_s;
    FFI_fit_results.coeff_errs_xFFI.robust_stats.robust_sigma(ffiIdx)   = robust_stats.robust_s;
    FFI_fit_results.coeff_errs_xFFI.robust_stats.mad_sigma(ffiIdx)      = robust_stats.mad_s;

    FFI_fit_residInfo.regress_resid_xFFI(ffiIdx,:)  = regressionResiduals;
    FFI_fit_residInfo.robust_resid_xFFI(ffiIdx,:)   = robust_stats.resid;
    FFI_fit_residInfo.response_data_xFFI(ffiIdx,:)  = trailing_black_data;
    FFI_fit_residInfo.robust_weights_xFFI(ffiIdx,:) = robust_stats.w;
end

% -> RECORD FFI INFO IN OUTPUT STRUCTURES
FFI_fit_results.numCoeffs         = length(regressionCoeffs);
FFI_fit_results.rowTimeConstant   = rowTimeConstant;
FFI_fit_results.thermalRowOffset  = thermalRowOffset;
FFI_fit_results.component_ID      = [repmat(FFI_Model.rows.Ref_ID, FFI_Model.rows.Predictor_count,1); ...
                                        repmat(FFI_Model.frame_pixels.Ref_ID, FFI_Model.frame_pixels.Predictor_count,1); ...
                                        repmat(FFI_Model.parallel_pixels.Ref_ID, FFI_Model.parallel_pixels.Predictor_count,1); ...
                                        repmat('US', size(undershootModel,2),1)];
FFI_fit_results.component_element   = [ 1:FFI_Model.rows.Predictor_count, ...
                                          1:FFI_Model.frame_pixels.Predictor_count, ...
                                          1:FFI_Model.parallel_pixels.Predictor_count, ...
                                          1:size(undershootModel,2) ];

% -> SAVE OUTPUT STRUCTURES TO FILES
A1_fit_results   =  struct( 'channel_number',   channel_num, ...
                            'LC',               LC_fit_results, ...
                            'FFI',              FFI_fit_results);
A1_fit_residInfo =  struct( 'channel_number',   channel_num, ...
                            'LC',               LC_fit_residInfo, ...
                            'FFI',              FFI_fit_residInfo);
dynablackResultsStruct.A1_fit_results                   = A1_fit_results;
dynablackResultsStruct.A1_fit_residInfo                 = A1_fit_residInfo;
dynablackResultsStruct.validDynablackFit                = true;                                          
dynablackResultsStruct.A1ModelDump.FCLC_Model           = FCLC_Model;
dynablackResultsStruct.A1ModelDump.FFI_Model            = FFI_Model; 
dynablackResultsStruct.A1ModelDump.rowsModelLinearRows  = linearRows;
dynablackResultsStruct.A1ModelDump.ROI                  = ROI;
dynablackResultsStruct.A1ModelDump.Inputs               = Inputs;
dynablackResultsStruct.A1ModelDump.Constants            = Constants;

