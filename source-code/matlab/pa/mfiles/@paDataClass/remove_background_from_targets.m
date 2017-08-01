function [paDataObject] = ...
remove_background_from_targets(paDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paDataObject] = ...
% remove_background_from_targets(paDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Remove the background from all target pixel time series in the current
% invocation. First interpolate the background polynomials to cover any
% cadences (long or short) for which they are not available. Then for each
% cadence, evaluate the background polynomials at the row/column
% coordinates of the target pixels. Subtract the estimated background
% value from the pixel value for each target.
%
% Update the pixel values and uncertainties in the PA data object. If the
% background coefficients require interpolation, save the results to the
% background matlab file so that the interpolation must only be done once.
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


% Get state file name.
paFileStruct = paDataObject.paFileStruct;
paStateFileName = paFileStruct.paStateFileName;

% Get fields from input object.
processingBackground = strcmpi(paDataObject.processingState, 'BACKGROUND');

cadenceType = paDataObject.cadenceType;
ccdModule = paDataObject.ccdModule;
ccdOutput = paDataObject.ccdOutput;

backgroundPolyStruct = paDataObject.backgroundPolyStruct;
targetStarDataStruct = paDataObject.targetStarDataStruct;

cadenceTimes = paDataObject.cadenceTimes;
cadenceNumbers = cadenceTimes.cadenceNumbers;
nCadences = length(cadenceNumbers);

paConfigurationStruct = paDataObject.paConfigurationStruct;
debugLevel = paConfigurationStruct.debugLevel;

spacecraftConfigMap = paDataObject.spacecraftConfigMap;

% Instantiate config map object.
configMapObject = configMapClass(spacecraftConfigMap);

% Set long and short cadence flags.
if strcmpi(cadenceType, 'long')
    processLongCadence = true;
elseif strcmpi(cadenceType, 'short')
    processLongCadence = false;
end

% Interpolate the background polynomials for long cadence (if necessary) or
% for short cadence target processing. Save the interpolated polynomials
% for use in later invocations. For a short cadence unit of work, the
% background polynomials and covariances must first be scaled to compensate
% for the differences in numbers of coadds between the short and long
% cadence data.

backgroundPolyGapIndicators = ~logical([backgroundPolyStruct.backgroundPolyStatus]');

if any(backgroundPolyGapIndicators) || length(backgroundPolyStruct) < nCadences
    
    if processingBackground && ~processLongCadence && ~all(backgroundPolyGapIndicators)
        % make the background poly compatible with short cadence data
        backgroundPolyStruct = scale_lc_background_poly_to_sc( backgroundPolyStruct, configMapObject );        
    end % if
    
    % interpolate to fill missing time stamps
    backgroundPolyStruct = interpolate_background_polynomials(backgroundPolyStruct, cadenceTimes, processLongCadence);
    
    paDataObject.backgroundPolyStruct = backgroundPolyStruct;
    save(paStateFileName, 'backgroundPolyStruct', '-append');
    
end % if

% Build arrays (nCadences x nPixels) with target pixel values, pixel
% uncertainties and gap indicators.
pixelDataStructArray = [targetStarDataStruct.pixelDataStruct];
pixelValues = [pixelDataStructArray.values];
pixelUncertainties = [pixelDataStructArray.uncertainties];
gapArray = [pixelDataStructArray.gapIndicators];

% Create vectors with the row/column coordinates for each of the target
% pixels.
ccdRows = [pixelDataStructArray.ccdRow]';
ccdColumns = [pixelDataStructArray.ccdColumn]';

% Plot the mean value for each target pixel regardless of the debug level.
close all;
isLandscapeOrientation = true;
includeTimeFlag = false;
printJpgFlag = false;

pixelValues(gapArray) = 0;
nValues = sum(~gapArray, 1)';
meanTarget = sum(pixelValues, 1)' ./ nValues;
isValid = nValues > 0;
plot3(ccdColumns(isValid), ccdRows(isValid), meanTarget(isValid), '.b');
title(['[PA] Mean Target Pixel Flux -- Module ', num2str(ccdModule), ' /  Output ', num2str(ccdOutput)]);
xlabel('CCD Column (1-based)');
ylabel('CCD Row (1-based)');
zlabel('Flux (e-)');
load(paStateFileName, 'nInvocations');
plot_to_file(['pa_mean_target_flux_', num2str(nInvocations-1)], isLandscapeOrientation, includeTimeFlag, ...
    printJpgFlag);

% Plot the target pixel and estimated background flux for each cadence if
% the debug level is greater than zero.
if debugLevel
    close all;
    for iCadence = 1 : nCadences
        targetValues = pixelValues(iCadence, : )';
        gapIndicators = gapArray(iCadence, : )';
        plot3(ccdColumns(~gapIndicators), ccdRows(~gapIndicators), targetValues(~gapIndicators), '.b');
        hold on
        [backgroundEstimates] = weighted_polyval2d(ccdRows, ccdColumns, ...
            backgroundPolyStruct(iCadence).backgroundPoly);
        plot3(ccdColumns(~gapIndicators), ccdRows(~gapIndicators), ...
            backgroundEstimates(~gapIndicators), '.r');
        hold off
        title(['[PA] Target and Estimated Background Flux -- Cadence ', num2str(cadenceNumbers(iCadence))]);
        xlabel('CCD Column (1-based)');
        ylabel('CCD Row (1-based)');
        zlabel('Flux (e-)');
        pause(1)
    end % for iCadence 
end % ifound flux for each cadence if
% the debug level is greater than zero.
if debugLevel
    close all;
    for iCadence = 1 : nCadences
        targetValues = pixelValues(iCadence, : )';
        gapIndicators = gapArray(iCadence, : )';
        plot3(ccdColumns(~gapIndicators), ccdRows(~gapIndicators), targetValues(~gapIndicators), '.b');
        hold on
        [backgroundEstimates] = weighted_polyval2d(ccdRows, ccdColumns, ...
            backgroundPolyStruct(iCadence).backgroundPoly);
        plot3(ccdColumns(~gapIndicators), ccdRows(~gapIndicators), ...
            backgroundEstimates(~gapIndicators), '.r');
        hold off
        title(['[PA] Target and Estimated Background Flux -- Cadence ', num2str(cadenceNumbers(iCadence))]);
        xlabel('CCD Column (1-based)');
        ylabel('CCD Row (1-based)');
        zlabel('Flux (e-)');
        pause(1)
    end % for iCadence 
end % if

% Remove the background. Note that gaps for output are identical to those
% for input.
[pixelValues, pixelUncertainties] = ...
    remove_background_from_pixels(pixelValues, pixelUncertainties, ...
    ccdRows, ccdColumns, [backgroundPolyStruct.backgroundPoly], gapArray);

% Redistribute the results target by target.
nTargets = length(targetStarDataStruct);
pixelIndex = 1;

for iTarget = 1 : nTargets
    
    targetDataStruct = targetStarDataStruct(iTarget);
    nPixels = length(targetDataStruct.pixelDataStruct);
    
    values = pixelValues( : , pixelIndex : pixelIndex + nPixels - 1);
    uncertainties = ...
        pixelUncertainties( : , pixelIndex : pixelIndex + nPixels - 1);
    
    valuesCellArray = num2cell(values, 1);
    [targetDataStruct.pixelDataStruct(1 : nPixels).values] = ...
            valuesCellArray{ : };
    
    uncertaintiesCellArray = num2cell(uncertainties, 1);
    [targetDataStruct.pixelDataStruct(1 : nPixels).uncertainties] = ...
            uncertaintiesCellArray{ : };
        
    targetStarDataStruct(iTarget) = targetDataStruct;
    pixelIndex = pixelIndex + nPixels;
      
end % for iTarget

paDataObject.targetStarDataStruct = targetStarDataStruct;

% Return.
return
