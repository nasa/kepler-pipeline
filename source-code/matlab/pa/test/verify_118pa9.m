function verify_118pa9
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_118pa9
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute and plot the standard deviation of the motion polynomial fit
% residuals and the max fit residual for each cadence. Then plot the
% residuals in the motion polynomial fits for each cadence for the
% pipeline run with zodi on (TC02). Note that the motion polynomials are
% generally only fit to the targets with the 'PPA_STELLAR' label.
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

ZODI_ON_TASK_DIR  = ['TC02' filesep 'pa-matlab-34-2634'];
TCPATH = [filesep,'release-5.0',filesep,'monthly',filesep];

if ispc
    TCPATH = [filesep,TCPATH];
end

TC02DIR = [TCPATH,ZODI_ON_TASK_DIR];


cd(TC02DIR);

STATEFILE = 'pa_state.mat';
load(STATEFILE, 'ppaTargetStarResultsStruct');

RA_HOURS_TO_DEGREES = 360 / 24;
targetRa = RA_HOURS_TO_DEGREES * [ppaTargetStarResultsStruct.raHours]';
targetDec = [ppaTargetStarResultsStruct.decDegrees]';

centroidRowTimeSeries = ...
    [ppaTargetStarResultsStruct.centroidRowTimeSeries];
centroidRows = [centroidRowTimeSeries.values];
gapArray = [centroidRowTimeSeries.gapIndicators];
clear centroidRowTimeSeries

centroidColumnTimeSeries = ...
    [ppaTargetStarResultsStruct.centroidColumnTimeSeries];
centroidColumns = [centroidColumnTimeSeries.values];
clear centroidColumnTimeSeries
clear ppaTargetStarResultsStruct

nCadences = size(centroidRows, 1);

MOTIONFILE = 'pa_motion.mat';
load(MOTIONFILE);
motionPolyStruct = inputStruct;
clear inputStruct;

rowResiduals = cell([1, nCadences]);
columnResiduals = cell([1, nCadences]);
sigmaRowResiduals = zeros([nCadences, 1]);
sigmaColumnResiduals = zeros([nCadences, 1]);
maxRowResidual = zeros([nCadences, 1]);
maxColumnResidual = zeros([nCadences, 1]);

for iCadence = 1 : nCadences
    centroidRowValues = centroidRows(iCadence, : )';
    centroidColumnValues = centroidColumns(iCadence, : )';
    gapIndicators = gapArray(iCadence, : )';
    [centroidRowEstimates] = weighted_polyval2d(targetRa, targetDec, ...
        motionPolyStruct(iCadence).rowPoly);
    [centroidColumnEstimates] = weighted_polyval2d(targetRa, targetDec, ...
        motionPolyStruct(iCadence).colPoly);
    rowResiduals{iCadence} = ...
        centroidRowValues(~gapIndicators) - centroidRowEstimates(~gapIndicators);
    sigmaRowResiduals(iCadence) = std(rowResiduals{iCadence});
    maxRowResidual(iCadence) = max(abs(rowResiduals{iCadence}));
    columnResiduals{iCadence} = ...
        centroidColumnValues(~gapIndicators) - centroidColumnEstimates(~gapIndicators);
    sigmaColumnResiduals(iCadence) = std(columnResiduals{iCadence});
    maxColumnResidual(iCadence) = max(abs(columnResiduals{iCadence}));
end

close all;
plot(sigmaRowResiduals, 'b');
hold on
plot(sigmaColumnResiduals, 'r');
plot(maxRowResidual, 'g');
plot(maxColumnResidual, 'm');
hold off
title('[PA] Motion Polynomial Fit Residual Sigma and Max');
xlabel('Cadence');
ylabel('Residual Sigma/Max (Pixels)');
legend('Row Sigma', 'Column Sigma', 'Row Max', 'Column Max');
grid
pause

for iCadence = 1 : nCadences
    gapIndicators = gapArray(iCadence, : )';
    plot3(targetRa(~gapIndicators), targetDec(~gapIndicators), ...
        rowResiduals{iCadence}, '.b');
    hold on
    plot3(targetRa(~gapIndicators), targetDec(~gapIndicators), ...
        columnResiduals{iCadence}, '.r');
    hold off
    title(['[PA] Motion Fit Residuals -- Cadence ', num2str(iCadence), ' / Order ', ...
        num2str(motionPolyStruct(iCadence).rowPoly.order), '-', ...
        num2str(motionPolyStruct(iCadence).colPoly.order)]);
    xlabel('Target Ra (deg)');
    ylabel('Target Dec (deg)');
    zlabel('Residual (Pixels)');
    pause(1)
    
    plot(columnResiduals{iCadence}, rowResiduals{iCadence}, '.')
    title('[PA] Motion Polynomial Fit Residuals');
    xlabel('Column Residual (Pixels)');
    ylabel('Row Residual (Pixels)');
    grid
    pause(1)
end

return
