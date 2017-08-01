function self = test_background_target_selection(self)
% self = test_background_target_selection(self)
%
% This test checks whether all selected background pixels are within a region
% bounded by the radius (an input parameter) from a stellar target.  The total
% number of background pixels collected are checked against the number expected
% (the number per stellar target (an input parameter) times the number of stellar
% targets).  An optional plot of the selected background pixels and input radii
% surrounding each target is created for visual inspection.
%
% Output from get_background_target_definition:
%  backgroundTargetDefinition   struct array with fields:
%       keplerId
%       maskIndex
%       referenceRow
%       referenceColumn
%       excessPixels
%       status
%  backgroundIndices             struct array with fields:
%       backgroundRows
%       backgroundColumns
%
%  Example
%  =======
%  Use a test runner to run the test method:
%         Example: run(text_test_runner, testRptsClass('test_background_target_selection'));
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  SOC_REQ_MAP: 967.TAD.2, M.test_background_target_selection, CERTIFIED <SVN_REV_#>
%  SOC_REQ_MAP: 967,TAD.3, M.test_background_target_selection, CERTIFIED <SVN_REV_#>
%  SOC_REQ_MAP: 926.TAD.7, M.test_background_target_selection, CERTIFIED <SVN_REV_#>
%  SOC_REQ_MAP: 926.TAD.17, M.test_background_target_selection, CERTIFIED <SVN_REV_#>
%  SOC_REQ_MAP: 926.TAD.22, M.test_background_target_selection, CERTIFIED <SVN_REV_#>
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
%load /path/to/matlab/tad/rpts/inputs.mat rptsInputStruct rptsObject;
%load ../rpts_bug_fix/rptsInputs.mat rptsInputStruct

load rptsInputs.mat rptsInputStruct


% (3) or load the previously generated bin file
% inputFileName = '/path/to/java/tad/rpts/inputs-0.bin';
% rptsInputStruct = read_RptsInputs(inputFileName);
% rptsObject = rptsClass(rptsInputStruct);

%if (~isobject(rptsObject))
rptsObject = rptsClass(rptsInputStruct);
%end

if (isfield(rptsInputStruct, 'debugFlag'))
    debugFlag = rptsInputStruct.debugFlag;
else
    debugFlag = 1;
end

