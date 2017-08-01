function initInfo = DynOBlack_init( inputs, dynablackResultsStruct )
%
% function initInfo = DynOBlack_init( inputs, dynablackResultsStruct )
%
% Initializes Dynamic 2D Black Model with fit results structure (dynablackResultsStruct) to enable use of DynOBlack function.
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

% ------- extract control parameters from inputs struct
channel                     = inputs.channel;
stdRatioThreshold           = inputs.stdRatioThreshold;
coefficentModelId           = inputs.coefficentModelId;
modelAutoSelectEnable       = inputs.modelAutoSelectEnable;
useRobustVerticalCoeffs     = inputs.useRobustVerticalCoeffs;
useRobustFrameFgsCoeffs     = inputs.useRobustFrameFgsCoeffs;
useRobustParallelFgsCoeffs  = inputs.useRobustParallelFgsCoeffs;
chi2Threshold               = inputs.chi2Threshold;

% ------- extract and/or build parameters from dynablackResultsStruct
meanBlackTable          = dynablackResultsStruct.meanBlackTable;
staticTwoDBlackImage    = dynablackResultsStruct.staticTwoDBlackImage;
removeStatic2DBlack     = dynablackResultsStruct.dynablackModuleParameters.removeStatic2DBlack;
nB1Models               = dynablackResultsStruct.B1bModelDump.initInfo.Constants.model_type_count;

% A1 model select parameters
longTimeConstant = dynablackResultsStruct.A1_fit_results.LC.longTimeConstant;
thermalRowOffset = dynablackResultsStruct.A1_fit_results.LC.thermalRowOffset;

% B1 model select parameters
timeColumnLocateCell = dynablackResultsStruct.B1aModelDump.initInfo.timeColumnLocate;
tempColumnLocateCell = dynablackResultsStruct.B1aModelDump.initInfo.tempColumnLocate;
stepColumnLocateCell = dynablackResultsStruct.B1aModelDump.initInfo.stepColumnLocate;

% count of predictors in models - use most complex model which will contain all predictors if modelAutoSelectEnable = true
% ------ assumes last model in list is most complex ---------
if modelAutoSelectEnable
    predictorModelId = nB1Models;
else
    predictorModelId = coefficentModelId;
end
predictorCount = numel( find( [timeColumnLocateCell{predictorModelId} > 0, ...
                                tempColumnLocateCell{predictorModelId} > 0, ...
                                any(stepColumnLocateCell{predictorModelId} > 0) ] ) );

% A1 fit parameters
linearRows          = dynablackResultsStruct.A1ModelDump.rowsModelLinearRows;
nVerticalCoeffs     = length(linearRows) + 1;
parallelFgsIdx      = dynablackResultsStruct.A1ModelDump.Inputs.controls.parallelPixelSelect;
nA1Coeffs           = dynablackResultsStruct.A1_fit_results.LC.numCoeffs;
nFgsFrameCoeffs     = dynablackResultsStruct.A1ModelDump.FCLC_Model.frame_pixels.Subset_predictor_count;        
nFgsParallelCoeffs  = dynablackResultsStruct.A1ModelDump.FCLC_Model.parallel_pixels.Subset_predictor_count;  
nRowCoeffs          = dynablackResultsStruct.A1ModelDump.FCLC_Model.rows.Subset_predictor_count;
nColCoeffs          = dynablackResultsStruct.A1ModelDump.FCLC_Model.columns.Subset_predictor_count;
nFfiRows            = dynablackResultsStruct.A1ModelDump.Constants.ffi_row_count;
nFfiCols            = dynablackResultsStruct.A1ModelDump.Constants.ffi_column_count;
maxMSmearRow        = dynablackResultsStruct.A1ModelDump.Constants.maxMaskedSmearRow;
nonlinColOffset     = 5;      % offset in resultsA1Lc from end of the fit coeffs and errors to non-linear (row time constant) column -- see resultsA1Lc below

resultsA1Lc = [dynablackResultsStruct.A1_fit_results.LC.coeffs_xLC.regress, ...
                  dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.regressCI_hi,...
                  dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.regressCI_lo,...
                  dynablackResultsStruct.A1_fit_results.LC.coeffs_xLC.robust, ...
                  dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stErr,...
                  zeros(dynablackResultsStruct.A1_fit_results.LC.lc_count,dynablackResultsStruct.A1_fit_results.LC.numCoeffs), ...
                  dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stats.sigma', ...
                  dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stats.ols_sigma', ...
                  dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stats.robust_sigma', ...
                  dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stats.mad_sigma', ...
                  ones(dynablackResultsStruct.A1_fit_results.LC.lc_count,1).*dynablackResultsStruct.A1_fit_results.LC.rowTimeConstant];

