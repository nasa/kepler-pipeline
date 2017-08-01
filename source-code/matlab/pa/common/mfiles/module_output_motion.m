function moduleOutputMotionPolyStruct = ...
    module_output_motion(targetStarStruct, motionPolynomialOrder)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function function moduleOutputMotionPolyStruct = module_output_motion(targetStarStruct, ...
%   motionPolynomialOrder)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% compute image motion polynomial from target pixels
%
% inputs: 
%   targetStarStruct struct array containing all data for each target star
%       with at least the following fields:
%       .referenceRow, .referenceColumn reference row and column for this
%           target's aperture
%       .pixelTimeSeriesStruct struct array giving the pixel time series data
%           with at least the following fields:
%           .timeSeries time series of pixel flux data
%           .target target index for target that contains this pixel
%           .row, .column row, column of pixel
%           .isInOptimalAperture flag that when true indicates this pixel is in
%               the target's optimal aperture
%   motionPolynomialOrder order of the polynomial used to compute output
%       2D polynomial
%
% output: 
%   .motionCoeffStruct 1 x # of cadences array of polynomial
%       coefficient structs describing image motion as returned by
%       robust_polyfit2d() 
%
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

% first make sure centroid data is in the input structure
if ~isfield(targetStarStruct, 'rowCentroid') || ...
        (isfield(targetStarStruct, 'rowCentroid') && isempty(targetStarStruct(1).rowCentroid)) 
    targetStarStruct = simple_target_centroid(targetStarStruct);
end

fluxMat = vertcat(targetStarStruct.flux);

nCadences = length(targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);
% make an nTargets x nCadences array with 1 for any target that has a gap
% in an optimal pixel in that cadence
gapsMat = zeros(size(fluxMat));
pixNum = zeros(length(targetStarStruct), 1);
for target = 1:length(targetStarStruct)
    for pixel = 1:length(targetStarStruct(target).pixelTimeSeriesStruct)
        pixelStruct = targetStarStruct(target).pixelTimeSeriesStruct(pixel);
        if pixelStruct.isInOptimalAperture
            gapsMat(target, pixelStruct.gapList) = 1;
        end
    end
    pixNum(target) = length(targetStarStruct(target).pixelTimeSeriesStruct);
end

% declare that any cadence at which there is a gap in an aperture is a gap
% in the centroid series for the whole aperture and fill in the centroid
% time series with a local polyfit
for target = 1:length(targetStarStruct)
    if (pixNum(target) >= 4) && (pixNum(target) <= 20)
        gaps = gapsMat(target, :);
        if any(gaps ~= 1)
            weights = gaps ~= 1;
            rowFit = robust_polyfit((1:nCadences)', targetStarStruct(target).rowCentroid', weights', 4);
            colFit = robust_polyfit((1:nCadences)', targetStarStruct(target).colCentroid', weights', 4);
            rowTrend = weighted_polyval((1:nCadences)', rowFit);
            colTrend = weighted_polyval((1:nCadences)', colFit);
            targetStarStruct(target).rowCentroid(gaps==1) = rowTrend(gaps==1);
            targetStarStruct(target).colCentroid(gaps==1) = colTrend(gaps==1);
        end
    end
end

% % declare that any cadence at which there is a gap in an aperture is a gap
% % in the centroid series for the whole aperture and fill in the centroid
% % time series with a local polyfit
% for target = 1:length(targetStarStruct)
%     if (pixNum(target) >= 4) && (pixNum(target) <= 20)
%         gaps = gapsMat(target, :);
%         rowFit = fast_local_polyfit(targetStarStruct(target).rowCentroid, 4, 50, 1);
%         colFit = fast_local_polyfit(targetStarStruct(target).colCentroid, 4, 50, 1);
%         targetStarStruct(target).rowCentroid(gaps==1) = rowFit(gaps==1);
%         targetStarStruct(target).colCentroid(gaps==1) = colFit(gaps==1);
%     end
% end

% reorganize the centroid data into an nTargets x nCadences array
rowCentroidMat = vertcat(targetStarStruct.rowCentroid);
centroidColumnMat = vertcat(targetStarStruct.colCentroid);

% for each cadence compute a motion polynomial
% get the number of cadences, assumes all time series are of same
% length

for cadence = 1:nCadences
    % compute offsets relative to the reference row and column
    row = rowCentroidMat(:,cadence);
    column = centroidColumnMat(:,cadence);
    % weight the targets by their shot noise
    weights = ones(length(targetStarStruct), 1);
%     weights(fluxMat(:,cadence) > 0) = power(sqrt(fluxMat(fluxMat(:,cadence) > 0,cadence)), -1);
%     % make it a column vector
%     weights = weights';
    % weight the centroids so that targets with zero flux at this cadence
    % are ignored (currently disabled)
%     weights(fluxMat(:,cadence) == 0) = 0;
    % weight the targets so only targets with between 9 and 35 pixels are
    % used
    weights(pixNum < 4) = 0;
    weights(pixNum > 20) = 0;

    % compute the motion as a 2D polynomial 
    moduleOutputMotionPolyStruct(cadence).rowCoeff = ...
        robust_polyfit2d([targetStarStruct.referenceRow]',...
        [targetStarStruct.referenceColumn]', row, weights, motionPolynomialOrder); 
    moduleOutputMotionPolyStruct(cadence).columnCoeff = ...
        robust_polyfit2d([targetStarStruct.referenceRow]',...
        [targetStarStruct.referenceColumn]', column, weights, motionPolynomialOrder); 
end
