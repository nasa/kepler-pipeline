function [calEtem2CollateralInputStruct, calEtem2PhotometricInputStruct] = ...
    set_cal_SC_input_struct(etem2RunDirName, pixelDataMatFilename, cadenceList, ...
    getRequantizedPixFlag, includeCosmicRaysFlag, ccdModule, ccdOutput)
%
%function set_cal_SC_input_struct
%
% function to construct cal short cadence inputs from saved etem2 outputs.
%
% **Make sure to set ccdModule, ccdOutput, start time (mjd), and requant/huffman
%    table IDs (these may eventually become inputs if changed often)
% 
% cadenceList
% This is a list of relative cadence numbers from which to build the
% CAL inputsStructs. The list must be a subset of relative cadences from
% the original ETEM data available in pixelDataMatFilename. Nominally this
% is all the available cadences from the ETEM run which produced
% pixelDataMatFilename. e.g. cadenceList = [1:3000] will generate CAL
% inputStruct for the first 3000 cadences of the ETEM run.
%
%
% Example inputs/outputs:
%
%  etem2RunDirName  = 'calSC_ETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn_dir'
%
%  pixelDataMatFilename = 'calSC_pixelSeries_2D_st_sm_dc_nl_lu_ff_rn_qn_sn'
%
%
%
%--------------------------------------------------------------------------
%
% OUTPUT
% The following input structs will be updated with etem2 data for CAL
% collateral (1st invocation) and photometric (2nd+ invocations) data
%
% collateralInputs =
%                    version: 'CalInputs Version 1'             ok
%                 debugLevel: 0                                 ok
%                  firstCall: 1                                 ok
%                   lastCall: 0                                 ok
%                totalPixels: 36601                        *UPDATE
%                cadenceType: 'LONG'                            ok
%                  ccdModule: 3                                 ok
%                  ccdOutput: 3                                 ok
%     moduleParametersStruct: [1x1 struct]           *enable relevant flags
%  pouModuleParametersStruct: [1x1 struct]           *enable relevant flags
%                fcConstants: [1x1 struct]                      ok
%               cadenceTimes: [1x1 struct]           *adjust to nCadences
%                  gainModel: [1x1 struct]                 *RETRIEVE
%             flatFieldModel: [1x1 struct]                 *RETRIEVE
%             twoDBlackModel: [1x1 struct]                 *RETRIEVE
%             linearityModel: [1x1 struct]                 *RETRIEVE
%            undershootModel: [1x1 struct]                 *RETRIEVE
%             readNoiseModel: [1x1 struct]                 *RETRIEVE
%         targetAndBkgPixels: []                                ok
%               twoDBlackIds: [1x4 struct]                   *set to []
%           ldeUndershootIds: [1x2 struct]                   *set to []
%          maskedSmearPixels: [1x1100 struct]              *UPDATE
%         virtualSmearPixels: [1x1100 struct]              *UPDATE
%                blackPixels: [1x1070 struct]              *UPDATE
%          maskedBlackPixels: []                                ok
%         virtualBlackPixels: []                                ok
%        spacecraftConfigMap: [1x1 struct]                 *RETRIEVE
%              requantTables: [1x1 struct]                 *RETRIEVE
%              huffmanTables: [1x1 struct]                 *RETRIEVE
%
%
% photometricInputs =
%                    version: 'CalInputs Version 1'
%                 debugLevel: 0
%                  firstCall: 0
%                   lastCall: 0
%                totalPixels:                             *UPDATE
%                cadenceType: 'LONG'
%                  ccdModule: 3
%                  ccdOutput: 3
%     moduleParametersStruct: [1x1 struct]          *enable relevant flags
%  pouModuleParametersStruct: [1x1 struct]           *enable relevant flags
%                fcConstants: [1x1 struct]
%               cadenceTimes:                       *adjust to nCadences
%                  gainModel: [1x1 struct]
%             flatFieldModel: [1x1 struct]
%             twoDBlackModel: [1x1 struct]
%             linearityModel: [1x1 struct]          (see above for models)
%            undershootModel: [1x1 struct]
%             readNoiseModel: [1x1 struct]
%         targetAndBkgPixels: [1x5993 struct]              *UPDATE
%               twoDBlackIds: [1x4 struct]                 *set to []
%           ldeUndershootIds: [1x2 struct]                 *set to []
%          maskedSmearPixels: []
%         virtualSmearPixels: []
%                blackPixels: []
%          maskedBlackPixels: []
%         virtualBlackPixels: []
%        spacecraftConfigMap: [1x1 struct]
%              requantTables: [1x1 struct]
%              huffmanTables: [1x1 struct]
%
%
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

