function U = put_collateral_covariance(S, C, cadences)
%**************************************************************************
% function U = put_collateral_covariance(S, C, cadences)
%**************************************************************************
% 
%**************************************************************************
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

% null input case
if isempty(S)
    disp('CAL POU blob contains no transform data. Returning empty array.');
    U = [];
    return;
end


% list collateral variables needed to calculate covariance for photometric indices
collateralList = {'darkLevelEstimate',...                  
                  'smearLevelEstimate',...
                  'fittedBlack',...
                  'darkColumns'};

% list collateral variables to reduce Cv for
collateralToReduce = {'darkLevelEstimate',...                  
                      'smearLevelEstimate'};

% populate intermediate errorPropStruct T
[collateralIndices, photometricIndices] = get_collateral_and_photometric_indices(S);
validIndices = [collateralIndices; photometricIndices];
if ~isempty(C)
    % expand errorPropStruct S for cadences
    T = expand_errorPropStruct(S, C, cadences);
else
    T = S(:,cadences);
end
[tf, newCollateralIndices] = ...
    ismember(collateralList,{S(validIndices,1).variableName});

% parse and save errorPropStruct to only those variables needed to calculate Cv for photometric indices
U = T([newCollateralIndices(tf)';photometricIndices],:);

% calculate Cv using structure T and store result in output structure U
for j=1:length(collateralToReduce)    
    for i=1:length(cadences)        
        [x,Cx] = cascade_transformations(T(:,i),collateralToReduce{j});
        U(:,i) = put_primitive_data(U(:,i),collateralToReduce{j},x,Cx,[]);
        index = iserrorPropStructVariable(U(:,i),collateralToReduce{j});
        U(index,i).transformStructArray = empty_tStruct;
    end    
end
