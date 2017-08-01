function [light_curve,ecc,inc_d,timestamps,prim_depth,sec_depth] = generateLightCurve(radii, mass, limbDark, per, i_on, e_on, dt, varargin )
%
% function [light_curve,ecc,inc_d,timestamps,prim_depth,sec_depth] = generateLightCurve(radii, mass, limbDark, per, i_on, e_on, dt, varargin )
%
% generateLightCurve returns a limb-darkened light curve for a transiting
% planet, or eclipsing binary with star radius Rpri, planet radius Rsec, and period per.
%
% Requires additional m-files:
%   quadeclipse, eclipse  % light curve integrators
%   getels, rvPQW, gmp, % orbit calculations
%   kepler, c_of_z, s_of_z, 
%   hist2ppcdfe, ppcdfinv
%
% Function Name:  generateLightCurve.m
%
% Modification History - This can be managed by a revision control system
%
% Software level: Research Code
%
% Description:  This function returns a light curve for two objects (primary &
% secondary). The code generates light curves for eclipsing binary stars,
% or transiting planets (Msec=0). The star luminosities are assumed proportional
% to M^3.2 (e.g., Mihalas & Binney,  "Galactic Astronomy", p. 113). Orbits
% can be specified to be circular e_on=0, in which case they can have
% inclination of 90 (edge-on) i_on=0, a random inclination i_on=1, or a
% specified inclination i_on=88.2. For eccentric orbits, the i_on flag is
% ignored and a random eclipsing orbit is generated.
%
%
% Input:
%       radii - 2-vector radius of primary star and secondary [Rpri, Rsec]  {R_sun}
%       mass - 2-vector mass of primary star & secondary star [Mpri, Msec]  {M_sun}
%       limbDark - 2-vector limb darkening coefficients of primary & secondary [cpri,csec]
%       period -  orbital period of binary system in days
%       i_on - logical flag to allow for inclined orbits [optionally inclination angle if different from 1]
%       e_on - logical flag to allow for eccentric orbits
%       dt - sampling period in minutes 
%       [ nTimeFactor ] - optional parameter to specify how many samplings
%           to include in one point on the light curve.
%       [ {elements}  ] - optional specification of orbital elements in
%         a cell array, either as { eccentricity, PerifocalVectorP,
%         PerifocalVectorQ }, or as { eccentricity, inclination,
%         AscendingNodeAngle, PeriapsisAngle }.
%       [ n_samp ] - the number of light curve samples to calculate.  If
%         left blank, a full period will be used.  This can be specified
%         after the {elements} cell array, or if {elements} is not specified,
%         after nTimeFactor.
%
%
% Output:
%       light_curve - fractional flux light curve with period/dt samples
%       ecc - eccentricity [0-1]
%       inc - orbital inclination [degrees, 90 => edge-on]
%       timestamps - time stamps [days from first sample]
%       prim_depth - fractional depth of primary eclipse (secondary in front of primary)
%       sec_depth - fractional depth of secondary eclipse (primary in front of secondary)
%
% History: This script was adapted from Kepler FOV evaluation simulation.
% Author: Jon Jenkins -(montecarlo_orbit2.m, received as email attachment on 8/09/04)
%
% H.Chandrasekaran - this version created on 5/1/05 for injecting science data into ETEM
% 
% D. Caldwell  23 May 2005 - modified to output a limb-darkened light curve for
% eclipsing binaries or transiting planets.
%
% K. Allen  27 June 2005-- Code refactoring, adding user-defined ellilptical orbits,
% and time-averaging of points (to better simulate detector operation).
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parse inputs:
    %
    if nargin < 7
        error('generateLightCurve:  requires at least seven (7) inputs');
    end

    % Get the input variables. 
    %   Variable dt (the sampling period) is given in units of minutes,
    %   returned in units of days (per is also in days):
    % Elaborate handling of varargin is done because passing varargin
    %   into a function causes it to morph from a whatever-element-length
    %   cell array into a one-element cell array with a whatever-element-length
    %   cell array as the first element.  Probably a cleaner way to do this.
    %
    nvargs = length( varargin );
    if nvargs < 3, varargin{3} = 'null'; end
    if nvargs < 2, varargin{2} = 'null'; end
    if nvargs < 1, varargin{1} = 'null'; end
    
    [ bRandomOrbit bOrbitAngles n_samp nTimeFactor Rpri Rsec       ... 
      Mpri GMpri Msec GMsec cpri csec pers e_on i_on inc dt        ...
      ecc  OmegaAscendingNode omegaPeriapsis P Q ] =               ... % vararg outputs
          parse_args( radii, mass, limbDark, per, i_on, e_on, dt,  ...
                      nvargs, varargin{1}, varargin{2}, varargin{3}  ); % vararg  inputs



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Perform setup calculations
    %
    
    % Estimate relative luminosities of two stars
    Lpri = Mpri^3.2;   % crude estimate of luminosity, OK for main sequence only
    Lsec = Msec^3.2;   %
                       % Note: R = Rsun_m*(M/Msun)^0.7 should also hold, however
                       %   there is currently no check for this in this program
                       %   See, e.g., Mihalas & Binney, "Galactic Astronomy", p. 113
    lum_ratio_f = Lsec / Lpri;

    % set up array of time stamps
    if 0 == n_samp % if no value was passed in, return one full period
        n_samp = fix( per / dt );
    end
    



    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do the work:
    %

    % Generate light curves for circular orbits:
    %
    good_curve = 0;
    while ~good_curve
        % Increase number of points by a factor here to do
        %   time-averaging (K. Allen 15 June 2005):
        %
        clear timestamps % have to compute timestamps every time 'cause it's tranposed by called routines
        timestamps = dt/nTimeFactor*(0:(n_samp*nTimeFactor)-1);  % array of time stamps in days
        tph = mod(timestamps,per);  % array of phases (seconds)
        
        if ~e_on
            Rorb = Rorbit( GMpri, GMsec, pers ) / Rsun_m (); % orbital radius in units of Rsun

            if 1 == i_on
                orbit = generateOrbit( 'Circular', Rorb, Rpri, Rsec, 1 );
            else
                orbit = generateOrbit( 'Circular', Rorb, Rpri, Rsec, 0, inc );
            end

            [ light_curve prim_depth sec_depth ]  = ...
                generateCircularLightCurve( ...
                    orbit.Rorb, orbit.Rpri, orbit.Rsec, ...
                    timestamps, tph, per,...
                    orbit.inc, ...
                    cpri, csec, lum_ratio_f );
        % Or elliptical orbits:
        %
        else
            if bRandomOrbit
                orbit = generateOrbit( 'Elliptical', bRandomOrbit, pers, Mpri, Msec, Rpri, Rsec );
            else
                if bOrbitAngles
                    orbit = generateOrbit( 'Elliptical', bRandomOrbit, pers, Mpri, Msec, ecc, inc, OmegaAscendingNode, omegaPeriapsis );
                else
                    orbit = generateOrbit( 'Elliptical', bRandomOrbit, pers, Mpri, Msec, ecc, P, Q );
                end
            end

            % Use the current orbit to generate a light curve:
            %
            [ light_curve inc_d timestamps prim_depth sec_depth ] =      ...
                LightCurveFromEllipticalOrbit( orbit.semilatus_p, orbit.P, orbit.Q, orbit.ecc, timestamps, Mpri, Msec, Rpri, Rsec, cpri, csec, lum_ratio_f );

            % Problem: generateRandomEllipticalOrbit isn't always returning eclipsing
            %   orbits.  Temporary solution:  a big kludge to continue generating
            %   orbits until an eclipsing one is found (if random orbits were requested):
            %
            while ( min( light_curve ) >= 1   &  bRandomOrbit )
                orbit = generateOrbit( 'Elliptical', bRandomOrbit, pers, Mpri, Msec, Rpri, Rsec );
                [ light_curve inc_d timestamps prim_depth sec_depth ] =      ...
                    LightCurveFromEllipticalOrbit( orbit.semilatus_p, orbit.P, orbit.Q, orbit.ecc, timestamps, Mpri, Msec, Rpri, Rsec, cpri, csec, lum_ratio_f );
            end
        end
        inc_d = 90-abs(orbit.inc*180/pi);

        [ timestamps light_curve ]  = rebin_output_data( timestamps, light_curve, nTimeFactor );
        
        flat_window = 5;
        if (min(light_curve(1:flat_window)) == 1 & min(light_curve(end - flat_window:end)) == 1)
            good_curve = 1;
        end
    end