% A2 fit parameters
frameFgsIdx             = 1:dynablackResultsStruct.A2ModelDump.RCLC_Model.frame_pixels.Predictor_count;
rcfcGroups              = dynablackResultsStruct.A2ModelDump.Inputs.RC_FC_groups;
nearestLCtoRC           = [rcfcGroups.FC_groups];
nSerialSubsetPredictor  = dynablackResultsStruct.A2ModelDump.RCLC_Model.serial_pixels.Subset_predictor_count;
nLeadColSubsetPredictor = dynablackResultsStruct.A2ModelDump.RCLC_Model.lead_columns.Subset_predictor_count;
horizRcParamIdx         = [nSerialSubsetPredictor + (1:nLeadColSubsetPredictor), 2:5];  
nHorizRcParams          = length(horizRcParamIdx);
resultsA2Rc             = dynablackResultsStruct.A2_fit_results.coeffs_and_errors_xRC;
nA2Coeffs               = (size(resultsA2Rc,2))/3.;
readsPerLongCadence     = dynablackResultsStruct.A2ModelDump.Constants.readsPerLongCadence;

% B1a fit parameters
coefficientModels   = dynablackResultsStruct.B1aModelDump.initInfo.coefficient_models;
resultsB1a          = dynablackResultsStruct.B1a_fit_results.B1coeffs_and_errors_xCoeff;
residualsB1a        = dynablackResultsStruct.B1a_fit_residInfo.B1residuals_xCoeff;
robustWeightsB1a    = dynablackResultsStruct.B1a_fit_results.B1robust_weights_xCoeff;
nWeightsB1a         = length(robustWeightsB1a(1,1,:));
chi2ProbB1a         = dynablackResultsStruct.B1a_fit_results.ch2probALL.chi2_probabilities;
startIdx            = dynablackResultsStruct.B1aModelDump.initInfo.data_start;
endIdx              = dynablackResultsStruct.B1aModelDump.initInfo.data_end; 

% B1b fit parameters
resultsB1b          = dynablackResultsStruct.B1b_fit_results.B1bcoeffs_and_errors_xCoeff;
residualsB1b        = dynablackResultsStruct.B1b_fit_residInfo.B1bresiduals_xCoeff;
robustWeightsB1b    = dynablackResultsStruct.B1b_fit_results.B1brobust_weights_xCoeff;
nWeightsB1b         = length(robustWeightsB1b(1,1,:));
chi2ProbB1b         = dynablackResultsStruct.B1b_fit_results.chi2_probabilitiesB1b;
smearParamIdx       = dynablackResultsStruct.A2ModelDump.smearParamIndices;                  
nSmearParams        = length(smearParamIdx);

% ------- get clock state mask
fgsClockStates     = get_fgs_clock_states;
framePixelImage    = fgsClockStates.Frame;
parallelPixelImage = fgsClockStates.Parallel;
nFgsFrameStates    = max(framePixelImage(:));
nFgsParallelStates = max(parallelPixelImage(:));

% ------- build control structures
constants = struct( 'Channel_list',            channel, ...
                    'FGSFrame_States',         framePixelImage, ...
                    'FGSParallel_States',      parallelPixelImage, ...
                    'ffi_row_count',           nFfiRows,...
                    'ffi_column_count',        nFfiCols,...
                    'frameFGS_modeledList',    frameFgsIdx,...
                    'parallelFGS_modeledList', parallelFgsIdx,...
                    'removeStatic2DBlack',     removeStatic2DBlack,...
                    'readPerCadence_count',    readsPerLongCadence );

% --- vertCoeff ---
% Specifies location of the coefficients needed for the vertical (i.e. row dependent) part of 2D model. Note the order is the same between between
% both robust and regress coefficients defined in resultsA1Lc(columnwise) and resultsB1a (row-wise)
vertCoeff = ...
    struct( 'count',           nVerticalCoeffs,...                                  % number of coefficients used = time constant(non-linear) + 3 linear coefficients
            'nonlin_locate',   6 * nA1Coeffs + nonlinColOffset,...                  % column in resultsA1Lc which contains the nonlinear parameter
            'lin_locateRange', linearRows + useRobustVerticalCoeffs * nA1Coeffs,... % rows in resultsB1a which contains the linear parameters
            'error_offset1',   1 * nA1Coeffs,...                                    % offset from B1a regress coeff to A1 regress coeff high confidence interval limit
            'error_offset2',   2 * nA1Coeffs,...                                    % offset from B1a regress coeff to A1 regress coeff low confidence interval limit
            'error_offset3',   3 * nA1Coeffs );                                     % offset from B1a robust coeff to A1robust coeff standard error

