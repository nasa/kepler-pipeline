function calOutputStruct = convert_cal_outputs_to_0_base(calOutputStruct)
%function calOutputStruct = convert_cal_outputs_to_0_base(calOutputStruct)
%
% function to convert all row/column outputs from matlab 1-based to
% java 0-based indices by subtracting '1' from all available rows/columns
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


% start clock
tic;
metricsKey = metrics_interval_start;

%--------------------------------------------------------------------------
% calOutputStruct.targetAndBackgroundPixels.row
%--------------------------------------------------------------------------
if ~isempty(calOutputStruct.targetAndBackgroundPixels)
    % extract pixels
    targetAndBackgroundPixels = calOutputStruct.targetAndBackgroundPixels;
    % combine pixel rows and subtract 1 from each value
    rowCorrected = [targetAndBackgroundPixels.row] - 1;
    % convert 2D arrays to cell arrays
    rowCorrectedCellArray = num2cell(rowCorrected);
    % deal 0-based values back into struct arrays
    [targetAndBackgroundPixels(1:length(rowCorrectedCellArray)).row] = ...
        deal(rowCorrectedCellArray{:});
    % save updated structure
    calOutputStruct.targetAndBackgroundPixels = targetAndBackgroundPixels;
end


%--------------------------------------------------------------------------
% calOutputStruct.targetAndBackgroundPixels.column
%--------------------------------------------------------------------------
if ~isempty(calOutputStruct.targetAndBackgroundPixels)
    % extract pixels
    targetAndBackgroundPixels = calOutputStruct.targetAndBackgroundPixels;
    % combine pixel cols and subtract 1 from each value
    colCorrected = [targetAndBackgroundPixels.column] - 1;
    % convert 2D arrays to cell arrays
    colCorrectedCellArray = num2cell(colCorrected);
    % deal 0-based values back into struct arrays
    [targetAndBackgroundPixels(1:length(colCorrectedCellArray)).column] = ...
        deal(colCorrectedCellArray{:});
    % save updated structure
    calOutputStruct.targetAndBackgroundPixels = targetAndBackgroundPixels;
end


%--------------------------------------------------------------------------
% calOutputStruct.calibratedCollateralPixels.blackResidual.row
%--------------------------------------------------------------------------

% extract calibratedCollateralPixels struct
calibratedCollateralPixels = calOutputStruct.calibratedCollateralPixels;


if ~isempty(calibratedCollateralPixels.blackResidual)
    % extract pixels
    blackResidual = calibratedCollateralPixels.blackResidual;
    % combine pixel row/col and subtract 1 from each value
    rowCorrected = [blackResidual.row] - 1;
    % convert 2D arrays to cell arrays
    rowCorrectedCellArray = num2cell(rowCorrected);
    % deal 0-based values back into struct arrays
    [blackResidual(1:length(rowCorrectedCellArray)).row] = ...
        deal(rowCorrectedCellArray{:});
    % save updated structure
    calibratedCollateralPixels.blackResidual = blackResidual;
end


%--------------------------------------------------------------------------
% calOutputStruct.calibratedCollateralPixels.maskedSmear.column
%--------------------------------------------------------------------------

if ~isempty(calibratedCollateralPixels.maskedSmear)
    % extract pixels
    maskedSmear = calibratedCollateralPixels.maskedSmear;
    % combine pixel row/col and subtract 1 from each value
    columnCorrected = [maskedSmear.column] - 1;
    % convert 2D arrays to cell arrays
    columnCorrectedCellArray = num2cell(columnCorrected);
    % deal 0-based values back into struct arrays
    [maskedSmear(1:length(columnCorrectedCellArray)).column] = ...
        deal(columnCorrectedCellArray{:});
    % save updated structure
    calibratedCollateralPixels.maskedSmear = maskedSmear;
end


%--------------------------------------------------------------------------
% calOutputStruct.calibratedCollateralPixels.virtualSmear.column
%--------------------------------------------------------------------------


if ~isempty(calibratedCollateralPixels.virtualSmear)
    % extract pixels
    virtualSmear = calibratedCollateralPixels.virtualSmear;
    % combine pixel row/col and subtract 1 from each value
    columnCorrected = [virtualSmear.column] - 1;
    % convert 2D arrays to cell arrays
    columnCorrectedCellArray = num2cell(columnCorrected);
    % deal 0-based values back into struct arrays
    [virtualSmear(1:length(columnCorrectedCellArray)).column] = ...
        deal(columnCorrectedCellArray{:});
    % save updated structure
    calibratedCollateralPixels.virtualSmear = virtualSmear;
end

% add calibratedCollateralPixels back into output struct
calOutputStruct.calibratedCollateralPixels = calibratedCollateralPixels;