%--------------------------------------------------------------------------
% Etem2 run parameters:
%--------------------------------------------------------------------------
mjdStart = 54922;    % '1-April-2009'

%--------------------------------------------------------------------------
% should be a retrieve function soon to get this info:
%--------------------------------------------------------------------------
requantTableId = 200;
huffmanTableId = 200;


if (nargin < 3)
    disp('Function must be called with at least three arguments.');
elseif (nargin == 3)
    % by default extract requantized pixels without cosmic rays
    getRequantizedPixFlag = false;
    includeCosmicRaysFlag = false;
elseif (nargin == 4)
    % by default extract pixels without cosmic rays
    includeCosmicRaysFlag = false;
end


tic;

outputLocation = [etem2RunDirName, '/'];

% cd into directory with etem2 output
eval(['cd ' outputLocation ]);


%--------------------------------------------------------------------------
% define new input structs for collateral and photometric data
%--------------------------------------------------------------------------
calEtem2CollateralInputStruct  = [];
calEtem2PhotometricInputStruct = [];


%--------------------------------------------------------------------------
% load FC constants struct
%--------------------------------------------------------------------------
fcConstants = convert_fc_constants_java_2_struct;

calEtem2CollateralInputStruct.fcConstants  = fcConstants;
calEtem2PhotometricInputStruct.fcConstants = fcConstants;

%--------------------------------------------------------------------------
% set module parameters for CAL inputs, which may need to be updated prior
% to running CAL:
%--------------------------------------------------------------------------
%
% moduleParametersStruct:
%                           debugEnabled: 1
%              linearityCorrectionEnabled: 0
%                       undershootEnabled: 0
%                     crCorrectionEnabled: 0
%              flatFieldCorrectionEnabled: 0
%                      falseRejectionRate: 0.0001
%                            polyOrderMax: 10
%     madSigmaThresholdForBleedingColumns: 15
%         madSigmaThresholdForSmearLevels: 3.5
%           undershootReverseFitPolyOrder: 1
%              undershootReverseFitWindow: 10
%
% pouModuleParametersStruct:
%             pouEnabled: 0
%     compressionEnabled: 1
%            maxSvdOrder: 10
%       numErrorPropVars: 30
%         pixelChunkSize: 2500
%       interpDecimation: 24
%           interpMethod: 'linear'
%       cadenceChunkSize: 1
%--------------------------------------------------------------------------
moduleParametersStruct.debugEnabled                        = false;
moduleParametersStruct.linearityCorrectionEnabled          = true;
moduleParametersStruct.undershootEnabled                   = true;
moduleParametersStruct.crCorrectionEnabled                 = true;
moduleParametersStruct.flatFieldCorrectionEnabled          = true;
moduleParametersStruct.falseRejectionRate                   = 1.0000e-04;
moduleParametersStruct.polyOrderMax                         = 10;
moduleParametersStruct.madSigmaThresholdForBleedingColumns  = 15;
moduleParametersStruct.madSigmaThresholdForSmearLevels      = 3.5000;
moduleParametersStruct.undershootReverseFitPolyOrder        = 1;
moduleParametersStruct.undershootReverseFitWindow           = 10;

pouModuleParametersStruct.pouEnabled                        = false;
pouModuleParametersStruct.compressionEnabled                = false;
pouModuleParametersStruct.maxSvdOrder                       = 10;
pouModuleParametersStruct.numErrorPropVars                  = 30;
pouModuleParametersStruct.pixelChunkSize                    = 2500;
pouModuleParametersStruct.interpDecimation                  = 24;
pouModuleParametersStruct.interpMethod                      = 'linear';
pouModuleParametersStruct.cadenceChunkSize                  = 1;


