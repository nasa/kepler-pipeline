function calInputStruct = coadd_ffi_collateral_data(calInputStruct)
% function calInputStruct = coadd_ffi_collateral_data(calInputStruct)
%
% This function takes input of a calInputStruct and checks that it is an 'FFI' cadence type. If it is not, the calInputStruct is returned
% unchanged. If it is and this is the first call, the data in twoDCollateral is coadded according to the spacecraft config map over columns
% (black) and rows (masked and virtual smear) and placed in the proper collateral data fields and the total pixel count is updated. If
% outlierThreshold > 0, the outliers are removed and the gaps are filled with the robust mean across rows (for smear) or columns (for
% black). Outliers are identified as those points lying outside outlierThreshold * standard deviation across the row or column. If it is not
% the first call, the total pixel count is updated from the state file. The return structure is the same calInputStruct with these modifications. 
%
% INPUTS:   calInputStruct   = calInputStruct of cadence type 'FFI' with 2D
%                              collateral data under field calInputStruct.twoDCollateral
% OUTPUT:   calInputStruct   = calInputStruct of cadence type 'FFI' with 2D
%                              collateral split into fields:
%                                   calInputStruct.maskedSmearPixels
%                                   calInputStruct.virtualSmearPixels
%                                   calInputStruct.blackPixels
%                             totalPixels is updated after collateral coadds.  
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


% return with processing if not FFI data
if ~strcmpi(calInputStruct.cadenceType,'ffi')
    return;
end

% filenames and variable names
compressionCollateralFilename = [ calInputStruct.localFilenames.stateFilePath, calInputStruct.localFilenames.compRootFilename,'_0.mat'];
totalPixelVariableName = 'nTotalPixelSeries';

tic;
metricsKey = metrics_interval_start;

% extract flags and constants
dynamic2DBlackEnabled   = calInputStruct.dataFlags.dynamic2DBlackEnabled;
nCcdRows                = calInputStruct.fcConstants.CCD_ROWS;
nCcdColumns             = calInputStruct.fcConstants.CCD_COLUMNS;
outlierThreshold        = calInputStruct.moduleParametersStruct.nSigmaForFfiOutlierRejection; 

if outlierThreshold == 0
    removeOutliers = false;
else
    removeOutliers = true;
    outlierThreshold = abs(outlierThreshold);
end

