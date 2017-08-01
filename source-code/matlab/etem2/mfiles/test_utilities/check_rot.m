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
modules = 11:15;
output_jittests = [3 3 3 1 1];
for mod=1:length(modules)
	filename = ['output_jittest/run_long_m' num2str(modules(mod)) 'o' num2str(output_jittests(mod)) 's1/motionBasis.mat'];
	load(filename);
	dm = motionBasis1(3,3).designMatrix;
	c = dm(1,1);
	eval(['m' num2str(modules(mod)) 'x = dm(:,2)/c - dm(1,2)/c']);
	eval(['m' num2str(modules(mod)) 'y = dm(:,3)/c - dm(1,3)/c']);
end
figure
plot(m11x, m11y, '+', m12x, m12y, '+', m13x, m13y, '+', m14x, m14y, '+', m15x, m15y);
%%
modules = 11:15;
output_jittests = [3 3 3 1 1];
for mod=1:length(modules)
	filename = ['output_jittest/run_long_m' num2str(modules(mod)) 'o' num2str(output_jittests(mod)) 's1/jitterMotion.mat'];
	load(filename, 'rowMotion', 'colMotion');
	eval(['m' num2str(modules(mod)) 'col = colMotion(1:100) - colMotion(1);']);
	eval(['m' num2str(modules(mod)) 'row = rowMotion(1:100) - rowMotion(1);']);



%	filename = ['output_jittest/run_long_m' num2str(modules(m)) 'o' num2str(output_jittests(m)) 's1/motionBasis.mat'];
%	load(filename);
%	dm = motionBasis1(3,3).designMatrix;
%	c = dm(1,1);
%	eval(['m' num2str(modules(m)) 'x = dm(:,2)/c - dm(1,2)/c']);
%	eval(['m' num2str(modules(m)) 'y = dm(:,3)/c - dm(1,3)/c']);
end
%figure
%plot(m11x, m11y, '+', m12x, m12y, '+', m13x, m13y, '+', m14x, m14y, '+', m15x, m15y);

figure(1);
subplot(2,1,1);
plot([m11col m12col m13col m14col m15col]);
legend('m11', 'm12', 'm13', 'm14', 'm15');
title('column jitter - phi only');
subplot(2,1,2);
plot([m11row m12row m13row m14row m15row]);
title('row jitter - phi only');

clear;

modules = [3 8 13 18 23];
output_jittests = [4 4 3 2 2];
for mod=1:length(modules)
	filename = ['output_jittest/run_long_m' num2str(modules(mod)) 'o' num2str(output_jittests(mod)) 's1/jitterMotion.mat'];
	load(filename, 'rowMotion', 'colMotion');
	eval(['m' num2str(modules(mod)) 'col = colMotion(1:100) - colMotion(1);']);
	eval(['m' num2str(modules(mod)) 'row = rowMotion(1:100) - rowMotion(1);']);
end

figure(2);
subplot(2,1,1);
plot([m3col m8col m13col m18col m23col]);
legend('m3', 'm8', 'm13', 'm18', 'm23');
title('column jitter - phi only');
subplot(2,1,2);
plot([m3row m8row m13row m18row m23row]);
title('row jitter - phi only');

clear;
module = 11;
for o=1:4
	filename = ['output_jittest/run_long_m' num2str(module) 'o' num2str(o) 's1/jitterMotion.mat'];
	load(filename, 'rowMotion', 'colMotion');
	eval(['o' num2str(o) 'col = colMotion(1:100) - colMotion(1);']);
	eval(['o' num2str(o) 'row = rowMotion(1:100) - rowMotion(1);']);
end

figure(3);
subplot(2,1,1);
plot([o1col o2col o3col o4col]);
legend('o1', 'o2', 'o3', 'o4');
title('column jitter - phi only');
subplot(2,1,2);
plot([o1row o2row o3row o4row]);
title('row jitter - phi only');

clear;
module = 2;
for o=1:4
	filename = ['output_jittest/run_long_m' num2str(module) 'o' num2str(o) 's1/jitterMotion.mat'];
	load(filename, 'rowMotion', 'colMotion');
	eval(['o' num2str(o) 'col = colMotion(1:100) - colMotion(1);']);
	eval(['o' num2str(o) 'row = rowMotion(1:100) - rowMotion(1);']);
end

figure(4);
subplot(2,1,1);
plot([o1col o2col o3col o4col]);
legend('o1', 'o2', 'o3', 'o4');
title('module 2 column jitter - ra/dec only');
subplot(2,1,2);
plot([o1row o2row o3row o4row]);
title('module 2 row jitter - ra/dec only');

%%
clear;
module = 24;
for o=1:4
	filename = ['output_jittest/run_long_m' num2str(module) 'o' num2str(o) 's1/jitterMotion.mat'];
	load(filename, 'rowMotion', 'colMotion', 'raMotion', 'decMotion');
	eval(['o' num2str(o) 'col = colMotion(1:100) - colMotion(1);']);
	eval(['o' num2str(o) 'row = rowMotion(1:100) - rowMotion(1);']);
	eval(['o' num2str(o) 'ra = raMotion(1:100) - raMotion(1);']);
	eval(['o' num2str(o) 'dec = decMotion(1:100) - decMotion(1);']);
end

figure(5);
subplot(2,1,1);
plot([o1col o2col o3col o4col]);
legend('o1', 'o2', 'o3', 'o4');
title('module 24 column jitter - ra/dec only');
subplot(2,1,2);
plot([o1row o2row o3row o4row]);
title('module 24 row jitter - ra/dec only');

figure(6);
subplot(2,1,1);
plot([o1ra o2ra o3ra o4ra]);
legend('o1', 'o2', 'o3', 'o4');
title('module 24 ra motion');
subplot(2,1,2);
plot([o1dec o2dec o3dec o4dec]);
title('module 24 dec motion');

