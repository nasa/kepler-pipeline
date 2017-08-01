%% function [targetDataStruct] = map_remove_map_correction (targetDataStruct, mapResultsObject, normMethod, ...
%                                   cadenceTimes, pdcModuleParameters)
%
% Removes the MAP correction from a targetDataStruct where the MAP correction has been removed. This is not a
% simple addition of the mapFit due to the returned MAP correction is in the unnormalized frame. To add the
% correction back in a couple steps are needed:
%
% 1) normalize targetDataStruct and mapFit
% 2) Add the mapFit to the flux
% 3) re-normalize targetDataStruct
%
% Multiple normalization methods are available so the method must be specified. Obviously, make sure you use
% the same method as was used to normalize the flux!
% Note:  If map was not performed then a reduced robust fit was used in its stead
%
% If quickMAP was performed then the quickMapFit is used. quickMapFit is always populated even if it was
% really just a reduced robust fit.
%
%************************************************************************************************************
% Inputs:
%   targetDataStruct  -- [struct] the unnormalized MAP corrected flux
%       fields used:
%           .values
%           .uncertainties
%           .gapIndicators
%   mapResultsObject  -- [mapResultsClass] Contains the mapFit to remove
%                         if field is a string then the object struct is stored in the file specified in the string.
%   normMethod        -- [Char] Normalization method to use. [median, mean, std, sqrtMedian]
%   cadenceTimes      -- [cadenceTimesStruct] Cadence times data. Only used if Masking E-P Recoveries.
%   pdcModuleParameters -- [pdcModuleParametersStruct]
%       fields used:
%                   variabilityEpRecoveryMaskEnabled -- used for normalizing flux by 'std'
%                   variabilityEpRecoveryMaskWindow
%   
%************************************************************************************************************
%   targetDataStruct -- [targetDataStruct]
%       fields Updated:
%                   values
%                   uncertainties
%************************************************************************************************************
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

function [targetDataStruct] = map_remove_map_correction (targetDataStruct, mapResultsObject, normMethod, ...
                                    cadenceTimes, pdcModuleParameters)

% Check if mapResultsObject was really passed, or just the file to load was passed
if (isa(mapResultsObject, 'char'))
    % Load the given file name
    mapResultsStruct = load(mapResultsObject);
    names = fieldnames(mapResultsStruct);
    % Saved as struct, convert to object
    mapResultsObject = mapResultsClass.construct_from_struct(mapResultsStruct.(names{1}));
    clear mapResultsStruct;
end

if (~isa(mapResultsObject, 'mapResultsClass'))
    error ('map_remove_map_correction; mapResultsObject is not of type mapResultsClass');
end

% If map had failed then nothing to do!
if (mapResultsObject.mapFailed)
    return;
end

nTargets = length(targetDataStruct);

% normalize
doNanGaps = false;
doMaskEpRecovery = pdcModuleParameters.variabilityEpRecoveryMaskEnabled;
maskWindow = pdcModuleParameters.variabilityEpRecoveryMaskWindow;
[normTargetDataStruct, medianFlux, meanFlux, stdFlux, noiseFloor] = mapNormalizeClass.normalize_flux (targetDataStruct, normMethod, ...
                doNanGaps, doMaskEpRecovery, cadenceTimes, maskWindow);

% If quick map was performed then the map fit is located in quickMapFit
if (mapResultsObject.quickMapPerformed)
    [quickMapFit] = mapResultsObject.get_fit_from_coefficients ([1:length(targetDataStruct)], 'quickMap', doNanGaps);
    [normQuickMapFit] = mapNormalizeClass.normalize_value (quickMapFit, medianFlux, meanFlux, stdFlux, noiseFloor, normMethod);
else
    [mapFit] = mapResultsObject.get_fit_from_coefficients ([1:length(targetDataStruct)], 'map', doNanGaps);
    [normMapFit] = mapNormalizeClass.normalize_value (mapFit, medianFlux, meanFlux, stdFlux, noiseFloor, normMethod);
    [reducedRobustFit] = mapResultsObject.get_fit_from_coefficients ([1:length(targetDataStruct)], 'reducedRobust', doNanGaps);
    [normReducedRobustFit] = mapNormalizeClass.normalize_value (reducedRobustFit, medianFlux, meanFlux, stdFlux, noiseFloor, normMethod);
end

% Add back in the mapFit in the normalized frame
% If map was not performed then a reduced robust fit was used in its stead
% If quickMAP was performed then quickMapFit always contains the actualy correction even if only a reduced
% robust fit was performed.
for iTarget = 1 : nTargets
    if (mapResultsObject.quickMapPerformed)
        normTargetDataStruct(iTarget).values = normTargetDataStruct(iTarget).values + normQuickMapFit(:,iTarget);
    elseif (mapResultsObject.targetsMapAppliedTo(iTarget))
        normTargetDataStruct(iTarget).values = normTargetDataStruct(iTarget).values + normMapFit(:,iTarget);
    else
        normTargetDataStruct(iTarget).values = normTargetDataStruct(iTarget).values + normReducedRobustFit(:,iTarget);
    end
end

% denormalize
targetDataStruct = mapNormalizeClass.denormalize_flux (normTargetDataStruct);

% Remove POU in the unnormalized frame by just restoring the raw uncertainties
for iTarget = 1 : nTargets
    targetDataStruct(iTarget).uncertainties = mapResultsObject.intermediateMapResults(iTarget).mapInputUncertainties;
end

return;

