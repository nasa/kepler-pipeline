function coaResultStruct = coa_matlab_controller(coaParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function coaResultStruct = coa_matlab_controller(coaParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% master control function for computing optimal pixels for each target
% the input coaParameterStruct is described in coaClass.m, with the
% exception of the following fields:
% 
% on completion coaResultStruct contains the following fields:
%   .completeOutputImage() 2D array containing the output image of the
%       current module output
%   .optimalApertures 1 x # of targets array that contains the following
%       fields:
%       .keplerId the KIC ID of this target object
%       .signalToNoiseRatio the signal-to-noise aperture for the optimal aperture for this
%           target
%       .crowdingMetric the ratio of flux from the target to the total
%           flux in the optimal aperture
%       .fluxFractionInAperture fraction of target flux in optimal aperture
%       .distanceFromEdge min distance of optimal aperture from any edge of
%			visible pixels
%       .badPixelCount the number of bad pixels that appear in this
%           target's optimal aperture
%       .referenceRow, .referenceColumn reference row and column of this
%           target's optimal aperture, from which the pixel offsets are
%           referenced
%       .offsets() 1D array of offsets desscribing the location of each
%       pixel in the optimal aperture relative to referenceRow and
%       referenceColumn, containing the following fields:
%           .row, .column row and column of each offset
%   .minRow, .maxRow, .minCol, .maxCol bounding box of aberrated targets
%       on the CCD module output
%
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

debugFlag = coaParameterStruct.debugFlag;
durationList = [];

% no inputs require a 0-base to 1-base conversion

% convert the prfBlob to a prfStruct
coaParameterStruct.prfStruct = blob_to_struct(coaParameterStruct.prfBlob);
coaParameterStruct = rmfield(coaParameterStruct, 'prfBlob');

% raDec2PixModel = retrieve_ra_dec_2_pix_model();
% coaParameterStruct.raDec2PixObject = raDec2PixClass(raDec2PixModel);
coaParameterStruct.raDec2PixObject = raDec2PixClass(coaParameterStruct.raDec2PixModel, 'one-based');

% convert the motion polynomial blob series to a motion polynomial struct
% array; the blob series may be empty
coaParameterStruct.motionPolyStruct = ...
    poly_blob_series_to_struct(coaParameterStruct.motionBlobs);
coaParameterStruct = rmfield(coaParameterStruct, 'motionBlobs');

% convert the background polynomial blob series to a background polynomial
% struct array; the blob series may be empty
coaParameterStruct.backgroundPolyStruct = ...
    poly_blob_series_to_struct(coaParameterStruct.backgroundBlobs);
coaParameterStruct = rmfield(coaParameterStruct, 'backgroundBlobs');

if debugFlag
    save_input_data(coaParameterStruct);
end

fcConstants = coaParameterStruct.fcConstants;
 
coaParameterStruct.moduleDescriptionStruct.nRowPix = fcConstants.nRowsImaging;
coaParameterStruct.moduleDescriptionStruct.nColPix = fcConstants.nColsImaging;
coaParameterStruct.moduleDescriptionStruct.leadingBlack = fcConstants.nLeadingBlack;
coaParameterStruct.moduleDescriptionStruct.trailingBlack = fcConstants.nTrailingBlack;
coaParameterStruct.moduleDescriptionStruct.virtualSmear = fcConstants.nVirtualSmear;
coaParameterStruct.moduleDescriptionStruct.maskedSmear = fcConstants.nMaskedSmear;

module = coaParameterStruct.module;
output = coaParameterStruct.output;

runStartMjd = datestr2mjd(coaParameterStruct.startTime);
runEndMjd = runStartMjd + coaParameterStruct.duration;
% make a gain object
gainObject = gainClass(coaParameterStruct.gainModel);
% gain is electrons per ADU
gain = get_gain(gainObject, runStartMjd, coaParameterStruct.module, coaParameterStruct.output);

% make a read noise object
noiseObject = readNoiseClass(coaParameterStruct.readNoiseModel);
% read noise is in ADU, convert to electrons
readNoisePerExposure = gain*get_read_noise(noiseObject, runStartMjd, ...
    coaParameterStruct.module, coaParameterStruct.output);

% make linearity object
linearityObject = linearityClass(coaParameterStruct.linearityModel);
polyStruct = get_weighted_polyval_struct(linearityObject, runStartMjd, module, output);
maxDnPerExposure = double(get_max_domain(linearityObject, runStartMjd, module, output));
wellCapacity = maxDnPerExposure .* gain ...
    .* weighted_polyval(maxDnPerExposure, polyStruct);

spacecraftConfigurationStruct = coaParameterStruct.spacecraftConfigurationStruct;

% set default start of K2 operation date
if ~isfield(coaParameterStruct, 'k2StartMjd')
    coaParameterStruct.k2StartMjd = datestr2mjd('1 Aug 2013');
end
% make the saturation model
% don't use the saturation model for K2 operations
if isempty(coaParameterStruct.saturationModel) || runStartMjd > coaParameterStruct.k2StartMjd
    coaParameterStruct.saturationObject = [];
else
    coaParameterStruct.saturationObject = saturationClass(coaParameterStruct.saturationModel);
end

% build the pixelModelStruct
coaParameterStruct.pixelModelStruct.saturationSpillUpFraction ...
    = fcConstants.SATURATION_SPILL_UP_FRACTION;
coaParameterStruct.pixelModelStruct.flux12 ...
    = fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;
coaParameterStruct.pixelModelStruct.parallelCTE ...
    = fcConstants.PARALLEL_CTE;
coaParameterStruct.pixelModelStruct.serialCTE ...
    = fcConstants.SERIAL_CTE;

% set the derived fields in coaParameterStruct.pixelModelStruct
% set the integration times (in seconds)
coaParameterStruct.pixelModelStruct.transferTime = ...
    spacecraftConfigurationStruct.millisecondsPerReadout/1000;
fgsPerIntegration = spacecraftConfigurationStruct.fgsFramesPerIntegration;
sPerFgsFrame = spacecraftConfigurationStruct.millisecondsPerFgsFrame/1000;
coaParameterStruct.pixelModelStruct.integrationTime = fgsPerIntegration*sPerFgsFrame;

% set the number of integrations in a long cadence
integrationsPerShort = spacecraftConfigurationStruct.integrationsPerShortCadence;
shortsPerLong = spacecraftConfigurationStruct.shortCadencesPerLongCadence;
coaParameterStruct.pixelModelStruct.exposuresPerCadence = integrationsPerShort*shortsPerLong;
coaParameterStruct.pixelModelStruct.cadenceTime = ...
    coaParameterStruct.pixelModelStruct.exposuresPerCadence ...
    * (coaParameterStruct.pixelModelStruct.integrationTime ...
    + coaParameterStruct.pixelModelStruct.transferTime);

% get the well capacity
coaParameterStruct.pixelModelStruct.wellCapacity = wellCapacity;

% get the flat field image
flatObject = flatFieldClass(coaParameterStruct.flatFieldModel);
coaParameterStruct.flatFieldImage = get_flat_field(flatObject, runStartMjd);

% set the noise values
coaParameterStruct.pixelModelStruct.readNoiseSquared = ...
    readNoisePerExposure^2 * coaParameterStruct.pixelModelStruct.exposuresPerCadence;
BITS_IN_ADC = fcConstants.BITS_IN_ADC;
coaParameterStruct.pixelModelStruct.quantizationNoiseSquared = ...
    ( wellCapacity / (2^BITS_IN_ADC-1))^2 / 12 ...
    * coaParameterStruct.pixelModelStruct.exposuresPerCadence;

coaParameterStruct = rmfield(coaParameterStruct, 'spacecraftConfigurationStruct');
coaParameterStruct = rmfield(coaParameterStruct, 'raDec2PixModel');
coaParameterStruct = rmfield(coaParameterStruct, 'readNoiseModel');
coaParameterStruct = rmfield(coaParameterStruct, 'gainModel');
coaParameterStruct = rmfield(coaParameterStruct, 'twoDBlackModel');
coaParameterStruct = rmfield(coaParameterStruct, 'linearityModel');
coaParameterStruct = rmfield(coaParameterStruct, 'undershootModel');
coaParameterStruct = rmfield(coaParameterStruct, 'flatFieldModel');
coaParameterStruct = rmfield(coaParameterStruct, 'saturationModel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% create coaClass
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
coaObject = coaClass(coaParameterStruct);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'coaClass';

if (debugFlag) 
    display(['coaClass duration: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute DVA motion
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(get(coaObject, 'dvaCoeffStruct'))
    tic;
    coaObject = compute_dva_motion(coaObject);
    duration = toc;

    durationElement = length(durationList);
    durationList(durationElement + 1).time = duration;
    durationList(durationElement + 1).label = 'compute_dva_motion';

    if (debugFlag) 
        display(['compute_dva_motion duration: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create output image
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(get(coaObject, 'outputImage'))
    tic;
    coaObject = create_output_image(coaObject);
    duration = toc;

    durationElement = length(durationList);
    durationList(durationElement + 1).time = duration;
    durationList(durationElement + 1).label = 'create_output_image';

    if (debugFlag)
        display(['create_output_image duration: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);
    end
end
if (debugFlag)
    draw(coaObject, 'outputImage');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract Optimal Pixels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(get(coaObject, 'outputImage'))
    tic;
    coaObject = extract_optimal_aperture(coaObject);
    duration = toc;

    durationElement = length(durationList);
    durationList(durationElement + 1).time = duration;
    durationList(durationElement + 1).label = 'extract_optimal_aperture';

    if (debugFlag)
        display(['extract_optimal_aperture duration: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);
    end
end

% fill the output structure
coaResultStruct = set_result_struct(coaObject);
coaResultStruct.durationList = durationList;

% convert the required outputs to 0-base
coaResultStruct = convert_coa_outputs_to_0_base(coaResultStruct);

if debugFlag
    save_output_data(coaResultStruct, coaParameterStruct);
end

% useful functions for saving output for testing
function save_input_data(coaParameterStruct)
filename = ['coaParameterStruct_m' num2str(...
        coaParameterStruct.module) 'o' ...
        num2str(coaParameterStruct.output) '.mat']
save(filename, 'coaParameterStruct');

function save_output_data(coaResultStruct, coaParameterStruct)
filename = ['coaResultStruct_m' num2str(...
        coaParameterStruct.module) 'o' ...
        num2str(coaParameterStruct.output) '.mat']
save(filename, 'coaResultStruct');