return

function [ timestamps light_curve ] = rebin_output_data( timestamps, light_curve, nTimeFactor )
    % Rebin the light_curve and timestamps back to the requested
    %   time resolution. (K. Allen, 15 June 05)
    %
    out_timestamps  = zeros( (length(timestamps) / nTimeFactor), 1 );
    out_light_curve = zeros( (length(timestamps) / nTimeFactor), 1 );

    for iLoop = 1 : (length(timestamps) / nTimeFactor)
        iStart = (iLoop-1) * nTimeFactor + 1;
        iStop  = iStart    + nTimeFactor - 1;
        
        out_timestamps(iLoop) = timestamps( iStop );
        out_light_curve(iLoop) = mean( light_curve( iStart : iStop ) );
    end
    timestamps  = out_timestamps;
	light_curve = out_light_curve;
return

function [ bRandomOrbit bOrbitAngles n_samp nTimeFactor Rpri Rsec              ... 
           Mpri GMpri Msec GMsec cpri csec pers e_on i_on inc dt               ...
           ecc OmegaAscendingNode omegaPeriapsis P Q ] =                       ... % vararg outs
               parse_args( radii, mass, limbDark, per, i_on, e_on, dt, nvargs, ...
                            vararg1, vararg2, vararg3  )

    % get the radii in units of Rsun
    if 2 ~= numel( radii )
        error('generateLightCurve: must input two element radius vector');
    end
    Rpri = radii(1);
    Rsec = radii(2);
    if Rpri<=0 | Rsec<=0
        error('generateLightCurve: radii must both be non-zero');
    end


    % get G* masses in MKS units
    %
    [ Mpri GMpri Msec GMsec ] = get_M_and_GM( mass );


    % get the limb darkening coefficients, assume no limb darkening if
    % secondary value is not given.
    cpri = limbDark(1);
    csec = 0;
    if 2 == numel( limbDark )
        csec = limbDark(2);
    end

    if (cpri<0 | csec<0 | cpri>1 | csec>1)
        error('generateLightCurve: limb darkening coefficients must be 0<= c <= 1')
    end

    pers = per*24*3600; % period in seconds

    % parse the logical inputs
    % this is unecessary, but is reserved for future use
    if 1 == i_on % inclined orbit flag on allows for random inclination    
        inc = -666;
    elseif i_on > 1
        inc = abs(90-i_on)*pi/180;  % convert to edge-on angle in radians. 
                  % Note: internally, i is measured up from the plane perpendicular to the plane of the sky, edge-on => i=0
        i_on = 0; % fixed inclination orbits
    elseif 0 == i_on
        inc = 0;
    elseif i_on < 1
        error('you can''t fool me, input a reasonable value')
    end

    if e_on
        e_on = 1;  % allow eccentric orbits
        ecc  = -666; % Kester: fake value to provide something to return.
    else
        e_on = 0;  % circular orbits
        ecc  = 0;
    end

    % set time sampling to days
    dt = dt/(60*24);  % set units to days


    % This var is used to determine if an elliptical orbit should be
    %   randomly generated or not.  This var is never used if e_on is
    %   not true.  Setting it true here to deal with the case of a seven
    %   argument call, which is by default asking for a random orbit, since
    %   the user has not supplied orbital elements as argment 8.
    %
    bRandomOrbit = 1;

    bOrbitAngles = 0;
    n_samp       = 0;
    nTimeFactor  = 5;
    
    % Defaults for the orbital elements, in case they're not set.
    OmegaAscendingNode = -666;
    omegaPeriapsis     = -666;
    P                  = -666;
    Q                  = -666;


    % Parse varargs. See beginning of file for permitted argument combinations.
    %
    
    % If there are three varargins, #3 is n_samp
    %
    if nvargs > 2
        n_samp = vararg3;
    end

    % If there are two or more varargs, #2's identity is determined by its
    %   length:
    %
    if nvargs > 1
        
        switch length( vararg2 )
            case 1
                % No orbit specified.  Will generate random orbit.
                n_samp = vararg2;
            case 3
                % Perifocal vectors have been supplied to define the orbit
                %   Set bRandomOrbit to FALSE, and use the default
                %   bOrbitAngles, which is FALSE.
                %
                bRandomOrbit = 0; 
                
                ecc          = vararg2{1};
                P            = vararg2{2};
                Q            = vararg2{3};
            case 4
                % Orbital angles have been specified to define the orbit.
                %   Set bRandomOrbit to false, and set bOrbitAngles to
                %   TRUE.
                bRandomOrbit       = 0;
                bOrbitAngles       = 1;
                
                ecc                = vararg2{1};
                inc                = vararg2{2};
                OmegaAscendingNode = vararg2{3};
                omegaPeriapsis     = vararg2{4};
            otherwise
                error( 'Error reading in varargin. Problem in orbital elements?' );
        end
    end

    % If there is one or more varargin, #1 is nTimeFactor, which must be an
    %   integer:
    %
    if nvargs > 0
        nTimeFactor = vararg1;
        if nTimeFactor ~= fix( nTimeFactor )
            error( 'Must have integer nTimeFactor' );
        end
    end
    
