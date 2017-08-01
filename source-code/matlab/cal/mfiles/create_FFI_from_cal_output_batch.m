function calImageStruct = create_FFI_from_cal_output_batch(numOutputFiles, cadenceForFfi)
% function calImageStruct = create_FFI_from_cal_output_batch(numOutputFiles, cadenceForFfi)
%
% This function takes the output structures from the multiple CAL invocations
% for a single CCD module/output (output from make_cal_LC_input_from_FFI_FITS),
% and reconstructs a full frame image (FFI).  The CAL output structs for all
% invocations of a given mod/out should be saved in the working directory as
% cal-outputs-#.mat, where # = numOutputFiles (# = 0 for collateral, and
% 1, ..., (numOutputFiles-1) for photometric).
%
% **Note for FFI calibration, the collateral data is first used to estimate
%   the black, smear, and dark levels, which are saved to local .mat files
%   in the first invocation. Rather than using the calibrated collateral pixels
%   (output from cal-outputs-0.mat, which are essentially the (calibrated) mean
%   of the coadded pixels), the original non-coadded collateral pixels are
%   chunked together with the photometric pixels before calibration.
%
%
% INPUTS:
%
% numOutputFiles    number of CAL output mat files containing calibrated pixels
%                   Example set of output files that should be in local dir:
%                       cal-outputs-0.mat
%                       cal-outputs-1.mat
%                       cal-outputs-2.mat
%                       cal-outputs-3.mat
%                       cal-outputs-4.mat
%                       cal-outputs-5.mat
%                       cal-outputs-6.mat
%                       cal-outputs-7.mat
%                       cal-outputs-8.mat
%                       cal-outputs-9.mat
%                       cal-outputs-10.mat
%                   An input file will also be loaded to retreive mod/out information:
%                       cal-inputs-0.mat
%
% OPTIONAL INPUTS:
% rawFFI           uncalibrated FFI, if image is desired for comparison
%
% cadenceForFfi    cadence to use for FFI, in case outputs contain N cadences
%                  and a certain cadence FFI is desired (= 1 by default)
%
%
% OUTPUTS:
%
% calImageStruct   A struct containing the FFI image and CCD module/output
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


if (nargin == 0)
    numOutputFiles = 10;
    cadenceForFfi = 1;
    
elseif (nargin == 1)
    cadenceForFfi = 1;
end

% ex. numOutputFiles = 10
gapFillValue = 0;

load cal-inputs-0.mat
ccdModule = inputsStruct.ccdModule;
ccdOutput = inputsStruct.ccdOutput;


% retrieve FC constants
fcConstants = convert_fc_constants_java_2_struct;

numCcdRows    = fcConstants.CCD_ROWS;
numCcdColumns = fcConstants.CCD_COLUMNS;

% allocate memory for full frame image
ffi           = zeros(numCcdRows, numCcdColumns);

%--------------------------------------------------------------------------
% load CAL photometric output pixels to build up FFI
%--------------------------------------------------------------------------

for i = 1:numOutputFiles
    
    load(['cal-outputs-' num2str(i) '.mat'], 'outputsStruct');
    
    % extract calibrated pixels, which include both collateral and
    % photometric pixel data
    calibratedPixels = outputsStruct.targetAndBackgroundPixels;
    
    pixelFlux = [calibratedPixels.values];          % nCadences x nPixels
    pixelFlux = pixelFlux(cadenceForFfi, :);
    
    pixelGaps = [calibratedPixels.gapIndicators];   % nCadences x nPixels
    pixelGaps = pixelGaps(cadenceForFfi, :);
    
    pixelFlux(pixelGaps) = gapFillValue;
    
    pixelRows = [calibratedPixels.row] + 1;               % 1 x nPixels
    pixelCols = [calibratedPixels.column] + 1;            % 1 x nPixels
    
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

colorbar
title(['Calibrated FFI for Module ' num2str(ccdModule) ' Output ' num2str(ccdOutput)], 'fontsize', 14);
xlabel('CCD Column Index', 'fontsize', 14);
ylabel('CCD Row Index', 'fontsize', 14);

fileNameStr = [ 'calibrated_ffi_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];

set(h, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

plot_to_file(fileNameStr, paperOrientationFlag);
close all;


return;
