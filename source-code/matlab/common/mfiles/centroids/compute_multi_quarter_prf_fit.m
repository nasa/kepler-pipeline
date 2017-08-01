function [centroidRa, centroidDec, centroidStatus, ...
	centroidCovariance, raJ, decJ, amplitude, diagnostics] ...
    = compute_multi_quarter_prf_fit(pixelData, prfStruct, raDec2PixData, ...
		seedRa, seedDec)
% function [centroidRa, centroidDec, centroidStatus, ...
% 	centroidCovariance, raJ, decJ, amplitude, diagnostics] ...
%     = compute_multi_quarter_prf_fit(pixelData, prfStruct, raDec2PixData, ...
% 		seedRa, seedDec)
%
% Routine that performs a joint PRF fit over multiple quarters, using as input 
% a single image per quarter, returning
% an RA and Dec position as the best fit position for all quarters.  
%
% The covariance returned by this function provides uncertainty for the
% propagated pixel-level noise and does not account for quarter-to-quarter
% position biases.  To do a multi-quarter fit that returns a covariance
% that accounts for those biases use bootstrap_multi_quarter_prf_fit.
%
% This function is used for difference image centroid analysis, where the
% single image per quarter is typically an average.
%
% inputs:
%	pixelData nQuarters x 1 structure array with the following fields set
%	for each quarter 
%		.values nPixels x 1 array containing the pixel values to be fit
%   	.ccdRow, ccdColumn nPixels x 1 array containing the row and column of each
%       	pixel in the .values field 
%		.ccdModule, .ccdOutput the module and output of the star being fit
%   	.uncertainties nPixels x nCadences array containing the pixel value
%       	uncertainties _or_ nPixels x nPixels array containing the pixel
%       	value covariance matrix 
%		.mjd the MJD time to be centroided this quarter (in the future this
%		may be extended to multiple MJDs) 
%   prfStruct nPRFs x 1 array containing the PRF data.  There must be one entry
%		for each channel present in the pixelData structure.  The fields are:
%		.prf a PRF object.  If it is a prfCollectionClass object it will be 
%			interpolated, otherwise it is used as is
%		.ccdModule, .ccdOutput the module and output on which this PRF is defined.
%   object for each quarter fit 
%	raDec2PixData a structure containing one of the following fields, only
%	one of which should be present 
%		.raDec2PixObject if present, CCD positions are computed using the
%		raDec2PixClass 
%		.motionPolynomialStruct if present, CCD positions are computed
%		using motion polynomials.  In this case the fields .fcConstants and
%		.pixelBaseCorrection (= 1 for zero-based and 0 for 1-based) are
%		required.
% 	seedRa, seedDec (optional) initial guess for the row and column position.
%		may be empty.  If these inputs are missing the sed is cmputed using
%		flux-weighted centroids 
%
% returns:
%   centroidRow, centroidColumn the row and column centroid for the each star
%   centroidStatus 1 x nCadences array indicating the status of the 
%       centroid computation: 0 = valid, 1 = invalid
%   centroidCovariance an nStars x 2 x 2 x nCadences array containing 
%       the row and column centroid covariance matrix 
%   raJ, decJ nPixels x 1 array giving
%       the Jacobian of the linearized transformation associated with the chosen
%       centroiding method 
%   amplitude the fitted amplitude of the data
%   diagnoatics structure containing various diagnostics useful for
%       understanding what happened 
%
% See also COMPUTE_PRF_CENTROID BOOTSTRAP_MULTI_QUARTER_PRF_FIT 
%
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

% control warnings
inputWarningState = warning('query', 'all');
warning('off', 'all');
lastwarn('');
centroidStatus = 0;

for i=1:length(pixelData)
	nPixels(i) = length(pixelData(i).values);
end
diagnostics.nPixels = nPixels;

if isfield(raDec2PixData, 'motionPolynomialStruct')
	% remove the gapped motion polynomials
	rowPolyStatus = [raDec2PixData.motionPolynomialStruct.rowPolyStatus];
	colPolyStatus = [raDec2PixData.motionPolynomialStruct.colPolyStatus];
	if any(rowPolyStatus == 0) || any(colPolyStatus == 0)
		raDec2PixData.motionPolynomialStruct ...
			= raDec2PixData.motionPolynomialStruct(rowPolyStatus & colPolyStatus);		
	end
