function [calOutputStruct] = validate_cal_outputs(calOutputStruct, processFFI)
%function [calOutputStruct] = validate_cal_outputs(calOutputStruct, processFFI)
%
% This method checks for the presence of expected fields in the output structure,
% then checks whether each parameter is within the appropriate range.
%
%--------------------------------------------------------------------------
% validate outputs and check fields and bounds
% (1) check for the presence of all fields
% (2) check whether the parameters are within bounds and are not NaNs/Infs
%
% Note: if fields are structures, make sure their bounds are empty
%
% Comments: This function generates an error under the following scenarios:
%          (1) when any of the essential fields are missing
%          (2) when any of the fields are NaNs/Infs or outside the appropriate bounds
%
%
% If processFFI flag is enabled, the photometric pixel validation will be
% skipped over.
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

tic

% set warning flag, where true produces warnings if any validation fails,
% otherwise errors are produced
warningInsteadOfErrorFlag = true;

% Set upper/lower bounds for flux/uncertainties (values set here will be
% '<= maxValue' and '>= minValue', where maxValue and minValue are set as
% follows:
%--------------------------------------------------------------------------
% set limits for target/background
%--------------------------------------------------------------------------
maxPhotFluxInElectrons = 1e9;
minPhotFluxInElectrons = -1e8;

maxPhotFluxUncertInElectrons = 1e9;
minPhotFluxUncertInElectrons = 0;

%--------------------------------------------------------------------------
% set limits for calibrated black
%--------------------------------------------------------------------------
maxCalibBlackInAdu = 1e9;
minCalibBlackInAdu = -1e8;

maxCalibBlackUncertInAdu  = 1e9;
minCalibBlackUncertInAdu  = -1e8;

%--------------------------------------------------------------------------
% set limits for calibrated masked black
%--------------------------------------------------------------------------
maxCalibMblackInAdu = 1e9;
minCalibMblackInAdu = -1e8;

maxCalibMblackUncertInAdu  = 1e9;
minCalibMblackUncertInAdu  = -1e8;

%--------------------------------------------------------------------------
% set limits for calibrated masked black
%--------------------------------------------------------------------------
maxCalibVblackInAdu = 1e9;
minCalibVblackInAdu = -1e8;

maxCalibVblackUncertInAdu  = 1e9;
minCalibVblackUncertInAdu  = -1e8;

%--------------------------------------------------------------------------
% set limits for calibrated masked smear
%--------------------------------------------------------------------------
maxCalibMsmearInElectrons = 1e9;
minCalibMsmearInElectrons = -1e8;

maxCalibMsmearUncertInElectrons = 1e9;
minCalibMsmearUncertInElectrons = -1e8;

%--------------------------------------------------------------------------
% set limits for calibrated virtual smear
%--------------------------------------------------------------------------
maxCalibVsmearInElectrons = 1e9;
minCalibVsmearInElectrons = -1e8;

maxCalibVsmearUncertInElectrons = 1e9;
minCalibVsmearUncertInElectrons = -1e8;

%--------------------------------------------------------------------------
% convert values to strings for validate_structs or validate_time_series
%--------------------------------------------------------------------------
maxPhotFluxInElectronsStr = sprintf('<= %d', maxPhotFluxInElectrons);
minPhotFluxInElectronsStr = sprintf('>= %d', minPhotFluxInElectrons);
maxPhotFluxUncertInElectronsStr = sprintf('<= %d', maxPhotFluxUncertInElectrons);
minPhotFluxUncertInElectronsStr = sprintf('>= %d', minPhotFluxUncertInElectrons);

maxCalibBlackInAduStr = sprintf('<= %d', maxCalibBlackInAdu);
minCalibBlackInAduStr = sprintf('>= %d', minCalibBlackInAdu);
maxCalibBlackUncertInAduStr = sprintf('<= %d', maxCalibBlackUncertInAdu);
minCalibBlackUncertInAduStr = sprintf('>= %d', minCalibBlackUncertInAdu);

maxCalibMblackInAduStr = sprintf('<= %d', maxCalibMblackInAdu);
minCalibMblackInAduStr = sprintf('>= %d', minCalibMblackInAdu);
maxCalibMblackUncertInAduStr = sprintf('<= %d', maxCalibMblackUncertInAdu);
minCalibMblackUncertInAduStr = sprintf('>= %d', minCalibMblackUncertInAdu);

maxCalibVblackInAduStr = sprintf('<= %d', maxCalibVblackInAdu);
minCalibVblackInAduStr = sprintf('>= %d', minCalibVblackInAdu);
maxCalibVblackUncertInAduStr = sprintf('<= %d', maxCalibVblackUncertInAdu);
minCalibVblackUncertInAduStr = sprintf('>= %d', minCalibVblackUncertInAdu);

maxCalibMsmearInElectronsStr = sprintf('<= %d', maxCalibMsmearInElectrons);
minCalibMsmearInElectronsStr = sprintf('>= %d', minCalibMsmearInElectrons);
maxCalibMsmearUncertInElectronsStr = sprintf('<= %d', maxCalibMsmearUncertInElectrons);
minCalibMsmearUncertInElectronsStr = sprintf('>= %d', minCalibMsmearUncertInElectrons);

maxCalibVsmearInElectronsStr = sprintf('<= %d', maxCalibVsmearInElectrons);
minCalibVsmearInElectronsStr = sprintf('>= %d', minCalibVsmearInElectrons);
maxCalibVsmearUncertInElectronsStr = sprintf('<= %d', maxCalibVsmearUncertInElectrons);
minCalibVsmearUncertInElectronsStr = sprintf('>= %d', minCalibVsmearUncertInElectrons);

%--------------------------------------------------------------------------
% validate all fields in top level
%--------------------------------------------------------------------------
fieldsAndBounds = cell(9,4);
fieldsAndBounds(1,:)  = { 'calibratedCollateralPixels'; []; []; []};
fieldsAndBounds(2,:)  = { 'targetAndBackgroundPixels'; []; []; []};
fieldsAndBounds(3,:)  = { 'cosmicRayEvents'; []; []; []};
fieldsAndBounds(4,:)  = { 'cosmicRayMetrics'; []; []; []};
fieldsAndBounds(5,:)  = { 'collateralMetrics'; []; []; []};
fieldsAndBounds(6,:)  = { 'theoreticalCompressionEfficiency'; []; []; []};
fieldsAndBounds(7,:)  = { 'achievedCompressionEfficiency'; []; []; []};
fieldsAndBounds(8,:)  = { 'ldeUndershootMetrics'; []; []; []};
fieldsAndBounds(9,:)  = { 'twoDBlackMetrics'; []; []; []};
%fieldsAndBounds(10,:)  = { 'uncertaintyBlobFileName'; []; []; []};

validate_structure(calOutputStruct, fieldsAndBounds,'calOutputStruct');

clear fieldsAndBounds;


%--------------------------------------------------------------------------
% validate 2nd-level calibratedCollateralPixels struct.  The short cadence
% masked/virtual black structs should not be empty (regardless of the pixel
% type that was processed) since they contain an 'exists' field which must
% be set to zero
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'blackResidual'; []; []; []};
fieldsAndBounds(2,:)  = { 'maskedBlackResidual'; []; []; []};
fieldsAndBounds(3,:)  = { 'virtualBlackResidual'; []; []; []};
fieldsAndBounds(4,:)  = { 'maskedSmear'; []; []; []};
fieldsAndBounds(5,:)  = { 'virtualSmear'; []; []; []};

