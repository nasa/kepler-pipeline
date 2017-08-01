function outputsStruct = produce_tip_output_for_target(inputsStruct)
%
% function outputsStruct = produce_tip_output_for_target(inputsStruct)
% 
% The function is a tool which can be used to make a consistent set of TIP parameters for given input parameters. It is based on the TIP
% method produce_tip_txt_file.
% This TIP method accepts input from the tipObject and produces a text file and an output struct.
% Both are as described in the tip_matlab_controller.
% 
% INPUTS:
% (e.g.)
% inputsStruct = 
% 
%                     keplerId: 8460790
%                     depthPpm: 84
%                durationHours: 12.9600
%                 orbitalPhase: 0
%      barycentricZeroEpochMjd: 55660
%              impactParameter: 0
%      transitSeparationFactor: 0
%                offsetEnabled: 0
%                 offsetArcSec: 0
%                  offsetPhase: 0
%               offsetDepthPpm: 5000000
%        transitBufferCadences: 2
%     useDefaultKicsParameters: 1
%                         logg: 0
%                         Teff: 0
%                 stellarRadii: 0
%                        FeOnH: 0
%
% OUTPUTS:
% (e.g.)
% outputsStruct = 
% 
%                       keplerId: 8460790
%                transitDepthPpm: 84
%           transitDurationHours: 12.9600
%              orbitalPeriodDays: 773.2340
%                       epochBjd: 55660
%                   eccentricity: 0
%         longitudeOfPeriDegrees: 0
%          transitSeparationDays: 0
%           transitOffsetEnabled: 0
%          transitOffsetDepthPpm: 5000000
%            transitOffsetArcsec: 0
%             transitOffsetPhase: 0
%              skyOffsetRaArcSec: 0
%             skyOffsetDecArcSec: 0 
%            sourceOffsetRaHours: 0 
%         sourceOffsetDecDegrees: 0
%         semiMajorAxisOverRstar: 354.4007
%               RplanetOverRstar: 0.0092
%                impactParameter: 0
%              stellarRadiusRsun: 1
%                stellarMassMsun: 1.0000
%            stellarLog10Gravity: 4.4378
%     stellarEffectiveTempKelvin: 5778
%         stellarLog10Metalicity: 0
%          transitBufferCadences: 2
%           singleEventStatistic: 0
%           normalizedEpochPhase: 0
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

% put in some default values that are not used in model generation
transitBufferCadences = 2;
thisSES = 0;
thisCdpp = 0; %#ok<NASGU>


% ~~~~~~~~~~~~~~~~~ hard coded parameters
% fminsearch params
SEARCH_TOLERANCE_FUN = 1e-6;
SEARCH_TOLERANCE_X = 1e-6;
% some solar values acting as defaults - we should really all be getting these from a common source!
% this logg value makes the solar mass come out right when calculated using BIG_G_CGS, SOLAR_MASS_GMS and SOLAR_RADIUS_CM from get_physical_constants_mks
DEFAULT_LOGG = 4.437803265;             
DEFAULT_TEFF = 5778;
DEFAULT_STELLAR_RADII = 1.0;
DEFAULT_FEONH = 0;
% earth/sun transit depth
EARTH_TRANSITING_SUN_PPM = 84;

% ~~~~~~~~~~~~~~~~~ retrieve physical constants
SOLAR_MASS_GMS = get_physical_constants_mks('solarMass') * 1000;
SOLAR_RADIUS_CM = get_physical_constants_mks('solarRadius') * 100;
BIG_G_CGS = get_physical_constants_mks('gravitationalConstant') * 1000;
EARTH_RADIUS_METERS = get_physical_constants_mks('earthRadius');

%  ~~~~~~~~~~~~~~~~~ retrieve units conversions
SECONDS_PER_DAY = get_unit_conversion('day2sec');
DAYS_PER_HOUR = get_unit_conversion('hour2day');


