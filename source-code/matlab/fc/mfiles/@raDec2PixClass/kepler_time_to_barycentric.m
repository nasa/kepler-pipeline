function mjdBarycentric = kepler_time_to_barycentric( raDec2PixObject, ra, dec, ...
    mjdKepler )
%
% kepler_time_to_barycentric -- convert MJDs in Kepler reference frame (UTC) to
% barycentric-time MJDs in the Barycentric Dynamical Time (TDB) system.
%
% mjdBarycentric = kepler_time_to_barycentric( raDec2PixObject, ra, dec, mjdKepler ) takes
%    vectors of right ascension and declination coordinates (all in degrees) and a vector
%    of MJD times of light-arrival at Kepler, and converts to the TDB times of light
%    arrival at the solar system barycenter.  The resulting mjdBarycentric is a matrix,
%    with dimension nCoordinates x nTimestamps.
%
% Version date:  2012-November-20.
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
%    2012-November-20, JT:
%        Kepler Archive Manual states that the barycentric timestamps should include
%        conversion to the TDB time standard. Now adding the TDB-UTC differences
%        for each timestamp so that the pipeline conforms to the TDB time
%        standard.
%    2011-January-18, PT:
%        Per KSOC-657, refactor so that the calls to get_state_vector are in the
%        upper-level methods.  This will make the lower-level computation of the
%        barycentric offset easier to test and to validate.
%
%=========================================================================================

% the correction is actually computed in a separate function, so that we can use the same
% algorithm to convert Kepler->Barycentric and Barycentric->Kepler

% coordinate conversion constants:

  sec2day = 1/24/60/60 ;
  
% first:  make sure that mjdKepler is a vector

  if ~isvector( mjdKepler )
      error('MATLAB:FC:raDec2PixClass:barycentricTimeToKepler:nonVectorArguments', ...
          'get_kepler_to_barycentric_offset: MJD must be scalar or vector') ;
  end
  
% second:  get the spacecraft position and TDB-UTC differences at the requested times

  [spacecraftPositionKm, ~, tdbMinusUtcSec] = get_state_vector( raDec2PixObject, ...
      mjdKepler + raDec2PixObject.mjdOffset, 'ssb' ) ;

% third:  compute the correction, given the spacecraft position
  
  barycentricCorrection = get_kepler_to_barycentric_offset( raDec2PixObject, ra, dec, ...
      spacecraftPositionKm ) ;

% since we want to convert Kepler time (MJD) to Barycentric (TDB), we can add the values in
% barycentricCorrection to the TDB adjusted Kepler values to get the mjdBarycentric values.
% To do this, we need to convert mjdKepler from its current vector form to a matrix with the
% dimensions nCoordinates x nTimestamps and include the TDB-UTC differences:

  mjdMatrix = repmat( mjdKepler(:)' + tdbMinusUtcSec(:)' * sec2day, length(ra), 1 ) ;
  mjdBarycentric = mjdMatrix + barycentricCorrection ;
  
return

% and that's it!

%
%
%


