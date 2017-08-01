function [differenceImageResults] = ...
perform_dv_difference_image_centroiding_and_offset_analysis(dvDataObject, ...
differenceImageResults, prfObject, isCadenceForFpaToSkyTransformation)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [differenceImageResults] = ...
% perform_dv_difference_image_centroiding_and_offset_analysis(dvDataObject, ...
% differenceImageResults, prfObject, isCadenceForFpaToSkyTransformation)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the PRF-based centroids of the control (i.e. mean out of transit)
% and difference images for the given target, planet candidate and target
% table. Ensure that the centroids are gapped if they do not fall within
% the bounding box of the pixel mask for the given target. Update the
% centroid results fields in the difference image results structure with
% the centroids and associated uncertainties.
%
% Compute the offsets between the difference and control image centroids
% separately in row and column. Compute the focal plane offset as the
% square root of the sum of the squares of the row and column offsets.
% Propagate the uncertainties in the respective centroids to the
% uncertainties in the offsets. Update the centroid offsets fields in the
% difference image results structure with the offsets and associated
% uncertainties.
%
% Transform the control and difference image centroids from focal plane to
% sky coordinates by inverting the motion polynomials for the given target
% table at the in-transit cadences where the difference image was
% determined. Average the transformed coordinates to obtain the sky
% control and difference image centroids. Compute the offsets between the
% difference and control images separately in RA and DEC. The sky offset is
% then determined as the square root of the sum of the squares of the RA
% and DEC offsets. Propagate the uncertainties in the respective centroids
% to the uncertainties in the offsets. Update the centroid offsets fields
% in the difference image results structure with the offsets and associated
% uncertainties.
%
% Transform the KIC target position from sky to focal plane coordinates by
% evaluating the motion polynomials at the in-transit candences. Repeat the
% computation of the focal plane and sky offsets for the difference image
% centroid with respect to the KIC reference coordinates for the given
% target and table. Update the centroid offsets fields in the difference
% image results structure accordingly.
%
% The dvDataObject and differenceImageResults are defined in the headers of
% the dv_matlab_controller and validate_dv_inputs functions. The prfObject 
% is an object of the prfCollectionClass containing the PRF model(s) for
% the given module output. The logical isCadenceForFpaToSkyTransformation
% column vector specifies the cadences for which the given planet candidate
% is determined to be in transit in the given target table.
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
GAP_VALUE = -1;

DEGREES_PER_HOUR = 360 / 24;

% Get needed fields from the DV data object.
dvCadenceTimes = dvDataObject.dvCadenceTimes;
cadenceGapIndicators = dvCadenceTimes.gapIndicators;
midTimestamps = dvCadenceTimes.midTimestamps;
cadenceNumbers = dvCadenceTimes.cadenceNumbers;

fcConstants = dvDataObject.fcConstants;

% Set a nominal timestamp for the given target table. Also get the motion
% polynomials for the given target table.
targetTableId = differenceImageResults.targetTableId;
targetTableIds = [dvDataObject.targetTableDataStruct.targetTableId];
targetTableDataStruct = ...
    dvDataObject.targetTableDataStruct(targetTableIds == targetTableId);

targetTableStartCadence = targetTableDataStruct.startCadence;
targetTableTimestamp = midTimestamps(find(~cadenceGapIndicators & ...
    cadenceNumbers >= targetTableStartCadence, 1, 'first'));

motionPolyStruct = targetTableDataStruct.motionPolyStruct;

% Compute the PRF-based centroid for the control (i.e. mean out of transit)
% image. Save the centroid and associated uncertainties if it is valid.
differenceImagePixelStructArray = ...
    [differenceImageResults.differenceImagePixelStruct];

pixelRows = [differenceImagePixelStructArray.ccdRow]';
pixelColumns = [differenceImagePixelStructArray.ccdColumn]';

meanFluxArray = [differenceImagePixelStructArray.meanFluxOutOfTransit];
pixelValues = [meanFluxArray.value]';
pixelUncertainties = [meanFluxArray.uncertainty]';

[fpaControlCentroidRow, fpaControlCentroidColumn, ...
    fpaControlCentroidStatus, fpaControlCentroidCovariance, ...
    differenceImageResults.controlImageCentroid] = ...
    compute_dv_prf_centroid(pixelRows, pixelColumns, pixelValues, ...
    pixelUncertainties, prfObject, targetTableTimestamp, fcConstants, ...
    differenceImageResults.controlImageCentroid);

% Compute the PRF-based centroid for the difference image. Save the
% centroid and associated uncertainties if it is valid.
meanFluxArray = [differenceImagePixelStructArray.meanFluxDifference];
pixelValues = [meanFluxArray.value]';
pixelUncertainties = [meanFluxArray.uncertainty]';

[fpaDifferenceCentroidRow, fpaDifferenceCentroidColumn, ...
    fpaDifferenceCentroidStatus, fpaDifferenceCentroidCovariance, ...
    differenceImageResults.differenceImageCentroid, ...
    differenceImageResults.qualityMetric] = ...
    compute_dv_prf_centroid(pixelRows, pixelColumns, pixelValues, ...
    pixelUncertainties, prfObject, targetTableTimestamp, fcConstants, ...
    differenceImageResults.differenceImageCentroid, ...
    differenceImageResults.qualityMetric);

% Convert the FPA centroids to sky coordinates (RA, DEC) with associated
% uncertainties for each valid in-transit cadence. Compute the average
% sky position over all of the valid in-transit cadences. Save the results
% if the centroids are valid.
polyGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
transformationCadenceIndices = ...
    find(~polyGapIndicators & isCadenceForFpaToSkyTransformation);

