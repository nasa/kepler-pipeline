function self = test_linear_fitter_bad_temps(self)
%
% test_linear_fitter_bad_temps -- test bart_linear_fitter handling of bad temperature
% values
%
% This is a unit test which verifies that bart_linear_fitter does the right thing when one
% of its temperatures is bad (as indicated by a NaN).  It is intended to be executed in
% the mlunit context.  For standalone execution use the following syntax:
%
%      run(text_test_runner, testBartLinearFitterClass('test_linear_fitter_bad_temps'));
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
  pixelData = add_pixel_data_artifacts( pixelData, readNoise, 0, 0 ) ;
  
  nImages = size(pixelData,1) ;
  nRows   = size(pixelData,2) ;
  nCols   = size(pixelData,3) ;
  nPixels = nRows * nCols ;

% set one of the temperatures to NaN

  badTemp = random_integer(1,1,1,nImages) ;
  T(badTemp) = NaN ;
  
% do the fit

  [model,diags] = bart_linear_fitter( pixelData, T, T0 ) ;

% First test:  all the dimensions should be correct

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
               
% second check:  the model values should all be good (no NaNs)

  mlunit_assert( sum(isnan(model.T0))==0, ...
      'T0 contains NaNs' ) ;
  mlunit_assert( sum(isnan(model.modelCoefficients(:)))==0, ...
      'modelCoefficients contains NaNs' ) ;
  mlunit_assert( sum(isnan(model.covarianceMatrix(:)))==0, ...
      'covarianceMatrix contains NaNs' ) ;

% third check:  in the diagnostics, all of the residuals for the bad temp should be NaN,
% and none of the other residuals should be NaN

  badResiduals = diags.fitResiduals(badTemp,:,:) ;
  mlunit_assert( sum(isnan(badResiduals(:))) == nPixels, ...
      'Residuals on image with bad temperature not all NaN' ) ;
  residuals = diags.fitResiduals ;
  residuals(badTemp,:,:) = [] ;
  mlunit_assert( sum(isnan(residuals(:))) == 0, ...
      'Residuals on image with good temperatures include NaNs' ) ;
  
% fourth check:  in the diagnostics, the weights for the bad temp should all be 0

  badWeights = diags.fitWeights(badTemp,:,:) ;
  mlunit_assert( sum(badWeights(:)==0) == nPixels, ...
      'Weights on image with bad temperature not all zero' ) ;
  
% fifth check:  none of the weighted RMS residuals should be NaN -- they should not
% include the excluded image residuals

  mlunit_assert( sum(isnan(diags.weightedRmsResiduals(:))) == 0, ...
      'Weighted RMS Residuals includes NaNs' ) ;
  
return 

% and that's it!

%
%
%

  