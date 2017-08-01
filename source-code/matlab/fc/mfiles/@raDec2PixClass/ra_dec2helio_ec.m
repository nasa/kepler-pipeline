function [hLongRadians, latRadians] = ra_dec2helio_ec(raDec2PixObject, julianTime, raRadians, decRadians)
%
% function [hLongRadians, latRadians] = ra_dec2helio_ec(raDec2PixObject, julianTime, raRadians, decRadians)
%
% Return the ecliptic latitude and helicentric ecliptic longitude
%    (target longitude - solar longitude) for an observation (or vector of
%    observations) given in the raRadians and decRadians arguments, based on the Kepler
%    postion at time T
%
% Inputs:
%   julianTime -- a 1-D vector of julian times
%   raRadians       -- a 1-D vector of RAs (in radians)
%   decRadians      -- a 1-D vector of DECs (in radians)
%   The raRadians and decRadians vectors must be the same length.  
%   If the length of raRadians/decRadians is 1, julianTime can be any nonzero length.
%   If the length of raRadians/decRadians is greater than 1, the length of julianTime must 
%     be either 1 equal to the the length of the raRadians/decRadians vectors.
%
% Outputs:
%   h_long_r   -- a 1-D vector of the heliocentric ecliptic longtitude (in radians)
%   lat_r      -- a 1-D vector of the ecliptic lattitude
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

    bRaDecBadSize = (length(raRadians) ~= length(decRadians));
    if bRaDecBadSize
        error( 'MATLAB:FC:raDec2PixClass:RaDec2HelioEc', 'ra and dec must have same lengths' );
    end
    
    if length(julianTime) > 1  && 1 == length(raRadians)
        raRadians  = repmat(ra_r,  length(julianTime), 1);
        decRadians = repmat(decRadians, length(julianTime), 1);
    end
        
    isJdWrongSize = length(raRadians) > 1 & ...
                    length(julianTime) ~= 1 & ...
                    length(julianTime) ~= length(raRadians);
    if isJdWrongSize
        error( 'MATLAB:FC:raDec2PixClass:RaDec2HelioEc', 'Jd is bad size' );
    end
           

    % Get the position of the spacecraft and normalize it:
    %
    try
        [pos vel] = get_state_vector(raDec2PixObject, julianTime);
        keplerPos = unitv(pos);
    catch
        error( 'MATLAB:FC:raDec2PixClass:RaDec2HelioEc', 'error caught retrieving kepler position' );
    end


    % Convert target RAs and DECs into LAT_target, LONG_target:
    %
    [latTargRadians longTargRadians] = Eq2Ecl(raRadians, decRadians);

    % Convert Kepler position into latitude and longitude
    %
    [longKeplerRadians, latKeplerRadians] = cart2sph(keplerPos(:,1), keplerPos(:,2), keplerPos(:,3)); %#ok

    % Invert Kepler lat/long into solar lat/long.  Also bound.
    %
    longSolRadians = bound(longKeplerRadians + pi,  0, 2*pi);

    % Bound ouput and return:
    %
    latRadians   = bound(latTargRadians,                   -pi/2, pi/2);
    hLongRadians = bound(longTargRadians - longSolRadians, 0, 2*pi);
return
