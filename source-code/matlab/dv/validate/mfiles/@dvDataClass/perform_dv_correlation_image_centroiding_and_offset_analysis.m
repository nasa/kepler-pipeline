function [pixelCorrelationResults] = ...
perform_dv_correlation_image_centroiding_and_offset_analysis(dvDataObject, ...
pixelCorrelationResults, differenceImageResults, prfObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pixelCorrelationResults] = ...
% perform_dv_correlation_image_centroiding_and_offset_analysis(dvDataObject, ...
% pixelCorrelationResults, differenceImageResults, prfObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the PRF-based centroids of the pixel correlation image for the
% given target, planet candidate and target table. The value for each pixel
% in the centroid aperture is given by the associated correlation statistic
% for that pixel. The values are therefore Gaussian distributed with unit
% variance. Ensure that the centroid is gapped if it does not fall within
% the bounding box of the pixel mask for the given target. Update the
% centroid results fields in the pixel correlation results structure with
% the centroid and associated uncertainties.
%
% Compute the offsets between the correlation and control (i.e. mean out of
% transit) image centroids separately in row and column. Compute the focal
% plane offset as the square root of the sum of the squares of the row and
% column offsets. Propagate the uncertainties in the respective centroids
% to the uncertainties in the offsets. Update the centroid offsets fields
% in the difference image results structure with the offsets and associated
% uncertainties.
%
% Transform the correlation image centroid from focal plane to sky
% coordinates by inverting the motion polynomials for the given target
% table at the in-transit cadences. Average the transformed coordinates to
% obtain the sky correlation image centroid. Compute the offsets between
% the correlation and control images separately in RA and DEC. The sky
% offset is then determined as the square root of the sum of the squares of
% the RA and DEC offsets. Propagate the uncertainties in the respective
% centroids to the uncertainties in the offsets. Update the centroid
% offsets fields in the pixel correlation results structure with the
% offsets and associated uncertainties.
%
% Repeat the computation of the focal plane and sky offsets for the pixel
% correlation image centroid with respect to the KIC reference coordinates
% for the given target and table. Update the centroid offsets fields in the
% pixel correlation results structure accordingly.
%
% The dvDataObject, pixelCorrelationResults and differenceImageResults are
% defined in the headers of the dv_matlab_controller and validate_dv_inputs
% functions. The prfObject is an object of the prfCollectionClass
% containing the PRF model(s) for the given module output.
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


% Set constant.
GAP_VALUE = -1;

% Get needed fields from the DV data object.
dvCadenceTimes = dvDataObject.dvCadenceTimes;
cadenceGapIndicators = dvCadenceTimes.gapIndicators;
midTimestamps = dvCadenceTimes.midTimestamps;
cadenceNumbers = dvCadenceTimes.cadenceNumbers;

fcConstants = dvDataObject.fcConstants;

% Set a nominal timestamp for the given target table. Also get the motion
% polynomials for the given target table.
targetTableId = pixelCorrelationResults.targetTableId;
targetTableIds = [dvDataObject.targetTableDataStruct.targetTableId];
targetTableDataStruct = ...
    dvDataObject.targetTableDataStruct(targetTableIds == targetTableId);

targetTableStartCadence = targetTableDataStruct.startCadence;
targetTableTimestamp = midTimestamps(find(~cadenceGapIndicators & ...
    cadenceNumbers >= targetTableStartCadence, 1, 'first'));

motionPolyStruct = targetTableDataStruct.motionPolyStruct;

% Get the timetag and PRF-based centroid for the control (i.e. mean out of
% transit) image.
pixelCorrelationResults.mjdTimestamp = differenceImageResults.mjdTimestamp;
[pixelCorrelationResults.controlImageCentroid] = ...
    copy_centroid_fields(differenceImageResults.controlImageCentroid, ...
    pixelCorrelationResults.controlImageCentroid);

controlImageCentroid = pixelCorrelationResults.controlImageCentroid;

if controlImageCentroid.row.uncertainty ~= GAP_VALUE && ...
        controlImageCentroid.column.uncertainty ~= GAP_VALUE
    fpaControlCentroidRow = controlImageCentroid.row.value;
    fpaControlCentroidColumn = controlImageCentroid.column.value;
    fpaControlCentroidCovariance = controlImageCentroid.rowColumnCovariance;
    fpaControlCentroidStatus = 0;
else
    fpaControlCentroidRow = 0;
    fpaControlCentroidColumn = 0;
    fpaControlCentroidCovariance = zeros([2, 2]);
    fpaControlCentroidStatus = 1;
end % if / else

% Compute the PRF-based centroid for the correlation image. Note that the
% uncertainties in the correlation statistics are all equal to one. Save
% the centroid and associated uncertainties if it is valid.
pixelCorrelationStatisticStructArray = ...
    [pixelCorrelationResults.pixelCorrelationStatisticStruct];

pixelRows = [pixelCorrelationStatisticStructArray.ccdRow]';
pixelColumns = [pixelCorrelationStatisticStructArray.ccdColumn]';

pixelValues = [pixelCorrelationStatisticStructArray.value]';
pixelUncertainties = [pixelCorrelationStatisticStructArray.significance]';
pixelUncertainties(pixelUncertainties ~= GAP_VALUE) = 1;

[fpaCorrelationCentroidRow, fpaCorrelationCentroidColumn, ...
    fpaCorrelationCentroidStatus, fpaCorrelationCentroidCovariance, ...
    pixelCorrelationResults.correlationImageCentroid] = ...
    compute_dv_prf_centroid(pixelRows, pixelColumns, pixelValues, ...
    pixelUncertainties, prfObject, targetTableTimestamp, fcConstants, ...
    pixelCorrelationResults.correlationImageCentroid);

% Get the FPA centroids in sky coordinates (ra, dec) with associated
% uncertainties. Save the results if the centroids are valid.
if controlImageCentroid.raHours.uncertainty ~= GAP_VALUE && ...
        controlImageCentroid.decDegrees.uncertainty ~= GAP_VALUE
    skyControlCentroidRaHours = controlImageCentroid.raHours.value;
    skyControlCentroidDecDegrees = controlImageCentroid.decDegrees.value;
    skyControlCentroidCovariance = controlImageCentroid.raDecCovariance;
    transformationCadenceIndices = ...
        controlImageCentroid.transformationCadenceIndices;
    skyControlCentroidStatus = 0;
else
    skyControlCentroidRaHours = 0;
    skyControlCentroidDecDegrees = 0;
    skyControlCentroidCovariance = zeros([2, 2]);
    transformationCadenceIndices = [];
    skyControlCentroidStatus = 1;
end % if / else

[skyCorrelationCentroidRaHours, skyCorrelationCentroidDecDegrees, ...
    skyCorrelationCentroidStatus, skyCorrelationCentroidCovariance, ...
    pixelCorrelationResults.correlationImageCentroid] = ...
    transform_centroid_from_fpa_to_sky_coordinates( ...
    fpaCorrelationCentroidRow, fpaCorrelationCentroidColumn, ...
    fpaCorrelationCentroidStatus, fpaCorrelationCentroidCovariance, ...
    transformationCadenceIndices, motionPolyStruct, fcConstants, ...
    pixelCorrelationResults.correlationImageCentroid);

% Compute the centroid offsets and propagate the associated uncertainties
% if both centroids were successfully computed.
if ~fpaControlCentroidStatus && ~fpaCorrelationCentroidStatus
    
    [pixelCorrelationResults.controlCentroidOffsets] = ...
        compute_fpa_offsets_and_uncertainties(fpaControlCentroidRow, ...
        fpaControlCentroidColumn, fpaControlCentroidCovariance, ...
        fpaCorrelationCentroidRow, fpaCorrelationCentroidColumn, ...
        fpaCorrelationCentroidCovariance, ...
        pixelCorrelationResults.controlCentroidOffsets);
    
end % if

if ~skyControlCentroidStatus && ~skyCorrelationCentroidStatus
    
    [pixelCorrelationResults.controlCentroidOffsets] = ...
        compute_sky_offsets_and_uncertainties(skyControlCentroidRaHours, ...
        skyControlCentroidDecDegrees, skyControlCentroidCovariance, ...
        skyCorrelationCentroidRaHours, skyCorrelationCentroidDecDegrees, ...
        skyCorrelationCentroidCovariance, ...
        pixelCorrelationResults.controlCentroidOffsets);
    
end % if

% Compute the centroid offsets with respect to the KIC reference centroid
% and propagate the associated uncertainties if both centroids were
% successfully computed.
[pixelCorrelationResults.kicReferenceCentroid] = ...
    copy_centroid_fields(differenceImageResults.kicReferenceCentroid, ...
    pixelCorrelationResults.kicReferenceCentroid);

referenceCentroidStatus = ...
    pixelCorrelationResults.kicReferenceCentroid.row.uncertainty == GAP_VALUE || ...
    pixelCorrelationResults.kicReferenceCentroid.column.uncertainty == GAP_VALUE;

if ~referenceCentroidStatus && ~fpaCorrelationCentroidStatus
    
    referenceRow = ...
        pixelCorrelationResults.kicReferenceCentroid.row.value;
    referenceColumn = ...
        pixelCorrelationResults.kicReferenceCentroid.column.value;
    referenceCovariance = ...
        pixelCorrelationResults.kicReferenceCentroid.rowColumnCovariance;

    [pixelCorrelationResults.kicCentroidOffsets] = ...
        compute_fpa_offsets_and_uncertainties(referenceRow, ...
        referenceColumn, referenceCovariance, ...
        fpaCorrelationCentroidRow, fpaCorrelationCentroidColumn, ...
        fpaCorrelationCentroidCovariance, ...
        pixelCorrelationResults.kicCentroidOffsets);
    
end % if

referenceCentroidStatus = ...
    pixelCorrelationResults.kicReferenceCentroid.raHours.uncertainty == GAP_VALUE || ...
    pixelCorrelationResults.kicReferenceCentroid.decDegrees.uncertainty == GAP_VALUE;

if ~referenceCentroidStatus && ~skyCorrelationCentroidStatus
    
    referenceRaHours = ...
        pixelCorrelationResults.kicReferenceCentroid.raHours.value;
    referenceDecDegrees = ...
        pixelCorrelationResults.kicReferenceCentroid.decDegrees.value;
    referenceCovariance = ...
        pixelCorrelationResults.kicReferenceCentroid.raDecCovariance;

    [pixelCorrelationResults.kicCentroidOffsets] = ...
        compute_sky_offsets_and_uncertainties(referenceRaHours, ...
        referenceDecDegrees, referenceCovariance, ...
        skyCorrelationCentroidRaHours, skyCorrelationCentroidDecDegrees, ...
        skyCorrelationCentroidCovariance, ...
        pixelCorrelationResults.kicCentroidOffsets);
    
end % if

% Return.
return


function [updatedCentroid] = copy_centroid_fields(centroid1, centroid2)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [updatedCentroid] = copy_centroid_fields(centroid1, centroid2)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Copy centroid fields from centroid1 to centroid2.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

updatedCentroid = centroid2;

updatedCentroid.row.value = centroid1.row.value;
updatedCentroid.row.uncertainty = centroid1.row.uncertainty;
updatedCentroid.column.value = centroid1.column.value;
updatedCentroid.column.uncertainty = centroid1.column.uncertainty;
updatedCentroid.rowColumnCovariance = centroid1.rowColumnCovariance;

updatedCentroid.raHours.value = centroid1.raHours.value;
updatedCentroid.raHours.uncertainty = centroid1.raHours.uncertainty;
updatedCentroid.decDegrees.value = centroid1.decDegrees.value;
updatedCentroid.decDegrees.uncertainty = centroid1.decDegrees.uncertainty;
updatedCentroid.raDecCovariance = centroid1.raDecCovariance;

updatedCentroid.transformationCadenceIndices = ...
    centroid1.transformationCadenceIndices;

return
