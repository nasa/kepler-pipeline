%% test the new 2D black algorithm
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
close all;

constants;

%%
load('darkFFIs.mat', 'darkFFIs');       % get variable: darkFFIs

load('fgs.mat', 'fgs_map');            % get variable: fgs_map


%%twoDBlackMeanImage
[drow, dcol] = size( fgs_map );

% add the injection region to FGS mask
fgs_map(SMEAR_INJECTION_ROWS, SMEAR_INJECTION_COLS) = 1;

% compute 2D black & xtalk combo mean and std via running mean and std algorithms
[meanFFI, stdFFI] = running_mean_std(darkFFIs);

figure, imagesc(meanFFI, [702, 714]); colorbar; title('meanFFI');
figure, imagesc(stdFFI, [0, 0.25]); colorbar; title('stdFFI');

%% use (max - min) difference to check the outlier candidates
darkFFIMax = max( darkFFIs, [], 3 );
darkFFIMin = min( darkFFIs, [], 3 );

modelStd = 0.5;
darkOutlierMask = ( darkFFIMax - darkFFIMin ) > 2 * modelStd;
figure, imagesc( darkOutlierMask ); colorbar; title('Temporal outliers');

% number of outlier candidates
sumOutlierTotal = sum( darkOutlierMask(:) );

% locate these outliers: should be few, not many!
[outlierY, outlierX] = find( darkOutlierMask > 0 );

meanFFINew = meanFFI;
stdFFINew = stdFFI;
% replace the contaminated mean and std estimates
if ( sumOutlierTotal == length(outlierY) )
    for k=1:sumOutlierTotal
        dat = darkFFIs( outlierY(k), outlierX(k), : );
        [meanNew, stdNew] = robust_mean( dat(:), modelStd);

        meanFFINew(outlierY(k), outlierX(k)) = meanNew;
        stdFFINew(outlierY(k), outlierX(k)) = stdNew;
    end
    
figure, imagesc(meanFFINew, [702, 714]); colorbar; title('temporal smoothed meanFFI');
figure, imagesc(stdFFINew, [0, 0.25]); colorbar; title('temporal smoothed stdFFI');

end

%% dilate xtalk_mask horizontally to cover the extended end pixels
[fgs_mask_expanded] = moving_weighted_mean(fgs_map, 1, [1, 1]);

figure, imagesc(fgs_mask_expanded); colorbar; title('extended FGS mask');

xtalk_weight = 10^16;

% Produce the map of weights with FGS xtalk pixels having small weights
black_pixel_weights = 1./ (fgs_mask_expanded * xtalk_weight + 1.0);

figure, imagesc(black_pixel_weights); colorbar;
title('extended FGS weights');

%% spatial outlier detection

[imgMean] = img_median( meanFFINew, fgs_mask_expanded, [9, 5]);

figure, imagesc(imgMean, [702, 714]); colorbar; title('post-spatial smoothed meanFFI');

%% This should have taken care of the bad pixels covered in the mask
twoDBlackMeanImage = moving_weighted_mean(meanFFI, black_pixel_weights, [9, 4]);

figure, imagesc(twoDBlackMeanImage, [704, 712]); colorbar;
title('smoothed 2D Black');

% get the true 2D Black statistics, i.e. without FGS xtalk signals
%regionStatsStruct = get_pixels_statistics(twoDBlackMeanImage, 1, true);

% reconstruct the 2D black with smoothed FGS signals. 
% Note: expanded FGS mask is used
fgs_mask_expanded(SMEAR_INJECTION_ROW_START:SMEAR_INJECTION_ROW_END, ...
    SMEAR_INJECTION_COL_START:SMEAR_INJECTION_COL_END) = 0;
twoDBlackXtalkMeanImage = twoDBlackMeanImage .* (fgs_mask_expanded <= 0.0) + (fgs_mask_expanded > 0.0) .* meanFFI;

figure, imagesc(twoDBlackXtalkMeanImage, [704, 712]); colorbar;
title('smoothed 2D Black + Xtalk signals');

pause;

%%

% display row/col profiles for validation
for row = 10:10:drow
    figure(88),plot(1:dcol, twoDBlackMeanImage(row, :) + 5, '-r', 1:dcol, meanFFI(row, :) + 3, '-g');
    axis([0, dcol, 710, 730]);
    title( ['profile comparison: row/col =' num2str(row)]);
    hold on;
    
    col = row;
    plot(1:drow, twoDBlackMeanImage(:, col) - 3, '-r',1:drow, meanFFI(:, col) - 5, '-g');
    axis([0, dcol, 710, 730]);
    hold off;
    pause(1);
end
