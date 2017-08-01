function [paDataObject, paResultsStruct] = perform_simple_aperture_photometry(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct] = ...
% perform_simple_aperture_photometry(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Perform simple aperture photometry (SAP) on a target by target basis. For
% each cadence, combine the fitted background in the optimal aperture to
% produce the backgroundFluxTimeseries. Combine the values for the target
% pixels in the optimal aperture and subtract the background flux to
% produce the targetFluxTimeseries. Set a gap in these flux time series at
% any cadence for which a pixel is missing in the optimal aperture for a
% given target. 
% After the target and background flux are determined, the fitted
% background is removed from all target pixels in the aperture and these
% background corrected target pixels replace the original pixel values in
% the paDataObject. Standard propagation of uncertainties is applied.
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


% Get fields from input object.
targetStarDataStruct = paDataObject.targetStarDataStruct;
targetStarResultsStruct = paResultsStruct.targetStarResultsStruct;
backgroundPolyStruct = paDataObject.backgroundPolyStruct;

cadenceTimes = paDataObject.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;

paConfigurationStruct = paDataObject.paConfigurationStruct;
simulatedTransitsEnabled = paConfigurationStruct.simulatedTransitsEnabled;
removeMedianSimulatedFlux = paConfigurationStruct.simulatedTransitsEnabled;
debugLevel = paConfigurationStruct.debugLevel;

pouConfigurationStruct = paDataObject.pouConfigurationStruct;
pouEnabled = pouConfigurationStruct.pouEnabled;
interpDecimation = pouConfigurationStruct.interpDecimation;

nTargets = length(targetStarDataStruct);
cadenceNumbers = cadenceTimes.cadenceNumbers;
nCadences = length(cadenceNumbers);

% If RA/Dec fitting is enabled and we are in the TARGETS processing state,
% append results to the state file. 
paStateFileName = paDataObject.paFileStruct.paStateFileName;
fittingRaDecMag = paDataObject.paConfigurationStruct.paCoaEnabled ...
    && paDataObject.apertureModelConfigurationStruct.raDecFittingEnabled ...
    && strcmp(paDataObject.processingState, 'TARGETS');

% build decimated cadence list
if pouEnabled                
    decimatedCadenceList = downsample(cadenceNumbers, interpDecimation);
    decimatedCadenceLogical = ismember(cadenceNumbers, decimatedCadenceList);
end

% Create the diagnostic figures for PA-COA
% Create the data strucutre for storing the aperture selection information
% Also load EPICS for K2 data
if (paDataObject.paConfigurationStruct.paCoaEnabled)
    paCoaFigureHandles(1) = figure;
    paCoaFigureHandles(2) = figure;
    if (paCoaClass.doPlotPrfModelFitting)
        paCoaFigureHandles(3) = figure;
    end
    % Structure for stoing the aperture selection information
    paCoaDiagnosticStruct = repmat(struct('tadCdpp', [], 'paSnrCdpp', [], 'paCdppCdpp', [], 'paUnionCdpp', [], 'selectedAperture', [], ...
                                    'mnrChosenRevertToTad', [], 'revertToTadAperture', [], 'inOptimalAperture', [], ...
                                    'tadFlux', [], 'paSnrFlux', [], 'paCdppFlux', [], 'paUnionFlux', []), [nTargets,1]);
    save paCoaDiagnosticStruct paCoaDiagnosticStruct;
    clear paCoaDiagnosticStruct;

    % For K2 data
    % Use sandbox tools to retrieve all targets up to 18th magnitude. Save
    % the database to a file so that paCoaClass can open this file for each
    % target. This is innefficient but it is for testing only.
    isK2Data = paDataObject.cadenceTimes.midTimestamps(find(~paDataObject.cadenceTimes.gapIndicators,1))  > ...
                                paDataObject.fcConstants.KEPLER_END_OF_MISSION_MJD;
    if (~isdeployed && isK2Data && paCoaClass.doLoadCatalogFile && ~exist(paCoaClass.k2CatalogFilename,  'file'))
        % This is risky but assume first cadence time is valid
        catalog = retrieve_kics_matlabstyle (paDataObject.ccdModule, paDataObject.ccdOutput, paDataObject.cadenceTimes.midTimestamps(1), 1, 18);
        save(paCoaClass.k2CatalogFilename, 'catalog');
        clear catalog;
    end
end

% Loop through the targets.
for iTarget = 1 : nTargets
    
    % Get data and results structures for given target.
    targetDataStruct = targetStarDataStruct(iTarget);    
    targetResultsStruct = targetStarResultsStruct(iTarget);
        
    % Get pixel values, uncertainties, gaps, rows and columns in the
    % optimal aperture.
    pixelDataStruct = targetDataStruct.pixelDataStruct;
    pixelValues = [pixelDataStruct.values];
    pixelUncertainties = [pixelDataStruct.uncertainties];
    gapArray = [pixelDataStruct.gapIndicators];
    rows = [pixelDataStruct.ccdRow];
    cols = [pixelDataStruct.ccdColumn];    
    
    % Calculate background subtracted pixels and uncertainties over full
    % aperture and update targetDataStruct. This operation must be done
    % cadence by cadence since multiple cadence use cases are not supported
    % by weighted_polyval2d. Uncertainties are propagated assuming both
    % target pixel values and fitted background values are independent. 
    backgroundPixelValues = zeros(size(pixelValues));
    backgroundPixelUncertainties = zeros(size(pixelUncertainties));
    
    % evaluate the b/g poly and get b/g pixel values and uncertainties for
    % all cadences
    for iCadence = 1:nCadences
        backgroundPoly = backgroundPolyStruct(iCadence).backgroundPoly;
        [bgVal, bgUnc] = weighted_polyval2d(rows, cols, backgroundPoly);
        backgroundPixelValues(iCadence,:) = rowvec(bgVal);
        backgroundPixelUncertainties(iCadence,:) = rowvec(bgUnc);
    end

    % form background corrected pixels w/uncertainties and save to
    % paDataObject
    newPixelValues = pixelValues - backgroundPixelValues;
    newPixelUncertainties = sqrt(pixelUncertainties.^2 + backgroundPixelUncertainties.^2);    
        
    % With pouEnabled we correct the pixel uncertainties to be a delta from
    % the original pixel uncertainties where the delta is developed from
    % the background subtracted pixels on the pou decimated cadences (since
    % this is where full pou has been employed in the background fit). This
    % is the best approximation we can do to employ "minimal pou + delta"
    % since the background polys have been fit using the full pixel
    % covariance on the decimated cadences but using an interpolated
    % covariance on all other cadences.
    if pouEnabled        
        origUncertainties = pixelUncertainties;
        origUncertainties(gapArray) = nan;
        newUncertainties = newPixelUncertainties;
        newUncertainties(gapArray) = nan;        
                
        delta = nanmedian(newUncertainties(decimatedCadenceLogical,:) - origUncertainties(decimatedCadenceLogical,:) );
        delta = repmat(delta,size(pixelUncertainties,1),1);
        delta(isnan(delta)) = 0;        
        newPixelUncertainties = origUncertainties + delta;
    end
        
    % deal back into pixelDataStruct    
    valuesCellArray = num2cell(newPixelValues,1);
    [pixelDataStruct.values] = deal(valuesCellArray{:});
    uncertaintiesCellArray = num2cell(newPixelUncertainties,1);
    [pixelDataStruct.uncertainties] = deal(uncertaintiesCellArray{:});
        
    if (paDataObject.paConfigurationStruct.paCoaEnabled)
        if (iTarget == 1)
            display('Finding Optimal Apertures with PA-COA...');
        end
        % PA-COA refinds the optimal aperture based on a PRF model fit to
        % the pixel data. PA-COA needs the raw pixel data, the background
        % data and the background removed pixel data. So, here paDataObject
        % still has the background included.
        backgroundRemovedPixelDataStruct = pixelDataStruct;
        paCoaResultsStruct = paCoaClass.find_optimal_aperture(paDataObject, backgroundRemovedPixelDataStruct, backgroundPixelValues, ...
                                    backgroundPixelUncertainties, iTarget, paCoaFigureHandles);
        % paCoaClass internally chooses to use the PA-COA or TAD-COA
        % aperture
        inOptimalAperture = paCoaResultsStruct.inOptimalAperture;
        % Place inOptimalAperture in pixelDataStruct just in case it's used
        % and someone is not paying attention
        for iPixel = 1 : length(pixelDataStruct)
            pixelDataStruct(iPixel).inOptimalAperture = inOptimalAperture(iPixel);
        end
        % Update targetResultsStruct with new outputs
        targetResultsStruct = paCoaClass.update_targetStarResultsStruct(paCoaResultsStruct, targetResultsStruct, paDataObject);
        
        % Accrue fitted RA, Dec, and mag values.
        if fittingRaDecMag
            if (iTarget == 1)
                raDecMagFitResults =[];
            end
                        
            raDecMagFitResults = accrue_ra_dec_fitting_results( ...
                raDecMagFitResults, paCoaResultsStruct, ...
                targetDataStruct.keplerId);
        end
    else
        % Use the TAD optimal aperture
        if (iTarget == 1)
            display('Using Optimal Apertures from TAD-COA...');
        end
        inOptimalAperture = [pixelDataStruct.inOptimalAperture]';   
        % KSOC-4731: We need to still populate the optimalAperture struct
        % since the pipeline now stores the optimalAperture values output
        % values from PA, even if PA-COA does not update the aperture.
        targetResultsStruct = paCoaClass.set_optimalAperture_with_TAD_values(targetResultsStruct, paDataObject, iTarget);
    end
    
    % update pixels in targetDataStruct
    targetDataStruct.pixelDataStruct = pixelDataStruct;
    
    if any(inOptimalAperture)
        
        pixelValues = pixelValues( : , inOptimalAperture);
        pixelUncertainties = pixelUncertainties( : , inOptimalAperture);
        gapArray = gapArray( : , inOptimalAperture);
        rows = rows(inOptimalAperture);
        cols = cols(inOptimalAperture);
        
        % Set a gap in the flux time series if any pixel in the optimal
        % aperture for the given target is missing. Set all gapped values
        % and uncertainties to 0.
        gapIndicators = any(gapArray, 2);
        pixelValues(gapIndicators, : ) = 0;
        pixelUncertainties(gapIndicators, : ) = 0;

        % Initialize background flux time series. Use same gaps as flux time
        % series
        backgroundFluxTimeSeries.values = zeros(nCadences,1);
        backgroundFluxTimeSeries.uncertainties = zeros(nCadences,1);
        backgroundFluxTimeSeries.gapIndicators = gapIndicators;
        
        % Perform SAP on fitted background values. Include standard
        % propagation of errors. This operation must be done cadence by
        % cadence since multiple cadence use cases are not supported by
        % weighted_polyval2d. Note: Since fill_background_polynomial_struct
        % has been run prior to this point there is a background polynomial
        % avaliable for all cadences. 
        
        minimalBackgroundUnc = nan(size(backgroundFluxTimeSeries.uncertainties));
        
        for iCadence = 1:nCadences
            if ~gapIndicators(iCadence)
                backgroundPoly = backgroundPolyStruct(iCadence).backgroundPoly;
                Cv = backgroundPoly.covariance;
                [backgroundValues, backgroundUnc, Aback] = weighted_polyval2d(rows, cols, backgroundPoly);                
                backgroundFluxTimeSeries.values(iCadence) = sum(backgroundValues);
                
                % b/g flux uncertainty w/ propagated fit covariance
                backgroundFluxTimeSeries.uncertainties(iCadence) = sqrt(sum(sum(Aback * Cv * Aback')));
                
                % so called 'minimal' b/g flux uncertainty from polynomial
                % evaluation - does not include fit covariance
                minimalBackgroundUnc(iCadence) = sqrt(sum(backgroundUnc.^2));
            end
        end
        
        % develop delta between full and minimal pou on decimated cadences
        % and update backgroud flux uncertainties
        if pouEnabled
            delta = nanmedian(backgroundFluxTimeSeries.uncertainties(decimatedCadenceLogical) - ...
                minimalBackgroundUnc(decimatedCadenceLogical) );
            if isnan(delta)
                delta = 0;
            end
            % make b/g flux uncertaianties minimal pou + delta
            backgroundFluxTimeSeries.uncertainties = minimalBackgroundUnc + delta;
        end

        % Perform SAP on target pixels. Include basic propagation of
        % uncertainties assuming for now that all pixels are uncorrelated
        % for any given cadence. Remove background flux from target flux.
        fluxTimeSeries.values = sum(pixelValues, 2) - backgroundFluxTimeSeries.values;
        fluxTimeSeries.uncertainties = sqrt( sum(pixelUncertainties .^ 2, 2) + backgroundFluxTimeSeries.uncertainties.^2 );
        fluxTimeSeries.gapIndicators = gapIndicators;
        
        % remove the median of any flux added from simulating transits -
        % See KSOC-3215
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
        pixelValues = [targetDataStruct.pixelDataStruct.values];
        gapArray = [targetDataStruct.pixelDataStruct.gapIndicators];
        ccdRows = [targetDataStruct.pixelDataStruct.ccdRow]';
        ccdColumns = [targetDataStruct.pixelDataStruct.ccdColumn]';
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
            num2str(targetDataStruct.keplerId)]);
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
            num2str(targetDataStruct.keplerId)]);
        xlabel('CCD Column (1-based)');
        ylabel('CCD Row (1-based)');
        pause(1)
        
        gapIndicators = fluxTimeSeries.gapIndicators;
        startTime = fix(timestamps(find(~cadenceGapIndicators, 1)));
        plot(timestamps(~gapIndicators) - startTime, ...
            fluxTimeSeries.values(~gapIndicators), '.-b');
        title(['[PA] Target Flux -- Kepler Id ', ...
            num2str(targetDataStruct.keplerId)]);
        xlabel(['Elapsed Days from ', mjd_to_utc(startTime, 0)]);
        ylabel('Flux (e-)');
        pause(1);
    end %if
    
    % update paDataObject for this target
    paDataObject.targetStarDataStruct(iTarget) = targetDataStruct;

