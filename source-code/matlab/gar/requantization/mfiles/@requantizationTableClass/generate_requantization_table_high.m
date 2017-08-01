function requantizationHighStruct = generate_requantization_table_high(requantizationTableObject, requantizationMainStruct, tableLengthHigh)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function requantizationHighStruct =
% generate_requantization_table_high(requantizationTableObject,
% requantizationMainStruct, tableLengthHigh)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method takes an object 'requantizationTableObject' of type
% 'requantizationTableClasss' as input (along with
% requantizationMainStruct) and builds the requantization table for the
% upper guard band. The 'requantizationHighStruct' contains the
% requantization table for the upper guard band and other intermediate
% computations.
%
% Input:  (1) An object of class requantizationTableClass with the following
%            fieds:
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
%                          fixedOffset: 420000
%                        guardBandHigh: 0.0500
%                    numberOfBitsInADC: 14
%                 quantizationFraction: 0.2500
%                            requantTableLength: 65536
%                        requantTableMinValue: 0
%                        requantTableMaxValue: 8388607
%                           debugLevel: 3
%
%  (2) A structure requantizationMainStruct with the following fields:
% 
%                                      mainTable: [65535x1 double]
%                mainTableIntrinsicNoiseVariance: [65534x1 double]
%     mainTableOriginalQuantizationNoiseVariance: [65534x1 double]
%         maxPositiveDeviationFromMeanBlackTable: 1139
%         maxNegativeDeviationFromMeanBlackTable: 4623
%                        nominalHighShortCadence: 567991
%                         nominalHighLongCadence: 4622784
%                                mainTableLength: 65535
%                           quantizationFraction: 0.2500
%                                   lastStepSize: 1
%                                  firstStepSize: 1
%                              visibleLCStepSize: [65534x1 double]
%                      visibleLCNoiseVarianceMin: [65534x1 double]
%                                blackLCStepSize: [65534x1 double]
%                        blackLCNoiseVarianceMin: [65534x1 double]
%                               vsmearLCStepSize: [65534x1 double]
%                       vsmearLCNoiseVarianceMin: [65534x1 double]
%                               msmearLCStepSize: [65534x1 double]
%                       msmearLCNoiseVarianceMin: [65534x1 double]
%                              visibleSCStepSize: [65534x1 double]
%                      visibleSCNoiseVarianceMin: [65534x1 double]
%                                blackSCStepSize: [65534x1 double]
%                        blackSCNoiseVarianceMin: [65534x1 double]
%                               vsmearSCStepSize: [65534x1 double]
%                       vsmearSCNoiseVarianceMin: [65534x1 double]
%                               msmearSCStepSize: [65534x1 double]
%                       msmearSCNoiseVarianceMin: [65534x1 double]
%                               vblackSCStepSize: [65534x1 double]
%                       vblackSCNoiseVarianceMin: [65534x1 double]
%                               mblackSCStepSize: [65534x1 double]
%                       mblackSCNoiseVarianceMin: [65534x1 double]
%        (3) tableLengthHigh - length of remaining entries in the
%        requantization table
%
% Output: A structure requantizationHighStruct with the following members:
%                     highTable
%                     highTableLength
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
fprintf('generating requantization table for the upper guard band range..\n');

if((requantizationMainStruct.mainTable(end) == requantizationTableObject.requantTableMaxValue)|| tableLengthHigh == 0)
    requantizationHighStruct.highTableLength = 0;
    requantizationHighStruct.highTable = [];
    return;
end;


requantTableMaxValue = requantizationTableObject.requantTableMaxValue;
mainTableHigh = requantizationMainStruct.mainTable(end);
lastStepSizeInMaintable = requantizationMainStruct.lastStepSize;

% calculate step size here (for explantion, see above)
tableRange = requantTableMaxValue -  mainTableHigh;

if(round(tableRange/lastStepSizeInMaintable) < tableLengthHigh)
    requantizationHighStruct = generate_table_with_same_step_size(requantizationTableObject, requantizationMainStruct, tableLengthHigh);
