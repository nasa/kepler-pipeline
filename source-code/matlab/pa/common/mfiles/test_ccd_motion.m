
function test_ccd_motion(motionPolyGaps, moduleOutputMotionPolyStruct)
% compare my centroids with ajit
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

% motionStructReconstructed = blob_to_struct(motionBlobStruct, 1, 700);
% moduleOutputMotionPolyStruct = motionStructReconstructed;
load /path/to/ETEM/Results/run1000/Ajit_run1000.mat

row = 550;
column = 512;

pointingRow = weighted_polyval2d(row, column, [moduleOutputMotionPolyStruct.rowCoeff])';
pointingColumn = weighted_polyval2d(row, column, [moduleOutputMotionPolyStruct.columnCoeff])';

gapRow = weighted_polyval2d(row, column, [motionPolyGaps.rowCoeff])';
gapColumn = weighted_polyval2d(row, column, [motionPolyGaps.columnCoeff])';

pointingRow = pointingRow - pointingRow(1);
pointingColumn = pointingColumn - pointingColumn(1);

gapRow = gapRow - gapRow(1);
gapColumn = gapColumn - gapColumn(1);

nCadences = length(moduleOutputMotionPolyStruct);

ajit = Ajit_Cell{3,3};
ajitMotionColumn = (ajit(1:nCadences,2) - ajit(1,2))./ajit(1:nCadences,1);
ajitMotionRow = (ajit(1:nCadences,3) - ajit(1,3))./ajit(1:nCadences,1);


figure(1);
plot(1:nCadences, ajitMotionRow, 1:nCadences, pointingRow, 1:nCadences, gapRow);
title('row pointing offset');
legend('injected jitter signal', 'from motion polynomial', 'from motion polynomial with gaps');
xlabel('cadence');
ylabel('row');

figure(2);
plot(1:nCadences, ajitMotionColumn, 1:nCadences, pointingColumn, 1:nCadences, gapColumn);
title('column pointing offset');
legend('injected jitter signal', 'from motion polynomial', 'from motion polynomial with gaps');
xlabel('cadence');
ylabel('column');

ajitRowTrend = polyval(polyfit(1:nCadences, ajitMotionRow', 5), 1:nCadences);
ajitColTrend = polyval(polyfit(1:nCadences, ajitMotionColumn', 5), 1:nCadences);
pointRowTrend = polyval(polyfit(1:nCadences, pointingRow', 5), 1:nCadences);
pointColTrend = polyval(polyfit(1:nCadences, pointingColumn', 5), 1:nCadences);
gapRowTrend = polyval(polyfit(1:nCadences, gapRow', 5), 1:nCadences);
gapColTrend = polyval(polyfit(1:nCadences, gapColumn', 5), 1:nCadences);

ajitRowJit = ajitMotionRow - ajitRowTrend';
ajitColJit = ajitMotionColumn - ajitColTrend';
pointRowJit = pointingRow - pointRowTrend';
pointColJit = pointingColumn - pointColTrend';
gapRowJit = gapRow - gapRowTrend';
gapColJit = gapColumn - gapColTrend';

figure(4)
subplot(1,2,1)
plot(1:nCadences, ajitRowJit, 1:nCadences, pointRowJit, 1:nCadences, gapRowJit);
title('row pointing jitter');
xlabel('cadence');
ylabel('row');
subplot(1,2,2)
plot(1:nCadences, ajitColJit, 1:nCadences, pointColJit, 1:nCadences, gapColJit);
title('column pointing jitter');
xlabel('cadence');
ylabel('column');
legend('injected jitter signal', 'from motion polynomial', 'from motion polynomial with gaps');

rowErr = ajitRowJit - pointRowJit;
gapRowErr = ajitRowJit - gapRowJit;
colErr = ajitColJit - pointColJit;
gapColErr = ajitColJit - gapColJit;

figure(5)
subplot(1,2,1)
plot(1:nCadences, rowErr, 1:nCadences, gapRowErr);
title('row pointing jitter error');
xlabel('cadence');
ylabel('row');
subplot(1,2,2)
plot(1:nCadences, colErr, 1:nCadences, gapColErr);
title('column pointing jitter error');
legend('injected jitter signal', 'from motion polynomial', 'from motion polynomial with gaps');
ylabel('column');
xlabel('cadence');

