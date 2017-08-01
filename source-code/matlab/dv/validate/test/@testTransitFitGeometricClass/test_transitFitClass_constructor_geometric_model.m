function self = test_transitFitClass_constructor_geometric_model( self )
%
% test_transitFitClass_constructor_geometric_model -- perform unit tests of the transitFitClass
% constructor with geometric transit model
%
% This is a unit test of the functionality of the transitFitClass constructor with geometric transit model.
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
%      run(text_test_runner, testTransitFitClass('test_transitFitClass_constructor_geometric_model'));
%
% Version date:  2011-April-20.
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
%    2011-April-20, JL:
%        update to support DV 7.0
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

  disp(' ');
  disp('... testing transitFitClass constructor with geometric transit model... ');
  disp(' ');
  
% perform partial initialization, just enough to make the subsidiary classes work correctly

  doInstantiate = false;
  doFit         = false;
  testTransitFitGeometricClass_initialization;

%
% Part I
%
% load transitFitStruct (format 3) and remove the debug level -- optional input
  
  load(fullfile(testDataDir,'transit-fit-struct'));
  transitFitStruct = rmfield( transitFitStruct, {'debugLevel'} );
  
% put random values into the transit generator object so that we can see clearly that the constructor is not using hard-coded values 
% -- randomize the epoch by up to 1/2 day, and the other physical parameters by up to 5%

  parameterRandomFactor = 0.05;

  planetModel                                       = get( transitFitStruct.transitGeneratorObject, 'planetModel' );
  planetModel.transitEpochBkjd                      = planetModel.transitEpochBkjd + rand(1) - 0.5;
  planetModel.minImpactParameter                    = rand(1) * parameterRandomFactor; 
  planetModel.ratioPlanetRadiusToStarRadius         = planetModel.ratioPlanetRadiusToStarRadius  * random_fraction( parameterRandomFactor );
  planetModel.ratioSemiMajorAxisToStarRadius        = planetModel.ratioSemiMajorAxisToStarRadius * random_fraction( parameterRandomFactor );
  planetModel.orbitalPeriodDays                     = planetModel.orbitalPeriodDays              * random_fraction( parameterRandomFactor );
  planetModel.starRadiusSolarRadii                  = planetModel.starRadiusSolarRadii           * random_fraction( parameterRandomFactor );
  transitFitStruct.transitGeneratorObject           = set( transitFitStruct.transitGeneratorObject, 'planetModel', planetModel );
  planetModel                                       = get( transitFitStruct.transitGeneratorObject, 'planetModel' );
  
% add noise to the whitened flux time series values

  transitFitStruct.whitenedFluxTimeSeries.values    = transitFitStruct.whitenedFluxTimeSeries.values + ...
                                                      transitFitStruct.whitenedFluxTimeSeries.uncertainties .* randn( size(transitFitStruct.whitenedFluxTimeSeries.values) );
  
% set the step sizes to non-default values

  transitFitStruct.configurationStruct.transitEpochStepSizeCadences             = 0.2;
  transitFitStruct.configurationStruct.ratioPlanetRadiusToStarRadiusStepSize    = 1e-5;
  transitFitStruct.configurationStruct.ratioSemiMajorAxisToStarRadiusStepSize   = 1e-5;
  transitFitStruct.configurationStruct.minImpactParameterStepSize               = 1e-3;
  transitFitStruct.configurationStruct.orbitalPeriodStepSizeDays                = 1e-4;
  transitFitStruct.configurationStruct.fitTimeoutDatenum                        = 1e6;
  
% check the fields of the cached structure -- they should match the required fields of the constructor, and not have any optional fields

  expectedFields = {'targetFluxTimeSeries', 'barycentricCadenceTimes', 'whitenedFluxTimeSeries', 'whiteningFilterModel', 'transitGeneratorObject', 'configurationStruct' };
  cachedStructFormatCorrect = all( isfield(transitFitStruct,expectedFields) ) && length(fieldnames(transitFitStruct)) == length(expectedFields);
  if ~cachedStructFormatCorrect
      error('dv:test:testTransitFitClassConstructor:cachedStructInvalid', 'test_transitFitClass_constructor: the cached struct has invalid format');
  end
  