return

function [ Mpri GMpri Msec GMsec ] = get_M_and_GM( mass )
%
%function [ Mpri GMpri Msec GMsec ] = get_M_and_GM( mass )
% get G* masses in MKS units 
%
    GMsun = get_GM( Msun() ); % m^3 s^-2

    Mpri = mass(1);
    GMpri = Mpri*GMsun;
    if 2 == numel( mass )
        Msec = mass(2);
        GMsec = Msec*GMsun;
    else
        Msec = 0; % assume zero mass secondary if value not given
        GMsec = Msec*GMsun;  
    end
    if Mpri <= 0  % check for zero or negative primary mass
        error('generateLightCurve: Primary star mass must be > 0')
    end
    if Msec < 0  % check for negative secondary mass
        error('generateLightCurve: Secondary mass must be >=0')
    end
return;

function GM_km = get_GM_km( M )
    GM_km = get_GM( M ) / 1000^3;
return

function [ light_curve i timestamps prim_depth sec_depth ] = LightCurveFromEllipticalOrbit( p, P, Q, ecc, timestamps, Mpri, Msec, Rpri, Rsec, cpri, csec, lum_ratio_f )

    timestamps = timestamps'*3600*24 ;  % time in seconds, timestamps needs to be a column vector for kepler.m

    % determine initial starting position & velocity for eclipsing orbit
    nu0 = 0;  %initial orbit anomaly
    [r0, v0] = rvPQW(p,ecc,nu0,P,Q,0); 

    tphase=0;

    % Note: starting in an eclipse is OK.  Logic to prevent that has been removed.
    %

    % determine G times total system mass in Km^3s^-2
    GMtotKm = get_GM_km( Mpri ) + get_GM_km( Msec );
    % call kepler.m with optional system mass instead of body number to
    % generate full orbit as a function of time, with r [Km] & v [Km/s]
    [r,v]=kepler(timestamps(1),r0,v0,timestamps+tphase,GMtotKm,p,ecc);

    rmag2 = magvec(r(:,1:2)); % separation of objects in the plane of the sky, in Km

    % get inclination angle
    [rm,im]=min(rmag2);  % minimum separation
    rorb = sqrt(r(im,1)^2 + r(im,2)^2 + r(im,3)^2);
    i = atan2(rm,rorb); % inclination in radians
    i = 90-abs(i*180/pi);

    rsep = rmag2'./(Rsun_m()/1000);  % separation in units of Rsun

    % separate orbit into two parts: one with secondary in front of
    % primar, the other with primary in front of secondary. The
    % separation is done by using the projection of r out of the plane
    % of the sky, i.e., along the z-axis [r(3)]
    i_prim = find( r(:,3) <=0 );
    i_sec  = find( r(:,3) >0 );

    [ light_curve prim_depth sec_depth ]  = generateEllipticalLightCurve( Rpri, Rsec, rsep, cpri, csec, i_prim, i_sec, lum_ratio_f, timestamps );


    timestamps=timestamps'/(3600*24);  % transpose to match circular orbit output, also in units of days

    % cheesy way to make sure that primary really is the primary, I
    % should be doing this using the orbit information! (DAC 6 Jun 2005)
    if sec_depth > prim_depth
        [ sec_depth prim_depth ] = deal( prim_depth, sec_depth );
    end
