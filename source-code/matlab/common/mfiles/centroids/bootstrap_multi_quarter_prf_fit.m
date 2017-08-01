function [centroidStatus, bsDirectRa, bsDirectDec, bsDirectCovariance, ...
bsDifferenceRa, bsDifferenceDec, bsDifferenceCovariance, bsDiagnostics] = ...
bootstrap_multi_quarter_prf_fit(directImageData, differenceImageData, ...
prfStruct, raDec2PixData, seedRa, seedDec, maxFail, maxTrials, ...
singlePrfFitForCentroidPositionsEnabled)
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
% function [meanRaOffset, meanDecOffset, centroidStatus, offsetCovariance, ...
% raOffsets, decOffsets, quarterList] = ...
% bootstrap_multi_quarter_prf_fit(directImageData, differenceImageData, ...
% prfStruct, raDec2PixData, seedRa, seedDec, maxFail, maxTrials, ...
% singlePrfFitForCentroidPositionsEnabled)
%
% Routine that provides bootstrap-based average RA and Dec positions based
% on repeated trials involving multi-quarter PRF fitting of direct (out-of-
% transit) average pixel images and average difference images. Covariance
% matrices for the estimated direct and difference image positions are also
% provided. The purpose is to separately identify the locations of the
% transit source and the target star. The offsets between transit source
% and target are computed separately.
%
% The positions and covariances returned by this function are the mean and
% covariance of nQuarters^2 positions measured by multi-quarter PRF fits on
% resampled (with replacement) data of the nQuarters input data. Because
% the execution time of each multi-quarter PRF fit scales as nQuarters, the
% execution time of this function scales as nQuarters^3.
%
% Because this function performs multi-quarter PRF fits based on resampling
% with replacement, some of the resampled quarters may not allow a fit.
% This function generates an error when more than maxFail consecutive
% resamplings result in multi-quarter fit failures.
%
% inputs:
%	directImageData nQuarters x 1 structure array with the following fields set for each quarter
%		.values nPixels x 1 array containing the pixel values to be fit
%   	.uncertainties nPixels x 1 array containing the pixel value uncertainties
%       	_or_ nPixels x nPixels array containing the pixel value covariance matrix
%   	.ccdRow, ccdColumn nPixels x 1 array containing the row and column of each
%       	pixel in the .values field 
%		.ccdModule, .ccdOutput the module and output of the star being fit
%		.mjd the MJD time to be centroided this quarter (in the future this may be extended to multiple MJDs)
%       .targetTableId integer LC target table Id for given 'quarter'
%	differenceImageData nQuarters x 1 structure array with the following fields set for each quarter
%		.values nPixels x 1 array containing the pixel values to be fit
%   	.uncertainties nPixels x 1 array containing the pixel value uncertainties
%       	_or_ nPixels x nPixels array containing the pixel value covariance matrix
%   	.ccdRow, ccdColumn nPixels x 1 array containing the row and column of each
%       	pixel in the .values field 
%		.ccdModule, .ccdOutput the module and output of the star being fit
%		.mjd the MJD time to be centroided this quarter (in the future this may be extended to multiple MJDs)
%       .targetTableId integer LC target table Id for given 'quarter'
%   prfStruct nPRFs x 1 array containing the PRF data.  There must be one entry
%		for each channel present in the image data structures.  The fields are:
%		.prf a PRF object.  If it is a prfCollectionClass object it will be 
%			interpolated, otherwise it is used as is
%		.ccdModule, .ccdOutput the module and output on which this PRF is defined.
%	raDec2PixData a structure containing one of the following fields, only one of which should be present
%		.raDec2PixObject if present, CCD positions are computed using the raDec2PixClass
%		.motionPolynomialStruct if present, CCD positions are computed
%		using motion polynomials.  In this case the fields .fcConstants and
%		.pixelBaseCorrection (= 1 for zero-based and 0 for 1-based) are
%		required.
% 	seedRa, seedDec (optional) initial guess for the Ra and Dec coordinates in units of degrees.
%		May be empty.  If these inputs are missing the seed is computed using flux-weighted centroids
%   maxFail (optional) the maximum number of consecutive failed resamplings
%       allowed before this function throws an error.
%   maxTrials (optional) the maximum number of bootstrap trials allowed
%   singlePrfFitForCentroidPositionsEnabled (optional) if true, use one
%        multi-quarter fit to all available direct and difference image
%        data to determine the respective centroid positions.
%
% returns:
%   centroidStatus 1 x nCadences array indicating the status of the 
%       centroid computation: 0 = valid, 1 = invalid
%   bsDirectRa, bsDirectDec The average of the nQuarters^2 RA and Dec direct image
%       coordinates measured by the individual resampled multi-quarter PRF fits
%       (in units of degrees)
%   bsDirectCovariance The covariance of the nQuarters^2 RA and Dec direct image
%       coordinates measured by the individual resampled multi-quarter PRF fits
%   bsDifferenceRa, bsDifferenceDec The average of the nQuarters^2 RA and Dec difference image
%       coordinates measured by the individual resampled multi-quarter PRF fits
%       (in units of degrees)
%   bsDifferenceCovariance The covariance of the nQuarters^2 RA and Dec difference image
%       coordinates measured by the individual resampled multi-quarter PRF fits
%   bsDiagnostics diagnostics structure with the following fields
%       targetTableIds nQuarters x 1 array with the targetTableId associated with
%           each 'quarter' in the bootstrap PRF fit
%       quarterList nQuarters^2 x nQuarters array giving the quarters used in
%           each resampled multi-quarter PRF fit, resulting in the coordinates in
%           directRaArray/directDecArray and differenceRaArray/differenceDecArray
%       directRaArray, directDecArray nQuarters^2 x 1 arrays with the RA and Dec
%           direct image coordinates for each trial
%       differenceRaArray, differenceDecArray nQuarters^2 x 1 arrays with the RA and Dec
%           difference image coordinates for each trial
%
% See also COMPUTE_MULTI_QUARTER_PRF_FIT 
%

