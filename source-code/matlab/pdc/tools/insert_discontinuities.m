function [pdcDataStruct, discontinuityStruct] = ...
insert_discontinuities(pdcDataStruct, maxStepSize, nTargetsWithDiscontinuities, ...
nDiscontinuitiesPerTarget)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdcDataStruct, discontinuityStruct] = ...
% insert_discontinuities(pdcDataStruct, maxStepSize, nTargetsWithDiscontinuities, ...
% nDiscontinuitiesPerTarget)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Introduce random discontinuities into the first
% 'nTargetsWithDiscontinuities' targets for PDC validation
% (identification/correction of discontinuities).
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Set defaults if necessary.
MAX_STEP_SIZE = 1.0e6;
N_TARGETS_WITH_DISCONTINUITIES = 500;
N_DISCONTINUITIES_PER_TARGET = 2;

if ~exist('maxStepSize', 'var')
    maxStepSize = MAX_STEP_SIZE;
end

if ~exist('nTargetsWithDiscontinuities', 'var')
    nTargetsWithDiscontinuities = N_TARGETS_WITH_DISCONTINUITIES;
end

if ~exist('nDiscontinuitiesPerTarget', 'var')
    nDiscontinuitiesPerTarget = N_DISCONTINUITIES_PER_TARGET;
end

% Identify the anomaly cadences.
cadenceTimes = pdcDataStruct.cadenceTimes;
dataAnomalyTypes = cadenceTimes.dataAnomalyTypes;
[dataAnomalyIndicators] = parse_data_anomaly_types(dataAnomalyTypes);
anomalyIndicators = ...
    dataAnomalyIndicators.attitudeTweakIndicators | ...
    dataAnomalyIndicators.safeModeIndicators | ...
    dataAnomalyIndicators.earthPointIndicators | ...
    dataAnomalyIndicators.coarsePointIndicators | ...
    dataAnomalyIndicators.argabrighteningIndicators | ...
    dataAnomalyIndicators.excludeIndicators;

% Insert the discontinuities. Don't insert a discontinuity into the first
% or last five cadences for any target.
targetDataStruct = pdcDataStruct.targetDataStruct;
nTargets = length(targetDataStruct);
keplerIdsCellArray = {targetDataStruct.keplerId};

discontinuityStruct = repmat(struct( ...
    'keplerId', 0, ...
    'index', [], ...
    'discontinuityStepSize', [] ), [nTargets, 1]);
[discontinuityStruct(1 : nTargets).keplerId] = keplerIdsCellArray{ : };

rand('twister', 5489);

for iTarget = 1 : nTargetsWithDiscontinuities
    
    values = targetDataStruct(iTarget).values;
    gapIndicators = targetDataStruct(iTarget).gapIndicators;
    
    indicators = gapIndicators | anomalyIndicators;
    indicators(find(~indicators, 5, 'first')) = true;
    indicators(find(~indicators, 5, 'last')) = true;
    index = ...
        sort(randsample(find(~indicators), nDiscontinuitiesPerTarget));
    discontinuityStepSize = ...
        2 * maxStepSize * (rand(nDiscontinuitiesPerTarget, 1) - 0.5);
    
    [newValues] = correct_time_series_discontinuities(values, index, ...
        -discontinuityStepSize, gapIndicators);
    
    targetDataStruct(iTarget).values = newValues;
    discontinuityStruct(iTarget).index = index;
    discontinuityStruct(iTarget).discontinuityStepSize = ...
        discontinuityStepSize;
    
end % for iTarget

pdcDataStruct.targetDataStruct = targetDataStruct;

% Return.
return
