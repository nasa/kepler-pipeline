% plot_centroid_discrepancy_on_focal_plane.m
% pdqOutputStruct.attitudeSolutionUncertaintyStruct(2)
% ans =
%             raStars: [316x1 double]
%            decStars: [316x1 double]
%          keplerMags: [316x1 double]
%           keplerIds: [316x1 double]
%        centroidRows: [316x1 double]
%     centroidColumns: [316x1 double]
%        CcentroidRow: [316x316 double]
%     CcentroidColumn: [316x316 double]
%           ccdModule: [316x1 double]
%           ccdOutput: [316x1 double]
%     nominalPointing: [290.673595638672 44.4982126098107 -0.00392402752362685]
%         cadenceTime: 55002.0276921977
%     CdeltaAttitudes: [3x3 double]
%       robustWeights: [600x1 double]
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

function [zCentroids, yCentroids, zStars,  yStars,  movieCentroidDiscrepancy] = ...
    plot_centroid_discrepancy_on_focal_plane(pdqOutputStruct, raDec2PixObject)


%--------------------------------------------------------------------------
% collect data
%--------------------------------------------------------------------------
close all;
clc;

nCadences = length(pdqOutputStruct.outputPdqTsData.cadenceTimes) ;
nStars =  length(pdqOutputStruct.attitudeSolutionUncertaintyStruct(end).raStars);

zCentroids = nan(nStars, nCadences);
yCentroids = nan(nStars, nCadences);
zStars = nan(nStars, nCadences);
yStars = nan(nStars, nCadences);

initArray  = nan(nStars,1);
centroidBiasStruct = repmat(struct('module', initArray,'output',initArray, ...
    'centroidRows',initArray, 'centroidColumns', initArray,'starRows', initArray, 'starColumns', initArray,...
    'rowBias', initArray, 'columnBias', initArray), nCadences,1);


for cadenceIndex = 1:nCadences

    raStars = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).raStars;

    decStars = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).decStars;

    cadenceTimeStampMjd = pdqOutputStruct.outputPdqTsData.cadenceTimes(cadenceIndex);


    attitudeSolutionRa = pdqOutputStruct.attitudeSolution(cadenceIndex,1);
    attitudeSolutionDec = pdqOutputStruct.attitudeSolution(cadenceIndex,2);
    attitudeSolutionRoll = pdqOutputStruct.attitudeSolution(cadenceIndex,3);

    % get mod, out, row, col of target stars using the newly computed attitude
    % solution for each ceadence
    aberrateFlag =1;
    [module, output, rows, columns] = ra_dec_2_pix_absolute( raDec2PixObject, raStars, decStars, cadenceTimeStampMjd, ...
        attitudeSolutionRa, attitudeSolutionDec, attitudeSolutionRoll, aberrateFlag);

    % Convert (mod, out, row, col) to focal plane coordinates

    ccdModule = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).ccdModule;
    ccdOutput = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).ccdOutput;
    centroidRows = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).centroidRows;
    centroidColumns = pdqOutputStruct.attitudeSolutionUncertaintyStruct(cadenceIndex).centroidColumns;

    validIndex = find(centroidColumns  ~= -1);

    centroidBiasStruct(cadenceIndex).module = ccdModule;
    centroidBiasStruct(cadenceIndex).output = ccdOutput;
    centroidBiasStruct(cadenceIndex).centroidRows(validIndex) = centroidRows(validIndex);
    centroidBiasStruct(cadenceIndex).centroidColumns(validIndex) = centroidColumns(validIndex);

    centroidBiasStruct(cadenceIndex).starRows(validIndex)  = rows(validIndex) ;
    centroidBiasStruct(cadenceIndex).starColumns(validIndex)  = columns(validIndex) ;
    centroidBiasStruct(cadenceIndex).rowBias(validIndex) = centroidRows(validIndex)  - rows(validIndex) ;
    centroidBiasStruct(cadenceIndex).columnBias(validIndex) = centroidColumns(validIndex)  - columns(validIndex) ;


    [zCentroidsTemp,   yCentroidsTemp]  = morc_to_focal_plane_coords(ccdModule(validIndex), ccdOutput(validIndex), centroidRows(validIndex), centroidColumns(validIndex),   'one-based');
    [zStarsTemp, yStarsTemp]  = morc_to_focal_plane_coords(module(validIndex), output(validIndex), rows(validIndex), columns(validIndex), 'one-based');


    zCentroids(validIndex, cadenceIndex) = zCentroidsTemp;
    yCentroids(validIndex, cadenceIndex) = yCentroidsTemp;

    zStars(validIndex, cadenceIndex) = zStarsTemp;
    yStars(validIndex, cadenceIndex) = yStarsTemp;

