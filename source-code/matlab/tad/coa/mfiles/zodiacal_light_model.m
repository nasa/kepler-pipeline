function zodi_estimate = zodiacal_light_model(Heliocentric_Ecliptic_Longitude, Ecliptic_Latitude, pixelangle)
%function zodi_estimate = Zodi_Model(Heliocentric_Ecliptic_Longitude, Ecliptic_Latitude, pixelangle)
%
% Heliocentric_Ecliptic_Longitude, Ecliptic_Latitude should be in degrees
% 
% Note: Both angles can be vectors/matrices as well as scalars.
%
% zodi_estimate will be given in Vmag PER PIXEL (per 3.98 arc-sec-squared)
% if the parameter pixelangle is not specified (in arc-seconds)
%
% Caution: All angles too near to the sun will return NaN.
%
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


% REFERENCE:
% http://www.stsci.edu/instruments/wfpc2/Wfpc2_hand_current/ch6_exposuretime5.html
%
% Table 6.3: Sky Brightness (V mag arcsec-2) as a Function of Heliocentric Ecliptic Latitude and Longitude. "SA" denotes that the target is unobservable due to solar avoidance. 
% Heliocentric
% Ecliptic
% Longitude  Ecliptic Latitude  
%       0�  15�  30�  45�  60�  75�  90�  
% 180� 22.1 22.4 22.7 23.0 23.2 23.4 23.3 
% 165� 22.3 22.5 22.8 23.0 23.2 23.4 23.3 
% 150� 22.4 22.6 22.9 23.1 23.3 23.4 23.3 
% 135� 22.4 22.6 22.9 23.2 23.3 23.4 23.3 
% 120� 22.4 22.6 22.9 23.2 23.3 23.3 23.3 
% 105� 22.2 22.5 22.9 23.1 23.3 23.3 23.3 
% 90�  22.0 22.3 22.7 23.0 23.2 23.3 23.3 
% 75�  21.7 22.2 22.6 22.9 23.1 23.2 23.3 
% 60�  21.3 21.9 22.4 22.7 23.0 23.2 23.3 
% 45�  SA   SA   22.1 22.5 22.9 23.1 23.3 
% 30�  SA   SA   SA   22.3 22.7 23.1 23.3 
% 15�  SA   SA   SA   SA   22.6 23.0 23.3 
%  0�  SA   SA   SA   SA   22.6 23.0 23.3 

% Table rows & columns (see above comment from the reference)
% Columns
Ecliptic_Lat   = [0 15 30 45 60 75 90];
% Rows
HeEcliptic_Lon = [180 165 150 135 120 105 90 75 60 55 30 15 0];

% Table, apparent magnitude per square arc-sec
% 
% 15 July 05: Changed lat45,long15 from NaN to 22.0 and
%                     lat45,long0  from NaN to 21.7
% on Doug Cauldwell's recommendation.
%
zodi = [
    22.1 22.4 22.7 23.0 23.2 23.4 23.3 
    22.3 22.5 22.8 23.0 23.2 23.4 23.3 
    22.4 22.6 22.9 23.1 23.3 23.4 23.3 
    22.4 22.6 22.9 23.2 23.3 23.4 23.3 
    22.4 22.6 22.9 23.2 23.3 23.3 23.3 
    22.2 22.5 22.9 23.1 23.3 23.3 23.3 
    22.0 22.3 22.7 23.0 23.2 23.3 23.3 
    21.7 22.2 22.6 22.9 23.1 23.2 23.3 
    21.3 21.9 22.4 22.7 23.0 23.2 23.3 
    NaN  NaN  22.1 22.5 22.9 23.1 23.3 
    NaN  NaN  NaN  22.3 22.7 23.1 23.3 
    NaN  NaN  NaN  22.0 22.6 23.0 23.3 
    NaN  NaN  NaN  21.7 22.6 23.0 23.3];
    %NaN  NaN  NaN  NaN  22.6 23.0 23.3 
    %NaN  NaN  NaN  NaN  22.6 23.0 23.3];


% Convert to apparent magnitude per pixel
zodi = b2mag( mag2b(zodi) * pixelangle^2 );

%INTERP2 2-D interpolation (table lookup).
%    ZI = INTERP2(X,Y,Z,XI,YI) interpolates to find ZI, the values of the
%    underlying 2-D function Z at the points in matrices XI and YI.
%    Matrices X and Y specify the points at which the data Z is given.

% Turn the row/column "headings" into X and Y matrices for interp2.
[X, Y] = meshgrid(Ecliptic_Lat, HeEcliptic_Lon);

% The table is symmetric in +/- lat/long, so convert any - values to +.
Heliocentric_Ecliptic_Longitude  = abs(Heliocentric_Ecliptic_Longitude);
if ( Heliocentric_Ecliptic_Longitude > 180 )
    Heliocentric_Ecliptic_Longitude = 360 - Heliocentric_Ecliptic_Longitude;
end
Ecliptic_Latitude                = abs(Ecliptic_Latitude);

% Estimate the zodi
zodi_estimate = interp2(X, Y, zodi, Ecliptic_Latitude, ...
                       Heliocentric_Ecliptic_Longitude, 'linear');

% ZodiModel is returning NaN for Heliocentric_Eclip_Long = 5.4
%   degrees, Eclip_Lat = 59 degrees.  This is right on the edge of 
%   the NaN region in the Zodi interp table.
% If zodi_estimate is returned NaN, all subsequent data, including
%   pixels and timeseries are corrupted.  Set zodi_estimate to
%   the value of the closes non-NaN element if NaN is calculated..
%
%   --K. Allen 18 July '05
%
% 

if ( IsZodiNaN( zodi_estimate ) )
    warning( 'Zodi estimate contains NaN! Taking closest zodi estimate.' );
    zodi_estimate = get_nonNaN_ZodiEstimate( zodi,       ...
                           HeEcliptic_Lon,                  Ecliptic_Lat, ...
                           Heliocentric_Ecliptic_Longitude, Ecliptic_Latitude );
end

return

function bNaN = IsZodiNaN( zodi_val )
    bNaN = any( isnan( zodi_val ) );
return

function zodi_estimate = get_nonNaN_ZodiEstimate( zodi, hlong_grid, lat_grid, hlong_val, lat_val );
    %
    % function zodi_estimate = get_nonNaN_ZodiEstimate( zodi, hlong_grid, lat_grid, hlong_val, lat_val );
    %
    % If the zodi estimate is NaN, step upards and rightwards through the
    %   matrix until you hit a non-NaN value:
    %
    iJump = 0;
    bContinue = 1;

    % Find the array element to start searching from:
    %
    good_hlong = find( hlong_grid <= hlong_val, 1 );
    all_good_lat = find( lat_grid <= lat_val );
    good_lat = all_good_lat(end);
    
    while ( bContinue )
       
        % Check the right, upper, and right-upper neighboring elements:
        %
        iJump = iJump + 1;
        zodi_tries = [ zodi(good_hlong-iJump, good_lat)
                       zodi(good_hlong,       good_lat+iJump)
                       zodi(good_hlong-iJump, good_lat+iJump) ];
                   
        % Grab the first one that's non-NaN:
        %
        for iLoop = 1 : 3
            if ~IsZodiNaN( zodi_tries(iLoop) )
                zodi_estimate = zodi_tries(iLoop);
                bContinue = 0;
                break;
            end
        end
    end
return
