function orbit = generateOrbit( sOrbitType, varargin )
%
%function orbit = generateOrbit( sOrbitType, varargin )
%
% Allowed arguments (pick one):
%   ( 'Circular',  Rorb (meters), Rpri (meters), Rsec (meters), [ bRandomInclination (boolean) [ inclination (radians) ] ] )
%   ( 'Elliptical', bRandomOrbit (boolean,TRUE),  period (sec), Mpri (solar masses), Msec (solar masses), Rpri (solar radii), Rsec (solar radii) )
%   ( 'Elliptical', bRandomOrbit (boolean,FALSE), period (sec), Mpri (solar masses), Msec (solar masses), ecc, periP (3 vector),  periQ (3 vector) )
%   ( 'Elliptical', bRandomOrbit (boolean,FALSE), period (sec), Mpri (solar masses), Msec (solar masses), ecc, inclination (radians), OmegaAscendingNode (radians), omegaPeriapsis  (radians))
%
% Returns:
%   A structure with the following fields:
%
%       Eliptical orbits:
%           semilatus_p -- semilatus rectum length (meters)
%           P -- perifocal vector P
%           Q -- perifocal vector Q
%           ecc -- eccentricity
% 
%       Circular Orbit
%           Rorb -- orbital radius (meters)
%           Rpri -- radius of primary body (meters)
%           Rsec -- radius of primary body (meters)
%           inc -- inclination (radians)
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
    nvargs = numel( varargin );
    switch sOrbitType
        case 'Circular'
            %
            % Elaborate argument-reading ritual:
            %
            if nvargs < 3  |  nvargs > 5
                error( 'bad number of args for circular orbit' );
            end

            [ Rorb Rpri Rsec ]  = deal( varargin{1:3} );

            bRandomInclination = 1;
            if nvargs > 3
                bRandomInclination = varargin{4};
            end

            badval = -666 * sqrt(-1);
            if bRandomInclination
                inc = badval; % shouldn't get used, ever.  A random inc will be generated.
            else
                inc = varargin{5};
            end

            % Generate the orbit, and check the inc:
            %
            inc = generateCircularOrbit( Rorb, Rpri, Rsec, bRandomInclination, inc );
            if badval == inc
                error( 'inclination is wrong (set to deliberate badval)' );
            end

            orbit = struct(   ...
                'Rorb', Rorb, ...
                'Rpri', Rpri, ...
                'Rsec', Rsec, ...
                'inc',  inc   ...
            );
        case 'Elliptical'
            % Read in the arguments from varargin:
            %
            if nvargs < 6
                error( 'Need 6 or more args for an elliptical orbit' );
            end

            [ bRandomOrbit period_sec Mpri Msec ]  = deal( varargin{1:4} );

            % If a random elliptical orbit is requested, generate one.
            if bRandomOrbit
                if 6 ~= nvargs
                    error( 'Need 6 numerical args for random elliptical orbit' );
                end

                [ Rpri Rsec ] = deal( varargin{5:6} );
                numin_fn = @(nu,semilatus_p,ecc,periP,periQ) ...
                           magvec(getels(rvPQW(semilatus_p,ecc,nu,periP,periQ,0),1:2));
                nu = (0:.001:1)*2*pi;  % set up coarse grid for initial orbit 
                nu = nu';

                [semilatus_p, periP, periQ, ecc] = generateRandomEllipticalOrbit(  ...
                                                       period_sec, nu, Mpri, Msec, ...
                                                       numin_fn, Rpri, Rsec        ...
                                                   );
                inc = getInclination( periP, periQ );
            else
                switch nvargs
                    case 7
                        % User-supplied perifocal vectors:
                        %
                        [ ecc periP periQ ] = deal( varargin{5:7} );
                        inc = getInclination( periP, periQ );
                    case 8
                        % Orbital angles given:
                        %
                        [ ecc inc OmegaAscendingNode omegaPeriapsis ] = deal( varargin{5:8} );
                        [ periP periQ ] = getPQ( OmegaAscendingNode, omegaPeriapsis, inc );
                    otherwise
                        error( 'Bad number of args for nonrandom elliptical orbit' );
                end



                a_OrbitKm = Rorbit( get_GM( Mpri * Msun() ), get_GM( Msec * Msun() ), period_sec ) / 1000;
                semilatus_p = a_OrbitKm * (1 - ecc^2); 
            end

            orbit = struct(                 ...
                'semilatus_p', semilatus_p, ...
                'P',           periP,       ...
                'Q',           periQ,       ...
                'ecc',         ecc,         ...
                'inc',         inc          ...
            );
        otherwise
            error( [ 'Illegal orbit type: ' sOrbitType ] );
    end
return


function inc_r = generateCircularOrbit( Rorb, Rpri, Rsec, bRandomInclination, inc_r )
%
% function [light_curve, inc_d, prim_depth, sec_depth] = generateCircularOrbit( Rorb, Rpri, Rsec, bRandomInclination, inc_r )
%
% Check the orbit, generate a random inclination if requested, and convert the inclination to degrees.

        % Die if the bodies are touching:
        %
        if Rorb < (Rpri + Rsec)
            error('LightCurve: orbital radius too small, objects in contact');
        end

        if bRandomInclination
            % Generate a random inclination that shows an eclipse:
            %
            bEclipse = 0;
            while ( ~bEclipse )
                inc_r = get_random_inc();
                bEclipse = abs( Rorb*sin(inc_r) ) <= (Rpri+Rsec);
            end
        else
            ;% Using inclination given in args list
        end
        