else
    requantizationHighStruct = generate_table_with_exponential_step_size(requantizationTableObject, requantizationMainStruct, tableLengthHigh);

end

return

%--------------------------------------------------------------------------
function requantizationHighStruct = generate_table_with_exponential_step_size(requantizationTableObject,...
    requantizationMainStruct, tableLengthHigh)
%--------------------------------------------------------------------------

requantTableMaxValue = requantizationTableObject.requantTableMaxValue;
mainTableHigh = requantizationMainStruct.mainTable(end);
lastStepSizeInMaintable = requantizationMainStruct.lastStepSize;

% calculate step size here (for explantion, see above)
% The equation to be solved to arrive at the correct step size is as
% follows: 
% tableLengthHigh = number of steps N
% solve for x where x is the addjustment to the current step size
% lastStepSizeInMaintable * SUM(i=0toN (1+x)^i) = (tableRange -
% lastStepSizeInMaintable)
% Remembering SUM(i=0toN (1+x)^i) can be simplified as [1 -(1+x)^(N+1)]/[1-(1+x)]
% the equation to be solved can be set up easily.

tableRange = requantTableMaxValue -  mainTableHigh;
stepSize = compute_step_size_for_guardband(round(tableRange/lastStepSizeInMaintable), tableLengthHigh);

stepSize = stepSize+1;

% pre allocate memory
requantizationTableHigh   =  zeros(tableLengthHigh,1);
iIndex = 1;
requantizationTableHigh(iIndex) = mainTableHigh + max(round(lastStepSizeInMaintable),1);

% Do while you've not reached the end - which is 0
while (requantizationTableHigh(iIndex) < requantTableMaxValue)

    % Next quantization level
    stepSizeNew = (stepSize^iIndex)*lastStepSizeInMaintable;

    % add the step size to the previous quantization level to find new level
    % ensure at least one bit is added to the new level
    iIndex = iIndex+1;
    requantizationTableHigh(iIndex)   = requantizationTableHigh(iIndex-1) + round(stepSizeNew);

    if(requantizationTableHigh(iIndex) > requantTableMaxValue)
        requantizationTableHigh(iIndex) = requantTableMaxValue;
        break;
    end;
    if(iIndex >= tableLengthHigh)
        requantizationTableHigh(iIndex) = requantTableMaxValue;
        break;
    end;
end

% Limit result to 'used' area
% set the last value to requantizationTableObject.requantTableMaxValue
requantizationTableHigh(tableLengthHigh) = requantTableMaxValue;

requantizationHighStruct.highTable = requantizationTableHigh;
requantizationHighStruct.highTableLength = iIndex;

return;


%--------------------------------------------------------------------------
function requantizationHighStruct = generate_table_with_same_step_size(requantizationTableObject, ...
    requantizationMainStruct, tableLengthHigh)
%--------------------------------------------------------------------------

requantTableMaxValue = requantizationTableObject.requantTableMaxValue;
mainTableHigh = requantizationMainStruct.mainTable(end);

% Setup for while loop:
stepSize = fix((requantTableMaxValue - mainTableHigh)/tableLengthHigh) ;

requantizationTableHigh   =  zeros(tableLengthHigh,1);
stepSize = max(round(stepSize),1);
requantizationTableHigh(1) = mainTableHigh + stepSize;


% Iterate while the end of the upper guard band has not been reached
for iIndex = 2:tableLengthHigh
    % add the same step size to the previous quantization level to find new level
    requantizationTableHigh(iIndex)   = requantizationTableHigh(iIndex-1) + stepSize;
end

% set the last value to requantizationTableObject.requantTableMaxValue
requantizationTableHigh(tableLengthHigh) = requantTableMaxValue;

requantizationHighStruct.highTable = requantizationTableHigh;
requantizationHighStruct.highTableLength = iIndex;

return;


