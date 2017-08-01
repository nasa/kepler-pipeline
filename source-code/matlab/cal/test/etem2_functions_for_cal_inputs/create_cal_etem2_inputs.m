function gloabalConfigurationStruct = create_cal_etem2_inputs(s)
%
% function to create the input structure for an ETEM2 run, where s is a
% structure specific to CAL with the configurable parameters used to
% validate CAL
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ETEM2 is run via:
%
%        etem2(gloabalConfigurationStruct)
%        etem2(create_cal_etem2_inputs(s))
%
% (example) 
%        load calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat  s
%
%  s =
%             outputDirectory: 'calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn_dir'
%                 numCadences: 5
%                   ccdModule: 7
%                   ccdOutput: 3
%                 cadenceType: 'long'
%            twoDBlackEnabled: 0
%                starsEnabled: 0
%                smearEnabled: 0
%                 darkEnabled: 0
%            darkCurrentValue: 2
%         nonlinearityEnabled: 0
%           undershootEnabled: 0
%            flatFieldEnabled: 0
%            readNoiseEnabled: 0
%           quantNoiseEnabled: 0
%            shotNoiseEnabled: 0
%           cosmicRaysEnabled: 0
%        supressAllMotionFlag: 1
%               makeCleanFlag: 0
%           targetListSetName: 'q1-lc'
%     refPixTargetListSetName: 'q1-rp'
%                runStartDate: '1-April-2009'
%       requantizationTableId: 175
%
% The outputDirectory name includes:
%  2D       two D black on
%  ST       stars on
%  SM       smear on
%  DC       dark current on
%  NL       nonlinearity on
%  LU       lde undershoot on
%  FF       flat field on
%  RN       read noise on
%  QN       quantization noise on
%  SN       shot noise on
%
% Upper case letters indicate the effects are on (enabled)
% Lower case letters indicate that the effects are off
%
% For each etem run, the pixels can be extracted in the following ways:
%
% RQ    requantized
% rq    not requantized
% CR    with cosmic rays        (if cosmic rays are enabled in this function)
% cr    without cosmic rays
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


outputDirectory         = s.outputDirectory;

numCadences             = s.numCadences;
ccdModule               = s.ccdModule;
ccdOutput               = s.ccdOutput;

cadenceType             = s.cadenceType;

twoDBlackEnabled        = s.twoDBlackEnabled;           % if true, include 2Dblack (useMeanBiasFlag = false), otherwise a bias (= mean 2D black) is included
starsEnabled            = s.starsEnabled;               % if true, turns all stars on (supressAllStarsFlag = false)

smearEnabled            = s.smearEnabled;
darkEnabled             = s.darkEnabled;
darkCurrentValue        = s.darkCurrentValue;           % if darkEnabled is true, set dark current value (ADU)

nonlinearityEnabled     = s.nonlinearityEnabled;        % if true, include nonlinearity
undershootEnabled       = s.undershootEnabled;
flatFieldEnabled        = s.flatFieldEnabled;

readNoiseEnabled        = s.readNoiseEnabled;
quantNoiseEnabled       = s.quantNoiseEnabled;
shotNoiseEnabled        = s.shotNoiseEnabled;

cosmicRaysEnabled       = s.cosmicRaysEnabled;

supressAllMotionFlag    = s.supressAllMotionFlag;       % if true, turn all object motion off
makeCleanFlag           = s.makeCleanFlag;              % if true, use average bias for producing clean image

targetListSetName       = s.targetListSetName;          % from retrieve_target_list_sets, 'q1-sc1' short cadence
refPixTargetListSetName = s.refPixTargetListSetName;    % from retrieve_target_list_sets

runStartDate            = s.runStartDate;
requantizationTableId   = s.requantizationTableId;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% get set of defined plugin classes
pluginList = defined_plugin_classes();

% global specification data for this simulation run
runParamsData.simulationData.numberOfTargetsRequested   = 2000;                         % Number of target stars before downselect
runParamsData.simulationData.runStartDate               = runStartDate;                 % start date of current run
runParamsData.simulationData.runDuration                = numCadences;                  % length of run in the units defined in the next field
runParamsData.simulationData.runDurationUnits           = 'cadences';                   % units of run length paramter: 'days' or 'cadences'
runParamsData.simulationData.initialScienceRun          = -1;                           % if positive, indicates a previous run to use as base
runParamsData.simulationData.firstExposureStartDate     = '1-Mar-2009 17:29:36.8448';   % Date of a roll near launch.
runParamsData.simulationData.moduleNumber               = ccdModule;                    % which CCD module, ouput and season, legal values: 2-4, 6-20, 22-24
runParamsData.simulationData.outputNumber               = ccdOutput;                    % legal values: 1-4
runParamsData.simulationData.observingSeason            = 1;                            % 0-3 0-summer,1-fall,2-winter,3-spring
runParamsData.simulationData.cadenceType                = cadenceType;                  % cadence types, <long> or <short>
runParamsData.simulationData.cleanOutput                = 0;                            % 1 to remove restart files


