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
clear;
evenFlag = 0;
oddFlag = 1;

[att_even include_even] = attitude_solution(evenFlag, 'output_motion');
[att_odd include_odd] = attitude_solution(oddFlag, 'output_motion');

ra_even = [att_even.ra];
ra_even = ra_even - ra_even(1);
ra_odd = [att_odd.ra];
ra_odd = ra_odd - ra_odd(1);

ra_diff = ra_even - ra_odd;

dec_even = [att_even.dec];
dec_even = dec_even - dec_even(1);
dec_odd = [att_odd.dec];
dec_odd = dec_odd - dec_odd(1);

dec_diff = dec_even - dec_odd;

phi_even = [att_even.phi];
phi_even = phi_even - phi_even(1);
phi_odd = [att_odd.phi];
phi_odd = phi_odd - phi_odd(1);

phi_diff = phi_even - phi_odd;

figure(1);
subplot(1,3,1);
plot([ra_even' ra_odd']);
title('consistent jitter: ra');
legend('even', 'odd');

subplot(1,3,2);
plot([dec_even' dec_odd']);
title('consistent jitter: dec');

subplot(1,3,3);
plot([phi_even' phi_odd']);
title('consistent jitter: phi');

figure(2);
plot([ra_diff' dec_diff' phi_diff']);
title('consistent jitter: difference between even and odd estimate');
legend('ra', 'dec', 'phi');

% fit and remove a polynomial to the data
nData = length(ra_even);
x = 1:nData;
[p, S, mu] = polyfit(x, ra_even, 4);
ra_even_resid = ra_even - polyval(p, x, S, mu);
clear p S mu;
[p, S, mu] = polyfit(x, ra_odd, 4);
ra_odd_resid = ra_odd - polyval(p, x, S, mu);
clear p S mu;
[p, S, mu] = polyfit(x, dec_even, 4);
dec_even_resid = dec_even - polyval(p, x, S, mu);
clear p S mu;
[p, S, mu] = polyfit(x, dec_odd, 4);
dec_odd_resid = dec_odd - polyval(p, x, S, mu);
clear p S mu;
[p, S, mu] = polyfit(x, phi_even, 4);
phi_even_resid = phi_even - polyval(p, x, S, mu);
clear p S mu;
[p, S, mu] = polyfit(x, phi_odd, 4);
phi_odd_resid = phi_odd - polyval(p, x, S, mu);
clear p S mu;

% get the injected signal
load('output_motion/run_long_m2o2s1/jitterMotion.mat', 'raMotion', 'decMotion', 'phiMotion');
binSize = length(raMotion)/96;
raBin = bin_matrix(raMotion, binSize, 1)/binSize;
decBin = bin_matrix(decMotion, binSize, 1)/binSize;
phiBin = bin_matrix(phiMotion, binSize, 1)/binSize;

figure(10);
subplot(1,3,1);
plot([ra_even_resid' ra_odd_resid' raBin']);
title('consistent jitter: ra residual');
legend('even', 'odd', 'injected motion');

subplot(1,3,2);
plot([dec_even_resid' dec_odd_resid' decBin']);
title('consistent jitter: dec residual');

subplot(1,3,3);
plot([phi_even_resid' phi_odd_resid' phiBin']);
title('consistent jitter: phi residual');

display(['ra standard deviation: ' num2str(std(ra_even_resid)) ' ' num2str(std(ra_odd_resid))]);
display(['dec standard deviation: ' num2str(std(dec_even_resid)) ' ' num2str(std(dec_odd_resid))]);
display(['phi standard deviation: ' num2str(std(phi_even_resid)) ' ' num2str(std(phi_odd_resid))]);


if 1
[att_even include_even] = attitude_solution(evenFlag, 'output_motion_bad');
[att_odd include_odd] = attitude_solution(oddFlag, 'output_motion_bad');

ra_even = [att_even.ra];
ra_even = ra_even - ra_even(1);
ra_odd = [att_odd.ra];
ra_odd = ra_odd - ra_odd(1);

ra_diff = ra_even - ra_odd;

dec_even = [att_even.dec];
dec_even = dec_even - dec_even(1);
dec_odd = [att_odd.dec];
dec_odd = dec_odd - dec_odd(1);

dec_diff = dec_even - dec_odd;

phi_even = [att_even.phi];
phi_even = phi_even - phi_even(1);
phi_odd = [att_odd.phi];
phi_odd = phi_odd - phi_odd(1);

phi_diff = phi_even - phi_odd;

figure(3);
subplot(1,3,1);
plot([ra_even' ra_odd']);
title('inconsistent jitter: ra');
legend('even', 'odd');

subplot(1,3,2);
plot([dec_even' dec_odd']);
title('inconsistent jitter: dec');

subplot(1,3,3);
plot([phi_even' phi_odd']);
title('inconsistent jitter: phi');

figure(4);
plot([ra_diff' dec_diff' phi_diff']);
title('inconsistent jitter: difference between even and odd estimate');
legend('ra', 'dec', 'phi');
end
