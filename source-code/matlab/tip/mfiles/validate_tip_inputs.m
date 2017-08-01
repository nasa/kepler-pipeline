function validate_tip_inputs(inputsStruct)
% 
% function validate_tip_inputs(inputsStruct)
% 
% Validate fields in the TIP inputsStruct.
% 
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Top level
% inputsStruct is a structure containing the following fields:
% 
%                               skyGroupId: [int]           sky group identifier
%                     targetStarDataStruct: [struct array]  target data for each target, nTargets x 1.
%                                     kics: [struct array]  stellar data for each target, nTargets x 1.
%     simulatedTransitsConfigurationStruct: [struct]        configuration parameters fro transit simulation
%                           raDec2PixModel: [struct]        raDec2Pix model for this unit of work               (list on this level only)
%                  parameterOutputFilename: [string]        filename for csv output file e.g. 'transit-injection-parameters.txt'
%                               configMaps: [struct array]  spacecraft configuration maps
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% inputsStruct.targetStarDataStruct() is a structure containing the following fields:
% 
%                   keplerId: [int]             target id
%                  keplerMag: [double]          target magnitude
%                    raHours: [double]          target right ascension angle in hours
%                 decDegrees: [double]          target declination angle in degrees
%              rmsCdppStruct: [struct array]    rms cdpp estimates
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% inputsStruct.kics() is a structure containing the following fields:
% 
%              skyGroupId: [int]            sky group identifier
%                keplerId: [int]            target id        
%                      ra: [1x1 struct]     target right ascension angle in hours
%                     dec: [1x1 struct]     target declination angle in degrees
%               keplerMag: [1x1 struct]     stellar magnitude for target
%           effectiveTemp: [1x1 struct]     stellar temperature in Kelvin for target
%     log10SurfaceGravity: [1x1 struct]     stellar surface gravity for target
%        log10Metallicity: [1x1 struct]     stellar metalicity for target
%                  radius: [1x1 struct]     stellar radius for target
%
% All 1x1 structs directly above contain the following fields:
%               value:  [double]    associated value
%         uncertainty:  [double]    associated uncertainty
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level 
% inputsStruct.simulatedTransitsConfigurationStruct is a structure containing the following fields:
% 
%            inputSesUpperLimit: [double]   upper limit of ses random distribution
%            inputSesLowerLimit: [double]   lower limit of ses random distribution
%       inputDurationUpperLimit: [double]   upper limit of duration random distribution (hours)
%       inputDurationLowerLimit: [double]   lower limit of duration random distribution (hours)
%     impactParameterUpperLimit: [double]   upper limit of impact parameter random distribution
%     impactParameterLowerLimit: [double]   lower limit of impact parameter random distribution
%   inputPlanetRadiusUpperLimit: [double]   upper limit of planet radius random distribution (Rearth)
%   inputPlanetRadiusLowerLimit: [double]   lower limit of planet radius random distribution (Rearth)
%  inputOrbitalPeriodUpperLimit: [double]   upper limit of orbital period random distribution (days) 
%  inputOrbitalPeriodLowerLimit: [double]   lower limit of orbital period random distribution (days) 
%        generatingParamSetName: [string]   transit model generating parameters; {'sesDurationParamSet','periodRPlanetParamSet'}
%          enableRandomParamGen: [logical]  true == generate input parameters randomly according to above limits; false == use generating
%                                           parameters read from input file
%                 offsetEnabled: [logical]  true == locate transit feature on background source
%        offsetLowerLimitArcSec: [double]   lower limit of offset magnitude random distribution
%        offsetUpperLimitArcSec: [double]   upper limit of offset magnitude random distribution
%            offsetTransitDepth: [double]   fractional depth of transit feature on background object (typically 0.5)
%         transitBufferCadences: [int]      number of cadences to buffer transit width when calling transit generator
%       transitSeparationFactor: [double]   artificial transit separation will be duration * transitSeparationFactor
%                                           Setting transitSeparationFactor = -1 will generate transits without artificially separating
%                                           them. The apparant period will be the actual orbital period used to create the transit shape.
%      useDefaultKicsParameters: [logical]  true == use solar defaults for all stellar parameters read from kic
%              epochZeroTimeMjd: [double]   time of epoch with zero phase and zero barycentric correction (nominally set to 54897.5 ==
%                                           '07-Mar-2009 12:00:00 Z')
%          randomSeedBySkygroup: [int array]84x1 array of seeds to use for random number gnerator - 1 per skygroup
%    randomSeedFromClockEnabled: [logical]  true == use sum(clock) as seed for random number generator
%                                           false == use entry from skygroup in randomSeedBySkygroup array as seed for random number generator
%        parameterInputFilename: [string]   filename for csv input file e.g. 'transit-generating-parameters.txt'
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Third Level
% inputsStruct.targetStarDataStruct().rmsCdppStruct() is a structure containing the following fields:
% 
%                      rmsCdpp: [double]    rms combined differential photometric precision for this trial pulse width
%     trialTransitPulseInHours: [double]    trial pulse width in hours
%
%-------------------------------------------------------------------------------------------------------------------------------------------------
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

