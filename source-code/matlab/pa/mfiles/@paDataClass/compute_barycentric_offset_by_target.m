function [paResultsStruct] = ...
compute_barycentric_offset_by_target(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paDataObject] = ...
% compute_barycentric_corrected_timestamps(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Loop through the targets and generate barycentric offsets for each based
% on target right ascension and declination. Use cadence mid-timestamps.
% The barycentric offset can then be added to a cadence mid-timestamp to
% obtain the barycentric corrected timestamp for a given target. Units for
% the offset are days.
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
HOURS_TO_DEGREES = 360 / 24;

% Get fields from the input object and output structure.
cadenceTimes = paDataObject.cadenceTimes;
raDec2PixModel = paDataObject.raDec2PixModel;
targetStarDataStruct = paDataObject.targetStarDataStruct;

targetStarResultsStruct = paResultsStruct.targetStarResultsStruct;

% Get the timestamps, cadence gap indicators and number of targets.
mjdTimestamps = cadenceTimes.midTimestamps;
gapIndicators = cadenceTimes.gapIndicators;
nTargets = length(targetStarDataStruct);

% Instantiate a raDec2Pix object.
[raDec2PixObject] = raDec2PixClass(raDec2PixModel, 'one-based');

% Get the readout offset for the ccdModule
readoutOffset = get_readout_offset(paDataObject.spacecraftConfigMap, paDataObject.ccdModule, paDataObject.fcConstants);

% Loop through the targets. Make sure that the results are column vectors.
mjdTimestamps = mjdTimestamps(~gapIndicators);

for iTarget = 1 : nTargets
    
    raDegrees = targetStarDataStruct(iTarget).raHours * HOURS_TO_DEGREES;
    decDegrees = targetStarDataStruct(iTarget).decDegrees;
    
    % RA or DEC could be NaN for custom targets. Don't try to compute
    % barycentric corrections for these targets.
    if ~isnan(raDegrees) && ~isnan(decDegrees)
    
        [barycentricTimestamps] = ...
            kepler_time_to_barycentric(raDec2PixObject, raDegrees, decDegrees,...
                                        mjdTimestamps - readoutOffset);

        values = zeros(size(gapIndicators));
        values(~gapIndicators) = barycentricTimestamps( : ) - mjdTimestamps;
                       
        targetStarResultsStruct(iTarget).barycentricTimeOffset.values = ...
            values;
        targetStarResultsStruct(iTarget).barycentricTimeOffset.gapIndicators = ...
            gapIndicators;
        
    else
        
        targetStarResultsStruct(iTarget).barycentricTimeOffset.values = ...
            zeros(size(gapIndicators));
        targetStarResultsStruct(iTarget).barycentricTimeOffset.gapIndicators = ...
            true(size(gapIndicators));
        
    end % if / else
    
end % for iTarget

% Append the target star results structure to the PA results structure.
paResultsStruct.targetStarResultsStruct = targetStarResultsStruct;

% Return.
return