%--------------------------------------------------------------------------
% RETRIEVE SPACECRAFT CONFIG MAP
mjdStart                = datestr2mjd(runStartDate);
spacecraftConfigMap     = retrieve_config_map(mjdStart);
configMapObject         = configMapClass(spacecraftConfigMap);
%--------------------------------------------------------------------------

% allowed values: exposuresPerShortCadence 7 - 19, shortsPerLongCadence: 15 - 120
shortsPerLongCadence        = get_number_of_shorts_in_long(configMapObject, mjdStart);  % = 30
runParamsData.keplerData.shortsPerLongCadence       = shortsPerLongCadence  ;      % # of short cadences in a long cadence

exposuresPerShortCadence    = get_number_of_exposures_per_short_cadence_period(configMapObject, mjdStart); % = 9
runParamsData.keplerData.exposuresPerShortCadence   = exposuresPerShortCadence;     % # of exposures in a short cadence, 9 for a ~1-minute cadence

% data about the current run
runParamsData.etemInformation.className = 'runParamsClass';

% Root location of the ETEM 2 code
runParamsData.etemInformation.etem2Location = '.';
runParamsData.etemInformation.etem2OutputLocation = [runParamsData.etemInformation.etem2Location filesep outputDirectory];

% global data about the spacecraft
runParamsData.keplerData.keplerInitialOrbitFilename     = 'keplerInitialOrbit.mat';
runParamsData.keplerData.keplerInitialOrbitFileLocation = 'configuration_files';

% set values from the focal plane constants
import gov.nasa.kepler.common.FcConstants;

runParamsData.keplerData.numVisibleRows             = FcConstants.nRowsImaging;
runParamsData.keplerData.numVisibleCols             = FcConstants.nColsImaging;
runParamsData.keplerData.numLeadingBlack            = FcConstants.nLeadingBlack;
runParamsData.keplerData.numTrailingBlack           = FcConstants.nTrailingBlack;
runParamsData.keplerData.numVirtualSmear            = FcConstants.nVirtualSmear;
runParamsData.keplerData.numMaskedSmear             = FcConstants.nMaskedSmear;
runParamsData.keplerData.numAtoDBits                = FcConstants.BITS_IN_ADC;
runParamsData.keplerData.saturationSpillUpFraction  = FcConstants.SATURATION_SPILL_UP_FRACTION;                 % fraction of spilled saturation goes up
runParamsData.keplerData.parallelCTE                = FcConstants.PARALLEL_CTE;                                 % parallel charge transfer efficiency
runParamsData.keplerData.serialCTE                  = FcConstants.SERIAL_CTE;                                   % serial charge transfer efficiency
runParamsData.keplerData.pixelAngle                 = FcConstants.pixel2arcsec;                                 % pixel width in seconds of arc
runParamsData.keplerData.fluxOfMag12Star            = FcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;   % flux of a 12th magnitude start in e-/sec

runParamsData.keplerData.pixelWidth         = 27;       % pixel width in microns
runParamsData.keplerData.boresiteDec        = 44.5;     % declination of boresite in degrees
runParamsData.keplerData.boresiteRa         = 290.67;   % RA of boresite in degrees

runParamsData.keplerData.intrapixWavelength = 800; % wavelength in nm of intra pixel variability
% must be 500 or 800 nm

%--------------------------------------------------------------------------
% RETRIEVE SPATIALLY COADDED ROW/COLS FOR COLLATERAL
% specification of which collateral pixels to use relative to the pixel set
blackStartColumn        = get_black_start_column(configMapObject, mjdStart);
blackEndColumn          = get_black_end_column(configMapObject, mjdStart);

maskedSmearStartRow     = get_masked_smear_start_row(configMapObject, mjdStart);
maskedSmearEndRow       = get_masked_smear_end_row(configMapObject, mjdStart);

virtualSmearStartRow    = get_virtual_smear_start_row(configMapObject, mjdStart);
virtualSmearEndRow      = get_virtual_smear_end_row(configMapObject, mjdStart);