return

function lc = get_lightcurve1( Rpri, Rsec, dist, ld_coeff, lum_ratio )
    %
    % calculate light curve for first 1/2 period

    % Generate the light curve and correct for luminosity of secondary
    %
    lc_offset = quadeclipse( Rpri, Rsec, dist, ld_coeff );
    lc_uncorrected = 1 - lc_offset;    
    lc = ( lc_uncorrected + lum_ratio )/ ( 1 + lum_ratio );
return

function lc = get_lightcurve2( Rpri, Rsec, dist, ld_coeff, lum_ratio )
    %
    % calculate light curve for second 1/2 period

    if 0 == lum_ratio 
        lc = ones( size( dist ) );
        return;
    end

    % Generate the light curve and correct for luminosity of primary:
    %
    lc_offset = quadeclipse( Rsec, Rpri, dist, ld_coeff );
    lc_uncorrected = 1 - lc_offset;
    lc = (lc_uncorrected+1/lum_ratio) / (1+1/lum_ratio); 
return


function [ light_curve prim_depth sec_depth ]  = generateEllipticalLightCurve( Rpri, Rsec, rsep, cpri, csec, i_prim, i_sec, lum_ratio_f, t )

    % calculate light curve for each 1/2 period
    light_curve1 = get_lightcurve1( Rpri, Rsec, rsep(i_prim), cpri, lum_ratio_f );
    light_curve2 = get_lightcurve2( Rpri, Rsec, rsep(i_sec ), csec, lum_ratio_f );

    % crude primary eclipse depth estimate, replace w/ fit to bottom of eclipse
    %
    prim_depth = 1 - min(light_curve1);  
    sec_depth  = 1 - min(light_curve2); 

    light_curve = combine_light_curves( size(t), i_prim, i_sec, light_curve1, light_curve2 );
