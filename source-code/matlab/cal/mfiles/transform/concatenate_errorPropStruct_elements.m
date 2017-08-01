function outputStruct = concatenate_errorPropStruct_elements(elementArray, outputName)
%
% This function takes input of an array of photometric errorPropStruct
% elements from CAL and concatenates them into a single errorPropStruct. It
% operates on a single cadence of data.
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

% INPUT:    elementArray    = nx1 array of photometric errorPropStruct
%                             elements from CAL. 
%           outputName      = variable name to attach to concatenated 
%                             outputStruct
% OUTPUT:   outputStruct    = single photometric errorPropStruct element
%                             containing information from all the elements
%                             in element array
%

if( isempty(elementArray) )
    outputStruct = empty_errorPropStruct;
    return;
end

% input elementArray must have no string paramters to eval()
elementArray = convert_errorPropStruct_string_paramters_to_numeric(elementArray);

% seed output and attach new variable name
outputStruct = elementArray(1);
outputStruct.variableName = outputName;

% Each errorPropStruct in the elementArray must contain the same
% transformation chain. This means the following fields must be identical
% for each element:
% elementArray().transformStructArray().transformType
% elementArray().transformStructArray().disableLevel
% elementArray().transformStructArray().yDataInputName

% get the contents of these fields for the first element
type0       = {elementArray(1).transformStructArray.transformType};
disable0    = [elementArray(1).transformStructArray.disableLevel];
yData0      = {elementArray(1).transformStructArray.yDataInputName};



for i=2:length(elementArray)
    
    % check necessary fields for matches
    type        = {elementArray(i).transformStructArray.transformType};
    disable     = [elementArray(i).transformStructArray.disableLevel];
    yData       = {elementArray(i).transformStructArray.yDataInputName};
    
    if( ~isequal(type0, type) || ~isequal(disable0, disable) || ~isequal(yData0, yData) )
        error(['CAL:',mfilename,...
            ':Transform chains not identical. Cannot concatenate transform chains']);
    end
    
    % save primitive length for gapList and others
    lengthPrimitive = length(outputStruct.xPrimitive);
    
    % concatenate root level vectors
    outputStruct.xPrimitive     = [outputStruct.xPrimitive; elementArray(i).xPrimitive];
    outputStruct.CxPrimitive    = [outputStruct.CxPrimitive; elementArray(i).CxPrimitive];
    outputStruct.row            = [outputStruct.row; elementArray(i).row];
    outputStruct.col            = [outputStruct.col; elementArray(i).col];
    
    % adjust gapList - indices listed are xPrimitive indices    
    if ~isempty(elementArray(i).gapList)
        outputStruct.gapList = [outputStruct.gapList; lengthPrimitive + elementArray(i).gapList];
    end
    
    
    for j=1:length(outputStruct.transformStructArray)
        
        % concatenate first level vectors
        if ~isempty( elementArray(i).transformStructArray(j).yIndices )
            outputStruct.transformStructArray(j).yIndices = ...
                [outputStruct.transformStructArray(j).yIndices; elementArray(i).transformStructArray(j).yIndices];
        end
        % concatenate third level vectors and arrays
        
        % scaleORweight
        if ~isempty( elementArray(i).transformStructArray(j).transformParamStruct.scaleORweight )
            a = outputStruct.transformStructArray(j).transformParamStruct.scaleORweight;
            b = elementArray(i).transformStructArray(j).transformParamStruct.scaleORweight;
            if strcmp(elementArray(i).transformStructArray(j).transformType, 'scale' )
                if ~isequal(single(a),single(b))
                    error(['CAL:',mfilename,':Scale factor not indentical. Can only concatenate identical scaling']);
                else
                    outputStruct.transformStructArray(j).transformParamStruct.scaleORweight = a;
                end
            else
                outputStruct.transformStructArray(j).transformParamStruct.scaleORweight = [a;b];
            end
        end
        
        % filterCoeffs_b
        % filterCoeffs_a
        % polyOrder
        
        
        % polyXvector
        if( ~isempty( elementArray(i).transformStructArray(j).transformParamStruct.polyXvector ) )
            a = outputStruct.transformStructArray(j).transformParamStruct.polyXvector;
            b = elementArray(i).transformStructArray(j).transformParamStruct.polyXvector;        
            if( ismember(outputStruct.transformStructArray(j).transformType, {'interpLinear','interpNearest'}) )            
                % type == interp, polyXvector == vector to interpolate to            
                outputStruct.transformStructArray(j).transformParamStruct.polyXvector = [a;max(a)+b];
            else
                % type == wPoly
                outputStruct.transformStructArray(j).transformParamStruct.polyXvector = [a;b];
            end
        
            % xIndices - for interpLinear or InterpNearest
            if( ~isempty( elementArray(i).transformStructArray(j).transformParamStruct.xIndices ) &&...
                ismember(elementArray(i).transformStructArray(j).transformType, {'interpLinear', 'interpNearest'}) )
                outputStruct.transformStructArray(j).transformParamStruct.xIndices = ...
                [outputStruct.transformStructArray(j).transformParamStruct.xIndices;...
                 max(a) + elementArray(i).transformStructArray(j).transformParamStruct.xIndices];
            end
        end
        
        % binSizes
        % FCmodelCall
        
        % userM
        if( ~isempty( elementArray(i).transformStructArray(j).transformParamStruct.userM ) )
            a = outputStruct.transformStructArray(j).transformParamStruct.userM;
            b = elementArray(i).transformStructArray(j).transformParamStruct.userM;
            rowSize = max([size(a,1),size(b,1)]);
            a = pad_2Darray(a,[rowSize,size(a,2)],0);
            b = pad_2Darray(b,[rowSize,size(b,2)],0);
            outputStruct.transformStructArray(j).transformParamStruct.userM = [a,b];
        end
        
        % xIndices - for index select
        if( ~isempty( elementArray(i).transformStructArray(j).transformParamStruct.xIndices ) &&...
                ~ismember(elementArray(i).transformStructArray(j).transformType, {'interpLinear', 'interpNearest'}) )

            outputStruct.transformStructArray(j).transformParamStruct.xIndices = ...
                [outputStruct.transformStructArray(j).transformParamStruct.xIndices;...
                 lengthPrimitive + elementArray(i).transformStructArray(j).transformParamStruct.xIndices];
             
        end         
    end
end
    
    
    