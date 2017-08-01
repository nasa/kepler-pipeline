function plotHandle = plot_filtered_zoomed_flux_time_series( transitFitObject, fullDirectory, keplerId, iPlanet, oddEvenFlag, ...
    targetFluxTimeSeries, nTransitTimesZoom, transitDurationMultiplier )
%
% plot_filtered_zoomed_flux_time_series -- plot a high-pass-filtered flux time series, folded and zoomed on the expected location of the transit
%
% plotHandle = plot_filtered_zoomed_flux_time_series( transitFitObject, fullDirectory, keplerId, iPlanet, oddEvenFlag, targetFluxTimeSeries, nTransitTimesZoom, transitDurationMultiplier )
%    plots the flux time series after first filtering it to remove slow variations, folding the filtered flux time series, and zooming into the area where the expected transit occurs.  
%    The plot handle of the resulting plot is returned.
%
% Version date:  2015-January-12.
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
%    2015-January-12. JL:
%       Adjust vertical axis scaling
%    2013-January-04, JL:
%       Update the diagnostic plots of odd/even transits fits
%
%=========================================================================================

TRANSIT_MARKER_SIZE     = 6.0;
TEXT_MARKER_POSITION    = 0.05;
TRANSIT_MARKER_POSITION = 0.025;
PPM_CONVERSION          = 1e6;

% get the cadences to use

includedCadences_unfolded = get_included_excluded_cadences( transitFitObject );

% get the fitted transit object

transitObject        = get_fitted_transit_object( transitFitObject );
cadenceTimes         = get( transitObject, 'cadenceTimes' );
cadenceDurationDays  = get( transitObject, 'cadenceDurationDays' );
planetModel          = get( transitObject, 'planetModel' );

modelChiSquare = transitFitObject.chisq;
if oddEvenFlag==0
    transitDepthAll  = planetModel(1).transitDepthPpm / PPM_CONVERSION;
else
    transitDepthOdd  = planetModel(1).transitDepthPpm / PPM_CONVERSION;
    transitDepthEven = planetModel(2).transitDepthPpm / PPM_CONVERSION;
end
planetModel = planetModel(1);

% filter the flux time series to remove slow variations and keep fast ones

filteredFluxValues_unfolded = remove_medfilt_from_time_series( targetFluxTimeSeries.values, planetModel.transitDurationHours * get_unit_conversion('hour2day') / cadenceDurationDays, ...
    planetModel.orbitalPeriodDays / cadenceDurationDays, transitDurationMultiplier );

if oddEvenFlag==0
    
    % Determine the folded phase of all cadences and the folded time series
    [phase, phaseFoldedAll, sortKey, filteredFluxValuesAll, includedCadencesAll] = ...
        fold_time_series(cadenceTimes, planetModel.transitEpochBkjd, planetModel.orbitalPeriodDays, filteredFluxValues_unfolded, includedCadences_unfolded);
    
    foldedTimeAllHours  = phaseFoldedAll * planetModel.orbitalPeriodDays * get_unit_conversion('day2hour');
    nTransitTimesZoom   = min( nTransitTimesZoom, range(foldedTimeAllHours) / planetModel.transitDurationHours );
    maxPhaseHours       = nTransitTimesZoom / 2 * planetModel.transitDurationHours;

    % Plot the folded time series of all transits in one plot
    figure;
    isInAllZoom  = (abs(foldedTimeAllHours) < maxPhaseHours) & includedCadencesAll;
    hold on
    plot( foldedTimeAllHours(isInAllZoom), filteredFluxValuesAll(isInAllZoom), 'bd' );

    offset    = max( prctile(filteredFluxValuesAll(isInAllZoom), 95), transitDepthAll/2 );

    x = axis();
    x(1) = - maxPhaseHours;
    x(2) =   maxPhaseHours;
    x3   =   max( x(3), -transitDepthAll                                 - 2.5*offset );
    x4   =   min( x(4),  prctile(filteredFluxValuesAll(isInAllZoom), 95) + 2.5*offset );
    if x3 < x4
        x(3) = x3;
        x(4) = x4;
    end
    axis(x);
    
    % When the all transits fit succeeds, mark the transit depth of the all transits fit
    if modelChiSquare ~= -1
        plot([x(1); x(2)], [-transitDepthAll; -transitDepthAll], '-r');
    end
    
    % Add text and transit markers.
    text(0, x(4) - TEXT_MARKER_POSITION    * (x(4) - x(3)), 'All',  'HorizontalAlignment', 'center');
    plot(0, x(3) + TRANSIT_MARKER_POSITION * (x(4) - x(3)), '^', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'red', 'MarkerSize', TRANSIT_MARKER_SIZE);
    hold off

    oddEvenStr1 = ' All Transits: ';
    oddEvenStr2 = 'all';
    
