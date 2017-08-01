% script to perform validation tests on Kepler barycentric correction
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

% start by obtaining an raDec2PixClass object

  raDec2PixModel = retrieve_ra_dec_2_pix_model() ;
  raDec2PixObject = raDec2PixClass( raDec2PixModel, 'one-based' ) ;
  day2min = get_unit_conversion( 'day2min' ) ;
  km2m    = 1000 ;
  m2km    = 1 / km2m ;
  sec2min = get_unit_conversion( 'sec2min' ) ;
  
% compute the distance in km which corresponds to 500 light seconds

  dist500LightSecondsKm = 500 * get_physical_constants_mks( 'speedOfLight' ) * m2km ;
  
% demonstrate that for an x distance from the barycenter of 500 light seconds the
% correction has the expected behavior

  xOffset = [dist500LightSecondsKm 0 0] ;
  ra = 0 ; dec = 0 ;
  barycentricCorrection = compute_barycentric_correction( xOffset, ra, dec ) ;
  disp( [ '  Correction for 500 light-second x offset, RA == ', num2str(ra), ...
      ' degrees, dec == ', num2str(dec), ' degrees:  ', ...
      num2str( barycentricCorrection ), ' seconds' ] ) ;
  ra = 90 ;
  barycentricCorrection = compute_barycentric_correction( xOffset, ra, dec ) ;
  disp( [ '  Correction for 500 light-second x offset, RA == ', num2str(ra), ...
      ' degrees, dec == ', num2str(dec), ' degrees:  ', ...
      num2str( barycentricCorrection ), ' seconds' ] ) ;
  ra = 180 ;
  barycentricCorrection = compute_barycentric_correction( xOffset, ra, dec ) ;
  disp( [ '  Correction for 500 light-second x offset, RA == ', num2str(ra), ...
      ' degrees, dec == ', num2str(dec), ' degrees:  ', ...
      num2str( barycentricCorrection ), ' seconds' ] ) ;
  ra = 270 ;
  barycentricCorrection = compute_barycentric_correction( xOffset, ra, dec ) ;
  disp( [ '  Correction for 500 light-second x offset, RA == ', num2str(ra), ...
      ' degrees, dec == ', num2str(dec), ' degrees:  ', ...
      num2str( barycentricCorrection ), ' seconds' ] ) ;
  ra = 0 ; dec = 60 ;
  barycentricCorrection = compute_barycentric_correction( xOffset, ra, dec ) ;
  disp( [ '  Correction for 500 light-second x offset, RA == ', num2str(ra), ...
      ' degrees, dec == ', num2str(dec), ' degrees:  ', ...
      num2str( barycentricCorrection ), ' seconds' ] ) ;
  dec = 90 ;
  barycentricCorrection = compute_barycentric_correction( xOffset, ra, dec ) ;
  disp( [ '  Correction for 500 light-second x offset, RA == ', num2str(ra), ...
      ' degrees, dec == ', num2str(dec), ' degrees:  ', ...
      num2str( barycentricCorrection ), ' seconds' ] ) ;

% demonstrate that the correction computed by the standalone code and the raDec2Pix code
% agree for a point on the Kepler flight

  mjd = 55027 ;
  [pos vel] = get_state_vector( raDec2PixObject, mjd + raDec2PixModel.mjdOffset, 'SSB' ) ;
  ra = 291 ; dec = 45 ;
  barycentricCorrection = compute_barycentric_correction( pos, ra, dec ) ;
  raDec2PixCorrection = get_kepler_to_barycentric_offset( raDec2PixObject, ra, dec, mjd ) ...
      * get_unit_conversion( 'day2sec' ) ;
  disp( [ '  Standalone correction for Kepler position on MJD ', num2str( mjd ), ...
      ' looking at RA == ', num2str(ra), ' degrees, dec == ', num2str(dec), ...
      ' degrees:  ', num2str(barycentricCorrection), ' seconds' ] ) ;
  disp( [ '  raDec2Pix correction for Kepler position on MJD ', num2str( mjd ), ...
      ' looking at RA == ', num2str(ra), ' degrees, dec == ', num2str(dec), ...
      ' degrees:  ', num2str(raDec2PixCorrection), ' seconds' ] ) ;
  
% Demonstrate that the kepler-to-barycentric and barycentric-to-kepler methods have the
% correct value and sign

  mjdBarycentric = kepler_time_to_barycentric( raDec2PixObject, ra, dec, mjd ) ;
  mjdKepler = barycentric_time_to_kepler( raDec2PixObject, ra, dec, mjdBarycentric ) ;
  deltaKToBSeconds = (mjdBarycentric - mjd) * get_unit_conversion('day2sec') ;
  deltaBToKSeconds = (mjdKepler - mjdBarycentric) * get_unit_conversion('day2sec') ;
  disp( [ '  K-to-B correction for Kepler position on MJD ', num2str( mjd ), ...
      ' looking at RA == ', num2str(ra), ' degrees, dec == ', num2str(dec), ...
      ' degrees:  ', num2str(deltaKToBSeconds), ' seconds' ] ) ;
  disp( [ '  B-to-K correction for Kepler position on MJD ', num2str( mjd ), ...
      ' looking at RA == ', num2str(ra), ' degrees, dec == ', num2str(dec), ...
      ' degrees:  ', num2str(deltaBToKSeconds), ' seconds' ] ) ;
  