if nargin < 5
	seedRa = [];
end

if nargin < 6
	seedDec = [];
end

if nargin < 7
	maxFail = 20;
end

if nargin < 8
    maxTrials = Inf;
end

if nargin < 9
    singlePrfFitForCentroidPositionsEnabled = false;
end

% set defaults
centroidStatus = 0;
bsDirectRa = [];
bsDirectDec = [];
bsDirectCovariance = [];
bsDifferenceRa = [];
bsDifferenceDec = [];
bsDifferenceCovariance = [];
bsDiagnostics = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% estimate mean direct and difference positions and uncertainties via bootstrap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nQuarters = length(directImageData);
nTrials = min(nQuarters*nQuarters, maxTrials);
if nQuarters > 0
    targetTableIds = [directImageData.targetTableId]';
else
    targetTableIds = [];
end

% now rotate through quarters
indexArray = fix(nQuarters*rand(5*nTrials,nQuarters)) + 1;
bCount = 1;
bIndex = 1;
failCount = 0;

directRaArray = zeros(nTrials, 1);
directDecArray = zeros(nTrials, 1);
differenceRaArray = zeros(nTrials, 1);
differenceDecArray = zeros(nTrials, 1);
quarterList = zeros(nTrials, nQuarters);

while bCount <= nTrials && bIndex <= size(indexArray, 1)
    
    bCadences = indexArray(bIndex, :);
    directBsData = directImageData(bCadences);
    differenceBsData = differenceImageData(bCadences);
	bIndex = bIndex + 1;

    caughtError = 0;
	try
    	[directRa, directDec, centroidFailed] = ...
        	compute_multi_quarter_prf_fit(directBsData, prfStruct, raDec2PixData, seedRa, seedDec);
    catch
        caughtError = 1;
    end
    
    if caughtError || centroidFailed
		disp(['direct: bad multi-quarter fit bootstrap sample, bCount = ' num2str(bCount) ...
			' of ' num2str(nTrials) ', bIndex = ' num2str(bIndex-1) ' of ' num2str(size(indexArray, 1))]);
		disp(bCadences);
		failCount = failCount + 1;
		if failCount > maxFail
			disp('bootstrap PRF fit: too many failures');
			centroidStatus = 1;
            return;
        end
		continue;
    end
    
    caughtError = 0;
	try
    	[differenceRa, differenceDec, centroidFailed] = ...
        	compute_multi_quarter_prf_fit(differenceBsData, prfStruct, raDec2PixData);
	catch
        caughtError = 1;
    end
    
    if caughtError || centroidFailed
		disp(['difference: bad multi-quarter fit bootstrap sample, bCount = ' num2str(bCount) ...
			' of ' num2str(nTrials) ', bIndex = ' num2str(bIndex-1) ' of ' num2str(size(indexArray, 1))]);
		disp(bCadences);
		failCount = failCount + 1;
		if failCount > maxFail
			disp('bootstrap PRF fit: too many failures');
			centroidStatus = 1;
            return;
        end
		continue;
    end
    
	directRaArray(bCount) = directRa;
    directDecArray(bCount) = directDec;
    differenceRaArray(bCount) = differenceRa;
    differenceDecArray(bCount) = differenceDec;
    quarterList(bCount, :) = bCadences;
	
	bCount = bCount + 1;
	failCount = 0;
    
end

if bCount <= nTrials
    disp('bootstrap PRF fit: too many failures to compute centroids');
	centroidStatus = 1;
    return;
end

bsDirectRa = mean(directRaArray);
bsDirectDec = mean(directDecArray);
bsDirectCovariance = cov(directRaArray, directDecArray);

bsDifferenceRa = mean(differenceRaArray);
bsDifferenceDec = mean(differenceDecArray);
bsDifferenceCovariance = cov(differenceRaArray, differenceDecArray);

bsDiagnostics = struct( ...
    'targetTableIds', targetTableIds, ...
    'quarterList', quarterList, ...
    'directRaArray', directRaArray, ...
    'directDecArray', directDecArray, ...
    'differenceRaArray', differenceRaArray, ...
    'differenceDecArray', differenceDecArray);

% Replace the bootstrapped mean centroid positions of the direct and
% difference images with single PRF centroid fit results to all available
% quarterly images if enabled. If either of the single MQ PRF fits fail
% then do not replace either the direct or difference image centroid
% positions.
if singlePrfFitForCentroidPositionsEnabled
    
    caughtDirectError = 0;
    caughtDifferenceError = 0;
    
    try
    	[directRa, directDec, directCentroidFailed] = ...
        	compute_multi_quarter_prf_fit(directImageData, prfStruct, ...
            raDec2PixData, seedRa, seedDec);
    catch
        caughtDirectError = 1;
    end
    
    try
    	[differenceRa, differenceDec, differenceCentroidFailed] = ...
        	compute_multi_quarter_prf_fit(differenceImageData, prfStruct, ...
            raDec2PixData);
	catch
        caughtDifferenceError = 1;
    end
    
    if ~caughtDirectError && ~directCentroidFailed && ...
            ~caughtDifferenceError && ~differenceCentroidFailed
        bsDirectRa = directRa;
        bsDirectDec = directDec;
        bsDifferenceRa = differenceRa;
        bsDifferenceDec = differenceDec;
    end
    
end

return
