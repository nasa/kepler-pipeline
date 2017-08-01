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
nvals = 100;
module = 16;
for i=1:4
	eval(['load output/run_long_m' num2str(module) 'o' num2str(i) 's1/jitterData.mat;']);
    eval(['jRa' num2str(i) ' = jitterRa(1:nvals);']);
    eval(['jDec' num2str(i) ' = jitterDec(1:nvals);']);
    eval(['jPhi' num2str(i) ' = jitterPhi(1:nvals);']);
   
    
    eval(['load output/run_long_m' num2str(module) 'o' num2str(i) 's1/motionBasis.mat;']);
    eval(['m' num2str(i) ' = motionBasis1;']);
    c = motionBasis1(3,3).designMatrix(1,1);
    eval(['x' num2str(i) ' = motionBasis1(3,3).designMatrix(:,2)/c;']);
    eval(['y' num2str(i) ' = motionBasis1(3,3).designMatrix(:,3)/c;']);
    eval(['x' num2str(i) ' = x' num2str(i) ' - x' num2str(i) '(1);']);
    eval(['y' num2str(i) ' = y' num2str(i) ' - y' num2str(i) '(1);']);
    clear motionBasis1
end
%%
nvals = 100;
module = 16;
for i=1:4
	eval(['load output/run_long_m' num2str(module) 'o' num2str(i) 's1/jitterData.mat;']);
    eval(['jRa' num2str(i) ' = jitterRa(1:nvals);']);
    eval(['jDec' num2str(i) ' = jitterDec(1:nvals);']);
    eval(['jPhi' num2str(i) ' = jitterPhi(1:nvals);']);
   
    
    eval(['load output/run_long_m' num2str(module) 'o' num2str(i) 's1/jitterMotion.mat rowMotion colMotion;']);
    eval(['x' num2str(i) ' = colMotion;']);
    eval(['y' num2str(i) ' = rowMotion;']);
    eval(['x' num2str(i) ' = x' num2str(i) ' - x' num2str(i) '(1);']);
    eval(['y' num2str(i) ' = y' num2str(i) ' - y' num2str(i) '(1);']);
    clear motionBasis1
end
module = 10;
for i=1:2
	eval(['load output/run_long_m' num2str(module) 'o' num2str(i) 's1/jitterData.mat;']);
    eval(['jbRa' num2str(i) ' = jitterRa(1:nvals);']);
    eval(['jbDec' num2str(i) ' = jitterDec(1:nvals);']);
    eval(['jbPhi' num2str(i) ' = jitterPhi(1:nvals);']);
   
    
    eval(['load output/run_long_m' num2str(module) 'o' num2str(i) 's1/jitterMotion.mat rowMotion colMotion;']);
    eval(['xb' num2str(i) ' = colMotion;']);
    eval(['yb' num2str(i) ' = rowMotion;']);
    eval(['xb' num2str(i) ' = x' num2str(i) ' - x' num2str(i) '(1);']);
    eval(['yb' num2str(i) ' = y' num2str(i) ' - y' num2str(i) '(1);']);
    clear motionBasis1
end
%%
x = 1:nvals;
figure(1);
plot(x, x1(1:nvals), x, x2(1:nvals), x, x3(1:nvals), x, x4(1:nvals));
legend('1', '2', '3', '4');
figure(2);
plot(x, y1(1:nvals), x, y2(1:nvals), x, y3(1:nvals), x, y4(1:nvals));
legend('1', '2', '3', '4');

figure(3);
plot(x, jRa1(1:nvals), x, jRa2(1:nvals));
plot(x, jRa1(1:nvals), x, jRa2(1:nvals), x, jRa3(1:nvals), x, jRa4(1:nvals));

%%
x = 1:nvals;
figure(1);
subplot(1,2,1);
plot(x, x1(1:nvals), x, -x2(1:nvals), x, -x3(1:nvals), x, x4(1:nvals), x, xb1(1:nvals), x, -xb2(1:nvals));
title('column');
legend('1', '2', '3', '4', 'b1', 'b2');
subplot(1,2,2);
plot(x, x1(1:nvals) - (-x2(1:nvals)), x, x1(1:nvals) - (-x3(1:nvals)), ...
    x, x1(1:nvals) - (x4(1:nvals)), x, -x2(1:nvals) - (-x3(1:nvals)), ...
    x, -x2(1:nvals) - (x4(1:nvals)), x, -x3(1:nvals) - (x4(1:nvals)), ...
    x, x1(1:nvals) - xb1(1:nvals));
