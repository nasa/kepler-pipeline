function test_private_methods_with_geometric_model( dvDataObject, testName )
%
% test_private_methods_with_geometric_model -- perform exercises of dvDataClass private methods in support of unit testing
%
% testResultStruct = test_private_methods_geometric_model ( dvDataObject ) exercises the privte methods of the dvDataClass and sends information on the test results
% back to the caller. This is necessary because Mathworks' idea of a private method is one which can only be called by a public method sitting in the directory over
% the /private directory (ie, it is tied to directories and not classes), so there has to be a public dvDataClass method to do the tests.  
%
% The methods tested are:
%
%    compute_odd_even_transit_model
%    remove_transit_signature_from_flux_time_series
%    roll_back_results_struct_from_failed_fit
%    check_planet_model_parameter_validity
%
%    Argument testName indicates which of the methods is to be exercised.
%
% Version date:  2011-December-20.
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
%    2011_December-20, JL:
%        update in support of DV 8.1.
%    2011-May-05, JL:
%        update in support of DV 7.0.
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%    2010-May-03, PT:
%        update to correspond to current organization and functionality of the
%        compute_odd_even_transit_model method.  Remove test for gapping odd or even
%        transits, since we don't do that kind of thing any more.  Don't test the
%        subtractions on odd or even transits only, since we don't do that any more
%        either.  Minor change to transit signature removal tests (loosen required
%        agreement between 2 MAD values from 0.01 / 10 to 0.02 / 10).  
%    2009-December-18, PT:
%        add check_planet_model_parameter_validity test code.
%
%=========================================================================================

% the top-level functionality is just a switchyard

  switch testName
      
      case 'compute_odd_even_geometric_transit_model'
          test_compute_odd_even_geometric_transit_model;
      case 'remove_transit_signature_from_flux_geometric_model'
          test_remove_transit_signature_from_flux_geometric_model;
      case 'roll_back_results_struct_from_failed_fit_geometric_model'
          test_roll_back_results_struct_from_failed_fit_geometric_model;
      case 'check_planet_model_parameter_validity_geometric_model'
          test_check_planet_model_parameter_validity_geometric_model;
          
          
  end
  
return

% and that's it!
%
%  
%

%=========================================================================================

% subfunction which performs the tests on compute_odd_even_transit_model

function test_compute_odd_even_geometric_transit_model

% initialize the workspace

  testDvDataGeometricClass_fitter_initialization;
    
% get a transit model for the first target using the dvDataClass method

  targetFluxTimeSeries = dvResultsStructBeforeFit.targetResultsStruct.residualFluxTimeSeries;
  allTransitsModel = convert_tps_parameters_to_transit_model(dvDataObject, 1, dvDataStruct.targetStruct.thresholdCrossingEvent, targetFluxTimeSeries);
  
% use the method to construct an odd-even-transits model

  planetResultsStruct = dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct;
  oddTransitsModel    = compute_odd_even_transit_model( allTransitsModel, planetResultsStruct );
  
% All of the planetModel fields should agree with the all-transits fit results model values

  planetModelValues = struct2array( oddTransitsModel.planetModel );
  fitValues = [planetResultsStruct.allTransitsFit.modelParameters.value];
  fitValues = fitValues([1 2 3 6 7 11 12 13]);
  assert_equals( planetModelValues, fitValues, 'odd-transits model has wrong planet model values' );
  
% all of the other fields should match between the all-transits planet model and the odd-even transits planet model

  assert_equals( orderfields( rmfield( allTransitsModel, 'planetModel' ) ), orderfields( rmfield( oddTransitsModel, 'planetModel' ) ), ...
      'all-transits and odd-transits models do not agree' );
    
  disp(' ');
  
return


%=========================================================================================
  
% subfunction which tests the transit subtraction private method

function test_remove_transit_signature_from_flux_geometric_model

% initialize the workspace

  testDvDataGeometricClass_fitter_initialization;
    