% --- horizCoeff --- 
% Specifies location of the coefficients needed for the horizontal (i.e. column dependent) part of 2D model        
horizCoeff = ...
    struct( 'count',                  nHorizRcParams + 2*nSmearParams,...                       % the number of unique parameters in model
            'RCparam_count',          nHorizRcParams,...                                        % number of RC coefficients used
            'smearParam_count',       nSmearParams,...                                          % number of smear coefficients used
            'RCparam_locateRange',    horizRcParamIdx,...                                       % columns in resultsA2Rc which contain RC coefficients
            'smearParam_locateRange', smearParamIdx, ...                                        % first indices in resultsB1b which contain the smear coefficients
            'nearestLCtoRC',          nearestLCtoRC,...                                         % list of long cadences closest to RC cadences
            'RCrefLoc',               nHorizRcParams + (1:nSmearParams) - nSmearParams,...      % location of last nSmearParams RC coefficients
            'error_offset1',          1 * nA2Coeffs, ...                                        % offset from B1b regress coeff to A2 regress coeff high confidence interval limit
            'error_offset2',          2 * nA2Coeffs);                                           % offset from B1b regress coeff to A2 regress coeff low confidence interval limit

% --- frameFGSCoeff ---
% Specifies location of the coefficients needed for the frame FGS crosstalk part of 2D model
frameFGSCoeff = ...
    struct( 'count',                nFgsFrameStates,...                             % the number of unique frame FGS clock cycles in model
            'A1count',              nFgsFrameCoeffs, ...                            % number of fgs frame coeffs used in A1 fit
            'A1locateRange',        nRowCoeffs + ...
                                    nColCoeffs + ...
                                    (1:nFgsFrameCoeffs) + ...
                                    useRobustFrameFgsCoeffs * nA1Coeffs,...         % the columns in resultsA1Lc which contains the A1parameters
            'RCparam_locateRange',  nSerialSubsetPredictor + ...
                                    nLeadColSubsetPredictor + ...
                                    (nFgsFrameCoeffs+1:nFgsFrameStates),...         % columns in resultsA2Rc which contains the 4 RC frame FGS fit params
            'error_offset1',        1 * nA1Coeffs, ...                              % offset from B1 regress coeffs to A1 regress coeffs high confidence interval limit
            'error_offset2',        2 * nA1Coeffs, ...                              % offset from B1 regress coeffs to A1 regress coeffs low confidence interval limit
            'error_offset3',        3 * nA1Coeffs );                                % offset from B1 robust coeffs to A1 robust coeffs standard error

% --- parallelFGSCoeff ---
% Specifies location of the coefficients needed for the parallel FGS crosstalk part of 2D model
parallelFGSCoeff = ...
    struct( 'count',                nFgsParallelStates, ...                         % the number of unique parallel FGS  clock cycles in model
            'A1count',              nFgsParallelCoeffs, ...                         % the number of parallel FGS coefficients being used from A1 fits
            'A1locateRange',        nRowCoeffs + ...
                                    nColCoeffs + ...
                                    nFgsFrameCoeffs + ...
                                    (1:nFgsParallelCoeffs) + ...
                                    useRobustParallelFgsCoeffs * nA1Coeffs,...      % columns in resultsA1Lc which contain the parameters        
            'A1clockOffset',        parallelFgsIdx, ...                             % list defining clock offset-to-A1coefficient correspondence
            'error_offset1',        1 * nA1Coeffs, ...                              % offset from B1 regress coeffs to A1 regress coeffs high confidence interval limit
            'error_offset2',        2 * nA1Coeffs, ...                              % offset from B1 regress coeffs to A1regress coeffs low confidence interval limit
            'error_offset3',        3 * nA1Coeffs );                                % offset from B1 robust coeffs to A1robust coeffs standard error

% --- predCoeff ---
% Specifies location of the time, temperature and step data
predCoeff = ...
    struct( 'count',                 predictorCount, ...                            % nominally one for temperature + one for time + one set of step columns = 3
            'temp_locate',           tempColumnLocateCell{predictorModelId}, ...    % column in coefficientModels{predCoeff.coefficentModelId} containing LC temperatures  
            'time_locate',           timeColumnLocateCell{predictorModelId}, ...    % column in coefficientModels{predCoeff.coefficentModelId} containing LC times
            'step_locate',           stepColumnLocateCell{predictorModelId}, ...    % columns in coefficientModels{predCoeff.coefficentModelId} containing bias deltas from constant term
            'coefficentModelId',     predictorModelId);                             % coefficientModels cell containing model elements for constant+temperature+time


% ---- PREDICTOR COEFFICIENTS ------------------------------------------------------------------------------
predictorObj = ModelParameters(predictorCount);
coeffTypes   = zeros(predictorCount,1);
coeffCells   = cell(predictorCount,1);

% use coeff type = 5 --> interpolate on discrete coefficients
coeffCells{1}  = coefficientModels{predictorModelId}(:,predCoeff.time_locate);               % times
coeffTypes(1)  = 5;
coeffCells{2}  = coefficientModels{predictorModelId}(:,predCoeff.temp_locate);               % temperatures
coeffTypes(2)  = 5;
% use coeff type = 7 --> identity -- return coeffCells content
coeffCells{3}  = coefficientModels{predictorModelId}(:,predCoeff.step_locate);               % steps array
coeffTypes(3)  = 7;

