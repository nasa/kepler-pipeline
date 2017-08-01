function plotHandle = plot_whitened_flux_time_series( transitFitObject, fullDirectory, keplerId, iPlanet, oddEvenFlag, fitFilename, nTransitTimesZoom, flagShowFoldedFlux )
%
% plot_whitened_flux_time_series -- plot the whitened flux time series for a fit
%
% plotHandle = plot_whitened_flux_time_series( transitFitObject, fullDirectory, keplerId, iPlanet, oddEvenFlag, fitFilename ) plots the whitened,
%    folded, averaged flux time series over the full phase (ie, from -0.5 periods to +0.5 periods).  The initial flux, fitted transit model, and
%    residual flux are plotted, the latter offset for better visibility.
%
% plotHandle = plot_whitened_flux_time_series( transitFitObject, fullDirectory, keplerId, iPlanet, oddEvenFlag, fitFilename, nTransitTimesZoom ) plots
%    the whitened, folded, averaged flux time series over a region zoomed in on the transit and showing a total of nTransitTimesZoom transit times 
%    (ie, from -0.5 * nTransitTimesZoom to +0.5 * nTransitTimesZoom).  In this plot, the flux from the other phase is also shown, offset from the residual
%    flux for ease of viewing.
%
% Version date:  2013-June-17.
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
%    2013-June-17, JL:
%       Update the calculation of y-axis offset and limits
%    2013-May-03, JL:
%       The y-axis limits are adjusted so that the outliers are not shown
%    2013-May-01, JL:
%       Add input 'flagShowFoldedFlux'
%    2013-March-13, JL:
%       Update the setting of 'plotHandle'
%    2013-January-04, JL:
%       Update the diagnostic plots of odd/even transits fits
%    2012-October-05, JL:
%        Fix a bug regarding 'cadenceTimesFit'
%    2012-October-03, JL:
%        Add folded flux time series. Plot the data points with robust
%        weights above given value in different color
%    2012-August-15, JL:
%        averagedFit is calculated with data only at includedCadences
%    2011-January-31, JL:
%        add the flag fitTimeCheckSkipped in 'model_function'
%
%=========================================================================================

% if nTransitTimesZoom is missing or empty, set it

if ~exist( 'nTransitTimesZoom', 'var' ) || isempty( nTransitTimesZoom )
    nTransitTimesZoom = inf;
end

% if flagShowFoldedFlux is missing or empty, set it

if ~exist( 'flagShowFoldedFlux', 'var' ) || isempty( flagShowFoldedFlux )
    flagShowFoldedFlux = true;
end


% get the cadences to use

includedCadences_unfolded = get_included_excluded_cadences( transitFitObject ) ;

% exclude the data points with robust weight below the threshold

includedNonZeroRobustWeights_unfolded   = includedCadences_unfolded;
robustWeightThresholdForPlots           = transitFitObject.configurationStruct.robustWeightThresholdForPlots;
includedNonZeroRobustWeights_unfolded(transitFitObject.robustWeights<robustWeightThresholdForPlots) = false;

% get the fitted transit object

transitObject       = get_fitted_transit_object( transitFitObject );
cadenceTimes        = get( transitObject, 'cadenceTimes' );
cadenceDurationDays = get( transitObject, 'cadenceDurationDays' );
planetModel         = get( transitObject, 'planetModel' );
planetModel         = planetModel(1) ;

% Obtain the 3 time series which are to be plotted

whitenedFluxValues_unfolded     = transitFitObject.whitenedFluxTimeSeries.values ;
whitenedFitValues_unfolded      = model_function(transitFitObject, transitFitObject.finalParValues, true, true);
whitenedResidualValues_unfolded = whitenedFluxValues_unfolded - whitenedFitValues_unfolded;

if oddEvenFlag==0
    
    % Generate the diagnostic plot of the all transits fit 
    
    plotHandle = figure;
    oddEvenStr = 'all';
    [nTransitTimesZoom] = plot_folded_whitened_flux_time_series( ...
        oddEvenStr, keplerId, iPlanet, nTransitTimesZoom, cadenceTimes, planetModel, cadenceDurationDays, robustWeightThresholdForPlots, ...
        whitenedFluxValues_unfolded, whitenedFitValues_unfolded, whitenedResidualValues_unfolded, includedCadences_unfolded, includedNonZeroRobustWeights_unfolded, plotHandle, flagShowFoldedFlux); 
    
    format_graphics_for_dv_report( plotHandle,  1.0, 0.5 );
    