validate_structure(calOutputStruct.calibratedCollateralPixels, ...
    fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels');

clear fieldsAndBounds;


%------------------------------------------------------------
% validate 3rd-level blackResidual struct if available; these fields will be
% present for collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.calibratedCollateralPixels.blackResidual)

    % validate row/columns using validate_structure
    fieldsAndBounds = cell(1,4);
    fieldsAndBounds(1,:)  = { 'row';'>= -1';'<= 1200'; []};

    nStructures = length(calOutputStruct.calibratedCollateralPixels.blackResidual);

    for j = 1:nStructures
        validate_structure(calOutputStruct.calibratedCollateralPixels.blackResidual(j), ...
            fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.blackResidual');
    end

    clear fieldsAndBounds;
end

if ~isempty(calOutputStruct.calibratedCollateralPixels.blackResidual) && ~processFFI

    % validate time series using validate_time_series_structure
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; minCalibBlackInAduStr; maxCalibBlackInAduStr; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties'; minCalibBlackUncertInAduStr; maxCalibBlackUncertInAduStr; []};

    nStructures = length(calOutputStruct.calibratedCollateralPixels.blackResidual);

    for j = 1:nStructures
        validate_time_series_structure(calOutputStruct.calibratedCollateralPixels.blackResidual(j), ...
            fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.blackResidual', warningInsteadOfErrorFlag);
    end

    clear fieldsAndBounds;
end


%------------------------------------------------------------
% validate 3rd-level maskedBlackResidual struct
%------------------------------------------------------------
if calOutputStruct.calibratedCollateralPixels.maskedBlackResidual.exists

    % validate 'exists' using validate_structure
    fieldsAndBounds = cell(1,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};

    validate_structure(calOutputStruct.calibratedCollateralPixels.maskedBlackResidual, ...
        fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.maskedBlackResidual');

    clear fieldsAndBounds;

    % validate time series using validate_time_series_structure
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; minCalibMblackInAduStr; maxCalibMblackInAduStr; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties'; minCalibMblackUncertInAduStr; maxCalibMblackUncertInAduStr; []};

    validate_time_series_structure(calOutputStruct.calibratedCollateralPixels.maskedBlackResidual, ...
        fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.maskedBlackResidual', warningInsteadOfErrorFlag);

    clear fieldsAndBounds;

else
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'values'; []; []; []};
    fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; []};
    fieldsAndBounds(4,:)  = { 'uncertainties'; []; []; []};

    validate_structure(calOutputStruct.calibratedCollateralPixels.maskedBlackResidual, ...
        fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.maskedBlackResidual');

    clear fieldsAndBounds;
end


%------------------------------------------------------------
% validate 3rd-level virtualBlackResidual struct
%------------------------------------------------------------
if calOutputStruct.calibratedCollateralPixels.virtualBlackResidual.exists

    % validate 'exists' using validate_structure
    fieldsAndBounds = cell(1,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};

    validate_structure(calOutputStruct.calibratedCollateralPixels.virtualBlackResidual, ...
        fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.virtualBlackResidual');

    clear fieldsAndBounds;

    % validate time series using validate_time_series_structure
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; minCalibVblackInAduStr; maxCalibVblackInAduStr; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties'; minCalibVblackUncertInAduStr; maxCalibVblackUncertInAduStr; []};

    validate_time_series_structure(calOutputStruct.calibratedCollateralPixels.virtualBlackResidual, ...
        fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.virtualBlackResidual', warningInsteadOfErrorFlag);

    clear fieldsAndBounds;

else
    fieldsAndBounds = cell(4,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'values'; []; []; []};
    fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; []};
    fieldsAndBounds(4,:)  = { 'uncertainties'; []; []; []};

    validate_structure(calOutputStruct.calibratedCollateralPixels.virtualBlackResidual, ...
        fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.virtualBlackResidual');

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level maskedSmear field if available; these fields will be
% present for collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.calibratedCollateralPixels.maskedSmear) && ~processFFI

    % validate row/columns using validate_structure
    fieldsAndBounds = cell(1,4);
    fieldsAndBounds(1,:)  = { 'column';'>= -1';'<= 1200'; []};

    nStructures = length(calOutputStruct.calibratedCollateralPixels.maskedSmear);

    for j = 1:nStructures
        validate_structure(calOutputStruct.calibratedCollateralPixels.maskedSmear(j), ...
            fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.maskedSmear');
    end

    clear fieldsAndBounds;

    % validate time series using validate_time_series_structure
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; minCalibMsmearInElectronsStr; maxCalibMsmearInElectronsStr; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties'; minCalibMsmearUncertInElectronsStr; maxCalibMsmearUncertInElectronsStr; []};

    nStructures = length(calOutputStruct.calibratedCollateralPixels.maskedSmear);

    for j = 1:nStructures
        validate_time_series_structure(calOutputStruct.calibratedCollateralPixels.maskedSmear(j), ...
            fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.maskedSmear', warningInsteadOfErrorFlag);
    end

    clear fieldsAndBounds;
end


%------------------------------------------------------------
% validate 3rd-level virtualSmear field if available; these fields will be
% present for collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.calibratedCollateralPixels.virtualSmear) && ~processFFI

    % validate row/columns using validate_structure
    fieldsAndBounds = cell(1,4);
    fieldsAndBounds(1,:)  = { 'column';'>= -1';'<= 1200'; []};

    nStructures = length(calOutputStruct.calibratedCollateralPixels.virtualSmear);

    for j = 1:nStructures
        validate_structure(calOutputStruct.calibratedCollateralPixels.virtualSmear(j), ...
            fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.virtualSmear');
    end

    clear fieldsAndBounds;

    % validate time series using validate_time_series_structure
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; minCalibVsmearInElectronsStr; maxCalibVsmearInElectronsStr; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties'; minCalibVsmearUncertInElectronsStr; maxCalibVsmearUncertInElectronsStr; []};

    nStructures = length(calOutputStruct.calibratedCollateralPixels.virtualSmear);

    for j = 1:nStructures
        validate_time_series_structure(calOutputStruct.calibratedCollateralPixels.virtualSmear(j), ...
            fieldsAndBounds,'calOutputStruct.calibratedCollateralPixels.virtualSmear', warningInsteadOfErrorFlag);
    end

    clear fieldsAndBounds;
end



%--------------------------------------------------------------------------
% validate 2nd-level targetAndBackgroundPixels struct if available; these
% fields will be present for photometric output data only.  If processing
% FFIs, this pixel value validation will be skipped over.
%--------------------------------------------------------------------------
if ~isempty(calOutputStruct.targetAndBackgroundPixels) && ~processFFI

    % validate row/columns using validate_structure
    fieldsAndBounds = cell(2,4);
    fieldsAndBounds(1,:)  = { 'column';'>= -1';'<= 1200'; []};
    fieldsAndBounds(2,:)  = { 'row';'>= -1';'<= 1200'; []};

    nStructures = length(calOutputStruct.targetAndBackgroundPixels);

    for j = 1:nStructures
        validate_structure(calOutputStruct.targetAndBackgroundPixels(j), ...
            fieldsAndBounds,'calOutputStruct.targetAndBackgroundPixels');
    end

    clear fieldsAndBounds;

    % validate time series using validate_time_series_structure
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; minPhotFluxInElectronsStr; maxPhotFluxInElectronsStr; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'uncertainties'; minPhotFluxUncertInElectronsStr; maxPhotFluxUncertInElectronsStr; []};

    nStructures = length(calOutputStruct.targetAndBackgroundPixels);

    for j = 1:nStructures  %validate only non-gapped data in time series
        validate_time_series_structure(calOutputStruct.targetAndBackgroundPixels(j), ...
            fieldsAndBounds,'calOutputStruct.targetAndBackgroundPixels', warningInsteadOfErrorFlag);
    end

    clear fieldsAndBounds;
end


%------------------------------------------------------------
% validate 2nd-level cosmicRayEvents struct
%------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'black'; []; []; []};
fieldsAndBounds(2,:)  = { 'maskedBlack'; []; []; []};
fieldsAndBounds(3,:)  = { 'virtualBlack'; []; []; []};
fieldsAndBounds(4,:)  = { 'maskedSmear'; []; []; []};
fieldsAndBounds(5,:)  = { 'virtualSmear'; []; []; []};

validate_structure(calOutputStruct.cosmicRayEvents, ...
    fieldsAndBounds,'calOutputStruct.cosmicRayEvents');

clear fieldsAndBounds;



%------------------------------------------------------------
% validate 3rd-level cosmicRayEvents.black struct if available; these fields
% will be present for collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.cosmicRayEvents.black)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'delta'; []; []; []};
    fieldsAndBounds(2,:)  = { 'rowOrColumn';'>= -1';'<= 1200'; []};
    fieldsAndBounds(3,:)  = { 'mjd'; '> 54000'; '< 64000'; []};

    nStructures = length(calOutputStruct.cosmicRayEvents.black);

    for j = 1:nStructures
        validate_structure(calOutputStruct.cosmicRayEvents.black(j), ...
            fieldsAndBounds,'calOutputStruct.cosmicRayEvents.black');
    end

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level cosmicRayEvents.maskedSmear struct if available;
% these fields will be present for collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.cosmicRayEvents.maskedSmear)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'delta'; []; []; []};
    fieldsAndBounds(2,:)  = { 'rowOrColumn';'>= -1';'<= 1200'; []};
    fieldsAndBounds(3,:)  = { 'mjd'; '> 54000'; '< 64000'; []};

    nStructures = length(calOutputStruct.cosmicRayEvents.maskedSmear);

    for j = 1:nStructures
        validate_structure(calOutputStruct.cosmicRayEvents.maskedSmear(j), ...
            fieldsAndBounds,'calOutputStruct.cosmicRayEvents.maskedSmear');
    end

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level cosmicRayEvents.virtualSmear struct if available; these
% fields will be present for collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.cosmicRayEvents.virtualSmear)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'delta'; []; []; []};
    fieldsAndBounds(2,:)  = { 'rowOrColumn';'>= -1';'<= 1200'; []};
    fieldsAndBounds(3,:)  = { 'mjd'; '> 54000'; '< 64000'; []};

    nStructures = length(calOutputStruct.cosmicRayEvents.virtualSmear);

    for j = 1:nStructures
        validate_structure(calOutputStruct.cosmicRayEvents.virtualSmear(j), ...
            fieldsAndBounds,'calOutputStruct.cosmicRayEvents.virtualSmear');
    end

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level cosmicRayEvents.maskedBlack struct if available; these
% fields will be present for short-cadence collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.cosmicRayEvents.maskedBlack)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'delta'; []; []; []};
    fieldsAndBounds(2,:)  = { 'rowOrColumn';'>= -1';'<= 1200'; []};
    fieldsAndBounds(3,:)  = { 'mjd'; '> 54000'; '< 64000'; []};

    nStructures = length(calOutputStruct.cosmicRayEvents.maskedBlack);

    for j = 1:nStructures
        validate_structure(calOutputStruct.cosmicRayEvents.maskedBlack(j), ...
            fieldsAndBounds,'calOutputStruct.cosmicRayEvents.maskedBlack');
    end

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level cosmicRayEvents.virtualBlack struct if available; these
% fields will be present for short-cadence collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.cosmicRayEvents.virtualBlack)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'delta'; []; []; []};
    fieldsAndBounds(2,:)  = { 'rowOrColumn';'>= -1';'<= 1200'; []};
    fieldsAndBounds(3,:)  = { 'mjd'; '> 54000'; '< 64000'; []};

    nStructures = length(calOutputStruct.cosmicRayEvents.virtualBlack);

    for j = 1:nStructures
        validate_structure(calOutputStruct.cosmicRayEvents.virtualBlack(j), ...
            fieldsAndBounds,'calOutputStruct.cosmicRayEvents.virtualBlack');
    end

    clear fieldsAndBounds;
