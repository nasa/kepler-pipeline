function new_display_plots(dgTrimmedImageObj)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function new_display_plots(dgTrimmedImageObj) takes a dgTrimmedImageObj
% and generates 2 figures with images of each pixel region
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:
%            
%
%       dgTrimmedImageObj: [object] with the following fields-
%
%           module: [int] CCD module number
%           output: [int] CCD output number
%        numCoadds: [int] number of coadds
%         startMjd: [double] start MJD time of data
%           endMjd: [double] end MJD time of data
%             star: [array double] normalized pixel values of the star region
%     leadingBlack: [array double] normalized pixel values of leading black region
%    trailingBlack: [array double] normalized pixel values of the trailing black region
%      maskedSmear: [array double] normalized pixel values of the masked smear region
%     virtualSmear: [array double] normalized pixel values of thevirtual
%     smear region
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS:
%
%         two figures: 
%
%               *fig_star contains image in hot colormap of the star
%               region, it gets the 'star' tag
%
%               *fig_collateral contains image in grey colormap of the four
%               collateral regions, it gets the 'collateral' tag
%
%          smart_imagesc is used to draw the images
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

star = get(dgTrimmedImageObj, 'star');
lb = get(dgTrimmedImageObj, 'leadingBlack');
tb = get(dgTrimmedImageObj, 'trailingBlack');
ms = get(dgTrimmedImageObj, 'maskedSmear');
vs = get(dgTrimmedImageObj, 'virtualSmear');
mod = get(dgTrimmedImageObj, 'module');
out = get(dgTrimmedImageObj, 'output');

% obtain row and col start for each of the pixel regions by calling
% define_pixel_regions() function, 1 based
[starRowStart, starRowEnd, starColStart,starColEnd,... 
    leadingBlackRowStart, leadingBlackRowEnd, leadingBlackColStart, leadingBlackColEnd,...
    trailingBlackRowStart, trailingBlackRowEnd, trailingBlackColStart, trailingBlackColEnd,...
    maskedSmearRowStart, maskedSmearRowEnd, maskedSmearColStart, maskedSmearColEnd...
    virtualSmearRowStart, virtualSmearRowEnd, virtualSmearColStart, virtualSmearColEnd] =...
    define_pixel_regions();



% figure of the star with one axes
fig_star = figure('units', 'pixels','position', [200 50 1000 715],...
    'numbertitle', 'off', 'name', ...
    sprintf('Star Region, Module %d Output %d', mod, out),...
    'tag', 'star', 'color',[1 1 1]);

star_ax = axes('units', 'pixels','position', [75 50 900 615],...
    'parent', fig_star);
smart_imagesc(star, [starColStart-1 starColEnd-1], [starRowStart-1 starRowEnd-1], star_ax)
title('\bf \fontsize{16} Star')
xlabel('\bf \fontsize{12} Column')
ylabel('\bf \fontsize{12} Row')
colormap(hot)
colorbar('eastoutside')



% figure of the collateral regionsm four axes
fig_collateral = figure('units', 'pixels','position', [70 70 1000 500],...
    'numbertitle', 'off', 'name', ...
    sprintf('Collateral Regions, Module %d Output %d', mod, out), ...
    'tag', 'collateral', 'color',[1 1 1]);

vs_ax = axes('units', 'pixels','position', [75 320 400 150],  'parent', fig_collateral); 
smart_imagesc(vs, [virtualSmearColStart-1 virtualSmearColEnd-1], [virtualSmearRowStart-1 virtualSmearRowEnd-1], vs_ax); 
title('\bf \fontsize{12} Virtual Smear'); 
colorbar('eastoutside');
xlabel('\bf \fontsize{12} Column')
ylabel('\bf \fontsize{12} Row')

ms_ax = axes('units', 'pixels','position', [75 70 400 150],  'parent', fig_collateral); 
smart_imagesc(ms,  [maskedSmearColStart-1 maskedSmearColEnd-1], [maskedSmearRowStart-1 maskedSmearRowEnd-1], ms_ax); 
title('\bf \fontsize{12} Masked Smear')
xlabel('\bf \fontsize{12} Column')
ylabel('\bf \fontsize{12} Row')
colorbar('eastoutside')

lb_ax = axes('units', 'pixels','position', [575 70 150 400], 'parent', fig_collateral); 
smart_imagesc(lb,  [leadingBlackColStart-1 leadingBlackColEnd-1],[leadingBlackRowStart-1 leadingBlackRowEnd-1], lb_ax);
title('\bf \fontsize{12} Leading Black')
xlabel('\bf \fontsize{12} Column')
ylabel('\bf \fontsize{12} Row')
colorbar('southoutside')

tb_ax = axes('units', 'pixels','position', [810 70 150 400], 'parent', fig_collateral); 
smart_imagesc(tb,  [trailingBlackColStart-1 trailingBlackColEnd-1],[trailingBlackRowStart-1 trailingBlackRowEnd-1], tb_ax)
title('\bf \fontsize{12} Trailing Black') 
xlabel('\bf \fontsize{12} Column')
ylabel('\bf \fontsize{12} Row')
colorbar('southoutside')

colormap(gray) % this will apply  to all images in fig_collateral


return
