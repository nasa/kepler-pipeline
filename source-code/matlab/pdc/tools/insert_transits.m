function [pdcDataStruct, transitStruct] = ...
insert_transits(pdcDataStruct, widthRange, depthRange, ...
nTargetsWithTransits, nTransitsPerTarget)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdcDataStruct, discontinuityStruct] = ...
% insert_transits(pdcDataStruct, widthRange, depthRange, ...
% nTargetsWithTransits, nTransitsPerTarget)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Introduce random gaussian transits into the first 'nTargetsWithTransits'
% targets for PDC validation (protection from outlier detection).
%
% Widths specified in hours, 
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

% Set constants, and defaults if necessary.
TRANSIT_WIDTH_SIGMAS = 6.0;
WIDTH_RANGE = [1.0; 12.0];
DEPTH_RANGE = [1.0e-5; 1.0e-1];
N_TARGETS_WITH_TRANSITS = 500;
N_TRANSITS_PER_TARGET = 2;

if ~exist('widthRange', 'var')
    widthRange = WIDTH_RANGE;
end

if ~exist('depthRange', 'var')
    depthRange = DEPTH_RANGE;
end

logDepthRange = log10(sort(depthRange));

if ~exist('nTargetsWithTransits', 'var')
    nTargetsWithTransits = N_TARGETS_WITH_TRANSITS;
end

if ~exist('nTransitsPerTarget', 'var')
    nTransitsPerTarget = N_TRANSITS_PER_TARGET;
end

% Set the cadence rate.
cadenceType = pdcDataStruct.cadenceType;
if strcmpi(cadenceType, 'LONG')
    cadencesPerHour = 2.0;
elseif strcmpi(cadenceType, 'SHORT')
    cadencesPerHour = 60.0;
else
    error(['unknown cadence type: ', cadenceType]);
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

% Insert the transits. Don't insert a transit (center) into the first
% or last five cadences for any target.
targetDataStruct = pdcDataStruct.targetDataStruct;
nTargets = length(targetDataStruct);
keplerIdsCellArray = {targetDataStruct.keplerId};

transitStruct = repmat(struct( ...
    'keplerId', 0, ...
    'index', [], ...
    'transitWidth', [], ...
    'transitDepth', [] ), [nTargets, 1]);
[transitStruct(1 : nTargets).keplerId] = keplerIdsCellArray{ : };

rand('twister', 5489);

for iTarget = 1 : nTargetsWithTransits
    
    values = targetDataStruct(iTarget).values;
    gapIndicators = targetDataStruct(iTarget).gapIndicators;
    medianValue = median(values(~gapIndicators));
    
    indicators = gapIndicators | anomalyIndicators;
    indicators(find(~indicators, 5, 'first')) = true;
    indicators(find(~indicators, 5, 'last')) = true;
    index = ...
        sort(randsample(find(~indicators), nTransitsPerTarget));
    transitWidth = diff(sort(widthRange)) * ...
        rand([nTransitsPerTarget, 1]) + min(widthRange);
    transitDepth = 10 .^ (diff(logDepthRange) * ...
        rand([nTransitsPerTarget, 1]) + min(logDepthRange));
    
    for iCount = 1 : nTransitsPerTarget
        
        cadence = index(iCount);
        sigma = transitWidth(iCount) * ...
            cadencesPerHour / TRANSIT_WIDTH_SIGMAS;
        amplitude = transitDepth(iCount) * medianValue; 
        transitValues = -amplitude * ...
            exp(-((((1 : length(values))' - cadence) / sigma) .^ 2) / 2);
        values = values + transitValues;
        
    end % for iCount
    
    values(gapIndicators) = 0;
    targetDataStruct(iTarget).values = values;
    transitStruct(iTarget).index = index;
    transitStruct(iTarget).transitWidth = transitWidth;
    transitStruct(iTarget).transitDepth = transitDepth;
    
end % for iTarget

pdcDataStruct.targetDataStruct = targetDataStruct;

% Return.
return
