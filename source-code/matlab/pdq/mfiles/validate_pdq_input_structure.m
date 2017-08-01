function  pdqInputStruct = validate_pdq_input_structure(pdqInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  pdqInputStruct = validate_pdq_input_structure(pdqInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function first checks for the presence of expected fields in the input
% structure, then checks whether each parameter is within the appropriate
% range.
%__________________________________________________________________________
% Input:  A data structure 'pdqInputStruct' with the following fields:
%__________________________________________________________________________
%
%   pdqInputStruct contains the following fields most which are structures
%   or arrays of structures
%            pdqConfiguration: [1x1 struct]
%                  fcConstants: [1x1 struct]
%                   configMaps: [1x1 struct]
%                 cadenceTimes: [4x1 double]
%                    gainModel: [1x1 struct]
%               raDec2PixModel: [1x1 struct]
%              twoDBlackModels: [1x84 struct]
%              flatFieldModels: [1x84 struct]
%               readNoiseModel: [1x1 struct]
%                requantTables: [1x1 struct]
%               inputPdqTsData: [1x1 struct]
%            stellarPdqTargets: [1x425 struct]
%         backgroundPdqTargets: [1x84 struct]
%         collateralPdqTargets: [1x1260 struct]
%..........................................................................
%
%     pdqInputStruct.pdqConfiguration contains the following fields
%
%                           significanceLevel: 0.00999999977648258
%                           maxBlackPolyOrder: 10
%                              eeFluxFraction: 0.949999988079071
%                          maxFzeroIterations: 500
%                 encircledEnergyPolyOrderMax: 20
%                        sigmaGaussianRollOff: 1
%          immediateNeighborhoodRadiusInPixel: 100
%         madSigmaThresholdForBleedingColumns: 10
%                                 horizonTime: 7
%                      minTrendFitSampleCount: 4
%                  exponentialSmoothingFactor: 0.2
%                       adaptiveBoundsXFactor: 3.5
%               cumRelativeFluxSigmaThreshold: 0.100000001490116
%                                trendFitTime: 4
%              backgroundLevelFixedLowerBound: 50000
%              backgroundLevelFixedUpperBound: 1000000
%                   blackLevelFixedLowerBound: -10
%                   blackLevelFixedUpperBound: 10
%             centroidsMeanColFixedLowerBound: -1
%             centroidsMeanColFixedUpperBound: 1
%             centroidsMeanRowFixedLowerBound: -1
%             centroidsMeanRowFixedUpperBound: 1
%                  darkCurrentFixedLowerBound: -3
%                  darkCurrentFixedUpperBound: 3
%             deltaAttitudeDecFixedLowerBound: -0.8
%             deltaAttitudeDecFixedUpperBound: 0.8
%              deltaAttitudeRaFixedLowerBound: -0.8
%              deltaAttitudeRaFixedUpperBound: 0.8
%            deltaAttitudeRollFixedLowerBound: -6.4
%            deltaAttitudeRollFixedUpperBound: 6.4
%                 dynamicRangeFixedLowerBound: 200
%                 dynamicRangeFixedUpperBound: 20000
%              encircledEnergyFixedLowerBound: 0
%              encircledEnergyFixedUpperBound: 8
%                     meanFluxFixedLowerBound: 0.5
%                     meanFluxFixedUpperBound: 1.5
%                   plateScaleFixedLowerBound: 0.75
%                   plateScaleFixedUpperBound: 1.25
%                   smearLevelFixedLowerBound: 5000
%                   smearLevelFixedUpperBound: 100000
%                                   debugLevel: 0
%                           forceReprocessing: 0
%..........................................................................
%
%     pdqInputStruct.fcConstants contains the following fields
%                               nRowsImaging: 1024
%                                nColsImaging: 1100
%                               nLeadingBlack: 12
%                              nTrailingBlack: 20
%                               nVirtualSmear: 26
%                                nMaskedSmear: 20
%                                    CCD_ROWS: 1070
%                                 CCD_COLUMNS: 1132
%                         LEADING_BLACK_START: 0
%                           LEADING_BLACK_END: 11
%                        TRAILING_BLACK_START: 1112
%                          TRAILING_BLACK_END: 1131
%                          MASKED_SMEAR_START: 0
%                            MASKED_SMEAR_END: 19
%                         VIRTUAL_SMEAR_START: 1044
%                           VIRTUAL_SMEAR_END: 1069
%                 REQUANT_TABLE_INDEX_BIT_NUM: 16
%                 REQUANT_TABLE_VALUE_BIT_NUM: 23
%                             crossTalkFactor: 1.0000e-006
%                                 ccdReadTime: 0.5190
%                             ccdExposureTime: 3
%                                pixel2arcsec: 3.9800
%                                  rad2arcsec: 2.0626e+005
%                                  arcsec2rad: 4.8481e-006
%            HALF_OFFSET_MODULE_ANGLE_DEGREES: 1.4300
%                          NOMINAL_FIRST_ROLL: 110
%                      NOMINAL_CLOCKING_ANGLE: 13
%                                    nModules: 21
%                               nModulesSpots: 25
%                          OUTPUTS_PER_COLUMN: 10
%                             OUTPUTS_PER_ROW: 10
%                           nOutputsPerModule: 4
%                                 outputsList: [4x1 double]
%                              MODULE_OUTPUTS: 84
%                          centerModuleNumber: 13
%                         modulesListWithGaps: [25x1 double]
%                                 modulesList: [21x1 double]
%     TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND: 246000
%                               moduleToIndex: [25x1 double]
%                                          IV: -559038737
%                            module2IndexList: [26x1 double]
%                            MOD_OUT_TO_INDEX: [1x26 struct]
%                       MOD_OUT_IN_GRID_ORDER: [1x100 struct]
%                   crossTalkOutputReflection: [4x1 double]
%                          outputArrangements: [1x5 struct]
%                              outputMappings: [25x1 double]
%                          CENTIDAYS_PER_YEAR: 36525
%                                   J2000_MJD: 5.1545e+004
%                         UNINITIALIZED_VALUE: -1
%                                 TEST_COEFFS: [2x1 double]
%                  NOMINAL_FOV_CENTER_DEGREES: [3x1 double]
%                  NOMINAL_FOV_CENTER_RADIANS: [3x1 double]
%                           eclipticObliquity: 0.4091
%                                    zodiGrid: [1x5 struct]
%                                  regionFile: '.ffiPix.reg'
%                          apertureRegionFile: '.ffiApertures.reg'
%                            apertureHtmlFile: '.ffiApertures.html'
%                      signalProcessingChains: [5x1 double]
%..........................................................................
%
%     pdqInputStruct.inputPdqTsData
%                pdqModuleOutputTsData: [1x84 struct]
%                          cadenceTimes: [4x1 double]
%                    attitudeSolutionRa: [1x1 struct]
%                   attitudeSolutionDec: [1x1 struct]
%                  attitudeSolutionRoll: [1x1 struct]
%                       deltaAttitudeRa: [1x1 struct]
%                      deltaAttitudeDec: [1x1 struct]
%                     deltaAttitudeRoll: [1x1 struct]
%                     desiredAttitudeRa: [1x1 struct]
%                    desiredAttitudeDec: [1x1 struct]
%                   desiredAttitudeRoll: [1x1 struct]
%         maxAttitudeResidualInPixels: [1x1 struct]
%
%     pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData ia a struct array with fields:
%                     1x84 struct array with fields:
%                         ccdModule
%                         ccdOutput
%                         backgroundLevels
%                         blackLevels
%                         centroidsMeanCols
%                         centroidsMeanRows
%                         darkCurrents
%                         dynamicRanges
%                         encircledEnergies
%                         meanFluxes
%                         plateScales
%                         smearLevels
%     pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(1)
%                             ccdModule: 2
%                             ccdOutput: 1
%                      backgroundLevels: [1x1 struct]
%                           blackLevels: [1x1 struct]
%                     centroidsMeanCols: [1x1 struct]
%                     centroidsMeanRows: [1x1 struct]
%                          darkCurrents: [1x1 struct]
%                         dynamicRanges: [1x1 struct]
%                     encircledEnergies: [1x1 struct]
%                            meanFluxes: [1x1 struct]
%                           plateScales: [1x1 struct]
%                           smearLevels: [1x1 struct]
% for example,
%         pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(1).backgroundLevels
%                    values: [4x1 double]
%             gapIndicators: [4x1 logical]
%             uncertainties: [4x1 double]
%..........................................................................
%
%     pdqInputStruct.stellarPdqTargets is a struct array with fields:
%         ccdModule
%         ccdOutput
%         labels
%         referencePixels
%         keplerId
%         ra
%         dec
%         keplerMag
%         initialCentroidRowValue
%         initialCentroidColumnValue
%
%     pdqInputStruct.stellarPdqTargets(1)
%           ccdModule: 2                                  ccdModule: 2
%           ccdOutput: 1                                  ccdOutput: 1
%              labels: {'PDQ_STELLAR'}                       labels: {'PDQ_STELLAR'  'PDQ_DYNAMIC_RANGE'}
%     referencePixels: [1x79 struct]                referencePixels: [1x15 struct]
%            keplerId: 9813313                             keplerId: 100000080
%             raHours: 18.8124                              raHours: 0
%          decDegrees: 44.0624                           decDegrees: 0
%           keplerMag: 12.0090                            keplerMag: 0
%
%     pdqInputStruct.stellarPdqTargets(1).referencePixels is a struct array with fields:
%         row
%         column
%         isInOptimalAperture
%         timeSeries
%         gapIndicators
%
%     pdqInputStruct.stellarPdqTargets(1).referencePixels(1)
%                     row: 584
%                  column: 783
%     isInOptimalAperture: 0
%              timeSeries: [30x1 double]
%           gapIndicators: [30x1 logical]
%..........................................................................
%
%     pdqInputStruct.backgroundPdqTargets is a struct array with fields:
%         ccdModule
%         ccdOutput
%         labels
%         referencePixels
%
%     pdqInputStruct.backgroundPdqTargets(1)
%               ccdModule: 2
%               ccdOutput: 1
%                  labels: {'PDQ_BACKGROUND'}
%         referencePixels: [1x1 struct]
%
%     pdqInputStruct.backgroundPdqTargets(1).referencePixels
%                         row: 638
%                      column: 17
%         isInOptimalAperture: 0
%                  timeSeries: [4x1 double]
%               gapIndicators: [4x1 logical]
%..........................................................................
%
%     pdqInputStruct.collateralPdqTargets is a struct array with fields:
%         ccdModule
%         ccdOutput
%         labels
%         referencePixels
%
%     pdqInputStruct.collateralPdqTargets(1)......  pdqInputStruct.collateralPdqTargets(6)
%           ccdModule: 2                                      ccdModule: 2
%           ccdOutput: 1                                      ccdOutput: 1
%              labels: {'PDQ_BLACK_COLLATERAL'}                  labels: {'PDQ_SMEAR_COLLATERAL'}
%     referencePixels: [1x88 struct]                    referencePixels: [1x95 struct]
%
%
%
%     pdqInputStruct.collateralPdqTargets(1).referencePixels is a struct array with fields:
%         row
%         column
%         isInOptimalAperture
%         timeSeries
%         gapIndicators
%
%     pdqInputStruct.collateralPdqTargets(1).referencePixels(1)
%                         row: 1
%                      column: 17
%         isInOptimalAperture: 1
%                  timeSeries: [4x1 double]
%               gapIndicators: [4x1 logical]
%
% Comments: This constructor generates an error under the following scenarios:
%          (1) when invoked with no inputs
%          (2) when any of the essential fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the
%              appropriate bounds
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

% NB:  Per discussions, we are going to force the validation of time structures in the
% pdqModuleoutputTsData fields to use validate_time_series_structure, and to issue a
% warning rather than an error when values are out of bounds.  To this end, we hard-code
% the flag which selects warnings rather than errors.

warningInsteadOfErrorFlag = true ;

if nargin == 0
    % generate error and return
    error('PDQ:pdqInputsClass:EmptyInputStruct',...
        'The constructor must be called with an input structure.')
end
% now validate inputs:
%---------------------------------------------
% (1) check for the presence of all the fields
% (2) check whether the parameters are within bounds and are not NaNs/Infs
%---------------------------------------------
%        pdqConfiguration: [1x1 struct]
%              fcConstants: [1x1 struct]
%               configMaps: [1x1 struct]
%             cadenceTimes: [4x1 double]
%                gainModel: [1x1 struct]
%           raDec2PixModel: [1x1 struct]
%          twoDBlackModels: [1x84 struct]
%          flatFieldModels: [1x84 struct]
%           readNoiseModel: [1x1 struct]
%            requantTables: [1x1 struct]
%           inputPdqTsData: [1x1 struct]
%        stellarPdqTargets: [1x425 struct]
%     backgroundPdqTargets: [1x84 struct]
%     collateralPdqTargets: [1x1260 struct]
%______________________________________________________________________
% check for the presence of all top level fields in pdqInputStruct
%______________________________________________________________________

% pdqInputStruct fields
fieldsAndBounds = cell(15,4);
fieldsAndBounds(1,:)  = { 'pdqConfiguration'; []; []; []};
fieldsAndBounds(2,:)  = { 'fcConstants'; []; []; []};
fieldsAndBounds(3,:)  = { 'configMaps'; []; []; []};
fieldsAndBounds(4,:)  = { 'pdqTimestampSeries'; []; []; []}; % replaces 'cadenceTimes' double array
fieldsAndBounds(5,:)  = { 'gainModel'; []; []; []};
fieldsAndBounds(6,:)  = { 'readNoiseModel'; []; []; []};
fieldsAndBounds(7,:)  = { 'raDec2PixModel'; []; []; []};
fieldsAndBounds(8,:)  = { 'prfModelFilenames'; []; []; []};
fieldsAndBounds(9,:)  = { 'twoDBlackModels'; []; []; []};
fieldsAndBounds(10,:)  = { 'flatFieldModels'; []; []; []};
fieldsAndBounds(11,:)  = { 'requantTables'; []; []; []};
fieldsAndBounds(12,:)  = { 'inputPdqTsData'; []; []; []};
fieldsAndBounds(13,:)  = { 'stellarPdqTargets'; []; []; []};
fieldsAndBounds(14,:)  = { 'backgroundPdqTargets'; []; []; []};
fieldsAndBounds(15,:)  = { 'collateralPdqTargets'; []; []; []};

validate_structure(pdqInputStruct, fieldsAndBounds,'pdqInputStruct');

%------------------------------------------------------------
% Check for the optional field preliminaryAttitudeSolutionStruct and
% validate it if it exists. This field was added for the K2 mission, which
% is expected to use large apertures (50x50) containing multiple bright
% stars. The usual seeding of PRF-based centroid fitting with flux-weighted
% centroids is not adequate under these conditions.
%------------------------------------------------------------
if isfield(pdqInputStruct, 'preliminaryAttitudeSolutionStruct')
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'mjd';         '> 54000'; '< 64000'; []};
    fieldsAndBounds(2,:)  = { 'raDegrees';   '>= -360'; '<= 360';  []};
    fieldsAndBounds(3,:)  = { 'decDegrees';  '>= -90';  '<= 90';   []};
    fieldsAndBounds(4,:)  = { 'rollDegrees'; '>= -360'; '<= 360';  []};
    validate_structure(pdqInputStruct.preliminaryAttitudeSolutionStruct, ...
        fieldsAndBounds, 'pdqInputStruct.preliminaryAttitudeSolutionStruct');
end

%------------------------------------------------------------
% check for the existence of prf files in the local drive since they should
% have been copied along with the inputs.bin file
%------------------------------------------------------------

nPrfFiles = length(pdqInputStruct.prfModelFilenames);

for jFiles = 1:nPrfFiles
    if(~isempty(pdqInputStruct.prfModelFilenames{jFiles}))
        if(~exist(pdqInputStruct.prfModelFilenames{jFiles}, 'file'))
            error('PDQ:validate_pdq_input_structure:prfFiles:doesNotExist', ...
                ['PDQ:validate_pdq_input_structure:prf file ' pdqInputStruct.prfModelFilenames{jFiles} ' does not exist\n']);
        end
    end
end

clear fieldsAndBounds;


%------------------------------------------------------------
% add check for ensuring that the following files are under spiceFileDir
% (1) spiceSpacecraftEphemerisFilename
% (2) planetaryEphemerisFilename
% (3) leapSecondFilename
%------------------------------------------------------------


spiceFileDir = pdqInputStruct.raDec2PixModel.spiceFileDir;
spiceSpacecraftEphemerisFilename = pdqInputStruct.raDec2PixModel.spiceSpacecraftEphemerisFilename;
planetaryEphemerisFilename = pdqInputStruct.raDec2PixModel.planetaryEphemerisFilename;
leapSecondFilename = pdqInputStruct.raDec2PixModel.leapSecondFilename;

if(exist([spiceFileDir '/' spiceSpacecraftEphemerisFilename], 'file') ~= 2)
    error('PDQ:validate_pdq_input_structure:FileDoesNotExist',...
        ['PDQ:validate_pdq_input_structure: spiceFileDir specified in raDec2PixModel does not contain ' spiceSpacecraftEphemerisFilename  ' ; can''t proceed; so quitting PDQ  ']);
end

if(exist([spiceFileDir '/' planetaryEphemerisFilename], 'file') ~= 2)

    error('PDQ:validate_pdq_input_structure:FileDoesNotExist',...
        ['PDQ:validate_pdq_input_structure: spiceFileDir specified in raDec2PixModel does not contain ' planetaryEphemerisFilename  ' ; can''t proceed; so quitting PDQ  ']);
end

if(exist([spiceFileDir '/' leapSecondFilename], 'file') ~= 2)

    error('PDQ:validate_pdq_input_structure:FileDoesNotExist',...
        ['PDQ:validate_pdq_input_structure: spiceFileDir specified in raDec2PixModel does not contain ' leapSecondFilename  ' ; can''t proceed; so quitting PDQ  ']);
end


%______________________________________________________________________
% second level validation
% validate the structure field  pdqConfiguration in pdqInputStruct
%______________________________________________________________________

% pdqInputStruct.pdqConfiguration fields
fieldsAndBounds = cell(47,4);
fieldsAndBounds(1,:)  = { 'haloAroundOptimalApertureInPixels'; []; []; '[0:4]'''};
fieldsAndBounds(2,:)  = { 'maxBlackPolyOrder'; '>= 0'; '< 25'; []};
fieldsAndBounds(3,:)  = { 'eeFluxFraction'; '> 0.7'; '< 1'; []};
fieldsAndBounds(4,:)  = { 'maxFzeroIterations'; '>= 10'; '< 1000'; []};

fieldsAndBounds(5,:)  = { 'encircledEnergyPolyOrderMax'; '>= 0'; '< 25'; []};

fieldsAndBounds(6,:)  = { 'sigmaGaussianRollOff'; '>= 0'; '< 25'; []};
fieldsAndBounds(7,:)  = { 'immediateNeighborhoodRadiusInPixel';  '>= 10'; '< 1000'; []};
fieldsAndBounds(8,:)  = { 'madSigmaThresholdForBleedingColumns'; '> 0'; '<= 25'; []};

fieldsAndBounds(9,:)  = { 'horizonTime'; []; []; []};  % add meaningful checks after talking with Joe
fieldsAndBounds(10,:)  = { 'minTrendFitSampleCount'; []; []; []};
fieldsAndBounds(11,:)  = { 'exponentialSmoothingFactor'; []; []; []};
fieldsAndBounds(12,:)  = { 'adaptiveBoundsXFactor'; []; []; []};


fieldsAndBounds(13,:)  = { 'trendFitTime'; []; []; []};
fieldsAndBounds(14,:)  = { 'backgroundLevelFixedLowerBound'; []; []; []};
fieldsAndBounds(15,:)  = { 'backgroundLevelFixedUpperBound'; []; []; []};
fieldsAndBounds(16,:)  = { 'blackLevelFixedLowerBound'; []; []; []};
fieldsAndBounds(17,:)  = { 'blackLevelFixedUpperBound'; []; []; []};
fieldsAndBounds(18,:)  = { 'centroidsMeanColFixedLowerBound'; []; []; []};
fieldsAndBounds(19,:)  = { 'centroidsMeanColFixedUpperBound'; []; []; []};
fieldsAndBounds(20,:)  = { 'centroidsMeanRowFixedLowerBound'; []; []; []};
fieldsAndBounds(21,:)  = { 'centroidsMeanRowFixedUpperBound'; []; []; []};
fieldsAndBounds(22,:)  = { 'darkCurrentFixedLowerBound'; []; []; []};
fieldsAndBounds(23,:)  = { 'darkCurrentFixedUpperBound'; []; []; []};
fieldsAndBounds(24,:)  = { 'deltaAttitudeDecFixedLowerBound'; []; []; []};
fieldsAndBounds(25,:)  = { 'deltaAttitudeDecFixedUpperBound'; []; []; []};
fieldsAndBounds(26,:)  = { 'deltaAttitudeRaFixedLowerBound'; []; []; []};
fieldsAndBounds(27,:)  = { 'deltaAttitudeRaFixedUpperBound'; []; []; []};
fieldsAndBounds(28,:)  = { 'deltaAttitudeRollFixedLowerBound'; []; []; []};
fieldsAndBounds(29,:)  = { 'deltaAttitudeRollFixedUpperBound'; []; []; []};
fieldsAndBounds(30,:)  = { 'dynamicRangeFixedLowerBound'; []; []; []};
fieldsAndBounds(31,:)  = { 'dynamicRangeFixedUpperBound'; []; []; []};
fieldsAndBounds(32,:)  = { 'encircledEnergyFixedLowerBound'; []; []; []};
fieldsAndBounds(33,:)  = { 'encircledEnergyFixedUpperBound'; []; []; []};
fieldsAndBounds(34,:)  = { 'meanFluxFixedLowerBound'; []; []; []};
fieldsAndBounds(35,:)  = { 'meanFluxFixedUpperBound'; []; []; []};
fieldsAndBounds(36,:)  = { 'plateScaleFixedLowerBound'; []; []; []};
fieldsAndBounds(37,:)  = { 'plateScaleFixedUpperBound'; []; []; []};
fieldsAndBounds(38,:)  = { 'smearLevelFixedLowerBound'; []; []; []};
fieldsAndBounds(39,:)  = { 'smearLevelFixedUpperBound'; []; []; []};

fieldsAndBounds(40,:)  = { 'debugLevel'; '>= 0'; '<= 3 '; []};
fieldsAndBounds(41,:)  = { 'forceReprocessing'; []; []; []};
fieldsAndBounds(42,:)  = { 'reportEnabled'; []; []; [true, false]};

fieldsAndBounds(43,:)  = { 'maxAttitudeResidualInPixelsFixedUpperBound'; ' >= 0'; ' <= 1'; []};
fieldsAndBounds(44,:)  = { 'maxAttitudeResidualInPixelsFixedLowerBound'; ' >= 0'; ' <= 1'; []};

fieldsAndBounds(45,:)  = { 'sigmaForRejectingBadTargets'; ' > 1'; ' <= 5'; []};
fieldsAndBounds(46,:)  = { 'madThresholdForCentroidOutliers'; ' >= 3'; ' <= 100'; []};
fieldsAndBounds(47,:)  = { 'excludeCadences'; []; []; []}; % can be empty, only for the reports



validate_structure(pdqInputStruct.pdqConfiguration, fieldsAndBounds,'pdqInputStruct.pdqConfiguration');

clear fieldsAndBounds;


%______________________________________________________________________
% second level validation
% validate the structure field  pdqTimestampSeries
%______________________________________________________________________
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'startTimes'; '> 54000'; '< 64000'; []};% use mjd
fieldsAndBounds(2,:)  = { 'refPixelFileNames'; []; []; []};
fieldsAndBounds(3,:)  = { 'processed'; []; []; []}; % boolean but can be empty, refers to cadences in the metric history
fieldsAndBounds(4,:)  = { 'excluded'; []; []; []}; % boolean but can be empty

