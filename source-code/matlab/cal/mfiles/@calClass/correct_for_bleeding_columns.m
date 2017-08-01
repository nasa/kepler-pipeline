function [calObject, calIntermediateStruct] = ...
    correct_for_bleeding_columns(calObject, calIntermediateStruct)
%function [calObject, calIntermediateStruct] = ...
%    correct_for_bleeding_columns(calObject, calIntermediateStruct)
%
%
% Bleeding stars affect masked and virtual smear values and show up as
% strong outliers.  Detect them by comparing the masked-virtual smear
% difference to the median absolute deviation of this difference across
% time for each pixel.  The columns with deviations larger than the input
% threshold parameter are declared bleeding columns and the masked smear
% pixels for those columns are gapped.
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


% add to module parameters struct for Release 7.0
MAX_BLEEDING_COLUMNS_TO_DISPLAY     = 10;

% estimate nominal dark current = 1.05 e-/s
darkCurrentEstimateElectronsPerSecond  	= 1.05;

% maximum number of coulumns to check for misidentified
% masked or virtual bleed due to miscorrected undershoot
% in the smear pixels
MAX_COLUMN_OFFSET                   = 30;


% extract data flags
processFFI          = calObject.dataFlags.processFFI;

ccdExposureTime   = calIntermediateStruct.ccdExposureTime;
numberOfExposures = calIntermediateStruct.numberOfExposures;
nCadences         = calIntermediateStruct.nCadences;

% extract input parameter threshold to detect saturated pixels
madSigmaThresholdForBleedingColumns = ...
    calObject.moduleParametersStruct.madSigmaThresholdForBleedingColumns;

% extract black-corrected smear pixels, gaps, and columns
mSmearPixels  = calIntermediateStruct.mSmearPixels;     % nPix x nCad
mSmearGaps    = calIntermediateStruct.mSmearGaps;       % nPix x nCad
mSmearColumns = calIntermediateStruct.mSmearColumns;    % nPix x 1

vSmearPixels  = calIntermediateStruct.vSmearPixels;     % nPix x nCad
vSmearGaps    = calIntermediateStruct.vSmearGaps;       % nPix x nCad
vSmearColumns = calIntermediateStruct.vSmearColumns;    % nPix x 1

% initialize tracking and gap arrays
trackNormalizedDeltaSmearResidual   = zeros(size(mSmearGaps));
mSmearBleedingColsLogicalArray      = false(size(mSmearGaps));
vSmearBleedingColsLogicalArray      = false(size(vSmearGaps));


% get number of columns
nColumns = max(length(mSmearColumns), length(vSmearColumns));

% find common valid (non-gapped) indices
validMsmearIndicatorsArray = ~(mSmearGaps);             % nPix x nCad
validVsmearIndicatorsArray = ~(vSmearGaps);             % nPix x nCad
commonValidIndicatorsArray = validMsmearIndicatorsArray & validVsmearIndicatorsArray;


% single long cadence and FFI:
if (nCadences == 1) || processFFI
    
    ffiDarkCurrentEstimate = darkCurrentEstimateElectronsPerSecond .* ccdExposureTime .* numberOfExposures;
    
    % calculate residual - expect deltaSmear = dark current
    if numel(ffiDarkCurrentEstimate) > 1
        residualDeltaSmear = mSmearPixels - vSmearPixels - repmat(ffiDarkCurrentEstimate, nColumns, 1);
    else
        residualDeltaSmear = mSmearPixels - vSmearPixels - ffiDarkCurrentEstimate;
    end
    
    % propagate uncertainties assuming shot noise dominates mSmear and vSmear
    CdeltaSmear = sqrt(abs(mSmearPixels) + abs(vSmearPixels));
    
    % identify bleeding columns
    mSmearBleedingColsLogicalArray(commonValidIndicatorsArray) = ...
        (residualDeltaSmear(commonValidIndicatorsArray) > 0) & ...
        ( abs(residualDeltaSmear(commonValidIndicatorsArray)./...
        CdeltaSmear(commonValidIndicatorsArray)) > madSigmaThresholdForBleedingColumns );
    vSmearBleedingColsLogicalArray(commonValidIndicatorsArray) = ...
        (residualDeltaSmear(commonValidIndicatorsArray) < 0) & ...
        ( abs(residualDeltaSmear(commonValidIndicatorsArray)./...
        CdeltaSmear(commonValidIndicatorsArray)) > madSigmaThresholdForBleedingColumns );
    
    % all other long cadences:
