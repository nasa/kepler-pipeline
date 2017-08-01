function self = test_get_number_of_transits_in_time_series( self )
%
% test_get_number_of_transits_in_time_series -- unit test for the transitGeneratorClass
% method get_number_of_transits_in_time_series
%
% The unit test of the get_number_of_transits_in_time_series exercises the following
% features of the method:
%
% ==> The method works correctly using all legal signatures (ie, with and without a
%     cadence times argument, with and without gap / fill arguments)
% ==> The method works correctly with non-continuous time series arguments
% ==> When an entire transit is gapped, the number of actual transits is reduced, the
%     number of expected transits is not, and the transit information struct has correct
%     values
% ==> When the epoch lies outside the time range of the transit object, the correct
%     transitInformationStruct is still produced (the epoch is adjusted in the calculation
%     to find a correct epoch within the range of the transit object).
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorClass('test_get_number_of_transits_in_time_series'));
%
% Version date:  2010-May-08.
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
%    2010-May-08, PT:
%        handle tiny round-off error in transit information structs.
%    2010-January-05, PT:
%        test case in which epoch lies outside time range of object.
%
%=========================================================================================

  disp('... testing get-number-of-transits method ... ')
  
  testTransitGeneratorClass_initialization ;
  
% run the method on the transitGeneratorClass object with no additional arguments

  [numExpectedTransits, numActualTransits, transitInformationStruct] = ...
      get_number_of_transits_in_time_series( transitObject ) ;
  
% make sure that the values are correct -- in this context it means that the number of
% expected and actual transits are both 1, that the length of the transit information
% structure is equal to the number of expected transits, that the center of the transit in
% the transit information struct is the epoch of the object, and that the duration of the
% transit as reported in the information struct matches the duration in the object

  transitDurationDays = get( transitObject, 'transitDurationHours' ) * ...
      get_unit_conversion('hour2day') ;
  valuesOk = numExpectedTransits == 1 ;
  valuesOk = valuesOk && numActualTransits == 1 ;
  valuesOk = valuesOk && length(transitInformationStruct) == numExpectedTransits ;
  valuesOk = valuesOk && get( transitObject, 'transitEpochBkjd' ) == ...
      mean( [transitInformationStruct.bkjdTransitStart ...
             transitInformationStruct.bkjdTransitEnd] ) ;
  valuesOk = valuesOk && abs( transitInformationStruct.bkjdTransitEnd - ...
      transitInformationStruct.bkjdTransitStart - transitDurationDays ) ...
      < 1e-10 * transitDurationDays ;
  valuesOk = valuesOk && ~transitInformationStruct.gapIndicator ;
  
  mlunit_assert( valuesOk, ...
      'Method call with 1 argument produces incorrect values' ) ;

% perform the test with the transit epoch shifted by 1 period (365 days) so that it is
% outside the range of the transit object (which is only about 70 days long); make sure
% that the correct result is produced.

  oldPlanetModel = get( transitObject, 'planetModel' ) ;
  planetModel = oldPlanetModel ;
  planetModel.transitEpochBkjd = planetModel.transitEpochBkjd + ...
      planetModel.orbitalPeriodDays ;
  transitObject = set( transitObject, 'planetModel', planetModel ) ;

  [numExpectedTransitsOffset, numActualTransitsOffset, transitInformationStructOffset] = ...
      get_number_of_transits_in_time_series( transitObject ) ;

  assert_equals( numExpectedTransits, numExpectedTransitsOffset, ...
      'Offsetting epoch by 1 period changed # of transits expected!' ) ;
  assert_equals( numActualTransits, numActualTransitsOffset, ...
      'Offsetting epoch by 1 period changed # of transits detected!' ) ;
%  assert_equals( transitInformationStruct, transitInformationStructOffset, ...
%      'Offsetting epoch by 1 period changed transit information struct!' ) ;
  mlunit_assert( transitInformationStruct.gapIndicator == ...
      transitInformationStructOffset.gapIndicator && ...
      abs( transitInformationStruct.bkjdTransitStart - ...
      transitInformationStructOffset.bkjdTransitStart ) < 1e-12 && ...
      abs( transitInformationStruct.bkjdTransitEnd - ...
      transitInformationStructOffset.bkjdTransitEnd ) < 1e-12,  ...
      'Offsetting epoch by 1 period changed transit information struct!' ) ;
  
  transitObject = set( transitObject, 'planetModel', oldPlanetModel ) ;
  