validate_structure(pdqInputStruct.pdqTimestampSeries, fieldsAndBounds,'pdqInputStruct.pdqTimestampSeries');

clear fieldsAndBounds;


% once the validation is done, extract the cadence time stamps into
% 'cadenceTimes' field which is no longer an input

if(isempty(pdqInputStruct.pdqTimestampSeries.excluded))
    
    oldOrExcludedTimeStamps = pdqInputStruct.pdqTimestampSeries.processed;
    
elseif(isempty(pdqInputStruct.pdqTimestampSeries.processed))
    
    oldOrExcludedTimeStamps = pdqInputStruct.pdqTimestampSeries.excluded ;
else
    
    oldOrExcludedTimeStamps = pdqInputStruct.pdqTimestampSeries.processed | pdqInputStruct.pdqTimestampSeries.excluded ;
end

cadenceTimes = pdqInputStruct.pdqTimestampSeries.startTimes(~oldOrExcludedTimeStamps);

if(isempty(cadenceTimes))
    error('PDQ:validate_pdq_input_structure:noNewTimeStamps',...
        'PDQ:validate_pdq_input_structure: no new timestamps to process; can''t proceed, so quitting PDQ  ');
else
    pdqInputStruct.cadenceTimes = cadenceTimes;
end


%______________________________________________________________________
% second level validation
% validate the structure field  fcConstants in pdqInputStruct
%______________________________________________________________________