else
    
    % Calculate the phase of cadences closer to the odd and even transits respectively
    [phase, phaseFoldedOdd,  sortKey, filteredFluxValuesOdd,  includedCadencesOdd]  = ...
        fold_time_series_with_odd_even_transits('odd',  cadenceTimes, planetModel.transitEpochBkjd, planetModel.orbitalPeriodDays, filteredFluxValues_unfolded, includedCadences_unfolded);
    [phase, phaseFoldedEven, sortKey, filteredFluxValuesEven, includedCadencesEven] = ...
        fold_time_series_with_odd_even_transits('even', cadenceTimes, planetModel.transitEpochBkjd, planetModel.orbitalPeriodDays, filteredFluxValues_unfolded, includedCadences_unfolded);
    
    foldedTimeOddHours  = phaseFoldedOdd  * planetModel.orbitalPeriodDays * get_unit_conversion('day2hour');
    foldedTimeEvenHours = phaseFoldedEven * planetModel.orbitalPeriodDays * get_unit_conversion('day2hour');
    nTransitTimesZoom   = min( nTransitTimesZoom, range(foldedTimeOddHours) / planetModel.transitDurationHours );
    maxPhaseHours       = nTransitTimesZoom / 2 * planetModel.transitDurationHours;
    
    % Plot the folded time series of the odd/even transits in one plot
    figure;
    isInOddZoom  = (abs(foldedTimeOddHours)  < maxPhaseHours) & includedCadencesOdd;
    isInEvenZoom = (abs(foldedTimeEvenHours) < maxPhaseHours) & includedCadencesEven;
    hold on
    plot(foldedTimeOddHours(isInOddZoom)   - maxPhaseHours, filteredFluxValuesOdd(isInOddZoom),   'bd');
    plot(foldedTimeEvenHours(isInEvenZoom) + maxPhaseHours, filteredFluxValuesEven(isInEvenZoom), 'bd');
    
    offset    = max( max( prctile(filteredFluxValuesOdd(isInOddZoom),   95), transitDepthOdd/2  ), ...
                     max( prctile(filteredFluxValuesEven(isInEvenZoom), 95), transitDepthEven/2 ) );

    x = axis();
    x(1) = -2 * maxPhaseHours;
    x(2) =  2 * maxPhaseHours;
    x3   =  max( x(3), -max(transitDepthOdd, transitDepthEven)                                                                    - 2.5*offset );
    x4   =  min( x(4),  max( prctile(filteredFluxValuesOdd(isInOddZoom), 95), prctile(filteredFluxValuesEven(isInEvenZoom), 95) ) + 2.5*offset );
    if x3 < x4
        x(3) = x3;
        x(4) = x4;
    end
    axis(x);
  
    % When the odd/even transits fits succeed, mark the transit depths of the odd/even transits fits
    if modelChiSquare ~= -1
        plot([x(1); 0   ], [-transitDepthOdd;  -transitDepthOdd],  '-r');
        plot([0;    x(2)], [-transitDepthEven; -transitDepthEven], '-r');
    end
    
    % Add text and transit markers.
    text(-maxPhaseHours, x(4) - TEXT_MARKER_POSITION    * (x(4) - x(3)), 'Odd',  'HorizontalAlignment', 'center');
    text( maxPhaseHours, x(4) - TEXT_MARKER_POSITION    * (x(4) - x(3)), 'Even', 'HorizontalAlignment', 'center');
    plot(-maxPhaseHours, x(3) + TRANSIT_MARKER_POSITION * (x(4) - x(3)), '^', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'red', 'MarkerSize', TRANSIT_MARKER_SIZE);
    plot( maxPhaseHours, x(3) + TRANSIT_MARKER_POSITION * (x(4) - x(3)), '^', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'red', 'MarkerSize', TRANSIT_MARKER_SIZE);

    % Mark the boundary between the odd and even plots.
    plot([0; 0], [x(3); x(4)], '--r');
    hold off

    oddEvenStr1 = ' Odd/Even Transits: ';
    oddEvenStr2 = 'odd/even';

end

xlabel('Phase [Hours]');
ylabel('Relative Flux');
titleString = ['Planet ', num2str(iPlanet), oddEvenStr1, 'Filtered Folded Flux Time Series'];
title( titleString );

plotHandle = gcf;
format_graphics_for_dv_report( plotHandle, 1.0, 0.5 ) ;
set( plotHandle, 'UserData', ...
    ['PDC Flux time series of ' oddEvenStr2 ' transits for KeplerId ', num2str(keplerId), ', Planet candidate ', num2str(iPlanet),' in the unwhitened domain. ', ...
    'Data has been high-pass filtered via a median filter operating at a specified multiple of the transit duration, '...
    'folded per the fitted period and epoch, and zoomed to the location of the model transit.'] );

return

