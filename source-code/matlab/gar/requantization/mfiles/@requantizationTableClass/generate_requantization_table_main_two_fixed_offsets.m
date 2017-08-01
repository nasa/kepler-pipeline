function requantizationMainStruct = generate_requantization_table_main_two_fixed_offsets(requantizationTableObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function requantizationMainStruct =
% generate_requantization_table_main(requantizationTableObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method takes an object 'requantizationTableObject' of type
% 'requantizationTableClasss' as input (along with a few precomputed
% constants) and builds the requantization table for the nominal range. The
% 'requantizationMainStruct' contains the requantization nominal range
% table and other intermediate computations.
%
% Inputs: An object of  the class requantizationTableClass  with the
% following fields:
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
%                          fixedOffsetLc: 420000
%                        guardBandHigh: 0.0500
%                    numberOfBitsInADC: 14
%                 quantizationFraction: 0.2500
%                            requantTableLength: 65536
%                        requantTableMinValue: 0
%                        requantTableMaxValue: 8388607
%                           debugLevel: 3
%
% Output: A structure requantizationMainStruct with the following fields:
%                                  mainTable: [56572x1 double]
% mainTableIntrinsicNoiseVariance
%     maxPositiveDeviationFromMeanBlackTable: 1.1390e+003
%     maxNegativeDeviationFromMeanBlackTable: 4.6227e+003
%                    nominalHighShortCadence: 2.2859e+005
%                     nominalHighLongCadence: 4283378
%                            mainTableLength: 56572
%                       quantizationFraction: 0.2500
%                               lastStepSize: 162
%                              firstStepSize: 1
%                          visibleLCStepSize: [56571x1 double]
%                  visibleLCNoiseVarianceMin: [56571x1 double]
%                            blackLCStepSize: [56571x1 double]
%                    blackLCNoiseVarianceMin: [56571x1 double]
%                           vsmearLCStepSize: [56571x1 double]
%                   vsmearLCNoiseVarianceMin: [56571x1 double]
%                           msmearLCStepSize: [56571x1 double]
%                   msmearLCNoiseVarianceMin: [56571x1 double]
%                          visibleSCStepSize: [14308x1 double]
%                  visibleSCNoiseVarianceMin: [14308x1 double]
%                            blackSCStepSize: [30749x1 double]
%                    blackSCNoiseVarianceMin: [30749x1 double]
%                           vsmearSCStepSize: [30749x1 double]
%                   vsmearSCNoiseVarianceMin: [30749x1 double]
%                           msmearSCStepSize: [30749x1 double]
%                   msmearSCNoiseVarianceMin: [30749x1 double]
%                           vblackSCStepSize: [56571x1 double]
%                   vblackSCNoiseVarianceMin: [56571x1 double]
%                           mblackSCStepSize: [56571x1 double]
%                   mblackSCNoiseVarianceMin: [56571x1 double]
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

gainTable                           = requantizationTableObject.gainTable;
readNoiseTable                      = requantizationTableObject.readNoiseTable;

visibleCCDResidualBlackRange        = requantizationTableObject.visibleCCDResidualBlackRange;
vsmearResidualBlackRange            = requantizationTableObject.vsmearResidualBlackRange;
msmearResidualBlackRange            = requantizationTableObject.msmearResidualBlackRange;
blackResidualBlackRange             = requantizationTableObject.blackResidualBlackRange;

virtualBlackResidualBlackRange      = requantizationTableObject.virtualBlackResidualBlackRange;
maskedBlackResidualBlackRange       = requantizationTableObject.maskedBlackResidualBlackRange;

numberOfExposuresPerShortCadence    = requantizationTableObject.numberOfExposuresPerShortCadence;
numberOfExposuresPerLongCadence     = requantizationTableObject.numberOfExposuresPerLongCadence;
numberOfVirtualSmearRowsSummed      = requantizationTableObject.numberOfVirtualSmearRowsSummed;
numberOfMaskedSmearRowsSummed       = requantizationTableObject.numberOfMaskedSmearRowsSummed;
numberOfBlackColumnsSummed          = requantizationTableObject.numberOfBlackColumnsSummed;

fixedOffsetLc                         = requantizationTableObject.fixedOffsetLc;
fixedOffsetSc                       = requantizationTableObject.fixedOffsetSc;
quantizationFraction                = requantizationTableObject.quantizationFraction;
requantTableLength                  = requantizationTableObject.requantTableLength;
debugLevel                          = requantizationTableObject.debugLevel;
rssOutOriginalQuantizationNoiseFlag = requantizationTableObject.rssOutOriginalQuantizationNoiseFlag;

% for each data type, compute the expected range over the requantization
% table with buffer around the ranges


[maxExpectedRangeStruct] = compute_max_expected_range_for_all_data_types_two_fixed_offsets(requantizationTableObject);


% maxExpectedRangeStruct =
%     maxPositiveDeviationFromMeanBlackTable: 1139
%     maxNegativeDeviationFromMeanBlackTable: 4622.7
%                     nominalHighLongCadence: 4622784
%                    nominalHighShortCadence: 5.6799e+005
%        expectedMaxSCvisiblePixelValueInADU: 5.6799e+005
%        expectedMinSCvisiblePixelValueInADU: 4.1478e+005
%        expectedMaxLCvisiblePixelValueInADU: 4622784
%        expectedMinLCvisiblePixelValueInADU: 4.1478e+005
%          expectedMaxSCblackPixelValueInADU: 4.1942e+005
%          expectedMinSCblackPixelValueInADU: 4.1877e+005
%          expectedMaxLCblackPixelValueInADU: 4.335e+005
%          expectedMinLCblackPixelValueInADU: -1.4769e+005
%          expectedMaxSCsmearPixelValueInADU: 4.4575e+005
%          expectedMinSCsmearPixelValueInADU: 4.1942e+005
%          expectedMaxLCsmearPixelValueInADU: 1.2097e+006
%          expectedMinLCsmearPixelValueInADU: 4.1995e+005
%         expectedMaxSCmblackPixelValueInADU: 4.198e+005
%         expectedMinSCmblackPixelValueInADU: 4.0365e+005


%---------------------------------------------------------------------
% iterate if the given quantizationFraction led to a table whose size >
% requantTableLength
%---------------------------------------------------------------------

while (true)

    % preallocate memory
    requantizationTable         =  zeros(requantTableLength,1);
    requantizationTableIntrinsicNoiseVariance =  zeros(requantTableLength,1);
    requantizationTableOriginalQNoiseVariance =  zeros(requantTableLength,1);

    visibleLCStepSize           =  zeros(requantTableLength,1);
    visibleLCNoiseVarianceMin   =  zeros(requantTableLength,1);

    blackLCStepSize             =  zeros(requantTableLength,1);
    blackLCNoiseVarianceMin     =  zeros(requantTableLength,1);

    vsmearLCStepSize            =  zeros(requantTableLength,1);
    vsmearLCNoiseVarianceMin    =  zeros(requantTableLength,1);

    msmearLCStepSize            =  zeros(requantTableLength,1);
    msmearLCNoiseVarianceMin    =  zeros(requantTableLength,1);


    visibleSCStepSize           =  zeros(requantTableLength,1);
    visibleSCNoiseVarianceMin   =  zeros(requantTableLength,1);

    blackSCStepSize             =  zeros(requantTableLength,1);
    blackSCNoiseVarianceMin     =  zeros(requantTableLength,1);

    vsmearSCStepSize            =  zeros(requantTableLength,1);
    vsmearSCNoiseVarianceMin    =  zeros(requantTableLength,1);

    msmearSCStepSize            =  zeros(requantTableLength,1);
    msmearSCNoiseVarianceMin    =  zeros(requantTableLength,1);

    vblackSCStepSize            =  zeros(requantTableLength,1);
    vblackSCNoiseVarianceMin    =  zeros(requantTableLength,1);

    mblackSCStepSize            =  zeros(requantTableLength,1);
    mblackSCNoiseVarianceMin    =  zeros(requantTableLength,1);


    % Setup for while loop:

    %requantizationTable(1)      = floor(min(fixedOffsetLc,fixedOffsetSc) + maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTable);
    requantizationTable(1)      = ceil(maxExpectedRangeStruct.requantTableFirstEntry);
    if(requantizationTable(1) < 0)
        error('GAR:generate_requantization_table_main_two_fixed_offsets:ShortCadenceFixedOffset', ...
            ['generate_requantization_table_main_two_fixed_offsets: increase short cadence fixed offset as the first entry in the main table is negative and equals ' ...
            num2str(requantizationTable(1) ) ]);
    end
    requantizationMainStruct.quantizationFraction = quantizationFraction;

    iIndex = 1;

    %---------------------------------------------------------------------
    % iterate while the end of the nominal range has not been reached..
    %---------------------------------------------------------------------
    while (requantizationTable(iIndex) < maxExpectedRangeStruct.nominalHighLongCadence)


        %-------------------
        % computation step
        % Next quant level
        %-------------------

        iIndex = iIndex+1;


        %----------------------------------------------------------------------
        % get step size for every type of data and choose the minimum size
        % step among them
        %----------------------------------------------------------------------

        intrinsicNoiseVarianceMin   = zeros(10,1); % to hold min. noise variances for each data type
        minStepSize                 = zeros(10,1); % to hold min. step size for each data type
        originalQuantizationNoiseVariance = zeros(10,1); % need only to compute once - but computed anyway inside compute_minimum_step_size
        %----------------------------------------------------------------------
        % compute minimum step size for LC target aperture pixels
        %----------------------------------------------------------------------
        numberOfSpatialCoAdds  = 1;
        [minStepSize(1), intrinsicNoiseVarianceMin(1), originalQuantizationNoiseVariance(1)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerLongCadence,...
            numberOfSpatialCoAdds, visibleCCDResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetLc, rssOutOriginalQuantizationNoiseFlag);



        %----------------------------------------------------------------------
        % compute minimum step size for LC black pixels
        %----------------------------------------------------------------------

        numberOfSpatialCoAdds  = numberOfBlackColumnsSummed;
        [minStepSize(2),  intrinsicNoiseVarianceMin(2), originalQuantizationNoiseVariance(2)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerLongCadence,...
            numberOfSpatialCoAdds, blackResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetLc, rssOutOriginalQuantizationNoiseFlag);


        %----------------------------------------------------------------------
        % compute minimum step size for LC virtual smear pixels
        %----------------------------------------------------------------------
        numberOfSpatialCoAdds  = numberOfVirtualSmearRowsSummed;

        [minStepSize(3),  intrinsicNoiseVarianceMin(3), originalQuantizationNoiseVariance(3)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerLongCadence,...
            numberOfSpatialCoAdds, vsmearResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetLc, rssOutOriginalQuantizationNoiseFlag);



        %----------------------------------------------------------------------
        % compute minimum step size for LC masked smear pixels
        %----------------------------------------------------------------------
        numberOfSpatialCoAdds  = numberOfMaskedSmearRowsSummed;

        [minStepSize(4), intrinsicNoiseVarianceMin(4), originalQuantizationNoiseVariance(4)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerLongCadence,...
            numberOfSpatialCoAdds, msmearResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetLc, rssOutOriginalQuantizationNoiseFlag);


        %----------------------------------------------------------------------
        % compute minimum step size for SC target aperture pixels
        %----------------------------------------------------------------------
        numberOfSpatialCoAdds  = 1;
        [minStepSize(5),  intrinsicNoiseVarianceMin(5), originalQuantizationNoiseVariance(5)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerShortCadence,...
            numberOfSpatialCoAdds, visibleCCDResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetSc, rssOutOriginalQuantizationNoiseFlag);



        %----------------------------------------------------------------------
        % compute minimum step size for SC black pixels
        %----------------------------------------------------------------------

        numberOfSpatialCoAdds  = numberOfBlackColumnsSummed;
        [minStepSize(6), intrinsicNoiseVarianceMin(6), originalQuantizationNoiseVariance(6)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerShortCadence,...
            numberOfSpatialCoAdds, blackResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetSc, rssOutOriginalQuantizationNoiseFlag);

        % at some point this step size should be ignored since black pixel
        % values won't extend all the way into the end of the requant table




        %----------------------------------------------------------------------
        % compute minimum step size for SC virtual smear pixels
        %----------------------------------------------------------------------
        numberOfSpatialCoAdds  = numberOfVirtualSmearRowsSummed;

        [minStepSize(7), intrinsicNoiseVarianceMin(7), originalQuantizationNoiseVariance(7)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerShortCadence,...
            numberOfSpatialCoAdds, vsmearResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetSc, rssOutOriginalQuantizationNoiseFlag);

        % at some point this step size should be ignored since smear pixel
        % values won't extend all the way into the end of the requant table




        %----------------------------------------------------------------------
        % compute minimum step size for SC masked smear pixels
        %----------------------------------------------------------------------
        numberOfSpatialCoAdds  = numberOfMaskedSmearRowsSummed;

        [minStepSize(8),  intrinsicNoiseVarianceMin(8), originalQuantizationNoiseVariance(8)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerShortCadence,...
            numberOfSpatialCoAdds, msmearResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetSc, rssOutOriginalQuantizationNoiseFlag);

        %----------------------------------------------------------------------
        % compute minimum step size for SC virtual black pixel
        %----------------------------------------------------------------------
        numberOfSpatialCoAdds  = numberOfVirtualSmearRowsSummed*numberOfBlackColumnsSummed;

        [minStepSize(9),  intrinsicNoiseVarianceMin(9), originalQuantizationNoiseVariance(9)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerShortCadence,...
            numberOfSpatialCoAdds, virtualBlackResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetSc, rssOutOriginalQuantizationNoiseFlag);


        %----------------------------------------------------------------------
        % compute minimum step size for SC masked smear pixels
        %----------------------------------------------------------------------
        numberOfSpatialCoAdds  = numberOfMaskedSmearRowsSummed*numberOfBlackColumnsSummed;

        [minStepSize(10), intrinsicNoiseVarianceMin(10), originalQuantizationNoiseVariance(10)] = ...
            compute_minimum_step_size(requantizationTable(iIndex-1), numberOfExposuresPerShortCadence,...
            numberOfSpatialCoAdds, maskedBlackResidualBlackRange, gainTable, readNoiseTable, quantizationFraction, fixedOffsetSc, rssOutOriginalQuantizationNoiseFlag);


        %minStepSize(5:10) = inf; %%%%% TEST IGNORE SC DATA
        %minStepSize(1:4) = inf; %%%%%%%% TEST IGNORE LC DATA


        adjustedMinStepSize = adjust_min_step_size_for_expected_ranges(maxExpectedRangeStruct,requantizationTable, iIndex, minStepSize);

        if(isinf(min(adjustedMinStepSize)))
            [stepSize, minIndex]  = max(minStepSize);%min(minStepSize);

            % for plotting purposes
            %adjustedMinStepSize = minStepSize;
        else
            [stepSize, minIndex]  = min(adjustedMinStepSize);
        end

        requantizationTableIntrinsicNoiseVariance(iIndex) = intrinsicNoiseVarianceMin(minIndex);

        requantizationTableOriginalQNoiseVariance(iIndex) = originalQuantizationNoiseVariance(minIndex);

        visibleLCStepSize(iIndex)           =  adjustedMinStepSize(1);
        visibleLCNoiseVarianceMin(iIndex)   =  intrinsicNoiseVarianceMin(1);

        blackLCStepSize(iIndex)             =  adjustedMinStepSize(2);
        blackLCNoiseVarianceMin(iIndex)     =  intrinsicNoiseVarianceMin(2);

        vsmearLCStepSize(iIndex)            =  adjustedMinStepSize(3);
        vsmearLCNoiseVarianceMin(iIndex)    =  intrinsicNoiseVarianceMin(3);

        msmearLCStepSize(iIndex)            =  adjustedMinStepSize(4);
        msmearLCNoiseVarianceMin(iIndex)    =  intrinsicNoiseVarianceMin(4);


        visibleSCStepSize(iIndex)           =  adjustedMinStepSize(5);
        visibleSCNoiseVarianceMin(iIndex)   =  intrinsicNoiseVarianceMin(5);

        blackSCStepSize(iIndex)             =  adjustedMinStepSize(6);
        blackSCNoiseVarianceMin(iIndex)     =  intrinsicNoiseVarianceMin(6);

        vsmearSCStepSize(iIndex)            =  adjustedMinStepSize(7);
        vsmearSCNoiseVarianceMin(iIndex)    =  intrinsicNoiseVarianceMin(7);

        msmearSCStepSize(iIndex)            =  adjustedMinStepSize(8);
        msmearSCNoiseVarianceMin(iIndex)    =  intrinsicNoiseVarianceMin(8);

        vblackSCStepSize(iIndex)            =  adjustedMinStepSize(9);
        vblackSCNoiseVarianceMin(iIndex)    =  intrinsicNoiseVarianceMin(9);

        mblackSCStepSize(iIndex)            =  adjustedMinStepSize(10);
        mblackSCNoiseVarianceMin(iIndex)    =  intrinsicNoiseVarianceMin(10);

        % add the step size to the previous quantization level to find new level
        % ensure at least one bit is added to the new level
        requantizationTable(iIndex)   = requantizationTable(iIndex-1) + stepSize;


        if(iIndex >= requantTableLength-2 )
            break;
        end


    end

    % Limit result to 'used' area
    requantizationTable = requantizationTable(1:iIndex);

    requantizationTableIntrinsicNoiseVariance = requantizationTableIntrinsicNoiseVariance(2:iIndex);
    requantizationTableOriginalQNoiseVariance = requantizationTableOriginalQNoiseVariance(2:iIndex);


    if((length(requantizationTable) >= (requantTableLength-2)) && (requantizationTable(end) < maxExpectedRangeStruct.nominalHighLongCadence))
        % increase quantizationFraction by 2%
        quantizationFraction = quantizationFraction*1.01;

        warning('GAR:generateMainRequantizationTable:quantizationFraction', ...
            ['Main table: Quantization fraction increased from ' num2str(requantizationTableObject.quantizationFraction) ...
            ' to '  num2str(quantizationFraction) ' as otherwise requantization table size is exceeded']);
        requantizationMainStruct.quantizationFraction = quantizationFraction;

    else
        break;
    end;

end
if (debugLevel)
    fprintf('Finished generating requantization table ..\n');
end

requantizationMainStruct.maxExpectedRangeStruct = maxExpectedRangeStruct;
requantizationMainStruct.mainTable = requantizationTable;

requantizationMainStruct.mainTableIntrinsicNoiseVariance = requantizationTableIntrinsicNoiseVariance;
requantizationMainStruct.mainTableOriginalQuantizationNoiseVariance = requantizationTableOriginalQNoiseVariance;

requantizationMainStruct.maxPositiveDeviationFromMeanBlackTable = maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTable;

requantizationMainStruct.maxNegativeDeviationFromMeanBlackTable = maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTable;

requantizationMainStruct.nominalHighShortCadence = maxExpectedRangeStruct.nominalHighShortCadence;
requantizationMainStruct.nominalHighLongCadence = maxExpectedRangeStruct.nominalHighLongCadence;



requantizationMainStruct.mainTableLength = iIndex;
requantizationMainStruct.quantizationFraction = quantizationFraction;

requantizationMainStruct.lastStepSize = stepSize;
requantizationMainStruct.firstStepSize = requantizationTable(3) - requantizationTable(2) ;


%--------------------------------------------------------------------------
% prep for plotting
%--------------------------------------------------------------------------


%requantizationMainStruct = prepare_data_structure_for_plotting(requantizationMainStruct);

% VisibleLC
visibleLCIndex = find(~isinf(visibleLCStepSize)& (visibleLCStepSize > 0));  % find valid indices
requantizationMainStruct.visibleLCIndex = visibleLCIndex;
requantizationMainStruct.visibleLCStepSize = visibleLCStepSize(visibleLCIndex);
requantizationMainStruct.visibleLCNoiseVarianceMin = visibleLCNoiseVarianceMin(visibleLCIndex);

% BlackLC
blackLCIndex = find(~isinf(blackLCStepSize) & (blackLCStepSize > 0)); % find valid indices
requantizationMainStruct.blackLCIndex = blackLCIndex;
requantizationMainStruct.blackLCStepSize = blackLCStepSize(blackLCIndex);
requantizationMainStruct.blackLCNoiseVarianceMin = blackLCNoiseVarianceMin(blackLCIndex);

% VsmearLC
vsmearLCIndex = find(~isinf(vsmearLCStepSize) & (vsmearLCStepSize > 0)); % find valid indices
requantizationMainStruct.vsmearLCIndex = vsmearLCIndex;
requantizationMainStruct.vsmearLCStepSize = vsmearLCStepSize(vsmearLCIndex);
requantizationMainStruct.vsmearLCNoiseVarianceMin = vsmearLCNoiseVarianceMin(vsmearLCIndex);

% MsmearLC
msmearLCIndex = find(~isinf(msmearLCStepSize) & (msmearLCStepSize > 0)); % find valid indices
requantizationMainStruct.msmearLCIndex = msmearLCIndex;
requantizationMainStruct.msmearLCStepSize = msmearLCStepSize(msmearLCIndex);
requantizationMainStruct.msmearLCNoiseVarianceMin = msmearLCNoiseVarianceMin(msmearLCIndex);

% VisibleSC
visibleSCIndex = find(~isinf(visibleSCStepSize) & (visibleSCStepSize > 0)); % find valid indices
requantizationMainStruct.visibleSCIndex = visibleSCIndex;
requantizationMainStruct.visibleSCStepSize = visibleSCStepSize(visibleSCIndex);
requantizationMainStruct.visibleSCNoiseVarianceMin = visibleSCNoiseVarianceMin(visibleSCIndex);


% BlackSC
blackSCIndex = find(~isinf(blackSCStepSize) & (blackSCStepSize > 0)); % find valid indices
requantizationMainStruct.blackSCIndex = blackSCIndex;
requantizationMainStruct.blackSCStepSize = blackSCStepSize(blackSCIndex);
requantizationMainStruct.blackSCNoiseVarianceMin = blackSCNoiseVarianceMin(blackSCIndex);

% VsmearSC
vsmearSCIndex = find(~isinf(vsmearSCStepSize) & (vsmearSCStepSize > 0)); % find valid indices
requantizationMainStruct.vsmearSCIndex = vsmearSCIndex;
requantizationMainStruct.vsmearSCStepSize = vsmearSCStepSize(vsmearSCIndex);
requantizationMainStruct.vsmearSCNoiseVarianceMin = vsmearSCNoiseVarianceMin(vsmearSCIndex);

% MsmearSC
msmearSCIndex = find(~isinf(msmearSCStepSize) & (msmearSCStepSize > 0)); % find valid indices
requantizationMainStruct.msmearSCIndex = msmearSCIndex;
requantizationMainStruct.msmearSCStepSize = msmearSCStepSize(msmearSCIndex);
requantizationMainStruct.msmearSCNoiseVarianceMin = msmearSCNoiseVarianceMin(msmearSCIndex);


% VblackSC
vblackSCIndex = find(~isinf(vblackSCStepSize) & (vblackSCStepSize > 0)); % find valid indices
requantizationMainStruct.vblackSCIndex = vblackSCIndex;
requantizationMainStruct.vblackSCStepSize = vblackSCStepSize(vblackSCIndex);
requantizationMainStruct.vblackSCNoiseVarianceMin = vblackSCNoiseVarianceMin(vblackSCIndex);


% MblackSC
mblackSCIndex = find(~isinf(mblackSCStepSize) & (mblackSCStepSize > 0)); % find valid indices
requantizationMainStruct.mblackSCIndex = mblackSCIndex;
requantizationMainStruct.mblackSCStepSize = mblackSCStepSize(mblackSCIndex);
requantizationMainStruct.mblackSCNoiseVarianceMin = mblackSCNoiseVarianceMin(mblackSCIndex);


if (debugLevel)
    plot_step_sizes_for_various_data_types(requantizationMainStruct);
    plot_step_sizes_versus_table_value_for_various_data_types(requantizationMainStruct);    
    plot_noise_variances_for_various_data_types(requantizationMainStruct);

end

return;
