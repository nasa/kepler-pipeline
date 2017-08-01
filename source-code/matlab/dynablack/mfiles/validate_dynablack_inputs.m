function validate_dynablack_inputs(inputsStruct)
% function validate_dynablack_inputs(inputsStruct)
%
% This function first checks for the presence of expected fields in the input structure and then checks whether each parameter is within the
% appropriate range. Once the validation of the inputs is complete, the class constructor for the dynablackClass may be called to
% instantiate a DYANBLACK class object.
%
% Comments: This function generates an error under the following scenarios:
%          (1) when invoked with no inputs
%          (2) when any of the fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the specified bounds
% 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'dynablackInputsStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%   dynablackInputsStruct is a structure with the following fields:
%
%                            ccdModule: [int]               CCD module number
%                            ccdOutput: [int]               CCD output number
%            dynablackModuleParameters: [struct]            module parameters for dynablack
%           rbaFlagConfigurationStruct: [struct]            configuration parameters for the rba flagging routine (B2a)
%       ancillaryEngineeringDataStruct: [struct array]      engineering temperature data for detrending over cadences
%                              rawFfis: [struct array]      raw ffi data
%                         cadenceTimes: [struct]            cadence times and gap indicators for long cadence data
%                          blackPixels: [struct array]      raw black collateral for long cadence data
%                    maskedSmearPixels: [struct array]      raw masked smear collateral for long cadence data
%                   virtualSmearPixels: [struct array]      raw virtual smear collateral for long cadence data
%                     backgroundPixels: [struct array]  -------- NOT USED
%                      arpTargetPixels: [struct array]      raw artifact removal pixels for long cadence data
%           reverseClockedCadenceTimes: [struct]            cadence times and gap indicators for reverse clocked data
%            reverseClockedBlackPixels: [struct array]      raw black collateral for reverse clocked data
%      reverseClockedMaskedSmearPixels: [struct array]      raw masked smear collateral for reverse clocked data
%     reverseClockedVirtualSmearPixels: [struct array]      raw virtual smear collateral for reverse clocked data
%       reverseClockedBackgroundPixels: [struct array]      raw background pixels for reverse clocked data
%           reverseClockedTargetPixels: [struct array]      raw target pixels for reverse clocked data
%                       twoDBlackModel: [struct]            static 2D black model
%                      undershootModel: [struct]        -------- NOT USED
%                            gainModel: [struct]        -------- NOT USED
%                       flatFieldModel: [struct]        -------- NOT USED
%                       linearityModel: [struct]        -------- NOT USED
%                       readNoiseModel: [struct]        -------- NOT USED
%                  spacecraftConfigMap: [struct array]      one or more spacecraft config maps
%                        requantTables: [struct]            requantization table (dynablack needs only the mean black table from this)
%                        huffmanTables: [struct]        -------- NOT USED
%                          fcConstants: [struct]            fc constants
%                               season: [int]               indicates observing season [0,1,2,3] 
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   dynablackModuleParameters is a structure with the following fields:
%                                                           
%                 NOTE: ALL ROW AND COLUMN INDICES IN DYNABLACK MODULE PARAMETERS ARE ONE-BASED
%
%                 ancillaryEngineeringMnemonics: {cell array}       ancillary mnemonic names
%                          rawFfiFileTimestamps: {cell array}       ffi time stamps in string form
%                      pixelBrightnessThreshold: [double]           brightness threshold to determine scene dependence (ADU/lc)
%     minimumColumnForExcludingTrailingBlackRow: [int]              
%                         reverseClockedEnabled: [logical]          enable processing of reverse clocked data
%                         dynablackBlobFilename: [string]           output blob local filename
%                           cadenceGapThreshold: [int]              gapped cadence threshold triggering insertion of bias step in smoothing
%                                                                   model over cadences 
%                           includeStepsInModel: [logical]          enables bias steps in smoothing model
%                               maxA1CoeffCount: [int]              maximum allowed FGS coefficients in A1 (vertical) fit
%                               maxA2CoeffCount: [int]              maximum allowed FGS coefficients in A2 (horizontal) fit
%                               maxB1CoeffCount: [int]              maximum allowed coefficients in B1a/B1b smoothing models
%                                 numModelTypes: [int]              number of B1a/B1b smoothing models 
%                          numB1PredictorCoeffs: [int]              number of B1 predictors (nominally 2, temperature and time)
%                           parallelPixelSelect: [int array]        clock cycles for fgs parallel pixels to fit in A1
%                         a2ParallelPixelSelect: [int array]        clock cycles for fgs parallel pixels to fit in A2
%                              framePixelSelect: [int array]        clock cycles for fgs frame pixels to fit in A1
%                            a2FramePixelSelect: [int array]        clock cycles for fgs frame pixels to fit in A2
%                           leadingColumnSelect: [int array]        leading columns for A1 fit
%                         a2LeadingColumnSelect: [int array]        leading columns for A2 fit
%                              thermalRowOffset: [double]           LDE thermal settling time measured in rows
%                        defaultRowTimeConstant: [double]           starting point for vertical non-linear fit
%                              minUndershootRow: [int]              row range minimum for undershoot estimate
%                              maxUndershootRow: [int]              row range maximum for undershoot estimate
%                               undershootSpan0: [int]              length of initial undershoot feature in columns
%                                undershootSpan: [int]              length of final undershoot feature in columns
%                               scDPixThreshold: [double]           brightness threshold to determine scene dependence (ADU/lc)
%                                       blurPix: [int]              size of row buffer for scene dependence
%                                  nearTbMinpix: [double]           column threshold for scene dependence in black
%                            a1NumPredictorRows: [int]              number of coefficients in the A1 (vertical) model
%                   a1NumNonlinearPredictorRows: [int]              number of nonlinear coefficients in the A1 (vertical) model
%                         a1NumFfiPredictorRows: [int]              number of coefficients in the ffi (vertical) model
%                                    a2SkipDiff: [logical]          disable smear difference fit
%                        a2ColumnPredictorCount: [int]              number of coefficients in the A2 (horizontal) model
%                    a2LeadColumnPredictorCount: [int]              number of lead columns to include in the A2 fit
%                         a2SmearPredictorCount: [int]              number of coefficeints in the A2 smear model
%                                    a2SolRange: [int array]        list of start of line ringing columns
%                                    a2SolStart: [int]              start of line ringing statr column
%                                                                   The ROIs (Region Of Interest) below are retangular regions defined by
%                                                                   the four component vector [row_min row_max column_min column_max]:
%                                    leadingArp: [int array]        define leading arp region 
%                                   trailingArp: [int array]        define trainling arp region
%                                 trailingArpUs: [int array]        define trailing arp undershoot region
%                                trailingCollat: [int array]        define trailing black region
%                               neartrailingArp: [int array]        define near trailing arp region
%                                   trailingFfi: [int array]        define trailing black region for ffis
%                                      rclcTarg: [int array]        define reverse clocked target region
%                           trailingMaskedSmear: [int array]        define masked smear region in the trailing black
%                            leadingMaskedSmear: [int array]        define masked smear region in the leading black
%              blackResidualsThresholdDnPerRead: [double]           if more than numBlackPixelsAboveThreshold of the standard deviation over
%                                                                   cadences of the fit residuals are above this threshold the dynablack fit
%                                                                   is deemed to be unreliable and validDynablackFit will be set to false in
%                                                                   the output blob 
%                  numBlackPixelsAboveThreshold: [int]              (see blackResidualsThresholdDnPerRead)
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second Level
%
%   rbaFlagConfigurationStruct is a struct with the following fields:
% 
%       pixelNoiseThresholdAduPerRead: [double]         20 ppm noise level in adu/read/pixel for 12th mag. star
%        pixelBiasThresholdAduPerRead: [double]         20 ppm bias level in adu/read/pixel for 12th mag. star
%                       cleaningScale: [int]            smoothing filter length in long cadences
%                  testPulseDurations: [int]            duration in long cadences for square wave transit model to test for rba
%                numerOfFlagVariables: [int]            number of flag variables in suspect data flag
%                   severityQuantiles: [double array]   quantiles to report in severity parameter monitoring (nominally [0.977, 0.5])
%                  meanSigmaThreshold: [double]         bias threshold in sigma
%               robustWeightThreshold: [double]         robust weight threshold
%          transitDepthSigmaThreshold: [double]         transit depth threshold in sigma
% 
%-------------------------------------------------------------------------------------------------------------------------------------------------%   Second level
%
%   ancillaryEngineeringDataStruct is an array of structures with the following fields:
%
%         mnemonic: [string]            mnemonic name of engineering data 
%       timestamps: [double array]      timestamp (MJD)
%           values: [double array]      engineering data value (ADU)
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level 
%
%   rawFfis is an array of structures with the following fields:
% 
%             fileName: [string]        date and time ffi filename
%   	startTimestamp: [double]        start time (MJD)
%         midTimestamp: [double]        mid time (MJD)
%         endTimestamp: [double]        end tiem (MJD)
%                image: [struct array]  1 x nCcdRows array of structures each containing a [double array] of nCcdColumns x 1 ffi values
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   blackPixels and reverseClockedBlackPixels are arrays of structures with the following fields:
%
%               row: [int]              zero based row index
%            values: [double array]     nCadence x 1 array of raw values
%     gapIndicators: [logical array]    nCadence x 1 array of gap indicators
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   maskedSmearPixels, virtualSmearPixels, reverseClockedMaskedSmearPixels and reverseClockedVirtualSmearPixels are arrays of structures
%   with the following fields: 
%
%            column: [int]              zero based column index
%            values: [double array]     nCadence x 1 array of raw values
%     gapIndicators: [logical array]    nCadence x 1 array of gap indicators
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   backgroundPixels, arpTargetPixels, reverseClockedBackgroundPixels and reverseClockedTargetPixels are arrays of structures with the
%   following fields: 
%
%               row: [int]              zero based row index
%            column: [int]              zero based column index
%            values: [double array]     nCadence x 1 array of raw values
%     gapIndicators: [logical array]    nCadence x 1 array of gap indicators
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   cadenceTimes and reversClockedCadenceTimes are structs with the following fields:
%
%           startTimestamps: [double array]     cadence start times (MJD)
%             midTimestamps: [double array]     cadence mid times (MJD)
%             endTimestamps: [double array]     cadence end times (MJD)
%             gapIndicators: [logical array]    true if cadence is unavailable
%            requantEnabled: [logical array]    true if requantization was enabled
%            cadenceNumbers: [int array]        absolute cadence numbers
%                 isSefiAcc: [logical array]    single event functional interrupt in accumulation memory (isSefiAcc = T)
%                 isSefiCad: [logical array]    single event functional interrupt in cadence memory (isSefiCad = T)
%                  isLdeOos: [logical array]    local detector electronics out of synch reported (isLdeOos = T)
%                 isFinePnt: [logical array]    spacecraft is in fine point (isFinePnt = T)
%                isMmntmDmp: [logical array]    momentum dump occurred during accumulation (isMmntmDmp = T)
%                isLdeParEr: [logical array]    local detector electronics parity error occurred (isLdeParEr = T)
%                 isScrcErr: [logical array]    SDRAM controller memory pixel error occurred (isScrcErr = T)
%          dataAnomalyFlags: [struct]           data anomaly flags - 1 x nCadence logical vector for each anomaly type
% 
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Third Level
%
%   dataAnomalyFlags is a struct with the following fields:
%
%               attitudeTweakIndicators: [logical array]
%                    safeModeIndicators: [logical array]
%                 coarsePointIndicators: [logical array]
%             argabrighteningIndicators: [logical array]
%                     excludeIndicators: [logical array]
%                  earthPointIndicators: [logical array]
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