end

paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;



%--------------------------------------------------------------------------
% plot centroid motion of each star from first cadence
%--------------------------------------------------------------------------

figure
subplot(2,1,1);

for j=1:nStars

    plot(zCentroids(j,:) - zCentroids(j,1),   yCentroids(j,:) -  yCentroids(j,1), '.-', 'color', 'b', 'MarkerSize', 12); % last parametr 0 is to turn autoscale off
    hold on;
end

subplot(2,1,2);

for j=1:nStars

    hold on;
    plot(zStars(j,:) - zStars(j,1),   yStars(j,:) - yStars(j,1),'.-', 'color', 'r', 'MarkerSize', 12); % last parametr 0 is to turn autoscale off

end

fileNameStr = 'centroid_motion_relative_to_first_cadence_across_the_focal_plane';

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

%--------------------------------------------------------------------------
% Plot differences of centroid positions in entire focal plane from nominal pointing attitude and attitude solution
%--------------------------------------------------------------------------
currentScreenSize = get(0,'ScreenSize');
figure('Position',[1 1 min(currentScreenSize(3), currentScreenSize(4)) min(currentScreenSize(3), currentScreenSize(4))]);
for cadenceIndex = 1:nCadences


    %     pad_draw_ccd(1:42);
    %     hold on;
    %     pad_draw_ccd(1:42);

    deltaZcentroids = zCentroids(:,cadenceIndex);
    deltaYcentroids  = yCentroids(:,cadenceIndex);

    deltaZstar = zStars(:,cadenceIndex);
    deltaYstar = yStars(:,cadenceIndex);

    quiver(zCentroids(:,cadenceIndex),   yCentroids(:,cadenceIndex), (deltaZcentroids - deltaZstar)*1000, (deltaYcentroids - deltaYstar)*1000,  0); % last parametr 0 is to turn autoscale off

    hold on;
end


hold on;

%     hold off;
%     title({'(Centroids - Positions of ra, dec of stars) on the focal plane using computed attitude solution';[ 'for cadence ' num2str(cadenceIndex) ', 1 unit of x/y axis = 1000 milli pixels']});
%     xlabel('Axis +Z (FPA coordinates)');
%     ylabel('Axis +Y (FPA coordinates)');
%
%     movieCentroidDiscrepancy0(cadenceIndex) = getframe(h, [1 1 min(currentScreenSize(3), currentScreenSize(4)) min(currentScreenSize(3), currentScreenSize(4))]);
%
%
%     paperOrientationFlag = false;
%     includeTimeFlag = false;
%     printJpgFlag = false;
%
%     fileNameStr = ['centroid_discrepancy_map_across_the_focal_plane_for_cadence_' num2str(cadenceIndex) ];
%
%     plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
%
%     close all;
%     hold off;

title({'(Centroids - Positions of ra, dec of stars) on the focal plane using computed attitude solution';[ 'for cadence ' num2str(cadenceIndex) ', 1 unit of x/y axis = 1000 milli pixels']});
xlabel('Axis +Z (FPA coordinates)');
ylabel('Axis +Y (FPA coordinates)');

paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

