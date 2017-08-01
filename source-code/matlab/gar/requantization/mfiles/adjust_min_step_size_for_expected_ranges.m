
function minStepSize = adjust_min_step_size_for_expected_ranges(maxExpectedRangeStruct,requantizationTable, iIndex, minStepSize)
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


if(maxExpectedRangeStruct.expectedMaxLCvisiblePixelValueInADU < requantizationTable(iIndex-1))
    minStepSize(1) = Inf;
end
if(maxExpectedRangeStruct.expectedMinLCvisiblePixelValueInADU > requantizationTable(iIndex-1))
    minStepSize(1) = Inf;
end

if(maxExpectedRangeStruct.expectedMaxLCblackPixelValueInADU < requantizationTable(iIndex-1))
    minStepSize(2) = Inf;
end
if(maxExpectedRangeStruct.expectedMinLCblackPixelValueInADU > requantizationTable(iIndex-1))
    minStepSize(2) = Inf;
end

if(maxExpectedRangeStruct.expectedMaxLCsmearPixelValueInADU < requantizationTable(iIndex-1))
    minStepSize(3) = Inf;
end
if(maxExpectedRangeStruct.expectedMinLCsmearPixelValueInADU > requantizationTable(iIndex-1))
    minStepSize(3) = Inf;
end

if(maxExpectedRangeStruct.expectedMaxLCsmearPixelValueInADU < requantizationTable(iIndex-1))
    minStepSize(4) = Inf;
end
if(maxExpectedRangeStruct.expectedMinLCsmearPixelValueInADU > requantizationTable(iIndex-1))
    minStepSize(4) = Inf;
end

if(maxExpectedRangeStruct.expectedMaxSCvisiblePixelValueInADU < requantizationTable(iIndex-1)) % we have already adequately covered the SC visible pixel range
    minStepSize(5) = Inf;
end
if(maxExpectedRangeStruct.expectedMinSCvisiblePixelValueInADU > requantizationTable(iIndex-1)) % we have already adequately covered the SC visible pixel range
    minStepSize(5) = Inf;
end
if(maxExpectedRangeStruct.expectedMaxSCblackPixelValueInADU < requantizationTable(iIndex-1))
    minStepSize(6) = Inf;
end
if(maxExpectedRangeStruct.expectedMinSCblackPixelValueInADU > requantizationTable(iIndex-1))
    minStepSize(6) = Inf;
end
if(maxExpectedRangeStruct.expectedMaxSCsmearPixelValueInADU < requantizationTable(iIndex-1))
    minStepSize(7) = Inf;
end
if(maxExpectedRangeStruct.expectedMinSCsmearPixelValueInADU > requantizationTable(iIndex-1))
    minStepSize(7) = Inf;
end

% at some point this step size should be ignored since smear pixel
% values won't extend all the way into the end of the requant table


if(maxExpectedRangeStruct.expectedMaxSCsmearPixelValueInADU < requantizationTable(iIndex-1))
    minStepSize(8) = Inf;
end
if(maxExpectedRangeStruct.expectedMinSCsmearPixelValueInADU > requantizationTable(iIndex-1))
    minStepSize(8) = Inf;
end
% at some point this step size should be ignored since black pixel
% values won't extend all the way into the end of the requant table


if(maxExpectedRangeStruct.expectedMaxSCmblackPixelValueInADU < requantizationTable(iIndex-1))
    minStepSize(9) = Inf;
end
if(maxExpectedRangeStruct.expectedMinSCmblackPixelValueInADU > requantizationTable(iIndex-1))
    minStepSize(9) = Inf;
end
% at some point this step size should be ignored since black pixel
% values won't extend all the way into the end of the requant table

if(maxExpectedRangeStruct.expectedMaxSCmblackPixelValueInADU < requantizationTable(iIndex-1))
    minStepSize(10) = Inf;
end
if(maxExpectedRangeStruct.expectedMinSCmblackPixelValueInADU > requantizationTable(iIndex-1))
    minStepSize(10) = Inf;
end

