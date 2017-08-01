function generate_trapezoidal_fit_plots(dvDataObject, dvResultsStruct, trapezoidalModelFitData)
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

iTarget  = trapezoidalModelFitData.iTarget;
iPlanet  = trapezoidalModelFitData.iPlanet;
keplerId = dvDataObject.targetStruct(iTarget).keplerId;


transitEpochBkjd            = trapezoidalModelFitData.trapezoidalFitOutputs.transitEpochBkjd;
transitDepthPpm             = trapezoidalModelFitData.trapezoidalFitOutputs.transitDepthPpm;
transitDurationHours        = trapezoidalModelFitData.trapezoidalFitOutputs.transitDurationHours;
transitIngressTimeHours     = trapezoidalModelFitData.trapezoidalFitOutputs.transitIngressTimeHours;
orbitalPeriodDays           = trapezoidalModelFitData.trapezoidalFitOutputs.orbitalPeriodDays;

originalTimestampsBkjd      = trapezoidalModelFitData.detrendOutputs.originalTimestampsBkjd;
originalFluxValuesUnfolded  = trapezoidalModelFitData.detrendOutputs.originalFluxValues - 1;
timestampsBkjd              = trapezoidalModelFitData.detrendOutputs.midTimestampsBkjd;
fluxValuesUnfolded          = trapezoidalModelFitData.detrendOutputs.newFluxValues - 1;

trapezoidalModelParameters  = [ transitEpochBkjd;  transitDepthPpm/1e6;  (transitDurationHours-transitIngressTimeHours)/24;  transitIngressTimeHours/24;  orbitalPeriodDays ];
transitSamplesPerCadence    = trapezoidalModelFitData.modelFittingParameters.transitSamplesPerCadence;
fitDataFlagUnfolded         = trapezoidalModelFitData.modelFittingParameters.fitDataFlag;
overSamplingFlagUnfolded    = trapezoidalModelFitData.modelFittingParameters.overSamplingFlag;
cadenceDurationDays         = median( diff( trapezoidalModelFitData.detrendOutputs.midTimestampsBkjd ) );

modelLightCurveUnfolded    = trapestmodel(trapezoidalModelParameters, timestampsBkjd, transitSamplesPerCadence, fitDataFlagUnfolded, overSamplingFlagUnfolded, cadenceDurationDays) - 1;
residualsUnfolded          = fluxValuesUnfolded - modelLightCurveUnfolded;

[originalPhase, originalPhaseFolded, sortKey, originalFluxValues] = fold_time_series(originalTimestampsBkjd, transitEpochBkjd, orbitalPeriodDays, originalFluxValuesUnfolded);
orginalFoldedTimeDays = originalPhaseFolded * orbitalPeriodDays;

[phase, phaseFolded, sortKey, fluxValues, modelLightCurve, residuals, fitDataFlag] = ...
    fold_time_series(timestampsBkjd, transitEpochBkjd, orbitalPeriodDays, fluxValuesUnfolded, modelLightCurveUnfolded, residualsUnfolded, fitDataFlagUnfolded);
foldedTimeDays = phaseFolded * orbitalPeriodDays;

[cadenceTimesData,  averagedFluxValues]      = bin_and_average_time_series_by_cadence_time( foldedTimeDays, fluxValues,      0, cadenceDurationDays );
[cadenceTimesData,  averagedResiduals]       = bin_and_average_time_series_by_cadence_time( foldedTimeDays, residuals,       0, cadenceDurationDays );
[cadenceTimesModel, averagedModelLightCurve] = bin_and_average_time_series_by_cadence_time( foldedTimeDays, modelLightCurve, 0, cadenceDurationDays );



dvFiguresRootDirectory  = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
planetFolder            = sprintf('planet-%02d', iPlanet);
fitFolder               = 'trapezoidal-model-fit' ;
fullDirectory           = fullfile( dvFiguresRootDirectory, planetFolder, 'planet-search-and-model-fitting-results', fitFolder ) ;

if ~exist(fullDirectory, 'dir')
    mkdir(fullDirectory);
end


% handle the possibility that nTransitTimesZoom is finite but inconveniently large
nTransitTimesZoom = 6;
nTransitTimesInPlot = range( cadenceTimesData ) / ( transitDurationHours * get_unit_conversion('hour2day') );
if nTransitTimesZoom > nTransitTimesInPlot
    nTransitTimesZoom = nTransitTimesInPlot;
