function [unaber_ra, unaber_dec] = unaberrate_stars( ra, dec, julian_dates, orbit_file_name )
% function [unaber_ra, unaber_dec] = unaberrate_stars( ra, dec, julian_dates )
%
% Unaberrate a vector of stars (given as vector of chip row and column positions)
%   using Kepler's velocity.  The results are for the series of Julian dates
%   given as the third argument.
%
% Spacecraft velocity is in ecliptic (lat/long), 
% Star (ra,dec)/(x,y,z) are in equatorial
% orbit_file_name is the path to a file specifying the Kepler orbit vector
%
% Convert star (ra,dec) --> star (long,lat), which is in the spacecraft velocity coordinate system.
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

% radian -> degrees -> radian conversion factors
r2d = 180/pi;
d2r = 1/r2d;

% Need to know position & velocity of the spacecraft at the date/time.
if nargin==3
    [ pos, vel ] = keplerOrbitVector( julian_dates' );
else
    [ pos, vel ] = keplerOrbitVector( julian_dates',  orbit_file_name);
end

% Convert RA & Dec (equatorial) to ecliptic Lat & Long
[ lat long ] = Eq2Ecl( ra .* d2r, dec .* d2r );
long = long .* r2d;
lat  = lat  .* r2d;

% Convert star positions to Cartesian & unaberrate the position
[ x, y, z ]                 = convert_stars_sph2cart( long, lat );
[ x, y, z ]                 = get_unaberrated_positions( x, y, z, vel );

% Convert the star positions to spherical & then back to RA & Dec
[ unaber_long, unaber_lat ] = convert_stars_cart2sph( x, y, z );
[ unaber_ra,   unaber_dec ] = Ecl2Eq( unaber_long .* d2r, unaber_lat .* d2r );

% Convert positions in radians to degrees
unaber_ra  = unaber_ra  .* r2d;
unaber_dec = unaber_dec .* r2d;

% Wrap-around boundaries managed
unaber_ra  = bound( unaber_ra,    0, 360 ); % RA goes from 0 to 360
unaber_dec = bound( unaber_dec, -90,  90 ); % Dec defined from -90 (S. Pole) to 90 (N. Pole)

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x_out, y_out, z_out] = get_unaberrated_positions( x, y , z, vel )
% Calc the aberrated positions for each frame, and the offsets
%   from each frame to the unaberrated positions.
%

x_out = zeros(size(x,1),size(vel,1)); % Number of stars X number of time stamps
y_out = x_out;  % Same size
z_out = x_out;  % Same size

for i_time = 1:size( vel, 1 )
    tmp_vel = repmat( vel(i_time,:), size( x, 1 ), 1 );
    [x_out(:,i_time), y_out(:,i_time), z_out(:,i_time)] = vel_aber_inv( x, y, z, tmp_vel );
end

return