% read from FcConstants, change the hard coded constants, okay to leave
% the hard coded constants

% pdqInputStruct.fcConstants fields
fieldsAndBounds = cell(19,4);
fieldsAndBounds(1,:)  = { 'nRowsImaging'; '== 1024'; []; []};
fieldsAndBounds(2,:)  = { 'nColsImaging'; '== 1100'; []; []};
fieldsAndBounds(3,:)  = { 'nLeadingBlack'; '==12'; []; []};
fieldsAndBounds(4,:)  = { 'nTrailingBlack'; '==20'; []; []};
fieldsAndBounds(5,:)  = { 'nVirtualSmear'; '==26'; []; []};
fieldsAndBounds(6,:)  = { 'nMaskedSmear'; '== 20'; []; []};
fieldsAndBounds(7,:)  = { 'CCD_ROWS'; '== 1070'; []; []};
fieldsAndBounds(8,:)  = { 'CCD_COLUMNS'; '== 1132'; []; []};




fieldsAndBounds(9,:)  = { 'REQUANT_TABLE_LENGTH'; '==65536'; []; []};
fieldsAndBounds(10,:)  = { 'REQUANT_TABLE_MIN_VALUE'; '==0'; []; []};
fieldsAndBounds(11,:)  = { 'REQUANT_TABLE_MAX_VALUE'; '==8388607'; []; []};
fieldsAndBounds(12,:)  = { 'MEAN_BLACK_TABLE_LENGTH'; '==84'; []; []};
fieldsAndBounds(13,:)  = { 'MEAN_BLACK_TABLE_MIN_VALUE'; '==0'; []; []};
fieldsAndBounds(14,:)  = { 'MEAN_BLACK_TABLE_MAX_VALUE'; '==16383'; []; []};

