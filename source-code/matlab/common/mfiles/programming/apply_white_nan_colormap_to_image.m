function cMap = apply_white_nan_colormap_to_image(varargin)
%
% function cMap = apply_white_nan_colormap_to_image(varargin)
%
% This function modifies the colormap of the image in the current axes
% and adjusts the image data contained in the object such that all NaN
% values are replaced by the minimum image value minus the range of values
% in the image and displays these value as white in the plotted image. If
% an argument is applied it must be the orignal image data (e.g. from
% imagesc(originalImageData) ). This is useful if the caxis has been
% adjusted after running apply_white_nan_colormap_to_image in order to
% effectively rescale the caxis so only the NaNa show white. The modified
% colormap is return.
%
% INPUTS:   vargin{1}   = original image data
% OUTPUTS:  cMap        = modified colormap with bottom bin = white
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


% get the current figure
f = gcf;
figure(f);

% get the axes handle and last child handle which contains the image data
% for an image plot 
% I'm not sure what this will do if the plot is not an image. It will
% probably just throw an error when it tries to retrieve the image data.
h = gca;
c = get(h,'Children');

% find which child contains CData
imageChild = 0;
for iChild = 1:length(c)
    if isfield(get(c(iChild)),'CData')
        imageChild = iChild;
        break;
    end
end

% if CData was not found in children simply return current colormap without
% making any adjustment to the map or the figure
if imageChild == 0
    cMap = colormap;
    return;
end
    

% get caxis scaling and colormap
currentCaxis = caxis;
cMap = colormap;
cMapLength = length(cMap);

% grab the image data
if(nargin > 0)
    tempImage = varargin{1};
else
    tempImage = get(c(imageChild),'CData');
end
minValue = min(min(tempImage));
maxValue = max(max(tempImage));

% place valid values that lie in first bin into second bin
binSize = (currentCaxis(2) - currentCaxis(1))/cMapLength;
tempImage(tempImage <= currentCaxis(1) + binSize) = currentCaxis(1) + 1.5*binSize;

% replace NaNs in image with very negative value
tempImage(isnan(tempImage)) = minValue - (maxValue - minValue);
set(c(imageChild),'CData',tempImage);

% set lowest element in colormap to 'white' ([1,1,1])
cMap(1,:) = [1,1,1];
colormap(cMap);