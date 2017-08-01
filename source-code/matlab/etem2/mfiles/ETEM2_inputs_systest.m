function gloabalConfigurationStruct = ETEM2_inputs_dv()

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs for Data Validation test data
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Input file that will be used to generate ETEM2 data for one Module/Output
% (7/3 = Channel 19) for verification/validation of all CSCIs
%
% The injected astrophysics have been tailored to suit DV testing, and
% include three multiple planet systems for specified Kepler IDs on
% Channel 19, along with an assortment of short and medium period Earths,
% Jupiters, eclipsing binaries, and background binaries.
%
% Version date:  2010-July-21.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


% get set of defined plugin classes
pluginList = defined_plugin_classes();

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% global specification data for this simulation run
%
% Note that many of these get retrieved of overwritten by the etem2_matlab_controller
% when run in the pipeline
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

runParamsData.simulationData.numberOfTargetsRequested = 2000;  %OVERWRITTEN           % Number of target stars before downselect
runParamsData.simulationData.runStartDate             = '26-June-2009 00:00:00.000'; % start date of current run
runParamsData.simulationData.runDuration              = 100;  %OVERWRITTEN            % length of run in the units defined in the next field
runParamsData.simulationData.runDurationUnits         = 'cadences';                   % units of run length paramter: 'days' or 'cadences'
runParamsData.simulationData.initialScienceRun        = -1;                           % if positive, indicates a previous run to use as base
runParamsData.simulationData.firstExposureStartDate   = '1-Mar-2009 17:29:36.8448';   % Date of a roll near launch.

runParamsData.simulationData.moduleNumber       = 7;  %OVERWRITTEN                    % which CCD module, ouput and season, legal values: 2-4, 6-20, 22-24
runParamsData.simulationData.outputNumber       = 3;  %OVERWRITTEN                    % legal values: 1-4
runParamsData.simulationData.observingSeason    = 0;  %OVERWRITTEN                    % 0-3 0-summer,1-fall,2-winter,3-spring
runParamsData.simulationData.cadenceType        = 'long';  %OVERWRITTEN               % cadence types, <long> or <short>

runParamsData.keplerData.exposuresPerShortCadence   = 9;   %OVERWRITTEN               % # of exposures in a short cadence, 9 for a ~1-minute cadence
runParamsData.keplerData.shortsPerLongCadence       = 30;  %OVERWRITTEN               % # of short cadences in a long cadence

runParamsData.simulationData.cleanOutput = 0;                                         % 1 to remove restart files

% data about the current run
runParamsData.etemInformation.className = 'runParamsClass';

% root location of the ETEM 2 code
runParamsData.etemInformation.etem2Location = '.';
runParamsData.etemInformation.etem2OutputLocation = ...
    [runParamsData.etemInformation.etem2Location filesep 'output'];  %OVERWRITTEN



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% global data about the spacecraft
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
runParamsData.keplerData.keplerInitialOrbitFilename     = 'keplerInitialOrbit.mat';
runParamsData.keplerData.keplerInitialOrbitFileLocation = 'configuration_files';

% set values from the focal plane constants
% ETEM requires the optional argument '1' to
% convert_fc_constants_java_2_struct,
% but this argument should not be used in any other case.
fcConstants = convert_fc_constants_java_2_struct(1);
runParamsData.keplerData.fcConstants = fcConstants;

% set ccd parameters
runParamsData.keplerData.numVisibleRows     = fcConstants.nRowsImaging;
runParamsData.keplerData.numVisibleCols     = fcConstants.nColsImaging;
runParamsData.keplerData.numLeadingBlack    = fcConstants.nLeadingBlack;
runParamsData.keplerData.numTrailingBlack   = fcConstants.nTrailingBlack;
runParamsData.keplerData.numVirtualSmear    = fcConstants.nVirtualSmear;
runParamsData.keplerData.numMaskedSmear     = fcConstants.nMaskedSmear;

