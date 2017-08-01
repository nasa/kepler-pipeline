function gloabalConfigurationStruct = ETEM2_inputs_example()

% Example ETEM2 input file which
% set up all ETEM2 input variables and saves them in a mat file named
% ETEM2_inputs_run###.mat
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

% get set of defined plugin classes
pluginList = defined_plugin_classes();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global specification data for this simulation run
runParamsData.simulationData.numberOfTargetsRequested=6; % Number of target stars before downselect

runParamsData.simulationData.runStartDate = '1-May-2009 12:00:00.000'; % start date of current run
runParamsData.simulationData.runDuration = 30; % length of run in the units defined in the next field
runParamsData.simulationData.runDurationUnits = 'days'; % units of run length paramter: 'days' or 'cadences'
runParamsData.simulationData.initialScienceRun = -1; % if positive, indicates a previous run to use as base
runParamsData.simulationData.firstExposureStartDate = '1-Mar-2009 17:29:36.8448'; % Date of a roll near launch.

runParamsData.simulationData.moduleNumber = 15; % which CCD module, ouput and season, legal values: 2-4, 6-20, 22-24
runParamsData.simulationData.outputNumber = 3; % legal values: 1-4
runParamsData.simulationData.observingSeason = 1; % 0-3 0-summer,1-fall,2-winter,3-spring

runParamsData.simulationData.cadenceType = 'short'; % cadence types, <long> or <short>

% allowed values: exposuresPerShortCadence 7 - 19, shortsPerLongCadence: 15 - 120
runParamsData.keplerData.exposuresPerShortCadence = 9; % # of exposures in a short cadence, 9 for a ~1-minute cadence
runParamsData.keplerData.shortsPerLongCadence = 30; % # of short cadences in a long cadence

runParamsData.simulationData.cleanOutput = 0; % 1 to remove restart files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data about the current run
runParamsData.etemInformation.className = 'runParamsClass';
% Root location of the ETEM 2 code
runParamsData.etemInformation.etem2Location = '.';
runParamsData.etemInformation.etem2OutputLocation = [runParamsData.etemInformation.etem2Location filesep 'output']; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global data about the spacecraft
runParamsData.keplerData.keplerInitialOrbitFilename = 'keplerInitialOrbit.mat';
runParamsData.keplerData.keplerInitialOrbitFileLocation = 'configuration_files';

% set ccd parameters
% set values from the focal plane constants
import gov.nasa.kepler.common.FcConstants;
 
runParamsData.keplerData.numVisibleRows = FcConstants.nRowsImaging;
runParamsData.keplerData.numVisibleCols = FcConstants.nColsImaging;
runParamsData.keplerData.numLeadingBlack = FcConstants.nLeadingBlack;
runParamsData.keplerData.numTrailingBlack = FcConstants.nTrailingBlack;
runParamsData.keplerData.numVirtualSmear = FcConstants.nVirtualSmear;
runParamsData.keplerData.numMaskedSmear = FcConstants.nMaskedSmear;
runParamsData.keplerData.numAtoDBits = FcConstants.BITS_IN_ADC;
runParamsData.keplerData.saturationSpillUpFraction = FcConstants.SATURATION_SPILL_UP_FRACTION; % fraction of spilled saturation goes up
runParamsData.keplerData.parallelCTE = FcConstants.PARALLEL_CTE; % parallel charge transfer efficiency
runParamsData.keplerData.serialCTE = FcConstants.SERIAL_CTE; % serial charge transfer efficiency
runParamsData.keplerData.pixelAngle = FcConstants.pixel2arcsec; % pixel width in seconds of arc
runParamsData.keplerData.fluxOfMag12Star = FcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND; % flux of a 12th magnitude start in e-/sec

runParamsData.keplerData.pixelWidth = 27; % pixel width in microns
runParamsData.keplerData.boresiteDec = 44.5; % declination of boresite in degrees
runParamsData.keplerData.boresiteRa = 290.67; % RA of boresite in degrees

runParamsData.keplerData.intrapixWavelength = 800; % wavelength in nm of intra pixel variability
                                  % must be 500 or 800 nm
% specification of which collateral pixels to use relative to the pixel set
runParamsData.keplerData.maskedSmearCoAddRows = 7:19;
runParamsData.keplerData.virtualSmearCoAddRows = 1046:1059;
runParamsData.keplerData.blackCoAddCols = 1116:1132;

runParamsData.keplerData.nSubPixelLocations = 10; % # of sub-pixel locations on a side of  a pixel
runParamsData.keplerData.prfDesignRangeBuffer = 1.25; % amount to expand prf design rangef