end
% initialize the fit by taking the flux-weighted centroid
if nargin < 4 || (isempty(seedRa) || isempty(seedDec))
	for i=1:length(pixelData)
		[seedRow(i), seedCol(i), centroidStatus(i)] ...
	    	= compute_flux_weighted_centroid(pixelData(i).ccdRow, pixelData(i).ccdColumn, ...
				pixelData(i).values, pixelData(i).uncertainties);
		if centroidStatus(i) || ...
                seedRow(i) < min(pixelData(i).ccdRow) ...
                || seedRow(i) > max(pixelData(i).ccdRow) ...
                || seedCol(i) < min(pixelData(i).ccdColumn) ...
                || seedCol(i) > max(pixelData(i).ccdColumn) ...
                || isnan(seedRow(i)) || isnan(seedCol(i))
            seedRow(i) = mean(pixelData(i).ccdRow);
            seedCol(i) = mean(pixelData(i).ccdColumn);
        end
        [seedRa(i) seedDec(i)] = pix_to_sky(raDec2PixData, pixelData(i).ccdModule, ...
            pixelData(i).ccdOutput, seedRow(i), seedCol(i), mean(pixelData(i).mjd));
	end
	diagnostics.seedRaArray = seedRa;
	diagnostics.seedDecArray = seedDec;
	seedRa = nanmean(seedRa); 
	seedDec = nanmean(seedDec); 
else
	for i=1:length(pixelData)
		[m o seedRow(i) seedCol(i)] = sky_to_pix(raDec2PixData, seedRa, seedDec, mean(pixelData(i).mjd));	
	end
end
diagnostics.seedCentroidStatus = centroidStatus;
diagnostics.seedRow = seedRow;
diagnostics.seedCol = seedCol;
diagnostics.seedRa = seedRa;
diagnostics.seedDec = seedDec;

% normalize the pixel values to improve conditioning
for i=1:length(pixelData)
	pixelData(i).scaleNormalization = sum(pixelData(i).values);
	pixelData(i).values ...
		= pixelData(i).values/pixelData(i).scaleNormalization;
end

% options = statset('nlinfit');
options = statset('TolX', 1e-12, 'TolFun', 1e-12, 'DerivStep', 10*eps);
% options = statset('Display', 'iter', 'TolX', 1e-12, 'TolFun', 1e-12, 'DerivStep', 10*eps);
% options = statset('Display', 'final', 'TolX', 1e-12, 'TolFun', 1e-12);
% options = statset('Display', 'iter');

if nargout > 3
	userStruct.computeUncertainty = true;
else
	userStruct.computeUncertainty = false;
end

if userStruct.computeUncertainty
	for i=1:length(pixelData)
		pixelData(i).valueCovariance = zeros(nPixels(i), nPixels(i));
		if size(pixelData(i).uncertainties, 2) == 1
        	pixelData(i).valueCovariance(:,:) = diag(pixelData(i).uncertainties.^2);
		elseif size(pixelData(i).uncertainties, 2) == size(pixelData(i).uncertainties, 1)
    		pixelData(i).valueCovariance = pixelData(i).uncertainties;
		end
		% scale the covariance matrix
    	pixelData(i).valueCovariance ...
        	= pixelData(i).valueCovariance./(pixelData(i).scaleNormalization^2);
    	pixelData(i).uncertainties(:) = sqrt(diag(pixelData(i).valueCovariance(:,:)));
	end
end

for i=1:length(pixelData)
    prfIndex = find([prfStruct.ccdModule] == pixelData(i).ccdModule ...
        & [prfStruct.ccdOutput] == pixelData(i).ccdOutput);
	for j=1:length(prfIndex)
    	if isa(prfStruct(prfIndex(j)).prf, 'prfCollectionClass')
            	prfStruct(prfIndex(j)).prf = get_interpolated_prf(prfStruct(prfIndex(j)).prf, ...
                	seedRow(i), seedCol(i));
    	end
    end
