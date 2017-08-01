function plot_dawg_background_metrics( Z )


% ~~~~~~~~~~~~~~~~~~~~ % produce some summary plots
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

MADS_TO_PLOT = 10;
MADS_TO_COLOR = 7;
ALL_CHANNELS = 1:84;
NUM_CHANNELS = length(ALL_CHANNELS);

% find valid channel indices - only channels in channelList are populated in output structure Z
mod = [Z.module];
out = [Z.output];
validIndices = find( ismember(mod,[2:4,6:20,22:24]) & ismember(out,1:4) );

% valid channel numbers
channel = convert_from_module_output(mod(validIndices),out(validIndices));

cadences = Z(validIndices(1)).cadences(:);
nCadences = length(cadences);

[sortedChannel, idxSortedChannel] = sort(channel);

CAD = repmat(cadences,1,NUM_CHANNELS);
CHAN = repmat(ALL_CHANNELS(:)',nCadences,1);

% initialize data arrays
nOutliers       = nan(nCadences,NUM_CHANNELS);
meanValue       = nan(nCadences,NUM_CHANNELS);
madResidual     = nan(nCadences,NUM_CHANNELS);
medianResidual  = nan(nCadences,NUM_CHANNELS);
madPixelUnc     = nan(nCadences,NUM_CHANNELS);
medianPixelUnc  = nan(nCadences,NUM_CHANNELS);
gaps            = true(nCadences,NUM_CHANNELS);

% get data from output fields
nOutliers(:,channel)        = [Z(validIndices).extremeOutlierCount];
meanValue(:,channel)        = [Z(validIndices).meanFittedValue];
madResidual(:,channel)      = [Z(validIndices).madNormalizedResidual];
medianResidual(:,channel)   = [Z(validIndices).medianNormalizedResidual];
madPixelUnc(:,channel)      = [Z(validIndices).madNormalizedPixelUncertainty];
medianPixelUnc(:,channel)   = [Z(validIndices).medianNormalizedPixelUncertainty];
gaps(:,channel)             = [Z(validIndices).gapIndicators];

% set gaps to NaN for plotting
nOutliers(gaps)         = NaN;
meanValue(gaps)         = NaN;
madResidual(gaps)       = NaN;
medianResidual(gaps)    = NaN;
madPixelUnc(gaps)       = NaN;
medianPixelUnc(gaps)    = NaN;

% plot extreme outlier metric
figure;
plot3(CAD(:),CHAN(:),nOutliers(:),'.','MarkerSize',1);
grid;
xlabel('cadence');
ylabel('channel');
zlabel('extreme outlier count');
title('50 MAD Outliers in Background Pixels');

figure;
plot(ALL_CHANNELS,nanmedian(nOutliers),'o');
grid;
xlabel('channel');
title('50 MAD Outliers in Background Pixels');

% plot mean value metric
figure;
mesh(ALL_CHANNELS,cadences,meanValue);
xlabel('channel');
ylabel('cadence');
zlabel('mean value (e-)');
title('Mean Fitted Background');

figure;
plot(Z(validIndices(1)).cadences,meanValue);
grid;
xlabel('cadences');
ylabel('mean value (e-)');
title('Mean Fitted Background');

% plot residual metrics
figure;
mesh(ALL_CHANNELS,cadences,madResidual);
aa = axis;
medianData = nanmean(nanmean(madResidual));
madData = mad(nanmean(madResidual));
axis([aa(1:4), medianData - MADS_TO_PLOT*madData, medianData + MADS_TO_PLOT*madData]);
caxis([medianData - MADS_TO_COLOR*madData, medianData + MADS_TO_COLOR*madData]);
xlabel('channel');
ylabel('cadence');
zlabel('mad residual (sigma)');
title('Mad Background Residual');


figure;
plot(ALL_CHANNELS,nanmedian(madResidual),'o');
grid;
xlabel('channel');
ylabel('mad residual (sigma)');
title('Mad Background Residual');

figure;
mesh(ALL_CHANNELS,cadences,medianResidual);
aa = axis;
medianData = nanmean(nanmean(medianResidual));
madData = mad(nanmean(medianResidual));
axis([aa(1:4), medianData - MADS_TO_PLOT*madData, medianData + MADS_TO_PLOT*madData]);
caxis([medianData - MADS_TO_COLOR*madData, medianData + MADS_TO_COLOR*madData]);
xlabel('channel');
ylabel('cadence');
zlabel('median residual (sigma)');
title('Median Background Residual');


figure;
plot(ALL_CHANNELS,nanmedian(medianResidual),'o');
grid;
xlabel('channel');
ylabel('median residual (sigma)');
title('Median Background Residual');
            
% plot pixel uncertainty metrics
figure;
mesh(ALL_CHANNELS,cadences,madPixelUnc);
aa = axis;
medianData = nanmean(nanmean(madPixelUnc));
madData = mad(nanmean(madPixelUnc));
axis([aa(1:4), medianData - MADS_TO_PLOT*madData, medianData + MADS_TO_PLOT*madData]);
caxis([medianData - MADS_TO_COLOR*madData, medianData + MADS_TO_COLOR*madData]);
xlabel('channel');
ylabel('cadence');
zlabel('mad pixel uncertainty (sigma)');
title('MAD Background Pixel Uncertainty Normalized to Standard Deviation Over Cadences');


figure;
plot(ALL_CHANNELS,nanmedian(madPixelUnc),'o');
grid;
xlabel('channel');
ylabel('mad pixel uncertainty (sigma)');
title('MAD Background Pixel Uncertainty Normalized to Standard Deviation Over Cadences');

figure;
mesh(ALL_CHANNELS,cadences,medianPixelUnc);
aa = axis;
medianData = nanmean(nanmean(medianPixelUnc));
madData = mad(nanmean(medianPixelUnc));
axis([aa(1:4), medianData - MADS_TO_PLOT*madData, medianData + MADS_TO_PLOT*madData]);
caxis([medianData - MADS_TO_COLOR*madData, medianData + MADS_TO_COLOR*madData]);
xlabel('channel');
ylabel('cadence');
zlabel('median pixel uncertainty (sigma)');
title('Median Background Pixel Uncertainty Normalized to Standard Deviation Over Cadences');


figure;
plot(ALL_CHANNELS,nanmedian(medianPixelUnc),'o');
grid;
xlabel('channel');
ylabel('median pixel uncertainty (sigma)');
title('Median Background Pixel Uncertainty Normalized to Standard Deviation Over Cadences');

% some image plots

% mean fitted background - channels x cadence
figure;
imagesc(ALL_CHANNELS,cadences,meanValue);
axis xy;
colorbar;
apply_white_nan_colormap_to_image;
set(gca,'FontWeight','bold');
xlabel('\bf\fontsize{12}channel #');
ylabel('\bf\fontsize{12}cadence #');
title('\bf\fontsize{14}Fitted Mean Background Level (e-/LC)');

% mean fitted background w/median removed - channels x cadence
figure;
imagesc(ALL_CHANNELS,cadences,meanValue-ones(nCadences,1)*nanmedian(meanValue));
axis xy;
colorbar;
apply_white_nan_colormap_to_image;
set(gca,'FontWeight','bold');
xlabel('\bf\fontsize{12}channel #');
ylabel('\bf\fontsize{12}cadence #');
title('\bf\fontsize{14}Fitted Mean Background Level Delta From Median (e-/LC)');

% median background fit residual
figure;
imagesc(sortedChannel,cadences,medianResidual(:,idxSortedChannel));
colorbar;
caxis([-1 1]);
axis xy;
apply_white_nan_colormap_to_image;
set(gca,'FontWeight','bold');
xlabel('\bf\fontsize{12}channel #');
ylabel('\bf\fontsize{12}cadence #');
title('\bf\fontsize{14}Median Background Fit Residual (sigma)');

% mad background fit residual
figure;
imagesc(ALL_CHANNELS,cadences,madResidual);
caxis([0, prctile(madResidual(:),95)]);
colorbar;
axis xy;
apply_white_nan_colormap_to_image;
set(gca,'FontWeight','bold');
xlabel('\bf\fontsize{12}channel #');
ylabel('\bf\fontsize{12}cadence #');
title('\bf\fontsize{14}MAD Background Fit Residual (sigma)');
  