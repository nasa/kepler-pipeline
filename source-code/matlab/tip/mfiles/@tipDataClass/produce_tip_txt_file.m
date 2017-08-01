function outputsStruct = produce_tip_txt_file(tipDataObject)
%
% function outputsStruct = produce_tip_txt_file(tipDataObject)
% 
% This TIP method accepts input from the tipObject and produces a text file and an output struct.
% Both are as described in the tip_matlab_controller.
% 
% INPUTS:   tipDataObject == [tipDataObject]  object containing data to be processed
%
% OUTPUTS:  outputsStruct is a structure with the following fields:
%               skyGroupId                              == [int]        sky group indentifier
%               transitInjectionParametersFileName      == [char]       csv text filename where the parameters are written
%               randomNumberSeed                        == [uint32]     seed used to initialize random number stream
%             each of the following is an nTargets x 1 array:
%               parametersProduced          == [logical]    true if parameters were produced for this target
%               keplerId                    == [int]        kepler id from kics
%               transitDepthPpm             == [double]     depth of simulated transits
%               transitDurationHours        == [double]     duration of simulated transits
%               orbitalPeriodDays           == [double]     period to determine shape of simulated transits
%               epochBjd                    == [double]     epoch of simulated transits
%               eccentricity                == [double]     eccentricity of simulated orbit
%               longitudeOfPeriDegrees      == [double]     longitude of perihelion of simulated transits
%               transitSeparationDays       == [double]     period of simulated transits
%               transitOffsetEnabled        == [logical]    enables transiting background object
%               transitOffsetDepthPpm       == [double]     depth of transiting background object
%               transitOffsetArcsec         == [double]     offset magnitude of transiting background object
%               transitOffsetPhase          == [double]     offset phase of transiting background object measured from +ra axis
%               skyOffsetRaArcSec           == [double]     offset magnitude of transiting background object in the ra direction on the sky
%               skyOffsetDecArcSec          == [double]     offset magnitude of transiting background object in the dec direction on the sky
%               sourceOffsetRaHours         == [double]     location of transiting background object in ra in hours
%               sourceOffsetDecDegrees      == [double]     location of transiting background object in dec in degrees
%               semiMajorAxisOverRstar      == [double]     axis of orbital ellipse
%               RplanetOverRstar            == [double]     planet size ratio
%               planetRadiusREarth          == [double]     planet size in Earth units
%               impactParameter             == [double]     impact parameter of orbit
%               stellarRadiusRsun           == [double]     radius of target star
%               stellarMassMsun             == [double]     mass of target star
%               stellarLog10Gravity         == [double]     log g of target star
%               stellarEffectiveTempKelvin  == [double]     effective temperature of target star
%               stellarLog10Metalicity      == [double]     metalicity of target star
%               transitBufferCadences       == [int]        number of cadences to buffer duration edges by when calling transit generator
%               singleEventStatistic        == [double]     single event statistic expected
%               normalizedEpochPhase        == [double]     phase of transit epoch relative to transit separation
% 
% The text file produced is in csv format with a single header row and contains the following parameters for all targets which produced
% valid parameters: 
%     keplerId
%     transitDepthPpm
%     transitDurationHours
%     orbitalPeriodDays
%     epochBjd
%     eccentricity
%     longitudeOfPeriDegrees
%     transitSeparationDays
%     transitOffsetEnabled
%     transitOffsetDepthPpm
%     transitOffsetArcsec
%     transitOffsetPhase
%     skyOffsetRaArcSec
%     skyOffsetDecArcSec
%     sourceOffsetRaHours
%     sourceOffsetDecDegrees     
%     semiMajorAxisOverRstar
%     RplanetOverRstar
%     planetRadiusREarth
%     impactParameter
%     stellarRadiusRsun
%     stellarMassMsun
%     stellarLog10Gravity
%     stellarEffectiveTempKelvin
%     stellarLog10Metalicity
%     transitBufferCadences  
%     singleEventStatistic
%     normalizedEpochPhase
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


% hard coded parameters
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

% set options for fminsearch
options = optimset('fminsearch');
options.TolFun = SEARCH_TOLERANCE_FUN;
options.TolX   = SEARCH_TOLERANCE_X;


% retrieve physical constants
SOLAR_MASS_GMS = get_physical_constants_mks('solarMass') * 1000;
SOLAR_RADIUS_CM = get_physical_constants_mks('solarRadius') * 100;
BIG_G_CGS = get_physical_constants_mks('gravitationalConstant') * 1000;
EARTH_RADIUS_METERS = get_physical_constants_mks('earthRadius');