runParamsData.keplerData.maskedSmearCoAddRows     = maskedSmearStartRow:maskedSmearEndRow;          %7:19;
runParamsData.keplerData.virtualSmearCoAddRows    = virtualSmearStartRow:virtualSmearEndRow;        %1046:1059;
runParamsData.keplerData.blackCoAddCols           = blackStartColumn:blackEndColumn;                %1116:1132;
%--------------------------------------------------------------------------


runParamsData.keplerData.nSubPixelLocations       = 10;      % # of sub-pixel locations on a side of  a pixel
runParamsData.keplerData.prfDesignRangeBuffer     = 1.25;    % amount to expand prf design rangef

runParamsData.keplerData.integrationTime          = 6.01982; % seconds from mail 4-June-2007.  Was 5.70845
runParamsData.keplerData.transferTime             = 0.51895; % seconds from CDPP spreadsheed

runParamsData.keplerData.wellCapacity             = 1.30E+06; % electrons assuming 1.3 milliion e- full well
%runParamsData.keplerData.wellCapacity             = 1.30E+50; % USE IF MODELING NO SPILLOVER

runParamsData.keplerData.numMemoryBits            = 23;      % number of bits in accumulation memory


%--------------------------------------------------------------------------
% RETRIEVE GAIN, although should get overwritten with gain model
numberOfLongsBetweenBaselines = get_number_of_longs_between_baselines(configMapObject, mjdStart);
mjdEnd      = (mjdStart + numCadences/numberOfLongsBetweenBaselines);

gainModel   = retrieve_gain_model(mjdStart, mjdEnd);
gainObject  = gainClass(gainModel);

% get gain for this mod/out
gain = get_gain(gainObject, mjdStart , ccdModule, ccdOutput);  % nCadences x 1

runParamsData.keplerData.electronsPerADU          = gain;    % 109.9; % match current value
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% RETRIEVE READ NOISE, although should get overwritten with read noise model

readNoiseModel  = retrieve_read_noise_model(mjdStart, mjdEnd);
readNoiseObject = readNoiseClass(readNoiseModel);

% get red noise for this mod/out
readNoiseInADU = get_read_noise(readNoiseObject, mjdStart, ccdModule, ccdOutput);

runParamsData.keplerData.readNoise                = readNoiseInADU*gain;     % e-/pixel/second (should be 100, use 30 to get more pixels for test)
%--------------------------------------------------------------------------


runParamsData.keplerData.adcGuardBandFractionLow  = 0.05;    % 5% guard band on low end of A/D converter
runParamsData.keplerData.adcGuardBandFractionHigh = 0.05;    % 5% guard band on high end of A/D converter
runParamsData.keplerData.chargeDiffusionSigma     = 1;       % charge diffusion coefficient in microns
runParamsData.keplerData.chargeDiffusionArraySize = 51;      % size of super-resolution grid for charge diffusion kernel, must be odd

runParamsData.keplerData.simulationFramesPerExposure = 5;   % # of simulation frames per integration
% not sure about that: ETEM comments say = ceil(integrationTime/.5 + 1) but that's not consistent with ETEM values
runParamsData.keplerData.numChains                = 5;      % not entirely sure what this is - fixed by hardware?

runParamsData.keplerData.motionPolyOrder          = 6;      % order of the motion polynomial
runParamsData.keplerData.dvaMeshOrder             = 3;      % order of the dva motion interpolation polynomial
runParamsData.keplerData.motionGridResolution     = 5;      % number of points on a side for motion grid
runParamsData.keplerData.numCadencesPerChunk      = 100;    % number of cadences to work with for memory management
runParamsData.keplerData.targetImageSize          = 11;     % size on a side of a target image in pixels.  Must be odd.

runParamsData.keplerData.badFitTolerance          = 6;      % allowed error before a pixel is considered badly fit
runParamsData.keplerData.saturationBoxSize        = 7;      % box to put around saturated pixels

runParamsData.keplerData.supressAllMotion         = supressAllMotionFlag;  % diagnostic which if true turns all object motion off
runParamsData.keplerData.supressAllStars          = ~starsEnabled;         % diagnostic which if true turns all stars off
runParamsData.keplerData.supressSmear             = ~smearEnabled;         % if true don't add smear, for producing clean image
runParamsData.keplerData.supressQuantizationNoise = ~quantNoiseEnabled;    % if true don't add quantization noise, for producing clean image

runParamsData.keplerData.useMeanBias              = ~twoDBlackEnabled;  % if true use average bias, for producing clean image
runParamsData.keplerData.makeClean                = makeCleanFlag;      % if true use average bias, for producing clean image

