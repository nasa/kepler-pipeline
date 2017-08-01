function collect_collateral_for_validation(dataTypeString, cadenceTypeString, ...
    dataDir, figurePath, taskfileMap, savePixelDataFlag, channelArray)
%
% function to collect collateral data for the input channel array
%
% Collateral data include:
%   (1) black residuals (black-corrected black)
%   (2) the calibrated masked smear
%   (3) the calibrated virtual smear pixels
%
% This data will be used to create plots/images for the DAWG data review.
%
% The black-corrected black pixels should have values close to zero if the
% CAL black correction is working correctly, and the smear difference should
% have values close to the dark level (very small DN).  All pixel values
% will be normalized by the number of exposures for direct comparison among
% LC and SC data.
%
%
% INPUTS:
%
%
%   quarterString     [string] quarter of data ('Q0', 'Q1', ...)
%   monthString       [string] month of data ('M1', 'M2, ...)
%   cadenceTypeString [string] cadence type  ('long', 'short', or 'ffi')
%   dataTypeString    [string] data type     ('flight' or 'etem')
%   dataDir           [string] run directory with data/taskfiles
%   figurePath        [string] pathname of directory to save matfiles/figures
%   taskfileMap       [string]  name of taskfile map (.csv file)
%   savePixelDataFlag [logical] flag to save data from the individual mod/outs
%   channelArray      [array]  array of select channels to create figures
%                              if empty, include all channels in dataDir
%
% OUTPUTS (saved in figurePath):
%
% The following 2D arrays are saved:
%
%      (1) (cadenceType)Cad_medAndStdBlackCorrection.mat with
%
%           medBlackAcrossRows
%           medBlackAcrossTime
%           stdBlackAcrossRows
%           stdBlackAcrossTime
%           channelList
%           rowsAndColumnsStruct
%
%
%      (2) (cadenceType)Cad_medAndStdSmearCorrection.mat with
%
%           medMsmearAcrossCols
%           medMsmearAcrossTime
%           medVsmearAcrossCols
%           medVsmearAcrossTime
%           stdMsmearAcrossCols
%           stdMsmearAcrossTime
%           stdVsmearAcrossCols
%           stdVsmearAcrossTime
%           channelList
%           rowsAndColumnsStruct
%
%     (3) (cadenceType)Cad_full3DArrays.mat
%
%           allBlackResidualsArray
%           allSmearResidualsArray
%           channelList
%           rowsAndColumnsStruct
%
%
%  If savePixelDataFlag = true, the individual black/smear data is saved for
%  each mod/out:
%
%     (1)  (cadenceType)Cad_CalibratedBlackPixels_(ccdChannel).mat with
%           blackPixels
%           blackGaps
%           blackRows
%           blackCommonRows
%
%
%     (2) (cadenceType)Cad_CalibratedSmearPixels_(ccdChannel).mat with
%           mSmearPixels
%           vSmearPixels
%           mSmearGaps
%           vSmearGaps
%           mSmearCols
%           vSmearCols
%           commonColumns
%           mSmearOutputCols
%           vSmearOutputCols
%           commonOutputCols
%--------------------------------------------------------------------------
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

% collect data in separate path
dataPath  = [figurePath 'collateral_data/'];
mkdir(dataPath)

% determine available channels
if strcmpi(dataTypeString, 'flight')
    
    [channelList, summaryStruct] = ...
        get_channels_from_taskfile_dir(taskfileMap, 'cal', dataDir); %#ok<*ASGLU>
    
    availableTaskFileDirs = {summaryStruct.taskfileDirName}';
    
elseif strcmpi(dataTypeString, 'etem')
    
    channelList = channelArray;  %#ok<*NASGU>
end


numCcdRows     = 1070;
numCcdCols     = 1132;
numAllChannels = 84;

rowsAndColumnsStruct = repmat(struct('ccdChannel', [], 'blackRows', [], ...
    'mSmearCols', [], 'vSmearCols', [], 'commonCols', [], 'blackOutputRows', [], ...
    'mSmearOutputCols', [], 'vSmearOutputCols', [], 'commonOutputCols', []), numAllChannels, 1);


for thisChannel = 1:numAllChannels
    
    
    if strcmpi(dataTypeString, 'flight')
        
        taskFilenames = get_taskfiles_from_modout(taskfileMap, 'cal', thisChannel, dataDir);
        
        validTaskFilenames = intersect(taskFilenames, availableTaskFileDirs);
        
        if isempty(validTaskFilenames)
            display(['No available data for Channel ' num2str(thisChannel)])
            continue;
        end
        
        % take only one invocation per channel for sc data
        numInvocations = length(validTaskFilenames);
        
        % start with first invocation
        taskFilename = [dataDir validTaskFilenames{1}];
        
    elseif strcmpi(dataTypeString, 'etem')
        
        % only one taskfile is available for etem
        taskFiles = dir([dataDir 'cal*']);
        
        taskFilename = [dataDir taskFiles.name];
        numInvocations = 1;
    end
    
    
    
    % check for input files
    if ~exist([ taskFilename '/st-0/cal-inputs-0.mat'], 'file') || ...
            ~exist([ taskFilename '/st-1/cal-inputs-0.mat'], 'file') || ...
            ~exist([ taskFilename '/st-0/cal-outputs-0.mat'], 'file') || ...
            ~exist([ taskFilename '/st-1/cal-outputs-0.mat'], 'file')
        
        continue
    end
    
    display(['Keeping invocation 1 of ' num2str(numInvocations) ' for Channel ' num2str(thisChannel)])
    
    
    
    %------------------------------------------------------------------
    % load collateral inputs
    %------------------------------------------------------------------
    display(['Loading collateral input data for CCD Channel ' num2str(thisChannel)]);
    load([taskFilename '/st-0/cal-inputs-0.mat']);
    
    % double check the mod/out
    ccdModule = inputsStruct.ccdModule;
    ccdOutput = inputsStruct.ccdOutput;
    
    ccdChannel = convert_from_module_output(ccdModule, ccdOutput);
    
    if ~isequal(thisChannel, ccdChannel)
        display(['Channels are inconsistent: This Channel= ' num2str(thisChannel)  ' and CCD Channel ' num2str(ccdChannel)]);
    end
    
    
    % extract the number of exposures for normalization
    configMapObject = configMapClass(inputsStruct.spacecraftConfigMap);
    
    if strcmpi(cadenceTypeString, 'long')
        numExposures = get_number_of_exposures_per_long_cadence_period(configMapObject);
    elseif strcmpi(cadenceTypeString, 'short')
        numExposures = get_number_of_exposures_per_short_cadence_period(configMapObject);
    end
    
    numExposures = numExposures(1);
    
    
    % get gain for this mod/out
    gainModel  = inputsStruct.gainModel;
    gainObject = gainClass(gainModel);
    gain = get_gain(gainObject, inputsStruct.cadenceTimes.midTimestamps(1), ccdModule, ccdOutput);
    
    % extract number of cadences
    [numCadences numBlackRows] = size([inputsStruct.blackPixels.values]); %#ok<NASGU>
    
    
    % collect rows and common columns from inputs
    
    blackRows  = [inputsStruct.blackPixels.row]' + 1;
    mSmearCols = [inputsStruct.maskedSmearPixels.column]' + 1;
    vSmearCols = [inputsStruct.virtualSmearPixels.column]' + 1;
    
    commonCols = [mSmearCols(:); vSmearCols(:)];
    commonCols = unique(commonCols);
    
    rowsAndColumnsStruct(thisChannel).ccdChannel = ccdChannel;
    rowsAndColumnsStruct(thisChannel).blackRows  = blackRows;
    rowsAndColumnsStruct(thisChannel).mSmearCols = mSmearCols;
    rowsAndColumnsStruct(thisChannel).vSmearCols = vSmearCols;
    rowsAndColumnsStruct(thisChannel).commonCols = commonCols;
    
    
    fcConstants = inputsStruct.fcConstants;
    
    chargeInjectionRowStart = fcConstants.CHARGE_INJECTION_ROW_START;   % 1059 in 1-based
    ccdEndRow               = fcConstants.CCD_ROWS;                     % 1070 in 1-based
    
    chargeInjectionRows = chargeInjectionRowStart:ccdEndRow;
    
    clear inputsStruct
    
    % extract number of valid pixels
    %numBlackInputRows  = length(blackRows);
    numMsmearInputCols = length(mSmearCols);
    numVsmearInputCols = length(vSmearCols);
    %numCommonInputCols = length(commonCols);
    
    
    %------------------------------------------------------------------
    % load collateral outputs
    %------------------------------------------------------------------
    display(['Loading collateral output data for CCD Channel ' num2str(thisChannel)]);
    
    load([taskFilename '/st-0/cal-outputs-0.mat']);
    
    
    % allocate arrays to collect median and std values across time and across cadences
    if thisChannel == 1
        %------------------------------------------------------------------
        % allocate memory for med/std black corrected black pixels
        %------------------------------------------------------------------
        medBlackAcrossRows = nan(numAllChannels, numCadences);
        medBlackAcrossTime = nan(numAllChannels, numCcdRows);
        
        stdBlackAcrossRows = nan(numAllChannels, numCadences);
        stdBlackAcrossTime = nan(numAllChannels, numCcdRows);
        
        
        %------------------------------------------------------------------
        % allocate memory for med/std black corrected masked smear pixels
        %------------------------------------------------------------------
        medMsmearAcrossCols = nan(numAllChannels, numCadences);
        medMsmearAcrossTime = nan(numAllChannels, numCcdCols);
        
        stdMsmearAcrossCols = nan(numAllChannels, numCadences);
        stdMsmearAcrossTime = nan(numAllChannels, numCcdCols);
        
        
        %------------------------------------------------------------------
        % allocate memory for med/std black corrected virtual smear pixels
        %------------------------------------------------------------------
        medVsmearAcrossCols = nan(numAllChannels, numCadences);
        medVsmearAcrossTime = nan(numAllChannels, numCcdCols);
        
        stdVsmearAcrossCols = nan(numAllChannels, numCadences);
        stdVsmearAcrossTime = nan(numAllChannels, numCcdCols);
        
        
        %------------------------------------------------------------------
        % allocate memory for med/std black corrected smear *difference*
        %------------------------------------------------------------------
        medSmearDiffAcrossCols = nan(numAllChannels, numCadences);
        medSmearDiffAcrossTime = nan(numAllChannels, numCcdCols);
        
        stdSmearDiffAcrossCols = nan(numAllChannels, numCadences);
        stdSmearDiffAcrossTime = nan(numAllChannels, numCcdCols);
        
        %------------------------------------------------------------------
        % allocate memory to collect all black residuals into on array of
        % size numCadences x numRows x numAllChannels
        %------------------------------------------------------------------
        allBlackResidualsArray = nan(numCcdRows, numCadences, numAllChannels);
        
        %------------------------------------------------------------------
        % allocate memory to collect all m-v residuals into on array of
        % size numCadences x numRows x numAllChannels
        %------------------------------------------------------------------
        allSmearResidualsArray = nan(numCcdCols, numCadences, numAllChannels);
    end
    
    
    %--------------------------------------------------------------
    % collect VALID black pixels, gaps, and rows
    %--------------------------------------------------------------
    
    blackPixels = [outputsStruct.calibratedCollateralPixels.blackResidual.values]; % numCadences x numPixels
    
    % normalize with number of exposures per cadence
    blackPixels = blackPixels/numExposures;
    
    blackGaps = [outputsStruct.calibratedCollateralPixels.blackResidual.gapIndicators]; % numCadences x numPixels
    
    % set gaps to NaNs for plotting purposes
    blackPixels(blackGaps) = nan;
    
    blackOutputRows = [outputsStruct.calibratedCollateralPixels.blackResidual.row]+1;
    
    % set charge injection rows to NaNs for plotting purposes
    isInChargeInjection = intersect(chargeInjectionRows, blackOutputRows);
    blackPixels(:, ismember(blackOutputRows, isInChargeInjection)) = nan;
    
    
    numBlackOutputRows = length(blackOutputRows);
    
    rowsAndColumnsStruct(thisChannel).blackOutputRows = blackOutputRows;
    
    
    % save black pixels for 3D plots
    % allBlackResidualsArray = nan(numCcdRows, numCadences, numAllChannels);
    allBlackResidualsArray(blackOutputRows, :, thisChannel) = blackPixels';
    
    
    %--------------------------------------------------------------
    % collect VALID smear pixels, gaps, and columns
    %--------------------------------------------------------------
    
    mSmearPixels = [outputsStruct.calibratedCollateralPixels.maskedSmear.values]; % numCadences x numPixels
    vSmearPixels = [outputsStruct.calibratedCollateralPixels.virtualSmear.values];% numCadences x numPixels
    
    mSmearGaps = [outputsStruct.calibratedCollateralPixels.maskedSmear.gapIndicators]; % numCadences x numPixels
    vSmearGaps = [outputsStruct.calibratedCollateralPixels.virtualSmear.gapIndicators]; % numCadences x numPixels
    
    mSmearPixels(mSmearGaps) = nan;
    vSmearPixels(vSmearGaps) = nan;
    
    % check for new gapped columns
    mSmearOutputCols = [outputsStruct.calibratedCollateralPixels.maskedSmear.column]+1;
    vSmearOutputCols = [outputsStruct.calibratedCollateralPixels.virtualSmear.column]+1;
    commonOutputCols = intersect(mSmearOutputCols, vSmearOutputCols);
    
    rowsAndColumnsStruct(thisChannel).mSmearOutputCols = mSmearOutputCols(:);
    rowsAndColumnsStruct(thisChannel).vSmearOutputCols = vSmearOutputCols(:);
    rowsAndColumnsStruct(thisChannel).commonOutputCols = commonOutputCols(:);
    
    numMsmearOutputCols = length(mSmearOutputCols);
    numVsmearOutputCols = length(vSmearOutputCols);
    numCommonOutputCols = length(commonOutputCols);
    
    clear outputsStruct
    
    if numMsmearOutputCols < numMsmearInputCols
        
        % adjust the virtual smear array to match the common cols
        idxToRemove = find(ismember(vSmearOutputCols, setxor(mSmearCols, mSmearOutputCols)));
        
        vSmearPixels(:, idxToRemove) = [];
        vSmearGaps(:, idxToRemove) = [];
    end
    
    if numVsmearOutputCols < numVsmearInputCols
        
        % adjust the masked smear array to match the common cols
        idxToRemove = find(ismember(mSmearOutputCols, setxor(vSmearCols, vSmearOutputCols)));
        
        mSmearPixels(:, idxToRemove) = [];
        mSmearGaps(:, idxToRemove) = [];
    end
    
    
    % normalize with number of exposures per cadence
    mSmearPixels = mSmearPixels/numExposures/gain;
    vSmearPixels = vSmearPixels/numExposures/gain;
    
    
    % save masked-minus-virtual smear for 3D plots
    % allSmearResidualsArray = nan(numCcdCols, numCadences, numAllChannels);
    allSmearResidualsArray(commonOutputCols, :, thisChannel) = mSmearPixels' - vSmearPixels';
    
    
    if savePixelDataFlag && any(ismember(channelArray, thisChannel))
        eval(['save ' dataPath, 'calibBlackPixels_ch' num2str(thisChannel) '.mat blackPixels blackGaps blackRows blackOutputRows'])
        eval(['save ' dataPath, 'calibSmearPixels_ch' num2str(thisChannel) '.mat mSmearPixels vSmearPixels mSmearGaps vSmearGaps mSmearCols vSmearCols commonCols mSmearOutputCols vSmearOutputCols commonOutputCols'])
        
        display(['Saving black and smear pixel data for CCD channel '  num2str(thisChannel) ])
    end
    
    
    %--------------------------------------------------------------
    % collect black data: loop over rows and cadences
    %--------------------------------------------------------------
    
    % loop over rows and take median/std across time
    for rowIndex = 1:numBlackOutputRows
        
        validPixels = blackPixels(:, rowIndex);
        validGaps   = blackGaps(:, rowIndex);
        
        if any(validPixels(~validGaps))
            
            medianValueForRow = nanmedian(validPixels(~validGaps));
            
            stdValueForRow    = nanstd(validPixels(~validGaps));
            
            medBlackAcrossTime(thisChannel, blackOutputRows(rowIndex)) = medianValueForRow;
            stdBlackAcrossTime(thisChannel, blackOutputRows(rowIndex)) = stdValueForRow;
        end
    end
    
    
    % loop over cadences and take median/std across rows
    for cadenceIndex = 1:numCadences
        
        validPixels = blackPixels(cadenceIndex, :);
        validGaps   = blackGaps(cadenceIndex, :);
        
        if any(validPixels(~validGaps))
            
            medianValueForCadence = nanmedian(validPixels(~validGaps));
            
            stdValueForCadence    = nanstd(validPixels(~validGaps));
            
            medBlackAcrossRows(thisChannel, cadenceIndex) = medianValueForCadence;
            stdBlackAcrossRows(thisChannel, cadenceIndex) = stdValueForCadence;
        end
    end
    
    
    %--------------------------------------------------------------
    % collect smear data: loop over columns and cadences
    %--------------------------------------------------------------
    
    % loop over cols and take median/std across time
    for colIndex = 1:numCommonOutputCols
        
        validMsmearPixels = mSmearPixels(:, colIndex); % numCadences x 1
        validMsmearGaps   = mSmearGaps(:, colIndex);   % numCadences x 1
        validVsmearPixels = vSmearPixels(:, colIndex); % numCadences x 1
        validVsmearGaps   = vSmearGaps(:, colIndex);   % numCadences x 1
        
        if any(validMsmearPixels(~validMsmearGaps))
            
            medianMsmearValueForCol = nanmedian(validMsmearPixels);
            stdMsmearValueForCol    = nanstd(validMsmearPixels);
            
            % save to output
            medMsmearAcrossTime(thisChannel, commonOutputCols(colIndex)) = medianMsmearValueForCol;
            stdMsmearAcrossTime(thisChannel, commonOutputCols(colIndex)) = stdMsmearValueForCol;
        end
        
        if any(validVsmearPixels(~validVsmearGaps))
            
            medianVsmearValueForCol = nanmedian(validVsmearPixels);
            stdVsmearValueForCol    = nanstd(validVsmearPixels);
            
            % save to output
            medVsmearAcrossTime(thisChannel, commonOutputCols(colIndex)) = medianVsmearValueForCol;
            stdVsmearAcrossTime(thisChannel, commonOutputCols(colIndex)) = stdVsmearValueForCol;
        end
        
        if any(validMsmearPixels(~validMsmearGaps)) & any(validVsmearPixels(~validVsmearGaps)) %#ok<AND2>
            
            commonGaps = validMsmearGaps | validVsmearGaps;
            
            medianMsmearMinusVsmearForCol = nanmedian(validMsmearPixels(~commonGaps) - validVsmearPixels(~commonGaps));
            stdMsmearMinusVsmearForCol    = nanstd(validMsmearPixels(~commonGaps) - validVsmearPixels(~commonGaps));
            
            % save to output
            medSmearDiffAcrossTime(thisChannel, commonOutputCols(colIndex)) = medianMsmearMinusVsmearForCol;
            stdSmearDiffAcrossTime(thisChannel, commonOutputCols(colIndex)) = stdMsmearMinusVsmearForCol;
        end
    end
    
    
    % loop over cadences and take median/std across rows
    for cadenceIndex = 1:numCadences
        
        validMsmearPixels = mSmearPixels(cadenceIndex, :); % 1xnumMsmearOutputCols
        validMsmearGaps   = mSmearGaps(cadenceIndex, :);   % 1xnumMsmearOutputCols
        validVsmearPixels = vSmearPixels(cadenceIndex, :); % 1xnumVsmearOutputCols
        validVsmearGaps   = vSmearGaps(cadenceIndex, :);   % 1xnumVsmearOutputCols
        
        if any(validMsmearPixels(~validMsmearGaps))
            
            medianMsmearValueForCadence = nanmedian(validMsmearPixels);
            stdMsmearValueForCadence    = nanstd(validMsmearPixels);
            
            % save to output
            medMsmearAcrossCols(thisChannel, cadenceIndex) = medianMsmearValueForCadence;
            stdMsmearAcrossCols(thisChannel, cadenceIndex) = stdMsmearValueForCadence;
        end
        
        if any(validVsmearPixels(~validVsmearGaps))
            
            medianVsmearValueForCadence = nanmedian(validVsmearPixels);
            stdVsmearValueForCadence    = nanstd(validVsmearPixels);
            
            % save to output
            medVsmearAcrossCols(thisChannel, cadenceIndex) = medianVsmearValueForCadence;
            stdVsmearAcrossCols(thisChannel, cadenceIndex) = stdVsmearValueForCadence;
        end
        
        if any(validMsmearPixels(~validMsmearGaps)) & any(validVsmearPixels(~validVsmearGaps)) %#ok<AND2>
            
            commonGaps = validMsmearGaps | validVsmearGaps;
            
            medianMsmearMinusVsmearForCadence = nanmedian(validMsmearPixels(~commonGaps) - validVsmearPixels(~commonGaps));
            stdMsmearMinusVsmearForCadence    = nanstd(validMsmearPixels(~commonGaps) - validVsmearPixels(~commonGaps));
            
            % save to output
            medSmearDiffAcrossCols(thisChannel, cadenceIndex) = medianMsmearMinusVsmearForCadence;
            stdSmearDiffAcrossCols(thisChannel, cadenceIndex) = stdMsmearMinusVsmearForCadence;
        end
    end
    
    display(['Collateral data collection complete for CCD Channel ' num2str(thisChannel)]);
    display(' ')
    
    %--------------------------------------------------------------------------
    % save the above black pixel 2D arrays to facilitate later analysis:
    %--------------------------------------------------------------------------
    eval(['save ' dataPath, 'medStdBlackArrays.mat medBlackAcrossRows medBlackAcrossTime stdBlackAcrossRows stdBlackAcrossTime channelList rowsAndColumnsStruct'])
    
    
    %--------------------------------------------------------------------------
    % save the above smear pixel 2D arrays to facilitate later analysis:
    %--------------------------------------------------------------------------
    eval(['save ' dataPath, 'medStdSmearArrays.mat medMsmearAcrossCols medMsmearAcrossTime medVsmearAcrossCols medVsmearAcrossTime stdMsmearAcrossCols stdMsmearAcrossTime stdVsmearAcrossCols stdVsmearAcrossTime medSmearDiffAcrossCols medSmearDiffAcrossTime stdSmearDiffAcrossCols stdSmearDiffAcrossTime channelList rowsAndColumnsStruct'])
end


%--------------------------------------------------------------------------
% save the full numRowsOrCols x numCadences x numAllChannels arrays for black
% and smear
%--------------------------------------------------------------------------
%eval(['save ' dataPath, 'blackAndSmear3DArrays.mat allBlackResidualsArray allSmearResidualsArray channelList rowsAndColumnsStruct'])


return;
