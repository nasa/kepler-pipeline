%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [targetDataStruct motionPolyStruct] = ...
% pdc_gap_data_anomalies(targetDataStruct, dataAnomalyIndicators, lcDataAnomalyIndicators, motionPolyStruct, cadenceTimes, thrusterFiringDataStruct )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Ensure that gaps are set in input (raw) flux time series for cadences
% marked by the following dataAnomalyTypes: EXCLUDE, SAFE_MODE, EARTH_POINT,
% ATTITUDE_TWEAK, COARSE_POINT, ARGABRIGHTENING. Also, gap the motion
% polynomials for the (long) data anomaly cadences. Use the long cadence
% anomaly indicators to do this.
%
% Also record the cadences associated with attitude tweaks in a seperate field in targetDataStruct so that the SPSD detector can be forced to not detect SPSDs
% over said cadences.
%
% We also should gap all cadence not flagged at fine point via cadenceTimes.isFinePnt. This is for the benefit of K2 data where coarse point data prior to
% science attitude is processed in CAL and may be passed to PDC.
%
% For K2 data gap all thruster firing cadences.
%
% Inputs:
%   targetDataStruct
%   dataAnomalyIndicators
%   lcDataAnomalyIndicators     -- used for gapping the motion polynomials
%   motionPolyStruct
%   cadenceTimes                -- for the getting isFinePoint
%   thrusterFiringDataStruct    -- thruster firing data synchronized to cadence times
%
% Outputs
%   targetDataStruct    --
%       .values                     -- zeroed in data anomalies
%       .uncertainties              -- zeroed in data anomalies
%       .gapIndicators              -- set true in data anomalies
%       .attitudeTweakIndicators    -- NEW FIELD: set to true around attitude tweaks
%
%   motiontPloyStruct   -- gaos the motion polynomails JUST for the long cadence anomaly indicators (Use for old PDC, candidate for removal)
%
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

function [targetDataStruct motionPolyStruct] = pdc_gap_data_anomalies(targetDataStruct, dataAnomalyIndicators, lcDataAnomalyIndicators, ...
                motionPolyStruct, cadenceTimes, thrusterFiringDataStruct)

% Find the thruster firing events
if (isempty(thrusterFiringDataStruct))
    thrusterFiring = false(length(cadenceTimes.isFinePnt),1);
else
    thrusterFiring = any(thrusterFiringDataStruct.thrusterFiringFlag')';
end

% Set the desired gap indicators.
gapIndicators = ...
    dataAnomalyIndicators.attitudeTweakIndicators | ...
    dataAnomalyIndicators.safeModeIndicators | ...
    dataAnomalyIndicators.earthPointIndicators | ...
    dataAnomalyIndicators.coarsePointIndicators | ...
    dataAnomalyIndicators.argabrighteningIndicators | ...
    dataAnomalyIndicators.excludeIndicators | ...
    thrusterFiring;

% We should also make sure any coarse point data is gapped
gapIndicators = gapIndicators | ~cadenceTimes.isFinePnt;

% If data anomalies fill up all gaps then crash with descriptive message
if (all(gapIndicators))
    error('pdc_gap_data_anomalies: all cadences are flagged with anomalies! Does not compute... blip, blip... does not compute... (smoke billowing from computer)')
end

% Loop over the targets and set the gaps.
nTargets = length(targetDataStruct);

for iTarget = 1 : nTargets
    targetDataStruct(iTarget).values(gapIndicators) = 0;
    targetDataStruct(iTarget).uncertainties(gapIndicators) = 0;
    targetDataStruct(iTarget).gapIndicators(gapIndicators) = true;
end % for iTarget

% Set gaps for the motion polynomials if present.
if (~isempty(motionPolyStruct))
    lcGapIndicators = ...
        lcDataAnomalyIndicators.attitudeTweakIndicators | ...
        lcDataAnomalyIndicators.safeModeIndicators | ...
        lcDataAnomalyIndicators.earthPointIndicators | ...
        lcDataAnomalyIndicators.coarsePointIndicators | ...
        lcDataAnomalyIndicators.argabrighteningIndicators | ...
        lcDataAnomalyIndicators.excludeIndicators;

    status = logical([motionPolyStruct.rowPolyStatus]);
    statusCellArray = num2cell(double(status & ~lcGapIndicators'));

    nCadences = length(motionPolyStruct);
    [motionPolyStruct(1 : nCadences).rowPolyStatus] = statusCellArray{ : };
    [motionPolyStruct(1 : nCadences).colPolyStatus] = statusCellArray{ : };
end


% Record the cadences associated with attitude tweaks, include cadences on either side of the attitude tweak (note: thse cadences are NOT gapped, just recorded
% here)
% This is so that the SPSD detector knows to ignore these cadences (see spsdCorrectedFluxStruct

cadencePadding = 5; % number of cadences on either side of the attitude tweaks to also include
attitudeTweakIndicators = dataAnomalyIndicators.attitudeTweakIndicators;
attitudeTweakIndices = find(attitudeTweakIndicators);

nCadences = length(targetDataStruct(1).values);
for iTarget = 1 : nTargets
    % Be sure to include cadences on either side of any gaps around the tweaks
    targetDataStruct(iTarget).attitudeTweakIndicators = false(nCadences,1) ;
    for iTweak = 1: length(attitudeTweakIndices)
        firstNonGapBeforeTweak = max(find(~targetDataStruct(iTarget).gapIndicators(1:attitudeTweakIndices(iTweak))));
        if (isempty(firstNonGapBeforeTweak))
            % No non-gaps before tweak so doesn't matter what I set this to.
            firstNonGapBeforeTweak = attitudeTweakIndices(iTweak);
        end
        firstNonGapAfterTweak  = min(find(~targetDataStruct(iTarget).gapIndicators(attitudeTweakIndices(iTweak):end))) - 1 + attitudeTweakIndices(iTweak);
        if (isempty(firstNonGapAfterTweak))
            % No non-gaps before tweak so doesn't matter what I set this to.
            firstNonGapAfterTweak = attitudeTweakIndices(iTweak);
        end
        cadencesToMark = [firstNonGapBeforeTweak-cadencePadding:firstNonGapBeforeTweak  firstNonGapAfterTweak:firstNonGapAfterTweak+cadencePadding-1];
        % remove indices out of cadence range (THIS IS LOOKING AT YOU MARTIN!)
        cadencesToMark = cadencesToMark(cadencesToMark > 0 & cadencesToMark <= nCadences);
        targetDataStruct(iTarget).attitudeTweakIndicators(cadencesToMark) = true;
    end
end




return