% perform instantiation -- should go without error

  transitFitObject1 = transitFitClass( transitFitStruct, 12 );
  
% convert the object back to a struct (format 4) and check that values were properly assigned

  transitFitStruct1 = get(transitFitObject1, '*');
  
  objectFields = {'targetFluxTimeSeries',  'barycentricCadenceTimes', 'whitenedFluxTimeSeries', 'whiteningFilterObject', 'transitGeneratorObject', 'parameterMapStruct', ...
      'initialParValues', 'finalParValues', 'parValueLowerBounds', 'parValueUpperBounds', 'parMessages', 'parValueCovariance', ...
      'configurationStruct', 'robustWeights', 'chisq', 'ndof', 'allTransitSnr', 'oddTransitSnr', 'evenTransitSnr', 'fitType', ...
      'fitOptions', 'oddEvenFlag', 'debugLevel', 'fitTimeoutDatenum'};
  fieldsCorrect = all( isfield(transitFitStruct1,objectFields) ) && length(fieldnames(transitFitStruct1))==length(objectFields);
  parameterMapStruct = transitFitStruct1.parameterMapStruct;
  parameterMapStructFields = {'transitEpochBkjd', 'ratioPlanetRadiusToStarRadius', 'ratioSemiMajorAxisToStarRadius', 'minImpactParameter', 'orbitalPeriodDays'};
  fieldsCorrect = fieldsCorrect && all( isfield(parameterMapStruct,parameterMapStructFields) ) && length(fieldnames(parameterMapStruct))==length(parameterMapStructFields);
  fieldsOk =             isequal( transitFitStruct.whitenedFluxTimeSeries, transitFitStruct1.whitenedFluxTimeSeries );
  fieldsOk = fieldsOk && isequal( transitFitStruct.transitGeneratorObject, transitFitStruct1.transitGeneratorObject );
  fieldsOk = fieldsOk && isequal( whiteningFilterClass( transitFitStruct.whiteningFilterModel ), transitFitStruct1.whiteningFilterObject );
  fieldsOk = fieldsOk && parameterMapStruct.transitEpochBkjd               == 1;
  fieldsOk = fieldsOk && parameterMapStruct.ratioPlanetRadiusToStarRadius  == 2;
  fieldsOk = fieldsOk && parameterMapStruct.ratioSemiMajorAxisToStarRadius == 3;
  fieldsOk = fieldsOk && parameterMapStruct.minImpactParameter             == 4;
  fieldsOk = fieldsOk && parameterMapStruct.orbitalPeriodDays              == 5;
  fieldsOk = fieldsOk && isempty( transitFitStruct1.finalParValues );
  fieldsOk = fieldsOk && isempty( transitFitStruct1.parValueCovariance );
  fieldsOk = fieldsOk && isempty( transitFitStruct1.robustWeights );
  fieldsOk = fieldsOk && transitFitStruct1.chisq          == -1;
  fieldsOk = fieldsOk && transitFitStruct1.ndof           == -1;
  fieldsOk = fieldsOk && transitFitStruct1.allTransitSnr  == -1;
  fieldsOk = fieldsOk && transitFitStruct1.oddTransitSnr  == -1;
  fieldsOk = fieldsOk && transitFitStruct1.evenTransitSnr == -1;
  fieldsOk = fieldsOk && transitFitStruct1.fitType == 12;
  fieldsOk = fieldsOk && isequal( transitFitStruct1.initialParValues(:), ...
      [planetModel.transitEpochBkjd; ...
       planetModel.ratioPlanetRadiusToStarRadius; ...
       planetModel.ratioSemiMajorAxisToStarRadius; ...
       planetModel.minImpactParameter; ...
       planetModel.orbitalPeriodDays] );
  fieldsOk = fieldsOk && transitFitStruct1.oddEvenFlag == 0;
  fieldsOk = fieldsOk && transitFitStruct1.debugLevel  == 0;
  fieldsOk = fieldsOk && transitFitStruct1.fitOptions.TolFun == transitFitStruct.configurationStruct.tolFun;
  robustOk = ( strcmpi(transitFitStruct1.fitOptions.Robust,'on' ) &&  transitFitStruct.configurationStruct.robustFitEnabled ) || ...
             ( strcmpi(transitFitStruct1.fitOptions.Robust,'off') && ~transitFitStruct.configurationStruct.robustFitEnabled );
  fieldsOk = fieldsOk && robustOk;
  expectedDerivStep = [ ...
      transitFitStruct.configurationStruct.transitEpochStepSizeCadences * get(transitFitStruct.transitGeneratorObject,'cadenceDurationDays') / planetModel.transitEpochBkjd; ...
      transitFitStruct.configurationStruct.ratioPlanetRadiusToStarRadiusStepSize; ...
      transitFitStruct.configurationStruct.ratioSemiMajorAxisToStarRadiusStepSize; ...
      transitFitStruct.configurationStruct.minImpactParameterStepSize; ...
      transitFitStruct.configurationStruct.orbitalPeriodStepSizeDays / planetModel.orbitalPeriodDays ];
  fieldsOk = fieldsOk && isequal( transitFitStruct1.fitOptions.DerivStep(:), expectedDerivStep );
  fieldsOk = fieldsOk && isequal( transitFitStruct1.fitTimeoutDatenum, transitFitStruct.configurationStruct.fitTimeoutDatenum );
  