% initialize predictor model parameters object
predictorObj = predictorObj.initialize(predictorCount, coeffTypes, coeffCells);

% develop predictor covariance for each model
predictorCovariance = cell(nB1Models,1);
for k=1:nB1Models
    [dummy,singularValuesMatrix,rightSingularMatrix] = svds(coefficientModels{k},size(coefficientModels{k},2));                       %#ok<ASGLU>
    transformationMatrix = rightSingularMatrix / singularValuesMatrix;
    predictorCovariance{k} = transformationMatrix * transformationMatrix';
end


% ---- VERTICAL COEFFICIENTS ------------------------------------------------------------------------------
vertCoeffObj = ModelParameters(vertCoeff.count);
coeffTypes = zeros(vertCoeff.count,1);
coeffCells = num2cell(zeros(vertCoeff.count,1));
vertErrorObj = ModelParameters(vertCoeff.count);
errorTypes = zeros(vertCoeff.count,1);
errorCells = num2cell(zeros(vertCoeff.count,1));

nVertCoeffs = vertCoeff.count;

% ------ discrete interpolation plus no smoothing on any vertical coefficients per KSOC-3850 ----- see comments with *** below

% time_constant coefficient
% use coeff type = 5 --> interpolate on discrete coefficients
coeffTypes(1) = 5;
coeffCells{1} = resultsA1Lc(:,vertCoeff.nonlin_locate);
errorTypes(1) = 6;
errorCells{1} = 0;

% Technically this could be coeffTypes = 6 --> constant since each cadence conatins the same nonlinear time constant (rowTimeConstant).
% errorTypes and errorCells would remain the same. Leave as is for now.
% coeffTypes(1) = 6;
% coeffCells{1} = median(resultsA1Lc(:,vertCoeff.nonlin_locate));
% errorTypes(1) = 6;
% errorCells{1} = 0;

% constant, log and exponential coefficients
for iParam = 2:nVertCoeffs
    
    thisCoeffLocation = vertCoeff.lin_locateRange(iParam-1);
    
    if modelAutoSelectEnable
        
        thisChi2Set = chi2ProbB1a(thisCoeffLocation,:);

        if all( thisChi2Set(1:4) > chi2Threshold )
            % all models fit equally well - use raw coefficeints - -1 indicates no model selected
            bestModelIndex  = -1;            
        else
            % determine the best model to use based on chi^2
            if thisChi2Set(1) < chi2Threshold
                bestModelIndex = 1;
            elseif thisChi2Set(2) < chi2Threshold
                bestModelIndex = 2;
            elseif thisChi2Set(3) < chi2Threshold
                bestModelIndex = 3;
            elseif thisChi2Set(4) < chi2Threshold
                bestModelIndex = 4;
            end
        end
    else
        % set model ID per inputs
        bestModelIndex = coefficentModelId;                     %#ok<*NASGU>
    end

    % ----------- force discrete coefficients without modeling for all coeffs - KSOC-3850 ***
    bestModelIndex = -1;
    
    if bestModelIndex > 0
        
        % set up coeff and error types based on model selected
        switch bestModelIndex
            case 1
                coeffTypes(iParam) = 0;
                errorTypes(iParam) = 11;
            case 2
                coeffTypes(iParam) = 1;
                errorTypes(iParam) = 8;
            case 3
                coeffTypes(iParam) = 2;
                errorTypes(iParam) = 9;
            case 4
                coeffTypes(iParam) = 3;
                errorTypes(iParam) = 10;
        end

        % number of columns in best model
        numModelColumns = size(coefficientModels{bestModelIndex},2);

        % get only fitted coeffs in resultsB1a corresponding to the best model
        coeffCells{iParam} = squeeze(resultsB1a(thisCoeffLocation, bestModelIndex, 2:(numModelColumns+1)));
        errorCells{iParam} = predictorCovariance{bestModelIndex} * var(squeeze(residualsB1a(thisCoeffLocation, bestModelIndex, 1:nWeightsB1a)));
    else
        
        % all models fit equally well - use raw coefficeints        
        nFitParams  = size(coefficientModels{1},2);
        fitParamIdx = 2:(2 + nFitParams - 1);

        fitParams = squeeze(resultsB1a(thisCoeffLocation,1,fitParamIdx));
        fitResid  = squeeze(residualsB1a(thisCoeffLocation,1,1:nWeightsB1a));

        % regenerate raw coeffs from lowest order fit + fit residuals
        coeffList = fitResid + coefficientModels{1} * fitParams(:);

        if thisCoeffLocation > vertCoeff.error_offset1
            % error_offset3 == standard error
            coeffError = median(resultsA1Lc(:,vertCoeff.error_offset3 + thisCoeffLocation));
        else
            % error_offset1 == high confidence interval bound, error_offset2 == low confidence interval bound
            coeffError = median((resultsA1Lc(:,vertCoeff.error_offset1 + thisCoeffLocation) - resultsA1Lc(:,vertCoeff.error_offset2 + thisCoeffLocation))/2);
        end

        stdRatio = std( diff(coeffList) ) / coeffError;             %#ok<NASGU>
        
        % ----------- force no smoothing for all coeffs - KSOC-3850 ***
        stdRatio = stdRatioThreshold + 1;

        % smooth raw coeffs if noise/error ratio is over threshold
        if stdRatio > stdRatioThreshold
            % use coeff type = 5 --> interpolate on discrete coefficients
            coeffTypes(iParam) = 5;
            coeffCells{iParam} = coeffList;
            errorTypes(iParam) = 6;
            errorCells{iParam} = coeffError;
        else
            % use coeff type = 4 --> interpolate on smoothed coefficients
            coeffTypes(iParam) = 4;
            coeffCells{iParam} = smooth_vsLC(coeffList, predictorObj.Coefficients, startIdx, endIdx);
            errorTypes(iParam) = 6;
            errorCells{iParam} = coeffError * std( diff(coeffCells{iParam}) ) / std( diff(coeffList) );
        end
    end