% retrieve units conversions
SECONDS_PER_DAY = get_unit_conversion('day2sec');
DAYS_PER_HOUR = get_unit_conversion('hour2day');
HOURS_PER_SECOND = get_unit_conversion('sec2hour');
DEGREES_PER_RADIAN = get_unit_conversion('rad2deg');
DEGREES_PER_HOUR = 2 * pi * DAYS_PER_HOUR * DEGREES_PER_RADIAN;
DEGREES_PER_ARCSEC = HOURS_PER_SECOND;


% retrieve input/output filenames
OUTPUT_FILENAME = tipDataObject.parameterOutputFilename;
TIP_STATE_FILENAME = tipDataObject.tipStateFilename;

% extract simulation parameters
simulatedTransitsConfigurationStruct = tipDataObject.simulatedTransitsConfigurationStruct;
generatingParamSetName          = simulatedTransitsConfigurationStruct.generatingParamSetName;
offsetEnabled                   = simulatedTransitsConfigurationStruct.offsetEnabled;
offsetTransitDepth              = simulatedTransitsConfigurationStruct.offsetTransitDepth;
transitSeparationFactor         = simulatedTransitsConfigurationStruct.transitSeparationFactor;
useDefaultKicsParameters        = simulatedTransitsConfigurationStruct.useDefaultKicsParameters;
transitBufferCadences           = simulatedTransitsConfigurationStruct.transitBufferCadences;


% retrieve input parameters
inputParams = get_tip_input_parameters( tipDataObject );

% retrieve selected target indices
targetIndices = inputParams.targetIndices;

% extract target data from object and trim to targets of interest
skyGroupId = tipDataObject.skyGroupId;
targets = tipDataObject.targetStarDataStruct(targetIndices);
keplerId         = colvec([targets.keplerId]);
targetRaHours    = colvec([targets.raHours]);
targetDecDegrees = colvec([targets.decDegrees]);
nTargets         = length(targets);

% convert kepler time epoch zero to barycentric equivalent for each target
epochZeroTimeMjd = simulatedTransitsConfigurationStruct.epochZeroTimeMjd;
raDec2PixObject = raDec2PixClass( tipDataObject.raDec2PixModel, 'one-based' );
barycentricZeroEpochMjd = kepler_time_to_barycentric(raDec2PixObject, targetRaHours(:), targetDecDegrees(:), epochZeroTimeMjd );

% extract stellar parameters from KIC for selected targets and ensure valid values
kics             = tipDataObject.kics(targetIndices);
logg            = ([kics.log10SurfaceGravity]);
Teff            = ([kics.effectiveTemp]);
stellarRadii    = ([kics.radius]);
FeOnH           = ([kics.log10Metallicity]);
logg            = colvec([logg.value]);
Teff            = colvec([Teff.value]);
stellarRadii    = colvec([stellarRadii.value]);
FeOnH           = colvec([FeOnH.value]);

% use default values for all KIC entries if so configured else set any invalid KIC values to defaults
if useDefaultKicsParameters
    logg(:) = DEFAULT_LOGG;
    Teff(:) = DEFAULT_TEFF;
    stellarRadii(:) = DEFAULT_STELLAR_RADII;
    FeOnH(:) = DEFAULT_FEONH;
else
%     logg( logg <= 0 | isnan(logg) )                         = DEFAULT_LOGG; 
    logg(isnan(logg) )                                      = DEFAULT_LOGG;   
    Teff( Teff <= 0 | isnan(Teff) )                         = DEFAULT_TEFF;
    stellarRadii( stellarRadii <= 0 | isnan(stellarRadii) ) = DEFAULT_STELLAR_RADII;
    FeOnH( FeOnH <= -99 | isnan(FeOnH) )                    = DEFAULT_FEONH;
end



% calculate stellar mass for all targets in units of solar mass
stellarMass = ( 10.^logg .* ( (SOLAR_RADIUS_CM.*stellarRadii).^2) ./ BIG_G_CGS ) ./ SOLAR_MASS_GMS;

% convert stellar solar units to mks
stellarRadiiMks = stellarRadii .* SOLAR_RADIUS_CM ./ 100;           % in m
stellarMassMks  = stellarMass .* SOLAR_MASS_GMS ./ 1000;            % in kg

