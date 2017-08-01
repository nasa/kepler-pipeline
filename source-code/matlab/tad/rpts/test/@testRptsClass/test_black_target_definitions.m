function self = test_black_target_definitions(self)
% self = test_black_target_definitions(self)
%
% This test compares logical images of (1) the input black columns and input
% stellar, background, and smear rows, and (2) the output black target definitions and supermask.
% An error is reported if the input and output pixels are not identical.
%
% Note: pixels in the mask definition are converted to 0-base herein (more efficient),
% whereas pixels in target definitions are converted in separate algorithm
%
% Output from get_black_target_definitions:
%   blackTargetDefinitions   struct array with fields:
%      keplerId
%      maskIndex
%      referenceRow
%      referenceColumn
%      excessPixels
%      status
%   blackMaskDefinition      struct array with field 'offsets', which contains:
%      row
%      column
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, testRptsClass('test_black_target_definitions'));
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  SOC_REQ_MAP: 926.TAD.7, M.test_black_target_definitions, CERTIFIED <SVN_REV_#>
%  SOC_REQ_MAP: 926.TAD.18, M.test_black_target_definitions, CERTIFIED <SVN_REV_#>
%  SOC_REQ_MAP: 926.TAD.20, M.test_black_target_definitions, CERTIFIED <SVN_REV_#>
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
    % generate the black target definitions and supermask.  Note target definitions
    % are in matlab 1-base, while supermask pixels are in 0-base
    % [blackTargetDefinitions, blackMaskDefinition] = get_black_target_definitions(rptsObject);
    rptsResultsStruct = get_reference_pixel_target_definitions(rptsObject);
    blackTargetDefinitions =  rptsResultsStruct.blackTargetDefinitions;
    blackMaskDefinition = rptsResultsStruct.blackMaskDefinition;

    % get pixel indices from stellar and background smear target definitions/masks,
    % which (along with smear rows) are are used to collect black
    [stellarTargetDefinitions, stellarIndices] = get_stellar_target_definitions(rptsObject);
    [backgroundTargetDefinition, backgroundMaskDefinition, backgroundIndices] =  ...
        get_background_target_definition(rptsObject);

    %--------------------------------------------------------------------------
    % create logical image of input black rows/columns
    %--------------------------------------------------------------------------
    blackColumns = rptsInputStruct.rptsModuleParametersStruct.blackColumns + 1;
    smearRows = rptsInputStruct.rptsModuleParametersStruct.smearRows + 1;

    % convert output image from arrays of structures to 2D array
    moduleOutputImage = rptsInputStruct.moduleOutputImage;
    moduleOutputImage = struct_to_array2D(moduleOutputImage);

    % preallocate arrays for binary images
    imageLogicalResults = zeros(size(moduleOutputImage));
    imageLogicalInputs = zeros(size(moduleOutputImage));

    % collect rows from stellar, background, and smear targets, which are input to
    % black target selection algorithm
    stellarRows = [stellarIndices.stellarRows];
    backgroundRows = [backgroundIndices.backgroundRows];
    blackRows = unique([stellarRows backgroundRows smearRows']);

    % create logical image
    imageLogicalInputs(blackRows, blackColumns) = 1;

    if (debugFlag)
        figure
        imagesc(imageLogicalInputs)
        title('Black input pixels')
        colormap hot
    end

    %--------------------------------------------------------------------------
    % create logical image of output black target + mask definitions
    %--------------------------------------------------------------------------
    blackOutputCenterRows = [blackTargetDefinitions.referenceRow];
    blackOutputCenterColumns = [blackTargetDefinitions.referenceColumn];

    for i = 1:length(blackTargetDefinitions)

        blackOutputRows = blackOutputCenterRows(i) +  ([blackMaskDefinition.offsets.row] + 1);
        blackOutputColumns = blackOutputCenterColumns(i) + ([blackMaskDefinition.offsets.column] + 1);

        % create logical image
        imageLogicalResults(blackOutputRows, blackOutputColumns) = 1;
    end

    if (debugFlag)
        figure
        imagesc(imageLogicalInputs)
        title('Black output pixels')
        colormap hot
    end

    %--------------------------------------------------------------------------
    % compare logical images
    input = find(imageLogicalInputs);
    output = find(imageLogicalResults);

    messageOut = 'Black input and output logical images are not identical';
    assert_equals(output, input, messageOut);

end
return