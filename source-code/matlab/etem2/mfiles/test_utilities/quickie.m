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
load modOut.mat
figure
hold on;
for i=1:84
	plot(modOut(i).cornerRa, modOut(i).cornerDec, 'r--');
	quiver(modOut(i).initRa, modOut(i).initDec, modOut(i).deltaRa, modOut(i).deltaDec, 0.8);
	text(mean(modOut(i).cornerRa), mean(modOut(i).cornerDec), num2str(i));
end
hold off
set(gca, 'YDir', 'reverse');
title('motion at each of the 5x5 points per mod out');


figure
hold on;
for i=1:84
	plot(modOut(i).cornerRa, modOut(i).cornerDec, 'r--');
	quiver(mean(mean(modOut(i).initRa)), mean(mean(modOut(i).initDec)), mean(mean(modOut(i).deltaRa)), mean(mean(modOut(i).deltaDec)), 1e5);
	text(mean(modOut(i).cornerRa), mean(modOut(i).cornerDec), num2str(i));
end
hold off
set(gca, 'YDir', 'reverse');
title('average motion per mod out');

clear
load modOutJitter.mat
figure
hold on;
for i=1:84
	plot(modOut(i).cornerRa, modOut(i).cornerDec, 'r--');
	quiver(modOut(i).initRa, modOut(i).initDec, modOut(i).deltaRa, modOut(i).deltaDec, 1e5);
	text(mean(modOut(i).cornerRa), mean(modOut(i).cornerDec), num2str(i));
end
hold off
set(gca, 'YDir', 'reverse');
title('jitter motion per mod out, first entry');

clear
load modOutDva.mat
figure
hold on;
for i=1:84
	plot(modOut(i).cornerRa, modOut(i).cornerDec, 'r--');
	quiver(modOut(i).initRa, modOut(i).initDec, modOut(i).deltaRa, modOut(i).deltaDec, 0.8);
	text(mean(modOut(i).cornerRa), mean(modOut(i).cornerDec), num2str(i));
end
hold off
set(gca, 'YDir', 'reverse');
title('motion from RaDec2Pix per mod out');

figure
hold on;
for i=1:84
	plot(modOut(i).cornerRa, modOut(i).cornerDec, 'r--');
	quiver(modOut(i).initRa, modOut(i).initDec, modOut(i).newDeltaRa, modOut(i).newDeltaDec, 0.8);
	text(mean(modOut(i).cornerRa), mean(modOut(i).cornerDec), num2str(i));
end
hold off
set(gca, 'YDir', 'reverse');
title('motion from RaDec2Pix per mod out');