fieldsAndBounds(15,:)  = { 'TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND'; '>= 2.1e5'; '<= 2.5e5'; []};


fieldsAndBounds(16,:)  = { 'NOMINAL_FOV_CENTER_DEGREES';  '>= 0'; '<= 360'; []};


% signal processing chains is a 2D array 21 long
validString = '[ 10, 1;   15, 1;   20, 1;   4, 2;   9, 2;   14, 2;   19, 2;   24, 2;   3, 3;   8, 3;   13, 3;  18, 3;   23, 3;   2, 4;   7, 4;   12, 4;   17, 4;   22, 4;   6, 5;   11, 5;   16, 5; ]';
fieldsAndBounds(17,:) = { 'signalProcessingChains'; []; []; validString};
fieldsAndBounds(18,:)  = { 'signalProcessingChainMapKeys'; []; []; []};
fieldsAndBounds(19,:)  = { 'signalProcessingChainMapValues'; []; []; []};

validate_structure(pdqInputStruct.fcConstants, fieldsAndBounds, 'pdqInputStruct.fcConstants');

% also check for the size of black2DModel as it has to be [1070x1132 double]

clear fieldsAndBounds;


%------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'externalId'; []; []; []};
fieldsAndBounds(2,:)  = { 'startMjd'; '> 54000'; '< 64000'; []};% use mjd
fieldsAndBounds(3,:)  = { 'requantEntries'; '>=0'; '<=2^23-1'; []}; % max value of requantization table = 2^23 - 1
fieldsAndBounds(4,:)  = { 'meanBlackEntries'; '>=0'; '<=2^24-1'; []}; % max value of mean black per read = 2^14 -1, 14 =  number of bits in the ADC