runParamsData.keplerData.numAtoDBits        = fcConstants.BITS_IN_ADC;
runParamsData.keplerData.saturationSpillUpFraction = fcConstants.SATURATION_SPILL_UP_FRACTION; % fraction of spilled saturation goes up
runParamsData.keplerData.parallelCTE        = fcConstants.PARALLEL_CTE;     % parallel charge transfer efficiency
runParamsData.keplerData.serialCTE          = fcConstants.SERIAL_CTE;       % serial charge transfer efficiency
runParamsData.keplerData.pixelAngle         = fcConstants.pixel2arcsec;     % pixel width in seconds of arc
runParamsData.keplerData.fluxOfMag12Star    = fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND; % flux of a 12th magnitude start in e-/sec

runParamsData.keplerData.pixelWidth         = 27;                           % pixel width in microns
runParamsData.keplerData.boresiteDec        = 44.5;                         % declination of boresite in degrees
runParamsData.keplerData.boresiteRa         = 290.67;                       % RA of boresite in degrees

runParamsData.keplerData.intrapixWavelength = 800;                          % wavelength in nm of intra pixel variability, must be 500 or 800 nm


runParamsData.keplerData.maskedSmearCoAddRows   = 7:19; %OVERWRITTEN        % specification of collateral pixels to use relative to the pixel set
runParamsData.keplerData.virtualSmearCoAddRows  = 1046:1059; %OVERWRITTEN
runParamsData.keplerData.blackCoAddCols         = 1116:1132; %OVERWRITTEN

runParamsData.keplerData.nSubPixelLocations     = 10;                       % # of sub-pixel locations on a side of  a pixel
runParamsData.keplerData.prfDesignRangeBuffer   = 1.25;                     % amount to expand prf design rangef

runParamsData.keplerData.integrationTime        = 6.01982; %OVERWRITTEN
runParamsData.keplerData.transferTime           = 0.51895; %OVERWRITTEN
runParamsData.keplerData.wellCapacity           = 1.30E+06;                 % electrons assuming 1.3 milliion e- full well
runParamsData.keplerData.readNoise              = 100; %OVERWRITTEN         % e-/pixel/second

runParamsData.keplerData.numMemoryBits          = 23;                       % number of bits in accumulation memory
runParamsData.keplerData.electronsPerADU        = 116; %OVERWRITTEN         % gain
runParamsData.keplerData.adcGuardBandFractionLow  = 0.05;                   % 5% guard band on low end of A/D converter
runParamsData.keplerData.adcGuardBandFractionHigh = 0.05;                   % 5% guard band on high end of A/D converter
runParamsData.keplerData.chargeDiffusionSigma     = 1;                      % charge diffusion coefficient in microns
runParamsData.keplerData.chargeDiffusionArraySize = 51;                     % size of super-resolution grid for charge diffusion kernel, must be odd

runParamsData.keplerData.simulationFramesPerExposure = 5;                   % # of simulation frames per integration
runParamsData.keplerData.numChains              = 5;                        % not entirely sure what this is - fixed by hardware?
runParamsData.keplerData.motionPolyOrder        = 6;                        % order of the motion polynomial
runParamsData.keplerData.dvaMeshOrder           = 3;                        % order of the dva motion interpolation polynomial
runParamsData.keplerData.motionGridResolution   = 5;                        % number of points on a side for motion grid
runParamsData.keplerData.numCadencesPerChunk    = 100;                      % number of cadences to work with for memory management
runParamsData.keplerData.targetImageSize        = 11;                       % size on a side of a target image in pixels.  Must be odd.