end



%------------------------------------------------------------
% validate 2nd-level cosmicRayMetrics struct
%------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'blackCosmicRayMetrics'; []; []; []};
fieldsAndBounds(2,:)  = { 'maskedBlackCosmicRayMetrics'; []; []; []};
fieldsAndBounds(3,:)  = { 'virtualBlackCosmicRayMetrics'; []; []; []};
fieldsAndBounds(4,:)  = { 'maskedSmearCosmicRayMetrics'; []; []; []};
fieldsAndBounds(5,:)  = { 'virtualSmearCosmicRayMetrics'; []; []; []};

validate_structure(calOutputStruct.cosmicRayMetrics, ...
    fieldsAndBounds,'calOutputStruct.cosmicRayMetrics');

clear fieldsAndBounds;


%------------------------------------------------------------
% validate 3rd-level blackCosmicRayMetrics struct; these fields are present
% in all CAL output structs since there is an 'exists' scalar field
%------------------------------------------------------------
if calOutputStruct.cosmicRayMetrics.blackCosmicRayMetrics.exists
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; [true, false]};

    validate_structure(calOutputStruct.cosmicRayMetrics.blackCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.blackCosmicRayMetrics');

    clear fieldsAndBounds;
else
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; []};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; []};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; []};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; []};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; []};

    validate_structure(calOutputStruct.cosmicRayMetrics.blackCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.blackCosmicRayMetrics');

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level maskedBlackCosmicRayMetrics struct; these fields are present
% in all CAL output structs since there is an 'exists' scalar field
%------------------------------------------------------------
if calOutputStruct.cosmicRayMetrics.maskedBlackCosmicRayMetrics.exists
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; [true, false]};

    validate_structure(calOutputStruct.cosmicRayMetrics.maskedBlackCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.maskedBlackCosmicRayMetrics');

    clear fieldsAndBounds;
else
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; []};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; []};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; []};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; []};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; []};

    validate_structure(calOutputStruct.cosmicRayMetrics.maskedBlackCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.maskedBlackCosmicRayMetrics');

    clear fieldsAndBounds;
end


%------------------------------------------------------------
% validate 3rd-level virtualBlackCosmicRayMetrics struct; these fields are present
% in all CAL output structs since there is an 'exists' scalar field
%------------------------------------------------------------
if calOutputStruct.cosmicRayMetrics.virtualBlackCosmicRayMetrics.exists
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; [true, false]};

    validate_structure(calOutputStruct.cosmicRayMetrics.virtualBlackCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.virtualBlackCosmicRayMetrics');

    clear fieldsAndBounds;
else
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; []};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; []};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; []};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; []};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; []};

    validate_structure(calOutputStruct.cosmicRayMetrics.virtualBlackCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.virtualBlackCosmicRayMetrics');

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level maskedSmearCosmicRayMetrics struct; these fields are present
% in all CAL output structs since there is an 'exists' scalar field
%------------------------------------------------------------
if calOutputStruct.cosmicRayMetrics.maskedSmearCosmicRayMetrics.exists
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; [true, false]};

    validate_structure(calOutputStruct.cosmicRayMetrics.maskedSmearCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.maskedSmearCosmicRayMetrics');

    clear fieldsAndBounds;
else
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; []};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; []};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; []};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; []};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; []};

    validate_structure(calOutputStruct.cosmicRayMetrics.maskedSmearCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.maskedSmearCosmicRayMetrics');

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level virtualSmearCosmicRayMetrics struct; these fields are present
% in all CAL output structs since there is an 'exists' scalar field
%------------------------------------------------------------
if calOutputStruct.cosmicRayMetrics.virtualSmearCosmicRayMetrics.exists
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; [true, false]};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; [true, false]};

    validate_structure(calOutputStruct.cosmicRayMetrics.virtualSmearCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.virtualSmearCosmicRayMetrics');

    clear fieldsAndBounds;
else
    fieldsAndBounds = cell(11,4);
    fieldsAndBounds(1,:)  = { 'exists'; []; []; [true, false]};
    fieldsAndBounds(2,:)  = { 'hitRates'; []; []; []};
    fieldsAndBounds(3,:)  = { 'hitRateGapIndicators'; []; []; []};
    fieldsAndBounds(4,:)  = { 'meanEnergy'; []; []; []};
    fieldsAndBounds(5,:)  = { 'meanEnergyGapIndicators'; []; []; []};
    fieldsAndBounds(6,:)  = { 'energyVariance'; []; []; []};
    fieldsAndBounds(7,:)  = { 'energyVarianceGapIndicators'; []; []; []};
    fieldsAndBounds(8,:)  = { 'energySkewness'; []; []; []};
    fieldsAndBounds(9,:)  = { 'energySkewnessGapIndicators'; []; []; []};
    fieldsAndBounds(10,:)  = { 'energyKurtosis'; []; []; []};
    fieldsAndBounds(11,:)  = { 'energyKurtosisGapIndicators'; []; []; []};

    validate_structure(calOutputStruct.cosmicRayMetrics.virtualSmearCosmicRayMetrics, ...
        fieldsAndBounds,'calOutputStruct.cosmicRayMetrics.virtualSmearCosmicRayMetrics');

    clear fieldsAndBounds;
end


%------------------------------------------------------------
% validate 2nd-level collateralMetrics struct
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'blackLevelMetrics'; []; []; []};
fieldsAndBounds(2,:)  = { 'smearLevelMetrics'; []; []; []};
fieldsAndBounds(3,:)  = { 'darkCurrentMetrics'; []; []; []};

