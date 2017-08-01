function [x, Cx] = cascade_transformations(errorPropStruct, variableName, varargin)
%
% function [x, Cx] = cascade_transformations(errorPropStruct, variableName, varargin)
%
% Cascade the transformation chain for a particular variableName from the 
% primitive data and transformations stored in errorPropStruct.
%
%   INPUT:  errorPropStruct     = error propagation struct built using
%                                 append_transform.m
%           variableName        = name of variable being tracked in
%                                 errorPropStruct
%           varargin            = indices = varargin{1}. Propagate primitive data for only the
%                                 indices in this list . indices = [] -->
%                                 propagate all primitive indices.
%                               = level = varargin{2}. Propagate to the end
%                                 of errorPropStruct.transformStructArray(level). 
%                                 Default is to propagate to the end of
%                                 transformStructArray.
%                               = mode = varargin{3}. Controls which data to propagate
%                                 mode = 0 --> propagate both x and Cx (default)
%                                 mode = 1 --> propagate x, Cx == 0
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

% compressed data indicator
COMPRESSED_DATA = 'SVD';

varIndex = iserrorPropStructVariable(errorPropStruct, variableName);

if(varIndex)
    
    % check for variable input
    indices = [];    
    level = length(errorPropStruct(varIndex).transformStructArray);
    mode = 0;
    if(nargin>2)
        if(~isempty(varargin{1}))
            indices = varargin{1};
        end
        if(nargin>3)
            if(~isempty(varargin{2}))
                level = varargin{2};
            end
            if(nargin>4)
                if(varargin{3}==1)
                    mode = 1;
                end
            end
        end
    end

    
    % get primitive data and covariance
    x = errorPropStruct(varIndex).xPrimitive;
    Cx = errorPropStruct(varIndex).CxPrimitive;
    
    %     % if all indices are gapped return zeros the size of x and Cx primitive data - no transforms performed
%     gapList = sort(errorPropStruct(varIndex).gapList);
%     if isequal(gapList(:)', 1:length(errorPropStruct(varIndex).xPrimitive) )
%         x = zeros(size(x));
%         Cx = zeros(size(Cx));
%         return;
%     end
        
    if(ischar(x))
        if(strcmp(x,COMPRESSED_DATA))
            error(['CAL:',mfilename,':Variable ',variableName,' data must be decompressed.']);
        else
            [x, Cx] = cascade_transformations(errorPropStruct, x, [], [], mode);
        end
    else
        
        if(mode)
            Cx = [];
        else
            % If primitive covariance is a vector, assume it is vector of variances,
            % e.g. [var] = [uncertainties].^2. Make Cx into a sparse diagonal matrix.
            % Otherwise Cx is full covariance matrix.
            if(~isempty(Cx) && isvector(Cx))
                Cx = sparse(1:length(Cx), 1:length(Cx), Cx);
            end
        end
        
        if(~isempty(indices))
            x = x(indices);
            if(~isempty(Cx))
                Cx = Cx(indices,indices);
            end
        end        
    end
    
    
    if(~isempty(errorPropStruct(varIndex).transformStructArray(1).transformType))
        
        for i=1:level
            y = errorPropStruct(varIndex).transformStructArray(i).yDataInputName;
            yIndices = errorPropStruct(varIndex).transformStructArray(i).yIndices; 

            if(~isempty(y))
                [y, Cy] = cascade_transformations(errorPropStruct, y, [], [], mode);

                if(~isempty(yIndices))
                    if(ischar(yIndices))
                        yIndices = eval(yIndices);
                    end
                    y = y(yIndices);
                    if(~isempty(Cy))
                        Cy = Cy(yIndices,yIndices);
                    end
                end
                if(~isempty(indices))
                    y = y(indices);
                    if(~isempty(Cy))
                        Cy = Cy(indices,indices);
                    end
                end
                
            else
                y = [];
                Cy = [];
            end
            
            [x, Cx] = do_transformation(errorPropStruct(varIndex).transformStructArray(i), x, y, Cx, Cy, indices, mode);
            
            if( strcmp(errorPropStruct(varIndex).transformStructArray(i).transformType, 'userM') && ~isempty(indices) )
                x = x(indices);
                if(~isempty(Cx))
                    Cx = Cx(indices,indices);
                end
            end

        end    
    end
else
    % if variableName not found in errorPropStruct generate error
    error(['CAL:',mfilename,':Variable ',variableName,' not found.']);
end