runParamsData.keplerData.integrationTime = 6.01982; % seconds from mail 4-June-2007.  Was 5.70845
runParamsData.keplerData.transferTime = 0.51895; % seconds from CDPP spreadsheed
runParamsData.keplerData.wellCapacity = 1.30E+06; % electrons assuming 1.3 milliion e- full well
runParamsData.keplerData.readNoise = 100; % e-/pixel/second (should be 100, use 30 to get more pixels for test)

runParamsData.keplerData.numMemoryBits = 23; % number of bits in accumulation memory
runParamsData.keplerData.electronsPerADU = 116; % match current value
runParamsData.keplerData.adcGuardBandFractionLow = 0.05; % 5% guard band on low end of A/D converter
runParamsData.keplerData.adcGuardBandFractionHigh = 0.05; % 5% guard band on high end of A/D converter
runParamsData.keplerData.chargeDiffusionSigma = 1; % charge diffusion coefficient in microns
runParamsData.keplerData.chargeDiffusionArraySize = 51; % size of super-resolution grid for charge diffusion kernel, must be odd

runParamsData.keplerData.simulationFramesPerExposure = 5; % # of simulation frames per integration
                        % not sure about that: ETEM comments say
                        % = ceil(integrationTime/.5 + 1) but that's not
                        % consistent with ETEM values
runParamsData.keplerData.numChains = 5; % not entirely sure what this is - fixed by hardware?

runParamsData.keplerData.motionPolyOrder = 6; % order of the motion polynomial
runParamsData.keplerData.dvaMeshOrder = 3; % order of the dva motion interpolation polynomial
runParamsData.keplerData.motionGridResolution = 5; % number of points on a side for motion grid
runParamsData.keplerData.numCadencesPerChunk = 100; % number of cadences to work with for memory management
runParamsData.keplerData.targetImageSize = 11; % size on a side of a target image in pixels.  Must be odd.

runParamsData.keplerData.badFitTolerance = 6; % allowed error before a pixel is considered badly fit
runParamsData.keplerData.saturationBoxSize = 7; % box to put around saturated pixels
runParamsData.keplerData.supressAllMotion = 0; % diagnostic which if true turns all object motion off
runParamsData.keplerData.supressAllStars = 0; % diagnostic which if true turns all stars off
runParamsData.keplerData.supressSmear = 0; % if true don't add smear, for producing clean image
runParamsData.keplerData.supressQuantizationNoise = 0; % if true don't add quantization noise, for producing clean image
runParamsData.keplerData.useMeanBias = 0; % if true use average bias, for producing clean image
runParamsData.keplerData.makeClean = 0; % if true use average bias, for producing clean image
runParamsData.keplerData.transitTimeBuffer = 4; % cadences to add to each side of a transit

runParamsData.keplerData.rowCorrection = 0; % offset to add to tad target definitions.
runParamsData.keplerData.colCorrection = 0; % offset to add to tad target definitions.

runParamsData.keplerData.refPixCadenceInterval = 48; % how often to save reference pixels (in cadences)
runParamsData.keplerData.refPixCadenceOffset = 0; % offset to add to reference pixel cadence interval.

runParamsData.keplerData.requantizationTableId = 42; % ID of requantization table
runParamsData.keplerData.requantTableLcFixedOffset = 419400; % needs to match requantization table
runParamsData.keplerData.requantTableScFixedOffset = 219400; % needs to match requantization table

% global pointing offset data
runParamsData.keplerData.raOffset = 0; % in longitudinal degrees
runParamsData.keplerData.decOffset = 0; % degrees
runParamsData.keplerData.phiOffset = 0; % degrees

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the raDec2pix object
runParamsData.raDec2PixData = pluginList.productionRaDec2PixData;
% set the barycentric time correction object
runParamsData.barycentricTimeCorrectionData = pluginList.barycentricTimeCorrectionData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the tad object
% the following lines cause ETEM2 to run tad to determined target
% definitions
tadInputData = pluginList.runTadData; 
tadInputData.targetSelectorData = pluginList.selectTargetByPropertyData;
tadInputData.targetSelectorData.magnitudeRange = [8 13];
tadInputData.usePointingOffsets = 0;
%%%%%
% the following lines cause ETEM2 to get target definitions from the
% database
% tadInputData = pluginList.databaseTadData;
% tadInputData.targetListSetName = 'set_name_here';
% tadInputData.refPixTargetListSetName = 'set_name_here';

% these lines must be present in any case
if isfield(tadInputData, 'targetListSetName')
	runParamsData.keplerData.targetListSetName = tadInputData.targetListSetName;
else
	runParamsData.keplerData.targetListSetName = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the catalog reader object
catalogReaderData = pluginList.kicCatalogReaderData; 
% catalogReaderData = pluginList.etem1CatalogReaderData; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define ccd plane objects

