function self = test_fold_statistics_at_trial_phases( self )
% 
% test_fold_statistics_at_trial_phases -- unit test for fold_statistics_at_trial_phases
% TPS function
%
% This function tests the following functionality of the TPS function which performs
% folding at trial phases:
%
% ==> The basic functionality works correctly:  Given a TPS results struct and a matched
%     period in cadences,
%     --> The folding is performed on the superresolution time series
%     --> The returned vectors of MES values and phase lags are correctly determined
%     --> The containsNaNs variable is returned as false
% ==> In the presence of deemphasis flags which are not at the selected period, 
%     --> The returned phase lags are the same as before
%     --> The MES of the optimal phase lag is reduced
%     --> The optimal phase lag is the same as before.
% ==> In the presence of deemphasis flags which are at the selected period, 
%     --> the containsNaNs variable is set to true
%     --> The correct phase lag is set to have zero MES.
%
% This unit test is intended for use in the mlunit context.  For standalone execution, use
% the following syntax:
%
%      run(text_test_runner, testTpsClass('test_fold_statistics_at_trial_phases'));
%
% Version date:  2010-July-19.
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

% Modification date:
%
%=========================================================================================

  disp(' ... testing fold_statistics_at_trial_phases function ... ') ;

  correlationValue = 1e6 ;
  normalizationValue = 3.6e4 ;
  
% set the test data path and retrieve the tps-full struct for instantiation

  tpsDataFile = 'tps-full-struct-for-instantiation' ;
  tpsDataStructName = 'tpsInputStruct' ;
  tps_testing_initialization ;
  
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
  
% call the folder

  [multipleEventStatistics, phaseLagInCadences, containsNaNs] = ...
      fold_statistics_at_trial_phases( tpsResultsBeforeFold, 3000, tpsModuleParameters ) ;
  
% interrogate the outputs

  assert_equals( size( multipleEventStatistics ), [3000 1], ...
      'Size of multipleEventStatistic not as expected!' ) ;
  assert_equals( phaseLagInCadences, (0:2999)', ...
      'phaseLagInCadences vector not as expected!' ) ;
  [maxValue, maxIndex] = max( multipleEventStatistics ) ;
  assert_equals( maxIndex, 1500, ...
      'Location of max MES not as expected!' ) ;
  mlunit_assert( abs( maxValue - 2*correlationValue/normalizationValue ) < 1e-6, ...
      'Value of max MES not as expected!' ) ;
  mlunit_assert( ~containsNaNs, ...
      'containsNaNs not as expected!' ) ;
  
% add deemphasis flags on the first transit location

  tpsResultsBeforeFold.deemphasisWeightSuperResolution(1400:1600) = 0 ;
  [multipleEventStatistics, phaseLagInCadences, containsNaNs] = ...
      fold_statistics_at_trial_phases( tpsResultsBeforeFold, 3000, tpsModuleParameters ) ;
  
% interrogate outputs 

  assert_equals( size( multipleEventStatistics ), [3000 1], ...
      'Size of multipleEventStatistic not as expected in deemphasis test 1!' ) ;
  assert_equals( phaseLagInCadences, (0:2999)', ...
      'phaseLagInCadences vector not as expected in deemphasis test 1!' ) ;
  [maxValue, maxIndex] = max( multipleEventStatistics ) ;
  assert_equals( maxIndex, 1500, ...
      'Location of max MES not as expected in deemphasis test 1!' ) ;
  mlunit_assert( abs( maxValue - sqrt(3)*correlationValue/normalizationValue ) < 1e-6, ...
      'Value of max MES not as expected in deemphasis test 1!' ) ;
  mlunit_assert( ~containsNaNs, ...
      'containsNaNs not as expected in deemphasis test 1!' ) ;
  
