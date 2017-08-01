function compare_2Dblack_and_raw_FFI(inputsStruct, rawFFI)
%
% function to compare cal input 2D black model with raw FFI
%
% INPUTS:
%  inputsStruct     inputs to CAL CSCI to process full frame images (FFIs)
%  rawFFI           raw FFI array that was repackaged for calibration
%
%  rawFFI = fitsread('/path/to/flight/commissioning/c019_bias_darker_FFI/data/kplr2009079110102_ffi-orig.fits', 'Image', channel);
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

ccdModule = inputsStruct.ccdModule;
ccdOutput = inputsStruct.ccdOutput;
channel = convert_from_module_output(ccdModule, ccdOutput);

%--------------------------------------------------------------------------
% create 2D black array that is input into CAL
%--------------------------------------------------------------------------
twoDBlackModel = inputsStruct.twoDBlackModel;

% instantiate object
twoDBlackObject = twoDBlackClass(twoDBlackModel);

% extract 2D black array
twoDBlackArray = get_two_d_black(twoDBlackObject);


%--------------------------------------------------------------------------
% compute mean 2D black and mean FFI
%--------------------------------------------------------------------------
meanRawFFI        = mean(rawFFI(:))/270;
meanTwoDBlack     = mean(twoDBlackArray(:));

medianRawFFI      = median(rawFFI(:))/270;
medianTwoDBlack   = median(twoDBlackArray(:));

%--------------------------------------------------------------------------
% display images of FFI and 2D black side by side
%--------------------------------------------------------------------------
figure
imagesc([rawFFI(1:1058, :)/270 - median(rawFFI(:))/270, twoDBlackArray(1:1058, : ) - median(twoDBlackArray(:))], ...
    [prctile(colvec(rawFFI(1:1058, :)/270 - median(rawFFI(:))/270), 1), prctile(colvec(rawFFI(1:1058, :)/270 - median(rawFFI(:))/270), 99)])

colorbar
title(['Raw FFI (left panel) and 2D Black (right panel), channel ' num2str(channel) ' [' num2str(ccdModule) ', ' num2str(ccdOutput) ']']);

fileNameStr = ['ffi_and_2dblack_images_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

%--------------------------------------------------------------------------
% display image of FFI minus 2D black
%--------------------------------------------------------------------------

figure
imagesc((rawFFI(1:1058, :)/270 - twoDBlackArray(1:1058, :)), [-1,1]*20)

colorbar
title(['FFI minus 2D Black, channel ' num2str(channel) ' [' num2str(ccdModule) ', ' num2str(ccdOutput) ']   med FFI = ' num2str(medianRawFFI, '%10.2f') ', med 2Dblack = ' num2str(medianTwoDBlack, '%10.2f')]);
xlabel('CCD Column Index');
ylabel('CCD Row Index');

fileNameStr = ['ffi_minus_2dblack_image_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

%--------------------------------------------------------------------------
% plot FFI minus 2D black
%--------------------------------------------------------------------------

figure
plot((rawFFI(1:1058,:)/270 - twoDBlackArray(1:1058, :)), '.')

title(['FFI minus 2D Black, channel ' num2str(channel) ' [' num2str(ccdModule) ', ' num2str(ccdOutput) ']   med FFI = ' num2str(medianRawFFI, '%10.2f') ', med 2Dblack = ' num2str(medianTwoDBlack, '%10.2f')]);
xlabel('CCD Row Index');
ylabel('FFI minus 2DBlack (ADU)');

fileNameStr = [ 'ffi_minus_2dblack_plot_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

%--------------------------------------------------------------------------
% plot FFI and 2D black
%--------------------------------------------------------------------------

figure
plot(1:1058, rawFFI(1:1058,:)/270, 'r.', 1:1058, twoDBlackArray(1:1058, :), 'b.')

title(['Raw FFI/270 and 2D Black, channel ' num2str(channel) ' [' num2str(ccdModule) ', ' num2str(ccdOutput) ']   mean FFI = ' num2str(meanRawFFI, '%10.2f') ', med FFI = ' num2str(medianRawFFI, '%10.2f') ', med 2Dblack = ' num2str(medianTwoDBlack, '%10.2f')]);
xlabel('CCD Row Index');
ylabel('Raw FFI/270 (red) and 2D Black (blue) (ADU)');

fileNameStr = [ 'ffi_and_2dblack_plot_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

return;