title('column');
legend('1-2', '1-3', '1-4', '2-3', '2-4', '3-4', '1-b1');

figure(2);
subplot(1,2,1);
plot(x, y1(1:nvals), x, y2(1:nvals), x, -y3(1:nvals), x, -y4(1:nvals), x, yb1(1:nvals), x, yb2(1:nvals));
title('row');
legend('1', '2', '3', '4', 'b1', 'b2');
subplot(1,2,2);
plot(x, y1(1:nvals) - y2(1:nvals), x, y1(1:nvals) - (-y3(1:nvals)),...
     x, y1(1:nvals) - (-y4(1:nvals)), x, y2(1:nvals) - (-y3(1:nvals)), ...
     x, y2(1:nvals) - (-y4(1:nvals)), x, -y3(1:nvals) - (-y4(1:nvals)), ...
     x, y1(1:nvals) - yb1(1:nvals));
title('row');
legend('1-2', '1-3', '1-4', '2-3', '2-4', '3-4', '1-b1');

figure(3);
subplot(1,3,1);
plot(x, jRa1(1:nvals), x, jRa2(1:nvals), x, jRa3(1:nvals));
title('ra');
subplot(1,3,2);
plot(x, jDec1(1:nvals), x, jDec2(1:nvals), x, jDec3(1:nvals));
title('dec');
subplot(1,3,3);
plot(x, jPhi1(1:nvals), x, jPhi2(1:nvals), x, jPhi3(1:nvals));
title('phi');

%%
module = 10;
nfiles = 2;
for i=1:nfiles
	filename = ['output/run_long_m' num2str(module) 'o' num2str(i) 's1/jitterMotion.mat'];
	load(filename, 'DrowDra', 'DcolDra', 'DrowDdec', 'DcolDdec', 'DrowDphi', 'DcolDphi');
	
    eval(['DrDra(' num2str(i) ') = DrowDra;']);
    eval(['DcDra(' num2str(i) ') = DcolDra;']);
    eval(['DrDdec(' num2str(i) ') = DrowDdec;']);
    eval(['DcDdec(' num2str(i) ') = DcolDdec;']);
    eval(['DrDphi(' num2str(i) ') = DrowDphi;']);
    eval(['DcDphi(' num2str(i) ') = DcolDphi;']);
end

disp('rows');
for i=1:nfiles
	disp(['output ' num2str(i) ' dr/ra = ' num2str(DrDra(i)) '.']);
end
for i=1:nfiles
	disp(['output ' num2str(i) ' dr/dec = ' num2str(DrDdec(i)) '.']);
end
for i=1:nfiles
	disp(['output ' num2str(i) ' dr/phi = ' num2str(DrDphi(i)) '.']);
end
disp('columns');
for i=1:nfiles
	disp(['output ' num2str(i) ' dc/ra = ' num2str(DcDra(i)) '.']);
end
for i=1:nfiles
	disp(['output ' num2str(i) ' dc/dec = ' num2str(DcDdec(i)) '.']);
end
for i=1:nfiles
	disp(['output ' num2str(i) ' dc/phi = ' num2str(DcDphi(i)) '.']);
end

%%
% module 6 and 20 output 3: roll jitter only
% module 6 and 20 output 4: ra/dec jitter only
module = 6;
output = 3;

filename = ['output/run_long_m' num2str(module) 'o' num2str(output) 's1/motionBasis.mat'];
load(filename);
dm = motionBasis1(3,3).designMatrix;
c = dm(1,1);
m6x = dm(:,2)/c - dm(1,2)/c;
m6y = dm(:,3)/c - dm(1,3)/c;

module = 20;
filename = ['output/run_long_m' num2str(module) 'o' num2str(output) 's1/motionBasis.mat'];
load(filename);
dm = motionBasis1(3,3).designMatrix;
c = dm(1,1);
m20x = dm(:,2)/c - dm(1,2)/c;
m20y = dm(:,3)/c - dm(1,3)/c;

figure
plot(m6x, m6y, '+', m20x, m20y, '+');

