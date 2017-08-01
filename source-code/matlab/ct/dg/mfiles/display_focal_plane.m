function  display_focal_plane(fpDisplayStruct, ffiName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dg_display_focal_plane(fpDisplayStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% displays the focal plane image using information from fpDisplayStruct
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:
%             
%   fpDisplayStruct, a struct with 21 entries with the following fields-
%
%               module: [int] module number
%               output: [int] output number
%              fpCoord: vector[z y] focal plane coordintes of the bottom 
%                       left output at pixel 1,1
%            binFactor: [int] bin factor of the input binnedStarImage
%          moduleImage: [single] image with 4 outputs put together in the
%               correct orientation with gaps filled in and correct
%               rotation
%
%    ffiName: [ string ] name of fits file
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS: a figure image of the focal plane with handle fh1
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

import gov.nasa.kepler.common.FcConstants;
quantSteps = FcConstants.MEAN_BLACK_TABLE_MAX_VALUE;

% define the outmost edge of CCD in focal plane
fpSpan = 5903 * 2;  % note this will always be an even number

% create focal plane grid, note rows = cols b/c symmetry
fpRow = floor(fpSpan/fpDisplayStruct(1).binFactor);

% make a focal plane that is in reality 12000 x 12000 pixels and 
% preallocate zeros for the focal plane
%numRow = 12000/fpDisplayStruct(1).binFactor;axis

fp = zeros(fpRow, fpRow);
modTag = zeros(fpRow, fpRow);
outTag= zeros(fpRow, fpRow);

% place each module in the big grid
for nMod = 1:21

    fpCoord= ceil((fpDisplayStruct(nMod).fpCoord)/(fpDisplayStruct(nMod).binFactor) + fpRow/2) +1;
    
    [r c] = size(fpDisplayStruct(nMod).moduleImage);
    
    fp(fpCoord(2):fpCoord(2) + r - 1, fpCoord(1) : fpCoord(1) + c - 1) ...
        = fpDisplayStruct(nMod).moduleImage;

    modTag(fpCoord(2):fpCoord(2) + r - 1, fpCoord(1) : fpCoord(1) + c - 1) ...
        = fpDisplayStruct(nMod).moduleLabel;
    
    outTag(fpCoord(2):fpCoord(2) + r - 1, fpCoord(1) : fpCoord(1) + c - 1) ...
        = fpDisplayStruct(nMod).outputLabel;


end



% if there are zeros or negative numbers in fp, convert these values to the
% minimum nonzero value of fp so that imagesc log10 does not throw out a
% bunch of warnings or errors
fpp = (fp<=0)*min(nonzeros(fp))+fp; 

% convert fpp to single
fpp = single(fpp);

fh1 = figure('position', [30 30 800 600], 'tag', 'fp_display'); % create figure for fp
imagesc( log10(fpp));
colormap(hot)
set(gca, 'ydir', 'normal', 'xtick', [], 'ytick', [])
set(gcf, 'numbertitle', 'off', 'name', 'Focal Plane Display');
title(sprintf('Focal Plane Display for File: %s',  ffiName), 'fontsize', 12);

% this setting ensures that missing data won't swamp the rest of the signal
if max(max(fpp)) >= quantSteps 
    climMin = log10(min(min(fpp)));
    climMax = log10(max(max(quantSteps)));
set(gca, 'clim', [climMin climMax]);
end


% place  modTag, outTag in applicationData of the figure and store in
% single

setappdata(fh1, 'modTag', single(modTag));
setappdata(fh1, 'outTag', single(outTag));

