function [paResultsStruct] = ...
set_rolling_band_contamination_flags(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct] = ...
% set_rolling_band_contamination_flags(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Set the rolling band contamination flags for each target, cadence and 
% pulse duration with a valid flux value. The flags are defined for the
% optimal aperture only. The contamination value is defined as the maximum
% rolling band level for all rows intersecting the optimal aperture.
% See KSOC-1882 for more details. The rollingBandContaminationStruct array
% for each target is populated in the PA outputs. The flags are computed
% for long cadence data only (because the flags are consumed in DV which
% deals only with long cadence. An empty rollingBandContaminationStruct
% array is returned for short cadence data.
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

% Set constants.
ROLLING_BAND_DETECTED_MASK = uint8(2);
ROLLING_BAND_LEVEL_MASK = uint8(12);
ROLLING_BAND_BIT_SHIFT = -2;

% Get input field.
rollingBandContaminationFlagsEnabled = ...
    paDataObject.paConfigurationStruct.rollingBandContaminationFlagsEnabled;

% Get the number of targets and cadences. Note that severity flags are
% produced for long cadence data only. The output
% rollingBandContaminationStruct array is empty for short cadence data.
nTargets = length(paResultsStruct.targetStarResultsStruct);
nCadences = length(paDataObject.cadenceTimes.gapIndicators);

% Loop over the pulse durations and produce the contamination severity
% flags for all targets for each pulse duration.
nPulses = ...
    length(paResultsStruct.targetStarResultsStruct(1).rollingBandContaminationStruct);
if nPulses > 0
    testPulseDurations = [paDataObject.rollingBandArtifactFlags.testPulseDurationLc];
end % if

for iPulse = 1 : nPulses

    % Get the rolling band artifact flags from Dynablack for the given
    % pulse duration.
    testPulseDurationLc = ...
        paResultsStruct.targetStarResultsStruct(1).rollingBandContaminationStruct(iPulse).testPulseDurationLc;
    rollingBandArtifactFlags = ...
        paDataObject.rollingBandArtifactFlags(testPulseDurations == testPulseDurationLc);
    
    % Get the rolling band artifact rows, values and gap indicators.
    artifactRows = [];
    artifactLevels = [];
    artifactGapIndicators = [];

    if ~isempty(rollingBandArtifactFlags) && rollingBandContaminationFlagsEnabled

        artifactRows = [rollingBandArtifactFlags.row]';
        flagsArray = [rollingBandArtifactFlags.flags];
        artifactValues = uint8([flagsArray.values]);
        artifactGapIndicators = [flagsArray.gapIndicators];
        clear flagsArray

        % The bit mapping for the rolling band flags is defined on KSOC-1882.
        % Bit 0 indicates scene dependence and is not relevant here.
        % Bit 1 is set if rolling bands have been detected.
        % Bits 3-2 encode the rolling band severity level.
        %
        % Contamination severity levels are also defined on KSOC-1882.
        % Level 0: no RBA detected.
        % Level 1: 1-2 x RBA threshold.
        % Level 2: 2-3 x RBA threshold.
        % Level 3: 3-4 x RBA threshold.
        % Level 4:  >4 x RBA threshold.
        artifactLevels = double(1 + bitshift( ...
            bitand(artifactValues, ROLLING_BAND_LEVEL_MASK), ...
            ROLLING_BAND_BIT_SHIFT));
        artifactLevels(artifactGapIndicators) = 0;
        artifactLevels(~bitand(artifactValues, ROLLING_BAND_DETECTED_MASK)) = 0;
        clear artifactValues

    end % if

    % Loop through the targets and set the contamination flags for each of
    % the optimal apertures on a cadence by cadence basis. Ensure that the
    % flags are not gapped only on cadences when the flux is not gapped.
    for iTarget = 1 : nTargets

        pixelDataStruct = ...
            paDataObject.targetStarDataStruct(iTarget).pixelDataStruct;
        ccdRows = [pixelDataStruct.ccdRow]';
        inOptimalAperture = [pixelDataStruct.inOptimalAperture]';
        clear pixelDataStruct

        rollingBandContaminationStruct = ...
            paResultsStruct.targetStarResultsStruct(iTarget).rollingBandContaminationStruct(iPulse);

        [rollingBandContaminationStruct.severityFlags] = ...
            compute_aperture_contamination(ccdRows(inOptimalAperture), ...
            artifactRows, artifactLevels, artifactGapIndicators, ...
            nCadences, rollingBandContaminationStruct.severityFlags);

        fluxGapIndicators = ...
            paResultsStruct.targetStarResultsStruct(iTarget).fluxTimeSeries.gapIndicators;

        [rollingBandContaminationStruct.severityFlags] = ...
            set_indicators_for_flux_gaps(fluxGapIndicators, ...
            rollingBandContaminationStruct.severityFlags);

        paResultsStruct.targetStarResultsStruct(iTarget).rollingBandContaminationStruct(iPulse) = ...
            rollingBandContaminationStruct;

    end % for iTarget

end % for iPulse

% Return.
return


function [severityFlags] = ...
compute_aperture_contamination(ccdRows, artifactRows, artifactLevels, ...
artifactGapIndicators, nCadences, severityFlags)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [severityFlags] = ...
% compute_aperture_contamination(ccdRows, artifactRows, artifactLevels, ...
% artifactGapIndicators, nCadences, severityFlags)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The contamination flags are determined for each cadence by the maximum of
% the artifact levels in the rows that intersect the given aperture.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Set default results. Quality flags are all-gapped by default.
severityFlags.values = zeros([nCadences, 1]);
severityFlags.gapIndicators = true([nCadences, 1]);

% Determine the artifact contamination values and gap indicators for the
% given aperture. Return if the artifact rows have not been defined or if
% none of the rolling band rows intersects the aperture.
rowMatch = ismember(artifactRows, unique(ccdRows));
if ~any(rowMatch)
    return
end % if

artifactLevels( : , ~rowMatch) = [];
artifactGapIndicators( : , ~rowMatch) = [];

severityFlags.values = max(artifactLevels, [], 2);
severityFlags.gapIndicators = all(artifactGapIndicators, 2);

% Return.
return


function [severityFlags] = ...
set_indicators_for_flux_gaps(fluxGapIndicators, severityFlags)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [severityFlags] = ...
% set_indicators_for_flux_gaps(fluxGapIndicators, severityFlags)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Ensure that the contamination flags are gapped on cadences where the
% target flux is gapped.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Define the metric only on cadences where the raw flux is valid.
severityFlags.values(fluxGapIndicators) = 0;
severityFlags.gapIndicators(fluxGapIndicators) = true;

% Return.
return