% the constructor was correctly instantiated if all of the fields are OK, so:

  mlunit_assert( fieldsCorrect && fieldsOk, 'transitFitClass object initial instantiation not correct in test 1' );
  
% instantiate a new object from transitFitStruct4 -- this should go without error and should produce an object which is bitwise-identical to the original.
% Note that the fitType argument is ignored in this case
  
  transitFitObject2 = transitFitClass( transitFitStruct1, 12 );
  mlunit_assert( isequal( transitFitObject1, transitFitObject2 ) , 'transitFitClass instantiation syntaxes do not produce equivalent objects in test 2' );
  
  transitFitObject3 = transitFitClass( transitFitStruct1, 14 );
  mlunit_assert( isequal( transitFitObject1, transitFitObject3 ) , 'transitFitClass instantiation syntaxes do not produce equivalent objects in test 3' );

%
% Part II
%
% set the debug level, and change the robust fitting option and fit type flags, and see whether the object is correctly instantiated

  transitFitStruct.debugLevel                           = 2;
  transitGeneratorObjectOld                             = transitFitStruct.transitGeneratorObject;
  transitFitStruct.configurationStruct.robustFitEnabled = ~transitFitStruct.configurationStruct.robustFitEnabled;
  
  load(fullfile(testDataDir,'transit-generator-model'));
  transitObject                             = transitGeneratorCollectionClass( transitModel, 1 );
  transitFitStruct.transitGeneratorObject   = transitObject;
  planetModel                               = get( transitObject, 'planetModel' );

  transitFitObject4  = transitFitClass( transitFitStruct, 12 );
  transitFitStruct2  = get( transitFitObject4, '*' );
  parameterMapStruct = transitFitStruct2.parameterMapStruct;
  oddEvenFlag        = get( transitFitStruct.transitGeneratorObject, 'oddEvenFlag' );
  
  fieldsOk =             isequal([parameterMapStruct.transitEpochBkjd],               [1  6]);
  fieldsOk = fieldsOk && isequal([parameterMapStruct.ratioPlanetRadiusToStarRadius],  [2  7]);
  fieldsOk = fieldsOk && isequal([parameterMapStruct.ratioSemiMajorAxisToStarRadius], [3  8]);
  fieldsOk = fieldsOk && isequal([parameterMapStruct.minImpactParameter],             [4  9]);
  fieldsOk = fieldsOk && isequal([parameterMapStruct.orbitalPeriodDays],              [5 10]);
  fieldsOk = fieldsOk && all(transitFitStruct2.fitType == 12);
  fieldsOk = fieldsOk && isequal( transitFitStruct2.initialParValues(:), repmat( [planetModel(1).transitEpochBkjd; ...
                                                                                  planetModel(1).ratioPlanetRadiusToStarRadius; ...
                                                                                  planetModel(1).ratioSemiMajorAxisToStarRadius; ...
                                                                                  planetModel(1).minImpactParameter; ...
                                                                                  planetModel(1).orbitalPeriodDays], 2, 1 ) );
  fieldsOk = fieldsOk && transitFitStruct2.oddEvenFlag == oddEvenFlag ;
  fieldsOk = fieldsOk && transitFitStruct2.debugLevel == transitFitStruct.debugLevel ;
  robustOk = ( strcmpi(transitFitStruct2.fitOptions.Robust,'on' ) &&  transitFitStruct.configurationStruct.robustFitEnabled ) || ...
             ( strcmpi(transitFitStruct2.fitOptions.Robust,'off') && ~transitFitStruct.configurationStruct.robustFitEnabled ) ;
  fieldsOk = fieldsOk && robustOk ;
  expectedDerivStep = [ ...
      transitFitStruct.configurationStruct.transitEpochStepSizeCadences * get(transitFitStruct.transitGeneratorObject,'cadenceDurationDays') / planetModel(1).transitEpochBkjd; ...
      transitFitStruct.configurationStruct.ratioPlanetRadiusToStarRadiusStepSize; ...
      transitFitStruct.configurationStruct.ratioSemiMajorAxisToStarRadiusStepSize; ...
      transitFitStruct.configurationStruct.minImpactParameterStepSize; ...
      transitFitStruct.configurationStruct.orbitalPeriodStepSizeDays / planetModel(1).orbitalPeriodDays ] ;
  fieldsOk = fieldsOk && isequal( transitFitStruct2.fitOptions.DerivStep(:), repmat(expectedDerivStep,2,1) ) ;
   
  mlunit_assert( fieldsOk, 'transitFitClass constructor instantiates incorrectly on test 4' ) ;
  
