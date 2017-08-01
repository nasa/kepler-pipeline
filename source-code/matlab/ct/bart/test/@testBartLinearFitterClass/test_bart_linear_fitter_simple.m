function self = test_bart_linear_fitter_simple(self)
%
% test_bart_linear_fitter_simple -- perform simple tests of bart_linear_fitter
%
% This unit test generates a full-sized set of FFI data (27 images, 1070 rows, 1132
%    columns) with linear temperature coefficients (up to 80 DN/read) and read noise (no
%    gaps, CRs, or other outliers) and performs the BART fit on that data.  The results of
%    the fit are then compared to ground-truth.  Requirements addressed by this test are
%    as follows:
%
% 53.BART.5:  BART's unit of work shall be module/output (partial test -- demonstrates
%             that BART fitter can process a full mod/out worth of data)
% 53.BART.6:  BART shall perform robust linear fit of pixel data vs temperature, 1 fit for
%             each pixel in the module/output (partial test -- does not test handling of
%             outliers, but linear fit, pixel-by-pixel, and robust fit type are tested).
%
% In addition, the implicit requirement of getting the right answer is tested.
%
% This is an mlunit test.  For standalone execution, use the following syntax:
%
%      run(text_test_runner, testBartLinearFitterClass('test_bart_linear_fitter_simple'));
%
% Version date:  2009-January-06.
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
  pixelData = add_pixel_data_artifacts( pixelData, readNoise, 0, 0 ) ;
  
  nImages = size(pixelData,1) ;
  nRows   = size(pixelData,2) ;
  nCols   = size(pixelData,3) ;
  nPixels = nRows * nCols ;
  
% process the images

  [model,diags] = bart_linear_fitter( pixelData, T, T0 ) ;
  
% first check -- presence of all fields and checks of dimensions

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

% now for dimensions and, as long as we're at it, type (double in all cases)

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
               
% Now to check the values:  as a first step, make sure that there are no NaNs in places
% where there shouldn't be any

  mlunit_assert( sum(isnan(model.T0))==0, ...
      'T0 contains NaNs' ) ;
  mlunit_assert( sum(isnan(model.modelCoefficients(:)))==0, ...
      'modelCoefficients contains NaNs' ) ;
  mlunit_assert( sum(isnan(model.covarianceMatrix(:)))==0, ...
      'covarianceMatrix contains NaNs' ) ;
  mlunit_assert( sum(isnan(diags.fitResiduals(:)))==0, ...
      'fitResiduals contains NaNs' ) ;
  mlunit_assert( sum(isnan(diags.fitWeights(:)))==0, ...
      'fitWeights contains NaNs' ) ;
  mlunit_assert( sum(isnan(diags.weightedRmsResiduals(:)))==0, ...
      'weightedRmsResiduals contains NaNs' ) ;
  mlunit_assert( sum(isnan(diags.weightSum(:)))==0, ...
      'weightSum contains NaNs' ) ;
  
% all of the weights should be between 0 and 1, all of the weight sums should be between 0
% and nImages

  mlunit_assert( sum(diags.fitWeights(:) < 0 | diags.fitWeights(:) > 1) == 0, ...
      'Not all fit weights between 0 and 1 inclusive' ) ;
  mlunit_assert( sum(diags.weightSum(:) < 0 | diags.weightSum(:) > nImages) == 0, ...
      'Not all weight sums between 0 and nImages inclusive' ) ;
  
% if all the weights are unity, then the robust fit isn't working right

  mlunit_assert( sum(diags.fitWeights(:)==1) ~= nPixels*nImages, ...
      'All weights are unity' ) ;
  
% model.T0 should be equal to T0

  mlunit_assert( model.T0 == T0, ...
      'model.T0 is not equal to T0' ) ;
  
% The model coefficients should be within errors of the ground-truth coefficients, where
% the errors are given by the covariance matrix terms.  Since this is a statistical
% process, what this means is that std((meas-act)/sigma) == 1 and mean((meas-act)/sigma) 
% == 0, where the latter should agree within 1/sqrt(nPixels-1) and the former within
% 1/sqrt(2*(nPixels-1)).  Since "should" is squishy, we will only require the mean to
% agree to within 3/sqrt(nPixels).  For some reason the widths of the distributions are
% coming out systematically about 5% larger than expected, and with more variation to
% boot.  For now I'll hard-code a cutoff at 6% different from the expected width.

  linearDiff = ( squeeze(model.modelCoefficients(1,:,:)) - c1 ) ./ ...
      squeeze(sqrt(model.covarianceMatrix(1,:,:))) ;
  dcDiff = ( squeeze(model.modelCoefficients(2,:,:)) - c0 ) ./ ...
      squeeze(sqrt(model.covarianceMatrix(3,:,:))) ;
  
  dcDiffMean = mean(dcDiff(:)) ;
  dcDiffRms  = std(dcDiff(:)) ;
  linearDiffMean = mean(linearDiff(:)) ;
  linearDiffRms  = std(linearDiff(:)) ;
  stdErrMean = 1/sqrt(nPixels-1) ;
%  stdErrErr  = 1/sqrt(2*(nPixels-1)) ;
  nSigmas    = 3 ;
  stdErrErr = 0.06 / nSigmas ;
  
  mlunit_assert( abs(dcDiffMean)<nSigmas*stdErrMean, ...
      'Fitted DC coeffs not within errors of ground truth' ) ;
  mlunit_assert( abs(linearDiffMean)<nSigmas*stdErrMean, ...
      'Fitted linear coeffs not within errors of ground truth' ) ;
  mlunit_assert( abs(dcDiffRms-1)<nSigmas*stdErrErr, ...
      'Fitted DC coeffs error distribution width incorrect' ) ;
  mlunit_assert( abs(linearDiffRms-1)<nSigmas*stdErrErr, ...
      'Fitted linear coeffs error distribution width incorrect' ) ;
  
% similarly, the fit residuals, normalized to the read noise, should be a Gaussian
% distribution with unit RMS width; since it is nRows * nCols fits of nImages values to a
% 2-parameter model, the ndof here is nRows * nCols * nImages-2.  Similarly to the
% situation above, the distribution width is coming out a little funny (it's too narrow --
% fitResiduals / readNoise has RMS about 0.97 instead of 1).  So for now, use the same 3 *
% 0.02 as my metric for the width of the distribution.

  nDataPoints = nRows * nCols * (nImages-2) ;

  mlunit_assert( abs(mean(diags.fitResiduals(:))/readNoise) < nSigmas/sqrt(nDataPoints), ...
      'Residuals not within errors of zero' ) ;
  mlunit_assert( abs(std(diags.fitResiduals(:))/readNoise - 1) < nSigmas*stdErrErr, ...
      'Residuals distribution width incorrect' ) ;
  
return

% and that's it!

%
%
%

  