return

function inc = get_random_inc()
    inc = (pi/2) * (rand(1)-0.5);
return

function [semilatus_p, periP, periQ, ecc] = generateRandomEllipticalOrbit( T, nu, Mpri, Msec, numin_fn, Rpri, Rsec )
        % returns a piece-wise polynomial representation for the histogram in
        %   Duquennoy and Mayor for the eccentricity of tight binaries:
        %
        ppe = hist2ppcdfe;

        %%%%%%%%%%%%%%%
        % Note: legacy orbit code uses [Km, kg, seconds] for units, above code
        % assumed [meters, kg, seconds], so new variables are defined here
        RpriKm = Rpri * Rsun_m() / 1000;
        RsecKm = Rsec * Rsun_m() / 1000;

        neclipses = 0;
        while ( 0 == neclipses )  % generate random orbits until one eclipses

            ecc = ppcdfinv(ppe,rand(1)); % draw a random eccentricity for the Duquennoy & Mayor distribution

            % assume tidally circularized orbits for periods < Tcirc
            %   the idea is to capture the physics of tidal circularization, so we
            %   don't expect elliptical orbits for short period binaries
            Tcirc = 10 * 86400; % 10 days, in seconds
            if ( T < Tcirc ) % if orbital period < Tcirc, set ecc = 0
                 ecc = 0;
%                  warning( 'Orbital period is less than Tcirc days, setting eccentricity to zero.' );
            end
            
            % generate a random orbit for a system with total mass = Mpri+Msec (scale factor in Msun units),
            % period=T, eccentricity=ecc
            [r,v, semilatus_p, periP, periQ] = Generate_Random_Orbit2(T, ecc, nu, Mpri+Msec);  

            rmag2 = magvec(r(:,1:2));  % separtion of objects on the plane of the sky
            % vmag=magvec(v) returns a column vector with the magnitude of each row of
            % v (considered to be spatial vectors)

            imins = find( (circshift(rmag2, 1) - rmag2) > 1   & ...
                          (circshift(rmag2,-1) - rmag2) > 1 );

            for j = 1:length(imins)
                %    inline function call takes 3 times as much time  according to Profiler
                %    numin(j) = fminbnd(numinstr,nu(imins(j))-diff(nu(1:2)),nu(imins(j))+diff(nu(1:2)),[],p,ecc,P, Q);
                % numin(j) in this step is identical to that from inline funcion call
                numin(j) = fminbnd(                               ...
                               numin_fn,                          ...
                               nu(imins(j)) - diff(nu(1:2)),      ...
                               nu(imins(j)) + diff(nu(1:2)),      ...
                               [], semilatus_p, ecc, periP, periQ ...
                           );

                [r2, v2] = rvPQW(semilatus_p,ecc,numin(j),periP,periQ,0);
                r2mag2 = magvec(r2(:,1:2));
                [ymin(j),jmin] = min(r2mag2); % minimum separation of objects on the sky

                if (ymin(j) < (RpriKm+RsecKm))
                    %%%%%%%%%%%%%
                    % note: I think these next two lines assume equal sized
                    % stars, probably ok for this quick estimate, as actual
                    % light curve is calculated below (DAC 23 May 2005)
                    % (eclipse_depth = overlap area during an eclipse)
                    D = ymin(j)/RpriKm;  
                    eclipse_depth(j) = (2*asin(sqrt(1-D.^2/4))-D.*sqrt(1-D.^2/4))/(2*pi); 
                    %%%%%%%%%%%%
                    vskyj = magvec(v2(jmin,1:2));
                    eclipse_dist = 2*sqrt((RpriKm+RsecKm)^2-ymin(j).^2);
                    eclipse_duration(j) = eclipse_dist/vskyj/3600; % in hours
                    
                    % Eclipse detected, count it:
                    %
                    neclipses = neclipses + 1;
                    
                    cosine_E = (ecc + cos(numin(j)) )/(1 + ecc*cos(numin(j)) );
                    radian_E = acos(cosine_E);
                    tmin(j) = (T/(2*pi)) *(radian_E - ecc*sin(radian_E));
                    % mean anomaly is (radian_E - e*sin(radian_E))
                    % eccentric anomaly is E
                    % true anomaly is nu

                    % check to see whether numin(j) and E stay in the same half-plane
                    if(numin(j) > pi)
                        radian_E = 2*pi - radian_E;
                        tmin(j) = (T/(2*pi)) *(radian_E - ecc*sin(radian_E));
                    end

                    epochs_time(j) = tmin(j)/86400; % in days
                end
            end  
            
        end
return

function inc = getInclination( periP, periQ, lookplaneX )
    
    if nargin < 3
        lookplaneX = [ 1 0 0 ];
    end
    periW = cross( periP, periQ );
    inc = acos( dot( periW, lookplaneX ) / norm( periW ) / norm( lookplaneX ) );
return

function [ P Q ] = getPQ( OmegaAscendingNode, omegaPeriapsis, inclination )
    % taken from calcrvfromels.m, in the Utilities dir:
    %
    cO = cos( OmegaAscendingNode );
    sO = sin( OmegaAscendingNode );
    co = cos( omegaPeriapsis );
    so = sin( omegaPeriapsis );
    ci = cos( inclination );
    si = sin( inclination );

    P  = [  cO*co - sO*so*ci,  sO*co + cO*so*ci, so*si ];
    Q  = [ -cO*so - sO*co*ci, -sO*so + cO*co*ci, co*si ];
return
