function [centroidRow, centroidColumn, centroidStatus, ...
    centroidCovariance, ...
    rowTransformation, columnTransformation, amplitude] ...
    = compute_pixel_centroid(row, column, values, uncertainties, ...
    prfObject, timeStamps, type, seedRow, seedColumn)
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
% function [centroidRow, centroidColumn, centroidStatus, ...
%     centroidCovariance, ...
%     rowTransformation, columnTransformation] ...
%     = compute_pixel_centroid(row, column, values, uncertainties, ...
%     prfObject, timeStamps, type, seedRow, seedColumn)
%
% centroiding routine for pixel data.
% inputs:
%   row, column nPixels x 1 array containing the row and column of each
%       pixel
%   values nPixels x nCadences array containing the pixel values
%   uncertainties either an nPixels x nCadences array containing the pixel value
%       uncertainties or an nPixels x nPixels x nCadences array
%       containing the pixels covariance matrix
%   prfObject prf to be used for centroiding.  May be empty.
%   timeStamps times used to compute prf in the case that the prf is time
%       dependent (unlikely).  May be empty.
% optional inputs:
%   type (default = 'best') string determining type of centroiding method.  
%   	Currently supported types:
%           'best' uses prf-based centroiding if available, otherwise
%               flux-weighted centroid
%           'flux-weighted' uses flux-weigheted centroiding
%           'gaussian-marginal' fits 1-dimensional Gaussians to the values
%               summed over rows and columns
%           '2D-gaussian' fits a two-dimensional gaussian
% 	seedRow, seedColumn initial guess for the row and column position.
%		may be empty
%
% returns:
% centroidRow, centroidColumn 1 x nCadences array containing the row
%   and column centroid for each star and cadence
% centroidStatus 1 x nCadences array indicating the status of the 
%	centroid computation: 0 = valid, 1 = invalid
% centroidCovariance an nStars x 2 x 2 x nCadences array containing 
%	the row and column centroid covariance matrix 
% rowTransformation, columnTransformation nPixels x nCadences array giving
%       the Jacobian of the linearized transformation associated with the chosen
%       centroiding method 
%
% See also COMPUTE_STARDATASTRUCT_CENTROID COMPUTE_FLUX_WEIGHTED_CENTROID 
% COMPUTE_GAUSSIAN_MARGINAL_CENTROID COMPUTE_2D_GAUSSIAN_CENTROID
% COMPUTE_PRF_CENTROID
%

if nargin < 9 
	seedRow = [];
	seedColumn = [];
end
if nargin < 7 
	type = 'best';
end

switch(type)
    case 'best'
        if isempty(prfObject)
            type = 'flux-weighted';
        else
            type = 'prf';
        end
end

amplitude = 0;

switch(type)
    case {'flux-weighted'}
		if nargout == 3
        	[centroidRow, centroidColumn, centroidStatus] ...
            	= compute_flux_weighted_centroid(row, column, values, ...
            	uncertainties);
		else
			[centroidRow, centroidColumn, centroidStatus, ...
                centroidCovariance, ...
                rowTransformation, columnTransformation] ...
            	= compute_flux_weighted_centroid(row, column, values, ...
            	uncertainties);
		end

    case {'gaussian-marginal'}
        	[centroidRow, centroidColumn, centroidStatus, ...
                centroidCovariance, ...
                rowTransformation, columnTransformation] ...
            	= compute_gaussian_marginal_centroid(row, column, values, ...
            	uncertainties, seedRow, seedColumn);

    case {'2D-gaussian'}
        	[centroidRow, centroidColumn, centroidStatus, ...
                centroidCovariance, ...
                rowTransformation, columnTransformation] ...
            	= compute_2D_gaussian_centroid(row, column, values, ...
            	uncertainties, seedRow, seedColumn);

    case {'prf'}
        	[centroidRow, centroidColumn, centroidStatus, ...
                centroidCovariance, ...
                rowTransformation, columnTransformation, amplitude] ...
            	= compute_prf_centroid(row, column, values, ...
            	uncertainties, prfObject, timeStamps, seedRow, seedColumn);

    
    otherwise
        error('bad centroid type');
end
