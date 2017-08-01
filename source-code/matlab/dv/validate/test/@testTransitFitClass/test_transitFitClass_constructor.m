function self = test_transitFitClass_constructor( self )
%
% test_transitFitClass_constructor -- perform unit tests of the transitFitClass
% constructor
%
% This is a unit test of the functionality of the transitFitClass constructor.
% Specifically, it tests the following:
%
% ==> The constructor will properly construct a transitFitClass object from either of its
%     accepted structure formats
% ==> The constructed object's members match expectations based on the input structure
% ==> Each of the errors in the constructor is thrown under the appropriate conditions.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_transitFitClass_constructor'));
%
% Version date:  2010-May-07.
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
%    2010-May-07, PT:
%        update in support of change from MJD to BKJD for fitting.
%    2010-April-30, PT:
%        updates in support of transitGeneratorCollectionClass.
%    2010-January-10, PT:
%        support for fitTimeoutDatenum member of transitFitClass.
%    2009-September-23, PT:
%        eliminate chisqRobustWeights field from constructor.
%
%=========================================================================================

  disp('... testing transitFitClass constructor ... ')
  
% set the path to the cached input structure

  initialize_soc_variables ;
  testDataDir = [socTestDataRoot, filesep, 'dv', filesep, 'unit-tests', filesep, ...
      'transitFitClass'] ;
  
% perform partial initialization, just enough to make the subsidiary classes work
% correctly

  doFit = false ;
  doInstantiate = false ;
  testTransitFitClass_initialization ;

% load and instantiate a transitGeneratorClass object so that reloaded objects are
% properly handled

  load(fullfile(testDataDir,'transit-generator-model')) ;
  transitObject = transitGeneratorClass( transitModel ) ;
  clear transitObject transitModel ;
  
  load(fullfile(testDataDir,'transitFitClass-struct-format1')) ;
    
% remove the debug level -- optional input

  transitFitStruct = rmfield( transitFitStruct, {'debugLevel'} ) ;
  
% put random values into the transit generator object so that we can see clearly that it
% the constructor is not using hard-coded values -- randomize the epoch by up to 1/2 day,
% and the other physical parameters by up to 5%

  parameterRandomFactor = 0.05 ;

  planetModel = get( transitFitStruct.transitGeneratorObject,'planetModel' ) ;
  planetModel.transitEpochBkjd = 55020 + rand(1) - 0.5 - kjd_offset_from_mjd ;
  planetModel.planetRadiusEarthRadii = planetModel.planetRadiusEarthRadii * ...
      random_fraction( parameterRandomFactor ) ;
  planetModel.semiMajorAxisAu = planetModel.semiMajorAxisAu * ...
      random_fraction( parameterRandomFactor ) ;
  planetModel.starRadiusSolarRadii = planetModel.starRadiusSolarRadii * ...
      random_fraction( parameterRandomFactor ) ;
  planetModel.minImpactParameter = rand(1) * parameterRandomFactor ;
  transitFitStruct.transitGeneratorObject = set( transitFitStruct.transitGeneratorObject, ...
      'planetModel', planetModel ) ;
  planetModel = get( transitFitStruct.transitGeneratorObject, 'planetModel' ) ;
  
% add noise to the whitened flux time series values

  transitFitStruct.whitenedFluxTimeSeries.values = ...
      transitFitStruct.whitenedFluxTimeSeries.values + ...
      transitFitStruct.whitenedFluxTimeSeries.uncertainties .* ...
      randn( size( transitFitStruct.whitenedFluxTimeSeries.values ) ) ;
  
% set the step sizes to non-default values

  transitFitStruct.configurationStruct.transitEpochStepSizeCadences = 0.01 ;
  transitFitStruct.configurationStruct.planetRadiusStepSizeEarthRadii = 1e-3 ;
  transitFitStruct.configurationStruct.semiMajorAxisStepSizeAu        = 2e-3 ;
  transitFitStruct.configurationStruct.minImpactParameterStepSize     = 1e-4 ;
  transitFitStruct.configurationStruct.orbitalPeriodStepSizeDays      = 2e-4 ;
  transitFitStruct.configurationStruct.fitTimeoutDatenum              = 1e6 ;
  
