% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
if 1
% load /path/to/coa-matlab-22-136/coa-inputs-0.mat
% load /path/to/coa-matlab-22-91/coa-inputs-0.mat
load /path/to/coa-matlab-22-148/coa-inputs-0.mat
inputsStruct.debugFlag = 1;
inputsStruct.raDec2PixModel.spiceFileDir = '/path/to/cache/spice';

coaResultStruct = coa_matlab_controller(inputsStruct);
end
%%

maxBrightness = 0.95;

graymap = repmat(0:maxBrightness/2499:maxBrightness, 3,1)';
graymap = [flipud(graymap); 1.0 0.5 0.0];

ccdImage = struct_to_array2D(coaResultStruct.completeOutputImage);
optimalApertures = coaResultStruct.optimalApertures;

optApImage = zeros(size(ccdImage));
nTargets = length(optimalApertures);
for t=1:nTargets
    if optimalApertures(t).keplerId ~= -1
        referenceRow = optimalApertures(t).referenceRow + 1;
        referenceColumn = optimalApertures(t).referenceColumn + 1;
        % draw the mask
        nApPix(t) = length([optimalApertures(t).offsets.row]);
        for p=1:nApPix(t)
            r = referenceRow + optimalApertures(t).offsets(p).row;
            c = referenceColumn + optimalApertures(t).offsets(p).column;
            optApImage(r, c) = 1;
        end
    end
end

figure('Color', 'white');
ax(1) = subplot(1,2,1);
h = imagesc(optApImage);
title('optimal apertures');
set(h, 'Parent', ax(1));
colormap(graymap);
ax(2) = subplot(1,2,2);
h = imagesc(ccdImage, [0, 6e6]);
title('simulated image');
colormap(flipud(colormap(gray(256))));
set(h, 'Parent', ax(2));
linkaxes(ax);
