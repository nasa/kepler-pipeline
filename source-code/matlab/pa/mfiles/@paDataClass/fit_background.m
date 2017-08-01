function [paResultsStruct, backgroundPolyStruct] = ...
fit_background(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct, backgroundPolyStruct] = ...
% fit_background(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Fit two-dimensional background polynomial to background targets for each
% cadence. Uses robust_polyfit2d/weighted_polyfit2D. Note that background
% is fit as a function of row and column for the given module output where
% row and column are indexed from one in the conventional Matlab manner.
% Add metadata to create background polynomial super structure. Save the
% background polynomials to a matlab file and write the file name to the PA
% results structure. Generate (warning) alerts in the event that the
% background coefficients cannot be computed for any cadence.
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

% Set maximum cadence chunk size for background.
MAX_CHUNK_SIZE = 1;

% Get file names.
paFileStruct = paDataObject.paFileStruct;
paBackgroundFileName = paFileStruct.paBackgroundFileName;
paStateFileName = paFileStruct.paStateFileName;
paInputUncertaintiesFileName = paFileStruct.paInputUncertaintiesFileName;
calPouFileRoot = paFileStruct.calPouFileRoot;

% Get fields from input object.
ccdModule = paDataObject.ccdModule;
ccdOutput = paDataObject.ccdOutput;
startCadence = paDataObject.startCadence;
endCadence = paDataObject.endCadence;

paConfigurationStruct = paDataObject.paConfigurationStruct;
debugLevel = paConfigurationStruct.debugLevel;

pouConfigurationStruct = paDataObject.pouConfigurationStruct;
pouEnabled = pouConfigurationStruct.pouEnabled;
compressionEnabled = pouConfigurationStruct.compressionEnabled;
pixelChunkSize = pouConfigurationStruct.pixelChunkSize;
cadenceChunkSize = pouConfigurationStruct.cadenceChunkSize;
interpDecimation = pouConfigurationStruct.interpDecimation;
interpMethod = pouConfigurationStruct.interpMethod;

backgroundConfigurationStruct = paDataObject.backgroundConfigurationStruct;
aicOrderSelectionEnabled = backgroundConfigurationStruct.aicOrderSelectionEnabled;
fitMaxOrder = backgroundConfigurationStruct.fitMaxOrder;

cadenceTimes = paDataObject.cadenceTimes;
startTimestamps = cadenceTimes.startTimestamps;
midTimestamps = cadenceTimes.midTimestamps;
endTimestamps = cadenceTimes.endTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;
cadenceNumbers = cadenceTimes.cadenceNumbers;

% Instantiate config map object.
configMapObject = configMapClass(paDataObject.spacecraftConfigMap);

% Determine the background cadence chunk size.
cadenceChunkSize = min(cadenceChunkSize, MAX_CHUNK_SIZE);

% Create the POU struct.
pouStruct.inputUncertaintiesFileName = paInputUncertaintiesFileName;
pouStruct.cadenceNumbers = cadenceNumbers;
pouStruct.pouEnabled = pouEnabled;
pouStruct.pouDecimationEnabled = true;
pouStruct.pouCompressionEnabled = compressionEnabled;
pouStruct.pouPixelChunkSize = pixelChunkSize;
pouStruct.pouCadenceChunkSize = cadenceChunkSize;
pouStruct.pouInterpDecimation = interpDecimation;
pouStruct.pouInterpMethod = interpMethod;
pouStruct.calPouFileRoot = calPouFileRoot;
pouStruct.debugLevel = debugLevel;

% Build arrays (nCadences x nPixels) with background pixel values, pixel
% uncertainties and gap indicators.
backgroundPixels = [paDataObject.backgroundDataStruct.values];
backgroundUncertainties = [paDataObject.backgroundDataStruct.uncertainties];
gapArray = [paDataObject.backgroundDataStruct.gapIndicators];
gapArray(cadenceGapIndicators, : ) = true;

% Create vectors with the row/column coordinates for each of the background
% pixels.
ccdRows = [paDataObject.backgroundDataStruct.ccdRow]';
ccdColumns = [paDataObject.backgroundDataStruct.ccdColumn]';

% Issue warning if any background uncertainties are equal to zero. These
% background pixels will be ignored in the background polynomial fit.
if any(0 == backgroundUncertainties(~gapArray))
    [paResultsStruct.alerts] = ...
        add_alert(paResultsStruct.alerts, 'warning', ...
        'background pixels with uncertainties equal to 0 will be ignored in the background fit');
    disp(paResultsStruct.alerts(end).message);
end

% Use AIC to determine optimal motion polynomial orders if enabled. Let the
% data component be the mean of n * (ln(2*pi*X^2/n) + 1) over all cadences.
if aicOrderSelectionEnabled
    
    aic = zeros([fitMaxOrder + 1, 1]);

    for order = 0 : fitMaxOrder

        nParams = (order + 1) * (order + 2) / 2;
        
        backgroundConfigurationStruct.fitOrder = order;
        [backgroundStruct, backgroundGapIndicators, chiSquare, nPixels] = ...
            fit_background_by_cadence(backgroundPixels, ...
            backgroundUncertainties, ccdRows, ccdColumns, gapArray,...
            backgroundConfigurationStruct);

        backgroundGapIndicators = backgroundGapIndicators | ...
            nParams >= nPixels - 1;
        
        if all(backgroundGapIndicators)
            if 0 == order 
                error('PA:fitBackground:invalidFit', ...
                    'Unable to fit background for any cadence')
            else
                aic(order + 1) = aic(order);
                break;
            end
        end
        
        warning off all;
        aicForPixels = ...
            nPixels .* (log((2 * pi) * chiSquare ./ nPixels) + 1) + ...
            2 * nParams * (nParams + 1) ./ (nPixels - nParams - 1);
        aic(order + 1) = ...
            2 * nParams + mean(aicForPixels(~backgroundGapIndicators));
        warning on all;

        if order ~= 0 && aic(order + 1) > min(aic(1 : order))
            break;
        end % if

    end % for

    [minAic, iMinAic] = min(aic(1 : order + 1));
    backgroundConfigurationStruct.fitOrder = iMinAic - 1;

end % if aicOrderSelectionEnabled

% Do the background fit. Any gaps in the background coefficient struct
% array will be filled by interpolation when the long or short cadence
% targets are processed. Save diagnostic results to the state file.
[backgroundStruct, backgroundGapIndicators, backgroundChiSquare, nBackgroundPixels] = ...
    fit_background_by_cadence(backgroundPixels, backgroundUncertainties, ...
    ccdRows, ccdColumns, gapArray, backgroundConfigurationStruct, pouStruct);              %#ok<NASGU>

save(paStateFileName, 'backgroundChiSquare', 'nBackgroundPixels', ...
    '-append');

% Initialize background polynomial structure.
nCadences = length(startTimestamps);

backgroundPolyStruct = repmat(struct( ...
    'cadence', -1, ...
    'mjdStartTime', -1, ...
    'mjdMidTime', -1, ...
    'mjdEndTime', -1, ...
    'module', -1, ...
    'output', -1, ...
    'backgroundPoly', [], ...
    'backgroundPolyStatus', -1), [1, nCadences]);

% Create background polynomial structure with metadata.
cadence = startCadence;  

for iCadence = 1 : nCadences
    polyStruct.cadence = cadence;
    polyStruct.mjdStartTime = startTimestamps(iCadence);
    polyStruct.mjdMidTime = midTimestamps(iCadence);
    polyStruct.mjdEndTime = endTimestamps(iCadence);
    polyStruct.module = ccdModule;
    polyStruct.output = ccdOutput;
    polyStruct.backgroundPoly = backgroundStruct(iCadence);
    polyStruct.backgroundPolyStatus = ...
        double(~backgroundGapIndicators(iCadence));
    backgroundPolyStruct(iCadence) = polyStruct;
    cadence = cadence + 1;
end % for iCadence

% Check for cadence consistency.
if cadence - 1 ~= endCadence
    error('PA:fitBackground:cadenceInconsistency', ...
        'Start cadence = %d, End cadence = %d; Number of timestamps = %d', ...
        startCadence, endCadence, nCadences)
end

% Blobify the background polynomial structure and write to a matlab file.
% Copy the file name to the PA results structure. Also save the gap filled
% background polynomial structure to the matlab state file for use in
% subsequent invocations.
struct_to_blob(backgroundPolyStruct, paBackgroundFileName);
paResultsStruct.backgroundBlobFileName = paBackgroundFileName;
backgroundPolyStruct = fill_background_polynomial_struct_array( backgroundPolyStruct, configMapObject, cadenceTimes, 'LONG' );
save(paStateFileName, 'backgroundPolyStruct', '-append');

% Generate alert if the background polynomial could not be computed for any
% non-gapped cadence.
nGaps = sum(backgroundGapIndicators & ~cadenceGapIndicators);
if nGaps > 0
    [paResultsStruct.alerts] = ...
        add_alert(paResultsStruct.alerts, 'warning', ...
        ['background polynomial could not be obtained for ', num2str(nGaps), ' valid cadence(s)']);
    disp(paResultsStruct.alerts(end).message);
end % if

% Plot the AIC for background order selection if AIC order selection is
% enabled.
close all;
isLandscapeOrientation = true;
includeTimeFlag = false;
printJpgFlag = false;

if aicOrderSelectionEnabled
    plot((0 : order), aic(1 : order + 1), 'o-');
    grid
    title(['[PA] Background Fit AIC -- Module ', num2str(ccdModule), ...
        ' /  Output ', num2str(ccdOutput)]);
    xlabel('Order');
    ylabel('AIC');
    plot_to_file('pa_background_aic', isLandscapeOrientation, includeTimeFlag, ...
        printJpgFlag);
end % if

% Plot the mean background value for each background pixel regardless of
% the debug level.
backgroundPixels(gapArray) = 0;
nValues = sum(~gapArray, 1)';
warning off all
meanBackground = sum(backgroundPixels, 1)' ./ nValues;
warning on all
isValid = nValues > 0;
plot3(ccdColumns(isValid), ccdRows(isValid), meanBackground(isValid), '.b');
title(['[PA] Mean Background Flux -- Module ', num2str(ccdModule), ' /  Output ', num2str(ccdOutput)]);
xlabel('CCD Column (1-based)');
ylabel('CCD Row (1-based)');
zlabel('Flux (e-)');

% clip z-axis to 5 MAD
medianBackground = median(meanBackground(isValid));
madBackground = mad(meanBackground(isValid));
aa = axis;
axis([aa(1:4) medianBackground - 5 * madBackground, medianBackground + 5 * madBackground]);

plot_to_file('pa_mean_background_flux', isLandscapeOrientation, includeTimeFlag, ...
    printJpgFlag);

% Plot the background fits for each cadence if the debug level is greater
% than zero.
if debugLevel
    close all;
    for iCadence = 1 : nCadences
        backgroundValues = backgroundPixels(iCadence, : )';
        gapIndicators = gapArray(iCadence, : )';
        if ~all(gapIndicators)
            plot3(ccdColumns(~gapIndicators), ccdRows(~gapIndicators), ...
                backgroundValues(~gapIndicators), '.b');
            hold on
            [backgroundEstimates] = weighted_polyval2d(ccdRows, ccdColumns, ...
                backgroundStruct(iCadence));
            plot3(ccdColumns(~gapIndicators), ccdRows(~gapIndicators), ...
                backgroundEstimates(~gapIndicators), '.r');
            hold off
            title(['[PA] Background Fit -- Cadence ', num2str(cadenceNumbers(iCadence)), ...
                ' / Order ', num2str(backgroundStruct(iCadence).order)]);
            xlabel('CCD Column (1-based)');
            ylabel('CCD Row (1-based)');
            zlabel('Flux (e-)');
            
            % clip z-axis to 5 MAD
            medianBackground = median(backgroundValues);
            madBackground = mad(backgroundValues);
            aa = axis;
            axis([aa(1:4) medianBackground - 5 * madBackground, medianBackground + 5 * madBackground]);
            
            pause(1);
        end % if
    end % for iCadence 
end % if

% Return.
return
