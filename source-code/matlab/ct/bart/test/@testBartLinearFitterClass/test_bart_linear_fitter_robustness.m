function self = test_bart_linear_fitter_robustness(self)
%
% test_bart_linear_fitter_robustness -- unit test for robust fitting in BART.
%
% This test checks that the BART fitter is robust against gaps in the data at the packet
% level (up to 10% missing data) and against cosmic rays.  In this case, "robust against"
% is interpreted to mean, "Gets the right answer in spite of."  It also implies that the
% correct values in the diagnostic struct are set to zero or NaN.  
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testBartLinearFitterClass('test_bart_linear_fitter_robustness'));
%
% Version date:  2009-January-07.
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

% Modification History:
%
%=========================================================================================

% get the standard parameters and paths set up

  bart_linear_fitter_test_parameters ;
  
% generate test data

  [pixelData,c1,c0] = make_fake_bart_pixel_data( meanBlack, blackRms, maxTempCoeff, dT ) ;
  
% Add 10% gaps, cosmic rays, and read noise to the images

  pixelData = add_pixel_data_artifacts( pixelData, readNoise, 0.1, 1 ) ;
  nImages = size(pixelData,1) ;
  nRows   = size(pixelData,2) ;
  nCols   = size(pixelData,3) ;
  nPixels = nRows * nCols ;

% perform the fit

  [model,diags] = bart_linear_fitter( pixelData, T, T0 ) ;

% start by checking that the dimensions and types of all fields are correct

  mlunit_assert( isfield(model,'T0'), ...
      'T0 field absent from BART model' ) ;
  mlunit_assert( isfield(model,'modelCoefficients'), ...
      'coefficients field absent from BART model' ) ;
  mlunit_assert( isfield(model,'covarianceMatrix'), ...
      'covariance field absent from BART model' ) ;
  mlunit_assert( isfield(diags,'fitResiduals'), ...
      'residuals field absent from BART diagnostics' ) ;
  mlunit_assert( isfield(diags,'fitWeights'), ...
      'weights field absent from BART diagnostics' ) ;
  mlunit_assert( isfield(diags,'weightedRmsResiduals'), ...
      'RMS residuals field absent from BART diagnostics' ) ;
  mlunit_assert( isfield(diags,'weightSum'), ...
      'Weight sum field absent from BART diagnostics' ) ;

  mlunit_assert( ( isa(model.T0,'double') && isequal(size(model.T0),[1 1]) ), ...
      'T0 is not a scalar double' ) ;
  mlunit_assert( ( isa(model.modelCoefficients,'double') && ...
                   isequal(size(model.modelCoefficients),[2 nRows nCols]) ), ...
                   'modelCoefficients is not 2 x nRows x nCols double' ) ;
  mlunit_assert( ( isa(model.covarianceMatrix,'double') && ...
                   isequal(size(model.covarianceMatrix),[3 nRows nCols]) ), ...
                   'modelCovariance not 3 x nRows x nCols double' ) ;
  mlunit_assert( ( isa(diags.fitResiduals,'double') && ...
                   isequal(size(diags.fitResiduals),[nImages nRows nCols]) ), ...
                   'fitResiduals is not nImages x nRows x nCols double' ) ;
  mlunit_assert( ( isa(diags.fitWeights,'double') && ...
                   isequal(size(diags.fitWeights),[nImages nRows nCols]) ), ...
                   'fitWeights is not nImages x nRows x nCols double' ) ;
  mlunit_assert( ( isa(diags.weightedRmsResiduals,'double') && ...
                   isequal(size(diags.weightedRmsResiduals),[nRows nCols]) ), ...
                   'weightedRmsResiduals is not nRows x nCols double' ) ;
  mlunit_assert( ( isa(diags.weightSum,'double') && ...
                   isequal(size(diags.weightSum),[nRows nCols]) ), ...
                   'weightSum is not nRows x nCols double' ) ;

% second check:  the model values should all be good (no NaNs)

  mlunit_assert( sum(isnan(model.T0))==0, ...
      'T0 contains NaNs' ) ;
  mlunit_assert( sum(isnan(model.modelCoefficients(:)))==0, ...
      'modelCoefficients contains NaNs' ) ;
  mlunit_assert( sum(isnan(model.covarianceMatrix(:)))==0, ...
      'covarianceMatrix contains NaNs' ) ;

% third check:  the gapped data should all have NaN for their residuals and zero for their
% fit weights, and no other point should have NaN for their residuals

  gappedData = find( pixelData(:)<0 ) ;
  mlunit_assert( isequal( find(isnan(diags.fitResiduals(:))), gappedData ), ...
      'Gapped data residuals not all NaN' ) ;
  mlunit_assert( sum(ismember(gappedData,find(diags.fitWeights(:)==0)))==length(gappedData) , ...
      'Gapped data weights are not all zero' ) ;
  
% fourth check:  weighted RMS residuals and sum of weights should have neither NaNs nor
% zeros in them

  mlunit_assert( sum(isnan(diags.weightedRmsResiduals(:))) == 0, ...
      'Weighted RMS residuals contains NaNs' ) ;
  mlunit_assert( sum(diags.weightedRmsResiduals(:)==0) == 0, ...
      'Weighted RMS residuals contains zeros' ) ;
  mlunit_assert( sum(isnan(diags.weightSum(:))) == 0, ...
      'Weight sum contains NaNs' ) ;
  mlunit_assert( sum(diags.weightSum(:)==0) == 0, ...
      'Weight sum contains zeros' ) ;
  
% fifth check:  the fit should get the right answer to within errors.  How close do they
% have to be?  Very tough to answer that question for a robust fit, so I'll arbitrarily
% say that the means have to be within 0.003 sigma of 0 and the RMS's within 0.065 of 1.

  linearDiff = ( squeeze(model.modelCoefficients(1,:,:)) - c1 ) ./ ...
      squeeze(sqrt(model.covarianceMatrix(1,:,:))) ;
  dcDiff = ( squeeze(model.modelCoefficients(2,:,:)) - c0 ) ./ ...
      squeeze(sqrt(model.covarianceMatrix(3,:,:))) ;
  
  dcDiffMean = mean(dcDiff(:)) ;
  dcDiffRms  = std(dcDiff(:)) ;
  linearDiffMean = mean(linearDiff(:)) ;
  linearDiffRms  = std(linearDiff(:)) ;
  meanDiffTol = 0.003 ;
  rmsDiffTol = 0.065 ;

  mlunit_assert( abs(dcDiffMean)<meanDiffTol, ...
      'Fitted DC coeffs not within errors of ground truth' ) ;
  mlunit_assert( abs(linearDiffMean)<meanDiffTol, ...
      'Fitted linear coeffs not within errors of ground truth' ) ;
  disp(['RMS width of DC coeffs distribution:  ',num2str(dcDiffRms)]) ;
  mlunit_assert( abs(dcDiffRms-1)<rmsDiffTol, ...
      'Fitted DC coeffs error distribution width incorrect' ) ;
  disp(['RMS width of linear coeffs distribution:  ',num2str(linearDiffRms)]) ;
  mlunit_assert( abs(linearDiffRms-1)<rmsDiffTol, ...
      'Fitted linear coeffs error distribution width incorrect' ) ;

  
return

% and that's it!

%
%
%

  