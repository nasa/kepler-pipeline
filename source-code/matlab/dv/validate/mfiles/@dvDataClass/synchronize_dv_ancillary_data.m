function [conditionedAncillaryDataArray, alerts] = ...
synchronize_dv_ancillary_data(dvDataObject, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [conditionedAncillaryDataArray, alerts] = ...
% synchronize_dv_ancillary_data(dvDataObject, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Method for DV synchronizes the ancillary data or CBVs for each target
% table. Get needed structures and fields from DV data object and call
% common synchronization function for each table.
%
% INPUT:    dvDataObject    From dvDataStruct. As defined in 
%                           dv_matlab_controller
%           alerts          From dvResultsStruct. As defined in
%                           dv_matlab_controller
% OUTPUT:   conditionedAncillaryDataArray
%                           Array containing synchronized ancillary data
%                           and associated metadata for each target table
%           alerts          Same as input with new alerts appended
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

% Extract relevant input parameters and structures.
cbvEnabled = dvDataObject.dvConfigurationStruct.cbvEnabled;

dvCadenceTimes = dvDataObject.dvCadenceTimes;
cadenceNumbers = dvCadenceTimes.cadenceNumbers;

ancillaryEngineeringDataFileName = ...
    dvDataObject.ancillaryEngineeringDataFileName;
ancillaryEngineeringConfigurationStruct = ...
    dvDataObject.ancillaryEngineeringConfigurationStruct;
ancillaryPipelineConfigurationStruct = ...
    dvDataObject.ancillaryPipelineConfigurationStruct;

targetTableDataStruct = dvDataObject.targetTableDataStruct;
targetStruct = dvDataObject.targetStruct;

% Load the ancillary engineering data from the SDF file.
[ancillaryEngineeringDataStruct, status, path, name, ext] = ...
    file_to_struct(ancillaryEngineeringDataFileName, ...
    'ancillaryEngineeringDataStruct');                                                      %#ok<ASGLU>
if ~status
    error('dv:synchronizeDvAncillaryData:unknownDataFileType', ...
        'unknown ancillary engineering data file type (%s%s)', ...
        name, ext);
end % if / else

% Validate the structure ancillaryEngineeringConfigurationStruct
% if there is ancillary engineering data.
if ~isempty(ancillaryEngineeringDataStruct)
    
    fieldsAndBounds = cell(5,4);
    fieldsAndBounds(1,:)  = { 'mnemonics'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'modelOrders'; '>= 0'; '<= 5'; []};
    fieldsAndBounds(3,:)  = { 'interactions'; []; []; {}};
    fieldsAndBounds(4,:)  = { 'quantizationLevels'; '>= 0'; []; []};
    fieldsAndBounds(5,:)  = { 'intrinsicUncertainties'; '>= 0'; []; []};

    validate_structure(ancillaryEngineeringConfigurationStruct, ...
        fieldsAndBounds, 'ancillaryEngineeringConfigurationStruct');

    clear fieldsAndBounds;
    
end % if

% Validate the structure array ancillaryEngineeringDataStruct
% if there is ancillary engineering data.
if ~isempty(ancillaryEngineeringDataStruct)
    
    fieldsAndBounds = cell(3,4);
    fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; {}};
    fieldsAndBounds(2,:)  = { 'timestamps'; '> 54500'; '< 70000'; []};      % 2/4/2008 to 7/13/2050
    fieldsAndBounds(3,:)  = { 'values'; []; []; []};                        % TBD

    nStructures = length(ancillaryEngineeringDataStruct);

    for i = 1 : nStructures
        validate_structure(ancillaryEngineeringDataStruct(i), ...
            fieldsAndBounds, 'ancillaryEngineeringDataStruct()');
    end % for
    
    clear fieldsAndBounds;

end % if

% Loop through the target tables and condition the ancillary data
% separately for each.
nTargets = length(targetStruct);
nTables = length(targetTableDataStruct);
conditionedAncillaryDataArray = repmat(struct( ...
    'conditionedAncillaryDataStruct', [], ...
    'targetTableId', -1, ...
    'ccdModule', -1, ...
    'ccdOutput', -1, ...
    'startCadenceAbsolute', -1, ...
    'endCadenceAbsolute', -1, ...
    'startCadenceRelative', -1, ...
    'endCadenceRelative', -1, ...
    'firstScienceCadenceIndex', -1, ...
    'lastScienceCadenceIndex', -1), ([1, nTables]));

for iTable = 1 : nTables
    
    % Find the first and last valid science cadences for the given target
    % table based on available pixel data. Excluded and anomaly cadences
    % should already have been gapped. Continue if there is no valid pixel
    % data for any of the targets.
    tableStruct = targetTableDataStruct(iTable);
    targetTableId = tableStruct.targetTableId;
    targetTableStartCadence = tableStruct.startCadence;
    targetTableEndCadence = tableStruct.endCadence;
    targetTableModule = tableStruct.ccdModule;
    targetTableOutput = tableStruct.ccdOutput;
    nCadences = targetTableEndCadence - targetTableStartCadence + 1;
    
    conditionedAncillaryDataArray(iTable).targetTableId = targetTableId;
    conditionedAncillaryDataArray(iTable).ccdModule = targetTableModule;
    conditionedAncillaryDataArray(iTable).ccdOutput = targetTableOutput;
    
    structArray = [];
    
    for iTarget = 1 : nTargets
        targetTableIds = ...
            [targetStruct(iTarget).targetDataStruct.targetTableId];
        [tf, loc] = ismember(targetTableId, targetTableIds);
        if tf
            pixelDataFileName = ...
                targetStruct(iTarget).targetDataStruct(loc).pixelDataFileName;
            [pixelDataStruct, status, path, name, ext] = ...
                file_to_struct(pixelDataFileName, 'pixelDataStruct');                       %#ok<ASGLU>
            if ~status
                error('dv:synchronizeDvAncillaryData:unknownDataFileType', ...
                    'unknown pixel data file type (%s%s)', ...
                    name, ext);
            end % if
            structArray = [structArray, pixelDataStruct];                                   %#ok<AGROW>
            clear pixelDataStruct
        end % if
    end % for iTarget
    
    if isempty(structArray)
        continue
    end % if
    
    structArray = [structArray.calibratedTimeSeries];
    gapIndicatorsArray = [structArray.gapIndicators];
    clear structArray
    
    if all(all(gapIndicatorsArray))
        continue
    end % if
    
    firstScienceCadenceIndex = find(any(~gapIndicatorsArray, 2), 1, 'first');
    lastScienceCadenceIndex = find(any(~gapIndicatorsArray, 2), 1, 'last');
    
    % Trim the cadence times structure for the given target table.
    isInTable = dvCadenceTimes.lcTargetTableIds == targetTableId;
    firstTableCadenceIndex = find(isInTable, 1, 'first');
    
    if cadenceNumbers(firstTableCadenceIndex) ~= targetTableStartCadence
        error('dv:synchronizeDvAncillaryData:cadenceTimesInconsistency', ...
            'inconsistency between start cadence and lcTargetTableIds for target table %d', ...
            targetTableId);
    end % if
    
    cadenceRange = firstTableCadenceIndex : firstTableCadenceIndex + nCadences - 1;
    [tableCadenceTimes] = trim_dv_cadence_times(dvCadenceTimes, cadenceRange);
    
    cadenceRange = firstTableCadenceIndex + firstScienceCadenceIndex - 1 : ...
        firstTableCadenceIndex + lastScienceCadenceIndex - 1;
    [scienceCadenceTimes] = trim_dv_cadence_times(dvCadenceTimes, cadenceRange);
    
    % Try to read the CBV blob if CBV processing is enabled.
    if cbvEnabled
        [cbvStruct, cbvGapIndicators] = ...
            cbv_blob_series_to_struct(tableStruct.cbvBlobs);
        if isempty(cbvStruct)
            [alerts] = add_alert(alerts, 'warning', ...
                sprintf('CBVs are not available for mod out %d.%d in target table %d.', ...
                targetTableModule, targetTableOutput, targetTableId));
                disp(alerts(end).message);
        end % if
    else
        cbvStruct = [];
    end % if / else
    
    % Use cotrending basis vectors (CBVs) for cotrending if they are
    % enabled and available of the given quarter. Otherwise fall back to
    % cotrending with ancillary engineering/pipelien data and motion
    % polynomials.
    cadenceRange = firstScienceCadenceIndex : lastScienceCadenceIndex;
    
    if ~isempty(cbvStruct)
        
        % Configure the CBVs for DV cotrending. They are already specified
        % per (long) cadence and are gap filled to boot.
        [conditionedAncillaryDataStruct] = ...
            configure_cbv_for_dv_cotrending(tableCadenceTimes, cbvStruct, ...
            cbvGapIndicators, cadenceRange);
        clear cbvStruct
        
    else
        
        % Get the motion polynomials and trim to the valid science data period
        % if the polynomials if the polynomials are not empty. This might
        % happen on dead module outputs in quarters when the skygroup passes
        % through.
        motionPolyStruct = tableStruct.motionPolyStruct;
        if ~isempty(motionPolyStruct) && motionPolyStruct(1).module ~= targetTableModule
            error('dv:synchronizeDvAncillaryData:motionPolyModuleInconsistency', ...
                ['inconsistency between target table (%d) and motion polynomial (%d) modules ', ...
                'for table %d'], targetTableModule, motionPolyStruct(1).module, targetTableId);
        end % if
        if ~isempty(motionPolyStruct) && motionPolyStruct(1).output ~= targetTableOutput
            error('dv:synchronizeDvAncillaryData:motionPolyOutputInconsistency', ...
                ['inconsistency between target table (%d) and motion polynomial (%d) outputs ', ...
                'for table %d'], targetTableOutput, motionPolyStruct(1).output, targetTableId);
        end % if
        if ~isempty(motionPolyStruct) && motionPolyStruct(1).cadence ~= targetTableStartCadence
            error('dv:synchronizeDvAncillaryData:motionPolyCadenceInconsistency', ...
                'inconsistency between start cadence and motion polynomials for table %d', ...
                targetTableId);
        end % if

        if ~isempty(motionPolyStruct)
            motionPolyStruct = motionPolyStruct(cadenceRange);
        end % if

        % Trim the ancillary data to the valid science data period for each
        % target table.
        startTime = scienceCadenceTimes.startTimestamps(1);
        endTime = scienceCadenceTimes.endTimestamps(end);

        ancillaryPipelineDataStructForTargetTable = ...
            tableStruct.ancillaryPipelineDataStruct;
        nMnemonics = length(ancillaryPipelineDataStructForTargetTable);

        for iMnemonic = 1 : nMnemonics

            pipelineStruct = ...
                ancillaryPipelineDataStructForTargetTable(iMnemonic);
            timestamps = pipelineStruct.timestamps;
            isInRange = timestamps >= startTime & timestamps <= endTime;

            pipelineStruct.timestamps = pipelineStruct.timestamps(isInRange);
            pipelineStruct.values = pipelineStruct.values(isInRange);
            pipelineStruct.uncertainies = ...
                pipelineStruct.uncertainties(isInRange);
            ancillaryPipelineDataStructForTargetTable(iMnemonic) = ...
                pipelineStruct;

        end % for iMnemonic

        ancillaryEngineeringDataStructForTargetTable = ...
            ancillaryEngineeringDataStruct;
        nMnemonics = length(ancillaryEngineeringDataStructForTargetTable);

        for iMnemonic = 1 : nMnemonics

            engineeringStruct = ...
                ancillaryEngineeringDataStructForTargetTable(iMnemonic);
            timestamps = engineeringStruct.timestamps;
            isInRange = timestamps >= startTime & timestamps <= endTime;

            engineeringStruct.timestamps = ...
                engineeringStruct.timestamps(isInRange);
            engineeringStruct.values = engineeringStruct.values(isInRange);
            ancillaryEngineeringDataStructForTargetTable(iMnemonic) = ...
                engineeringStruct;

        end % for iMnemonic

        % Perform the ancillary data conditioning. Note that in DV, cadence
        % times and long cadence times structures are equivalent.
        [conditionedAncillaryDataStruct, alerts] = ...
            synchronize_ancillary_data_mp(scienceCadenceTimes, scienceCadenceTimes, ...
            ancillaryEngineeringConfigurationStruct, ...
            ancillaryEngineeringDataStructForTargetTable, ...
            ancillaryPipelineConfigurationStruct, ...
            ancillaryPipelineDataStructForTargetTable, ...
            motionPolyStruct, alerts);

        clear ancillaryEngineeringDataStructForTargetTable
        clear ancillaryPipelineDataStructForTargetTable

    end % if / else
    
    % Pad any cadences before or after valid science data acquisition.
    nMnemonics = length(conditionedAncillaryDataStruct);
    
    for iMnemonic = 1 : nMnemonics
        
        ancillaryTimeSeries = ...
            conditionedAncillaryDataStruct(iMnemonic).ancillaryTimeSeries;
        
        values = zeros([nCadences, 1]);
        uncertainties = zeros([nCadences, 1]);
        gapIndicators = true([nCadences, 1]);
        timestamps = zeros([nCadences, 1]);
        
        values(cadenceRange) = ancillaryTimeSeries.values;
        uncertainties(cadenceRange) = ancillaryTimeSeries.uncertainties;
        gapIndicators(cadenceRange) = ancillaryTimeSeries.gapIndicators;
        timestamps(cadenceRange) = ancillaryTimeSeries.timestamps;
        
        ancillaryTimeSeries.values = values;
        ancillaryTimeSeries.uncertainties = uncertainties;
        ancillaryTimeSeries.gapIndicators = gapIndicators;
        ancillaryTimeSeries.timestamps = timestamps;
        
        conditionedAncillaryDataStruct(iMnemonic).ancillaryTimeSeries = ...
            ancillaryTimeSeries;
        
    end % for iMnemonic
    
    % Assign the conditioned ancillary data struct for the given target
    % table to the output array. Include relevant target table metadata to
    % facilitate cotrending on target table basis.
    conditionedAncillaryDataArray(iTable).conditionedAncillaryDataStruct = ...
        conditionedAncillaryDataStruct;
    conditionedAncillaryDataArray(iTable).startCadenceAbsolute = ...
        targetTableStartCadence;
    conditionedAncillaryDataArray(iTable).endCadenceAbsolute = ...
        targetTableEndCadence;
    conditionedAncillaryDataArray(iTable).startCadenceRelative = ...
        firstTableCadenceIndex;
    conditionedAncillaryDataArray(iTable).endCadenceRelative = ...
        firstTableCadenceIndex + nCadences - 1;
    conditionedAncillaryDataArray(iTable).firstScienceCadenceIndex = ...
        firstScienceCadenceIndex;
    conditionedAncillaryDataArray(iTable).lastScienceCadenceIndex = ...
        lastScienceCadenceIndex;
    
end % for iTable

% Return.
return
