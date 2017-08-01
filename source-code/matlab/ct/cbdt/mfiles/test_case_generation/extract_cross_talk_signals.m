%%
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
MY_CODE_ROOT = '/path/to/code';
% load the cross talk pixel locations
load( fullfile(MY_CODE_ROOT, 'matlab/ct/cbdt/mfiles/@cbdBadPixelsClass/cross_talk_map.mat') );

% name of the FFI folder I want to extract the xtalk signals from
folderName = '/path/to/smb/lv00/data/photometer_test_data/ball_tests/PH0051_psf_cold_test/TVAC/08Mar14/';

% name of the FFI
fileName = 'ffi_200803140837_set_01_module_13.fits';

GOOD_PIXEL  = 4;
xtalkPixels = (xtalkImage ~= GOOD_PIXEL);
goodPixels  = (xtalkImage == GOOD_PIXEL);

% expand the bad pixel coverage as the xtalk locations provided are not
% precise
xtalkPixels(1, :) = 1;
xtalkPixels(end, :) = 1;
xtalkPixels(:, 1) = 1;
xtalkPixels(:, end) = 1;

xtalkPixels(2:end-1, 2:end-1) = xtalkPixels(2:end-1, 2:end-1) | ...
                                xtalkPixels(1:end-2, 2:end-1) | xtalkPixels(3:end, 2:end-1) | ...
                                xtalkPixels(2:end-1, 1:end-2) | xtalkPixels(2:end-1, 3:end) | ...
                                xtalkPixels(1:end-2, 1:end-2) | xtalkPixels(3:end, 3:end) | ...
                                xtalkPixels(1:end-2, 3:end)   | xtalkPixels(3:end, 1:end-2);
goodPixels = ~xtalkPixels;

figure(21), subplot(1, 2, 1), imagesc( xtalkImage ); colorbar; title('Bad pixel locations')
subplot(1, 2, 2), imagesc( xtalkPixels ); colorbar; title('Xtalk pixels');


%% This routine extracts the crosstalk signals from a given FFI
numCoadds = 275;


% read in 4 channels of coadd FFIs
FFIs = fitsread( strcat(folderName, fileName) );

[rows, cols, num] = size(FFIs);

imgSize = rows * cols;
% normalize coadd FFI
FFIs = FFIs / numCoadds;

xtalkSignals = zeros(rows, cols, num );


for k = 1:4
    tempFFI = FFIs(:, :, k);
    junk = sort( tempFFI(:) );

    % extract pixel value range for proper display
    minFFI = junk( uint32( 100 ) );
    maxFFI = junk( uint32( imgSize - 5 * cols ) );

    % throw away the outliers that fall outside the typical data range
    tempFFI( tempFFI > maxFFI ) = maxFFI;
    tempFFI( tempFFI < minFFI ) = minFFI;
    
    fprintf('FFI: %2d: pixel values range: [%f, %f], mid 96 percent values range [%f, %f]\n', ...
        k, junk(1), junk(imgSize), minFFI, maxFFI);
    figure(22), 
    subplot(2, 4, k), imagesc( tempFFI, [minFFI, maxFFI] ); colorbar; title( strcat('Raw FFIs from channel:', num2str(k, '%2d')) );
    subplot(2, 4, k + 4), plot( tempFFI(:, 500) ); title('Profile of column 500'); xlim([0, 1070]);
    
    % fit plane
    % remove the xtalk signals
    tempFFIClean = tempFFI .* goodPixels;
    
    tempFFIClean( tempFFIClean == 0) = minFFI;
       
    tempFFIMedian = mean( tempFFI(:) );    
    
    usePlaneEstimation = true;
    %usePlaneEstimation = false;   
    if ( usePlaneEstimation )
        % extract the tilted plane first
        %%
        poly2DOrder = 1;
        xx = repmat( [1:cols], rows, 1);
        yy = repmat( [1:rows]', 1, cols);
        planeFitStruct = robust_polyfit2D(xx(:), yy(:), tempFFIClean(:), goodPixels(:), poly2DOrder);
        planeVal = weighted_polyval2D(xx(:), yy(:), planeFitStruct);
        planeVal = reshape( planeVal(:), rows, cols);
        
        xtalkSignals(:, :, k) = ( tempFFI - planeVal ) .* xtalkPixels;
        
        figure(51), subplot(1, 4, k), imagesc(planeVal, [minFFI, maxFFI]); colorbar; title( strcat('Ambient black from channel:', num2str(k, '%2d')) );
        %%
    else
        % simple subtraction bythe mean.
        xtalkSignals(:, :, k) = ( tempFFI - tempFFIMedian ) .* xtalkPixels;
    end
    
    figure(23), subplot(2, 4, k), imagesc( xtalkSignals(:, :, k), [minFFI, maxFFI ] - tempFFIMedian ); colorbar; title('Xtalk signals');
    subplot(2, 4, k + 4), plot( xtalkSignals(:, 500, k) ); title('Profile of column 500'); xlim([0, 1070]);
    
    figure(50),
    subplot(2, 4, k), imagesc( tempFFIClean, [minFFI, maxFFI] ); colorbar; title( strcat('Cleaned FFIs from channel:', num2str(k, '%2d')) );
    subplot(2, 4, k + 4), plot( tempFFIClean(:, 500) ); title('Profile of column 500'); xlim([0, 1070]);
end

% should take the mean?
xtalkSignalsOne = mean(xtalkSignals, 3);

% extract pixel value range for proper display
junk = sort( xtalkSignalsOne(:) );
minXtalk = junk( uint32( 5 ) );
maxXtalk = junk( uint32( imgSize - 5 * cols ) );
figure(24), subplot(1, 2, 1), imagesc( xtalkSignalsOne, [minXtalk, maxXtalk] ); colorbar; title('Mean crosstalk signals');
subplot(1, 2, 2), plot( xtalkSignalsOne(:, 500) ); title('Profile of column 500'); xlim([0, 1070]);

save 'xtalk_signals.mat' xtalkSignals
