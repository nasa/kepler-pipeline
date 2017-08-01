function self = test_fold_statistics_at_trial_periods( self )
%
% test_fold_statistics_at_trial_periods -- unit test for TPS function
% fold_statistics_at_trial_periods
%
% This unit test exercises the following functionality of the function:
%
% ==> The folding is performed on the super-resolution time series, not on the normal
%     resolution time series
% ==> The folding is performed correctly whether the user supplies the optional periods
%     vector or not
% ==> The returned periods vector is correct
% ==> The returned folded statistics and lags are correct
% ==> A max period which is less than the min period is correctly handled
% ==> Deemphasis of super-resolution cadences is correctly handled
%
% This unit test is intended for use in the mlunit context.  For standalone execution, use
% the following syntax:
%
%      run(text_test_runner, testTpsClass('test_fold_statistics_at_trial_periods'));
%
% Version date:  2010-June-18.
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

  disp(' ... testing fold_statistics_at_trial_periods function ... ') ;

  correlationValue = 1e6 ;
  normalizationValue = 3.6e4 ;
  
% set the test data path and retrieve the tps-full struct for instantiation
  
  tpsDataFile = 'tps-full-struct-for-instantiation' ;
  tpsDataStructName = 'tpsInputStruct' ;
  tps_testing_initialization ;
  load( fullfile( testDataPath, 'tps-full-results-before-folding' ) ) ;
  
% set the random number generator to the correct value

  s = RandStream('mcg16807','Seed',10) ;
  RandStream.setDefaultStream(s) ;
  
% generate a valid results struct and extended flux
 
  nCadences = length(tpsInputStruct.tpsTargets.fluxValue) ;
  tpsInputStruct.tpsModuleParameters.requiredTrialTransitPulseInHours = 3 ;
  tpsInputStruct.tpsModuleParameters.storeCdppFlag = true ;
  tpsInputStruct.tpsModuleParameters.minTrialTransitPulseInHours = -1 ;
  tpsInputStruct.tpsModuleParameters.maxTrialTransitPulseInHours = -1 ;
  tpsInputStruct = validate_tps_input_structure(tpsInputStruct) ;
  tpsModuleParameters = tpsInputStruct.tpsModuleParameters ;
  tpsInputStruct.tpsTargets.fluxValue = randn(nCadences,1) ;
  tpsScienceObject = tpsClass(tpsInputStruct) ;
  [tpsScienceObject, harmonicTimeSeriesAll, fittedTrendAll] = ...
      perform_quarter_stitching( tpsScienceObject ) ;
  [tpsResultsBeforeFold, ~, extendedFlux, ~] = compute_cdpp_time_series(...
      tpsScienceObject, harmonicTimeSeriesAll, fittedTrendAll) ;
  
% add deemphasis parameters/weights

  deemphasisParameter = ones(nCadences,1) ;
  discontinuityIndices = [] ;

  [deemphasisParameterSuperResolution, deemphasisParameter] = ...
      collect_cadences_to_deemphasize( deemphasisParameter, ...
      tpsModuleParameters.superResolutionFactor, ...
      [], discontinuityIndices, ...
      tpsModuleParameters.deemphasizePeriodAfterTweakInCadences) ;

% convert from deemphasis parameter to cadence weight, and store same  

  deemphasisWeightSuperResolution = ...
      convert_deemphasis_parameter_to_weight( deemphasisParameterSuperResolution ) ;
  deemphasisWeight = ...
      convert_deemphasis_parameter_to_weight( deemphasisParameter ) ;
  tpsResultsBeforeFold.deemphasisWeightSuperResolution = deemphasisWeightSuperResolution ;
  tpsResultsBeforeFold.deemphasisWeight = deemphasisWeight ;
  
%  prep the corr and norm

  tpsResultsBeforeFold.correlationTimeSeriesHiRes = randn( size( ...
      tpsResultsBeforeFold.correlationTimeSeriesHiRes ) ) ;
  tpsResultsBeforeFold.normalizationTimeSeriesHiRes = normalizationValue * ones( size( ...
      tpsResultsBeforeFold.normalizationTimeSeriesHiRes ) ) ;

% add some big spikes to the superresolution time series

  spikeLocations = [1500 4500 7500 10500] ;
  tpsResultsBeforeFold.correlationTimeSeriesHiRes(spikeLocations) = correlationValue ;
  tpsResultsBeforeFold.normalizationTimeSeriesHiRes(spikeLocations) = normalizationValue ;
  
  troughLocations = [2100 5100 8100 11100] ;
  tpsResultsBeforeFold.correlationTimeSeriesHiRes(troughLocations) = -correlationValue ;
  tpsResultsBeforeFold.normalizationTimeSeriesHiRes(troughLocations) = normalizationValue ;

