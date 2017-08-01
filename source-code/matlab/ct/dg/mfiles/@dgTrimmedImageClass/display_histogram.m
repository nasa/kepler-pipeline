function display_histogram(dgTrimmedImageObj)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% display_histogram(dgTrimmedImageObj) generates histograms for
% dgTrimmedImageObj
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS:
%
%         two figures: 
%
%               *fig_hist_star contains the histogram of the star image,
%               top plot axes is the histogram over the full DN range in
%               1000 bin.
%               Bottom plots are the zooms in per quarter range ea/ at 50
%               bins.
%               Contains the tag 'hist_star'
%
%               *fig_hist_col contains the scatter plots of the four
%               collateral regions.  Top plots are the full range histograms
%               in 1000 bins.  Bottom are zoom in histograms within 1 stdev
%               of the mode, also at 1000 bins.  Contains the tag
%               'hist_col'.
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
star = get(dgTrimmedImageObj, 'star');
lb = get(dgTrimmedImageObj, 'leadingBlack');
tb = get(dgTrimmedImageObj, 'trailingBlack');
ms = get(dgTrimmedImageObj, 'maskedSmear');
vs = get(dgTrimmedImageObj, 'virtualSmear');
mod = get(dgTrimmedImageObj, 'module');
out = get(dgTrimmedImageObj, 'output');



% figure for star
fig_hist_star = figure('units', 'pixels','position', [70 70 1000 500],...
    'numbertitle', 'off', 'name', ...
    sprintf('Histogram of Star Region, Module %d Output %d', mod, out), ...
    'tag', 'hist_star', 'color',[1 1 1]);

uipanel('units', 'pixels', 'position', [ 5 5 950 490], 'parent', fig_hist_star);

subplot(2,1,1)
hist(star(:),1000) % 1000 bins  for the full range
set(gca, 'tickdir', 'out')
grid on
title('\bf \fontsize{10} Star')
ylabel('\bf \fontsize{10} Count')
xlabel('\bf \fontsize{10} DN/Read')

mainXlim = get(gca, 'xlim');
maxStar = max(star(:));
minStar = min(star(:));
bound1 = [minStar, 0.25*(maxStar-minStar)+minStar];
bound2 = [.25*(maxStar-minStar)+minStar, 0.5*(maxStar-minStar)+minStar];
bound3 = [0.5*(maxStar-minStar)+minStar, 0.75*(maxStar-minStar)+minStar];
bound4 = [0.75*(maxStar-minStar)+minStar, maxStar];

starZoom1 = nonzeros((star(:) >= bound1(1) & star(:) <= bound1(2)).*star(:));
subplot(2,4,5);
hist(starZoom1,50); 
set(gca, 'xlim', [mainXlim(1) bound1(2)], 'tickdir', 'out'); 
grid on
xlabel('\bf \fontsize{10} DN/Read'); 
ylabel('\bf \fontsize{10} Count')


starZoom2 = nonzeros((star(:) > bound2(1) & star(:) <= bound2(2)).*star(:));
subplot(2,4,6); 
hist(starZoom2, 50); 
set(gca, 'xlim', bound2, 'tickdir', 'out');
grid on
xlabel('\bf \fontsize{10} DN/Read')


starZoom3 = nonzeros((star(:) > bound3(1) & star(:) <= bound3(2)).*star(:));
subplot(2,4,7); 
hist(starZoom3, 50);
set(gca, 'xlim', bound3, 'tickdir', 'out'); 
grid on
xlabel('\bf \fontsize{10} DN/Read')

 
starZoom4 = nonzeros((star(:) > bound4(1) & star(:) <= bound4(2)).*star(:));
subplot(2,4,8); 
hist(starZoom4, 50); 
set(gca, 'xlim',[ bound4(1) mainXlim(2)], 'tickdir', 'out'); 
grid on
xlabel('\bf \fontsize{10} DN/Read')



% figure for collaterals
fig_hist_col = figure('units', 'pixels','position', [40 40 1000 500],...
    'numbertitle', 'off', 'name', ...
    sprintf('Histograms of Collateral Regions, Module %d Output %d', mod, out),...
    'tag', 'hist_col', 'color', [1 1 1]);

uipanel('units', 'pixels', 'position', [ 5 5 950 490], 'parent', fig_hist_col);

% leading black
subplot(2,4,1);
hist(lb(:),1000);
title('\bf \fontsize{10} Leading Black');
ylabel('\bf \fontsize{10} Count')
[zoomImage xlim] = smart_hist(lb);
set(gca, 'tickdir', 'out')
grid on
subplot(2,4,5);
hist(zoomImage, 50);
set(gca, 'xlim', xlim, 'tickdir', 'out')
grid on
ylabel('\bf \fontsize{10}Count');
xlabel('\bf \fontsize{10} DN/Read')



% trailing black
subplot(2,4,2);hist(tb(:),1000);
title('\bf \fontsize{10} Trailing Black');
[zoomImage xlim] = smart_hist(tb);
set(gca, 'tickdir', 'out')
grid on
subplot(2,4,6);
hist(zoomImage, 50);
set(gca, 'xlim', xlim, 'tickdir', 'out')
xlabel('\bf \fontsize{10} DN/Read')
grid on


% masked smear
subplot(2,4,3);
hist(ms(:),1000); 
title('\bf \fontsize{10} Masked Smear')
[zoomImage xlim] = smart_hist(ms);
set(gca, 'tickdir', 'out')
grid on
subplot(2,4,7);
hist(zoomImage, 50);
set(gca, 'xlim', xlim, 'tickdir', 'out')
xlabel(' \bf \fontsize{10}DN/Read')    
grid on


% virtual smear
subplot(2,4,4); 
hist(vs(:), 1000);  
title('\bf \fontsize{10} Virtual Smear')
[zoomImage xlim] = smart_hist(vs);
set(gca, 'tickdir', 'out')
grid on
subplot(2,4,8); 
hist(zoomImage, 50);
set(gca, 'xlim', xlim, 'tickdir', 'out')
grid on
xlabel(' \bf \fontsize{10}DN/Read')  

return

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [zoomImage xlim] = smart_hist(image)
% subfunction takes an image array and looks for the mode,
% then grabs all values within 1 stdev of the mode and 
% returns it in a vector zoomImage
m = mode(image(:));
stdm= std(image(:));
lowerlimit = m-stdm;
upperlimit =m+stdm;
zoomImage = nonzeros((image(:) >= lowerlimit & image(:) <= upperlimit).*image(:));
xlim = [lowerlimit upperlimit];
return