runParamsData.keplerData.badFitTolerance        = 6;                        % allowed error before a pixel is considered badly fit
runParamsData.keplerData.saturationBoxSize      = 7;                        % box to put around saturated pixels
runParamsData.keplerData.supressAllMotion       = 0;                        % diagnostic which if true turns all object motion off
runParamsData.keplerData.supressAllStars        = 0;                        % diagnostic which if true turns all stars off
runParamsData.keplerData.supressSmear           = 0;                        % if true don't add smear, for producing clean image
runParamsData.keplerData.supressQuantizationNoise = 0;                      % if true don't add quantization noise, for producing clean image
runParamsData.keplerData.useMeanBias            = 0;                        % if true use average bias, for producing clean image
runParamsData.keplerData.makeClean              = 0;                        % if true use average bias, for producing clean image
runParamsData.keplerData.transitTimeBuffer      = 1;                        % cadences to add to each side of a transit

runParamsData.keplerData.rowCorrection = 0;                                 % offset to add to tad target definitions.
runParamsData.keplerData.colCorrection = 0;                                 % offset to add to tad target definitions.

runParamsData.keplerData.refPixCadenceInterval  = 48;                       % how often to save reference pixels (in cadences)
runParamsData.keplerData.refPixCadenceOffset    = 0;                        % offset to add to reference pixel cadence interval.

runParamsData.keplerData.requantizationTableId     = 200; %OVERWRITTEN      % ID of requantization table,
runParamsData.keplerData.requantTableLcFixedOffset = 419400; %OVERWRITTEN
runParamsData.keplerData.requantTableScFixedOffset = 219400; %OVERWRITTEN

% global pointing offset data
runParamsData.keplerData.raOffset  = 0;                                     % in longitudinal degrees
runParamsData.keplerData.decOffset = 0;                                     % degrees
runParamsData.keplerData.phiOffset = 0;                                     % degrees


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set the raDec2pix object
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
runParamsData.raDec2PixData = pluginList.productionRaDec2PixData;
% set the barycentric time correction object
runParamsData.barycentricTimeCorrectionData = pluginList.barycentricTimeCorrectionData;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set the tad object
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% the following lines cause ETEM2 to run tad to determined target definitions
% tadInputData                    = pluginList.runTadData;
% tadInputData.targetSelectorData = pluginList.selectTargetByPropertyData;
% tadInputData.targetSelectorData.magnitudeRange = [9 17];
% tadInputData.usePointingOffsets = 0;

% the following lines cause ETEM2 to get target definitions from the database
tadInputData                            = pluginList.databaseTadData;
tadInputData.targetListSetName          = 'quarter2_summer2009_lc'; %OVERWRITTEN
tadInputData.refPixTargetListSetName    = 'quarter2_summer2009_rp_trimmed'; %OVERWRITTEN % quarter3_fall2009_rp_v3 or quarter2_summer2009_rp_trimmed

% these lines must be present in any case
if isfield(tadInputData, 'targetListSetName')
    runParamsData.keplerData.targetListSetName = tadInputData.targetListSetName;
else
    runParamsData.keplerData.targetListSetName = [];
end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set the catalog reader object
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
catalogReaderData = pluginList.kicCatalogReaderData;
% catalogReaderData = pluginList.etem1CatalogReaderData;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define ccd plane objects
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ccdPlaneCount = 1;
% define the psf for this ccd plane
% To load PRFs from the database, use the line with
% pluginList.psfFromPrfData.  To load the default pre-flight testing PRFs
% use the line with pluginList.specificPsfData;
% ccdPlaneData(ccdPlaneCount).psfObjectData = pluginList.specificPsfData;
ccdPlaneData(ccdPlaneCount).psfObjectData = pluginList.psfFromPrfData;

% define motions that are global to this ccd plane
ccdPlaneData(ccdPlaneCount).motionDataList = [];