% First, turn off the maxFoldingsInPeriodSearch and test the output

  tpsModuleParameters.maxFoldingsInPeriodSearch = -1;
  tpsModuleParameters.maxDutyCycle = 1;
  [maxStatistic, phaseLagMax, possiblePeriods, minStatistic, phaseLagMin] = ...
      fold_statistics_at_trial_periods( tpsResultsBeforeFold, tpsModuleParameters ) ;
    
  assert_equals( possiblePeriods, possiblePeriodsExpectedValuesWithNoMaxFolds, ...
      'Possible periods vector not as expected!' ) ;
  tpsModuleParameters.maxFoldingsInPeriodSearch = 10;
  
% Now call the folder without a possible periods argument with the
% maxFoldings turned back on

  [maxStatistic, phaseLagMax, possiblePeriods, minStatistic, phaseLagMin] = ...
      fold_statistics_at_trial_periods( tpsResultsBeforeFold, tpsModuleParameters ) ;
  
% check that the returned possible periods vector matches the expected one
% Note that this also checks that the maxFoldingsInPeriodSearch is working
% when it is turned on

  assert_equals( possiblePeriods, possiblePeriodsExpectedValues, ...
      'Possible periods vector not as expected!' ) ;
  
% check that all other returned vectors have the correct shape compared to the possible
% periods vector

  mlunit_assert( isequal( size(maxStatistic), size(possiblePeriods) ) && ...
      isequal( size(phaseLagMax), size(possiblePeriods) ) && ...
      isequal( size(minStatistic), size(possiblePeriods) ) && ...
      isequal( size(phaseLagMin), size(possiblePeriods) ), ...
      'Return vector sizes not as expected' ) ;
  
% The max statistic should be at a period of 3000 cadences and a lag of 1499

  [maxValue, maxIndex] = max( maxStatistic ) ;
  mlunit_assert( abs( maxValue - 2*correlationValue/normalizationValue ) < 1e-4, ...
      'Max MES value not as expected!' )  ;
  assert_equals( round( possiblePeriods(maxIndex) ), 3000, ...
      'Period at max MES value not as expected!' ) ;
  assert_equals( phaseLagMax(maxIndex), 1499, ...
      'Phase lag at max MES value not as expected!' ) ;
  
% the min statistic should be at a period of 6000 cadences and a lag of 2099

  [minValue, minIndex] = min( minStatistic ) ;
  mlunit_assert( abs( minValue + 2 * correlationValue/normalizationValue ) < 1e-6, ...
      'Min MES value not as expected!' ) ;
  assert_equals( round( possiblePeriods(minIndex) ), 3000, ...
      'Period at min MES value not as expected!' ) ;
  assert_equals( phaseLagMin( minIndex ), 2099, ...
      'Phase lag at min MES value not as expected!' ) ;
  
% Call the function with a possible periods argument, the results should be the same

  [maxStatistic2, phaseLagMax2, possiblePeriods2, minStatistic2, phaseLagMin2] = ...
      fold_statistics_at_trial_periods( tpsResultsBeforeFold, tpsModuleParameters, ...
      possiblePeriodsExpectedValues ) ;
  
  assert_equals( maxStatistic, maxStatistic2, ...
      'maxStatistic does not agree between with- and without-periods cases!' ) ;
  assert_equals( phaseLagMax, phaseLagMax2, ...
      'phaseLagMax does not agree between with- and without-periods cases!' ) ;
  assert_equals( possiblePeriods, possiblePeriods2, ...
      'possiblePeriods does not agree between with- and without-periods cases!' ) ;
  assert_equals( minStatistic, minStatistic2, ...
      'minStatistic does not agree between with- and without-periods cases!' ) ;
  assert_equals( phaseLagMin, phaseLagMin2, ...
      'phaseLagMin does not agree between with- and without-periods cases!' ) ;
  
% lop off the first of the possible periods and make sure that the results change in the
% expected ways:

  possiblePeriods3 = possiblePeriods(2:end) ;
  [maxStatistic3, phaseLagMax3, possiblePeriods4, minStatistic3, phaseLagMin3] = ...
      fold_statistics_at_trial_periods( tpsResultsBeforeFold, tpsModuleParameters, ...
      possiblePeriods3 ) ;
  
  assert_equals( maxStatistic3, maxStatistic(2:end), ...
      'maxStatistic not as expected when possible periods vector is modified!' ) ;
  assert_equals( phaseLagMax3, phaseLagMax(2:end), ...
      'phaseLagMax not as expected when possible periods vector is modified!' ) ;
  assert_equals( minStatistic3, minStatistic(2:end), ...
      'minStatistic not as expected when possible periods vector is modified!' ) ;
  assert_equals( phaseLagMin3, phaseLagMin(2:end), ...
      'phaseLagMin3 not as expected when possible periods vector is modified!' ) ;
  assert_equals( possiblePeriods4, possiblePeriods3, ...
      'Returned possiblePeriods not as expected when possible periods vector is modified!' ) ;
  