% module parameters
calEtem2CollateralInputStruct.moduleParametersStruct  = moduleParametersStruct;
calEtem2PhotometricInputStruct.moduleParametersStruct = moduleParametersStruct;

calEtem2CollateralInputStruct.pouModuleParametersStruct  = pouModuleParametersStruct;
calEtem2PhotometricInputStruct.pouModuleParametersStruct = pouModuleParametersStruct;

%--------------------------------------------------------------------------
% Set additional CAL inputs
%--------------------------------------------------------------------------
calEtem2CollateralInputStruct.version  = 'CalInputs Version 1';
calEtem2PhotometricInputStruct.version = 'CalInputs Version 1';

calEtem2CollateralInputStruct.debugLevel  = 2;
calEtem2PhotometricInputStruct.debugLevel = 2;

calEtem2CollateralInputStruct.firstCall  = 1;
calEtem2PhotometricInputStruct.firstCall = 0;

calEtem2CollateralInputStruct.lastCall  = 0;
calEtem2PhotometricInputStruct.lastCall = 1;

calEtem2CollateralInputStruct.cadenceType  = 'SHORT';
calEtem2PhotometricInputStruct.cadenceType = 'SHORT';

calEtem2CollateralInputStruct.ccdModule  = ccdModule;
calEtem2PhotometricInputStruct.ccdModule = ccdModule;

calEtem2CollateralInputStruct.ccdOutput  = ccdOutput;
calEtem2PhotometricInputStruct.ccdOutput = ccdOutput;

% set ppa target fields to empty
calEtem2CollateralInputStruct.twoDBlackIds  = [];
calEtem2PhotometricInputStruct.twoDBlackIds = [];

calEtem2CollateralInputStruct.ldeUndershootIds  = [];
calEtem2PhotometricInputStruct.ldeUndershootIds = [];


%--------------------------------------------------------------------------
% Construct cadenceTimes struct:
%--------------------------------------------------------------------------
%
% cadenceTimes =
%     startTimestamps: [nCadencesx1 double]
%       midTimestamps: [nCadencesx1 double]
%       endTimestamps: [nCadencesx1 double]
%       gapIndicators: [nCadencesx1 logical]
%      requantEnabled: [nCadencesx1 logical]
%           isSefiAcc: [nCadencesx1 logical]
%           isSefiCad: [nCadencesx1 logical]
%            isLdeOos: [nCadencesx1 logical]
%           isFinePnt: [nCadencesx1 logical]
%          isMmntmDmp: [nCadencesx1 logical]
%          isLdeParEr: [nCadencesx1 logical]
%           isScrcErr: [nCadencesx1 logical]
%    dataAnomalyTypes: {1xnCadences cell}
%

% Fix timeStamp data:   1392 cadences @ 48 cad per day
nLongCadencePerDay = 48;      % inverse = 0.020833
nShortsInLong = 30;
nShortCadencePerDay = nLongCadencePerDay*nShortsInLong;  % inverse = 6.9444e-04

nCadences = length(cadenceList);


mjdEnd   = (mjdStart + nCadences/nShortCadencePerDay);

timestampArray = mjdStart: 6.9444e-04 : mjdEnd;

cadenceTimes.midTimestamps  = timestampArray(1:end-1);
cadenceTimes.midTimestamps  = cadenceTimes.midTimestamps(:);

cadenceTimes.startTimestamps = repmat(55000, length(cadenceTimes.midTimestamps), 1); %not used in cal
cadenceTimes.endTimestamps   = repmat(55000, length(cadenceTimes.midTimestamps), 1); %not used in cal
cadenceTimes.gapIndicators   = false(length(cadenceTimes.midTimestamps), 1);

if getRequantizedPixFlag
    cadenceTimes.requantEnabled  = true(length(cadenceTimes.midTimestamps), 1);
else
    cadenceTimes.requantEnabled  = false(length(cadenceTimes.midTimestamps), 1);