end

vertCoeffObj = vertCoeffObj.initialize( nVertCoeffs, coeffTypes, coeffCells );
vertErrorObj = vertErrorObj.initialize( nVertCoeffs, errorTypes, errorCells );


% ---- HORIZONTAL COEFFICIENTS ------------------------------------------------------------------------------
horizCoeffObj = ModelParameters(horizCoeff.count);
coeffTypes = zeros(horizCoeff.count,1);
coeffCells = num2cell(zeros(horizCoeff.count,1));

horizErrorObj = ModelParameters(horizCoeff.count);
errorTypes = zeros(horizCoeff.count,1);
errorCells = num2cell(zeros(horizCoeff.count,1));

nHorizontalRcCoeffs = horizCoeff.RCparam_count;
nHorizontalSmearCoeffs = horizCoeff.smearParam_count;

% coefficients from RC fits
for iParam=1:nHorizontalRcCoeffs
    % use coeff type = 6 --> constant
    coeffTypes(iParam) = 6;
    coeffVal = mean(resultsA2Rc(:,horizCoeff.RCparam_locateRange(iParam)));
    if ~isnan(coeffVal)
        coeffCells{iParam} = coeffVal;
    else
        coeffCells{iParam} = 0;
    end
    errorTypes(iParam) = 6;
    errorCells{iParam} = 0;
end

