function [stateFilenames] = restore_cal_state_files(inputsStruct)
%
% function [stateFilenames] = restore_cal_state_files(inputsStruct)
%
% The CAL utility function restores CAL state files from back-ups if ~firstCall, otherwise it removes state
% files and backups. The cell array of state file names is returned. Not all of the original list of state
% files is needed depending on cadence type and other parameters. The state file list is initialized at the
% top of this function and parsed accordingly.
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

metricsKey = metrics_interval_start;

% build list of state filenames for back-up
stateFilePath  = inputsStruct.localFilenames.stateFilePath;
localFilenames = inputsStruct.localFilenames;
stateFilenames = {localFilenames.calCompEffFilename,...
                    [localFilenames.pouRootFilename,'_0.mat']};                
                
% extract flags
dataFlags = inputsStruct.dataFlags;
processFFI             = dataFlags.processFFI;
processShortCadence    = dataFlags.processShortCadence;
processLongCadence     = dataFlags.processLongCadence;
performExpLc1DblackFit = dataFlags.performExpLc1DblackFit; 
dynamic2DBlackEnabled  = dataFlags.dynamic2DBlackEnabled;

% extract input parameters
firstCall   = inputsStruct.firstCall;
pouEnabled  = inputsStruct.pouModuleParametersStruct.pouEnabled;


% adjust state file list per cadence type, pouEnabled, black algorithm
if processFFI
    stateFilenames = setdiff( stateFilenames, localFilenames.calMetricsFilename);
end
if (processLongCadence && ~performExpLc1DblackFit) || processShortCadence || processFFI
    stateFilenames = setdiff( stateFilenames, localFilenames.oneDBlackFitFilename);
end
if ~pouEnabled
    stateFilenames = setdiff( stateFilenames, [localFilenames.pouRootFilename,'_0.mat']);
end
if ~dynamic2DBlackEnabled
    stateFilenames = setdiff( stateFilenames, localFilenames.dynoblackModelsFilename);
end

% restore backed-up files
if ~firstCall
    for iFile = 1:length(stateFilenames)
        if(exist([stateFilePath,stateFilenames{iFile},localFilenames.backupTag],'file') == 2)
            copyfile( [stateFilePath,stateFilenames{iFile},localFilenames.backupTag], [stateFilePath, stateFilenames{iFile}] );
            display(['CAL:cal_matlab_controller: State file ',stateFilenames{iFile},' restored from backup.']);
        else
            % throw error if backup file does not exist
            error('CAL:cal_matlab_controller:StateFileBackupNotFound', ...
                ['State file backup ',[stateFilenames{iFile},localFilenames.backupTag],' was not found.']);
        end
    end
else
    for iFile = 1:length(stateFilenames)
        if(exist([stateFilePath,stateFilenames{iFile},localFilenames.backupTag],'file') == 2)
            delete( [stateFilePath,stateFilenames{iFile},localFilenames.backupTag] );
            display(['CAL:cal_matlab_controller: Stale backup state file ',[stateFilenames{iFile},localFilenames.backupTag],' removed.']);
        end
        if(exist( [stateFilePath,stateFilenames{iFile}],'file') == 2)
            delete([stateFilePath,stateFilenames{iFile}] );
            display(['CAL:cal_matlab_controller: Stale state file ',stateFilenames{iFile},' removed.']);
        end
    end
end

metrics_interval_stop('cal.restore_cal_state_files.execTimeMillis',metricsKey);