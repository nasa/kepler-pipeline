function self = test_barycentric_correction( self )
%
% test_barycentric_correction -- unit test for raDec2PixClass method which performs
% barycentric time correction
%
% The test_barycentric_correction unit test exercises the get_kepler_to_barycentric_offset
%    method of the raDec2PixClass and tests the following behaviors:
%
% ==> the method operates properly when given multiple sky points and multiple MJDs, and
%     returns a correctly-shaped output
% ==> the method accepts any combination of row- and column-vectors for its 3 vector
%     inputs
% ==> the method errors out when any of the following happens:
%     ==> ra, dec, or MJD is not a vector (ie, a multi-dimensional array)
%     ==> the length of ra ~= the length of dec
%     ==> any value of ra is outside the range [0,360]
%     ==> any value of dec is outside the range [-90,90]
% ==> the method returns the correct values for two numeric test cases:
%     ==> barycentric time corrections for Kepler's FOV spanning 1 "Kepler year"
%     ==> barycentric time corrections for a range of declinations at Kepler's nominal
%         center RA at the time of maximum correction
% ==> The actual user methods -- kepler_time_to_barycentric and barycentric_time_to_kepler
%         -- work and return correct values
% ==> The low-level get_kepler_to_barycentric_offset method gets the correct answer for
%         cases where the correct answer is easy to calculate from first principles.
%
% Note that the value tests are regression tests, so test_barycentric_correction uses a
%    cached raDec2Pix model and cached ephemeris files.
% 
% test_barycentric_correction runs under mlunit, so the correct syntax for invoking it is:
%
%    run(text_test_runner,testRaDec2PixClass('test_barycentric_correction')) ;
%
% Version date:  2011-January-19.
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

% Modification Date:
%
%    2011-January-19, PT:
%        updated test to match changes in the 3 barycentric correction method, plus added
%        tests which operate directly on the lowest-level calculation method and compares
%        to easily-calculated cases.
%
%=========================================================================================

  display('barycentric correction')
  
% the desired model and ephemeris files are in the test-data repo; get their location now

  initialize_soc_variables ;
  fcDataDir = fullfile(socTestDataRoot, 'fc', 'barycentric-correction');
  
% load the raDec2PixModel, update its spiceFileDir, and instantiate it

%   load(fullfile(fcDataDir,'raDec2PixModel')) ;
  raDec2PixModel = retrieve_ra_dec_2_pix_model();
  raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');
  raDec2PixModel.spiceSpacecraftEphemerisFilename = 'spk_2009065045522_2009008233141_kplr.bsp' ;
  raDec2PixModel.planetaryEphemerisFilename = 'de405.bsp' ;
  raDec2PixObject = raDec2PixClass(raDec2PixModel,'one-based') ;
  
% TEST 1 -- multiple sky point / multiple MJD test

  ra = [290 291 292 293 294] ; dec =[45 45 45 45 45] ; mjd = [54936:54939] ;
  dt = kepler_time_to_barycentric( raDec2PixObject, ra, dec, mjd ) ;
  assert_equals( size(dt),[length(ra) length(mjd)], ...
      'shape of dt does not match expected shape' ) ;
  dt = barycentric_time_to_kepler( raDec2PixObject, ra, dec, mjd ) ;
  assert_equals( size(dt),[length(ra) length(mjd)], ...
      'shape of dt does not match expected shape' ) ;
  
