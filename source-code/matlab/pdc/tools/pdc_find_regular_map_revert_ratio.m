%% function [revertRatio targetsThatReverted] = pdc_find_regular_map_revert_ratio (outputsStruct)
%
% Finds the ratio of targets that reverted to regular MAP
%
% Inputs:
%   outputsStruct  -- the output from a PDC run
% 
% Outputs:
%   revertRatio         -- [double] ratio of targets that reverted to regular MAP
%   targetThatReverted  -- [logical array(nTargets)] the targets that revereted
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

function [revertRatio targetsThatReverted] = pdc_find_regular_map_revert_ratio (outputsStruct)

nTargets  = length(outputsStruct.targetResultsStruct);

% Create cell array of pdcMethod for each target
pdcMethod = cell(nTargets, 1);
for iTarget = 1 : nTargets
    pdcMethod{iTarget} = outputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.pdcMethod;
end

% Count regularMap, multiScaleMap and leastSquares
regularMap = false(nTargets,1);
msMap = false(nTargets,1);
leastSquares = false(nTargets,1);
for iTarget = 1 : nTargets
    here = strcmp(pdcMethod{iTarget}, {'regularMap', 'multiScaleMap', 'leastSquares'});
    regularMap(iTarget)     = here(1);
    msMap(iTarget)          = here(2);
    leastSquares(iTarget)   = here(3);
end

% Confirm the sum adds up to nTargets
% leastSquares should NEVER be chosen
nTotal = (sum(regularMap) + sum(msMap));
if (nTotal ~= nTargets)
    display('Warning: Not all targets were chosen as msMap or regularMap, this should not happen');
    revertRatio = -1;
    targetsThatRerverted = -1;
end

revertRatio = sum(regularMap) / nTargets;
targetsThatReverted = regularMap;

return
