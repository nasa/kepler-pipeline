function [probabilities statistics] = ...
    Create_CDF_From_Histogram_Modified(histfile,lengthSES,skipcount)
% to be used for unit testing with compute false positivies
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

[x,n] = textread(histfile, ['%f','%f']);
counts = lengthSES;


% move bin locations from the left edge to the middle of the bin
% bin_spacing = unique(abs(diff(x)));
% half_spacing = 0.5*bin_spacing(1);
% x = x + half_spacing;
n = n + n.*skipcount; % if the skipcount is 0, count stays the same;
% if the skip count is 25, then this equation is correct since 26 is the
% increment to the counter in C++ and FORTRAN code


ntransits = 4;
nlength = counts;

total_events = nlength(1).^ntransits;

n = n./total_events;
vals = n;
% breaks = x;
% xstep = unique(diff(breaks));
% breaks(end+1) = breaks(end)+ xstep(1);
% 
% 
% M = size(vals,1);
% 
% % determine breaks for pp
% ppbreaks = [breaks(1:end-1) breaks(2:end)];

% compute the cdf

vals2 = flipud(vals);
vals3 = flipud(cumsum(vals2));

probabilities = vals3;
statistics = x;


% vals3 = [0; vals3];
% cdf  = 1 - vals3;
% cdf = flipud(cdf);
% how wide are the bins?
% interval = diff(ppbreaks,[],2);


% c1 is the slope = delta(prob)/delta(x) (differential calculus notation: delta = change in variable) 
% c1 = diff(cdf) ./ interval;

% this is the point in the middle of the bin
%c0 = cumsum([vals(1:M-1);0]);
% c0 = cdf(1:M);

% Make the breaks & coefficients into a pp structure
% ppe = mkpp(breaks,[c1,c0]);
% 
% yy = ppval(ppe,breaks);

%figure;
%semilogy(breaks,yy,'bo'); % plot CDF
%hold on;

% how to get the pp form of 1-CDF??


% yy10 = 1 - yy;
% yy1 = yy10;
% 
% semilogy(breaks,yy1,'ro-'); % plot CDF
% grid on;
% hold on;
% 
% z = -10:.01:10; % random variable 
% curve3 =   0.5*erfc(z./sqrt(2));
% semilogy(z, curve3,'b.-');
% 
% % interested only in the range from 6sigma to 10 sigma
% xlim([6 10]);
% ylim([min(yy1) max(yy1)*10]);
% 
% xlabel('Detection Threshold \sigma')
% ylabel('False Alarm Rate')
% legend('DIARAD data plus shot and inst. noise for an m_{v} = 12 star','gaussian', 'Location', 'SouthWest')
% 
% % choose this legend if using only DIARAD data
% %legend('DIARAD data ','gaussian', 'Location', 'SouthWest')
% 
% legend('boxoff');
% 
% sFilename = sprintf('Bootstrap_CDF.jpg');
% fprintf('\n\nSaving the plot to a file named %s \n',sFilename);
% fprintf('Please wait....\n\n');
% print('-djpeg','-r300',sFilename);
% 
% hold off;

return
