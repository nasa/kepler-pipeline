function [timeSeries, idxFilled] = fill_data_gaps_interp_long(timeSeries, gapFillParams, debugLevel)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [timeSeries, idxFilled] = fill_data_gaps_interp_long(timeSeries, gapFillParams, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% INPUTS:
% timeSeries        = time series structure with the following fields:
%   values              = values; double array, nx1
%   uncertainties       = uncertainties; double array, nx1
%   gapIndicators       = gap indicators; logical array, nx1
% gapFillParams     = parameter struct used by pdc gap filling
% debugLevel        = debug level; double

% OUTPUTS:
% timeSeries        = time series structure with data gaps filled with the following fields:
%   values              = values; double array, nx1
%   uncertainties       = uncertainties; double array, nx1
%   gapIndicators       = gap indicators; logical array, nx1 (should be all false)
% idxFilled         = list of filled indices; double, nFilledEntriesx1
% 




% This function is built specifically for DV:perform_centroid_tests and is
% loosely based on PDC:fill_data_gaps. The short gaps are filled with a call
% to pdc:fill_short_data_gaps (just as in PDC:fill_data_gaps). The long gaps
% are filled by linear interpolation with zero mean Gaussian noise added. The 
% standard deviation of the added noise = 1.4826 * MAD(ungapped data) near the
% data gap. The MADs of the valid data windows before and after the data
% gap are used to estimate the MAD for the data in the gap. The
% uncertainties of any filled long data gaps are set to a default value (-1
% nominally).
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% ~~~~~~~~~ % HARD CODED CONSTANTS
% empirical standard deviation to median absolute deviation ratio (assumes Gaussian distribution)
STD_MAD_RATIO = 1.4826;

% set window used to determine MAD near long gap
MAD_WINDOW_LENGTH = 48;
MIN_POINTS_FOR_MAD = 3;

% set uncertainty for long gap filled samples
LONG_GAP_UNC = -1;
% ~~~~~~~~~ %


% parse input struct
values          = timeSeries.values;
uncertainties   = timeSeries.uncertainties;
gaps            = timeSeries.gapIndicators;

% identify available samples
indexAvailable = find(~gaps);

%--------------------------------------------------------------------------
% pathological case 1 - at most one valid sample is available; can't even
% use interp1 in this case
%--------------------------------------------------------------------------
if(length(indexAvailable) <= 1)
    warning('GapFill:fill_data_gaps_interp_long',....
        'GapFill:fill_data_gaps_interp_long:can''t fill gaps as less than 2 valid samples are available.');
    idxFilled = [];
    return
end

%--------------------------------------------------------------------------
% pathological case 2 - just 3 or fewer samples are available; all gaps are
% filled by nearest neighbor interpolation
%--------------------------------------------------------------------------
if(length(indexAvailable) <= 3)
    warning('GapFill:fill_data_gaps_interp_long',....
        'GapFill:fill_data_gaps_interp_long:using interp1 to fill gaps as less than 4 samples are available.');

    nTimeSteps = (1:length(values))';
    
    timeSeries.values = interp1(indexAvailable,values(indexAvailable),nTimeSteps,'nearest','extrap');

    timeSeries.uncertainties(gaps) = LONG_GAP_UNC;
    timeSeries.gapIndicators = gaps & false;
    idxFilled = find(gaps);    
    return
end

%--------------------------------------------------------------------------
% standard gaps case; all short gaps are filled by AR prediction, and all
% long gaps are filled by linear extrapolation plus gaussian white noise
%--------------------------------------------------------------------------

% First fill in the short data gaps. The short data gap filling function
% will still return the master index of giant transits even if there are
% not actually any data gaps.

% force the gap filler to identify outliers if we are filling gaps
if ~isequal( sum(gaps), 0 )
    indexOfAstroEvents = 0;
else
    indexOfAstroEvents = [];
end

[values, ~, gaps, uncertainties] = fill_short_gaps(values,gaps,indexOfAstroEvents,debugLevel,gapFillParams,uncertainties);


% Now fill the long data gaps using linear interpolation. 
% If there are any gaps left they must be long data gaps.
if any(gaps)
    
    allIndices = 1:length(values);    
    gapLocations = find_datagap_locations(gaps);
    gappedIndices = find(gaps);
    ungappedIndices = setdiff(allIndices, gappedIndices);
    endGapIndices = [];
    
    if any(gapLocations(:,1) == 1) || any(gapLocations(:,2) == length(gaps))
        
        % consider only the gaps which include the first or last cadence
        beginIdx = find(gapLocations(:,1) == 1);
        endIdx = find(gapLocations(:,2) == length(gaps));        
        endGapIndices = [gapLocations(beginIdx,1):gapLocations(beginIdx,2), gapLocations(endIdx,1):gapLocations(endIdx,2)];
        
        % perform nearest neighbor interpolation over long gaps at the beginning or end of the data set (KSOC-2487)
        % using median filtered data as input
        medianValue = median(values(ungappedIndices));
        filteredValues = medfilt1_soc(values(ungappedIndices) - medianValue,48) + medianValue;
        values(endGapIndices) = interp1(ungappedIndices(:), filteredValues, endGapIndices(:), 'nearest', 'extrap');
        uncertainties(endGapIndices) = LONG_GAP_UNC;
        
        % update gaps, gappedIndices and ungappedIndices for linear interpolation segment
        gaps(endGapIndices) = false;
        gappedIndices = find(gaps);
        ungappedIndices = setdiff(allIndices, gappedIndices);
        
    end

    % perform linear interpolation across remaining long gaps  
    medianValue = median(values(ungappedIndices));
    filteredValues = medfilt1_soc(values(ungappedIndices) - medianValue,48) + medianValue;
    values(gappedIndices) = interp1(ungappedIndices(:), filteredValues, gappedIndices(:), 'linear', 'extrap');
    uncertainties(gappedIndices) = LONG_GAP_UNC;

    
    % restore gaps indicators and gappedIndices so noise can be will be estimated from original ungapped data
    % and added to all originally gapped data
    gaps(endGapIndices) = true;
    gappedIndices = find(gaps);
    
    
    % ~~~~~~~~~~ % For each gap, add zero mean gaussian noise w/var= (STD_MAD_RATIO * MAD)^2 to the gap filled data
    gapStart = gapLocations(:,1);
    gapFinish = gapLocations(:,2);
    
    if length(gapStart) ~= length(gapFinish)
        warning('GapFill:fill_data_gaps_interp_long',....
            'GapFill:fill_data_gaps_interp_long:unequal length gap start and stop vectors. Estimating MAD from of all ungapped data.');
        equalLengthStartAndStopVectors = false;
    else
        equalLengthStartAndStopVectors = true;
    end
    
    % unequal length gap start and stop vectors should never happen now due to KSOC-2487 fix (see above)    
    if equalLengthStartAndStopVectors
        % gaps are well defined - estimate noise in each gap separately
        
        for gapIndex = 1:length(gapStart)

            % ~~~~~~~~~~ % determine MAD of valid linear detrended data in window left and right of (before and after) the gap
            % define left window
            madIndexStart = max( gapStart(gapIndex) - MAD_WINDOW_LENGTH, 1);
            madIndexFinish = gapStart(gapIndex) - 1;

            leftMadWindowMask = false(size(gaps));
            if madIndexStart <= madIndexFinish && madIndexStart > 0 && madIndexFinish > 0
                leftMadWindowMask(madIndexStart:madIndexFinish) = true;
            end
            leftMadIndices = find(leftMadWindowMask & ~gaps);

            if length(leftMadIndices) > MIN_POINTS_FOR_MAD
                % get mad of detrended valid data in window
                if( all(uncertainties(leftMadIndices)>0) )
                    weights = 1./(uncertainties(leftMadIndices).^2);
                else
                    weights = ones(size(uncertainties(leftMadIndices)));
                end
                leftMad = mad( weighted_linear_detrend( values(leftMadIndices), weights, leftMadIndices ) );
            else
                % -1 indicates not enough points for mad
                leftMad = -1;           
            end

            
            % define right window
            madIndexStart = gapFinish(gapIndex) + 1;
            madIndexFinish = min( length(gaps), gapFinish(gapIndex) + MAD_WINDOW_LENGTH );        

            rightMadWindowMask = false(size(gaps));
            if madIndexStart <= madIndexFinish && madIndexStart <= length(gaps)  && madIndexFinish <= length(gaps) 
                rightMadWindowMask(madIndexStart:madIndexFinish) = true;
            end
            rightMadIndices = find(rightMadWindowMask & ~gaps);

            if length(rightMadIndices) > MIN_POINTS_FOR_MAD
                % get mad of detrended valid data in window
                if( all(uncertainties(rightMadIndices)>0) )
                    weights = 1./(uncertainties(rightMadIndices).^2);
                else
                    weights = ones(size(uncertainties(rightMadIndices)));
                end
                rightMad = mad( weighted_linear_detrend( values(rightMadIndices), weights, rightMadIndices ) );
            else
                % -1 indicates not enough points for mad
                rightMad = -1;          
            end

            % ~~~~~~~~~~ % estimate MAD in gap from right and/or left window mad or from mad of all ungapped values
            if leftMad ~= -1 && rightMad ~= -1
                % use mean of MAD in left and right windows to form estimate for MAD in gap
                madUngappedData = mean( [leftMad, rightMad] );

            elseif leftMad ~= -1
                % right mad not available
                madUngappedData = leftMad;

            elseif rightMad ~= -1
                % left mad not available
                madUngappedData = rightMad;

            else
                % neither right or left mad is available
                madUngappedData = mad( values(ungappedIndices) );
            end

            % ~~~~~~~~~~ % add gaussian noise to filled data
            thisGapIndices = gappedIndices( gappedIndices >= gapStart(gapIndex) & gappedIndices <= gapFinish(gapIndex) );
            values(thisGapIndices) = values(thisGapIndices) + (STD_MAD_RATIO * madUngappedData) .* randn(length(thisGapIndices),1);       
        end    
    else
        % gaps are not well defined - estimate noise based on mad over all ungapped indices
        madUngappedData = mad( values(ungappedIndices) );
        values(gappedIndices) = values(gappedIndices) + (STD_MAD_RATIO * madUngappedData) .* randn(length(gappedIndices),1);
    end
    
end

% Set output
idxFilled = find(timeSeries.gapIndicators);
timeSeries.values = values;
timeSeries.uncertainties = uncertainties;
timeSeries.gapIndicators = false(size(timeSeries.gapIndicators));

return;



% sub function to remove linear trend from data using a weighted least squares fit
function data = weighted_linear_detrend(data, weights, indices)
A = [indices(:), ones(length(indices),1)];
b = lscov(A,data,weights);
data = data - A*b;
return;
end % function weighted_linear_detrend

end % function fill_data_gaps_interp_long
