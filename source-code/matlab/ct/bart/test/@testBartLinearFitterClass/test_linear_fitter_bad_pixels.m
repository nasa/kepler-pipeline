function self = test_linear_fitter_bad_pixels(self)
% 
% test_linear_fitter_bad_pixels -- test the response of bart_linear_fitter to bad pixels
%
% This unit test exercises bart_linear_fitter's handling of pixels which have 0, 1, or 2
% valid data values (the remainder being missing due to gaps).  Pixels which have 0 or 1
% values obviously cannot be fitted, while those with 2 points can be fitted but have zero
% covariance.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testBartLinearFitterClass('test_linear_fitter_bad_pixels'));
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
  
% block out row of pixels of each bad type -- 0, 1, or 2 good values

  zeroValuesColumn = 1 ;
  oneValueColumn = 2 ;
  twoValuesColumn = 3 ;
  allOtherColumns = 4:nCols ;
  
  pixelData(1:27,:,zeroValuesColumn) = -1 ;
  pixelData(2:27,:,oneValueColumn) = -1 ;
  pixelData(3:27,:,twoValuesColumn) = -1 ;  
  
% perform the fit

  [model,diags] = bart_linear_fitter( pixelData, T, T0 ) ;

% First check:  the model coefficients for 0 and 1 good value per pixel should be NaN; all
% other model coefficients should be good values

  mlunit_assert( isequal( find(isnan(model.modelCoefficients(1,:,zeroValuesColumn))), ...
      [1:nRows] ), ...
      'Linear fit coeffs for pixels with no good values not correctly NaN''ed' ) ;
  mlunit_assert( isequal( find(isnan(model.modelCoefficients(2,:,zeroValuesColumn))), ...
      [1:nRows] ), ...
      'DC fit coeffs for pixels with no good values not correctly NaN''ed' ) ;
  
  mlunit_assert( isequal( find(isnan(model.modelCoefficients(1,:,oneValueColumn))), ...
      [1:nRows] ), ...
      'Linear fit coeffs for pixels with one good value not correctly NaN''ed' ) ;
  mlunit_assert( isequal( find(isnan(model.modelCoefficients(2,:,oneValueColumn))), ...
      [1:nRows] ), ...
      'DC fit coeffs for pixels with one good value not correctly NaN''ed' ) ;
  
  mlunit_assert( isempty( find(isnan(model.modelCoefficients(1,:,twoValuesColumn)), 1) ), ...
      'Linear fit coeffs for pixels with two good values not contains NaNs' ) ;
  mlunit_assert( isempty( find(isnan(model.modelCoefficients(2,:,twoValuesColumn)), 1) ), ...
      'DC fit coeffs for pixels with two good values not contains NaNs' ) ;
  
  mlunit_assert( isempty( find(isnan(model.modelCoefficients(1,:,allOtherColumns)), 1) ), ...
      'Linear fit coeffs for pixels with >2 good values not contains NaNs' ) ;
  mlunit_assert( isempty( find(isnan(model.modelCoefficients(2,:,allOtherColumns)), 1) ), ...
      'DC fit coeffs for pixels with >2 good values not contains NaNs' ) ;
  
% second check -- the covariances for 0 and 1 good value per pixel should be NaN; for 2
% good values per pixel should be 0; all others should have at least positive, non-NaN
% diagonal covariance terms, and non-NaN cross-terms

  mlunit_assert( isequal( find(isnan(model.covarianceMatrix(1,:,zeroValuesColumn))), ...
      [1:nRows] ), ...
      'Linear uncertainty for pixels with no good values not correctly NaN''ed' ) ;
  mlunit_assert( isequal( find(isnan(model.covarianceMatrix(2,:,zeroValuesColumn))), ...
      [1:nRows] ), ...
      'Cross-term uncertainty for pixels with no good values not correctly NaN''ed' ) ;
  mlunit_assert( isequal( find(isnan(model.covarianceMatrix(3,:,zeroValuesColumn))), ...
      [1:nRows] ), ...
      'DC uncertainty for pixels with no good values not correctly NaN''ed' ) ;
  
  mlunit_assert( isequal( find(isnan(model.covarianceMatrix(1,:,oneValueColumn))), ...
      [1:nRows] ), ...
      'Linear uncertainty for pixels with 1 good value not correctly NaN''ed' ) ;
  mlunit_assert( isequal( find(isnan(model.covarianceMatrix(2,:,oneValueColumn))), ...
      [1:nRows] ), ...
      'Cross-term uncertainty for pixels with 1 good value not correctly NaN''ed' ) ;
  mlunit_assert( isequal( find(isnan(model.covarianceMatrix(3,:,oneValueColumn))), ...
      [1:nRows] ), ...
      'DC uncertainty for pixels with no 1 good value not correctly NaN''ed' ) ;

  mlunit_assert( isequal( find(model.covarianceMatrix(1,:,twoValuesColumn)==0), ...
      [1:nRows] ), ...
      'Linear uncertainty for pixels with 2 good values non-zero' ) ;
  mlunit_assert( isequal( find(model.covarianceMatrix(2,:,twoValuesColumn)==0), ...
      [1:nRows] ), ...
      'Cross-term uncertainty for pixels with 2 good values non-zero' ) ;
  mlunit_assert( isequal( find(model.covarianceMatrix(3,:,twoValuesColumn)==0), ...
      [1:nRows] ), ...
      'DC uncertainty for pixels with 2 good values non-zero' ) ;

  mlunit_assert( isempty( find(model.covarianceMatrix(1,:,allOtherColumns)<=0, 1) ), ...
      'Linear uncertainty for pixels with >2 good values not positive-definite' ) ;
  mlunit_assert( isempty( find(model.covarianceMatrix(3,:,allOtherColumns)<=0, 1) ), ...
      'DC uncertainty for pixels with >2 good values not positive-definite' ) ;
  mlunit_assert( isempty( find(isnan(model.covarianceMatrix(3,:,allOtherColumns)), 1) ), ...
      'Cross-term uncertainty for pixels with >2 good values contains NaNs' ) ;
  
