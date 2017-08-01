function create_bleeding_columns_image(taskFilename, season, ffiFlag)

%----------------------------------------------------
% Create logical image plots for masked and virtual
%----------------------------------------------------
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

% check to see if any targets lie in bleeding columns
load([taskFilename '/st-1/cal-inputs-0.mat']);

% extract CCD channel
channel = convert_from_module_output(inputsStruct.ccdModule, inputsStruct.ccdOutput);


targetColsZeroBase = [inputsStruct.targetAndBkgPixels.column];
targetColsOneBase  = targetColsZeroBase + 1;
uniqueTargetColsOneBase  = unique(targetColsOneBase(:));

% extract bleeding columns for this channel/season
maskedBleedCols  = get_masked_smear_columns_to_exclude(season, channel);
virtualBleedCols = get_virtual_smear_columns_to_exclude(season, channel);


% check to see if any target pixels lie in these columns
bleedChannel = ismember(uniqueTargetColsOneBase, [maskedBleedCols(:);virtualBleedCols(:)]);
if ~any(bleedChannel)
    
    display(['There are no target pixels in bleeding columns for Channel ' num2str(channel)])
    return;
end

bleedInMaskedIdx  =  ismember(uniqueTargetColsOneBase, maskedBleedCols(:));
bleedInVirtualIdx =  ismember(uniqueTargetColsOneBase, virtualBleedCols(:));

bleedInMaskedCols  = uniqueTargetColsOneBase(bleedInMaskedIdx);
bleedInVirtualCols = uniqueTargetColsOneBase(bleedInVirtualIdx);

if any(bleedInMaskedIdx)
    display(['There are target pixels in masked bleeding columns ' mat2str(bleedInMaskedCols) ' in Channel ' num2str(channel)])
end

if any(bleedInVirtualIdx)
    display(['There are target pixels in virtual bleeding columns ' mat2str(bleedInVirtualCols) ' in Channel ' num2str(channel)])
end


load([taskFilename '/st-0/cal-inputs-0.mat']);
load([taskFilename '/st-0/cal-outputs-0.mat']);

if ~ffiFlag
    inputMaskedGaps  = [inputsStruct.maskedSmearPixels.gapIndicators];
else
    inputMaskedGaps = [inputsStruct.twoDCollateral.maskedSmearStruct.gaps.array];
    inputMaskedGaps = inputMaskedGaps(:, 1);
end

outputMaskedGaps = [outputsStruct.calibratedCollateralPixels.maskedSmear.gapIndicators];

maskedColsZeroBase = [outputsStruct.calibratedCollateralPixels.maskedSmear.column]; % 0-base

if ~ffiFlag
    inputVirtualGaps  = [inputsStruct.virtualSmearPixels.gapIndicators];
else
    inputVirtualGaps = [inputsStruct.twoDCollateral.virtualSmearStruct.gaps.array];
    inputVirtualGaps = inputVirtualGaps(:, 1);
end

outputVirtualGaps = [outputsStruct.calibratedCollateralPixels.virtualSmear.gapIndicators];

virtualColsZeroBase = [outputsStruct.calibratedCollateralPixels.virtualSmear.column]; % 0-base


% update columns to one base for image
maskedColsOneBase  = maskedColsZeroBase + 1;
virtualColsOneBase = virtualColsZeroBase + 1;


% allocate full nCadences x 1132 new gap array
nCadences = length(inputsStruct.cadenceTimes.midTimestamps);

inputMaskedGapArray = false(nCadences, 1132);
inputMaskedGapArray(:, maskedColsOneBase) = inputMaskedGaps;

outputMaskedGapArray = false(nCadences, 1132);
outputMaskedGapArray(:, maskedColsOneBase) = outputMaskedGaps;


inputVirtualGapArray = false(nCadences, 1132);
inputVirtualGapArray(:, virtualColsOneBase) = inputVirtualGaps;

outputVirtualGapArray = false(nCadences, 1132);
outputVirtualGapArray(:, virtualColsOneBase) = outputVirtualGaps;

figure;
imagesc(single(outputMaskedGapArray)-single(inputMaskedGapArray)); colorbar; colormap gray

xlabel(' Column Index ', 'fontsize', 12)
ylabel(' Cadence Index ', 'fontsize', 12)
title(['Channel ' num2str(channel) ' Masked Bleeding Cols (one-base): ' mat2str(bleedInMaskedCols)],  'fontsize', 12)

fileNameStr = ['masked_bleeding_cols_image_ch' num2str(channel)];
plot_to_file(fileNameStr, true, false, false);

figure;
imagesc(single(outputVirtualGapArray)-single(inputVirtualGapArray)); colorbar; colormap gray

xlabel(' Column Index ', 'fontsize', 12)
ylabel(' Cadence Index ', 'fontsize', 12)
title(['Channel ' num2str(channel) ' Virtual Bleeding Cols (one-base): ' mat2str(bleedInVirtualCols)],  'fontsize', 12)

fileNameStr = ['virtual_bleeding_cols_image_ch' num2str(channel)];
plot_to_file(fileNameStr, true, false, false);



return;