% extract parameters for this target
thisKeplerId                = inputsStruct.keplerId;
thisDuration                = inputsStruct.durationHours;                 % hours
thisImpactParameter         = inputsStruct.impactParameter;               % unitless
thisDepth                   = inputsStruct.depthPpm;                      % in ppm
thisOffsetTransitDepthPpm   = inputsStruct.offsetDepthPpm;                % ppm
thisOffsetArcSec            = inputsStruct.offsetArcSec;                  % arcsec
thisOffsetPhase             = inputsStruct.offsetPhase;                   % radians

skyOffsetRaArcSec           = inputsStruct.skyOffsetRaArcSec;             % arcsec
skyOffsetDecArcSec          = inputsStruct.skyOffsetDecArcSec;            % arcsec
sourceOffsetRaHours         = inputsStruct.sourceOffsetRaHours;           % in hours
sourceOffsetDecDegrees      = inputsStruct.sourceOffsetDecDegrees;        % in degrees

offsetEnabled               = inputsStruct.offsetEnabled;                 % logical
thisStellarRadii            = inputsStruct.stellarRadii;                  % solar units

% thisStellarMass             = inputsStruct.stellarMass;                   % solar units

thisLogg                    = inputsStruct.logg;                          % solar units
thisTeff                    = inputsStruct.Teff;                          % solar units
thisFeOnH                   = inputsStruct.FeOnH;                         % solar units 
useDefaultKicsParameters    = inputsStruct.useDefaultKicsParameters;      % logical

barycentricZeroEpochMjd     = inputsStruct.barycentricZeroEpochMjd;       % days
inputPhase                  = inputsStruct.orbitalPhase;
transitSeparationFactor     = inputsStruct.transitSeparationFactor;

% use default values for KIC entries if so configured
if useDefaultKicsParameters
    thisLogg = DEFAULT_LOGG;
    thisTeff = DEFAULT_TEFF;
    thisStellarRadii = DEFAULT_STELLAR_RADII;
    thisFeOnH = DEFAULT_FEONH;
end

% ~~~~~~~~~~~~~~~~~ calculate stellar mass in units of solar mass
thisStellarMass = ( 10.^thisLogg .* ( (SOLAR_RADIUS_CM.*thisStellarRadii).^2) ./ BIG_G_CGS ) ./ SOLAR_MASS_GMS;

% % need to generate true period from the duration for the transit generator model
% thisPeriod = ( thisDuration / (1.412 * thisStellarMass^(-1/3) * thisStellarRadii) )^3;        % in days

% need to generate true period from the duration for the transit generator model using approximation
% periodDays = k * mStarSolar * ( durationHours / rStarSolar )^3
k = pi*BIG_G_CGS*SOLAR_MASS_GMS*(3600^3)/(4*3600*24*SOLAR_RADIUS_CM^3);                         % k = 0.16698
% imperical k set by Earth transit of Sun; k = 0.16779;
thisPeriod = k * thisStellarMass * ( thisDuration / thisStellarRadii)^3;                        % in days

% convert stellar solar units to mks
thisRadius = thisStellarRadii * SOLAR_RADIUS_CM / 100;          % in m
thisMass = thisStellarMass * SOLAR_MASS_GMS / 1000;             % in kg

% estimate orbit radius
thisSemiMajorAxisOverRstar = ((( (thisPeriod*SECONDS_PER_DAY)^2 * thisMass * BIG_G_CGS / 1000 )/(4*pi^2) )^(1/3) )/thisRadius;

% Make a rough estimate of this planet radius and use to get rOverRstar estimate.
% thisRp is not used in the modeling. Only rOverRstar is important here.
thisRp = sqrt( ( thisDepth * thisStellarRadii^2 ) / EARTH_TRANSITING_SUN_PPM );
rOverRstar = thisRp * EARTH_RADIUS_METERS / thisRadius;

% refine estimate of rplanet/rstar to match the depth we want
options = optimset('fminsearch');
options.TolFun = SEARCH_TOLERANCE_FUN;
options.TolX   = SEARCH_TOLERANCE_X;
thisROverRstar = fminsearch(@(r)((1 - thisDepth/1e6) - get_transit_light_curve_for_uniform_star(thisImpactParameter,r))^2, rOverRstar, options);

