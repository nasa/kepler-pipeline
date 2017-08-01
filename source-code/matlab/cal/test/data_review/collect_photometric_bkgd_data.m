function collect_photometric_bkgd_data(calIntermediateStruct, correctionString, ...
    backgroundPixCoordinatesFilename)
%
% function to collect background pixels for each invocation given a
% background pixel coordinates file.  The background pixels will be
% plotted and also saved.
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



if nargin == 2
    backgroundPixCoordinatesFilename = '/path/to/matlab/cal/data/bkg.pixel.coordinates.14.2.11914.13379.mat';
end

ccdModule = calIntermediateStruct.ccdModule;
ccdOutput = calIntermediateStruct.ccdOutput;

channel = convert_from_module_output(ccdModule, ccdOutput);

targetPixels = calIntermediateStruct.photometricPixels;  % nPixels x nCadences
targetGaps   = calIntermediateStruct.photometricGaps;    % nPixels x nCadences

load(backgroundPixCoordinatesFilename) % bgPixelCoord: nPixels x 2 ([rows(:) cols(:)])

targetRows   = calIntermediateStruct.photometricRows;    % nPixels x 1
targetCols   = calIntermediateStruct.photometricColumns; % nPixels x 1

nBackgroundPixels = length(bgPixelCoord);

targetPixelCoord = [targetRows(:) targetCols(:)];

% collect background pixel indices
bgPixelIdx = [];

for i = 1:nBackgroundPixels

    bgRowCol = bgPixelCoord(i, :);

    isBgPixel = ismember(targetPixelCoord, bgRowCol, 'rows');

    if any(isBgPixel)

        newBgIdx = find(isBgPixel);

        % collect background indicators into an array
        bgPixelIdx = [bgPixelIdx; newBgIdx];
    end
end


% set gaps to NaNs and plot median of background pixels
nanGapPixels = targetPixels;
nanGapPixels(targetGaps) = nan;

figure;
plot(median(nanGapPixels(bgPixelIdx, :)))


xlabel('Cadence Index')
title(['CAL Channel ' num2str(channel) ' Median Background Pixels (' correctionString '-Corrected)'])


if strcmpi(correctionString, 'Fixed Offset') || strcmpi(correctionString, 'Mean Black') || ...
        strcmpi(correctionString, '2D Black') || strcmpi(correctionString, 'Black') || ...
        strcmpi(correctionString, 'Nonlinearity') || strcmpi(correctionString, 'None')

    ylabel('Background Flux (ADU/cadence)')

else
    ylabel('Background Flux (e-/cadence)')

end

fileNameStr = [ 'ch' num2str(channel)  '_background_pixels_' correctionString '_corrected' ];
plot_to_file(fileNameStr);

return;