% Define constants
MIN_CUSTOM_TARGET_ID = 100000000;

%--------------------------------------------------------------------------
% validate all fields in top level input struct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(7,4);
fieldsAndBounds(1,:)  = { 'skyGroupId';  '>= 1'; '<= 84'; []};
fieldsAndBounds(2,:)  = { 'targetStarDataStruct'; []; []; []};                  % Validate only those fields required by this CSCI below first level
fieldsAndBounds(3,:)  = { 'kics'; []; []; []};                                  % Validate only those fields required by this CSCI below first level
fieldsAndBounds(4,:)  = { 'simulatedTransitsConfigurationStruct'; []; []; []};
fieldsAndBounds(5,:)  = { 'raDec2PixModel'; []; []; []};                        % Do not validate below first level
fieldsAndBounds(6,:)  = { 'parameterOutputFilename'; []; []; []};               % Do not validate below first level
fieldsAndBounds(7,:)  = { 'configMaps'; []; []; []};                            % Do not validate below first level

validate_structure(inputsStruct, fieldsAndBounds,'inputsStruct');
clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.targetStarDataStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
fieldsAndBounds(2,:)  = { 'keplerMag'; '>= 0'; '< 30'; []};
fieldsAndBounds(3,:)  = { 'raHours'; '>= 0'; '< 24'; []};
fieldsAndBounds(4,:)  = { 'decDegrees'; '>= -90'; '<= 90'; []};
fieldsAndBounds(5,:)  = { 'rmsCdppStruct'; []; []; []};

nStructures = length(inputsStruct.targetStarDataStruct);
for i = 1 : nStructures    
    targetStruct = inputsStruct.targetStarDataStruct(i);    
    % pass targets with magnitude = NaN through validator
    if isfield(targetStruct, 'keplerMag') && isnan(targetStruct.keplerMag)
        targetStruct.keplerMag = 0;
    end    
    % pass custom targets with ra and/or dec = NaN through validator
    if isfield(targetStruct, 'keplerId') && targetStruct.keplerId >= MIN_CUSTOM_TARGET_ID
        if isfield(targetStruct, 'raHours') && isnan(targetStruct.raHours)
            targetStruct.raHours = 0;
        end
        if isfield(targetStruct, 'decDegrees') && isnan(targetStruct.decDegrees)
            targetStruct.decDegrees = 0;
        end
    end    
    validate_structure(targetStruct, fieldsAndBounds, 'inputsStruct.targetStarDataStruct()');    
end
clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.kics
%--------------------------------------------------------------------------
fieldsAndBounds = cell(9,4);
fieldsAndBounds(1,:)  = { 'skyGroupId';  '>= 1'; '<= 84'; []};
fieldsAndBounds(2,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};
fieldsAndBounds(3,:)  = { 'ra'; []; []; []};
fieldsAndBounds(4,:)  = { 'dec'; []; []; []};
fieldsAndBounds(5,:)  = { 'keplerMag'; []; []; []};
fieldsAndBounds(6,:)  = { 'effectiveTemp'; []; []; []}; 
fieldsAndBounds(7,:)  = { 'log10SurfaceGravity'; []; []; []}; 
fieldsAndBounds(8,:)  = { 'log10Metallicity'; []; []; []}; 
fieldsAndBounds(9,:)  = { 'radius'; []; []; []}; 

nStructures = length(inputsStruct.kics);
for i = 1 : nStructures    
    targetStruct = inputsStruct.kics(i);    
    validate_structure(targetStruct, fieldsAndBounds, 'inputsStruct.kics()');    
end
clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.simulatedTransitsConfigurationStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(23,4);

