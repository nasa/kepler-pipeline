function requantizationOutputStruct = generate_requantization_table(requantizationTableObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function requantizationOutputStruct =
% generate_requantization_table(requantizationTableObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method takes an object 'requantizationTableObject' of type
% 'requantizationTableClasss' as input and calls several private methods to
% build the requantization table for the low guard band, nominal range, and
% the high guard band. The  'requantizationOutputStruct' contains the
% requantization table and other intermediate computations. The constant
% requantizationTableObject.requantTableLength denotes the allowable size of the
% requantization table.
%
% The following error conditions are trapped:
% (1) Requantization main table length equals or exceeds 64K - Can't create
% requantization table for the high or the low guard band
% (2) Requantization table (main and high guard band) length equals or
% exceeds 64K - Can't create requantization table for the low guard band
% If the debugFlag is set, the requantization table plot is generated.
%
%
% Input: An object of class requantizationTableClass with the following
% fieds:
%                       meanBlackTable: [84x1 double]
%         visibleCCDResidualBlackRange: [84x2 double]
%             vsmearResidualBlackRange: [84x2 double]
%             msmearResidualBlackRange: [84x2 double]
%              blackResidualBlackRange: [84x2 double]
%       virtualBlackResidualBlackRange: [84x2 double]
%        maskedBlackResidualBlackRange: [84x2 double]
%                            gainTable: [84x1 double]
%                       readNoiseTable: [84x1 double]
%     numberOfExposuresPerShortCadence: 9
%      numberOfExposuresPerLongCadence: 270
%       numberOfVirtualSmearRowsSummed: 5
%        numberOfMaskedSmearRowsSummed: 5
%           numberOfBlackColumnsSummed: 5
%                          fixedOffset: 420000
%                        guardBandHigh: 0.0500
%                    numberOfBitsInADC: 14
%                 quantizationFraction: 0.2500
%                            requantTableLength: 65536
%                        requantTableMinValue: 0
%                        requantTableMaxValue: 8388607
%                           debugLevel: 3
%
%
% Output: A structure called requantizationOutputStruct with the following
% fields:
% requantizationResultsStruct =
%                         requantizationTable: [65536x1 double]
%                      blackLevelShortCadence: 7372
%                       blackLevelLongCadence: 221171
%                     nominalHighShortCadence: 140075
%                      nominalHighLongCadence: 4202240
%                              maximumEntries: 65536
%            guardBandEarlyLowInitialStepSize: 1.0012
%           guardBandMiddleLowInitialStepSize: 1.0017
%                       guardBandHighStepSize: 160
%                 mainTableLengthShortCadence: 8864
%                  mainTableLengthLongCadence: 49430
%                    guardBandHighTableLength: 1921
%                guardBandLowFirstTableLength: 1920
%               guardBandLowSecondTableLength: 3401
%     requantizationLcMainTableVerifyFraction: [49429x1 double]
%     requantizationScMainTableVerifyFraction: [8863x1 double]
%                      quantizationFractionLc: 0.2500
%                      quantizationFractionSc: 0.2500
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

%--------------------------------------------------------------------------
% generate the main requantization table for long cadence
%--------------------------------------------------------------------------

fprintf('Generating requantization main table ...\n');
requantizationMainStruct = generate_requantization_table_main_two_fixed_offsets(requantizationTableObject);




requantTableLength = requantizationTableObject.requantTableLength;
requantTableMaxValue = requantizationTableObject.requantTableMaxValue;
requantTableMinValue = requantizationTableObject.requantTableMinValue;
tableLengthMain = requantizationMainStruct.mainTableLength;
firstEntryInMainTable = requantizationMainStruct.mainTable(1);

lastEntryInMainTable = requantizationMainStruct.mainTable(end);

lastStepSizeInMainTable = requantizationMainStruct.lastStepSize;
firstStepSizeInMainTable = requantizationMainStruct.firstStepSize;
%guardBandHigh = requantizationTableObject.guardBandHigh;

mainTableIntrinsicNoiseVariance = requantizationMainStruct.mainTableIntrinsicNoiseVariance;



%--------------------------------------------------------------------------
% check whether there is room for upper guard band table
% allocate the remaining table entries for the low and high guard bands
% divide evenly the left over space in the table to low and high end
%--------------------------------------------------------------------------

leftOverTableEntries = requantTableLength - tableLengthMain;
if(requantizationMainStruct.mainTable(end)~= requantTableMaxValue) % check whether there is room for upper guard band table

    tableLengthHighExpected = fix((requantTableMaxValue - lastEntryInMainTable)/lastStepSizeInMainTable);

    % it is possible the upper end of table may take up all the remaining
    % table space, so curtail its length
    if(tableLengthHighExpected > fix(leftOverTableEntries/2))
        tableLengthHighExpected =  fix(leftOverTableEntries/2);
    end;

    tableLengthLow = requantTableLength - (tableLengthMain + tableLengthHighExpected);

else
    % no table for upper guard band since requantTableMaxValue has already been
    % reached by the main table
    tableLengthLow = requantTableLength - tableLengthMain;
end;


%--------------------------------------------------------------------------
% correct flat / step like regions in the main table and allow for smooth transitions between
% regions
%--------------------------------------------------------------------------

% requantizationMainStruct = correct_step_like_regions_in_main_table(requantizationMainStruct, tableLengthHighExpected, tableLengthLow);
%
%
% tableLengthMain = requantizationMainStruct.mainTableLength;
% lastEntryInMainTable = requantizationMainStruct.mainTable(end);
% firstEntryInMainTable = requantizationMainStruct.mainTable(1);
%
%
% leftOverTableEntries = requantTableLength - tableLengthMain;
% if(requantizationMainStruct.mainTable(end)~= requantTableMaxValue) % check whether there is room for upper guard band table
%
%     tableLengthHighExpected = fix((requantTableMaxValue - lastEntryInMainTable)/lastStepSizeInMainTable);
%
%     % it is possible the upper end of table may take up all the remaining
%     % table space, so curtail its length
%     if(tableLengthHighExpected > fix(leftOverTableEntries/2))
%         tableLengthHighExpected =  fix(leftOverTableEntries/2);
%     end;
%
%     tableLengthLow = requantTableLength - (tableLengthMain + tableLengthHighExpected);
%
% else
%     % no table for upper guard band since requantTableMaxValue has already been
%     % reached by the main table
%     tableLengthLow = requantTableLength - tableLengthMain;
% end;

%--------------------------------------------------------------------------
% generate the requantization table for the low guard band
%--------------------------------------------------------------------------

fprintf('Generating requantization table for the low guard band ...\n');
requantizationLowStruct = generate_requantization_table_low(requantTableMinValue, firstEntryInMainTable, firstStepSizeInMainTable, tableLengthLow);

if(requantizationLowStruct.lowTable(end) == firstEntryInMainTable)
    requantizationLowStruct.lowTable = requantizationLowStruct.lowTable(1:end-1);
    requantizationLowStruct.lowTableLength = requantizationLowStruct.lowTableLength-1;
end


tableLengthLow = requantizationLowStruct.lowTableLength;
tableLengthSoFar = tableLengthMain + tableLengthLow;



tableLengthHigh  = requantTableLength - tableLengthSoFar;

if( tableLengthHigh < 0)
    error('GAR:generateMainRequantizationTable:quantizationFraction', ...
        'Error generating requantization table for high guard band');
end

%--------------------------------------------------------------------------
% generate the requantization table for the high guard band
%--------------------------------------------------------------------------

% generate the requantization table for the high guard band
fprintf('Generating requantization table for the high guard band ...\n');

requantizationHighStruct = generate_requantization_table_high(requantizationTableObject, requantizationMainStruct, tableLengthHigh );

tableLengthHigh = requantizationHighStruct.highTableLength;


% prepare output structure

requantizationOutputStruct.requantizationTable = zeros(requantizationTableObject.requantTableLength,1);

requantizationOutputStruct.requantizationTable(1:tableLengthLow) = flipud(requantizationLowStruct.lowTable);
iStartIndex = tableLengthLow + 1;

iEndIndex = iStartIndex + tableLengthMain - 1;
requantizationOutputStruct.requantizationTable(iStartIndex:iEndIndex) = requantizationMainStruct.mainTable;
iStartIndex = iEndIndex+1;

iEndIndex = iStartIndex + tableLengthHigh-1;
requantizationOutputStruct.requantizationTable(iStartIndex:iEndIndex) = requantizationHighStruct.highTable;


%-----------------------------------------------------------------------
% verification step - applies only to the nominal range of the A/D (long
% cadence main requantization table) where shot noise plays a role.
%-----------------------------------------------------------------------

fprintf('Creating verification plots ...\n');

%  2^23 bit requantization values along the x axis
%  step sizes shown below - center of the steps are marked by an 'x'
% now use the noiseVariance computed earlier
% evaluate the quantizationFraction for verification purposes

%xTable = requantizationMainStruct.mainTableFirstAttempt;
xTable = requantizationMainStruct.mainTable;
stepSizes = abs(diff(xTable));
originalQuantizationNoiseVariance = requantizationMainStruct.mainTableOriginalQuantizationNoiseVariance;

noiseSigma      = sqrt(mainTableIntrinsicNoiseVariance);

% get original quantization noise & rss with requantization noise:

if(requantizationTableObject.rssOutOriginalQuantizationNoiseFlag)
    % switchValue is ON for RSS'ing out originalQuantizationNoise
    totalQuantizationNoiseSigma = sqrt(originalQuantizationNoiseVariance + stepSizes.^2/12);
    requantizationMainTableVerifyFraction = totalQuantizationNoiseSigma./noiseSigma;
else
    totalQuantizationNoiseSigma = sqrt(stepSizes.^2/12);
    requantizationMainTableVerifyFraction = totalQuantizationNoiseSigma./noiseSigma;
end

%--------------------------------------------------------------------------
% plot if the debugFlag is set
%--------------------------------------------------------------------------
if (requantizationTableObject.debugLevel)
    close all;
    plot(requantizationMainTableVerifyFraction,  'b-');

    grid on;
    set(gca,'FontSize',10);

    ylabel('StepSize/(sqrt(12)* IntrinsicNoise \sigma)');
    xlabel('Requantization Table Index');
    title( 'Requantization Table Nominal Range (Main Table) Verification');

    isOrientationLandscapeFlag = true;
    plot_to_file('requantization_verify_table', isOrientationLandscapeFlag);
end



%--------------------------------------------------------------------------
% plot if the debugFlag is set
%--------------------------------------------------------------------------
if (requantizationTableObject.debugLevel)
    close all;
    % first plot the requantization table for the low guard band
    yTableLow = 1:tableLengthLow;
    h1 = plot(requantizationOutputStruct.requantizationTable(1:tableLengthLow), yTableLow,  'r.-');
    hold on;

    % next plot the requantization table for the nominal range
    iStartIndex = tableLengthLow + 1;
    iEndIndex = iStartIndex + tableLengthMain-1;
    yTableMain = iStartIndex:iEndIndex;
    h2 = plot(requantizationOutputStruct.requantizationTable(iStartIndex:iEndIndex), yTableMain,  'b.-');

    % next plot the requantization table for the upper guard band
    iStartIndex = iEndIndex+1;
    iEndIndex = iStartIndex + tableLengthHigh-1;
    yTableHigh = iStartIndex:iEndIndex;
    h3 = plot(requantizationOutputStruct.requantizationTable(iStartIndex:iEndIndex), yTableHigh,  'k.-');

    grid on;
    set(gca,'FontSize',10);

    ylabel('Quantization Table Index (nominally up to 2^1^6)');
    xlabel('Quantization Table Value (nominally up to 2^2^3) ADU');
    title( 'Quantization Table (Lower Guard Band + Main + Upper Guard Band)');


    if((~isempty(requantizationLowStruct)) && tableLengthHigh > 0)
        legend([h1 h2 h3 ], {'Lower Guard Band'; 'Nominal Range All Data Types'; 'Upper Guard Band'}, 'Location', 'NorthWest');
    end;

    if((isempty(requantizationLowStruct)) && tableLengthHigh > 0)
        legend([h2 h3 ], {'Nominal Range All Data Types'; 'Upper Guard Band'}, 'Location', 'NorthWest');
    end;

    if((isempty(requantizationLowStruct)) && tableLengthHigh == 0)
        legend( h3 , {'Nominal Range All Data Types'; }, 'Location', 'NorthWest');
    end;

    if((~isempty(requantizationLowStruct)) && tableLengthHigh  == 0)
        legend([h1 h2  ], {'Lower Guard Band'; 'Nominal Range All Data Types';}, 'Location', 'NorthWest');
    end;

    grid on;
    plot_to_file('requantization_table_entry_vs_index');

    % second plot requant table entry versu sstep size
    close all;
    % first plot the requantization table for the low guard band
    h1 = plot(requantizationOutputStruct.requantizationTable(1:tableLengthLow - 1), ...
        diff(requantizationOutputStruct.requantizationTable(1:tableLengthLow)),  'r.-');
    hold on;

    % next plot the requantization table for the nominal range
    iStartIndex = tableLengthLow + 1;
    iEndIndex = iStartIndex + tableLengthMain-1;
    h2 = plot(requantizationOutputStruct.requantizationTable(iStartIndex:iEndIndex - 1), ...
        diff(requantizationOutputStruct.requantizationTable(iStartIndex:iEndIndex)),  'b.-');

    % next plot the requantization table for the upper guard band
    iStartIndex = iEndIndex+1;
    iEndIndex = iStartIndex + tableLengthHigh-1;
    h3 = plot(requantizationOutputStruct.requantizationTable(iStartIndex:iEndIndex - 1), ...
        diff(requantizationOutputStruct.requantizationTable(iStartIndex:iEndIndex)),  'k.-');

    grid on;
    set(gca,'FontSize',10);

    ylabel('Quantization Table Step Size');
    xlabel('Quantization Table Value (nominally up to 2^2^3) ADU');
    title( 'Quantization Table (Lower Guard Band + Main + Upper Guard Band)');


    if((~isempty(requantizationLowStruct)) && tableLengthHigh > 0)
        legend([h1 h2 h3 ], {'Lower Guard Band'; 'Nominal Range All Data Types'; 'Upper Guard Band'}, 'Location', 'NorthWest');
    end;

    if((isempty(requantizationLowStruct)) && tableLengthHigh > 0)
        legend([h2 h3 ], {'Nominal Range All Data Types'; 'Upper Guard Band'}, 'Location', 'NorthWest');
    end;

    if((isempty(requantizationLowStruct)) && tableLengthHigh == 0)
        legend( h3 , {'Nominal Range All Data Types'; }, 'Location', 'NorthWest');
    end;

    if((~isempty(requantizationLowStruct)) && tableLengthHigh  == 0)
        legend([h1 h2  ], {'Lower Guard Band'; 'Nominal Range All Data Types';}, 'Location', 'NorthWest');
    end;

    grid on;
    plot_to_file('requantization_table_entry_vs_step_size');


end


requantizationOutputStruct.requantizationMainStruct = requantizationMainStruct;

requantizationOutputStruct.requantizationLowStruct = requantizationLowStruct;
requantizationOutputStruct.requantizationHighStruct = requantizationHighStruct;
requantizationOutputStruct.requantizationMainTableVerifyFraction = requantizationMainTableVerifyFraction;
requantizationOutputStruct.tableLengthLow = tableLengthLow;
requantizationOutputStruct.tableLengthMain = tableLengthMain;
requantizationOutputStruct.tableLengthHigh = tableLengthHigh;
requantizationOutputStruct.meanBlackTable = requantizationTableObject.meanBlackTable;
requantizationOutputStruct.fixedOffsetLc =  requantizationTableObject.fixedOffsetLc;
requantizationOutputStruct.fixedOffsetSc =  requantizationTableObject.fixedOffsetSc;

close all;
return;