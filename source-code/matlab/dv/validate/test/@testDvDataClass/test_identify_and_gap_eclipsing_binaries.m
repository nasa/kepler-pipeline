function self = test_identify_and_gap_eclipsing_binaries( self )
%
% test_identify_and_gap_eclipsing_binaries -- unit test for dvDataClass method
% identify_and_gap_eclipsing_binaries
%
% This unit test exercises the following functionality of this method:
%
% ==> Under the correct conditions, an EB signature is detected and gapped
%     ==> All transits are too deep, or a combination of gapped and too deep
%         ==> or just all-odd or all-even transits meet these conditions
%     ==> All transits are too wide, or a combination of gapped and too wide
%         ==> or just all-odd or all-even transits meet these conditions
% ==> The EB signatures are not gapped when:
%     ==> All transits are either too wide or too deep, but they are not all one or the
%         other
%     ==> Some transits are too wide
%     ==> Some transits are too deep
%     ==> Transits are wide but not deep enough
%     ==> some transits do not line up with giant transits
%     ==> there are no giant transits detected in the flux time series
%     ==> eclipse removal parameters are changed to make the giant transits not trip the
%         thresholds
% ==> When there are several families of giant transits, only the ones which are connected
%     to the TCE are gapped, the others are not.
% ==> giant transits which have a transit cadence at the first or last cadence of the
%     time series work correctly.
% ==> time series in which the first or last transit overlaps the start or end of the time
%     series work correctly.
% ==> Time series in which the odd transits are all too small and the even transits are
%     all fully gapped (or vice-versa) are not flagged as EBs.
% ==> Time series in which all of the odd transits are fully gapped, 1 even transit meets
%     the EB criteria, and the remaining even transits have a gap are flagged, even if the
%     even transits are gapped such that the ungapped cadences do not meet the criteria
%     (and vice-versa).
% ==> Time series in which all of the odd transits are fully gapped, all of the even
%     transits contain gaps, and none of the transits actually meet the criteria for EB
%     (due to being gapped at their deepest points) are not flagged as EBs.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_identify_and_gap_eclipsing_binaries'));
%
% Version date:  2010-May-10.
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
%    2010-May-10, PT:
%        update to support change from MJD to BKJD as time standard for fit.
%    2009-December-18, PT:
%        add tests for various irritating combinations of small transits, fully-gapped
%        transits, gapped transits which meet the test criteria, gapped transits which
%        don't meet the test criteria, etc.
%
%=========================================================================================

  disp('... testing eclipsing-binary removal method ... ')
  
  testDvDataClass_fitter_initialization ;
  
  cadenceTimes = dvDataStruct.barycentricCadenceTimes.midTimestamps + ...
      kjd_offset_from_mjd ;
  fluxTimeSeries = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries ;

% set the parameters which control the identification and gapping process

  dvDataStruct.planetFitConfigurationStruct.eclipsingBinaryDepthLimitPpm = 150000 ;
  dvDataStruct.planetFitConfigurationStruct.eclipsingBinaryAspectRatioLimitCadences = ...
      10000 ;
  dvDataStruct.planetFitConfigurationStruct.eclipsingBinaryAspectRatioDepthLimitPpm = ...
      5000 ;
  dvDataObject = dvDataClass( dvDataStruct ) ;
  
% construct a TCE which has the time signature we want -- a period of about 10 days
% (actually 480 cadences) with an epoch which is about cadence 300

  tceForEclipsingBinaryRemoval = tceForWhitenerTest ;
  tceForEclipsingBinaryRemoval.epochMjd = cadenceTimes(300) ;
  tceForEclipsingBinaryRemoval.orbitalPeriod = cadenceTimes(481) - cadenceTimes(1) ;
  
  transitMidCadence = 300:480:length(cadenceTimes) ;
  mjdMidCadence = cadenceTimes(transitMidCadence) ;
  nTransits = length(transitMidCadence) ;
  
% construct a baseline flux time series which has no transit signatures in it but just
% Gaussian noise at the 65 PPM level

  noiseBaseline = 65e-6 * randn( size( fluxTimeSeries.values ) ) ;
  fluxTimeSeries.gapIndicators = false( size( fluxTimeSeries.values ) ) ;
  fluxTimeSeries.filledIndices = [] ;
  
