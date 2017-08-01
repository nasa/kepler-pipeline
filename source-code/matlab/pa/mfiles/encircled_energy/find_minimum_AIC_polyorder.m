function bestAICorder = find_minimum_AIC_polyorder(eeTempStruct)
%
% function bestAICorder = find_minimum_AIC_polyorder(eeTempStruct)
%
% This function selects the polynomial order at which the AIC has reached a
% minimum and returns that order. The input is assumed to be a valid
% eeTempStruct with all the necessary fields populated. The input data is 
% not checked for structure or any other kind of error in this function.
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


% If polyOrder ~= -1, return with current polyOrder value
if( eeTempStruct.encircledEnergyStruct.polyOrder ~= -1 )
    bestAICorder = eeTempStruct.encircledEnergyStruct.polyOrder;
    return;
end

MIN_P_ORDER_DELTA   = 3;      % start polynomial order search at MIN_P_ORDER_DELTA + MIN_POLY_ORDER
AIC_FRACTION        = eeTempStruct.encircledEnergyStruct.AIC_FRACTION;
MAX_POLY_ORDER      = eeTempStruct.encircledEnergyStruct.MAX_POLY_ORDER;
MIN_POLY_ORDER      = eeTempStruct.encircledEnergyStruct.MIN_POLY_ORDER;
numCadence          = length(eeTempStruct.targetStar(1).cadence);

% generate a unique sorted list of ~ AIC_FRACTION of random cadence numbers
randCadences = unique(sort(ceil(numCadence.*rand(ceil(AIC_FRACTION*numCadence),1))));  

% send only the chosen cadences of data to encircledEnergy using tempStruct
tempStruct = make_ee_temp_struct_w_cadence_select(eeTempStruct,randCadences);

% Step through entire range of polyOrder and save polyOrder which gives minimum AIC across all cadences.

pOrderStart = max( [ 1 , MIN_POLY_ORDER + MIN_P_ORDER_DELTA] );
pOrders = pOrderStart:MAX_POLY_ORDER;

cadenceList = 1:length(tempStruct.targetStar(1).cadence);

% seed AIC with BIG_NUMBER
savedAIC = nan(length(pOrders),1);

% turn off warnings during order search
s = warning;
warning off all;

disp('Searching for minimum AIC fit order...');

for j = 1:length(pOrders)       
    dummyStruct     = encircledEnergy(tempStruct,pOrders(j));
    gapsRowVector   = dummyStruct.encircledEnergyStruct.eeDataGap(:)';    
    ungappedIndices = setdiff(cadenceList, gapsRowVector);
       
    if( ~isempty(ungappedIndices) )
        savedAIC(j) = median(dummyStruct.encircledEnergyStruct.AIC(ungappedIndices));
    end
    
    disp(['AIC for raw pixel fit order ',num2str(pOrders(j)+2),' = ',num2str(savedAIC(j))]);    
end

% restore warning state
warning on all;
warning(s);

% return best fit order
[bestAIC, bestIndex] = min(savedAIC);
bestAICorder = pOrders(bestIndex);
disp(['Select best fit order = ',num2str(bestAICorder+2)]);