% linear and quadradic coefficients from smear data (determine variation only)
for iParam = 1:nHorizontalSmearCoeffs

    paramLoc = iParam + nHorizontalRcCoeffs;
    thisCoeffLocation = horizCoeff.smearParam_locateRange(iParam);

    if modelAutoSelectEnable

        thisChi2Set = chi2ProbB1b(thisCoeffLocation,:);

        if all( thisChi2Set(1:4) > chi2Threshold )
            % all models fit equally well -  -1 indicates no model selected
            bestModelIndex  = -1;         
        else
            % determine the best model to use based on chi^2
            if thisChi2Set(1) < chi2Threshold
                bestModelIndex = 1;
            elseif thisChi2Set(2) < chi2Threshold
                bestModelIndex = 2;
            elseif thisChi2Set(3) < chi2Threshold
                bestModelIndex = 3;
            elseif thisChi2Set(4) < chi2Threshold
                bestModelIndex = 4;
            end
        end
    else
        % set model ID per inputs
        bestModelIndex = coefficentModelId;
    end

    if bestModelIndex > 0
        % set up coeff and error types based on model selected
        switch bestModelIndex
            case 1
                coeffTypes(paramLoc) = 0;
                errorTypes(paramLoc) = 11;
            case 2
                coeffTypes(paramLoc) = 1;
                errorTypes(paramLoc) = 8;
            case 3
                coeffTypes(paramLoc) = 2;
                errorTypes(paramLoc) = 9;
            case 4
                coeffTypes(paramLoc) = 3;
                errorTypes(paramLoc) = 10;
        end

        % number of columns in best model
        numModelColumns = size(coefficientModels{bestModelIndex},2);
        
        % get only fitted coeffs in resultsB1b corresponding to the best model
        coeffCells{paramLoc} = squeeze(resultsB1b(thisCoeffLocation, bestModelIndex, 2:(numModelColumns+1)));
        errorCells{paramLoc} = predictorCovariance{bestModelIndex} * var(squeeze(residualsB1a(thisCoeffLocation, bestModelIndex, 1:nWeightsB1a)));
        
    else
        % all models fit equally well        
        nFitParams      = size(coefficientModels{1},2);
        fitParamIdx     = 2:(2 + nFitParams - 1);

        fitParams = squeeze(resultsB1b(thisCoeffLocation,1,fitParamIdx));
        fitResid  = squeeze(residualsB1b(thisCoeffLocation,1,1:nWeightsB1b));

        % regenerate raw coeffs from lowest order fit + residuals
        coeffList = fitResid + coefficientModels{1} * fitParams(:);

        % error_offset1 == high confidence interval bound, error_offset2 == low confidence interval bound
        coeffErrorVal  = median( (resultsA2Rc(:,horizCoeff.error_offset1+thisCoeffLocation) - resultsA2Rc(:,horizCoeff.error_offset2+thisCoeffLocation) ) / 2 );
        
        if ~isnan(coeffErrorVal)
            coeffError = coeffErrorVal;
        else
            coeffError = 0;
        end

        stdRatio = std( diff(coeffList) ) / coeffError;
        if stdRatio > stdRatioThreshold
            % use coeff type = 5 --> interpolate on discrete coefficients
            coeffTypes(paramLoc) = 5;
            coeffCells{paramLoc} = coeffList;
            errorTypes(paramLoc) = 6;
            errorCells{paramLoc} = coeffError;
        else
            % use coeff type = 4 --> interpolate on smoothed coefficients
            coeffTypes(paramLoc) = 4;
            coeffCells{paramLoc} = smooth_vsLC(coeffList, predictorObj.Coefficients, startIdx, endIdx);
            errorTypes(paramLoc) = 6;
            errorCells{paramLoc} = coeffError * std( diff(coeffCells{paramLoc}) ) / std( diff(coeffList) );
        end
    end

    % use coeff type = 6 --> constant
    paramLocB = iParam + nHorizontalSmearCoeffs + nHorizontalRcCoeffs;
    coeffTypes(paramLocB) = 6;
    
    nFitParams      = size(coefficientModels{1},2);
    fitParamIdx     = 2:(2 + nFitParams - 1);
        
    fitParams = squeeze(resultsB1b(thisCoeffLocation,1,fitParamIdx));
    fitResid  = squeeze(residualsB1b(thisCoeffLocation,1,horizCoeff.nearestLCtoRC));
    reference = coeffCells{horizCoeff.RCrefLoc(iParam)};
    model     = coefficientModels{1}(horizCoeff.nearestLCtoRC,:);

    % regenerate raw coeffs from lowest order B1b fit + residuals
    coeffVal = mean(fitResid + model * fitParams(:)) - reference;
    if ~isnan(coeffVal)
        coeffCells{paramLocB} = mean(fitResid + model * fitParams(:)) - reference;
    else
        coeffCells{paramLocB} = 0;
    end
    errorTypes(paramLocB) = 6;
    errorCells{paramLocB} = 0;
end

horizCoeffObj = horizCoeffObj.initialize(horizCoeff.count,coeffTypes, coeffCells);
horizErrorObj = horizErrorObj.initialize( horizCoeff.count, errorTypes, errorCells );  %08-22-2011:JK



% ---- FGS-FRAME CROSSTALK COEFFICIENTS ------------------------------------------------------------------------------
frameCoeffObj = ModelParameters(frameFGSCoeff.count);
coeffTypes = zeros(frameFGSCoeff.count,1);
coeffCells = num2cell(zeros(frameFGSCoeff.count,1));

frameErrorObj = ModelParameters(frameFGSCoeff.count);
errorTypes  = zeros(frameFGSCoeff.count,1);
errorCells  = num2cell(zeros(frameFGSCoeff.count,1));

