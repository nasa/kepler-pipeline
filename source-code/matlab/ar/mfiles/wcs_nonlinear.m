function [sipWcs ra dec colPoints rowPoints rMatrix rInvMatrix pVar colOffset qVar rowOffset] = wcs_nonlinear(inputsStruct)
% [sipWcs ra dec colPoints rowPoints rMatrix rInvMatrix pVar colOffset qVar rowOffset] = ffi_wcs_nonlinear(inputsStruct)
%
% Pipeline module to determine the nonlinear WCS coefficients for an FFI.
%
% INPUTS:
%     inputsStruct.
%         fcConstants            An FcConstants structure.
%         motionPolyBlobs        The motion poly blobs for this FFI.
%         debugFlag              A boolean to indicate debug status.
%         sipWcsInputs           struct
%             referenceLongCadence   int. The long cadence to use a a reference for this calculation.
%             colStep                double. The column step size in pixels of the grid to calculate the WCS transform on.
%             rowStep                double. The row step size in pixels of the grid to calculate the WCS transform on.
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

%         
% OUTPUTS:
%     sipWcs -- A struct with the following fields:
%         referenceCcdRow -- The reference row used in this calculation.
%         referenceCcdColumn -- The reference column used in this calculation.
%         ra  -- The right ascension of the reference pixel.
%         dec -- The declination of the reference pixel.
%         rotationAndScale -- An 2-element array of structs with field "array".
%
%         forwardPolynomial -- A struct with the following fields:
%             a -- A struct with the following fields:
%                 order -- The order of this polynomial
%                 polynomial -- An array of structs with fields:
%                     keyword -- The keyword for this value of the polynomial
%                     value -- The value for this value of the polynomial
%             b -- A struct with the following fields:
%                 order -- The order of this polynomial
%                 polynomial -- An array of structs with fields:
%                     keyword -- The keyword for this value of the polynomial
%                     value -- The value for this value of the polynomial
%         inversePolynomial -- A struct with the following fields:
%             a -- A struct with the following fields:
%                 order -- The order of this polynomial
%                 polynomial -- An array of structs with fields:
%                     keyword -- The keyword for this value of the polynomial
%                     value -- The value for this value of the polynomial
%             b -- A struct with the following fields:
%                 order -- The order of this polynomial
%                 polynomial -- An array of structs with fields:
%                     keyword -- The keyword for this value of the polynomial
%                     value -- The value for this value of the polynomial

sipWcsInputs = inputsStruct.sipWcsInputs;


sipWcs.referenceCcdRow = 0;
sipWcs.referenceCcdColumn = 0;
sipWcs.ra = 0;
sipWcs.dec = 0;
sipWcs.rotationAndScale = zeros(0);
sipWcs.forwardPolynomial.a.polynomial = zeros(0);
sipWcs.forwardPolynomial.a.order = -1;
sipWcs.forwardPolynomial.b = sipWcs.forwardPolynomial.a;
sipWcs.inversePolynomial = sipWcs.forwardPolynomial;
sipWcs.maxDistortionA = 0;
sipWcs.maxDistortionB = 0;
% here I'm making some of these variables which should be structures
% scalar values.  I just want to define them and exit out of this
% function since it is supposed to do nothing.
ra = 0;
dec = 0;
colPoints = 0;
rowPoints = 0;
rMatrix = 0;
rInvMatrix = 0;
pVar = 0;
colOffset =0;
qVar = 0;
rowOffset = 0;

if ~inputsStruct.sipWcsInputs.perform
    return
end

% Sanity check on input data:
%
fieldsAndBounds = cell(1, 4);
fieldsAndBounds(1,:) = {'rowStep'; '> 0'; '<= 1200'; []};
fieldsAndBounds(2,:) = {'colStep'; '> 0'; '<= 1200'; []};
validate_structure(sipWcsInputs, fieldsAndBounds, 'ar:wcs_nonlinear');

motionPoly = get_closest_motion_poly(inputsStruct.motionPolyBlobs, sipWcsInputs.referenceLongCadence, inputsStruct.debugFlag);

if isempty(motionPoly)
    return
end

[colPoints rowPoints colGridPoints rowGridPoints] = get_grid_points(sipWcsInputs.colStep, sipWcsInputs.rowStep, inputsStruct.fcConstants);

ra = zeros(size(colPoints));
dec = zeros(size(colPoints));

for i = 1:length(colPoints)
    [ra(i) dec(i)] = ...
        invert_motion_polynomial(rowPoints(i), colPoints(i), ...
                                 motionPoly, zeros(2,2), ...
                                 inputsStruct.fcConstants);
    if ra(i) == -1 || dec(i) == -1
        error('MATLAB:ar:wcs_nonlinear', 'Failed to invert motion polynomial.');
    end
