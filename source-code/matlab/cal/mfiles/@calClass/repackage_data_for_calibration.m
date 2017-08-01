function calIntermediateStruct = repackage_data_for_calibration(calObject)
%function calIntermediateStruct = repackage_data_for_calibration(calObject)
%
% This calClass method repackages data from CAL input structures into (nPixels x nCadences) arrays in order to take advantage of Matlab's
% vectorization and to calibrate pixels efficiently. Depending on the available pixel types for each invocation, the pixel arrays, gap
% arrays, and row/column arrays are created and saved to an intermediate data structure (calIntermediateStruct), which is passed (along with
% the  calObject) into all subsequent CAL functions.
%
% For short cadence, only the smear and black pixels for the projected photometric target row/columns are available, so masked and virtual
% black pixels are needed to calibrate the smear for black level. In order to calibrate and propagate uncertainties with minimal
% book-keeping, we fill in the unavailable row/columns with zeros, and set the corresponding logical gap indicators to true.  The short
% cadence data arrays are saved as sparse arrays.
%
% OUTPUT
%   calIntermediateStruct is a structure comtaining raw pixel data in the following fields:
%
%  (Long and short cadence collateral data)
%
%   blackPixels         % nCcdRows x nCadences
%   blackGaps           % nCcdRows x nCadences
%   blackRows           % nCcdRows x 1
%   mSmearPixels        % nCcdColumns x nCadences
%   mSmearGaps          % nCcdColumns x nCadences
%   mSmearColumns       % nCcdColumns x 1
%   vSmearPixels        % nCcdColumns x nCadences
%   vSmearGaps          % nCcdColumns x nCadences
%   vSmearColumns       % nCcdColumns x 1
%
%  (Short cadence collateral data only)
%
%   mBlackPixels        % nCadences x 1
%   mBlackGaps          % nCadences x 1
%   vBlackPixels        % nCadences x 1
%   vBlackGaps          % nCadences x 1
%
%  (Long and short cadence photometric data)
%
%   photometricPixels      % nPhotometricPixels x nCadences
%   photometricGaps        % nPhotometricPixels x nCadences
%   photometricColumns     % nPhotometricPixels x 1
%   photometricRows        % nPhotometricPixels x 1
%
%  (Missing cadences identified)
%
%   missingBlackCadences        missing cadence numbers
%   missingMblackCadences       missing cadence numbers
%   missingVblackCadences       missing cadence numbers
%   missingMsmearCadences       missing cadence numbers
%   missingVsmearCadences       missing cadence numbers
%   missingPhotometricCadences  missing cadence numbers
%
%  (additional flags, indicators and counters)
%   pouEnabled            logical
%   nCadences             scalar
%   nCcdRows              scalar
%   nCcdColumns           scalar
%   debugLevel            logical
%   dataFlags             struct
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

% extract debug level indicator
debugLevel = calObject.debugLevel;

% extract preset data flags
processLongCadence          = calObject.dataFlags.processLongCadence;
processShortCadence         = calObject.dataFlags.processShortCadence;
processFFI                  = calObject.dataFlags.processFFI;
isAvailableBlackPix         = calObject.dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix   = calObject.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = calObject.dataFlags.isAvailableVirtualBlackPix;
isAvailableMaskedSmearPix   = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix  = calObject.dataFlags.isAvailableVirtualSmearPix;
isAvailableTargetAndBkgPix  = calObject.dataFlags.isAvailableTargetAndBkgPix;
isAvailableFfiPix           = calObject.dataFlags.isAvailableFfiPix;

% extract module parameter flags
pouEnabled  = calObject.pouModuleParametersStruct.pouEnabled;
enableSmearExcludeColumnMap = calObject.moduleParametersStruct.enableSmearExcludeColumnMap;
enableSceneDependentRowMap = calObject.moduleParametersStruct.enableSceneDependentRowMap;
enableBlackCoefficientOverrides = calObject.moduleParametersStruct.enableBlackCoefficientOverrides;

% extract ccd rows and columns from FC constants:
nCcdRows    = calObject.fcConstants.CCD_ROWS;
nCcdColumns = calObject.fcConstants.CCD_COLUMNS;

% get number of cadences and cadence gaps from calObject
cadenceGapIndicators = calObject.cadenceTimes.gapIndicators;
nCadences = length(cadenceGapIndicators);
calIntermediateStruct.cadenceGapIndicators = cadenceGapIndicators;

