function transitModelStruct = set_transit_model_input_struct(...
    cadenceTimes, ...           
    log10SurfaceGravity, ...    
    effectiveTemp, ...          
    debugFlag, ...              
    transitModelName, ...      
    limbDarkeningModelName, ... 
    transitBufferCadences, ...  
    transitSamplesPerCadence, ...
    configMaps, ...             
    transitEpochMjd, ...       
    eccentricity, ...           
    longitudeOfPeriDegrees, ... 
    minImpactParameter, ...     
    starRadiusSolarRadii, ...   
    transitDepthPpm, ...        
    orbitalPeriodDays, ...      
    transitDurationHours)
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
%
% function to set an input struct for the transit signal generator for a given
% model and planet/star parameters.  
%
% Valid model names supported are:
%
% (1) transitModelName = 'gaussian'
% (2) transitModelName = 'mandel-agol_transit_model'    
%
%
% function transitModelStruct = set_transit_model_input_struct(...
%     cadenceTimes, ...           % [array]  of bary-corrected mjd timestamps
%     log10SurfaceGravity, ...    % [scalar] stellar (log) surface gravity
%     effectiveTemp, ...          % [scalar] stellar effective temperature
%     debugFlag, ...              % [logical] debug flag
%     transitModelName, ...       % [string] 'gaussian' or 'mandel-agol_transit_model'
%     limbDarkeningModelName, ... % [string] 'claret_nonlinear_limb_darkening_model'
%     transitBufferCadences, ...  % [scalar] num cadences to add before/after transit for detailed modelling
%     configMaps, ...             % [struct] spacecraft config map 
%     transitEpochMjd, ...        % [scalar] planetModel field
%     eccentricity, ...           % [scalar] planetModel field
%     longitudeOfPeriDegrees, ... % [scalar] planetModel field
%     minImpactParameter, ...     % [scalar] planetModel field
%     starRadiusSolarRadii, ...   % [scalar] planetModel field
%     transitDepthPpm, ...        % [scalar] planetModel field
%     orbitalPeriodDays, ...      % [scalar] planetModel field
%     transitDurationHours)       % [scalar] planetModel field
%
% Note get_unit_conversion can be used to convert to desired input units
%
%
%
% OUTPUT
%
% transitModelStruct =
%              cadenceTimes: [6049x1 double]
%       log10SurfaceGravity: 4.4000
%             effectiveTemp: 5200
%                 debugFlag: 1
%          modelNamesStruct: [1x1 struct]
%     transitBufferCadences: 1
%                configMaps: [1x1 struct]
%               planetModel: [1x1 struct]
%
%  transitModelStruct.modelNamesStruct =
%           transitModelName: 'mandel-agol_transit_model'
%     limbDarkeningModelName: 'claret_nonlinear_limb_darkening_model'
%
%
%   transitModelStruct.planetModel =
%           transitEpochBkjd: 134.5
%               eccentricity: 0
%         minImpactParameter: 0.2000
%       starRadiusSolarRadii: 1.1200
%            transitDepthPpm: 16000
%          orbitalPeriodDays: 21
%     longitudeOfPeriDegrees: 0
%
%
% 
%--------------------------------------------------------------------------
% The transitModelStruct can then be input into the following functions to
% compute the planet model light curve:
% 
% (1) [transitModelObject] = transitGeneratorClass(transitModelStruct)
% (2) [transitModelLightCurve, cadenceTimes] = 
%           generate_planet_model_light_curve(transitModelObject)
%
%--------------------------------------------------------------------------


if isempty(transitModelName)
    transitModelName = 'mandel-agol_transit_model';
    warning('DV:set_transit_model_input_struct:emptyField', ' transitModelName field is empty, setting default to mandel-agol_transit_model')
end


if isempty(debugFlag)
    debugFlag = 0;
    warning('DV:set_transit_model_input_struct:emptyField', ' debugFlag field is empty, setting default to false')
end


if isempty(transitBufferCadences)
    transitBufferCadences = 1;
    warning('DV:set_transit_model_input_struct:emptyField', ' transitBufferCadences field is empty, setting default to 1')
end


if isempty(transitSamplesPerCadence)
    transitSamplesPerCadence = 11;
    warning('DV:set_transit_model_input_struct:emptyField', ' transitSamplesPerCadence field is empty, setting default to 11')
end


if isempty(configMaps)
    configMaps = retrieve_config_map(cadenceTimes(1));
    warning('DV:set_transit_model_input_struct:emptyField', ' configMaps field is empty, retreiving config map for cadenceTimes(1)')
end


if isempty(eccentricity)
    eccentricity = 0;
    warning('DV:set_transit_model_input_struct:emptyField', ' eccentricity field is empty, setting default to 0')
end


if isempty(longitudeOfPeriDegrees)
    longitudeOfPeriDegrees = 0;
    warning('DV:set_transit_model_input_struct:emptyField', ' longitudeOfPeriDegrees field is empty, setting default to 0')
end


if isempty(transitDurationHours)
    transitDurationHours = 0;
    warning('DV:set_transit_model_input_struct:emptyField', ' transitDurationHours field is empty, setting default to 0')
end




% set transit model input struct
transitModelStruct.cadenceTimes          = cadenceTimes;
transitModelStruct.log10SurfaceGravity   = log10SurfaceGravity;
transitModelStruct.effectiveTemp         = effectiveTemp;
transitModelStruct.debugFlag             = debugFlag;


% set up modelNamesStruct
modelNamesStruct.transitModelName        = transitModelName;
modelNamesStruct.limbDarkeningModelName  = limbDarkeningModelName;

transitModelStruct.modelNamesStruct      =  modelNamesStruct;

transitModelStruct.transitBufferCadences    = transitBufferCadences;
transitModelStruct.transitSamplesPerCadence = transitSamplesPerCadence;
transitModelStruct.configMaps               = configMaps;

% set up planetModel struct
planetModel.transitEpochBkjd             = transitEpochMjd;
planetModel.eccentricity                 = eccentricity;
planetModel.longitudeOfPeriDegrees       = longitudeOfPeriDegrees;
planetModel.minImpactParameter           = minImpactParameter;
planetModel.starRadiusSolarRadii         = starRadiusSolarRadii;
planetModel.transitDepthPpm              = transitDepthPpm;
planetModel.orbitalPeriodDays            = orbitalPeriodDays;

% transit duration is used in gaussian light curve generation only
if ~strcmpi(transitModelName, 'mandel-agol_transit_model')

    planetModel.transitDurationHours     = transitDurationHours;
end

% transit duration is used in gaussian light curve generation only
if ~strcmpi(transitModelName, 'mandel-agol_transit_model')

    planetModel.transitDurationHours     = transitDurationHours;
end


transitModelStruct.planetModel = planetModel;


return;