end

% Find the central pixel of the mod/out (assumes the colGridPoints are sorted).
% This pixel will be the reference pixel used for CRPIX1 and CRPIX2 in
% the FITS header. It doesn't have to be exactly in the centre
%
colCentralIndex = floor(length(colGridPoints)/2);
rowCentralIndex = floor(length(rowGridPoints)/2);

% centIndex is the array index at the central pixel
% Used for CRPIX1, CRPIX2, CRVAL1 and CRVAL2
%
centIndex = find(colPoints == colGridPoints(colCentralIndex) & ...
                 rowPoints == rowGridPoints(rowCentralIndex));

% Set the middle of the u,v plane to be at the reference pixel
%
colOffset = colPoints - colPoints(centIndex);
rowOffset = rowPoints - rowPoints(centIndex);

% Function performs the projection from spherical geometry to plane
% projection coordinates, known as intermediate world coordinate in the
% literature:
%
[xn yn] = spherical_to_plane_projection_coords(ra, dec, centIndex);

rMatrix = get_r_value(colOffset, rowOffset, xn, yn);
[rInvMatrix pVar qVar] = get_rinv_value(colOffset, rowOffset, xn, yn, rMatrix);

sipWcs = generateKeywords(ra, dec, centIndex, colPoints, rowPoints, rMatrix, pVar, colOffset, qVar, rowOffset, rInvMatrix);
return

function [colPoints rowPoints colGridPoints rowGridPoints] = get_grid_points(colStep, rowStep, fcConstants)
    
    colGridStart = fcConstants.nLeadingBlack + 1;
    colGridEnd   = colGridStart + fcConstants.nColsImaging - 1;
    
    rowGridStart = fcConstants.nMaskedSmear + 1;
    rowGridEnd   = rowGridStart + fcConstants.nRowsImaging - 1;
    
    colGridPoints = colGridStart:colStep:colGridEnd;
    rowGridPoints = rowGridStart:rowStep:rowGridEnd;
    
    [colPointsMesh rowPointsMesh] = meshgrid(colGridStart:colStep:colGridEnd, rowGridStart:rowStep:rowGridEnd);
    
    % This sorting duplicates Tom Barclay's original vectors; this is done in
    % order to allow direct comparison of his outputs and mine, which makes
    % testing easier:
    %
    tmpOutput = sortrows([rowPointsMesh(:) colPointsMesh(:)]);
    colPoints = tmpOutput(:,2);
    rowPoints = tmpOutput(:,1);
return

