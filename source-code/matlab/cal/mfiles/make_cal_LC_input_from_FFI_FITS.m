function result = make_cal_LC_input_from_FFI_FITS(fitsFilename, imageIndex)
% function result = make_cal_LC_input_from_FFI_FITS(fitsFilename, imageIndex)
%
% This function takes input of a FITS files containing a set of Full Frame
% Images (FFI)and creates the corresponding calInputStructs in a single long
% cadence (LC) format. The calInputStructs are saved to the working directory
% as cal-input#.mat, # = 0 (collateral), 1,...,22 (photometric). The
% calInputStruct variable in each of these files is named 'inputsStruct'.
%
% INPUTS:   filename    = FITS filename (*.fits). Assumes file contains
%                         only data with 'Image' extension
%           imageIndex  = The FITS file is assumed to contain one image for
%                         each channel. imageIndex = 1 ... 84 but may not
%                         agree with channel number
% OUTPUT:   result      = dummy - set to true for all calls
%           cal-inputs
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

result = true;

calInputFilePrefix  = 'cal-inputs';
nRowsPerInvocation = 1070;

extensionName   = 'IMAGE';
channelName     = 'CHANNEL';
moduleName      = 'MODULE';
outputName      = 'OUTPUT';
startTimeName   = 'STARTIME';
endTimeName     = 'END_TIME';
midTimeName     = 'MID_TIME';
numFFIName      = 'NUM_FFI';

info = fitsinfo(fitsFilename);
data = fitsread(fitsFilename, extensionName, imageIndex);

% get time index (mjd) from FITS info
startMjd = info.PrimaryData.Keywords{find(strcmp(info.PrimaryData.Keywords(:,1),startTimeName)),2};
midMjd = info.PrimaryData.Keywords{find(strcmp(info.PrimaryData.Keywords(:,1),midTimeName)),2};
endMjd = info.PrimaryData.Keywords{find(strcmp(info.PrimaryData.Keywords(:,1),endTimeName)),2};

% get mod/out for this index from FITS info
ccdModule  = info.Image(imageIndex).Keywords{find(strcmp(info.Image(imageIndex).Keywords(:,1),moduleName)),2};
ccdOutput  = info.Image(imageIndex).Keywords{find(strcmp(info.Image(imageIndex).Keywords(:,1),outputName)),2};
ccdChannel = info.Image(imageIndex).Keywords{find(strcmp(info.Image(imageIndex).Keywords(:,1),channelName)),2};

% get number of temporal coadds in image. used in mean black subtraction
numFFICoadd = info.PrimaryData.Keywords{find(strcmp(info.PrimaryData.Keywords(:,1),numFFIName)),2};

requantTableId      = 200;
huffmanTableId      = 200;

% set up module parameters
moduleParametersStruct.debugEnabled                         = false;
moduleParametersStruct.linearityCorrectionEnabled           = true;
moduleParametersStruct.undershootEnabled                    = true;
moduleParametersStruct.crCorrectionEnabled                  = true;
moduleParametersStruct.flatFieldCorrectionEnabled           = false;
moduleParametersStruct.falseRejectionRate                   = 1.0000e-04;
moduleParametersStruct.polyOrderMax                         = 10;
moduleParametersStruct.madSigmaThresholdForBleedingColumns  = 15;
moduleParametersStruct.madSigmaThresholdForSmearLevels      = 3.5000;
moduleParametersStruct.undershootReverseFitPolyOrder        = 1;
moduleParametersStruct.undershootReverseFitWindow           = 10;

% set up pou parameters
pouModuleParametersStruct.pouEnabled                        = false;
pouModuleParametersStruct.compressionEnabled                = false;
pouModuleParametersStruct.maxSvdOrder                       = 10;
pouModuleParametersStruct.numErrorPropVars                  = 40;
pouModuleParametersStruct.pixelChunkSize                    = 2500;
pouModuleParametersStruct.interpDecimation                  = 24;
pouModuleParametersStruct.interpMethod                      = 'linear';
pouModuleParametersStruct.cadenceChunkSize                  = 1;

% retrieve constants, models and config map
fcConstants         = convert_fc_constants_java_2_struct;
spacecraftConfigMap = retrieve_config_map(startMjd, endMjd);
readNoiseModel      = retrieve_read_noise_model(startMjd, endMjd);
gainModel           = retrieve_gain_model(startMjd, endMjd);
undershootModel     = retrieve_undershoot_model(startMjd, endMjd);
linearityModel      = retrieve_linearity_model(startMjd, endMjd, ccdModule, ccdOutput);
twoDBlackModel      = retrieve_two_d_black_model(ccdModule, ccdOutput, startMjd, endMjd);
flatFieldModel      = retrieve_flat_field_model(ccdModule, ccdOutput, startMjd, endMjd);

% ensure config map has same number of exposures (FDMLDEFFINUM) as FFI
spacecraftConfigMap.entries(10).value = num2str(numFFICoadd);