validate_structure(calOutputStruct.collateralMetrics, ...
    fieldsAndBounds,'calOutputStruct.collateralMetrics');

clear fieldsAndBounds;


%------------------------------------------------------------
% validate 3rd-level blackLevelMetrics struct if available; these
% fields will be present for collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.collateralMetrics.blackLevelMetrics.values)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values';'>= -1e8'; '<=1e9'; []};
    fieldsAndBounds(2,:)  = { 'uncertainties';  '>= -1'; '<= 1e5'; []};
    fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true, false]};

    validate_time_series_structure(calOutputStruct.collateralMetrics.blackLevelMetrics, ...
        fieldsAndBounds,'calOutputStruct.collateralMetrics.blackLevelMetrics', warningInsteadOfErrorFlag);

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level smearLevelMetrics struct if available; these
% fields will be present for collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.collateralMetrics.smearLevelMetrics.values)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values';'>= -1e8'; '<=1e9'; []};
    fieldsAndBounds(2,:)  = { 'uncertainties';  '>= -1'; '<= 1e5'; []};
    fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true, false]};

    validate_time_series_structure(calOutputStruct.collateralMetrics.smearLevelMetrics, ...
        fieldsAndBounds,'calOutputStruct.collateralMetrics.smearLevelMetrics', warningInsteadOfErrorFlag);

    clear fieldsAndBounds;