% construct an odd-transits model

  targetFluxTimeSeries = dvResultsStructBeforeFit.targetResultsStruct.residualFluxTimeSeries;
  allTransitsModel     = convert_tps_parameters_to_transit_model(dvDataObject, 1, dvDataStruct.targetStruct.thresholdCrossingEvent, targetFluxTimeSeries);
  planetResultsStruct  = dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct;
  oddTransitsModel     = compute_odd_even_transit_model( allTransitsModel, planetResultsStruct );
  
  transitObject        = transitGeneratorClass( oddTransitsModel );
    
% Start with suppression method 0, which is straight subtraction.  

  originalGapIndicators     = targetFluxTimeSeries.gapIndicators;
  originalValues            = targetFluxTimeSeries.values( ~originalGapIndicators );
  originalRangeOverMad      = range(originalValues) / mad(originalValues, 1);
  
% perform the subtraction for all transits

  subtractedFluxTimeSeries00 = remove_transit_signature_from_flux_time_series( targetFluxTimeSeries, transitObject, 0, 0 );
  subtractedGapIndicators00  = subtractedFluxTimeSeries00.gapIndicators;
  subtractedValues00         = subtractedFluxTimeSeries00.values( ~subtractedGapIndicators00 );
  subtractedRangeOverMad00   = range(subtractedValues00) / mad(subtractedValues00, 1);
  
% the gap indicators should be the same, and the range/MAD should be reduced

  assert_equals( originalGapIndicators, subtractedGapIndicators00, 'Subtracted gap indicators not correct for mode 0' );
  mlunit_assert( originalRangeOverMad > 100 && subtractedRangeOverMad00 < 20, 'Range/MAD reduction not correct for mode 0' );

% Now we basically do the same thing with subtraction mode 1, which also gaps the transit cadences.  Start with all-transits

  subtractedFluxTimeSeries10 = remove_transit_signature_from_flux_time_series( targetFluxTimeSeries, transitObject, 1, 0 );
  subtractedGapIndicators10  = subtractedFluxTimeSeries10.gapIndicators;
  subtractedValues10         = subtractedFluxTimeSeries10.values( ~subtractedGapIndicators10 );
  subtractedRangeOverMad10   = range(subtractedValues10) / mad(subtractedValues10,1);
  
% the gap indicators should match the transit cadences

  mjdMidTimeBaryCorrect      = dvDataStruct.barycentricCadenceTimes.midTimestamps;
  transitNumber              = identify_transit_cadences( transitObject, mjdMidTimeBaryCorrect, 0 );
  isATransitCadence          = logical( transitNumber );
  assert_equals( subtractedGapIndicators10, isATransitCadence, 'Not all cadences are correctly gapped' );
  mlunit_assert( subtractedRangeOverMad10 < 20, 'Range/MAD reduction not correct for mode 1' );
  mlunit_assert( length( find(subtractedGapIndicators10) ) > length( find(originalGapIndicators) ) , 'Number of gapped cadences is too small' );
  
% Finally, use mode 1 but with an additional buffer region around each transit.  
% This should have small range/MAD but with more gapped cadences than the version with no buffer

  subtractedFluxTimeSeries11 = remove_transit_signature_from_flux_time_series( targetFluxTimeSeries, transitObject, 1, 1 );
  subtractedGapIndicators11  = subtractedFluxTimeSeries11.gapIndicators;
  subtractedValues11         = subtractedFluxTimeSeries11.values( ~subtractedGapIndicators11 );
  subtractedRangeOverMad11   = range(subtractedValues11) / mad(subtractedValues11, 1);
  
% the gap indicators should match the transit cadences, and there should be more of them than when no buffer is used

  transitNumber              = identify_transit_cadences( transitObject, mjdMidTimeBaryCorrect, 1 );
  isATransitCadence          = logical( transitNumber );
  assert_equals( subtractedGapIndicators11, isATransitCadence, 'Not all cadences are correctly gapped with buffer' ) ;
  mlunit_assert( subtractedRangeOverMad11 < 20, 'Range/MAD reduction not correct for mode 1 with buffer' );
  mlunit_assert( length( find(subtractedGapIndicators11) ) > length( find(subtractedGapIndicators10) ), 'Number of gapped cadences is too small with buffer' );
  
