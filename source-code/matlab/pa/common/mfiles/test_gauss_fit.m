load gauss_fit_nogaps.mat
load /disk2/ETEM_output/30_min_cadence/run1000/Ajit_run1000.mat

%%
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
tic;
[moduleOutputMotionPolyStruct, gaussOutputMotionPolyStruct] = ...
    module_output_gauss_fit_motion(targetStructGaussFit, 5);
toc;

%%
row = 550;
column = 512;

pointingRow = weighted_polyval2d(row, column, [moduleOutputMotionPolyStruct.rowCoeff])';
pointingColumn = weighted_polyval2d(row, column, [moduleOutputMotionPolyStruct.columnCoeff])';

pointingRow = pointingRow - pointingRow(1);
pointingColumn = pointingColumn - pointingColumn(1);

gaussRow = weighted_polyval2d(row, column, [gaussOutputMotionPolyStruct.rowCoeff])';
gaussColumn = weighted_polyval2d(row, column, [gaussOutputMotionPolyStruct.columnCoeff])';

gaussRow = gaussRow - gaussRow(1);
gaussColumn = gaussColumn - gaussColumn(1);

nCadences = length(moduleOutputMotionPolyStruct);

ajit = Ajit_Cell{3,3};
ajitMotionColumn = (ajit(1:nCadences,2) - ajit(1,2))./ajit(1:nCadences,1);
ajitMotionRow = (ajit(1:nCadences,3) - ajit(1,3))./ajit(1:nCadences,1);

figure(1);
plot(1:nCadences, pointingRow, 1:nCadences, gaussRow, 1:nCadences, ajitMotionRow);
title('row pointing offset');
legend('flux-weighted centroid', 'gaussian fit', 'from Ajit');

figure(2);
plot(1:nCadences, pointingColumn, 1:nCadences, gaussColumn, 1:nCadences, ajitMotionColumn);
title('column pointing offset');
legend('flux-weighted centroid', 'gaussian fit', 'from Ajit');