validate_structure(pdqInputStruct.requantTables, fieldsAndBounds,'pdqInputStruct.requantTables');

clear fieldsAndBounds;
%------------------------------------------------------------
%______________________________________________________________________
% second level validation
% validate the structure field  inputPdqTsData in pdqInputStruct
%______________________________________________________________________
fieldsAndBounds = cell(12,4);

%     Declination, like latitude, is measured as 0 degrees at the equator,
%     +90 degrees at the North Pole, and -90 degrees at the South Pole.


% (http://www.mathworks.com/support/solutions/data/1-19T9M.html?solution=1-% 19T9M)
% The Julian day number, JD, and MATLAB's datenum, T, are measuring the
% same thing -- number of days (and fractions of days) since some arbitrary
% ancient origin. One is simply an offset of the other. The Julian day
% number starts at noon, while the MATLAB datenum starts at midnight, so
% the offset involves half a day.
%
% Here is the formula, applied to the time when you want to write this:
%
% JD = T + 1721058.5
% MJD = T + 1721058.5- 2400000.5;
%


% pdqInputStruct.inputPdqTsData  fields
if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData))

    fieldsAndBounds(1,:)  = { 'pdqModuleOutputTsData'; []; []; []};

    if (isfield(pdqInputStruct.inputPdqTsData, 'cadenceTimes'))

        if(~isempty(pdqInputStruct.inputPdqTsData.cadenceTimes) )
            fieldsAndBounds(2,:)  = { 'cadenceTimes'; '> 54000'; '< 64000'; []};% use mjd
        else
            fieldsAndBounds(2,:)  = { 'cadenceTimes'; []; []; []};% use mjd
        end
    else % validate_structure will catch this error anyway, no need for special error message here
        fieldsAndBounds(2,:)  = { 'cadenceTimes'; []; []; []};% use mjd
    end


    fieldsAndBounds(3,:)  = { 'attitudeSolutionRa'; []; []; []}; % a structure
    fieldsAndBounds(4,:)  = { 'attitudeSolutionDec'; []; []; []};% a structure
    fieldsAndBounds(5,:)  = { 'attitudeSolutionRoll'; []; []; []};% a structure
    fieldsAndBounds(6,:)  = { 'desiredAttitudeRa'; []; []; []};% a structure
    fieldsAndBounds(7,:)  = { 'desiredAttitudeDec';  []; []; []};% a structure
    fieldsAndBounds(8,:)  = { 'desiredAttitudeRoll';[]; []; []};% a structure
    fieldsAndBounds(9,:)  = { 'deltaAttitudeRa'; []; []; []};% units of arc sec
    fieldsAndBounds(10,:) = { 'deltaAttitudeDec';  []; []; []};% units of arc sec
    fieldsAndBounds(11,:) = { 'deltaAttitudeRoll';[]; []; []};% units of arc sec
    fieldsAndBounds(12,:) = { 'maxAttitudeResidualInPixels'; []; []; []}; % units of pixels

    validate_structure(pdqInputStruct.inputPdqTsData, fieldsAndBounds, 'pdqInputStruct.inputPdqTsData');

    clear fieldsAndBounds;

    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= 285'; '<= 295'; []};  % stricter range since the telescope is never going to be far off from ..
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties'; '>= 0'; '<= 1e-2'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.attitudeSolutionRa, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.attitudeSolutionRa');

    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.attitudeSolutionRa.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.attitudeSolutionRa.gapIndicators;
        pdqInputStruct.inputPdqTsData.attitudeSolutionRa.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.attitudeSolutionRa.uncertainties(gapIndicators) = -1;

    end



    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values';  '>= 40'; '<= 50'; []}; % broad ranges still
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties'; '>= 0'; '<= 1e-2'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.attitudeSolutionDec, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.attitudeSolutionDec');


    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.attitudeSolutionDec.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.attitudeSolutionDec.gapIndicators;
        pdqInputStruct.inputPdqTsData.attitudeSolutionDec.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.attitudeSolutionDec.uncertainties(gapIndicators) = -1;

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -5'; '<= 5'; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e-2'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.attitudeSolutionRoll, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.attitudeSolutionRoll');

    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.attitudeSolutionRoll.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.attitudeSolutionRoll.gapIndicators;
        pdqInputStruct.inputPdqTsData.attitudeSolutionRoll.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.attitudeSolutionRoll.uncertainties(gapIndicators) = -1;

    end


    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= 285'; '<= 295'; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e-2'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.desiredAttitudeRa, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.desiredAttitudeRa');

    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.desiredAttitudeRa.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.desiredAttitudeRa.gapIndicators;
        pdqInputStruct.inputPdqTsData.desiredAttitudeRa.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.desiredAttitudeRa.uncertainties(gapIndicators) = -1;

    end


    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= 40'; '<= 50'; []}; % broad ranges still
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e-2'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.desiredAttitudeDec, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.desiredAttitudeDec');

    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.desiredAttitudeDec.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.desiredAttitudeDec.gapIndicators;
        pdqInputStruct.inputPdqTsData.desiredAttitudeDec.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.desiredAttitudeDec.uncertainties(gapIndicators) = -1;

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -5'; '<= 5'; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e-2'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.desiredAttitudeRoll, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.desiredAttitudeRoll');

    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.desiredAttitudeRoll.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.desiredAttitudeRoll.gapIndicators;
        pdqInputStruct.inputPdqTsData.desiredAttitudeRoll.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.desiredAttitudeRoll.uncertainties(gapIndicators) = -1;

    end


    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -3600'; '<= 3600'; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 36'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.deltaAttitudeRa, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.deltaAttitudeRa');

    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.deltaAttitudeRa.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.deltaAttitudeRa.gapIndicators;
        pdqInputStruct.inputPdqTsData.deltaAttitudeRa.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.deltaAttitudeRa.uncertainties(gapIndicators) = -1;

    end


    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -3600'; '<= 3600'; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 36'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.deltaAttitudeDec, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.deltaAttitudeDec');

    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.deltaAttitudeDec.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.deltaAttitudeDec.gapIndicators;
        pdqInputStruct.inputPdqTsData.deltaAttitudeDec.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.deltaAttitudeDec.uncertainties(gapIndicators) = -1;

    end


    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -3600'; '<= 3600'; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 36'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.deltaAttitudeRoll, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.deltaAttitudeRoll');

    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.deltaAttitudeRoll.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.deltaAttitudeRoll.gapIndicators;
        pdqInputStruct.inputPdqTsData.deltaAttitudeRoll.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.deltaAttitudeRoll.uncertainties(gapIndicators) = -1;

    end


    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>=0'; '< 20'; []}; % units of pixels, tighten the bounds later on
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 20'; []};

    validate_structure(pdqInputStruct.inputPdqTsData.maxAttitudeResidualInPixels, fieldsAndBounds,'pdqInputStruct.inputPdqTsData.maxAttitudeResidualInPixels');

    % set the unavailable metrics to -1
    if(~isempty(pdqInputStruct.inputPdqTsData.maxAttitudeResidualInPixels.values))

        gapIndicators = pdqInputStruct.inputPdqTsData.maxAttitudeResidualInPixels.gapIndicators;
        pdqInputStruct.inputPdqTsData.maxAttitudeResidualInPixels.values(gapIndicators) = -1;
        pdqInputStruct.inputPdqTsData.maxAttitudeResidualInPixels.uncertainties(gapIndicators) = -1;

    end


    clear fieldsAndBounds;
    %------------------------------------------------------------
    %______________________________________________________________________
    % third level validation
    % validate the structure field  moduleOutputTsData in pdqInputStruct.inputPdqTsData
    %______________________________________________________________________


    % this will change considerably as each metric now is a structure with
    % fields values, gapIndicators, uncertainties

    nIncomingCadences = length(pdqInputStruct.inputPdqTsData.cadenceTimes);


    fieldsAndBounds = cell(12,4);

    fieldsAndBounds(1,:)   = { 'ccdModule';  []; []; '[2:4, 6:20, 22:24]'''; };
    fieldsAndBounds(2,:)   = { 'ccdOutput';  []; []; '[1 2 3 4]'''};
    fieldsAndBounds(3,:)  = { 'backgroundLevels'; []; []; []}; % a structure
    fieldsAndBounds(4,:)  = { 'blackLevels';[]; []; []}; % a structure
    fieldsAndBounds(5,:)  = { 'centroidsMeanCols'; []; []; []}; % a structure
    fieldsAndBounds(6,:)  = { 'centroidsMeanRows'; []; []; []}; % a structure
    fieldsAndBounds(7,:)  = { 'darkCurrents'; []; []; []}; % a structure
    fieldsAndBounds(8,:)  = { 'dynamicRanges'; []; []; []}; % a structure
    fieldsAndBounds(9,:)  = { 'encircledEnergies'; []; []; []}; % a structure
    fieldsAndBounds(10,:)  = { 'meanFluxes'; []; []; []}; % a structure
    fieldsAndBounds(11,:)  = { 'plateScales'; []; []; []}; % a structure
    fieldsAndBounds(12,:)  = { 'smearLevels'; []; []; []}; % a structure

    nStructures = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData);

    for j = 1:nStructures
        validate_structure(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j), fieldsAndBounds,'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData');
    end

    clear fieldsAndBounds;

    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values';  '> -1e5'; '< 1e9'; []}; % may be -ve too ...
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1e5'; []};

    for j = 1:nStructures
        validate_time_series_structure(...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).backgroundLevels, ...
            fieldsAndBounds,...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.backgroundLevels', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).backgroundLevels.values);

        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;

        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingBackgroundMetricTimeSeries', ...
                ['Incoming background metric time series must contain  [' num2str(nIncomingCadences') '] cadences on  {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end

        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).backgroundLevels.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).backgroundLevels.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).backgroundLevels.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).backgroundLevels.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values';  '> -1e4'; '< 1e9'; []}; %-1 if unavailable, may be -ve depending on the black2D model
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1e5'; []};

    for j = 1:nStructures
        validate_time_series_structure(...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).blackLevels, ...
            fieldsAndBounds, ...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.blackLevels', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).blackLevels.values);

        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;


        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingBlackLevelsMetricTimeSeries', ...
                ['Incoming black level metric time series must contain  [' num2str(nIncomingCadences') '] cadences on {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end

        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).blackLevels.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).blackLevels.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).blackLevels.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).blackLevels.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>=-25'; '<= 25 '; []}; % units of pixels
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1'; []};

    for j = 1:nStructures
        validate_time_series_structure(...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanCols, ...
            fieldsAndBounds, ...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.centroidsMeanCols', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanCols.values);

        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;

        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingCentroidsMeanColsMetricTimeSeries', ...
                ['Incoming centroidsMeanCols metric time series must contain  [' num2str(nIncomingCadences') '] cadences on {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end

        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanCols.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanCols.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanCols.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanCols.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>=- 25'; '<= 25 '; []}; % units of pixels, very broad range
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1'; []};

    for j = 1:nStructures
        validate_time_series_structure(...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanRows, ...
            fieldsAndBounds, ...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.centroidsMeanRows', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanRows.values);

        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;


        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingCentroidsMeanRowsMetricTimeSeries', ...
                ['Incoming centroidsMeanRows metric time series must contain  [' num2str(nIncomingCadences') '] cadences on {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end

        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanRows.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanRows.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanRows.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).centroidsMeanRows.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values';  '>-1e4'; '<= 1e9'; []}; %-1 if unavailable
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1e5'; []};

    for j = 1:nStructures
        validate_time_series_structure( ...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).darkCurrents, ...
            fieldsAndBounds, ...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.darkCurrents', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).darkCurrents.values);

        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;


        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingDarkCurrentsMetricTimeSeries', ...
                ['Incoming darkCurrents metric time series must contain  [' num2str(nIncomingCadences') '] cadences on {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end

        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).darkCurrents.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).darkCurrents.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).darkCurrents.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).darkCurrents.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -1'; '<= 1e13'; []}; %result in ADUs (use max value ADU for upper bound), -1 if unavailable
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  []; []; []}; % no uncertainties for dynamic ranges

    for j = 1:nStructures
        validate_time_series_structure( ...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).dynamicRanges, ...
            fieldsAndBounds, ...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.dynamicRanges', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).dynamicRanges.values);

        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;


        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingDynamicRangesMetricTimeSeries', ...
                ['Incoming dynamicRanges metric time series must contain  [' num2str(nIncomingCadences') '] cadences on {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end

        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).dynamicRanges.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).dynamicRanges.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).dynamicRanges.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).dynamicRanges.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -1'; '< 20'; []}; % units of pixels, -1 if unavailable
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 20'; []}; % fix for ORT1 error message thrown

    for j = 1:nStructures
        validate_time_series_structure( ...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).encircledEnergies, ...
            fieldsAndBounds, ...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.encircledEnergies', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).encircledEnergies.values);

        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;


        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingEncircledEnergiesMetricTimeSeries', ...
                ['Incoming encircled energies metric time series must contain  [' num2str(nIncomingCadences') '] cadences on {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end

        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).encircledEnergies.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).encircledEnergies.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).encircledEnergies.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).encircledEnergies.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -1'; '<= 2'; []}; % normalized flux, -1 if unavailable
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 0.5'; []};

    for j = 1:nStructures
        validate_structure(...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).meanFluxes, ...
            fieldsAndBounds, ...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.meanFluxes', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).meanFluxes.values);

        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;


        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingMeanFluxesMetricTimeSeries', ...
                ['Incoming meanFluxes metric time series: must contain  [' num2str(nIncomingCadences') '] cadences on {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end
        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).meanFluxes.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).meanFluxes.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).meanFluxes.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).meanFluxes.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -1 '; '<= 10'; []}; % close to 4, -1 if unavailable
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1e-1'; []};

    for j = 1:nStructures
        validate_time_series_structure(...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).plateScales, ...
            fieldsAndBounds, ...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.plateScales', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).plateScales.values);


        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;

        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingPlateScalesMetricTimeSeries', ...
                ['Incoming plateScales metric time series must contain  [' num2str(nIncomingCadences') '] cadences on {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end
        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).plateScales.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).plateScales.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).plateScales.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).plateScales.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; '>= -1e4 '; '< 1e9'; []}; % -1 if unavailable
    fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1e5'; []};

    for j = 1:nStructures
        validate_time_series_structure( ...
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).smearLevels, ...
            fieldsAndBounds, ...
            'pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData.smearLevels', ...
            warningInsteadOfErrorFlag);

        nActualIncomingCadences = length(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).smearLevels.values);

        ccdModule = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdModule;
        ccdOutput = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).ccdOutput;


        if(nActualIncomingCadences ~= nIncomingCadences)
            error('PDQ:validateInputStructure:IncomingSmearLevelsMetricTimeSeries', ...
                ['Incoming smearLevels metric time series must contain  [' num2str(nIncomingCadences') '] cadences on {' ...
                num2str(ccdModule) ' , ' num2str(ccdOutput) '} but contains only [' num2str(nActualIncomingCadences) ']' ]);
        end
        % set the unavailable metrics to -1
        if(~isempty(pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).smearLevels.values))

            gapIndicators = pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).smearLevels.gapIndicators;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).smearLevels.values(gapIndicators) = -1;
            pdqInputStruct.inputPdqTsData.pdqModuleOutputTsData(j).smearLevels.uncertainties(gapIndicators) = -1;

        end

    end

    clear fieldsAndBounds;
    %------------------------------------------------------------

