function requantizationLowStruct = generate_requantization_table_low(requantTableMinValue,firstEntryInMainTable,firstStepSizeInMainTable, lowEndTableLength)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function requantizationLowStruct =
% generate_requantization_table_low(requantTableMinValue,firstEntryInMainTable,fir
% stStepSizeInMainTable, lowEndTableLength)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method takes an object 'requantizationTableObject' of type
% 'requantizationTableClasss' as input (along with other parameters and
% precomputed constants) and builds the requantization table for the
% lower guard band.
%
% Input:
%           (1) requantTableMinValue - miimum values in the requantization table 0
%           (governed by the FS-GS ICD)
%           (2) firstEntryInMainTable
%           (3) firstStepSizeInMainTable
%           (4) lowEndTableLength - allocated table length for the low end of
%           the quantization table
%
% Output: A structure requantizationLowStruct with the following fields:
%             lowTable
%             lowTableLength
%             stepSize
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Calls: Subfunction 'compute_step_size_for_guardband_low'
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% After filling the requantization table for the nominal range (say n1
% entries) and the high guard band range (n2 entries), only 2^16-(n1+n2)
% entries are available for the low guard band table. Coomputing the step
% size for the lower guard band with the condition that the table for the
% low guard band make use of all the available 2^16-(n1+n2) entries is non
% trivial. As we move from the low end of the nomianl range to 0 value
% covered by the low guard band, the step size gets bigger and bigger
% (follows a geometric sequence). This subfunction determines the best
% stepsize to start with such that as the step size is inflated the total
% number of entries stay close to 2^16-(n1+n2).
%
% A try - catch block is used in this subfunction to trap the errors thrown
% by the built-in function fzero. The initial guess, which forms the range
% over which a root is searched for, is adjusted and fzero is invoked
% again.
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
fprintf('generating requantization table for the lower guard band range..\n');


% Setup for while loop:
if(lowEndTableLength == 1)

    requantizationLowStruct.lowTable = requantTableMinValue;
    requantizationLowStruct.lowTableLength = 1;
    requantizationLowStruct.stepSize = firstEntryInMainTable - requantTableMinValue;

    return;

end;

% calculate step size here (for explantion, see above)
% The equation to be solved to arrive at the correct step size is as
% follows:
% lowEndTableLength = number of steps N
% solve for x where x is the addjustment to the current step size
% firstStepSizeInMainTable * SUM(i=0toN (1+x)^i) = (firstEntryInMainTable -
% firstStepSizeInMainTable)
% Remembering SUM(i=0toN (1+x)^i) can be simplified as [1 -(1+x)^(N+1)]/[1-(1+x)]
% the equation to be solved can be set up easily.


%
stepSize = compute_step_size_for_guardband(round(firstEntryInMainTable/firstStepSizeInMainTable), lowEndTableLength);
stepSize = (1+stepSize);



% pre allocate memory
requantizationTableLow   =  zeros(lowEndTableLength,1);
iIndex = 1;
requantizationTableLow(iIndex) = firstEntryInMainTable - firstStepSizeInMainTable;
% Do while you've not reached the end - which is 0
while (requantizationTableLow(iIndex) > requantTableMinValue)
    % Next quantization level
    stepSizeNew = (stepSize^iIndex)*firstStepSizeInMainTable;

    % add the step size to the previous quantization level to find new level
    % ensure at least one bit is added to the new level
    iIndex = iIndex+1;
    requantizationTableLow(iIndex)   = requantizationTableLow(iIndex-1) - max(round(stepSizeNew),1);

    if(requantizationTableLow(iIndex) < requantTableMinValue)
        requantizationTableLow(iIndex) = requantTableMinValue;
        break;
    end;
    if(iIndex >= lowEndTableLength)
        requantizationTableLow(iIndex) = requantTableMinValue;
        break;
    end;
end

% Limit result to 'used' area
requantizationTableLow(iIndex) = requantTableMinValue;
requantizationTableLow = requantizationTableLow(1:iIndex);


requantizationLowStruct.lowTable = requantizationTableLow;
requantizationLowStruct.lowTableLength = iIndex;
requantizationLowStruct.stepSize = stepSize;

return;