% clock sequence position coefficients
for iParam = 1:frameFGSCoeff.A1count

    thisCoeffLocation = frameFGSCoeff.A1locateRange(iParam);

    if modelAutoSelectEnable

        thisChi2Set = chi2ProbB1a(thisCoeffLocation,:);

        if all( thisChi2Set(1:4) > chi2Threshold )
            % all models fit equally well -  -1 == no model selected
            bestModelIndex  = -1; 
        else
            % determine the best model to use based on chi^2
            if thisChi2Set(1) < chi2Threshold
                bestModelIndex = 1; 
            elseif thisChi2Set(2) < chi2Threshold
                bestModelIndex = 2;
            elseif thisChi2Set(3) < chi2Threshold
                bestModelIndex = 3;
            elseif thisChi2Set(4) < chi2Threshold
                bestModelIndex = 4;
            end
        end
    else
        % set model ID per inputs
        bestModelIndex = coefficentModelId;
    end
    
    if bestModelIndex > 0
        % set up coeff and error types based on model selected
        switch bestModelIndex
            case 1
                coeffTypes(iParam) = 0;
                errorTypes(iParam) = 11;
            case 2
                coeffTypes(iParam) = 1;
                errorTypes(iParam) = 8;
            case 3
                coeffTypes(iParam) = 2;
                errorTypes(iParam) = 9;
            case 4
                coeffTypes(iParam) = 3;
                errorTypes(iParam) = 10;
        end

        % number of columns in best model
        numModelColumns = size(coefficientModels{bestModelIndex},2);
        
        % get only fitted coeffs in resultsB1a corresponding to the best model
        coeffCells{iParam} = squeeze(resultsB1a(thisCoeffLocation, bestModelIndex, 2:(numModelColumns+1)));
        errorCells{iParam} = predictorCovariance{bestModelIndex} * var(squeeze(residualsB1a(thisCoeffLocation, bestModelIndex, 1:nWeightsB1a)));        
    else
        % all models fit equally well        
        nFitParams      = size(coefficientModels{1},2);
        fitParamIdx     = 2:(2 + nFitParams - 1);

        fitParams = squeeze(resultsB1a(thisCoeffLocation,1,fitParamIdx));
        fitResid  = squeeze(residualsB1a(thisCoeffLocation,1,1:nWeightsB1a));
        
        % regenerate raw coeffs from lowest order fit + residuals
        coeffList = fitResid + coefficientModels{1} * fitParams(:);

        if thisCoeffLocation > frameFGSCoeff.error_offset1
            % error_offset3 == standard error
            coeffError = median(resultsA1Lc(:,frameFGSCoeff.error_offset3+thisCoeffLocation));
        else
            % error_offset1 == high confidence interval bound, error_offset2 == low confidence interval bound
            coeffError = median((resultsA1Lc(:, frameFGSCoeff.error_offset1 + thisCoeffLocation) - ...
                resultsA1Lc(:, frameFGSCoeff.error_offset2 + thisCoeffLocation))/2 );
        end

        stdRatio = std( diff(coeffList) ) / coeffError;

        if stdRatio > stdRatioThreshold
            % use coeff type = 5 --> interpolate on discrete coefficients
            coeffTypes(iParam) = 5;
            coeffCells{iParam} = coeffList;
            errorTypes(iParam) = 6;
            errorCells{iParam} = coeffError;
        else
            % use coeff type = 4 --> interpolate on smoothed coefficients
            coeffTypes(iParam) = 4;
            coeffCells{iParam} = smooth_vsLC(coeffList, predictorObj.Coefficients, startIdx, endIdx);
            errorTypes(iParam) = 6;
            errorCells{iParam} = coeffError * std( diff(coeffCells{iParam}) ) / std( diff(coeffList) );
        end
    end
end

for iParam = frameFGSCoeff.A1count+1:frameFGSCoeff.count
    % use coeff type = 6 --> constant
    coeffTypes(iParam) = 6;
    coeffVal = mean(resultsA2Rc(:,frameFGSCoeff.RCparam_locateRange(iParam-frameFGSCoeff.A1count)));
    if ~isnan(coeffVal)
        coeffCells{iParam} = coeffVal;
    else
        coeffCells{iParam} = 0;
    end

    errorTypes(iParam) = 6;
    errorCells{iParam} = 0;
end

frameCoeffObj = frameCoeffObj.initialize(frameFGSCoeff.count,coeffTypes,coeffCells);
frameErrorObj = frameErrorObj.initialize( frameFGSCoeff.count, errorTypes, errorCells );



% ---- FGS-PARALLEL CROSSTALK COEFFICIENTS ------------------------------------------------------------------------------
parallelCoeffObj = ModelParameters(parallelFGSCoeff.count);
coeffTypes = zeros(parallelFGSCoeff.count,1);
coeffCells = num2cell(zeros(parallelFGSCoeff.count,1));

parallelErrorObj = ModelParameters(parallelFGSCoeff.count);
errorTypes  = zeros(parallelFGSCoeff.count,1);
errorCells  = num2cell(zeros(parallelFGSCoeff.count,1));


