function requantizationMainStruct = correct_step_like_regions_in_main_table(requantizationMainStruct, tableLengthHighExpected, tableLengthLow)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function requantizationMainStruct =
% correct_step_like_regions_in_main_table(requantizationMainStruct,
% tableLengthHighExpected, tableLengthLow)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function replaces step like regions in the requantization main table
% one in the very beginning (between visible SC and black SC) and the other
% one in the middle (between the beginning of visible LC and end of visible
% SC) with smooth transitions as much a spossible. To achieve this, certain
% number of left over table entries are appropriated. The first step like
% region (between the beginnig of visible SC and end of black SC) is
% allocated 10% of left over entries, the second region is alloctaed 20% of
% left over entries. The hard coding of these numbers is not important and
% there is no plan to turn these into parameters.
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

additionalEntriesFirst = fix(0.1*(tableLengthHighExpected+tableLengthLow)); % allocate 10% of available entries for first step like region between black SC and visible SC
additionalEntriesSecond = fix(0.2*(tableLengthHighExpected+tableLengthLow));

indexOfStepSizeHighToLow =  find(diff(diff(requantizationMainStruct.mainTable)) < 0);% there should be only two step lik eregions


stepSizes  = diff(requantizationMainStruct.mainTable);
mainTable  = requantizationMainStruct.mainTable;

%---------------------------------------------------------------------------------------
% region 1 between the end of SC black and the beginning of visible SC
%---------------------------------------------------------------------------------------

indexOfFlatRegion = find(stepSizes  ==   stepSizes(indexOfStepSizeHighToLow(1)));

indexOfFlatRegion = indexOfFlatRegion(indexOfFlatRegion <= indexOfStepSizeHighToLow(1));

regionSpanFirst = mainTable(indexOfFlatRegion(end) + 1 ) - mainTable(indexOfFlatRegion(1));

stepSizeStart = stepSizes(indexOfFlatRegion(1)); % high

stepSizeEnd = stepSizes(indexOfFlatRegion(end)+1 ); % low

nEntriesForThisSpan = additionalEntriesFirst + length(indexOfFlatRegion);

stepsToTake = stepSizeStart:-1:stepSizeEnd;

nHops = length(stepsToTake);

entriesPerHop = ceil(nEntriesForThisSpan/length(stepsToTake));



%--------------------------------------------------------------------------
% figuring out how many table entries to allocate to each step is tricky
% if allocating equal number of entries to each step, does not cover the
% span, then allocate more entries to big steps
%--------------------------------------------------------------------------
if(sum(stepsToTake.*entriesPerHop) < regionSpanFirst)

    if(nHops > 2)
        j = 2;
        while(sum(stepsToTake.*entriesPerHop) <= regionSpanFirst )

            stepsToTake(j) = stepSizeStart;

            j = j+1;
            if(j >= nHops)
                break;
            end
        end

    end

else

    %--------------------------------------------------------------------------
    % if allocating equal number of entries to each step, more than cover the
    % span, then allocate more entries to small steps
    %--------------------------------------------------------------------------

    if(nHops > 2)


        if(nHops > 2)
            index = find(cumsum(stepsToTake).*entriesPerHop > regionSpanFirst , 1, 'first' );
            stepsToTake(index:end) = stepSizeEnd;

        end


    end
end

%---------------------------------------------------------------------------------------
% see whether we can span the range with entriesPerHop for each step; if not, skip this step
%---------------------------------------------------------------------------------------
if(sum(stepsToTake.*entriesPerHop) >= regionSpanFirst)

    spliceTableFirst = zeros(nEntriesForThisSpan,1);

    startIndex = 1;
    for j = 1:nHops

        if(j == 1)
            lastValue = 0;
        else
            lastValue = spliceTableFirst(startIndex - 1);
        end

        endIndex = startIndex + entriesPerHop - 1;

        spliceTableFirst(startIndex:endIndex) = lastValue + cumsum(repmat(stepsToTake(j),1,entriesPerHop));

        startIndex = endIndex + 1;

    end

    spliceTableFirst = spliceTableFirst(1:endIndex);

    indexStop = find(spliceTableFirst >= regionSpanFirst, 1, 'first');
    spliceTableFirst = spliceTableFirst(1:indexStop);

    spliceTableFirst(end) = regionSpanFirst;
    spliceTableFirst = spliceTableFirst + mainTable(indexOfFlatRegion(1));

else
    spliceTableFirst = [];
end

regionFirstLocation = indexOfFlatRegion;


%---------------------------------------------------------------------------------------
% region 2 between the end of visible SC and the beginning of visible LC
%---------------------------------------------------------------------------------------


indexOfFlatRegion = find(stepSizes  ==   stepSizes(indexOfStepSizeHighToLow(end)));

indexOfFlatRegion = indexOfFlatRegion(indexOfFlatRegion <= indexOfStepSizeHighToLow(end));

regionSpanSecond = mainTable(indexOfFlatRegion(end) + 1) - mainTable(indexOfFlatRegion(1) - 2);

stepSizeStart = stepSizes(indexOfFlatRegion(1) - 1); % high

stepSizeEnd = stepSizes(indexOfFlatRegion(end)+1); % low

nEntriesForThisSpan = additionalEntriesSecond + length(indexOfFlatRegion);

stepsToTake = stepSizeStart:-1:stepSizeEnd;

nHops = length(stepsToTake);

entriesPerHop = ceil(nEntriesForThisSpan/length(stepsToTake));

