function dynablackResultsStruct = B1b_main( dynablackObject, dynablackResultsStruct )
% function dynablackResultsStruct = B1b_main( dynablackObject, dynablackResultsStruct )
%
% This dynablackClass method performs linear fits of A2 results to combinations of a constant, temperature, and time.
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


% set up control parameters
[initInfo, inputs] = B1b_parameter_init( dynablackObject );

% extract models
coefficientModels = initInfo.coefficient_models;

% extract constants
constants   = initInfo.Constants;
idx0        = constants.data_start;
idxEnd      = constants.data_end;
nCadences   = constants.lc_count;
nModels     = constants.model_type_count;
maxA2Coeffs = constants.A2coeff_count_Max;
maxB1Coeffs = constants.max_B1coeffs;

% allocate space
B1ResponseVector          = zeros(maxA2Coeffs, nCadences);
B1ResponseVectorErrors    = zeros(maxA2Coeffs, nCadences);
B1bCoeffsAndErrorsByCoeff = zeros(maxA2Coeffs, nModels, 6*maxB1Coeffs+5);
B1bResidualsByCoeff       = zeros(maxA2Coeffs, nModels, 2*nCadences);
B1bRobustWeightsByCoeff   = zeros(maxA2Coeffs, nModels, nCadences);
regressProb               = zeros(maxA2Coeffs, nModels);
robustProb                = zeros(maxA2Coeffs, nModels);
goodnessInfo              = zeros(4,nModels);

    
% -> GET A2 SPATIAL COEFFICIENTS FOR MULTI-CADENCE FITS
smearCoeffsAndErrorsByLc  = dynablackResultsStruct.A2_fit_results.smearCoeffs_and_errors_xLC; 
nA2Coeffs                 = size(smearCoeffsAndErrorsByLc,2) / 3;
A2CoeffColumns            = 1:nA2Coeffs;
A2CoeffErrorColumnRegress = [nA2Coeffs+(1:nA2Coeffs); 2*nA2Coeffs+(1:nA2Coeffs)];

for iCoeff = 1:nA2Coeffs
    columnNum = A2CoeffColumns(iCoeff);
    B1ResponseVector(iCoeff,idx0:idxEnd) = smearCoeffsAndErrorsByLc(:,columnNum);
    errorColumnNumRegress1 = A2CoeffErrorColumnRegress(1,iCoeff);
    errorColumnNumRegress2 = A2CoeffErrorColumnRegress(2,iCoeff);
    B1ResponseVectorErrors(iCoeff,idx0:idxEnd) = (smearCoeffsAndErrorsByLc(:,errorColumnNumRegress1) - smearCoeffsAndErrorsByLc(:,errorColumnNumRegress2))/2.;
end


% turn off robustfit warning
warning('off','stats:statrobustfit:IterationLimit');

% -> LOOP - FOR EACH A2 SPATIAL COEFFICIENT
for iCoeff = 1:nA2Coeffs

    % --> PERFORM LINEAR FITS ON ONE A2 SPATIAL COEFFICIENT
    % performs a linear fit to obtain thermo-temporal parameters for a single A2 spatial coefficient

    % get data for one coefficient        
    thisParam      = B1ResponseVector(iCoeff,:)';                    
    thisParamError = B1ResponseVectorErrors(iCoeff,:)';

    % --> LOOP - FOR EACH OF A SERIES OF MODELS
    for iModel = 1:nModels
        
        % ---> PERFORM LINEAR FITS FOR 1 MODEL
        [regressionCoeffs,...
            regressionCoeffCI,...
            regressionResiduals] = regress( thisParam, coefficientModels{iModel}, 0.32);
        
        [robustCoeffs, robustStats]  = robustfit( coefficientModels{iModel}, thisParam, 'bisquare', 4.685, 'off' );

        % ---> RECORD FIT RESULTS IN OUTPUT ARRAYS
        chi2Regress = sum( (regressionResiduals./thisParamError).^2 );
        dofRegress  = nCadences - size(coefficientModels{iModel},2) - 1;
        chi2Robust  = sum( (robustStats.resid./thisParamError).^2 );
        dofRobust   = sum(robustStats.w) - size(coefficientModels{iModel},2) - 1;

        goodnessInfo(:,iModel) = [chi2Regress; dofRegress; chi2Robust; dofRobust];

        fitResults =  [regressionCoeffs; ... 
                        regressionCoeffCI(:,2); ...
                        regressionCoeffCI(:,1); ...
                        robustCoeffs; ...
                        robustStats.se; ...
                        robustStats.p;
                        robustStats.s;
                        robustStats.ols_s;
                        robustStats.robust_s;
                        robustStats.mad_s;
                        goodnessInfo(:,iModel)]';

        lengthFitResults = length( fitResults ) + 1;

        B1bCoeffsAndErrorsByCoeff(iCoeff, iModel, 1:lengthFitResults)  = [lengthFitResults fitResults]';
        B1bResidualsByCoeff(iCoeff, iModel, 1:2*nCadences)    = [regressionResiduals; robustStats.resid];
        B1bRobustWeightsByCoeff(iCoeff, iModel, 1:nCadences) = robustStats.w;

        % --> END OF MODEL LOOP
    end

    % -> RECORD COEFFICIENT-DEPENDENT INFO IN OUTPUT ARRAYS
    regressProb(iCoeff,:) = chi2cdf(goodnessInfo(1,:),goodnessInfo(2,:));
    robustProb(iCoeff,:)  = chi2cdf(goodnessInfo(3,:),goodnessInfo(4,:));

    % --> END OF COEFFICIENT LOOP
end

% turn on robustfit warning
warning('on','stats:statrobustfit:IterationLimit');

% construct chi2 statistics
B1bChi2Probabilities = [regressProb, robustProb];

% save to results struct
dynablackResultsStruct.B1b_fit_results.B1bcoeffs_and_errors_xCoeff = B1bCoeffsAndErrorsByCoeff;
dynablackResultsStruct.B1b_fit_results.B1brobust_weights_xCoeff    = B1bRobustWeightsByCoeff;
dynablackResultsStruct.B1b_fit_results.chi2_probabilitiesB1b       = B1bChi2Probabilities;

dynablackResultsStruct.B1b_fit_residInfo.B1bresiduals_xCoeff = B1bResidualsByCoeff;
                                    
% dynablackResultsStruct.B1bModelDump.coefficient_models = coefficient_models;
dynablackResultsStruct.B1bModelDump.initInfo           = initInfo;
dynablackResultsStruct.B1bModelDump.Inputs             = inputs;                             