% check the range -- it should be smaller than for the subtracted-only case, since we have also gapped the transit cadences

  mlunit_assert( subtractedRangeOverMad11 < subtractedRangeOverMad00, 'Range/MAD too large for mode 1, oddEvenFlag 0 with buffer' );

% test that errors are thrown if the inputs are not valid
  
  lasterror('reset');
  try
      z = remove_transit_signature_from_flux_time_series( targetFluxTimeSeries, transitObject, -1, 0 );
      assert_equals( 1, 0, 'No error thrown when removalType -> -1' );
  catch
      lastError = lasterror;
      assert_equals( lastError.identifier, 'dv:removeTransitSignatureFromFluxTimeSeries:removalTypeInvalid',         'Wrong type of error thrown' ) ;
  end
  
  try
      z = remove_transit_signature_from_flux_time_series( targetFluxTimeSeries, transitObject, 1, -1 ) ;
      assert_equals( 1, 0, 'No error thrown when transitBufferFactor -> -1' ) ;
  catch
      lastError = lasterror;
      assert_equals( lastError.identifier, 'dv:removeTransitSignatureFromFluxTimeSeries:transitBufferFactorInvalid', 'Wrong type of error thrown' ) ;
  end

  disp(' ');
  
return


%=========================================================================================

% subfunction which performs the work required to test the roll-back procedure

function test_roll_back_results_struct_from_failed_fit_geometric_model

% initialize the workspace

  testDvDataGeometricClass_fitter_initialization;
    
% execute the all-transits roll back and make sure that the all-transits was rolled back but not the odd- or even-transits

  dvResultsStruct = roll_back_results_struct_from_failed_fit( dvResultsStructAfterFit, 1, 1, 0 );
  assert_equals(     dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.oddTransitsFit,  dvResultsStruct.targetResultsStruct.planetResultsStruct.oddTransitsFit, ...
      'All-transits roll back touched odd-transits fit struct' );
  assert_equals(     dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.evenTransitsFit, dvResultsStruct.targetResultsStruct.planetResultsStruct.evenTransitsFit, ...
      'All-transits roll back touched even-transits fit struct' );
  assert_not_equals( dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.allTransitsFit,  dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit, ...
      'All-transits roll back did not touch all-transits fit struct' );
  fitStruct = dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit;
  valuesOk =             fitStruct.modelChiSquare == -1 ;
  valuesOk = valuesOk && all(fitStruct.robustWeights == 0);
  valuesOk = valuesOk && isempty(fitStruct.modelParameters);
  valuesOk = valuesOk && isempty(fitStruct.modelParameterCovariance);
  mlunit_assert( valuesOk, 'All-transits fit rollback produces incorrect values' ) ;
  
% now do the same for odd-transits rollback

  dvResultsStruct = roll_back_results_struct_from_failed_fit( dvResultsStructAfterFit, 1, 1, 1 );
  assert_equals(     dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.evenTransitsFit, dvResultsStruct.targetResultsStruct.planetResultsStruct.evenTransitsFit, ...
      'Odd-transits roll back touched even-transits fit struct' );
  assert_equals(     dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.allTransitsFit,  dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit, ...
      'Odd-transits roll back touched all-transits fit struct' );
  assert_not_equals( dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.oddTransitsFit,  dvResultsStruct.targetResultsStruct.planetResultsStruct.oddTransitsFit, ...
      'Odd-transits roll back did not touch odd-transits fit struct' );
  fitStruct = dvResultsStruct.targetResultsStruct.planetResultsStruct.oddTransitsFit;
  valuesOk =             fitStruct.modelChiSquare == -1;
  valuesOk = valuesOk && all(fitStruct.robustWeights == 0);
  valuesOk = valuesOk && isempty(fitStruct.modelParameters);
  valuesOk = valuesOk && isempty(fitStruct.modelParameterCovariance);
  mlunit_assert( valuesOk, 'Odd-transits fit rollback produces incorrect values' );

