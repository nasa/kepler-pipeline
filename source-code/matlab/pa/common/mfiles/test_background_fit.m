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
close all;

load paTestData_run1000_700Cadences_nogaps backgroundStruct targetStarStruct;

backgroundConfigurationStruct = build_background_configuration_struct();

% replace gap values with zero
nPixels = length(backgroundStruct);
for pixel = 1:nPixels 
    gapList = backgroundStruct(pixel).gapList;
    backgroundStruct(pixel).timeSeries(gapList) = 0;    
end

cosmicRayConfigurationStruct = build_cr_configuration_struct();
% clean the background
tic;
backgroundStruct = clean_cosmic_ray_from_background( ...
    backgroundStruct, cosmicRayConfigurationStruct);
toc;

%%
% fit the background
tic;
backgroundCoeffStruct = fit_background_by_time_series(backgroundStruct, ...
    backgroundConfigurationStruct);
toc;

save backgroundCoeffStruct_run1000_700Cadences.mat backgroundCoeffStruct
%%
% test the fit on a few pixels
[rowMesh, colMesh] = meshgrid(1:50:1000, 1:50:1000);

tic;
[pixelValues, uncertainties] = evaluate_background(rowMesh(:), colMesh(:), ...
    backgroundCoeffStruct, backgroundConfigurationStruct);
toc;

% display some statistics
m = mean(pixelValues, 2);
display(['mean of background: ' num2str(mean(m))]);
display(['range of mean background: ' ...
    num2str(min(m)) ' to ' num2str(max(m))]);

sd = std(pixelValues, 0, 2);
display(['mean of background standard deviation: ' num2str(mean(sd))]);
display(['median of background standard deviation: ' num2str(median(sd))]);
display(['range of background standard deviation: ' ...
    num2str(min(sd)) ' to ' num2str(max(sd))]);

%%
nTargets = length(targetStarStruct);
for target = 1:nTargets
    nPixels = length(targetStarStruct(target).pixelTimeSeriesStruct);
    for pixel = 1:nPixels 
        gapList = targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList;
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(gapList) = 0;    
    end
end
%%
tic;
bgRemovedStarStruct = remove_background_from_targets(targetStarStruct, ...
    backgroundCoeffStruct, backgroundConfigurationStruct);
toc;

%%
nCadences = length(backgroundCoeffStruct);
maxBackground = max(max(pixelValues));
minBackground = min(min(pixelValues));
bgrow = [backgroundStruct.row];
bgcol = [backgroundStruct.column];

n = length(backgroundStruct);
figure;
for cadence = 1:nCadences
    for i=1:n 
        bgval(i) = backgroundStruct(i).timeSeries(cadence); 
    end
    background = reshape(pixelValues(:,cadence), size(rowMesh));
    mesh(rowMesh, colMesh, background);
    hold on;
    scatter3(bgrow(1:10:n), bgcol(1:10:n), bgval(1:10:n));
    
    axis([0 1100 0 1100 min(bgval(1:10:n)) max(bgval(1:10:n))]);
    hold off;
    drawnow;
end