% extract input parameters
impactParameters    = inputParams.impactParameters;
inputPhase          = inputParams.inputPhase;
offsetArcSec        = inputParams.offsetArcSec;
offsetPhase         = inputParams.offsetPhase;

% select generating param set dependent parameters
switch generatingParamSetName    
    case 'sesDurationParamSet'
        inputSES       = inputParams.inputSES;                                                            % dimensionless
        inputDurations = inputParams.inputDurations;                                                      % in hours        
        % orbital period from duration, stellar mass and radii
        orbitalPeriodDays = ( inputDurations ./ (1.412.*stellarMass.^(-1/3) .* stellarRadii) ).^3;        % in days        
        % initial rOverRStar and planetRadiusREarth w/nan
        rOverRStar = nan(size(keplerId));
        planetRadiusREarth = nan(size(keplerId));
    case 'periodRPlanetParamSet'
        planetRadiusREarth = inputParams.planetRadius;                                                    % in rEarth
        orbitalPeriodDays  = inputParams.orbitalPeriodDays;                                               % in days        
        % convert to mks units
        planetRadiusMks = planetRadiusREarth .* EARTH_RADIUS_METERS;                                      % in m        
        % duration from orbital period, stellar mass and radii
        inputDurations = 1.412 .* stellarRadii .* ( orbitalPeriodDays ./ stellarMass ).^(1/3);            % in hours        
        % planet radius ratio
        rOverRStar = planetRadiusMks ./ stellarRadiiMks;                                                  % dimensionless        
        % initial SES w/nan
        inputSES = nan(size(keplerId));        
end


% orbit radius ratio from period, stellar mass and stellar radius
semiMajorAxisOverRstar = ((( (orbitalPeriodDays .* SECONDS_PER_DAY).^2 .* stellarMassMks .* BIG_G_CGS ./ 1000 )./(4.*pi.^2) ).^(1./3) )./stellarRadiiMks;       % dimensionless

% compute sky offset and offset source location
skyOffsetRaArcSec       = offsetArcSec .* cos(offsetPhase);
skyOffsetDecArcSec      = offsetArcSec .* sin(offsetPhase);
sourceOffsetRaHours     = targetRaHours + skyOffsetRaArcSec .* DEGREES_PER_ARCSEC ./ DEGREES_PER_HOUR ./ cos(deg2rad( targetDecDegrees ));
sourceOffsetDecDegrees  = targetDecDegrees + skyOffsetDecArcSec .* DEGREES_PER_ARCSEC;

% generate fake period (transit separation, transitSeparationFactor = 0 --> use real period)
simulatedTransitSeparation = transitSeparationFactor.*inputDurations.*DAYS_PER_HOUR;    % in days
orbitalPhaseDays = ( double(~simulatedTransitSeparation).*orbitalPeriodDays + simulatedTransitSeparation ).*inputPhase;

% generate epoch in the barycentric time frame for this target
epoch = barycentricZeroEpochMjd + orbitalPhaseDays(:);

% eccentricy and longitude of perihelion set to zero in these models
eccentricity = zeros(size(keplerId));
longitudeOfPeriDegrees = zeros(size(keplerId));

% all offset transit sources are set to this transit depth
transitOffsetDepthPpm = ones(size(keplerId)).*offsetTransitDepth.*1e6;

% buffer cadences identical for all targets
transitBufferCadences = ones(size(keplerId)).*transitBufferCadences;

% offset enabled set globally by module parameter
transitOffsetEnabled = offsetEnabled & true(size(keplerId));

% initialize transit depth w/nan
transitDepthPpm = nan(size(keplerId));