ccdPlaneCount = 1;
% define the psf for this ccd plane
ccdPlaneData(ccdPlaneCount).psfObjectData = pluginList.specificPsfData;

% define motions that are global to this ccd plane
ccdPlaneData(ccdPlaneCount).motionDataList = [];
% define the selection algorithm which determines which stars are on this
% plane
ccdPlaneData(ccdPlaneCount).starSelectorData = pluginList.randomStarSelectorData;
ccdPlaneData(ccdPlaneCount).starSelectorData.probability = 1; %pick out all the stars
ccdPlaneData(ccdPlaneCount).diagnosticDisplay = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define ccd object

% define motions that are global to the ccd
% first define the special dva motion object
% this object cannot be empty.  To turn jitter off use
% ccdData.dvaMotionData = pluginList.dvaNoMotionData;
ccdData.dvaMotionData = pluginList.dvaMotionData;

% define the special jitter motion object
% this object cannot be empty.  To turn jitter off use
% ccdData.jitterMotionData = pluginList.jitterNoMotionData;
ccdData.jitterMotionData = pluginList.pointingJitterMotionData;

% define the other motion objects in the motion list
% example:
% ccdMotionCount = 1;
% ccdData.motionDataList(ccdMotionCount) = {pluginList.jitterMotionData};
ccdData.motionDataList = [];

% define the visible background objects
% these background signals appear on the visible pixels only
counter = 1;
ccdData.visibleBackgroundDataList(counter) ...
    = {pluginList.zodiacalLightData};
counter = counter+1;
ccdData.visibleBackgroundDataList(counter) ...
    = {pluginList.stellarBackgroundData};

% define the pixel background objects
% these background signals appear on all physical pixels
counter = 1;
ccdData.pixelBackgroundDataList(counter) ...
    = {pluginList.darkCurrentData};

% define the flat field component objects
counter = 1;
ccdData.flatFieldDataList(counter) ...
    = {pluginList.flatFieldData};
% counter = counter+1;
% ccdData.flatFieldDataList(counter) ...
%     = {pluginList.vignettingData};

% define the black level object
ccdData.blackLevelData = pluginList.twoDBlackData;

% define the pixel effect objects
counter = 1;
ccdData.pixelEffectDataList(counter) ...
    = {pluginList.cteData};

% define the electrons to ADU converter object
ccdData.electronsToAduData = pluginList.nonlinearEtoAData;

% define the spatially varying well depth object
ccdData.wellDepthVariationData = pluginList.spatialWellDepthData;

% define the pixel noise objects
counter = 1;
ccdData.pixelNoiseDataList(counter) ...
    = {pluginList.shotNoiseData};

% define the electronics effects objects
counter = 1;
ccdData.electronicsEffectDataList(counter) ...
    = {pluginList.etemUndershootData};

% define the read noise objects
counter = 1;
ccdData.readNoiseDataList(counter) ...
    = {pluginList.readNoiseData};
% ccdData.pixelNoiseDataList = [];

% define the list of ccdPlanes
ccdData.ccdPlaneDataList = ccdPlaneData;

% define the cosmic ray object
% ccdData.cosmicRayData = [];
ccdData.cosmicRayData = pluginList.cosmicRayData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define the target science manager object, with list of target
% assignment specifications
% the targetScienceManager cannot be instantiated until the 
% the targets have been defined by a call to 
% set_pixels_of_interest(ccdObject).
counter = 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'SOHO-based stellar variability';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'all';
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
	= pluginList.sohoSolarVariabilityData;
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Transiting Earths';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber = 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [8 13];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange = [4 5];
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
	= pluginList.transitingPlanetData;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange = [10 20]; % days
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Transiting Jupiters';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber = 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [8 13];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange = [4 5];
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
	= pluginList.transitingPlanetData;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.radiusUnits = 'jupiterRadius';
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange = [10 30]; % days
counter = counter + 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
    'Eclipsing Binary Stars';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'random';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionNumber = 1;
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionOn = 'properties';
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionMagnitudeRange = [8 13];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionEffTempRange = [5240 6530];
ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionlogGRange = [4 5];
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
	= pluginList.transitingStarData;
ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData.orbitalPeriodRange = [10 40]; % days
	
% the following line turns off all astrophysics
% ccdData.targetScienceManagerData = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear everything we don't want saved
clear ccdPlaneData ccdPlaneCount ccdMotionCount etem2FileLocations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the output struct
gloabalConfigurationStruct.runParamsData = runParamsData;
gloabalConfigurationStruct.ccdData = ccdData;
gloabalConfigurationStruct.tadInputData = tadInputData;
gloabalConfigurationStruct.catalogReaderData = catalogReaderData;
