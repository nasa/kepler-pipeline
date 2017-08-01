function display_scatter(dgTrimmedImageObj, LGB ,HGB)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% display_scatter(dgTrimmedImageObj, LGB ,HGB) makes scatter plots for each
% of the pixel regions
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
%              LGB: [1 x 84 vector] the low guard bands, 95% of the mean black
%               for ea/ modout
%              HGB: [double] the high guard band value (2^14-1)
%             
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS:
%
%         two figures: 
%
%               *fig_scatter_star contains scatter plot of the star image,
%               it gets tagged with 'scatter_star'
%
%               *fig_scatter_col contains the scatter plots of the four
%               collateral regions, it gets the 'scatter_col' tag
%
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

ch = convert_from_module_output(mod, out);

% figure for the star
fig_scatter_star = figure('units', 'pixels','position', [70 70 1000 500],...
    'numbertitle', 'off', 'name', ...
    sprintf('Scatter Plot of Star, Module %d Output %d', mod, out), ...
    'tag', 'scatter_star', 'color',[1 1 1]);

uipanel('units', 'pixels', 'position', [ 5 5 950 485], ...
    'parent', fig_scatter_star);

x = 1:numel(star(:));
line1 = LGB(ch)*ones(1,length(x));
line2 = HGB*ones(1,length(x));
semilogy(x, star(:), '.b', x, line1, '-r', x, line2, '-g')
ylabel('\bf \fontsize{14} DN/Read')
xlabel('\bf \fontsize{14} Pixels');
set(gca, 'xtick',[])
title('\bf \fontsize{16} Star')
legend('Pixel Values', 'Low Guard Band', 'High Guard Band')


% figure for the collateral regions
fig_scatter_col = figure('units', 'pixels','position', [40 40 1000 500],...
    'numbertitle', 'off', 'name', ...
    sprintf('Scatter Plots of Collateral Regions, Module %d Output %d', mod, out), ...
    'tag', 'scatter_col', 'color',[1 1 1]);

uipanel('units', 'pixels', 'position', [ 5 5 950 485], 'parent', fig_scatter_col);

subplot(2,2,1) % virtual smear
x = 1:numel(vs(:));
line1 = LGB(ch)*ones(1,length(x));
line2 = HGB*ones(1,length(x));
plot(x, vs(:), '.b',x, line1, '-r')
if max(vs(:))>0.5*HGB
    hold on
    plot(x,line2, '-g')
end
xlabel('\bf \fontsize{14} Pixels')
ylabel('\bf \fontsize{14} DN/Read')
set(gca, 'xtick',[], 'ygrid', 'on')
title('\bf \fontsize{16} Virtual Smear')

subplot(2,2,3) % masked smear
x = 1:numel(ms(:));
line1 = LGB(ch)*ones(1,length(x));
line2 = HGB*ones(1,length(x));
plot(x, ms(:), '.b',x, line1, '-r')
if max(ms(:))>0.5*HGB
    hold on
plot(x,line2, '-g')   
end  
xlabel('\bf \fontsize{14} Pixels')
ylabel('\bf \fontsize{14} DN/Read')
set(gca, 'xtick',[], 'ygrid', 'on')
title('\bf \fontsize{16} Masked Smear')


subplot(2,2,2) % leading black
x = 1:numel(lb(:));
line1 = LGB(ch)*ones(1,length(x));
line2 = HGB*ones(1,length(x));
plot(x,lb(:), '.b' ,x, line1, '-r')
if max(lb(:))>0.5*HGB
    hold on
plot(x,line2, '-g')   
end  
xlabel('\bf \fontsize{14} Pixels')
ylabel('\bf \fontsize{14} DN/Read')
set(gca, 'xtick',[], 'ygrid', 'on')
title('\bf \fontsize{16} Leading Black')


subplot(2,2,4) % trailing blakc
x = 1:numel(tb(:));
line1 = LGB(ch)*ones(1,length(x));
line2 = HGB*ones(1,length(x));
plot(x,tb(:), '.b', x, line1, '-r')
if max(tb(:))>0.5*HGB
    hold on
    plot(x,line2, '-g')
end
xlabel('\bf \fontsize{14} Pixels')
ylabel('\bf \fontsize{14} DN/Read')
set(gca, 'xtick',[], 'ygrid', 'on')
title('\bf \fontsize{16} Trailing Black')

return
