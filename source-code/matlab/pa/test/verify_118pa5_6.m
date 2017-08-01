function verify_118pa5_6(invocation,cadenceType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_118pa5_6(invocation,cadenceType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the centroid row time series for all targets in the TC02 test data
% set, the uncertainties in the centroid row time series for all targets,
% the centroid column time series for all targets and the uncertainties in
% the centroid column time series for all targets. Then plot the RMS
% centroid uncertainty vs sigma flux for the row and column centroids for
% each target. Then for each target, overlay all valid centroids on a 2D
% plot of the mean flux for each pixel in the target aperture.
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
LC_PATH = [filesep,'release-5.0',filesep,'monthly',filesep];
SC_PATH = 'TBD_SC_PATH';

if( strcmpi(cadenceType, 'long') )
    TCPATH = LC_PATH;
elseif( strcmpi(cadenceType, 'short') )
        TCPATH = SC_PATH;
else
    disp(['Cadence type ',cadenceType,' is invalid. Type must be *short* or *long*.']);
    return;
end

if ispc
    TCPATH = [filesep,TCPATH];
end

TC02DIR = [TCPATH,filesep,ZODI_ON_TASK_DIR];

fileName = ['pa-outputs-', num2str(invocation), '.mat'];

cd(TC02DIR);
load(fileName);
zodiOnResultsStruct = outputsStruct;
clear outputsStruct

centroidRowTimeSeries = ...
    [zodiOnResultsStruct.targetStarResultsStruct.centroidRowTimeSeries];
centroidRowValues = 1 + [centroidRowTimeSeries.values];
centroidRowUncertainties = [centroidRowTimeSeries.uncertainties];
centroidRowGapIndicators = [centroidRowTimeSeries.gapIndicators];
clear centroidRowTimeSeries

nTargets = size(centroidRowValues, 2);
rmsCentroidRowUncertainties = zeros([nTargets, 1]);
sigmaCentroidRowValues = zeros([nTargets, 1]);

for iTarget = 1 : nTargets
    values = centroidRowValues( : , iTarget);
    uncertainties = centroidRowUncertainties( : , iTarget);
    gaps = centroidRowGapIndicators( : , iTarget);
    if sum(~gaps) > 2
        rmsCentroidRowUncertainties(iTarget) = sqrt(mean(uncertainties(~gaps) .^ 2));
        sigmaCentroidRowValues(iTarget) = std(values(~gaps));
    end
end

close all;
centroidRowValues(centroidRowGapIndicators) = NaN;
plot(centroidRowValues);
title('[PA] Centroid Row Values');
xlabel('Cadence');
ylabel('Centroid (1-based)');
pause

centroidRowUncertainties(centroidRowGapIndicators) = NaN;
plot(centroidRowUncertainties);
title('[PA] Centroid Row Uncertainties');
xlabel('Cadence');
ylabel('Uncertainty (pixels)');
pause

centroidColumnTimeSeries = ...
    [zodiOnResultsStruct.targetStarResultsStruct.centroidColumnTimeSeries];
centroidColumnValues = 1 + [centroidColumnTimeSeries.values];
centroidColumnUncertainties = [centroidColumnTimeSeries.uncertainties];
centroidColumnGapIndicators = [centroidColumnTimeSeries.gapIndicators];
clear centroidColumnTimeSeries

rmsCentroidColumnUncertainties = zeros([nTargets, 1]);
sigmaCentroidColumnValues = zeros([nTargets, 1]);
isValid = false([nTargets, 1]);

for iTarget = 1 : nTargets
    values = centroidColumnValues( : , iTarget);
    uncertainties = centroidColumnUncertainties( : , iTarget);
    gaps = centroidColumnGapIndicators( : , iTarget);
    if sum(~gaps) > 2
        rmsCentroidColumnUncertainties(iTarget) = sqrt(mean(uncertainties(~gaps) .^ 2));
        sigmaCentroidColumnValues(iTarget) = std(values(~gaps));
        isValid(iTarget) = true;
    end
end

centroidColumnValues(centroidColumnGapIndicators) = NaN;
plot(centroidColumnValues);
title('[PA] Centroid Column Values');
xlabel('Cadence');
ylabel('Centroid (1-based)');
pause

centroidColumnUncertainties(centroidColumnGapIndicators) = NaN;
plot(centroidColumnUncertainties);
title('[PA] Centroid Column Uncertainties');
xlabel('Cadence');
ylabel('Uncertainty (pixels)');
pause

plot(rmsCentroidRowUncertainties(isValid), sigmaCentroidRowValues(isValid), '.b')
hold on
plot(rmsCentroidColumnUncertainties(isValid), sigmaCentroidColumnValues(isValid), '.r')
title('[PA] RMS Centroid Uncertainties & Centroid Sigmas');
xlabel('RMS Uncertainty (Pixels)');
ylabel('Centroid Sigma (Pixels)');
legend('Row Centroids', 'Column Centroids', 'Location', 'Northwest');
grid
x = axis;
minAxis = min(x);
maxAxis = max(x);
plot([minAxis; maxAxis], [minAxis; maxAxis], 'k');
pause

fileName = ['pa-inputs-', num2str(invocation), '.mat'];
load(fileName);
zodiOnDataStruct = inputsStruct;
clear inputsStruct

for iTarget = 1 : nTargets
    hold off;
    keplerId = zodiOnDataStruct.targetStarDataStruct(iTarget).keplerId;
    pixelDataStruct = ...
        zodiOnDataStruct.targetStarDataStruct(iTarget).pixelDataStruct;
    ccdRows = 1 + [pixelDataStruct.ccdRow]';
    ccdColumns = 1 + [pixelDataStruct.ccdColumn]';
    pixelValues = [pixelDataStruct.values];
    gapArray = [pixelDataStruct.gapIndicators];
    pixelValues(gapArray) = 0;
    nValues = sum(~gapArray, 1)';
    meanValues = sum(pixelValues, 1)' ./ nValues;
    isValid = nValues > 0;
    meanValues(~isValid) = 0;
    minRow = min(ccdRows);
    maxRow = max(ccdRows);
    minCol = min(ccdColumns);
    maxCol = max(ccdColumns);
    nRows = maxRow - minRow + 1;
    nColumns = maxCol - minCol + 1;
    aperturePixelValues = zeros([nRows, nColumns]);
    aperturePixelIndices = sub2ind([nRows, nColumns], ...
        ccdRows - minRow + 1, ...
        ccdColumns - minCol + 1);
    aperturePixelValues(aperturePixelIndices) = meanValues;
    imagesc([minCol; maxCol], [minRow; maxRow], aperturePixelValues);
    set(gca, 'YDir', 'normal');
    colorbar;
    title(['[PA] Mean Pixel Values -- Kepler Id ', num2str(keplerId)]);
    xlabel('CCD Column');
    ylabel('CCD Row');
    
    hold on;
    plot(centroidColumnValues, centroidRowValues, 'xw', ...
        'MarkerSize', 10, 'LineWidth', 3)
    pause(1)
end

return