end

userStruct.pixelData = pixelData;
userStruct.nPixels = nPixels;
userStruct.prfStruct = prfStruct;
userStruct.raDec2PixData = raDec2PixData;
seed = [seedRa, seedDec];

% a is an input vector with 
% a(1) = ra
% a(2) = dec

centroidStatus = 0;
try
    [centroidRa, centroidDec, amplitude, ...
        centroidCovariance, raJ, decJ, seed, diagnostics] ...
        = compute_centroid(seed, options, userStruct, diagnostics);
catch
	centroidStatus = 1;
	centroidRa = -1;
	centroidDec = -1;
	centroidCovariance = [];
	raJ = [];
	decJ = [];
	amplitude = -1;
	diagnostics = []; 
end
warning(inputWarningState);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cRa, cDec, amplitude, covariance, raJ, decJ, seed, diagnostics] ...
    = compute_centroid(seed, options, userStruct, diagnostics)

bestFit = seed;
X = [];
y = [];
for i=1:length(userStruct.pixelData)
	X = [X; [userStruct.pixelData(i).ccdRow]; [userStruct.pixelData(i).ccdColumn]];
	y = [y; [userStruct.pixelData(i).values]./[userStruct.pixelData(i).uncertainties]];
end
diagnostics.X = X;
diagnostics.y = y;

[bestFit, r, J, C] = kepler_user_nonlinearfit(X, y, ...
        @compute_star_image, bestFit, options, userStruct);
    
testPrfSet = compute_star_image(bestFit, X, userStruct);
diagnostics.testPrfSet = testPrfSet;
pixStart = 1;
for i=1:length(userStruct.nPixels)
	pixEnd = pixStart + userStruct.nPixels(i) - 1;
	pixIndx = pixStart:pixEnd;
	newAmplitude = sum(sum(testPrfSet(pixIndx).*y(pixIndx)))/sum(sum(testPrfSet(pixIndx).^2));
	amplitude(i) = newAmplitude*userStruct.pixelData(i).scaleNormalization;
	pixStart = pixEnd + 1;
end
diagnostics.amplitude = amplitude;
diagnostics.J = J;
diagnostics.bestFit = bestFit;
%         disp(['bestFit = ' num2str(bestFit)]);
cRa = bestFit(1);
cDec = bestFit(2);

seed = bestFit;

