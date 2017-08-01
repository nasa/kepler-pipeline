function returnObject = get(vignettingObject, propName)

% if no property is requested return 
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
if nargin == 1
    if ~exist(vignettingObject.vignettingFile, 'file')
        error('vignetting data file does not exist');
    end
    
    runParamsObject = vignettingObject.runParamsClass;
    moduleNumber = get(runParamsObject, 'moduleNumber');
    outputNumber = get(runParamsObject, 'outputNumber');

    % Re-compute to find the 1-84 output number
    module_1_21   = [-1 0:2 -1 3:17 -1 18:20 -1];
    linearOutputNumber = outputNumber + 4*module_1_21(moduleNumber);

    % map the linear output index to the unique outputs for which
    % vignetting has been computed.
    output2Unique = Output_Map(); % function defined below
    mappedUniqueOutput = output2Unique(linearOutputNumber, 2);
    
    varString = ['v' num2str(mappedUniqueOutput)];
    
    % Load only the variable of interest
    load(vignettingObject.vignettingFile, varString);

    % Assign the loaded variable to the output variable.
    eval(['returnObject = ' varString ';']);
    
    return;
end

switch propName
    case 'className' 
        returnObject = interPixelVariabilityObject.className;

    otherwise
        error([propName,' Is not a valid interPixelVariabilityObject property']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vm = Output_Map()

vm = [
    1 10
    2 9
    3 12
    4 11
    5 6
    6 6
    7 7
    8 7
    9 9
    10 10
    11 11
    12 12
    13 9
    14 10
    15 11
    16 12
    17 25
    18 26
    19 27
    20 28
    21 22
    22 22
    23 23
    24 23
    25 25
    26 26
    27 27
    28 28
    29 10
    30 9
    31 12
    32 11
    33 6
    34 6
    35 7
    36 7
    37 22
    38 22
    39 23
    40 23
    41 42
    42 42
    43 42
    44 42
    45 22
    46 22
    47 23
    48 23
    49 6
    50 6
    51 7
    52 7
    53 10
    54 9
    55 12
    56 11
    57 25
    58 26
    59 27
    60 28
    61 22
    62 22
    63 23
    64 23
    65 25
    66 26
    67 27
    68 28
    69 9
    70 10
    71 11
    72 12
    73 9
    74 10
    75 11
    76 12
    77 6
    78 6
    79 7
    80 7
    81 10
    82 9
    83 12
    84 11];