end

% offset the residuals so that they can be seen more clearly
transitDepth      = -min( averagedFluxValues );
prctile95         = prctile(fluxValues, 95);
offset            = max( prctile95, transitDepth / 2 );
averagedResiduals = averagedResiduals + offset;


hFigure1 = figure;

plot(orginalFoldedTimeDays, originalFluxValues,       'k.', 'MarkerSize', 4);
hold on
plot(cadenceTimesData,      averagedFluxValues     ,  'b.', 'MarkerSize', 6);
%     plot(cadenceTimesModel,     averagedModelLightCurve,  'r.-');
plot(foldedTimeDays,        modelLightCurve,          'r-', 'LineWidth',  2);
plot(cadenceTimesData,      averagedResiduals,        'g.', 'MarkerSize', 6);
hold off
set(gca, 'xlim', orbitalPeriodDays*[-0.5 0.5]);

yLim = get( gca, 'ylim');
if ~isempty(averagedFluxValues)
    offset  = max( prctile(originalFluxValues, 95), -min(averagedFluxValues)/2 );
    yLim(1) = max( yLim(1), min( averagedFluxValues )         - 2.5*offset );
    yLim(2) = min( yLim(2), prctile( averagedFluxValues, 95 ) + 2.5*offset );
    if yLim(1) < yLim(2)
        set( gca, 'ylim', yLim );
    end
end

xlabel('Phase [Days]');
ylabel('Relative Flux');
titleString = ['Planet ', num2str(iPlanet), ' Trapezoidal Fit: Folded Detrended Flux Time Series'] ;
title( titleString ) ;
format_graphics_for_dv_report( hFigure1, 1.0, 0.5 ) ;

set( hFigure1, 'UserData', ...
    ['Folded detrended flux time series for KeplerId ', num2str(keplerId), ', Planet candidate ', num2str(iPlanet),' and folded trapezoidal model light curve.']);

filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), '-all-trapezoidal.fig'] ;
saveas( hFigure1, fullfile( fullDirectory, filename ) ) ;

close(hFigure1)

hFigure2 = figure;

averagedResiduals = averagedResiduals + prctile(averagedFluxValues, 95);

plot(orginalFoldedTimeDays      *24, originalFluxValues,      '.',   'Color', [0 1.0 1.0], 'MarkerSize', 12);
hold on
plot(foldedTimeDays(fitDataFlag)*24, fluxValues(fitDataFlag), '.',   'Color', [0 0.5 0.5], 'MarkerSize', 12);
plot(cadenceTimesData           *24, averagedFluxValues,      'b.',  'MarkerSize', 18);
%     plot(cadenceTimesModel          *24, averagedModelLightCurve, 'r.-', 'MarkerSize', 18, 'LineWidth', 2);
plot(foldedTimeDays             *24, modelLightCurve,         'r-',  'LineWidth',   2);
plot(cadenceTimesData           *24, averagedResiduals,       'g.',  'MarkerSize', 18);
hold off
desiredRange = nTransitTimesZoom * transitDurationHours ;
set( gca, 'xlim', [-desiredRange/2 desiredRange/2] ) ;

yLim = get( gca, 'ylim');
if ~isempty(averagedFluxValues)
    offset  = max( prctile(originalFluxValues, 95), -min(averagedFluxValues)/2 );
    yLim(1) = max( yLim(1), min( averagedFluxValues )         - 2.5*offset );
    yLim(2) = min( yLim(2), prctile( averagedFluxValues, 95 ) + 2.5*offset );
    if yLim(1) < yLim(2)
        set( gca, 'ylim', yLim );
    end
end

xlabel('Phase [Hours]');
ylabel('Relative Flux');
titleString = ['Planet ', num2str(iPlanet), ' Trapezoidal Fit: Zoomed Folded Detrended Flux Time Series'] ;
title( titleString ) ;

format_graphics_for_dv_report( hFigure2, 1.0, 0.5 ) ;

set( hFigure2, 'UserData', ...
    ['Zoomed folded detrended flux time series for KeplerId ', num2str(keplerId), ', Planet candidate ', num2str(iPlanet),' and folded trapezoidal model light curve.']);


filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), '-all-trapezoidal-zoomed.fig'] ;
saveas( hFigure2, fullfile( fullDirectory, filename ) ) ;

close(hFigure2)

return