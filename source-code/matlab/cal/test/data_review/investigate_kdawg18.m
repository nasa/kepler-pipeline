function investigate_kdawg18(channelString)
%
% function to collect background pixels for each invocation to investigate
% the background chatter problem explained in KDAWG-18
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


if strcmpi(channelString, '19')

    dataDir = '/path/to/flight/i1757/cal-matlab-1757-71685/';
    backgroundPixCoordinatesFilename = '/path/to/matlab/cal/data/bkg.pixel.coordinates.7.3.11914.13379.mat';


elseif strcmpi(channelString, '46')

    dataDir = '/path/to/flight/i1757/cal-matlab-1757-71712/';
    backgroundPixCoordinatesFilename = '/path/to/matlab/cal/data/bkg.pixel.coordinates.14.2.11914.13379.mat';
end


% load bgPixelCoord: nPixels x 2 ([rows(:) cols(:)])
load(backgroundPixCoordinatesFilename)
nBackgroundPixels = length(bgPixelCoord);

cd(dataDir)

invocations = dir('cal-inputs*');
numInvocations = length(invocations);

% loop through invocations and collect (1) background pixel indices, (2) input
% background pixels, and (3) output background pixels.  Indices can be used
% to trace through individual invocations to investigate where chatter is
% introduced


for i = 1:numInvocations-1

    eval(['load cal-outputs-' num2str(i) '.mat'])

    pixels = [outputsStruct.targetAndBackgroundPixels.values]';
    gaps = [outputsStruct.targetAndBackgroundPixels.gapIndicators]';
    rows = [outputsStruct.targetAndBackgroundPixels.row] + 1;
    cols = [outputsStruct.targetAndBackgroundPixels.column] + 1;


    pixelCoord = [rows(:) cols(:)];

    % collect background pixel indices
    bgPixelIdx = [];

    for j = 1:nBackgroundPixels

        bgRowCol = bgPixelCoord(j, :);

        isBgPixel = ismember(pixelCoord, bgRowCol, 'rows');

        if any(isBgPixel)

            newBgIdx = find(isBgPixel);

            % collect background indicators into an array
            bgPixelIdx = [bgPixelIdx; newBgIdx];
        end
    end

    bgOutputPixels = pixels(bgPixelIdx, :); %#ok<NASGU>
    bgOutputGaps   = gaps(bgPixelIdx, :); %#ok<NASGU>


    eval(['save /path/to/matlab/cal/mfiles/run_cal_here/test/bg_output_pixels_ch' channelString '_invoc' num2str(i) '.mat  bgOutputPixels bgOutputGaps bgPixelIdx'])
end


for i = 1:numInvocations-1

    eval(['load cal-inputs-' num2str(i) '.mat'])

    pixels = [inputsStruct.targetAndBkgPixels.values]';
    gaps = [inputsStruct.targetAndBkgPixels.gapIndicators]';
    rows = [inputsStruct.targetAndBkgPixels.row]+1;
    cols = [inputsStruct.targetAndBkgPixels.column]+1;

    pixelCoord = [rows(:) cols(:)];

    % collect background pixel indices
    bgPixelIdx = [];

    for j = 1:nBackgroundPixels

        bgRowCol = bgPixelCoord(j, :);

        isBgPixel = ismember(pixelCoord, bgRowCol, 'rows');

        if any(isBgPixel)

            newBgIdx = find(isBgPixel);

            % collect background indicators into an array
            bgPixelIdx = [bgPixelIdx; newBgIdx];
        end
    end

    bgInputPixels = pixels(bgPixelIdx, :); %#ok<NASGU>
    bgInputGaps   = gaps(bgPixelIdx, :); %#ok<NASGU>


    eval(['save /path/to/matlab/cal/mfiles/run_cal_here/test/bg_input_pixels_ch' channelString '_invoc' num2str(i) '.mat  bgInputPixels bgInputGaps bgPixelIdx'])
end

%
% % plot background pixels
%
% targetPixelsPrime = targetPixels';
% targetGapsPrime   = targetGaps';
%
% % set gaps to nans
% targetPixelsPrimeNanGaps = targetPixelsPrime;
% targetPixelsPrimeNanGaps(targetGapsPrime) = nan;
%
%
% figure;
% %plot(targetPixelsPrimeNanGaps, 'c.')
% %hold on
% plot(targetPixelsPrimeNanGaps(:, bgPixelIdx), 'm')
%
% xlabel('Cadence Index')
% title(['CAL Background Pixels corrected for ' correctionString])
%
% ylabel('Background Flux (ADU/cadence)')
% ylabel('Background Flux (e-/cadence)')
%
% fileNameStr = [ 'background_pixels_' correctionString '_corrected' ];
% plot_to_file(fileNameStr);

return;
