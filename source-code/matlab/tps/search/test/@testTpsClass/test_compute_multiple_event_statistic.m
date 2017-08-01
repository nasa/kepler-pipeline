function self = test_compute_multiple_event_statistic( self )
%
% test_compute_multiple_event_statistic -- unit test for tpsClass method 
%    compute_multiple_event_statistic
%
% This unit test exercises the following functionality of the method:
%
% 
%
% This test is intended to operate in the mlunit context.  For standalone execution, use
% the following syntax:
%
%      run(text_test_runner, testTpsClass('test_compute_multiple_event_statistic'));
%
% Version date:  2011-August-12.
%
%=========================================================================================
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

disp(' ... testing MES computation ... ') ;

% set the test data path and retrieve the tps-full struct for instantiation

tpsDataFile = 'tps-full-struct-for-instantiation' ;
tpsDataStructName = 'tpsInputStruct' ;
tps_testing_initialization ;

tpsInputStructOrig = tpsInputStruct;

% set the random number generator to the correct value

s = RandStream('mcg16807','Seed',10) ;
RandStream.setDefaultStream(s) ;
  
% generate an input to test the basic functionality of
% compute_multiple_event_statistic

tpsInputStruct.tpsModuleParameters.minTrialTransitPulseInHours = -1;
tpsInputStruct.tpsModuleParameters.maxTrialTransitPulseInHours = -1;
tpsInputStruct.tpsModuleParameters.requiredTrialTransitPulseInHours = [3 6 12];
tpsInputStruct.tpsModuleParameters.storeCdppFlag = true(3,1);
tpsInputStruct.tpsTargets.fluxValue = randn(4354,1) ;
tpsInputStruct.tpsTargets.fluxValue(1000:1024) = -1.0 ;
tpsInputStruct.tpsTargets.fluxValue(2000:2024) = -1.0 ;
tpsInputStruct.tpsTargets.fluxValue(3000:3024) = -1.0 ;
tpsInputStruct.tpsTargets.fluxValue(4000:4024) = -1.0 ;

% check dimensionality of output when we have multiple targets/pulses

tpsInputStruct.tpsTargets(2) = tpsInputStruct.tpsTargets ;

tpsInputStruct = validate_tps_input_structure(tpsInputStruct);

% generate the output

tpsObject = tpsClass( tpsInputStruct ) ;
[tpsObject, harmonicTimeSeries, fittedTrend] = perform_quarter_stitching(tpsObject) ;
[tpsResults, ~, extendedFlux] = ...
    compute_cdpp_time_series(tpsObject, harmonicTimeSeries, fittedTrend) ;

% force the first cdpp time series to be -1's to test alerts
tpsResults(1).cdppTimeSeries = -1 * ones(size(tpsResults(1).cdppTimeSeries)) ;
tpsResultsBeforeMES = tpsResults ;

[tpsResults, alerts] = compute_multiple_event_statistic( tpsObject, ...
    tpsResults, [], extendedFlux ) ;
  
% start interrogating the results.  First of all:  check the added fields

scalarFields = {'numValidCadences','dataSpanInCadences','foldingWallTimeHours'} ;
vectorFields = {'deemphasisWeight', 'deemphasisWeightSuperResolution'} ;
addedFields = [ scalarFields, vectorFields ] ;
fieldsPresent = isfield( tpsResults, addedFields ) ;
mlunit_assert( all( fieldsPresent ), ...
    'Not all fields correctly added to results struct!' ) ;

% check results dimensionality

mlunit_assert( length( tpsResults ) == 6, 'tpsResults has wrong length!' ) ;

% now just grab the 12 hour pulse for checking

tpsResults = tpsResults(6) ;

% check the dimensions and values of the vector fields as best we can

mlunit_assert( ...
    isvector( tpsResults.deemphasisWeight ) && ...
    isvector( tpsResults.deemphasisWeightSuperResolution ) && ...
    tpsInputStruct.tpsModuleParameters.superResolutionFactor ...
    * length( tpsResults.deemphasisWeight ) == ...
    length( tpsResults.deemphasisWeightSuperResolution ), ...
    'Deemphasis vectors dimensions not as expected!' ) ;

% check the values of the scalar fields

mlunit_assert( isequal( tpsResults.dataSpanInCadences, ...
   length(tpsResults.deemphasisWeight) ), 'dataSpanInCadences not as expected!' ) ;
mlunit_assert( (tpsResults.numValidCadences > 0) && ...
   (tpsResults.numValidCadences <= length(tpsResults.deemphasisWeight) ), ...
   'numValidCadences not as expected!' ) ;
mlunit_assert( (tpsResults.foldingWallTimeHours > 0) && ...
   (tpsResults.foldingWallTimeHours < 0.002) , ...
   'foldingWallTimeHours not as expected!' ) ;
   
% check the basic detection results to make sure folder worked

mes = tpsResults.maxMultipleEventStatistic ;
rs = tpsResults.robustStatistic ;

mlunit_assert( (mes > 7.1) && (mes < 10.0) , 'MES not as expected!') ;  % 9.2305
mlunit_assert( (rs > 6.4) && (rs < 10), 'RS not as expected!') ;  % 8.1954
%mlunit_assert( tpsResults.isPlanetACandidate, 'isPlanetACandidate not as expected!') ;
      
% finally the alerts

mlunit_assert( isequal(size(alerts), [1 1]), ...
  'Size of alerts struct not as expected!' ) ;
mlunit_assert( ~isempty( strfind(alerts.message,'time series not available') ) && ...
  ~isempty( strfind(alerts.message,'target 1 Kepler Id 12207111') ) && ...
  ~isempty( strfind(alerts.message,'trial transit pulse of 3 hours') ), ...
  'Alerts message not as expected!' ) ;

tpsStruct = struct(tpsObject) ;
tpsStruct.taskTimeoutSecs = 2 ;
tpsObject = tpsClass(tpsStruct) ;

% test to make sure that the system exits when the overall timeout is exceeded by
% individual folding and searching operations

[tpsResults] = compute_multiple_event_statistic( tpsObject, tpsResultsBeforeMES, [], ...
    extendedFlux ) ;

maxMultipleEventStatistic = [tpsResults.maxMultipleEventStatistic] ;

neg1Pointer = maxMultipleEventStatistic == -1 ;
assert_equals( neg1Pointer(:), [true ; true ; true ; true ; false ; true], ...
    'Exit on overall timeout does not result in expected MES vector!' ) ;

disp('') ;
  
return

