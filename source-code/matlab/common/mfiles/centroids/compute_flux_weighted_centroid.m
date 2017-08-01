function [centroidRow, centroidColumn, centroidStatus, ...
    centroidCovariance, rowJacobian, columnJacobian] ...
    = compute_flux_weighted_centroid(row, column, values, uncertainties)
% function [centroidRow, centroidColumn, ...
%   centroidRowCovariance, centroidColumnCovariance, transformation] ...
%     = compute_flux_weighted_centroid(row, column, value, uncertainties)
%
% flux-weighted centroiding routine for pixel data.
% inputs:
%   row, column nPixels x 1 array containing the row and column of each
%       pixel
%   values nPixels x nCadences array containing the pixel values
%   uncertainties nPixels x nCadences array containing the pixel value
%       uncertainties
%
% returns:
% centroidRow, centroidColumn 1 x nCadences array containing the row
%   and column centroid for each star and cadence
% centroidStatus 1 x nCadences array indicating the status of the 
%	centroid computation: 0 = valid, 1 = invalid
% centroidCovariance a 2 x 2 x nCadences arrays containing the row and column covariance matrix for
%   each cadence
% rowJacobian, columnJacobian nPixels x nCadences array giving
% the linearized transformations associated with the chosen centroiding method
%
% See also COMPUTE_STARDATASTRUCT_CENTROID COMPUTE_PIXEL_CENTROID
% COMPUTE_GAUSSIAN_MARGINAL_CENTROID COMPUTE_2D_GAUSSIAN_CENTROID
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

sumFlux = sum(values, 1);
% flag the cadences with zero flux
centroidStatus = sumFlux == 0;
goodCadence = ~centroidStatus;
goodValues = values(:,goodCadence);

nPixels = size(values, 1);
nCadences = size(values, 2);
nGoodCadences = size(goodValues, 2);

rowTransformation = zeros(nPixels, nCadences);
columnTransformation = zeros(nPixels, nCadences);

for cadence = 1:nCadences
    if goodCadence(cadence)
		rowTransformation(:,cadence) = row/sumFlux(cadence);
		columnTransformation(:,cadence) = column/sumFlux(cadence);
	end
end

% sumFlux, rowWeightedSum and colWeightedSum are 1 x nCadences
centroidRow = zeros(1, size(values,2));
centroidColumn = centroidRow;
centroidRow(goodCadence) = diag(rowTransformation(:,goodCadence)'*goodValues);
centroidColumn(goodCadence) = diag(columnTransformation(:,goodCadence)'*goodValues);

% compute the uncertainty if requested
if nargout > 3    
	finiteUncertainties = uncertainties;
	finiteUncertainties(finiteUncertainties == 1e100) = 0;
	valueCovariance = zeros(nPixels, nPixels, nCadences);
	if ndims(uncertainties) == 2
    	for cadence = 1:nCadences
        	if goodCadence(cadence)
            	valueCovariance(:,:,cadence) = diag(finiteUncertainties(:,cadence).^2);
        	end
    	end
		valueUncertainties = finiteUncertainties;
	elseif ndims(uncertainties) == 3
    	valueCovariance = finiteUncertainties;
    	for cadence = 1:nCadences
			valueUncertainties(:,cadence) = squeeze(sqrt(diag(valueCovariance(:,:,cadence))));
		end
	end

    centroidCovariance = zeros(2, 2, nCadences);
	rowJacobian = zeros(nPixels, nCadences);
	columnJacobian = zeros(nPixels, nCadences);
    for cadence = 1:nCadences
        if goodCadence(cadence)
			rowJ = (row - centroidRow(:,cadence))/sumFlux(cadence);
			colJ = (column - centroidColumn(:,cadence))/sumFlux(cadence);
			T = [rowJ colJ]';
			centroidCovariance(:,:,cadence) = T*valueCovariance(:,:,cadence)*T';
			rowJacobian(:,cadence) = rowJ;
			columnJacobian(:,cadence) = colJ;
        end
    end
end
