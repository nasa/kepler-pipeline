function generate_phased_flux_time_series_plot_by_quarter(dvDataObject, dvResultsStruct, iTarget, plotWhitenedFluxFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function generate_phased_flux_time_series_plot_by_quarter(dvDataObject, dvResultsStruct, iTarget, plotWhitenedFluxFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate plots of the phased unwhitened flux time series and the phased unwhitened model light curve by quarters. 
%
% Version date:  2014-September-16.
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
%    2014-September-16, JL:
%        Adjust size of subplot of all transits 
%    2014-September-15, JL:
%        Initial release.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ~exist('plotWhitenedFluxFlag', 'var') || isempty(plotWhitenedFluxFlag )
    plotWhitenedFluxFlag  = false ;
end

if plotWhitenedFluxFlag
    whitenedStr = 'whitened';
else
    whitenedStr = 'unwhitened';
end

xOffset          = 0.05;
yOffset          = 0.08;
nTransitTimeZoom = 6;
nQuarters        = 16;

barycentricCadenceTimes          = dvDataObject.barycentricCadenceTimes(iTarget);
barycentricCadenceTimes.quarters = dvDataObject.dvCadenceTimes.quarters;

transitDurationMultiplier        = dvDataObject.planetFitConfigurationStruct.transitDurationMultiplier;

keplerId                         = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
dvFiguresRootDirectory           = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;

configMapObject                  = configMapClass( dvDataObject.configMaps );
mjd                              = dvDataObject.dvCadenceTimes.midTimestamps(1);
numExposuresPerCadence           = get_number_of_exposures_per_long_cadence_period( configMapObject, mjd );
exposureTimeSec                  = get_exposure_time( configMapObject, mjd );
readoutTimeSec                   = get_readout_time( configMapObject, mjd );
cadenceDurationDays              = numExposuresPerCadence * ( exposureTimeSec + readoutTimeSec ) * get_unit_conversion('sec2day');

  
nPlanets = length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
for iPlanet = 1:nPlanets
    
    hFig = figure;
    
    quarterArray = true(nQuarters, 1);
    
    xPosition = xOffset + 0.005;
    yPosition = yOffset + 0.005;
    subplot('Position', [xPosition, yPosition, 0.17, 0.16]);

    [transitEpochBkjd, orbitalPeriodDays, xLim, yLim] = ...
        generate_phased_flux_time_series_subplots(dvResultsStruct, barycentricCadenceTimes, iTarget, iPlanet, quarterArray, cadenceDurationDays, transitDurationMultiplier, nTransitTimeZoom, plotWhitenedFluxFlag);
    
    set(gca, 'yTickLabel', []);
    text(0, yLim(2)/2, 'All', 'fontSize', 12, 'color', 'blue');

    for iQuarter = 1 : nQuarters
        
        quarterArray            = false(nQuarters, 1);
        quarterArray(iQuarter)  = true;
        
        xPosition = xOffset + 0.005 + ( mod(iQuarter-1, 4) + 1      ) * 0.18;
        yPosition = yOffset + 0.005 + ( 4 - floor( (iQuarter-1)/4 ) ) * 0.17;
        subplot('Position', [xPosition, yPosition, 0.17, 0.16]);

        [transitEpochBkjd_ignored, orbitalPeriodDays_ignored, xLim_ignored, yLim_ignored] = ...
            generate_phased_flux_time_series_subplots(dvResultsStruct, barycentricCadenceTimes, iTarget, iPlanet, quarterArray, cadenceDurationDays, transitDurationMultiplier, nTransitTimeZoom, plotWhitenedFluxFlag);
        
        set(gca, 'xLim', xLim);
        set(gca, 'yLim', yLim);
        set(gca, 'xTickLabel', []);
        set(gca, 'yTickLabel', []);
        text(0, yLim(2)/2, ['Q' num2str(iQuarter)], 'fontSize', 12, 'color', 'blue');
        
    end
    
    for iYear = 1:4
        
        quarterArray  = false(nQuarters, 1);
        quarterArray( ((iYear-1)*4+1) : ((iYear-1)*4+4) ) = true;
        
        xPosition = xOffset + 0.005;
        yPosition = yOffset + 0.005 + ( 5 - iYear ) * 0.17;
        subplot('Position', [xPosition, yPosition, 0.17, 0.16]);
        
        [transitEpochBkjd_ignored, orbitalPeriodDays_ignored, xLim_ignored, yLim_ignored] = ...
            generate_phased_flux_time_series_subplots(dvResultsStruct, barycentricCadenceTimes, iTarget, iPlanet, quarterArray, cadenceDurationDays, transitDurationMultiplier, nTransitTimeZoom, plotWhitenedFluxFlag);
        
        set(gca, 'xLim', xLim);
        set(gca, 'yLim', yLim);
        set(gca, 'xTickLabel', []);
        if iYear > 1
            set(gca, 'yTickLabel', []);
        end
        text(0, yLim(2)/2, ['Y' num2str(iYear)], 'fontSize', 12, 'color', 'blue');
        
    end
    
    for iSeason = 1:4
        
        quarterArray = false(nQuarters, 1);
        quarterArray( iSeason : 4 : nQuarters ) = true;
        
        xPosition = xOffset + 0.005 + iSeason * 0.18;
        yPosition = yOffset + 0.005;
        subplot('Position', [xPosition, yPosition, 0.17, 0.16]);
        
        [transitEpochBkjd_ignored, orbitalPeriodDays_ignored, xLim_ignored, yLim_ignored] = ...
            generate_phased_flux_time_series_subplots(dvResultsStruct, barycentricCadenceTimes, iTarget, iPlanet, quarterArray, cadenceDurationDays, transitDurationMultiplier, nTransitTimeZoom, plotWhitenedFluxFlag);

        set(gca, 'xLim', xLim);
        set(gca, 'yLim', yLim);
        set(gca, 'yTickLabel', []);
        text(0, yLim(2)/2, ['S' num2str(mod(iSeason-2, 4))], 'fontSize', 12, 'color', 'blue');
       
    end  
    
    xPosition = 0.15;
    yPosition = yOffset + 0.005 + 5 * 0.17;
    axes('position', [xPosition, yPosition, 0.7, 0.005], 'Visible', 'off');
    title(['Planet: ', num2str(iPlanet), '   Phased Unwhitened Flux Time Series by Quarters']);
    set(get(gca, 'title'), 'Visible', 'on');
    set(get(gca, 'title'), 'FontWeight', 'bold');

    xPosition = 0.45;
    yPosition = 0.002;
    axes('position', [xPosition, yPosition, 0.1, 0.001], 'Visible', 'off');
    title('Phase (Hours)');
    set(get(gca, 'title'), 'Visible', 'on');
    set(get(gca, 'title'), 'fontWeight', 'bold');
    
    format_graphics_for_dv_report(hFig);
    

    set(hFig, 'UserData', ['Phased ', whitenedStr, ' flux time series by quarter for target ' num2str(keplerId) ', planet candidate ', num2str(iPlanet), ...
        '. Period = ', num2str(orbitalPeriodDays), ' days; transit epoch = ', num2str(transitEpochBkjd), ' BKJD.']);
   
    % Save figures to file
    figureFilename = [num2str(keplerId, '%09d'), '-', num2str(iPlanet, '%02d'), '-phased-' whitenedStr '-flux-time-series-by-quarter.fig'];
    saveas(hFig, fullfile(dvFiguresRootDirectory, 'summary-plots', figureFilename), 'fig');
    
    close(hFig);
    
end

return


function [transitEpochBkjd, orbitalPeriodDays, xLim, yLim] = generate_phased_flux_time_series_subplots(dvResultsStruct, barycentricCadenceTimes, iTarget, iPlanet, quarterArray, ...
                            cadenceDurationDays, transitDurationMultiplier, nTransitTimesZoom, plotWhitenedFluxFlag)

modelParameterNames   = {dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters.name};
epochIndex            = strcmp( 'transitEpochBkjd',     modelParameterNames );
periodIndex           = strcmp( 'orbitalPeriodDays',    modelParameterNames );
durationIndex         = strcmp( 'transitDurationHours', modelParameterNames );

transitEpochBkjd      = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(epochIndex).value;
orbitalPeriodDays     = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(periodIndex).value;
transitDurationHours  = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(durationIndex).value;

displayedCadences = false(size(barycentricCadenceTimes.quarters));
for iQuarter = 1 : length(quarterArray)
    if quarterArray(iQuarter) 
        displayedCadences(barycentricCadenceTimes.quarters==iQuarter) = true;
    end
end

if plotWhitenedFluxFlag
    
    plottedFluxValues     = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedFluxTimeSeries.values;
    plottedFitValues      = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedModelLightCurve.values;
    includedCadences      = ~(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedFluxTimeSeries.gapIndicators) & displayedCadences;
    
else
    
    originalFluxValues    = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.values;
    plottedFitValues      = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).modelLightCurve.values;
    includedCadences      = ~(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.gapIndicators) & displayedCadences;
    includedCadences(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.filledIndices) = false;
    
    % filter the flux time series to remove slow variations and keep fast ones
    plottedFitValues_buf = plottedFitValues;
    plottedFitValues_buf(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.filledIndices) = 0;
    [filteredFluxValues] = remove_medfilt_from_time_series( originalFluxValues - plottedFitValues_buf, transitDurationHours * get_unit_conversion('hour2day') / cadenceDurationDays, ...
                                                            orbitalPeriodDays / cadenceDurationDays, transitDurationMultiplier );
    plottedFluxValues    = filteredFluxValues + plottedFitValues_buf;
    
end

plottedFluxValues(~includedCadences) = NaN;

phase = mod( barycentricCadenceTimes.midTimestamps - transitEpochBkjd, orbitalPeriodDays ) / orbitalPeriodDays;
indexBuf = phase > 0.5;
phase(indexBuf) = phase(indexBuf) - 1 ;
[phaseSorted, sortKey] = sort( phase ) ;

phasedFluxValues        = plottedFluxValues(sortKey);
phasedFitValues         = plottedFitValues(sortKey);
phasedIncludedCadences  = includedCadences(sortKey);

foldedTimeDays = phaseSorted * orbitalPeriodDays ;
[cadenceTimesData, averagedFluxValue] = bin_and_average_time_series_by_cadence_time(foldedTimeDays, phasedFluxValues, 0, cadenceDurationDays, ~phasedIncludedCadences);

if ~all(~phasedIncludedCadences)
    
    timeConversion = get_unit_conversion( 'day2hour' ) ;
    hold on
    plot( foldedTimeDays      * timeConversion, phasedFluxValues,  'k.',  'MarkerSize',  4 );
    plot( cadenceTimesData    * timeConversion, averagedFluxValue, 'b.',  'MarkerSize', 12 );
    if ~all(plottedFitValues==0)
        plot( foldedTimeDays  * timeConversion, phasedFitValues,   'r',   'lineWidth',   1 );
    end
    
end

desiredRange = nTransitTimesZoom * transitDurationHours;
xLim         = [-desiredRange/2 desiredRange/2];
set( gca, 'xlim', xLim );

yLim = get( gca, 'ylim');

if ~isempty(averagedFluxValue)
    
    prctileNumber = 95;
    transitDepth  = -min( averagedFluxValue);
    prctile95     = prctile(plottedFluxValues(includedCadences), prctileNumber);
    offset        = max( prctile95, transitDepth/2 );
    
    yLim(1) = max( yLim(1), min( averagedFluxValue )                    - 2.5*offset );
    yLim(2) = min( yLim(2), prctile( averagedFluxValue, prctileNumber ) + 2.5*offset );
    if yLim(1) < yLim(2)
        set( gca, 'ylim', yLim );
    end
    
end

return