% check the fields of the cached structure -- they should match the required fields of the
% constructor, and not have any optional fields

  expectedFields = {'whitenedFluxTimeSeries', 'whiteningFilterModel', ...
      'transitGeneratorObject', 'configurationStruct' } ;
  cachedStructFormatCorrect = ...
      all( isfield(transitFitStruct,expectedFields) ) && ...
      length(fieldnames(transitFitStruct)) == length(expectedFields) ;
  if ~cachedStructFormatCorrect
      error('dv:test:testTransitFitClassConstructor:cachedStructInvalid', ...
          'test_transitFitClass_constructor: the cached struct has invalid format') ;
  end
  
% perform instantiation -- should go without error

  transitFitObject = transitFitClass( transitFitStruct, 1 ) ;
  
% convert the object back to a struct and check that values were properly assigned

  transitFitStruct2 = get(transitFitObject, '*') ;
  
  objectFields = {'whitenedFluxTimeSeries',  ...
      'whiteningFilterObject', 'transitGeneratorObject', ...
      'parameterMapStruct', 'initialParValues', 'finalParValues', 'parValueCovariance', ...
      'robustWeights', 'chisq', 'ndof', 'fitType', 'fitOptions', 'oddEvenFlag', ...
      'debugLevel', 'fitTimeoutDatenum'} ;
  fieldsCorrect = ...
      all( isfield(transitFitStruct2,objectFields) ) && ...
      length(fieldnames(transitFitStruct2)) == length(objectFields) ;
  parameterMapStruct = transitFitStruct2.parameterMapStruct ;
  parameterMapStructFields = {'transitEpochBkjd' , 'planetRadiusEarthRadii', ...
      'semiMajorAxisAu', 'minImpactParameter', 'orbitalPeriodDays'} ;
  fieldsCorrect = fieldsCorrect && ...
      all( isfield(parameterMapStruct,parameterMapStructFields) ) && ...
      length(fieldnames(parameterMapStruct)) == length(parameterMapStructFields) ;
  fieldsOk = isequal( transitFitStruct.whitenedFluxTimeSeries, ...
                      transitFitStruct2.whitenedFluxTimeSeries ) ;
  fieldsOk = fieldsOk && isequal( transitFitStruct.transitGeneratorObject, ...
                                  transitFitStruct2.transitGeneratorObject ) ;
  fieldsOk = fieldsOk && isequal( whiteningFilterClass( transitFitStruct.whiteningFilterModel ), ...
                                  transitFitStruct2.whiteningFilterObject ) ;
  fieldsOk = fieldsOk && parameterMapStruct.transitEpochBkjd == 1 ;
  fieldsOk = fieldsOk && parameterMapStruct.planetRadiusEarthRadii == 2 ;
  fieldsOk = fieldsOk && parameterMapStruct.semiMajorAxisAu == 3 ;
  fieldsOk = fieldsOk && parameterMapStruct.orbitalPeriodDays == 4 ;
  fieldsOk = fieldsOk && parameterMapStruct.minImpactParameter == 0 ;
  fieldsOk = fieldsOk && isempty( transitFitStruct2.finalParValues ) ;
  fieldsOk = fieldsOk && isempty( transitFitStruct2.parValueCovariance ) ;
  fieldsOk = fieldsOk && isempty( transitFitStruct2.robustWeights ) ;
  fieldsOk = fieldsOk && transitFitStruct2.chisq == 0 ;
  fieldsOk = fieldsOk && transitFitStruct2.ndof == 0 ;
  fieldsOk = fieldsOk && transitFitStruct2.fitType == 1 ;
  fieldsOk = fieldsOk && isequal( transitFitStruct2.initialParValues(:), ...
      [planetModel.transitEpochBkjd ; planetModel.planetRadiusEarthRadii ; ...
       planetModel.semiMajorAxisAu ; planetModel.orbitalPeriodDays] ) ;
  fieldsOk = fieldsOk && transitFitStruct2.oddEvenFlag == 0 ;
  fieldsOk = fieldsOk && transitFitStruct2.debugLevel == 0 ;
  fieldsOk = fieldsOk && transitFitStruct2.fitOptions.convSigma == ...
      transitFitStruct.configurationStruct.tolSigma ;
  fieldsOk = fieldsOk && transitFitStruct2.fitOptions.TolFun == ...
      transitFitStruct.configurationStruct.tolFun ;
  robustOk = ( strcmpi(transitFitStruct2.fitOptions.Robust,'on') && ...
               transitFitStruct.configurationStruct.robustFitEnabled    ) || ...
      ( strcmpi(transitFitStruct2.fitOptions.Robust,'off') && ...
                ~transitFitStruct.configurationStruct.robustFitEnabled    ) ;
  fieldsOk = fieldsOk && robustOk ;
  expectedDerivStep = [ ...
      transitFitStruct.configurationStruct.transitEpochStepSizeCadences * ...
      get( transitFitStruct.transitGeneratorObject, 'cadenceDurationDays' ) / ...
       planetModel.transitEpochBkjd ; ...
       transitFitStruct.configurationStruct.planetRadiusStepSizeEarthRadii / ...
       planetModel.planetRadiusEarthRadii ; ...
       transitFitStruct.configurationStruct.semiMajorAxisStepSizeAu / ...
       planetModel.semiMajorAxisAu ; ...
       transitFitStruct.configurationStruct.orbitalPeriodStepSizeDays / ...
       planetModel.orbitalPeriodDays ...
       ] ;
  fieldsOk = fieldsOk && isequal( transitFitStruct2.fitOptions.DerivStep(:), ...
      expectedDerivStep ) ;
  fieldsOk = fieldsOk && isequal( transitFitStruct2.fitTimeoutDatenum, ...
      transitFitStruct.configurationStruct.fitTimeoutDatenum ) ;
  
