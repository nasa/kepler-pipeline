function [cosmicRayAnalysisStruct] = ...
analyze_cosmic_rays_by_mod_out()

% Assume that gaps only occur at the cadence level, i.e. all pixels are
% gapped when a cadence is gapped and only when a cadence is gapped.
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

f = dir('pa_state.mat');
if isempty(f)
    cosmicRayAnalysisStruct = [];
    disp('no data available')
    return
end

load('pa_state.mat', 'nInvocations');

load('pa-inputs-0.mat')
paDataStruct = inputsStruct;
clear inputsStruct

cadenceTimes = paDataStruct.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;

% interpolate the missing timestamps
timestamps(cadenceGapIndicators) = interp1(find(~cadenceGapIndicators), ...
    timestamps(~cadenceGapIndicators), find(cadenceGapIndicators), 'linear', 'extrap');

load('pa-outputs-0.mat')
paResultsStruct = outputsStruct;
clear outputsStruct

ccdModule = paResultsStruct.ccdModule;
ccdOutput = paResultsStruct.ccdOutput;
cosmicRayAnalysisStruct.ccdModule = ccdModule;
cosmicRayAnalysisStruct.ccdOutput = ccdOutput;
cosmicRayAnalysisStruct.modOutIndex = convert_from_module_output(ccdModule, ccdOutput);

cadenceType = paResultsStruct.cadenceType;

if strcmpi(cadenceType, 'LONG')
    pixelCoordinates = unique([paDataStruct.backgroundDataStruct.ccdRow; ...
        paDataStruct.backgroundDataStruct.ccdColumn]', 'rows');
    backgroundCosmicRayEvents = paResultsStruct.backgroundCosmicRayEvents;
    backgroundCosmicRayMetrics = paResultsStruct.backgroundCosmicRayMetrics;
    backgroundMjds = [backgroundCosmicRayEvents.mjd]';
    backgroundCountsByCadence = histc(backgroundMjds, timestamps);
    backgroundCoords = [backgroundCosmicRayEvents.ccdRow; ...
        backgroundCosmicRayEvents.ccdColumn]';
    backgroundCountsByPixel = histc(coords2ind(backgroundCoords, 1132), ...
        coords2ind(pixelCoordinates, 1132));
    backgroundCountsHistogram = histc(backgroundCountsByPixel, (0:250-1)');
    
    cosmicRayAnalysisStruct.backgroundCosmicRayMetrics = ...
        backgroundCosmicRayMetrics;
    cosmicRayAnalysisStruct.backgroundCountsByCadence = ...
        backgroundCountsByCadence;
    cosmicRayAnalysisStruct.backgroundCountsByPixel = ...
        backgroundCountsByPixel;
    cosmicRayAnalysisStruct.backgroundCountsHistogram = ...
        backgroundCountsHistogram;
    
    clear paDataStruct paResultsStruct
else
    cosmicRayAnalysisStruct.backgroundCosmicRayMetrics = [];
    cosmicRayAnalysisStruct.backgroundCountsByCadence = [];
    cosmicRayAnalysisStruct.backgroundCountsByPixel = [];
    cosmicRayAnalysisStruct.backgroundCountsHistogram = [];
end

load(['pa-outputs-', num2str(nInvocations-1), '.mat'])
paResultsStruct = outputsStruct;
clear outputsStruct

load('pa_state.mat', 'pixelCoordinates');
pixelCoordinates = pixelCoordinates - 1;   % These are 1-based in state file
targetStarCosmicRayEvents = paResultsStruct.targetStarCosmicRayEvents;
targetStarCosmicRayMetrics = paResultsStruct.targetStarCosmicRayMetrics;
targetStarMjds = [targetStarCosmicRayEvents.mjd]';
targetStarCountsByCadence = histc(targetStarMjds, timestamps);
targetStarCoords = [targetStarCosmicRayEvents.ccdRow; ...
    targetStarCosmicRayEvents.ccdColumn]';
targetStarCountsByPixel = histc(coords2ind(targetStarCoords, 1132), ...
        coords2ind(pixelCoordinates, 1132));
targetStarCountsHistogram = histc(targetStarCountsByPixel, (0:250-1)');

cosmicRayAnalysisStruct.targetStarCosmicRayMetrics = ...
    targetStarCosmicRayMetrics;
cosmicRayAnalysisStruct.targetStarCountsByCadence = ...
    targetStarCountsByCadence;
cosmicRayAnalysisStruct.targetStarCountsByPixel = ...
    targetStarCountsByPixel;
cosmicRayAnalysisStruct.targetStarCountsHistogram = ...
    targetStarCountsHistogram;

return


function [ix] = coords2ind(coords, nCols)

ix = coords( :, 1) * nCols + coords( : , 2);

return