% TEST 2 -- all combinations of row and column vectors are accepted

  dt = kepler_time_to_barycentric( raDec2PixObject, ra, dec, mjd ) ;
  dt1 = kepler_time_to_barycentric( raDec2PixObject, ra', dec, mjd ) ;
    assert_equals( dt, dt1, 'dt1 values not correct' ) ;
  dt2 = kepler_time_to_barycentric( raDec2PixObject, ra, dec', mjd ) ;
    assert_equals( dt, dt2, 'dt1 values not correct' ) ;
  dt3 = kepler_time_to_barycentric( raDec2PixObject, ra', dec', mjd ) ;
    assert_equals( dt, dt3, 'dt3 values not correct' ) ;
  dt4 = kepler_time_to_barycentric( raDec2PixObject, ra, dec, mjd' ) ;
    assert_equals( dt, dt4, 'dt4 values not correct' ) ;
  dt5 = kepler_time_to_barycentric( raDec2PixObject, ra', dec, mjd' ) ;
    assert_equals( dt, dt5, 'dt5 values not correct' ) ;
  dt6 = kepler_time_to_barycentric( raDec2PixObject, ra, dec', mjd' ) ;
    assert_equals( dt, dt6, 'dt6 values not correct' ) ;
  dt7 = kepler_time_to_barycentric( raDec2PixObject, ra', dec', mjd' ) ;
    assert_equals( dt, dt7, 'dt7 values not correct' ) ;
    
  dt = barycentric_time_to_kepler( raDec2PixObject, ra, dec, mjd ) ;
  dt1 = barycentric_time_to_kepler( raDec2PixObject, ra', dec, mjd ) ;
    assert_equals( dt, dt1, 'dt1 values not correct' ) ;
  dt2 = barycentric_time_to_kepler( raDec2PixObject, ra, dec', mjd ) ;
    assert_equals( dt, dt2, 'dt1 values not correct' ) ;
  dt3 = barycentric_time_to_kepler( raDec2PixObject, ra', dec', mjd ) ;
    assert_equals( dt, dt3, 'dt3 values not correct' ) ;
  dt4 = barycentric_time_to_kepler( raDec2PixObject, ra, dec, mjd' ) ;
    assert_equals( dt, dt4, 'dt4 values not correct' ) ;
  dt5 = barycentric_time_to_kepler( raDec2PixObject, ra', dec, mjd' ) ;
    assert_equals( dt, dt5, 'dt5 values not correct' ) ;
  dt6 = barycentric_time_to_kepler( raDec2PixObject, ra, dec', mjd' ) ;
    assert_equals( dt, dt6, 'dt6 values not correct' ) ;
  dt7 = barycentric_time_to_kepler( raDec2PixObject, ra', dec', mjd' ) ;
    assert_equals( dt, dt7, 'dt7 values not correct' ) ;
    
    
% TEST 3 -- error conditions

% Condition 1 -- RA is not a vector

  ra2 = [ra ; ra] ; dec2 = [dec dec] ;
  try_to_catch_error_condition(...
      'barycentric_time_to_kepler(raDec2PixObject,ra2,dec2,mjd) ;', ...
      'nonVectorArguments', ...
      'caller' ) ;
  
% condition 2 -- Dec is not a vector

  ra2 = [ra ra] ; dec2 = [dec ; dec] ;
  try_to_catch_error_condition(...
      'barycentric_time_to_kepler(raDec2PixObject,ra2,dec2,mjd) ;', ...
      'nonVectorArguments', ...
      'caller' ) ;
  
% condition 3 -- mjd is not a vector

  mjd2 = [mjd ; mjd] ;
  try_to_catch_error_condition(...
      'barycentric_time_to_kepler(raDec2PixObject,ra,dec,mjd2) ;', ...
      'nonVectorArguments', ...
      'caller' ) ;
  
% condition 4 -- length(ra) ~= length(dec)

  try_to_catch_error_condition(...
      'barycentric_time_to_kepler(raDec2PixObject,ra2,dec,mjd) ;', ...
      'vectorLengthUnequal', ...
      'caller' ) ;
  
% condition 5 -- RA out of bounds

  ra2 = ra ;
  ra2(1) = -1 ;
  try_to_catch_error_condition(...
      'barycentric_time_to_kepler(raDec2PixObject,ra2,dec,mjd) ;', ...
      'raOutOfBounds', ...
      'caller' ) ;
  ra2(1) = 361 ;
  try_to_catch_error_condition(...
      'barycentric_time_to_kepler(raDec2PixObject,ra2,dec,mjd) ;', ...
      'raOutOfBounds', ...
      'caller' ) ;

% condition 6 -- Dec out of bounds

  dec2 = dec ;
  dec2(1) = -91 ;
  try_to_catch_error_condition(...
      'barycentric_time_to_kepler(raDec2PixObject,ra,dec2,mjd) ;', ...
      'decOutOfBounds', ...
      'caller' ) ;
  dec2(1) = 91 ;
  try_to_catch_error_condition(...
      'barycentric_time_to_kepler(raDec2PixObject,ra,dec2,mjd) ;', ...
      'decOutOfBounds', ...
      'caller' ) ;
  
% TEST 4 -- regression tests

% load the regression values from the test data repository

  load(fullfile(fcDataDir,'correctTestResults')) ;
  
% case 1 -- 400 days' worth of barycentric corrections at Kepler nominal FOV center

  ra  = 290.6666667 ;
  dec =  44.5 ;
  mjd = 54936:54936+399 ;
  
  mjdCorrected = kepler_time_to_barycentric( raDec2PixObject, ra, dec, mjd ) ;
  dt = mjdCorrected - mjd ;
  mlunit_assert( all( abs(dt-dt400DaysAtFov) < 1e-09 ), ...
      'corrections at FOV center diverge from cached values' ) ;
  
% case 2 -- a range of Dec values at the nominal RA and the MJD which results in the
% maximum barycentric correction

  mjd = 55046 ;
  dec = -90:90 ; 
  ra = ra * ones(size(dec)) ;
  mjdCorrected = kepler_time_to_barycentric( raDec2PixObject, ra, dec, mjd ) ;
  dt = mjdCorrected - mjd ;
  mlunit_assert( all( abs(dt-dtDecScan) < 1e-09 ), ...
      'corrections across declination scan diverge from cached values' ) ;

% TEST 5 -- make sure that kepler_time_to_barycentric and barycentric_time_to_kepler
% actually work

  ra  = 290.6666667 ;
  dec =  44.5 ;
  mjd = 55046 ;

  mjd2 = kepler_time_to_barycentric( raDec2PixObject, ra, dec, mjd ) ;
  assert_equals( mjd2, mjdKeplerToBarycentric, ...
      'Kepler -> Barycentric conversion gets incorrect answer' ) ;
  mjd3 = barycentric_time_to_kepler( raDec2PixObject, ra, dec, mjd ) ;
  assert_equals( mjd3, mjdBarycentricToKepler, ...
      'Kepler -> Barycentric conversion gets incorrect answer' ) ;
  
% test 6:  compare the computed barycentric offsets with simple cases, which can easily be
% computed by hand.  Use a spacecraft which is 500 light-seconds from the Sun in the +x
% direction and compute the barycentric correction for target stars in the orbital plane
% and for target star at +/-90 degree declination.

  dtMaxSeconds = 500 ;
  xPosition = dtMaxSeconds * get_physical_constants_mks( 'speedOfLight' ) * ...
      0.001 ; % convert to km
  dtMaxDays = dtMaxSeconds * get_unit_conversion( 'sec2day' ) ;
  position = [xPosition 0 0] ;
  ra = [0 ; 45 ; 90 ; 135 ; 180 ; 225 ; 270 ; 315 ; 0 ; 0] ; 
  dec = [0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; -90 ; 90] ;
  dt = get_kepler_to_barycentric_offset( raDec2PixObject, ra, dec, position ) ;
  dtExpected = dtMaxDays * [ 1 ; 1/sqrt(2) ; 0 ; -1/sqrt(2) ; -1 ; ...
      -1/sqrt(2) ; 0 ; 1/sqrt(2) ; 0 ; 0 ] ;
  mlunit_assert( all( abs( dt - dtExpected ) < 1e-09 ) , ...
      'Simple test of get_kepler_to_barycentric_offset gets wrong values!' ) ;
  
return  
  
% and that's it!

%
%
%
