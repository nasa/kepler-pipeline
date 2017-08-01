%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [timeSeriesWithGapsFilled, gapLocations]  =
% fill_long_gap_by_reflecting_segments_into_gap(timeSeriesWithGaps,
% dataGapIndicators, maxDetrendPolyOrder, debugFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function fills the long data gaps in a non stationary time series by
% reflecting data segments on either side of the gap across the gap. This
% is the first step in filling the long data gaps.
%
% Inputs:
%        1. timeSeriesWithGaps - time series with long data gaps ( a long
%           data gap is any gap > 4 days or so)
%        2. dataGapIndicators = a logical array with 1's indicating data gaps
%        3. maxDetrendPolyOrder = 25 % max order of polynomial used for
%           detrending
%        4. debugFlag - a boolean when set enables plotting intermediate results
%
% Output:
%        1. timeSeriesWithGapsFilled - time series where data gaps have been
%           temporarily filled with weighted sum of samples from reflected
%           segments
%        2. gapLocations - a 2-D array indicating the beginning and the
%           end of gaps locations
%
% References:
%   [1] KADN-26068 Long data gap fill algorithm
%   [2]	J. Jenkins, "The Impact of Solar-like variability on the
%   Detectability of Transiting terrestrial Planets," The Astrophysical
%   Journal, Vol. 575, No. 1, Part 1, August 2002, pages 493 -505.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
function [timeSeriesWithGapsFilled, gapLocations, gapFillStatusStruct] = ...
    fill_long_gap_by_reflecting_segments_into_gap(timeSeriesWithGaps, ...
    dataGapIndicators, maxDetrendPolyOrder, debugFlag)


% 'timeSeriesWithGaps' should be an evenly sampled sequence with
% missing values filled in with zeros.


nOriginalLength = length(dataGapIndicators);
timeSeriesWithGapsSaved = timeSeriesWithGaps;


gapFillStatusStruct = struct('successStatus', true, 'leftGap', false, 'rightGap', false, 'midGap', false, ...
    'leftSegmentLength', -1, 'rightSegmentLength', -1, 'dataGapIndicators' , []);

% % find out whether the signal length is a power of 2
% % if not, extend it to a length just enough to make it a power of 2.
% n1 = floor(log2(nOriginalLength));
% if (2^n1 ~= nOriginalLength)
%     n2 = n1+1;
%     timeSeriesWithGaps = [timeSeriesWithGaps; zeros(2^n2-nOriginalLength,1)];
%     dataGapIndicators = [dataGapIndicators; true(2^n2-nOriginalLength,1)];
% end;

dataGapIndicatorsSaved = dataGapIndicators;

gapLocations = find_datagap_locations(dataGapIndicators);


if(isempty(gapLocations))
    timeSeriesWithGapsFilled = timeSeriesWithGaps;
    return;
end

if(~any(~dataGapIndicators))
    timeSeriesWithGapsFilled = timeSeriesWithGaps;
    return;
end


gapLengths = gapLocations(:,2) - gapLocations(:,1)+ 1;

numberOfGaps = length(gapLengths);


if(numberOfGaps > 1)
    % ensure that the gaps except for the last are not pathological

    newGapLocations = gapLocations;

    for j = 1:numberOfGaps-1

        endOfFirstGap = gapLocations(j,2);
        beginningOfNextGap = gapLocations(j+1,1);

        if(beginningOfNextGap < gapLengths(j)+endOfFirstGap) % next gap begins too soon to contain enough samples to close the first gap
            % combine two gaps
            newGapLocations(j,1) = gapLocations(j,1);
            newGapLocations(j,2) = gapLocations(j+1,2);
            gapLocations(j+1,:) = newGapLocations(j,:);
            newGapLocations(j+1,:) = newGapLocations(j,:);
        end

    end

    for j=1:length(newGapLocations)
        dataGapIndicators(newGapLocations(j,1):newGapLocations(j,2)) = true;
    end

    gapLocations = find_datagap_locations(dataGapIndicators);
    gapLengths = gapLocations(:,2) - gapLocations(:,1)+ 1;

    numberOfGaps = length(gapLengths);
end


% check to see if the entire timeseries has been gapped because gapped segments were longer than data segments
% compute the mean and std of existing samples and fill the gaps with randn(mean,std)
% issue a warning stating that the gaps  were too big to fill using wavelet transorm based fill_long_data_gaps and
% instead using a simpler method to fill the samples

if(  (sum(dataGapIndicators)/nOriginalLength) > 0.5)  % more than 50% is gaps, gap


    indexOfValidSamples = find(~dataGapIndicatorsSaved);
    indexOfGapSamples = find(dataGapIndicatorsSaved);
    meanForFillSamples = mean(timeSeriesWithGapsSaved(indexOfValidSamples));
    stdForFillSamples = std(timeSeriesWithGapsSaved(indexOfValidSamples));


    timeSeriesWithGapsFilled(indexOfGapSamples) = stdForFillSamples*randn(length(indexOfGapSamples),1)+meanForFillSamples;
    timeSeriesWithGapsFilled(indexOfValidSamples) = timeSeriesWithGapsSaved(indexOfValidSamples);
    gapLocations =[];
    timeSeriesWithGapsFilled = timeSeriesWithGapsFilled(:);

    warning('longgapfill:fill_long_gap_by_reflecting_segments_into_gap',...
        'gaps are much longer than the data segments; not using wavelet transform based gap filling; using a simpler method of gap filling ...');

    return

end






for j = 1:numberOfGaps

    currentGapSize = gapLengths(j);

    iGapStart = gapLocations(j,1);
    iGapEnd = gapLocations(j,2);

    %++++++++++++++++ FROM LEFT  +++++++++++++++++++++++++++++++++++
    % reflect data segment from the left
    % note: reflection is around the first available point to the left
    % edge of the gap and sometimes the left segment might not be long
    % enough to cover the gap

    iLeftDataSegmentEnd = gapLocations(j,1)-1;
    if(iLeftDataSegmentEnd ~= 0)
        % there are samples to the left of the gap
        iLeftDataSegmentBegin = max(gapLocations(j,1)-1- currentGapSize, 1);

        lengthOfLeftDataSegment = iLeftDataSegmentEnd - iLeftDataSegmentBegin +1;
        % create tapered weights for the reflected segemnt
        leftTaperWeights = (1 - (0:(currentGapSize-1))./(currentGapSize-1));

        leftTaperWeights = leftTaperWeights';
    else
        % no available samples to the left of the gap indicates a gap in the very beginning
        iLeftDataSegmentBegin = -1;
        iLeftDataSegmentEnd = -1;
        leftTaperWeights = 0;
        lengthOfLeftDataSegment = 0;
    end



    %++++++++++++++++ FROM RIGHT  +++++++++++++++++++++++++++++++++++
    % remember: reflection is around the first available point to the right
    % edge of the gap

    iRightDataSegmentBegin = gapLocations(j,2)+ 1;
    if(iRightDataSegmentBegin <= nOriginalLength)

        iRightDataSegmentEnd = min(gapLocations(j,2)+1+ currentGapSize, nOriginalLength);

        %++++++++ IMPORTANT ++++++++++++++++++++++++++++++++++++++
        % since gaps are closed from the left side, we only need to make sure
        % that reflected segment from the right does not contain another gap or
        % hole
        if(j < numberOfGaps && iRightDataSegmentEnd >= gapLocations(j+1,1))
            iRightDataSegmentEnd = gapLocations(j+1,1)-1;
        end;

        lengthOfRightDataSegment = iRightDataSegmentEnd - iRightDataSegmentBegin +1;
        rightTaperWeights = (1 - (0:(currentGapSize-1))./(currentGapSize-1));
        rightTaperWeights = rightTaperWeights';


    else
        % data gap at the end of the time series
        iRightDataSegmentBegin = -1;
        iRightDataSegmentEnd = -1;
        lengthOfRightDataSegment = 0;
    end
    % when the last gap is located at the end of a quarter, there is
    % a problem since iRightDataSegmentEnd < iLeftDataSegmentBegin

    %if(j == numberOfGaps) % the very last gap added to make the length a power of 2 or last gap + gap added to make it a power of two length
    if(lengthOfRightDataSegment == 0)

        gapIndices = (iGapStart:iGapEnd)';
        % last gap introduced to make the length a power of 2
        iRightDataSegmentBegin = 1;
        iRightDataSegmentEnd = min(currentGapSize+1, gapLocations(j,1)-1);

        lengthOfRightDataSegment = iRightDataSegmentEnd;

        rightTaperWeights = (1 - (0:(currentGapSize-1))./(currentGapSize-1));
        rightTaperWeights = rightTaperWeights';

        nExtendedlength = length(timeSeriesWithGaps); % extended length is a power of 2
        timeSeriesWithGapsTemp = timeSeriesWithGaps;

        nTimeSteps = (1:nOriginalLength+currentGapSize)'; % nTimeSteps now runs from 1:a power of 2 length ( > nOriginalLength)
        %nTimeSteps = (1:nExtendedlength)'; % nTimeSteps now runs from 1:a power of 2 length ( > nOriginalLength)
        indexOfAvailable = (1:iGapStart-1)'; % what is available is the original time series

        if(currentGapSize > length(indexOfAvailable))
            nTimeSteps = (iLeftDataSegmentBegin:2*iLeftDataSegmentEnd)';
            nExtendedlength = 2*iLeftDataSegmentEnd - 1;

            iGapEnd = nExtendedlength;
            % this temp time series extends to twice the left segment

            timeSeriesWithGapsTemp(nExtendedlength+1:nExtendedlength+iLeftDataSegmentEnd) = timeSeriesWithGaps(1:iLeftDataSegmentEnd);  % this temp time series extends beyond 2^n length
            indexOfAvailableTemp = [indexOfAvailable; (nExtendedlength+1:nExtendedlength+iLeftDataSegmentEnd)']; %available indices include those in the periodic extension

            [fittedTrend] = fit_trend(nTimeSteps, indexOfAvailableTemp, timeSeriesWithGapsTemp, maxDetrendPolyOrder); % fit trend over temp time series which extends beyond 2^n length
            fittedTrend = fittedTrend(1:nExtendedlength); % restrict to 2^n length and discard the rest

            tempTimeSeries = timeSeriesWithGapsTemp(indexOfAvailable) - fittedTrend(indexOfAvailable); % form the residuals time series
            tempTimeSeries(iLeftDataSegmentEnd+iRightDataSegmentBegin:iLeftDataSegmentEnd+iRightDataSegmentEnd) = tempTimeSeries(iRightDataSegmentBegin:iRightDataSegmentEnd); % now reflect residuals into gap

            newTimeSeries = tempTimeSeries; % copy to 'newTimeSeries' so common code for cases ('if' case and 'else' case) can be used

            newTimeSeries = newTimeSeries(:);

            newGapSize = iGapEnd-iGapStart+1;
            rightTaperWeights = (1 - (0:(newGapSize-1))./(newGapSize-1));
            rightTaperWeights = rightTaperWeights';

            leftTaperWeights = rightTaperWeights;


            taperStruct.rightTaperWeights = rightTaperWeights;
            taperStruct.leftTaperWeights = leftTaperWeights;

            taperStruct.lengthOfRightDataSegment = lengthOfRightDataSegment;
            taperStruct.lengthOfLeftDataSegment = lengthOfLeftDataSegment;

            taperStruct.iLeftDataSegmentBegin = iLeftDataSegmentBegin;
            taperStruct.iLeftDataSegmentEnd = iLeftDataSegmentEnd;

            taperStruct.iRightDataSegmentBegin = iRightDataSegmentBegin;
            taperStruct.iRightDataSegmentEnd = iRightDataSegmentEnd;
            taperStruct.currentGapSize = currentGapSize;

            filledSamples = apply_taper_to_reflected_segments(taperStruct, newTimeSeries);


            timeSeriesWithGaps(iGapStart:iGapEnd) = filledSamples + flipud(fittedTrend(iLeftDataSegmentBegin:iLeftDataSegmentEnd-1));

            warning('longgapfill:fill_long_gap_by_reflecting_segments_into_gap',...
                'gap in the end longer than the number of available samples to the left of the gap - filling iteratively...');

            timeSeriesWithGapsFilled = timeSeriesWithGaps;

            gapFillStatusStruct.successStatus = false;
            gapFillStatusStruct.rightGap = true;
            gapFillStatusStruct.gapSize = currentGapSize;
            gapFillStatusStruct.leftSegmentLength = length(indexOfAvailable);
            gapFillStatusStruct.dataGapIndicators = false(gapLocations(end,2),1);
            gapFillStatusStruct.dataGapIndicators(iGapEnd+1:end) = true;
            return


        else


            % leave the gap as it is but fill the samples beyond the gap by
            % periodic extension assume that the time series repeats after
            % every 'nExtendedlength'; now we have samples on both sides of the
            % gap to fold into the gap
            timeSeriesWithGapsTemp(nExtendedlength+1:nExtendedlength+nOriginalLength) = timeSeriesWithGaps(1:nOriginalLength);  % this temp time series extends beyond 2^n length
            indexOfAvailableTemp = [indexOfAvailable; (nExtendedlength+1:nExtendedlength+nOriginalLength)']; %available indices include those in the periodic extension

            [fittedTrend] = fit_trend(nTimeSteps, indexOfAvailableTemp, timeSeriesWithGapsTemp, maxDetrendPolyOrder); % fit trend over temp time series which extends beyond 2^n length


            fittedTrend = fittedTrend(1:nExtendedlength); % restrict to 2^n length and discard the rest

            tempTimeSeries = timeSeriesWithGapsTemp(indexOfAvailable) - fittedTrend(indexOfAvailable); % form the residuals time series


            tempTimeSeries(nOriginalLength+iRightDataSegmentBegin:nOriginalLength+iRightDataSegmentEnd) = tempTimeSeries(iRightDataSegmentBegin:iRightDataSegmentEnd); % now reflect residuals into gap


            newTimeSeries = tempTimeSeries; % copy to 'newTimeSeries' so common code for cases ('if' case and 'else' case) can be used

        end
    else
        % gaps other than the last

        gapIndices = (iGapStart:iGapEnd)';

        if(lengthOfLeftDataSegment == 0)  % data gap in the very beginning

            indexOfAvailable = (iRightDataSegmentBegin:iRightDataSegmentEnd)';
            if( (currentGapSize > length(indexOfAvailable)))
                warning('longgapfill:fill_long_gap_by_reflecting_segments_into_gap',...
                    'gap in the beginning longer than the number of available samples to the right of the gap - filling iteratively...');
                timeSeriesWithGapsFilled = timeSeriesWithGaps(1:nOriginalLength);

                gapFillStatusStruct.successStatus = false;
                gapFillStatusStruct.leftGap = true;
                gapFillStatusStruct.gapSize = currentGapSize;
                gapFillStatusStruct.rightSegmentLength = length(indexOfAvailable);
                gapFillStatusStruct.dataGapIndicators = dataGapIndicators;

                return
            end

            % now we are extrapolating into the gap - so restrict
            % polynomial order to 1


            nTimeSteps = (iGapStart:iRightDataSegmentEnd)';
            [fittedTrend] = fit_trend(nTimeSteps, indexOfAvailable, timeSeriesWithGaps,  1);

            %elseif (lengthOfRightDataSegment == 0) % this gap is now combined with power of 2 length gap, so has become the last gap and this case doesn't arise at all
        else
            % normal case, left data segment + data gap + right data segment

            nTimeSteps = (iLeftDataSegmentBegin:iRightDataSegmentEnd)';
            indexOfAvailable = setxor(nTimeSteps, gapIndices);

            %check to see whether the left and right segments span the gap
            %completely

            if(( currentGapSize > length(indexOfAvailable)))
                gapFillStatusStruct.successStatus = false;
                gapFillStatusStruct.midGap = true;
                gapFillStatusStruct.gapSize = currentGapSize;
                gapFillStatusStruct.leftSegmentLength = lengthOfLeftDataSegment;
                gapFillStatusStruct.rightSegmentLength = lengthOfRightDataSegment;
                gapFillStatusStruct.dataGapIndicators = dataGapIndicators;

                gapFillStatusStruct.dataGapIndicators(iRightDataSegmentBegin - lengthOfRightDataSegment + 1 : end ) = false;
                gapFillStatusStruct.dataGapIndicators(1: iLeftDataSegmentEnd + lengthOfLeftDataSegment -1 ) = false;

            end

            [fittedTrend] = fit_trend(nTimeSteps, indexOfAvailable, timeSeriesWithGaps, maxDetrendPolyOrder);
        end

        tempTimeSeries = timeSeriesWithGaps(indexOfAvailable) - fittedTrend(indexOfAvailable - nTimeSteps(1)+1 );

        newTimeSeries(indexOfAvailable) = tempTimeSeries;


    end

    newTimeSeries = newTimeSeries(:);

    taperStruct.rightTaperWeights = rightTaperWeights;
    taperStruct.leftTaperWeights = leftTaperWeights;

    taperStruct.lengthOfRightDataSegment = lengthOfRightDataSegment;
    taperStruct.lengthOfLeftDataSegment = lengthOfLeftDataSegment;

    taperStruct.iLeftDataSegmentBegin = iLeftDataSegmentBegin;
    taperStruct.iLeftDataSegmentEnd = iLeftDataSegmentEnd;

    taperStruct.iRightDataSegmentBegin = iRightDataSegmentBegin;
    taperStruct.iRightDataSegmentEnd = iRightDataSegmentEnd;
    taperStruct.currentGapSize = currentGapSize;

    filledSamples = apply_taper_to_reflected_segments(taperStruct, newTimeSeries);


    if(lengthOfRightDataSegment ~= 0) % not the last gap
        timeSeriesWithGaps(iGapStart:iGapEnd) = filledSamples + fittedTrend(gapIndices - nTimeSteps(1)+1); % add trend and filled in residuals
    else
        if(currentGapSize == length(iLeftDataSegmentBegin:iLeftDataSegmentEnd-1))
            timeSeriesWithGaps(iGapStart:iGapEnd) = filledSamples + flipud(fittedTrend(iLeftDataSegmentBegin:iLeftDataSegmentEnd-1));
        else % true when the incoming time series is exact power of 2 length and we need to extend it to the next power of 2 length
            timeSeriesWithGaps(iGapStart:iGapEnd) = filledSamples + flipud(fittedTrend(iLeftDataSegmentBegin:iLeftDataSegmentEnd));
        end
    end;

    if(debugFlag)
        if(j==1)
            h1 = plot(timeSeriesWithGaps,'.');
            hold on;
        end;
        h2 = plot(nTimeSteps(1:length(fittedTrend)), fittedTrend,'m.');

        h3 = plot((iGapStart:iGapEnd),timeSeriesWithGaps(iGapStart:iGapEnd),'k.-');
        legend([h1 h2 h3], {'original time series with gaps'; 'fitted trend'; 'filled time series'});
        pause(0.1);
        close all;
    end
end;

timeSeriesWithGapsFilled = timeSeriesWithGaps;

% incase there were pathological gaps in the beginning, restore the
% origianl samples
timeSeriesWithGapsFilled(~dataGapIndicatorsSaved) = timeSeriesWithGapsSaved(~dataGapIndicatorsSaved);
gapLocations = find_datagap_locations(dataGapIndicatorsSaved);

return

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function filledSamples = apply_taper_to_reflected_segments(taperStruct, newTimeSeries)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rightTaperWeights = taperStruct.rightTaperWeights;
leftTaperWeights  = taperStruct.leftTaperWeights;

lengthOfRightDataSegment = taperStruct.lengthOfRightDataSegment;
lengthOfLeftDataSegment = taperStruct.lengthOfLeftDataSegment;

iLeftDataSegmentBegin = taperStruct.iLeftDataSegmentBegin;
iLeftDataSegmentEnd = taperStruct.iLeftDataSegmentEnd;

iRightDataSegmentBegin = taperStruct.iRightDataSegmentBegin;
iRightDataSegmentEnd = taperStruct.iRightDataSegmentEnd;

currentGapSize = taperStruct.currentGapSize;


if(lengthOfRightDataSegment > 0 && lengthOfLeftDataSegment > 0)
    if(lengthOfRightDataSegment > lengthOfLeftDataSegment)

        % modify right taper so that the weights are set to 1 in the regions
        % where left segment is zero

        rightTaperWeights(1:end-lengthOfLeftDataSegment+1)  = 1 ;% use the left segment as it is
        leftTaperWeights(lengthOfLeftDataSegment+1:end) = 0;

    end
    if(lengthOfRightDataSegment < lengthOfLeftDataSegment)

        % modify left taper so that the weights are set to 1 in the regions
        % where right segment is zero

        leftTaperWeights(1:end-lengthOfRightDataSegment+1)  = 1 ;% use the left segment as it is
        rightTaperWeights(lengthOfRightDataSegment+1:end) = 0;

    end;
end

if(lengthOfLeftDataSegment > 0)
    segmentReflectedFromLeft(1:lengthOfLeftDataSegment) = flipud(newTimeSeries(iLeftDataSegmentBegin:iLeftDataSegmentEnd));
    segmentReflectedFromLeft = segmentReflectedFromLeft(:);
    if(lengthOfRightDataSegment == 0)
        leftTaperWeights(:) =  1;
    end

    filledFromLeftSegment = segmentReflectedFromLeft(2:end).*leftTaperWeights(1:length(segmentReflectedFromLeft(2:end)));
    if(length(filledFromLeftSegment) < currentGapSize)
        padLength = currentGapSize - length(filledFromLeftSegment);
        filledFromLeftSegment = [filledFromLeftSegment; zeros(padLength,1)];
    end
else
    filledFromLeftSegment = [];
end

if(lengthOfRightDataSegment > 0)
    segmentReflectedFromRight(1:lengthOfRightDataSegment) = newTimeSeries(iRightDataSegmentBegin:iRightDataSegmentEnd);
    segmentReflectedFromRight =segmentReflectedFromRight(:);
    if(lengthOfLeftDataSegment == 0)
        rightTaperWeights(:) = 1;
    end

    filledFromRightSegment = flipud(segmentReflectedFromRight(2:end).*rightTaperWeights(1:length(segmentReflectedFromRight(2:end))));

    if(length(filledFromRightSegment) < currentGapSize)
        padLength = currentGapSize - length(filledFromRightSegment);
        filledFromRightSegment = [zeros(padLength,1); filledFromRightSegment ];
    end

else
    filledFromRightSegment = [];
end

if(lengthOfRightDataSegment > 0 && lengthOfLeftDataSegment > 0)
    filledSamples = filledFromLeftSegment + filledFromRightSegment;

elseif(lengthOfLeftDataSegment == 0)
    filledSamples =  filledFromRightSegment;
elseif(lengthOfRightDataSegment==0)
    filledSamples = filledFromLeftSegment;
end



return