% return without validation if uow is invalid
if ~inputsStruct.validUow
    return;
end

% a message!
disp('Validating dynablack inputs...');
t0 = clock;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validate inputs and check fields and bounds.
%
% (1) check for the presence of all fields
% (2) check whether the parameters are within bounds and are not NaNs/Infs
%
% Note: if fields are structures, make sure that their bounds are empty.
    
%--------------------------------------------------------------------------
% Top level validation.
% Validate fields in inputsStruct
%--------------------------------------------------------------------------
fieldsAndBounds = cell(28,4);
fieldsAndBounds(1,:)  = { 'ccdModule';  []; []; '[2:4, 6:20, 22:24]'};
fieldsAndBounds(2,:)  = { 'ccdOutput';  []; []; '[1 2 3 4]'''};
fieldsAndBounds(3,:)  = { 'dynablackModuleParameters'; []; []; []};
fieldsAndBounds(4,:)  = { 'rbaFlagConfigurationStruct'; []; []; []};
fieldsAndBounds(5,:)  = { 'ancillaryEngineeringDataStruct'; []; []; []};
fieldsAndBounds(6,:)  = { 'rawFfis'; []; []; []};
fieldsAndBounds(7,:)  = { 'cadenceTimes'; []; []; []};
fieldsAndBounds(8,:)  = { 'blackPixels'; []; []; []};
fieldsAndBounds(9,:)  = { 'maskedSmearPixels'; []; []; []};
fieldsAndBounds(10,:) = { 'virtualSmearPixels'; []; []; []};
fieldsAndBounds(11,:) = { 'backgroundPixels'; []; []; []};
fieldsAndBounds(12,:) = { 'arpTargetPixels'; []; []; []};
fieldsAndBounds(13,:) = { 'reverseClockedCadenceTimes'; []; []; []};
fieldsAndBounds(14,:) = { 'reverseClockedBlackPixels'; []; []; []};
fieldsAndBounds(15,:) = { 'reverseClockedMaskedSmearPixels'; []; []; []};
fieldsAndBounds(16,:) = { 'reverseClockedVirtualSmearPixels'; []; []; []};
fieldsAndBounds(17,:) = { 'reverseClockedBackgroundPixels'; []; []; []};
fieldsAndBounds(18,:) = { 'reverseClockedTargetPixels'; []; []; []};
fieldsAndBounds(19,:) = { 'twoDBlackModel'; []; []; []};            % Do not validate
fieldsAndBounds(20,:) = { 'undershootModel'; []; []; []};           % Do not validate
fieldsAndBounds(21,:) = { 'gainModel'; []; []; []};                 % Do not validate
fieldsAndBounds(22,:) = { 'flatFieldModel'; []; []; []};            % Do not validate
fieldsAndBounds(23,:) = { 'linearityModel'; []; []; []};            % Do not validate
fieldsAndBounds(24,:) = { 'readNoiseModel'; []; []; []};            % Do not validate
fieldsAndBounds(25,:) = { 'spacecraftConfigMap'; []; []; []};       % Do not validate
fieldsAndBounds(26,:) = { 'requantTables'; []; []; []};             % Validate only needed fields
fieldsAndBounds(27,:) = { 'huffmanTables'; []; []; []};             % Do not validate
fieldsAndBounds(28,:) = { 'fcConstants'; []; []; []};               % Validate only needed fields
fieldsAndBounds(29,:) = { 'season'; []; []; '[0:3]'};