fileNameStr = ['centroid_discrepancy_map_across_the_focal_plane'];

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
%%

%--------------------------------------------------------------------------
% Plot median (across all the stars on the focal plane)  motion of bias
% removed centroids / stars on the focal plane
%--------------------------------------------------------------------------


meanRemovedZcentroids = zCentroids - repmat(mean(zCentroids,2),1, nCadences);

meanRemovedYcentroids = yCentroids - repmat(mean(yCentroids,2),1, nCadences);


meanRemovedZstars =  zStars - repmat(mean(zStars,2),1, nCadences);

meanRemovedYstars = yStars - repmat(mean(yStars,2),1, nCadences);

idx = find(~isnan(meanRemovedZcentroids(:,1)));
hold on;


plot(median(meanRemovedZcentroids(idx,:) - repmat(meanRemovedZcentroids(idx,1),1, nCadences)),'b.-');
hold on;
plot(median(meanRemovedYcentroids(idx,:) - repmat(meanRemovedYcentroids(idx,1),1, nCadences)),'bp-');

plot(median(meanRemovedZstars(idx,:) - repmat(meanRemovedZstars(idx,1), 1, nCadences)),'r.-');
plot(    median(meanRemovedYstars(idx,:) - repmat(meanRemovedYstars(idx,1), 1, nCadences)) , 'rp-');

% plot(median(meanRemovedZcentroids(idx,:) - repmat(meanRemovedZcentroids(idx,1),1, nCadences)),...
%     median(meanRemovedYcentroids(idx,:) - repmat(meanRemovedYcentroids(idx,1),1, nCadences)) , 'b.-');
% hold on;
% plot(median(meanRemovedZstars(idx,:) - repmat(meanRemovedZstars(idx,1), 1, nCadences)),...
%     median(meanRemovedYstars(idx,:) - repmat(meanRemovedYstars(idx,1), 1, nCadences)) , 'r.-');
%
%
%%

%--------------------------------------------------------------------------
% Plot motion of bias removed centroids / stars on the focal plane
%--------------------------------------------------------------------------


currentScreenSize = get(0,'ScreenSize');
h = figure('Position',[1 1 min(currentScreenSize(3), currentScreenSize(4)) min(currentScreenSize(3), currentScreenSize(4))]);


for cadenceIndex = 1:nCadences

    % Plot differences of centroid positions in entire focal plane from nominal pointing attitude and attitude solution
    %     currentScreenSize = get(0,'ScreenSize');
    %     h = figure('Position',[1 1 min(currentScreenSize(3), currentScreenSize(4)) min(currentScreenSize(3), currentScreenSize(4))]);

    %     pad_draw_ccd(1:42);
    %     hold on;
    %pad_draw_ccd(1:42);

    deltaZcentroids = zCentroids(:,cadenceIndex) - mean(zCentroids, 2);
    deltaYcentroids  = yCentroids(:,cadenceIndex) - mean(yCentroids, 2);

    deltaZstar = zStars(:,cadenceIndex) - mean(zStars, 2);
    deltaYstar = yStars(:,cadenceIndex) - mean(yStars,2);

    %quiver(zCentroids(:,cadenceIndex),   yCentroids(:,cadenceIndex), (deltaZcentroids - deltaZstar)*1000, (deltaYcentroids - deltaYstar)*1000,  0); % last parametr 0 is to turn autoscale off
    h1 = quiver(zCentroids(:,cadenceIndex),   yCentroids(:,cadenceIndex), (deltaZcentroids)*1000, (deltaYcentroids )*1000,  0, 'b'); % last parameter 0 is to turn autoscale off
    hold on;
    h2 = quiver(zCentroids(:,cadenceIndex),   yCentroids(:,cadenceIndex), (deltaZstar)*1000, ( deltaYstar)*1000,  0, 'r'); % last parameter 0 is to turn autoscale off

    %     hold off;
    %     title({'(Mean removed centroids - Mean removed positions of ra, dec of stars) on the focal plane using computed attitude solution';[ 'for cadence ' num2str(cadenceIndex) ', 1 unit of x/y axis = 1000 milli pixels']});
    %     xlabel('Axis +Z (FPA coordinates)');
    %     ylabel('Axis +Y (FPA coordinates)');
    %
    %     movieCentroidDiscrepancy(cadenceIndex) = getframe(h, [1 1 min(currentScreenSize(3), currentScreenSize(4)) min(currentScreenSize(3), currentScreenSize(4))]);
    %
    %
    %     paperOrientationFlag = false;
    %     includeTimeFlag = false;
    %     printJpgFlag = false;
    %
    %     fileNameStr = ['mean_removed_centroid_discrepancy_map_across_the_focal_plane_for_cadence_' num2str(cadenceIndex) ];
    %
    %     plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    %
    %     close all;
    %
