function self = test_fill_planet_results_struct( self )
%
% test_fill_planet_results_struct -- unit test for fill_planet_results_struct method of
% transitFitClass
%
% This unit test exercises the following functionality of the method:
%
% ==> The method correctly fills the allTransitsFit, oddTransitsFit, or evenTransitsFit
%     structs in the planetResultsStruct, depending on the value of oddEvenFlag
% ==> The values which are put into the planetResultsStruct match the values in the
%     transitFitClass object
% ==> The correct parameters are flagged as fitted parameters
% ==> The expected and observed transit count values in the planetResultsStruct are filled
%     correctly when the all-transits fit struct is filled.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_fill_planet_results_struct'));
%
% Version date:  2010-April-30.
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
%    2010-April-30, PT:
%        allow for a little round-off in the parameters.  Changes in support of
%        transitGeneratorCollectionClass.
%
%=========================================================================================

% start with initialization

  disp(' ... testing fill-planet-results-struct method ... ')
  
  testTransitFitClass_initialization ;
  load( fullfile( testDataDir, 'planet-results-struct' ) ) ;
  planetResultsStructBefore = planetResultsStruct ;
  
% exercise the method on the all-transits-fit case and make sure that the correct values
% are inserted in the correct places

  planetResultsStruct = fill_planet_results_struct( transitFitObject1, ...
      planetResultsStructBefore ) ;
  
  assert_equals( planetResultsStruct.planetCandidate.expectedTransitCount, 10, ...
      'Expected transit count value is incorrect on all-transits fill operation!' ) ;
  assert_equals( planetResultsStruct.planetCandidate.observedTransitCount, 10, ...
      'Observed transit count value is incorrect on all-transits fill operation!' ) ;
  assert_equals( planetResultsStruct.oddTransitsFit, ...
      planetResultsStructBefore.oddTransitsFit, ...
      'Odd-transits fit struct touched during all-transits-fit fill operation!' ) ;
  assert_equals( planetResultsStruct.evenTransitsFit, ...
      planetResultsStructBefore.evenTransitsFit, ...
      'Even-transits fit struct touched during all-transits-fit fill operation!' ) ;
  
  check_filled_values( transitFitObject1, planetResultsStruct.allTransitsFit, ...
      'all-transits-fit' ) ;
  
% Now do the same checks for odd-transits and even-transits structs; this requires a new
% fit

  load(fullfile(testDataDir,'transit-generator-model')) ;
  transitObject = transitGeneratorCollectionClass( transitModel, 1 ) ;
  transitFitStruct.transitGeneratorObject = transitObject ;
  transitFitObject2 = transitFitClass( transitFitStruct, 1 ) ;
  transitFitObject2 = fit_transit( transitFitObject2 ) ;

  planetResultsStruct = fill_planet_results_struct( transitFitObject2, ...
      planetResultsStructBefore ) ;
  
  assert_equals( planetResultsStruct.planetCandidate.expectedTransitCount, 0, ...
      'Expected transit count value is incorrect on odd-transits fill operation!' ) ;
  assert_equals( planetResultsStruct.planetCandidate.observedTransitCount, 0, ...
      'Observed transit count value is incorrect on aodd-transits fill operation!' ) ;
  assert_equals( planetResultsStruct.allTransitsFit, ...
      planetResultsStructBefore.allTransitsFit, ...
      'All-transits fit struct touched during odd-transits-fit fill operation!' ) ;
  
  check_filled_values( transitFitObject2, planetResultsStruct.oddTransitsFit, ...
      'odd-transits-fit' ) ;
    
  check_filled_values( transitFitObject2, planetResultsStruct.evenTransitsFit, ...
      'even-transits-fit' ) ;
  
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which performs the actual value checks in the fill function

function check_filled_values( transitFitObject1, transitFitStruct, messageString )