% and for even-transits

  dvResultsStruct = roll_back_results_struct_from_failed_fit( dvResultsStructAfterFit, 1, 1, 2 );
  assert_equals(     dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.oddTransitsFit,  dvResultsStruct.targetResultsStruct.planetResultsStruct.oddTransitsFit, ...
      'Even-transits roll back touched odd-transits fit struct' ) ;
  assert_equals(     dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.allTransitsFit,  dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit, ...
      'Even-transits roll back touched all-transits fit struct' ) ;
  assert_not_equals( dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.evenTransitsFit, dvResultsStruct.targetResultsStruct.planetResultsStruct.evenTransitsFit, ...
      'Even-transits roll back did not touch Even-transits fit struct' ) ;
  fitStruct = dvResultsStruct.targetResultsStruct.planetResultsStruct.evenTransitsFit;
  valuesOk =             fitStruct.modelChiSquare == -1;
  valuesOk = valuesOk && all(fitStruct.robustWeights == 0);
  valuesOk = valuesOk && isempty(fitStruct.modelParameters);
  valuesOk = valuesOk && isempty(fitStruct.modelParameterCovariance);
  mlunit_assert( valuesOk, 'Even-transits fit rollback produces incorrect values' );

% check that error is thrown for invalid value of oddEvenFlag

  lasterror('reset');
  try
      z=roll_back_results_struct_from_failed_fit( dvResultsStructAfterFit, 1, 1, 3 );
      assert_equals( 1, 0, 'No error thrown when oddEvenFlag -> 3' );
  catch
      lastError = lasterror;
      assert_equals( lastError.identifier, 'dv:rollBackResultsFromFailedFit:oddEvenFlagInvalid', 'Wrong type of error thrown' );
  end
  
  disp(' ');
  
return

%=========================================================================================

% subfunction to test check_planet_model_parameter_validity private method

function test_check_planet_model_parameter_validity_geometric_model

% initialize the workspace

  testDvDataGeometricClass_fitter_initialization;

% construct a planetResultsStruct with some values

  planetResultsStruct = dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct;
  
% start with a valid model

  unitOfWorkStart = 55000;
  unitOfWorkEnd   = 55100;

  modelParameters(1).name        = 'orbitalPeriodDays';
  modelParameters(1).value       = 10;
  modelParameters(1).uncertainty = 1e-3;
  modelParameters(1).fitted      = true;
  
  modelParameters(2).name        = 'transitEpochBkjd';
  modelParameters(2).value       = 55005;
  modelParameters(2).uncertainty = 1e-3;
  modelParameters(2).fitted      = true;
  
  modelParameters(3).name        = 'transitDurationHours';
  modelParameters(3).value       = 10;
  modelParameters(3).uncertainty = 1e-3;
  modelParameters(3).fitted      = false;

  modelParametersValid = modelParameters;
  
  planetResultsStruct.allTransitsFit.modelParameters  = modelParametersValid;
  planetResultsStruct.oddTransitsFit.modelParameters  = modelParametersValid;
  planetResultsStruct.evenTransitsFit.modelParameters = modelParametersValid;

% this should run without error and return a planetResultsStruct which matches the current one

  planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 0 );
  assert_equals( planetResultsStructOut, planetResultsStruct, 'Planet results struct changed in all-OK, all-transits fit case!' );
  planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 1 );
  assert_equals( planetResultsStructOut, planetResultsStruct, 'Planet results struct changed in all-OK, odd-transits fit case!' );
  planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 2 );
  assert_equals( planetResultsStructOut, planetResultsStruct, 'Planet results struct changed in all-OK, even-transits fit case!' );
  
