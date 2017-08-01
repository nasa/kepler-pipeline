function [calIntermediateStruct] = get_config_map_parameters(calObject, calIntermediateStruct)
%function [calIntermediateStruct] = get_config_map_parameters(calObject, calIntermediateStruct)
%
% This calClass method collects relevant parameters from the spacecraft config map for use in CAL. The config map is not expected to change
% for a given mod/out and unit of work however, we allow for the possibility of time dependence. If the min = max, then only a scalar
% value is saved. Otherwise the full time array is saved to the intermediate struct. The noise model and gain model are also read from the
% calObject and attached to calIntermediateStruct.
%
% The following parameters are read from the spacecraft config map:
%   requantTableFixedOffsets  LC or SC data
%   blackColumnStart        beginning column of trailing black coadd
%   blackColumnEnd          ending column of trailing black coadd
%   mSmearRowStart          beginning row of masked smear coadd
%   mSmearRowEnd            ending row of masked smear coadd
%   vSmearRowStart          beginning row of virtual smear coadd
%   vSmearRowEnd            ending row of virtual smear coadd
%   ccdReadTime             CCD readout time (s)
%   ccdExposureTime         CCD exposure time (s)
%   numberOfExposures       number of coadded exposures
%
% These values are calculated from the spacecraft config map parameters:
%   numberOfBlackColumns        number of spatially co-added columns
%   numberOfMaskedSmearRows     number of spatially co-added rows
%   numberOfVirtualSmearRows    number of spatially co-added rows
%   numberOfMaskedBlackPixels
%   numberOfVirtualBlackPixels
% 
% These value are retrieved from the readNoise and gain models:
%   readNoiseInADU
%   gain
%
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

% extract data flags
processLongCadence   = calObject.dataFlags.processLongCadence;
processShortCadence  = calObject.dataFlags.processShortCadence;
processFFI           = calObject.dataFlags.processFFI;

% extract mod/out
ccdModule = calObject.ccdModule;
ccdOutput = calObject.ccdOutput;

% extract timestamp (mjds)
timestamp               = calObject.cadenceTimes.timestamp;
timestampGapIndicators  = calObject.cadenceTimes.gapIndicators;

% extract config maps
spacecraftConfigMap     = calObject.spacecraftConfigMap;

% create config map object
configMapObject         = configMapClass(spacecraftConfigMap);

%--------------------------------------------------------------------------
% extract fixed offset for short and long cadence
%--------------------------------------------------------------------------
if processLongCadence

    % allocate memory to extract and record the fixed offset for valid cadences
    requantTableFixedOffsets = zeros(size(timestamp));
    requantTableFixedOffsets(~timestampGapIndicators) = get_long_cadence_fixed_offset(configMapObject, timestamp(~timestampGapIndicators));

elseif processShortCadence

    requantTableFixedOffsets = zeros(size(timestamp));
    requantTableFixedOffsets(~timestampGapIndicators) = get_short_cadence_fixed_offset(configMapObject, timestamp(~timestampGapIndicators));
else
    requantTableFixedOffsets = 0;
end

% fixed offset may vary with time, so display the fixed offset value if constant, or else display the max/min values
if processLongCadence && ~processFFI

    if min(requantTableFixedOffsets(~timestampGapIndicators)) == max(requantTableFixedOffsets(~timestampGapIndicators))
        display(['CAL:get_config_map_parameters: Long cadence fixed offset is: ',num2str(mean(requantTableFixedOffsets(~timestampGapIndicators))) ]);
        % save to intermediate struct
        calIntermediateStruct.requantTableFixedOffsets = min(requantTableFixedOffsets(~timestampGapIndicators));
    else
        display(['CAL:get_config_map_parameters: Long cadence fixed offset varies with time;  min: ' ...
            num2str(min(requantTableFixedOffsets(~timestampGapIndicators))) ', max: ' ...
            num2str(max(requantTableFixedOffsets(~timestampGapIndicators))) ]);

        % save to intermediate struct
        calIntermediateStruct.requantTableFixedOffsets = requantTableFixedOffsets;
    end

