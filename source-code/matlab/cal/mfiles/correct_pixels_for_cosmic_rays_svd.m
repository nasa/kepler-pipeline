function [cosmicRayCorrectedPixelArray, pixelsWithCosmicRayHits] = ...
    correct_pixels_for_cosmic_rays_svd(pixelArrayToCorrect, gapArray, falseRejectionRate, timestamp)
%function [cosmicRayCorrectedPixelArray, pixelsWithCosmicRayHits] = ...
%    correct_pixels_for_cosmic_rays_svd(pixelArrayToCorrect, gapArray, falseRejectionRate, timestamp)
%
% function to identify and clean cosmic rays from input pixel time series
% by calling the function clean_cosmic_rays_svd.  The pixel columns should
% be passed into this function if correcting black pixels for cosmic rays,
% and the pixel rows should be passed in to correct masked or virtual smear.
% A warning is issued if any pixel time series best order was limited by the
% max SVD order parameter.
%
% INPUTS
%
%   pixelArrayToCorrect
%   gapArray
%   falseRejectionRate
%   timestamp
%
% OUTPUTS
%
%   cosmicRayCorrectedPixelArray
%   pixelsWithCosmicRayHits
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

% transpose the input arrays so that the time series are column vectors
pixelArrayToCorrect = pixelArrayToCorrect';
gapArray            = gapArray';

% Identify the cosmic ray events by calling clean_cosmic_rays_svd. Issue a
% warning if any pixel time series best order was limited by the max SVD
% order parameter.
[cosmicRayCorrectedPixelArray, cosmicRayEventsIndicators, nMaxOrders] = ...
    clean_cosmic_rays_svd(pixelArrayToCorrect, gapArray, falseRejectionRate);

if nMaxOrders > 0
    warning('CAL:correct_pixels_for_cosmic_rays_svd', ...
        ['The best SVD order for CR cleaning was limited for ' num2str(nMaxOrders) ]);
end


% Transpose the time series arrays
cosmicRayCorrectedPixelArray = cosmicRayCorrectedPixelArray';
pixelArrayToCorrect          = pixelArrayToCorrect';
cosmicRayEventsIndicators    = cosmicRayEventsIndicators';

% populate the output structure
if (any(any(cosmicRayEventsIndicators)))

    [rowOrColumn, indices] = find(cosmicRayEventsIndicators);

    delta = pixelArrayToCorrect(cosmicRayEventsIndicators) - cosmicRayCorrectedPixelArray(cosmicRayEventsIndicators);
    mjd   = timestamp(indices);

    % convert arrays to cell arrays
    deltasCellArray       = num2cell(delta);
    indicesCellArray      = num2cell(indices);
    rowOrColumnCellArray  = num2cell(rowOrColumn);
    mjdCellArray          = num2cell(mjd);

    % deal back into individual struct arrays
    [pixelsWithCosmicRayHits(1:length(deltasCellArray)).delta] = deal(deltasCellArray{:});
    [pixelsWithCosmicRayHits(1:length(indicesCellArray)).indices] = deal(indicesCellArray{:});
    [pixelsWithCosmicRayHits(1:length(rowOrColumnCellArray)).rowOrColumn] = deal(rowOrColumnCellArray{:});
    [pixelsWithCosmicRayHits(1:length(mjdCellArray)).mjd] = deal(mjdCellArray{:});
else
    pixelsWithCosmicRayHits = [];
end

return;