else
    
    % Use the median masked-virtual smear difference as the dark current estimate.
    
    darkCurrent  = zeros( 1, nCadences );
    CdarkCurrent = zeros( 1, nCadences );
    
    % get dark current estimate for each cadence
    for iCadence = 1:nCadences
        
        validColumns = find(commonValidIndicatorsArray(:,iCadence));
        numValidColumns = length(validColumns);
        
        if( numValidColumns > 0 )
            
            validMSmearPixels = mSmearPixels(validColumns,iCadence);
            validVSmearPixels = vSmearPixels(validColumns,iCadence);
            
            darkCurrent(iCadence) = median( validMSmearPixels )  - median( validVSmearPixels );        % 1 x nCad
            
            % Use POU for mean even though these are medians - assume shot noise dominates
            CdarkCurrent(iCadence) = sqrt( (abs(median(validMSmearPixels)) + abs(median(validVSmearPixels))) ./ numValidColumns );
            
        end
    end
    
    
    % loop over columns in order to exclude gapped columns when computing the residual
    % of (masked - virtual smear) for each pixel time series
    medianResidualDeltaSmearOfColumn = zeros(nColumns, 1);
    CmedianResidualDeltaSmearOfColumn = zeros(nColumns, 1);
    
    
    for columnIndex = 1:nColumns
        
        % find cadences with valid masked and virtual smear for this column
        commonValidCadences = find(commonValidIndicatorsArray(columnIndex,:));
        
        if (~isempty(commonValidCadences))
            
            residualDeltaSmear = mSmearPixels(columnIndex,commonValidCadences) - ...
                vSmearPixels(columnIndex,commonValidCadences) - darkCurrent(commonValidCadences); % 1xnCommonValidCadences
            
            CresidualDeltaSmear = sqrt(abs(mSmearPixels(columnIndex,commonValidCadences)) + ...
                abs(vSmearPixels(columnIndex,commonValidCadences)) + ...
                CdarkCurrent(commonValidCadences).^2);
            % 1xnCommonValidCadences
            
            normalizedDeltaSmearResidual = residualDeltaSmear ./ CresidualDeltaSmear;
            
            cadencesWithBleedingMSmear = commonValidCadences(normalizedDeltaSmearResidual > madSigmaThresholdForBleedingColumns);
            
            cadencesWithBleedingVSmear = commonValidCadences(-normalizedDeltaSmearResidual > madSigmaThresholdForBleedingColumns);
            
            % update gap information
            if (~isempty(cadencesWithBleedingMSmear))
                mSmearBleedingColsLogicalArray(columnIndex, cadencesWithBleedingMSmear) = true;
            end
            if (~isempty(cadencesWithBleedingVSmear))
                vSmearBleedingColsLogicalArray(columnIndex, cadencesWithBleedingVSmear) = true;
            end
            
            medianResidualDeltaSmearOfColumn(columnIndex) = median(residualDeltaSmear);
            CmedianResidualDeltaSmearOfColumn(columnIndex) = median(CresidualDeltaSmear);
            trackNormalizedDeltaSmearResidual(columnIndex, commonValidCadences) = normalizedDeltaSmearResidual;
        end
    end
    
    
    %----------------------------------------------------------------------
    % save and plot additional bleeding columns information
    %----------------------------------------------------------------------
    calIntermediateStruct.medianResidualDeltaSmearOfColumn = medianResidualDeltaSmearOfColumn;
    calIntermediateStruct.CmedianResidualDeltaSmearOfColumn = CmedianResidualDeltaSmearOfColumn;
    
    close all;
    paperOrientationFlag = true;
    
    h = figure;
    subplot(2, 1, 1);
    plot(trackNormalizedDeltaSmearResidual);
    
    title('[CAL] Normalized Residual Delta Smear', 'fontsize', 14);
    xlabel(' Column ', 'fontsize', 13);
    ylabel(' Residual Smear/Uncertainty', 'fontsize', 13);
    grid on;
    
    subplot(2, 1, 2);
    imagesc(double(mSmearBleedingColsLogicalArray)' + 2.*double(vSmearBleedingColsLogicalArray)');
    title('[CAL] Gapped Bleeding Columns (Masked=1, Virtual=2)', 'fontsize', 14);
    xlabel(' Column ', 'fontsize', 13);
    ylabel(' Cadence ', 'fontsize', 13);
    
    %apply_white_nan_colormap_to_image();
    
    colorbar
    fileNameStr = 'cal_bleeding_columns';
    
    set(h, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    plot_to_file(fileNameStr, paperOrientationFlag);
    close all;
end


% update mSmear and vSmear gap arrays - gap bleeding columns
% This patch compensates for uncorrected undershoot in the masked and
% virtual smear data (see KSOC-141/337). If virtual smear is gapped for
% bleed in the next column after a masked smear column was gapped for
% bleed then the virtual gap will be changed to a masked gap. Apply
% this gap reassignment iteratively until the masked gap array remains
% unchanged or the maximum number of offset columns is reached. Adjust
% the virtual bleed gaps in a similar fashion swapping masked and
% virtual gap in the previous sentence.


% check for misidentified masked bleed due to miscorrected undershoot in the virtual smear pixels
deltaBleed = true(size(vSmearBleedingColsLogicalArray));
columnOffset = 0;

while( any(any(deltaBleed)) && columnOffset < MAX_COLUMN_OFFSET )
    
    columnOffset = columnOffset + 1;
    
    % compare adjacent columns for vSmearBleed & mSmearBleed pairs
    % flag any mSmearBleed directly after (next highest column number) any vSmearBleed
    shiftedBleed = [false(1,nCadences);vSmearBleedingColsLogicalArray(1:end-1,:)];
    deltaBleed = shiftedBleed & mSmearBleedingColsLogicalArray;
    
    % adjust mSmearBleed and vSmearBleed logicals
    % remove delta from vSmearBleed and add delta to mSmearBleed
    vSmearBleedingColsLogicalArray = vSmearBleedingColsLogicalArray | deltaBleed;
    mSmearBleedingColsLogicalArray = xor(mSmearBleedingColsLogicalArray, deltaBleed);
    
end


% check for misidentified virtual bleed due to miscorrected undershoot in the masked smear pixels
deltaBleed = true(size(mSmearBleedingColsLogicalArray));
columnOffset = 0;

while( any(any(deltaBleed)) && columnOffset < MAX_COLUMN_OFFSET )
    
    columnOffset = columnOffset + 1;
    
    % compare adjacent columns for mSmearBleed & vSmearBleed pairs
    % flag any vSmearBleed directly after (next highest column number) any mSmearBleed
    shiftedBleed = [false(1,nCadences);mSmearBleedingColsLogicalArray(1:end-1,:)];
    deltaBleed = shiftedBleed & vSmearBleedingColsLogicalArray;
    
    % adjust mSmearBleed and vSmearBleed logicals
    % remove delta from vSmearBleed and add to mSmearBleed
    mSmearBleedingColsLogicalArray = mSmearBleedingColsLogicalArray | deltaBleed;
    vSmearBleedingColsLogicalArray = xor(vSmearBleedingColsLogicalArray, deltaBleed);
    
end

% update masked and virtual smear gaps for bleeding columns
mSmearGaps = mSmearGaps | mSmearBleedingColsLogicalArray;
vSmearGaps = vSmearGaps | vSmearBleedingColsLogicalArray;

% display message to standard output
if(any(any(mSmearBleedingColsLogicalArray)))
    
    if( size(mSmearBleedingColsLogicalArray, 2) > 1 )
        gappedColumns = mSmearColumns(any(mSmearBleedingColsLogicalArray'));
    else
        gappedColumns = mSmearColumns(mSmearBleedingColsLogicalArray)';
    end
    nGappedColumns = length(gappedColumns);
    
    
    if( nGappedColumns <= MAX_BLEEDING_COLUMNS_TO_DISPLAY )
        
        display(['CAL:correct_for_bleeding_columns: Bleeding columns detected in masked smear for at least one cadence in columns: ' mat2str(gappedColumns)]);
        
    else
        display(['CAL:correct_for_bleeding_columns: Bleeding columns detected in ' num2str(nGappedColumns) ' masked smear columns']);
    end
end


if(any(any(vSmearBleedingColsLogicalArray)))
    
    if( size(vSmearBleedingColsLogicalArray, 2) > 1 )
        gappedColumns = vSmearColumns(any(vSmearBleedingColsLogicalArray'));
    else
        gappedColumns = vSmearColumns(vSmearBleedingColsLogicalArray)';
    end
    nGappedColumns = length(gappedColumns);
    
    if( nGappedColumns <= MAX_BLEEDING_COLUMNS_TO_DISPLAY )
        
        display(['CAL:correct_for_bleeding_columns: Bleeding columns detected in virtual smear for at least one cadence in columns: ' mat2str(gappedColumns)]);
        
    else
        display(['CAL:correct_for_bleeding_columns: Bleeding columns detected in ' num2str(nGappedColumns) ' virtual smear columns']);
    end
end

% save bleeding column logical arrays
calIntermediateStruct.mSmearBleedingColsLogicalSparseArray = sparse(mSmearBleedingColsLogicalArray);
calIntermediateStruct.vSmearBleedingColsLogicalSparseArray = sparse(vSmearBleedingColsLogicalArray);

% save updated gap array to intermediate struct
calIntermediateStruct.mSmearGaps = mSmearGaps;
calIntermediateStruct.vSmearGaps = vSmearGaps;



return;