% populate the outputsStruct with TIP model parameters
outputsStruct = struct('skyGroupId',                            skyGroupId,...
                        'transitInjectionParametersFileName',   OUTPUT_FILENAME,...
                        'simulationInputParameters',            inputParams,...
                        'parametersProduced',                   false(size(keplerId(:))),...                        
                        'keplerId',                             keplerId(:),...
                        'transitDepthPpm',                      transitDepthPpm(:),...
                        'transitDurationHours',                 inputDurations(:),...
                        'orbitalPeriodDays',                    orbitalPeriodDays(:),...
                        'epochBjd',                             epoch(:),...
                        'eccentricity',                         eccentricity(:),...
                        'longitudeOfPeriDegrees',               longitudeOfPeriDegrees(:),...
                        'transitSeparationDays',                simulatedTransitSeparation(:),...
                        'transitOffsetEnabled',                 transitOffsetEnabled(:),...
                        'transitOffsetDepthPpm',                transitOffsetDepthPpm(:),...
                        'transitOffsetArcsec',                  offsetArcSec(:),...
                        'transitOffsetPhase',                   offsetPhase(:),...                        
                        'skyOffsetRaArcSec',                    skyOffsetRaArcSec(:),...
                        'skyOffsetDecArcSec',                   skyOffsetDecArcSec(:),...
                        'sourceOffsetRaHours',                  sourceOffsetRaHours(:),...
                        'sourceOffsetDecDegrees',               sourceOffsetDecDegrees(:),...                        
                        'semiMajorAxisOverRstar',               semiMajorAxisOverRstar(:),...
                        'RplanetOverRstar',                     rOverRStar(:),...
                        'planetRadiusREarth',                   planetRadiusREarth(:),...
                        'impactParameter',                      impactParameters(:),...
                        'stellarRadiusRsun',                    stellarRadii(:),...
                        'stellarMassMsun',                      stellarMass(:),...
                        'stellarLog10Gravity',                  logg(:),...
                        'stellarEffectiveTempKelvin',           Teff(:),...
                        'stellarLog10Metalicity',               FeOnH(:),...
                        'transitBufferCadences',                transitBufferCadences(:),...
                        'singleEventStatistic',                 inputSES(:),...
                        'normalizedEpochPhase',                 inputPhase(:));


% update rmsCdpp dependent TIP model parameters
for i = 1:nTargets    
    rmsCdppStructArray = targets(i).rmsCdppStruct;    
    if( ~isempty(rmsCdppStructArray) )                       
        pipelineDurations   = [rmsCdppStructArray.trialTransitPulseInHours];
        rmsCdppForDuration  = [rmsCdppStructArray.rmsCdpp];                                         % in ppm        
        if( ~isempty(pipelineDurations) && ~isempty(rmsCdppForDuration) )        
            % cdpp is available for this target - Yeah! Let's simulate some transits.            
            % extract parameters for this target            
            thisDuration                = inputDurations(i);                % in hours
            thisImpactParameter         = impactParameters(i);              % dimensionless
            thisStellarRadii            = stellarRadii(i);                  % in solar radii
            thisStellarRadiiMks         = stellarRadiiMks(i);               % in m
            % find the closest CDPP to this duration - round up to the longer duration if directly between two durations
            delta = abs(pipelineDurations - thisDuration);
            nearestPipelineDurationIndx = find(pipelineDurations == pipelineDurations(delta == min(delta)));
            nearestPipelineDurationIndx = nearestPipelineDurationIndx(end);
            thisCdpp = rmsCdppForDuration(nearestPipelineDurationIndx);            
            % set the generatingParamSet dependent parameters
            switch generatingParamSetName    
                case 'sesDurationParamSet'
                    % get depth from SES
                    thisSES = inputSES(i);
                    thisDepth = thisCdpp * thisSES;                         % in ppm                    
                    % Make a rough estimate of this planet radius and use to get rOverRstar estimate.
                    % thisRp is not used in the modeling. Only rOverRstar is important here.                    
                    % approximate rP and rP/rStar
                    thisRp = sqrt( ( thisDepth .* thisStellarRadii.^2 ) ./ EARTH_TRANSITING_SUN_PPM );                          % in rEarth
                    testROverRStar = thisRp .* EARTH_RADIUS_METERS ./ thisStellarRadiiMks;                    
                    % refine estimate of rplanet/rstar to match the depth we want
                    thisROverRstar = fminsearch(@(r)((1 - thisDepth/1e6) - get_transit_light_curve_for_uniform_star(thisImpactParameter,r))^2, testROverRStar, options);                    
                    % find rPlanetREarth from updated rOverRStar
                    thisPlanetRadiusREarth = thisROverRstar * thisStellarRadiiMks / EARTH_RADIUS_METERS;                        % in rEarth                    
                case 'periodRPlanetParamSet' 
                    thisPlanetRadiusREarth = planetRadiusREarth(i);
                    thisROverRstar = thisPlanetRadiusREarth * EARTH_RADIUS_METERS / thisStellarRadiiMks;                    
                    % get depth from impact parameter and rP/rStar
                    thisDepth = (1 - get_transit_light_curve_for_uniform_star(thisImpactParameter,thisROverRstar)) * 1e6;       % in ppm                    
                    % calculate SES from depthPpm
                    thisSES = thisDepth / thisCdpp;
            end            
            % update the outputsStruct            
            outputsStruct.parametersProduced(i)    = true;
            outputsStruct.transitDepthPpm(i)       = thisDepth;
            outputsStruct.singleEventStatistic(i)  = thisSES;
            outputsStruct.RplanetOverRstar(i)      = thisROverRstar;
            outputsStruct.planetRadiusREarth(i)    = thisPlanetRadiusREarth;
        end
    end