% Note that the constructor using format 4 should ignore the fitType argument  
  
  transitFitObject5 = transitFitClass( transitFitStruct2, 12 );
  mlunit_assert( isequal( transitFitObject4, transitFitObject5 ), 'transitFitClass constructor instantiates incorrectly on test 5' );
   
  transitFitObject6 = transitFitClass( transitFitStruct2, 14 );
  mlunit_assert( isequal( transitFitObject4, transitFitObject6 ), 'transitFitClass constructor instantiates incorrectly on test 6' );

%
% Part III
%
% Set the number of transits to 2, request fitType 12 on odd-even transits, and make sure that fitType 14 is what it actually instantiates with

  transitFitStruct.transitGeneratorObject       = transitObject;
  cadenceTimes                                  = get( transitFitStruct.transitGeneratorObject, 'cadenceTimes' );
  timeRange                                     = range(cadenceTimes);
  planetModel                                   = get( transitFitStruct.transitGeneratorObject, 'planetModel'  );
  planetModel(1).transitEpochBkjd               = cadenceTimes(1) + 0.25 * timeRange;
  planetModel(1).orbitalPeriodDays              =                   0.6  * timeRange;
  planetModel(2).transitEpochBkjd               = cadenceTimes(1) + 0.25 * timeRange;
  planetModel(2).orbitalPeriodDays              =                   0.6  * timeRange;
  transitFitStruct.transitGeneratorObject       = set( transitFitStruct.transitGeneratorObject, 'planetModel', planetModel );
  
  transitFitObject7 = transitFitClass( transitFitStruct, 12 ) ;
  fitType = get( transitFitObject7, 'fitType' ) ;
  assert_equals( fitType(:), [14; 14], 'transitFitClass constructor instantiates incorrectly on test 7' );
  
% Set the number of transits to 3, request fitType 12 on odd-even transits, and make sure that evens get fitType 14 but odds get fitType 12

  planetModel                                   = get( transitFitStruct.transitGeneratorObject, 'planetModel' );
  planetModel(1).transitEpochBkjd               = cadenceTimes(1) + 0.25 * timeRange;
  planetModel(1).orbitalPeriodDays              =                   0.3  * timeRange;
  planetModel(2).transitEpochBkjd               = cadenceTimes(1) + 0.25 * timeRange;
  planetModel(2).orbitalPeriodDays              =                   0.3  * timeRange;
  transitFitStruct.transitGeneratorObject       = set( transitFitStruct.transitGeneratorObject, 'planetModel', planetModel );

  transitFitObject8 = transitFitClass( transitFitStruct, 12 );
  fitType = get( transitFitObject8, 'fitType' ) ;
  assert_equals( fitType(:), [12; 14], 'transitFitClass constructor instantiates incorrectly on test 8' );
  
