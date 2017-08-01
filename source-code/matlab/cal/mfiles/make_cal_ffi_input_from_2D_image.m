function result = make_cal_ffi_input_from_2D_image(data,varargin)
% function result = make_cal_ffi_input_from_2D_image(data, varargin)
%
% This function takes input of a full frame image as a 2D array and creates
% the corresponding calInputStructs in 'FFI' cadence format. The resulting
% calInputStructs are written out to MATLAB .mat files in standard format
% (filename = 'cal-inputs(#).mat', contain one variable, 'inputsStruct').
%
% INPUTS:   data            = 2D full frame image
%           (optional)
%           mod             = 
%           out             = 
%           mjd             = 
% OUTPUT:   result          = dummy
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

% set dummy return
result = true;

% set default parameters
ccdModule = 7;
ccdOutput = 3;
mjd       = datestr2mjd(now);

calInputFilePrefix  = 'cal-inputs';
nRowsPerInvocation = 1070;

if nargin > 1
    ccdModule = varargin{1};
    if nargin > 2
        ccdOutput = varargin{2};
        if nargin > 3
            mjd = varargin{3};
        end
    end
end


% set start, end and mid timetags to same value
startMjd = mjd;
midMjd = mjd;
endMjd = mjd;

% set up module parameters
moduleParametersStruct.debugEnabled                         = false;
moduleParametersStruct.linearityCorrectionEnabled           = true;
moduleParametersStruct.undershootEnabled                    = true;
moduleParametersStruct.crCorrectionEnabled                  = true;
moduleParametersStruct.flatFieldCorrectionEnabled           = true;
moduleParametersStruct.falseRejectionRate                   = 1.0000e-04;
moduleParametersStruct.polyOrderMax                         = 10;
moduleParametersStruct.madSigmaThresholdForBleedingColumns  = 15;
moduleParametersStruct.madSigmaThresholdForSmearLevels      = 3.5000;
moduleParametersStruct.undershootReverseFitPolyOrder        = 1;
moduleParametersStruct.undershootReverseFitWindow           = 10;

% set up pou default parameters
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

% construct cadenceTimes struct - this should contain a single cadence
% timestamp of each type: start, mid, end
cadenceTimes.startTimestamps    = startMjd;
cadenceTimes.midTimestamps      = midMjd;
cadenceTimes.endTimestamps      = endMjd;
cadenceTimes.gapIndicators      = false(size(cadenceTimes.midTimestamps));
cadenceTimes.requantEnabled     = false(size(cadenceTimes.midTimestamps));
cadenceTimes.cadenceNumbers     = (0:length(cadenceTimes.midTimestamps)-1)';

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

% set up generic CAL inputsStruct
tempStruct  = [];

tempStruct.version        = 'CalInputs Version 1';
tempStruct.debugLevel     = 0;
tempStruct.firstCall      = 0;
tempStruct.lastCall       = 0;
tempStruct.totalPixels    = length(blackRows)*length(blackColumns) + ...
                            length(mSmearRows)*length(mSmearColumns) + ...
                            length(vSmearRows)*length(vSmearColumns) + ...
                            (imageRowEnd - imageRowStart + 1)*(imageColEnd - imageColStart + 1);
tempStruct.cadenceType    = 'FFI';
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
tempStruct.requantTables          = [];
tempStruct.huffmanTables          = [];

tempStruct.twoDCollateral.blackStruct           = [];
tempStruct.twoDCollateral.virtualSmearStruct    = [];
tempStruct.twoDCollateral.maskedSmearStruct     = [];


fixedOffset = 0;
firstInvocation = 0;
lastInvocation = ceil((imageRowEnd - imageRowStart + 1)/nRowsPerInvocation);

for invocation = firstInvocation:lastInvocation
    
    inputsStruct = tempStruct;
    
    if(invocation == firstInvocation)
        
        inputsStruct.firstCall = true;
                
        % store black
        tempNew = [];
        tempNew.pixels(length(blackRows)).array = zeros(length(blackColumns),1);
        tempNew.gaps(length(blackRows)).array = false(length(blackColumns),1);
        for r = 1:length(blackRows)
            tempNew.pixels(r).array = data(blackRows(r),blackColumns)' + fixedOffset;
            tempNew.gaps(r).array = isnan(data(blackRows(r),blackColumns))';            
        end         
        inputsStruct.twoDCollateral.blackStruct = tempNew;        
        
        
        % store virtual smear
        tempNew = [];
        tempNew.pixels(length(vSmearRows)).array = zeros(length(vSmearColumns),1);
        tempNew.gaps(length(vSmearRows)).array = false(length(vSmearColumns),1);
        for r = 1:length(vSmearRows)
            tempNew.pixels(r).array = data(vSmearRows(r),vSmearColumns)' + fixedOffset;
            tempNew.gaps(r).array = isnan(data(vSmearRows(r),vSmearColumns))';            
        end        
        inputsStruct.twoDCollateral.virtualSmearStruct = tempNew;        
        
        
        % store masked smear
        tempNew = [];
        tempNew.pixels(length(mSmearRows)).array = zeros(length(mSmearColumns),1);
        tempNew.gaps(length(mSmearRows)).array = false(length(mSmearColumns),1);
        for r = 1:length(mSmearRows)
            tempNew.pixels(r).array = data(mSmearRows(r),mSmearColumns)' + fixedOffset;
            tempNew.gaps(r).array = isnan(data(mSmearRows(r),mSmearColumns))';            
        end
        inputsStruct.twoDCollateral.maskedSmearStruct = tempNew;   
        
        % inputsStruct.(collateralPixelTypes) = [] for cadenceType = 'FFI'
        
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
                