validate_structure(inputsStruct, fieldsAndBounds, 'inputsStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters
%--------------------------------------------------------------------------
fieldsAndBounds = cell(49,4);
fieldsAndBounds(1,:)  = { 'ancillaryEngineeringMnemonics'; []; []; {}};
fieldsAndBounds(2,:)  = { 'rawFfiFileTimestamps'; []; []; {}};
fieldsAndBounds(3,:)  = { 'pixelBrightnessThreshold'; '>= 0'; '< 1e7'; []};
fieldsAndBounds(4,:)  = { 'minimumColumnForExcludingTrailingBlackRow'; '>= 0'; '<= 1132'; []};
fieldsAndBounds(5,:)  = { 'reverseClockedEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'dynablackBlobFilename'; []; []; []};
fieldsAndBounds(7,:)  = { 'cadenceGapThreshold'; '> 0'; []; []};
fieldsAndBounds(8,:)  = { 'includeStepsInModel'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'maxA1CoeffCount'; '> 0'; '<= 566'; []};
fieldsAndBounds(10,:) = { 'maxA2CoeffCount'; '> 0'; '<= 566'; []};
fieldsAndBounds(11,:) = { 'maxB1CoeffCount'; '> 0'; '<= 10'; []};
fieldsAndBounds(12,:) = { 'numModelTypes'; '> 0'; '<= 4'; []};
fieldsAndBounds(13,:) = { 'numB1PredictorCoeffs'; '> 0'; '<= 2'; []};
fieldsAndBounds(14,:) = { 'parallelPixelSelect'; '>= 1'; '<= 566'; []};
fieldsAndBounds(15,:) = { 'a2ParallelPixelSelect'; '>= 1'; '<= 566'; []};
fieldsAndBounds(16,:) = { 'framePixelSelect'; '>= 1'; '<= 32'; []};
fieldsAndBounds(17,:) = { 'a2FramePixelSelect'; '>= 1'; '<= 32'; []};
fieldsAndBounds(18,:) = { 'leadingColumnSelect'; '>= 1'; '<= 1132'; []};
fieldsAndBounds(19,:) = { 'a2LeadingColumnSelect'; '>= 1'; '<= 1132'; []};
fieldsAndBounds(20,:) = { 'thermalRowOffset'; '>= 1'; '<= 1070'; []};
fieldsAndBounds(21,:) = { 'defaultRowTimeConstant'; '>= 1'; '<= 1070'; []};
fieldsAndBounds(22,:) = { 'minUndershootRow'; '>= 1'; '<= 1070'; []};
fieldsAndBounds(23,:) = { 'maxUndershootRow'; '>= 1'; '<= 1070'; []};
fieldsAndBounds(24,:) = { 'undershootSpan0'; '< 0'; [] ; []};
fieldsAndBounds(25,:) = { 'undershootSpan'; '< 0'; []; []};
fieldsAndBounds(26,:) = { 'scDPixThreshold'; '>= 0'; '<= 1e7'; []};
fieldsAndBounds(27,:) = { 'blurPix'; '>= 0'; '<= 100'; []};
fieldsAndBounds(28,:) = { 'nearTbMinpix'; '>= 1'; '<= 1132'; []};
fieldsAndBounds(29,:) = { 'a1NumPredictorRows'; '>= 1'; '<= 12'; []};
fieldsAndBounds(30,:) = { 'a1NumNonlinearPredictorRows'; '>= 1'; '<= 6'; []};
fieldsAndBounds(31,:) = { 'a1NumFfiPredictorRows'; '>= 1'; '<= 12'; []};
fieldsAndBounds(32,:) = { 'a2SkipDiff'; []; []; [true; false]};
fieldsAndBounds(33,:) = { 'a2ColumnPredictorCount'; '>= 1'; '<= 1132'; []};
fieldsAndBounds(34,:) = { 'a2LeadColumnPredictorCount'; '>= 1'; '<= 1132'; []};
fieldsAndBounds(35,:) = { 'a2SmearPredictorCount'; '>= 1'; '<= 12'; []};
fieldsAndBounds(36,:) = { 'a2SolRange'; '>= 1'; '<= 1132'; []};
fieldsAndBounds(37,:) = { 'a2SolStart'; '>= 1'; '<= 1132'; []};
fieldsAndBounds(38,:) = { 'leadingArp'; []; []; []};
fieldsAndBounds(39,:) = { 'trailingArp'; []; []; []};
fieldsAndBounds(40,:) = { 'trailingArpUs'; []; []; []};
fieldsAndBounds(41,:) = { 'trailingCollat'; []; []; []};
fieldsAndBounds(42,:) = { 'neartrailingArp'; []; []; []};
fieldsAndBounds(43,:) = { 'trailingFfi'; []; []; []};
fieldsAndBounds(44,:) = { 'rclcTarg'; []; []; []};
fieldsAndBounds(45,:) = { 'trailingMaskedSmear'; []; []; []};
fieldsAndBounds(46,:) = { 'leadingMaskedSmear'; []; []; []};
fieldsAndBounds(47,:) = { 'blackResidualsThresholdDnPerRead';'>=0';'<500';[]};                  %  typically set 5 DN/read 14 coadded columns
fieldsAndBounds(48,:) = { 'blackResidualsStdDevThresholdDnPerRead';'>=0';'<500';[]};            %  typically set 0.15 DN/read 14 coadded columns
fieldsAndBounds(49,:) = { 'numBlackPixelsAboveThreshold';'>=0';'<=100';[]};                     %  typically set to 1% of rows == 10 pixels

validate_structure(inputsStruct.dynablackModuleParameters, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.rbaFlagConfigurationStruct
%--------------------------------------------------------------------------
s = inputsStruct.rbaFlagConfigurationStruct;
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'pixelNoiseThresholdAduPerRead'; '> 0'; '< 100'; []};
fieldsAndBounds(2,:)  = { 'pixelBiasThresholdAduPerRead'; '> 0'; '< 100'; []};
fieldsAndBounds(3,:)  = { 'cleaningScale'; '> 0'; '<= 100'; []};
fieldsAndBounds(4,:)  = { 'testPulseDurations'; '> 0'; '< 100'; []};
fieldsAndBounds(5,:)  = { 'numberOfFlagVariables'; '> 0'; '<= 20'; []};
fieldsAndBounds(6,:)  = { 'severityQuantiles'; '>=0'; '<=1'; []};
fieldsAndBounds(7,:)  = { 'meanSigmaThreshold'; '>= 0'; '<= 100'; []};
fieldsAndBounds(8,:)  = { 'robustWeightThreshold'; '>= 0'; '<=1'; []};
fieldsAndBounds(9,:)  = { 'transitDepthSigmaThreshold'; '>= 0'; '<= 100'; []};
fieldsAndBounds(10,:)  = { 'durationEarthOnSunLC'; '>= 0'; '<= 100'; []};

validate_structure(s, fieldsAndBounds, 'inputsStruct.rbaFlagConfigurationStruct');

% check that testPulseDurations is positive int
tf = all(s.testPulseDurations > 0) & all(floor(s.testPulseDurations) == s.testPulseDurations);
if ~tf
    display(['rbaFlagConfigurationStruct.testPulseDurations = [',num2str(s.testPulseDurations),']']);
    error('All elements of rbaFlagConfigurationStruct.testPulseDurations must be positve integers.');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.ancillaryEngineeringDataStruct()
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; {}};
fieldsAndBounds(2,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'values'; []; []; []};                     

nStructures = length(inputsStruct.ancillaryEngineeringDataStruct);

for i = 1 : nStructures
    validate_structure(inputsStruct.ancillaryEngineeringDataStruct(i), ...
        fieldsAndBounds, 'inputsStruct.ancillaryEngineeringDataStruct()');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.rawFfis()
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'fileName'; []; []; {}};
fieldsAndBounds(2,:)  = { 'startTimestamp'; '> 54500'; '< 70000'; []};  % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'midTimestamp'; '> 54500'; '< 70000'; []};    % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'endTimestamp'; '> 54500'; '< 70000'; []};    % 2/4/2008 to 7/13/2050
fieldsAndBounds(5,:)  = { 'image'; []; []; []};                                                                     % <-------- 3rd level