% the constructor was correctly instantiated if all of the fields are OK, so:

  mlunit_assert( fieldsCorrect && fieldsOk, ...
      'transitFitClass object initial instantiation not correct' ) ;
  
% instantiate a new object from transitFitStruct2 -- this should go without error and
% should produce an object which is bitwise-identical to the original.  Note that the
% fitType argument is ignored in this case

  transitFitObject2 = transitFitClass( transitFitStruct2, 0 ) ;
  mlunit_assert( isequal( transitFitObject, transitFitObject2 ) , ...
      'transitFitClass instantiation syntaxes do not produce equivalent objects' ) ;
  
% set the debug level, and change the robust fitting option and fit
% type flags, and see whether the object is correctly instantiated

  transitFitStruct.debugLevel = 2 ;
  transitGeneratorObjectOld = transitFitStruct.transitGeneratorObject ;
  transitFitStruct.configurationStruct.robustFitEnabled = ...
      ~transitFitStruct.configurationStruct.robustFitEnabled ;
  load(fullfile(testDataDir,'transit-generator-model')) ;
  transitObject = transitGeneratorCollectionClass( transitModel, 1 ) ;
  transitFitStruct.transitGeneratorObject = transitObject ;
  planetModelOld = planetModel ;
  planetModel = get( transitObject, 'planetModel' ) ;

  transitFitObject3 = transitFitClass( transitFitStruct, 0 ) ;
  transitFitStruct2 = get( transitFitObject3, '*' ) ;
  parameterMapStruct = transitFitStruct2.parameterMapStruct ;
  oddEvenFlag = get( transitFitStruct.transitGeneratorObject, 'oddEvenFlag' ) ;
  
  fieldsOk = isequal([parameterMapStruct.transitEpochBkjd], [1 5]) ;
  fieldsOk = fieldsOk && isequal([parameterMapStruct.planetRadiusEarthRadii], [2 6]) ;
  fieldsOk = fieldsOk && isequal([parameterMapStruct.semiMajorAxisAu], [3 7]) ;
  fieldsOk = fieldsOk && all([parameterMapStruct.orbitalPeriodDays] == 0) ;
  fieldsOk = fieldsOk && isequal([parameterMapStruct.minImpactParameter], [4 8]) ;
  fieldsOk = fieldsOk && all(transitFitStruct2.fitType == 0) ;
  fieldsOk = fieldsOk && isequal( transitFitStruct2.initialParValues(:), ...
      repmat( [planetModel(1).transitEpochBkjd ; planetModel(1).planetRadiusEarthRadii ; ...
       planetModel(1).semiMajorAxisAu ; planetModel(1).minImpactParameter], 2, 1 ) ) ;
  fieldsOk = fieldsOk && transitFitStruct2.oddEvenFlag == oddEvenFlag ;
  fieldsOk = fieldsOk && transitFitStruct2.debugLevel == transitFitStruct.debugLevel ;
  robustOk = ( strcmpi(transitFitStruct2.fitOptions.Robust,'on') && ...
               transitFitStruct.configurationStruct.robustFitEnabled    ) || ...
      ( strcmpi(transitFitStruct2.fitOptions.Robust,'off') && ...
                ~transitFitStruct.configurationStruct.robustFitEnabled    ) ;
  fieldsOk = fieldsOk && robustOk ;
  expectedDerivStep = [ ...
      transitFitStruct.configurationStruct.transitEpochStepSizeCadences * ...
      get( transitFitStruct.transitGeneratorObject, 'cadenceDurationDays' ) / ...
       planetModel(1).transitEpochBkjd ; ...
       transitFitStruct.configurationStruct.planetRadiusStepSizeEarthRadii / ...
       planetModel(1).planetRadiusEarthRadii ; ...
       transitFitStruct.configurationStruct.semiMajorAxisStepSizeAu / ...
       planetModel(1).semiMajorAxisAu ; ...
       transitFitStruct.configurationStruct.minImpactParameterStepSize ...
       ] ;
  fieldsOk = fieldsOk && isequal( transitFitStruct2.fitOptions.DerivStep(:), ...
      repmat(expectedDerivStep,2,1) ) ;
   
  mlunit_assert( fieldsOk, 'transitFitClass constructor instantiates incorrectly on test 3' ) ;
  
