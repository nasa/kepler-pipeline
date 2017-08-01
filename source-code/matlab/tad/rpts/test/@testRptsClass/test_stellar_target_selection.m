function self = test_stellar_target_selection(self)
% self = test_stellar_target_selection(self)
%
% This test compares a binary image of the output (stellar target definitions and
% offsets) to a binary image of the input (stellar apertures and offsets, with
% the entire image convolved using the same kernel as that used in convolving
% individual target images).  An error is reported if the input pixels are not
% a subset of the output target definitions.  An optional plot of the input &
% output pixels is created for visual inspection.
%
% Output from get_stellar_target_definitions:
%   stellarTargetDefinitions   struct array with fields:
%        keplerId
%        maskIndex
%        referenceRow
%        referenceColumn
%        excessPixels
%        status
%   stellarIndices    struct array with fields:
%        stellarRows
%        stellarColumns
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, testRptsClass('test_stellar_target_selection'));
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  SOC_REQ_MAP: 967.TAD.2, M.test_stellar_target_selection, CERTIFIED <SVN_REV_#>
%  SOC_REQ_MAP: 967.TAD.3, M.test_stellar_target_selection, CERTIFIED <SVN_REV_#>
%  SOC_REQ_MAP: 926.TAD.7, M.test_stellar_target_selection, CERTIFIED <SVN_REV_#>
%  SOC_REQ_MAP: 926.TAD.23, M.test_stellar_target_selection, CERTIFIED <SVN_REV_#>
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

% generate the inputs structure by one of the following methods:

% (1) create the input structure rptsInputStruct (which is saved as inputs.mat)
% [rptsInputStruct, rptsObject] = generate_rpts_test_data;

% (2) load the previously generated test data structure rptsInputStruct
load /path/to/matlab/tad/rpts/inputs.mat rptsInputStruct rptsObject;

% (3) or load the previously generated bin file
% inputFileName = '/path/to/java/tad/rpts/inputs-0.bin';
% rptsInputStruct = read_RptsInputs(inputFileName);
% rptsObject = rptsClass(rptsInputStruct);

if (~isobject(rptsObject))
    rptsObject = rptsClass(rptsInputStruct);
end

if (isfield(rptsInputStruct, 'debugFlag'))
    debugFlag = rptsInputStruct.debugFlag;
else
    debugFlag = 0;
end

