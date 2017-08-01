function [x, Cx] = get_compressed_primitive_data(C, variableName, varargin)

% function [x, Cx] = get_compressed_primitive_data(C, variableName, cadenceList)
%
% Retrieve compressed primitive data for variableName stored in compressed data 
% structure C for cadences in cadenceList and indices in indexList. Assumes
% data is arranged in row==cadence, col==index (concatenation of time series).
%
% INPUT:    C               = compressed data struct
%           variableName    = compressed data variable name
%           varargin
%               cadenceList     = list of cadence indices (rows) of the desired data
%               indexList       = list of index indices (columns) of the desired data
% OUTPUT:   x               = nCadences x nIndices matrix of reconstructed x data
%           Cx              = nCadences x nIndices matrix of reconstructed Cx data
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


% get cadenceList and indexList from variable input
cadenceList = [];
indexList = [];

% SHOULD ADD SOME ERROR CHECKING HERE - cadnenceList and indexList > 0,
% integer, ...
if(nargin > 2)
    cadenceList = varargin{1};
    if(nargin > 3)
        indexList = varargin{2};
    end
end 

index = iscompressedDataVariable(C, variableName);

if(index)
    
    % uncompress the underlying data (x) -  get basis vectors and singular values
    u = C(index).xPrimitive.U;    
    s = diag(C(index).xPrimitive.S);
    v = C(index).xPrimitive.V;
    
    % get number of rows and columns of the fully reconstructed data
    % row == cadence, col == index
    nCadences = size(u,1);
    nIndices = size(v,1);
    
    % trim basis vectors using only cadences in list (u) and indices in
    % list (v) - empty lists includes full dimensions of U*S*V'
    if(isempty(cadenceList) || length(cadenceList) >= nCadences)
        rows = 1:nCadences;
    else
        rows = cadenceList;
    end
    if(isempty(indexList) || length(indexList) >= nIndices)
        cols = 1:nIndices;
    else
        cols = indexList;
    end
    
    u = u(rows,:);
    v = v(cols,:);
    optimalOrder = C(index).xPrimitive.minimumAicOrder(cols);
    
    % reconstruct matrix of time series data 
    % row == time, col == spatial index for each column, use the optimal
    % model order determined using AIC during compression
    x = zeros(length(rows), length(cols));
    for i=1:length(cols)
        orderSelect = speye(size(s,1));        
        orderSelect(optimalOrder(i)+1:end, optimalOrder(i)+1:end) = 0;        
        x(:,i) = u*orderSelect*s*v(i,:)';
    end
    
    
    % do the same for the variance (Cx)
    u = C(index).CxPrimitive.U;    
    s = diag(C(index).CxPrimitive.S);
    v = C(index).CxPrimitive.V;
    nCadences = size(u,1);
    nIndices = size(v,1);
    if(isempty(cadenceList) || length(cadenceList) >= nCadences)
        rows = 1:nCadences;
    else
        rows = cadenceList;
    end
    if(isempty(indexList) || length(indexList) >= nIndices)
        cols = 1:nIndices;
    else
        cols = indexList;
    end
    u = u(rows,:);
    v = v(cols,:);
    optimalOrder = C(index).CxPrimitive.minimumAicOrder(cols);
    Cx = zeros(length(rows), length(cols));
    for i=1:length(cols)
        orderSelect = speye(size(s,1));        
        orderSelect(optimalOrder(i)+1:end, optimalOrder(i)+1:end) = 0;        
        Cx(:,i) = u*orderSelect*s*v(i,:)';
    end    
        
else    
    x = [];
    Cx = [];    
end