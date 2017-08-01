function plot_pa_centroids_mp_residuals_and_quivers(startCadenceForQuivers, manualPauseFlag)
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

PAUSE_SECS = 0.1;
SCALE = 1000 / 1;
RA_HOURS_TO_DEGREES = 360 / 24;

if ~exist('startCadenceForQuivers', 'var')
    startCadenceForQuivers = 1;
end

if ~exist('manualPauseFlag', 'var')
    manualPauseFlag = false;
end

load pa_state.mat ppaTargetStarResultsStruct ...
    rowRobustWeightArray columnRobustWeightArray
load pa_motion.mat
motionPolyStruct = inputStruct;
clear inputStruct

ccdModule = motionPolyStruct(1).module;
ccdOutput = motionPolyStruct(1).output;
rowOrder = motionPolyStruct(1).rowPoly.order;
columnOrder = motionPolyStruct(1).colPoly.order;

% NOTE: centroids from PA state file and motion polynomials are 1-based
prfCentroids = [ppaTargetStarResultsStruct.prfCentroids];
centroidRowTimeSeriesArray = ...
    [prfCentroids.rowTimeSeries];
centroidColumnTimeSeriesArray = ...
    [prfCentroids.columnTimeSeries];
clear prfCentroids

centroidRows = [centroidRowTimeSeriesArray.values];
centroidRowUncertainties = [centroidRowTimeSeriesArray.uncertainties];
centroidColumns = [centroidColumnTimeSeriesArray.values];
centroidColumnUncertainties = [centroidColumnTimeSeriesArray.uncertainties];
gapArray = [centroidRowTimeSeriesArray.gapIndicators];

rowResiduals = zeros(size(centroidRows));
columnResiduals = zeros(size(centroidColumns));

targetRa = RA_HOURS_TO_DEGREES * [ppaTargetStarResultsStruct.raHours]';
targetDec = [ppaTargetStarResultsStruct.decDegrees]';

nCadences = length(motionPolyStruct);
for iCadence = 1 : nCadences
    centroidRowValues = centroidRows(iCadence, : )';
    centroidColumnValues = centroidColumns(iCadence, : )';
    gapIndicators = gapArray(iCadence, : )';
    [centroidRowEstimates] = weighted_polyval2d(targetRa, targetDec, ...
        motionPolyStruct(iCadence).rowPoly);
    [centroidColumnEstimates] = weighted_polyval2d(targetRa, targetDec, ...
        motionPolyStruct(iCadence).colPoly);
    rowResiduals(iCadence, ~gapIndicators) = ...
        (centroidRowValues(~gapIndicators) - centroidRowEstimates(~gapIndicators))';
    columnResiduals(iCadence, ~gapIndicators) = ...
        (centroidColumnValues(~gapIndicators) - centroidColumnEstimates(~gapIndicators))';
end % for iCadence

weightedRowResiduals = rowResiduals .* rowRobustWeightArray;
weightedColumnResiduals = columnResiduals .* columnRobustWeightArray;

hold off
centroidRows2 = centroidRows;
centroidRows2(rowRobustWeightArray < eps) = NaN;
plot(centroidRows2-repmat(nanmean(centroidRows2), [nCadences, 1]))
title(['[PA] PPA\_STELLAR Row Centroids (Mean Subtracted) -- Module Output ', ...
        num2str(ccdModule), '/', num2str(ccdOutput)]);
xlabel('Cadence')
ylabel('Centroid (Pixels)')
grid
pause

centroidColumns2 = centroidColumns;
centroidColumns2(columnRobustWeightArray < eps) = NaN;
plot(centroidColumns2-repmat(nanmean(centroidColumns2), [nCadences, 1]))
title(['[PA] PPA\_STELLAR Column Centroids (Mean Subtracted) -- Module Output ', ...
        num2str(ccdModule), '/', num2str(ccdOutput)]);
xlabel('Cadence')
ylabel('Centroid (Pixels)')
grid
pause

centroidRowUncertainties2 = centroidRowUncertainties;
centroidRowUncertainties2(rowRobustWeightArray < eps) = NaN;
plot(centroidRowUncertainties2)
title(['[PA] PPA\_STELLAR Row Centroid Uncertainties -- Module Output ', ...
        num2str(ccdModule), '/', num2str(ccdOutput)]);
xlabel('Cadence')
ylabel('Centroid Uncertainty (Pixels)')
grid
pause

centroidColumnUncertainties2 = centroidColumnUncertainties;
centroidColumnUncertainties2(columnRobustWeightArray < eps) = NaN;
plot(centroidColumnUncertainties2)
title(['[PA] PPA\_STELLAR Column Centroid Uncertainties -- Module Output ', ...
        num2str(ccdModule), '/', num2str(ccdOutput)]);
xlabel('Cadence')
ylabel('Centroid Uncertainty (Pixels)')
grid
pause

rowResiduals2 = rowResiduals;
rowResiduals2(rowRobustWeightArray < eps) = NaN;
plot(rowResiduals2)
title(['[PA] PPA\_STELLAR Motion Polynomial Row Fit Residuals -- Module Output ', ...
        num2str(ccdModule), '/', num2str(ccdOutput)]);
xlabel('Cadence')
ylabel('Residual (Pixels)')
grid
pause

columnResiduals2 = columnResiduals;
columnResiduals2(columnRobustWeightArray < eps) = NaN;
plot(columnResiduals2)
title(['[PA] PPA\_STELLAR Motion Polynomial Column Fit Residuals -- Module Output ', ...
        num2str(ccdModule), '/', num2str(ccdOutput)]);
xlabel('Cadence')
ylabel('Residual (Pixels)')
grid
pause

for iCadence = startCadenceForQuivers : nCadences
    if ~motionPolyStruct(iCadence).rowPolyStatus
        continue
    end
    centroidRowValues = centroidRows(iCadence, : )';
    centroidColumnValues = centroidColumns(iCadence, : )';
    gapIndicators = gapArray(iCadence, : )';
    rowResidualValues = rowResiduals(iCadence, : )';
    columnResidualValues = columnResiduals(iCadence, : )';
    weightedRowResidualValues = weightedRowResiduals(iCadence, : )';
    weightedColumnResidualValues = weightedColumnResiduals(iCadence, : )';
    hold off
    quiver(centroidColumnValues(~gapIndicators), centroidRowValues(~gapIndicators), ...
        SCALE * columnResidualValues(~gapIndicators), SCALE * rowResidualValues(~gapIndicators), ...
        0, 'b')
    hold on
    quiver(centroidColumnValues(~gapIndicators), centroidRowValues(~gapIndicators), ...
        SCALE * weightedColumnResidualValues(~gapIndicators), SCALE * weightedRowResidualValues(~gapIndicators), ...
        0, 'r')
    title(['[PA] PPA\_STELLAR Motion Polynomial Fit Residuals -- Cadence ', num2str(iCadence), ' / Order ', ...
        num2str(rowOrder), '-', num2str(columnOrder)]);
    xlabel('CCD Column (pixels)');
    ylabel('CCD Row (pixels)');
    grid
    legend('Unweighted Residuals (scale 1000:1)', 'Robust Weighted Residuals (scale 1000:1)')
    if manualPauseFlag
        pause
    else
        pause(PAUSE_SECS)
    end
end % for iCadence

return
