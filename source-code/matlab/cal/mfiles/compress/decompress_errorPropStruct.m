function errorPropStruct = decompress_errorPropStruct( errorPropStruct, compressedDataStruct, varargin)
%
% function errorPropStruct = decompress_errorPropStruct( errorPropStruct, compressedDataStruct)
%
% This function reads the compressed data from compressedDataStruct,
% decompresses it and writes it back into errorPropStruct. This should
% restore errorPropStruct to the state it was in during CAL after:
%
% errorPropStruct = minimize_errorPropStructArray(errorPropStructArray)
%
% and before:
%
% [C, errorPropStruct] = compress_collateral_errorPropStruct(tempStruct, SVDorder);
% [Cp, Sp]= compress_photometric_errorPropStruct(S, SVDorder, invocationsList);
%
% INPUT:    errorPropStruct         =   minimized errorPropStruct from CAL      nVars x 1
%           compressedDataStruct    =   compressed data from CAL                nCompressedVars x 1
%           varargin{1}             =   relative cadence list to decompress     nCadences x 1
%           varargin{2}             =   relative index list to decompress       nIndices x 1
%           
% OUTPUT:   errorPropStruct         =   maximized errorPropStruct               nVars x nCadences
%
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

% set variable input arguments
cadenceList = [];
indexList = [];
if(nargin > 2)
    cadenceList = varargin{1};
    if(nargin > 3)
        indexList = varargin{2};
    end
end

for i = 1:length(compressedDataStruct)
    varName = compressedDataStruct(i).variableName;    
    j = iserrorPropStructVariable(errorPropStruct, varName);

    if( j > 0 )
        if( ~isempty(compressedDataStruct(i).xPrimitive.U) && ~isempty(compressedDataStruct(i).CxPrimitive.U) )
            [x, Cx] = get_compressed_primitive_data(compressedDataStruct, varName, cadenceList, indexList);
            errorPropStruct(j).xPrimitive = x;
            errorPropStruct(j).CxPrimitive = Cx;
        end

        tIndex = 1;
        while (tIndex <= length(compressedDataStruct(i).transformData ) )
            if ( ~isempty(compressedDataStruct(i).transformData(tIndex).transformParamName) )
                tLevel = compressedDataStruct(i).transformData(tIndex).transformLevel;
                [T, paramName] = get_compressed_transform_data(compressedDataStruct, varName, tLevel, cadenceList, indexList);
                errorPropStruct(j).transformStructArray(tLevel).transformParamStruct.(paramName) = T;
            end
            tIndex = tIndex + 1;
        end
    end
end