% Note that the constructor using format 2 should ignore the fitType argument  
  
  transitFitObject4 = transitFitClass( transitFitStruct2, 1 ) ;
  mlunit_assert( isequal( transitFitObject3, transitFitObject4 ), ...
      'transitFitClass constructor instantiates incorrectly on test 3' ) ;
   
% set the fitType flag to 2 and make sure that the relevant fields are set correctly

  transitFitStruct.transitGeneratorObject = transitGeneratorObjectOld ;
  planetModel = planetModelOld ;
  transitFitObject5 = transitFitClass( transitFitStruct, 2 ) ;
  transitFitStruct2 = get( transitFitObject5, '*' ) ;
  parameterMapStruct = transitFitStruct2.parameterMapStruct ;
  fieldsOk = parameterMapStruct.transitEpochBkjd == 1 ;
  fieldsOk = fieldsOk && parameterMapStruct.planetRadiusEarthRadii == 2 ;
  fieldsOk = fieldsOk && parameterMapStruct.semiMajorAxisAu == 3 ;
  fieldsOk = fieldsOk && parameterMapStruct.orbitalPeriodDays == 0 ;
  fieldsOk = fieldsOk && parameterMapStruct.minImpactParameter == 0 ;
  fieldsOk = fieldsOk && transitFitStruct2.fitType == 2 ;
  
  fieldsOk = fieldsOk && isequal( transitFitStruct2.initialParValues(:), ...
      [planetModel.transitEpochBkjd ; planetModel.planetRadiusEarthRadii ; ...
       planetModel.semiMajorAxisAu] ) ;
  expectedDerivStep = [ ...
      transitFitStruct.configurationStruct.transitEpochStepSizeCadences * ...
      get( transitFitStruct.transitGeneratorObject, 'cadenceDurationDays' ) / ...
       planetModel.transitEpochBkjd ; ...
       transitFitStruct.configurationStruct.planetRadiusStepSizeEarthRadii / ...
       planetModel.planetRadiusEarthRadii ; ...
       transitFitStruct.configurationStruct.semiMajorAxisStepSizeAu / ...
       planetModel.semiMajorAxisAu] ;
  fieldsOk = fieldsOk && isequal( transitFitStruct2.fitOptions.DerivStep(:), ...
      expectedDerivStep ) ;

  mlunit_assert( fieldsOk, 'transitFitClass constructor instantiates incorrectly on test 5' ) ;
   
