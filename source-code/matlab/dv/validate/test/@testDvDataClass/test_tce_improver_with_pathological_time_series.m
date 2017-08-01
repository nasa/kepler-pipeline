function self = test_tce_improver_with_pathological_time_series( self ) 

%      run(text_test_runner, testDvDataClass('test_tce_improver_with_pathological_time_series'));
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

  testDvDataClass_fitter_initialization ;
  
  cadenceTimes = dvDataStruct.barycentricCadenceTimes.midTimestamps ;
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
  noiseBaselineMad = mad(noiseBaseline, 1) ;
  fluxTimeSeries.uncertainties = 65e-6 * ones( size(fluxTimeSeries.values) ) ;
  
% construct a "unit transit" with a depth of 1, trapezoidal profile, and a duration of 11
% cadences

  triangularTransit = [-0.5 -1*ones(1,9) -0.5] ;
  triangularTransitCadenceOffset = -5:5 ;
  triangularTransitStruct.cadenceOffset = triangularTransitCadenceOffset(:) ;
  triangularTransitStruct.transitSize = triangularTransit(:) ;

  
%=========================================================================================

% construct a time series with 2:1 intervals between its eclipses and eclipses are deep

  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, [0.1 0 0.15 0.1 0 0.15] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

% call the TCE-improver

  improvedTce = improve_threshold_crossing_event( dvDataObject, dvResultsStruct, ...
      tceForEclipsingBinaryRemoval, 1, 1 ) ;
  
% the improved TCE should have a period which is around 3x the initial period estimate

  originalPeriod = tceForEclipsingBinaryRemoval.orbitalPeriod ;
  improvedPeriod = improvedTce.orbitalPeriod ;
  
  mlunit_assert( improvedPeriod > 3 * originalPeriod - 2 && ...
      improvedPeriod < 3 * originalPeriod + 2, ...
      'Improved TCE period in deep 2:1 test is not correct' ) ;

%=========================================================================================

% construct a time series with uniform intervals and deep eclipses, but uneven depths

  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, [0.1 0.05 0.15 0.1 0.05 0.15] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

% call the TCE-improver

  improvedTce = improve_threshold_crossing_event( dvDataObject, dvResultsStruct, ...
      tceForEclipsingBinaryRemoval, 1, 1 ) ;
  
% the improved TCE should have a period which is around the initial period estimate

  originalPeriod = tceForEclipsingBinaryRemoval.orbitalPeriod ;
  improvedPeriod = improvedTce.orbitalPeriod ;
  
  mlunit_assert( improvedPeriod > 1 * originalPeriod - 2 && ...
      improvedPeriod < 1 * originalPeriod + 2, ...
      'Improved TCE period in deep uniformly-spaced eclipse test is not correct' ) ;

%=========================================================================================

% construct a time series with 2:1 intervals between its eclipses and eclipses are shallow

  transitDepth = 10 * noiseBaselineMad ;
  [fluxTimeSeries.values, transitCadence] = construct_flux_value_array( noiseBaseline, ...
      transitMidCadence, triangularTransitStruct, ...
      transitDepth * [1 0 1 1 0 1] ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = fluxTimeSeries ;

% call the TCE-improver

  improvedTce = improve_threshold_crossing_event( dvDataObject, dvResultsStruct, ...
      tceForEclipsingBinaryRemoval, 1, 1 ) ;
  
% the improved TCE should have a period which is around the initial period estimate,
% because the small eclipse depths (wrt the nominal giant-transit identification
% threshold) causes the improver to not use its trick for detecting this kind of
% pathological time series

  originalPeriod = tceForEclipsingBinaryRemoval.orbitalPeriod ;
  improvedPeriod = improvedTce.orbitalPeriod ;
  
  mlunit_assert( improvedPeriod > originalPeriod - 2 && ...
      improvedPeriod < originalPeriod + 2, ...
      'Improved TCE period in shallow 2:1 test is not correct' ) ;

  disp(' ') ;
  
return  

  
  
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
  
  fluxValues = fluxValues - median(fluxValues) ;
  
return
  
