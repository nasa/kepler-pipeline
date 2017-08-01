function calInputStruct = convert_cal_etem2_inputs_to_0_base(calInputStruct)
%function calInputStruct = convert_cal_inputs_to_1_base(calInputStruct)
%
% function to convert all row/column ETEM2 output to java 0-based indices 
%
% example calInputStruct =
%                    version: 'CalInputs Version 4'
%                 debugLevel: 1
%                  firstCall: 1
%                   lastCall: 0
%                totalPixels: 8759
%                cadenceType: 'LONG'
%                  ccdModule: 6
%                  ccdOutput: 3
%     moduleParametersStruct: [1x1 struct]
%                fcConstants: [1x1 struct]
%               cadenceTimes: [1x1 struct]
%                  gainModel: [1x1 struct]
%             flatFieldModel: [1x1 struct]
%             twoDBlackModel: [1x1 struct]
%             linearityModel: [1x1 struct]
%            undershootModel: [1x1 struct]
%             readNoiseModel: [1x1 struct]
%         targetAndBkgPixels: []
%               twoDBlackIds: [1x4 struct]
%           ldeUndershootIds: [1x3 struct]
%          maskedSmearPixels: [1x1100 struct]
%         virtualSmearPixels: [1x1100 struct]
%                blackPixels: [1x1070 struct]
%          maskedBlackPixels: []
%         virtualBlackPixels: []
%        spacecraftConfigMap: [1x1 struct]
%              requantTables: [1x1 struct]
%              huffmanTables: [1x1 struct]
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

% extract pixel fields that contain rows and/or columns; check for
% availability, then convert to matlab 1-based indices
availableBlackPixels         = ~isempty(calInputStruct.blackPixels);
availableMaskedSmearPixels   = ~isempty(calInputStruct.maskedSmearPixels);
availableVirtualSmearPixels  = ~isempty(calInputStruct.virtualSmearPixels);
availableTargetAndBkgPixels  = ~isempty(calInputStruct.targetAndBkgPixels);
availabletwoDBlackIds        = ~isempty(calInputStruct.twoDBlackIds);
availableldeUndershootIds    = ~isempty(calInputStruct.ldeUndershootIds);

%--------------------------------------------------------------------------
% black pixel rows
%--------------------------------------------------------------------------
if (availableBlackPixels)
    % extract pixels
    blackPixels = calInputStruct.blackPixels;
    % combine pixels and increment each value in array by 1
    blackRows = [blackPixels.row] - 1;
    % convert 2D arrays to cell arrays
    blackRowsCellArray = num2cell(blackRows);
    % deal 1-based values back into struct arrays
    [blackPixels(1:length(blackRowsCellArray)).row] = deal(blackRowsCellArray{:});
    % save updated structure
    calInputStruct.blackPixels = blackPixels;
end

%--------------------------------------------------------------------------
% masked smear pixel columns
%--------------------------------------------------------------------------
if (availableMaskedSmearPixels)
    % extract pixels
    maskedSmearPixels = calInputStruct.maskedSmearPixels;
    % combine pixels and increment each value in array by 1
    msmearColumns = [maskedSmearPixels.column] - 1;
    % convert 2D arrays to cell arrays
    msmearColumnsCellArray = num2cell(msmearColumns);
    % deal 1-based values back into struct arrays
    [maskedSmearPixels(1:length(msmearColumnsCellArray)).column] = ...
        deal(msmearColumnsCellArray{:});
    % save updated structure
    calInputStruct.maskedSmearPixels = maskedSmearPixels;
end

%--------------------------------------------------------------------------
% virtual smear pixel columns
%--------------------------------------------------------------------------
if (availableVirtualSmearPixels)
    % extract pixels
    virtualSmearPixels = calInputStruct.virtualSmearPixels;
    % combine pixels and increment each value in array by 1
    vsmearColumns = [virtualSmearPixels.column] - 1;
    % convert 2D arrays to cell arrays
    vsmearColumnsCellArray = num2cell(vsmearColumns);
    % deal 1-based values back into struct arrays
    [virtualSmearPixels(1:length(vsmearColumnsCellArray)).column] = ...
        deal(vsmearColumnsCellArray{:});
    % save updated structure
    calInputStruct.virtualSmearPixels = virtualSmearPixels;
end

%--------------------------------------------------------------------------
% target/background pixel rows and columns
%--------------------------------------------------------------------------
if (availableTargetAndBkgPixels)
    % extract pixels
    targetAndBkgPixels = calInputStruct.targetAndBkgPixels;

    % combine rows and increment each value in array by 1
    targetBkgRows = [targetAndBkgPixels.row] - 1;
    % convert 2D arrays to cell arrays
    targetBkgRowsCellArray = num2cell(targetBkgRows);
    % deal 1-based values back into struct arrays
    [targetAndBkgPixels(1:length(targetBkgRowsCellArray)).row] = ...
        deal(targetBkgRowsCellArray{:});

    % combine columns and increment each value in array by 1
    targetBkgColumns = [targetAndBkgPixels.column] - 1;
    % convert 2D arrays to cell arrays
    targetBkgColumnsCellArray = num2cell(targetBkgColumns);
    % deal 1-based values back into struct arrays
    [targetAndBkgPixels(1:length(targetBkgColumnsCellArray)).column] = ...
        deal(targetBkgColumnsCellArray{:});

    % save updated structure
    calInputStruct.targetAndBkgPixels = targetAndBkgPixels;
end

%--------------------------------------------------------------------------
% twoDBlack pixel rows and columns
%--------------------------------------------------------------------------
if (availabletwoDBlackIds)
    % extract pixels
    twoDBlackIds = calInputStruct.twoDBlackIds;

    % increment the rows and columns for the twoDBlackIds; this is a little
    % different than the cases above because the sizes of the twoDBlack
    % regions do not have to be uniform
    twoDBlackIdsRowsCellArray = arrayfun(@(x) x.rows - 1, twoDBlackIds, ...
        'UniformOutput', false);
    [twoDBlackIds(1:length(twoDBlackIdsRowsCellArray)).rows] = ...
        twoDBlackIdsRowsCellArray{:};

    twoDBlackIdsColsCellArray = arrayfun(@(x) x.cols - 1, twoDBlackIds, ...
        'UniformOutput', false);
    [twoDBlackIds(1:length(twoDBlackIdsColsCellArray)).cols] = ...
        twoDBlackIdsColsCellArray{:};

    % save updated structure
    calInputStruct.twoDBlackIds = twoDBlackIds;
end

%--------------------------------------------------------------------------
% ldeUndershoot pixel rows and columns
%--------------------------------------------------------------------------
if (availableldeUndershootIds)
    % extract pixels
    ldeUndershootIds = calInputStruct.ldeUndershootIds;

    % increment the rows and columns for the ldeUndershootIds; this is a little
    % different than the cases above because the sizes of the ldeUndershoot
    % regions do not have to be uniform
    ldeUndershootIdsRowsCellArray = arrayfun(@(x) x.rows - 1, ldeUndershootIds, ...
        'UniformOutput', false);
    [ldeUndershootIds(1:length(ldeUndershootIdsRowsCellArray)).rows] = ...
        ldeUndershootIdsRowsCellArray{:};

    ldeUndershootIdsColsCellArray = arrayfun(@(x) x.cols - 1, ldeUndershootIds, ...
        'UniformOutput', false);
    [ldeUndershootIds(1:length(ldeUndershootIdsColsCellArray)).cols] = ...
        ldeUndershootIdsColsCellArray{:};

    % save updated structure
    calInputStruct.ldeUndershootIds = ldeUndershootIds;
end


return;
