function [cotrendedFluxTimeSeries, fittedFluxTimeSeries, ...
saturationSegmentsStruct, shortTimeScalePowerRatio] = ...
correct_systematic_error(conditionedAncillaryDataStruct, targetDataStruct, ...
ancillaryDesignMatrixConfigurationStruct, pdcModuleParameters, ...
saturationSegmentConfigurationStruct, gapFillParametersStruct, ...
restoreMeanFlag, dataAnomalyIndicators)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [cotrendedFluxTimeSeries, fittedFluxTimeSeries, ...
% saturationSegmentsStruct, shortTimeScalePowerRatio] = ...
% correct_systematic_error(conditionedAncillaryDataStruct, targetDataStruct, ...
% ancillaryDesignMatrixConfigurationStruct, pdcModuleParameters, ...
% saturationSegmentConfigurationStruct, gapFillParametersStruct, ...
% restoreMeanFlag, dataAnomalyIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This PDC function corrects systematic errors in flux time series by
% cotrending with conditioned ancillary data (gap filled and resampled).
% The cotrending is performed by either robust fit or singular value
% decomposition and least squares projection. The cotrended flux time
% series (from which the systematic trend has been removed), the fitted
% flux time series (representing the nonlinear trend due to systematic
% errors) and the uncertainties in the cotrended flux time series are
% returned in the output structures of this function. The uncertainties are
% obtained through standard propagation of error analysis.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% If the restore mean flag was not specified then set it to true. If the
% data anomaly indicators do not exist then set the structure to empty.
if ~exist('restoreMeanFlag', 'var')
    restoreMeanFlag = true;
end

if ~exist('dataAnomalyIndicators', 'var')
    dataAnomalyIndicators = [];
end

% Get the number of stellar targets and number of cadences.
nTargets = length(targetDataStruct);
nCadences = length(targetDataStruct(1).values);

% Create the design matrix with the conditioned ancillary data.
[designMatrix] = ...
    create_design_matrix(conditionedAncillaryDataStruct, nCadences);

% Filter the columns of the design matrix.
[designMatrix] = ...
    filter_design_matrix_columns(designMatrix, ...
    ancillaryDesignMatrixConfigurationStruct, dataAnomalyIndicators);

% Cotrend the flux time series.
[cotrendedFluxTimeSeries, fittedFluxTimeSeries, ...
    saturationSegmentsStruct, shortTimeScalePowerRatio] = ...
    cotrend_flux_timeseries(designMatrix, pdcModuleParameters, ...
    saturationSegmentConfigurationStruct, gapFillParametersStruct, ...
    targetDataStruct, restoreMeanFlag, dataAnomalyIndicators);

% Compute and plot the rms error for each of the targets if the debug
% flag is set. Note that cotrended flux values are zero if associated gap
% indicators are set.
debugLevel = pdcModuleParameters.debugLevel;

if debugLevel
    
    cotrendedFluxArray = [cotrendedFluxTimeSeries.values];
    gapIndicatorsArray = [cotrendedFluxTimeSeries.gapIndicators];
    
    nSamples = sum(~gapIndicatorsArray);
    meanCotrendedFlux = sum(cotrendedFluxArray) ./ nSamples;
    detrendedFluxArray = cotrendedFluxArray - ...
        repmat(meanCotrendedFlux, [size(cotrendedFluxArray, 1), 1]);
    detrendedFluxArray(gapIndicatorsArray) = 0;
    
    rmsError = sqrt(sum(detrendedFluxArray .^ 2) ./ nSamples);

    cotrendedFluxArray(gapIndicatorsArray) = NaN;
    medianAbsoluteError = mad(cotrendedFluxArray, 1);

    mags = [targetDataStruct.keplerMag];
    [sortedMags, indxSortedMags] = sort(mags);
    clf;
    semilogy(sortedMags, rmsError(indxSortedMags), '.b');
    hold;
    semilogy(sortedMags, medianAbsoluteError(indxSortedMags), '.r');
    title('Errors in Cotrended Time Series');
    xlabel('Target Magnitude');
    ylabel('Error');
    legend('RMS', 'MAD')
    grid;
    input('Press return to continue >>>');

    pause(4);
    
end

% Plot four results at a time if debug flag is set. Pause one second
% between updates. User can escape at any time with CTRL-C.
if debugLevel
    
    clf;
    nPlotRows = 4;
    nGroups = fix(nTargets / nPlotRows);

    for count = 1 : nGroups
        iTarget = count;
        for iPlotRow = 1 : nPlotRows
            plot_series( ...
                targetDataStruct(iTarget).values, ...
                fittedFluxTimeSeries(iTarget).values, ...
                cotrendedFluxTimeSeries(iTarget).values, ...
                targetDataStruct(iTarget).gapIndicators, ...
                nPlotRows, iPlotRow, iTarget);
            iTarget = iTarget + nGroups;
        end
        pause(1);
    end

end % if

% Return.
return


function plot_series(targetFlux, fittedFlux, cotrendedFlux, ...
gapIndicators, nPlotRows, iPlotRow, iTarget)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_series(targetFlux, fittedFlux, cotrendedFlux, ...
% gapIndicators, nPlotRows, iPlotRow, iTarget)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot target flux with fitted flux side by side with cotrended flux.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

i = (1 : length(targetFlux))';

subplot(nPlotRows, 2, 2*iPlotRow - 1)
set(gca,'fontsize',7);
hold off
plot(i(~gapIndicators), targetFlux(~gapIndicators), 'b.-');
hold on
plot(i(~gapIndicators), fittedFlux(~gapIndicators), 'r.-');
str = sprintf('Target = %d', iTarget);
title(str);
        
subplot(nPlotRows, 2, 2*iPlotRow)
set(gca,'fontsize',7);
plot(i(~gapIndicators), cotrendedFlux(~gapIndicators), 'b.-');
str = sprintf('Target = %d', iTarget);
title(str);

% Return.
return
