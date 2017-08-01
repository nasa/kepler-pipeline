function ReflectedLightSignature = generateReflectedLightCurve( OrbitalPeriod, inclination_deg, Rplanet, SamplingFreq, SimulationDays, ModelFlag, albedo )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function ReflectedLightSignature = generateReflectedLightCurve( OrbitalPeriod, inclination_deg, Rplanet, SamplingFreq, SimulationDays, ModelFlag, albedo )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function Name:  generateReflectedLightCurve.m
%
% Modification History - This can be managed by a revision control system
%
% Software level: Prototype Code
%
% Description:
%     This function uses Seager et al.'s reflected light curve function for two
%     different atmospheric models, sampling interval in hours, orbital
%     inclination I, orbital period OrbitalPeriod, albedo, number of output
%     points as to generate a light curve.
%
% Inputs:
%       OrbitalPeriod  (days)  - orbital period of CEGP (Close-in Extra Solar Giant Planet)
%       inclination_deg (deg)  - orbital inclination in degrees
%       RPlanet        (Rjup)  - planet radius in Jupiter radii (Rjupiter = 7.1492e7 m)
%       SamplingFreq   (1/day) - number of samples per day
%       SimulationDays (days)  - simulation duration
%       [ModelFlag]            - flag to indicate what reflected light model to use (see  below)
%       [albedo]               - input albedo for "simple" model (defalult=2/3)
%
% Output:
%       A structure ReflectedLightSignature with fields:
%           TimeStamps
%           TimeSeries
%           PlanetOrbitalPeriod (in days)
%           InclinationAngle
%           PlanetRadius (in Jupiter radii)
%           MeanOrbitalDistance (in AU)
%           Albedo (0 <= albedo <= 1)
%           Model (the name of the atmospheric model used)
%
% Models:
%       0 => simple model, uniform scattering (Lambert sphere) with albedo specified
%
%       1 => Seager, Whitney and Sasselov light curves 0.1 micron particle
%               size, loads unmkppSS.mat,  pp_phasefcn gives the relationship
%               between phase angle and variation of flux in micromagnitudes
%
%       2 => Seager, Whitney, and Sasselov 1.0 micron particle size,
%               loads unmkppSS.mat,  pp_phasefcn gives the relationship between
%               phase angle and variation of flux in micromagnitudes
%
%       3 => Dyudina, et al. light curves, loads  unmkppDyudina.mat.  Not
%               implemented yet.
%
%       4+=> Not implemented yet.
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