% test the format 2 instantation in this case

  transitFitObject6 = transitFitClass( transitFitStruct2, 1 ) ;
  mlunit_assert( isequal( transitFitObject5, transitFitObject6 ), ...
      'transitFitClass constructor instantiates incorrectly on test 6' ) ;
   
% Reduce the number of transits to 2, request fitType 1 on odd-even transits, and make
% sure that fitType 2 is what it actually instantiates with

  transitFitStruct.transitGeneratorObject = transitObject ;
  cadenceTimes = get( transitFitStruct.transitGeneratorObject, 'cadenceTimes' ) ;
  timeRange = range(cadenceTimes) ;
  planetModel = get( transitFitStruct.transitGeneratorObject, 'planetModel' ) ;
  planetModel(1).orbitalPeriodDays = 0.6 * timeRange ;
  planetModel(1).transitEpochBkjd = cadenceTimes(1) + 0.35 * timeRange ;
  planetModel(2).orbitalPeriodDays = 0.6 * timeRange ;
  planetModel(2).transitEpochBkjd = cadenceTimes(1) + 0.35 * timeRange ;
  transitFitStruct.transitGeneratorObject = set( transitFitStruct.transitGeneratorObject, ...
      'planetModel', planetModel ) ;
  
  transitFitObject7 = transitFitClass( transitFitStruct, 1 ) ;
  fitType = get( transitFitObject7, 'fitType' ) ;
  assert_equals( fitType(:), [2 ; 2], ...
      'transitFitClass constructor instantiates incorrectly on test 7' ) ;
  
% set # of transits to 3, request fitType 1 on odd-even transits, and make sure that evens
% get fitType 2 but odds get fitType 1

  planetModel = get( transitFitStruct.transitGeneratorObject, 'planetModel' ) ;
  planetModel(1).orbitalPeriodDays = 0.3 * timeRange ;
  planetModel(1).transitEpochBkjd = cadenceTimes(1) + 0.25 * timeRange ;
  planetModel(2).orbitalPeriodDays = 0.3 * timeRange ;
  planetModel(2).transitEpochBkjd = cadenceTimes(1) + 0.25 * timeRange ;
  transitFitStruct.transitGeneratorObject = set( transitFitStruct.transitGeneratorObject, ...
      'planetModel', planetModel ) ;

  transitFitObject8 = transitFitClass( transitFitStruct, 1 ) ;
  fitType = get( transitFitObject8, 'fitType' ) ;
  assert_equals( fitType(:), [1 ; 2], ...
      'transitFitClass constructor instantiates incorrectly on test 8' ) ;
  
% exercise error statements:

  transitFitStruct.transitGeneratorObject = transitGeneratorObjectOld ;