if userStruct.computeUncertainty
	valueCovariance = zeros(sum(userStruct.nPixels), sum(userStruct.nPixels));
	vStart = 1;
	for i=1:length(userStruct.pixelData)
		vEnd = vStart + userStruct.nPixels(i) - 1;
		valueCovariance(vStart:vEnd,vStart:vEnd) = userStruct.pixelData(i).valueCovariance;
		vStart = vEnd + 1;
	end

	forwardRaJacobian = J(:,1);
	forwardDecJacobian = J(:,2);
	uncertainties = sqrt(diag(valueCovariance));
	raJ = ((forwardRaJacobian'*forwardRaJacobian)\forwardRaJacobian')';
	decJ = ((forwardDecJacobian'*forwardDecJacobian)\forwardDecJacobian')';
	T = [raJ./uncertainties decJ./uncertainties]';
	diagnostics.valueCovariance = valueCovariance;
	diagnostics.T = T;
	covariance = T*valueCovariance*T';

	vStart = 1;
	for i=1:length(userStruct.pixelData)
		vEnd = vStart + userStruct.nPixels(i) - 1;
		raJ(vStart:vEnd) ...
			= raJ(vStart:vEnd)./(uncertainties(vStart:vEnd)*userStruct.pixelData(i).scaleNormalization);
		decJ(vStart:vEnd) ...
			= decJ(vStart:vEnd)./(uncertainties(vStart:vEnd)*userStruct.pixelData(i).scaleNormalization);
		vStart = vEnd + 1;
	end
else
	covariance = [];
	raJ = [];
	decJ = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prfSet = compute_star_image(a, X, userStruct)
prfSet = [];
pixStart = 1;
rowStart = 1;
colStart = userStruct.nPixels(1) + 1;
for i=1:length(userStruct.pixelData)

	pixEnd = pixStart + userStruct.nPixels(i) - 1;
	rowEnd = rowStart + userStruct.nPixels(i) - 1;
	colEnd = colStart + userStruct.nPixels(i) - 1;
	
	rowIndx = rowStart:rowEnd;
	colIndx = colStart:colEnd;
    
    prfIndex = find([userStruct.prfStruct.ccdModule] == userStruct.pixelData(i).ccdModule ...
        & [userStruct.prfStruct.ccdOutput] == userStruct.pixelData(i).ccdOutput);
	prfIndex = prfIndex(1); % in case there is a prf object for each quarter

    nTransits = length(userStruct.pixelData(i).mjd);
	prf = zeros(length(rowIndx), nTransits);
	for t=1:nTransits
		[m o row col] = sky_to_pix(userStruct.raDec2PixData, a(1), a(2), userStruct.pixelData(i).mjd(t));

		prf(:,i) = evaluate(userStruct.prfStruct(prfIndex).prf, row, col, X(rowIndx), X(colIndx));
	end
	prf = mean(prf,2);

	if isempty(prf)
		disp('compute_star_image: prf is empty');
		keyboard;
	end
    prf = prf./userStruct.pixelData(i).uncertainties;

    y = userStruct.pixelData(i).values./userStruct.pixelData(i).uncertainties;
    amplitude = sum(sum(prf.*y))/sum(sum(prf.^2));
    prf = amplitude*prf;
		
	prfSet = [prfSet; prf];

	if i < length(userStruct.pixelData)
		pixStart = pixEnd + 1;
		rowStart = rowEnd + userStruct.nPixels(i) + 1; % skip over columns from this quarter
		colStart = colEnd + userStruct.nPixels(i+1) + 1; % skip over rows from next quarter
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ra dec] = pix_to_sky(raDec2PixData, module, output, row, column, mjd)
if isfield(raDec2PixData, 'raDec2PixObject')
	[ra dec] = pix_2_ra_dec(raDec2PixData.raDec2PixObject, module, output, row, column, mjd);
elseif isfield(raDec2PixData, 'motionPolynomialStruct')
    mpStruct = raDec2PixData.motionPolynomialStruct;
    % find the nearest motion polynomial to this mjd
    mpMjds = [mpStruct.mjdMidTime];
    if mjd < min(mpMjds) || mjd > max(mpMjds)
        error('sky_to_pix: requested MJD outside of motion polynomial range');
    end
    [dm mpIndx] = min(abs(mpMjds - mjd));
    mp = mpStruct(mpIndx);

    [ra, dec] = invert_motion_polynomial(...
        row + raDec2PixData.pixelBaseCorrection, ...
        column + raDec2PixData.pixelBaseCorrection, mp, eye(2), ...
        raDec2PixData.fcConstants);
else
	ra = nan;
	dec = nan;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mod out row col] = sky_to_pix(raDec2PixData, ra, dec, mjd)
if isfield(raDec2PixData, 'raDec2PixObject')
	[mod out row col] = ra_dec_2_pix(raDec2PixData.raDec2PixObject, ra, dec, mjd);
elseif isfield(raDec2PixData, 'motionPolynomialStruct')
    mpStruct = raDec2PixData.motionPolynomialStruct;
    % find the nearest motion polynomial to this mjd
    mpMjds = [mpStruct.mjdMidTime];
    if mjd < min(mpMjds) || mjd > max(mpMjds)
        error('sky_to_pix: requested MJD outside of motion polynomial range');
    end
    [dm mpIndx] = min(abs(mpMjds - mjd));
    mp = mpStruct(mpIndx);
    row = weighted_polyval2d(ra, dec, mp.rowPoly) - raDec2PixData.pixelBaseCorrection;
    col = weighted_polyval2d(ra, dec, mp.colPoly) - raDec2PixData.pixelBaseCorrection;
    mod = mp.module;
    out = mp.output;
else
	mod = nan;
	out = nan;
	row = nan;
	col = nan;
end
