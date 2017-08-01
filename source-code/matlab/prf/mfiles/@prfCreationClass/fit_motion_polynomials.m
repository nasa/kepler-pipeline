function [motionBlobFileName, motionPolyStruct] = ...
fit_motion_polynomials(prfCreationObject, centroids)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [motionBlobFileName, motionPolyStruct] = ...
% fit_motion_polynomials(prfCreationObject, centroids)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Fit two-dimensional motion polynomials separately to target row and column
% centroids for each cadence. Uses robust_polyfit2d/weighted_polyfit2D. Note
% that motion polynomials are fit as a function of right ascension and
% declination for the given module output. RA and DEC are both specified in
% units of degrees. Add metadata to create motion polynomial super structure.
% Save the motion polynomials to a matlab file and write the file name to the
% PA results structure.
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


% Set constant and motion polynomial file name.
RA_HOURS_TO_DEGREES = 360 / 24;
prfMotionFileName = ['prfMotion_',datestr(now,30),'.mat'];

% Get fields from input object and results structure.
ccdModule = prfCreationObject.ccdModule;
ccdOutput = prfCreationObject.ccdOutput;
startCadence = prfCreationObject.startCadence;
endCadence = prfCreationObject.endCadence;

cadenceTimes = prfCreationObject.cadenceTimes;
startTimestamps = cadenceTimes.startTimestamps;
midTimestamps = cadenceTimes.midTimestamps;
endTimestamps = cadenceTimes.endTimestamps;

motionConfigurationStruct = prfCreationObject.motionConfigurationStruct;
aicOrderSelectionEnabled = ...
    motionConfigurationStruct.aicOrderSelectionEnabled;

targetStarsStruct = prfCreationObject.targetStarsStruct;

% Build arrays (nCadences x nTargets) with row and column centroids,
% uncertainties and gap indicators (which apply to both rows and columns).
centroidRows = [centroids.rows];
centroidRowUncertainties = [centroids.rowUncertainties];
centroidColumns = [centroids.columns];
centroidColumnUncertainties = [centroids.columnUncertainties];

gapIndicesCellArray = {centroids.gapIndices};
gapArray = false(size(centroidRows));
for iTarget = 1 : length(gapIndicesCellArray)
    gapArray(gapIndicesCellArray{iTarget}, iTarget) = true;
end

% Create vectors with the right ascension and declination of each of the
% target stars, in degrees.
targetRa = RA_HOURS_TO_DEGREES * [targetStarsStruct.ra]';
targetDec = [targetStarsStruct.dec]';

% For the purposes of the FPG/PRF loop, do not allow centroid errors with
% small associated uncertainties to corrupt the robust fitting process.
% Rather, set the uncertainties for all valid centroids for each target to
% be equal to the median uncertainty of the valid centroids for that
% target.
for iTarget = 1 : length(centroids)
    targetGapIndicators = gapArray( : , iTarget);
    if any(~targetGapIndicators)
        medianRowUncertainty = ...
            median(centroidRowUncertainties(~targetGapIndicators, iTarget));
        centroidRowUncertainties(~targetGapIndicators, iTarget) = ...
            medianRowUncertainty;
        medianColumnUncertainty = ...
            median(centroidColumnUncertainties(~targetGapIndicators, iTarget));
        centroidColumnUncertainties(~targetGapIndicators, iTarget) = ...
            medianColumnUncertainty;
    end % if
end % for iTarget
        
% Use AIC to determine optimal motion polynomial orders if enabled.
if aicOrderSelectionEnabled
    [motionConfigurationStruct] = ...
        select_motion_polynomial_orders(centroidRows, centroidRowUncertainties, ...
        centroidColumns, centroidColumnUncertainties, gapArray, targetRa, targetDec, ...
        motionConfigurationStruct);
end % if aicOrderSelectionEnabled

% Do the motion polynomial fit.
[rowMotionStruct, columnMotionStruct, motionGapIndicators] = ...
    fit_motion_polynomials_by_cadence(centroidRows, centroidRowUncertainties, ...
    centroidColumns, centroidColumnUncertainties, targetRa, targetDec, ...
    gapArray, motionConfigurationStruct);

% Initialize motion polynomial structure.
nCadences = length(startTimestamps);

motionPolyStruct = repmat(struct( ...
    'cadence', -1, ...
    'mjdStartTime', -1, ...
    'mjdMidTime', -1, ...
    'mjdEndTime', -1, ...
    'module', -1, ...
    'output', -1, ...
    'rowPoly', [], ...
    'rowPolyStatus', -1, ...
    'colPoly', [], ...
    'colPolyStatus', -1), [1, nCadences]);

% Create motion polynomial structure with metadata.
cadence = startCadence;  

for iCadence = 1 : nCadences
    polyStruct.cadence = cadence;
    polyStruct.mjdStartTime = startTimestamps(iCadence);
    polyStruct.mjdMidTime = midTimestamps(iCadence);
    polyStruct.mjdEndTime = endTimestamps(iCadence);
    polyStruct.module = ccdModule;
    polyStruct.output = ccdOutput;
    polyStruct.rowPoly = rowMotionStruct(iCadence);
    polyStruct.rowPolyStatus = ...
        double(~motionGapIndicators(iCadence));
    polyStruct.colPoly = columnMotionStruct(iCadence);
    polyStruct.colPolyStatus = ...
        double(~motionGapIndicators(iCadence));
    motionPolyStruct(iCadence) = polyStruct;
    cadence = cadence + 1;
end % for iCadence

% Check for cadence consistency.
if cadence - 1 ~= endCadence
    error('PRF:fitMotionPolynomials:cadenceInconsistency', ...
        'Start cadence = %d, End cadence = %d; Number of timestamps = %d', ...
        startCadence, endCadence, nCadences)
end

% Blobify the motion polynomial structure and write to a matlab file. Copy
% the file name to the PRF results structure.
struct_to_blob(motionPolyStruct, prfMotionFileName);
motionBlobFileName = prfMotionFileName;

% Return.
return