% define the selection algorithm which determines which stars are on this plane
ccdPlaneData(ccdPlaneCount).starSelectorData = pluginList.randomStarSelectorData;
ccdPlaneData(ccdPlaneCount).starSelectorData.probability = 1; %pick out all the stars
ccdPlaneData(ccdPlaneCount).diagnosticDisplay = 1;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define ccd object with the following:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DVA Motion
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define motions that are global to the ccd; first define the special dva
% motion object (this object cannot be empty).
% To turn off use: ccdData.dvaMotionData = pluginList.dvaNoMotionData;
ccdData.dvaMotionData = pluginList.dvaMotionData;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Jitter Motion
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the special jitter motion object (this object cannot be empty).
% To turn off use: ccdData.jitterMotionData = pluginList.jitterNoMotionData;
ccdData.jitterMotionData = pluginList.pointingJitterMotionData;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Other motion
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the other motion objects in the motion list, example:
% ccdMotionCount = 1;
% ccdData.motionDataList(ccdMotionCount) = {pluginList.jitterMotionData};
ccdData.motionDataList = [];


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Background (visible): Zodi and Stellar background
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the visible background objects; these background signals appear on
% the visible pixels only
counter = 1;
ccdData.visibleBackgroundDataList(counter) = {pluginList.zodiacalLightData};

counter = counter+1;
ccdData.visibleBackgroundDataList(counter) = {pluginList.stellarBackgroundData};


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Background (all pixels): Dark Current
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the pixel background objects; these background signals appear on
% all physical pixels
counter = 1;
ccdData.pixelBackgroundDataList(counter) = {pluginList.darkCurrentData};


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Flat Field and Vignetting
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the flat field component objects
counter = 1;
ccdData.flatFieldDataList(counter) = {pluginList.flatFieldData};

% counter = counter+1;
% ccdData.flatFieldDataList(counter) = {pluginList.vignettingData};


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2D Black
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the black level object
ccdData.blackLevelData = pluginList.twoDBlackData;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Charge Transfer Efficiency
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the pixel effect objects
counter = 1;
ccdData.pixelEffectDataList(counter) = {pluginList.cteData};


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Gain and Nonlinearity
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the electrons to ADU converter object
% For gain only, use: ccdData.electronsToAduData = pluginList.linearEtoAData;
ccdData.electronsToAduData = pluginList.nonlinearEtoAData;

% define the spatially varying well depth object
ccdData.wellDepthVariationData = pluginList.spatialWellDepthData;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Shot Noise
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the pixel noise objects
counter = 1;
ccdData.pixelNoiseDataList(counter) = {pluginList.shotNoiseData};


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Undershoot
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the electronics effects objects
counter = 1;
ccdData.electronicsEffectDataList(counter) = {pluginList.etemUndershootData};


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Read Noise
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the read noise objects
counter = 1;
ccdData.readNoiseDataList(counter) = {pluginList.readNoiseData};


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Other Noise
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ccdData.pixelNoiseDataList = [];


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% CCD Plane Data
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the list of ccdPlanes
ccdData.ccdPlaneDataList = ccdPlaneData;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Cosmic Rays
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the cosmic ray object
% To turn off, use: ccdData.cosmicRayData = [];
ccdData.cosmicRayData = pluginList.cosmicRayData;



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Astrophysics:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% To turn off all astrophysics, use:
% ccdData.targetScienceManagerData = [];



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Stellar Variability
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'SOHO-based stellar variability';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'all';

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.sohoSolarVariabilityData;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (1) Earths:
%       Short periods (4-7 days)
%       Range of impact parameters (b = 0-0.7)
%       Circular orbits (e = 0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Earths: P = 4-7 days, b = 0-0.7, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [1 3];       % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'earthRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [1 1];   % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0.7]; % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];  % default = []



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (2) Earths:
%       Short periods (4-7 days)
%       Central transits (b = 0)
%       Circular orbits (e = 0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Earths: P = 4-7 days, b = 0, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [1 3];       % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'earthRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];  % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [4 7];  % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';  % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];  % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];  % default = []



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (3) Earths:
%       Medium periods (7-30 days)
%       Range of impact parameters (b = 0-0.7)
%       Circular orbits (e = 0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Earths: P = 7-30 days, b = 0-0.7, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [1 3];       % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'earthRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [7 30];  % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0.7]; % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];  % default = []



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (4) Earths:
%       Medium periods (7-30 days)
%       Central transits (b = 0)
%       Circular orbits (e = 0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Earths: P = 7-30 days, b = 0, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [1 3];       % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'earthRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];  % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [7 30]; % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';  % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];  % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];  % default = []



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (5) Jupiters:
%       Short periods (4-7 days)
%       Range of impact parameters (b = 0-0.7)
%       Circular orbits (e = 0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Jupiters: P = 4-7 days, b = 0-0.7, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [0.5 3];         % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'jupiterRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [1 1];   % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0.7]; % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];  % default = []



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (6) Jupiters:
%       Short periods (4-7 days)
%       Central transits (b = 0)
%       Circular orbits (e = 0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Jupiters: P = 4-7 days, b = 0, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [0.5 3];         % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'jupiterRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];  % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [4 7];  % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';  % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];  % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];  % default = []




