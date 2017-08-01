function [centroidRow, centroidColumn, centroidStatus, ...
    centroidCovariance, transformationStruct, amplitude] ...
    = compute_starDataStruct_centroid(starDataStruct, prfObject, timeStamps, type)
% function [centroidRow, centroidColumn, centroidStatus, ...
%     centroidCovariance, transformationStruct] ...
%     = compute_starDataStruct_centroid(starDataStruct, prfObject, timeStamps, type)
%
% top-level centroiding routine for star pixel data.
% inputs:
% starDataStruct: Structure array of length nStars with the fields
%   .row, .column nPixels x 1 array containing the row and column of each
%       pixel
%   .values nPixels x nCadences array containing the pixel values
%   .uncertainties either an nPixels x nCadences array containing the pixel value
%       uncertainties or an nPixels x nPixels x nCadences array
%       containing the pixels covariance matrix
%   .inOptimalAperture nPixels x 1 array with a 1 if pixel is in optimal
%       aperture, 0 otherwise
%   .gapIndicators nPixels x nCadences array containing containing 1 if the
%       pixel value is gapped at a cadence
%	.seedRow, .seedColumn initial guess for the row and column position.
%		set these to empty if there is no initial guess
% prfObject prf to be used for centroiding.  May be empty.
% timeStamps times used to compute prf in the case that the prf is time
%   dependent (unlikely).  May be empty.
% optional inputs:
% type (default = 'best') string determining type of centroiding method.  
%   Currently supported types:
%       'best' uses prf-based centroiding if available, otherwise
%           flux-weighted centroid
%   	'flux-weighted' uses flux-weigheted centroiding
%       'gaussian-marginal' fits 1-dimensional Gaussians to the values
%           summed over rows and columns
%       '2D-gaussian' fits a two-dimensional gaussian
%
% returns:
% centroidRow, centroidColumn nStars x nCadences array containing the row
%   and column centroid for each star and cadence
% centroidStatus nStars x nCadences array indicating the status of the 
%	centroid computation: 0 = valid, 1 = invalid
% centroidCovariance an nStars x 2 x 2 x nCadences array containing 
%	the row and column centroid covariance matrix 
% transformationStruct structure array of length nStars with the following
%   fields:
%   .rowJacobian, .columnJacobian nPixels x nCadences array giving
%       the Jacobian of the linearized transformation associated with the chosen
%       centroiding method 
%
% See also COMPUTE_PIXEL_CENTROID COMPUTE_FLUX_WEIGHTED_CENTROID
% COMPUTE_GAUSSIAN_MARGINAL_CENTROID COMPUTE_2D_GAUSSIAN_CENTROID
% COMPUTE_PRF_CENTROID
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


if nargin < 4
    type = 'best';
end

nStars = length(starDataStruct);
nCadences = size(starDataStruct(1).values, 2);
centroidRow = zeros(nStars, nCadences);
centroidColumn = zeros(nStars, nCadences);
centroidStatus = zeros(nStars, nCadences);
centroidCovariance = zeros(nStars, 2, 2, nCadences);
transformationStruct = repmat(struct('rowJacobian', [], 'columnJacobian', []), nStars, 1);
for s=1:nStars
    if isempty(starDataStruct(s).inOptimalAperture) || sum(starDataStruct(s).inOptimalAperture) < 9
        inOptAp = ones(size(starDataStruct(s).values, 1), 1);
    else
        inOptAp = starDataStruct(s).inOptimalAperture;
    end
    notGaps = ~starDataStruct(s).gapIndicators(inOptAp==1, :);
    if ndims(starDataStruct(s).uncertainties) == 2
        uncertainties = starDataStruct(s).uncertainties(inOptAp==1, :);
        uncertainties(~notGaps) = 1e100;
    elseif ndims(starDataStruct(s).uncertainties) == 3
        uncertainties = starDataStruct(s).uncertainties(inOptAp==1, inOptAp==1, :);
        for c=1:nCadences
            uncertainties(~notGaps(:, c), :, c) = 1e100; % don't use inf 'cause MATLAB says 0*inf = NAN
            uncertainties(:, ~notGaps(:, c), c) = 1e100; % don't use inf 'cause MATLAB says 0*inf = NAN
        end
    end
    [centroidRow(s,:), centroidColumn(s,:), centroidStatus(s,:), ...
		centroidCovariance(s,:,:,:), ...
        transformationStruct(s).rowJacobian, ...
        transformationStruct(s).columnJacobian, amplitude] ...
        = compute_pixel_centroid(starDataStruct(s).row(inOptAp==1), ...
        starDataStruct(s).column(inOptAp==1), starDataStruct(s).values(inOptAp==1, :).*notGaps, ...
        uncertainties, prfObject, timeStamps, type, ...
		starDataStruct(s).seedRow, starDataStruct(s).seedColumn);
end
