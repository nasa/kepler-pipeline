function [centroidRow, centroidColumn, centroidStatus, ...
	centroidCovariance, rowJacobian, columnJacobian, amplitude] ...
    = compute_prf_centroid(row, column, values, uncertainties, prfMasterObject, ...
	timeStamps, seedRow, seedCol)
% function [centroidRow, centroidColumn, centroidStatus, ...
% 	centroidCovariance, rowJacobian, columnJacobian] ...
%     = compute_prf_centroid(row, column, values, uncertainties, prfObject, ...
% 	timeStamps, seedRow, seedCol)
%
% centroiding routine that fits a 2-dimensional PRF to the pixel array
% values.  The fit is initialized by taking the flux-weighted centroid.
%
% inputs:
%   row, column nPixels x 1 array containing the row and column of each
%       pixel
%   values nPixels x nCadences array containing the pixel values
%   uncertainties nPixels x nCadences array containing the pixel value
%       uncertainties
%   prfObject prf object to fit the pixels to
%   timeStamps times used to compute prf in the case that the prf is time
%       dependent (unlikely).  May be empty.
%   seedRow, seedCol (optional) initial guess for the row and column position.
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
% amplitude 1 x nCadences array giving the fitted amplitude of the data
%
% See also COMPUTE_STARDATASTRUCT_CENTROID COMPUTE_PIXEL_CENTROID
% COMPUTE_FLUX_WEIGHTED_CENTROID COMPUTE_GAUSSIAN_MARGINAL_CENTROID
% COMPUTE_2D_GAUSSIAN_CENTROID 
%
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

% extract interpolated prf for the input position
% prfObject = get_interpolated_prf( prfMasterObject, mean(row), mean(column) );

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

amplitude = zeros(1, nCadences);
centroidRow = zeros(1, nCadences);
centroidColumn = zeros(1, nCadences);
centroidCovariance = zeros(2, 2, nCadences);
rowJacobian = zeros(nPixels, nCadences);
columnJacobian = zeros(nPixels, nCadences);
% options = statset('nlinfit');
options = statset('TolX', 1e-12, 'TolFun', 1e-12, 'DerivStep', 10*eps);
% options = statset('Display', 'iter', 'TolX', 1e-12, 'TolFun', 1e-12, 'DerivStep', 10*eps);
% options = statset('Display', 'final', 'TolX', 1e-12, 'TolFun', 1e-12);
% options = statset('Display', 'iter');

valueCovariance = zeros(nPixels, nPixels, nCadences);
if ndims(uncertainties) == 2
    for cadence = 1:nCadences
        valueCovariance(:,:,cadence) = diag(uncertainties(:,cadence).^2);
    end
elseif ndims(uncertainties) == 3
    valueCovariance = uncertainties;
end
% scale the covariance matrix
for cadence = 1:nCadences
    valueCovariance(:,:,cadence) ...
        = valueCovariance(:,:,cadence)./(scaleNormalization(cadence)^2);
    uncertainties(:,cadence) = sqrt(diag(squeeze(valueCovariance(:,:,cadence))));
end


seedRow = seedRow(1);
seedCol = seedCol(1);

prfObject = get_interpolated_prf( prfMasterObject, seedRow, seedCol);
% draw(prfObject);

userStruct.uncertainties = uncertainties(:,1);
userStruct.prfObject = prfObject;
% if ~centroidStatus(1)        
% 	testPrf = compute_star_image([seedRow, seedCol], [row; column], userStruct);
% % 	seedAmplitude = max(values(:,1)./uncertainties(:,1))/max(testPrf);
% 	normValues = values(:,1)./uncertainties(:,1);
% 	seedAmplitude = sum(sum(testPrf.*normValues))/sum(sum(testPrf.^2));
% else
% 	seedAmplitude = 1;
% end
seed = [seedRow, seedCol];

for cadence = 1:nCadences
    if ~centroidStatus(cadence)        
        % a is an input vector with 
        % a(1) = amplitude
        % a(2) = row center
        % a(3) = column center
        userStruct.uncertainties = uncertainties(:,cadence);
%         disp(cadence);

%         disp(['initial data = ' num2str([seedAmplitude, seedRow(cadence), seedCol(cadence)])]);
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
            if nargin >= 7
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
%     disp(amplitude(cadence));
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

userStruct.y = y;
bestFit = seed;

[bestFit, r, J, C] = kepler_user_nonlinearfit(X, y, ...
        @compute_star_image, bestFit, options, userStruct);
    
testPrf = compute_star_image(bestFit, X, userStruct);
newAmplitude = sum(sum(testPrf.*y))/sum(sum(testPrf.^2));

%         disp(['bestFit = ' num2str(bestFit)]);
cRow = bestFit(1);
cCol = bestFit(2);
amplitude = newAmplitude*scaleNormalization;

seed = bestFit;

[covariance, rowJ, colJ] = centroid_error_propagation(valueCovariance, J);
rowJ = rowJ./(userStruct.uncertainties*scaleNormalization);
colJ = colJ./(userStruct.uncertainties*scaleNormalization);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prf = compute_star_image(a, X, userStruct)
nPixels = size(userStruct.uncertainties, 1);
prf = evaluate(userStruct.prfObject, a(1), a(2), ...
	X(1:nPixels), X(nPixels+1:end))./userStruct.uncertainties;
y = userStruct.y;
amplitude = sum(sum(prf.*y))/sum(sum(prf.^2));
prf = amplitude*prf;