%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (7) Jupiters:
%       Medium periods (7-30 days)
%       Range of impact parameters (b = 0-0.7)
%       Circular orbits (e = 0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Jupiters: P = 7-30 days, b = 0-0.7, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [0.5 3];         % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'jupiterRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [7 30];  % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0.7]; % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];  % default = []




%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (8) Jupiters:
%       Medium periods (7-30 days)
%       Central transits (b = 0)
%       Circular orbits (e = 0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Jupiters: P = 7-30 days, b = 0, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [0.5 3];         % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'jupiterRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];  % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [7 30]; % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';  % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];  % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];     % default = []




%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (9) Eclipsing Binaries:
%       Short periods (4-7 days)
%       Range of impact parameters (b = 0-0.7)
%       Eccentricities randomly drawn from Duquennoy & Mayor (1991) distribution
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Eclipsing Binaries: P = 4-7 days, b = 0-0.7, e = random';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingStarData;


% set stellar companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.effectiveTemperatureRange   = [4800 6500]; % default = [4800 6500]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.logGRange                   = [3 5];   % default = [3 5]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [];      % default = [] %%% ADDED 7/20/2010
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [4 7];   % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0.7]; % default = [0 0.7]



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (10) Eclipsing Binaries:
%       Medium periods (7-30 days)
%       Range of impact parameters (b = 0-0.7)
%       Eccentricities randomly drawn from Duquennoy & Mayor (1991) distribution
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Eclipsing Binaries: P = 7-30 days, b = 0-0.7, e = random';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingStarData;


