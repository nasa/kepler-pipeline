% script to test blob management
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


%
% test without gaps
%

clear;

load backgroundCoeffStruct_run1000

structLength(1) = 200;
structLength(2) = 400;
structLength(3) = length(backgroundCoeffStruct) - (structLength(1) + structLength(2));

testData(1).struct = backgroundCoeffStruct(1:structLength(1));
testData(2).struct = backgroundCoeffStruct(structLength(1)+1:structLength(1)+structLength(2)+1);
testData(3).struct = backgroundCoeffStruct(structLength(1)+structLength(2)+2:sum(structLength));

absStart = 10000;

for i=1:3
    bstruct(i).blob = struct_to_blob(testData(i).struct);
    if i == 1
        bstruct(i).startCadence = absStart;
    else
        bstruct(i).startCadence = bstruct(i-1).endCadence + 1;
    end
    bstruct(i).endCadence = bstruct(i).startCadence + length(testData(i).struct) - 1;
end

% we've now constructed the blobs, let's see if we can reconstruct the
% struct

[resultStruct gapList] = blob_to_struct(bstruct, 10099, 10400);

if ~all(isequal(backgroundCoeffStruct(100:400), resultStruct(1:301)))
    display('no gaps: entries not equal');
else
    display('no gaps: test passed');
end

%
% test with gaps
%

clear;

load backgroundCoeffStruct_run1000

gap = 100;
structLength(1) = 200;
structLength(2) = 400;
structLength(3) = length(backgroundCoeffStruct) - (structLength(1) + structLength(2)) - gap;

testData(1).struct = backgroundCoeffStruct(1:structLength(1));
testData(2).struct = backgroundCoeffStruct(structLength(1)+gap:structLength(1)+gap+structLength(2)+1);
testData(3).struct = backgroundCoeffStruct(structLength(1)+gap+structLength(2)+2:sum(structLength)+gap);

absStart = 10000;

for i=1:3
    bstruct(i).blob = struct_to_blob(testData(i).struct);
    if i == 1
        bstruct(i).startCadence = absStart;
    elseif i == 2
        bstruct(i).startCadence = bstruct(i-1).endCadence + gap + 1;
    else
        bstruct(i).startCadence = bstruct(i-1).endCadence + 1;
    end
    bstruct(i).endCadence = bstruct(i).startCadence + length(testData(i).struct) - 1;
end

% we've now constructed the blobs, let's see if we can reconstruct the
% struct

[resultStruct gapList] = blob_to_struct(bstruct, 10099, 10400);

if ~all(isequal(backgroundCoeffStruct(100:200), resultStruct(1:101)))
    display('gaps: first set entries not equal');
else
    display('gaps: first test passed');
end
if ~all(isequal(backgroundCoeffStruct(300:399), resultStruct(202:301)))
    display('gaps: second set entries not equal');
else
    display('gaps: second test passed');
end