% construct cadenceTimes struct - this should contain a single cadence
% timestamp of each type: start, mid, end
cadenceTimes.midTimestamps      = midMjd;
cadenceTimes.startTimestamps    = startMjd;
cadenceTimes.endTimestamps      = endMjd;
cadenceTimes.gapIndicators      = false(size(cadenceTimes.midTimestamps));
cadenceTimes.requantEnabled     = false(size(cadenceTimes.midTimestamps));
cadenceTimes.cadenceNumbers     = (0:length(cadenceTimes.midTimestamps)-1)';

% construct requant tables struct
[requantEntries, meanBlackEntries]  = retrieve_requant_table(requantTableId);
requantTables.externalId            = 150;
requantTables.startMjd              = startMjd;
requantTables.requantEntries        = double(requantEntries);
requantTables.meanBlackEntries      = double(meanBlackEntries);

% construct huffman tables struct
huffmanData = retrieve_huffman_table(huffmanTableId);
huffmanTables.theoreticalCompressionRate    = huffmanData.theoreticalCompressionRate;
huffmanTables.effectiveCompressionRate      = huffmanData.effectiveCompressionRate;
huffmanTables.achievedCompressionRate       = 0;
huffmanTables.externalId                    = 150;
huffmanTables.bitString                     = huffmanData.bitstring;
huffmanTables.startMjd                      = startMjd;

% get spatial coadd row/column, start/end indices - one based (MATLAB)
configMapObject     = configMapClass(spacecraftConfigMap);
blackColumnStart    = get_black_start_column(configMapObject);
blackColumnEnd      = get_black_end_column(configMapObject);
blackRowStart       = get_black_start_row(configMapObject);
blackRowEnd         = get_black_end_row(configMapObject);
mSmearColumnStart   = get_masked_smear_start_column(configMapObject);
mSmearColumnEnd     = get_masked_smear_end_column(configMapObject);
mSmearRowStart      = get_masked_smear_start_row(configMapObject);
mSmearRowEnd        = get_masked_smear_end_row(configMapObject);
vSmearColumnStart   = get_virtual_smear_start_column(configMapObject);
vSmearColumnEnd     = get_virtual_smear_end_column(configMapObject);
vSmearRowStart      = get_virtual_smear_start_row(configMapObject);
vSmearRowEnd        = get_virtual_smear_end_row(configMapObject);

mSmearRows      = mSmearRowStart:mSmearRowEnd;
mSmearColumns   = mSmearColumnStart:mSmearColumnEnd;
vSmearRows      = vSmearRowStart:vSmearRowEnd;
vSmearColumns   = vSmearColumnStart:vSmearColumnEnd;
blackRows       = blackRowStart:blackRowEnd;
blackColumns    = blackColumnStart:blackColumnEnd;

% treat all of FFI as photometric pixels
imageRowStart   = fcConstants.MASKED_SMEAR_START + 1;
imageRowEnd     = fcConstants.VIRTUAL_SMEAR_END + 1;
imageColStart   = fcConstants.LEADING_BLACK_START + 1;
imageColEnd     = fcConstants.TRAILING_BLACK_END + 1;

imageRows       = imageRowStart:imageRowEnd;
imageCols       = imageColStart:imageColEnd;


% FFI has no fixed offset added or mean black subtracted
fixedOffset     = get_long_cadence_fixed_offset(configMapObject);
meanBlack       = numFFICoadd * requantTables.meanBlackEntries(ccdChannel);

% subtract mean black from all pixels
data = data - meanBlack;

% set up generic CAL inputsStruct
tempStruct  = [];

tempStruct.version        = 'CalInputs Version 1';
tempStruct.debugLevel     = 0;
tempStruct.firstCall      = 0;
tempStruct.lastCall       = 0;
tempStruct.totalPixels    = length(blackRows) + length(mSmearColumns) + length(vSmearColumns) + ...
    (imageRowEnd - imageRowStart + 1)*(imageColEnd - imageColStart + 1);
tempStruct.cadenceType    = 'LONG';
tempStruct.ccdModule      = ccdModule;
tempStruct.ccdOutput      = ccdOutput;

tempStruct.moduleParametersStruct     = moduleParametersStruct;
tempStruct.pouModuleParametersStruct  = pouModuleParametersStruct;
tempStruct.fcConstants                = fcConstants;
tempStruct.cadenceTimes               = cadenceTimes;

% set constants, config map and models
tempStruct.readNoiseModel         = readNoiseModel;
tempStruct.gainModel              = gainModel;
tempStruct.undershootModel        = undershootModel;
tempStruct.linearityModel         = linearityModel;
tempStruct.twoDBlackModel         = twoDBlackModel;
tempStruct.flatFieldModel         = flatFieldModel;

tempStruct.twoDBlackIds           = [];
tempStruct.ldeUndershootIds       = [];
tempStruct.targetAndBkgPixels     = [];
tempStruct.maskedSmearPixels      = [];
tempStruct.virtualSmearPixels     = [];
tempStruct.blackPixels            = [];
tempStruct.maskedBlackPixels      = [];
tempStruct.virtualBlackPixels     = [];

