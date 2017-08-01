function dynablackResultsStruct = B1a_main( dynablackObject, dynablackResultsStruct )
% function dynablackResultsStruct = B1a_main( dynablackObject, dynablackResultsStruct )
% 
% This dynablackClass method performs fitting of the coefficients determined in A1_main to combinations of a constant, temperature, and time.
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
 

% extract control parameters
[initInfo, inputs] = B1a_parameter_init( dynablackObject );

% extract models
coefficientModels   = initInfo.coefficient_models;

% extract constants
nCadences       = length(inputs.lc_list);
idx0            = initInfo.data_start;
idxEnd          = initInfo.data_end;
maxA1Coeffs     = initInfo.A1coeff_count_Max;
nModels         = initInfo.model_type_count;
maxB1aCoeffs    = initInfo.max_B1coeffs;

   
% allocate space
B1aResponseVector           = zeros(maxA1Coeffs*2, nCadences);
B1aResponseVectorErrors     = zeros(maxA1Coeffs*2, nCadences);
B1aCoeffsAndErrorsByCoeff   = zeros(maxA1Coeffs*2, nModels, 6*maxB1aCoeffs+5);
B1aResidualsByCoeff         = zeros(maxA1Coeffs*2, nModels, 2*nCadences);
B1aRobustWeightsByCoeff     = zeros(maxA1Coeffs*2, nModels, nCadences);
regressProb                 = zeros(maxA1Coeffs, nModels);
robustProb                  = zeros(maxA1Coeffs, nModels);
goodnessInfo                = zeros(4,nModels);


% retrieve A1 spatial coefficients for multi cadence fits

A1coeffsAndErrorsByLc       = [dynablackResultsStruct.A1_fit_results.LC.coeffs_xLC.regress, ...
                                dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.regressCI_hi,...
                                dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.regressCI_lo,...
                                dynablackResultsStruct.A1_fit_results.LC.coeffs_xLC.robust, ...
                                dynablackResultsStruct.A1_fit_results.LC.coeff_errs_xLC.robust_stErr];
nA1Coeffs                   = dynablackResultsStruct.A1_fit_results.LC.numCoeffs;
A1coeffColumns              = [1:nA1Coeffs 3*nA1Coeffs+(1:nA1Coeffs)];
A1coeffErrorColumnsRegress  = [nA1Coeffs+(1:nA1Coeffs); 2*nA1Coeffs+(1:nA1Coeffs)];
A1coeffErrorColumnsRobust   = 4*nA1Coeffs+(1:nA1Coeffs);

for iCoeff = 1:nA1Coeffs*2

    columnNum = A1coeffColumns(iCoeff);            
    B1aResponseVector(iCoeff,idx0:idxEnd) = A1coeffsAndErrorsByLc(:,columnNum);

    if iCoeff <= round(nA1Coeffs)
       errorColumnNumRegress1 = A1coeffErrorColumnsRegress(1,iCoeff);
       errorColumnNumRegress2 = A1coeffErrorColumnsRegress(2,iCoeff);
       B1aResponseVectorErrors(iCoeff,idx0:idxEnd) = ...
            (A1coeffsAndErrorsByLc(:,errorColumnNumRegress1) - A1coeffsAndErrorsByLc(:,errorColumnNumRegress2))/2.;
    else
       errorColumnNumRobust = A1coeffErrorColumnsRobust(iCoeff-round(nA1Coeffs));
       B1aResponseVectorErrors(iCoeff,idx0:idxEnd) = A1coeffsAndErrorsByLc(:,errorColumnNumRobust);
    end
    
end



% turn off warmings for robustfit
warning('off','stats:statrobustfit:IterationLimit');   
    
% -> LOOP - FOR EACH A1 SPATIAL COEFFICIENT
for iCoeff = 1:nA1Coeffs*2

    % get data for one coefficient        
    thisParam     = B1aResponseVector(iCoeff,:)';            
    thisParamError = B1aResponseVectorErrors(iCoeff,:)';
    
    % --> LOOP - FOR EACH OF A SERIES OF MODELS
    for iModel = 1:nModels

        % ---> PERFORM LINEAR FITS FOR 1 MODEL
        % performs a linear fit to obtain thermo-temporal parameters for a single A1 spatial coefficient
        [regressionCoeffs,...
            regressionCoeffCI,...
            regressionResiduals] = regress( thisParam, coefficientModels{iModel}, 0.32 );

        [robustCoeffs, robustStats] = robustfit( coefficientModels{iModel}, thisParam, 'bisquare', 4.685, 'off' );

        % ---> RECORD FIT RESULTS IN OUTPUT ARRAYS
        chi2Regress    = sum((regressionResiduals./thisParamError).^2);
        dofRegress     = nCadences-size(coefficientModels{iModel},2)-1;
        chi2Robust     = sum((robustStats.resid./thisParamError).^2);
        dofRobust      = sum(robustStats.w)-size(coefficientModels{iModel},2)-1;

        goodnessInfo(:,iModel) = [chi2Regress; dofRegress; chi2Robust; dofRobust];

        fitResults = [regressionCoeffs; ... 
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
        B1aCoeffsAndErrorsByCoeff(iCoeff,iModel,1:lengthFitResults) = [lengthFitResults fitResults]';
        B1aResidualsByCoeff(iCoeff,iModel,1:2*nCadences) = [regressionResiduals; robustStats.resid];
        B1aRobustWeightsByCoeff(iCoeff,iModel,1:nCadences) = robustStats.w;

        % --> END OF MODEL LOOP
    end

    % -> RECORD COEFFICIENT-DEPENDENT INFO IN OUTPUT ARRAYS        
    regressProb(iCoeff,:) = chi2cdf(goodnessInfo(1,:),goodnessInfo(2,:));
    robustProb(iCoeff,:)  = chi2cdf(goodnessInfo(3,:),goodnessInfo(4,:));

    % --> END OF COEFFICIENT LOOP
end

% turn on warmings for robustfit
warning('on','stats:statrobustfit:IterationLimit');
    


% package chi2 results
chi2Probabilities = [regressProb, robustProb];

% save to results struct
dynablackResultsStruct.B1a_fit_results.B1coeffs_and_errors_xCoeff       = B1aCoeffsAndErrorsByCoeff;
dynablackResultsStruct.B1a_fit_results.B1robust_weights_xCoeff          = B1aRobustWeightsByCoeff;
dynablackResultsStruct.B1a_fit_results.ch2probALL.chi2_probabilities    = chi2Probabilities;
dynablackResultsStruct.B1a_fit_residInfo.B1residuals_xCoeff             = B1aResidualsByCoeff;
dynablackResultsStruct.B1aModelDump.initInfo                            = initInfo;
dynablackResultsStruct.B1aModelDump.Inputs                              = inputs;
