function [result, temp] = allowed_input(type, inputData)

% function result = allowed_input(type, inputData)
%
% This function checks the variable input argument for a match according to
% the transformation type. result == boolean, 1 = input is allowed, 0 = not
% allowed.
%
%   INPUT:  type        = transformation type; string
%           inputData   = transformation input data; cell array
%   OUTPUT: result      = boolean; 1 == type/data is allowed, 0 == type/data is not allowed
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

% check input arguments as passed in append_transformation(errorPropStruct, type, variableName, varargin)


temp = empty_tStruct;
numVarArgs = length(inputData);
[index, allowedTypes, allowedNumArgs] = allowed_transform(type);

result = logical(index);

if(result)
    
    temp.transformType = type;
    
    % check that the function was passed the correct input data given the transformation type 
    switch type
         case 'scale'
            if( numVarArgs == allowedNumArgs(index) && isscalar(inputData{1}) )
                temp.transformParamStruct.scaleORweight = inputData{1};
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = scalar']);
                result = false;
            end        
    % -------------------------------------------------------------------        
         case {'scaleV','wSum','wMean'}
            if( numVarArgs == allowedNumArgs(index) &&...
                    (isvector(inputData{1}) || (ischar(inputData{1}) && isvector(eval(inputData{1}))))...
                    )
                temp.transformParamStruct.scaleORweight = issmaller_as_sparse(inputData{1});
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = column vector']);
                result = false;
            end            
    % -------------------------------------------------------------------        
         case 'bin'
            if( numVarArgs == allowedNumArgs(index) &&...
                    (isvector(inputData{1}) || (ischar(inputData{1}) && isvector(eval(inputData{1}))))...
                    )
                temp.transformParamStruct.binSizes = inputData{1};
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = column vector']);
                result = false;
            end            
    % -------------------------------------------------------------------        
        case {'addV','diffV','multV','divV','concatRows'}
            if( numVarArgs == allowedNumArgs(index) && ...
                    ischar(inputData{1}) &&  ...
                    ( isempty(inputData{2}) || (isvector(inputData{2}) && isnumeric(inputData{2})) ||...
                     ( isvector(eval(inputData{2})) && isnumeric(eval(inputData{2})) ) )...
                      )
                temp.yDataInputName = inputData{1};                
                if(isnumeric(inputData{2}))
                    temp.yIndices = int32(floor(inputData{2}));
                elseif(ischar(inputData{2}))
                    temp.yIndices = inputData{2};
                end
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = string']);
                result = false;
            end
    % -------------------------------------------------------------------         
        case 'lsPolyFit'
            if( numVarArgs == allowedNumArgs(index) &&...
                    isscalar(inputData{1}) && ...
                    (isvector(inputData{2}) || (ischar(inputData{2}) && isvector(eval(inputData{2}))))...
                    )
                temp.transformParamStruct.polyOrder     = inputData{1};
                temp.transformParamStruct.polyXvector   = inputData{2};
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = {scalar, vector OR string which evals to vector}']);
                result = false;
            end
    % -------------------------------------------------------------------         
        case 'wPoly'
            if( numVarArgs == allowedNumArgs(index) && ...
                    isscalar(inputData{1}) && ...
                    (isvector(inputData{2}) || (ischar(inputData{2}) && isvector(eval(inputData{2})))) && ...
                    (isvector(inputData{3}) || (ischar(inputData{3}) && isvector(eval(inputData{3}))))...
                    )
                temp.transformParamStruct.polyOrder     = inputData{1};
                temp.transformParamStruct.polyXvector   = inputData{2};
                temp.transformParamStruct.scaleORweight = issmaller_as_sparse(inputData{3});
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = {scalar, column vector, column vector}']);
                result = false;
            end
    % -------------------------------------------------------------------         
        case 'expSum'
            % Functional form:
            % Sum of exponentials with different time constants.
            % z = sum( Ai * e^( x./Ki ) = T * A
            % Where:
            % K = vector of decay constants         == inputData{1}
            % x = vector of independent variables   == inputData{2}
            %
            % A = incoming fitted parameters w/associated covariance
            
            if( numVarArgs == allowedNumArgs(index) && ...
                    (isvector(inputData{1}) || (ischar(inputData{1}) && isvector(eval(inputData{1})))) && ...
                    (isvector(inputData{2}) || (ischar(inputData{2}) && isvector(eval(inputData{2})))))
                
                    % load inputs into transformParamStruct
                    temp.transformParamStruct.polyOrder     = inputData{1};
                    temp.transformParamStruct.polyXvector   = inputData{2};
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = {column, column vector, column vector}']);
                result = false;
            end
    % -------------------------------------------------------------------         
        case 'custom01_calFitted1DBlack'
            % Functional form:
            % Sum of linear + two exponentials(~select indices) + linear(select indices)
            % z = T * A
            %
            % Where:
            % T = [ 1;
            %      ( x - (R - mod(R,2))/2 ) ./ ( (R - mod(R,2))/2 );
            %      exp(-( x-B ) / Klong) .* ~double(mSmearSelect);
            %      exp(-( x-B ) / Kshort) .* ~double(mSmearSelect); 
            %      double(mSmearSelect);
            %      ( x .* double(mSmearSelect) - mean( x(mSmearRows).*double(mSmearSelect(mSmearRows)) ) .* double(mSmearSelect)]     
            %    
            %    x = 1:R        == black collateral rows
            %    B              == start of science rows
            %    Klong          == long decayy constant
            %    Kshort         == short decay constant
            %    mSmearRows     == list of masked smear rows used
            %    mSearSelect    == logical array indicating rows <= max(all masked smear rows)
            %
            % Assign inputs to existing parameter names (some don't really match the meaning of the variable, but they are just names):
            % inputData{1}  == [Klong, Kshort]              == scaleORweight
            % inputData{2}  == x                            == polyXvector
            % inputData{3}  == mSmearRows                   == xIndices
            % inputData{4}  == B                            == filterCoeffs_b
            % inputData{5}  == max(all masked smear rows)   == filterCoeffs_a
            
            if( numVarArgs == allowedNumArgs(index) && ...
                    (isvector(inputData{1}) && ...
                    (isvector(inputData{2}) || (ischar(inputData{2}) && isvector(eval(inputData{2})))) && ...
                    (isvector(inputData{2}) || (ischar(inputData{3}) && isvector(eval(inputData{3})))) && ...
                    isscalar(inputData{4}) && isscalar(inputData{5})))
                
                temp.transformParamStruct.scaleORweight     = inputData{1};
                temp.transformParamStruct.polyXvector       = inputData{2};
                temp.transformParamStruct.xIndices          = inputData{3};
                temp.transformParamStruct.filterCoeffs_b    = inputData{4};
                temp.transformParamStruct.filterCoeffs_a    = inputData{5};
  
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = { [vector], [vector](or string), [vector](or string), scalar, scalar }']);
                result = false;
            end
    % -------------------------------------------------------------------         
        case 'filter'
            if( numVarArgs == allowedNumArgs(index) && isvector(inputData{1}) && isvector(inputData{2}) )
                temp.transformParamStruct.filterCoeffs_b = inputData{1}(:);
                temp.transformParamStruct.filterCoeffs_a = inputData{2}(:);
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = {column vector, column vector}']);
                result = false;
            end
    % -------------------------------------------------------------------         
        case {'FCmodelScale', 'FCmodelAdd'}
            if( numVarArgs == allowedNumArgs(index) && ischar(inputData{1}) )
                temp.transformParamStruct.FCmodelCall = inputData{1};
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'", "FCmodelAdd"; inputData = string']);
                result = false;
            end
    % -------------------------------------------------------------------         
        case 'userM'
            if( numVarArgs == allowedNumArgs(index) && ...
                    (isnumeric(inputData{1}) || (ischar(inputData{1}) && isnumeric(eval(inputData{1}))))...
                    )
                temp.transformParamStruct.userM = issmaller_as_sparse(inputData{1});
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = numeric array or string which evaluates to numeric array']);
                result = false;
            end
     % -------------------------------------------------------------------         
        case 'selectIndex'
            if( numVarArgs == allowedNumArgs(index) && ...
                    ((isvector(inputData{1}) && isnumeric(inputData{1})) ||...
                      (ischar(inputData{1}) && isvector(eval(inputData{1})) &&...
                       isnumeric(eval(inputData{1}))))...
                    )
                if(isnumeric(inputData{1}))
                    temp.transformParamStruct.xIndices = int32(floor(inputData{1}));
                elseif(ischar(inputData{1}))
                    temp.transformParamStruct.xIndices = inputData{1};
                end
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = numeric vector or string which evaluates to numeric vector']);
                result = false;
            end
     % -------------------------------------------------------------------         
        case 'fillRows'
            % X --> X where X(xindices) = Y(yindices)
            % inputData{1} == errorPropStruct variable name (Y)
            % inputData{2} == yindices
            % inputData{3} == xindices
            %
            if( numVarArgs == allowedNumArgs(index) && ischar(inputData{1}) && ...
                    ( isempty(inputData{2}) || (isvector(inputData{2}) && isnumeric(inputData{2})) ||...
                      (isvector(eval(inputData{2})) && isnumeric(eval(inputData{2})))) && ...
                      ( isempty(inputData{3}) || (isvector(inputData{3}) && isnumeric(inputData{3})) ||...
                      (isvector(eval(inputData{3})) && isnumeric(eval(inputData{3}))))...
                    )
                temp.yDataInputName = inputData{1};
                if(isnumeric(inputData{2}))
                    temp.yIndices = int32(floor(inputData{2}));
                elseif(ischar(inputData{2}))
                    temp.yIndices = inputData{2};
                end
                if(isnumeric(inputData{3}))
                    temp.transformParamStruct.xIndices = int32(floor(inputData{3}));
                elseif(ischar(inputData{3}))
                    temp.transformParamStruct.xIndices = inputData{3};
                end
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = numeric vector or string which evaluates to numeric vector']);
                result = false;
            end
     % -------------------------------------------------------------------
    case {'interpLinear', 'interpNearest'}
            if( numVarArgs == allowedNumArgs(index) && ...
                    ((isvector(inputData{1}) && isnumeric(inputData{1})) ||...
                     (ischar(inputData{1}) && (isvector(eval(inputData{1})) && isnumeric(eval(inputData{1})))) &&...
                     (isvector(inputData{2}) && isnumeric(inputData{2})) ||...
                     (ischar(inputData{2}) && (isvector(eval(inputData{2})) && isnumeric(eval(inputData{2}))))...
                    ))
                
                % store original indices in transformParamStruct.xIndices
                if(isnumeric(inputData{1}))
                    temp.transformParamStruct.xIndices = int32(floor(inputData{1}));
                elseif(ischar(inputData{1}))
                    temp.transformParamStruct.xIndices = inputData{1};                    
                end
                
                % store interpolated indices in transformParamStruct.polyXvector
                if(isnumeric(inputData{2}))
                    temp.transformParamStruct.polyXvector = int32(floor(inputData{2}));
                elseif(ischar(inputData{2}))
                    temp.transformParamStruct.polyXvector = inputData{2};                    
                end
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp(['type = "',type,'"; inputData = numeric vector or string which evaluates to numeric vector']);
                result = false;
            end

    % -------------------------------------------------------------------         
        case 'eye'
            if( numVarArgs == allowedNumArgs(index) && ...
                    ((isnumeric(inputData{1}) && ...
                      isnumeric(inputData{2}) && ...
                      (isnumeric(inputData{3}) || islogical(inputData{3})) && ...
                      isnumeric(inputData{4}) && ...
                      isnumeric(inputData{5}))||...                        
                    (ischar(inputData{1}) && ...
                     isempty(inputData{2}) && ...
                     isempty(inputData{3}) && ...
                     isempty(inputData{4}) && ...
                     isempty(inputData{5})) ) )
                
                temp = empty_errorPropStruct;                
                temp.xPrimitive     = issmaller_as_sparse(inputData{1});
                temp.CxPrimitive    = issmaller_as_sparse(inputData{2});
                temp.gapList        = int16(inputData{3});
                temp.row            = int16(inputData{4});
                temp.col            = int16(inputData{5});

                % if xPrimitive is a string, make a row vector,
                if(ischar(temp.xPrimitive))
                    temp.xPrimitive = temp.xPrimitive(:)';
                end
            else
                disp('Wrong input data for transformation type.');
                disp('Usage: allowed_input(type, inputData)');
                disp('type = "eye"; inputData = {numeric column vector, numeric array or column vector, numeric column vector}');
                disp(['type = "',type,'"; inputData = {variable name, [], []}']);
                result = false;
            end
    % -------------------------------------------------------------------
        otherwise
            display('Should never see this line displayed .... . ');
            result = false;
    end
    
else
    
    disp(['TRANSFORMATION TYPE "',type,'" NOT ALLOWED']);
    disp('Allowed types:'),
    disp(allowedTypes);
    temp = struct;   
    
end

 