function barycentricCorrectionSeconds = compute_barycentric_correction( ...
    spacecraftPositionKm, raDegrees, decDegrees )
%
% compute_barycentric_correction( spacecraftPositionKm, raDegrees, decDegrees ) -- compute
% the barycentric time correction for a spacecraft given its position vector, in km, WRT
% the solar system barycenter, and the sky point (RA and Dec in degrees) which it looks
% at.  Correction is returned in seconds.
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

% coordinate conversion constants:

  deg2rad = get_unit_conversion('deg2rad') ;
  m2km    = 1/1000 ;
  km2m    = 1/m2km ;
  sec2day = get_unit_conversion('sec2day') ;
    
% The coordinates of the spacecraft WRT SSB are defined as follows:
%
% The xy plane is parallel to the equatorial plane of the Earth, and passes through the
% barycenter.
%
% The +x axis points towards RA = 0 hours (00 degrees)
% The +y axis points towards RA = 6 hours (90 degrees)
% The +z axis completes the right-handed coordinate system, pointing towards Dec = +90
%    degrees.
%
% Convert to meters now

  spacecraftPositionMeters = spacecraftPositionKm(:) * km2m ;
  
% construct the unit vector pointing towards RA and Dec in the coordinate system.  To do
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

  theta = raDegrees*deg2rad ;
  phi   = (90-decDegrees)*deg2rad ;
  
  targetUnitVector = [cos(theta).*sin(phi)  sin(theta).*sin(phi)  cos(phi)] ;
  
% the correction is given by the dot-product of the unit vector and the position vector
% divided by the speed of light. 

  barycentricCorrectionSeconds = targetUnitVector * spacecraftPositionMeters / ...
      get_physical_constants_mks('speedOfLight') ;

return