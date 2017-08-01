function [polyStruct, cadenceTimes] = ...
interpolate_polynomials(polyStruct, polyGapIndicators, cadenceTimes, ...
polyTimestamps)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [polyStruct, cadenceTimes] = ...
% interpolate_polynomials(polyStruct, polyGapIndicators, cadenceTimes, ...
% polyTimestamps)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Interpolate polynomial coefficients and their associated covariances of
% the type returned by robust_polyfit2d (e.g. PA background coefficients
% and motion polynomials). In the long cadence case, linearly interpolate
% to fill any gaps in the polynomial structure. In the short cadence case,
% use all valid long cadence polynomials to linearly interpolate at every
% short cadence time. Do reasonable consistency checking in both cases to
% ensure that the interpolated polynomials are valid. The polyTimestamps
% are specified only in the short cadence case.
%
% The timestamps for any gapped cadences are estimated. Return complete
% (interpolated) polynomial structure arrays and complete vectors of
% cadence timestamps.
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


% Assume that we are just filling coefficient gaps if no polynomial
% timestamps are provided.
if ~exist('polyTimestamps', 'var')
    processLongCadence = true;
    processShortCadence = false;
else
    processLongCadence = false;
    processShortCadence = true;
end

% Check that there are at least two valid coefficient structures.
if sum(~polyGapIndicators) < 2
    error('PA:interpolatePolynomials:insufficientPolynomialData', ...
        'There is insufficient polynomial data to perform interpolation')
end

% Get the valid polynomials and covariances.
validPolyStruct = polyStruct(~polyGapIndicators);
validPolys = [validPolyStruct.coeffs];
validCovariances = cat(3, validPolyStruct.covariance);

% Estimate any missing cadence timestamps.
[cadenceTimes] = estimate_timestamps(cadenceTimes);

% Get mid timestamps and number of cadences.
midTimestamps = cadenceTimes.midTimestamps;
nCadences = length(midTimestamps);

% Interpolate the polynomials as specified.
if processLongCadence

    % Perform linear interpolation to estimate missing long cadence
    % polynomials. Update the associated covariances as well.
    validTimestamps = midTimestamps(~polyGapIndicators);
    desiredTimestamps = midTimestamps(polyGapIndicators);
    
    [interpolatedPolys, interpolatedCovariances, lowIndices] = ...
        linear_interp_poly(validTimestamps, validPolys, validCovariances, ...
        desiredTimestamps);
    
    % Do some consistency checking. Interpolation is not valid if
    % definitions for low and hi polynomials are not consistent for each
    % desired timestamp. 
    lowOrder   = [validPolyStruct(lowIndices).order];
    hiOrder    = [validPolyStruct(lowIndices + 1).order];
    
    lowScalex  = [validPolyStruct(lowIndices).scalex];
    hiScalex   = [validPolyStruct(lowIndices + 1).scalex];
    
    lowOriginx = [validPolyStruct(lowIndices).originx];
    hiOriginx  = [validPolyStruct(lowIndices + 1).originx];
    
    lowOffsetx = [validPolyStruct(lowIndices).offsetx];
    hiOffsetx  = [validPolyStruct(lowIndices + 1).offsetx];
    
    lowScaley  = [validPolyStruct(lowIndices).scaley];
    hiScaley   = [validPolyStruct(lowIndices + 1).scaley];
    
    lowOriginy = [validPolyStruct(lowIndices).originy];
    hiOriginy  = [validPolyStruct(lowIndices + 1).originy];
    
    lowOffsety = [validPolyStruct(lowIndices).offsety];
    hiOffsety  = [validPolyStruct(lowIndices + 1).offsety];
    
    if ~isequal(lowOrder, hiOrder) || ~isequal(lowScalex, hiScalex) || ...
            ~isequal(lowOriginx, hiOriginx) || ~isequal(lowOffsetx, hiOffsetx) || ...
            ~isequal(lowScaley, hiScaley) || ~isequal(lowOriginy, hiOriginy) || ...
            ~isequal(lowOffsety, hiOffsety)
        error('PA:interpolatePolynomials:inconsistentPolynomialDefinitions', ...
            'Unable to perform interpolation due to inconsistent polynomial definitions')
    end
    
    % Assign the interpolated polynomials and covariances to standard
    % polynomial structures and merge with the given poly struct. Also
    % update the timestamps for the interpolated polynomials.
    polyStruct(polyGapIndicators) = validPolyStruct(lowIndices);
    
    interpolatedPolysCellArray = num2cell(interpolatedPolys, 1);
    [polyStruct(polyGapIndicators).coeffs] = interpolatedPolysCellArray{ : };
    
    interpolatedCovariancesCellArray = num2cell(interpolatedCovariances, [1, 2]);
    [polyStruct(polyGapIndicators).covariance] = interpolatedCovariancesCellArray{ : };
    
elseif processShortCadence
    
    % Do gross consistency checking first in the short cadence case. It
    % will be necessary to interpolate between all valid background
    % polynomials.
    order = [validPolyStruct.order];
    scalex = [validPolyStruct.scalex];
    originx = [validPolyStruct.originx];
    offsetx = [validPolyStruct.offsetx];
    scaley = [validPolyStruct.scaley];
    originy = [validPolyStruct.originy];
    offsety = [validPolyStruct.offsety];
    
    if any(order ~= order(1)) || any(scalex ~= scalex(1)) || ...
            any(originx ~= originx(1)) || any(offsetx ~= offsetx(1)) || ...
            any(scaley ~= scaley(1)) || any(originy ~= originy(1)) || ...
            any(offsety ~= offsety(1))
        error('PA:interpolatePolynomials:inconsistentPolynomialDefinitions', ...
            'Unable to perform interpolation due to inconsistent polynomial definitions')
    end
    
    % Perform polynomial interpolation for all short cadences.
    validTimestamps = polyTimestamps(~polyGapIndicators);
    desiredTimestamps = midTimestamps;
    
    [interpolatedPolys, interpolatedCovariances] = ...
        linear_interp_poly(validTimestamps, validPolys, validCovariances, ...
        desiredTimestamps);
    
    % Assign the interpolated polynomials and covariances to standard
    % polynomial structures. Also update the timestamps for the interpolated
    % polynomials.
    polyStruct = repmat(validPolyStruct(1), [1, nCadences]);
    
    interpolatedPolysCellArray = num2cell(interpolatedPolys, 1);
    [polyStruct(1 : nCadences).coeffs] = interpolatedPolysCellArray{ : };
    
    interpolatedCovariancesCellArray = num2cell(interpolatedCovariances, [1, 2]);
    [polyStruct(1 : nCadences).covariance] = interpolatedCovariancesCellArray{ : };
    
end % if processLongCadence / elseif processShortCadence

% Return.
return