% Loads:
%       unmkppSS.mat (ModelFlag=1)
%       unmkppDyudina.mat (ModelFlag=2)
% 
%
% Calls:
%         calcafromT.m -> gmp.m
%         rad2deg.m
%         unitv.m -> magvec.m & scalecol.m
%         mag2b.m
%         AU2km.m
%
% Assumptions:
%         Assume a solar mass star.
%         x-axis points to Earth
%
% References:
% 'Detecting reflected light from close-in extrasolar giant planets with
% the KEPLER photometer' by Jon. M. Jenkins and L. R. Doyle The
% Astrophysical Journal, 595:429-445, September 2003.
%
% 'Photometric light curves and polarization of close-in extrasolar giant
% planets' by S. Seager, B.A. Whitney, and D.D. Sasselov The Astrophysical
% Journal, 540:504-520, September 2000.
%
% 'Phase Light Curves for Extrasolar Jupiters and Saturns', Dyudina, U. A.,
% Sackett, P. D., Bayliss, D. D. R., Seager, S., Porco, C. C., Throop, H.
% B., & Dones, L. 2005, ApJ, 618, 973
%
% J.Jenkins - author
% H.Chandrasekaran - added comments on 12/3/04
% D. Caldwell - modified format, separated out models
% K. Allen - refactored code 15 July 05.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Verify arguments:
    %
    % If albedo (arg 6) is not given, set it to 2/3.
    % If 4 args are given (no ModelFlag, no albedo), default to simple model
    %   (ModelFlag = 0) with albedo = 2/3
    % Error out if there are less than 4 args.
    %
    if nargin < 7, albedo    = 2/3; end % if albedo is not given, set it to 2/3
    if nargin < 6, ModelFlag =   0; end % default to the simple model
    if nargin < 5
        error( [ 'Not enough arguments! Syntax: ReflectedLightSignature =' ...
                 ' generateReflectedLightCurve( OrbitalPeriod, Rplanet, '   ...
                 'SamplingFreq, SimulationDays, [ModelFlag, [albedo]] )' ] );
    end
    
    if albedo > 1 | albedo < 0
        error( 'Illegal value: albedo is not in range [0,1].  Quitting.' );
    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up planet parameters:
    %
    RplanetKm = Rplanet   * RjupiterKm();
    RplanetAU = RplanetKm / AU2km(); % radius of planet in AU
    inc_rad   = inclination_deg* pi/180;

    % We assume a solar mass star.
    % x-axis points to Earth
    % Sampling interval SamplingInterval in hour
    % Number of output points nPoints
    % Period in days OrbitalPeriod
    % Inclination in degrees I
    % albedo is albedo (0 <= albedo <= 1)

    SamplingInterval_hr = 24 / SamplingFreq; % sampling interval in hours
    nPoints  = fix( SamplingFreq * SimulationDays );
    timestamps = ( 0:nPoints - 1)' * (SamplingInterval_hr / 24); % t in days

    % Set up orbit, compute phase angle.  Implicitly use a 1.0 solar mass star
    %   to calculate semi-major axis of orbit from the orbital period (second
    %   arg "0"):
    %
    OrbitalPeriod_sec = OrbitalPeriod * 24 * 60 * 60;
    a_AU = (1/AU2km()) * calcafromT( OrbitalPeriod_sec, 0 ); % implicitly use solar mass star (0);

    orbit = generateOrbit( 'Circular', a_AU, 0, RplanetAU, 0, inc_rad );

    theta = ( 2 * pi * timestamps / OrbitalPeriod ); % phase angle in orbit
    cosphi = get_cosphi( orbit.Rorb, theta, orbit.inc );

    % The time series should be relative, as in identically equal to 1.0
    % where no reflected light signature exists. Since 'flux_b' is the deviation 
    % from that value, add '1.0' to it to get the desired time series curve.
    %
    flux_b = 1.0 + getFlux( ModelFlag, cosphi, orbit.Rorb, orbit.Rsec, albedo );

    % Package the outgoing data into a structure:
    %
    ReflectedLightSignature = struct(                     ...
        'MeanOrbitalDistance', orbit.Rorb,                ...
        'PlanetOrbitalPeriod', OrbitalPeriod,             ...
        'InclinationAngle',    orbit.inc * 180/pi,        ...
        'PlanetRadius',        orbit.Rsec,                ...
        'Albedo',              albedo,                    ...
        'Model',               getModelName( ModelFlag ), ...
        'TimeStamps',          timestamps,                ...
        'TimeSeries',          flux_b                     ...
    );
return

function RjupiterKm = RjupiterKm
    RjupiterKm = 71492; % Jupiter radius in km
return

function [ pp_phasefcn RmodelPlanet a_modelOrbit_AU ] = getModelData( ModelFlag )
%
% function [ pp_phasefcn RmodelPlanet a_modelOrbit_AU ] = getModelData( ModelFlag )
%
% See getModelName for model names

    switch ModelFlag
        case 1  % Seager, Whitney and Sasselov light curves 0.1 micron
            % reflected light curve from planets with atmospheric particle size  = 0.1 micron
            load( 'unmkppSS'); 
            pp = mkpp(brp1, cop1); %brp1 and cop1 are saved in unmkppSS

            RmodelPlanet     = 1.2;   % [Rjupiter] S & S assumed    planet radius for model light curves
            a_modelOrbit_AU  = 0.051; % [AU]       S & S assumed orbital distance for model light curves
        case 2 % Seager, Whitney and Sasselov light curves - 1 micon
            % reflected light curve from planets with atmospheric particle size  = 1 micron
            load( 'unmkppSS'); 
            pp = mkpp(br1, co1);  %br1 and co1 are saved in unmkppSS

            RmodelPlanet     = 1.2;   % [Rjupiter] S & S assumed    planet radius for model light curves
            a_modelOrbit_AU  = 0.051; % [AU]       S & S assumed orbital distance for model light curves
        case 3 % load Dyudina, et al. light curves
            error('Dyudina model not yet supported');
            load('unmkppDyudina');

            RmodelPlanet     = 1.0;   % [Rjupiter] Dyudina assumed planet radius for model light curves
            a_modelOrbit_AU  = 0.051; % [AU] Dyudina assumed orbital distance for model light curves
        otherwise
            error(['Model ',int2str(ModelFlag),' not yet supported']);
    end

    % the following lines extract the breakpoints(x axis) and their y axis
    % values; the last column of the polynomial coefficients gives the values
    % at the break points except for the value at end point. That value is
    % added by the third statement
    %
    [br,co] = unmkpp( pp );
    br      = br(:);
    val     = [ co(:,end); ppval(pp,br(end)) ];

    pp_phasefcn = [ br, val ];
