function [centroidRow, centroidColumn, centroidStatus, ...
	centroidCovariance, rowJacobian, columnJacobian] ...
    = compute_2D_gaussian_centroid(row, column, values, uncertainties, ...
	seedRow, seedCol)
% function [centroidRow, centroidColumn, centroidStatus, ...
% 	centroidCovariance, rowJacobian, columnJacobian] ...
%     = compute_2D_gaussian_centroid(row, column, values, uncertainties, ...
% 	seedRow, seedCol)
%
% centroiding routine that fits a 2-dimensional Gaussian.  The fit is
% initialized by taking the flux-weighted centroid
%
% inputs:
%   row, column nPixels x 1 array containing the row and column of each
%       pixel
%   values nPixels x nCadences array containing the pixel values
%   uncertainties nPixels x nCadences array containing the pixel value
%       uncertainties
% 	seedRow, seedCol initial guess for the row and column position.
%		may be empty
%
% returns:
% centroidRow, centroidColumn 1 x nCadences array containing the row
%   and column centroid for each star and cadence
% centroidStatus 1 x nCadences array indicating the status of the 
%	centroid computation: 0 = valid, 1 = invalid
% centroidCovariance an nStars x 2 x 2 x nCadences array containing 
%	the row and column centroid covariance matrix 
% transformationStruct structure array of length nStars with the following
%   fields:
%   .rowJacobian, .columnJacobian nPixels x nCadences array giving
%       the Jacobian of the linearized transformation associated with the chosen
%       centroiding method 
%
% See also COMPUTE_STARDATASTRUCT_CENTROID COMPUTE_PIXEL_CENTROID
% COMPUTE_FLUX_WEIGHTED_CENTROID COMPUTE_GAUSSIAN_MARGINAL_CENTROID 
% COMPUTE_PRF_CENTROID
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

nCadences = size(values, 2);
nPixels = size(values, 1);

% initialize the fit by taking the flux-weighted centroid
if nargin < 6 || (isempty(seedRow) || isempty(seedCol))
	[seedRow, seedCol, centroidStatus] ...
	    = compute_flux_weighted_centroid(row, column, values, uncertainties);
else
	centroidStatus = zeros(1, nCadences);
	% make sure the seeds are the expected sizes
	if length(seedRow) == 1
		seedRow = seedRow*ones(1, nCadences);
	end
	if length(seedCol) == 1
		seedCol = seedCol*ones(1, nCadences);
	end
end
centroidStatus(seedRow < min(row) | seedRow > max(row) ...
    | seedCol < min(column) | seedCol > max(column)) = 1;

% normalize the pixel values to improve conditioning
scaleNormalization = sum(values,1);
goodCadences = scaleNormalization ~= 0;
values(:,goodCadences) = scalerow(1./scaleNormalization(goodCadences), values(:,goodCadences));
uncertainties(:,goodCadences) = scalerow(1./scaleNormalization(goodCadences), uncertainties(:,goodCadences));

centroidRow = zeros(1, nCadences);
centroidColumn = zeros(1, nCadences);
centroidCovariance = zeros(2, 2, nCadences);
rowJacobian = zeros(nPixels, nCadences);
columnJacobian = zeros(nPixels, nCadences);
options = statset('nlinfit');

valueCovariance = zeros(nPixels, nPixels, nCadences);
if ndims(uncertainties) == 2
    for cadence = 1:nCadences
        valueCovariance(:,:,cadence) = diag(uncertainties(:,cadence).^2);
    end
elseif ndims(uncertainties) == 3
    valueCovariance = uncertainties;
end

userStruct.uncertainties = uncertainties(:,cadence);
testFit = compute_gaussian([1, seedRow(1), seedCol(1), 1], [row; column], userStruct);
seedAmplitude = max(values(:,1)./uncertainties(:,1))/max(testFit);
seed = [seedAmplitude, seedRow(1), seedCol(1), 1];
for cadence = 1:nCadences
    if ~centroidStatus(cadence)
        userStruct.uncertainties = uncertainties(:,cadence);
        % a is an input vector with 
        % a(1) = amplitude
        % a(2) = row center
        % a(3) = column center
        % a(4) = width
			
        try
            [centroidRow(cadence), centroidColumn(cadence), amplitude(cadence), ...
                centroidCovariance(:,:,cadence), ...
                rowJacobian(:,cadence), columnJacobian(:,cadence), seed] ...
                = compute_centroid([row; column], ...
                values(:,cadence)./uncertainties(:,cadence), ...
                seed, options, userStruct, ...
                scaleNormalization(cadence), squeeze(valueCovariance(:,:,cadence)));
        catch
            % the centroid with the current seed failed.
            % if that seed was in the inputs, try a flux-weighted centroid
            if nargin >= 5
                try
                    [seedRow, seedCol, centroidStatus] ...
                        = compute_flux_weighted_centroid(row, column, values, uncertainties);
                    seed = [seedAmplitude, seedRow, seedCol];
                    [centroidRow(cadence), centroidColumn(cadence), amplitude(cadence), ...
                        centroidCovariance(:,:,cadence), ...
                        rowJacobian(:,cadence), columnJacobian(:,cadence), seed] ...
                        = compute_centroid([row; column], ...
                        values(:,cadence)./uncertainties(:,cadence), ...
                        seed, options, userStruct, ...
                        scaleNormalization(cadence), squeeze(valueCovariance(:,:,cadence)));
                catch
        			centroidStatus(cadence) = 1;
                end
            else
                centroidStatus(cadence) = 1;
            end
        end
		if ~isempty(lastwarn)
			centroidStatus(cadence) = 1;
			lastwarn('');
		end
    end
end
centroidStatus(centroidRow < min(row) | centroidRow > max(row) ...
    | centroidColumn < min(column) | centroidColumn > max(column)) = 1;

warning(inputWarningState);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cRow, cCol, amplitude, covariance, rowJ, colJ, seed] ...
    = compute_centroid(X, y, seed, options, userStruct, scaleNormalization, valueCovariance)

[bestFit, r, J, C] = kepler_user_nonlinearfit(X, y, ...
    @compute_gaussian, seed, options, userStruct);

%         disp(['bestFit = ' num2str(bestFit)]);
cRow = bestFit(2);
cCol = bestFit(3);
amplitude = bestFit(1)*scaleNormalization;

seed = bestFit;

[covariance, rowJ, colJ] = centroid_error_propagation(valueCovariance, J);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g = compute_gaussian(a, X, userStruct)
nPixels = size(userStruct.uncertainties, 1);
g = a(1)*exp(-((X(1:nPixels) - a(2)).^2 ...
	+ (X(nPixels+1:end) - a(3)).^2)/a(4)^2)./userStruct.uncertainties;
