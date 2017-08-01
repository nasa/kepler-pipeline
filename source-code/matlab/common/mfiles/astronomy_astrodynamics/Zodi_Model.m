function zodi_estimate = Zodi_Model(ra, dec, julianDate, raDec2PixObject, pixelangle)
%function zodi_estimate = Zodi_Model(ra, dec, julianDate, raDec2PixObject)
% 
% INPUTS:
%    ra               A vector of RA in degrees.
%    dec              A vector of declination in degrees.
%    julianDate       A vector of julian dates.
%    raDec2PixObject  An raDec2PixClass object
%
% OUTPUT:
%    zodi_estimate  The estaimte of the zodiacal light in V mag / pixel
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
    
    % Transform ra, dec, julianDate into heliocentricEclipticLongitude and eclipticLatitude
    %
    [heLong eLat] = ra_dec2helio_ec(raDec2PixObject, julianDate, ra*pi/180, dec*pi/180);

    heLong = heLong * 180/pi;
    eLat   = eLat   * 180/pi;

    % REFERENCE:
    % http://www.stsci.edu/instruments/wfpc2/Wfpc2_hand_current/ch6_exposuretime5.html
    %
    % Table 6.3: Sky Brightness (V mag arcsec-2) as a Function of 
    % Heliocentric Ecliptic Latitude and Longitude. "SA" denotes that 
    % the target is unobservable due to solar avoidance. 
    %
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
    eclipticLatitude   = [0 15 30 45 60 75 90];
    % Rows
    heliocentricEclipticLongitude = [180 165 150 135 120 105 90 75 60 55 30 15 0];

    % Table, apparent magnitude per square arc-sec
    % 
    % 15 July 05: Changed lat45,long15 from NaN to 22.0 and
    %                     lat45,long0  from NaN to 21.7
    % on Doug Caldwell's recommendation.
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

    % Convert to apparent magnitude per pixel
%     import gov.nasa.kepler.common.FcConstants;
%     pixelangle = FcConstants.pixel2arcsec;
    zodi = b2mag(mag2b(zodi) * pixelangle^2);

    %INTERP2 2-D interpolation (table lookup).
    %    ZI = INTERP2(X,Y,Z,XI,YI) interpolates to find ZI, the values of the
    %    underlying 2-D function Z at the points in matrices XI and YI.
    %    Matrices X and Y specify the points at which the data Z is given.

    % Turn the row/column "headings" into X and Y matrices for interp2.
    [gridX gridY] = meshgrid(eclipticLatitude, heliocentricEclipticLongitude);

    % The table is symmetric in +/- lat/long, so convert any - values to +.
    heLong = abs(heLong);
    eLat = abs(eLat);

    while (any(heLong > 360) | any(eLat>360))
        heLong(heLong > 360) = heLong(heLong > 360) - 360;
        eLat(  eLat   > 360) = eLat(  eLat   > 360) - 360;
    end

    longGt180 = find(heLong > 180);
    heLong(longGt180) = 360 - heLong(longGt180);

    latQuad4  = find(eLat >  270);
    latQuad3  = find(eLat <= 270 & eLat > 180);
    latQuad2  = find(eLat <= 180 & eLat >  90);

    eLat(latQuad4) =  360 - eLat(latQuad4);
    eLat(latQuad3) = -180 + eLat(latQuad3);
    eLat(latQuad2) =  180 - eLat(latQuad2);

        

    % Estimate the zodi
    zodi_estimate = interp2(gridX, gridY, zodi, eLat, heLong);

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

    if (any(isnan(zodi_estimate)))
        nanIndices = find(isnan(zodi_estimate) > 0);
        for ii = 1:length(nanIndices)
            index = nanIndices(ii);
            zodi_estimate(index) = getClosestNonNan(zodi, ...
                heliocentricEclipticLongitude, eclipticLatitude, ...
                heLong(index), eLat(index));
        end
    end

return

function zodiEstimate = getClosestNonNan(zodi, hlong_grid, lat_grid, hlong_val, elat_val);
    %
    % function zodi_estimate = getClosestNonNan( zodi, hlong_grid, lat_grid, hlong_val, elat_val );
    %
    % If the zodi estimate is NaN, step upwards and rightwards through the
    %   matrix until you hit a non-NaN value:
    %
    iLoop = 0;

    % Find the array element to start searching from:
    %
    good_hlong = find(hlong_grid <= hlong_val, 1, 'first');
    good_lat   = find(lat_grid   <= elat_val,  1, 'last');

    while (true)
        iLoop = iLoop+1;
        [rowOffsets colOffsets] = getUpperRightIndices(iLoop);

        for ii=1:length(rowOffsets)
            zTmp = zodi(good_hlong+rowOffsets(ii),good_lat+colOffsets(ii));
            if ~isnan(zTmp)
                zodiEstimate = zTmp;
                return;
            end
        end
    end

return

function [row col] = getUpperRightIndices(distance)
    rowOffset = -distance;
    row = zeros(1,1);
    col = zeros(1,1);
    for colOffset = 0:distance
        row(end+1) = rowOffset;
        col(end+1) = colOffset;
    end
    for rowOffsetOffset = 1:distance
        row(end+1) = rowOffset+rowOffsetOffset;
        col(end+1) = colOffset;
    end
    
    row = row(2:end);
    col = col(2:end);
return