runParamsData.keplerData.transitTimeBuffer        = 4;      % cadences to add to each side of a transit
runParamsData.keplerData.rowCorrection            = 0;      % offset to add to tad target definitions.
runParamsData.keplerData.colCorrection            = 0;      % offset to add to tad target definitions.
runParamsData.keplerData.refPixCadenceInterval    = 48;     % how often to save reference pixels (in cadences)
runParamsData.keplerData.refPixCadenceOffset      = 0;      % offset to add to reference pixel cadence interval.
runParamsData.keplerData.requantizationTableId    = requantizationTableId;  % ID of requantization table

%--------------------------------------------------------------------------
% RETRIEVE FIXED OFFSETS
requantTableLcFixedOffset = get_long_cadence_fixed_offset(configMapObject, mjdStart);
requantTableScFixedOffset = get_short_cadence_fixed_offset(configMapObject, mjdStart);

runParamsData.keplerData.requantTableLcFixedOffset = requantTableLcFixedOffset; % needs to match requantization table
runParamsData.keplerData.requantTableScFixedOffset = requantTableScFixedOffset; % needs to match requantization table
%--------------------------------------------------------------------------


% global pointing offset data
runParamsData.keplerData.raOffset       = 0;    % in longitudinal degrees
runParamsData.keplerData.decOffset      = 0;    % degrees
runParamsData.keplerData.phiOffset      = 0;    % degrees

% set the raDec2pix object
runParamsData.raDec2PixData = pluginList.productionRaDec2PixData;

% set the barycentric time correction object
runParamsData.barycentricTimeCorrectionData = pluginList.barycentricTimeCorrectionData;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set the tad object
% the following lines cause ETEM2 to run tad to determined target
% definitions
% tadInputData = pluginList.runTadData;
% tadInputData.targetSelectorData = pluginList.selectTargetByPropertyData;
% tadInputData.usePointingOffsets = 0;

% the following lines cause ETEM2 to get target definitions from the database
tadInputData                            = pluginList.databaseTadData;
tadInputData.targetListSetName          = targetListSetName;
tadInputData.refPixTargetListSetName    = refPixTargetListSetName;

% these lines must be present in any case
if isfield(tadInputData, 'targetListSetName')
    runParamsData.keplerData.targetListSetName = tadInputData.targetListSetName;
else
    runParamsData.keplerData.targetListSetName = [];
end

% set the catalog reader object
catalogReaderData                       = pluginList.targetOnlyCatalogData;  %use only if defining target list set
%catalogReaderData                      = pluginList.etem1CatalogReaderData;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define ccd plane objects
%
ccdPlaneCount = 1;
% define the psf for this ccd plane
% ccdPlaneData(ccdPlaneCount).psfObjectData       = pluginList.psfByModOutData;
ccdPlaneData(ccdPlaneCount).psfObjectData     = pluginList.specificPsfData;
% ccdPlaneData(ccdPlaneCount).psfObjectData.psfFilename = 'psf_focus_4_z1f1.mat';
% ccdPlaneData(ccdPlaneCount).psfObjectData.psfFilename = 'psf_focus_1_z5f5.mat';

% define motions that are global to this ccd plane
ccdPlaneData(ccdPlaneCount).motionDataList      = [];
% define the selection algorithm which determines which stars are on this plane
ccdPlaneData(ccdPlaneCount).starSelectorData    = pluginList.randomStarSelectorData;
ccdPlaneData(ccdPlaneCount).starSelectorData.probability = 1; %pick out all the stars
ccdPlaneData(ccdPlaneCount).diagnosticDisplay   = 1;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define ccd object
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% JITTER/DVA:

% define motions that are global to the ccd. first define the special dva motion object
% this object cannot be empty.  To turn jitter off use
%ccdData.dvaMotionData                       = pluginList.dvaNoMotionData;
ccdData.dvaMotionData                      = pluginList.dvaMotionData;

% define the special jitter motion object, this object cannot be empty.  To turn jitter off use
%ccdData.jitterMotionData                    = pluginList.jitterNoMotionData;
ccdData.jitterMotionData                   = pluginList.pointingJitterMotionData;

%
% define the other motion objects in the motion list, example:
%
% ccdMotionCount = 1;
% ccdData.motionDataList(ccdMotionCount)    = {pluginList.jitterMotionData};
ccdData.motionDataList                      = [];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% BACKGROUND/ZODI
%
% define the visible background objects, these background signals appear on the visible pixels only
%
%counter = 1;
%ccdData.visibleBackgroundDataList(counter) = {pluginList.zodiacalLightData};
%
%counter = counter+1;
%ccdData.visibleBackgroundDataList(counter) = {pluginList.stellarBackgroundData};
ccdData.visibleBackgroundDataList            = [];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DARK CURRENT:
%
% define the pixel background objects, these background signals appear on all physical pixels
%
if (darkEnabled)

    counter = 1;
    ccdData.pixelBackgroundDataList(counter) = {pluginList.darkCurrentData};
    ccdData.pixelBackgroundDataList{counter}.darkCurrentValue = darkCurrentValue;