elseif processShortCadence

    if min(requantTableFixedOffsets(~timestampGapIndicators)) == max(requantTableFixedOffsets(~timestampGapIndicators))
        display(['CAL:get_config_map_parameters: Short cadence fixed offset is: ',num2str(mean(requantTableFixedOffsets(~timestampGapIndicators))) ]);
        % save to intermediate struct
        calIntermediateStruct.requantTableFixedOffsets = min(requantTableFixedOffsets(~timestampGapIndicators));
    else
        display(['CAL:get_config_map_parameters: Short cadence fixed offset varies with time;  min: ' ...
            num2str(min(requantTableFixedOffsets(~timestampGapIndicators))) ', max: ' ...
            num2str(max(requantTableFixedOffsets(~timestampGapIndicators))) ]);

        % save to intermediate struct
        calIntermediateStruct.requantTableFixedOffsets = requantTableFixedOffsets;
    end
end

%--------------------------------------------------------------------------
% extract number of spatial coadds and the start and end row/cols for black,
% masked, and virtual smear regions that were spatially coadded into the black
% column, virtual smear row, or masked smear row that are inputs into CAL;
% Row/cols have already been converted to 1-based indexing in these methods
%--------------------------------------------------------------------------
blackStartColumns = zeros(size(timestamp));
[blackStartColumns(~timestampGapIndicators)]     = ...
    get_black_start_column(configMapObject, timestamp(~timestampGapIndicators));

blackEndColumns = zeros(size(timestamp));
[blackEndColumns(~timestampGapIndicators)]       = ...
    get_black_end_column(configMapObject, timestamp(~timestampGapIndicators));

maskedSmearStartRows = zeros(size(timestamp));
[maskedSmearStartRows(~timestampGapIndicators)]  = ...
    get_masked_smear_start_row(configMapObject, timestamp(~timestampGapIndicators));

maskedSmearEndRows = zeros(size(timestamp));
[maskedSmearEndRows(~timestampGapIndicators)]    = ...
    get_masked_smear_end_row(configMapObject, timestamp(~timestampGapIndicators));

virtualSmearStartRows = zeros(size(timestamp));
[virtualSmearStartRows(~timestampGapIndicators)] = ...
    get_virtual_smear_start_row(configMapObject, timestamp(~timestampGapIndicators));

virtualSmearEndRows = zeros(size(timestamp));
[virtualSmearEndRows(~timestampGapIndicators)]   = ...
    get_virtual_smear_end_row(configMapObject, timestamp(~timestampGapIndicators));


% collect above row/cols into arrays
blackColumnsArray       = [blackStartColumns blackEndColumns];
maskedSmearRowsArray    = [maskedSmearStartRows maskedSmearEndRows];
virtualSmearRowsArray   = [virtualSmearStartRows virtualSmearEndRows];


% get black columns and smear rows that were summed onboard spacecraft
blackColumnStart = blackColumnsArray(:, 1);
blackColumnEnd   = blackColumnsArray(:, 2);

mSmearRowStart = maskedSmearRowsArray(:, 1);
mSmearRowEnd   = maskedSmearRowsArray(:, 2);

vSmearRowStart = virtualSmearRowsArray(:, 1);
vSmearRowEnd   = virtualSmearRowsArray(:, 2);


% compute number of rows/columns (for long cadence black and smear pixels)
numberOfBlackColumns        = blackColumnEnd - blackColumnStart + 1;
numberOfMaskedSmearRows     = mSmearRowEnd - mSmearRowStart + 1;
numberOfVirtualSmearRows    = vSmearRowEnd - vSmearRowStart + 1;

% compute number of masked/virtual black pixels (used for short cadence data)
numberOfMaskedBlackPixels   = numberOfBlackColumns.*numberOfMaskedSmearRows;
numberOfVirtualBlackPixels  = numberOfBlackColumns.*numberOfVirtualSmearRows;