% on first call spatialy coadd collateral data to look like LC data
if calInputStruct.firstCall
    
    % get model timestamp
    twoDBlackMjd = calInputStruct.cadenceTimes.midTimestamps;
    
    % make configmap object    
    CMObject = configMapClass(calInputStruct.spacecraftConfigMap);
    
    % get number of temporal coadds
    nReads = get_number_of_exposures_per_ffi(CMObject);
    
    % get collateral rows and cols (1-based)
    blackRows = get_black_start_row(CMObject):get_black_end_row(CMObject);
    blackColumns = get_black_start_column(CMObject):get_black_end_column(CMObject);
    maskedSmearRows = get_masked_smear_start_row(CMObject):get_masked_smear_end_row(CMObject);
    maskedSmearColumns = get_masked_smear_start_column(CMObject):get_masked_smear_end_column(CMObject);
    virtualSmearRows = get_virtual_smear_start_row(CMObject):get_virtual_smear_end_row(CMObject);
    virtualSmearColumns = get_virtual_smear_start_column(CMObject):get_virtual_smear_end_column(CMObject);    
    
    if ~dynamic2DBlackEnabled
        % extract static two-d black
        twoDBlackObject = twoDBlackClass(calInputStruct.twoDBlackModel);
        M = get_two_d_black(twoDBlackObject, twoDBlackMjd);
    else
        % extract dynamic two-d black and make nCcdRows x nCcdColumns array
        initializedModels = calInputStruct.dynoblackModels;
        M = retrieve_dynamic_2d_black(initializedModels, 1:nCcdRows, 1:nCcdColumns, twoDBlackMjd, 2 );
        M = reshape(M, nCcdRows, nCcdColumns);
    end
    
    % get 2dblack in regions of interest    
    black2Dblack = nReads .* M(blackRows, blackColumns);
    mSmear2Dblack = nReads .* M(maskedSmearRows, maskedSmearColumns);
    vSmear2Dblack = nReads .* M(virtualSmearRows, virtualSmearColumns);
        
    % extract collateral data as 2D arrays
    blackValues = [calInputStruct.twoDCollateral.blackStruct.pixels.array];
    blackGaps = [calInputStruct.twoDCollateral.blackStruct.gaps.array];

    maskedSmearValues = [calInputStruct.twoDCollateral.maskedSmearStruct.pixels.array];
    maskedSmearGaps = [calInputStruct.twoDCollateral.maskedSmearStruct.gaps.array];

    virtualSmearValues = [calInputStruct.twoDCollateral.virtualSmearStruct.pixels.array];
    virtualSmearGaps = [calInputStruct.twoDCollateral.virtualSmearStruct.gaps.array];

    % get original collateral pixel count
    originalCollateralPixelCount = numel(blackValues) + numel(maskedSmearValues) + numel(virtualSmearValues);
    
    
    if removeOutliers
        % black outlier removal
        % copy black to temp array and remove 2D black
        tempBlack = blackValues - black2Dblack';

        % find outliers > outlierThreshold across columns
        meanTempBlack = repmat(mean(tempBlack,1),length(blackColumns),1);
        stdTempBlack = repmat(std(tempBlack,1,1),length(blackColumns),1);
        rootVarianceBlack = tempBlack - meanTempBlack;

        outlierLogical = rootVarianceBlack > outlierThreshold.*stdTempBlack;

        % update mean
        newMean = sum(tempBlack .* ~outlierLogical,1) ./ sum(~outlierLogical,1);
        meanTempBlack = repmat(newMean,length(blackColumns),1);

        % replace outliers w/updated mean
        tempBlack(outlierLogical) = meanTempBlack(outlierLogical);

        % add back 2D black and copy temp to black
        blackValues = tempBlack + black2Dblack';
        disp(['CAL:coadd_ffi_collateral_data: Removed ',num2str(length(find(outlierLogical==1))),' outliers in FFI collateral black region']);


        % virtual smear outlier removal
        % copy virtual smear to temp array and remove 2D black
        tempVSmear = virtualSmearValues - vSmear2Dblack';

        % find outliers > outlierThreshold across rows
        meanTempVSmear = repmat(mean(tempVSmear,2),1,length(virtualSmearRows));
        stdTempVSmear = repmat(std(tempVSmear,1,2),1,length(virtualSmearRows));
        rootVarianceVSmear = tempVSmear - meanTempVSmear;

        outlierLogical = rootVarianceVSmear > outlierThreshold.*stdTempVSmear;

        % update mean
        newMean = sum(tempVSmear .* ~outlierLogical,2) ./ sum(~outlierLogical,2);
        meanTempVSmear = repmat(newMean,1,length(virtualSmearRows));

        % replace outliers w/ updated mean
        tempVSmear(outlierLogical) = meanTempVSmear(outlierLogical);

        % add back 2D black and copy temp to virtual smear
        virtualSmearValues = tempVSmear + vSmear2Dblack';
        disp(['CAL:coadd_ffi_collateral_data: Removed ',num2str(length(find(outlierLogical==1))),' outliers in FFI collateral virtual smear region']);
        

        % masked smear outlier removal
        % copy masked smear to temp array and remove 2D black
        tempMSmear = maskedSmearValues - mSmear2Dblack';

        % find outliers > outlierThreshold across rows
        meanTempMSmear = repmat(mean(tempMSmear,2),1,length(maskedSmearRows));
        stdTempMSmear = repmat(std(tempMSmear,1,2),1,length(maskedSmearRows));
        rootVarianceMSmear = tempMSmear - meanTempMSmear;

        outlierLogical = rootVarianceMSmear > outlierThreshold.*stdTempMSmear;

        % update mean
        newMean = sum(tempMSmear .* ~outlierLogical,2) ./ sum(~outlierLogical,2);
        meanTempMSmear = repmat(newMean,1,length(maskedSmearRows));

        % replace outliers w/ updated mean
        tempMSmear(outlierLogical) = meanTempMSmear(outlierLogical);

        % add back 2D black and copy temp to masked smear
        maskedSmearValues = tempMSmear + mSmear2Dblack';
        disp(['CAL:coadd_ffi_collateral_data: Removed ',num2str(length(find(outlierLogical==1))),' outliers in FFI collateral masked smear region']);
    end

    % perform spatial coadds
    blackValues = sum(blackValues,1);
    maskedSmearValues = sum(maskedSmearValues,2);
    virtualSmearValues = sum(virtualSmearValues,2);

    % get modified collateral pixel count
    modifiedCollateralPixelCount = numel(blackValues) + numel(maskedSmearValues) + numel(virtualSmearValues);

    % update pixel count in input struct
    calInputStruct.totalPixels = calInputStruct.totalPixels - originalCollateralPixelCount + modifiedCollateralPixelCount;

    % set gapIndicators
    blackGaps = any(blackGaps,1);
    maskedSmearGaps = any(maskedSmearGaps,2);
    virtualSmearGaps= any(virtualSmearGaps,2);

    % assign 0-based rows or columns for coadded collateral data  
    blackRows = blackRows - 1;
    maskedSmearColumns = maskedSmearColumns - 1;
    virtualSmearColumns = virtualSmearColumns - 1;

    % deal blackPixels into inputStruct
    blackValuesCellArray = num2cell(blackValues);
    blackGapIndicatorsCellArray = num2cell(blackGaps);
    blackRowsCellArray = num2cell(blackRows);

    tempNew = [];
    [tempNew(1:length(blackRowsCellArray)).row] = deal(blackRowsCellArray{:});
    [tempNew(1:length(blackValuesCellArray)).values] = deal(blackValuesCellArray{:});
    [tempNew(1:length(blackGapIndicatorsCellArray)).gapIndicators] = deal(blackGapIndicatorsCellArray{:});

    calInputStruct.blackPixels = tempNew;

    % deal maskedSmearPixels into inputStruct
    maskedSmearValuesCellArray = num2cell(maskedSmearValues);
    maskedSmearGapIndicatorsCellArray = num2cell(maskedSmearGaps);
    maskedSmearRowsCellArray = num2cell(maskedSmearColumns);

    tempNew = [];
    [tempNew(1:length(maskedSmearRowsCellArray)).column] = deal(maskedSmearRowsCellArray{:});
    [tempNew(1:length(maskedSmearValuesCellArray)).values] = deal(maskedSmearValuesCellArray{:});
    [tempNew(1:length(maskedSmearGapIndicatorsCellArray)).gapIndicators] = deal(maskedSmearGapIndicatorsCellArray{:});

    calInputStruct.maskedSmearPixels = tempNew;

    % deal virtualSmearPixels into inputStruct
    virtualSmearValuesCellArray = num2cell(virtualSmearValues);
    virtualSmearGapIndicatorsCellArray = num2cell(virtualSmearGaps);
    virtualSmearRowsCellArray = num2cell(virtualSmearColumns);

    tempNew = [];
    [tempNew(1:length(virtualSmearRowsCellArray)).column] = deal(virtualSmearRowsCellArray{:});
    [tempNew(1:length(virtualSmearValuesCellArray)).values] = deal(virtualSmearValuesCellArray{:});
    [tempNew(1:length(virtualSmearGapIndicatorsCellArray)).gapIndicators] = deal(virtualSmearGapIndicatorsCellArray{:});

    calInputStruct.virtualSmearPixels = tempNew;

    % maskedBlack and virtualBlack set to zero for FFI as in LC
    
    % update data flags
    calInputStruct.dataFlags.isAvailableBlackPix         = true;
    calInputStruct.dataFlags.isAvailableMaskedSmearPix   = true;
    calInputStruct.dataFlags.isAvailableVirtualSmearPix  = true;  
    
else
    % otherwise update total pixels and make raw image
    
    % update totalPixels from state file
    load(compressionCollateralFilename, totalPixelVariableName);    
    calInputStruct.totalPixels = eval(totalPixelVariableName);
    
    % create raw full frame image
    tic;
    create_original_ffi_image(calInputStruct);
    display_cal_status('CAL:cal_matlab_controller: FFI image created from CAL inputs', 1);  
end

metrics_interval_stop('cal.coadd_ffi_collateral_data.execTimeMillis',metricsKey);
