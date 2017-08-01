function eventsFound = plot_cal_cosmic_ray_events(inputsStruct, outputsStruct, pixelRow, pixelColumn)
%
% function eventsFound = plot_cal_cosmic_ray_events(inputsStruct, outputsStruct, pixelRow, pixelColumn)
% 
% This function plots the calibrated pixel time series identified by the
% pixelRow, pixelColumn pair and marks any cosmic rays for the pixel (red circle)
% and the value that was used to replace the cosmic ray (black circle). If
% there were no CR found in the pixel time series then the plot will be
% empty.
%
% INPUTS:
%         inputsStruct  = cal collateral input struct
%         outputsStruct = cal collateral output struct
%         pixelsRow     = list of pixel rows to check for cosmic rays, nx1, zero-based
%         pixelColumn   = list of pixel columns to check for cosmic rays, nx1, zero-based
%                           Note: pixelRow, pixelColumn are input as
%                           ordered pairs. The member of the pair which
%                           does not participate in the identification of
%                           the pixel should be assigned a value of zero.
%           e.g. to get all the available black rows,
%           pixelRow = [1:1070]-1, pixelColumn = zeros(size(pixelRow)
%           e.g. to get all the smear columns, 
%           pixelsRow = zeros(size(pixelsColumn)),pixelColumn = [1:1132]-1;
%           For short cadence masked and virtual black input pixelRow = -1, pixelColumn = -1
% OUTPUTS:
%        eventsFound    = cell array, nx1
%                         The ith cell contains an array of cosmic ray event
%                         structs corresponding to all the events related to the
%                         ith element of the pixelRow, pixelColumn pair.
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



rowSize = size(pixelRow);
colSize = size(pixelColumn);

if( min(rowSize)~=1 )
    error('pixelRow and pixelColumn must be nx1 or 1xn');
end

if( ~isequal(rowSize, colSize) )
    error('pixelRow and pixelColumn must have same size and shape');
end


% get location of all collateral pixels in the output struct
% cal does not clean cosmic rays from target and background pixels

rows = [];
cols = [];
vals = [];
gaps = [];

if( ~isempty(outputsStruct.calibratedCollateralPixels.blackResidual) )
    rows = [rows, [outputsStruct.calibratedCollateralPixels.blackResidual.row]];
    cols = [cols, zeros(size([outputsStruct.calibratedCollateralPixels.blackResidual.row]))];
    vals = [vals, [outputsStruct.calibratedCollateralPixels.blackResidual.values]];
    gaps = [gaps, [outputsStruct.calibratedCollateralPixels.blackResidual.gapIndicators]];
end

if( ~isempty(outputsStruct.calibratedCollateralPixels.maskedSmear) )
    rows = [rows, zeros(size([outputsStruct.calibratedCollateralPixels.maskedSmear.column]))];
    cols = [cols, [outputsStruct.calibratedCollateralPixels.maskedSmear.column]];    
    vals = [vals, [outputsStruct.calibratedCollateralPixels.maskedSmear.values]];
    gaps = [gaps, [outputsStruct.calibratedCollateralPixels.maskedSmear.gapIndicators]];
end

if( ~isempty(outputsStruct.calibratedCollateralPixels.virtualSmear) )
    rows = [rows, zeros(size([outputsStruct.calibratedCollateralPixels.virtualSmear.column]))];
    cols = [cols, [outputsStruct.calibratedCollateralPixels.virtualSmear.column]];    
    vals = [vals, [outputsStruct.calibratedCollateralPixels.virtualSmear.values]];
    gaps = [gaps, [outputsStruct.calibratedCollateralPixels.virtualSmear.gapIndicators]];
end

if( ~isempty(outputsStruct.calibratedCollateralPixels.maskedBlackResidual) ||...
        ~isempty(outputsStruct.calibratedCollateralPixels.virtualBlackResidual) )
    rows = [rows, -1 ];
    cols = [cols, -1 ];
end

if( ~isempty(outputsStruct.calibratedCollateralPixels.maskedBlackResidual) )
    vals = [vals, [outputsStruct.calibratedCollateralPixels.maskedBlackResidual.values]];
    gaps = [gaps, [outputsStruct.calibratedCollateralPixels.maskedBlackResidual.gapIndicators]];
end

if( ~isempty(outputsStruct.calibratedCollateralPixels.virtualBlackResidual) )
    vals = [vals, [outputsStruct.calibratedCollateralPixels.virtualBlackResidual.values]];
    gaps = [gaps, [outputsStruct.calibratedCollateralPixels.virtualBlackResidual.gapIndicators]];
end


tfInBlack  = ismember(  [rows(:), -1.*ones(size(rows(:)))], [pixelRow(:), pixelColumn(:)], 'rows' );
tfInSmear  = ismember(  [-1.*ones(size(cols(:))), cols(:)], [pixelRow(:), pixelColumn(:)], 'rows' );
tfInMaskedAndVirtualBlack = ismember( [rows(:), cols(:)], [pixelRow(:), pixelColumn(:)], 'rows' );

tfIn = tfInBlack | tfInSmear | tfInMaskedAndVirtualBlack;


% trim to only the ones founds in the input list
rows = rows(tfIn);
cols = cols(tfIn);
vals = vals(:,tfIn);
gaps = logical(gaps(:,tfIn));

% set gaps to NaN
vals(gaps) = NaN;


% allocate storage for summary of cosmic ray events per pixel
eventsFound = cell(length(pixelRow),1);


% build set of events and row/column pairs
eventRows = [];
eventCols = [];
events = [];


if( ~isempty(outputsStruct.cosmicRayEvents.black) )
    events = [events, rowvec(outputsStruct.cosmicRayEvents.black)];
    eventRows = [eventRows, [outputsStruct.cosmicRayEvents.black.rowOrColumn]];
    eventCols = [eventCols, zeros(size([outputsStruct.cosmicRayEvents.black.rowOrColumn]))];
end

if( ~isempty(outputsStruct.cosmicRayEvents.maskedSmear) )
    events = [events, rowvec(outputsStruct.cosmicRayEvents.maskedSmear)];
    eventRows = [eventRows, zeros(size([outputsStruct.cosmicRayEvents.maskedSmear.rowOrColumn]))];
    eventCols = [eventCols, [outputsStruct.cosmicRayEvents.maskedSmear.rowOrColumn]];    
end

if( ~isempty(outputsStruct.cosmicRayEvents.virtualSmear) )
    events = [events, rowvec(outputsStruct.cosmicRayEvents.virtualSmear)];
    eventRows = [eventRows, zeros(size([outputsStruct.cosmicRayEvents.virtualSmear.rowOrColumn]))];
    eventCols = [eventCols, [outputsStruct.cosmicRayEvents.virtualSmear.rowOrColumn]];    
end

if( ~isempty(outputsStruct.cosmicRayEvents.maskedBlack) )
    events = [events, rowvec(outputsStruct.cosmicRayEvents.maskedBlack)];
    eventRows = [eventRows, -1 .* ones(size(rowvec(outputsStruct.cosmicRayEvents.maskedBlack)))];
    eventCols = [eventCols, -1 .* ones(size(rowvec(outputsStruct.cosmicRayEvents.maskedBlack)))];    
end

if( ~isempty(outputsStruct.cosmicRayEvents.virtualBlack) )
    events = [events, rowvec(outputsStruct.cosmicRayEvents.virtualBlack)];
    eventRows = [eventRows, -1 .* ones(size(rowvec(outputsStruct.cosmicRayEvents.virtualBlack)))];
    eventCols = [eventCols, -1 .* ones(size(rowvec(outputsStruct.cosmicRayEvents.virtualBlack)))];    
end


cadences = [inputsStruct.cadenceTimes.cadenceNumbers];

figure;
hold on;




% loop over input pixels
for i=1:length(rows)
        
    % find subset of events for this input pixel
    tfOut = ismember([eventRows(:), eventCols(:)], [rows(i), cols(i)], 'rows' );

    % get timestamp index of all found events

    if( ~isempty(events) )
        [tfCadence, cadenceIdx] = ...
            ismember([events(tfOut).mjd],[inputsStruct.cadenceTimes.midTimestamps]);
    end
    
    if( any(tfOut) && any(tfCadence) )
        eventsFound{i} = events(tfOut);
        
        % extract pixel time series
        tempVals = vals(:,i);  
    
        % add the delta back in
        tempVals(cadenceIdx) = tempVals(cadenceIdx) + [events(tfOut).delta]';
        % plot the delta
        plot(cadences(cadenceIdx), tempVals(cadenceIdx),'ro','MarkerSize',10);
        % plot the replacement point
        plot(cadences(cadenceIdx), vals(cadenceIdx,i) ,'ko');        
        % add delta back in for plot later
        vals(:,i) = tempVals;
    end
end

plot(cadences,vals);

grid;
hold off;


