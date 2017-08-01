function [maxExpectedRangeStruct] = ...
    compute_max_expected_range_for_all_data_types_two_fixed_offsets(requantizationTableObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [maxPositiveDeviationFromMeanBlackTable  maxNegativeDeviationFromMeanBlackTable] = ...
%     compute_max_positive_negative_deviations_from_mean_black(requantizationTableObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function computes the max positive and max negative deviations from
% the mean black across all modouts across all data types (4 LC data types
% and 6 SC data types)
%
% The black ranges for visible, black, msmear, and vsmear regions contain
% deviations from the mean black2D. The black regions have also been
% spatially coadded where appropriate.
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

% The first column in each of these black ranges contains the max deviations
% and the second column contains the min deviations and the black ranges
% are 84 x 2 long.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


inflationFactorForBufferZone        = requantizationTableObject.inflationFactorForBufferZone;
expectedSmearMaxBlackCorrectedPerReadInAdu        = requantizationTableObject.expectedSmearMaxBlackCorrectedPerReadInAdu;
expectedSmearMinBlackCorrectedPerReadInAdu        = requantizationTableObject.expectedSmearMinBlackCorrectedPerReadInAdu;
% black2D levels have been spatially coadded where appropriate


numberOfVirtualSmearRowsSummed      = requantizationTableObject.numberOfVirtualSmearRowsSummed;
numberOfMaskedSmearRowsSummed       = requantizationTableObject.numberOfMaskedSmearRowsSummed;
numberOfBlackColumnsSummed          = requantizationTableObject.numberOfBlackColumnsSummed;

fixedOffsetLc                       = requantizationTableObject.fixedOffsetLc;
fixedOffsetSc                       = requantizationTableObject.fixedOffsetSc;

guardBandHigh                       = requantizationTableObject.guardBandHigh;
numberOfBitsInADC                   = requantizationTableObject.numberOfBitsInADC;
requantTableMaxValue                = requantizationTableObject.requantTableMaxValue;





visibleCCDResidualBlackRange          = requantizationTableObject.visibleCCDResidualBlackRange;
vsmearResidualBlackRange              = requantizationTableObject.vsmearResidualBlackRange;
msmearResidualBlackRange              = requantizationTableObject.msmearResidualBlackRange;
blackResidualBlackRange               = requantizationTableObject.blackResidualBlackRange;

virtualBlackResidualBlackRange        = requantizationTableObject.virtualBlackResidualBlackRange;
maskedBlackResidualBlackRange         = requantizationTableObject.maskedBlackResidualBlackRange;

numberOfExposuresPerShortCadence      = requantizationTableObject.numberOfExposuresPerShortCadence;
numberOfExposuresPerLongCadence       = requantizationTableObject.numberOfExposuresPerLongCadence;

%----------------------------------------------------------


maxPositiveDeviationFromMeanBlackTableForVisiblePixelsLC = max(visibleCCDResidualBlackRange(:,1))*numberOfExposuresPerLongCadence;
maxNegativeDeviationFromMeanBlackTableForVisiblePixelsLC = min(visibleCCDResidualBlackRange(:,2))*numberOfExposuresPerLongCadence;


maxPositiveDeviationFromMeanBlackTableForVsmearLC = max(vsmearResidualBlackRange(:,1))*numberOfExposuresPerLongCadence;
maxNegativeDeviationFromMeanBlackTableForVsmearLC = min(vsmearResidualBlackRange(:,2))*numberOfExposuresPerLongCadence;


maxPositiveDeviationFromMeanBlackTableForMsmearLC = max(msmearResidualBlackRange(:,1))*numberOfExposuresPerLongCadence;
maxNegativeDeviationFromMeanBlackTableForMsmearLC= min(msmearResidualBlackRange(:,2))*numberOfExposuresPerLongCadence;


maxPositiveDeviationFromMeanBlackTableForBlackLC = max(blackResidualBlackRange(:,1))*numberOfExposuresPerLongCadence;
maxNegativeDeviationFromMeanBlackTableForBlackLC = min(blackResidualBlackRange(:,2))*numberOfExposuresPerLongCadence;


% short cadence


maxPositiveDeviationFromMeanBlackTableForVisiblePixelsSC = max(visibleCCDResidualBlackRange(:,1))*numberOfExposuresPerShortCadence;
maxNegativeDeviationFromMeanBlackTableForVisiblePixelsSC = min(visibleCCDResidualBlackRange(:,2))*numberOfExposuresPerShortCadence;


maxPositiveDeviationFromMeanBlackTableForVsmearSC = max(vsmearResidualBlackRange(:,1))*numberOfExposuresPerShortCadence;
maxNegativeDeviationFromMeanBlackTableForVsmearSC = min(vsmearResidualBlackRange(:,2))*numberOfExposuresPerShortCadence;


maxPositiveDeviationFromMeanBlackTableForMsmearSC = max(msmearResidualBlackRange(:,1))*numberOfExposuresPerShortCadence;
maxNegativeDeviationFromMeanBlackTableForMsmearSC = min(msmearResidualBlackRange(:,2))*numberOfExposuresPerShortCadence;


maxPositiveDeviationFromMeanBlackTableForBlackSC = max(blackResidualBlackRange(:,1))*numberOfExposuresPerShortCadence;
maxNegativeDeviationFromMeanBlackTableForBlackSC = min(blackResidualBlackRange(:,2))*numberOfExposuresPerShortCadence;

maxPositiveDeviationFromMeanBlackTableForVblackSC = max(virtualBlackResidualBlackRange(:,1))*numberOfExposuresPerShortCadence;
maxNegativeDeviationFromMeanBlackTableForVblackSC = min(virtualBlackResidualBlackRange(:,2))*numberOfExposuresPerShortCadence;

maxPositiveDeviationFromMeanBlackTableForMblackSC = max(maskedBlackResidualBlackRange(:,1))*numberOfExposuresPerShortCadence;
maxNegativeDeviationFromMeanBlackTableForMblackSC = min(maskedBlackResidualBlackRange(:,2))*numberOfExposuresPerShortCadence;


%-------------------------------------------------------------------------
% add to structure
%-------------------------------------------------------------------------
maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForVisiblePixelsLC = maxPositiveDeviationFromMeanBlackTableForVisiblePixelsLC;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForVisiblePixelsLC = maxNegativeDeviationFromMeanBlackTableForVisiblePixelsLC;


maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForVsmearLC = maxPositiveDeviationFromMeanBlackTableForVsmearLC;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForVsmearLC = maxNegativeDeviationFromMeanBlackTableForVsmearLC;


maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForMsmearLC = maxPositiveDeviationFromMeanBlackTableForMsmearLC;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForMsmearLC = maxNegativeDeviationFromMeanBlackTableForMsmearLC;


maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForBlackLC = maxPositiveDeviationFromMeanBlackTableForBlackLC;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForBlackLC = maxNegativeDeviationFromMeanBlackTableForBlackLC;


% short cadence


maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForVisiblePixelsSC = maxPositiveDeviationFromMeanBlackTableForVisiblePixelsSC;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForVisiblePixelsSC = maxNegativeDeviationFromMeanBlackTableForVisiblePixelsSC;


maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForVsmearSC = maxPositiveDeviationFromMeanBlackTableForVsmearSC;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForVsmearSC = maxNegativeDeviationFromMeanBlackTableForVsmearSC;


maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForMsmearSC = maxPositiveDeviationFromMeanBlackTableForMsmearSC ;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForMsmearSC = maxNegativeDeviationFromMeanBlackTableForMsmearSC;


maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForBlackSC = maxPositiveDeviationFromMeanBlackTableForBlackSC;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForBlackSC = maxNegativeDeviationFromMeanBlackTableForBlackSC;

maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForVblackSC = maxPositiveDeviationFromMeanBlackTableForVblackSC;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForVblackSC = maxNegativeDeviationFromMeanBlackTableForVblackSC;

maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTableForMblackSC = maxPositiveDeviationFromMeanBlackTableForMblackSC;
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTableForMblackSC = maxNegativeDeviationFromMeanBlackTableForMblackSC;




maxPositiveDeviationFromMeanBlackTable = max([maxPositiveDeviationFromMeanBlackTableForVisiblePixelsLC; maxPositiveDeviationFromMeanBlackTableForVsmearLC;...
    maxPositiveDeviationFromMeanBlackTableForMsmearLC; maxPositiveDeviationFromMeanBlackTableForBlackLC;maxPositiveDeviationFromMeanBlackTableForVisiblePixelsSC;...
    maxPositiveDeviationFromMeanBlackTableForVsmearSC; maxPositiveDeviationFromMeanBlackTableForMsmearSC; maxPositiveDeviationFromMeanBlackTableForBlackSC;...
    maxPositiveDeviationFromMeanBlackTableForVblackSC;maxPositiveDeviationFromMeanBlackTableForMblackSC]);


maxNegativeDeviationFromMeanBlackTable = min([maxNegativeDeviationFromMeanBlackTableForVisiblePixelsLC;maxNegativeDeviationFromMeanBlackTableForVsmearLC;...
    maxNegativeDeviationFromMeanBlackTableForMsmearLC;maxNegativeDeviationFromMeanBlackTableForBlackLC;maxNegativeDeviationFromMeanBlackTableForVisiblePixelsSC;...
    maxNegativeDeviationFromMeanBlackTableForVsmearSC;maxNegativeDeviationFromMeanBlackTableForMsmearSC;maxNegativeDeviationFromMeanBlackTableForBlackSC;...
    maxNegativeDeviationFromMeanBlackTableForVblackSC;maxNegativeDeviationFromMeanBlackTableForMblackSC]);









nominalHighLongCadence = ((2^numberOfBitsInADC)-1)*numberOfExposuresPerLongCadence * (1 - guardBandHigh) + ...
    maxPositiveDeviationFromMeanBlackTable + fixedOffsetLc;


if( nominalHighLongCadence > requantTableMaxValue)
    error('GAR:generateMainRequantizationTable:nominalHighLongCadence', ...
        'Error computing maxPositiveDeviationFromMeanBlackTable. nominalHighLongCadence > 2^23-1');
end




nominalHighShortCadence = ((2^numberOfBitsInADC)-1)*numberOfExposuresPerShortCadence + ...
    maxPositiveDeviationFromMeanBlackTable + fixedOffsetSc;

nominalHighLongCadence = ceil(nominalHighLongCadence);

% is there a possibility that nominalHighLongCadence > requantTableMaxValue at
% this point? (JT)
% It should never happen but still need to throw an error if such a
% condition is caught
nominalHighLongCadence = min(nominalHighLongCadence, requantTableMaxValue);




maxExpectedRangeStruct.maxPositiveDeviationFromMeanBlackTable = ceil(maxPositiveDeviationFromMeanBlackTable);
maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTable = ceil(maxNegativeDeviationFromMeanBlackTable);



maxExpectedRangeStruct.nominalHighLongCadence = ceil(nominalHighLongCadence);
maxExpectedRangeStruct.nominalHighShortCadence = ceil(nominalHighShortCadence);

% keep track of the minimum value which will go in as the first entry in
% the requant table

requantTableFirstEntry = floor(min(fixedOffsetLc,fixedOffsetSc) + maxExpectedRangeStruct.maxNegativeDeviationFromMeanBlackTable);


%--------------------------------------------------------------------------
% Black LC, Black SC
%--------------------------------------------------------------------------
maxExpectedRangeStruct.expectedMaxSCblackPixelValueInADU       = ...
    maxPositiveDeviationFromMeanBlackTableForBlackSC*inflationFactorForBufferZone + fixedOffsetSc;
maxExpectedRangeStruct.expectedMinSCblackPixelValueInADU       = ...
    fixedOffsetSc + maxNegativeDeviationFromMeanBlackTableForBlackSC*inflationFactorForBufferZone ;


if(requantTableFirstEntry > maxExpectedRangeStruct.expectedMinSCblackPixelValueInADU)
    requantTableFirstEntry = maxExpectedRangeStruct.expectedMinSCblackPixelValueInADU;
end


maxExpectedRangeStruct.expectedMaxLCblackPixelValueInADU       = ...
    maxPositiveDeviationFromMeanBlackTableForBlackLC*inflationFactorForBufferZone + fixedOffsetLc;
maxExpectedRangeStruct.expectedMinLCblackPixelValueInADU       = ...
    fixedOffsetLc + maxNegativeDeviationFromMeanBlackTableForBlackLC*inflationFactorForBufferZone ;


if(requantTableFirstEntry > maxExpectedRangeStruct.expectedMinLCblackPixelValueInADU)
    requantTableFirstEntry = maxExpectedRangeStruct.expectedMinLCblackPixelValueInADU;
end


%--------------------------------------------------------------------------
% smear LC, smear SC
%--------------------------------------------------------------------------


maxExpectedRangeStruct.expectedMaxSCsmearPixelValueInADU       = ...
    expectedSmearMaxBlackCorrectedPerReadInAdu*numberOfExposuresPerShortCadence*numberOfVirtualSmearRowsSummed*inflationFactorForBufferZone + fixedOffsetSc;

maxExpectedRangeStruct.expectedMinSCsmearPixelValueInADU       = ...
    expectedSmearMinBlackCorrectedPerReadInAdu*numberOfExposuresPerShortCadence*numberOfVirtualSmearRowsSummed/inflationFactorForBufferZone + fixedOffsetSc;

if(requantTableFirstEntry > maxExpectedRangeStruct.expectedMinSCsmearPixelValueInADU)
    requantTableFirstEntry = maxExpectedRangeStruct.expectedMinSCsmearPixelValueInADU;
end



maxExpectedRangeStruct.expectedMaxLCsmearPixelValueInADU       = ...
    expectedSmearMaxBlackCorrectedPerReadInAdu*numberOfExposuresPerLongCadence*numberOfVirtualSmearRowsSummed*inflationFactorForBufferZone + fixedOffsetLc;

maxExpectedRangeStruct.expectedMinLCsmearPixelValueInADU       = ...
    expectedSmearMinBlackCorrectedPerReadInAdu*numberOfExposuresPerLongCadence*numberOfVirtualSmearRowsSummed/inflationFactorForBufferZone + fixedOffsetLc;


if(requantTableFirstEntry > maxExpectedRangeStruct.expectedMinLCsmearPixelValueInADU)
    requantTableFirstEntry = maxExpectedRangeStruct.expectedMinLCsmearPixelValueInADU;
end


%--------------------------------------------------------------------------
% vblack/mblack SC
%--------------------------------------------------------------------------
numberOfSpatialCoadds = numberOfMaskedSmearRowsSummed*numberOfBlackColumnsSummed ;

maxExpectedRangeStruct.expectedMaxSCmblackPixelValueInADU      = ...
    maxPositiveDeviationFromMeanBlackTableForBlackSC*numberOfSpatialCoadds*inflationFactorForBufferZone + fixedOffsetSc;


maxExpectedRangeStruct.expectedMinSCmblackPixelValueInADU      = ...
    fixedOffsetSc + maxNegativeDeviationFromMeanBlackTableForBlackSC*numberOfSpatialCoadds*inflationFactorForBufferZone ;



if(requantTableFirstEntry > maxExpectedRangeStruct.expectedMinSCmblackPixelValueInADU)
    requantTableFirstEntry = maxExpectedRangeStruct.expectedMinSCmblackPixelValueInADU;
end

%--------------------------------------------------------------------------
% Visible LC, Visible SC
%--------------------------------------------------------------------------

maxExpectedRangeStruct.expectedMaxSCvisiblePixelValueInADU     = ceil(nominalHighShortCadence);

maxExpectedRangeStruct.expectedMinSCvisiblePixelValueInADU     = maxExpectedRangeStruct.expectedMinSCblackPixelValueInADU;

if(requantTableFirstEntry > maxExpectedRangeStruct.expectedMinSCvisiblePixelValueInADU )
    requantTableFirstEntry = maxExpectedRangeStruct.expectedMinSCvisiblePixelValueInADU ;
end


maxExpectedRangeStruct.expectedMaxLCvisiblePixelValueInADU     = ceil(nominalHighLongCadence);



maxExpectedRangeStruct.expectedMinLCvisiblePixelValueInADU     = maxExpectedRangeStruct.expectedMinLCblackPixelValueInADU;


if(requantTableFirstEntry > maxExpectedRangeStruct.expectedMinLCvisiblePixelValueInADU )
    requantTableFirstEntry = maxExpectedRangeStruct.expectedMinLCvisiblePixelValueInADU ;
end


maxExpectedRangeStruct.requantTableFirstEntry = requantTableFirstEntry;
return

