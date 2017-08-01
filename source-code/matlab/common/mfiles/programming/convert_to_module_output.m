function [moduleNumber outputNumber] = convert_to_module_output(index)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [moduleNumber outputNumber] = convert_to_module_output(index)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Converts module linear index (1 - 84) to {ccd module, output} pair values
%
% Inputs:
%           index: legal values are 1 - 84
% Output:
%   moduleNumber: legal values are 2-4, 6-20, and 22-24
%   outputNumber: legal values are 1 - 4
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
linearOutputIndex = (1:84)';

index = index(:); % convert to column vector
% Check for legal index value (1 - 84)
if(~isequal(intersect(linearOutputIndex,index), unique(index)))
    error('convertToModuleOutput:invalidInput','convert_to_module_output: one or more inputs are invalid');
end

[indexUnique, notUsed, sortKey] = unique(index) ;

moduleOutputLookupTable = zeros(24, 5);

legalCcdModules = [2:4, 6:20, 22:24]';


linearOutputIndex = reshape(linearOutputIndex, 4,21);
linearOutputIndex = linearOutputIndex';

moduleOutputLookupTable(legalCcdModules, :) = [legalCcdModules linearOutputIndex];

% moduleOutputLookupTable =
%      0     0     0     0     0
%      2     1     2     3     4
%      3     5     6     7     8
%      4     9    10    11    12
%      0     0     0     0     0
%      6    13    14    15    16
%      7    17    18    19    20
%      8    21    22    23    24
%      9    25    26    27    28
%     10    29    30    31    32
%     11    33    34    35    36
%     12    37    38    39    40
%     13    41    42    43    44
%     14    45    46    47    48
%     15    49    50    51    52
%     16    53    54    55    56
%     17    57    58    59    60
%     18    61    62    63    64
%     19    65    66    67    68
%     20    69    70    71    72
%      0     0     0     0     0
%     22    73    74    75    76
%     23    77    78    79    80
%     24    81    82    83    84


% Reference the look-up table to get the correct ouput number
leaveFirstColumnOutTable = moduleOutputLookupTable(:,2:5);

[commonEntries linearIndex] = intersect(leaveFirstColumnOutTable(:), indexUnique);

[moduleNumberUnique outputNumberUnique] = ind2sub([24, 4],linearIndex);
moduleNumber = moduleNumberUnique(sortKey) ;
outputNumber = outputNumberUnique(sortKey) ;

return;