end

title({'(Mean removed centroids - Mean removed positions of ra, dec of stars) on the focal plane using computed attitude solution';[ 'for cadence ' num2str(cadenceIndex) ', 1 unit of x/y axis = 1000 milli pixels']});
xlabel('Axis +Z (FPA coordinates)');
ylabel('Axis +Y (FPA coordinates)');

movieCentroidDiscrepancy(cadenceIndex) = getframe(h, [1 1 min(currentScreenSize(3), currentScreenSize(4)) min(currentScreenSize(3), currentScreenSize(4))]);


paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

fileNameStr = ['mean_removed_centroid_discrepancy_map_across_the_focal_plane' ];

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


%------------------------------------------------------------------------
% last plot for KAR-503
% Quiver plot of bias removed centroids / stars on the focal plane
%--------------------------------------------------------------------------


deltaZcentroids = zCentroids(:,nCadences) - zCentroids(:,1) ;
deltaYcentroids  = yCentroids(:,nCadences) - yCentroids(:,1);
deltaZstar = zStars(:,nCadences) - zStars(:,1) ;
deltaYstar = yStars(:,nCadences) - yStars(:,1) ;

h1 = quiver(zCentroids(:,cadenceIndex),   yCentroids(:,cadenceIndex), deltaZcentroids*1000, deltaYcentroids*1000,  0, 'b'); % last parametr 0 is to turn autoscale off
hold on;
h2 = quiver(zCentroids(:,cadenceIndex),   yCentroids(:,cadenceIndex), deltaZstar*1000, deltaYstar*1000,  0, 'r'); % last parametr 0 is to turn autoscale off

legend([h1 h2], {'Mean centroid motion'; 'Mean star motion'});
title({'(Mean removed centroids - Mean removed positions of ra, dec of stars) on the focal plane using computed attitude solution';[ 'for cadence ' num2str(cadenceIndex) ', 1 unit of x/y axis = 1000 milli pixels']});
xlabel('Axis +Z (FPA coordinates)');
ylabel('Axis +Y (FPA coordinates)');

paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

fileNameStr = ['mean_removed_centroid_discrepancy_map_across_the_focal_plane' ];

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


%------------------------------------------------------------------------
% To demonstrate that the centroid row/column estimates contain strong
% systematic components
% SVD of row/column bias and plots of systematic removed centroid residuals
% agree with the estimated uncertainties
%--------------------------------------------------------------------------

plot([centroidBiasStruct.rowBias],'.-')
xlabel('Index of PDQ target stars ');
ylabel('Centroid row bias in pixels');
title('PDQ target stars: Centroid row resdidual for Quarter 1 reference pixels set')

paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

fileNameStr = ['centroid_row_residuals_of_PDQ_targets_across_the_focal_plane'];

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


plot([centroidBiasStruct.columnBias],'.-')
xlabel('Index of PDQ target stars ');
ylabel('Centroid column bias in pixels');
title('PDQ target stars: Centroid column resdidual for Quarter 1 reference pixels set')

paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

fileNameStr = ['centroid_column_residuals_of_PDQ_targets_across_the_focal_plane'];

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


