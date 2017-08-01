function [pixelRows, pixelColumns] = clip_pixels_to_photometric_ccd(pixelRows, ...
    pixelColumns, fcConstants, stellarTypeString, warningFlag)
%function [pixelRows, pixelColumns] = clip_pixels_to_photometric_ccd(pixelRows, ...
%   pixelColumns, fcConstants, stellarTypeString, warningFlag)
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


if (nargin < 4)
    stellarTypeString = ' ';
    warningFlag = false;
    
    if (nargin < 5)
        warningFlag = false;
    end
end

% extract focal plane constants
nRowsImaging     = fcConstants.nRowsImaging;   % 1024
nColsImaging     = fcConstants.nColsImaging;   % 1100
nLeadingBlack    = fcConstants.nLeadingBlack;  % 12
%nTrailingBlack  = fcConstants.nTrailingBlack; % 20
%nVirtualSmear   = fcConstants.nVirtualSmear;  % 26
nMaskedSmear     = fcConstants.nMaskedSmear;   % 20


%------------------------------------------------------------------
% clip off any pixels in collateral region or off CCD
%------------------------------------------------------------------
pixelRowsInMaskedSmear  = find(pixelRows <= nMaskedSmear);
pixelRowsInVirtualSmear = find(pixelRows >  nMaskedSmear+nRowsImaging);

pixelColsInLeadingBlack  = find(pixelColumns <= nLeadingBlack);
pixelColsInTrailingBlack = find(pixelColumns >  nLeadingBlack+nColsImaging);

invalidPixelIdx = cat(1, pixelRowsInMaskedSmear(:), pixelRowsInVirtualSmear(:), ...
    pixelColsInLeadingBlack(:), pixelColsInTrailingBlack(:));

if ~isempty(invalidPixelIdx)

    clippedPixelIdx = unique(invalidPixelIdx);

    validPixelIdx = setxor(clippedPixelIdx, 1:length(pixelRows));

    pixelRows    = pixelRows(validPixelIdx);     % w.r.t. mod/out coordinates
    pixelColumns = pixelColumns(validPixelIdx);  % w.r.t. mod/out coordinates


    if (~isempty(pixelRowsInMaskedSmear) && warningFlag)
        warning('RPTS:clip_pixels_to_photometric_ccd', ...
            [stellarTypeString ' pixels in masked smear region have been clipped to the photometric region on CCD for background pixel selection.']);
    end


    if (~isempty(pixelRowsInVirtualSmear) && warningFlag)
        warning('RPTS:clip_pixels_to_photometric_ccd', ...
            [stellarTypeString ' pixels in virtual smear region have been clipped to the photometric region on CCD for background pixel selection.']);
    end


    if (~isempty(pixelColsInLeadingBlack) && warningFlag)
        warning('RPTS:clip_pixels_to_photometric_ccd', ...
            [stellarTypeString ' pixels in leading black region have been clipped to the photometric region on CCD for background pixel selection.']);
    end


    if (~isempty(pixelColsInTrailingBlack) && warningFlag)
        warning('RPTS:clip_pixels_to_photometric_ccd', ...
            [stellarTypeString ' pixels in trailing black region have been clipped to the photometric region on CCD for background pixel selection.']);
    end
end

return;