% put in an invalid period and test to make sure that the correct error is thrown

  modelParametersBadPeriod          = modelParameters;
  modelParametersBadPeriod(1).value = -1;
  
  planetResultsStruct.allTransitsFit.modelParameters  = modelParametersBadPeriod;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 0 );
  planetResultsStruct.allTransitsFit.modelParameters  = modelParametersValid;
  planetResultsStruct.oddTransitsFit.modelParameters  = modelParametersBadPeriod;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 1 );
  planetResultsStruct.oddTransitsFit.modelParameters  = modelParametersValid;
  planetResultsStruct.evenTransitsFit.modelParameters = modelParametersBadPeriod;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 2 );
  planetResultsStruct.evenTransitsFit.modelParameters = modelParametersValid;
  
  modelParametersBadPeriod(1).value = 101;

  planetResultsStruct.allTransitsFit.modelParameters = modelParametersBadPeriod;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 0 );
  planetResultsStruct.allTransitsFit.modelParameters = modelParametersValid;
  planetResultsStruct.oddTransitsFit.modelParameters = modelParametersBadPeriod;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 1 );
  planetResultsStruct.oddTransitsFit.modelParameters = modelParametersValid;
  planetResultsStruct.evenTransitsFit.modelParameters = modelParametersBadPeriod;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 2 );
  planetResultsStruct.evenTransitsFit.modelParameters = modelParametersValid;
  
% put in an invalid duration and make sure that an error is thrown

  modelParametersBadDuration          = modelParametersValid;
  modelParametersBadDuration(3).value = -1;
  
  planetResultsStruct.allTransitsFit.modelParameters = modelParametersBadDuration;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 0 );
  planetResultsStruct.allTransitsFit.modelParameters = modelParametersValid;
  planetResultsStruct.oddTransitsFit.modelParameters = modelParametersBadDuration;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 1 );
  planetResultsStruct.oddTransitsFit.modelParameters = modelParametersValid;
  planetResultsStruct.evenTransitsFit.modelParameters = modelParametersBadDuration;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 2 );
  planetResultsStruct.evenTransitsFit.modelParameters = modelParametersValid;

  modelParametersBadDuration(3).value = 101 * 24;
  planetResultsStruct.allTransitsFit.modelParameters = modelParametersBadDuration;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 0 );
  planetResultsStruct.allTransitsFit.modelParameters = modelParametersValid;
  planetResultsStruct.oddTransitsFit.modelParameters = modelParametersBadDuration;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 1 );
  planetResultsStruct.oddTransitsFit.modelParameters = modelParametersValid;
  planetResultsStruct.evenTransitsFit.modelParameters = modelParametersBadDuration;
  execute_validity_check_with_error( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 2 );
  planetResultsStruct.evenTransitsFit.modelParameters = modelParametersValid;
  
% put in invalid epochs and see that they are properly corrected