% now set the normalization time series so it will add to be zero over zero to get
% NaN's out

  tpsResultsBeforeFold.normalizationTimeSeriesHiRes(1000:1010) = 0 ;  
  tpsResultsBeforeFold.normalizationTimeSeriesHiRes(4000:4010) = 0 ;  
  tpsResultsBeforeFold.normalizationTimeSeriesHiRes(7000:7010) = 0 ;  
  tpsResultsBeforeFold.normalizationTimeSeriesHiRes(10000:10010) = 0 ;  
  tpsResultsBeforeFold.normalizationTimeSeriesHiRes(13000:13010) = 0 ;
  tpsResultsBeforeFold.correlationTimeSeriesHiRes(1000:1010) = -1 ;  
  tpsResultsBeforeFold.correlationTimeSeriesHiRes(4000:4010) = -1 ;  
  tpsResultsBeforeFold.correlationTimeSeriesHiRes(7000:7010) = 0 ;  
  tpsResultsBeforeFold.correlationTimeSeriesHiRes(10000:10010) = 1 ;  
  tpsResultsBeforeFold.correlationTimeSeriesHiRes(13000:13010) = 1 ;
  lastwarn('') ;
  [multipleEventStatistics, phaseLagInCadences, containsNaNs] = ...
      fold_statistics_at_trial_phases( tpsResultsBeforeFold, 3000, tpsModuleParameters ) ;
  assert_equals( size( multipleEventStatistics ), [3000 1], ...
      'Size of multipleEventStatistic not as expected in deemphasis test 2!' ) ;
  assert_equals( phaseLagInCadences, (0:2999)', ...
      'phaseLagInCadences vector not as expected in deemphasis test 2!' ) ;
  [maxValue, maxIndex] = max( multipleEventStatistics ) ;
  assert_equals( maxIndex, 1500, ...
      'Location of max MES not as expected in deemphasis test 2!' ) ;
  mlunit_assert( abs( maxValue - sqrt(3)*correlationValue/normalizationValue ) < 1e-6, ...
      'Value of max MES not as expected in deemphasis test 2!' ) ;
  mlunit_assert( containsNaNs, ...
      'containsNaNs not as expected in deemphasis test 2!' ) ;
  assert_equals( multipleEventStatistics(1000:1010), zeros(11,1), ...
      'Zero MES values not as expected in deemphasis test 2!' ) ;  
  
% now set some deemphasis weights to force the MES to be zero

  tpsResultsBeforeFold.deemphasisWeightSuperResolution(1000:1010) = 0 ;  
  tpsResultsBeforeFold.deemphasisWeightSuperResolution(4000:4010) = 0 ;  
  tpsResultsBeforeFold.deemphasisWeightSuperResolution(7000:7010) = 0 ;  
  tpsResultsBeforeFold.deemphasisWeightSuperResolution(10000:10010) = 0 ;  
  tpsResultsBeforeFold.deemphasisWeightSuperResolution(13000:13010) = 0 ;
  lastwarn('') ;
  [multipleEventStatistics, phaseLagInCadences, containsNaNs] = ...
      fold_statistics_at_trial_phases( tpsResultsBeforeFold, 3000, tpsModuleParameters ) ;
  assert_equals( size( multipleEventStatistics ), [3000 1], ...
      'Size of multipleEventStatistic not as expected in deemphasis test 2!' ) ;
  assert_equals( phaseLagInCadences, (0:2999)', ...
      'phaseLagInCadences vector not as expected in deemphasis test 2!' ) ;
  [maxValue, maxIndex] = max( multipleEventStatistics ) ;
  assert_equals( maxIndex, 1500, ...
      'Location of max MES not as expected in deemphasis test 2!' ) ;
  mlunit_assert( abs( maxValue - sqrt(3)*correlationValue/normalizationValue ) < 1e-6, ...
      'Value of max MES not as expected in deemphasis test 2!' ) ;
  assert_equals( multipleEventStatistics(1000:1010), zeros(11,1), ...
      'Zero MES values not as expected in deemphasis test 2!' ) ;
  
  disp('') ;
  
return