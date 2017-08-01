
function smart_imagesc(displayImage, colBoundaries, rowBoundaries, ax_h)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function smart_imagesc(displayImage, colBoundaries, rowBoundaries, ax_h)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% smart_imagesc does an imagesc on axes with handles ax_h using auto-adjusted
% clims that are suitable for Kepler images.  colBoundaries and rowBoundaries
% are 2 element vectors specifying the pixel address
% (instead of automatic 1-based) for displayImage.
% If image has  size 1070 x 1132 (untrimmed ffi) or 26 x 1100 (virtual
% smear), charge injection intenstity values will not be used for
% determining clims for scaling.
% CSCIs that use this function:  DG, BART, POOF
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:
%
%           displayImage:  [array] of the image
%                   colBoundaries:  [vector] of the image's startRow endRow
%                   rowBoundaries:  [vector] of the image's startCol endCol
%                   ax_h:  [double] axes handle to apply the function
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUTS:
%
%             an image with automatic clim scaling with startRow, startCol
%             on the bottom left corner
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

% must avoid mean and median computation on NaN images.
% Also avoid scaling any gappy values (2^32-1)
% and charge injection pixels

try

    tempDisplayImage = displayImage;
    % look for untrimmed images or virtual smear images
    % set the charge injection pixels to NaN
    s= size(tempDisplayImage);
    if  s == [1070, 1132] %#ok<BDSCA>    
        import gov.nasa.kepler.common.FcConstants   
        exRowStart = FcConstants.CHARGE_INJECTION_ROW_START+1;
        exRowEnd = FcConstants.CHARGE_INJECTION_ROW_END+1;
        exColStart = FcConstants.CHARGE_INJECTION_COLUMN_START+1;
        exColEnd = FcConstants.CHARGE_INJECTION_COLUMN_END+1;
        tempDisplayImage(exRowStart:exRowEnd, exColStart:exColEnd) = NaN;
    elseif  s == [26, 1100] %#ok<BDSCA>
        exRowStart = 16;
        exRowEnd = 19;
        exColStart = 1;
        exColEnd = 1100;
        tempDisplayImage(exRowStart:exRowEnd, exColStart:exColEnd) = NaN;
    end

    idx1 = find(~isnan(tempDisplayImage));
    idx2 = find(tempDisplayImage < 2^32-1);
    indxToUse = intersect(idx1, idx2);
    usefulPixels = tempDisplayImage(indxToUse); %#ok<FNDSB>

    maxDispImage = max(usefulPixels(:));
    madIndex = abs(std(usefulPixels(:)));


    % determine value of n
    if  madIndex < 8
        n = 5;
    elseif (madIndex >= 8 ) && (madIndex < 50)
        n = 10 ;
    elseif (madIndex >= 50 ) && (madIndex < 80)
        n = 12 ;
    elseif (madIndex >= 80 ) && (madIndex < 150)
        n = 15 ;
    elseif (madIndex >= 150 ) && (madIndex < 200)
        n = 18;
    elseif (madIndex >= 200 ) && (madIndex < 250)
        n = 20 ;
    else
        n = 30;
    end

    climMin = median(usefulPixels(:))-n*mad(usefulPixels(:));
    if climMin < min(usefulPixels(:))
        climMin = min(usefulPixels(:));
    end

    climMax = median(usefulPixels(:))+ n*mad(usefulPixels(:));
    while climMax > maxDispImage
        n = n-1;
        climMax = median(usefulPixels(:))+ n*mad(usefulPixels(:));
        if n < 0
            climMax = max(usefulPixels(:));
        end
    end

    clim = [climMin, climMax];
    imagesc(colBoundaries, rowBoundaries, displayImage, 'parent', ax_h );
    set(ax_h, 'clim', clim, 'ydir', 'normal');

catch

    %if the above fails, do a regular imagesc
    imagesc(colBoundaries, rowBoundaries, displayImage, 'parent', ax_h )
    set(ax_h, 'ydir', 'normal')

end