nStructures = length(inputsStruct.rawFfis);

for i = 1 : nStructures
    validate_structure(inputsStruct.rawFfis(i), fieldsAndBounds, 'inputsStruct.rawFfis()');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.cadenceTimes
%--------------------------------------------------------------------------
fieldsAndBounds = cell(14,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true; false]};
fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; [true; false]};
fieldsAndBounds(6,:)  = { 'cadenceNumbers'; '>= 0'; '< 2e7'; []};
fieldsAndBounds(7,:)  = { 'isSefiAcc'; []; []; [true; false]};
fieldsAndBounds(8,:)  = { 'isSefiCad'; []; []; [true; false]};
fieldsAndBounds(9,:)  = { 'isLdeOos'; []; []; [true; false]};
fieldsAndBounds(10,:) = { 'isFinePnt'; []; []; [true; false]};
fieldsAndBounds(11,:) = { 'isMmntmDmp'; []; []; [true; false]};
fieldsAndBounds(12,:) = { 'isLdeParEr'; []; []; [true; false]};
fieldsAndBounds(13,:) = { 'isScrcErr'; []; []; [true; false]};
fieldsAndBounds(14,:) = { 'dataAnomalyFlags'; []; []; {}};

cadenceTimes = inputsStruct.cadenceTimes;
cadenceTimes.startTimestamps = cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.midTimestamps = cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.endTimestamps = cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);

