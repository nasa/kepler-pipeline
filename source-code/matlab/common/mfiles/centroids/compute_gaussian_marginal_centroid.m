function [centroidRow, centroidColumn, centroidStatus, ...
	centroidCovariance, rowJacobian, columnJacobian] ...
    = compute_gaussian_marginal_centroid(row, column, values, uncertainties, ...
	seedRow, seedCol)
% function [centroidRow, centroidColumn, centroidStatus, ...
% 	centroidCovariance, rowJacobian, columnJacobian] ...
%     = compute_gaussian_marginal_centroid(row, column, values, uncertainties, ...
% 	seedRow, seedCol)
%
% centroiding routine that fits 1-dimensional Gaussians to the values
% summed over rows and columns.  The fit is initialized by taking the
% flux-weighted centroid
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
% COMPUTE_FLUX_WEIGHTED_CENTROID COMPUTE_2D_GAUSSIAN_CENTROID
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
% make a 2D array to hold the image
minRow = min(row);
minCol = min(column);
maxRow = max(row);
maxCol = max(column);
nRows = maxRow - minRow + 1;
nCols = maxCol - minCol + 1;
arrayRows = minRow:maxRow;
arrayCols = minCol:maxCol;

% define a matrix that converts the input pixel array to a row sum array:
% T[nRows x nPixels] * P[nPixels x nCadences] = rowSum[nRows x nCadences]
rowSumTransform = zeros(nRows, nPixels);
for r=1:length(arrayRows)
    rowSumTransform(r, :) = row == arrayRows(r);
end
rowSum = rowSumTransform * values;
% same for columns
colSumTransform = zeros(nCols, nPixels);
for c=1:length(arrayCols)
    colSumTransform(c, :) = column == arrayCols(c);
end
colSum = colSumTransform * values;


% normalize to improve the conditioning of the Jacobian
rowSum = rowSum./max(max(rowSum));
colSum = colSum./max(max(colSum));

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
centroidStatus(seedRow < minRow | seedRow > maxRow ...
    | seedCol < minCol | seedCol > maxCol) = 1;

finiteUncertainties = uncertainties;
finiteUncertainties(finiteUncertainties == 1e100) = 0;

uncertaintySquare = finiteUncertainties.^2;
rowUncertainty = sqrt(rowSumTransform * uncertaintySquare)./max(max(rowSum));
colUncertainty = sqrt(colSumTransform * uncertaintySquare)./max(max(colSum));

valueCovariance = zeros(nPixels, nPixels, nCadences);
if ndims(uncertainties) == 2
    for cadence = 1:nCadences
        valueCovariance(:,:,cadence) = diag(uncertaintySquare(:,cadence));
    end
elseif ndims(uncertainties) == 3
    valueCovariance = finiteUncertainties;
end


centroidRow = zeros(size(seedRow));
centroidColumn = zeros(size(seedCol));
centroidCovariance = zeros(2, 2, nCadences);
rowJacobian = zeros(nPixels, nCadences);
columnJacobian = zeros(nPixels, nCadences);
for cadence = 1:nCadences
    if ~centroidStatus(cadence)

        % fit the row sum first

        % define Gaussian anonymous error function 
        % a is an input vector with 
        % a(1) = amplitude
        % a(2) = center
        % a(3) = width
        try
            Gaussian = @(a, X) a(1)*exp(-(X - a(2)).^2/a(3)^2)./rowUncertainty(:,cadence);
            seedAmplitude = max(rowSum(:,cadence)./rowUncertainty(:,cadence));
            [bestFit, r, J, c] = nlinfit(arrayRows', ...
                rowSum(:,cadence)./rowUncertainty(:,cadence), Gaussian, ...
                [seedAmplitude, seedRow(cadence), 1]);
            centroidRow(cadence) = bestFit(2);
            forwardRowJ = squeeze(J(:,2));
            fitRowJacobian = (inv(forwardRowJ'*forwardRowJ)*forwardRowJ')';
            rowJacobian(:,cadence) = rowSumTransform'*(fitRowJacobian./rowUncertainty(:,cadence));

            % fit the columns
            Gaussian = @(a, X) a(1)*exp(-(X - a(2)).^2/a(3)^2)./colUncertainty(:,cadence);
            seedAmplitude = max(colSum(:,cadence)./colUncertainty(:,cadence));
            [bestFit, r, J, c] = nlinfit(arrayCols', ...
                colSum(:,cadence)./colUncertainty(:,cadence), Gaussian, ...
                [seedAmplitude, seedCol(cadence), 1]);
            centroidColumn(cadence) = bestFit(2);
            forwardColJ = squeeze(J(:,2));
            fitColJacobian = (inv(forwardColJ'*forwardColJ)*forwardColJ')';
            columnJacobian(:,cadence) = colSumTransform'*(fitColJacobian./colUncertainty(:,cadence));

            centroidCovariance(1,1,cadence) = rowJacobian(:,cadence)' ...
                *valueCovariance(:,:,cadence)*rowJacobian(:,cadence);
            centroidCovariance(1,2,cadence) = rowJacobian(:,cadence)' ...
                *valueCovariance(:,:,cadence)*columnJacobian(:,cadence);
            centroidCovariance(2,1,cadence) = centroidCovariance(1,2,cadence);
            centroidCovariance(2,2,cadence) = columnJacobian(:,cadence)' ...
                *valueCovariance(:,:,cadence)*columnJacobian(:,cadence);        
        catch
            centroidStatus(cadence) = 1;
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