end

% update planet models produced with derived parameters from transitGeneratorClass
simStruct = build_simulated_transits_struct_from_tip_parameter_struct(outputsStruct);
simStruct.configMaps = tipDataObject.configMaps;
simStruct = update_planet_model_with_derived_parameters(simStruct);
outputsStruct = update_tip_parameter_struct_from_simulated_transits_struct(outputsStruct, simStruct);

% adjust transit separation based on updated duration
outputsStruct.transitSeparationDays = transitSeparationFactor.*outputsStruct.transitDurationHours.*DAYS_PER_HOUR;    % in days

% adjust SES based on updated duration and depth
disp('Updating SES based on updated model parameters...');
for i = 1:length(outputsStruct.keplerId)
    % find the target index in inputs which matches this target keplerId
    thisTargetIdx = find([targets.keplerId] == outputsStruct.keplerId(i));
    
    % make sure you've got a match and you've produced parameters
    if length(thisTargetIdx) == 1 && outputsStruct.parametersProduced(i)        
        
        % since this had parameters produced we are guarenteed to have a non-empty
        % rmsCdppArray and non-empty fields from above loop
        rmsCdppStructArray = targets(thisTargetIdx).rmsCdppStruct;
        pipelineDurations   = [rmsCdppStructArray.trialTransitPulseInHours];
        rmsCdppForDuration  = [rmsCdppStructArray.rmsCdpp];                                         % in ppm
        
        % extract updated duration and depth for this target
        thisDuration = outputsStruct.transitDurationHours(i);
        thisDepth = outputsStruct.transitDepthPpm(i);
        
        % find the closest CDPP to this updated duration - round up to the longer duration if directly between two durations
        delta = abs(pipelineDurations - thisDuration);
        nearestPipelineDurationIndx = find(pipelineDurations == pipelineDurations(delta == min(delta)));
        nearestPipelineDurationIndx = nearestPipelineDurationIndx(end);
        thisCdpp = rmsCdppForDuration(nearestPipelineDurationIndx);
        
        % calculate SES from updated depth and cdpp corresponding to updated duration
        thisSES = thisDepth / thisCdpp;
        
        % update outputsStruct
        outputsStruct.singleEventStatistic(i) = thisSES;        
    end
end


% set up TIP structure to write
% subset of output fields define the column headings in the csv text output file
dontWriteToTextFile = {'skyGroupId','transitInjectionParametersFileName','parametersProduced','simulationInputParameters'};
structToWrite = rmfield(outputsStruct,dontWriteToTextFile);

% trim data in TIP output file to only those targets with injected transit models produced
validParametersProduced = outputsStruct.parametersProduced;
if any(~validParametersProduced)    
    % adjust field data
    fNames = fieldnames(structToWrite);
    nNames = length(fNames);
    for iName = 1:nNames
        structToWrite.(fNames{iName}) = structToWrite.(fNames{iName})(validParametersProduced);
    end
    % throw warning
    display('WARNING: Transit injection parameters not produced for the following keplerIds:');
    disp(outputsStruct.keplerId(~validParametersProduced));    
end

% write the TIP file
display(['Writing TIP output file ',OUTPUT_FILENAME,' ...']);
write_simulated_transit_parameters( OUTPUT_FILENAME, structToWrite );

% check that we've actually written a valid TIP file
display(['Validating TIP output file ',OUTPUT_FILENAME,' ...']);
if ~isvalid_transit_injection_parameters_file( OUTPUT_FILENAME )
    error(['TIP produced the text file ',OUTPUT_FILENAME,' which does not contain a valid set of simulation parameters.']);
end

% write intermediate products to TIP state file
display(['Updating TIP state file ',TIP_STATE_FILENAME]);
save(TIP_STATE_FILENAME, 'keplerId', 'validParametersProduced', 'generatingParamSetName', 'inputParams',...
                            'simulatedTransitsConfigurationStruct', 'barycentricZeroEpochMjd');

return;