end

%______________________________________________________________________
% second level validation
% validate the structure field  stellarPdqTargets in pdqInputStruct
%______________________________________________________________________
fieldsAndBounds = cell(9,4);

% pdqInputStruct.stellarPdqTargets fields
fieldsAndBounds(1,:)  = { 'ccdModule';  []; []; '[2:4, 6:20, 22:24]'''; };
fieldsAndBounds(2,:)  = { 'ccdOutput';  []; []; '[1 2 3 4]'''};
fieldsAndBounds(3,:)  = { 'labels'; []; []; {'PDQ_STELLAR' ; 'PDQ_DYNAMIC_RANGE'}};  %
fieldsAndBounds(4,:)  = { 'referencePixels'; []; []; []};
fieldsAndBounds(5,:)  = { 'keplerId'; '> 0'; '< 1e9'; []};    % use stricter bounds
fieldsAndBounds(6,:)  = { 'raHours'; '>= 0'; '<= 24'; []};
fieldsAndBounds(7,:)  = { 'decDegrees'; '>= -90'; '<= 90'; []};
fieldsAndBounds(8,:)  = { 'keplerMag'; '> 4'; '< 20'; []};
fieldsAndBounds(9,:)  = {'fluxFractionInAperture';  '> 0'; '<= 1'; []};%