return

function model = getModelName( ModelFlag )
    switch ModelFlag
        case 0, model = 'Simple';
        case 1, model = 'Seager_Sasselov_0.1Micron';
        case 2, model = 'Seager_Sasselov_1Micron';
        case 3, model = 'Dyudina';
        otherwise
            error( [ 'model ' int2str( ModelFlag ) ' is not implemented' ] );
    end
return

function flux_b = getFlux( ModelFlag, cosphi, a_m, Rplanet_m, albedo )

    a_AU      = (a_m       / 1000) / AU2km();
    RplanetAU = (Rplanet_m / 1000) / AU2km();
    if strcmp( 'Simple', getModelName( ModelFlag ) )
        % Simple model

        % Compute fraction of sky blocked by planet, as seen from the star
        %   integrate over the area of the cap covered by the planet at
        %   radius a*cos(beta) and divide by the total area of a sphere of
        %   the same radius [4pi (a*cos(beta))^2]
        %                   /2pi   /beta
        %   Acap  =   |         |           (a cos(beta))^2 sin(theta) d_theta d_phi
        %                  /0     /0
        %
        beta     = asin( RplanetAU / a_AU );
        frac_sky = (1 - cos( beta )) / 2;
        % fraction of lit planet face seen by a distant observer
        frac_lit_planet = ((1+cosphi) / 2);

        flux_b = albedo * frac_sky * frac_lit_planet;
    else 
        % Spline function from the various scattering models
        %
        [ pp_phasefcn RmodelPlanet a_modelOrbit_AU ] = getModelData( ModelFlag );

        phi = get_phi ( cosphi, pp_phasefcn );

        % determine values of phase function at orbital points specified by
        % the angle phi. Model values are in micro-magnitudes (see Seager,
        % et al.)
        flux_b = mag2b( interp1( pp_phasefcn(:,1), pp_phasefcn(:,2), phi ) * 1e-6 ) - 1; 

        % scale model light curves by planet area and 1/distance^2,
        % note: radii are in Km here, a_modelOrbit_AU and semi-major axis
        % (a_AU) is in AU.
        %
        RplanetKm = RplanetAU * AU2km();
        RmodelPlanetKm      = RmodelPlanet * RjupiterKm ();
        planet_area_ratio   = RplanetKm^2  / RmodelPlanetKm^2;
        SemiMajorAxis_ratio = a_AU         / a_modelOrbit_AU;
        flux_b =  flux_b * (planet_area_ratio / SemiMajorAxis_ratio^2);
    end

return

function cosphi = get_cosphi( a_orbit, theta, inc )
    x_vec = a_orbit * sin(theta) * cos(inc);
    y_vec = a_orbit * cos(theta);
    z_vec = a_orbit * sin(theta) * sin(inc);

    % compute phase angle
    xhat3  = unitv( [ x_vec, y_vec, z_vec ] );
    cosphi = -xhat3(:,1);
return

function phi = get_phi( cosphi, pp_phasefcn )
    phi = acos( cosphi ) * rad2deg; % convert cosphi to angle in deg
    phi = min( max(      pp_phasefcn(:,1)         ), ...
               max( min( pp_phasefcn(:,1) ), phi  ) );
return