% since there is some round-off error (we are comparing the par values in transitFitObject
% to the ones in the fit struct; but the fit struct is filled from the planet model; so
% the round-off in the Kepler's 3rd law calc comes into play), put in a round-off error
% tolerance

  roundOffTolerance = 1e-12 ;

% start with the easy ones 

  assert_equals( get(transitFitObject1,'chisq'), ...
      transitFitStruct.modelChiSquare, ...
      ['modelChiSquare not correctly filled in ',messageString,' test!'] ) ;
  assert_equals( get(transitFitObject1,'ndof'), ...
      transitFitStruct.modelDegreesOfFreedom, ...
      ['modelDegreesOfFreedom not correctly filled in ',messageString,' test!'] ) ;
  assert_equals( get(transitFitObject1,'robustWeights'), ...
      transitFitStruct.robustWeights, ...
      ['robustWeights not correctly filled in ',messageString,' test!'] ) ;
  
% check the size of the covariance and model parameters 

  assert_equals( size( transitFitStruct.modelParameterCovariance ), [144 1], ...
      ['modelParameterCovariance has wong dimensions in ', messageString, ' test!'] ) ;
  assert_equals( size( transitFitStruct.modelParameters ), [1 12], ...
      ['modelParameters has wong dimensions in ', messageString, ' test!'] ) ;
  
% identify the parameters which are actually fitted in the transit fit object

  fittedParameters = { 'transitEpochBkjd', 'planetRadiusEarthRadii', 'semiMajorAxisAu', ...
      'orbitalPeriodDays' } ;
  
% loop over the parameters in the output struct; make sure that the parameter
% uncertainties are correctly copied from the covariance, that the fitted parameter values
% and uncertainties are correctly copied from the transit object, and that the fit flags
% are correctly set.  Note that the returned value of the epoch for the even transits is
% offset from the fitted value by 1 period, so we must take care of that before doing the
% comparison

  modelParameterCovariance = reshape( transitFitStruct.modelParameterCovariance, 12, 12 ) ;
  modelParameters = transitFitStruct.modelParameters ;
  parameterMapStruct = get( transitFitObject1, 'parameterMapStruct' ) ;
  finalParValues = get( transitFitObject1, 'finalParValues' ) ;
  parValueCovariance = get( transitFitObject1, 'parValueCovariance' ) ;
  
  if strcmp( messageString, 'odd-transits-fit' )
      parameterMapStruct = parameterMapStruct(1) ;
  elseif strcmp( messageString, 'even-transits-fit' )
      parameterMapStruct = parameterMapStruct(2) ;
      modelParameters(1).value = modelParameters(1).value - modelParameters(11).value ;
      modelParameters(1).uncertainty = sqrt( modelParameterCovariance(1,1) + ...
          modelParameterCovariance(11,11) - 2*modelParameterCovariance(1,11) ) ;
      offsetJacobian = eye( 12 ) ;
      offsetJacobian(1,11) = -1 ;
      modelParameterCovariance = offsetJacobian * modelParameterCovariance * ...
          offsetJacobian' ;
  end
  
  for iPar = 1:12
      
      parameterName = modelParameters(iPar).name ;
      parameterValue = modelParameters(iPar).value ;
      parameterUncertainty = modelParameters(iPar).uncertainty ;
      fitFlag = modelParameters(iPar).fitted ;
      
      assert_equals( sqrt(modelParameterCovariance(iPar,iPar)), parameterUncertainty, ...
          ['Uncertainty and covariance do not agree for parameter ', parameterName, ...
          ' on ', messageString, ' test!'] ) ;
      if ismember( parameterName, fittedParameters )
          
          parameterPointer = parameterMapStruct.(parameterName) ;
          mlunit_assert( ...
              abs( finalParValues(parameterPointer) - parameterValue ) < ...
              roundOffTolerance, ...
              ['Incorrect value for parameter ', parameterName, ...
              ' on ', messageString, ' test!'] ) ;
          mlunit_assert( fitFlag, ...
              ['Fit flag not set for parameter ', parameterName, ...
              ' on ', messageString, ' test!'] ) ;
          assert_equals( sqrt( parValueCovariance( parameterPointer, parameterPointer ) ), ...
              parameterUncertainty, ...
              ['Uncertainty does not match fitted covariance value for parameter ', ...
              parameterName, ' on ', messageString, ' test!'] ) ;
          
      else
          
          mlunit_assert( ~fitFlag, ...
              ['Fit flag set for parameter ', parameterName, ...
              ' on ', messageString, ' test!'] ) ;
          
      end
      
  end
  
return

% and that's it!

%
%
%