fieldsAndBounds(1,:)  = { 'inputSesUpperLimit'; '>= 0'; '<= 100'; []};
fieldsAndBounds(2,:)  = { 'inputSesLowerLimit'; '>= 0'; '<= 100'; []};
fieldsAndBounds(3,:)  = { 'inputDurationUpperLimit'; '>= 0'; '<= 100'; []};
fieldsAndBounds(4,:)  = { 'inputDurationLowerLimit'; '>= 0'; '<= 100'; []};
fieldsAndBounds(5,:)  = { 'impactParameterUpperLimit'; '>= 0'; '<= 2'; []};
fieldsAndBounds(6,:)  = { 'impactParameterLowerLimit'; '>= 0'; '<= 2'; []};
fieldsAndBounds(7,:)  = { 'inputPlanetRadiusUpperLimit'; '<= 1000'; '>= 1'; []};
fieldsAndBounds(8,:)  = { 'inputPlanetRadiusLowerLimit'; '>= 0'; '<= 1'; []};
fieldsAndBounds(9,:)  = { 'inputOrbitalPeriodUpperLimit'; '<= 1000'; '>= 50'; []};
fieldsAndBounds(10,:)  = { 'inputOrbitalPeriodLowerLimit'; '>= 0'; '<= 50'; []};
fieldsAndBounds(11,:)  = { 'generatingParamSetName'; []; []; {'sesDurationParamSet','periodRPlanetParamSet'}};
fieldsAndBounds(12,:)  = { 'enableRandomParamGen'; []; []; [true false]};
fieldsAndBounds(13,:)  = { 'offsetEnabled'; []; []; [true false]};
fieldsAndBounds(14,:)  = { 'offsetLowerLimitArcSec'; '>= 0'; '<= 25'; []};
fieldsAndBounds(15,:)  = { 'offsetUpperLimitArcSec'; '>= 0'; '<= 25'; []};
fieldsAndBounds(16,:)  = { 'offsetTransitDepth'; '>= 0.3'; '<= 1'; []};
fieldsAndBounds(17,:)  = { 'transitSeparationFactor'; '>= 0'; '<= 500'; []};
fieldsAndBounds(18,:)  = { 'useDefaultKicsParameters'; []; []; [true; false]};
fieldsAndBounds(19,:)  = { 'transitBufferCadences'; '>=0'; '<=50'; []};
fieldsAndBounds(20,:)  = { 'epochZeroTimeMjd'; '> 54897'; '< 54897 + 3.5 * 365'; []};       % epoch zero must be within nominal mission
fieldsAndBounds(21,:)  = { 'randomSeedBySkygroup'; '> -Inf'; '< +Inf'; []};                 % 84x1 array. All entries must be numeric
fieldsAndBounds(22,:)  = { 'randomSeedFromClockEnabled'; []; []; [true false]};
fieldsAndBounds(23,:)  = { 'parameterInputFilename'; []; []; []};

validate_structure(inputsStruct.simulatedTransitsConfigurationStruct, fieldsAndBounds,...
    'inputsStruct.simulatedTransitsConfigurationStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.kics.{'ra','dec','keplerMag','effectiveTemp','log10SurfaceGravity','log10Metallicity','radius'}
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'value'; []; []; []};
fieldsAndBounds(2,:)  = { 'uncertainty'; []; []; []};

fieldList = {'ra','dec','keplerMag','effectiveTemp','log10SurfaceGravity','log10Metallicity','radius'};

for iTarget = 1:length(inputsStruct.kics)
    for iField = 1:length(fieldList)
        validate_structure(inputsStruct.kics(iTarget).(fieldList{iField}), fieldsAndBounds,...
            ['inputsStruct.kics(',num2str(iTarget),').',fieldList{iField}]);
    end
end
clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.targetStarDataStruct(iTarget).rmsCdppStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'rmsCdpp'; []; []; []};
fieldsAndBounds(2,:)  = { 'trialTransitPulseInHours'; []; []; []};

for iTarget = 1:length(inputsStruct.targetStarDataStruct)
    for iCdpp = 1:length(inputsStruct.targetStarDataStruct(iTarget).rmsCdppStruct)
        validate_structure(inputsStruct.targetStarDataStruct(iTarget).rmsCdppStruct(iCdpp), fieldsAndBounds,...
            ['inputsStruct.targetStarDataStruct(',num2str(iTarget),').rmsCdppStruct(',num2str(iCdpp),')']);
    end
end
clear fieldsAndBounds;

return;