validate_structure(cadenceTimes, fieldsAndBounds, 'inputsStruct.cadenceTimes');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.blackPixels()
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'row'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true false]};

nStructures = length(inputsStruct.blackPixels);

for i = 1 : nStructures
    validate_structure(inputsStruct.blackPixels(i), fieldsAndBounds, 'inputsStruct.blackPixels()');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.maskedSmearPixels()
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'column'; '>= 0'; '< 1132'; []};
fieldsAndBounds(2,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true false]};

nStructures = length(inputsStruct.maskedSmearPixels);

for i = 1 : nStructures
    validate_structure(inputsStruct.maskedSmearPixels(i), fieldsAndBounds, 'inputsStruct.maskedSmearPixels()');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.virtualSmearPixels()
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'column'; '>= 0'; '< 1132'; []};
fieldsAndBounds(2,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true false]};

nStructures = length(inputsStruct.virtualSmearPixels);

for i = 1 : nStructures
    validate_structure(inputsStruct.virtualSmearPixels(i), fieldsAndBounds, 'inputsStruct.virtualSmearPixels()');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.backgroundPixels()
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'row'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'column'; '>= 0'; '< 1132'; []};
fieldsAndBounds(3,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true false]};

nStructures = length(inputsStruct.backgroundPixels);

for i = 1 : nStructures
    validate_structure(inputsStruct.backgroundPixels(i), fieldsAndBounds, 'inputsStruct.backgroundPixels()');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.arpTargetPixels()
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'row'; '>= 0'; '< 1070'; []};
fieldsAndBounds(2,:)  = { 'column'; '>= 0'; '< 1132'; []};
fieldsAndBounds(3,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true false]};

