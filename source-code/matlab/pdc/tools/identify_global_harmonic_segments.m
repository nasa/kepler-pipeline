function [globalHarmonicSegments] = ...
identify_global_harmonic_segments(dataAnomalyIndicators, ...
cadenceGapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [globalHarmonicSegments] = ...
% identify_global_harmonic_segments(dataAnomalyIndicators, ...
% cadenceGapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify the cadence ranges bounded by attitude tweaks and safe mode
% recoveries. For each, identify the start and end cadence and the
% gapped cadences. Set a validity flag to true for each segment that
% contains at least one valid (i.e. ungapped) cadence. Merge the invalid
% segments with adjacent valid segments. Return an array of structures
% containing the details for each segment.
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


% Get the anomaly indicators and the number of cadences.
attitudeTweakIndicators = dataAnomalyIndicators.attitudeTweakIndicators;
safeModeIndicators = dataAnomalyIndicators.safeModeIndicators;
coarsePointIndicators = dataAnomalyIndicators.coarsePointIndicators;
argabrighteningIndicators = dataAnomalyIndicators.argabrighteningIndicators;
excludeIndicators = dataAnomalyIndicators.excludeIndicators;

nCadences = length(cadenceGapIndicators);

% Set global gap indicators.
globalGapIndicators = cadenceGapIndicators | safeModeIndicators | ...
    coarsePointIndicators | argabrighteningIndicators | excludeIndicators;
globalGapIndices = find(globalGapIndicators);

% Initialize a harmonic segment structure and the output structure array.
% Return if there are no cadences to process.
harmonicSegmentStruct = struct( ...
    'startIndex', -1, ...
    'endIndex', -1, ...
    'segmentIndices', [], ...
    'gapIndices', [], ...
    'isValid', false);

globalHarmonicSegments = [];

if isempty(cadenceGapIndicators)
    return
end

% Loop through the cadences and identify the segments (based on known
% anomalies) where harmonics must be identified separately for all of the
% variable targets.
globalHarmonicSegment = harmonicSegmentStruct;
globalHarmonicSegment.startIndex = 1;

for iCadence = 2 : nCadences
    
    % If an attitude tweak or recovery from safe mode occurs, complete the
    % current segment and begin a new one.
    if attitudeTweakIndicators(iCadence) || ...
            (~safeModeIndicators(iCadence) && ...
            safeModeIndicators(iCadence - 1))
        
        globalHarmonicSegment.endIndex = iCadence - 1;
        globalHarmonicSegments = ...
            [globalHarmonicSegments, globalHarmonicSegment];                                 %#ok<AGROW>
        
        globalHarmonicSegment = harmonicSegmentStruct;
        globalHarmonicSegment.startIndex = iCadence;
        
    end % if
    
end % for iCadence
        
% Complete the final segment.
globalHarmonicSegment.endIndex = nCadences;
globalHarmonicSegments = ...
    [globalHarmonicSegments, globalHarmonicSegment];
        
% Fill in the remaining fields for the harmonic segments. Valid segments
% are those that are not all gapped.
for iSegment = 1 : length(globalHarmonicSegments)
    
    globalHarmonicSegment = globalHarmonicSegments(iSegment);
    globalHarmonicSegment.segmentIndices = ...
        (globalHarmonicSegment.startIndex : globalHarmonicSegment.endIndex)';
    globalHarmonicSegment.gapIndices = intersect( ...
        globalHarmonicSegment.segmentIndices, globalGapIndices);
    if ~isequal(globalHarmonicSegment.segmentIndices, ...
            globalHarmonicSegment.gapIndices)
        globalHarmonicSegment.isValid = true;
    end
    globalHarmonicSegments(iSegment) = globalHarmonicSegment;
    
end % for iSegment

% Merge invalid segments from the beginning and/or end toward the middle.
while length(globalHarmonicSegments) > 1 && ...
        ~all([globalHarmonicSegments.isValid])
    
    if ~globalHarmonicSegments(end).isValid
        globalHarmonicSegments(end - 1).endIndex = ...
            globalHarmonicSegments(end).endIndex;
        globalHarmonicSegments(end - 1).segmentIndices = ...
            [globalHarmonicSegments(end - 1).segmentIndices; ...
            globalHarmonicSegments(end).segmentIndices];
        globalHarmonicSegments(end - 1).gapIndices = ...
            [globalHarmonicSegments(end - 1).gapIndices; ...
            globalHarmonicSegments(end).gapIndices];
        globalHarmonicSegments(end) = [];
    end % if
    
    if length(globalHarmonicSegments) > 1 && ...
            ~globalHarmonicSegments(1).isValid
        globalHarmonicSegments(2).startIndex = ...
            globalHarmonicSegments(1).startIndex;
        globalHarmonicSegments(2).segmentIndices = ...
            [globalHarmonicSegments(1).segmentIndices; ...
            globalHarmonicSegments(2).segmentIndices];
        globalHarmonicSegments(2).gapIndices = ...
            [globalHarmonicSegments(1).gapIndices; ...
            globalHarmonicSegments(2).gapIndices];
        globalHarmonicSegments(1) = [];
    end % if
    
end % while

% Display a log message indicating the number of global segments.
nSegments = sum([globalHarmonicSegments.isValid]);
if nSegments > 1
    display([num2str(nSegments), ...
        ' global segments were found for harmonics identification']);
end

% Return.
return