function rMatrix = get_r_value(colOffset, rowOffset, xn, yn)
    %guess the intial values of the fit between colOffset,rowOffset and xn,yn
    findcolOffsetEqualsZero = find(colOffset == 0);
    findrowOffsetEqualsZero = find(rowOffset == 0);
    
    yscale =  (yn(max(findcolOffsetEqualsZero)) - yn(min(findcolOffsetEqualsZero))) / (rowOffset(max(findcolOffsetEqualsZero))-rowOffset(min(findcolOffsetEqualsZero)));
    xscale =  (xn(max(findrowOffsetEqualsZero)) - xn(min(findrowOffsetEqualsZero))) / (colOffset(max(findrowOffsetEqualsZero))-colOffset(min(findrowOffsetEqualsZero)));
    
    %the array with the inital guess
    initialGuess = zeros(1,18);
    initialGuess(1) = xscale;
    initialGuess(4) = yscale;

    %put the values into a single array which is read by the fitting function
    fminsearchParams = [colOffset rowOffset xn yn];
    %define option for the fit
    options = optimset('MaxIter', 50000., 'TolX', 1e-7', 'MaxFunEvals', 50000000., 'TolFun', 1e-7);
    %perform the fit
    rMatrix = fminsearch(@(finp) fitting_function(finp, fminsearchParams), initialGuess, options);
    rMatrix(8:11) = 0.0;
    rMatrix(15:18) = 0.0;
return

function [rInvMatrix pMatrix qMatrix] = get_rinv_value(colOffset, rowOffset, xn, yn, rMatrix)

    %this is the CD matrix used the in fits headers
    cdMatrix = [rMatrix(1) rMatrix(2);rMatrix(3) rMatrix(4)];

    %we now need to perform the inverse fit so we can go back to u,v from x,y
    %calculate the inverse cd matrix
    invcd = inv(cdMatrix);

    %calculate the linear term to map xn,yn to colOffset,rowOffset
    pMatrix = invcd(1,1).*xn + invcd(1,2).*yn;
    qMatrix = invcd(2,1).*xn + invcd(2,2).*yn;

    dMatrix = -rMatrix;
    dMatrix(1:4) = 0.0;
    t = [colOffset rowOffset xn yn pMatrix qMatrix];
    options = optimset('TolX',1e-4','TolFun',1e-4);
    %the inverse fit
    rInvMatrix = fminsearch(@(finp) inverse_fitting_function(finp,t), dMatrix, options);
    rInvMatrix(8:11) = 0.0;
    rInvMatrix(15:18) = 0.0;
return


function motionPolyToUse = get_closest_motion_poly(motionPolyBlobs, referenceLongCadence, isDebug)
    motionPolyToUse = [];
    if isDebug
        motionPolyStruct = inputsStruct.motionPolysDebug;
    else
        motionPolyStruct = poly_blob_series_to_struct(motionPolyBlobs);
    end
    if ~isfield(motionPolyStruct, 'cadence')
        fprintf('MATLAB:arffi:ffi_wcs_nonlinear The motion polynomials do not contain cadence information. This probably indicates there are no motion polys for this mod/out/timerange.');
        return
    end
    index = find([motionPolyStruct.cadence] == referenceLongCadence);
    if isempty(index)
        error('MATLAB:arffi:ffi_wcs_nonlinear', 'Cadence %d is not an entry in the motionPolyStruct inputs.', referenceLongCadence);
    end
    motionPolyToUse = motionPolyStruct(index);
return

function sumsq = fitting_function(coefficientsC, uvxypq)
    ac = coefficientsC(5:11);
    bc = coefficientsC(12:18);
    
    val1 = evaluate_higher_order_coeffs(uvxypq(:,1), uvxypq(:,2),ac);
    val2 = evaluate_higher_order_coeffs(uvxypq(:,1), uvxypq(:,2),bc);

    pvar = uvxypq(:,1) + val1;
    qvar = uvxypq(:,2) + val2;

    xresid = uvxypq(:,3) - coefficientsC(1) .* pvar - coefficientsC(2) .* qvar;
    yresid = uvxypq(:,4) - coefficientsC(3) .* pvar - coefficientsC(4) .* qvar;
    
    sumsq = sum((xresid .* xresid) + (yresid .* yresid));
return

function sumsq = inverse_fitting_function(coefficientsD, uvxypq)
    apc = coefficientsD(5:11);
    bpc = coefficientsD(12:18);
    uresid = uvxypq(:,1) - uvxypq(:,5)- coefficientsD(1) .* uvxypq(:,5) - coefficientsD(2) .* uvxypq(:,6) - evaluate_higher_order_coeffs(uvxypq(:,5), uvxypq(:,6), apc);
    vresid = uvxypq(:,2) - uvxypq(:,6)- coefficientsD(3) .* uvxypq(:,5) - coefficientsD(4) .* uvxypq(:,6) - evaluate_higher_order_coeffs(uvxypq(:,5), uvxypq(:,6), bpc);
    sumsq = sum(uresid.*uresid + vresid.*vresid);
return

function val = evaluate_higher_order_coeffs(x, y, coeff)
% This function evaluates the higher order coefficients, currently only evaluates a second order 2D polynomial
%
    val = (coeff(1) .* x .* x) + (coeff(2) .* y .* y) + (coeff(3) .* x .*y);
return

function [iDeg jDeg] = spherical_to_plane_projection_coords(raDeg, decDeg, centIndex)
% Inputs: the ra and dec in degrees and the array index which specifies the reference pixel 
% Outputs: the projection plan coordinates used for fitting
%
    [phiRad thetaRad] = ra_dec_to_relative_sky_coords(raDeg, decDeg, centIndex);
    [iDeg jDeg] = relative_sky_coords_to_tangent_plane_coords(thetaRad, phiRad);
return

function [phiRad thetaRad] = ra_dec_to_relative_sky_coords(raDeg, decDeg, centIndex)
% This function converts from ra dec coords in degrees to relative sky coordinates.
% The calculation performs a rotation in spherical coordinates using Euler 
% angles. The equations are taken from Section 2.3 of Calabretta and 
% Greisen 2002, equation 5
%
    alphaRad = deg2rad(raDeg);
    deltaRad = deg2rad(decDeg);

    lonpole = 180.; %if CRVAL1 == 90, lonpole = 0 -> not an issue for Kepler
    phiPoleRad = deg2rad(lonpole);

    alpha0 = alphaRad(centIndex);
    delta0 = deltaRad(centIndex);

    sinD = sin(deltaRad);
    cosD = cos(deltaRad);
    sinD0 = sin(delta0);
    cosD0 = cos(delta0);
    sinADiff = sin(alphaRad - alpha0);
    cosADiff = cos(alphaRad - alpha0);

    aValue = sinD.*cosD0 - cosD.*sinD0.*cosADiff;
    bValue = -cosD.*sinADiff;

    phiRad = phiPoleRad +atan2(bValue, aValue);
    thetaRad = asin(sinD.*sinD0 + cosD.*cosD0.*cosADiff);
return

function [iDeg jDeg] = relative_sky_coords_to_tangent_plane_coords(thetaRad, phiRad)
% Converts from tangent plane spherical coordinates to tangent plane cartesian coordinates.
% The equations are taken from Equs. 12, 13 and 54 of Calabretta and Greisen 2002
% The i and j used here as called x and y in the paper but I found this
% confusing when talking about this and CCD physical coords.

    Rtheta = rad2deg(1./tan(thetaRad));

    iDeg = Rtheta .* sin(phiRad);
    jDeg = -Rtheta .* cos(phiRad);
return

function sipWcs = generateKeywords(ra, dec, centIndex, colPoints, rowPoints, rMatrix, pVar, colOffset, qVar, rowOffset, rInvMatrix)
% Generate the FITS keywords
%

    sipWcs.ra = ra(centIndex); %sipWcs.CRVAL1 = ra(centIndex);
    sipWcs.dec = dec(centIndex); %sipWcs.CRVAL2 = dec(centIndex);
    sipWcs.referenceCcdColumn = colPoints(centIndex); %sipWcs.CRPIX1 = colPoints(centIndex);
    sipWcs.referenceCcdRow = rowPoints(centIndex); %sipWcs.CRPIX2 = rowPoints(centIndex);
    sipWcs.maxDistortionA = max(pVar-colOffset);
    sipWcs.maxDistortionB = max(qVar-rowOffset);

    
    %sipWcs.rotationAndScale = [rMatrix(1) rMatrix(2); rMatrix(3) rMatrix(4)]; 
    sipWcs.rotationAndScale(1).array(1) = rMatrix(1);
    sipWcs.rotationAndScale(1).array(2) = rMatrix(2); 
    sipWcs.rotationAndScale(2).array(1) = rMatrix(3);
    sipWcs.rotationAndScale(2).array(2) = rMatrix(4); 

    sipWcs.forwardPolynomial.a.order = 2;
    sipWcs.forwardPolynomial.b.order = 2;
    
    sipWcs.forwardPolynomial.a.polynomial(1) = kv_struct('2_0', rMatrix(5));
    sipWcs.forwardPolynomial.a.polynomial(2) = kv_struct('0_2', rMatrix(6));
    sipWcs.forwardPolynomial.a.polynomial(3) = kv_struct('1_1', rMatrix(7));

    sipWcs.forwardPolynomial.b.polynomial(1) = kv_struct('2_0', rMatrix(12));
    sipWcs.forwardPolynomial.b.polynomial(2) = kv_struct('0_2', rMatrix(13));
    sipWcs.forwardPolynomial.b.polynomial(3) = kv_struct('1_1', rMatrix(14));

    sipWcs.inversePolynomial.a.order = 2;
    sipWcs.inversePolynomial.b.order = 2;

    sipWcs.inversePolynomial.a.polynomial(1) = kv_struct('1_0', rInvMatrix(1));
    sipWcs.inversePolynomial.a.polynomial(2) = kv_struct('0_1', rInvMatrix(2));
    sipWcs.inversePolynomial.a.polynomial(3) = kv_struct('2_0', rInvMatrix(5));
    sipWcs.inversePolynomial.a.polynomial(4) = kv_struct('0_2', rInvMatrix(6));
    sipWcs.inversePolynomial.a.polynomial(5) = kv_struct('1_1', rInvMatrix(7));

    sipWcs.inversePolynomial.b.polynomial(1) = kv_struct('1_0', rInvMatrix(3));
    sipWcs.inversePolynomial.b.polynomial(2) = kv_struct('0_1', rInvMatrix(4));
    sipWcs.inversePolynomial.b.polynomial(3) = kv_struct('2_0', rInvMatrix(12));
    sipWcs.inversePolynomial.b.polynomial(4) = kv_struct('0_2', rInvMatrix(13));
    sipWcs.inversePolynomial.b.polynomial(5) = kv_struct('1_1', rInvMatrix(14));
return

function keywordValueStruct = kv_struct(keyword, value)
    keywordValueStruct = struct('keyword', keyword, 'value', value);
return
