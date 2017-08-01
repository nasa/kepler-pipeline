function targetStarStruct = gauss_fit_target_centroid(targetStarStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function targetStarStruct = gauss_fit_target_centroid(targetStarStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% compute the target centroid time series in CCD coordinates using simple
% weighted sum algorithm.
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
% outputs:
%   targetStarStruct struct array as above with the following fields added:
%       .rowCentroid, .colCentroid 1 x # of cadences arrays giving row, column  
%           centroid location in CCD coordinates
%       .flux 1 x # of cadences array giving the simple pixel sum flux of
%       the target 
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

global gaussFitData;

% options = optimset('LargeScale', 'off', 'Jacobian', 'off', 'TolFun', 1e-5, ...
%     'Display', 'iter');
options = optimset('Display', 'off', 'LargeScale', 'off', 'Jacobian', 'on', ...
    'TolFun', 1e-5, 'TolX', 1e-5, 'DerivativeCheck', 'off');

% compute the centroids a target at a time
nTargets = length(targetStarStruct);
% check to see if cosmic ray cleaned pixels are available
% initialize crCleanedPixelsAvailable to an illegal value and search until
% it's been set to 0 or 1
crCleanedPixelsAvailable = -1;
if ~isfield(targetStarStruct(1).pixelTimeSeriesStruct(1), 'crCleanedSeries')
    crCleanedPixelsAvailable = 0;
else
    for target = 1:nTargets
        targetStruct = targetStarStruct(target);
        for pixel = 1:length(targetStruct.pixelTimeSeriesStruct)
            % cosmic ray cleaned pixels are not available if there is a target with
            % a pixel with non-zero timeSeries and zero crCleanedSeries
            if (sum(targetStruct.pixelTimeSeriesStruct(pixel).crCleanedSeries) == 0) && ...
                    (sum(targetStruct.pixelTimeSeriesStruct(pixel).timeSeries) ~= 0)
                crCleanedPixelsAvailable = 0;
                break;
            % cosmic ray cleaned pixels are  available if there is any target with
            % a pixel with non-zero crCleanedSeries            
            elseif sum(targetStruct.pixelTimeSeriesStruct(pixel).crCleanedSeries) ~= 0
                crCleanedPixelsAvailable = 1;
                break;
            end
        end
        % break out if we've determined state of cosmic ray cleaning 
        if crCleanedPixelsAvailable ~= -1
            break;
        end
    end
end
for target = 1:nTargets
    % pick out a target
    targetStruct = targetStarStruct(target);
    pixelStruct = targetStruct.pixelTimeSeriesStruct;
    % get the number of pixels
    nPixels = length(targetStruct.pixelTimeSeriesStruct);
    % get the number of cadences, assumes all time series are of same
    % length
    nCadences = length(pixelStruct(1).timeSeries);

    % do computation vectorized across pixels and cadences
    % rearrange pixel values to facilitate fast computation
    pixval = zeros(nPixels, nCadences);
    % test to see if cosmic ray cleaned pixels were computed
    
    if crCleanedPixelsAvailable
        % use the cosmic ray cleaned pixels if available
        for pixel = 1:nPixels 
            pixval(pixel, :) = pixelStruct(pixel).crCleanedSeries *...
                pixelStruct(pixel).isInOptimalAperture;
        end
    else
        for pixel = 1:nPixels 
            pixval(pixel, :) = pixelStruct(pixel).timeSeries *...
                pixelStruct(pixel).isInOptimalAperture;
        end
    end
    
    % do flux-weighted centroid first 
    % flux-weighted centroid using the formula
    %
    %   centroid = sum(x*pixel_value)/sum(pixel_value)
    %
    % compute denominator in formula
    flux = sum(pixval, 1);
    targetStarStruct(target).flux = flux;
    % compute formula, using column-by-column dot product to compute sums in
    % numerator where each column is a cadence
    % do computataion where flux is nonzero
    nonZeroFluxCadences = find(flux ~= 0);
    zeroFluxCadences = find(flux == 0);
    targetStarStruct(target).rowCentroid(nonZeroFluxCadences) = (...
        [pixelStruct.row]*pixval(:,nonZeroFluxCadences))./ ...
        flux(nonZeroFluxCadences);  
    targetStarStruct(target).colCentroid(nonZeroFluxCadences) = (...
        [pixelStruct.column]*pixval(:,nonZeroFluxCadences))./ ...
        flux(nonZeroFluxCadences);
    targetStarStruct(target).rowCentroid(zeroFluxCadences) = -1;
    targetStarStruct(target).colCentroid(zeroFluxCadences) = -1;
    
    targetStarStruct(target).gaussCentroidRow = targetStarStruct(target).rowCentroid;
    targetStarStruct(target).gaussCentroidColumn = targetStarStruct(target).colCentroid;
    targetStarStruct(target).gaussWidth = 0;

    % if we have enough pixels do the gaussian fit
    if (nPixels >= 9) && (nPixels < 35)
        gaussFitData.rowFitData = [];
        gaussFitData.colFitData = [];
        gaussFitData.fluxFitData = [];
        
        gaussFitData.rowFitData = vertcat(pixelStruct.row);
        gaussFitData.colFitData = vertcat(pixelStruct.column);
        for cadence = 1:nCadences
            if flux > 0
%                 gaussFitData.fluxFitData = pixval(:,cadence);
%                 % x = [a, b, s, r0, c0];
%                 % estimate the amplitude as the flux
%                 x0(1) = max(gaussFitData.fluxFitData);
%                 % estimate the offset as 0
%                 x0(2) = 0;
%                 % estimate the width as 0.1 pixel
%                 x0(3) = 0.7;
%                 % set the initial row and column from the flux-weighted
%                 % centroid
%                 x0(4) = targetStarStruct(target).rowCentroid(cadence);
%                 x0(5) = targetStarStruct(target).colCentroid(cadence);
% 
% %                 display(['x0      = ' num2str(x0)]);
%                 x = lsqnonlin(@gauss_fit, x0, [], [], options);

                gaussFitData.fluxFitData = pixval(:,cadence)/max(pixval(:,cadence));
                % x = [s, r0, c0];
                % estimate the width
                x0(1) = 0.7;
                % set the initial row and column from the flux-weighted
                % centroid
                if cadence == 1
                    x0(2) = targetStarStruct(target).rowCentroid(cadence);
                    x0(3) = targetStarStruct(target).colCentroid(cadence);
                else
                    x0(2) = targetStarStruct(target).gaussCentroidRow(cadence-1);
                    x0(3) = targetStarStruct(target).gaussCentroidColumn(cadence-1);
                end

%                 display(['x0      = ' num2str(x0)]);
                x = lsqnonlin(@gauss_fit, x0, [], [], options);
                targetStarStruct(target).gaussCentroidRow(cadence) = x(2);
                targetStarStruct(target).gaussCentroidColumn(cadence) = x(3);
%                 targetStarStruct(target).gaussCentroidRow(cadence) = x(4);
%                 targetStarStruct(target).gaussCentroidColumn(cadence) = x(5);
%                 display(['x after = ' num2str(x)]);
%                 display(['diff = ' num2str(x - x0)]);
%                 if cadence == 1
%                     display(['target ' num2str(target) ': x after = ' num2str(x)]);
%                     targetStarStruct(target).gaussWidth = x(1);
%                 end
            end
        end
    end

    % clear pixval just to be sure for the next loop
    clear pixval;
end