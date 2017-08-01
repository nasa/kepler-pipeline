function [centroidOffsets] = ...
compute_sky_offsets_and_uncertainties(referenceRaHours, referenceDecDegrees, ...
referenceCovariance, centroidRaHours, centroidDecDegrees, centroidCovariance, ...
centroidOffsets)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [centroidOffsets] = ...
% compute_sky_offsets_and_uncertainties(referenceRaHours, referenceDecDegrees, ...
% referenceCovariance, centroidRaHours, centroidDecDegrees, centroidCovariance, ...
% centroidOffsets)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the celestial offsets between the given centroid and reference
% coordinates and propagate the associated uncertainties.
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
HOURS_PER_DEGREE = 24 / 360;
ARCSEC_PER_DEGREE = 60 * 60;
ARCSEC_PER_HOUR = ARCSEC_PER_DEGREE / HOURS_PER_DEGREE;
T_RA_ARCSEC_DEC_ARCSEC = [ARCSEC_PER_HOUR, 0; 0, ARCSEC_PER_DEGREE];

% Compute the ra, dec and focal plane offsets in units of arcseconds.
% The ra offset is computed by (ra_centroid-ra_ref)*cos(dec_ref)
% to produce a consistent angular measure with the dec offset.
cosDec = cosd(referenceDecDegrees);
sinDec = sind(referenceDecDegrees);

deltaRa = ARCSEC_PER_HOUR * (centroidRaHours - referenceRaHours);
raOffsetValue = deltaRa * cosDec;
decOffsetValue = ...
    ARCSEC_PER_DEGREE * (centroidDecDegrees - referenceDecDegrees);
skyOffsetValue = sqrt(raOffsetValue^2 + decOffsetValue^2);

% Construct the covariance matrix for the reference ra/dec and the
% centroid ra/dec.
Crc = zeros([4, 4]);
Crc(1 : 2, 1 : 2) = ...
    T_RA_ARCSEC_DEC_ARCSEC * referenceCovariance * T_RA_ARCSEC_DEC_ARCSEC';
Crc(3 : 4, 3 : 4) = ...
    T_RA_ARCSEC_DEC_ARCSEC * centroidCovariance * T_RA_ARCSEC_DEC_ARCSEC';

% Construct the Jacobians for the ra, dec and sky offsets.
Jra = [-cosDec, -deltaRa * sinDec, cosDec, 0];
Jdec = [0, -1, 0, 1];
Jsky = [-raOffsetValue * cosDec, -(raOffsetValue * deltaRa * sinDec + decOffsetValue), ...
    raOffsetValue * cosDec, decOffsetValue] ...
    / skyOffsetValue;

% Propagate the uncertainties.
raOffsetUncertainty = sqrt(Jra * Crc * Jra');
decOffsetUncertainty = sqrt(Jdec * Crc * Jdec');
skyOffsetUncertainty = sqrt(Jsky * Crc * Jsky');

% Save the offset results.
centroidOffsets.raOffset.value = raOffsetValue;
centroidOffsets.decOffset.value = decOffsetValue;
centroidOffsets.skyOffset.value = skyOffsetValue;
centroidOffsets.raOffset.uncertainty = raOffsetUncertainty;
centroidOffsets.decOffset.uncertainty = decOffsetUncertainty;
centroidOffsets.skyOffset.uncertainty = skyOffsetUncertainty;

% Return.
return
