function calImageStruct = create_FFI_from_cal_input_batch(numInputFiles,cadenceForFfi)
%function  calImageStruct = create_FFI_from_cal_input(numInputFiles,cadenceForFfi)
%
% This function takes the input structure from the second CAL-FFI invocation
% (which contains collateral and photometric pixels) for a single CCD module/output,
% and reconstructs a full frame image (FFI).
%
%
% **Note for FFI calibration, the collateral data is first calibrated to estimate
%   the black, smear, and dark levels, which are saved to local .mat files
%   in the first invocation.  Rather than exporting the calibrated collateral
%   pixels (which are the average of the coadded pixels), the original non-coadded
%   collateral pixels are chunked together with photometric pixels before calibration.
%
%
% INPUTS:   numInputFiles   number of photometric invocations. e.g.
%                           max(n) of cal-input-n.mat
%           cadenceForFfi   cadence number of FFI to create. Default is
%                           cadence #1
% OUTPUTS:  calImageStruct  A struct containing the FFI image and CCD module/output.
%
%--------------------------------------------------------------------------
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

gapFillValue = 0;

if(nargin==1)
    cadenceForFfi = 1;
end


load cal-inputs-0.mat

ccdModule     = inputsStruct.ccdModule;
ccdOutput     = inputsStruct.ccdOutput;
numCcdRows    = inputsStruct.fcConstants.CCD_ROWS;
numCcdColumns = inputsStruct.fcConstants.CCD_COLUMNS;

% allocate memory for full frame image
ffi = zeros(numCcdRows, numCcdColumns);

% make config map object
CMObject = configMapClass(inputsStruct.spacecraftConfigMap);

%     % get number of temporal coadds
%     nReads = get_number_of_exposures_per_ffi(CMObject);

% get collateral rows and cols (1-based)
blackRows = get_black_start_row(CMObject):get_black_end_row(CMObject);
blackColumns = get_black_start_column(CMObject):get_black_end_column(CMObject);
maskedSmearRows = get_masked_smear_start_row(CMObject):get_masked_smear_end_row(CMObject);
maskedSmearColumns = get_masked_smear_start_column(CMObject):get_masked_smear_end_column(CMObject);
virtualSmearRows = get_virtual_smear_start_row(CMObject):get_virtual_smear_end_row(CMObject);
virtualSmearColumns = get_virtual_smear_start_column(CMObject):get_virtual_smear_end_column(CMObject);

% extract collateral data as 2D arrays
blackValues = [inputsStruct.twoDCollateral.blackStruct.pixels.array];
blackGaps = [inputsStruct.twoDCollateral.blackStruct.gaps.array];

maskedSmearValues = [inputsStruct.twoDCollateral.maskedSmearStruct.pixels.array];
maskedSmearGaps = [inputsStruct.twoDCollateral.maskedSmearStruct.gaps.array];

virtualSmearValues = [inputsStruct.twoDCollateral.virtualSmearStruct.pixels.array];
virtualSmearGaps = [inputsStruct.twoDCollateral.virtualSmearStruct.gaps.array];

% load collateral data into image
ffi(blackRows,blackColumns) = blackValues';
ffi(maskedSmearRows,maskedSmearColumns) = maskedSmearValues';
ffi(virtualSmearRows,virtualSmearColumns) = virtualSmearValues';

%--------------------------------------------------------------------------
% load CAL photometric output pixels to build up FFI
%--------------------------------------------------------------------------

for i = 1:numInputFiles
    
    load(['cal-inputs-' num2str(i) '.mat'], 'inputsStruct');
    
    % extract raw pixels, which include both collateral and
    % photometric pixel data
    rawPixels = inputsStruct.targetAndBkgPixels;
    
    pixelFlux = [rawPixels.values];          % nCadences x nPixels
    pixelFlux = pixelFlux(cadenceForFfi, :);
    
    pixelGaps = [rawPixels.gapIndicators];   % nCadences x nPixels
    pixelGaps = pixelGaps(cadenceForFfi, :);
    
    pixelFlux(pixelGaps) = gapFillValue;
    
    pixelRows = [rawPixels.row] + 1;               % 1 x nPixels
    pixelCols = [rawPixels.column] + 1;            % 1 x nPixels
    
    % get linear indices for pixel row/columns
    pixelLinearIdx = sub2ind(size(ffi), pixelRows, pixelCols);
    
    ffi(pixelLinearIdx) = pixelFlux;
    
    display(['Pixels extracted from CAL output file #' num2str(i) ]);
end


%--------------------------------------------------------------------------
% save image and mod/out information to output struct
%--------------------------------------------------------------------------
calImageStruct.ccdModule = ccdModule;
calImageStruct.ccdOutput = ccdOutput;
calImageStruct.ffi = ffi;


%--------------------------------------------------------------------------
% display image
%--------------------------------------------------------------------------
close all;
paperOrientationFlag = true;

h = figure;

imagesc(ffi, [0 max(ffi(:))/100]);
colorbar;
colormap hot(256);

title(['Raw FFI for Module ' num2str(ccdModule) ' Output ' num2str(ccdOutput)], 'fontsize', 14);
xlabel('CCD Column Index', 'fontsize', 14);
ylabel('CCD Row Index', 'fontsize', 14);

fileNameStr = [ 'calibrated_ffi_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];

set(h, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

plot_to_file(fileNameStr, paperOrientationFlag);
close all;


return;