% run test only if input stellar apertures is non-empty struct array
if (~isempty(rptsInputStruct.stellarApertures))

    %--------------------------------------------------------------------------
    % generate the stellar target definitions and the row/column indices of the selected pixels
    % note pixels are in matlab 1-base
    [stellarTargetDefinitions, stellarIndices] = get_stellar_target_definitions(rptsObject);

    %--------------------------------------------------------------------------
    % create logical image of input stellar target (refRow/refCol + offset) pixels,
    % with entire image convolved using same kernel as individual stellar target images
    % in get_stellar_target_definitions
    %--------------------------------------------------------------------------
    % convert output image from arrays of structures to 2D array
    moduleOutputImage = rptsInputStruct.moduleOutputImage;
    moduleOutputImage = struct_to_array2D(moduleOutputImage);
    [dim1, dim2] = size(moduleOutputImage);

    nHaloRings = rptsInputStruct.rptsModuleParametersStruct.nHaloRings;

    imageLogical = 0;
    for i = 1: length([rptsInputStruct.stellarApertures])

        inputOffsetRows = [rptsInputStruct.stellarApertures(i).offsets.row];
        inputOffsetColumns = [rptsInputStruct.stellarApertures(i).offsets.column];

        stellarInputRows = rptsInputStruct.stellarApertures(i).referenceRow  + 1 + inputOffsetRows;
        stellarInputColumns = rptsInputStruct.stellarApertures (i).referenceColumn + 1 + inputOffsetColumns;

        % create logical image
        imageLogical = imageLogical + full(sparse(double(stellarInputRows), double(stellarInputColumns), 1., dim1, dim2));
    end

    haloKernel = [1,1,1;1,1,1;1,1,1];

    % incrementally add a 1 pixel buffer around the input aperture
    for k = 1:nHaloRings
        % convolve mod/out image with same kernel used in creating stellar target definitions
        imageConvolved = conv2(haloKernel, imageLogical);
        imageLogical = imageConvolved(1:dim1, 1:dim2);

        % center pixel row/column shifts by 1
        shiftedImageLogical = shift_image(imageLogical, [-1, -1]);
        imageLogical = shiftedImageLogical;
    end

    [imageRow, imageCol] = find(imageLogical);
    imageLogical = full(sparse(double(imageRow), double(imageCol), 1., dim1, dim2));

    % plot pixels in (input) apertures including halo pixels
    if (debugFlag)
        figure
        imagesc(imageLogical)
        title('Stellar input pixels (binary image convolved)')
        colormap hot
    end

    %--------------------------------------------------------------------------
    % create logical image of output stellar target (refRow/refCol + offset) pixels
    %--------------------------------------------------------------------------
    maskIndices = [stellarTargetDefinitions.maskIndex];

    imageLogicalResults = 0;
    for i = 1:length(maskIndices)

        outputOffsetRows = [ rptsInputStruct.existingMasks(stellarTargetDefinitions(i).maskIndex).offsets.row];
        outputOffsetColumns = [rptsInputStruct.existingMasks(stellarTargetDefinitions(i).maskIndex).offsets.column];

        stellarOutputRows = stellarTargetDefinitions(i).referenceRow + outputOffsetRows;
        stellarOutputColumns = stellarTargetDefinitions(i).referenceColumn + outputOffsetColumns;

        % create logical image
        imageLogicalResults = imageLogicalResults + full(sparse(double(stellarOutputRows), ...
            double(stellarOutputColumns), 1., dim1, dim2));
    end

    % plot pixels in (output) target definitions (# of excess pixels is displayed in title)
    imageDiff = imageLogicalResults - imageLogical;
    nExcessPixels = length(find(imageDiff));
    if (debugFlag)
        figure
        imagesc(imageLogicalResults)
        title(['Stellar output pixels; excess pixels: ', num2str(nExcessPixels)])
        colormap hot
    end

    %--------------------------------------------------------------------------
    % compare logical images from (1) input stellar apertures and offsets convolved
    % and (2) output stellar target definitions and offsets, and check to see
    % whether all input aperture pixels are defined in output target definitions
    %--------------------------------------------------------------------------

    inputPixels = find(imageLogical);
    outputPixels = find(imageLogicalResults);

    % check if all input pixels are in output pixel list
    allPixelsSelected = all(ismember(inputPixels, outputPixels));

    if (~allPixelsSelected)
        messageOut = 'Pixels in target definitions are not a subset of input aperture (+ halos) pixels';
        assert_equals(1, 0, messageOut);
    end

    %--------------------------------------------------------------------------
    % Optional: plot input & output pixels for visual inspection
    %--------------------------------------------------------------------------
    if (debugFlag)
        figure

        % plot input aperture pixels (convolved)
        [inputRow, inputCol] = find(imageLogical);
        plot(inputRow, inputCol, 'go')
        hold on

        % overlay input aperture pixels
        for i = 1:length([rptsInputStruct.stellarApertures])

            % plot (input) stellar aperture reference row/cols and offsets, add 1 for matlab 1-base
            inputOffsetsRow = [rptsInputStruct.stellarApertures(i).offsets.row];
            inputOffsetsColumn = [rptsInputStruct.stellarApertures(i).offsets.column];

            plot((rptsInputStruct.stellarApertures(i).referenceRow + 1 + inputOffsetsRow), ...
                (rptsInputStruct.stellarApertures (i).referenceColumn + 1 + inputOffsetsColumn), 'ro');

            hold on
        end
        hold on

        % plot (output) stellar target definition row/cols and offsets, no need to add 1 (already done in rptsClass)
        for i = 1:length(stellarTargetDefinitions)
            outputOffsetsRow = [rptsInputStruct.existingMasks(stellarTargetDefinitions(i).maskIndex).offsets.row];
            outputOffsetsColumn = [rptsInputStruct.existingMasks(stellarTargetDefinitions(i).maskIndex).offsets.column];

            plot((stellarTargetDefinitions(i).referenceRow + outputOffsetsRow), ...
                (stellarTargetDefinitions(i).referenceColumn + outputOffsetsColumn), 'b+');

            hold on
            title('Stellar Apertures (red), added Halos (green) and Output Target Definition Pixels (blue)');

            grid on
        end
    end
end

return