function barycentricCorrectionDays = get_kepler_to_barycentric_offset( raDec2PixObject, ...
    ra, dec, position )
%
% get_kepler_to_barycentric_offset -- compute the time offset between Kepler time and
% barycentric time
%
% barycentricCorrection = get_kepler_to_barycentric_offset( raDec2PixObject, ra, dec, 
%    positionKm ) computes the offset, in days, which must be added to a Kepler MJD to
%    produce the equivalent barycentric MJD (ie, the time difference between the arrival
%    time of light from a given RA and Dec at Kepler and the arrival time of that same
%    light at the solar system barycenter).  The ra and dec arguments may be vectors but
%    must be of equal length to one another; argument positionKm is a matrix, dimensions
%    nTimestamps x 3.  The returned barycentricCorrection is a matrix, with dimensions
%    length(ra) x length(mjd).
%
% Version date:  2011-January-18.
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
%    2011-January-18, PT:
%        update with position calculation performed outside the routine; adjust error
%        trapping on arguments accordingly.
%    2009-April-06, PT:
%        correct coordinate system to the one used by Spice.  Add error-trapping on
%        arguments.
%
%=========================================================================================

% if any of the vector-ready arguments are multi-dimensional arrays, error out

  if ( ~isvector(ra) || ~isvector(dec) )
      error('MATLAB:FC:raDec2PixClass:getKeplerToBarycentricOffset:nonVectorArguments', ...
          'get_kepler_to_barycentric_offset:  RA and Dec must be scalar or vector') ;
  end
  
  if ~isequal( size( position,2 ), 3 )
      error('MATLAB:FC:raDec2PixClass:getKeplerToBarycentricOffset:positionWrongShape', ...
          'get_kepler_to_barycentric_offset: position argument must be nTimestamps x 3') ;
  end
  
  if ( length(ra) ~= length(dec) )
      error('MATLAB:FC:raDec2PixClass:getKeplerToBarycentricOffset:vectorLengthUnequal', ...
          'get_kepler_to_barycentric_offset:  RA and Dec must have equal lengths') ;
  end
  
  if ( min(ra) < 0 || max(ra) > 360 )
      error('MATLAB:FC:raDec2PixClass:getKeplerToBarycentricOffset:raOutOfBounds', ...
          'get_kepler_to_barycentric_offset:  RA values are out of bounds') ;
  end

  if ( min(dec) < -90 || max(dec) > 90 )
      error('MATLAB:FC:raDec2PixClass:getKeplerToBarycentricOffset:decOutOfBounds', ...
          'get_kepler_to_barycentric_offset:  Dec values are out of bounds') ;
  end

% coordinate conversion constants:

  deg2rad = pi/180 ;
  m2km    = 1/1000 ;
  sec2day = 1/24/60/60 ;
  
  
% Note on the position argument: the dimensions of position are km, and the positions are
% with respect to the solar system barycenter.  The coordinates are defined as follows:
%
% The xy plane is parallel to the equatorial plane of the Earth, and passes through the
% barycenter.
%
% The +x axis points towards RA = 0 hours (00 degrees)
% The +y axis points towards RA = 6 hours (90 degrees)
% The +z axis completes the right-handed coordinate system, pointing towards Dec = +90
%    degrees.

  
% convert RA and Dec into column vectors, if they aren't already

  ra = ra(:) ;
  dec = dec(:) ;  
  
% construct the unit vectors pointing towards RA and Dec in the coordinate system.  To do
% this, we will convert RA and Dec into more conventional spherical coordinates, to wit:
%
% 	theta = angle from +x-axis towards the +y-axis,
% 	phi = angle from the +z-axis towards the x-y plane.
%
% In this coordinate system, the transformation into a Cartesian unit vector is:
%
%	x = cos(theta)*sin(phi)
%	y = sin(theta)*sin(phi)
%	z = cos(phi)

  theta = ra*deg2rad ;
  phi   = (90-dec)*deg2rad ;
  
  targetUnitVector = [cos(theta).*sin(phi)  sin(theta).*sin(phi)  cos(phi)] ;
  
% the correction is given by the dot-product of the unit vector and the position vector
% divided by the speed of light. 

  barycentricCorrectionSeconds = targetUnitVector * position' / ...
      (get_physical_constants_mks('speedOfLight') * m2km) ;
  
% convert to correction in days

  barycentricCorrectionDays = barycentricCorrectionSeconds * sec2day ;
  
return

% and that's it -- good thing, too, more comments than code!

%
%
%
