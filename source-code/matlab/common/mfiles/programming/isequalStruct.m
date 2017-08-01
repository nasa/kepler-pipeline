function [result, AfieldName, BfieldName] = isequalStruct(A,B,varargin)

% function [result, fieldName] = isequalStruct(A,B)
%
%   INPUT:  A, B        = two structures to compare
%           varargin{1} = boolean; true == display inequalities at top level as they are found, default = false
%           varargin{2} = tolerance with with to compare numerical values, default = 0
%           varargin{3} = boolean; true == called recursively, default = false
%   OUTPUT: result      = boolean; structures identical
%           AfieldName  = cell array; fieldnames where mismatch occurs in A
%           BfieldName  = cell array; fieldnames where mismatch occurs in B
%
%   Checks for identical equality of data structures. Structures are 
%   identical if and only if they are numerically equal AND their field 
%   names and structure match.
%
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


% ---- get input fieldnames
AfieldName = {inputname(1)};
BfieldName = {inputname(2)};

% ---- unpack variable inputs
tolerance = 0;
recursiveCall = false;
displayMismatch = false;
if nargin > 2
    tolerance = abs(varargin{1});    
    if nargin > 3
        recursiveCall = varargin{2};
        if nargin > 4
            displayMismatch = logical(varargin{3});            
        end
    end
end

% ---- check some trivial cases
% must be same data type
if ~strcmp(class(A),class(B))
    result = false;
    return;
end
% must be the same size
if ~isequal(size(A),size(B))
        result = false;
    return;
end
% empties are equal by definition  
if isempty(A) && isempty(B)
    result = true;
    % reset return fieldnames
    AfieldName = {''};
    BfieldName = {''};
    return;
end


% ---- check structures
if isstruct(A)
    
    % extract incoming filenames
    baseNameA = AfieldName;
    baseNameB = BfieldName;    
    
    % check sub-fields
    S = fieldnames(A);
    Q = fieldnames(B);
    
    % check equality of fieldnames
    result = isequal(S,Q);
    
    % if different field names, log, remove diffs and recheck remainder,
    if ~result
        % add mismatched field names to lists
        AfieldName = strcat(baseNameA,{'.'},setdiff(S,Q));
        BfieldName = strcat(baseNameB,{'.'},setdiff(Q,S));
        % check the remainder of the struct
        [tf, Aname, Bname] = isequalStruct(rmfield(A,setdiff(S,Q)),rmfield(B,setdiff(Q,S)),tolerance,true);
        if ~tf
            iA0 = length(AfieldName);
            iB0 = length(BfieldName);
            % Since isequalStruct is called with an expression (rather than a name) for arg #1 and #2, internal AfieldName and BfieldName
            % are set to empty strings ('') because of the way inputname() works. All this means is that Aname and Bname returned will start
            % with '.'. So we will omit the explicit '.' when augmenting the AfieldName and BfieldName lists here.
            AfieldName(iA0+1:iA0+length(Aname)) = strcat(baseNameA,Aname);
            BfieldName(iB0+1:iB0+length(Bname)) = strcat(baseNameB,Bname);
        end
        
    % fieldnames OK -  check contents of each field for each array element
    else
        for j = 1:length(A)
            i = 1;
            iName = 1;
            Q = S;
            while i <= length(S)
                [ tf, Aname, Bname ] = isequalStruct(A(j).(S{i}),B(j).(S{i}),tolerance,true);
                if ~tf
                    result = false;
                    % remove field from further array checks
                    Q = setdiff(Q,S{i});
                    % add unequal field name to list
                    AfieldName(iName:iName + length(Aname) - 1) = strcat(baseNameA,'.',S{i},Aname);
                    BfieldName(iName:iName + length(Bname) - 1) = strcat(baseNameB,'.',S{i},Bname);
                    iName = iName + length(Aname);
                end
                i=i+1;
            end
            S = Q;
        end
    end    
    
% ---- they're not structures - check contents      
else       
          
    % non-structure input must be identical or numerically equal within tolerance
    result = false;
    
    % check non-numeric or numeric w/tolerance == 0
    if ~isnumeric(A) || tolerance == 0
        result = isequalwithequalnans(A,B);
    end
    
    % if unequal check within tolerance for numeric input only
    if ~result && isnumeric(A) && isnumeric(B)
        result = all(all(all(abs(A-B) < ones(size(A)).*tolerance)));
    end
    
    if result
        % they're equal - return empty fieldnames
        AfieldName = {''};
        BfieldName = {''};
    end
end

% ---- display unequal results if top level call
if ~result && ~recursiveCall && displayMismatch
    for i = 1:length(AfieldName)
        disp(strcat(AfieldName{i},{'   <>    '},BfieldName{i}));
    end
end

return;