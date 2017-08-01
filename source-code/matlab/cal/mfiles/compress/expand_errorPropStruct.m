function T = expand_errorPropStruct( S, C, cadenceList, varargin )
% 
% function T = expand_errorPropStruct( S, C, cadenceList, varargin )
% 
% This function expands a minimized and compressed errorPropStruct from CAL
% into a full errorPropStruct for only the cadences selected. It is not
% quite the same as running 
% S = decompress_errorPropStruct(S, C);
% S = maximize_errorPropStructArray( S );
% S = S(:,cadenceList);
% In this function only the cadences requested are decompressed in the
% first place. This should run faster than decompressing all available
% cadences then selecting only those requested.
%
% INPUT:    S               =   minimized and compressed errorPropStruct from CAL;  nVars x 1
%           C               =   compressed data from CAL;                           nCompressedVars x 1
%           cadenceList     =   list of relative cadence indices;                   nCadences x 1
%                               Empty cadenceList will return all available
%                               cadences.
%           varargin        =   {1} == total number of cadences represented by 
%                               the data in the original errorPropStruct.
%                               This argument MUST BE SET in recursive calls
%                               to this function.
% OUTPUT:   T               =   full errorPropStruct for cadenceList selected;      nVars x nCadences
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



% constant
SIZE_FIELDNAME  = {'size'};

% set cadenceList
cadenceList = cadenceList(:);
if isempty(cadenceList)
    cadenceList = 1:S(1).size.xPrimitive(1);
end

% initialize output structure
T = S;

% If S is a full errorPropStruct trim the struct and decompress data
% S will be a full errorPropStruct only on the first call of the recursion

if iserrorPropStruct(T)
    
    % trim empty elements of input errorPropStruct 
    [~, varList] = iserrorPropStructVariable(T,'');
    nVariables = length(varList);
    T = T(1:nVariables);
    
    
    if ~isempty(C)
        
        % decompress data into first cadence of output struct
        T = decompress_errorPropStruct(T, C, cadenceList);
        
        % original row count of xPrimitive for the first element sets the total number of cadences
        totalCadences = T(1).size.xPrimitive(1);
    
    elseif all(ismember( cadenceList, 1:size(T,2)))
        
        T = T(:,cadenceList);
        totalCadences = length(cadenceList);
        
    else
        
        error(['PA:',mfilename,':invalidErrorPropStruct/CompressedData'],...
               'Expand function requires compatible errorPropStruct and compresseData.');        
    end

   
else
    totalCadences = varargin{1};    
end



% pick out cadences in cadenceList for all fields except .size, update the .size field
fields = setdiff( fieldnames(T), SIZE_FIELDNAME );

for j=1:length(T)

    for i=1:length(fields)
        
        if isstruct(T(j).(fields{i}))
            T(j).(fields{i}) = ...
                expand_errorPropStruct(T(j).(fields{i}), [], cadenceList, totalCadences );
            
        elseif ~isempty( T(j).(fields{i}) ) && ~isempty(T(j).size.(fields{i}))
            
            tempArray = T(j).(fields{i});
            
            minimizedSize = size(tempArray);            
            originalSize = T(j).size.(fields{i});
            
            % get size of original elements stacked in the cadence dimension
            elementSize = originalSize(1) / totalCadences;
            
            % set up array of indices to pick out            
            pick = elementSize.*cadenceList(:)';
            for c = 1:elementSize-1
                pick = [ elementSize.*cadenceList(:)' - c; pick];                           %#ok<AGROW>
            end
            pick = pick(:);
            
            % The conditional on pick 'em is a bit of overkill since
            % minimizedSize(1) == 1 OR minimizedSize(1) == originalSize(1),
            % there is no in between. Note this leaves any decompressed
            % data alone since it has been decompressed only for the
            % cadences requested, not the full original matrix.
            
            % pick 'em
            if( all( pick <= minimizedSize(1)) )
                T(j).(fields{i}) = tempArray(pick,:);
            end
           
            % update size
            T(j).size.(fields{i}) = [length(pick), originalSize(2)];
        end
    end
end


% maximize if returning from the first call
if iserrorPropStruct(S)
    T = maximize_errorPropStructArray(T);      
end