% generate fake period (transit separation - transitSeparationFactor = 0 --> use real period)
simulatedTransitSeparation = transitSeparationFactor * thisDuration * DAYS_PER_HOUR;    % in days
if simulatedTransitSeparation == 0
    thisPhase = inputPhase * thisPeriod;
else
    thisPhase = inputPhase * simulatedTransitSeparation;                                % in days
end

% generate epoch in the barycentric time frame for this target
thisEpoch = barycentricZeroEpochMjd + thisPhase;

% eccentricy and longitude of perihelion set to zero in these models
thisEccentricity = 0;
thisLongitudeOfPeri = 0;

% write to the outputsStruct

outputsStruct = struct('keplerId',                  thisKeplerId,...
                        'transitDepthPpm',          thisDepth,...
                        'transitDurationHours',     thisDuration,...
                        'orbitalPeriodDays',        thisPeriod,...
                        'epochBjd',                 thisEpoch,...
                        'eccentricity',             thisEccentricity,...
                        'longitudeOfPeriDegrees',   thisLongitudeOfPeri,...
                        'transitSeparationDays',    simulatedTransitSeparation,...
                        'transitOffsetEnabled',     offsetEnabled,...                        
                        'transitOffsetDepthPpm',    thisOffsetTransitDepthPpm,...
                        'transitOffsetArcsec',      thisOffsetArcSec,...
                        'transitOffsetPhase',       thisOffsetPhase,...
                        'skyOffsetRaArcSec',        skyOffsetRaArcSec,...
                        'skyOffsetDecArcSec',       skyOffsetDecArcSec,...
                        'sourceOffsetRaHours',      sourceOffsetRaHours,...
                        'sourceOffsetDecDegrees',   sourceOffsetDecDegrees,... 
                        'semiMajorAxisOverRstar',   thisSemiMajorAxisOverRstar,...
                        'RplanetOverRstar',         thisROverRstar,...
                        'impactParameter',          thisImpactParameter,...
                        'stellarRadiusRsun',        thisStellarRadii,...
                        'stellarMassMsun',          thisStellarMass,...                     
                        'stellarLog10Gravity',      thisLogg,...
                        'stellarEffectiveTempKelvin',thisTeff,...
                        'stellarLog10Metalicity',   thisFeOnH,...
                        'transitBufferCadences',    transitBufferCadences,...
                        'singleEventStatistic',     thisSES,...
                        'normalizedEpochPhase',     thisPhase);

% included in output - used to build geometric-observable planet model                    
%     keplerId
%     transitDepthPpm
%     transitDurationHours
%     + orbitalPeriodDays
%     + *epochBjd
%     + *eccentricity
%     + *longitudeOfPeriDegrees
%     transitSeparationDays
%     transitOffsetEnabled
%     transitOffsetDepthPpm
%     transitOffsetArcsec
%     transitOffsetPhase
%     skyOffsetRaArcSec
%     skyOffsetDecArcSec
%     sourceOffsetRaHours
%     sourceOffsetDecDegrees 
%     + semiMajorAxisOverRstar
%     + RplanetOverRstar
%     + *impactParameter
%     + *stellarRadiusRsun
%     stellarMassMsun
%     stellarLog10Gravity
%     stellarEffectiveTempKelvin
%     stellarLog10Metalicity
%     transitBufferCadences  
%     singleEventStatistic
%     normalizedEpochPhase
%
% not included in output - needed to build physical planet model
%     * planetRadiusEarthRadii [scalar] planet radius (Earth radii)
%     * semimajorAxisAu        [scalar] planet semimajor axis (AU)
%
% key
%     * physical parameters
%     + geometric-observable parameters
%
% Note: The geometric-observable parameters must be self consistent if editing the TIP txt file by hand.

% These are the generating parameters for the TIP file. From these, the target data (rmsCdpp) and the kics values for a particular target
% all the parameters in the output above are generated.
% inputSES
% inputDurations
% impactParameters
% inputPhase
% offsetArcSec
% offsetPhase





                    