nStructures = length(inputsStruct.arpTargetPixels);

for i = 1 : nStructures
    validate_structure(inputsStruct.arpTargetPixels(i), fieldsAndBounds, 'inputsStruct.arpTargetPixels()');
end

clear fieldsAndBounds;


% conditionally validate reverse clocked fields
if inputsStruct.dynablackModuleParameters.reverseClockedEnabled
    
    %--------------------------------------------------------------------------
    % Second level validation.
    % Validate the structure field inputsStruct.reverseClockedCadenceTimes
    %--------------------------------------------------------------------------
    fieldsAndBounds = cell(14,4);
    fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
    fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
    fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
    fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true; false]};
    fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; [true; false]};
    fieldsAndBounds(6,:)  = { 'cadenceNumbers'; '>= 0'; '< 2e7'; []};
    fieldsAndBounds(7,:)  = { 'isSefiAcc'; []; []; [true; false]};
    fieldsAndBounds(8,:)  = { 'isSefiCad'; []; []; [true; false]};
    fieldsAndBounds(9,:)  = { 'isLdeOos'; []; []; [true; false]};
    fieldsAndBounds(10,:) = { 'isFinePnt'; []; []; [true; false]};
    fieldsAndBounds(11,:) = { 'isMmntmDmp'; []; []; [true; false]};
    fieldsAndBounds(12,:) = { 'isLdeParEr'; []; []; [true; false]};
    fieldsAndBounds(13,:) = { 'isScrcErr'; []; []; [true; false]};
    fieldsAndBounds(14,:) = { 'dataAnomalyFlags'; []; []; {}};
    
    cadenceTimes = inputsStruct.reverseClockedCadenceTimes;
    cadenceTimes.startTimestamps = cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
    cadenceTimes.midTimestamps = cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
    cadenceTimes.endTimestamps = cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);
    
    validate_structure(cadenceTimes, fieldsAndBounds, 'inputsStruct.reverseClockedCadenceTimes');
    
    clear fieldsAndBounds;
    
    %--------------------------------------------------------------------------
    % Second level validation.
    % Validate the structure field inputsStruct.reverseClockedBlackPixels()
    %--------------------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'row'; '>= 0'; '< 1070'; []};
    fieldsAndBounds(2,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
    fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true false]};
    
    nStructures = length(inputsStruct.reverseClockedBlackPixels);
    
    for i = 1 : nStructures
        validate_structure(inputsStruct.reverseClockedBlackPixels(i), fieldsAndBounds, 'inputsStruct.reverseClockedBlackPixels()');
    end
    
    clear fieldsAndBounds;
    
    %--------------------------------------------------------------------------
    % Second level validation.
    % Validate the structure field inputsStruct.reverseClockedMaskedSmearPixels()
    %--------------------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'column'; '>= 0'; '< 1132'; []};
    fieldsAndBounds(2,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
    fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true false]};
    
    nStructures = length(inputsStruct.reverseClockedMaskedSmearPixels);
    
    for i = 1 : nStructures
        validate_structure(inputsStruct.reverseClockedMaskedSmearPixels(i), fieldsAndBounds, 'inputsStruct.reverseClockedMaskedSmearPixels()');
    end
    
    clear fieldsAndBounds;
    
    %--------------------------------------------------------------------------
    % Second level validation.
    % Validate the structure field inputsStruct.reverseClockedVirtualSmearPixels()
    %--------------------------------------------------------------------------
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'column'; '>= 0'; '< 1132'; []};
    fieldsAndBounds(2,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
    fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true false]};
    
    nStructures = length(inputsStruct.reverseClockedVirtualSmearPixels);
    
    for i = 1 : nStructures
        validate_structure(inputsStruct.reverseClockedVirtualSmearPixels(i), fieldsAndBounds, 'inputsStruct.reverseClockedVirtualSmearPixels()');
    end
    
    clear fieldsAndBounds;
    
    %--------------------------------------------------------------------------
    % Second level validation.
    % Validate the structure field inputsStruct.reverseClockedBackgroundPixels()
    %--------------------------------------------------------------------------
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'row'; '>= 0'; '< 1070'; []};
    fieldsAndBounds(2,:)  = { 'column'; '>= 0'; '< 1132'; []};
    fieldsAndBounds(3,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
    fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true false]};
    
    nStructures = length(inputsStruct.reverseClockedBackgroundPixels);
    
    for i = 1 : nStructures
        validate_structure(inputsStruct.reverseClockedBackgroundPixels(i), fieldsAndBounds, 'inputsStruct.reverseClockedBackgroundPixels()');
    end
    
    clear fieldsAndBounds;
    
    %--------------------------------------------------------------------------
    % Second level validation.
    % Validate the structure field inputsStruct.reverseClockedTargetPixels()
    %--------------------------------------------------------------------------
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'row'; '>= 0'; '< 1070'; []};
    fieldsAndBounds(2,:)  = { 'column'; '>= 0'; '< 1132'; []};
    fieldsAndBounds(3,:)  = { 'values'; '>= 0'; '<= 2^23-1'; []};
    fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true false]};
    
    nStructures = length(inputsStruct.reverseClockedTargetPixels);
    
    for i = 1 : nStructures
        validate_structure(inputsStruct.reverseClockedTargetPixels(i), fieldsAndBounds, 'inputsStruct.reverseClockedTargetPixels()');
    end
    
    clear fieldsAndBounds;