fieldsAndBoundsDynamicRange = cell(9,4);

% pdqInputStruct.stellarPdqTargets fields
fieldsAndBoundsDynamicRange(1,:)  = { 'ccdModule';  []; []; '[2:4, 6:20, 22:24]'''; };
fieldsAndBoundsDynamicRange(2,:)  = { 'ccdOutput';  []; []; '[1 2 3 4]'''};
fieldsAndBoundsDynamicRange(3,:)  = { 'labels'; []; []; {'PDQ_STELLAR' ; 'PDQ_DYNAMIC_RANGE'}};  %
fieldsAndBoundsDynamicRange(4,:)  = { 'referencePixels'; []; []; []}; % don't care
fieldsAndBoundsDynamicRange(5,:)  = { 'keplerId';  []; []; []};% don't care
fieldsAndBoundsDynamicRange(6,:)  = { 'raHours'; []; []; []};% don't care
fieldsAndBoundsDynamicRange(7,:)  = { 'decDegrees'; []; []; []};% don't care
fieldsAndBoundsDynamicRange(8,:)  = { 'keplerMag'; []; []; []};% don't care
fieldsAndBoundsDynamicRange(9,:)  = {'fluxFractionInAperture'; []; []; []};% don't care


nStructures = length(pdqInputStruct.stellarPdqTargets);

