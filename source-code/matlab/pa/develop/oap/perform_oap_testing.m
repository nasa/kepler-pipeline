% Moving this method outside of the class structure becuase old-schoool matlab classes do not allow for easy access to object fields and methods making
% debugging very slow.
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
% function [paResultsStruct] = ...
% perform_optimal_aperture_photometry(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Perform optimal aperture photometry (OAP) on a target by target basis. For
% each cadence, combine the fitted background in the found optimal aperture to
% produce the backgroundFluxTimeseries. Combine the values for the target
% pixels in the found optimal aperture and subtract the background flux to
% produce the targetFluxTimeseries. Set a gap in these flux time series at
% any cadence for which a pixel is missing in the optimal aperture for a
% given target. 
% After the target and background flux are determined, the fitted
% background is removed from all target pixels in the aperture and these
% background corrected target pixels replace the original pixel values in
% the paDataObject. Standard propagation of uncertainties is applied.
%
% Inputs:
%   paDataObject    -- [struct] a struct version os paDataObject
%   paResultsStruct -- [paResultsStruct]
%   kic             -- [struct] Fulle KIC catalog for all objects, Giant struct!
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [paDataObject, paResultsStruct, optimumApertureEachTarget] = perform_oap_testing(paDataObject, paResultsStruct, kic, coaParameterStruct)


% Get fields from input object.
targetStarDataStruct = paDataObject.targetStarDataStruct;
targetStarResultsStruct = paResultsStruct.targetStarResultsStruct;
backgroundPolyStruct = paDataObject.backgroundPolyStruct;

cadenceTimes = paDataObject.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;
gapFilledCadenceTimes  = pdc_fill_cadence_times (cadenceTimes);

paConfigurationStruct = paDataObject.paConfigurationStruct;
simulatedTransitsEnabled = paConfigurationStruct.simulatedTransitsEnabled;
removeMedianSimulatedFlux = paConfigurationStruct.simulatedTransitsEnabled;
debugLevel = paConfigurationStruct.debugLevel;

% Loop through the targets.
nTargets = length(targetStarDataStruct);
nCadences = length(timestamps);

oapFigureHandles(1) = figure;
oapFigureHandles(2) = figure;
oapFigureHandles(3) = figure;
oapFigureHandles(4) = figure;
oapFigureHandles(5) = figure;

cdppFigureHandle = figure;

tadCdppRms = zeros(nTargets,1);
paCdppRms  = zeros(nTargets,1);
differenceFound  = false(nTargets,1);

optimumApertureEachTarget = repmat(struct('inOptimalAperture', [], 'pixelAddingOrder', [], 'apertureChanged', [], 'cadencesToFind', []), [nTargets,1]);

%for iTarget = 1 : nTargets
% TODO: TESTING!!!!!
% TODO: TESTING!!!!!
% TODO: TESTING!!!!!
% TODO: TESTING!!!!!
% TODO: TESTING!!!!!
% TODO: TESTING!!!!!
 for iTarget = 1 : nTargets
% TODO: TESTING!!!!!
% TODO: TESTING!!!!!
% TODO: TESTING!!!!!
% TODO: TESTING!!!!!
% TODO: TESTING!!!!!
    
    display(['Working on target ', num2str(iTarget), ' of ', num2str(nTargets)]);
    
    % Get data and results structures for given target.
    targetDataStruct = targetStarDataStruct(iTarget);    
    targetResultsStruct = targetStarResultsStruct(iTarget);
    
    % Get pixel values, uncertainties, gaps, rows and columns in the optimal aperture.
    pixelDataStruct = targetDataStruct.pixelDataStruct;
    withBackgroundPixelValues = [pixelDataStruct.values];
    pixelUncertainties = [pixelDataStruct.uncertainties];
    gapArray = [pixelDataStruct.gapIndicators];
    rows = [pixelDataStruct.ccdRow];
    cols = [pixelDataStruct.ccdColumn];
    
    
    % Calculate background subtracted pixels and uncertainties over full
    % aperture and update targetDataStruct. This operation must be done
    % cadence by cadence since multiple cadence use cases are not supported
    % by weighted_polyval2d. Uncertainties are propagated assuming both
    % target pixel values and fitted background values are independent. 
    
    newPixelValues          = zeros(size(withBackgroundPixelValues));
    newPixelUncertainties   = zeros(size(withBackgroundPixelValues));
    backgroundValues        = zeros(size(withBackgroundPixelValues));
    backgroundUncertainties = zeros(size(withBackgroundPixelValues));
    for iCadence = 1:nCadences
        backgroundPoly = backgroundPolyStruct(iCadence).backgroundPoly;
        [backgroundValues(iCadence,:), backgroundUncertainties(iCadence,:)] = weighted_polyval2d(rows, cols, backgroundPoly);
        newPixelValues(iCadence,:) = withBackgroundPixelValues(iCadence,:) - backgroundValues(iCadence,:);
        newPixelUncertainties(iCadence,:) = sqrt(pixelUncertainties(iCadence,:).^2 + rowvec(backgroundUncertainties(iCadence,:)).^2);
    end
    
    % deal background removed pixels back into pixelDataStruct    
    valuesCellArray = num2cell(newPixelValues,1);
    [pixelDataStruct.values] = deal(valuesCellArray{:});
    uncertaintiesCellArray = num2cell(newPixelUncertainties,1);
    [pixelDataStruct.uncertainties] = deal(uncertaintiesCellArray{:});
    
    % update pixels in targetDataStruct
    backgroundRemovedTargetDataStruct = targetDataStruct;
    backgroundRemovedTargetDataStruct.pixelDataStruct = pixelDataStruct;
    
    % update paDataObject for this target
    % Background is now removed
    paDataObject.targetStarDataStruct(iTarget) = backgroundRemovedTargetDataStruct;

   %% Check if there are any pixels in optimal aperture.
   %inOptimalAperture = [pixelDataStruct.inOptimalAperture]';   

    withBackgroundPixels = withBackgroundPixelValues;

    %***
    % Find optimum aperture per cadence
    [optimumApertureEachTarget(iTarget).inOptimalAperture optimumApertureEachTarget(iTarget).pixelAddingOrder ...
            optimumApertureEachTarget(iTarget).cadencesToFind optimumApertureEachTarget(iTarget).apertureChanged fluxFraction crowdingMetric] = ...
            find_optimum_aperture_per_cadence (paDataObject, withBackgroundPixels, ...
                        backgroundValues, backgroundUncertainties, oapFigureHandles, iTarget, nTargets, kic, coaParameterStruct);

    %The median of the apertures found at each cadence
    inOptimalAperture = optimumApertureEachTarget(iTarget).inOptimalAperture;

    %***
    % Run the CDPP afterburner.
    % This will look at the CDPP of the resulting light curves as a function of the adding pixels in the pixel adding order

    inOptimalApertureCdpp = cdpp_afterburner (inOptimalAperture, optimumApertureEachTarget(iTarget).pixelAddingOrder, pixelDataStruct, ...
                            paDataObject.gapFillConfigurationStruct, gapFilledCadenceTimes, iTarget, cdppFigureHandle);

    %***

    % Determine pixels in optimum aperture taking a median of the images found
   %[inOptimalApertureMedianImage, tadCdppRms(iTarget), paCdppRms(iTarget)] = ...
   %            find_optimal_aperture_from_median_image(paDataObject, withBackgroundPixels, backgroundValues, backgroundUncertainties, ...
   %                                    oapFigureHandles, iTarget, nTargets, kic, coaParameterStruct);
   %
   %differenceFound(iTarget) = any(inOptimalApertureMedianAperture ~= inOptimalApertureMedianImage);

   %display(['For target ', num2str(iTarget), ' Difference found = ', num2str(differenceFound )]);

    % Only plot if there is a difference between the two methods
   %if (differenceFound(iTarget))
        % Plot a comparison of the flux between the two methods and the Tad Flux
        fluxFigure = oapFigureHandles(3);
        [~, ~] = plot_flux (pixelDataStruct, inOptimalAperture, inOptimalApertureCdpp, fluxFigure, iTarget, nTargets, ...
                            gapFilledCadenceTimes, paDataObject.gapFillConfigurationStruct, fluxFraction, crowdingMetric);
       %display(['Found difference for target ', num2str(iTarget)]);
        pause;
   %end

    if (false)
   %if (any(inOptimalAperture))
        
        withBackgroundPixelValues = withBackgroundPixelValues( : , inOptimalAperture);
        pixelUncertainties = pixelUncertainties( : , inOptimalAperture);
        gapArray = gapArray( : , inOptimalAperture);
        rows = rows(inOptimalAperture);
        cols = cols(inOptimalAperture);
        
        % Set a gap in the flux time series if any pixel in the optimal
        % aperture for the given target is missing. Set all gapped values
        % and uncertainties to 0.
        gapIndicators = any(gapArray, 2);
        withBackgroundPixelValues(gapIndicators, : ) = 0;
        pixelUncertainties(gapIndicators, : ) = 0;

        % Initialize background flux time series. Use same gaps as flux time
        % series
        backgroundFluxTimeSeries.values = zeros(nCadences,1);
        backgroundFluxTimeSeries.uncertainties = zeros(nCadences,1);
        backgroundFluxTimeSeries.gapIndicators = gapIndicators;
        
        % Perfrom SAP on fitted background values. Include standard
        % propagation of errors. This operation must be done cadence by
        % cadence since multiple cadence use cases are not supported by
        % weighted_polyval2d. Note: Since fill_background_polynomial_struct
        % has been run prior to this point there is a background polynomial
        % avaliable for all cadences. 
        for iCadence = 1:nCadences
            % Ensure that flux time series and background time series values/uncertainties are set to 0 on cadences where gap indicators are set.
            if ~gapIndicators(iCadence)
                backgroundPoly = backgroundPolyStruct(iCadence).backgroundPoly;
                Cv = backgroundPoly.covariance;
                [backgroundValues, ~, Aback] = weighted_polyval2d(rows, cols, backgroundPoly);
                backgroundFluxTimeSeries.values(iCadence) = sum(backgroundValues);
                backgroundFluxTimeSeries.uncertainties(iCadence) = sqrt(sum(sum(Aback * Cv * Aback')));
            end 
        end

        % Perform SAP on target pixels. Include basic propagation of
        % uncertainties assuming for now that all pixels are uncorrelated
        % for any given cadence. Remove background flux from target flux.
        fluxTimeSeries.values = sum(withBackgroundPixelValues, 2) - backgroundFluxTimeSeries.values;
        fluxTimeSeries.uncertainties = sqrt( sum(pixelUncertainties .^ 2, 2) + backgroundFluxTimeSeries.uncertainties.^2 );
        fluxTimeSeries.gapIndicators = gapIndicators;
        
        % remove the median of any flux added from simulating transits - See KSOC-3215
        if simulatedTransitsEnabled && removeMedianSimulatedFlux
            medianPhotocurrentAdded = targetStarResultsStruct(iTarget).medianPhotocurrentAdded;
            fluxTimeSeries.values(~gapIndicators) = fluxTimeSeries.values(~gapIndicators) - medianPhotocurrentAdded;                
        end            

    else % there are no pixels in aperture
        
        backgroundFluxTimeSeries.values = zeros([nCadences, 1]);
        backgroundFluxTimeSeries.uncertainties = zeros([nCadences, 1]);
        backgroundFluxTimeSeries.gapIndicators = true([nCadences, 1]);         
        
        fluxTimeSeries.values = zeros([nCadences, 1]);
        fluxTimeSeries.uncertainties = zeros([nCadences, 1]);
        fluxTimeSeries.gapIndicators = true([nCadences, 1]);
        
    end % if / else
    
    % Copy the target results to the target star results structure.
    targetResultsStruct.fluxTimeSeries = fluxTimeSeries;
    targetResultsStruct.backgroundFluxTimeSeries = backgroundFluxTimeSeries;
    targetStarResultsStruct(iTarget) = targetResultsStruct;
    
    % Plot the mean flux for each target if the debug flag is greater than
    % zero. Also plot the target flux time series.
    if debugLevel
        close all;
        pixelValues = [backgroundRemovedTargetDataStruct.pixelDataStruct.values];
        gapArray = [backgroundRemovedTargetDataStruct.pixelDataStruct.gapIndicators];
        ccdRows = [backgroundRemovedTargetDataStruct.pixelDataStruct.ccdRow]';
        ccdColumns = [backgroundRemovedTargetDataStruct.pixelDataStruct.ccdColumn]';
        pixelValues(gapArray) = 0;
        nValues = sum(~gapArray, 1)';
        meanTarget = sum(pixelValues, 1)' ./ nValues;
        isValid = nValues > 0;
        plot3(ccdColumns(isValid & inOptimalAperture), ...
            ccdRows(isValid & inOptimalAperture), ...
            meanTarget(isValid & inOptimalAperture), '.r');
        hold on
        plot3(ccdColumns(isValid & ~inOptimalAperture), ...
            ccdRows(isValid & ~inOptimalAperture), ...
            meanTarget(isValid & ~inOptimalAperture), '.b');
        hold off
        title(['[PA] Mean Target Flux -- Kepler Id ', ...
            num2str(backgroundRemovedTargetDataStruct.keplerId)]);
        xlabel('CCD Column (1-based)');
        ylabel('CCD Row (1-based)');
        zlabel('Flux (e-)');
        pause(1);

        meanTarget(~isValid) = 0;
        minRow = min(ccdRows);
        maxRow = max(ccdRows);
        minCol = min(ccdColumns);
        maxCol = max(ccdColumns);
        nRows = maxRow - minRow + 1;
        nColumns = maxCol - minCol + 1;
        aperturePixelValues = zeros([nRows, nColumns]);
        aperturePixelIndices = sub2ind([nRows, nColumns], ...
            ccdRows - minRow + 1, ccdColumns - minCol + 1);
        aperturePixelValues(aperturePixelIndices) = meanTarget;
        imagesc([minCol; maxCol], [minRow; maxRow], aperturePixelValues);
        set(gca, 'YDir', 'normal');
        colorbar;
        title(['[PA] Mean Target Flux -- Kepler Id ', ...
            num2str(backgroundRemovedTargetDataStruct.keplerId)]);
        xlabel('CCD Column (1-based)');
        ylabel('CCD Row (1-based)');
        pause(1)
        
        gapIndicators = fluxTimeSeries.gapIndicators;
        startTime = fix(timestamps(find(~cadenceGapIndicators, 1)));
        plot(timestamps(~gapIndicators) - startTime, ...
            fluxTimeSeries.values(~gapIndicators), '.-b');
        title(['[PA] Target Flux -- Kepler Id ', ...
            num2str(backgroundRemovedTargetDataStruct.keplerId)]);
        xlabel(['Elapsed Days from ', mjd_to_utc(startTime, 0)]);
        ylabel('Flux (e-)');
        pause(1);
    end %if
    
end % for iTarget

% Copy the target star results structure to the PA results structure.
paResultsStruct.targetStarResultsStruct = targetStarResultsStruct;

end

%*************************************************************************************************************
%*************************************************************************************************************
%*************************************************************************************************************
% INTERNAL FUNCTIONS

%*************************************************************************************************************
% First prototype taken from 
% svn+ssh://host/path/to/getoptaps_K2.m
%

function [inOptimalAperture, tadCdppRms, paCdppRms] = find_optimal_aperture_from_median_image(paDataObject, withBackgroundPixels, ...
                        backgroundValues, backgroundUncertainties, figureHandles, iTarget, nTargets, kic, coaParameterStruct)

    % CONSTANT CONFIGURATION PARAMETERS
    doUsePrfNumerator = true;
    doPerCadenceCalculation = true;
    PIXELSTEP = 100;
                        
    %***
   %% system parameters (These should be passed in, or read from a config file)
   %% TODO: These must be read from the PA inputs
   %readNoise = 100;  % e- 
   %nCoadds = 270; % number of reads in the exposure
   %quantFactor = 12; % quantization noise relative to read noise
   %gain = 110; % average gain in e-/s for noise calculations
   %tExposureSingle = 58*0.10379; % single exposure time in seconds
   %tExp = nCoadds*tExposureSingle; % total exposure time per cadence 
    %***

    cadenceTimes  = pdc_fill_cadence_times (paDataObject.cadenceTimes);

    keplerId        = paDataObject.targetStarDataStruct(iTarget).keplerId;

    % pixelDataStruct has background removed from values
    pixelDataStruct = paDataObject.targetStarDataStruct(iTarget).pixelDataStruct;
    row     = [pixelDataStruct.ccdRow]';
    column  = [pixelDataStruct.ccdColumn]';
    values  = [pixelDataStruct.values]';
    gaps    = [pixelDataStruct.gapIndicators]';
    uncertainties = [pixelDataStruct.uncertainties]';
    tadOptimalAperture = [pixelDataStruct.inOptimalAperture]';

    %****
   %% Locate center pixel via flux weighted centroiding
   %% Assume the TAD optimum aperture contains the center
   %% TODO: this assumption is not valid. Really should do something better
   %% mask pixels outside TAD optimum aperture
   %maskedValues = values;
   %maskedValues(~tadOptimalAperture ,:) = 0.0;
   %[centroidRow, centroidColumn, centroidStatus, centroidCovariance, rowJacobian, columnJacobian] ...
   %                    = compute_flux_weighted_centroid(row, column, maskedValues, uncertainties);

   %centerColumn = median(centroidColumn(~centroidStatus));
   %centerRow    = median(centroidRow(~centroidStatus));
   %centerPixelIndex = find(column == round(centerColumn) & row == round(centerRow));
   %if (isempty(centerPixelIndex));
   %    error('Center pixel could not be found!');
   %end

    %****

    minRow = min(row);
    maxRow = max(row);
    minCol = min(column);
    maxCol = max(column);
    nRows = maxRow - minRow + 1;
    nColumns = maxCol - minCol + 1;
    rowOffset = minRow - 1;
    columnOffset = minCol - 1;

    % Compute median values for pixels
    values(gaps) = nan;
    withBackgroundPixels(gaps) = nan;
   %medianValues = nanmean(values,2);
    medianValues = nanmedian(values,2);
    medianWithBackgroundValues = nanmedian(withBackgroundPixels,1)';
    medianBackgroundValues = nanmedian(backgroundValues,1)';
    medianBackgroundUncertainties = nanmedian(backgroundUncertainties,1)';

    %****
   %prfPixelValues = compute_prf_pixel_values (paDataObject, keplerId, pixelDataStruct, centerRow, centerColumn, medianValues, tExp);

    % Find PRF model pixel values from Rob's method
    nCadences = length(cadenceTimes);
    cadencesToComputeModelFor = false(nCadences,1);
    cadencesToComputeModelFor(1:PIXELSTEP:end) = true;

    [~, medianPrfTargetFlux, medianPrfOtherFlux, medianPrfBackgroundFlux, centerRow, centerColumn] = ...
                        find_prf_pixel_values (paDataObject, iTarget, kic, cadencesToComputeModelFor);
    centerPixelIndex = find(column == round(centerColumn) & row == round(centerRow));

    %***
    % Fill missing pixels so that we have a true nxm grid
    % Also sort the pixels in proper order
    pixelDataStructAperture = zeros(nRows, nColumns);
    pixelDataStructPixelMapping = sub2ind([nRows,nColumns],row - rowOffset, column - columnOffset);
    pixelDataStructAperture(pixelDataStructPixelMapping) = 1;
    missingPixels = ~pixelDataStructAperture;
    missingPixelIndices = find(missingPixels);
    [missingPixelRows, missingPixelColumns] = ind2sub([nRows,nColumns], missingPixelIndices);

    % Sort medianValues and medianWithBackgroundValues in proper sub2ind order
    medianValues(pixelDataStructPixelMapping) = medianValues; % Sort
    medianValues(missingPixelIndices) = 0.0;
    medianWithBackgroundValues(pixelDataStructPixelMapping) = medianWithBackgroundValues; % Sort
    medianWithBackgroundValues(missingPixelIndices) = 0.0;
    centerPixelIndex = pixelDataStructPixelMapping(centerPixelIndex);

    medianBackgroundValues(pixelDataStructPixelMapping) = medianBackgroundValues; % Sort
    medianBackgroundValues(missingPixelIndices) = 0.0;

    medianBackgroundUncertainties(pixelDataStructPixelMapping) = medianBackgroundUncertainties; % Sort
    medianBackgroundUncertainties(missingPixelIndices) = 0.0;

   %% We also need to order the prfPixelValues
   %prfPixelValues(pixelDataStructPixelMapping) = prfPixelValues; % Sort
   %prfPixelValues(missingPixelIndices) = 0.0;

    % We also need to order outputs to the PRF fitting
    medianPrfTargetFlux(pixelDataStructPixelMapping) = medianPrfTargetFlux; % Sort
    medianPrfTargetFlux(missingPixelIndices) = 0.0;
    medianPrfOtherFlux(pixelDataStructPixelMapping) = medianPrfOtherFlux; % Sort
    medianPrfOtherFlux(missingPixelIndices) = 0.0;
    medianPrfBackgroundFlux(pixelDataStructPixelMapping) = medianPrfBackgroundFlux; % Sort
    medianPrfBackgroundFlux(missingPixelIndices) = 0.0;
    %***

    % Clear these since they are in the missing pixel indexing reference
    clear row column values uncertainties gaps tadOptimalAperture  withBackgroundPixels backgroundValues backgroundUncertainties% not needed anymore

    % Pixel flux values should be in e- per cadence.

    %**********************
    % Have to decide what to use in the numerator as the target pixel values.
    if (doUsePrfNumerator)
        numeratorPixelValues       = medianPrfTargetFlux;
    else
        numeratorPixelValues       = medianValues;
    end
    % Likewise, there are options for the denominator
    denominatorPixelValues    = medianWithBackgroundValues;

    nPixels = length(numeratorPixelValues);


    %**********************
    % If using a prf model then the model pixel values can approach the background values. When this happens the SNR test become unreliable because we are
    % comparing two numbers, one with noise (real pixel values) and the other without (PRF values). If the PRF valus is larger than the value of the real pixel
    % value in the denominator then the SNR is artificailly inflated. What we should do is zero the PRF value when they approcah the background noise values.
    % The real question is when do we "approach" the background values?

    %The median value of all background median pixel values
    medianMedianBackgroundValue = median(medianBackgroundValues(medianBackgroundValues ~= 0.0));
    medianMedianBackgroundUncertainties = median(medianBackgroundUncertainties(medianBackgroundUncertainties ~= 0.0));

    % The threshold is 2 sigma in background uncertainty above the background level
    backgroundNoiseThreshold = medianMedianBackgroundValue + 2 * medianMedianBackgroundUncertainties ;

    % Zero all PRF values below the background noise threshold
    if (doUsePrfNumerator)
        numeratorPixelValues(numeratorPixelValues < backgroundNoiseThreshold) = 0.0;
    end


    %**********************
    % Find aperture based on SNR test

    % Flux, and variance of first (center) pixel
    centerFlux = numeratorPixelValues(centerPixelIndex);
    % Component of variance due to shot noise Use the non backgroudn corrected flux so that the background shot noise in included
    centerVariance = denominatorPixelValues(centerPixelIndex);

    % Variance due to non-shot noise terms
    [readNoiseSquared, quantizationNoiseSquared] = find_non_shot_variance (paDataObject, coaParameterStruct, []);

    nonShotVariance = readNoiseSquared + quantizationNoiseSquared;

   %nonShotVariance = readNoise*nCoadds + readNoise*nCoadds/quantFactor;

    %**********************

    % Try to identify and remove background pixels
    snrFigure = figureHandles(1);
    stillFindingBackgroundPixels = true;
    backgroundDominatedPixels = [];
    while (stillFindingBackgroundPixels)

        [pixelAddingOrder] = find_pixel_adding_order (numeratorPixelValues, denominatorPixelValues, nonShotVariance, ...
                                    centerPixelIndex, centerFlux, centerVariance, nRows, nColumns, backgroundDominatedPixels);

        % Cumulative mean flux
        cumFluxContig=cumsum(numeratorPixelValues(pixelAddingOrder));

        % Cumulative mean variance estimate: note read noise and quantization noise terms. 
        % TODO: Should add calibration noise terms (from black & smear)
        cumVarContig = cumsum(denominatorPixelValues(pixelAddingOrder) + nonShotVariance);
    
        % Compute snr & locate peak in curve
        snrContig = cumFluxContig./sqrt(cumVarContig);

        [snrPeakIndex, peakType] = find_snr_peak_or_inflection (snrContig, snrFigure);
        pause(1.0); % Pause for one second to view the iteration

        if (strcmp(peakType, 'target'))
            stillFindingBackgroundPixels = false;
        elseif (strcmp(peakType, 'background'))
            backgroundDominatedPixels = [backgroundDominatedPixels; pixelAddingOrder(snrPeakIndex+1)];
        end
    end

    % Set aperture out to the maximum SNR point
    inOptimalAperture = false(nPixels,1);
    inOptimalAperture(pixelAddingOrder(1:snrPeakIndex)) = true;

    % Remove inserted missing pixels and convert back to pixelDataStruct pixel order
    [inOptimalAperture, pixelAddingOrder, backgroundDominatedPixels, medianPrfTargetFlux, denominatorPixelValues] = convert_to_pixelDataStruct_indexing ...
                                (inOptimalAperture, missingPixelIndices, pixelDataStructPixelMapping, pixelAddingOrder, ...
                                                backgroundDominatedPixels, medianPrfTargetFlux, denominatorPixelValues);

   %apertureFigure = figureHandles(2);
   %apertureFigure2 = figureHandles(4);
   %apertureFigure3 = figureHandles(5);
   %plot_pixel_array (pixelDataStruct, medianPrfTargetFlux, denominatorPixelValues, [centerColumn, centerRow], pixelAddingOrder, snrPeakIndex, ...
   %            backgroundDominatedPixels, apertureFigure, apertureFigure2, apertureFigure3, []);
   %fluxFigure = figureHandles(3);
   %[tadCdppRms, paCdppRms] = ...
   %    plot_flux (pixelDataStruct, inOptimalAperture, fluxFigure, iTarget, nTargets, cadenceTimes, paDataObject.gapFillConfigurationStruct);
   %pause;
    tadCdppRms = 0.0;
    paCdppRms = 0.0;
    
    
end

%************************************************************************************************************
% Finds the pixel adding order where background dominated pixels are masked.
%
% This function is olivious to if we are looking at a single cadence or all cadences averaged.
%

function [pixelAddingOrder] = find_pixel_adding_order (numeratorPixelValues, denominatorPixelValues, nonShotVariance, ...
                                    centerPixelIndex, centerFlux, centerVariance, nRows, nColumns, backgroundDominatedPixels)  

    % TODO: Make sure pixelAddingOrder corresponds to workingApertureModel
    
    nPixels = length(numeratorPixelValues);

    % convolution mask for selecting contig. pixels; use cross to prohibit
    % diagonal-only contiguity
    mask = [0,1,0;1,1,1;0,1,0];  

    % Starting values for cumulative flux and variance
    sumFlux = centerFlux;
    sumVar = centerVariance + nonShotVariance;

    % WorkingApertureModel is the aperture model as we add pixels
    workingApertureModel = zeros(nRows, nColumns);
    % Beginning aperture for just the center pixel
    workingApertureModel(centerPixelIndex) = 1;

    % Keep track of the order of pixels as we add them to the optimal aperture
    % We begin with the centroid pixel
    pixelAddingOrder = centerPixelIndex;
    
    % Add in each neighboring pixel that increases SNR by the most amount. 
    % Sequentially add all pixels.
    % After the loop we pick the cutoff
   %workingApertureFigure = figure;
    for iPixel = 2 : nPixels
        % select neigbors of current pixels
        pixelNeighbors = conv2(workingApertureModel,mask,'same');  % pixels contig. w/ current optimum aperture
        % Find the new pixels under consideration using linear indexing
        newPotentialPixels = setdiff(find(pixelNeighbors),find(workingApertureModel));

        % Remove identidifed background dominated pixels from newPotentialPixels
        newPotentialPixels = setdiff(newPotentialPixels, backgroundDominatedPixels);
        
        % construct arrays of the current signal and variance plus each of
        % the neighboring pixels
        signalArray = sumFlux + numeratorPixelValues(newPotentialPixels);
        varArray    = sumVar + denominatorPixelValues(newPotentialPixels) + nonShotVariance;
        snrArray    = (signalArray)./sqrt(varArray);
        % Pick the pixel that maximizes the SNR
        [~,maxSnrIndex]=max(snrArray);
        bestPixelIndex = newPotentialPixels(maxSnrIndex);
        workingApertureModel(bestPixelIndex) = 1;
        
        % Update running signal & variance totals
        sumFlux = sumFlux + numeratorPixelValues(bestPixelIndex);
        sumVar  = sumVar  + denominatorPixelValues(bestPixelIndex) + nonShotVariance;

        pixelAddingOrder = [pixelAddingOrder; bestPixelIndex];
       %[tempInOptimalAperture, tempPixelAddingOrder] = convert_to_pixelDataStruct_indexing ...
       %            (workingApertureModel(:), missingPixelIndices, pixelDataStructPixelMapping, pixelAddingOrder);
       %plot_pixel_array (pixelDataStruct, [centerColumn, centerRow], tempPixelAddingOrder, [], workingApertureFigure);
       %pause;
    end % loop over pixels
    
end

%*************************************************************************************************************
% Plots the mean pixel values for an aperture. 
%
% Plots optimum aperture and the new found optimum aperture
%
% Also plot the found center.
%
% Inputs:
%   pixelDataStruct -- [struct]
%       .ccdRow
%       .ccdColumn
%       .values
%       .gapIndicators
%   prfPixelValues          -- the PRF model pixel values, This is in the proper mesh pixel order including missing pixels
%   center                  -- [int array(2)] [column, row] in 1-based pixel units;
%   foundPixelAddingOrder   -- [int array(nPixelsInAperture)] The list of pixels in found aperture in found order
%   nPeakPixels             -- [int] number of pixels from foundPixelAddingOrder that are in the found optimum aperture
%                                   if empty then select all pixels.
%
%

function [figureHandle] = plot_pixel_array (pixelDataStruct, prfPixelValues, withBackgroundValues, center, foundPixelAddingOrder, nPeakPixels, ...
    backgroundDominatedPixels, figureHandle, figureHandle2, figureHandle3, cadenceIndex)

    row     = [pixelDataStruct.ccdRow]';
    column  = [pixelDataStruct.ccdColumn]';
    tadOptimalAperture = [pixelDataStruct.inOptimalAperture];

    % id no cadence index is passed then take median of all values 
    if (isempty(cadenceIndex))
        values  = [pixelDataStruct.values]';
        gaps    = [pixelDataStruct.gapIndicators]';
        values(gaps) = nan;
        values = nanmedian(values,2);
    else
        nPixels = length(pixelDataStruct);
        values = zeros(nPixels,1);
        gaps   = false(nPixels,1);
        for iPixel = 1 : nPixels
            values(iPixel)  = pixelDataStruct(iPixel).values(cadenceIndex);
            gaps(iPixel)    = pixelDataStruct(iPixel).gapIndicators(cadenceIndex);
        end
        values(gaps) = nan;
    end

    if (length(row) ~= length(column))
        error('Row and Column should be the same length');
    end
    
    if (isempty(nPeakPixels))
        nPeakPixels = length(foundPixelAddingOrder);
    end


    minRow = min(row);
    maxRow = max(row);
    minCol = min(column);
    maxCol = max(column);
    nRows = maxRow - minRow + 1;
    nColumns = maxCol - minCol + 1;
    aperturePixelValues = zeros([nRows, nColumns]);
    aperturePixelIndices = sub2ind([nRows, nColumns], ...
        row - minRow + 1, column - minCol + 1);
    aperturePixelValues(aperturePixelIndices) = values;

    % Set up PRF model and backgroudn added pixel arrays
    prfPixelValuesGrid = zeros([nRows, nColumns]);
    prfPixelValuesGrid(aperturePixelIndices) = prfPixelValues;
    withBackgroundValuesGrid = zeros([nRows, nColumns]);
    withBackgroundValuesGrid(aperturePixelIndices) = withBackgroundValues;

    backgroundValuesGrid = withBackgroundValuesGrid - aperturePixelValues;

    % Set the color limits for the imagesc plots so they are all on the same scale
    clims = [0 max([aperturePixelValues(:); prfPixelValuesGrid(:); backgroundValuesGrid(:)])];

    if (isempty(figureHandle))
        figureHandle = figure;
    else
        figure(figureHandle);
    end
    hold off;
   %imagesc([minCol; maxCol], [minRow; maxRow], aperturePixelValues, clims);
    imagesc([minCol; maxCol], [minRow; maxRow], withBackgroundValuesGrid, clims);
    set(gca,'YTick',[min(row):max(row)]);
    set(gca,'XTick',[min(column):max(column)]);
    set(gca, 'YDir', 'normal');
    colorbar;
    if (isempty(cadenceIndex))
        title(['Median Raw Pixel Values (with background)']);
    else
        title(['Median Raw Pixel Values (with background); for cadence ', num2str(cadenceIndex)]);
    end
    xlabel('CCD Column (1-based)');
    ylabel('CCD Row (1-based)');

    hold on;

    % plot the target pixel model (PRF model values)
   %[missingPixelRows, missingPixelColumns] = ind2sub([nRows,nColumns], missingPixelIndices);
    contour([minCol: maxCol], [minRow: maxRow], prfPixelValuesGrid, 'LineColor', 'black');

    % Plot the center
    plot(center(1), center(2), '*w', 'MarkerSize',10);
        
    % Plot the TAD Optimum Aperture
    plot(column(tadOptimalAperture), row(tadOptimalAperture), '+w', 'MarkerSize',15, 'MarkerEdgeColor','w');

    % Plot the background dominated pixels
    plot(column(backgroundDominatedPixels), row(backgroundDominatedPixels), 'xw', 'MarkerSize', 20)

    % Plot the Found Optimum Aperture
    textOffset = 0.3; % in units of pixels
    for iPixel = 1 : length(foundPixelAddingOrder)
        if (iPixel <= nPeakPixels)
            plot(column(foundPixelAddingOrder(iPixel)), row(foundPixelAddingOrder(iPixel)), 'ow', 'MarkerSize', 20);
        end
        text(column(foundPixelAddingOrder(iPixel)) + textOffset, row(foundPixelAddingOrder(iPixel))+textOffset, num2str(iPixel), ...
                                    'HorizontalAlignment', 'left', 'BackgroundColor', 'w');
    end

    hold off;

    if (isempty(backgroundDominatedPixels))
        legendHandle = legend('PRF Model Values', 'Found Center', 'TAD Optimal Aperture', 'Found Optimal Aperture');
    else
        legendHandle = legend('PRF Model Values', 'Found Center', 'TAD Optimal Aperture', 'Found Background Objects', 'Found Optimal Aperture');
    end
    set(legendHandle, 'Color', [0.45, 0.45, 0.45])

    % Also plot the evaluated PRF
    figure(figureHandle2);
    imagesc([minCol; maxCol], [minRow; maxRow], prfPixelValuesGrid, clims);
    set(gca,'YTick',[min(row):max(row)]);
    set(gca,'XTick',[min(column):max(column)]);
    set(gca, 'YDir', 'normal');
    colorbar;
    title('The PRF model pixel values');
    xlabel('CCD Column (1-based)');
    ylabel('CCD Row (1-based)');

    % Also also plot the background removed values.
    figure(figureHandle3);
    imagesc([minCol; maxCol], [minRow; maxRow], aperturePixelValues, clims);
    set(gca,'YTick',[min(row):max(row)]);
    set(gca,'XTick',[min(column):max(column)]);
    set(gca, 'YDir', 'normal');
    colorbar;
    title('The pixel values background removed');
    xlabel('CCD Column (1-based)');
    ylabel('CCD Row (1-based)');

end

%*************************************************************************************************************
%
% The pixelDataStruct is in some odd order. It's not a typical nxm matrix indexing. This function converts from matrix indexing to the pixelDataStruct order. It
% uses the <pixelDataStructPixelMapping> map to convert to the proper order and <missingPixelIndices> to remove the pixel in the square grid that are not in
% pixelDataStruct.
%

function [inOptimalAperture, pixelAddingOrder, backgroundDominatedPixels, targetPixelValues, withBackgroundValues] =  convert_to_pixelDataStruct_indexing ...
                (inOptimalAperture, missingPixelIndices, pixelDataStructPixelMapping, pixelAddingOrder, backgroundDominatedPixels, ...
                    targetPixelValues, withBackgroundValues)

    % Convert to the PixelDataStruct pixel order
   %inOptimalAperture = false(length(inOptimalAperture) - length(missingPixelIndices),1);
    inOptimalAperture = inOptimalAperture(pixelDataStructPixelMapping);

    targetPixelValues    = targetPixelValues(pixelDataStructPixelMapping);
    withBackgroundValues = withBackgroundValues(pixelDataStructPixelMapping);

    [~,addingOrderLoc] = ismember(pixelAddingOrder, pixelDataStructPixelMapping);
    [~,backgroundLoc] = ismember(backgroundDominatedPixels, pixelDataStructPixelMapping);

    % Remove missing pixels
    pixelAddingOrder = addingOrderLoc(addingOrderLoc~=0);
    backgroundDominatedPixels= backgroundLoc(backgroundLoc~=0);

   %% Flag the in optimal aperture pixels, but only those that are not missing from the square grid
   %inOptimalAperture(addingOrderLoc(addingOrderLoc~=0)) = true;


end

%*************************************************************************************************************
% Find the SNR peak or saddle
%
% Inputs:
%   snrContig       -- the contiguous cumulative sum SNR as each pixel is added.
%   figureHandle    -- The figure to plot to
% Outputs:
%   peakType = {'target', 'background'}
%

function [snrPeakIndex peakType] = find_snr_peak_or_inflection (snrContig, figureHandle)

    [~,snrPeakIndex] = max(snrContig);
    
    %**********************
    % The SNR curve has inflections where new stars are pulled into the
    % aperture. 

    % Need to have a fudge factor to decide when an inflection or peak is significant.
    snrContigScale = std(snrContig);
    threshold = 0.01; % 1% of STD is significant
    featureSignificance = snrContigScale * threshold;

    smoothNumPix = 1; % number of pixels over which to smooth derivatives
    
    snrContigSmooth  = medfilt1(snrContig  ,smoothNumPix);
    ddSmooth  = medfilt1(diff(snrContig)  ,smoothNumPix);
    dd2Smooth = medfilt1(diff(snrContig,2),smoothNumPix); % smoothed 2nd derivative
    % pad 2nd deritive so datums line up
    dd2Smooth = [0; dd2Smooth];
    
    % This is the first true maximum
   %firstPeakIndex  = find(ddSmooth < 0, 1, 'first');
   %[~, firstPeakIndex] = findpeaks(snrContigSmooth, 'NPEAKS', 1);
    [~, firstPeakIndex] = max(snrContigSmooth);
    if (isempty(firstPeakIndex))
        firstPeakIndex = length(snrContig);
    end

    % Find first increase in the 1st derivative (i.e. 2nd derivative > 0) after 1st derivative passed it's first peak
    [~, firstddPeak] = findpeaks(ddSmooth, 'NPEAKS', 1);
    if (isempty(firstddPeak))
        firstddPeak = 1;
    end
    
    inflectionIndex = find(dd2Smooth(firstddPeak:end) > featureSignificance, 1, 'first') + firstddPeak-1;
    if (isempty(inflectionIndex))
        inflectionIndex = length(snrContig);
    end

   %snrPeakIndex = min(firstPeakIndex, inflectionIndex);

   %if (snrPeakIndex == inflectionIndex && inflectionIndex ~= length(snrContig))
   %    peakType = 'background';
   %else
   %    peakType = 'target';
   %end

    % Just pick peak, ignore inflections
    snrPeakIndex = firstPeakIndex;
    peakType = 'target';
    
    %***
    % Find when 1st deriviative begins to increase after decreasing
   %firstDecrease = find(dd2Smooth < 0, 1, 'first');
   %snrPeakIndex = find(ddSmooth(firstDecrease+1:end)); 

    %***
    % Find when 2nd derivative is higher than 1st derivative.
   %snrPeakIndex = find(dd2Smooth > ddSmooth);

    %***
   %% This approach is to look for first time the derivative goes negative, or
   %% when the smoothed 2nd derivative is positive and the smoothed 1st
   %% derivative is still significantly positive
   %dd        = diff(snrContig);  
   %
   %eps1st = 0.0; % paramater for significant 1st derivative
   %eps2nd = 0.0; % parameter for significant 2nd derivative
   %ddPeakIndex  = find(dd<0, 1, 'first');
   %dd2PeakIndex = find( dd2Smooth(2:end) > eps2nd & ddSmooth(2:end-1) > eps1st, 1, 'first');
   %
   %
   %% Now pick the aperture
   %if (isempty(ddPeakIndex))
   %    % If there is no 2nd deriviative peak we default to using all the pixels in the contiguous aperture
   %    warning('find_optimal_aperture: no optimum aperture found, using all pixels in aperture.')
   %else
   %    if isempty(dd2PeakIndex)
   %        dd2Peakindex=ddPeakIndex; % no 2nd derivative matching case found
   %    end
   %    snrPeakIndex= min(ddPeakIndex,dd2PeakIndex);  % select the smallest aperture that meets one of the two conditions
   %end
    %***

    if (~isempty(figureHandle)) 
        % Plot the found peak
        figure(figureHandle)
        hold off;
        subplot(2,1,1);
        title('Finding the First Peak or Inflection');
        plot(snrContig, '-*b');
        hold on;
        plot(firstPeakIndex,     snrContig(firstPeakIndex), 'or', 'MarkerSize',10);
        plot(inflectionIndex, snrContig(inflectionIndex), 'oc', 'MarkerSize',10);
        plot(snrPeakIndex,    snrContig(snrPeakIndex), 'ok', 'MarkerSize',15);
        hold off;
        legend('SNR', 'First Peak', 'First Inflection', 'Optimum Aperture', 'Location', 'Best')
        grid on;
        subplot(2,1,2);
        plot(ddSmooth,  '-*r');
        hold on;
        plot(dd2Smooth, '-*c');
        hold off;
        legend('First Derivative', 'Second Derivative', 'Location', 'Best');
        grid on;
    end

end

%*************************************************************************************************************
% Plots the aperture flux. Comparing both the TAD aperture and the found aperture.
% Backgrounds are already removed.
%
% Inputs:
%   pixelDataStruct -- [struct]
%       .ccdRow
%       .ccdColumn
%       .values
%       .gapIndicators
%

function [tadCdppRms, paCdppRms] = plot_flux (pixelDataStruct, ...
                        inOptimalAperture, inOptimalApertureCdpp, figureHandle, iTarget, nTargets, cadenceTimes, gapFillConfigurationStruct, fluxFraction, crowdingMetric)

        

    row     = [pixelDataStruct.ccdRow]';
    column  = [pixelDataStruct.ccdColumn]';
    values  = [pixelDataStruct.values]';
    gaps    = [pixelDataStruct.gapIndicators]';
    tadOptimalAperture = [pixelDataStruct.inOptimalAperture];

    if (length(row) ~= length(column))
        error('Row and Column should be the same length');
    end
    
   %if (isempty(nPeakPixels) || nPeakPixels > length(foundPixelAddingOrder))
   %    nPeakPixels = length(foundPixelAddingOrder);
   %end

    % Summing flux so zero gaps
    values(gaps) = 0.0;

    % TAD SAP
    tadSap = sum(values(tadOptimalAperture,:),1)';

    % Found SAP
    paSap = sum(values(inOptimalAperture,:),1)';
    paSapCdpp = sum(values(inOptimalApertureCdpp,:),1)';

    tadGaps = any(gaps(tadOptimalAperture,:),1);
    paSapGaps = any(gaps(inOptimalAperture,:),1);
    paSapCdppGaps = any(gaps(inOptimalApertureCdpp,:),1);

   %% Correct for Flux Fraction and Crowding Metric
   %paSapCorrected = paSap;
   %nonZeroFfAndCm = fluxFraction ~=0 & crowdingMetric ~=0;
   %paSapCorrected(nonZeroFfAndCm) = paSap(nonZeroFfAndCm)  - (1 - crowdingMetric(nonZeroFfAndCm)) * median(paSap(paSapGaps));
   %paSapCorrected(nonZeroFfAndCm) = paSapCorrected(nonZeroFfAndCm) ./ fluxFraction(nonZeroFfAndCm);

    tadSap(tadGaps) = nan;
    paSap(paSapGaps) = nan;
    paSapCdpp(paSapCdppGaps) = nan;
   %paSapCorrected(paSapGaps) = nan;

    % The mean flux values can be dramatically different since different number of pixels are added together. We need to normalize the mean flux values
    tadSap  = mapNormalizeClass.normalize_value (tadSap, nanmedian(tadSap), [], [], [], 'median');
    paSap   = mapNormalizeClass.normalize_value (paSap, nanmedian(paSap), [], [], [], 'median');
    paSapCdpp = mapNormalizeClass.normalize_value (paSapCdpp, nanmedian(paSapCdpp), [], [], [], 'median');
   %paSapCorrected   = mapNormalizeClass.normalize_value (paSapCorrected, nanmedian(paSapCorrected), [], [], [], 'median');

    % We need to fill gaps onces very simply for the median filtering
    % Further down we fill gaps better
    tadSap(tadGaps) = interp1(cadenceTimes(~tadGaps), tadSap(~tadGaps), cadenceTimes(tadGaps), 'pchip');

    if (~isempty(paSap(~paSapGaps)))
        paSap(paSapGaps)   = interp1(cadenceTimes(~paSapGaps), paSap(~paSapGaps), cadenceTimes(paSapGaps), 'pchip');
    end

    if (~isempty(paSapCdpp(~paSapCdppGaps)))
        paSapCdpp(paSapCdppGaps)   = interp1(cadenceTimes(~paSapCdppGaps), paSapCdpp(~paSapCdppGaps), cadenceTimes(paSapCdppGaps), 'pchip');
    end

   %if (~isempty(paSapCorrected(~paSapGaps)))
   %    paSapCorrected(paSapGaps) = interp1(cadenceTimes(~paSapGaps), paSapCorrected(~paSapGaps), cadenceTimes(paSapGaps), 'pchip');
   %end

   %smoothNumCadences = 47;
    smoothNumCadences = 100;
    % NaNs will "NaN" call medfilt1 values within <smoothNumCadences> cadences from each NaNed cadence, 
    tadSapDetrended = tadSap    - medfilt1(tadSap, smoothNumCadences);
    paSapDetrended  = paSap- medfilt1(paSap, smoothNumCadences);
    paSapCdppDetrended  = paSapCdpp- medfilt1(paSapCdpp, smoothNumCadences);
   %paSapCorrectedDetrended  = paSapCorrected     - medfilt1(paSapCorrected, smoothNumCadences);

    % Need
    % maxCorrelationWindowLimit           = maxCorrelationWindowXFactor * maxArOrderLimit;
    % To be larger than the largest gap
    gapFillConfigurationStruct.maxCorrelationWindowXFactor = 300 / gapFillConfigurationStruct.maxArOrderLimit;

    [tadSapDetrended] = fill_short_gaps(tadSapDetrended, tadGaps, [], false, gapFillConfigurationStruct, [], zeros(length(tadSapDetrended),1));
    [paSapDetrended]            = fill_short_gaps(paSapDetrended, paSapGaps, [], false, gapFillConfigurationStruct, [], ...
                                                    zeros(length(paSapDetrended),1));
    [paSapCdppDetrended]            = fill_short_gaps(paSapCdppDetrended, paSapCdppGaps, [], false, gapFillConfigurationStruct, [], ...
                                                    zeros(length(paSapCdppDetrended),1));
   %[paSapCorrectedDetrended]   = fill_short_gaps(paSapCorrectedDetrended, paSapGaps, [], false, gapFillConfigurationStruct, [], ...
   %                                                zeros(length(paSapCorrectedDetrended),1));

    %***
   %sigmaPaSap    = mad(paSapDetrended,1) * 1.4826;
   %sigmaTadSap = mad(tadSapDetrended,1) * 1.4826;

    %***
    % Use actual CDPP calculation!
    % Use default values for CDPP wrapper
    trialTransitPulseDurationInHours = [];
    tpsModuleParameters = [];
    cadencesPerHour = 1 / (median(diff(cadenceTimes))*24);

    % Ignore the edge effects by only looking at the center portion
    tadFluxTimeSeries.values = tadSapDetrended(smoothNumCadences:end-smoothNumCadences);
    tadCdpp = calculate_cdpp_wrapper (tadFluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters);

    if (~isnan(paSapDetrended))
        paFluxTimeSeries.values = paSapDetrended(smoothNumCadences:end-smoothNumCadences);
        paCdpp = calculate_cdpp_wrapper (paFluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters);
    else
        paCdpp.values = 0.0;
        paCdpp.rms = 0.0;
    end

    if (~isnan(paSapCdppDetrended))
        paFluxTimeSeries.values = paSapCdppDetrended(smoothNumCadences:end-smoothNumCadences);
        paCdppCdpp = calculate_cdpp_wrapper (paFluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters);
    else
        paCdppCdpp.values = 0.0;
        paCdppCdpp.rms = 0.0;
    end

   %if (~isnan(paSapCorrectedDetrended))
   %    paFluxTimeSeries.values = paSapCorrectedDetrended(smoothNumCadences:end-smoothNumCadences);
   %    paCorrectedCdpp = calculate_cdpp_wrapper (paFluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters);
   %else
   %    paCorrectedCdpp.values = 0.0;
   %    paCorrectedCdpp.rms = 0.0;
   %end
    %***

    if (isempty(figureHandle))
        figureHandle = figure;
    else
        figure(figureHandle);
    end

    % Put NaNs back in so they plot as blanks
    tadSap(tadGaps) = nan;
    paSap(paSapGaps) = nan;
    paSapCdpp(paSapCdppGaps) = nan;
   %paSapCorrected(paSapGaps) = nan;

   %subplot(2,1,1)
    hold off;
    plot(tadSap, '-b', 'LineWidth', 2);
    hold on;
    plot(paSap, '-r');
    plot(paSapCdpp, '-c');
   %plot(paSapCorrected, '-c');
    L = legend( ['TAD SAP quasi-CDPP rms                  = ', num2str(tadCdpp.rms)], ...
                ['PA SAP quasi-CDPP rms                   = ', num2str(paCdpp.rms)], ...
                ['PA SAP CDPP Afterburner quasi-CDPP rms  = ', num2str(paCdppCdpp.rms)], 'Location', 'Best');
    set(L,'FontName','FixedWidth')
    title (['Median Normalized Flux Values. Plotting target ', num2str(iTarget), ' of ', num2str(nTargets)]);

   %tadSapDetrended(tadGaps) = nan;
   %paSapDetrended(paSapGaps) = nan;

   %subplot(2,1,2)
   %hold off;
   %plot(tadSapDetrended, '-b');
   %hold on;
   %plot(paSapDetrended, '-r');
   %L = legend(['TAD SAP sigma = ', num2str(sigmaTadSap)], ['PA  SAP sigma = ', num2str(sigmaPaSap)], 'Location', 'Best');
   %set(L,'FontName','FixedWidth')
   %title (['Detrended Flux Values. Plotting target ', num2str(iTarget), ' of ', num2str(nTargets)]);

   tadCdppRms         = tadCdpp.rms;
   paCdppRms          = paCdpp.rms;
  %paCorrectedCdppRms = paCorrectedCdpp.rms;
    

end

%*************************************************************************************************************
% This function uses the static PRF model to find the target pixel values. It is really simple but just to have something to test out my method until Rob gives
% me the better target models.
%
% Outputs:
%   prfPixelValues  -- [doubel array] the target flux values for each pixelDataStruct pixel in ELECTRONS PER SECOND
%

function [prfPixelValues] = compute_prf_pixel_values (paDataObject, keplerId, pixelDataStruct, centerRow, centerCol, backgroundRemovedPixelValues, tExp)

    % There is a bug in the PA inouts where keplerMag Ra and Dec are not in the inputsStruct for PA "Target" runs
    % For now load from a saved file
    kicFilename = '/path/to/ksoc-3891_pixel_weighted_photometry/test_pa_task/st-6_oap/Q15_2_1_kic.mat';
    load(kicFilename);

    targetIndex = find([Q15_2_1_kic.keplerId] == keplerId);
    keplerMag   = Q15_2_1_kic(targetIndex).keplerMag;
    ra          = Q15_2_1_kic(targetIndex).ra;
    dec         = Q15_2_1_kic(targetIndex).dec;

    starFlux = paDataObject.fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND * (mag2b(keplerMag) / mag2b(12));

    % The prfModel in paDataObject appears to be incorrect.
   %prfModel = retrieve_prf_model(paDataObject.ccdModule, paDataObject.ccdOutput);
    prfStruct = blob_to_struct(paDataObject.prfModel.blob);
    prfObject = prfCollectionClass(prfStruct, paDataObject.fcConstants);

    % ra_dec_2_pix doesn't seem to work
   %firstTimestamp = paDataObject.cadenceTimes.midTimestamps(~paDataObject.cadenceTimes.gapIndicators);
   %firstTimestamp = firstTimestamp(1);
   %raDec2PixObject = raDec2PixClass(paDataObject.raDec2PixModel, 'one-based');
   %[module output centerRow, centerCol] = ra_dec_2_pix(raDec2PixObject, ra, dec, firstTimestamp);

   %prfPixelValues = evaluate(prfObject, centerRow, centerCol, [pixelDataStruct.ccdRow], [pixelDataStruct.ccdColumn]);
    [prfPixelValues, pixelRows, pixelColumns] = evaluate(prfObject, centerRow, centerCol);

    % normalize the flux values
    prfPixelValues = prfPixelValues ./ sum(prfPixelValues);

    prfPixelValues = prfPixelValues * starFlux;

    % Only keep the pixel corresponding to pixelDataStruct
    pixelIndex = zeros(length(pixelDataStruct),1);
    missingPixels = []; 
    for iPixel = 1 : length(pixelDataStruct)
        foundPixel = find(pixelRows == pixelDataStruct(iPixel).ccdRow & pixelColumns == pixelDataStruct(iPixel).ccdColumn);
        if (isempty(foundPixel))
            % No model data for this pixel, set to zero
            missingPixels = [missingPixels, iPixel];
        elseif (length(foundPixel) ~=1)
            error('compute_prf_pixel_values: error finding target PRF model pixel values; Indexing error?');
        else
            pixelIndex(iPixel) = foundPixel;
        end
    end
    pixelIndex = pixelIndex(pixelIndex ~= 0);

    prfPixelValues = prfPixelValues(pixelIndex);

    % Add in missing pixels
    for iPixel = 1 : length(missingPixels)
        if (missingPixels(iPixel) == 1)
            prfPixelValues = [0.0; prfPixelValues];
        elseif (missingPixels(iPixel) == length(pixelDataStruct))
            prfPixelValues = [prfPixelValues; 0.0];
        else
            prfPixelValues = [prfPixelValues(1:missingPixels(iPixel)-1); 0.0; prfPixelValues(missingPixels(iPixel):end)];
        end
    end

    % Convert from e- / sec to e- / cadence
    prfPixelValues  = prfPixelValues * tExp;
    
   %% Scale pixel values so that the center pixel PRF value matches the background removed pixel data values
   %% Find center pixel index
   %centerPixelIndex = find([pixelDataStruct.ccdRow] == round(centerRow) & [pixelDataStruct.ccdColumn] == round(centerCol));

   %scaleFactor = backgroundRemovedPixelValues(centerPixelIndex) / prfPixelValues(centerPixelIndex);

   %prfPixelValues = prfPixelValues * scaleFactor;

end

%*************************************************************************************************************
% Wrapper to find the PRF fitted pixel values from the PRF fitting code.
%

function [prfPixelDataStruct, medianPrfTargetFlux, medianPrfOtherFlux, medianPrfBackgroundFlux, centerRow, centerColumn] = ...
                    find_prf_pixel_values (paDataObject, iTarget, kic, cadencesToComputeModelFor)


    [prfPixelDataStruct, contributingStarStruct, apertureModelObject] = pa_coa_fit_aperture_model(paDataObject, iTarget, ...
            cadencesToComputeModelFor, kic, paDataObject.cadenceType);

    % Nan gaps
    for iPixel = 1 : length(prfPixelDataStruct)
        prfPixelDataStruct(iPixel).targetFluxEstimates(prfPixelDataStruct(iPixel).gapIndicators) = nan;
        prfPixelDataStruct(iPixel).bgStellarFluxEstimates(prfPixelDataStruct(iPixel).gapIndicators) = nan;
        prfPixelDataStruct(iPixel).bgConstFluxEstimates(prfPixelDataStruct(iPixel).gapIndicators) = nan;
    end

    % Find median image
    medianPrfTargetFlux     = nanmedian([prfPixelDataStruct.targetFluxEstimates],1)';
    medianPrfOtherFlux      = nanmedian([prfPixelDataStruct.bgStellarFluxEstimates],1)';
    medianPrfBackgroundFlux = nanmedian([prfPixelDataStruct.bgConstFluxEstimates],1)';

    % Find the target
    targetStarStruct = contributingStarStruct(find([contributingStarStruct.keplerId] == paDataObject.targetStarDataStruct(iTarget).keplerId));
    if(isempty(targetStarStruct))
        error('find_prf_pixel_values: error finding the target star!');
    end

    % Find the center pixel
   %centerRow = median(targetStarStruct.centroidRow(cadencesToComputeModelFor));
   %centerColumn = median(targetStarStruct.centroidCol(cadencesToComputeModelFor));
    centerRow = median(targetStarStruct.centroidRow);
    centerColumn = median(targetStarStruct.centroidCol);

end

%*************************************************************************************************************
% This function calculates the Read Noise and the quantization noise based ont he method as used in TAD-COA coa_matlab_controller
%
%*************************************************************************************************************
function [readNoiseSquared, quantizationNoiseSquared] = find_non_shot_variance (paDataObject, coaParameterStruct, cadenceIndex);

module = paDataObject.ccdModule;
output = paDataObject.ccdOutput;

% If a cadence index is given the use that cadence, otherwise, just use the first cadence
% This probably doesn't really matter
if (isempty(cadenceIndex))
    startMjd = paDataObject.cadenceTimes.midTimestamps(~paDataObject.cadenceTimes.gapIndicators);
    startMjd = startMjd(1);
else
    startMjd = paDataObject.cadenceTimes.midTimestamps(cadenceIndex);
end

% set the number of integrations in a cadence
integrationsPerShort = coaParameterStruct.spacecraftConfigurationStruct.integrationsPerShortCadence;
if (strcmp(paDataObject.cadenceType, 'LONG'))
    shortsPerLong = coaParameterStruct.spacecraftConfigurationStruct.shortCadencesPerLongCadence;
    exposuresPerCadence = integrationsPerShort*shortsPerLong;
else
    exposuresPerCadence = integrationsPerShort;
end


% read noise is in ADU, convert to electrons% make a gain object
gainObject = gainClass(coaParameterStruct.gainModel);
% gain is electrons per ADU
gain = get_gain(gainObject, startMjd, module, output);


% make a read noise object
noiseObject = readNoiseClass(coaParameterStruct.readNoiseModel);
% read noise is in ADU, convert to electrons
readNoisePerExposure = gain*get_read_noise(noiseObject, startMjd, module, output);

readNoiseSquared = readNoisePerExposure^2 * exposuresPerCadence;

% make linearity object
linearityObject = linearityClass(coaParameterStruct.linearityModel);
polyStruct = get_weighted_polyval_struct(linearityObject, startMjd, module, output);
maxDnPerExposure = double(get_max_domain(linearityObject, startMjd, module, output));
wellCapacity = maxDnPerExposure .* gain .* weighted_polyval(maxDnPerExposure, polyStruct);

BITS_IN_ADC = paDataObject.fcConstants.BITS_IN_ADC;

quantizationNoiseSquared = ( wellCapacity / (2^BITS_IN_ADC-1))^2 / 12 * exposuresPerCadence;

end

%*************************************************************************************************************
% Perform brute force test where optimum aperture is calculated at each cadence. 
%
% Check if optimum aperture actually changes at all over the quarter.
%
%*************************************************************************************************************

function [inOptimalApertureMedian pixelAddingOrderMedian cadencesToFind apertureChanged fluxFraction crowdingMetric] = find_optimum_aperture_per_cadence ...
            (paDataObject, withBackgroundPixels, ...
                        backgroundValues, backgroundUncertainties, figureHandles, iTarget, nTargets, kic, coaParameterStruct)

    CADENCESTEP = 200;

    cadenceTimes = pdc_fill_cadence_times (paDataObject.cadenceTimes);
    nCadences    = length(cadenceTimes);

    keplerId        = paDataObject.targetStarDataStruct(iTarget).keplerId;

    % pixelDataStruct has background removed from values
    pixelDataStruct = paDataObject.targetStarDataStruct(iTarget).pixelDataStruct;
    nPixels = length(pixelDataStruct);
    row     = [pixelDataStruct.ccdRow]';
    column  = [pixelDataStruct.ccdColumn]';

    minRow = min(row);
    maxRow = max(row);
    minCol = min(column);
    maxCol = max(column);
    nRows = maxRow - minRow + 1;
    nColumns = maxCol - minCol + 1;
    rowOffset = minRow - 1;
    columnOffset = minCol - 1;

    values = [pixelDataStruct.values];
    uncertainties = [pixelDataStruct.uncertainties];
    gaps   =  [pixelDataStruct.gapIndicators];

    % Perform COA for each cadence seperately
    inOptimalAperture = false(nCadences, nPixels);
    pixelAddingOrder  = zeros(nCadences, nPixels);
    cadencesToFind = false(nCadences,1);
    cadencesToFind(1:CADENCESTEP:end) = true;

    % Get the PRF pixel values for each cadence
    % Find PRF model pixel values from Rob's method

    [prfPixelDataStruct, contributingStarStruct, apertureModelObject] = pa_coa_fit_aperture_model(paDataObject, iTarget, ...
            cadencesToFind, kic);


    % Nan gaps
   %for iPixel = 1 : length(prfPixelDataStruct)
   %    prfPixelDataStruct(iPixel).targetFluxEstimates(prfPixelDataStruct(iPixel).gapIndicators) = nan;
   %    prfPixelDataStruct(iPixel).bgStellarFluxEstimates(prfPixelDataStruct(iPixel).gapIndicators) = nan;
   %    prfPixelDataStruct(iPixel).bgConstFluxEstimates(prfPixelDataStruct(iPixel).gapIndicators) = nan;
   %end

    % Find the target
    targetStarStruct = contributingStarStruct(find([contributingStarStruct.keplerId] == paDataObject.targetStarDataStruct(iTarget).keplerId));
    if(isempty(targetStarStruct))
        error('find_prf_pixel_values: error finding the target star!');
    end
    
    targetStarFlux           = zeros(nCadences,1);
    inApertureFromTarget     = zeros(nCadences,1);
    inApertureFromBackground = zeros(nCadences,1);
    fluxFraction    = zeros(nCadences,1);
    crowdingMetric  = zeros(nCadences,1);

    cadenceIndex = 0;
    for iCadence = 1 : nCadences

        if (~cadencesToFind(iCadence))
            continue;
        end

        prfTargetFlux     = zeros(nPixels,1);
        prfOtherFlux      = zeros(nPixels,1);
        prfBackgroundFlux = zeros(nPixels,1);

        cadenceIndex = cadenceIndex + 1;

       %display(['Working on Cadence ', num2str(iCadence), ' of ', num2str(nCadences), ' for target ', num2str(iTarget), ' of ', num2str(nTargets), '.']);

        % Skip cadence gaps
        if (paDataObject.cadenceTimes.gapIndicators(iCadence))
           %cadencesToFind(iCadence) = false;
            continue;
        elseif (all(gaps(iCadence,:)))
           %cadencesToFind(iCadence) = false;
            continue;
        elseif (any(gaps(iCadence,:)))
           %cadencesToFind(iCadence) = false;
            continue;
        end

        thisCadenceValues = values(iCadence,:)';
        thisCadenceUncertainties = uncertainties(iCadence,:)';
        thisCadenceGaps   = gaps(iCadence,:)';
        thisCadenceWithBackgroundValues = withBackgroundPixels(iCadence,:)';
        thisCadenceBackgroundValues = backgroundValues(iCadence,:)';
        thisCadenceBackgroundUncertainties = backgroundUncertainties(iCadence,:)';

        thisCadenceValues(thisCadenceGaps) = nan;
        thisCadenceUncertainties(thisCadenceGaps) = nan;
        thisCadenceWithBackgroundValues(thisCadenceGaps) = nan;
        thisCadenceBackgroundValues(thisCadenceGaps) = nan;
        thisCadenceBackgroundUncertainties(thisCadenceGaps) = nan;

        %***
        % Get the PRF flux values for this cadence
        for iPixel = 1 : length(prfPixelDataStruct)
            prfTargetFlux(iPixel)     = prfPixelDataStruct(iPixel).targetFluxEstimates(iCadence );
            prfOtherFlux(iPixel)      = prfPixelDataStruct(iPixel).bgStellarFluxEstimates(iCadence );
            prfBackgroundFlux(iPixel) = prfPixelDataStruct(iPixel).bgConstFluxEstimates(iCadence );
        end

        % Find the center pixel
        centerRow = targetStarStruct.centroidRow(cadenceIndex);
        centerColumn = targetStarStruct.centroidCol(cadenceIndex);
        centerPixelIndex = find(column == round(centerColumn) & row == round(centerRow));

        %***
        % Fill missing pixels so that we have a true nxm grid
        % Also sort the pixels in proper order
        pixelDataStructAperture = zeros(nRows, nColumns);
        pixelDataStructPixelMapping = sub2ind([nRows,nColumns],row - rowOffset, column - columnOffset);
        pixelDataStructAperture(pixelDataStructPixelMapping) = 1;
        missingPixels = ~pixelDataStructAperture;
        missingPixelIndices = find(missingPixels);
        [missingPixelRows, missingPixelColumns] = ind2sub([nRows,nColumns], missingPixelIndices);
        
        % Sort pixel values and withBackgroundValues in proper sub2ind order
        thisCadenceValues(pixelDataStructPixelMapping) = thisCadenceValues; % Sort
        thisCadenceValues(missingPixelIndices) = 0.0;
        thisCadenceUncertainties(pixelDataStructPixelMapping) = thisCadenceUncertainties; % Sort
        thisCadenceUncertainties(missingPixelIndices) = 0.0;
        thisCadenceWithBackgroundValues(pixelDataStructPixelMapping) = thisCadenceWithBackgroundValues; % Sort
        thisCadenceWithBackgroundValues(missingPixelIndices) = 0.0;
        centerPixelIndex = pixelDataStructPixelMapping(centerPixelIndex);
        
        thisCadenceBackgroundValues(pixelDataStructPixelMapping) = thisCadenceBackgroundValues; % Sort
        thisCadenceBackgroundValues(missingPixelIndices) = 0.0;
        
        thisCadenceBackgroundUncertainties(pixelDataStructPixelMapping) = thisCadenceBackgroundUncertainties; % Sort
        thisCadenceBackgroundUncertainties(missingPixelIndices) = 0.0;
        
        % We also need to order outputs to the PRF fitting
        prfTargetFlux(pixelDataStructPixelMapping) = prfTargetFlux; % Sort
        prfTargetFlux(missingPixelIndices) = 0.0;
        prfOtherFlux(pixelDataStructPixelMapping) = prfOtherFlux; % Sort
        prfOtherFlux(missingPixelIndices) = 0.0;
        prfBackgroundFlux(pixelDataStructPixelMapping) = prfBackgroundFlux; % Sort
        prfBackgroundFlux(missingPixelIndices) = 0.0;
        %***
        
        % Pixel flux values should be in e- per cadence.

        numeratorPixelValues    = prfTargetFlux;
        denominatorPixelValues  = thisCadenceWithBackgroundValues;
        
        %**********************
        % If using a prf model then the model pixel values can approach the background values. When this happens the SNR test become unreliable because we are
        % comparing two numbers, one with noise (real pixel values) and the other without (PRF values). If the PRF valus is larger than the value of the real pixel
        % value in the denominator then the SNR is artificailly inflated. What we should do is zero the PRF value when they approcah the background noise values.
        % The real question is when do we "approach" the background values?
        
        %The median value of all background median pixel values
        medianBackgroundValue = median(thisCadenceBackgroundValues(thisCadenceBackgroundValues ~= 0.0));
        medianBackgroundUncertainties = median(thisCadenceBackgroundUncertainties(thisCadenceBackgroundUncertainties ~= 0.0));
        
        % The threshold is 2 sigma in background uncertainty above the background level
        backgroundNoiseThreshold = medianBackgroundValue + 2 * medianBackgroundUncertainties ;
        
        % Zero all PRF values below the background noise threshold
        numeratorPixelValues(numeratorPixelValues < backgroundNoiseThreshold) = 0.0;

        %**********************
        % Find aperture based on SNR test
        
        % Flux, and variance of first (center) pixel
        centerFlux = numeratorPixelValues(centerPixelIndex);
        % Component of variance due to shot noise.
        % Use the non background corrected flux so that the background shot noise in included
        centerVariance = denominatorPixelValues(centerPixelIndex);
        
        % Variance due to non-shot noise terms
        [readNoiseSquared, quantizationNoiseSquared] = find_non_shot_variance (paDataObject, coaParameterStruct, iCadence);
        
        nonShotVariance = readNoiseSquared + quantizationNoiseSquared;


        %**********************
        
        [thisCadencePixelAddingOrder] = find_pixel_adding_order (numeratorPixelValues, denominatorPixelValues, nonShotVariance, ...
                                    centerPixelIndex, centerFlux, centerVariance, nRows, nColumns, backgroundDominatedPixels);
        
        % Cumulative mean flux
        cumFluxContig=cumsum(numeratorPixelValues(thisCadencePixelAddingOrder));
        
        % Cumulative mean variance estimate: note read noise and quantization noise terms. 
        % TODO: Should add calibration noise terms (from black & smear)
        cumVarContig = cumsum(denominatorPixelValues(thisCadencePixelAddingOrder) + nonShotVariance);
        
        % Compute snr & locate peak in curve
        snrContig = cumFluxContig./sqrt(cumVarContig);
        
        snrFigure = figureHandles(1);
        [snrPeakIndex, peakType] = find_snr_peak_or_inflection (snrContig, []);

        % Just in case it picks more pixels then there are real pixels in pixelDataStruct
        snrPeakIndex = min(snrPeakIndex,nPixels);
        
        % Set aperture out to the maximum SNR point
        thisCadenceInOptimalAperture = false(length(numeratorPixelValues),1);
        thisCadenceInOptimalAperture(thisCadencePixelAddingOrder(1:snrPeakIndex)) = true;
        
        % Remove inserted missing pixels and convert back to pixelDataStruct pixel order
        [inOptimalAperture(iCadence,:), pixelAddingOrder(iCadence,:), backgroundDominatedPixels, prfTargetFlux, denominatorPixelValues] = ...
                            convert_to_pixelDataStruct_indexing ...
                                    (thisCadenceInOptimalAperture, missingPixelIndices, pixelDataStructPixelMapping, thisCadencePixelAddingOrder, ...
                                                    backgroundDominatedPixels, prfTargetFlux, denominatorPixelValues);

       %apertureFigure  = figureHandles(2);
       %apertureFigure2 = figureHandles(3);
       %apertureFigure3 = figureHandles(4);
       %plot_pixel_array (pixelDataStruct, prfTargetFlux, denominatorPixelValues, [centerColumn, centerRow], pixelAddingOrder, snrPeakIndex, ...
       %            backgroundDominatedPixels, apertureFigure, apertureFigure2, apertureFigure3, iCadence);
       %fluxFigure = figureHandles(5);
       %[tadCdppRms, paCdppRms] = ...
       %    plot_flux (pixelDataStruct, pixelAddingOrder(iCadence,:), snrPeakIndex, fluxFigure, iTarget, nTargets, cadenceTimes, paDataObject.gapFillConfigurationStruct);
       %pause;

    end % cadence loop

    %***
    % Find the averaged pixel adding order
    % Use the mode, which is liek the median but forces it to pick one of the values.
    pixelAddingOrderMedian = mode(pixelAddingOrder(cadencesToFind,:));

    % The found optimal aperture is the median aperture found at each cadence
    starFluxGaps = any(gaps,2);
    inOptimalApertureMedian = logical(nanmedian(inOptimalAperture((~starFluxGaps & cadencesToFind),:))');

    cadenceIndex = 0;
    for iCadence = 1 : nCadences

        if (~cadencesToFind(iCadence))
            continue;
        end

        cadenceIndex = cadenceIndex + 1;

        % Find flux fraction and crowding metric
        [fluxFraction(iCadence), crowdingMetric(iCadence), targetStarFlux(iCadence), inApertureFromTarget(iCadence), inApertureFromBackground(iCadence)] = ...
                    find_flux_fraction_and_crowding_metric (inOptimalApertureMedian, prfPixelDataStruct, targetStarStruct, ...
                                contributingStarStruct, iCadence, cadenceIndex);

    end

    % Plot target star flux from the PRF fit
    targetStarFlux(any(gaps,2) | paDataObject.cadenceTimes.gapIndicators | ~cadencesToFind) = nan;
    inApertureFromTarget(any(gaps,2) | paDataObject.cadenceTimes.gapIndicators | ~cadencesToFind) = nan;
    inApertureFromBackground(any(gaps,2) | paDataObject.cadenceTimes.gapIndicators | ~cadencesToFind) = nan;

    figure(figureHandles(2));
    subplot(3,1,1)
    plot(targetStarFlux, '-b')
    title('Target Star Flux from the PRF fit');
    subplot(3,1,2)
    plot(inApertureFromTarget, '-b')
    title('Target Star Flux in Aperture');
    subplot(3,1,3)
    plot(inApertureFromBackground, '-b')
    title('Background Star Flux in Aperture');
    

    % Check if the optimum aperture actually changed.

    apertureChanged =  any(any(inOptimalAperture(cadencesToFind,:)) & ~all(inOptimalAperture(cadencesToFind,:)));

end

%*************************************************************************************************************
% Finds the Flux fraction and crowding metric using the results of pa_coa_fit_aperture_model
%
%
%*************************************************************************************************************

function [fluxFraction, crowdingMetric, targetStarFlux, inApertureFromTarget, inApertureFromBackground] = find_flux_fraction_and_crowding_metric ...
        (inOptimalAperture, prfPixelDataStruct, targetStarStruct, contributingStarStruct, iQuarterCadence, cadenceIndexInContributingStarStruct )

    inApertureFromTarget = 0.0;   
    inApertureFromBackground = 0.0;
    for iPixel = 1 : length(prfPixelDataStruct)
        if (inOptimalAperture(iPixel))
            inApertureFromTarget     = inApertureFromTarget     + prfPixelDataStruct(iPixel).targetFluxEstimates(iQuarterCadence);
            inApertureFromBackground = inApertureFromBackground + prfPixelDataStruct(iPixel).bgStellarFluxEstimates(iQuarterCadence);
        end
    end
    
    targetStarFlux = targetStarStruct.totalFlux(cadenceIndexInContributingStarStruct);

    fluxFraction = inApertureFromTarget / targetStarFlux;

    crowdingMetric = inApertureFromTarget / (inApertureFromBackground + inApertureFromTarget);

end
%*************************************************************************************************************
% Takes the current found optimal aperture as the starting point then adjusts the aperture based on <pixeAddingOrdeer> while monitoring the CDPP computed by
% calculate_cdpp_wrapp. Stops when minimum CDPP is found.
%
%*************************************************************************************************************
function inOptimalAperture = cdpp_afterburner (inOptimalAperture, pixelAddingOrder, pixelDataStruct, gapFillConfigurationStruct, cadenceTimes, ...
                                                iTarget, figureHandle)

    % Number of pixels to sweep through n either side of the found aperture pixel length
    SweepLength = 50;

    % The uncertainty on CDPP RMS
    CDPPRMSERROR = 4;

    row     = [pixelDataStruct.ccdRow]';
    column  = [pixelDataStruct.ccdColumn]';
    values  = [pixelDataStruct.values]';
    gaps    = [pixelDataStruct.gapIndicators]';

    if (length(row) ~= length(column))
        error('Row and Column should be the same length');
    end
    
    % Summing flux so zero gaps
    values(gaps) = 0.0;

    % The initial number of pixels in paerture
    nPixelsInitial = sum(inOptimalAperture);

    % Sweep through all pixels lengths and calculate CDPP
    nTotPixels = length(pixelAddingOrder);
    cdpp = nan(nTotPixels,1);
    startNPixels = max(nPixelsInitial - SweepLength,1);
    endNPixels   = min(nPixelsInitial + SweepLength,nTotPixels);
    for nPixels = startNPixels : endNPixels 
    
        currentFlux= sum(values(pixelAddingOrder(1:nPixels),:),1)';

        currentGaps = any(gaps(pixelAddingOrder(1:nPixels),:),1);

        %***
        % Massage the data to be ready for CDPP
        currentFlux(currentGaps) = nan;

        % The mean flux values can be dramatically different since different number of pixels are added together. We need to normalize the mean flux values
        currentFlux   = mapNormalizeClass.normalize_value (currentFlux, nanmedian(currentFlux), [], [], [], 'median');
 
        % NaNs will "NaN" the medfilt1 values within <smoothNumCadences> cadences from each NaNed cadence, so we need to fill gaps
        % Further down we fill gaps better
        if (~isempty(currentFlux(~currentGaps)))
            currentFlux(currentGaps)   = interp1(cadenceTimes(~currentGaps), currentFlux(~currentGaps), cadenceTimes(currentGaps), 'pchip');
        end
 
        smoothNumCadences = 100;
        currentFluxDetrended  = currentFlux - medfilt1(currentFlux, smoothNumCadences);
 
        % Need
        % maxCorrelationWindowLimit           = maxCorrelationWindowXFactor * maxArOrderLimit;
        % To be larger than the largest gap
        gapFillConfigurationStruct.maxCorrelationWindowXFactor = 300 / gapFillConfigurationStruct.maxArOrderLimit;
 
        [currentFluxDetrended] = fill_short_gaps(currentFluxDetrended, currentGaps, [], false, gapFillConfigurationStruct, [], zeros(length(currentFluxDetrended),1));
 
        %***
        % Compute the current CDPP
        % Use default values for CDPP wrapper
        trialTransitPulseDurationInHours = [];
        tpsModuleParameters = [];
        cadencesPerHour = 1 / (median(diff(cadenceTimes))*24);
 
        if (~isnan(currentFluxDetrended))
            % Ignore the edge effects by only looking at the center portion
            fluxTimeSeries.values = currentFluxDetrended(smoothNumCadences:end-smoothNumCadences);
            cdppTemp = calculate_cdpp_wrapper (fluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters);
        else
            cdppTemp.values = 0.0;
            cdppTemp.rms = nan;
        end

        cdpp(nPixels) = cdppTemp.rms;

    end

    %***
    % Find the minimum CDPP
    [cdppMin, cdppMinLoc] = min(cdpp);

    % If the found CDPP minimum is within the uncertainty of the initial CDPP then keep the initial.
    if (cdppMin > cdpp(nPixelsInitial) - CDPPRMSERROR)
        cdppMinLoc = nPixelsInitial;
    end
    
    inOptimalAperture = false(nTotPixels,1);
    inOptimalAperture(pixelAddingOrder(1:cdppMinLoc)) = true;

    if (~isempty(figureHandle))
        figure(figureHandle);
        plot(cdpp,'*');
        hold on;
        plot(nPixelsInitial, cdpp(nPixelsInitial), 'or', 'MarkerSize', 10);
        plot(cdppMinLoc, cdpp(cdppMinLoc), 'oc', 'MarkerSize', 10);
        grid on;
        legend('CDPP', 'Initial Pixel Number', 'Final Pixel Number');
        title(['CDPP vs Pixel Number in Aperture for target ', num2str(iTarget)]);
        xlabel('Number of pixels in aperture');
        ylabel('Quasi-CDPP RMS');
        hold off
    end

end