end

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.requantTables (only needed fields)
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'meanBlackEntries'; '>= 0'; '<= 10000'; []};

nStructures = length(inputsStruct.requantTables);

for i = 1 : nStructures
    validate_structure(inputsStruct.requantTables(i), fieldsAndBounds, 'inputsStruct.requantTables()');
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field inputsStruct.fcConstants (only needed fields)
%--------------------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'CCD_ROWS'; '>= 1070'; '<= 1070'; []};
fieldsAndBounds(2,:)  = { 'CCD_COLUMNS'; '>= 1132'; '<= 1132'; []};

validate_structure(inputsStruct.fcConstants, fieldsAndBounds, 'inputsStruct.fcConstants');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.rawFfis().image
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'array'; '>= 0'; '<=1e8'; []};

nFfis = length(inputsStruct.rawFfis);

for j=1:nFfis    
    nStructures = length(inputsStruct.rawFfis(j));    
    for i = 1 : nStructures
        validate_structure(inputsStruct.rawFfis(j).image(i), fieldsAndBounds, ['inputsStruct.rawFfis(',num2str(j),').image(',num2str(i),')']);
    end
end

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters.leadingArp
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'Rmin'; '>= 1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'Rmax'; '>= 1'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'Cmin'; '>= 1'; '<=1132'; []};
fieldsAndBounds(4,:)  = { 'Cmax'; '>= 1'; '<=1132'; []};

