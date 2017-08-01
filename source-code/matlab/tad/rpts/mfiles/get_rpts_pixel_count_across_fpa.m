function rptsCountStruct = get_rpts_pixel_count_across_fpa(pathname)
%
% function to get reference pixel counts for all channels across focal
% plane.
%
% pathname      full path to RPTS outputs:
%   ex /path/to/ort4b-redo-rpts-trimmed
%
%
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


cd(pathname)

rptsRunDirs = dir([ pathname '/rpts-*']);

numberOfRuns = length(rptsRunDirs);

% allocate memory to collect target/pixel count information
rptsCountStruct = repmat(struct('countStruct', []), numberOfRuns, 1);

channelID                   = zeros(numberOfRuns, 1);
numPhotometricTargets       = zeros(numberOfRuns, 1);
aveNumPixelsPerPhotTarget   = zeros(numberOfRuns, 1);
numPhotometricPixels        = zeros(numberOfRuns, 1);
numCollateralPixels         = zeros(numberOfRuns, 1);
numExcessPhotometricPixelsTotal = zeros(numberOfRuns, 1);

%numPhotometricPixelsArray        = cell(numberOfRuns, 1);
%numExcessPhotometricPixelsArray  = cell(numberOfRuns, 1);


% begin figure to plot each target and excess pixels for all mod outs
figure

hWaitbar = waitbar(0,'Collecting target and pixel counts');

for i = 1:numberOfRuns

    dirString = rptsRunDirs(i).name;

    cd(dirString)

    load rpts-inputs-0.mat
    load rpts-outputs-0.mat

    % get target and pixel counts for this mod/out
    countStruct = get_num_rpts_output_pixels(inputsStruct, outputsStruct);

    rptsCountStruct(i).countStruct = countStruct;

    channelID(i)                 = countStruct.channel;

    % collect #photometric targets for for each channel
    numPhotometricTargets(i)     = countStruct.numTotalPhotometricTargets;

    % collect #pixels per photometric targets (averaged) for each channel
    aveNumPixelsPerPhotTarget(i) = countStruct.numTotalPhotometricPixels / countStruct.numTotalPhotometricTargets;

    % collect #total photometric pixels for each channel
    numPhotometricPixels(i)      = countStruct.numTotalPhotometricPixels;

    % collect #total collateral pixels for each channel
    numCollateralPixels(i)       = countStruct.numTotalCollateralPixels;

    % collect #total excess photometric pixels for each channel
    numExcessPhotometricPixelsTotal(i)  = countStruct.numExcessPhotometricPixelsTotal;

    % collect #photometric targets for for each target in channel
    numPhotometricPixelsArray  = countStruct.numPhotometricPixelsArray;

    numExcessPhotometricPixelsArray  = countStruct.numExcessPhotometricPixelsArray;

    channelArrayForPlot = repmat(channelID(i), numPhotometricTargets(i), 1);

    hold on
    h1 = plot(channelArrayForPlot, numPhotometricPixelsArray, 'r.');
    hold on
    h2 = plot(channelArrayForPlot, numExcessPhotometricPixelsArray, 'c.');


    disp(['Channel ' num2str(channelID(i)) ' [' num2str(countStruct.ccdModule) ', ' ...
        num2str(countStruct.ccdOutput) ']   #Phot Targets= ' num2str(numPhotometricTargets(i)) ...
        '   Ave #Pix/Target= ' num2str(round(aveNumPixelsPerPhotTarget(i))) '   #Phot Pixels= ' ...
        num2str(numPhotometricPixels(i)) '   #Excess Phot Pixels= ' num2str(numExcessPhotometricPixelsTotal(i)) ...
        ' #Coll Pixels= ' num2str(numCollateralPixels(i)) ]);

    cd('../')

    waitbar(i/numberOfRuns);
end
close(hWaitbar);


totPhotometricPixels = sum(numPhotometricPixels);
totCollateralPixels  = sum(numCollateralPixels);
totPixels            = totPhotometricPixels + totCollateralPixels;

totExcessPhotometricPixels = sum(numExcessPhotometricPixelsTotal);

%--------------------------------------------------------------------------
% plot # pixels and # excess pixels for each target over all mod/outs
%--------------------------------------------------------------------------

grid on
axis([-1 85 0 150])

legend([h1 h2], {'#pix in mask', '#excess pix'}, 'Location', 'Best');

title(['#Pix in Each Mask (sum = ' num2str(totPhotometricPixels) ') and #Excess Pix (sum = ' num2str(totExcessPhotometricPixels) ')'], 'fontsize', 10);
xlabel('CCD Channel', 'fontsize', 10);
ylabel('# Pixels', 'fontsize', 10);



fileNameStr = 'excess_pixels_count';
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);


%--------------------------------------------------------------------------
% plot
%--------------------------------------------------------------------------
figure
subplot(2, 2, 1)
plot(numPhotometricTargets, 'b.')
grid on

title('# Photometric Targets', 'fontsize', 10);
xlabel('CCD Channel', 'fontsize', 10);
ylabel('# Photometric Targets', 'fontsize', 10);

subplot(2, 2, 2)
plot(aveNumPixelsPerPhotTarget, 'r.')
grid on

title('Ave # Photometric Pixels Per Target', 'fontsize', 10);
xlabel('CCD Channel', 'fontsize', 10);
ylabel('# Pixels/Phot. Target', 'fontsize', 10);


subplot(2, 2, 3)
plot(numPhotometricPixels, 'c.')
grid on

title(['Total# of Photometric Pixels (sum = ' num2str(totPhotometricPixels) ')'], 'fontsize', 10);
xlabel('CCD Channel', 'fontsize', 10);
ylabel('# Phot. Pixels', 'fontsize', 10);


subplot(2, 2, 4)
plot(numCollateralPixels, 'm.')
grid on

title(['Total# of Collateral Pixels (sum = ' num2str(totCollateralPixels) ')'], 'fontsize', 10);
xlabel('CCD Channel', 'fontsize', 10);
ylabel('# Coll. Pixels', 'fontsize', 10);




fileNameStr = 'ref_pixel_and_target_count';
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);


return;