% test various combinations of gapped and filled cadence information:  first some
% combinations which will not result in changes to the output even though they gap some
% (but not all!) of the cadences which are in transit

  [numExpected2, numActual2, informationStruct2] = ...
      get_number_of_transits_in_time_series( transitObject, [], true(13,1) ) ;
  valuesOk = numExpected2 == numExpectedTransits && numActual2 == numActualTransits && ...
      isequal( informationStruct2, transitInformationStruct ) ;
  mlunit_assert( valuesOk, ...
      'Method call with limited gaps produces incorrect values' ) ;
  
  [numExpected2, numActual2, informationStruct2] = ...
      get_number_of_transits_in_time_series( transitObject, [], [], [1:13] ) ;
  valuesOk = numExpected2 == numExpectedTransits && numActual2 == numActualTransits && ...
      isequal( informationStruct2, transitInformationStruct ) ;
  mlunit_assert( valuesOk, ...
      'Method call with limited fills produces incorrect values' ) ;

  [numExpected2, numActual2, informationStruct2] = ...
      get_number_of_transits_in_time_series( transitObject, [], true(10,1), [11:20] ) ;
  valuesOk = numExpected2 == numExpectedTransits && numActual2 == numActualTransits && ...
      isequal( informationStruct2, transitInformationStruct ) ;
  mlunit_assert( valuesOk, ...
      'Method call with limited gaps and fills produces incorrect values' ) ;
  
% now some combinations which will change the output -- we will gap out the entire transit

  [numExpectedGap, numActualGap, informationStructGap] = ...
      get_number_of_transits_in_time_series( transitObject, [], true(26,1) ) ;
  valuesOk = numExpectedGap == numExpectedTransits && numActualGap == numActualTransits - 1 && ...
      length(informationStructGap) == 1 && informationStructGap.bkjdTransitStart == ...
      transitInformationStruct.bkjdTransitStart && ...
      informationStructGap.bkjdTransitEnd == transitInformationStruct.bkjdTransitEnd && ...
      informationStructGap.gapIndicator ;
  mlunit_assert( valuesOk, ...
      'Method call with complete gapping produces incorrect values' ) ;
  
  [numExpected2, numActual2, informationStruct2] = ...
      get_number_of_transits_in_time_series( transitObject, [], [], [1:26] ) ;
  valuesOk = numExpected2 == numExpectedGap && numActual2 == numActualGap && ...
      isequal( informationStruct2, informationStructGap ) ;
  mlunit_assert( valuesOk, ...
      'Method call with complete filling produces incorrect values' ) ;

  [numExpected2, numActual2, informationStruct2] = ...
      get_number_of_transits_in_time_series( transitObject, [], true(13,1), [14:26] ) ;
  valuesOk = numExpected2 == numExpectedGap && numActual2 == numActualGap && ...
      isequal( informationStruct2, informationStructGap ) ;
  mlunit_assert( valuesOk, ...
      'Method call with complete gapping / filling produces incorrect values' ) ;
  
% set up a cadence time series which will have 2 transits in it and which is not
% continuous

  cadenceTimes = get( transitObject, 'cadenceTimes' ) ;
  cadenceTimes = [cadenceTimes ; cadenceTimes + 330] ;
  
% test the method with a cadenceTimes vector

  transitPeriod = get(transitObject,'orbitalPeriodDays') ;
  [numExpected3, numActual3, informationStruct3] = ...
      get_number_of_transits_in_time_series( transitObject, cadenceTimes ) ;
  valuesOk = numExpected3 == 2 ;
  valuesOk = valuesOk && numActual3 == 2 ;
  valuesOk = valuesOk && length( informationStruct3 ) == numActual3 ;
%  valuesOk = valuesOk && isequal( informationStruct3(1), transitInformationStruct ) ;
  valuesOk = valuesOk && (transitInformationStruct.gapIndicator == ...
      informationStruct3(1).gapIndicator && ...
      abs( transitInformationStruct.bkjdTransitStart - ...
      informationStruct3(1).bkjdTransitStart ) < 1e-12 && ...
      abs( transitInformationStruct.bkjdTransitEnd - ...
      informationStruct3(1).bkjdTransitEnd ) < 1e-12) ;
  valuesOk = valuesOk && abs(informationStruct3(2).bkjdTransitStart - ...
      informationStruct3(1).bkjdTransitStart - transitPeriod) < 1e-12 ;
  valuesOk = valuesOk && (informationStruct3(2).bkjdTransitEnd - ...
      informationStruct3(1).bkjdTransitEnd - transitPeriod) < 1e-12 ;
  valuesOk = valuesOk && ~informationStruct3(2).gapIndicator ;
  
  mlunit_assert( valuesOk, ...
      'Method call with extended cadence times produces incorrect values' ) ;
  
% test the method with a cadenceTimes vector and with gap indicators which remove 1
% transit.  Note that we won't go through all the combinations of gap indicators and fill
% indices which we did above -- I assert that it is only necessary to do that entire
% pattern of gaps and fills once to test the capability.

  [numExpected4, numActual4, informationStruct4] = ...
      get_number_of_transits_in_time_series( transitObject, cadenceTimes, ...
      true(13,1), [14:26] ) ;
  valuesOk = numExpected4 == numExpected3 && numActual4 == numActual3 - 1 && ...
      isequal( informationStruct4(2), informationStruct3(2) ) && ...
      isequal( informationStruct4(1), informationStructGap ) ;
  mlunit_assert( valuesOk, ...
      'Method call with extended cadence times and complete gapping / filling produces incorrect values' ) ;
  disp(' ') ;
  
return

% and that's it!

%
%
%