% deempasize the first transit by setting the deemphasis flags

  tpsResultsBeforeFold.deemphasisWeightSuperResolution(1400:1600) = 0 ;

  [maxStatistic4, phaseLagMax4, possiblePeriods5, minStatistic4, phaseLagMin4] = ...
      fold_statistics_at_trial_periods( tpsResultsBeforeFold, tpsModuleParameters, ...
      possiblePeriodsExpectedValues ) ;
  
% the statistics and lags should not exactly equal the ones from the run without any
% deempahsis

  assert_not_equals( maxStatistic4, maxStatistic, ...
      'maxStatistic not as expected for deemphasis test!' ) ;
  assert_not_equals( phaseLagMax4, phaseLagMax, ...
      'phaseLagMax not as expected for deemphasis test!' ) ;
  assert_not_equals( minStatistic4, minStatistic, ...
      'minStatistic not as expected for deemphasis test!' ) ;
  assert_not_equals( phaseLagMin4, phaseLagMin, ...
      'phaseLagMin not as expected for deemphasis test!' ) ;
  
% the possible periods vector should be identical

  assert_equals( possiblePeriods5, possiblePeriodsExpectedValues, ...
      'possiblePeriods not as expected for deemphasis test!' ) ;
  
% the minimum value, its location in the periods vector, and the phase lag of the minimum
% should be the same as the nominal case

  [minValue2, minIndex2] = min( minStatistic4 ) ;
  assert_equals( minValue2, minValue, ...
      'minStatistic minimum value not as expected for deemphasis test!' ) ;
  assert_equals( minIndex2, minIndex, ...
      'minStatistic minimum value location in array not as expected for deemphasis test!' ) ;
  assert_equals( phaseLagMin4(minIndex2), phaseLagMin(minIndex2), ...
      'phase lag of min MES not as expected for deemphasis test!' ) ;
  
% the maximum value should have the same period and lag as the nominal case

  [maxValue2, maxIndex2] = max( maxStatistic4 ) ;
  assert_equals( maxIndex2, maxIndex, ...
      'maxStatistic minimum value location in array not as expected for deemphasis test!' ) ;
  assert_equals( phaseLagMax4(maxIndex2), phaseLagMax(maxIndex2), ...
      'phase lag of max MES not as expected for deemphasis test!' ) ;
  
% However, the value of the max MES should be smaller than in the case without any
% deemphasis by a factor of sqrt(2)

  mlunit_assert( abs( maxValue2 * 2/sqrt(3) - maxValue ) < 1e-6, ...
      'max MES reduction in deemphasis case not as expected!' ) ;
 
% If the min period is set to less than the max period, then the folder should issue a
% warning and set max == min

  tpsModuleParameters.maximumSearchPeriodInDays = 0.5 ;
  lastwarn('') ;
  errorString = ...
      'fold_statistics_at_trial_periods( tpsResultsBeforeFold, tpsModuleParameters )' ;
  try_to_catch_error_condition( errorString, 'noFoldingPossible', 'caller' ) ;
  
%   assert_equals( possiblePeriods6, possiblePeriods5(1), ...
%       'possiblePeriods not as expected for minPeriod > maxPeriod test!' ) ;
%   assert_equals( maxStatistic5, maxStatistic4(1), ...
%       'maxStatistic not as expected for minPeriod > maxPeriod test!' ) ;
%   assert_equals( phaseLagMax5, phaseLagMax4(1), ...
%       'phaseLagMax not as expected for minPeriod > maxPeriod test!' ) ;  
%   assert_equals( minStatistic5, minStatistic4(1), ...
%       'minStatistic not as expected for minPeriod > maxPeriod test!' ) ;
%   assert_equals( phaseLagMin5, phaseLagMin4(1), ...
%       'phaseLagMin not as expected for minPeriod > maxPeriod test!' ) ;  
%   [lastWarnMsg, lastWarnId] = lastwarn ;
%   assert_equals( lastWarnId, 'TPS:foldStatisticsAtTrialPeriods', ...
%       'Incorrect warning produced for minPeriod > maxPeriod test!' ) ;
  
% If maxDutyCycle is set, then make sure the possible periods vector is 
% smaller
  tpsModuleParameters = tpsInputStruct.tpsModuleParameters ;
  tpsModuleParameters.maxFoldingsInPeriodSearch = -1;
  tpsModuleParameters.maxDutyCycle = 0.025;
  [~, ~, possiblePeriods7, ~, ~] = ...
      fold_statistics_at_trial_periods( tpsResultsBeforeFold, tpsModuleParameters ) ;
  mlunit_assert( length(possiblePeriods7) < length(possiblePeriodsExpectedValuesWithNoMaxFolds), ...
      'possiblePeriods not as expected when maxDutyCycle is set!' ) ;
  
  disp('') ;
return