end % for iTarget

% Close the diagnostic figures for PA-COA
if (paDataObject.paConfigurationStruct.paCoaEnabled)
    close(paCoaFigureHandles(1));
    close(paCoaFigureHandles(2));
    if (paCoaClass.doPlotPrfModelFitting)
        close(paCoaFigureHandles(3));
    end
end

% Copy the target star results structure to the PA results structure.
paResultsStruct.targetStarResultsStruct = targetStarResultsStruct;


% If both PA-COA and RA/Dec fitting are enabled and we are in the
% TARGETS processing state, append results to the state file. 
if fittingRaDecMag
    save(paStateFileName, 'raDecMagFitResults', '-append');
end


end %  perform_simple_aperture_photometry()


%**************************************************************************
function raDecMagFitResults = accrue_ra_dec_fitting_results( ...
    raDecMagFitResults, paCoaResultsStruct, targetId)
    fieldsToRetain = {...
        'keplerId',          'keplerMag',        'raDegrees',           ...
        'decDegrees',        'catalogMag',       'catalogRaDegrees',    ...
        'catalogDecDegrees', 'lockRaDec',        'estimatedPeakSnr',    ...
        'isInsideAperture',  'minDistToValidPixel'};
    
    % If PA-COA did not actually run, for example custom or saturated
    % targets then apertureModelObjectForRaDecFit is empty
    if (~isempty(paCoaResultsStruct.apertureModelObjectForRaDecFit))
        starStructArray = ...
            paCoaResultsStruct.apertureModelObjectForRaDecFit.contributingStars;
    else
        starStructArray = [];
    end
    
    if ~isempty(starStructArray) && any(isfield(starStructArray, fieldsToRetain))
        
        % At this point we know starStructArray has at least one field to 
        % be retained.
        fieldsToRemove  = setdiff(fieldnames(starStructArray), fieldsToRetain);
        starStructArray = rmfield(starStructArray, fieldsToRemove);
        
        % Add a field for the target ID to the structure.
        [starStructArray.targetId] = deal(targetId);
        
        % Append to the results struct array.
        raDecMagFitResults = [raDecMagFitResults, starStructArray];
    end
            
end

%********************************** EOF ***********************************