else
    
    % Generate the diagnotic plots of the odd/even transits fits as two subplots of one figure
    
    plotHandle = figure;
    subplot(2,1,1)
    oddEvenStr = 'odd';
    [nTransitTimesZoom, xOdd]  = plot_folded_whitened_flux_time_series( ...
        oddEvenStr, keplerId, iPlanet, nTransitTimesZoom, cadenceTimes, planetModel, cadenceDurationDays, robustWeightThresholdForPlots, ...
        whitenedFluxValues_unfolded, whitenedFitValues_unfolded, whitenedResidualValues_unfolded, includedCadences_unfolded, includedNonZeroRobustWeights_unfolded, plotHandle, flagShowFoldedFlux); 
    
    subplot(2,1,2)
    oddEvenStr = 'even';
    [nTransitTimesZoom, xEven] = plot_folded_whitened_flux_time_series( ...
        oddEvenStr, keplerId, iPlanet, nTransitTimesZoom, cadenceTimes, planetModel, cadenceDurationDays, robustWeightThresholdForPlots, ...
        whitenedFluxValues_unfolded, whitenedFitValues_unfolded, whitenedResidualValues_unfolded, includedCadences_unfolded, includedNonZeroRobustWeights_unfolded, plotHandle, flagShowFoldedFlux); 
    
    % Keep the axis scaling of two subplots the same
    
    subplot(2,1,1)
    axis([min(xOdd(1), xEven(1)) max(xOdd(2), xEven(2)) min(xOdd(3), xEven(3)) max(xOdd(4), xEven(4))]);
    subplot(2,1,2)
    axis([min(xOdd(1), xEven(1)) max(xOdd(2), xEven(2)) min(xOdd(3), xEven(3)) max(xOdd(4), xEven(4))]);
    
    format_graphics_for_dv_report( plotHandle );
    
end

% Save the figure

if isinf( nTransitTimesZoom )
    filename = [num2str(keplerId, '%09d'), '-', num2str(iPlanet, '%02d'), fitFilename, 'whitened.fig'];
else
    if flagShowFoldedFlux
        filename = [num2str(keplerId, '%09d'), '-', num2str(iPlanet, '%02d'), fitFilename, 'whitened-zoomed.fig'];
    else
        filename = [num2str(keplerId, '%09d'), '-', num2str(iPlanet, '%02d'), fitFilename, 'whitened-zoomed-summary.fig'];
    end
end
saveas( plotHandle, fullfile( fullDirectory, filename ) ) ;

return


function  [nTransitTimesZoom, xLim] = plot_folded_whitened_flux_time_series(oddEvenStr, keplerId, iPlanet,  nTransitTimesZoom, cadenceTimes, planetModel, cadenceDurationDays, robustWeightThresholdForPlots, ...
    whitenedFluxValues_unfolded, whitenedFitValues_unfolded, whitenedResidualValues_unfolded, includedCadences_unfolded, includedNonZeroRobustWeights_unfolded, plotHandle, flagShowFoldedFlux)

% fold the 3 flux time series and the included cadences vector

if strcmp(oddEvenStr, 'all')
    [phase, phaseFolded, sortKey, whitenedFluxValues, whitenedFitValues, whitenedResidualValues, includedCadences, includedNonZeroRobustWeights] = ...
        fold_time_series(cadenceTimes, planetModel.transitEpochBkjd, planetModel.orbitalPeriodDays, ...
            whitenedFluxValues_unfolded, whitenedFitValues_unfolded, whitenedResidualValues_unfolded, includedCadences_unfolded, includedNonZeroRobustWeights_unfolded);
else
    [phase, phaseFolded, sortKey, whitenedFluxValues, whitenedFitValues, whitenedResidualValues, includedCadences, includedNonZeroRobustWeights] = ...
        fold_time_series_with_odd_even_transits(oddEvenStr, cadenceTimes, planetModel.transitEpochBkjd, planetModel.orbitalPeriodDays, ...
            whitenedFluxValues_unfolded, whitenedFitValues_unfolded, whitenedResidualValues_unfolded, includedCadences_unfolded, includedNonZeroRobustWeights_unfolded);
end
foldedTimeDays = phaseFolded * planetModel.orbitalPeriodDays;


% perform the averaging -- note that when this is done we'll wind up with 2 different
% cadence times vectors, since the cadence times which correspond to empty bins are
% removed, which is in turn a function mainly of the gap indicators; and there are no gaps
% for the fit, but there might be for the data

