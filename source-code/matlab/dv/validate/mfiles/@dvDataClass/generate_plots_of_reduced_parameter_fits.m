function generate_plots_of_reduced_parameter_fits(dvDataObject, dvResultsStruct, iTarget, iPlanet)
% function generate_plots_of_reduced_parameter_fits(dvDataObject, dvResultsStruct, iTarget, iPlanet)
%
% This function generates the plots of model chi squares and fitted parameters (transitEpochBkjd, orbitalPeriodDays, ratioPlanetRadiusToStarRadius, ratioSemimajorAxisToStarRadius)
% of reduced parameter fits vs. impact parameters. The fit result with the minimum model chi square is set as the seed of allTransitsFit and labeled as red stars in the plots. 
% The plots will be incorporated into the DV report.
%
% Version date:  2014-December-23.
%
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

% Modification History:
%
%    2014-December-23, JL:
%        Retrieve keplerId from dvResultsStruct
%    2014-October-14, JL:
%        Update captions of diagnostic plots
%    2012-November-08, JL:
%        Update plot label and caption
%    2012-July-16, JL:
%        Use red dash line to indicate the fit with minimum chiSquare
%    2012-July-02, JL:
%        Initial release.
%
%=========================================================================================

% Get keplerId of the target

keplerId      = dvResultsStruct.targetResultsStruct(iTarget).keplerId;

% Make a folder for the plots of reduced parameter fits 

directory     = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
planetFolder  = sprintf('planet-%02d', iPlanet);
fitFolder     = 'reduced-parameter-fits';
fullDirectory = fullfile( directory, planetFolder, 'planet-search-and-model-fitting-results', fitFolder );
if ~exist(fullDirectory, 'dir')
    mkdir(fullDirectory);
end

% Set file name of the plots

allPlotHandles = [];
fitFilename = '-reduced-fits-';

% Determine the valid reduced parameter fits (modelChiSquare>0) and the fit with the minimum chi square

reducedParameterFits      = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).reducedParameterFits;
modelChiSquareArray       = [reducedParameterFits.modelChiSquare];
validReducedParameterFits = reducedParameterFits(modelChiSquareArray>0);
validChiSquareArray       = modelChiSquareArray(modelChiSquareArray>0);

nValidFits = length(validReducedParameterFits);
if nValidFits==0
    return
end

[ignored, minIndex] = min(validChiSquareArray);

% Retrieve fitted parameters and uncertainties of the valid reduced parameter fits

parameterMatrix   = [];
uncertaintyMatrix = [];
for i=1:nValidFits
    parameterArray    = [ validReducedParameterFits(i).modelParameters.value       ];
    uncertaintyArray  = [ validReducedParameterFits(i).modelParameters.uncertainty ];
    parameterMatrix   = [ parameterMatrix   parameterArray(:)   ];
    uncertaintyMatrix = [ uncertaintyMatrix uncertaintyArray(:) ];
end

% Get indices of fitted parameters

modelParameterNames  = {reducedParameterFits(minIndex).modelParameters.name};
indexImpactParameter = find(strcmp('minImpactParameter',             modelParameterNames));
indexTransitEpoch    = find(strcmp('transitEpochBkjd',               modelParameterNames));
indexOrbitalPeriod   = find(strcmp('orbitalPeriodDays',              modelParameterNames));
indexRpOverRstar     = find(strcmp('ratioPlanetRadiusToStarRadius',  modelParameterNames));
indexAOverRstar      = find(strcmp('ratioSemiMajorAxisToStarRadius', modelParameterNames));

% Plot model chi squares vs. impact parameters

plotHandle = figure;
plot(parameterMatrix(indexImpactParameter, :), validChiSquareArray, '.-', 'MarkerSize', 18);
hold on;
yLim = get(gca, 'yLim');
plot(parameterMatrix(indexImpactParameter, minIndex)*[1 1], [yLim(1) yLim(2)], 'r--');
plot(parameterMatrix(indexImpactParameter, :), validChiSquareArray, '.-', 'MarkerSize', 18);
% plot(parameterMatrix(indexImpactParameter, minIndex), validChiSquareArray(minIndex), 'ro', 'MarkerSize', 10);
hold off;
axis([0 1 yLim(1) yLim(2)]);
title(['Planet #' num2str(iPlanet) ': Reduced Parameter Fit Results']);
xlabel('Impact Parameter');
ylabel('Chi Square');

format_graphics_for_dv_report( plotHandle );
set( plotHandle, 'UserData', ['Model chi squares of reduced parameter fits vs. impact parameter for KeplerId ' num2str(keplerId) ', Planet candidate ' num2str(iPlanet) ...
     '. The fit result with the minimum chi square is marked with a dashed line in the plot.']);

filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), fitFilename,'chi-square.fig'];
saveas( plotHandle, fullfile( fullDirectory, filename ) );  
allPlotHandles = [allPlotHandles; plotHandle];

% Plot transit epochs vs. impact parameters

plotHandle = figure;
plot(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexTransitEpoch, :), '.-');
hold on;
errorbar(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexTransitEpoch, :), uncertaintyMatrix(indexTransitEpoch, :) );
yLim = get(gca, 'yLim');
plot(parameterMatrix(indexImpactParameter, minIndex)*[1 1], [yLim(1) yLim(2)], 'r--');
plot(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexTransitEpoch, :), '.-');
errorbar(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexTransitEpoch, :), uncertaintyMatrix(indexTransitEpoch, :) );
% plot(parameterMatrix(indexImpactParameter, minIndex), parameterMatrix(indexTransitEpoch, minIndex),  'ro', 'MarkerSize', 10);
hold off;
axis([0 1 yLim(1) yLim(2)]);
title(['Planet #' num2str(iPlanet) ': Reduced Parameter Fit Results']);
xlabel('Impact Parameter');
ylabel('Epoch (Bkjd)');

