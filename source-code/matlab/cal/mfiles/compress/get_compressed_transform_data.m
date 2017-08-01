function [T, transParamName] = get_compressed_transform_data(C, variableName, transformLevel, varargin)

% function T = get_compressed_transform_data(C, variableName, cadenceList, indexList, transformLevel)
%
% Retrieve compressed transform data at level transformLevel for variableName stored in compressed data 
% structure C for cadences in cadenceList and indices in indexList. Assumes data is arranged in 
% row==cadence, col==index (concatenation of time series).
%
% INPUT:    C               = compressed data struct
%           variableName    = compressed data variable name
%           transformLevel  = index of transform in transformation chain
%                             (e.g. source errorPropStruct.transformStructArray(index)) 
%           varargin
%               cadenceList     = list of cadence indices (rows) of the desired data
%           	indexList       = list of index indices (columns) of the desired data
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

% OUTPUT:   T               = nCadences x nIndices matrix of reconstructed transform data
%           transParamName  = name of field in errorPropStruct.transformStructArray.transformParamStruct
%                             which should recieve the decompressed data
%

% seed null return values
T = [];
transParamName = '';

index = iscompressedDataVariable(C, variableName);

if(index)
    
    % find transformData index that contains transformLevel data
    levelIndex = 0;
    transformLevelFound = false;
    while(levelIndex < length(C(index).transformData) && ~transformLevelFound)
        levelIndex = levelIndex + 1;
        if(C(index).transformData(levelIndex).transformLevel == transformLevel)
            transformLevelFound = true;
        end
    end
    
    if(transformLevelFound)    
        
        cadenceList = [];
        indexList = [];

        if(nargin > 3)
            cadenceList = varargin{1};
            if(nargin > 4)
                indexList = varargin{2};
            end
        end 
        
        % return transform parameter name
        transParamName = C(index).transformData(levelIndex).transformParamName;
        
        % uncompress the underlying data (x) -  get basis vectors and singular values
        u = C(index).transformData(levelIndex).U;    
        s = diag(C(index).transformData(levelIndex).S);
        v = C(index).transformData(levelIndex).V;

        nCadences = size(u,1);
        nIndices  = size(v,1);

        % trim basis vectors using only cadences in list (u) and indices in
        % list (v) - empty lists includes all cadences or indices
        if(isempty(cadenceList) || length(cadenceList) >= nCadences)
            cadenceList = 1:nCadences;  
        end
        if(isempty(indexList) || length(indexList) >= nIndices)
            indexList = 1:nIndices;
        end

        u = u(cadenceList,:);
        v = v(indexList,:);
        optimalOrder = C(index).transformData(levelIndex).minimumAicOrder(indexList);

        % reconstruct matrix of time series data 
        % row == time, col == spatial index for each column, use the optimal
        % model order determined using AIC during compression
        T = zeros(length(cadenceList), length(indexList));
        for i=1:length(indexList)
            orderSelect = speye(size(s,1));        
            orderSelect(optimalOrder(i)+1:end, optimalOrder(i)+1:end) = 0;        
            T(:,i) = u*orderSelect*s*v(i,:)';
        end
    end
end