[cadenceTimesData, averagedData]      = bin_and_average_time_series_by_cadence_time( foldedTimeDays, whitenedFluxValues,     0, cadenceDurationDays, ~includedCadences );
[cadenceTimesData, averagedResiduals] = bin_and_average_time_series_by_cadence_time( foldedTimeDays, whitenedResidualValues, 0, cadenceDurationDays, ~includedCadences );
[cadenceTimesFit,  averagedFit]       = bin_and_average_time_series_by_cadence_time( foldedTimeDays, whitenedFitValues,      0, cadenceDurationDays, ~includedCadences );

% handle the possibility that nTransitTimesZoom is finite but inconveniently large

nTransitTimesInPlot = range( cadenceTimesData ) / ( planetModel.transitDurationHours * get_unit_conversion('hour2day') );
if ~isinf( nTransitTimesZoom ) && nTransitTimesZoom > nTransitTimesInPlot
    nTransitTimesZoom = nTransitTimesInPlot;
end

% offset the residuals so that they can be seen more clearly

transitDepthSigmas = -min( averagedData );
if flagShowFoldedFlux
    prctile95 = prctile(whitenedFluxValues(includedCadences), 95);
    offset    = max( prctile95,                                          transitDepthSigmas / 2 );
else
    offset    = max( -min( averagedResiduals ) + mad( averagedData, 1 ), transitDepthSigmas / 6 ) ;
end

prctileNumber = 95;
averagedResiduals = averagedResiduals + offset;
if ~isinf( nTransitTimesZoom )
%    averagedResiduals = averagedResiduals + max( averagedData );
    averagedResiduals = averagedResiduals + prctile( averagedData, prctileNumber );
end

if strcmp(oddEvenStr, 'all')

    % do the same for the other phase information

    otherPhaseFolded                     = zeros( size(phaseFolded) );
    otherPhaseFolded( phaseFolded < 0  ) = phaseFolded( phaseFolded < 0 )  + 0.5;
    otherPhaseFolded( phaseFolded >= 0 ) = phaseFolded( phaseFolded >= 0 ) - 0.5;
    foldedOtherPhaseTimeDays             = otherPhaseFolded * planetModel.orbitalPeriodDays;

    [cadenceTimesOtherPhase, averagedDataOtherPhase] = bin_and_average_time_series_by_cadence_time(foldedOtherPhaseTimeDays, whitenedFluxValues, 0, cadenceDurationDays, ~includedCadences);

    averagedDataOtherPhase = averagedDataOtherPhase + 2*offset ;
    if ~isinf( nTransitTimesZoom )
    %    averagedDataOtherPhase = averagedDataOtherPhase + max( averagedData );
        averagedDataOtherPhase = averagedDataOtherPhase + prctile( averagedData, prctileNumber );
    end

end


if isinf( nTransitTimesZoom )

    % plot the data, fit, and residuals on one set of axes; 

    timeConversion = 1 ;
    plot( foldedTimeDays(includedCadences)             * timeConversion, whitenedFluxValues(includedCadences),             'k.', 'MarkerSize', 4 );
    hold on
    plot( cadenceTimesData * timeConversion, averagedData,       'b.', 'MarkerSize', 6 );
    plot( cadenceTimesFit  * timeConversion, averagedFit,        'r.-' );
    plot( cadenceTimesData * timeConversion, averagedResiduals,  'g.', 'MarkerSize', 6 );
    
    set( gca, 'xlim', planetModel.orbitalPeriodDays*[-0.5 0.5] );
    
    yLim = get( gca, 'ylim');
    yLim(1) = max( yLim(1), min( averagedData )                    - 2.5*offset );
    yLim(2) = min( yLim(2), prctile( averagedData, prctileNumber ) + 2.0*offset );
    if yLim(1) < yLim(2)
        set( gca, 'ylim', yLim );
    end
    
