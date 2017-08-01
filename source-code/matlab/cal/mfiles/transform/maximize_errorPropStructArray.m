function outputStruct = maximize_errorPropStructArray(inputStruct, varargin)
%
% function outputStruct = maximize_errorPropStructArray(inputStruct, varargin)
%
% This function regenerates the errorPropStruct array for multiple cadences
% where fields contain nIndex x 1 arrays from the corresponding minimized 
% errorPropStruct where fields contain nCadence x nIndex arrays.
%
% INPUT:    inputStruct     = errorPropStruct which has been minimized but
%                             not compressed.
%           varargin        = {1} == list of cadences to maximize. If no
%                             list is entered or the list is empty, all
%                             available cadences will be returned.
%                             {2} == total number of cadences represented by 
%                             the data in the original errorPropStruct.
%                             This argument must be set in recursive calls
%                             to this function.
% OUTPUT:   outputStruct    = errorPropStruct array nVariables x nCadences
%                             where the fields of each array element
%                             contain nIndex x 1 arrays
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



SIZE_FIELDNAMES = {'size'};

% trim empty elements of input errorPropStruct if it is a full errorPropStruct
if(iserrorPropStruct(inputStruct))    
    [returnIndex, varList] = iserrorPropStructVariable(inputStruct,'');
    a=1;b=length(varList);
    inputStruct = inputStruct(a:b); 
    
    % original row count of xPrimitive for the first element sets the total number of cadences
    if( ~isempty(inputStruct(1).size.xPrimitive) )
        totalCadences = inputStruct(1).size.xPrimitive(1);
    else
        totalCadences = size(inputStruct(1).xPrimitive,2);
    end
else
    % set totalCadences from variable input
    totalCadences = varargin{2};    
end



% set the cadence list from variable input
cadenceList = [];
if(nargin > 1)
    cadenceList = varargin{1};
end
if(isempty(cadenceList))
    cadenceList = 1:totalCadences;
end
cadenceList = cadenceList(:);
nCadences = length(cadenceList);

% initialize output structure
outputStruct = repmat(inputStruct,1,nCadences);

% maximize all fields except the size fields
fields = setdiff( fieldnames(inputStruct), SIZE_FIELDNAMES );

for c = 1:nCadences
    cadence = cadenceList(c);
    for j=1:length(inputStruct)        
        for i=1:length(fields)            
            if( isstruct(inputStruct(j).(fields{i})) )
                outputStruct(j,c).(fields{i}) = ...
                    maximize_errorPropStructArray(inputStruct(j).(fields{i}), cadence, totalCadences );
            else
                if( ~isempty(inputStruct(j).(fields{i})) && ~isempty(inputStruct(j).size.(fields{i})) )
                    tempArray = inputStruct(j).(fields{i});
                    originalSize = inputStruct(j).size.(fields{i});
                    minimizedSize = size(tempArray);

                    if( ischar( tempArray ) || all(originalSize == 0 & minimizedSize == 0) )
                        outputStruct(j,c).(fields{i}) = tempArray;
                    else

                        % if minimized size ~= originalSize --> expand using repmat
                        if( any(minimizedSize ~= originalSize) )
                            % expand to full rows
                            if( minimizedSize(1) == 1 && originalSize(1) ~= 1 )
                                tempArray = repmat(tempArray, originalSize(1), 1);
                            end
                            % expand to full cols
                            if( minimizedSize(2) == 1 && originalSize(2) ~= 1 )
                                tempArray = repmat(tempArray, 1, originalSize(2));
                            end
                            % mismatch with original size throws an error
                            if( any( size(tempArray) ~= originalSize ) )
                                display(['original size = ',num2str(originalSize)]);
                                display(['restored size = ',num2str(minimizedSize)]);
                                disp(inputStruct(j));
                                error(['CAL:',mfilename,'Size mismatch maximizing field contents for ',fields{i}]);                            
                            end
                        end

                        % get size of original elements stacked in the cadence dimension
                        elementSize = originalSize(1) / totalCadences;

                        if( cadence <= originalSize(1) )
                            outputStruct(j,c).(fields{i}) = tempArray( 1+(cadence-1)*elementSize : cadence*elementSize, : )';
                        else
                            outputStruct(j,c).(fields{i}) = tempArray';
                        end

                    end
                end
            end
        end        
    end    
end

% remove any padding to restore original field arrays if returning from
% original call
if(iserrorPropStruct(inputStruct)) 
    outputStruct = restore_original_shape(outputStruct);
end