% clock sequence position coefficients
for iParam = 1:parallelFGSCoeff.A1count

    thisCoeffLocation = parallelFGSCoeff.A1locateRange(iParam);
    thisClockOffset = parallelFGSCoeff.A1clockOffset(iParam);

    if modelAutoSelectEnable

        thisChi2Set = chi2ProbB1a(thisCoeffLocation,:);

        if all( thisChi2Set(1:4) > chi2Threshold )
            % all models fit equally well -   -1 == no model selected
            bestModelIndex  = -1;           
        else
            % determine the best model to use based on chi^2
            if thisChi2Set(1) < chi2Threshold
                bestModelIndex = 1;
            elseif thisChi2Set(2) < chi2Threshold
                bestModelIndex = 2;   
            elseif thisChi2Set(3) < chi2Threshold
                bestModelIndex = 3;         
            elseif thisChi2Set(4) < chi2Threshold
                bestModelIndex = 4;
            end
        end
    else
        % set model ID per inputs
        bestModelIndex = coefficentModelId;
    end
    
    if bestModelIndex > 0
        % set up coeff and error types based on model selected
        switch bestModelIndex
            case 1
                coeffTypes(thisClockOffset) = 0;
                errorTypes(thisClockOffset) = 11;
            case 2
                coeffTypes(thisClockOffset) = 1;
                errorTypes(thisClockOffset) = 8;
            case 3
                coeffTypes(thisClockOffset) = 2;
                errorTypes(thisClockOffset) = 9;
            case 4
                coeffTypes(thisClockOffset) = 3;
                errorTypes(thisClockOffset) = 10;
        end

        % number of columns in best model
        numModelColumns = size(coefficientModels{bestModelIndex},2);
        
        % get only fitted coeffs in resultsB1a corresponding to the best model
        coeffCells{thisClockOffset} = squeeze(resultsB1a(thisCoeffLocation, bestModelIndex, 2:(numModelColumns+1)));
        errorCells{thisClockOffset} = predictorCovariance{bestModelIndex} * var(squeeze(residualsB1a(thisCoeffLocation, bestModelIndex, 1:nWeightsB1a)));
    else        
        % all models fit equally well        
        nFitParams = size(coefficientModels{1},2);
        fitParamIdx = 2:(2 + nFitParams - 1);
        
        fitParams = squeeze(resultsB1a(thisCoeffLocation,1,fitParamIdx));
        fitResid  = squeeze(residualsB1a(thisCoeffLocation,1,1:nWeightsB1a));
        
        % regenerate raw coeffs from lowest order fit + residuals
        coeffList = fitResid + coefficientModels{1} * fitParams(:);

        if thisCoeffLocation > parallelFGSCoeff.error_offset1
            % error_offset3 == standard error
            coeffError = median(resultsA1Lc(:,parallelFGSCoeff.error_offset3 + thisCoeffLocation));
        else
            % error_offset1 == high confidence interval bound, error_offset2 == low confidence interval bound
            coeffError = median((resultsA1Lc(:,parallelFGSCoeff.error_offset1 + thisCoeffLocation)- ...
                resultsA1Lc(:,parallelFGSCoeff.error_offset2 + thisCoeffLocation))/2);
        end

        stdRatio = std( diff(coeffList) ) / coeffError;

        if stdRatio > stdRatioThreshold
            % use coeff type = 5 --> interpolate on discrete coefficients
            coeffTypes(thisClockOffset) = 5;
            coeffCells{thisClockOffset} = coeffList;
            errorTypes(thisClockOffset) = 6;
            errorCells{thisClockOffset} = coeffError;
        else
            % use coeff type = 4 --> interpolate on smoothed coefficients
            coeffTypes(thisClockOffset) = 4;
            coeffCells{thisClockOffset} = smooth_vsLC(coeffList, predictorObj.Coefficients, startIdx, endIdx);
            errorTypes(thisClockOffset) = 6;
            errorCells{thisClockOffset} = coeffError * std( diff(coeffCells{thisClockOffset}) ) / std( diff(coeffList) );

        end
    end
end

parallelCoeffObj = parallelCoeffObj.initialize(parallelFGSCoeff.count,coeffTypes,coeffCells);
parallelErrorObj = parallelErrorObj.initialize( parallelFGSCoeff.count, errorTypes, errorCells );


% ----- assemble model input structures and populate return structure with constants and dynablack model

% develop correlation matrix for verticle fit
[dummy,singularValuesMatrix,rightSingularMatrix] = svd(dynablackResultsStruct.A1ModelDump.FCLC_Model.rows.Matrix(linearRows,:)',0);         %#ok<ASGLU>
transformationMatrix        = rightSingularMatrix / singularValuesMatrix;
verticalCovarianceMatrix    = transformationMatrix * transformationMatrix';
sigmas                      = diag( sqrt( 1./diag(verticalCovarianceMatrix) ) );
verticalCorrelationMatrix   = sigmas * verticalCovarianceMatrix * sigmas;

modelInputs = ...
    struct( 'mean_black',               meanBlackTable(channel),...
            'staticTwoDBlackImage',     staticTwoDBlackImage,...
            'removeStatic2DBlack',      removeStatic2DBlack,...
            'longTimeConstant',         longTimeConstant,...
            'thermalRowOffset',         thermalRowOffset,...            
            'maxMaskedSmearRow',        maxMSmearRow,...
            'vertical_coeffs',          vertCoeffObj, ...
            'horizontal_coeffs',        horizCoeffObj, ...
            'FGSframe_coeffs',          frameCoeffObj, ...
            'FGSparallel_coeffs',       parallelCoeffObj, ...
            'predictor_data',           predictorObj);
        
errorInputs = ...
    struct( 'vertical_errCoeffs',       vertErrorObj, ...
            'horizontal_errCoeffs',     horizErrorObj, ...
            'FGSframe_errCoeffs',       frameErrorObj, ...
            'FGSparallel_errCoeffs',    parallelErrorObj, ...
            'predictor_errors',         [], ...  
            'verticalCorrelationMatrix', verticalCorrelationMatrix);
 
initInfo = ...
    struct( 'constants',      constants,...
            'dynablackModel', dynamicBlackModel( channel, modelInputs, errorInputs));


