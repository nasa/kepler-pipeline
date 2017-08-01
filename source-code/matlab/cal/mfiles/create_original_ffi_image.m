function create_original_ffi_image(inputsStruct)
%function create_FFI_from_cal_input(outputsStruct)
%
% function to create an FFI image from CAL outputs
%
%
% INPUTS:
%
% inputsStruct     CAL output struct containing all calibrated pixels
%
%
% OUTPUTS:
%
% original FFI image saved to original_ffi_channel*.fig
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

numCcdRows    = inputsStruct.fcConstants.CCD_ROWS;
numCcdColumns = inputsStruct.fcConstants.CCD_COLUMNS;
ccdModule     = inputsStruct.ccdModule;
ccdOutput     = inputsStruct.ccdOutput;

% allocate memory for full frame image
ffi = zeros(numCcdRows, numCcdColumns);

%--------------------------------------------------------------------------
% extract input pixels
%--------------------------------------------------------------------------
inputPixels = inputsStruct.targetAndBkgPixels;

pixelFlux = [inputPixels.values]';          % nPixels x 1

pixelGaps = [inputPixels.gapIndicators]';   % nPixels x 1

pixelFlux(pixelGaps) = gapFillValue;

pixelRows = [inputPixels.row]' + 1;               % 1 x nPixels
pixelCols = [inputPixels.column]' + 1;            % 1 x nPixels

% get linear indices for pixel row/columns
pixelLinearIdx = sub2ind(size(ffi), pixelRows, pixelCols);

ffi(pixelLinearIdx) = pixelFlux;


%--------------------------------------------------------------------------
% display image
%--------------------------------------------------------------------------
close all;
paperOrientationFlag = true;

h = figure;

imagesc(ffi(1:1058, :))

caxis([prctile(ffi(:), 5) prctile(ffi(:), 95)])

colormap hot
colorbar

title(['Original FFI for Module ' num2str(ccdModule) ' Output ' num2str(ccdOutput)], 'fontsize', 14);
xlabel('CCD Column Index', 'fontsize', 14);
ylabel('CCD Row Index', 'fontsize', 14);

fileNameStr = [ 'original_ffi_channel'  num2str(convert_from_module_output(ccdModule, ccdOutput))];

set(h, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

plot_to_file(fileNameStr, paperOrientationFlag);
close all;


return;
