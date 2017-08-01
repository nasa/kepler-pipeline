function [centroidRow, centroidColumn, centroidStatus, centroidCovariance, ...
imageCentroid, qualityMetric] = compute_dv_prf_centroid(pixelRows, pixelColumns, ...
pixelValues, pixelUncertainties, prfObject, targetTableTimestamp, ...
fcConstants, imageCentroid, qualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [centroidRow, centroidColumn, centroidStatus, centroidCovariance, ...
% imageCentroid, qualityMetric] = compute_dv_prf_centroid(pixelRows, pixelColumns, ...
% pixelValues, pixelUncertainties, prfObject, targetTableTimestamp, ...
% fcConstants, imageCentroid, qualityMetric)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the PRF-based centroid of the given pixel image using the
% specified PRF collection class object. Update the imageCentroid with the
% results if the PRF-based centroid is valid. Compute and update the
% qualityMetric if one is optionally specified and the PRF-based centroid
% is valid.
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
CENTROID_TOLERANCE = 1e-10;

% Set up the data structure required by compute_starDataStruct_centroid for
% the pixel image.
pixelValues = pixelValues( : );
pixelUncertainties = pixelUncertainties( : );
pixelRows = pixelRows( : );
pixelColumns = pixelColumns( : );

starDataStruct.values = pixelValues;
starDataStruct.uncertainties = pixelUncertainties;

gapIndicators = pixelUncertainties == GAP_VALUE;
starDataStruct.values(gapIndicators) = 0;
starDataStruct.uncertainties(gapIndicators) = 0;
starDataStruct.gapIndicators = gapIndicators;

starDataStruct.row = pixelRows;
starDataStruct.column = pixelColumns;
starDataStruct.seedRow = [];
starDataStruct.seedColumn = [];

inPrfCentroidAperture = true(size(starDataStruct.row));
[inPrfCentroidAperture] = ...
    trim_non_photometric_pixels_from_aperture( ...
    starDataStruct.row, starDataStruct.column, ...
    inPrfCentroidAperture, fcConstants);
starDataStruct.inOptimalAperture = inPrfCentroidAperture;

% Define the PRF aperture bounding box for validation of row/column
% centroid coordinates.
minPrfApertureRow = min(starDataStruct.row(inPrfCentroidAperture));
maxPrfApertureRow = max(starDataStruct.row(inPrfCentroidAperture));
minPrfApertureColumn = min(starDataStruct.column(inPrfCentroidAperture));
maxPrfApertureColumn = max(starDataStruct.column(inPrfCentroidAperture));
    
% Compute the centroid of the image for the given target table. Set
% defaults and failure status if there are no valid pixels in the centroid
% aperture.
isValid = inPrfCentroidAperture & ~gapIndicators;
if any(isValid)
    [centroidRow, centroidColumn, centroidStatus, centroidCovariance] = ...
        compute_starDataStruct_centroid(starDataStruct, prfObject, ...
        targetTableTimestamp, 'best');
    centroidCovariance = squeeze(centroidCovariance);
else
    centroidRow = 0;
    centroidColumn = 0;
    centroidCovariance = zeros([2, 2]);
    centroidStatus = 1;
end % if / else

% Check that PRF-based centroid for the image is valid. It can't be valid
% if it does not fall within the bounding box for the centroiding aperture.
if centroidStatus == 0 && ...
        (centroidRow + CENTROID_TOLERANCE < minPrfApertureRow || ...
        centroidRow - CENTROID_TOLERANCE > maxPrfApertureRow || ...
        centroidColumn + CENTROID_TOLERANCE < minPrfApertureColumn || ...
        centroidColumn - CENTROID_TOLERANCE > maxPrfApertureColumn)
    centroidRow = 0;
    centroidColumn = 0;
    centroidCovariance = zeros([2, 2]);
    centroidStatus = 1;
end % if

% Save the control image centroid and associated uncertainties if it is
% valid.
if centroidStatus == 0
    imageCentroid.row.value = centroidRow;
    imageCentroid.column.value = centroidColumn;
    imageCentroid.row.uncertainty = sqrt(centroidCovariance(1, 1));
    imageCentroid.column.uncertainty = sqrt(centroidCovariance(2, 2));
    imageCentroid.rowColumnCovariance = centroidCovariance;
end % if

% Compute and update the correlation quality metric if one is desired
% and the PRF-based centroid is valid. Also note whether there was a
% credible attempt to compute the PRF-based centroid and hence the metric.
if exist('qualityMetric', 'var')
    
    if any(isValid)
        
        qualityMetric.attempted = true;
        
        if centroidStatus == 0
            
            pixelRows = pixelRows(isValid);
            pixelColumns = pixelColumns(isValid);
            pixelValues = pixelValues(isValid);

            prfData = evaluate(prfObject, centroidRow, centroidColumn, ...
                pixelRows, pixelColumns);
            amplitude = (prfData' * pixelValues) / (prfData' * prfData);
            prfData = abs(amplitude) * prfData;

            qualityMetric.value = corr(prfData, pixelValues);
            qualityMetric.valid = true;
        
        end % if
    
    end % if
    
end % if

% Return.
return