validate_structure(inputsStruct.dynablackModuleParameters.leadingArp, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters.leadingArp');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters.trailingArp
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'Rmin'; '>= 1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'Rmax'; '>= 1'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'Cmin'; '>= 1'; '<=1132'; []};
fieldsAndBounds(4,:)  = { 'Cmax'; '>= 1'; '<=1132'; []};

validate_structure(inputsStruct.dynablackModuleParameters.trailingArp, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters.trailingArp');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters.trailingArpUs
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'Rmin'; '>= 1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'Rmax'; '>= 1'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'Cmin'; '>= 1'; '<=1132'; []};
fieldsAndBounds(4,:)  = { 'Cmax'; '>= 1'; '<=1132'; []};

validate_structure(inputsStruct.dynablackModuleParameters.trailingArpUs, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters.trailingArpUs');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters.trailingCollat
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'Rmin'; '>= 1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'Rmax'; '>= 1'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'Cmin'; '>= 1'; '<=1132'; []};
fieldsAndBounds(4,:)  = { 'Cmax'; '>= 1'; '<=1132'; []};

validate_structure(inputsStruct.dynablackModuleParameters.trailingCollat, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters.trailingCollat');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters.neartrailingArp
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'Rmin'; '>= 1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'Rmax'; '>= 1'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'Cmin'; '>= 1'; '<=1132'; []};
fieldsAndBounds(4,:)  = { 'Cmax'; '>= 1'; '<=1132'; []};

validate_structure(inputsStruct.dynablackModuleParameters.neartrailingArp, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters.neartrailingArp');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters.trailingFfi
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'Rmin'; '>= 1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'Rmax'; '>= 1'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'Cmin'; '>= 1'; '<=1132'; []};
fieldsAndBounds(4,:)  = { 'Cmax'; '>= 1'; '<=1132'; []};

validate_structure(inputsStruct.dynablackModuleParameters.trailingFfi, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters.trailingFfi');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters.rclcTarg
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'Rmin'; '>= 1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'Rmax'; '>= 1'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'Cmin'; '>= 1'; '<=1132'; []};
fieldsAndBounds(4,:)  = { 'Cmax'; '>= 1'; '<=1132'; []};

validate_structure(inputsStruct.dynablackModuleParameters.rclcTarg, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters.rclcTarg');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters.trailingMaskedSmear
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'Rmin'; '>= 1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'Rmax'; '>= 1'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'Cmin'; '>= 1'; '<=1132'; []};
fieldsAndBounds(4,:)  = { 'Cmax'; '>= 1'; '<=1132'; []};

validate_structure(inputsStruct.dynablackModuleParameters.trailingMaskedSmear, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters.trailingMaskedSmear');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.dynablackModuleParameters.leadingMaskedSmear
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'Rmin'; '>= 1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'Rmax'; '>= 1'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'Cmin'; '>= 1'; '<=1132'; []};
fieldsAndBounds(4,:)  = { 'Cmax'; '>= 1'; '<=1132'; []};

validate_structure(inputsStruct.dynablackModuleParameters.leadingMaskedSmear, fieldsAndBounds, 'inputsStruct.dynablackModuleParameters.leadingMaskedSmear');

clear fieldsAndBounds;


%--------------------------------------------------------------------------
% Third level validation.
% Validate the structure field inputsStruct.cadenceTimes.dataAnomalyFlags
%--------------------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'attitudeTweakIndicators'; []; []; [true, false]};
fieldsAndBounds(2,:)  = { 'safeModeIndicators'; []; []; [true, false]};
fieldsAndBounds(3,:)  = { 'coarsePointIndicators'; []; []; [true, false]};
fieldsAndBounds(4,:)  = { 'argabrighteningIndicators'; []; []; [true, false]};
fieldsAndBounds(5,:)  = { 'excludeIndicators'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'earthPointIndicators'; []; []; [true, false]};

validate_structure(inputsStruct.cadenceTimes.dataAnomalyFlags, fieldsAndBounds, 'inputsStruct.cadenceTimes.dataAnomalyFlags');

clear fieldsAndBounds;


% conditionally validate reverse clocked fields
if inputsStruct.dynablackModuleParameters.reverseClockedEnabled
    
    %--------------------------------------------------------------------------
    % Third level validation.
    % Validate the structure field inputsStruct.reverseClockedCadenceTimes.dataAnomalyFlags
    %--------------------------------------------------------------------------
    fieldsAndBounds = cell(6,4);
    fieldsAndBounds(1,:)  = { 'attitudeTweakIndicators'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'safeModeIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'coarsePointIndicators'; []; []; [true, false]};
    fieldsAndBounds(4,:)  = { 'argabrighteningIndicators'; []; []; [true, false]};
    fieldsAndBounds(5,:)  = { 'excludeIndicators'; []; []; [true, false]};
    fieldsAndBounds(6,:)  = { 'earthPointIndicators'; []; []; [true, false]};
    
    validate_structure(inputsStruct.reverseClockedCadenceTimes.dataAnomalyFlags, fieldsAndBounds, 'inputsStruct.reverseClockedCadenceTimes.dataAnomalyFlags');
    
    clear fieldsAndBounds;
end



% display elapsed time
t1 = clock;
disp(['Elapsed time = ',num2str(etime(t1,t0)/60),' minutes']);disp(' ');