%--------------------------------------------------------------------------
% figuring out how many table entries to allocate to each step is tricky
% if allocating equal number of entries to each step, does not cover the
% span, then allocate more entries to big steps
%--------------------------------------------------------------------------
if(sum(stepsToTake.*entriesPerHop) < regionSpanSecond)

    if(nHops > 2)
        j = 2;
        while(sum(stepsToTake.*entriesPerHop) <= regionSpanSecond )

            stepsToTake(j) = stepSizeStart;

            j = j+1;
            if(j >= nHops-1)
                break;
            end
        end
    end

else
    %--------------------------------------------------------------------------
    % if allocating equal number of entries to each step, more than cover the
    % span, then allocate more entries to small steps
    %--------------------------------------------------------------------------

    if(nHops > 2)
        index = find(cumsum(stepsToTake).*entriesPerHop > regionSpanSecond, 1, 'first' );
        stepsToTake(index:end) = stepSizeEnd;

    end
end


%---------------------------------------------------------------------------------------
% see whether we can span the range with entriesPerHop for each step; if not, skip this step
%---------------------------------------------------------------------------------------
if(sum(stepsToTake.*entriesPerHop) >= regionSpanSecond)

    spliceTableSecond = zeros(nEntriesForThisSpan,1);
    startIndex = 1;
    for j = 1:nHops


        if(j == 1)
            lastValue = 0;
        else
            lastValue = spliceTableSecond(startIndex - 1);
        end

        endIndex = startIndex + entriesPerHop - 1;

        spliceTableSecond(startIndex:endIndex) = lastValue + cumsum(repmat(stepsToTake(j),1,entriesPerHop));

        startIndex = endIndex + 1;

    end

    spliceTableSecond = spliceTableSecond(1:endIndex);

    indexStop = find(spliceTableSecond >= regionSpanSecond, 1, 'first');
    spliceTableSecond = spliceTableSecond(1:indexStop);
    spliceTableSecond(end) = regionSpanSecond;
    spliceTableSecond = spliceTableSecond + mainTable(indexOfFlatRegion(1)- 2);


else
    spliceTableSecond = [];
end

regionSecondLocation = indexOfFlatRegion;

%---------------------------------------------------------------------------------------
% allocate memory to the new, perhaps extended table
% remember that the first splice table extends one entry beyond the step
% like region on the right, second splice table extends one entry beyond
% the step like region
%---------------------------------------------------------------------------------------

if(~isempty(spliceTableFirst) && ~isempty(spliceTableSecond))

    newMainTableLength = length(mainTable) - length(regionFirstLocation) - 1 - length(regionSecondLocation) - 2 + ...
        length(spliceTableFirst) + length(spliceTableSecond);

elseif(~isempty(spliceTableFirst) && isempty(spliceTableSecond))

    newMainTableLength = length(mainTable) - length(regionFirstLocation) - 1 + length(spliceTableFirst);

elseif(isempty(spliceTableFirst) && ~isempty(spliceTableSecond))

    newMainTableLength = length(mainTable) - length(regionSecondLocation) - 2 + length(spliceTableSecond);
else
    newMainTableLength = length(mainTable);

end

%---------------------------------------------------------------------------------------
% copy the entries from the main table, replace the step like regions with
% two splice tables, if they are not empty
%---------------------------------------------------------------------------------------

mainTableNew  = zeros(newMainTableLength, 1);

if(~isempty(spliceTableFirst))
    mainTableNew(1:length(spliceTableFirst)) = spliceTableFirst;


    startIndexForNewTable = length(spliceTableFirst) +1;
    endIndexForNewTable = startIndexForNewTable - 1 + length(regionFirstLocation(end)+2:regionSecondLocation(1) - 2);

else

    mainTableNew(1:regionFirstLocation(end)+1) = mainTable(1:regionFirstLocation(end)+1);

    startIndexForNewTable = regionFirstLocation(end)+2;
    endIndexForNewTable = startIndexForNewTable - 1 + length(regionFirstLocation(end)+2:regionSecondLocation(1) - 2);

end

mainTableNew(startIndexForNewTable:endIndexForNewTable) = ...
    mainTable(regionFirstLocation(end)+2:regionSecondLocation(1) - 2);

startIndexForNewTable = endIndexForNewTable + 1;


if(~isempty(spliceTableSecond))

    endIndexForNewTable = startIndexForNewTable  - 1 + length(spliceTableSecond);
    mainTableNew(startIndexForNewTable:endIndexForNewTable) = spliceTableSecond;
    mainTableNew(endIndexForNewTable+1:end) = mainTable((regionSecondLocation(end)+2):end);

else

    mainTableNew(startIndexForNewTable:end) = mainTable(regionSecondLocation(1)-1:end);

end


if(~isempty(spliceTableFirst) || ~isempty(spliceTableSecond))

    requantizationMainStruct.mainTableFirstAttempt = mainTable;
    requantizationMainStruct.mainTable = mainTableNew;

    requantizationMainStruct.mainTableLength = length(mainTableNew);

else

    warning('GAR:correct_step_like_regions_in_main_table:notEnoughEntriesLeft', ...
        'correct_step_like_regions_in_main_table: Not correcting step like regions in the requantization table as there not enough entries in the table ');

    requantizationMainStruct.mainTableFirstAttempt = mainTable;
    requantizationMainStruct.mainTable = mainTable;

    requantizationMainStruct.mainTableLength = length(mainTable);

end


return