% run test only if input stellar apertures is non-empty struct array
if (~isempty(rptsInputStruct.stellarApertures))

    %--------------------------------------------------------------------------
    % generate the background target definition, mask definition, and the row/column
    % indices of the selected pixels.  Note pixels for mask definition are in java 0-base
    %--------------------------------------------------------------------------
    [backgroundTargetDefinition, backgroundMaskDefinition, backgroundIndices] = ...
        get_background_target_definition(rptsObject);

    %--------------------------------------------------------------------------
    % check to ensure all selected pixels are bounded by the input radius of each target star
    %--------------------------------------------------------------------------

    % convert output image from arrays of structures to 2D array
    moduleOutputImage = rptsInputStruct.moduleOutputImage;
    moduleOutputImage = struct_to_array2D(moduleOutputImage);
    [dim1, dim2] = size(moduleOutputImage);

    [rowMesh, columnMesh] = ndgrid(1:dim1, 1:dim2);
    backgroundRadius = rptsInputStruct.rptsModuleParametersStruct.radiusForBackgroundPixelSelection;

    apertureCenterRow = zeros(length(rptsInputStruct.stellarApertures), 1);
    apertureCenterColumn = zeros(length(rptsInputStruct.stellarApertures), 1);
    for j = 1:length(rptsInputStruct.stellarApertures)

        % find aperture center row/column
        offsetRows = [rptsInputStruct.stellarApertures(j).offsets.row];
        offsetColumns = [rptsInputStruct.stellarApertures(j).offsets.column];

        % apertures are in 0-base, so increase by 1
        apertureCenterRow(j) = round(mean(rptsInputStruct.stellarApertures(j).referenceRow + 1 + offsetRows));
        apertureCenterColumn(j) = round(mean(rptsInputStruct.stellarApertures(j).referenceColumn + 1 + offsetColumns));

        % (to be less conservative, can divide by this by 2 to find the max radius)
        maxRowOffsets = max(offsetRows) - min(offsetRows);

        % the maximum 'spread in y' will be used to add to bounding radius to
        % be conservative, can divide by this by two to find the max in row offsets
        maxColOffsets = max(offsetColumns) - min(offsetColumns);

        % take the maximum number of pixels to add to the bounding radius.  The
        % aperture pixels will be filtered out.
        newBackgroundRadius = backgroundRadius + max(maxRowOffsets, maxColOffsets);


        % find pixels within input radius on target image
        pixelDistanceArray = sqrt((rowMesh - apertureCenterRow(j)).^2 + (columnMesh - apertureCenterColumn(j)).^2);

        [goodPixelsRow, goodPixelsColumn] =  find(pixelDistanceArray <= newBackgroundRadius + 1);

        backgroundPixelsRow = backgroundIndices(j).backgroundRows;
        backgroundPixelsColumn = backgroundIndices(j).backgroundColumns;

        allGoodBackgroundPixels = all(ismember([backgroundPixelsRow(:), backgroundPixelsColumn(:)], ...
            [goodPixelsRow(:), goodPixelsColumn(:)],'rows'));

        if (~allGoodBackgroundPixels)
            messageOut = 'Background row or column pixels are not bounded by input radius to a stellar target';
            assert_equals(1, 0, messageOut);
        end
    end
    
    %--------------------------------------------------------------------------
    % check to ensure number of selected background reference pixels are less than
    % or equal to expected number (number per stellar target (input parameter) times
    % number of stellar targets)
    %--------------------------------------------------------------------------

    % number of expected background pixels
    nBackgroundPixelsInput = length([rptsInputStruct.stellarApertures]) * ...
        rptsInputStruct.rptsModuleParametersStruct.nBackgroundPixelsPerStellarTarget;

    % number of selected background pixels may be less than expected (if there weren't
    % enough "good" pixels to select from)
    nBackgroundPixelsSelected = length([backgroundIndices.backgroundRows]);

    if (nBackgroundPixelsSelected > nBackgroundPixelsInput)
        messageOut = 'Number of background pixels selected exceeds total number of requested pixels';
        assert_equals(1, 0, messageOut);
    end

    if (nBackgroundPixelsSelected < nBackgroundPixelsInput)
        warning('TAD:rpts:backgroundTargetSelectionTest', ...
            'TAD:rpts:get_background_target_definition:  Number of background pixels selected is less than total number of requested pixels');
    end


    %--------------------------------------------------------------------------
    % Optional: plot input stellar apertures & output background reference pixels for visual inspection
    %--------------------------------------------------------------------------
    if (debugFlag)
        % plot (input) stellar aperture reference row/cols
        figure
        plot(apertureCenterRow, apertureCenterColumn, 'rd');
        hold on

        % plot stellar apertures

        for j = 1:length(rptsInputStruct.stellarApertures)

            % find aperture center row/column
            offsetRows = [rptsInputStruct.stellarApertures(j).offsets.row];
            offsetColumns = [rptsInputStruct.stellarApertures(j).offsets.column];

            apertureRows = rptsInputStruct.stellarApertures(j).referenceRow  + 1 + offsetRows;
            apertureColumns = rptsInputStruct.stellarApertures (j).referenceColumn + 1 + offsetColumns;
            plot(apertureRows, apertureColumns, 'ro');

        end

        % (output) background target definition row/col is in 1-base (1,1)
        plot(backgroundTargetDefinition.referenceRow, backgroundTargetDefinition.referenceColumn, 'go');

        % plot (output) mask definition pixel offsets, add 1 for matlab 1-base
        plot([backgroundMaskDefinition.offsets.row] + 1, [backgroundMaskDefinition.offsets.column] + 1, 'b+');

        % plot the collected background rows and columns
        hold on
        plot([backgroundIndices.backgroundRows], 1, 'ko')
        hold on
        plot(1, [backgroundIndices.backgroundColumns], 'ko');

        title('Background target pixels selected (blue symbols) and stellar apertures (red symbols)');
        %legend('aperture centers', 'aperture pixels', 'background target def (output)', 'selected background pixels');

        %--------------------------------------------------------------------------
        % extract background radius
        backgroundRadius = rptsInputStruct.rptsModuleParametersStruct.radiusForBackgroundPixelSelection;

        % plot circles bounding area around aperture centers - any pixel that had a segment of
        % circle is defined to lie within input radius
        hold on
        for k = 1:length([rptsInputStruct.stellarApertures])
            offsetsRow = [rptsInputStruct.stellarApertures(k).offsets.row];
            offsetsColumn = [rptsInputStruct.stellarApertures(k).offsets.column];

            centerRow = round(mean(rptsInputStruct.stellarApertures(k).referenceRow + 1 + offsetsRow));
            centerColumn = round(mean(rptsInputStruct.stellarApertures(k).referenceColumn + 1 + offsetsColumn));

            % the largest spread in row/col offsets are used to add to bounding radius
            % (to be less conservative, can divide by this by 2 to find the max radius)
            maxRowOffsets = max(offsetsRow) - min(offsetsRow);

            % the maximum 'spread in y' will be used to add to bounding radius to
            % be conservative, can divide by this by two to find the max in row offsets
            maxColOffsets = max(offsetsColumn) - min(offsetsColumn);

            % take the maximum number of pixels to add to the bounding radius.  The
            % aperture pixels will be filtered out.
            newBackgroundRadius = backgroundRadius + max(maxRowOffsets, maxColOffsets);

            theta = linspace(0, 2*pi, 500);
            radius = ones(1, 500) * (newBackgroundRadius + 0.5);
            [x, y] = pol2cart(theta, radius);

            xNew = x + centerRow;
            yNew = y + centerColumn;
            hold on
            plot(xNew, yNew, 'r.');
        end
        grid on
    end
end
return