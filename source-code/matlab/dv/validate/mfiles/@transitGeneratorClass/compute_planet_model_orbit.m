function intermediateStruct = compute_planet_model_orbit(transitModelObject, intermediateStruct)
% function intermediateStruct = compute_planet_model_orbit(transitModelObject, intermediateStruct)
%
%
%
%
%
%
%  calls compute_kepler_orbit
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



transitExposureStartTimes = intermediateStruct.transitExposureStartTimes;
transitExposureEndTimes   = intermediateStruct.transitExposureEndTimes;
minImpactParameter = intermediateStruct.minImpactParameter;


%--------------------------------------------------------------------------
% compute the orbital positions for the exposure start and end times
%--------------------------------------------------------------------------

exposureStartPosition = compute_keplerian_orbit(transitModelObject, intermediateStruct, transitExposureStartTimes);

exposureEndPosition   = compute_keplerian_orbit(transitModelObject, intermediateStruct, transitExposureEndTimes);


% get the angle of the transit event
thetaLOS = intermediateStruct.thetaLOS;

primaryRadiusMeters    = intermediateStruct.primaryRadiusMeters;
secondaryRadiusMeters  = intermediateStruct.secondaryRadiusMeters;

% now rotate the orbit to get the desired minimum impact parameter
if intermediateStruct.minImpactParameter ~= 0

    rAtTransit = intermediateStruct.rAtTransit(1);

    % the angle we want to rotate out of the plane is phi
    phi = asin(primaryRadiusMeters*minImpactParameter/rAtTransit); % in radians

    rotZMatrix      = rotate_z(thetaLOS);
    rotYMatrix      = rotate_y(phi);
    rotationMatrix  = rotZMatrix*rotYMatrix*rotZMatrix';

    rotatedExposureStartPosition = (rotationMatrix*exposureStartPosition')';
    rotatedExposureEndPosition   = (rotationMatrix*exposureEndPosition')';

else
    rotatedExposureStartPosition = exposureStartPosition;
    rotatedExposureEndPosition   = exposureEndPosition;
end

%--------------------------------------------------------------------------
% compute impact parameters for each time, projecting onto the plane of the
% sky using the unit vector along the line of sight
%--------------------------------------------------------------------------
losVector = [cos(thetaLOS), sin(thetaLOS), 0];

% compute impact parameter for exposure start times
exposureStartImpactParam = rotatedExposureStartPosition - udotv(rotatedExposureStartPosition, losVector)*losVector;
exposureStartTransitSign = sign(udotv(rotatedExposureStartPosition, losVector));

exposureStartImpactParam(exposureStartTransitSign >= 0) = magvec(exposureStartImpactParam(exposureStartTransitSign > 0,:))/primaryRadiusMeters;
exposureStartImpactParam(exposureStartTransitSign <  0) = magvec(exposureStartImpactParam(exposureStartTransitSign < 0,:))/secondaryRadiusMeters;


% compute impact parameter for exposure end times
exposureEndImpactParam = rotatedExposureEndPosition - udotv(rotatedExposureEndPosition, losVector)*losVector;
exposureEndTransitSign = sign(udotv(rotatedExposureEndPosition, losVector));

exposureEndImpactParam(exposureEndTransitSign >= 0) = magvec(exposureEndImpactParam(exposureEndTransitSign >= 0,:))/primaryRadiusMeters;
exposureEndImpactParam(exposureEndTransitSign <  0) = magvec(exposureEndImpactParam(exposureEndTransitSign < 0,:))/secondaryRadiusMeters;




intermediateStruct.exposureStartPosition    = exposureStartPosition;
intermediateStruct.exposureEndPosition      = exposureEndPosition;
intermediateStruct.exposureStartImpactParam = exposureStartImpactParam;
intermediateStruct.exposureEndImpactParam   = exposureEndImpactParam;
intermediateStruct.exposureStartTransitSign = exposureStartTransitSign;
intermediateStruct.exposureEndTransitSign   = exposureEndTransitSign;


%==========================================================================
function rotMatrix = rotate_z(theta)

% rotate about the z-axis by the angle theta in radians
cs = cos(theta);
sn = sin(theta);
rotMatrix = [cs -sn 0
    sn cs 0
    0 0 1];

return;

function rotMatrix = rotate_y(theta)

% rotate about the z-axis by the angle theta in radians
cs = cos(theta);
sn = sin(theta);
rotMatrix = [cs 0 -sn
    0 1 0
    sn 0 cs];

return;