%--------------------------------------------------------------------------
% calOutputStruct.cosmicRayEvents.black.rowOrColumn
%--------------------------------------------------------------------------

% extract cosmicRayEvents struct
cosmicRayEvents = calOutputStruct.cosmicRayEvents;

if ~isempty(cosmicRayEvents.black)
    % extract pixels
    black = cosmicRayEvents.black;
    % combine pixel row/col and subtract 1 from each value
    rowOrColumnCorrected = [black.rowOrColumn] - 1;
    % convert 2D arrays to cell arrays
    rowOrColumnCorrectedCellArray = num2cell(rowOrColumnCorrected);
    % deal 0-based values back into struct arrays
    [black(1:length(rowOrColumnCorrectedCellArray)).rowOrColumn] = ...
        deal(rowOrColumnCorrectedCellArray{:});
    % save updated structure
    cosmicRayEvents.black = black;
end


%--------------------------------------------------------------------------
% calOutputStruct.cosmicRayEvents.maskedBlack.rowOrColumn
%--------------------------------------------------------------------------

if ~isempty(cosmicRayEvents.maskedBlack)
    % extract pixels
    maskedBlack = cosmicRayEvents.maskedBlack;
    % combine pixel row/col and subtract 1 from each value
    rowOrColumnCorrected = [maskedBlack.rowOrColumn] - 1;
    % convert 2D arrays to cell arrays
    rowOrColumnCorrectedCellArray = num2cell(rowOrColumnCorrected);
    % deal 0-based values back into struct arrays
    [maskedBlack(1:length(rowOrColumnCorrectedCellArray)).rowOrColumn] = ...
        deal(rowOrColumnCorrectedCellArray{:});
    % save updated structure
    cosmicRayEvents.maskedBlack = maskedBlack;
end


%--------------------------------------------------------------------------
% calOutputStruct.cosmicRayEvents.virtualBlack.rowOrColumn
%--------------------------------------------------------------------------


if ~isempty(cosmicRayEvents.virtualBlack)
    % extract pixels
    virtualBlack = cosmicRayEvents.virtualBlack;
    % combine pixel row/col and subtract 1 from each value
    rowOrColumnCorrected = [virtualBlack.rowOrColumn] - 1;
    % convert 2D arrays to cell arrays
    rowOrColumnCorrectedCellArray = num2cell(rowOrColumnCorrected);
    % deal 0-based values back into struct arrays
    [virtualBlack(1:length(rowOrColumnCorrectedCellArray)).rowOrColumn] = ...
        deal(rowOrColumnCorrectedCellArray{:});
    % save updated structure
    cosmicRayEvents.virtualBlack = virtualBlack;
end


%--------------------------------------------------------------------------
% calOutputStruct.cosmicRayEvents.maskedSmear.rowOrColumn
%--------------------------------------------------------------------------

if ~isempty(cosmicRayEvents.maskedSmear)
    % extract pixels
    maskedSmear = cosmicRayEvents.maskedSmear;
    % combine pixel row/col and subtract 1 from each value
    rowOrColumnCorrected = [maskedSmear.rowOrColumn] - 1;
    % convert 2D arrays to cell arrays
    rowOrColumnCorrectedCellArray = num2cell(rowOrColumnCorrected);
    % deal 0-based values back into struct arrays
    [maskedSmear(1:length(rowOrColumnCorrectedCellArray)).rowOrColumn] = ...
        deal(rowOrColumnCorrectedCellArray{:});
    % save updated structure
    cosmicRayEvents.maskedSmear = maskedSmear;
end


%--------------------------------------------------------------------------
% calOutputStruct.cosmicRayEvents.virtualSmear.rowOrColumn
%--------------------------------------------------------------------------
if ~isempty(cosmicRayEvents.virtualSmear)
    % extract pixels
    virtualSmear = cosmicRayEvents.virtualSmear;
    % combine pixel row/col and subtract 1 from each value
    rowOrColumnCorrected = [virtualSmear.rowOrColumn] - 1;
    % convert 2D arrays to cell arrays
    rowOrColumnCorrectedCellArray = num2cell(rowOrColumnCorrected);
    % deal 0-based values back into struct arrays
    [virtualSmear(1:length(rowOrColumnCorrectedCellArray)).rowOrColumn] = ...
        deal(rowOrColumnCorrectedCellArray{:});
    % save updated structure
    cosmicRayEvents.virtualSmear = virtualSmear;
end


% add cosmicRayEvents back into output struct
calOutputStruct.cosmicRayEvents = cosmicRayEvents;

display_cal_status('CAL:cal_matlab_controller: Outputs converted to Java 0-based indexing', 1);
metrics_interval_stop('cal.convert_cal_outputs_to_0_base.execTimeMillis',metricsKey);