function targetStarStruct = detrend_target(targetStarStruct, motionPolyStruct)
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
nTargets = length(targetStarStruct);

for target = 1:nTargets
    targetStruct = targetStarStruct(target);
    nPixels = length(targetStruct.pixelTimeSeriesStruct);
    nCadences = length(targetStruct.pixelTimeSeriesStruct(1).timeSeries);
    if ~isfield(targetStruct, 'flux')
        pixval = zeros(nPixels, nCadences);
        for pixel = 1:nPixels 
            pixval(pixel, :) = ...
                targetStruct.pixelTimeSeriesStruct(pixel).timeSeries;
        end
        targetStruct.flux = sum(pixval, 1); 
        clear pixval;
    end
    partition = partition_by_curvature(targetStruct.flux, 3, 5, 10);
    targetStarStruct(target).partition = partition;
    nPartitions = length(partition);
    
    for pixel = 1:nPixels
        pixelStruct = targetStruct.pixelTimeSeriesStruct(pixel);
        pixelSeries = pixelStruct.timeSeries;
        % get the row and column of this pixel
        row = pixelStruct.row;
        column = pixelStruct.column;
        for part = 1:nPartitions
            partitionRange = partition(part).start:partition(part).end;
            fitStruct = ...
                detrend_time_series(pixelSeries(partitionRange), ...
                row, column, motionPolyStruct(partitionRange));
            targetStarStruct(target).detrendFit(pixel).residual(partitionRange) = ...
                fitStruct.residual;
            targetStarStruct(target).detrendFit(pixel).trend(partitionRange) = ...
                fitStruct.trend;
        end
        
        if 1
            figure;
            subplot(4,1,1);
            plot(1:nCadences, pixelSeries, 1:nCadences, ...
                targetStarStruct(target).detrendFit(pixel).trend);
            subplot(4,1,2);
            plot(targetStarStruct(target).detrendFit(pixel).residual);
            [sd, average] = fast_local_standard_deviation( ...
                targetStarStruct(target).detrendFit(pixel).residual, 100);
            subplot(4,1,3);
            plot(sd);
            subplot(4,1,4);
            plot(average);
        end
    end
end