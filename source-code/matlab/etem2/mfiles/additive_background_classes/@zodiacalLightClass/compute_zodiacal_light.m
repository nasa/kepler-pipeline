function zodiacalLightObject = compute_zodiacal_light(zodiacalLightObject)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
if zodiacalLightObject.zodiFluxValue ~= 0
    disp('no zodiacal light');
    return;
end

runParamsObject = zodiacalLightObject.runParamsClass;
module = get(runParamsObject, 'moduleNumber');
output = get(runParamsObject, 'outputNumber');
numVisibleRows = get(runParamsObject, 'numVisibleRows');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
runStartTime = get(runParamsObject, 'runStartTime'); % days
runEndTime = get(runParamsObject, 'runEndTime'); % days
timeVector = get(runParamsObject, 'timeVector'); 
flux12 = get(runParamsObject, 'fluxOfMag12Star'); 
integrationTime = get(runParamsObject, 'integrationTime'); 
raDec2PixObject = get(runParamsObject, 'raDec2PixObject');
centerTimeIndex = get(raDec2PixObject, 'centerTimeIndex');
socRaDec2PixObject = get(raDec2PixObject, 'raDec2PixObject');
pixelAngle = get(runParamsObject, 'pixelAngle');

meshOrder = zodiacalLightObject.meshOrder;
nMeshRows = zodiacalLightObject.nMeshRows;
nMeshCols = zodiacalLightObject.nMeshCols;

zodiTimeMjd = timeVector(centerTimeIndex);
zodiTimeJulian = mjd_to_julian_day(zodiTimeMjd);

% compute zodiacal light image by computing zodi signal on a coarse mesh
% then interpolating all pixels
% co-opt the dva mesh since we are building the same kind of polynomial
% first construct grid on which to compute zodi signal. 
% nMeshRows and nMeshCols points equally
% spaced across a CCD as defined in the moduleDataStruct.
[zodiMeshCol, zodiMeshRow] = meshgrid(...
    linspace(1, numVisibleCols, nMeshCols), ...
    linspace(1, numVisibleRows, nMeshRows));
% find the initial unaberrated RA and dec of the dva mesh points
zodiRA = zeros(size(zodiMeshRow));
zodiDec = zeros(size(zodiMeshRow));
for meshRow = 1:nMeshRows
    for meshCol = 1:nMeshCols
        [zodiRA(meshRow, meshCol), zodiDec(meshRow, meshCol)] ...
            = pix_to_ra_dec(raDec2PixObject, module, output, ...
            zodiMeshRow(meshRow, meshCol) + numMaskedSmear, ...
            zodiMeshCol(meshRow, meshCol) + numLeadingBlack, zodiTimeMjd, 1);
    end
end
% check for nan and inf
if any(any(~isfinite(zodiRA)))
    error('ETEM2:compute_zodiacal_light:zodiRA:not_finite',...
        'zodiRA contains NAN or INF after pix_to_ra_dec.');
end
if any(any(~isfinite(zodiDec)))
    error('ETEM2:compute_zodiacal_light:zodiDec:not_finite',...
        'zodiDec contains NAN or INF after pix_to_ra_dec.');
end
% now compute the zodi signal at the mesh points
zodiMeshValues = zeros(nMeshRows, nMeshCols);
for meshRow = 1:nMeshRows
    for meshCol = 1:nMeshCols
        % compute the aberrated RA and dec of each dva mesh point at each
        % sample
        zodiMeshValues(meshRow, meshCol) = Zodi_Model( ...
            zodiRA(meshRow, meshCol), zodiDec(meshRow, meshCol), ...
            zodiTimeJulian, socRaDec2PixObject, pixelAngle);
    end
end
% now create 2D polynomial for the zodi and evaluate it for all pixels
[ccdPixCols ccdPixRows] = meshgrid(1:numVisibleCols, 1:numVisibleRows);
zodiPoly = weighted_polyfit2d( ...
    zodiMeshRow(:)/numVisibleRows, zodiMeshCol(:)/numVisibleCols, ...
    zodiMeshValues(:), 1, meshOrder, 'standard');
check_poly2d_struct(zodiPoly, ...
    'TAD:extract_optimal_apertures:zodiPoly:');
zodiValues = reshape(weighted_polyval2d(ccdPixRows(:)/numVisibleRows, ...
    ccdPixCols(:)/numVisibleCols, zodiPoly), numVisibleRows, numVisibleCols);

% return answer in e-/second
zodiacalLightObject.zodiFluxValue = flux12 * mag2b(zodiValues) / mag2b(12); % zodi is in e-/sec