format_graphics_for_dv_report( plotHandle );
set( plotHandle, 'UserData', ['Transit epochs of reduced parameter fits vs. impact parameter for KeplerId ' num2str(keplerId) ', Planet candidate ' num2str(iPlanet) ...
     '. The fit result with the minimum chi square is marked with a dashed line in the plot.']);

filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), fitFilename,'transit-epoch.fig'];
saveas( plotHandle, fullfile( fullDirectory, filename ) );  
allPlotHandles = [allPlotHandles; plotHandle];

% Plot orbital periods vs. impact parameters

plotHandle = figure;
plot(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexOrbitalPeriod, :), '.-');
hold on;
errorbar(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexOrbitalPeriod, :), uncertaintyMatrix(indexOrbitalPeriod, :) );
yLim = get(gca, 'yLim');
plot(parameterMatrix(indexImpactParameter, minIndex)*[1 1], [yLim(1) yLim(2)], 'r--');
plot(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexOrbitalPeriod, :), '.-');
errorbar(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexOrbitalPeriod, :), uncertaintyMatrix(indexOrbitalPeriod, :) );
% plot(parameterMatrix(indexImpactParameter, minIndex), parameterMatrix(indexOrbitalPeriod, minIndex),  'ro', 'MarkerSize', 10);
hold off;
axis([0 1 yLim(1) yLim(2)]);
title(['Planet #' num2str(iPlanet) ': Reduced Parameter Fit Results']);
xlabel('Impact Parameter');
ylabel('Period (Day)');

format_graphics_for_dv_report( plotHandle );
set( plotHandle, 'UserData', ['Orbital periods of reduced parameter fits vs. impact parameter for KeplerId ' num2str(keplerId) ', Planet candidate ' num2str(iPlanet) ...
     '. The fit result with the minimum chi square is marked with a dashed line in the plot.']);

filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), fitFilename,'orbital-period.fig'];
saveas( plotHandle, fullfile( fullDirectory, filename ) );  
allPlotHandles = [allPlotHandles; plotHandle];

% Plot ratios of planet radius to star radius vs. impact parameters

plotHandle = figure;
plot(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexRpOverRstar, :), '.-');
hold on;
errorbar(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexRpOverRstar, :), uncertaintyMatrix(indexRpOverRstar, :) );
yLim = get(gca, 'yLim');
plot(parameterMatrix(indexImpactParameter, minIndex)*[1 1], [yLim(1) yLim(2)], 'r--');
plot(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexRpOverRstar, :), '.-');
errorbar(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexRpOverRstar, :), uncertaintyMatrix(indexRpOverRstar, :) );
% plot(parameterMatrix(indexImpactParameter, minIndex), parameterMatrix(indexRpOverRstar, minIndex),  'ro', 'MarkerSize', 10);
hold off;
axis([0 1 yLim(1) yLim(2)]);
title(['Planet #' num2str(iPlanet) ': Reduced Parameter Fit Results']);
xlabel('Impact Parameter');
ylabel('Rp / R*');

format_graphics_for_dv_report( plotHandle );
set( plotHandle, 'UserData', ['Ratios of planet radius to star radius of reduced parameter fits vs. impact parameter for KeplerId ' num2str(keplerId) ', Planet candidate ' num2str(iPlanet) ...
     '. The fit result with the minimum chi square is marked with a dashed line in the plot.']);

filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), fitFilename,'rp-over-rstar.fig'];
saveas( plotHandle, fullfile( fullDirectory, filename ) );  
allPlotHandles = [allPlotHandles; plotHandle];

% Plot ratios of semimajor axis to star radius vs. impact parameters

plotHandle = figure;
plot(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexAOverRstar, :), '.-');
hold on;
errorbar(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexAOverRstar, :), uncertaintyMatrix(indexAOverRstar, :) );
yLim = get(gca, 'yLim');
plot(parameterMatrix(indexImpactParameter, minIndex)*[1 1], [yLim(1) yLim(2)], 'r--');
plot(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexAOverRstar, :), '.-');
errorbar(parameterMatrix(indexImpactParameter, :), parameterMatrix(indexAOverRstar, :), uncertaintyMatrix(indexAOverRstar, :) );
% plot(parameterMatrix(indexImpactParameter, minIndex), parameterMatrix(indexAOverRstar, minIndex),  'ro', 'MarkerSize', 10);
hold off;
axis([0 1 yLim(1) yLim(2)]);
title(['Planet #' num2str(iPlanet) ': Reduced Parameter Fit Results']);
xlabel('Impact Parameter');
ylabel('a / R*');

format_graphics_for_dv_report( plotHandle );
set( plotHandle, 'UserData', ['Ratios of semimajor axis to star radius of reduced parameter fits vs. impact parameter for KeplerId ' num2str(keplerId) ', Planet candidate ' num2str(iPlanet) ...
     '. The fit result with the minimum chi square is marked with a dashed line in the plot.']);

filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), fitFilename,'a-over-rstar.fig'];
saveas( plotHandle, fullfile( fullDirectory, filename ) );  
allPlotHandles = [allPlotHandles; plotHandle];

% Clean up the plots

for iFigure = 1:length( allPlotHandles )
    close( allPlotHandles(iFigure) );
end

return