return

function [ light_curve prim_depth sec_depth ]  = generateCircularLightCurve( Rorb, Rpri, Rsec, t, tph, per, inc, cpri, csec, lum_ratio_f )

    % Calc the indicies and elements for the two orbit halves (first half of
    %   orbit, secondary in front of primary, second half of orbit, primary in
    %   front of secondary, only if secondary is luminous):
    %
    i_prim = find( tph <= per/2 );
    i_sec  = find( tph >  per/2 );

    line_of_sight_dist1 = line_of_sight_distance( Rorb, t(i_prim), per, inc );
    line_of_sight_dist2 = line_of_sight_distance( Rorb, t(i_sec ), per, inc );

    % calculate light curve for 1/2 period
    light_curve1 = get_lightcurve1( Rpri, Rsec, line_of_sight_dist1, cpri, lum_ratio_f );
    light_curve2 = get_lightcurve2( Rpri, Rsec, line_of_sight_dist2, csec, lum_ratio_f ); %, t2, per, inc, Rorb );

    % crude primary eclipse depth estimate, replace w/ fit to bottom of eclipse
    %
    prim_depth = 1 - min(light_curve1);  
    sec_depth  = 1 - min(light_curve2);
                                            
    light_curve = combine_light_curves( size(t), i_prim, i_sec, light_curve1, light_curve2 );
return

function dist = line_of_sight_distance( Rorb, time, per, inc )
    %
    % function dist = line_of_sight_distance( Rorb, time, per, inc )
    %
    % determine the distance across line of sight as a function of time
    %
    theta = 2*pi*time/per;
    dp = Rorb * cos(theta);              % in-plane distance
    di = Rorb * sin( inc * sin(theta));  % out-of-plane distance
    dist = sqrt(dp.^2 + di.^2);
return

function lc = combine_light_curves( size_t, i_prim, i_sec, lc1, lc2 )
    lc = zeros( size_t );
    lc(i_prim) = lc1; % time stamps with secondary in front of primary
    lc(i_sec)  = lc2; % time stamps with primary in front of secondary
return