%
% Part IV
%
% exercise error statements:

  transitFitStruct.transitGeneratorObject = transitGeneratorObjectOld;

% invalid struct fields
  
  transitFitStructFail                          = transitFitStruct;
  transitFitStructFail.testField                = [];
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,12);', 'invalidStructFormat', transitFitStructFail, 'transitFitStruct' );
  
  transitFitStructFail                          = transitFitStruct; 
  transitFitStructFail                          = rmfield(transitFitStructFail, 'configurationStruct');
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,12);', 'invalidStructFormat', transitFitStructFail, 'transitFitStruct' );
  
  transitFitStructFail                          = transitFitStruct2;
  transitFitStructFail.testField                = [];
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,12);', 'invalidStructFormat', transitFitStructFail, 'transitFitStruct' );
  
  transitFitStructFail                          = transitFitStruct2 ;
  transitFitStructFail                          = rmfield(transitFitStructFail, 'fitType');
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,12);', 'invalidStructFormat', transitFitStructFail, 'transitFitStruct' );
  
% one transit and odd-even flag set to 0 (allTransitsFit)

  transitFitStructFail                          = transitFitStruct ;
  planetModel                                   =  get( transitFitStructFail.transitGeneratorObject, 'planetModel' ) ;
  planetModel(1).transitEpochBkjd               = cadenceTimes(1) + 0.5 * timeRange;
  planetModel(1).orbitalPeriodDays              =                   2   * timeRange;
  transitFitStructFail.transitGeneratorObject   = set( transitFitStructFail.transitGeneratorObject, 'planetModel', planetModel );
  
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,12);', 'insufficientTransitsToFit', transitFitStructFail, 'transitFitStruct' );

% zero transits and odd-even flag set to 1 (oddEvenTransitsFit)

  transitFitStructFail                          = transitFitStruct;
  transitFitStructFail.transitGeneratorObject   = transitObject;
  planetModel                                   = get( transitFitStructFail.transitGeneratorObject, 'planetModel' );
  planetModel(1).transitEpochBkjd               = cadenceTimes(1) + 1.5 * timeRange;
  planetModel(1).orbitalPeriodDays              =                   2   * timeRange;
  planetModel(2).transitEpochBkjd               = cadenceTimes(1) + 1.5 * timeRange;
  planetModel(2).orbitalPeriodDays              =                   2   * timeRange;
  transitFitStructFail.transitGeneratorObject   = set( transitFitStructFail.transitGeneratorObject, 'planetModel', planetModel );
  
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,12);', 'insufficientTransitsToFit', transitFitStructFail, 'transitFitStruct' );
  
% oddEvenFlag set to 1 (oddEvenTransitsFit), 4 transits present based on timing but all odd or all even are gapped out.

  planetModel                                   = get( transitFitStructFail.transitGeneratorObject, 'planetModel' );
  planetModel(1).transitEpochBkjd               = cadenceTimes(1) + 0.2  * timeRange;
  planetModel(1).orbitalPeriodDays              =                   0.25 * timeRange;
  planetModel(2).transitEpochBkjd               = cadenceTimes(1) + 0.2  * timeRange;
  planetModel(2).orbitalPeriodDays              =                   0.25 * timeRange;
  transitFitStructFail.transitGeneratorObject   = set( transitFitStructFail.transitGeneratorObject, 'planetModel', planetModel );
  
% only transits 1 and 3 present 
  
  nCadences = length( transitFitStructFail.whitenedFluxTimeSeries.gapIndicators );
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators( round(0.25*nCadences):round(0.5*nCadences) ) = true;
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators( round(0.75*nCadences):nCadences            ) = true;
  
  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,12);', 'insufficientTransitsToFit', transitFitStructFail, 'transitFitStruct' );

% only transits 2 and 4 present
  
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators( 1:end                                      ) = false;
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators( 1:round(0.25*nCadences)                    ) = true;
  transitFitStructFail.whitenedFluxTimeSeries.gapIndicators( round(0.5*nCadences):round(0.75*nCadences) ) = true;

  try_to_catch_error_condition( 'test=transitFitClass(transitFitStruct,12);', 'insufficientTransitsToFit', transitFitStructFail, 'transitFitStruct' );
    
  disp(' ');

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
