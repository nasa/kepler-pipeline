
function   [timeSeriesWithGapsFilled, gapLocations] = ...
    fill_long_gap_iteratively_reflecting_segments_into_gap(timeSeriesWithGaps, ...
    longDataGapIndicators, maxDetrendPolyOrder, debugFlag)
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

nOriginalLength = length(longDataGapIndicators);


[timeSeriesWithGapsFilled, gapLocations, gapFillStatusStruct] = ...
    fill_long_gap_by_reflecting_segments_into_gap(timeSeriesWithGaps, ...
    longDataGapIndicators, maxDetrendPolyOrder, debugFlag);

if(~gapFillStatusStruct.successStatus) % gap too big to fill
    % see whether the gap was located in the beginning or end or in the
    % middle
    
    if(gapFillStatusStruct.leftGap) % first gap too big to fill
        timeSeriesWithGapsFilled = timeSeriesWithGaps;
        while(any(gapFillStatusStruct.dataGapIndicators))
            
            longDataGapIndicators = gapFillStatusStruct.dataGapIndicators;
            timeSeriesWithGapsFilled(longDataGapIndicators) = 0;
            startCadence = max(gapFillStatusStruct.gapSize - gapFillStatusStruct.rightSegmentLength + 2 , 1);
            
            shortenedTimeSeriesWithGaps = timeSeriesWithGapsFilled( startCadence : end);
            shortenedTimeSeriesGapIndicators  = longDataGapIndicators(startCadence : end);
            
            % this time gap fill will succeed and will return a power of 2
            % length time series - so truncate to correct length and
            % iterate till all gaps are filled
            
            [timeSeriesWithGapsFilled2 ]  = ...
                fill_long_gap_by_reflecting_segments_into_gap(shortenedTimeSeriesWithGaps, ...
                shortenedTimeSeriesGapIndicators, maxDetrendPolyOrder, debugFlag);
            
            timeSeriesWithGapsFilled(startCadence : end) = ...
                timeSeriesWithGapsFilled2(1:length(shortenedTimeSeriesGapIndicators));
            gapFillStatusStruct.dataGapIndicators(startCadence : end) = false;
            gapFillStatusStruct.gapSize = length(1:startCadence-1);
        end
        timeSeriesWithGapsFilled = timeSeriesWithGapsFilled2; % power of 2 length filled time series
        
        if(sum(gapFillStatusStruct.dataGapIndicators) > 0) % there is right gap remaining to be filled
            longDataGapIndicators = gapFillStatusStruct.dataGapIndicators;
            
            [timeSeriesWithGapsFilled, gapLocations, gapFillStatusStruct] = ...
                fill_long_gap_by_reflecting_segments_into_gap(timeSeriesWithGapsFilled, ...
                longDataGapIndicators, maxDetrendPolyOrder, debugFlag);
        end
    end
    
    
    if(gapFillStatusStruct.rightGap) % first gap too big to fill
        %timeSeriesWithGapsFilled = timeSeriesWithGaps;
        
        while(any(gapFillStatusStruct.dataGapIndicators))
            
            longDataGapIndicators = gapFillStatusStruct.dataGapIndicators;
            timeSeriesWithGapsFilled(longDataGapIndicators) = 0;
            
            endCadence = min(2*gapFillStatusStruct.leftSegmentLength, length(timeSeriesWithGapsFilled));
            
            shortenedTimeSeriesWithGaps = timeSeriesWithGapsFilled(1:endCadence);
            shortenedTimeSeriesGapIndicators  = longDataGapIndicators(1:endCadence);
            
            % this time gap fill will succeed and will return a power of 2
            % length time series - so truncate to correct length and
            % iterate till all gaps are filled
            
            [timeSeriesWithGapsFilled2, gapLocations, gapFillStatusStruct]  = ...
                fill_long_gap_by_reflecting_segments_into_gap(shortenedTimeSeriesWithGaps, ...
                shortenedTimeSeriesGapIndicators, maxDetrendPolyOrder, debugFlag);
            
            
            timeSeriesWithGapsFilled(1:endCadence) = ...
                timeSeriesWithGapsFilled2(1:length(shortenedTimeSeriesGapIndicators));
            gapFillStatusStruct.dataGapIndicators(1:endCadence) = false;
        end
        timeSeriesWithGapsFilled = timeSeriesWithGapsFilled2;
    end
    
    
    if(gapFillStatusStruct.midGap) % first gap too big to fill
        
        while(any(gapFillStatusStruct.dataGapIndicators))
            
            longDataGapIndicators = gapFillStatusStruct.dataGapIndicators;
            
            newTimeSeriesWithGapsFilled = timeSeriesWithGapsFilled(1:length(longDataGapIndicators));
            newTimeSeriesWithGapsFilled(longDataGapIndicators) = 0;
            
            [timeSeriesWithGapsFilled, gapLocations2, gapFillStatusStruct] = ...
                fill_long_gap_by_reflecting_segments_into_gap(newTimeSeriesWithGapsFilled, ...
                longDataGapIndicators, maxDetrendPolyOrder, debugFlag);
            
            
        end
    end
    
    
end


% find out whether the signal length is a power of 2
% if not, extend it to a length just enough to make it a power of 2.
n1 = floor(log2(nOriginalLength));
gapLocations2 = [];
if (2^n1 ~= nOriginalLength)
    n2 = n1+1;
    timeSeriesWithGapsFilled2 = [timeSeriesWithGapsFilled; zeros(2^n2-nOriginalLength,1)];
    longDataGapIndicators = [false(nOriginalLength,1); true(2^n2-nOriginalLength,1)];
    [timeSeriesWithGapsFilled, gapLocations2] = ...
        fill_long_gap_by_reflecting_segments_into_gap(timeSeriesWithGapsFilled2, ...
        longDataGapIndicators, maxDetrendPolyOrder, debugFlag);
    
end;


gapLocations = [gapLocations; gapLocations2];
return