% black columns may vary with time, so display the value if constant, or else display the max/min values
if ~isempty(blackColumnStart(~timestampGapIndicators)) && ...
        (min(blackColumnStart(~timestampGapIndicators)) == ...
        max(blackColumnStart(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Black start column is: ',num2str(mean(blackColumnStart(~timestampGapIndicators))) ]);
    calIntermediateStruct.blackColumnStart = min(blackColumnStart(~timestampGapIndicators));

elseif  ~isempty(blackColumnStart(~timestampGapIndicators))
    
    display(['CAL:get_config_map_parameters: Black start column varies with time;  min: ' ...
        num2str(min(blackColumnStart(~timestampGapIndicators))) ', max: ' ...
        num2str(max(blackColumnStart(~timestampGapIndicators))) ]);

    calIntermediateStruct.blackColumnStart = blackColumnStart;
end


% black columns may vary with time, so display the value if constant, or else display the max/min values
if ~isempty(blackColumnEnd(~timestampGapIndicators)) && ...
        (min(blackColumnEnd(~timestampGapIndicators)) == ...
        max(blackColumnEnd(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Black end column is: ',num2str(mean(blackColumnEnd(~timestampGapIndicators))) ]);
    calIntermediateStruct.blackColumnEnd = min(blackColumnEnd(~timestampGapIndicators));

elseif  ~isempty(blackColumnEnd(~timestampGapIndicators))
    
    display(['CAL:get_config_map_parameters: Black end column varies with time;  min: ' ...
        num2str(min(blackColumnEnd(~timestampGapIndicators))) ', max: ' ...
        num2str(max(blackColumnEnd(~timestampGapIndicators))) ]);

    calIntermediateStruct.blackColumnEnd = blackColumnEnd;
end


% smear rows may vary with time, so display the value if constant, or else display the max/min values
if ~isempty(mSmearRowStart(~timestampGapIndicators)) && ...
        (min(mSmearRowStart(~timestampGapIndicators)) == ...
        max(mSmearRowStart(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Masked smear start row is: ',num2str(mean(mSmearRowStart(~timestampGapIndicators))) ]);
    calIntermediateStruct.mSmearRowStart = min(mSmearRowStart(~timestampGapIndicators));

elseif  ~isempty(mSmearRowStart(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Masked smear start row varies with time;  min: ' ...
        num2str(min(mSmearRowStart(~timestampGapIndicators))) ', max: ' ...
        num2str(max(mSmearRowStart(~timestampGapIndicators))) ]);

    calIntermediateStruct.mSmearRowStart = mSmearRowStart;
end


% smear rows may vary with time, so display the value if constant, or else display the max/min values
if ~isempty(mSmearRowEnd(~timestampGapIndicators)) && ...
        (min(mSmearRowEnd(~timestampGapIndicators)) == ...
        max(mSmearRowEnd(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Masked smear end row is: ',num2str(mean(mSmearRowEnd(~timestampGapIndicators))) ]);
    calIntermediateStruct.mSmearRowEnd = min(mSmearRowEnd(~timestampGapIndicators));

elseif  ~isempty(mSmearRowEnd(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Masked smear end row varies with time;  min: ' ...
        num2str(min(mSmearRowEnd(~timestampGapIndicators))) ', max: ' ...
        num2str(max(mSmearRowEnd(~timestampGapIndicators))) ]);

    calIntermediateStruct.mSmearRowEnd = mSmearRowEnd;
end


% smear rows may vary with time, so display the value if constant, or else display the max/min values
if ~isempty(vSmearRowStart(~timestampGapIndicators)) && ...
        (min(vSmearRowStart(~timestampGapIndicators)) == ...
        max(vSmearRowStart(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Virtual smear start row is: ',num2str(mean(vSmearRowStart(~timestampGapIndicators))) ]);
    calIntermediateStruct.vSmearRowStart = min(vSmearRowStart(~timestampGapIndicators));

elseif  ~isempty(vSmearRowStart(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Virtual smear start row varies with time;  min: ' ...
        num2str(min(vSmearRowStart(~timestampGapIndicators))) ', max: ' ...
        num2str(max(vSmearRowStart(~timestampGapIndicators))) ]);

    calIntermediateStruct.vSmearRowStart = vSmearRowStart;
end


% smear rows may vary with time, so display the value if constant, or else display the max/min values
if ~isempty(vSmearRowEnd(~timestampGapIndicators)) && ...
        (min(vSmearRowEnd(~timestampGapIndicators)) == ...
        max(vSmearRowEnd(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Virtual smear end row is: ',num2str(mean(vSmearRowEnd(~timestampGapIndicators))) ]);
    calIntermediateStruct.vSmearRowEnd = min(vSmearRowEnd(~timestampGapIndicators));

elseif  ~isempty(vSmearRowEnd(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Virtual smear end row varies with time;  min: ' ...
        num2str(min(vSmearRowEnd(~timestampGapIndicators))) ', max: ' ...
        num2str(max(vSmearRowEnd(~timestampGapIndicators))) ]);

    calIntermediateStruct.vSmearRowEnd = vSmearRowEnd;
end


% number of coadded pixels may vary with time, so display the value if constant, or else display the max/min values
if ~isempty(numberOfBlackColumns(~timestampGapIndicators)) && ...
        (min(numberOfBlackColumns(~timestampGapIndicators)) == ...
        max(numberOfBlackColumns(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Number of black coadded columns is: ',num2str(mean(numberOfBlackColumns(~timestampGapIndicators))) ]);
    calIntermediateStruct.numberOfBlackColumns = min(numberOfBlackColumns(~timestampGapIndicators));

elseif  ~isempty(numberOfBlackColumns(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Number of black coadded columns varies with time;  min: ' ...
        num2str(min(numberOfBlackColumns(~timestampGapIndicators))) ', max: ' ...
        num2str(max(numberOfBlackColumns(~timestampGapIndicators))) ]);

    calIntermediateStruct.numberOfBlackColumns = numberOfBlackColumns;
end


if ~isempty(numberOfMaskedSmearRows(~timestampGapIndicators)) && ...
        (min(numberOfMaskedSmearRows(~timestampGapIndicators)) == ...
        max(numberOfMaskedSmearRows(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Number of masked smear coadded rows is: ',num2str(mean(numberOfMaskedSmearRows(~timestampGapIndicators))) ]);
    calIntermediateStruct.numberOfMaskedSmearRows = min(numberOfMaskedSmearRows(~timestampGapIndicators));

elseif  ~isempty(numberOfMaskedSmearRows(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Number of masked smear coadded rows varies with time;  min: ' ...
        num2str(min(numberOfMaskedSmearRows(~timestampGapIndicators))) ', max: ' ...
        num2str(max(numberOfMaskedSmearRows(~timestampGapIndicators))) ]);

    calIntermediateStruct.numberOfMaskedSmearRows = numberOfMaskedSmearRows;
end


if ~isempty(numberOfVirtualSmearRows(~timestampGapIndicators)) && ...
        (min(numberOfVirtualSmearRows(~timestampGapIndicators)) == ...
        max(numberOfVirtualSmearRows(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Number of virtual smear coadded rows is: ',num2str(mean(numberOfVirtualSmearRows(~timestampGapIndicators))) ]);
    calIntermediateStruct.numberOfVirtualSmearRows = min(numberOfVirtualSmearRows(~timestampGapIndicators));

elseif  ~isempty(numberOfVirtualSmearRows(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Number of virtual smear coadded rows varies with time;  min: ' ...
        num2str(min(numberOfVirtualSmearRows(~timestampGapIndicators))) ', max: ' ...
        num2str(max(numberOfVirtualSmearRows(~timestampGapIndicators))) ]);

    calIntermediateStruct.numberOfVirtualSmearRows = numberOfVirtualSmearRows;
end

if processShortCadence && ~isempty(numberOfMaskedBlackPixels(~timestampGapIndicators)) && ...
        (min(numberOfMaskedBlackPixels(~timestampGapIndicators)) == ...
        max(numberOfMaskedBlackPixels(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Number of masked black coadded pixels is: ',num2str(mean(numberOfMaskedBlackPixels(~timestampGapIndicators))) ]);
    calIntermediateStruct.numberOfMaskedBlackPixels = min(numberOfMaskedBlackPixels(~timestampGapIndicators));

elseif  processShortCadence && ~isempty(numberOfMaskedBlackPixels(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Number of masked black coadded pixels varies with time;  min: ' ...
        num2str(min(numberOfMaskedBlackPixels(~timestampGapIndicators))) ', max: ' ...
        num2str(max(numberOfMaskedBlackPixels(~timestampGapIndicators))) ]);

    calIntermediateStruct.numberOfMaskedBlackPixels = numberOfMaskedBlackPixels;
end


if processShortCadence && ~isempty(numberOfVirtualBlackPixels(~timestampGapIndicators)) && ...
        (min(numberOfVirtualBlackPixels(~timestampGapIndicators)) == ...
        max(numberOfVirtualBlackPixels(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Number of virtual black coadded pixels is: ',num2str(mean(numberOfVirtualBlackPixels(~timestampGapIndicators))) ]);
    calIntermediateStruct.numberOfVirtualBlackPixels = min(numberOfVirtualBlackPixels(~timestampGapIndicators));

elseif processShortCadence && ~isempty(numberOfVirtualBlackPixels(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Number of virtual black coadded pixels varies with time;  min: ' ...
        num2str(min(numberOfVirtualBlackPixels(~timestampGapIndicators))) ', max: ' ...
        num2str(max(numberOfVirtualBlackPixels(~timestampGapIndicators))) ]);

    calIntermediateStruct.numberOfVirtualBlackPixels = numberOfVirtualBlackPixels;
end


%--------------------------------------------------------------------------
% extract readout and exposure times
%--------------------------------------------------------------------------
ccdReadTime = zeros(size(timestamp));
[ccdReadTime(~timestampGapIndicators)] = get_readout_time(configMapObject, timestamp(~timestampGapIndicators));

ccdExposureTime = zeros(size(timestamp));
[ccdExposureTime(~timestampGapIndicators)] = get_exposure_time(configMapObject, timestamp(~timestampGapIndicators));

% read time values vary with time, so display the value if constant, or else display the max/min values
if ~isempty(ccdReadTime(~timestampGapIndicators)) && ...
        (min(ccdReadTime(~timestampGapIndicators)) == ...
        max(ccdReadTime(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: CCD read time is: ',num2str(mean(ccdReadTime(~timestampGapIndicators))) ]);
    calIntermediateStruct.ccdReadTime = min(ccdReadTime(~timestampGapIndicators));

elseif ~isempty(ccdReadTime(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: CCD read time varies with time;  min: ' ...
        num2str(min(ccdReadTime(~timestampGapIndicators))) ', max: ' ...
        num2str(max(ccdReadTime(~timestampGapIndicators))) ]);

    calIntermediateStruct.ccdReadTime = ccdReadTime;
end

% exposure time values vary with time, so display the value if constant, or else display the max/min values
if ~isempty(ccdExposureTime(~timestampGapIndicators)) && ...
        (min(ccdExposureTime(~timestampGapIndicators)) == ...
        max(ccdExposureTime(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: CCD exposure time is: ',num2str(mean(ccdExposureTime(~timestampGapIndicators))) ]);
    calIntermediateStruct.ccdExposureTime = min(ccdExposureTime(~timestampGapIndicators));

elseif ~isempty(ccdExposureTime(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: CCD exposure time varies with time;  min: ' ...
        num2str(min(ccdExposureTime(~timestampGapIndicators))) ', max: ' ...
        num2str(max(ccdExposureTime(~timestampGapIndicators))) ]);

    calIntermediateStruct.ccdExposureTime = ccdExposureTime;
end

%--------------------------------------------------------------------------
% extract number of exposures for long or short cadences, or FFIs, for valid
% cadences
%--------------------------------------------------------------------------
numberOfExposuresPerLongCadence = zeros(size(timestamp));
numberOfExposuresPerLongCadence(~timestampGapIndicators) = ...
    get_number_of_exposures_per_long_cadence_period(configMapObject, timestamp(~timestampGapIndicators));

numberOfExposuresPerShortCadence = zeros(size(timestamp));
[numberOfExposuresPerShortCadence(~timestampGapIndicators)] = ...
    get_number_of_exposures_per_short_cadence_period(configMapObject, timestamp(~timestampGapIndicators));

numberOfExposuresPerFFI = zeros(size(timestamp));
numberOfExposuresPerFFI(~timestampGapIndicators) = ...
    get_number_of_exposures_per_ffi(configMapObject, timestamp(~timestampGapIndicators));

numberOfShortCadencesPerLongCadence = zeros(size(timestamp));
[numberOfShortCadencesPerLongCadence(~timestampGapIndicators)] = ...
    get_number_of_shorts_in_long(configMapObject, timestamp(~timestampGapIndicators));

% number of exposures may vary with time, so display the value if constant, or else display the max/min values
if processLongCadence && ~processFFI && ...
        ~isempty(numberOfExposuresPerLongCadence(~timestampGapIndicators)) && ...
        (min(numberOfExposuresPerLongCadence(~timestampGapIndicators)) == ...
        max(numberOfExposuresPerLongCadence(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Number of LC exposures is: ',num2str(mean(numberOfExposuresPerLongCadence(~timestampGapIndicators))) ]);
    calIntermediateStruct.numberOfExposures = min(numberOfExposuresPerLongCadence(~timestampGapIndicators));

elseif processLongCadence && ~processFFI && ~isempty(numberOfExposuresPerLongCadence(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Number of LC exposures varies with time;  min: ' ...
        num2str(min(numberOfExposuresPerLongCadence(~timestampGapIndicators))) ', max: ' ...
        num2str(max(numberOfExposuresPerLongCadence(~timestampGapIndicators))) ]);

    calIntermediateStruct.numberOfExposures = numberOfExposuresPerLongCadence;
end

% display for short cadence
if processShortCadence && ~isempty(numberOfExposuresPerShortCadence(~timestampGapIndicators)) && ...
        (min(numberOfExposuresPerShortCadence(~timestampGapIndicators)) == ...
        max(numberOfExposuresPerShortCadence(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Number of SC exposures is: ',num2str(mean(numberOfExposuresPerShortCadence(~timestampGapIndicators))) ]);
    calIntermediateStruct.numberOfExposures = min(numberOfExposuresPerShortCadence(~timestampGapIndicators));

elseif processShortCadence && ~isempty(numberOfExposuresPerShortCadence(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Number of SC exposures varies with time;  min: ' ...
        num2str(min(numberOfExposuresPerShortCadence(~timestampGapIndicators))) ', max: ' ...
        num2str(max(numberOfExposuresPerShortCadence(~timestampGapIndicators))) ]);

    calIntermediateStruct.numberOfExposures = numberOfExposuresPerShortCadence;
end

if processShortCadence && ~isempty(numberOfShortCadencesPerLongCadence(~timestampGapIndicators)) && ...
        (min(numberOfShortCadencesPerLongCadence(~timestampGapIndicators)) == ...
        max(numberOfShortCadencesPerLongCadence(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Number of SC exposures per LC exposure is: ',num2str(mean(numberOfShortCadencesPerLongCadence(~timestampGapIndicators))) ]);
    calIntermediateStruct.numberOfShortCadencesPerLong = min(numberOfShortCadencesPerLongCadence(~timestampGapIndicators));

elseif processShortCadence && ~isempty(numberOfShortCadencesPerLongCadence(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Number of SC exposures per LC exposure varies with time;  min: ' ...
        num2str(min(numberOfShortCadencesPerLongCadence(~timestampGapIndicators))) ', max: ' ...
        num2str(max(numberOfShortCadencesPerLongCadence(~timestampGapIndicators))) ]);

    calIntermediateStruct.numberOfShortCadencesPerLong = numberOfShortCadencesPerLongCadence;
end

% display for ffi
if (processFFI)
    display(['CAL:get_config_map_parameters: Number of exposures in FFI is: ' ...
        num2str(numberOfExposuresPerFFI) ]);

    calIntermediateStruct.numberOfExposures = numberOfExposuresPerFFI;
end


%--------------------------------------------------------------------------
% extract the read noise model (in ADU) and add to the intermediate struct
%--------------------------------------------------------------------------
calIntermediateStruct.readNoiseInADU = zeros(length(timestamp), 1);
readNoiseModel  = calObject.readNoiseModel;

% create the read noise object
readNoiseObject = readNoiseClass(readNoiseModel);

% retrieve the read noise for current mod/out/mjds for valid cadences
readNoiseInADU  = zeros(size(timestamp));
readNoiseInADU(~timestampGapIndicators) = get_read_noise(readNoiseObject, timestamp(~timestampGapIndicators), ccdModule, ccdOutput);

% read noise value varies with time, so display the value if constant, or
% else display the max/min values
if ~isempty(readNoiseInADU(~timestampGapIndicators)) && ...
        (min(readNoiseInADU(~timestampGapIndicators)) == ...
        max(readNoiseInADU(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Read noise in ADU (from FC model) is: ',num2str(mean(readNoiseInADU(~timestampGapIndicators))) ]);
    calIntermediateStruct.readNoiseInADU = min(readNoiseInADU(~timestampGapIndicators));

elseif ~isempty(readNoiseInADU(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Read noise in ADU (from FC model) varies with time;  min: ' ...
        num2str(min(readNoiseInADU(~timestampGapIndicators))) ', max: ' ...
        num2str(max(readNoiseInADU(~timestampGapIndicators))) ]);

    calIntermediateStruct.readNoiseInADU = readNoiseInADU;

end

%--------------------------------------------------------------------------
% extract the ADC gain model to have access to the gain in the intermediate struct
%--------------------------------------------------------------------------
calIntermediateStruct.gain = zeros(length(timestamp), 1);
gainModel  = calObject.gainModel;

% create the gain object
gainObject = gainClass(gainModel);

% get gain for this mod/out
gain = zeros(size(timestamp));  % nCadences x 1
gain(~timestampGapIndicators) = get_gain(gainObject, timestamp(~timestampGapIndicators), ccdModule, ccdOutput);

% the gain value varies with time, so display the value if constant, or
% else display the max/min values
if ~isempty(gain(~timestampGapIndicators)) && (min(gain(~timestampGapIndicators)) == max(gain(~timestampGapIndicators)))

    display(['CAL:get_config_map_parameters: Gain (e-/ADU) (from FC model) is: ',num2str(mean(gain(~timestampGapIndicators))) ]);
    calIntermediateStruct.gain = min(gain(~timestampGapIndicators));

elseif ~isempty(gain(~timestampGapIndicators))

    display(['CAL:get_config_map_parameters: Gain (e-/ADU) (from FC model) varies with time;  min: ' ...
        num2str(min(gain(~timestampGapIndicators))) ', max: ' ...
        num2str(max(gain(~timestampGapIndicators))) ]);

    calIntermediateStruct.gain = gain;

end


return;