else
    
    % if there's a zoom requested, apply it, convert the time from days to hours, and also plot the other phase
    
    timeConversion = get_unit_conversion( 'day2hour' ) ;
    hold on
    if flagShowFoldedFlux
        plot( foldedTimeDays(includedCadences)             * timeConversion, whitenedFluxValues(includedCadences),             '.', 'Color', [0 1.0 1.0], 'MarkerSize', 12 );
        plot( foldedTimeDays(includedNonZeroRobustWeights) * timeConversion, whitenedFluxValues(includedNonZeroRobustWeights), '.', 'Color', [0 0.5 0.5], 'MarkerSize', 12 );
    end
    plot( cadenceTimesData * timeConversion, averagedData,       'b.',  'MarkerSize', 18 );
    plot( cadenceTimesFit  * timeConversion, averagedFit,        'r.-', 'MarkerSize', 18, 'LineWidth', 2.0 );
    plot( cadenceTimesData * timeConversion, averagedResiduals,  'g.',  'MarkerSize', 18 );
    if strcmp(oddEvenStr, 'all')
        plot( cadenceTimesOtherPhase * timeConversion, averagedDataOtherPhase, 'm.', 'MarkerSize', 18 ) ;
    end
    desiredRange = nTransitTimesZoom * planetModel.transitDurationHours ;
    set( gca, 'xlim', [-desiredRange/2 desiredRange/2] ) ;
    
    % adjust y-axis limits when flagShowFoldedFlux is true
    
    if flagShowFoldedFlux
        yLim = get( gca, 'ylim');
        yLim(1) = max( yLim(1), min( averagedData )                    - 2.5*offset );
        yLim(2) = min( yLim(2), prctile( averagedData, prctileNumber ) + 2.5*offset );
        if yLim(1) < yLim(2)
            set( gca, 'ylim', yLim );
        end
    end
    
end

% add the axes labels and titles

if strcmp(oddEvenStr, 'odd')
    oddEvenFitStr      = ' Odd Transits Fit: ';
    oddEvenTransitsStr = 'odd/even';
elseif strcmp(oddEvenStr, 'even')
    oddEvenFitStr      = ' Even Transits Fit: ';
    oddEvenTransitsStr = 'odd/even';
else
    oddEvenFitStr      = ' All Transits Fit: ';
    oddEvenTransitsStr = 'all';
end

ylabel( 'Whitened Flux Value [\sigma]' ) ;
if ~isinf( nTransitTimesZoom )
    xlabel( 'Phase [Hours]' );
    titleString = ['Planet ', num2str(iPlanet), oddEvenFitStr, 'Whitened Folded Averaged Zoomed Flux Time Series'];
else
    xlabel( 'Phase [Days]' );
    titleString = ['Planet ', num2str(iPlanet), oddEvenFitStr, 'Whitened Folded Averaged Flux Time Series'];
end
title( titleString );

xLim = axis();
if isinf( nTransitTimesZoom )
    set( plotHandle, 'UserData', ...
        ['Folded flux time series for KeplerId ', num2str(keplerId), ', Planet candidate ', num2str(iPlanet), ...
        ' in the whitened domain is plotted in black dots.  Values are averaged into 1 cadence wide bins. ', ...
        'The blue dots represent the averaged values of the folded flux time series; ', ...
        'the red dots represent the averaged values of the folded model light curve of the ', oddEvenTransitsStr, ' transits fit; ', ...
        'the green dots are the averaged folded fit residuals, vertically offset for clarity.'] );
else
    if flagShowFoldedFlux
        set( plotHandle, 'UserData', ...
            ['Folded flux time series for KeplerId ', num2str(keplerId), ', Planet candidate ', num2str(iPlanet),' in the whitened domain, zoomed on the transit. ', ...
            'The flux data whose robust weights are larger/smaller than ', num2str(robustWeightThresholdForPlots) ' are plotted in dark green/cyan dots, respectively. ', ...
            'Values are averaged into 1 cadence wide bins.  The blue dots represent the averaged values of the folded flux time series; ', ...
            'the red dots represent the averaged values of the fitted model light curve of the ', oddEvenTransitsStr, ' transits fit; ', ...
            'the green dots are the averaged folded fit residuals, vertically offset for clarity.  ', ...
            'Magenta dots are the averaged values of the folded flux time series, with a phase shift of 0.5 relative to the blue dots, vertically offset for clarity.'] );
    else
        set( plotHandle, 'UserData', ...
            ['Folded flux time series for KeplerId ', num2str(keplerId), ', Planet candidate ', num2str(iPlanet),' in the whitened domain, zoomed on the transit. ', ...
            'The flux data are averaged into 1 cadence wide bins.  The blue dots represent the averaged values of the folded flux time series; ', ...
            'the red dots represent the averaged values of the fitted model light curve of the ', oddEvenTransitsStr, ' transits fit; ', ...
            'the green dots are the averaged folded fit residuals, vertically offset for clarity.  ', ...
            'Magenta dots are the averaged values of the folded flux time series, with a phase shift of 0.5 relative to the blue dots, vertically offset for clarity.'] );
    end
end

return
