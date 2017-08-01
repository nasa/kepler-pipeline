function [centroidRaHours, centroidDecDegrees, skyCentroidStatus, ...
skyCentroidCovariance, imageCentroid] = ...
transform_centroid_from_fpa_to_sky_coordinates(centroidRow, centroidColumn, ...
fpaCentroidStatus, fpaCentroidCovariance, transformationCadenceIndices, ...
motionPolyStruct, fcConstants, imageCentroid)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [centroidRaHours, centroidDecDegrees, skyCentroidStatus, ...
% skyCentroidCovariance, imageCentroid] = ...
% transform_centroid_from_fpa_to_sky_coordinates(centroidRow, centroidColumn, ...
% fpaCentroidStatus, fpaCentroidCovariance, transformationCadenceIndices, ...
% motionPolyStruct, fcConstants, imageCentroid)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Transform the given centroid and associated centroid covariance from
% focal plane (row, column) to sky (ra, dec) coordinates by inverting the
% motion polynomials at the specified transformation cadence indices. Save
% the results if the transformation is successful.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Set constants.
HOURS_PER_DEGREE = 24 / 360;
T_RA_HOURS_DEC_DEGREES = [HOURS_PER_DEGREE, 0; 0, 1];

% The FPA centroid must be good and there must be valid in-transit cadences
% in the given target table to perform the transformation.
if ~fpaCentroidStatus && ~isempty(transformationCadenceIndices)
    
    % Define a struct array for temporary storage of the converted sky
    % coordinates on each cadence for transformation.
    nTransformationCadences = length(transformationCadenceIndices);
    
    skyCentroidStruct = repmat(struct( ...
        'cadence', 0, ...
        'raHours', 0, ...
        'decDegrees', 0, ...
        'covariance', zeros([2, 2])), [1, nTransformationCadences]);

    % Use the motion polynomials to perform the transformation from focal
    % plane to sky coordinates on each valid in-transit cadences. Convert
    % the right ascension from degrees to hours, and update the covariance
    % matrix for the transformed sky coordinates accordingly.
    for iCadence = 1 : nTransformationCadences

        index = transformationCadenceIndices(iCadence);
        motionPoly = motionPolyStruct(index);
        
        [raDegrees, decDegrees, Crd] = ...
            invert_motion_polynomial(centroidRow, centroidColumn, ...
            motionPoly, fpaCentroidCovariance, fcConstants);

        skyCentroidStruct(iCadence).cadence = index;
        skyCentroidStruct(iCadence).raHours = HOURS_PER_DEGREE * raDegrees;
        skyCentroidStruct(iCadence).decDegrees = decDegrees;
        skyCentroidStruct(iCadence).covariance = ...
            T_RA_HOURS_DEC_DEGREES * Crd * T_RA_HOURS_DEC_DEGREES';

    end % for iCadence

    % Compute the mean sky coordinate position. Also compute the mean
    % covariance [sum(Cn)/N] rather than propagated covariance [sum(Cn)/N^2]
    % which reflects more than just a transformation to sky coordinates and
    % underestimates the true uncertainties in the transformed sky
    % coordinates.
    centroidRaHours = mean([skyCentroidStruct.raHours]);
    centroidDecDegrees = mean([skyCentroidStruct.decDegrees]);
    skyCentroidCovariance = mean(cat(3, skyCentroidStruct.covariance), 3);
    skyCentroidStatus = 0;

else
    
    % Set defaults and failure status if the centroid cannot be
    % transformed.
    centroidRaHours = 0;
    centroidDecDegrees = 0;
    skyCentroidCovariance = zeros([2, 2]);
    skyCentroidStatus = 1;
    
end % if / else

% Save the results if the transformation was successful.
if ~skyCentroidStatus
    imageCentroid.raHours.value = centroidRaHours;
    imageCentroid.decDegrees.value = centroidDecDegrees;
    imageCentroid.raHours.uncertainty = sqrt(skyCentroidCovariance(1, 1));
    imageCentroid.decDegrees.uncertainty = sqrt(skyCentroidCovariance(2, 2));
    imageCentroid.raDecCovariance = skyCentroidCovariance;
    imageCentroid.transformationCadenceIndices = transformationCadenceIndices;
end % if

% Return.
return
