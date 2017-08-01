function outputsStruct = tip_matlab_controller(inputsStruct)
% 
% function outputsStruct = tip_matlab_controller(inputsStruct)
% 
% This is the top level function on the MATLAB side of the TIP CSCI. TIP produces a text file written to the current working directory
% containing transit injection paramters which may be read by PA and DV methods and used to generate self consistant model light curves
% containing injected transits using the transit generator class. The functionality contained here is identical to that contained in PA
% (SOC-8.3) in input_simulated_transits.m. The parameters are built using kic values and the following simulation parameters drawn from a
% randn distribution: single event statistic, transit duration, impact parameter, phase relative to some universal epoch (nominally
% 07-Mar-2009 12:00:00 Z but is selectable through the simulatedTransitsConfigurationStruct). If a background offset is enabled
% (offsetEnabled = true) then an offset magnitude and phase are also drawn from a randn distribution. The distribution widths and mean are
% selectable through the simulatedTransitsConfigurationStruct. An output struct is produced containing the same information written to the
% text file plus a skygroup identifier, the output filename if it was produced and a boolean indicating whether or not parameters were
% generated for each target ID.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'inputsStruct' with the following fields:
% (List only the fields required by this CSCI)
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Top level
% inputsStruct is a structure containing the following fields:
% 
%                               skyGroupId: [int]           sky group identifier
%                     targetStarDataStruct: [struct array]  target data for each target, nTargets x 1.
%                                     kics: [struct array]  stellar data for each target, nTargets x 1.
%     simulatedTransitsConfigurationStruct: [struct]        configuration parameters for transit simulation
%                           raDec2PixModel: [struct]        raDec2Pix model for this unit of work               (list on this level only)
%                  parameterOutputFilename: [string]        filename for csv output file e.g. 'transit-injection-parameters.txt'
%                   parameterInputFilename: [string]        filename for csv input file e.g. 'transit-generating-parameters.txt'
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
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Third Level
% inputsStruct.targetStarDataStruct().rmsCdppStruct() is a structure containing the following fields:
% 
%                      rmsCdpp: [double]    rms combined differential photometric precision for this trial pulse width
%     trialTransitPulseInHours: [double]    trial pulse width in hours
%
%-------------------------------------------------------------------------------------------------------------------------------------------------
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure 'outputsStruct' with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Top level
% outputsStruct is a structure containing the following fields:
% 
%                           skyGroupId: [int]             sky group identifier
%   transitInjectionParametersFileName: [string]          csv parameter output filename e.g. 'transit-injection-parameters.txt'
%                                                         See below for definition of the csv output.
%                     randomNumberSeed: [int]             seed used to initialize the random number generator in TIP
%                   parametersProduced: [logical array]   true == simulation parameters produced for this target
%                             keplerId: [int array]       target id
%                      transitDepthPpm: [double array]    depth of simulated transit in parts per million
%                 transitDurationHours: [double array]    duration of simulated transit in hours
%                    orbitalPeriodDays: [double array]    orbital period of simulated transit in days - used to set transit shape
%                             epochBjd: [double array]    epoch of simulated transit in barycentric time
%                         eccentricity: [double array]    eccentricity of simulated transit
%               longitudeOfPeriDegrees: [double array]    longitude of perihelion of simulated transit
%                transitSeparationDays: [double array]    observed period of simulated transits
%                 transitOffsetEnabled: [logical array]   true == location of transiting object is offset from target
%                transitOffsetDepthPpm: [double array]    transit depth of background object in parts per million
%                  transitOffsetArcsec: [double array]    offset magnitude of transiting background object in arcsec
%                   transitOffsetPhase: [double array]    phase angle locating background object relative to +ra axis
%                    skyOffsetRaArcSec: [double array]    offset of transiting object on the sky in the RA direction in arc sec
%                   skyOffsetDecArcSec: [double array]    offset of transiting object on the sky in the Dec direction in arc sec
%                  sourceOffsetRaHours: [double array]    location of offset transiting object in RA (hours)
%               sourceOffsetDecDegrees: [double array]    location of offset transiting object in Dec (degrees)
%               semiMajorAxisOverRstar: [double array]    ratio of orbit radius to star radius
%                     RplanetOverRstar: [double array]    ratio of planet radius to star radius
%                      impactParameter: [double array]    impact parameter
%                    stellarRadiusRsun: [double array]    star radius in solar units
%                      stellarMassMsun: [double array]    star mass in solar units
%                  stellarLog10Gravity: [double array]    log surface gravity of star
%           stellarEffectiveTempKelvin: [double array]    effective temperature of star
%               stellarLog10Metalicity: [double array]    metalicity of star
%                transitBufferCadences: [int array]       number of cadences to buffer transit width when calling transit generator
%                 singleEventStatistic: [double array]    single event statistic expected for this transiting object
%                 normalizedEpochPhase: [double array]    defines the epoch for this transit event relative to the barycentric corrected
%                                                         zero-epoch time which is set in the simulatedTransitsConfigurationStruct. The
%                                                         normalizedEpochPhase is applied to the observedTransitSeparation (transitSeparationDays)
%                   
% All arrays in the top level output are nTargets x 1.
% 
% The text file produced is written to the current working directory in csv format. It has a single header row and contains the following
% parameters in column order for all targets which successfully produced parameters: 
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
%     impactParameter
%     stellarRadiusRsun
%     stellarMassMsun
%     stellarLog10Gravity
%     stellarEffectiveTempKelvin
%     stellarLog10Metalicity
%     transitBufferCadences  
%     singleEventStatistic
%     normalizedEpochPhase
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


% update inputs
inputsStruct = update_tip_inputs(inputsStruct);

% validate inputs
validate_tip_inputs(inputsStruct);

% create object
tipDataObject = tipDataClass(inputsStruct);

% produce output file
outputsStruct = produce_tip_txt_file(tipDataObject);

return;