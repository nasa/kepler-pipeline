function gloabalConfigurationStruct = ETEM2_inputs_TC02()

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs for etem2 test data generation for verification/validation
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Input file that will be used for select mod/outs to generate data for
% verification and validation of various CSCIs. 
%
% This version, TC02, includes the following CCD effects/astrophysics:
%
% ENABLED:
%
%   2D      2D black
%   ST      stars 
%   SM      smear
%   DC      dark current
%   NL      nonlinearity
%   LU      lde undershoot
%   FF      flat field
%   RN      read noise
%   QN      quantization noise
%   SN      shot noise
%   ZD      zodiacal light
%
% DISABLED:
%
%   dv      differential velocity aberration
%   jt      jitter
%   sv      stellar variability
%   ap      astrophysics (transit light curves)
%   cr      cosmic rays
%
%
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Version date:  2009-November-19.
%
%
% Modification History:
%
% Jan-13-2010
% EQ: disabled the effects as indicated above.
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
runParamsData.simulationData.runDuration              = 1440;  %OVERWRITTEN            % length of run in the units defined in the next field
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
import gov.nasa.kepler.common.FcConstants;

% set ccd parameters
runParamsData.keplerData.numVisibleRows     = FcConstants.nRowsImaging;
runParamsData.keplerData.numVisibleCols     = FcConstants.nColsImaging;
runParamsData.keplerData.numLeadingBlack    = FcConstants.nLeadingBlack;
runParamsData.keplerData.numTrailingBlack   = FcConstants.nTrailingBlack;
runParamsData.keplerData.numVirtualSmear    = FcConstants.nVirtualSmear;
runParamsData.keplerData.numMaskedSmear     = FcConstants.nMaskedSmear;

runParamsData.keplerData.numAtoDBits        = FcConstants.BITS_IN_ADC;
runParamsData.keplerData.saturationSpillUpFraction = FcConstants.SATURATION_SPILL_UP_FRACTION; % fraction of spilled saturation goes up
runParamsData.keplerData.parallelCTE        = FcConstants.PARALLEL_CTE;     % parallel charge transfer efficiency
runParamsData.keplerData.serialCTE          = FcConstants.SERIAL_CTE;       % serial charge transfer efficiency
runParamsData.keplerData.pixelAngle         = FcConstants.pixel2arcsec;     % pixel width in seconds of arc
runParamsData.keplerData.fluxOfMag12Star    = FcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND; % flux of a 12th magnitude start in e-/sec

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
runParamsData.keplerData.supressAllMotion       = true;                     % diagnostic which if true turns all object motion off
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
ccdPlaneData(ccdPlaneCount).psfObjectData = pluginList.specificPsfData;

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
% or set suppressAllMotion=true;
ccdData.dvaMotionData = pluginList.dvaMotionData;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Jitter Motion
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the special jitter motion object (this object cannot be empty).
% To turn off use: ccdData.jitterMotionData = pluginList.jitterNoMotionData;
% or set suppressAllMotion=true;
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
%
% To turn off use: ccdData.visibleBackgroundDataList = [];

counter = 1;
ccdData.visibleBackgroundDataList(counter) = {pluginList.stellarBackgroundData};

counter = counter+1;
ccdData.visibleBackgroundDataList(counter) = {pluginList.zodiacalLightData};


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
% To turn on, use: ccdData.cosmicRayData = pluginList.cosmicRayData;
ccdData.cosmicRayData = [];


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Astrophysics:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% To turn off all astrophysics, use:
ccdData.targetScienceManagerData = [];


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Stellar Variability
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% To turn off, disable astrophysics
%
% counter = 1;
% ccdData.targetScienceManagerData.targetSpecifiction(counter).description = ...
%     'SOHO-based stellar variability';
% ccdData.targetScienceManagerData.targetSpecifiction(counter).selectionType = 'all';
% 
% ccdData.targetScienceManagerData.targetSpecifiction(counter).lightCurveData ...
%     = pluginList.sohoSolarVariabilityData;
%



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set the output struct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% clear everything we don't want saved
clear ccdPlaneData ccdPlaneCount ccdMotionCount etem2FileLocations

gloabalConfigurationStruct.runParamsData        = runParamsData;
gloabalConfigurationStruct.ccdData              = ccdData;
gloabalConfigurationStruct.tadInputData         = tadInputData;
gloabalConfigurationStruct.catalogReaderData    = catalogReaderData;


