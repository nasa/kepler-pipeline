function self = test_fill_fit_results_with_gapped_eclipses( self )
%
% test_fill_fit_results_with_gapped_eclipses -- unit test for dvDataClass method
% fill_fit_results_with_gapped_eclipses
%
% This unit test exercises the following functionality of the dvDataClass method
%    fill_fit_results_with_gapped_eclipses:
%
% ==> Correctly fills the all-transits, odd-transits, and even-transits results structs
%     with the desired parameters and the correct values
% ==> Correctly sets the planetCandidate flag suspectedEclipsingBinary
% ==> Correctly handles transits which were gapped before the process began
% ==> Correctly handles the case in which there are no transits (all gapped, for example).
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_fill_fit_results_with_gapped_eclipses'));
%
% Version date:  2010-May-09.
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
%    2010-May-09, PT:
%        support for change from MJD to BKJD.
%
%=========================================================================================

  disp('... testing eclipsing-binary fit-result filler method ... ')
  
  testDvDataClass_fitter_initialization ;
  
  cadenceTimes = dvDataStruct.barycentricCadenceTimes.midTimestamps ;
  
% construct a TCE which has the time signature we want -- a period of about 10 days
% (actually 480 cadences) with an epoch which is about cadence 300 (plus conversion from
% BKJD back to MJD)

  tceForEclipsingBinaryRemoval = tceForWhitenerTest ;
  tceForEclipsingBinaryRemoval.epochMjd = cadenceTimes(300) + ...
      kjd_offset_from_mjd ;
  tceForEclipsingBinaryRemoval.orbitalPeriod = cadenceTimes(481) - cadenceTimes(1) ;
  
% construct a gappedTransitStruct for use in the method.  Note that the
% gappedTransitStruct doesn't need to be complete, since the only pieces of it which are
% used are the gap indicators, the transit durations, and the transit depths

  gappedTransitStructTemplate = struct( 'transitDepth', 0.16, ...
      'transitDurationCadences', 10, 'gapIndicator', false ) ;
  
  configMapObject        = configMapClass( dvDataStruct.configMaps ) ;
  cadenceDurationSeconds = get_long_cadence_period( configMapObject, ...
      tceForEclipsingBinaryRemoval.epochMjd ) ;
  cadenceDurationHours   = cadenceDurationSeconds * get_unit_conversion( 'sec2hour' ) ;  
  
% construct odd- and even-transit structs with different durations and depths

  gappedTransitStructEven = gappedTransitStructTemplate ;
  gappedTransitStructEven.transitDepth = 0.14 ;
  gappedTransitStructEven.transitDurationCadences = 8 ;
  
  gappedTransitStructOdd = gappedTransitStructTemplate ;
  
  gappedTransitStruct = [gappedTransitStructOdd ; gappedTransitStructEven ; ...
      gappedTransitStructOdd ; gappedTransitStructEven ; gappedTransitStructOdd ; ...
      gappedTransitStructEven] ;

  epsDouble = eps('double') ;
  
% test 1:  submit the transit struct as-is and see whether the correct values are
% populated in the results struct

  dvResultsStruct = fill_fit_results_with_gapped_eclipses( dvDataObject, ...
      dvResultsStructBeforeFit, 1, 1, tceForEclipsingBinaryRemoval, gappedTransitStruct ) ;
  
  allTransitsFit = ...
      dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1).allTransitsFit ;
  oddTransitsFit = ...
      dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1).oddTransitsFit ;
  evenTransitsFit = ...
      dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1).evenTransitsFit ;
  planetCandidate = ...
      dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1).planetCandidate ;
      
  preFitTransitsFit = ...
      dvResultsStructBeforeFit.targetResultsStruct(1).planetResultsStruct(1).allTransitsFit ;
  
  mlunit_assert( planetCandidate.suspectedEclipsingBinary, ...
      'suspectedEclipsingBinary flag not set' ) ;
  assert_equals( rmfield( allTransitsFit, 'modelParameters' ), ...
      rmfield( preFitTransitsFit, 'modelParameters' ), ...
      'allTransitsFit struct does not match pre-fit results struct' ) ;
  assert_equals( rmfield( oddTransitsFit, 'modelParameters' ), ...
      rmfield( preFitTransitsFit, 'modelParameters' ), ...
      'oddTransitsFit struct does not match pre-fit results struct' ) ;
  assert_equals( rmfield( evenTransitsFit, 'modelParameters' ), ...
      rmfield( preFitTransitsFit, 'modelParameters' ), ...
      'evenTransitsFit struct does not match pre-fit results struct' ) ;

  expectedParameters = { 'transitEpochBkjd', 'transitDurationHours', 'transitDepthPpm', ...
      'orbitalPeriodDays' } ;
  assert_equals( {allTransitsFit.modelParameters.name}, ...
      expectedParameters, ...
      'allTransitsFit model parameter names not as expected' ) ;
  assert_equals( {oddTransitsFit.modelParameters.name}, ...
      expectedParameters, ...
      'oddTransitsFit model parameter names not as expected' ) ;
  assert_equals( {evenTransitsFit.modelParameters.name}, ...
      expectedParameters, ...
      'evenTransitsFit model parameter names not as expected' ) ;
  
  mlunit_assert( all( [allTransitsFit.modelParameters.value] - ...
      [tceForEclipsingBinaryRemoval.epochMjd - kjd_offset_from_mjd ...
       9 * cadenceDurationHours ...
       0.15 * 1e6 ...
       tceForEclipsingBinaryRemoval.orbitalPeriod] < ...
       repmat(epsDouble,1,4) .* [allTransitsFit.modelParameters.value] ), ...
       'allTransitsFit model parameter values not as expected' ) ;
  assert_equals( [oddTransitsFit.modelParameters.value], ...
      [tceForEclipsingBinaryRemoval.epochMjd - kjd_offset_from_mjd ...
       10 * cadenceDurationHours ...
       0.16 * 1e6 ...
       tceForEclipsingBinaryRemoval.orbitalPeriod], ...
       'oddTransitsFit model parameter values not as expected' ) ;
  assert_equals( [evenTransitsFit.modelParameters.value], ...
      [tceForEclipsingBinaryRemoval.epochMjd + ...
      tceForEclipsingBinaryRemoval.orbitalPeriod - kjd_offset_from_mjd ...
       8 * cadenceDurationHours ...
       0.14 * 1e6 ...
       tceForEclipsingBinaryRemoval.orbitalPeriod], ...
       'evenTransitsFit model parameter values not as expected' ) ;
   
  assert_equals( [allTransitsFit.modelParameters.uncertainty], [0 0 0 0], ...
      'allTransitsFit model parameter uncertainties not as expected' ) ;
  assert_equals( [oddTransitsFit.modelParameters.uncertainty], [0 0 0 0], ...
      'oddTransitsFit model parameter uncertainties not as expected' ) ;
  assert_equals( [evenTransitsFit.modelParameters.uncertainty], [0 0 0 0], ...
      'evenTransitsFit model parameter uncertainties not as expected' ) ;
 
  assert_equals( [allTransitsFit.modelParameters.fitted], [false false false false], ...
      'allTransitsFit model parameter fit flags not as expected' ) ;
  assert_equals( [oddTransitsFit.modelParameters.fitted], [false false false false], ...
      'aoddTransitsFit model parameter fit flags not as expected' ) ;
  assert_equals( [evenTransitsFit.modelParameters.fitted], [false false false false], ...
      'evenTransitsFit model parameter fit flags not as expected' ) ;

