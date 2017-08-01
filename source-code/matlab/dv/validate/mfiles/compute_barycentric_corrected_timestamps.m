function [dvDataStruct, alerts] = ...
compute_barycentric_corrected_timestamps(dvDataStruct, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvDataStruct] = ...
% compute_barycentric_corrected_timestamps(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Loop through the targets and generate barycentric corrected timestamps
% for each based on target right ascension and declination. Append the
% struct array of corrected timestamps (one element per target) to the
% dvDataStruct.
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
RA_HOURS_TO_DEGREES = 360 / 24;

% Get fields from the input structure.
cadenceTimes = dvDataStruct.dvCadenceTimes;
raDec2PixModel = dvDataStruct.raDec2PixModel;
targetStruct = dvDataStruct.targetStruct;
targetTableDataStruct = dvDataStruct.targetTableDataStruct;
configMaps = dvDataStruct.configMaps;
fcConstants = dvDataStruct.fcConstants;

% Initialize the barycentric cadence times structure.
gapIndicators = cadenceTimes.gapIndicators;
timestamps = zeros(size(gapIndicators));
nTargets = length(targetStruct);

barycentricCadenceTimes = repmat(struct( ...
    'keplerId', [], ...
    'startTimestamps', timestamps, ...
    'midTimestamps', timestamps, ...
    'endTimestamps', timestamps, ...
    'gapIndicators', gapIndicators) , [1, nTargets]);

% Instantiate a raDec2Pix object.
[raDec2PixObject] = raDec2PixClass(raDec2PixModel, 'one-based');

% Compute the readout offsets by target table. They change with CCD module
% from quarter to quarter.
lcTargetTableIds = cadenceTimes.lcTargetTableIds;
readoutOffset = zeros(size(gapIndicators));
nTables = length(targetTableDataStruct);

for iTable = 1 : nTables
    
    targetTableId = targetTableDataStruct(iTable).targetTableId;
    ccdModule = targetTableDataStruct(iTable).ccdModule;
    
    offset = get_readout_offset(configMaps, ccdModule, fcConstants);
    isTable = lcTargetTableIds == targetTableId;
    readoutOffset(isTable) = offset;
    
end % for iTable

% Loop through the targets and compute the barycentric corrected
% timestamps.
for iTarget = 1 : nTargets
    
    % Set the keplerId.
    keplerId = targetStruct(iTarget).keplerId;
    barycentricCadenceTimes(iTarget).keplerId = keplerId;
    
    % Get the target RA and DEC in degrees. If the RA or DEC is unknown
    % (for a custom target) then estimate them by inverting the motion
    % polynomials for the target table associated with the first available
    % pixel data. Note that CCD coordinates are still 0-based when this
    % function is called. Issue a warning if the RA and DEC are estimated
    % for any given target. Update the RA/Dec parameters in the DV input
    % structure so that the esimated values are known to the rest of DV.
    raDegrees = targetStruct(iTarget).raHours.value * RA_HOURS_TO_DEGREES;
    decDegrees = targetStruct(iTarget).decDegrees.value;
    
    if isnan(raDegrees) || isnan(decDegrees)
        
        targetTableId = targetStruct(iTarget).targetDataStruct(1).targetTableId;
        pixelDataFileName = targetStruct(iTarget).targetDataStruct(1).pixelDataFileName;
        [pixelDataStruct, status, path, name, ext] = ...
            file_to_struct(pixelDataFileName, 'pixelDataStruct');                           %#ok<ASGLU>
        if ~status
            error('dv:computeBarycentricCorrectedTimestamps:unknownDataFileType', ...
                'unknown pixel data file type (%s%s)', ...
                name, ext);
        end % if
        ccdRows = [pixelDataStruct.ccdRow]' + 1;
        ccdColumns = [pixelDataStruct.ccdColumn]' + 1;
        inOptimalAperture = [pixelDataStruct.inOptimalAperture]';
        clear pixelDataStruct
        
        if any(inOptimalAperture)
            nominalRow = mean(ccdRows(inOptimalAperture));
            nominalColumn = mean(ccdColumns(inOptimalAperture));
        else
            nominalRow = mean(ccdRows);
            nominalColumn = mean(ccdColumns);
        end % if / else
        
        targetTableIds = [targetTableDataStruct.targetTableId];
        motionPolyStruct = ...
            targetTableDataStruct(targetTableIds == targetTableId).motionPolyStruct;
        motionPolyGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
        
        raDegrees = nan(size(motionPolyGapIndicators));
        decDegrees = nan(size(motionPolyGapIndicators));
        validCadences = find(~motionPolyGapIndicators);
        
        for iCadence = validCadences( : )'
            [raDegrees(iCadence), decDegrees(iCadence)] = ...
                invert_motion_polynomial(nominalRow, nominalColumn, ...
                motionPolyStruct(iCadence), zeros(2, 2), fcConstants);
        end % for iCadence
        
        raDegrees = nanmean(raDegrees);
        decDegrees = nanmean(decDegrees);
        
        dvDataStruct.targetStruct(iTarget).raHours.value = raDegrees / RA_HOURS_TO_DEGREES;
        dvDataStruct.targetStruct(iTarget).raHours.uncertainty = 0;
        dvDataStruct.targetStruct(iTarget).raHours.provenance = 'DV Estimate';
        dvDataStruct.targetStruct(iTarget).decDegrees.value = decDegrees;
        dvDataStruct.targetStruct(iTarget).decDegrees.uncertainty = 0;
        dvDataStruct.targetStruct(iTarget).decDegrees.provenance = 'DV Estimate';
        
        resultsStruct.alerts = alerts;
        string = 'RA and DEC have been estimated for purpose of computing barycentric timestamps';
        [resultsStruct] = add_dv_alert(resultsStruct, 'dvMatlabController', ...
            'warning', string, iTarget, keplerId);
        alerts = resultsStruct.alerts;
        disp(alerts(end).message);
        
    end % if
    
    % Compute the barycentric cadence times for all timestamps in the unit
    % of work. Convert to BKJD.
    [barycentricCadenceTimes(iTarget).startTimestamps] = ...
        kepler_time_to_barycentric(raDec2PixObject, raDegrees, decDegrees, ...
        cadenceTimes.startTimestamps - readoutOffset( : )) - kjd_offset_from_mjd ;
    [barycentricCadenceTimes(iTarget).midTimestamps] = ...
        kepler_time_to_barycentric(raDec2PixObject, raDegrees, decDegrees, ...
        cadenceTimes.midTimestamps - readoutOffset( : )) - kjd_offset_from_mjd ;
    [barycentricCadenceTimes(iTarget).endTimestamps] = ...
        kepler_time_to_barycentric(raDec2PixObject, raDegrees, decDegrees, ...
        cadenceTimes.endTimestamps - readoutOffset( : )) - kjd_offset_from_mjd ;
    
    % Ensure that the results are column vectors.
    barycentricCadenceTimes(iTarget).startTimestamps = ...
        barycentricCadenceTimes(iTarget).startTimestamps( : );
    barycentricCadenceTimes(iTarget).midTimestamps = ...
        barycentricCadenceTimes(iTarget).midTimestamps( : );
    barycentricCadenceTimes(iTarget).endTimestamps = ...
        barycentricCadenceTimes(iTarget).endTimestamps( : );
    
end % for iTarget

% Append the barycentric corrected cadence times structure to the DV data
% struct.
dvDataStruct.barycentricCadenceTimes = barycentricCadenceTimes;

% Return.
return