end

cadenceTimes.isSefiAcc           = false(length(cadenceTimes.midTimestamps), 1);
cadenceTimes.isSefiCad           = false(length(cadenceTimes.midTimestamps), 1);
cadenceTimes.isLdeOos            = false(length(cadenceTimes.midTimestamps), 1);
cadenceTimes.isFinePnt           = true(length(cadenceTimes.midTimestamps), 1);
cadenceTimes.isMmntmDmp          = false(length(cadenceTimes.midTimestamps), 1);
cadenceTimes.isLdeParEr          = false(length(cadenceTimes.midTimestamps), 1);
cadenceTimes.isScrcErr           = false(length(cadenceTimes.midTimestamps), 1);
cadenceTimes.dataAnomalyTypes    = cell(1,length(cadenceTimes.midTimestamps));


cadenceTimes.cadenceNumbers  = 0:length(cadenceTimes.midTimestamps)-1;
cadenceTimes.cadenceNumbers  = cadenceTimes.cadenceNumbers(:);

calEtem2CollateralInputStruct.cadenceTimes  = cadenceTimes;
calEtem2PhotometricInputStruct.cadenceTimes = cadenceTimes;


% set cosmic ray parameters struct
calEtem2CollateralInputStruct.cosmicRayParametersStruct = struct('detrendOrder', 2,...
                                                                 'medianFilterLength', 5,...
                                                                 'madThreshold', 12,...
                                                                 'thresholdMultiplierForNegativeEvents', 2,...
                                                                 'consecutiveCosmicRayCleaningEnabled', false,...
                                                                 'twoSidedFinalThresholdingEnabled', false,...
                                                                 'madWindowLength', 145);
                                                             
calEtem2PhotometricInputStruct.cosmicRayParametersStruct = struct('detrendOrder', 2,...
                                                                  'medianFilterLength', 5,...
                                                                  'madThreshold', 12,...
                                                                  'thresholdMultiplierForNegativeEvents', 2,...
                                                                  'consecutiveCosmicRayCleaningEnabled', false,...
                                                                  'twoSidedFinalThresholdingEnabled', false,...
                                                                  'madWindowLength', 145);
                                                             
                                                             



%--------------------------------------------------------------------------
% extract_SC_pixel_time_series_from_etem2 saves the following .mat file
% with target and background data in per-pixel structs

if (getRequantizedPixFlag && ~includeCosmicRaysFlag)

    eval(['load ' pixelDataMatFilename '_RQ_cr.mat']);

elseif (getRequantizedPixFlag && includeCosmicRaysFlag)

    eval(['load ' pixelDataMatFilename '_RQ_CR.mat']);

elseif (~getRequantizedPixFlag && ~includeCosmicRaysFlag)

    eval(['load ' pixelDataMatFilename '_rq_cr.mat']);

elseif  (~getRequantizedPixFlag && includeCosmicRaysFlag)

    eval(['load ' pixelDataMatFilename '_rq_CR.mat']);
end


%--------------------------------------------------------------------------
% extract pixels
%--------------------------------------------------------------------------
% the following fields are loaded:
%
% pixelSeries =
% 1x2 struct array with fields:
%     pixelValues
%     pixelRows
%     pixelCols
%     blackValues
%     maskedSmearValues
%     virtualSmearValues
%     blackMaskedValue
%     blackVirtualValue