tempStruct.spacecraftConfigMap    = spacecraftConfigMap;


tempStruct.requantTables          = requantTables;
tempStruct.huffmanTables          = huffmanTables;

firstInvocation = 0;
lastInvocation = ceil((imageRowEnd - imageRowStart + 1)/nRowsPerInvocation);

for invocation = firstInvocation:lastInvocation

    inputsStruct = tempStruct;

    if(invocation == firstInvocation)

        inputsStruct.firstCall = true;

        % perform mSmear spatial coadds across rows and deal
        % add fixed offset
        mSmearValues = sum(data(mSmearRows,mSmearColumns),1) + fixedOffset;

        % gaps in FFI are represented as NaNs
        mSmearGaps = isnan(mSmearValues);

        mSmearValuesCellArray = num2cell(mSmearValues);

        % save mSmear columns as 0-based index
        mSmearColumnsCellArray = num2cell(mSmearColumns - 1);

        mSmearGapIndicatorsCellArray = num2cell(mSmearGaps);
        tempNew = [];
        [tempNew(1:length(mSmearValuesCellArray)).values] = ...
            deal(mSmearValuesCellArray{:});
        [tempNew(1:length(mSmearColumnsCellArray)).column] = ...
            deal(mSmearColumnsCellArray{:});
        [tempNew(1:length(mSmearGapIndicatorsCellArray)).gapIndicators] = ...
            deal(mSmearGapIndicatorsCellArray{:});
        inputsStruct.maskedSmearPixels = tempNew;

        % perform vSmear spatial coadds across rows and deal
        % add fixed offset
        vSmearValues = sum(data(vSmearRows,vSmearColumns),1) + fixedOffset;

        % gaps in FFI are represented as NaNs
        vSmearGaps = isnan(vSmearValues);

        vSmearValuesCellArray = num2cell(vSmearValues);

        % save vSmear columns as 0-based index
        vSmearColumnsCellArray = num2cell(vSmearColumns - 1);

        vSmearGapIndicatorsCellArray = num2cell(vSmearGaps);
        tempNew = [];
        [tempNew(1:length(vSmearValuesCellArray)).values] = ...
            deal(vSmearValuesCellArray{:});
        [tempNew(1:length(vSmearColumnsCellArray)).column] = ...
            deal(vSmearColumnsCellArray{:});
        [tempNew(1:length(vSmearGapIndicatorsCellArray)).gapIndicators] = ...
            deal(vSmearGapIndicatorsCellArray{:});
        inputsStruct.virtualSmearPixels = tempNew;

        % perform black spatial coadds across columns and deal
        % add fixed offset
        blackValues = sum(data(blackRows,blackColumns),2) + fixedOffset;

        % gaps in FFI are represented as NaNs
        blackGaps = isnan(blackValues);

        blackValuesCellArray = num2cell(blackValues);

        % save black rows as 0-based index
        blackRowsCellArray = num2cell(blackRows - 1);

        blackGapIndicatorsCellArray = num2cell(blackGaps);

        tempNew = [];
        [tempNew(1:length(blackValuesCellArray)).values] = ...
            deal(blackValuesCellArray{:});
        [tempNew(1:length(blackRowsCellArray)).row] = ...
            deal(blackRowsCellArray{:});
        [tempNew(1:length(blackGapIndicatorsCellArray)).gapIndicators] = ...
            deal(blackGapIndicatorsCellArray{:});
        inputsStruct.blackPixels = tempNew;

        % masked black and virtual black are empty for LC

    else

        dataRows = imageRows((invocation - 1)*nRowsPerInvocation + 1:min(invocation*nRowsPerInvocation,length(imageRows)));
        dataCols = imageCols;

        % add fixed offset
        values = data(dataRows,dataCols)';
        values = values(:) + fixedOffset;

        rows = repmat(dataRows(:)',length(dataCols),1);
        rows = rows(:);
        cols = repmat(dataCols(:),1,length(dataRows));
        cols = cols(:);

        % gaps in FFI are represented as NaNs
        gaps = isnan(values);

        valuesCellArray = num2cell(values);

        % save rows and columns as 0-based indices
        rowsCellArray = num2cell(rows - 1);
        colsCellArray = num2cell(cols - 1);

        gapIndicatorsCellArray = num2cell(gaps);

        tempNew = [];
        [tempNew(1:length(valuesCellArray)).values] = ...
            deal(valuesCellArray{:});
        [tempNew(1:length(rowsCellArray)).row] = ...
            deal(rowsCellArray{:});
        [tempNew(1:length(colsCellArray)).column] = ...
            deal(colsCellArray{:});
        [tempNew(1:length(gapIndicatorsCellArray)).gapIndicators] = ...
            deal(gapIndicatorsCellArray{:});
        inputsStruct.targetAndBkgPixels = tempNew;
    end

    if(invocation == lastInvocation)
        inputsStruct.lastCall = true;
    end

    % save the inputsStruct out to a local file
    filename = [calInputFilePrefix,'-',num2str(invocation),'.mat'];
    save(filename,'inputsStruct');
end