% test 2:  change the values in the first 2 transits, and gap them; the resulting structs
% should come out exactly the same as they are now

  gappedTransitStruct(1).transitDepth = 0 ;
  gappedTransitStruct(1).transitDurationCadences = 1 ;
  gappedTransitStruct(1).gapIndicator = true ;
  
  gappedTransitStruct(2) = gappedTransitStruct(1) ;
  
  dvResultsStruct2 = fill_fit_results_with_gapped_eclipses( dvDataObject, ...
      dvResultsStructBeforeFit, 1, 1, tceForEclipsingBinaryRemoval, gappedTransitStruct ) ;

  allTransitsFit2 = ...
      dvResultsStruct2.targetResultsStruct(1).planetResultsStruct(1).allTransitsFit ;
  oddTransitsFit2 = ...
      dvResultsStruct2.targetResultsStruct(1).planetResultsStruct(1).oddTransitsFit ;
  evenTransitsFit2 = ...
      dvResultsStruct2.targetResultsStruct(1).planetResultsStruct(1).evenTransitsFit ;
  
  assert_equals( allTransitsFit, allTransitsFit2, ...
      'allTransitsFit struct with gapped transits not as expected' ) ;
  assert_equals( oddTransitsFit, oddTransitsFit2, ...
      'oddTransitsFit struct with gapped transits not as expected' ) ;
  assert_equals( evenTransitsFit, evenTransitsFit2, ...
      'evenTransitsFit struct with gapped transits not as expected' ) ;
  
% test 3: gap all the transits and see that the correct values are set

  gappedTransitStruct(3).gapIndicator = true ;
  gappedTransitStruct(4).gapIndicator = true ;
  gappedTransitStruct(5).gapIndicator = true ;
  gappedTransitStruct(6).gapIndicator = true ;
  
  dvResultsStruct3 = fill_fit_results_with_gapped_eclipses( dvDataObject, ...
      dvResultsStructBeforeFit, 1, 1, tceForEclipsingBinaryRemoval, gappedTransitStruct ) ;

  allTransitsFit3 = ...
      dvResultsStruct3.targetResultsStruct(1).planetResultsStruct(1).allTransitsFit ;
  oddTransitsFit3 = ...
      dvResultsStruct3.targetResultsStruct(1).planetResultsStruct(1).oddTransitsFit ;
  evenTransitsFit3 = ...
      dvResultsStruct3.targetResultsStruct(1).planetResultsStruct(1).evenTransitsFit ;
  
  assert_equals( [allTransitsFit3.modelParameters.value], ...
      [tceForEclipsingBinaryRemoval.epochMjd - kjd_offset_from_mjd ...
       0 ...
       0 ...
       tceForEclipsingBinaryRemoval.orbitalPeriod], ...
      'allTransitsFit struct with all-gapped transits parameter values not as expected' ) ;
  assert_equals( [oddTransitsFit3.modelParameters.value], ...
      [tceForEclipsingBinaryRemoval.epochMjd - kjd_offset_from_mjd ...
       0 ...
       0 ...
       tceForEclipsingBinaryRemoval.orbitalPeriod], ...
      'oddTransitsFit struct with all-gapped transits parameter values not as expected' ) ;
  assert_equals( [evenTransitsFit3.modelParameters.value], ...
      [tceForEclipsingBinaryRemoval.epochMjd + ...
      tceForEclipsingBinaryRemoval.orbitalPeriod - kjd_offset_from_mjd ...
       0 ...
       0 ...
       tceForEclipsingBinaryRemoval.orbitalPeriod], ...
      'evenTransitsFit struct with all-gapped transits parameter values not as expected' ) ;
   
  disp(' ') ;
  
return

% and that's it!

%
%
%
