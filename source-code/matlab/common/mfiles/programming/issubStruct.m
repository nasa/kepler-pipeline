function result = issubStruct(A,B)
%%
%   function result = issubStruct(A,B)
%
%   Determines if A is a sub-structure of B.
%   INPUT:  A       = struct; smaller MATLAB structure (subStruct)
%           B       = struct; larger MATLAB structure (superStruct)
%   OUTPUT: result  = boolean; 1 if A is a sub-structure of B, 0 if not
%
%   A is a sub-structure of B if and only if all field 
%   names and structure hierarchy in A are contained within
%   B AND all data arrays within A are numerically equal
%   to their corresponding arrays in B. Structure inputs may be
%   arrays of structures.
%   Note that A == B also returns 1.
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

% disp(mfilename('fullpath'));

%% Seed with false result and check trivial cases first

result = 0;
% input must be structures
if(~isstruct(A) || ~isstruct(B))
    result = isequal(A,B);
    return;
end
% check empty struct cases
if(isempty(A))              % empty structs are sub-structs of all structs
    result=1;
    return;
else if(isempty(B))       % non-empty struct cannot be a sub-struct of an empty one
        return;
    end
end

%% Collect size, shape, names and types for top level input structures
% get the field names
subFieldNames = fieldnames(A);
superFieldNames = fieldnames(B);

% get struct array dimensions
subSize = size(A);
superSize = size(B);

% get the lengths of equivalent 1-D array of input structs
subLength=length(A(:));
superLength=length(B(:)); %#ok<NASGU>

% locate sub-structures in A
structID = zeros(length(subFieldNames),1);
for i=1:length(subFieldNames)
    structID(i) = isstruct(A(1).(subFieldNames{i}));
end
structsInSubFields      = find(structID==1);
notStructsInSubFields   = find(structID~=1);

% locate sub-structures in B
structID = zeros(length(superFieldNames),1);
for i=1:length(superFieldNames)
    structID(i) = isstruct(B(1).(superFieldNames{i}));
end
structsInSuperFields      = find(structID==1);
notStructsInSuperFields   = find(structID~=1); %#ok<NASGU>


%% Check for matches in top level structure
% check for matches in names
allSubNamesInSuper = sum(ismember(subFieldNames,superFieldNames))==length(subFieldNames);

% check for matching structure and size
sameSizeAndShape = (length(subSize) == length(superSize)) && sum(subSize == superSize) == length(subSize);

%% Top Level Matches - Check Content
if(allSubNamesInSuper && sameSizeAndShape)
    
    % assume match
    allNotStructsOK = 1;
    allSubsOK = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % check each non-structure element of the structure array - first not equal stops check
    iSub = 1;
    while(iSub<=subLength && allNotStructsOK && allSubsOK)

        % check arrays for numerical equality - first not equal stops check
        i=1;
        while(i<=length(notStructsInSubFields) && allNotStructsOK)      
            thisField=subFieldNames{notStructsInSubFields(i)};        
            allNotStructsOK = isequal(A(iSub).(thisField),B(iSub).(thisField));
            i=i+1;
        end
        iSub=iSub+1;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % check each structure element of the structure array - first not equal stops check
    iSub = 1;
    while(iSub<=subLength && allNotStructsOK && allSubsOK)        
        % check sub-structs on next level
        i=1;
        while(i<=length(structsInSubFields) && allSubsOK)
            thisField=subFieldNames{structsInSubFields(i)};
            if(~isempty(A(iSub).(thisField)) && ...
                    ~isempty(B(iSub).(thisField)))
                allSubsOK = issubStruct(A(iSub).(thisField),B(iSub).(thisField));
            else
                allSubsOK=0;
            end
            i=i+1;
        end 
        iSub=iSub+1;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    result = allNotStructsOK && allSubsOK;
end

%% no match at this structure level - check against sub-structures of B
if(result==0)     
    
    % pass A to the sub-structures of B until you get a match
    iSuper = 1;
    while(result==0 && iSuper<=length(structsInSuperFields))
        thisField=superFieldNames{structsInSuperFields(iSuper)};
        result = issubStruct(A,B(1).(thisField));
        iSuper=iSuper+1;
    end
end