%----------------------------------------------------------------------
% convert ETEM2 black arrays into array of structures for output
%----------------------------------------------------------------------
% extract black pixels
blackValues         = ([pixelSeries.blackValues])';   % nPix x nCad
blackRows           = ([pixelSeries.blackRows]');     % nPix x 1
blackGapIndicators  = false(size(blackValues));

blackValuesCellArray        = num2cell(blackValues(:,cadenceList)', 1);
blackRowsCellArray          = num2cell(blackRows);
blackGapIndicatorsCellArray = num2cell(blackGapIndicators(:,cadenceList)', 1);

% deal into new struct arrays
blackNew = [];

[blackNew(1:length(blackValuesCellArray)).values] = ...
    deal(blackValuesCellArray{:});
[blackNew(1:length(blackGapIndicatorsCellArray)).gapIndicators] = ...
    deal(blackGapIndicatorsCellArray{:});
[blackNew(1:length(blackRowsCellArray)).row] = ...
    deal(blackRowsCellArray{:});

% save black to input pixel struct
calEtem2CollateralInputStruct.blackPixels   = blackNew;
% set empty for photometric pixels
calEtem2PhotometricInputStruct.blackPixels  = [];


%----------------------------------------------------------------------
% extract masked black pixels
%----------------------------------------------------------------------
% blackMaskedValue is actually identical for all targets in pixelSeries,
% but the mean will do here
maskedBlackPixels.values        = mean([pixelSeries.blackMaskedValue], 2);
maskedBlackPixels.values        = maskedBlackPixels.values(cadenceList);
maskedBlackPixels.gapIndicators = false(size(maskedBlackPixels.values(cadenceList)));

% save to input pixel struct
calEtem2CollateralInputStruct.maskedBlackPixels = maskedBlackPixels;

% set empty for photometric pixels
calEtem2PhotometricInputStruct.maskedBlackPixels  = [];


%----------------------------------------------------------------------
% extract virtual black pixels
%----------------------------------------------------------------------
% virtualMaskedValue is actually identical for all targets in pixelSeries,
% but the mean will do here
virtualBlackPixels.values        = mean([pixelSeries.blackVirtualValue], 2);
virtualBlackPixels.values        = virtualBlackPixels.values(cadenceList);
virtualBlackPixels.gapIndicators = false(size(virtualBlackPixels.values(cadenceList)));

% save to input pixel struct
calEtem2CollateralInputStruct.virtualBlackPixels   = virtualBlackPixels;

% set empty for photometric pixels
calEtem2PhotometricInputStruct.virtualBlackPixels  = [];


%----------------------------------------------------------------------
% convert ETEM2 masked smear arrays into array of structures for output
%----------------------------------------------------------------------
% extract masked smear pixels
maskedSmearValues           = ([pixelSeries.maskedSmearValues])';  % nPix x nCad
maskedSmearColumns          = ([pixelSeries.maskedCols]');         % nPix x 1
maskedSmearGapIndicators    = false(size(maskedSmearValues));

mSmearValuesCellArray           = num2cell(maskedSmearValues(:,cadenceList)', 1);
mSmearColumnsCellArray          = num2cell(maskedSmearColumns);
mSmearGapIndicatorsCellArray    = num2cell(maskedSmearGapIndicators(:,cadenceList)', 1);

% deal into new struct arrays
maskedSmearNew = [];

[maskedSmearNew(1:length(mSmearValuesCellArray)).values] = ...
    deal(mSmearValuesCellArray{:});
[maskedSmearNew(1:length(mSmearGapIndicatorsCellArray)).gapIndicators] = ...
    deal(mSmearGapIndicatorsCellArray{:});
[maskedSmearNew(1:length(mSmearColumnsCellArray)).column] = ...
    deal(mSmearColumnsCellArray{:});

% save masked smear to collateral pixel struct
calEtem2CollateralInputStruct.maskedSmearPixels     = maskedSmearNew;
% set empty for photometric pixels
calEtem2PhotometricInputStruct.maskedSmearPixels    = [];



%--------------------------------------------------------------------------
% convert ETEM2 virtual smear arrays into array of structures for output
%----------------------------------------------------------------------
% extact virtual smear pixels
virtualSmearValues          = ([pixelSeries.virtualSmearValues])';  % nPix x nCad
virtualSmearColumns         = ([pixelSeries.virtualCols]');         % nPix x 1
virtualSmearGapIndicators   = false(size(virtualSmearValues));

vSmearValuesCellArray        = num2cell(virtualSmearValues(:,cadenceList)', 1);
vSmearColumnsCellArray       = num2cell(virtualSmearColumns);
vSmearGapIndicatorsCellArray = num2cell(virtualSmearGapIndicators(:,cadenceList)', 1);

% deal into new struct arrays
virtualSmearNew = [];

[virtualSmearNew(1:length(vSmearValuesCellArray)).values] = ...
    deal(vSmearValuesCellArray{:});
[virtualSmearNew(1:length(vSmearGapIndicatorsCellArray)).gapIndicators] = ...
    deal(vSmearGapIndicatorsCellArray{:});
[virtualSmearNew(1:length(vSmearColumnsCellArray)).column] = ...
    deal(vSmearColumnsCellArray{:});

% save virtual smear to collateral pixel struct
calEtem2CollateralInputStruct.virtualSmearPixels    = virtualSmearNew;
% set empty for photometric pixels
calEtem2PhotometricInputStruct.virtualSmearPixels   = [];



%--------------------------------------------------------------------------
% create photometric pixel input struct
%----------------------------------------------------------------------
% CAL input struct requires the following format/fields:
%
% targetAndBkgPixels
%      1xnPixels struct array with fields:
%           row
%           column
%           values
%           gapIndicators

targetValues        = ([pixelSeries.pixelValues])';  % nPix x nCad
targetRows          = ([pixelSeries.pixelRows])';    % nPix x 1
targetColumns       = ([pixelSeries.pixelCols])';    % nPix x 1
targetGapIndicators = false(size(targetValues));

targetValuesCellArray        = num2cell(targetValues(:,cadenceList)', 1);
targetRowsCellArray          = num2cell(targetRows);
targetColumnsCellArray       = num2cell(targetColumns);
targetGapIndicatorsCellArray = num2cell(targetGapIndicators(:,cadenceList)', 1);


% deal into new struct arrays
targetNew = [];

[targetNew(1:length(targetValuesCellArray)).values] = ...
    deal(targetValuesCellArray{:});

[targetNew(1:length(targetRowsCellArray)).row] = ...
    deal(targetRowsCellArray{:});

[targetNew(1:length(targetColumnsCellArray)).column] = ...
    deal(targetColumnsCellArray{:});

[targetNew(1:length(targetGapIndicatorsCellArray)).gapIndicators] = ...
    deal(targetGapIndicatorsCellArray{:});


% save to input pixel struct
calEtem2CollateralInputStruct.targetAndBkgPixels  = [];
calEtem2PhotometricInputStruct.targetAndBkgPixels = targetNew;


%--------------------------------------------------------------------------
% update total pixels, which must include #collateral + # photometric (target + bkgd) + ppa
%--------------------------------------------------------------------------
nTargetPixels   = length(targetValues(:, 1));

nMsmearPixels   = length(maskedSmearValues(:, 1));
nVsmearPixels   = length(virtualSmearValues(:, 1));
nBlackPixels    = length(blackValues(:, 1));

nMblackPixels   = 1;
nVblackPixels   = 1;

totalPixels     = nTargetPixels+nMsmearPixels+nVsmearPixels+nBlackPixels+nMblackPixels+nVblackPixels;

calEtem2CollateralInputStruct.totalPixels  = totalPixels;
calEtem2PhotometricInputStruct.totalPixels = totalPixels;



%--------------------------------------------------------------------------
% retrieve current FC models for this run (using startMjd
%--------------------------------------------------------------------------

startMjd = cadenceTimes.midTimestamps(1);
endMjd   = cadenceTimes.midTimestamps(end);

%--------------------------------------------------------------------------
% extract spacecraft config map
%--------------------------------------------------------------------------
%spacecraftConfigMap = retrieve_config_map(startMjd);
spacecraftConfigMap = retrieve_config_map(startMjd, endMjd);

calEtem2CollateralInputStruct.spacecraftConfigMap  = spacecraftConfigMap;
calEtem2PhotometricInputStruct.spacecraftConfigMap = spacecraftConfigMap;


%--------------------------------------------------------------------------
% construct requant tables struct
%
% ex. requantTables =
%           externalId: 150
%             startMjd: 5.4909e+04
%       requantEntries: [65536x1 double]
%     meanBlackEntries: [84x1 double]
%
%--------------------------------------------------------------------------
[requantEntries, meanBlackEntries] = retrieve_requant_table(requantTableId);

requantTables.externalId        = 150;
requantTables.startMjd          = startMjd;
requantTables.requantEntries    = double(requantEntries);
requantTables.meanBlackEntries  = double(meanBlackEntries);

calEtem2CollateralInputStruct.requantTables  = requantTables;
calEtem2PhotometricInputStruct.requantTables = requantTables;


%--------------------------------------------------------------------------
% construct huffman tables struct
%
% ex. huffmanTables =
%     theoreticalCompressionRate: 6.2753
%       effectiveCompressionRate: 6.3224
%        achievedCompressionRate: 0
%                     externalId: 150
%                      bitString: {1x131071 cell}
%                       startMjd: 5.4909e+04
%--------------------------------------------------------------------------
huffmanData = retrieve_huffman_table(huffmanTableId);

% output from above function is:
% huffmanData =
%     theoreticalCompressionRate: 14.9015731811523
%       effectiveCompressionRate: 14.9330358505249
%                      bitstring: {131071x1 cell}
%                 histogramEntry: [131071x1 double]

% redefine huffman tables struct for CAL
huffmanTables.theoreticalCompressionRate    = huffmanData.theoreticalCompressionRate;
huffmanTables.effectiveCompressionRate      = huffmanData.effectiveCompressionRate;
huffmanTables.achievedCompressionRate       = 0;
huffmanTables.externalId                    = 150;
huffmanTables.bitString                     = huffmanData.bitstring;
huffmanTables.startMjd                      = startMjd;

calEtem2CollateralInputStruct.huffmanTables  = huffmanTables;
calEtem2PhotometricInputStruct.huffmanTables = huffmanTables;

%--------------------------------------------------------------------------
% construct readNoiseModel struct
%
% ex. readNoiseModel =
%          mjds: 5.4504e+04
%     constants: [1x1 struct]
%--------------------------------------------------------------------------
readNoiseModel = retrieve_read_noise_model(startMjd, endMjd);

calEtem2CollateralInputStruct.readNoiseModel  = readNoiseModel;
calEtem2PhotometricInputStruct.readNoiseModel = readNoiseModel;


%--------------------------------------------------------------------------
% construct gainModel struct
%
% ex. gainModel =
%          mjds: 5.4505e+04
%     constants: [1x1 struct]
%--------------------------------------------------------------------------
gainModel = retrieve_gain_model(startMjd, endMjd);

calEtem2CollateralInputStruct.gainModel  = gainModel;
calEtem2PhotometricInputStruct.gainModel = gainModel;


%--------------------------------------------------------------------------
% construct undershootModel struct
%
% ex. undershootModel =
%          mjds: 5.4505e+04
%     constants: [1x1 struct]
%--------------------------------------------------------------------------
undershootModel = retrieve_undershoot_model(startMjd, endMjd);

calEtem2CollateralInputStruct.undershootModel  = undershootModel;
calEtem2PhotometricInputStruct.undershootModel = undershootModel;


%--------------------------------------------------------------------------
% construct linearityModel struct
%
% ex.linearityModel =
%              mjds: 5.4517e+04
%         constants: [1x1 struct]
%     uncertainties: [1x1 struct]
%          offsetXs: 0
%           scaleXs: 2.5291e-04
%          originXs: 3.8474e+03
%             types: {'standard'}
%          xIndices: -1
%        maxDomains: 11465
%--------------------------------------------------------------------------
linearityModel = retrieve_linearity_model(startMjd, endMjd, ccdModule, ccdOutput);

calEtem2CollateralInputStruct.linearityModel  = linearityModel;
calEtem2PhotometricInputStruct.linearityModel = linearityModel;

%--------------------------------------------------------------------------
% construct twoDBlackModel struct
%
% ex. twoDBlackModel =
%              mjds: 5.4501e+04
%              rows: []
%           columns: []
%            blacks: [1x1 struct]
%     uncertainties: [1x1 struct]
%           ccdRows: 1070
%        ccdColumns: 1132
%--------------------------------------------------------------------------
twoDBlackModel = retrieve_two_d_black_model(ccdModule, ccdOutput, startMjd, endMjd);

calEtem2CollateralInputStruct.twoDBlackModel  = twoDBlackModel;
calEtem2PhotometricInputStruct.twoDBlackModel = twoDBlackModel;

%--------------------------------------------------------------------------
% construct flatFieldModel struct
%
% ex. flatFieldModel =
%                mjds: [2x1 double]
%                rows: []
%             columns: []
%               flats: [1x2 struct]
%       uncertainties: [1x2 struct]
%     polynomialOrder: [2x1 double]
%                type: {'standard'  'standard'}
%              xIndex: [2x1 double]
%             offsetX: [2x1 double]
%              scaleX: [2x1 double]
%             originX: [2x1 double]
%              yIndex: [2x1 double]
%             offsetY: [2x1 double]
%              scaleY: [2x1 double]
%             originY: [2x1 double]
%              coeffs: [1x2 struct]
%              covars: [1x2 struct]
%             ccdRows: 1070
%          ccdColumns: 1132
%--------------------------------------------------------------------------
flatFieldModel = retrieve_flat_field_model(ccdModule, ccdOutput, startMjd, endMjd);

calEtem2CollateralInputStruct.flatFieldModel  = flatFieldModel;
calEtem2PhotometricInputStruct.flatFieldModel = flatFieldModel;


%--------------------------------------------------------------------------
% convert ETEM2 outputs to Java 0-based indices needed for CAL inputs
%--------------------------------------------------------------------------

calEtem2CollateralInputStruct  = convert_cal_etem2_inputs_to_0_base(calEtem2CollateralInputStruct);
calEtem2PhotometricInputStruct = convert_cal_etem2_inputs_to_0_base(calEtem2PhotometricInputStruct);


%--------------------------------------------------------------------------
% sort photometric pixels and remove duplicates
%--------------------------------------------------------------------------
[calEtem2PhotometricInputStruct, dups] = sort_photometric_pixels_and_remove_duplicates(calEtem2PhotometricInputStruct);

calEtem2CollateralInputStruct.totalPixels = calEtem2CollateralInputStruct.totalPixels - dups;


duration = toc;

display(['CAL input structs created for Short Cadence ETEM2 run ' etem2RunDirName ' : ' num2str(duration/60) ' minutes']);


%--------------------------------------------------------------------------
% save inputs
%--------------------------------------------------------------------------

if (getRequantizedPixFlag && ~includeCosmicRaysFlag)

    eval(['save /path/to/matlab/cal/calInputs_', etem2RunDirName, '_RQ_cr.mat calEtem2CollateralInputStruct calEtem2PhotometricInputStruct']);
    eval(['save calInputs_', etem2RunDirName, '_RQ_cr.mat calEtem2CollateralInputStruct calEtem2PhotometricInputStruct']);


elseif (getRequantizedPixFlag && includeCosmicRaysFlag)

    eval(['save /path/to/matlab/cal/calInputs_', etem2RunDirName, '_RQ_CR.mat calEtem2CollateralInputStruct calEtem2PhotometricInputStruct']);
    eval(['save calInputs_', etem2RunDirName, '_RQ_CR.mat calEtem2CollateralInputStruct calEtem2PhotometricInputStruct']);

elseif (~getRequantizedPixFlag && ~includeCosmicRaysFlag)

    eval(['save /path/to/matlab/cal/calInputs_', etem2RunDirName, '_rq_cr.mat calEtem2CollateralInputStruct calEtem2PhotometricInputStruct']);
    eval(['save calInputs_', etem2RunDirName, '_rq_cr.mat calEtem2CollateralInputStruct calEtem2PhotometricInputStruct']);

elseif  (~getRequantizedPixFlag && includeCosmicRaysFlag)

    eval(['save /path/to/matlab/cal/calInputs_', etem2RunDirName, '_rq_CR.mat calEtem2CollateralInputStruct calEtem2PhotometricInputStruct']);
    eval(['save calInputs_', etem2RunDirName, '_rq_CR.mat calEtem2CollateralInputStruct calEtem2PhotometricInputStruct']);

end


cd ..
return;