for j = 1:nStructures

    isDynamicRangeTarget    = strcmp(pdqInputStruct.stellarPdqTargets(j).labels, 'PDQ_DYNAMIC_RANGE');
    if(any(isDynamicRangeTarget))
        validate_structure(pdqInputStruct.stellarPdqTargets(j), fieldsAndBoundsDynamicRange,'pdqInputStruct.stellarPdqTargets');
    else
        validate_structure(pdqInputStruct.stellarPdqTargets(j), fieldsAndBounds,'pdqInputStruct.stellarPdqTargets');
    end
end

clear fieldsAndBounds fieldsAndBoundsDynamicRange;
%______________________________________________________________________
% third level validation
% validate the structure field  referencePixels in pdqInputStruct.stellarPdqTargets
%______________________________________________________________________
fieldsAndBounds = cell(5,4);
% pdqInputStruct.stellarPdqTargets.referencePixels fields
fieldsAndBounds(1,:)  = { 'row';'>= 0';'<= 1070'; []};
fieldsAndBounds(2,:)  = { 'column';'>= 0';'<= 1132'; []};
fieldsAndBounds(3,:)  = { 'isInOptimalAperture'; []; []; [true, false]}; % boolean
fieldsAndBounds(4,:)  = { 'timeSeries';'>=  -1';'< 1e10'; []};    % adu range, test data contains 0 values even though it is not valid, check later
fieldsAndBounds(5,:)  = { 'gapIndicators'; []; []; [true, false]}; % boolean


warningInsteadOfErrorFlag = true;
kStructs = length(pdqInputStruct.stellarPdqTargets);
for i = 1:kStructs
    nStructures = length(pdqInputStruct.stellarPdqTargets(i).referencePixels);

    fieldsAndBounds0 = { 'stellarPixelsInMask'; '> 0'; '<= 300'; []};  %


    validate_field(nStructures, fieldsAndBounds0, 'PDQ:validate_input_structure:tooManyPixelsInMask',  warningInsteadOfErrorFlag);

    for j = 1:nStructures

        validate_structure(pdqInputStruct.stellarPdqTargets(i).referencePixels(j), fieldsAndBounds,...
            ['pdqInputStruct.stellarPdqTargets(' num2str(i) ').referencePixels']);
    end

end

clear fieldsAndBounds fieldsAndBounds0;

%------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'ccdModule'; []; []; '[2:4, 6:20, 22:24]''';};
fieldsAndBounds(2,:)  = { 'ccdOutput'; []; []; '[1 2 3 4]'''};
fieldsAndBounds(3,:)  = { 'labels'; []; []; {'PDQ_BACKGROUND'}};  %
fieldsAndBounds(4,:)  = { 'referencePixels'; []; []; []};

nStructures = length(pdqInputStruct.backgroundPdqTargets);

for j = 1:nStructures
    validate_structure(pdqInputStruct.backgroundPdqTargets(j), fieldsAndBounds,'pdqInputStruct.backgroundPdqTargets');
end

clear fieldsAndBounds;

%------------------------------------------------------------

fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)  = { 'row';'>= 0';'<= 1070'; []};
fieldsAndBounds(2,:)  = { 'column';'>= 0';'<= 1132'; []};
fieldsAndBounds(3,:)  = { 'isInOptimalAperture'; []; []; []};
fieldsAndBounds(4,:)  = { 'timeSeries';'>=  -1';'< 1e10'; []};
fieldsAndBounds(5,:)  = { 'gapIndicators'; []; []; [true, false]};


kStructs = length(pdqInputStruct.backgroundPdqTargets);
for i = 1:kStructs
    nStructures = length(pdqInputStruct.backgroundPdqTargets(i).referencePixels);

    for j = 1:nStructures
        validate_structure(pdqInputStruct.backgroundPdqTargets(i).referencePixels(j), fieldsAndBounds,'pdqInputStruct.backgroundPdqTargets(i).referencePixels');
    end

end

clear fieldsAndBounds;

%------------------------------------------------------------
fieldsAndBounds = cell(4,4);

fieldsAndBounds(1,:)  = { 'ccdModule'; []; []; '[2:4, 6:20, 22:24]''';};
fieldsAndBounds(2,:)  = { 'ccdOutput'; []; []; '[1 2 3 4]'''};
fieldsAndBounds(3,:)  = { 'labels'; []; []; {'PDQ_BLACK_COLLATERAL','PDQ_SMEAR_COLLATERAL'}};
fieldsAndBounds(4,:)  = { 'referencePixels'; []; []; []};

nStructures = length(pdqInputStruct.collateralPdqTargets);

for j = 1:nStructures
    validate_structure(pdqInputStruct.collateralPdqTargets(j), fieldsAndBounds,'pdqInputStruct.collateralPdqTargets');
end

clear fieldsAndBounds;

%------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'row';'>= 0';'<= 1070'; []};
fieldsAndBounds(2,:)  = { 'column';'>= 0';'<= 1132'; []};
fieldsAndBounds(3,:)  = { 'isInOptimalAperture'; []; []; []};
fieldsAndBounds(4,:)  = { 'timeSeries';'>=  -1';'< 1e10'; []};
fieldsAndBounds(5,:)  = { 'gapIndicators'; []; []; [true, false]};

kStructs = length(pdqInputStruct.collateralPdqTargets);
for i = 1:kStructs
    nStructures = length(pdqInputStruct.collateralPdqTargets(i).referencePixels);

    for j = 1:nStructures
        validate_structure(pdqInputStruct.collateralPdqTargets(i).referencePixels(j), fieldsAndBounds,...
            ['pdqInputStruct.collateralPdqTargets(' num2str(i) ').referencePixels']);
    end

end

clear fieldsAndBounds;
%------------------------------------------------------------

return
