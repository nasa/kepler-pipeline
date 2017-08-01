% create a super-aperture, into which any of the unique apertures can fit
% start with a large array, tall enough to capture an entire column of
% saturation, but smaller in width
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
bigTallApImage = zeros(1023, 101); % dimensions must be odd
bigTallApImageCenter = [fix(size(bigTallApImage, 1)/2), fix(size(bigTallApImage, 2)/2)];
bigWideApImage = zeros(101, 1023); % dimensions must be odd
bigWideApImageCenter = [fix(size(bigWideApImage, 1)/2), fix(size(bigWideApImage, 2)/2)];
for a=1:length(uniqueAps)
    apImage = target_definition_to_image(uniqueAps(a));
    if size(apImage, 1) > size(apImage, 2)
        for i=1:length(uniqueAps(a).offsets)
            bigTallApImage(bigTallApImageCenter(1) + uniqueAps(a).offsets(i).row, ...
                bigTallApImageCenter(2) + uniqueAps(a).offsets(i).column) = 1;
        end
    else
        for i=1:length(uniqueAps(a).offsets)
            bigWideApImage(bigWideApImageCenter(1) + uniqueAps(a).offsets(i).row, ...
                bigWideApImageCenter(2) + uniqueAps(a).offsets(i).column) = 1;
        end
    end
end

boxCount = 1;
if any(bigTallApImage(:) > 0)
    % get bounding box of bigMask
    [a, n, m, box] = square_ap(bigTallApImage);
    bigTallApBoxImage = ones(box(1, 2)-box(1, 1)+1,box(2, 2)-box(2, 1)+1);
    % now make the mask definition from the box image
    height = min(size(bigTallApBoxImage, 1), maxMaskHeight);
    width  = min(size(bigTallApBoxImage, 2), maxMaskWidth);
    halfHeight = fix(height/2);
    halfWidth = fix(width/2);
    bigTallApBoxImageCenter(1) = halfHeight;
    bigTallApBoxImageCenter(2) = halfWidth;
    hIncrement = fix(halfHeight/nNestedBoxes);
    wIncrement = fix(halfWidth/nNestedBoxes);
    boxCount = 1;
    % reduce size in both dimensions
    if hIncrement > 0 || wIncrement > 0
        for i=1:nNestedBoxes
            bigMasks(boxCount) = image_to_target_definition( ...
                bigTallApBoxImage( ...
                1+hIncrement*(i-1):height-hIncrement*(i-1), ...
                1+wIncrement*(i-1):width-wIncrement*(i-1)), ...
                fix([(height-hIncrement*(i-1) - (1+hIncrement*(i-1)) + 1)/2, ...
                    (width-wIncrement*(i-1) - (1+wIncrement*(i-1)) + 1)/2]));
            boxCount = boxCount + 1;
        end
    else
        bigMasks(boxCount) = image_to_target_definition(bigTallApBoxImage, ...
            bigTallApBoxImageCenter);
        boxCount = boxCount + 1;
    end    
    % reduce size along the width dimension only
    if hIncrement > 0 
        for i=1:nNestedBoxes-1
            bigMasks(boxCount) = image_to_target_definition( ...
                bigTallApBoxImage( ...
                1:height, 1+wIncrement*i:width-wIncrement*i), ...
                fix([(height - 1)/2, ...
                    (width-wIncrement*i - (1+wIncrement*i) + 1)/2]));
            boxCount = boxCount + 1;
        end
    end  
end

if any(bigWideApImage(:) > 0)
    [a, n, m, box] = square_ap(bigWideApImage);
    bigWideApBoxImage = ones(box(1, 2)-box(1, 1)+1,box(2, 2)-box(2, 1)+1);
    % now make the mask definition from the box image
	% switch max width and height
    height = min(size(bigWideApBoxImage, 1), maxMaskWidth);
    width  = min(size(bigWideApBoxImage, 2), maxMaskHeight);
    halfHeight = fix(height/2);
    halfWidth = fix(width/2);
    bigWideApBoxImageCenter(1) = halfHeight;
    bigWideApBoxImageCenter(2) = halfWidth;
    hIncrement = fix(halfHeight/nNestedBoxes);
    wIncrement = fix(halfWidth/nNestedBoxes);
    if hIncrement > 0 || wIncrement > 0
        for i=1:nNestedBoxes
            bigMasks(boxCount) = image_to_target_definition( ...
                bigWideApBoxImage( ...
                1+hIncrement*(i-1):height-hIncrement*(i-1), ...
                1+wIncrement*(i-1):width-wIncrement*(i-1)), ...
                fix([(height-hIncrement*(i-1) - (1+hIncrement*(i-1)))/2, ...
                    (width-wIncrement*(i-1) - (1+wIncrement*(i-1)) + 1)/2]));
            boxCount = boxCount + 1;
        end
    else
        bigMasks(boxCount) = image_to_target_definition(bigWideApBoxImage, ...
            bigWideApBoxImageCenter);
        boxCount = boxCount + 1;
    end    
    % reduce size along the height dimension only
    if wIncrement > 0
        for i=1:nNestedBoxes-1
            bigMasks(boxCount) = image_to_target_definition( ...
                bigWideApBoxImage( ...
                1+hIncrement*i:height-hIncrement*i, 1:width), ...
                fix([(height-hIncrement*i - (1+hIncrement*i) + 1)/2, ...
                    (width - 1)/2]));
            boxCount = boxCount + 1;
        end
    end
end