else
    ccdData.pixelBackgroundDataList          = [];
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% FLAT FIELD:
%
% define the flat field component objects
%
if (flatFieldEnabled)

    counter = 1;
    ccdData.flatFieldDataList(counter)  = {pluginList.flatFieldData};
else
    ccdData.flatFieldDataList           = [];
end

% counter = counter+1;
% ccdData.flatFieldDataList(counter)    = {pluginList.vignettingData};


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2DBLACK:
%
% define the black level object
ccdData.blackLevelData                  = pluginList.twoDBlackData;


% define the pixel effect objects
% counter = 1;
% ccdData.pixelEffectDataList(counter) ...
%     = {pluginList.cteData};
ccdData.pixelEffectDataList=[];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% NONLINEARITY/GAIN
%
% define the electrons to ADU converter object
%
if (nonlinearityEnabled)

    ccdData.electronsToAduData           = pluginList.nonlinearEtoAData;
else
    ccdData.electronsToAduData           = pluginList.linearEtoAData;
end

% define the spatially varying well depth object
ccdData.wellDepthVariationData           = pluginList.spatialWellDepthData;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% SHOT NOISE
%
% define the pixel noise objects
%
if (shotNoiseEnabled)

    counter = 1;
    ccdData.pixelNoiseDataList(counter)   = {pluginList.shotNoiseData};
else
    ccdData.pixelNoiseDataList            = [];
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% UNDERSHOOT
%
% define the electronics effects objects
%
if (undershootEnabled)

    counter = 1;
    ccdData.electronicsEffectDataList(counter) = {pluginList.etemUndershootData};
else
    ccdData.electronicsEffectDataList     = [];
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% READ NOISE
%
% define the read noise objects
%
if (readNoiseEnabled)

    counter = 1;
    ccdData.readNoiseDataList(counter)     = {pluginList.readNoiseData};
else
    ccdData.readNoiseDataList              = [];
end

% define the list of ccdPlanes
ccdData.ccdPlaneDataList = ccdPlaneData;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% COSMIC RAYS
%
% define the cosmic ray object
%
if (cosmicRaysEnabled)

    ccdData.cosmicRayData                  = pluginList.cosmicRayData;
else
    ccdData.cosmicRayData                  = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define the target science manager object, with list of target
% assignment specifications
% the targetScienceManager cannot be instantiated until the
% the targets have been defined by a call to
% set_pixels_of_interest(ccdObject).
% counter = 1;
% ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
%     'SOHO-based stellar variability';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'all';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
% 	= pluginList.sohoSolarVariabilityData;
% 
% 
% counter = counter + 1;
% ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
%     'Transiting Earths';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'random';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber = 20;
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn = 'properties';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange = [5240 6530];
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange = [4 5];
% ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
% 	= pluginList.transitingPlanetData;
% 
% 
% counter = counter + 1;
% ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
%     'Transiting Jupiters';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'random';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber = 20;
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn = 'properties';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange = [5240 6530];
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange = [4 5];
% ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
% 	= pluginList.transitingPlanetData;
% ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits = 'jupiterRadius';
% 
% 
% counter = counter + 1;
% ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
%     'Eclipsing Binary Stars';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'random';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber = 20;
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn = 'properties';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange = [5240 6530];
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange = [4 5];
% ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
% 	= pluginList.transitingStarData;
% 
% ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionType = 'random';
% ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionNumber = 20;
% ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionOn = 'properties';
% ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionMagnitudeRange = [9 15];
% ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionEffTempRange = [5240 6530];
% ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionlogGRange = [4 5];
% ccdData.targetScienceManagerData.backgroundBinarySpecification.backgroundBinaryData ...
% 	= pluginList.backgroundBinaryData;

% the following line turns off all astrophysics
ccdData.targetScienceManagerData = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear everything we don't want saved
clear ccdPlaneData ccdPlaneCount ccdMotionCount etem2FileLocations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the output struct
gloabalConfigurationStruct.runParamsData        = runParamsData;
gloabalConfigurationStruct.ccdData              = ccdData;
gloabalConfigurationStruct.tadInputData         = tadInputData;
gloabalConfigurationStruct.catalogReaderData    = catalogReaderData;