% set stellar companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.effectiveTemperatureRange   = [4800 6500]; % default = [4800 6500]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.logGRange                   = [3 5];   % default = [3 5]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [];      % default = [] %%% ADDED 7/20/2010
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [7 30];  % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0.7]; % default = [0 0.7]



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (11) Eclipsing Binaries:
%       Short periods (4-7 days)
%       Range of impact parameters (b = 0-0.7)
%       Circular orbits (e=0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Eclipsing Binaries: P = 4-7 days, b = 0-0.7, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingStarData;


% set stellar companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.effectiveTemperatureRange   = [4800 6500]; % default = [4800 6500]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.logGRange                   = [3 5];   % default = [3 5]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = []  %%% ADDED 7/20/2010
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [4 7];   % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0.7]; % default = [0 0.7]



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (12) Eclipsing Binaries:
%       Medium periods (7-30 days)
%       Range of impact parameters (b = 0-0.7)
%       Circular orbits (e=0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Eclipsing Binaries: P = 7-30 days, b = 0-0.7, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingStarData;


% set stellar companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.effectiveTemperatureRange   = [4800 6500]; % default = [4800 6500]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.logGRange                   = [3 5];   % default = [3 5]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = []  %%% ADDED 7/20/2010
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [7 30];  % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0.7]; % default = [0 0.7]


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (13) Eclipsing Binaries:
%       Short periods (4-7 days)
%       Central transits (b=0)
%       Circular orbits (e=0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Eclipsing Binaries: P = 4-7 days, b = 0, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingStarData;


% set stellar companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.effectiveTemperatureRange   = [4800 6500]; % default = [4800 6500]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.logGRange                   = [3 5];   % default = [3 5]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = []  %%% ADDED 7/20/2010
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [4 7];   % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (14) Eclipsing Binaries:
%       Medium periods (7-30 days)
%       Central transits (b=0)
%       Circular orbits (e=0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Eclipsing Binaries: P = 7-30 days, b = 0, e = 0';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingStarData;


% set stellar companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.effectiveTemperatureRange   = [4800 6500]; % default = [4800 6500]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.logGRange                   = [3 5];   % default = [3 5]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = []  %%% ADDED 7/20/2010
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [7 30];  % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (15) Eclipsing Binaries:
%       Short periods (4-7 days)
%       Central transits (b=0)
%       Eccentricities randomly drawn from Duquennoy & Mayor (1991) distribution
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Eclipsing Binaries: P = 4-7 days, b = 0, e = random';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingStarData;


% set stellar companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.effectiveTemperatureRange   = [4800 6500]; % default = [4800 6500]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.logGRange                   = [3 5];   % default = [3 5]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [];      % default = []  %%% ADDED 7/20/2010
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [4 7];   % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (16) Eclipsing Binaries:
%       Medium periods (7-30 days)
%       Central transits (b=0)
%       Eccentricities randomly drawn from Duquennoy & Mayor (1991) distribution
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Eclipsing Binaries: P = 7-30 days, b = 0, e = random';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType           = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber         = 5;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn             = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingStarData;


% set stellar companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.effectiveTemperatureRange   = [4800 6500]; % default = [4800 6500]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.logGRange                   = [3 5];   % default = [3 5]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [];      % default = []  %%% ADDED 7/20/2010
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [7 30];  % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (17) Background Binaries: Medium periods (10-20 days)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set host star parameters
ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionType    = 'random';
ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionNumber  = 5;
ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionOn      = 'properties';
ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionMagnitudeRange = [9 15];
ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionEffTempRange   = [5240 6530];
ccdData.targetScienceManagerData.backgroundBinarySpecification.selectionlogGRange      = [4 5];

ccdData.targetScienceManagerData.backgroundBinarySpecification.backgroundBinaryData ...
    = pluginList.backgroundBinaryData;


% set stellar companion parameters and offsets from target (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.backgroundBinarySpecification.effectiveTemperatureRange    = [4800 6500]; % default = [4800 6500]
ccdData.targetScienceManagerData.backgroundBinarySpecification.logGRange                    = [3 5];     % default = [3 5]
ccdData.targetScienceManagerData.backgroundBinarySpecification.eccentricityRange            = [];        % default = [] for BBs  %%% ADDED 7/22/2010
ccdData.targetScienceManagerData.backgroundBinarySpecification.orbitalPeriodRange           = [10 20];   % default = [10 20]
ccdData.targetScienceManagerData.backgroundBinarySpecification.orbitalPeriodUnits           = 'day';     % default = 'day'
ccdData.targetScienceManagerData.backgroundBinarySpecification.minimumImpactParameterRange  = [0 0.7];   % default = [0 0.7]
ccdData.targetScienceManagerData.backgroundBinarySpecification.pixelOffsetRange             = [0.1 3];   % default = [0.5 1.5]
ccdData.targetScienceManagerData.backgroundBinarySpecification.magnitudeOffsetRange         = [5 7];     % default = [5 7]




%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Multiple body systems
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Kepler Ids are retrieved via:
% validKeplerIds = retrieve_kics_for_dv(module, output)
%
% validKeplerIds_mod7_out3 =
%    * 4557345
%      4920632
%    * 4921090
%      4921698
%    * 5009426
%      5185653
%      5360273
%      5529481
%
% The selected (*) kepler Ids have been cross checked with the target list set,
% in this case (database = kepsnpq/kepsnpt) quarter2_summer2009_lc, and are
% checked against allowed values of effective temp, logg, and magnitude
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% keplerId 4557345, Mod/Out = 7/3
%
% Two planet system: Jupiter(5d)-Earth(15d)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Multiple Planet System #1, Mod/Out = 7/3, KepId = 4557345, Jupiter (Rp=1, P=5 days, b=0, e=0)';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType      = 'byKeplerId';
ccdData.targetScienceManagerData.targetSpecifiction(counter).keplerId           = 4557345;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [1 1];           % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'jupiterRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];  % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [5 5];  % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';  % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];  % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];     % default = []


counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Multiple Planet System #1, Mod/Out = 7/3, KepId = 4557345, Earth (Rp=2.7, P=15 days, b=0, e=0)';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType      = 'byKeplerId';
ccdData.targetScienceManagerData.targetSpecifiction(counter).keplerId           = 4557345;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [2.7 2.7];         % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'earthRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [15 15]; % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];      % default = []



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% keplerId 4921090, Mod/Out = 7/3
%
% Two planet system: Earth(4d)-Jupiter(18d)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Multiple Planet System #2, Mod/Out = 7/3, KepId = 4921090, Jupiter (Rp=2.5, P=18 days, b=0, e=0)';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType      = 'byKeplerId';
ccdData.targetScienceManagerData.targetSpecifiction(counter).keplerId           = 4921090;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [2.5 2.5];           % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'jupiterRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [18 18]; % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];      % default = []


counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Multiple Planet System #2, Mod/Out = 7/3, KepId = 4921090, Earth (Rp=2, P=4 days, b=0, e=0)';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType      = 'byKeplerId';
ccdData.targetScienceManagerData.targetSpecifiction(counter).keplerId           = 4921090;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [2 2];         % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'earthRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [4 4];   % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];      % default = []





%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% keplerId 5009426, Mod/Out = 7/3
%
% Three planet system: Earth (4d)-Jupiter(10d)-Earth(18d)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Multiple Planet System #3, Mod/Out = 7/3, KepId = 5009426, Jupiter (Rp=1.5, P=10 days, b=0, e=0)';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType      = 'byKeplerId';
ccdData.targetScienceManagerData.targetSpecifiction(counter).keplerId           = 5009426;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [1.5 1.5];           % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'jupiterRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [10 10]; % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];      % default = []


counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Multiple Planet System #3, Mod/Out = 7/3, KepId = 5009426, Earth (Rp=1.5, P=4 days, b=0, e=0)';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType      = 'byKeplerId';
ccdData.targetScienceManagerData.targetSpecifiction(counter).keplerId           = 5009426;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [1.5 1.5];         % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'earthRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [4 4];   % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];      % default = []



counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Multiple Planet System #3, Mod/Out = 7/3, KepId = 5009426, Earth (Rp=2.8, P=18 days, b=0, e=0)';

% set host star parameters
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType      = 'byKeplerId';
ccdData.targetScienceManagerData.targetSpecifiction(counter).keplerId           = 5009426;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
    = pluginList.transitingPlanetData;

% set planetary companion parameters (some overwrite defaults in defined_plugins)
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusRange                 = [2.8 2.8];         % default = [0.5 3]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits                 = 'earthRadius'; % default = 'earthRadius'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.eccentricityRange           = [0 0];   % default = [0 0.8]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange          = [18 18]; % default = [10 20]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodUnits          = 'day';   % default = 'day'
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.minimumImpactParameterRange = [0 0];   % default = [0 0.7]
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.depthRange                  = [];      % default = []



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set the output struct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% clear everything we don't want saved
clear ccdPlaneData ccdPlaneCount ccdMotionCount etem2FileLocations

gloabalConfigurationStruct.runParamsData        = runParamsData;
gloabalConfigurationStruct.ccdData              = ccdData;
gloabalConfigurationStruct.tadInputData         = tadInputData;
gloabalConfigurationStruct.catalogReaderData    = catalogReaderData;