% construct a "unit transit" with a depth of 1, triangular profile, and a duration of 11
% cadences

  triangularTransit = [linspace(0,-1,6) linspace(-0.8,0,5)] ;
  triangularTransitCadenceOffset = -5:5 ;
  triangularTransitStruct.cadenceOffset = triangularTransitCadenceOffset(:) ;
  triangularTransitStruct.transitSize = triangularTransit(:) ;
  
% construct a "unit transit" with a depth of 1, square profile, and duration of 101 units

  squareTransit = -1 * ones(101,1) ;
  squareTransitCadenceOffset = -50:50 ;
  squareTransitStruct.cadenceOffset = squareTransitCadenceOffset(:) ;
  squareTransitStruct.transitSize = squareTransit(:) ;
  
%=========================================================================================
%  
% D E T E C T   A N D   G A P   D E E P   T R A N S I TS
%
%=========================================================================================

% put a deep transit at each transit location -- in this case, we'll go for a transit
% which has a depth of 16%, since the detection threshold is 15%

  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, 0.16 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
          
% locate and gap the eclipses  
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  
% success is defined as the removedEclipsingBinary flag is set, the cadences with the
% giant transits are all gapped, and the vast majority of the remaining cadences are not
% gapped (the exact number is somewhat fuzzy since it depends on the details of where the
% giant-transit detector puts the boundary between the transit and the baseline of the
% flux time series), plus the gappedTransitStruct has the correct values

  mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on deep-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on deep-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence), ...
      'Too many cadences gapped on deep-eclipse test' ) ;
  structOk = length(gappedTransitStruct) == length(transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startCadence] < transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.endCadence] > transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startMjd] < mjdMidCadence') ;
  structOk = structOk && all([gappedTransitStruct.endMjd] > mjdMidCadence') ;
  structOk = structOk && all(~[gappedTransitStruct.gapIndicator]) ;
  structOk = structOk && all([gappedTransitStruct.transitDepth] > 0.15) ;
  mlunit_assert( structOk, ...
      'gappedTransitStruct is incorrectly formed on deep-eclipse test' ) ;
  
% now gap one cadence in one transit and all the cadences in another transit, and see that
% the removal still works correctly

  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;  
  gapIndicators = fluxTimeSeries.gapIndicators ;
  fluxValues    = fluxTimeSeries.values ;
  gapIndicators( transitMidCadence(1) ) = true ;
  gapIndicators( transitMidCadence(2) + triangularTransitStruct.cadenceOffset(:) ) = true ;
  fluxValues( gapIndicators ) = 0 ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators = ...
      gapIndicators ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.values = ...
      fluxValues ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  gappedTransits = [gappedTransitStruct.gapIndicator] ;
  transitDepths  = [gappedTransitStruct.transitDepth] ;
  
  mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on deep+gapped-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on deep+gapped-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence), ...
      'Too many cadences gapped on deep+gapped-eclipse test' ) ;
  structOk = length(gappedTransitStruct) == length(transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startCadence] < transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.endCadence] > transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startMjd] < mjdMidCadence') ;
  structOk = structOk && all([gappedTransitStruct.endMjd] > mjdMidCadence') ;
  structOk = structOk && all(gappedTransits == [1 1 0 0 0 0]) ;
  structOk = structOk && all(transitDepths(~gappedTransits) > 0.15) ;
  structOk = structOk && all(transitDepths(gappedTransits) < 0.15) ;
  mlunit_assert( structOk, ...
      'gappedTransitStruct is incorrectly formed on deep+gapped-eclipse test' ) ;
  
% Now test to see whether all the transits are removed if only the odd or the only the
% even ones pass the depth test:

% start with odd-transits being deep, even ones shallow

  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, 0.16 * [1 ; 0.5 ; 1 ; 0.5 ; 1 ; 0.5] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  gappedTransits = [gappedTransitStruct.gapIndicator] ;
  transitDepths  = [gappedTransitStruct.transitDepth] ;
  
  mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on deep-shallow-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on deep-shallow-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence), ...
      'Too many cadences gapped on deep-shallow-eclipse test' ) ;
  structOk = length(gappedTransitStruct) == length(transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startCadence] < transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.endCadence] > transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startMjd] < mjdMidCadence') ;
  structOk = structOk && all([gappedTransitStruct.endMjd] > mjdMidCadence') ;
  structOk = structOk && all(~gappedTransits) ;
  structOk = structOk && all(transitDepths(1:2:end) > 0.15) ;
  structOk = structOk && all(transitDepths(2:2:end) < 0.15) ;
  mlunit_assert( structOk, ...
      'gappedTransitStruct is incorrectly formed on deep-shallow-eclipse test' ) ;
  
% now do odd-transits shallow, even ones deep  
  
  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, 0.16 * [0.5 ; 1 ; 0.5 ; 1 ; 0.5 ; 1] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  gappedTransits = [gappedTransitStruct.gapIndicator] ;
  transitDepths  = [gappedTransitStruct.transitDepth] ;
  
  mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on shallow-deep-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on deep-shallow-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence), ...
      'Too many cadences gapped on shallow-deep-eclipse test' ) ;
  structOk = length(gappedTransitStruct) == length(transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startCadence] < transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.endCadence] > transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startMjd] < mjdMidCadence') ;
  structOk = structOk && all([gappedTransitStruct.endMjd] > mjdMidCadence') ;
  structOk = structOk && all(~gappedTransits) ;
  structOk = structOk && all(transitDepths(2:2:end) > 0.15) ;
  structOk = structOk && all(transitDepths(1:2:end) < 0.15) ;
  mlunit_assert( structOk, ...
      'gappedTransitStruct is incorrectly formed on shallow-deep-eclipse test' ) ;
  
%=========================================================================================
%  
% D E T E C T   A N D   G A P   W I D E   T R A N S I TS
%
%=========================================================================================

% here we will use the square pulse with a depth of 0.9%, since the threshold is width /
% depth = 10,000 cadences and the square is 101 cadences in duration

  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, squareTransitStruct, 0.009 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
          
% locate and gap the eclipses  
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  
% success is defined as the removedEclipsingBinary flag is set, the cadences with the
% giant transits are all gapped, and the vast majority of the remaining cadences are not
% gapped (the exact number is somewhat fuzzy since it depends on the details of where the
% giant-transit detector puts the boundary between the transit and the baseline of the
% flux time series)

  mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on wide-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on wide-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence), ...
      'Too many cadences gapped on wide-eclipse test' ) ;
  structOk = length(gappedTransitStruct) == length(transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startCadence] < transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.endCadence] > transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startMjd] < mjdMidCadence') ;
  structOk = structOk && all([gappedTransitStruct.endMjd] > mjdMidCadence') ;
  structOk = structOk && all(~[gappedTransitStruct.gapIndicator]) ;
  structOk = structOk && all([gappedTransitStruct.aspectRatioCadences] > 10000) ;
  mlunit_assert( structOk, ...
      'gappedTransitStruct is incorrectly formed on wide-eclipse test' ) ;
  
% now gap one cadence in one transit and all the cadences in another transit, and see that
% the removal still works correctly

  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;  
  gapIndicators = fluxTimeSeries.gapIndicators ;
  fluxValues    = fluxTimeSeries.values ;
  gapIndicators( transitMidCadence(1) ) = true ;
  gapIndicators( transitMidCadence(2) + squareTransitCadenceOffset(:) ) = true ;
  fluxValues( gapIndicators ) = 0 ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators = ...
      gapIndicators ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.values = ...
      fluxValues ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  gappedTransits = [gappedTransitStruct.gapIndicator] ;
  aspectRatios  = [gappedTransitStruct.aspectRatioCadences] ;
  
  mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on wide+gapped-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on wide+gapped-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence), ...
      'Too many cadences gapped on wide+gapped-eclipse test' ) ;
  structOk = length(gappedTransitStruct) == length(transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startCadence] < transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.endCadence] > transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startMjd] < mjdMidCadence') ;
  structOk = structOk && all([gappedTransitStruct.endMjd] > mjdMidCadence') ;
  structOk = structOk && all(gappedTransits == [1 1 0 0 0 0]) ;
  structOk = structOk && all(aspectRatios(~gappedTransits) > 10000) ;
  mlunit_assert( structOk, ...
      'gappedTransitStruct is incorrectly formed on wide+gapped-eclipse test' ) ;
  
% now look at time series in which only the odd-numbered transits match the aspect ratio
% test, or only the even-numbered ones.  Start with odd-numbered:

  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, squareTransitStruct, ...
      [0.009 ; 0.011 ; 0.009 ; 0.011 ; 0.009 ; 0.011] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
          
% locate and gap the eclipses  
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  gappedTransits = [gappedTransitStruct.gapIndicator] ;
  aspectRatios  = [gappedTransitStruct.aspectRatioCadences] ;

  mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on wide-narrow-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on wide-narrow-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence), ...
      'Too many cadences gapped on wide-narrow-eclipse test' ) ;
  structOk = length(gappedTransitStruct) == length(transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startCadence] < transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.endCadence] > transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startMjd] < mjdMidCadence') ;
  structOk = structOk && all([gappedTransitStruct.endMjd] > mjdMidCadence') ;
  structOk = structOk && all(~gappedTransits) ;
  structOk = structOk && all(aspectRatios(1:2:end) > 10000) ;
  structOk = structOk && all(aspectRatios(2:2:end) < 10000) ;
  mlunit_assert( structOk, ...
      'gappedTransitStruct is incorrectly formed on wide-narrow-eclipse test' ) ;
  
% now do the evens
  
  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, squareTransitStruct, ...
      [0.011 ; 0.009 ; 0.011 ; 0.009 ; 0.011 ; 0.009] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
          
% locate and gap the eclipses  
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  gappedTransits = [gappedTransitStruct.gapIndicator] ;
  aspectRatios  = [gappedTransitStruct.aspectRatioCadences] ;

  mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on narrow-wide-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on narrow-wide-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence), ...
      'Too many cadences gapped on narrow-wide-eclipse test' ) ;
  structOk = length(gappedTransitStruct) == length(transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startCadence] < transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.endCadence] > transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startMjd] < mjdMidCadence') ;
  structOk = structOk && all([gappedTransitStruct.endMjd] > mjdMidCadence') ;
  structOk = structOk && all(~gappedTransits) ;
  structOk = structOk && all(aspectRatios(1:2:end) < 10000) ;
  structOk = structOk && all(aspectRatios(2:2:end) > 10000) ;
  mlunit_assert( structOk, ...
      'gappedTransitStruct is incorrectly formed on narrow-wide-eclipse test' ) ;

%=========================================================================================
%  
% N O   G A P P I N G   C A S E S
%
%=========================================================================================

% Cases in which we do not expect the detector to detect and gap EB signatures:

% First:  mixture of too-deep and too-wide

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, ...
      [squareTransitStruct ; squareTransitStruct ; squareTransitStruct ; ...
       triangularTransitStruct ; triangularTransitStruct ; triangularTransitStruct], ...
      [0.009 ; 0.009 ; 0.009 ; 0.16 ; 0.16 ; 0.16] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

  [dvResultsStruct, removedEclipsingBinary, giantTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  
  mlunit_assert( ~removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag set on mixed-type test' ) ;
  mlunit_assert( isempty(find(gapIndicators, 1)), ...
      'Eclipsing binary tool gaps cadences on mixed-type test' ) ;
  mlunit_assert( isempty(giantTransitStruct), ...
      'giantTransitStruct is not empty in mixed-type test' ) ;
  
% Second:  some transits are too deep, others are not

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, ...
      [0.14 ; 0.14 ; 0.14 ; 0.16 ; 0.16 ; 0.16] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

  [dvResultsStruct, removedEclipsingBinary, giantTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  
  mlunit_assert( ~removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag set on partial-too-deep test' ) ;
  mlunit_assert( isempty(find(gapIndicators, 1)), ...
      'Eclipsing binary tool gaps cadences on partial-too-deep test' ) ;
  mlunit_assert( isempty(giantTransitStruct), ...
      'giantTransitStruct is not empty in partial-too-deep test' ) ;
  
% third:  some transits are too wide, others are not
  
  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, squareTransitStruct, ...
      [0.009 ; 0.009 ; 0.009 ; 0.011 ; 0.011 ; 0.011] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

  [dvResultsStruct, removedEclipsingBinary, giantTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  
  mlunit_assert( ~removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag set on partial-too-wide test' ) ;
  mlunit_assert( isempty(find(gapIndicators, 1)), ...
      'Eclipsing binary tool gaps cadences on partial-too-wide test' ) ;
  mlunit_assert( isempty(giantTransitStruct), ...
      'giantTransitStruct is not empty in partial-too-wide test' ) ;
  
% fourth:  transits are wide enough but not deep enough

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, squareTransitStruct, ...
      [0.003 ; 0.003 ; 0.003 ; 0.003 ; 0.003 ; 0.003] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

  [dvResultsStruct, removedEclipsingBinary, giantTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  
  mlunit_assert( ~removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag set on too-wide-not-deep-enough test' ) ;
  mlunit_assert( isempty(find(gapIndicators, 1)), ...
      'Eclipsing binary tool gaps cadences on too-wide-not-deep-enough test' ) ;
  mlunit_assert( isempty(giantTransitStruct), ...
      'giantTransitStruct is not empty in too-wide-not-deep-enough test' ) ;

% fifth:  not all of the transits in the TCE line up with transits in the flux time
% series; in particular, there's no giant transit at the 6th transit location

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence(1:5), squareTransitStruct, 0.16 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

  [dvResultsStruct, removedEclipsingBinary, giantTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;

  mlunit_assert( ~removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag set on missing-transit test' ) ;
  mlunit_assert( isempty(find(gapIndicators, 1)), ...
      'Eclipsing binary tool gaps cadences on missing-transit test' ) ;
  mlunit_assert( isempty(giantTransitStruct), ...
      'giantTransitStruct is not empty in missing-transit test' ) ;

% sixth:  no giant transits at all (technically a special case of the one above) 

  fluxTimeSeries.values = noiseBaseline ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

  [dvResultsStruct, removedEclipsingBinary, giantTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  
  mlunit_assert( ~removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag set on no-transits test' ) ;
  mlunit_assert( isempty(find(gapIndicators, 1)), ...
      'Eclipsing binary tool gaps cadences on no-transits test' ) ;
  mlunit_assert( isempty(giantTransitStruct), ...
      'giantTransitStruct is not empty in no-transits test' ) ;
  
% seventh:  deep transits but depth parameter readjusted

  dvDataStruct.planetFitConfigurationStruct.eclipsingBinaryDepthLimitPpm = 2000000 ;
  dvDataObject = dvDataClass( dvDataStruct ) ;

  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, 0.16 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  
  mlunit_assert( ~removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag set on adjusted-depth-threshold test' ) ;
  mlunit_assert( isempty(find(gapIndicators, 1)), ...
      'Eclipsing binary tool gaps cadences on adjusted-depth-threshold test' ) ;
  mlunit_assert( isempty(giantTransitStruct), ...
      'giantTransitStruct is not empty in adjusted-depth-threshold test' ) ;

% eighth:  wide transits but parameters adjusted 

  dvDataStruct.planetFitConfigurationStruct.eclipsingBinaryDepthLimitPpm = 150000 ;
  dvDataStruct.planetFitConfigurationStruct.eclipsingBinaryAspectRatioLimitCadences = 2000000 ;
  dvDataObject = dvDataClass( dvDataStruct ) ;

  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, squareTransitStruct, 0.009 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
          
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;

  mlunit_assert( ~removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag set on adjusted-width-threshold test' ) ;
  mlunit_assert( isempty(find(gapIndicators, 1)), ...
      'Eclipsing binary tool gaps cadences on adjusted-width-threshold test' ) ;
  mlunit_assert( isempty(giantTransitStruct), ...
      'giantTransitStruct is not empty in adjusted-width-threshold test' ) ;
  
  dvDataStruct.planetFitConfigurationStruct.eclipsingBinaryAspectRatioLimitCadences = 10000 ;
  dvDataStruct.planetFitConfigurationStruct.eclipsingBinaryAspectRatioDepthLimitPpm = 2000000 ;
  
  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, squareTransitStruct, 0.009 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
          
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;

  mlunit_assert( ~removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag set on wide-eclipse-adjusted-depth-threshold test' ) ;
  mlunit_assert( isempty(find(gapIndicators, 1)), ...
      'Eclipsing binary tool gaps cadences on wide-eclipse-adjusted-depth-threshold test' ) ;
  mlunit_assert( isempty(giantTransitStruct), ...
      'giantTransitStruct is not empty in wide-eclipse-adjusted-depth-threshold test' ) ;
  
  dvDataStruct.planetFitConfigurationStruct.eclipsingBinaryAspectRatioDepthLimitPpm = 5000 ;
  dvDataObject = dvDataClass( dvDataStruct ) ;
  
%=========================================================================================
%  
% M I X E D   T I M E   S E R I E S
%
%=========================================================================================

% if there are giant transits which belong with the TCE and others which do not, only the
% ones which go with the TCE should be gapped.

  transitMidCadenceExtra = 540:480:length(cadenceTimes) ;
  transitMidCadenceAll = sort([transitMidCadence transitMidCadenceExtra]) ;
  
  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadenceAll, triangularTransitStruct, 0.16 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
% locate and gap the eclipses  
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;
  fluxValues = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.values ;
  
  mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on deep-eclipse-extra test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence), ...
      'Too many cadences gapped on deep-eclipse-extra test' ) ;
  mlunit_assert( min( fluxValues( ~gapIndicators ) ) < -0.15, ...
      'Can''t locate extra eclipses on deep-eclipse-extra test' ) ;
  structOk = length(gappedTransitStruct) == length(transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startCadence] < transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.endCadence] > transitMidCadence) ;
  structOk = structOk && all([gappedTransitStruct.startMjd] < mjdMidCadence') ;
  structOk = structOk && all([gappedTransitStruct.endMjd] > mjdMidCadence') ;
  structOk = structOk && all(~[gappedTransitStruct.gapIndicator]) ;
  structOk = structOk && all([gappedTransitStruct.transitDepth] > 0.15) ;
  mlunit_assert( structOk, ...
      'gappedTransitStruct is incorrectly formed on deep-eclipse-extra test' ) ; 
  
%=========================================================================================
%
% T R A N S I T   O V E R L A P S   F I R S T   O R   L A S T   C A D E N C E
%
%=========================================================================================

% change the eclipse timing so that the first eclipse starts on cadence 1

  tceForEclipsingBinaryRemoval.epochMjd = cadenceTimes(6) ;
  
  transitMidCadence = 6:480:length(cadenceTimes) ;

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, 0.16 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
% locate and gap the eclipses -- there's no actual assertion required here, we just need
% to see that the buffer code does not attempt to write past the upstream end of the array
  
  [dvResultsStruct, removedEclipsingBinary] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;

% now do the same test at the end

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, 0.16 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
% locate and gap the eclipses -- there's no actual assertion required here, we just need
% to see that the buffer code does not attempt to write past the upstream end of the array
  
  [dvResultsStruct, removedEclipsingBinary] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;

%=========================================================================================
%
% T R A N S I T   P A S S E S   E N D   O F   T I M E   S E R I E S
%
%=========================================================================================

% adjust the timing so that the first transit has an epoch of cadence # -3

  tceForEclipsingBinaryRemoval = tceForWhitenerTest ;
  tceForEclipsingBinaryRemoval.epochMjd = cadenceTimes(477) ;
  tceForEclipsingBinaryRemoval.orbitalPeriod = cadenceTimes(481) - cadenceTimes(1) ;
  
  transitMidCadence = 477:480:length(cadenceTimes) ;

% put a deep transit at each transit location -- in this case, we'll go for a transit
% which has a depth of 16%, since the detection threshold is 15%.  Also put giant transits
% at the start and end of the time series

  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, 0.16 ) ;
  fluxTimeSeries.values(1) = -0.16 * 0.6 ;
  fluxTimeSeries.values(2) = -0.16 * 0.4 ;
  fluxTimeSeries.values(3) = -0.16 * 0.2 ;
  fluxTimeSeries.values(end-2) = -0.16 * 0.2 ;
  fluxTimeSeries.values(end-1) = -0.16 * 0.4 ;
  fluxTimeSeries.values(end)   = -0.16 * 0.6 ;
  
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
          
% locate and gap the eclipses  
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;

% the first 3 cadences should be gapped, as well as the ones which are in the properly
% identified transits

   mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on early-overlap-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on early-overlap-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence) + 3, ...
      'Too many cadences gapped on early-overlap-eclipse test' ) ;
  mlunit_assert( all( gapIndicators(1:3) ) , ...
      'First 3 cadences not gapped on early-overlap-eclipse test' ) ;
  mlunit_assert( all( ~gapIndicators(end-2:end) ) , ...
      'Last 3 cadences gapped on early-overlap-eclipse test' ) ;
  
% now we do the same thing but at the late end of the time series  

  transitMidCadence = sort([length(cadenceTimes)-477:-480:0]) ;
  tceForEclipsingBinaryRemoval.epochMjd = cadenceTimes(transitMidCadence(1)) ;
  
  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, 0.16 ) ;
  fluxTimeSeries.values(1) = -0.16 * 0.6 ;
  fluxTimeSeries.values(2) = -0.16 * 0.4 ;
  fluxTimeSeries.values(3) = -0.16 * 0.2 ;
  fluxTimeSeries.values(end-2) = -0.16 * 0.2 ;
  fluxTimeSeries.values(end-1) = -0.16 * 0.4 ;
  fluxTimeSeries.values(end)   = -0.16 * 0.6 ;
  
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
          
% locate and gap the eclipses  
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;

   mlunit_assert( removedEclipsingBinary, ...
      'Eclipsing binary signature removal flag not set on late-overlap-eclipse test' ) ;
  mlunit_assert( all( ismember( transitCadence(:), find( gapIndicators ) ) ), ...
      'Not all EB cadences gapped on late-overlap-eclipse test' ) ;
  mlunit_assert( length(find(gapIndicators)) - length(transitCadence(:)) <= ...
      6 * length(transitMidCadence) + 3, ...
      'Too many cadences gapped on late-overlap-eclipse test' ) ;
  mlunit_assert( all( ~gapIndicators(1:3) ) , ...
      'First 3 cadences gapped on late-overlap-eclipse test' ) ;
  mlunit_assert( all( gapIndicators(end-2:end) ) , ...
      'Last 3 cadences not gapped on late-overlap-eclipse test' ) ;

%=========================================================================================
%
% T R A N S I T S   W I T H   G A P S
%
%=========================================================================================

% Generate a series of triangular transits in which the odd transits are too small and the
% even ones are entirely gapped

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, ...
      [0.08 ; 0.16 ; 0.08 ; 0.16 ; 0.08 ; 0.16] ) ;
  fluxTimeSeries.gapIndicators = false( size( fluxTimeSeries.gapIndicators ) ) ;
  for iTransit = 2:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;

  mlunit_assert( ~removedEclipsingBinary, ...
      'EB removed for small-odd and all-gapped even transit case!' ) ;
  assert_equals( gapIndicators, fluxTimeSeries.gapIndicators, ...
      'Gap indicators changed in small-odd, all-gapped-even transit case!' ) ;
  
% do the same test but exchange odd and even transits

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, ...
      [0.16 ; 0.08 ; 0.16 ; 0.08 ; 0.16 ; 0.08] ) ;
  fluxTimeSeries.gapIndicators = false( size( fluxTimeSeries.gapIndicators ) ) ;
  for iTransit = 1:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;

  mlunit_assert( ~removedEclipsingBinary, ...
      'EB removed for all-gapped-odd and small-even transit case!' ) ;
  assert_equals( gapIndicators, fluxTimeSeries.gapIndicators, ...
      'Gap indicators changed in all-gapped-odd, small-even transit case!' ) ;

% Just for completeness, test the case in which all the transits are fully gapped 

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, ...
      [0.16 ; 0.18 ; 0.16 ; 0.18 ; 0.16 ; 0.18] ) ;
  fluxTimeSeries.gapIndicators = false( size( fluxTimeSeries.gapIndicators ) ) ;
  for iTransit = 1:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  gapIndicators = dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators ;

  mlunit_assert( ~removedEclipsingBinary, ...
      'EB removed for all-gapped-all transit case!' ) ;
  assert_equals( gapIndicators, fluxTimeSeries.gapIndicators, ...
      'Gap indicators changed in all-gapped-all transit case!' ) ;

% Test case in which the odd cadences are all too small, even cadences are all gapped, but
% 1 of them is in fact large enough to trigger the EB detector

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, ...
      [0.08 ; 0.16 ; 0.08 ; 0.16 ; 0.08 ; 0.16] ) ;
  fluxTimeSeries.gapIndicators = false( size( fluxTimeSeries.gapIndicators ) ) ;
  for iTransit = 4:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  fluxTimeSeries.gapIndicators( transitMidCadence(2) + ...
      triangularTransitStruct.cadenceOffset(1) ) = true ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  mlunit_assert( removedEclipsingBinary, ...
      'EB not removed for all-small-odd, 1-not-ungapped-even transit case!' ) ;
  
% same test case except that the odd transits are also gapped

  for iTransit = 1:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  mlunit_assert( removedEclipsingBinary, ...
      'EB not removed for all-gapped-odd, 1-not-ungapped-even transit case!' ) ;

% same 2 test cases as above but with odd and even exchanged

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, ...
      [0.16 ; 0.08 ; 0.16 ; 0.08 ; 0.16 ; 0.16] ) ;
  fluxTimeSeries.gapIndicators = false( size( fluxTimeSeries.gapIndicators ) ) ;
  for iTransit = 3:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  fluxTimeSeries.gapIndicators( transitMidCadence(1) + ...
      triangularTransitStruct.cadenceOffset(1) ) = true ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  mlunit_assert( removedEclipsingBinary, ...
      'EB not removed for 1-not-ungapped-odd, all-small-even transit case!' ) ;
  
  for iTransit = 2:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  mlunit_assert( removedEclipsingBinary, ...
      'EB not removed for 1-not-ungapped-odd, all-small-even transit case!' ) ;

% Go back to all the odd transits are small, and the 1 ungapped even transit has its
% deepest point gapped; this should not be flagged as EB

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, ...
      [0.08 ; 0.16 ; 0.08 ; 0.16 ; 0.08 ; 0.16] ) ;
  fluxTimeSeries.gapIndicators = false( size( fluxTimeSeries.gapIndicators ) ) ;
  for iTransit = 4:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  fluxTimeSeries.gapIndicators( transitMidCadence(2) + ...
      triangularTransitStruct.cadenceOffset(6) ) = true ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  mlunit_assert( ~removedEclipsingBinary, ...
      'EB removed for all-small-odd, 1-ungapped-even-gapped-at-minimum transit case!' ) ;

% same case as above except that the odd transits are fully gapped  

  for iTransit = 1:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  mlunit_assert( ~removedEclipsingBinary, ...
      'EB removed for all-gapped-odd, 1-ungapped-even-gapped-at-minimum transit case!' ) ;
  
% same 2 cases as above but with odd and even exchanged

  [fluxTimeSeries.values] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, ...
      [0.16 ; 0.08 ; 0.16 ; 0.08 ; 0.16 ; 0.08] ) ;
  fluxTimeSeries.gapIndicators = false( size( fluxTimeSeries.gapIndicators ) ) ;
  for iTransit = 3:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  fluxTimeSeries.gapIndicators( transitMidCadence(1) + ...
      triangularTransitStruct.cadenceOffset(6) ) = true ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  mlunit_assert( ~removedEclipsingBinary, ...
      'EB removed for 1-ungapped-odd-gapped-at-minimum, all-small-even transit case!' ) ;

  for iTransit = 2:2:nTransits
      fluxTimeSeries.gapIndicators( transitMidCadence(iTransit) + ...
          triangularTransitStruct.cadenceOffset(:) ) = true ;
  end
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;
  
  [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = ...
      identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, 1, ...
      tceForEclipsingBinaryRemoval ) ;
  mlunit_assert( ~removedEclipsingBinary, ...
      'EB removed for 1-ungapped-odd-gapped-at-minimum, all-gapped-even transit case!' ) ;
  
  disp(' ')
  
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which returns a flux value array which contains a noise baseline and a set
% of user-defined transits at user-defined locations

function [fluxValues, transitCadences] = construct_flux_value_array( noiseBaseline, ...
    transitMidTimeCadences, transitStruct, transitScale )

% start with the noise baseline

  fluxValues = noiseBaseline ;
  nTransits = length(transitMidTimeCadences) ;
  if ( length(transitStruct) == 1 )
      transitStruct = repmat( transitStruct, nTransits, 1 ) ;
  end
  if ( length(transitScale) == 1 )
      transitScale = repmat( transitScale, nTransits, 1 ) ;
  end
  
% loop over the transits and construct the offset-and-scaled transit for each location,
% and add them to the flux time series value array

  transitCadences = [] ;

  for iTransit = 1:length(transitMidTimeCadences)
      transitTimeCadences = transitMidTimeCadences(iTransit) + ...
          transitStruct(iTransit).cadenceOffset ;
      transitSize = transitScale(iTransit) * ...
          transitStruct(iTransit).transitSize ;
      fluxValues( transitTimeCadences ) = fluxValues( transitTimeCadences ) + ...
          transitSize ;
      transitCadences = [transitCadences ; transitTimeCadences(:)] ;
  end
  
  transitCadences = sort( unique( transitCadences ) ) ;
  
return
  
