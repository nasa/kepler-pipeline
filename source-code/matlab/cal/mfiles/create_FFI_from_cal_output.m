function calImageStruct = create_FFI_from_cal_output(outputsStruct, ccdModule, ...
    ccdOutput, fcConstants, zeroBaseIdxFlag, rawFFI, cadenceIdx, plotsOn)
%function  calImageStruct = create_FFI_from_cal_output(outputsStruct, ccdModule, ...
%   ccdOutput, fcConstants, zeroBaseIdxFlag, rawFFI, cadenceIdx, plotsOn)
%
% This function takes the output structure from the second CAL-FFI invocation
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
% INPUTS:
%
% outputsStruct     CAL output struct containing all calibrated pixels
%
% ccdModule
% ccdOutput
%
% fcConstants       FC constants struct containing numCcdRows and numCcdColumns
%
% rawFFI            If raw FFI array is input, an image will also be created
%                   and saved to local directory
%
% OUTPUTS:
%
% calImageStruct   A struct containing the FFI image and CCD module/output.
%                  The calibrated FFI image will be saved to local directory
%
%
%
% Note if not running in pipeline, can extract fcConstants struct with:
%     fcConstants = convert_fc_constants_java_2_struct
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

if (nargin < 5)
    zeroBaseIdxFlag = false;
    rawFFI          = [];
    cadenceIdx      = 1;
    plotsOn         = false;
elseif (nargin == 5)
    rawFFI          = [];
    cadenceIdx      = 1;
    plotsOn         = false;
elseif (nargin == 6)
    cadenceIdx      = 1;
    plotsOn         = false;
elseif (nargin == 7)
    plotsOn         = false;
end

% ex. numOutputFiles = 10
gapFillValue = 0;

numCcdRows    = fcConstants.CCD_ROWS;
numCcdColumns = fcConstants.CCD_COLUMNS;

% allocate memory for full frame image
ffi           = zeros(numCcdRows, numCcdColumns);

%--------------------------------------------------------------------------
% load CAL photometric output pixels to build up FFI
%--------------------------------------------------------------------------

% extract calibrated pixels, which include collateral and photometric pixels
calibratedPixels = outputsStruct.targetAndBackgroundPixels;

pixelFlux = [calibratedPixels.values]';          % nPixels x 1

% get pixels for a single cadence
pixelFlux = pixelFlux(:, cadenceIdx);

pixelGaps = [calibratedPixels.gapIndicators]';   % nPixels x 1

% get pixel gaps for a single cadence
pixelGaps = pixelGaps(:, cadenceIdx);

pixelFlux(pixelGaps) = gapFillValue;


% correct pixels for Java 0-base indices only if this function is not run
% in the SOC pipeline
if zeroBaseIdxFlag
    pixelRows = [calibratedPixels.row]' + 1;               % 1 x nPixels
    pixelCols = [calibratedPixels.column]' + 1;            % 1 x nPixels
else
    pixelRows = [calibratedPixels.row]';               % 1 x nPixels
    pixelCols = [calibratedPixels.column]';            % 1 x nPixels
end

% get linear indices for pixel row/columns
pixelLinearIdx = sub2ind(size(ffi), pixelRows, pixelCols);

ffi(pixelLinearIdx) = pixelFlux;


%--------------------------------------------------------------------------
% save image and mod/out information to output struct
%--------------------------------------------------------------------------
calImageStruct.ccdModule = ccdModule;
calImageStruct.ccdOutput = ccdOutput;
calImageStruct.ffi = ffi;

if (plotsOn)
    
    %--------------------------------------------------------------------------
    % display image
    %--------------------------------------------------------------------------
    close all;
    paperOrientationFlag = true;
    
    h = figure;
    
    if(max(max(ffi(1:1058, :)))/100 > 0)
        imagesc(ffi(1:1058, :), [0 max(max(ffi(1:1058, :)))/100]);
    else
        imagesc(ffi(1:1058, :));
    end
    
    colormap hot
    colorbar
    
    if (cadenceIdx > 1)
        title(['Calibrated FFI for Module ' num2str(ccdModule) ' Output ' num2str(ccdOutput) ',    Cad# ' num2str(cadenceIdx)], 'fontsize', 14);
    else
        title(['Calibrated FFI for Module ' num2str(ccdModule) ' Output ' num2str(ccdOutput)], 'fontsize', 14);
    end
    
    xlabel('CCD Column Index', 'fontsize', 14);
    ylabel('CCD Row Index (charge injection rows clipped)', 'fontsize', 14);
    
    fileNameStr = [ 'calibrated_ffi_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
    
    set(h, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    plot_to_file(fileNameStr, paperOrientationFlag);
    close all;
    
    %--------------------------------------------------------------------------
    % display raw image
    %--------------------------------------------------------------------------
    if (nargin == 6 && ~isempty(rawFFI))
        
        h2 = figure;
        
        imagesc(rawFFI, [0 max(rawFFI(:))/100]);
        
        colorbar
        title(['Raw FFI for Module ' num2str(ccdModule) ' Output ' num2str(ccdOutput)], 'fontsize', 14);
        xlabel('CCD Column Index', 'fontsize', 14);
        ylabel('CCD Row Index', 'fontsize', 14);
        
        fileNameStr = [ 'raw_ffi_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
        
        set(h2, 'PaperPositionMode', 'auto');
        set(gca, 'fontsize', 13);
        
        plot_to_file(fileNameStr, paperOrientationFlag);
        close all;
    end
end

return;