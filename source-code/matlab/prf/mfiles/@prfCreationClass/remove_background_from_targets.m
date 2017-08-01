function [prfCreationObject] = ...
remove_background_from_targets(prfCreationObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [prfCreationObject] = ...
% remove_background_from_targets(prfCreationObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Remove the background from all target pixel time series in the current
% invocation. First interpolate the background polynomials to cover any
% cadences (long) for which they are not available. Then for each cadence,
% evaluate the background polynomials at the row/column coordinates of the
% target pixels. Subtract the estimated background value from the pixel
% value for each target. Update the pixel values and uncertainties in the
% PRF creation object.
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

% Set the input uncertainties file name.
prfInputUncertaintiesFileName = 'prf_input_uncertainties.mat';
POU_DEBUG_LEVEL = 0;

% Get fields from input object.
backgroundPolyStruct = prfCreationObject.backgroundPolyStruct;
targetStarsStruct = prfCreationObject.targetStarsStruct;

cadenceTimes = prfCreationObject.cadenceTimes;
cadenceNumbers = cadenceTimes.cadenceNumbers;

pouConfigurationStruct = prfCreationObject.pouConfigurationStruct;
pouEnabled = pouConfigurationStruct.pouEnabled;
compressionEnabled = pouConfigurationStruct.compressionEnabled;
pixelChunkSize = pouConfigurationStruct.pixelChunkSize;
cadenceChunkSize = pouConfigurationStruct.cadenceChunkSize;
interpDecimation = pouConfigurationStruct.interpDecimation;
interpMethod = pouConfigurationStruct.interpMethod;

% Create the POU struct.
pouStruct.inputUncertaintiesFileName = prfInputUncertaintiesFileName;
pouStruct.cadenceNumbers = cadenceNumbers;
pouStruct.pouEnabled = pouEnabled;
pouStruct.pouDecimationEnabled = true;
pouStruct.pouCompressionEnabled = compressionEnabled;
pouStruct.pouPixelChunkSize = pixelChunkSize;
pouStruct.pouCadenceChunkSize = cadenceChunkSize;
pouStruct.pouInterpDecimation = interpDecimation;
pouStruct.pouInterpMethod = interpMethod;
pouStruct.debugLevel = POU_DEBUG_LEVEL;

% Interpolate the background polynomial coefficients if they are not
% available for any long cadence. Interpolating the coefficients is
% mathematically equivalent to evaluating the polynomials at target
% coordinates and then interpolating the estimated background. It is
% far more computationally efficient to interpolate the (relatively few)
% coefficients just once than it is to interpolate the estimated
% background for all target pixels for the missing cadence. The
% covariance matrices must be "interpolated" as well, but the
% interpolation is not a simple linear one. Save the complete
% background structure to a matlab file for later use.
backgroundPolyGapIndicators = ...
    ~logical([backgroundPolyStruct.backgroundPolyStatus]');

if any(backgroundPolyGapIndicators)
    [backgroundPolyStruct] = ...
        interpolate_background_polynomials(backgroundPolyStruct, ...
        cadenceTimes);
    prfCreationObject.backgroundPolyStruct = backgroundPolyStruct;
end

% Build arrays (nCadences x nPixels) with target pixel values, pixel
% uncertainties and gap indicators. Building the gap array is complicated
% by the use of gap indices rather than gap indicators.
pixelDataStructArray = [targetStarsStruct.pixelTimeSeriesStruct];
pixelValues = [pixelDataStructArray.values];
pixelUncertainties = [pixelDataStructArray.uncertainties];

gapIndicesCellArray = {pixelDataStructArray.gapIndices};
gapArray = false(size(pixelValues));
for iPixel = 1 : length(gapIndicesCellArray)
    gapArray(gapIndicesCellArray{iPixel}, iPixel) = true;
end

% Create vectors with the row/column coordinates for each of the target
% pixels.
ccdRows = [pixelDataStructArray.row]';
ccdColumns = [pixelDataStructArray.column]';

% Remove the background. Note that gaps for output are identical to those
% for input.
[pixelValues, pixelUncertainties] = ...
    remove_background_from_pixels(pixelValues, pixelUncertainties, ...
    ccdRows, ccdColumns, [backgroundPolyStruct.backgroundPoly], gapArray, ...
    pouStruct);

% Redistribute the results target by target.
nTargets = length(targetStarsStruct);
pixelIndex = 1;

for iTarget = 1 : nTargets
    
    targetDataStruct = targetStarsStruct(iTarget);
    nPixels = length(targetDataStruct.pixelTimeSeriesStruct);
    
    values = pixelValues( : , pixelIndex : pixelIndex + nPixels - 1);
    uncertainties = ...
        pixelUncertainties( : , pixelIndex : pixelIndex + nPixels - 1);
    
    valuesCellArray = num2cell(values, 1);
    [targetDataStruct.pixelTimeSeriesStruct(1 : nPixels).values] = ...
            valuesCellArray{ : };
    
    uncertaintiesCellArray = num2cell(uncertainties, 1);
    [targetDataStruct.pixelTimeSeriesStruct(1 : nPixels).uncertainties] = ...
            uncertaintiesCellArray{ : };
        
    targetStarsStruct(iTarget) = targetDataStruct;
    pixelIndex = pixelIndex + nPixels;
      
end % for iTarget

prfCreationObject.targetStarsStruct = targetStarsStruct;

% Return.
return