end

%------------------------------------------------------------
% validate 3rd-level darkCurrentMetrics struct if available; these
% fields will be present for collateral output data only
%------------------------------------------------------------
if ~isempty(calOutputStruct.collateralMetrics.darkCurrentMetrics.values)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values';'>= -1e8'; '<=1e9'; []};
    fieldsAndBounds(2,:)  = { 'uncertainties';  '>= -1'; '<= 1e6'; []};
    fieldsAndBounds(3,:)  = { 'gapIndicators'; []; []; [true, false]};

    validate_time_series_structure(calOutputStruct.collateralMetrics.darkCurrentMetrics, ...
        fieldsAndBounds,'calOutputStruct.collateralMetrics.darkCurrentMetrics', warningInsteadOfErrorFlag);

    clear fieldsAndBounds;
end


%------------------------------------------------------------
% validate 2nd-level theoreticalCompressionEfficiency struct
%------------------------------------------------------------
if ~isempty(calOutputStruct.theoreticalCompressionEfficiency.values)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; []; []; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'nCodeSymbols'; []; []; []};

    validate_structure(calOutputStruct.theoreticalCompressionEfficiency, ...
        fieldsAndBounds,'calOutputStruct.theoreticalCompressionEfficiency');

    clear fieldsAndBounds;
end


%------------------------------------------------------------
% validate 2nd-level achievedCompressionEfficiency struct
%------------------------------------------------------------
if ~isempty(calOutputStruct.achievedCompressionEfficiency.values)
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'values'; []; []; []};
    fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
    fieldsAndBounds(3,:)  = { 'nCodeSymbols'; []; []; []};

    validate_structure(calOutputStruct.achievedCompressionEfficiency, ...
        fieldsAndBounds,'calOutputStruct.achievedCompressionEfficiency');

    clear fieldsAndBounds;
end


%------------------------------------------------------------
% validate 2nd-level ldeUndershootMetrics
%------------------------------------------------------------
% This field is computed in the controller after collateral/photometric
% pixel calibration is complete

%------------------------------------------------------------
% validate 2nd-level twoDBlackMetrics
%------------------------------------------------------------
% This field is computed in the controller after collateral/photometric
% pixel calibration is complete

return;