% Third check:  the residuals for pixels with 0 and 1 good value should all be NaN; the
% residuals with multiple values should not be NaN; in the case of the fits with 2 good
% pixels the good pixels should have residuals approx equal to 0, and the bad ones should
% be NaN.

  mlunit_assert( isequal( length(find(isnan(diags.fitResiduals(:,:,zeroValuesColumn)))), ...
      nImages*nRows ), ...
      'Fit residuals for pixels with zero values not all NaN' ) ;
  mlunit_assert( isequal( length(find(isnan(diags.fitResiduals(:,:,oneValueColumn)))), ...
      nImages*nRows ), ...
      'Fit residuals for pixels with one value not all NaN' ) ;
  D = sqrt(eps) ;
  mlunit_assert( isequal( length(find(abs(diags.fitResiduals(1:2,:,twoValuesColumn))<D)), ...
      2*nRows ), ...
      'Fit residuals for pixels with two values not all miniscule on good values' ) ;
  mlunit_assert( isequal( length(find(isnan(diags.fitResiduals(3:nImages,:,twoValuesColumn)))), ...
      (nImages-2)*nRows ), ...
      'Fit residuals for pixels with two values not all NaN on bad values' ) ;
  mlunit_assert( isequal( length(find(isnan(diags.fitResiduals(:,:,allOtherColumns)))), ...
      0 ), ...
      'Fit residuals for pixels with >2 values contains NaNs' ) ;

% fourth check:  weighted RMS fit residuals should follow the same pattern of NaNs as the
% fit residuals themselves

  mlunit_assert( isequal( length(find(isnan(diags.weightedRmsResiduals(:,zeroValuesColumn)))), ...
      nRows ), ...
      'RMS residuals for pixels with zero values not all NaN' ) ;
  mlunit_assert( isequal( length(find(isnan(diags.weightedRmsResiduals(:,oneValueColumn)))), ...
      nRows ), ...
      'RMS residuals for pixels with one value not all NaN' ) ;
  mlunit_assert( isequal( length(find(abs(diags.weightedRmsResiduals(:,twoValuesColumn))<D)), ...
      nRows ), ...
      'RMS residuals for pixels with two values not all miniscule' ) ;
  mlunit_assert( isequal( length(find(isnan(diags.weightedRmsResiduals(:,allOtherColumns)))), ...
      0 ), ...
      'RMS residuals for pixels with >2 values contains NaNs' ) ;
  
% fifth check:  weights of all values on pixels with 0 or 1 good value should be 0;
% weights of good values on pixels with 2 good values should be 1, weights on bad values
% should be 0.  For some reason, the fitter does deweight the points on a 2-point fit, and
% the deweighting is not at the level of 1e-8 -- it can get into the 1e-4 level.  Thus
% I've hard-coded an appropriate cutoff for the calculation

  maxWeightDeviation = 1e-3 ;

  mlunit_assert( isequal( length(find(diags.fitWeights(:,:,zeroValuesColumn)==0)), ...
      nImages*nRows ), ...
      'Fit weights for pixels with zero values not all 0' ) ;
  mlunit_assert( isequal( length(find(diags.fitWeights(:,:,oneValueColumn)==0)), ...
      nImages*nRows ), ...
      'Fit weights for pixels with one value not all 0' ) ;
  mlunit_assert( isequal( length(find(diags.fitWeights(3:nImages,:,twoValuesColumn)==0)), ...
      (nImages-2)*nRows ), ...
      'Fit weights for pixels with two values not all 0 on bad values' ) ;
  mlunit_assert( isequal( length(find( ...
      abs(diags.fitWeights(1:2,:,twoValuesColumn)-1)<maxWeightDeviation ...
                                      )), ...
      2*nRows ), ...
      'Fit weights for pixels with two values not all 1 on good values' ) ;

% no test on the other columns because they can actually be set to zero by the fitter;
% similarly no test on weightSum, since it seems unlikely that we can break the fitter so
% badly that it is unable to correctly sum the weights in a pixel!  

return

% and that's it!

%
%
%