function mask = make_rpts_mask(rptsOptApStruct, nHalos, addUndershoot, nExtraHalos)
% function masks = make_rpts_mask(rptsOptApStruct, addExtraHalo)
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

startSize = 200;
maskImage = zeros(startSize);
% loop through the mod out channels
for t=1:length(rptsOptApStruct)
    targetImage = rptsOptApStruct(t).aperture;
    [nr, nc] = size(targetImage);
    convCount = conv2(rot90(targetImage,2),maskImage);
	convMax = max(max(convCount));
	if convMax > 0
    	goodFit = convCount == convMax;
    	% try to find a good fit near the center of the mask, use
    	% the centroid of the good fit pixels
        maxRow = round(sum(sum(goodFit,2).*(1:size(goodFit, 1))') / sum(sum(goodFit,2)));
        maxCol = round(sum(sum(goodFit,1).*(1:size(goodFit, 2))) / sum(sum(goodFit,1)));
% 		disp([maxRow maxCol]);
    	% check that the centroid is actually on a good fit pixel
    	if ~goodFit(maxRow, maxCol)
        	% The centroid is no good, so pick any good fit offset
        	[goodFitRow goodFitCol] = find(goodFit);
        	% pick something near the middle
        	goodFitChoice = fix(length(goodFitRow)/2);
        	maxRow = goodFitRow(goodFitChoice);
        	maxCol = goodFitCol(goodFitChoice);
    	end
    	convRow = maxRow - round(size(convCount, 1)/2);
    	convCol = maxCol - round(size(convCount, 2)/2);
	else
    	convRow = 0;
    	convCol = 0;
	end
    % register target image centroid to center of maskImage
    ro = fix(startSize/2 - fix(nr/2)) - convRow;
    co = fix(startSize/2 - fix(nc/2)) - convCol;
	rowRange = ro:ro+nr-1;
	colRange = co:co+nc-1;
    maskImage(rowRange, colRange) ...
        = maskImage(rowRange, colRange) | targetImage;
% 	disp(sum(sum(maskImage)))
end
if nExtraHalos
	[maskImage, apertureCenter] = apply_halo(maskImage, fix([startSize/2, startSize/2]), ...
    	nExtraHalos, 0);
end
mask = image_to_target_definition(maskImage, fix([startSize/2, startSize/2]));