%   modelParametersBadEpoch          = modelParameters;
%   modelParametersBadEpoch(2).value = 54997;
%   planetResultsStruct.allTransitsFit.modelParameters = modelParametersBadEpoch;
%   planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 0 );
%   assert_equals( planetResultsStructOut.allTransitsFit.modelParameters(2).value,  55007, 'All-transits epoch 54997 incorrectly adjusted!'  );
%   assert_equals( planetResultsStructOut.oddTransitsFit.modelParameters(2).value,  55005, 'Odd-transits epoch 55005 incorrectly touched!'   );
%   assert_equals( planetResultsStructOut.evenTransitsFit.modelParameters(2).value, 55005, 'Even-transits epoch 55005 incorrectly touched!'  );
% 
%   planetResultsStruct.allTransitsFit.modelParameters = modelParametersValid;
%   planetResultsStruct.oddTransitsFit.modelParameters = modelParametersBadEpoch;
%   planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 1 );
%   assert_equals( planetResultsStructOut.allTransitsFit.modelParameters(2).value,  55005, 'All-transits epoch 55005 incorrectly touched!'   );
%   assert_equals( planetResultsStructOut.oddTransitsFit.modelParameters(2).value,  55007, 'Odd-transits epoch 54997 incorrectly adjusted!'   );
%   assert_equals( planetResultsStructOut.evenTransitsFit.modelParameters(2).value, 55005, 'Even-transits epoch 55005 incorrectly touched!'  );
%   planetResultsStruct.oddTransitsFit.modelParameters = modelParametersValid;
%   planetResultsStruct.evenTransitsFit.modelParameters = modelParametersBadEpoch;
%   planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 2 );
%   assert_equals( planetResultsStructOut.allTransitsFit.modelParameters(2).value,  55005, 'All-transits epoch 55005 incorrectly touched!'   );
%   assert_equals( planetResultsStructOut.oddTransitsFit.modelParameters(2).value,  55005, 'Odd-transits epoch 55005 incorrectly touched!'   );
%   assert_equals( planetResultsStructOut.evenTransitsFit.modelParameters(2).value, 55007, 'Even-transits epoch 54997 incorrectly adjusted!' );
%   planetResultsStruct.evenTransitsFit.modelParameters = modelParametersValid;
% 
%   modelParametersBadEpoch(2).value = 55107;
%   planetResultsStruct.allTransitsFit.modelParameters = modelParametersBadEpoch;
%   planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 0 ) ;
%   assert_equals( planetResultsStructOut.allTransitsFit.modelParameters(2).value,  55007, 'All-transits epoch 55107 incorrectly adjusted!'  );
%   assert_equals( planetResultsStructOut.oddTransitsFit.modelParameters(2).value,  55005, 'Odd-transits epoch 55005 incorrectly touched!'   );
%   assert_equals( planetResultsStructOut.evenTransitsFit.modelParameters(2).value, 55005, 'Even-transits epoch 55005 incorrectly touched!'  );
%   planetResultsStruct.allTransitsFit.modelParameters = modelParametersValid;
%   planetResultsStruct.oddTransitsFit.modelParameters = modelParametersBadEpoch;
%   planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 1 );
%   assert_equals( planetResultsStructOut.allTransitsFit.modelParameters(2).value,  55005, 'All-transits epoch 55005 incorrectly touched!'   );
%   assert_equals( planetResultsStructOut.oddTransitsFit.modelParameters(2).value,  55007, 'Odd-transits epoch 55107 incorrectly adjusted!'   );
%   assert_equals( planetResultsStructOut.evenTransitsFit.modelParameters(2).value, 55005, 'Even-transits epoch 55005 incorrectly touched!'  );
%   planetResultsStruct.oddTransitsFit.modelParameters = modelParametersValid;
%   planetResultsStruct.evenTransitsFit.modelParameters = modelParametersBadEpoch;
%   planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 2 );
%   assert_equals( planetResultsStructOut.allTransitsFit.modelParameters(2).value,  55005, 'All-transits epoch 55005 incorrectly touched!'   );
%   assert_equals( planetResultsStructOut.oddTransitsFit.modelParameters(2).value,  55005, 'Odd-transits epoch 55005 incorrectly touched!'   );
%   assert_equals( planetResultsStructOut.evenTransitsFit.modelParameters(2).value, 55007, 'Even-transits epoch 55107 incorrectly adjusted!' );
%   planetResultsStruct.evenTransitsFit.modelParameters = modelParametersValid ;
  
  disp(' ');
  
return

% and that's it!


%=========================================================================================

% subfunction which exercises and checks the error-throw

function execute_validity_check_with_error( planetResultsStruct, uowStart, uowEnd, oddEvenFlag )

  try
      planetResultsStructOut = check_planet_model_parameter_validity( planetResultsStruct, uowStart, uowEnd, oddEvenFlag );
      mlunit_assert( false, 'No error thrown for invalid parameters!' );
  catch
      lastError = lasterror;
      mlunit_assert( ~isempty( strfind( lastError.identifier, 'invalidParameters' ) ), 'Wrong type of error thrown for invalid parameters!' ); 
  end
  
return