%--------------------------------------------------------------------------
% construct pixel arrays for all black pixel data
%--------------------------------------------------------------------------
if isAvailableBlackPix

    % allocate memory for full ccd row - use sparse for short cadence
    if processShortCadence
        blackPixels = sparse(nCcdRows, nCadences);
        blackGaps   = true(nCcdRows, nCadences);
        blackRows   = sparse(nCcdRows, 1);
    else
        blackPixels = zeros(nCcdRows, nCadences);
        blackGaps   = sparse(true(nCcdRows, nCadences));
        blackRows   = zeros(nCcdRows, 1);
    end

    % concatenate input pixels, gaps, and row values into arrays
    blackPixels([calObject.blackPixels.row]', :) = [calObject.blackPixels.values]';
    blackGaps([calObject.blackPixels.row]', :)   = [calObject.blackPixels.gapIndicators]';
    blackRows([calObject.blackPixels.row]')      = [calObject.blackPixels.row]';

    % add cadence gaps from cadenceTimes
    blackGaps = blackGaps | repmat(cadenceGapIndicators(:)',size(blackGaps,1),1);
    
    % collect arrays in intermediate struct
    calIntermediateStruct.blackPixels = blackPixels;  % nCcdRows x nCadences
    calIntermediateStruct.blackGaps   = blackGaps;    % nCcdRows x nCadences
    calIntermediateStruct.blackRows   = blackRows;    % nCcdRows x 1

    clear blackPixels blackGaps blackRows
end


if isAvailableMaskedBlackPix

    % concatenate pixels and gaps into arrays, collect arrays in intermediate struct
    mBlackPixels = [calObject.maskedBlackPixels.values];          % nCadences x 1
    mBlackGaps   = [calObject.maskedBlackPixels.gapIndicators];   % nCadences x 1
    
    % add cadence gaps from cadenceTimes
    mBlackGaps = mBlackGaps | cadenceGapIndicators;
    
    % store
    calIntermediateStruct.mBlackPixels = mBlackPixels;
    calIntermediateStruct.mBlackGaps   = mBlackGaps;
end


if isAvailableVirtualBlackPix

    % concatenate pixels and gaps into arrays, collect arrays in intermediate struct
    vBlackPixels = [calObject.virtualBlackPixels.values];          % nCadences x 1
    vBlackGaps   = [calObject.virtualBlackPixels.gapIndicators];   % nCadences x 1
    
    % add cadence gaps from cadenceTimes
    vBlackGaps = vBlackGaps | cadenceGapIndicators;
    
    % store
    calIntermediateStruct.vBlackPixels = vBlackPixels;
    calIntermediateStruct.vBlackGaps   = vBlackGaps;
    
end


%--------------------------------------------------------------------------
% check for missing cadences in black pixel data
%--------------------------------------------------------------------------
if processLongCadence

    if processFFI

        calIntermediateStruct.missingBlackCadences = [];
    else

        if isAvailableBlackPix && ~isempty(calIntermediateStruct.blackGaps)
            
            % 'all' operates on columns, returning a row of logicals
            blackAvailableLogical = ~all(calIntermediateStruct.blackGaps)';                     % nCadences x 1                        
            missingBlackCadences  = find(~blackAvailableLogical);                   

            if ~isempty(missingBlackCadences) && length(missingBlackCadences) < 10      %print only moderately sized arrays to screen
                display(['CAL:repackage_data_for_calibration: Black pixel data is missing',...
                    ' for cadences ' mat2str(missingBlackCadences(:)) ', will be filled with nearest cadence data.']);
            elseif ~isempty(missingBlackCadences) && length(missingBlackCadences) >= 10
                display(['CAL:repackage_data_for_calibration: Black pixel data is missing',...
                    ' for ' num2str(length(missingBlackCadences)) ' cadences, will be filled with nearest cadence data.']);
            end

            calIntermediateStruct.missingBlackCadences = missingBlackCadences;
        end
    end

elseif processShortCadence

    if isAvailableBlackPix && ~isempty(calIntermediateStruct.blackGaps)

        blackAvailableLogical = ~all(calIntermediateStruct.blackGaps)';             % nCadences x 1            
        missingBlackCadences  = find(~blackAvailableLogical);                       % nCadences x 1        

        if ~isempty(missingBlackCadences) && length(missingBlackCadences) < 10          %print only moderately sized arrays to screen
            display(['CAL:repackage_data_for_calibration: Black pixel data is missing',...
                ' for cadences ' mat2str(missingBlackCadences(:)) ', will be filled with nearest cadence data.']);
        elseif ~isempty(missingBlackCadences) && length(missingBlackCadences) >= 10
            display(['CAL:repackage_data_for_calibration: Black pixel data is missing',...
                ' for ' num2str(length(missingBlackCadences)) ' cadences, will be filled with nearest cadence data.'])
        end

        calIntermediateStruct.missingBlackCadences  = missingBlackCadences;
    end

    if isAvailableMaskedBlackPix && ~isempty(calIntermediateStruct.mBlackGaps)

        mBlackAvailableLogical = ~calIntermediateStruct.mBlackGaps(:)';
        missingMblackCadences  = find(~mBlackAvailableLogical);

        if ~isempty(missingMblackCadences) && length(missingMblackCadences) < 10        %print only moderately sized arrays to screen
            display(['CAL:repackage_data_for_calibration: Masked black pixel data',...
                ' is missing for cadences ' mat2str(missingMblackCadences(:)) ', will be filled with nearest cadence data.']);
        elseif ~isempty(missingMblackCadences) && length(missingMblackCadences) >= 10
            display(['CAL:repackage_data_for_calibration: Masked black pixel data',...
                ' is missing for ' num2str(length(missingMblackCadences)) ' cadences, will be filled with nearest cadence data.'])
        end

        calIntermediateStruct.missingMblackCadences = missingMblackCadences;
    end


    if isAvailableVirtualBlackPix && ~isempty(calIntermediateStruct.vBlackGaps)

        vBlackAvailableLogical = ~calIntermediateStruct.vBlackGaps(:)';
        missingVblackCadences  = find(~vBlackAvailableLogical);

        if ~isempty(missingVblackCadences) && length(missingVblackCadences) < 10        %print only moderately sized arrays to screen
            display(['CAL:repackage_data_for_calibration: Virtual black pixel data',...
                ' is missing for cadences ' mat2str(missingVblackCadences(:)) ', will be filled with nearest cadence data.']);
        elseif ~isempty(missingVblackCadences) && length(missingVblackCadences) >= 10
            display(['CAL:repackage_data_for_calibration: Virtual black pixel data',...
                ' is missing for ' num2str(length(missingVblackCadences)) ' cadences, will be filled with nearest cadence data.']);
        end

        calIntermediateStruct.missingVblackCadences = missingVblackCadences;
    end


    if isAvailableBlackPix && isAvailableMaskedBlackPix && isAvailableVirtualBlackPix && ...
            ~isempty(calIntermediateStruct.blackGaps) && ~isempty(calIntermediateStruct.mBlackGaps) &&...
            ~isempty(calIntermediateStruct.vBlackGaps)

        % concatenate all black pixels
        allBlackPixelGaps = cat(1, calIntermediateStruct.blackGaps, calIntermediateStruct.mBlackGaps(:)', calIntermediateStruct.vBlackGaps(:)');
        
        % 'all' operates on columns, returning a row of logicals
        blackAvailableLogical = ~all(allBlackPixelGaps)';               % nCadences x 1
        missingBlackCadences  = find(~blackAvailableLogical);           % nCadences x 1

        if ~isempty(missingBlackCadences) && length(missingBlackCadences) < 10          %print only moderately sized arrays to screen
            display(['CAL:repackage_data_for_calibration: Black, masked black,',...
                ' and virtual black pixel data are all missing for cadences '...
                mat2str(missingBlackCadences(:)) ', will be filled with nearest cadence data.']);
        elseif ~isempty(missingBlackCadences) && length(missingBlackCadences) >= 10
            display(['CAL:repackage_data_for_calibration: Black, masked black,',...
                ' and virtual black pixel data are all missing for '...
                num2str(length(missingBlackCadences)) ' cadences, will be filled with nearest cadence data.']);
        end

        calIntermediateStruct.missingBlackCadences = missingBlackCadences;
    end
end

%--------------------------------------------------------------------------
% construct pixel arrays for all smear pixel data
%--------------------------------------------------------------------------
if isAvailableMaskedSmearPix

    % allocate memory for full ccd column
    if processShortCadence
        mSmearPixels    = sparse(nCcdColumns, nCadences);
        mSmearGaps      = true(nCcdColumns, nCadences);
        mSmearColumns   = sparse(nCcdColumns, 1);
    else
        mSmearPixels    = zeros(nCcdColumns, nCadences);        % nCcdColumns x nCadences
        mSmearGaps      = sparse(true(nCcdColumns, nCadences)); % nCcdColumns x nCadences
        mSmearColumns   = zeros(nCcdColumns, 1);                % nCcdColumns x 1
    end

    % concatenate input pixels, gaps, and row values into arrays
    mSmearPixels([calObject.maskedSmearPixels.column]', :) = [calObject.maskedSmearPixels.values]';
    mSmearGaps([calObject.maskedSmearPixels.column]', :)   = [calObject.maskedSmearPixels.gapIndicators]';
    mSmearColumns([calObject.maskedSmearPixels.column]')   = [calObject.maskedSmearPixels.column]';
    
    % add cadence gaps from cadenceTimes
    mSmearGaps = mSmearGaps | repmat(cadenceGapIndicators(:)',size(mSmearGaps,1),1);

    % collect arrays in intermediate struct
    calIntermediateStruct.mSmearPixels  = mSmearPixels;   % nPixels x nCadences
    calIntermediateStruct.mSmearGaps    = mSmearGaps;     % nPixels x nCadences
    calIntermediateStruct.mSmearColumns = mSmearColumns;  % nPixels x 1

    clear mSmearPixels mSmearGaps mSmearColumns

    %--------------------------------------------------------------------------
    % check for missing cadences in masked smear pixel data
    %--------------------------------------------------------------------------
    if processFFI

        calIntermediateStruct.missingMsmearCadences = [];
    else
        if ~isempty(calIntermediateStruct.mSmearGaps)

            % 'all' operates on columns, returning a row of logicals
            mSmearAvailableLogical = ~all(calIntermediateStruct.mSmearGaps)';                       % nCadences x 1
            missingMsmearCadences  = find(~mSmearAvailableLogical);         % nCadences x 1

            if ~isempty(missingMsmearCadences) && length(missingMsmearCadences) < 10        %print only moderately sized arrays to screen
                display(['CAL:repackage_data_for_calibration: Masked smear pixel data',...
                    ' is missing for cadences ' mat2str(missingMsmearCadences(:))]);
            elseif ~isempty(missingMsmearCadences) && length(missingMsmearCadences) >= 10
                display(['CAL:repackage_data_for_calibration: Masked smear pixel data',...
                    ' is missing for ' num2str(length(missingMsmearCadences)) ' cadences']);
            end

            calIntermediateStruct.missingMsmearCadences  = missingMsmearCadences;
        end
    end
end


if isAvailableVirtualSmearPix

    % allocate memory for full ccd column
    if processShortCadence
        vSmearPixels  = sparse(nCcdColumns, nCadences);
        vSmearGaps    = true(nCcdColumns, nCadences);
        vSmearColumns = sparse(nCcdColumns, 1);
    else
        vSmearPixels  = zeros(nCcdColumns, nCadences);
        vSmearGaps    = sparse(true(nCcdColumns, nCadences));
        vSmearColumns = zeros(nCcdColumns, 1);
    end

    % concatenate input pixels, gaps, and row values into arrays
    vSmearPixels([calObject.virtualSmearPixels.column]', :) = [calObject.virtualSmearPixels.values]';
    vSmearGaps([calObject.virtualSmearPixels.column]', :)   = [calObject.virtualSmearPixels.gapIndicators]';
    vSmearColumns([calObject.virtualSmearPixels.column]')   = [calObject.virtualSmearPixels.column]';
    
    % add cadence gaps from cadenceTimes
    vSmearGaps = vSmearGaps | repmat(cadenceGapIndicators(:)',size(vSmearGaps,1),1);

    % collect arrays in intermediate struct
    calIntermediateStruct.vSmearPixels  = vSmearPixels;   % nPixels x nCadences
    calIntermediateStruct.vSmearGaps    = vSmearGaps;     % nPixels x nCadences
    calIntermediateStruct.vSmearColumns = vSmearColumns;  % nPixels x 1

    clear vSmearPixels vSmearGaps vSmearColumns

    %--------------------------------------------------------------------------
    % check for missing cadences in virtual smear pixel data
    %--------------------------------------------------------------------------
    if processFFI

        calIntermediateStruct.missingVsmearCadences = [];
    else

        if ~isempty(calIntermediateStruct.vSmearGaps)

            % 'all' operates on columns, returning a row of logicals
            vSmearAvailableLogical  = ~all(calIntermediateStruct.vSmearGaps)';                      % nCadences x 1
            missingVsmearCadences   = find(~vSmearAvailableLogical);        % nCadences x 1

            if ~isempty(missingVsmearCadences) && length(missingVsmearCadences) < 10            %print only moderately sized arrays to screen
                display(['CAL:repackage_data_for_calibration: Virtual smear pixel data',...
                    ' is missing for cadences ' mat2str(missingVsmearCadences(:))]);
            elseif ~isempty(missingVsmearCadences) && length(missingVsmearCadences) >= 10
                display(['CAL:repackage_data_for_calibration: Virtual smear pixel data',...
                    ' is missing for ' num2str(length(missingVsmearCadences)) ' cadences']);
            end

            calIntermediateStruct.missingVsmearCadences = missingVsmearCadences;
        end
    end
end


%--------------------------------------------------------------------------
% construct pixel arrays for all target/photometric pixel data
%--------------------------------------------------------------------------
if isAvailableTargetAndBkgPix

    % concatenate pixels, gaps, rows, and columns into arrays
    % collect arrays in intermediate struct
    calIntermediateStruct.photometricPixels     = [calObject.targetAndBkgPixels.values]';
    calIntermediateStruct.photometricColumns    = [calObject.targetAndBkgPixels.column]';
    calIntermediateStruct.photometricRows       = [calObject.targetAndBkgPixels.row]';
        
    % add cadence gaps from cadenceTimes
    photometricGaps = [calObject.targetAndBkgPixels.gapIndicators]';    
    photometricGaps = photometricGaps | repmat(cadenceGapIndicators(:)',size(photometricGaps,1),1);
    
    % store
    calIntermediateStruct.photometricGaps = photometricGaps;
    

    %--------------------------------------------------------------------------
    % check for missing cadences in photometric data
    %--------------------------------------------------------------------------
    if processFFI

        calIntermediateStruct.missingPhotometricCadences = [];
    else

        if ~isempty(calIntermediateStruct.photometricGaps)

            % 'all' operates on columns, returning a row of logicals
            photometricAvailableLogical = ~all(calIntermediateStruct.photometricGaps)';             % nCadences x 1
            missingPhotometricCadences  = find(~photometricAvailableLogical);                       % nCadences x 1

            %print only moderately sized arrays to screen
            if ~isempty(missingPhotometricCadences) && length(missingPhotometricCadences) < 10
                display(['CAL:repackage_data_for_calibration: Photometric pixel data',...
                    ' is missing for cadences ' mat2str(missingPhotometricCadences(:))]);
            elseif ~isempty(missingPhotometricCadences) && length(missingPhotometricCadences) >= 10
                display(['CAL:repackage_data_for_calibration: Photometric pixel data',...
                    ' is missing for ' num2str(length(missingPhotometricCadences)) ' cadences']);
            end

            calIntermediateStruct.missingPhotometricCadences = missingPhotometricCadences;
        end
    end
end


%--------------------------------------------------------------------------
% construct pixel arrays for FFI pixel data from photometric rows
%--------------------------------------------------------------------------
if isAvailableFfiPix
    % build data structure
    numFfis = length(calObject.ffis);    
    ffiStruct = repmat(struct('rows',[],...
                                'columns',[],...
                                'image',[],...
                                'timestamp',[]),1,numFfis);
                            
    for iFfi = 1:numFfis
        % timestamp
        ffiStruct(iFfi).timestamp = calObject.ffis(iFfi).midTimestamp;
        % build 2D image - comes out as nColumns x nRows
        ffiStruct(iFfi).image  = [calObject.ffis(iFfi).image.array];
        % read row and column indices for image from input
        ffiStruct(iFfi).rows = rowvec(calObject.ffis(iFfi).absoluteRowNumbers);
        ffiStruct(iFfi).columns = rowvec(1:size(ffiStruct(iFfi).image,1));
   end    
    
    % store working copy
    calIntermediateStruct.ffiStruct = ffiStruct;
end
    

%--------------------------------------------------------------------------
% add data flags to intermediate struct
%--------------------------------------------------------------------------
calIntermediateStruct.ccdModule = calObject.ccdModule;
calIntermediateStruct.ccdOutput = calObject.ccdOutput;
calIntermediateStruct.dataFlags = calObject.dataFlags;

calIntermediateStruct.pouEnabled = pouEnabled;
calIntermediateStruct.enableSmearExcludeColumnMap = enableSmearExcludeColumnMap;
calIntermediateStruct.enableSceneDependentRowMap = enableSceneDependentRowMap;
calIntermediateStruct.enableBlackCoefficientOverrides = enableBlackCoefficientOverrides;

calIntermediateStruct.nCadences     = nCadences;
calIntermediateStruct.nCcdRows      = nCcdRows;
calIntermediateStruct.nCcdColumns   = nCcdColumns;
calIntermediateStruct.debugLevel    = debugLevel;

return;