%------------------------------------------------------------
%%
close all;
madThresholdForCentroidOutliers =5;
attitudeSolutionStruct = pdqOutputStruct.attitudeSolutionUncertaintyStruct;
nCadences = length(attitudeSolutionStruct);

for cadenceIndex = 1:nCadences
    centroidRows     = attitudeSolutionStruct(cadenceIndex).centroidRows;
    centroidColumns  = attitudeSolutionStruct(cadenceIndex).centroidColumns;

    CcentroidColumn = attitudeSolutionStruct(cadenceIndex).CcentroidColumn;
    CcentroidRow = attitudeSolutionStruct(cadenceIndex).CcentroidRow;


    % if any of the centroidRows or centroidColumns are -ve, remove them and
    % remove corresponding rows and columns form  covariance matrix too
    centroidColumnUncertainties = sqrt(diag(CcentroidColumn));
    centroidRowUncertainties = sqrt(diag(CcentroidRow));
    keplerMags = attitudeSolutionStruct(cadenceIndex).keplerMags;
    centroidGapIndicators = false(length(keplerMags), 1);

    invalidRows = find(centroidRows <= 0);
    invalidColumns = find(centroidColumns <= 0);

    invalidEntries = [invalidRows; invalidColumns];
    invalidEntries = invalidEntries(:);

    centroidGapIndicators(invalidEntries) = true;

    [outOfFamilyIndicators] = ...
        identify_out_of_family_centroids(keplerMags, centroidRowUncertainties, ...
        centroidColumnUncertainties, centroidGapIndicators, madThresholdForCentroidOutliers);


    %outOfFamilyIndicators = centroidGapIndicators;

    invalidEntriesNow = find(outOfFamilyIndicators);

    rowResidual = centroidBiasStruct(cadenceIndex).rowBias;

    rowResidual(invalidEntriesNow) = nan;
    centroidBiasStruct(cadenceIndex).rowBias = rowResidual;

    columnResidual = centroidBiasStruct(cadenceIndex).columnBias;

    columnResidual(invalidEntriesNow) = nan;
    centroidBiasStruct(cadenceIndex).columnBias = columnResidual;

end




%%
close all;

rowResidual = [centroidBiasStruct.rowBias];
columnResidual = [centroidBiasStruct.columnBias];

%find entire rows set to nan

rowIndex = find(isnan(rowResidual(:,1)));

rowResidual(rowIndex, :) = [];
columnResidual(rowIndex, :) = [];

idx = find(isnan(rowResidual));

rowResidual(idx) = 0;

idx = find(isnan(columnResidual));

columnResidual(idx) = 0;

nSvdOrder = 6;
[Ur, Sr, Vr] = svd(rowResidual',0);
figure;
plot(rowResidual' - Ur(:, 1:nSvdOrder)*Ur(:, 1:nSvdOrder)' * rowResidual' )
figure;

plot(Ur(:, 1:nSvdOrder)*Ur(:, 1:nSvdOrder)' * rowResidual' );

[Uc, Sc, Vc] = svd(columnResidual',0);
figure
plot(columnResidual' - Uc(:, 1:nSvdOrder)*Uc(:, 1:nSvdOrder)' * columnResidual' )
%%

%save centroidBiasPDQ.mat zCentroids yCentroids zStars  yStars pdqOutputStruct raDec2PixObject movieCentroidDiscrepancy movieCentroidDiscrepancy0;
save centroidBiasPDQ.mat zCentroids yCentroids zStars  yStars pdqOutputStruct raDec2PixObject  centroidBiasStruct;

% load centroidBiasPDQ.mat
% currentScreenSize = get(0,'ScreenSize');
% h = figure('Position',[1 1 min(currentScreenSize(3), currentScreenSize(4)) min(currentScreenSize(3), currentScreenSize(4))]);
% movie(h, movieCentroidDiscrepancy, [1, 1:35], 2)
