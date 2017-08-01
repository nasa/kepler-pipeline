function generate_phased_flux_time_series_plots(dvDataObject, dvResultsStruct, iTarget, plotWhitenedFluxFlag, useTpsEpochPeriodFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function generate_phased_flux_time_series_plots(dvDataObject, dvResultsStruct, iTarget, plotWhitenedFluxFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate plots of phased whitened/unwhitened flux time series and the phased whitened/unwhitened model light curve. 
% Transit event markers indicate the locations of transits of each planet candidate.
%
% Version date:  2014-November-26.
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
%    2014-November-26, JL:
%        Adjust vertical scale of the phased flux time series plots
%    2013-August-16, JL: 
%        Modify median filter: subtract model light curve, filter residual
%        and add model light curve
%    2013-August-12, JL:
%        Add median filter for unwhitened flux time series 
%    2013-June-17, JL:
%        Update the x-axis limits
%    2013-January-15, JL:
%        Fix a typo
%    2012-October-31, JL:
%        Update the caption of the plot
%    2012-October-29, JL:
%        Add input parameter useTpsEpochPeriodFlag
%    2012-October-03, JL:
%        Initial release.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ~exist('plotWhitenedFluxFlag', 'var') || isempty(plotWhitenedFluxFlag )
    plotWhitenedFluxFlag  = true ;
end

if ~exist('useTpsEpochPeriodFlag','var') || isempty(useTpsEpochPeriodFlag)
    useTpsEpochPeriodFlag = false;
end
  
debugLevel                = dvDataObject.dvConfigurationStruct.debugLevel;
barycentricCadenceTimes   = dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps;
transitDurationMultiplier = dvDataObject.planetFitConfigurationStruct.transitDurationMultiplier;

keplerId                  = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
dvFiguresRootDirectory    = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;

maxPhase = 0.75;

configMapObject         = configMapClass( dvDataObject.configMaps );
mjd                     = dvDataObject.dvCadenceTimes.midTimestamps(1);
numExposuresPerCadence  = get_number_of_exposures_per_long_cadence_period( configMapObject, mjd );
exposureTimeSec         = get_exposure_time( configMapObject, mjd );
readoutTimeSec          = get_readout_time( configMapObject, mjd );
cadenceDurationDays     = numExposuresPerCadence * ( exposureTimeSec + readoutTimeSec ) * get_unit_conversion('sec2day');
  
nPlanets = length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
if mod(nPlanets, 2)==0
    nFigures = nPlanets/2;
else
    nFigures = ceil(nPlanets/2);
end

for iFigure = 1:nFigures

    hFig = figure;
    
    iPlanet   = (iFigure-1)*2 + 1;
    subplot(2,1,1);
    generate_phased_flux_time_series_subplots(dvResultsStruct, barycentricCadenceTimes, iTarget, iPlanet, nPlanets, ...
        cadenceDurationDays, maxPhase, transitDurationMultiplier, plotWhitenedFluxFlag, useTpsEpochPeriodFlag); 
    planetStr = num2str(iPlanet, '%02d');
    
    iPlanet = (iFigure-1)*2 + 2;
    if iPlanet<=nPlanets
        subplot(2,1,2);
        generate_phased_flux_time_series_subplots(dvResultsStruct, barycentricCadenceTimes, iTarget, iPlanet, nPlanets, ...
            cadenceDurationDays, maxPhase, transitDurationMultiplier, plotWhitenedFluxFlag, useTpsEpochPeriodFlag);
    end
    
    format_graphics_for_dv_report(hFig);
    if plotWhitenedFluxFlag
        whitenedStr = 'whitened';
    else
        whitenedStr = 'unwhitened';
    end
    set(hFig, 'UserData', ['Phased ', whitenedStr, ' flux time series is plotted in black dots. When all transits fit completed with full or secondary convergence, ', ...
        'the phase is determined with the fitted epoch and period; otherwise, the phase is determined with the TPS epoch and period. ', ...
        'The values of the phased ', whitenedStr, ' flux time series averaged in one cadence wide bins are plotted in bigger blue dots. ', ...
        'When all transits fit completes with full or secondary convergence, the averaged values of the phased ', whitenedStr, ' fitted model light curve ', ...
        'are plotted in red dots. Transit event markers in different colors indicate the locations of the transits of all planet candidates. ', ...
        'The transits of the same planet candidate are labeled with the markers of the same color, for example, blue markers for transits of plane candidate #1, ', ...
        'red markers for transits of planet candidate #2, etc.']);
    
    % Save figures to file
    if useTpsEpochPeriodFlag
        figureFilename = [num2str(keplerId, '%09d'), '-', planetStr, '-phased-' whitenedStr '-flux-time-series-tps.fig'];
    else
        figureFilename = [num2str(keplerId, '%09d'), '-', planetStr, '-phased-' whitenedStr '-flux-time-series.fig'];
    end
    saveas(hFig, fullfile(dvFiguresRootDirectory, 'summary-plots', figureFilename), 'fig');
   
    % close figure
    if (debugLevel==0)
        close(hFig);
    else
        drawnow;
    end
  
end

return


function generate_phased_flux_time_series_subplots(dvResultsStruct, barycentricCadenceTimes, iTarget, iPlanet, nPlanets, ...
    cadenceDurationDays, maxPhase, transitDurationMultiplier, plotWhitenedFluxFlag, useTpsEpochPeriodFlag)

colorValueArray = [ 1  0   0         % red
                    0  0   1         % blue
                    0  1   0         % green
                    0  0   0         % black
                    1  0   1         % magenta
                    1  0.7 0 ];      % orange
                
modelParameterNames   = {dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters.name};
epochIndex            = strcmp( 'transitEpochBkjd',     modelParameterNames );
periodIndex           = strcmp( 'orbitalPeriodDays',    modelParameterNames );
durationIndex         = strcmp( 'transitDurationHours', modelParameterNames );

transitEpochBkjd      = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(epochIndex).value;
orbitalPeriodDays     = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(periodIndex).value;
if useTpsEpochPeriodFlag
    transitEpochBkjd  = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.epochMjd - kjd_offset_from_mjd;
    orbitalPeriodDays = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.orbitalPeriod; 
end
transitDurationHours  = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(durationIndex).value;

if plotWhitenedFluxFlag
    plottedFluxValues     = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedFluxTimeSeries.values;
    plottedFitValues      = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedModelLightCurve.values;
%    plottedResidualValues = plottedFluxValues - plottedFitValues;
    includedCadences      = ~(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedFluxTimeSeries.gapIndicators);
else
    originalFluxValues    = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.values;
    plottedFitValues      = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).modelLightCurve.values;
%    plottedResidualValues = plottedFluxValues - plottedFitValues;
    includedCadences      = ~(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.gapIndicators);
    includedCadences(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.filledIndices) = false;
    
% filter the flux time series to remove slow variations and keep fast ones
    plottedFitValues(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.filledIndices) = 0;
    [filteredFluxValues] = remove_medfilt_from_time_series( originalFluxValues - plottedFitValues, transitDurationHours * get_unit_conversion('hour2day') / cadenceDurationDays, ...
                                                            orbitalPeriodDays / cadenceDurationDays, transitDurationMultiplier );
    plottedFluxValues    = filteredFluxValues + plottedFitValues;
    
end
plottedFluxValues(~includedCadences) = NaN;
plottedFitValues(~includedCadences)  = NaN;


phase = mod( barycentricCadenceTimes - transitEpochBkjd, orbitalPeriodDays ) / orbitalPeriodDays ;
indexOverMaxPhase = phase > maxPhase ;
phase(indexOverMaxPhase) = phase(indexOverMaxPhase) - 1 ;
[phaseSorted, sortKey] = sort( phase ) ;

phasedFluxValues        = plottedFluxValues(sortKey);
phasedFitValues         = plottedFitValues(sortKey);
% phasedResidualValues    = plottedResidualValues(sortKey);
phasedIncludedCadences  = includedCadences(sortKey);

foldedTimeDays = phaseSorted * orbitalPeriodDays ;
[cadenceTimesData,     averagedFluxValue] = bin_and_average_time_series_by_cadence_time(foldedTimeDays, phasedFluxValues,     0, cadenceDurationDays, ~phasedIncludedCadences);
[cadenceTimesFit,      averagedFitValue]  = bin_and_average_time_series_by_cadence_time(foldedTimeDays, phasedFitValues,      0, cadenceDurationDays, ~phasedIncludedCadences);
% [cadenceTimesResidual, averagedResidual]  = bin_and_average_time_series_by_cadence_time(foldedTimeDays, phasedResidualValues, 0, cadenceDurationDays, ~phasedIncludedCadences);

phaseFlux             = phaseSorted;
phaseAveragedFlux     = cadenceTimesData    /orbitalPeriodDays;
phaseAveragedFit      = cadenceTimesFit     /orbitalPeriodDays;
% phaseAveragedResidual = cadenceTimesResidual/orbitalPeriodDays;

if ~all(~phasedIncludedCadences)
    
    plot( phaseFlux,             phasedFluxValues,                                 'k.',  'MarkerSize',  4 );
    hold on
    plot( phaseAveragedFlux,     averagedFluxValue,                                'b.',  'MarkerSize', 12 );
    if ~all(plottedFitValues==0)
        plot( phaseAveragedFit,  averagedFitValue,                                 'r.-', 'MarkerSize', 12 );
    end
    % plot( phaseAveragedResidual, averagedResidual + prctile(phasedFluxValues, 95), 'g.-', 'MarkerSize', 12 );
    
    yLim = get( gca, 'ylim');
    if ~isempty(averagedFluxValue)
        offset  = max( prctile(phasedFluxValues, 95), -min(averagedFluxValue)/2 );
        yLim(1) = max( yLim(1), min( averagedFluxValue )         - 2.5*offset );
        yLim(2) = min( yLim(2), prctile( averagedFluxValue, 95 ) + 2.5*offset );
        if yLim(1) < yLim(2)
            set( gca, 'ylim', yLim );
        end
    end

    yLim = get( gca, 'ylim');
    for i=1:nPlanets
        
        colorValue  = colorValueArray(mod(i-1, size(colorValueArray,1))+1, :);
        
        transitEpochBkjd_i  = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(i).allTransitsFit.modelParameters(epochIndex).value;
        orbitalPeriodDays_i = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(i).allTransitsFit.modelParameters(periodIndex).value;
        nTransits           = floor( (barycentricCadenceTimes(end) - transitEpochBkjd_i)/orbitalPeriodDays_i ) + 1;
        transitTimePhaseBuf = (transitEpochBkjd_i + ([1:nTransits]'-1) * orbitalPeriodDays_i - transitEpochBkjd)/orbitalPeriodDays;
        
        transitTimePhase    = transitTimePhaseBuf - floor(transitTimePhaseBuf);
        indexOverMaxPhase   = transitTimePhase>maxPhase;
        transitTimePhase(indexOverMaxPhase) = transitTimePhase(indexOverMaxPhase) - 1;
        markerYpos = yLim(1) * ( 1 + 0.1*i );
        plot( transitTimePhase, markerYpos*ones(nTransits, 1), '^', 'MarkerSize', 6, 'MarkerEdgeColor', colorValue, 'MarkerFaceColor', colorValue);
        
    end
    
    yLim(1) = yLim(1) * ( 1 + 0.1*(nPlanets+2) );
    set( gca, 'ylim', yLim );
    
    hold off
    
end

if ( dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelChiSquare==-1 ) || useTpsEpochPeriodFlag
    tpsDvStr = '(TPS Epoch/Period)';
else
    tpsDvStr = '(Fit Epoch/Period)';
end

if plotWhitenedFluxFlag
    ylabel( 'Whitened Flux Value [\sigma]' ) ;
    title(['Planet ', num2str(iPlanet), ' : Phased Whitened Flux Time Series ' tpsDvStr]);
else
    ylabel( 'Unwhitened Relative Flux Value' ) ;
    title(['Planet ', num2str(iPlanet), ' : Phased Unwhitened Flux Time Series ' tpsDvStr]);
end
xlabel( 'Phase' ) ;
set(gca, 'xLim', [maxPhase-1.0 maxPhase+0.0]);

return