[skyControlCentroidRaHours, skyControlCentroidDecDegrees, ...
    skyControlCentroidStatus, skyControlCentroidCovariance, ...
    differenceImageResults.controlImageCentroid] = ...
    transform_centroid_from_fpa_to_sky_coordinates(...
    fpaControlCentroidRow, fpaControlCentroidColumn, ...
    fpaControlCentroidStatus, fpaControlCentroidCovariance, ...
    transformationCadenceIndices, motionPolyStruct, fcConstants, ...
    differenceImageResults.controlImageCentroid);

[skyDifferenceCentroidRaHours, skyDifferenceCentroidDecDegrees, ...
    skyDifferenceCentroidStatus, skyDifferenceCentroidCovariance, ...
    differenceImageResults.differenceImageCentroid] = ...
    transform_centroid_from_fpa_to_sky_coordinates( ...
    fpaDifferenceCentroidRow, fpaDifferenceCentroidColumn, ...
    fpaDifferenceCentroidStatus, fpaDifferenceCentroidCovariance, ...
    transformationCadenceIndices, motionPolyStruct, fcConstants, ...
    differenceImageResults.differenceImageCentroid);

% Compute the centroid offsets and propagate the associated uncertainties
% if both centroids were successfully computed.
if ~fpaControlCentroidStatus && ~fpaDifferenceCentroidStatus
    
    [differenceImageResults.controlCentroidOffsets] = ...
        compute_fpa_offsets_and_uncertainties(fpaControlCentroidRow, ...
        fpaControlCentroidColumn, fpaControlCentroidCovariance, ...
        fpaDifferenceCentroidRow, fpaDifferenceCentroidColumn, ...
        fpaDifferenceCentroidCovariance, ...
        differenceImageResults.controlCentroidOffsets);
    
end % if

if ~skyControlCentroidStatus && ~skyDifferenceCentroidStatus
    
    [differenceImageResults.controlCentroidOffsets] = ...
        compute_sky_offsets_and_uncertainties(skyControlCentroidRaHours, ...
        skyControlCentroidDecDegrees, skyControlCentroidCovariance, ...
        skyDifferenceCentroidRaHours, skyDifferenceCentroidDecDegrees, ...
        skyDifferenceCentroidCovariance, ...
        differenceImageResults.controlCentroidOffsets);
    
end % if

% Compute the centroid offsets with respect to the KIC reference centroid
% and propagate the associated uncertainties if both centroids were
% successfully computed.
referenceCentroidStatus = ...
    differenceImageResults.kicReferenceCentroid.raHours.uncertainty == GAP_VALUE || ...
    differenceImageResults.kicReferenceCentroid.decDegrees.uncertainty == GAP_VALUE;

if ~referenceCentroidStatus && ~isempty(transformationCadenceIndices)
    
    % Compute the reference CCD coordinates over the given target table
    % from the motion polynomials based on the KIC RA/DEC (if available).
    % Set the uncertainty in the mean row and column coordinates to be the
    % RMS uncertainty of the evaluated row and column motion polynomials.
    % Assume that there are no uncertainties in the KIC RA/DEC coordinates.
    referenceRaHours = ...
        differenceImageResults.kicReferenceCentroid.raHours.value;
    referenceRaDegrees = referenceRaHours * DEGREES_PER_HOUR;
    referenceDecDegrees = ...
        differenceImageResults.kicReferenceCentroid.decDegrees.value;
    
    [referenceRow, referenceRowUncertainty, ...
        referenceColumn, referenceColumnUncertainty, referenceCovariance] = ...
        transform_kic_position_to_fpa_coordinates( ...
        referenceRaDegrees, referenceDecDegrees, motionPolyStruct, ...
        transformationCadenceIndices);
    
    % Update the results structure with the FPA centroid and uncertainties.
    differenceImageResults.kicReferenceCentroid.row.value = ...
        referenceRow;
    differenceImageResults.kicReferenceCentroid.row.uncertainty = ...
        referenceRowUncertainty;
    differenceImageResults.kicReferenceCentroid.column.value = ...
        referenceColumn;
    differenceImageResults.kicReferenceCentroid.column.uncertainty = ...
        referenceColumnUncertainty;
    differenceImageResults.kicReferenceCentroid.rowColumnCovariance = ...
        referenceCovariance;
    differenceImageResults.kicReferenceCentroid.transformationCadenceIndices = ...
        transformationCadenceIndices;
    
    % Compute the FPA offsets if the difference image FPA centroid is
    % valid. Update the results structure.
    if ~fpaDifferenceCentroidStatus
        
        [differenceImageResults.kicCentroidOffsets] = ...
            compute_fpa_offsets_and_uncertainties(referenceRow, ...
            referenceColumn, referenceCovariance, ...
            fpaDifferenceCentroidRow, fpaDifferenceCentroidColumn, ...
            fpaDifferenceCentroidCovariance, ...
            differenceImageResults.kicCentroidOffsets);
    
    end % if
    
    % Compute the sky offsets if the difference image sky centroid is
    % valid. Update the results structure.
    if ~skyDifferenceCentroidStatus
        
        referenceCovariance = ...
            differenceImageResults.kicReferenceCentroid.raDecCovariance;

        [differenceImageResults.kicCentroidOffsets] = ...
            compute_sky_offsets_and_uncertainties(referenceRaHours, ...
            referenceDecDegrees, referenceCovariance, ...
            skyDifferenceCentroidRaHours, skyDifferenceCentroidDecDegrees, ...
            skyDifferenceCentroidCovariance, ...
            differenceImageResults.kicCentroidOffsets);
        
    end % if
    
end % if

% Return.
return
