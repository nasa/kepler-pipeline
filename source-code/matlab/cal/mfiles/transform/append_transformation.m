function result = append_transformation(errorPropStruct, type, variableName, disableLevel, varargin)

% function result = append_transformation(errorPropStruct, type, variableName,  disableLevel, varargin)
%
% This function can be is used in the CSCI:CAL to track transformations
% used to generate:
%       Collateral data estimates
%           smearLevelEstimate
%           darkLevelEstimate
%           blackEstimate
%       Photometric data estimates
%           targetPixelValues
%           backgroundPixelValues
%           referencePixelValues
%   
%   Note: Input vector data is assumed to be a column.
%
%   INPUT:  errorPropStruct     = transformation struct to modify
%           type                = type of transformation applied; character string
%
%           Allowed types are:
%             1) scale          ==   scale data by a constant                                  z = c .* x      
%             2) scaleV         ==   scale data by a constant vector                           z = v .* x                       
%             3) addV           ==   add two variable vectors                                  z = x + y    
%             4) diffV          ==   difference two variable vectors                           z = x - y    
%             5) multV          ==   multiply two variable vectors                             z = x .* y
%             6) divV           ==   divide two variable vectors                               z = x ./ y
%             7) wSum           ==   weighted sum of a variable vector                         z = sum(w .* x)
%             8) wMean          ==   weighted mean of a variable vector                        z = mean(sum(w .* x)) 
%             9) bin            ==   bin the elements of a variable vector                     z(i) = sum( x(j:k) )
%             10)lsPolyFit      ==   least squares polynomial fit                              [p, Cp] = lscov(y, x, Cy) 
%             11)wPoly          ==   apply a weighted polynomial design matrix                 z = scalecol( w, M) * x
%             12)filter         ==   filter input data (x) using filter(b,a,x)                 z = filter(b, a, x)
%             13)FCmodelScale   ==   apply scaling model from Fc models                        z = Mmodel * x
%             14)FCmodelAdd     ==   apply additive model from Fc models                       z = Mmodel + x
%             15)userM          ==   user defined matrix transformation                        z = M * x
%             16)selectIndex    ==   select subset of incoming data based                      z = x(index,:)
%             17)concatRows     ==   concatenate input row-wise                                z = [x; y]
%             18)fillRows       ==   fill rows in x at index with rows of y                    z = x; x(index) = y                              
%             19)clearVar       ==   clear transformation record for variableName          
%             20)clearAll       ==   clear transformation record for all variableNames
%             21)eye            ==   indentity transformation                                  z = I * x 
%             22)expSum         ==   sum of exponentials                                       z = sum( Ai * e ^ (x/Ki) )
%             23)custom01_calFitted1DBlack == 1d Black two-exponential fit                     z = T * A
%             
%                  
%              
%
%           variableName     = variable name to track; string
%           disableLevel     = indicates whether or not to apply this transformation in the cascade
%                           0 --> xnew = T*x, Cxnew = T*Cx*T'   (both x and Cx are transformed - none disabled)
%                           1 --> xnew = T*x, Cxnew = I*Cx      (only x is transformed - Cx disabled)
%                           2 --> xnew = I*x, Cxnew = T*Cx*T'   (only Cx is transformed - x disabled)
%                           3 --> xnew = I*x, Cxnew = I*Cx      (neither x or Cx are transformed - both disabled)
%           varargin         = variable input arguments. Number and data type depend on transform 'type' specified.
%                              For details see 'type' case in 'make_transformation_matrix.m' or 'do_transformation.m'.
%
%   OUTPUT: result           = errorPropStruct with transformation appended
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



inputData = varargin;

typeOK = allowed_transform(type);
[inputOK, temp_Struct] = allowed_input(type, inputData);

if ( typeOK && inputOK )
    % set disableLevel
    if(~isempty(disableLevel))
        temp_Struct.disableLevel = int8(disableLevel);
    end
    
    varFound = iserrorPropStructVariable( errorPropStruct, variableName);        
    if ( varFound )        
        if( strcmp( type, 'eye' ) )
            % throw error if variable already initialized
            msgString = ['CAL:',mfilename,':Variable *',variableName,...
                '* already exists. Type "eye" transform not allowed.'];
            error(msgString);
        else
            % add element to transformStructArray
            if( isempty(errorPropStruct(varFound).transformStructArray(1).transformType ) )
                errorPropStruct(varFound).transformStructArray = temp_Struct;
            else        
                errorPropStruct(varFound).transformStructArray = ...
                    [ errorPropStruct(varFound).transformStructArray; temp_Struct ];
            end
        end        
    else
        
        % variable not found - create new variable entry if type = 'eye'
        if ( strcmp(type, 'eye') )
            
            % error if primitive data is a variable name which does not exist
            if(ischar(temp_Struct.xPrimitive))
                inputNameOK = iserrorPropStructVariable( errorPropStruct, temp_Struct.xPrimitive);
            else
                inputNameOK = 1;
            end
                        
            if(inputNameOK)
                temp_Struct.variableName = variableName;
                % find first empty entry
                entryIndex = 1;
                while( entryIndex <= length( errorPropStruct ) && ~isempty( errorPropStruct(entryIndex).variableName ) )
                    entryIndex = entryIndex + 1;
                end
                %add struct at array entry - expand array if necessary
                errorPropStruct( entryIndex ) = temp_Struct;
                errorPropStruct = errorPropStruct(:);    
            else
                msgString = ['CAL:',mfilename,':Input variable *',temp_Struct.xPrimitive,...
                '* not found in errorPropStruct'];
                error(msgString);
            end

        else
        % otherwise - error    
            msgString = ['CAL:',mfilename,':Variable *',variableName,...
                '* not found in errorPropStruct'];
            error(msgString);
        end
    end
    
end

result = errorPropStruct;   