% invalid struct fields
  
  transitFitStructFail = transitFitStruct ;
  transitFitStructFail.testField = [] ;
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,1);', ...
      'invalidStructFormat', transitFitStructFail, 'transitFitStruct' ) ;
  
  transitFitStructFail = transitFitStruct ; 
  transitFitStructFail = rmfield(transitFitStructFail, 'configurationStruct') ;
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,1);', ...
      'invalidStructFormat', transitFitStructFail, 'transitFitStruct' ) ;
  
  transitFitStructFail = transitFitStruct2 ;
  transitFitStructFail.testField = [] ;
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,1);', ...
      'invalidStructFormat', transitFitStructFail, 'transitFitStruct' ) ;
  transitFitStructFail = transitFitStruct2 ;
  transitFitStructFail = rmfield(transitFitStructFail, 'fitType') ;
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,1);', ...
      'invalidStructFormat', transitFitStructFail, 'transitFitStruct' ) ;
  
% one transit and odd-even flag set to 0

  transitFitStructFail = transitFitStruct ;
  planetModel = get( transitFitStructFail.transitGeneratorObject, 'planetModel' ) ;
  planetModel(1).orbitalPeriodDays = 2 * timeRange ;
  planetModel(1).transitEpochBkjd = cadenceTimes(1) + 0.5 * timeRange ;
  transitFitStructFail.transitGeneratorObject = set( ...
      transitFitStructFail.transitGeneratorObject, 'planetModel', planetModel ) ;
  
   try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,1);', ...
      'insufficientTransitsToFit', transitFitStructFail, 'transitFitStruct' ) ;

% zero transits and odd-even flag set to 1

  transitFitStructFail = transitFitStruct ;
  transitFitStructFail.transitGeneratorObject = transitObject ;
  planetModel = get( transitFitStructFail.transitGeneratorObject, 'planetModel' ) ;
  planetModel(1).orbitalPeriodDays = 2 * timeRange ;
  planetModel(1).transitEpochBkjd = cadenceTimes(1) + 1.5 * timeRange ;
  planetModel(2).orbitalPeriodDays = 2 * timeRange ;
  planetModel(2).transitEpochBkjd = cadenceTimes(1) + 1.5 * timeRange ;
  transitFitStructFail.transitGeneratorObject = set( ...
      transitFitStructFail.transitGeneratorObject, 'planetModel', planetModel ) ;
  
   try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,1);', ...
      'insufficientTransitsToFit', transitFitStructFail, 'transitFitStruct' ) ;
  
% oddEvenFlag set to 1, 4 transits present based on timing but all odd or all even are
% gapped out.

  planetModel = get( transitFitStructFail.transitGeneratorObject, 'planetModel' ) ;
  planetModel(1).orbitalPeriodDays = 0.25 * timeRange ;
  planetModel(1).transitEpochBkjd = cadenceTimes(1) + 0.2 * timeRange ;
  planetModel(2).orbitalPeriodDays = 0.25 * timeRange ;
  planetModel(2).transitEpochBkjd = cadenceTimes(1) + 0.2 * timeRange ;
  transitFitStructFail.transitGeneratorObject = set( ...
      transitFitStructFail.transitGeneratorObject, 'planetModel', planetModel ) ;
  
% only transits 1 and 3 present 
  
  nCadences = length( transitFitStructFail.whitenedFluxTimeSeries.gapIndicators ) ;
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators( ...
      [round(0.25*nCadences):round(0.5*nCadences)] ) = true ;
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators( ...
      [round(0.75*nCadences):nCadences] ) = true ;
  
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,1);', ...
      'insufficientTransitsToFit', transitFitStructFail, 'transitFitStruct' ) ;

% only transits 2 and 4 present
  
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators(1:end) = false ;
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators( ...
      [1:round(0.25*nCadences)] ) = true ;
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators( ...
      [round(0.5*nCadences):round(0.75*nCadences)] ) = true ;

  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,1);', ...
      'insufficientTransitsToFit', transitFitStructFail, 'transitFitStruct' ) ;
    
  disp(' ') ;

return
  
% and that's it!

%
%
%

  
%=========================================================================================

% subfunction to return a random fractional change

function rvalue = random_fraction( fraction )

% not much to it

  rvalue = 1 + 2*fraction*(randn(1)-0.5) ;
  
return 

% and that's it!

%
%
%
