function pdqval_generate_test_cases(configStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate test cases for PDQ regression testing
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
% Run from within the directory where you want to create the test cases.
% This function started as a script and evolved into a function so it could
% take parameters. It is currently specific to my (RLM) computing
% environment and not a generally useful tool. If time permits, I will
% make it configurable so that anyone can use it.
%
% Use pdqval_init_case_generation_config_struct.m to create a config
% structure that can then be modified as desired.
%
% Notes:
%
%     For many cases we use data from the most recent quarter, since it's
%     assumed that it will most closely resemble future data.
%
%     To Do:
%     1) Include mapping of source directories to case subdirectories in 
%        the configuration structure.
%     2) Find and copy panetary ephemeris and leap seconds files
%     
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
programName      = 'generate_test_cases';
pdqInputFileName = 'pdq-inputs-0.mat';

diary off;
if exist('diary.log','file')
    delete('diary.log');
end
diary('diary.log');

%--------------------------------------------------------------------------
% Configure
%--------------------------------------------------------------------------
if ~exist('configStruct','var')
    configStruct = pdqval_init_case_generation_config_struct();
end

srcRootDir    = configStruct.srcRootDir;
destRootDir   = configStruct.destRootDir;
caseList      = configStruct.caseList;


%--------------------------------------------------------------------------
% Create test cases
%--------------------------------------------------------------------------
for caseIdx = 1:numel(caseList)
 
    if exist('inputsStruct','var')
        clear('inputsStruct');
    end

    switch caseList{caseIdx}
        
        case 'all_quarters'
            %
            % Cases tested:
            %
            % 1. Contacts from all quarters
            % 2. Varying numbers of new cadences
            % 3. Presence/absence of metric histories
            % 4. Plate scale two stars per channel (q9 data)
            %
            subDirs = { ...                                       
               'ref_data_by_qtr/q0/pdq-matlab-679-16455/'; ...
               'ref_data_by_qtr/q1/pdq-matlab-116-7795/'; ...    
               'ref_data_by_qtr/q2/pdq-matlab-660-16436/'; ...
               'ref_data_by_qtr/q3/pdq-matlab-916-17369/'; ...
               'ref_data_by_qtr/q4/pdq-matlab-1121-18614/'; ...
                'ref_data_by_qtr/q5/pdq-matlab-1524-22697/'; ...
               'ref_data_by_qtr/q6/pdq-matlab-1946-26039/'; ...
               'ref_data_by_qtr/q7/pdq-matlab-1989-26065_reproc_all_q7/'; ...
               'ref_data_by_qtr/q8/pdq-matlab-2775-31531/'; ...    
               'ref_data_by_qtr/q9/pdq-matlab-2957-31713/'; ...
                };

            for n = 1:numel(subDirs)
                srcDir = fullfile(srcRootDir, subDirs{n});
                destDir = fullfile(destRootDir, caseList{caseIdx}, subDirs{n});        
                [status,message] = create_case(srcDir, destDir);
                if ~status
                    warning(message);
                end
            end
            
           
            
        case 'variable_number_of_channels'            
            %
            % Cases tested:
            %
            % 1. Varying numbers of channels available
            %
            subDir = 'ref_data_by_qtr/q9/pdq-matlab-2957-31713/';
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});

            channels = [0 2 5 57 79];
            
            load( fullfile(srcDir, pdqInputFileName) );
            availableChannels = find(pdqval_get_valid_channels(inputsStruct));
            nAvailableChannels = length(availableChannels);
            clear('inputsStruct');
            
            % Get root taskfile directory name for test cases
            while (srcDir(end) == '/')
                srcDir(end) = []; % strip trailing slashes
            end
            [dummy, destSubDirBasename, ext] = fileparts(srcDir);
            
            % Handle directory names that contain a '.'
            if ~isempty(ext)
                destSubDirBasename = strcat(destSubDirBasename, ext);
            end

            % Loop for each test case
            nCases = length(channels);
            for n = 1:nCases
                nChannels = channels(n);

                % Select channels to retain
                retainFlags = false(84,1);

                status = true;              
                if nChannels >= 1
                    if nChannels > nAvailableChannels
                        warning('Number of channels requested is greater than total available.');
                        status = false;
                        continue;
                    end
                    permInd = randperm(nAvailableChannels);
                    retainIndices = permInd(1:nChannels);
                    retainFlags(availableChannels(retainIndices)) = true;  
                end
                
                % Specify whether history should be removed.
                clearHistory = true;

                % Make a directory for this test case and copy the required task files
                destSubDir = fullfile(destDir, [destSubDirBasename, '_channels_', num2str(nChannels)]);
                [status, message] = create_case(srcDir, destSubDir, retainFlags, clearHistory);
                if any(~status)
                    warning(['Case: ', caseList{caseIdx}, message]);                
                end

            end
            
            
%         case 'taskfiles_with_gaps'
%             %
%             % Cases tested:
%             %
%             % 1. gaps in time series
%             % 2. Gappy reference data resulting in KSOC-855
%             %
%             subDirs = { ...
%                 'gaps/pdq-matlab-1503-22676/'; ...
%                 'gaps/pdq-matlab-1522-22695/'; ...
%                 'gaps/pdq-matlab-1523-22696/'; ...
%                 'gaps/pdq-matlab-1905-25998/'; ... 
%                 'gaps/pdq-matlab-1926-26019/'; ...
%                 'gaps/pdq-matlab-1927-26020/'; ...  
%                 'gaps/pdq-matlab-1970-26046/'; ...
%             };
%                 
%             for n = 1:numel(subDirs)
%                 srcDir = fullfile(srcRootDir, subDirs{n});
%                 destDir = fullfile(destRootDir, caseList{caseIdx}, subDirs{n});        
%                 [status,message] = create_case(srcDir, destDir);
%                 if ~status
%                    warning(message);
%                 end
%             end

            
        case 'gapped_channels'
            %
            % Cases tested:
            %
            % 1. Two channels: one containing only gaps and the other data
            % 
            subDir = 'ref_data_by_qtr/q9/pdq-matlab-3036-32532/';
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});

            modouts = [42 43];
            retainFlags = false(84,1);
            retainFlags(modouts) = true;
            clearHistory = true;

            [status,message] = create_case(srcDir, destDir, retainFlags, clearHistory);
            
            if status
                load(fullfile(destDir, pdqInputFileName));
                inputsStruct = pdqval_gap_modouts_and_cadences(inputsStruct, modouts);
                save(fullfile(destDir, pdqInputFileName), 'inputsStruct');
            else
                warning(message);
            end
                        

        case 'gapped_cadences'
            %
            % Cases tested:
            %
            % 1. Gapped cadence over 4 available channels
            % 
            subDir = 'ref_data_by_qtr/q9/pdq-matlab-3036-32532/';
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});

            cadences = [1];
            modouts = [42];
            retainFlags = false(84,1);
            retainFlags(modouts) = true;
            clearHistory = true;

            [status,message] = create_case(srcDir, destDir, retainFlags, clearHistory);
            
            if status
                load(fullfile(destDir, pdqInputFileName));
                inputsStruct = pdqval_gap_modouts_and_cadences(inputsStruct, modouts, cadences);
                save(fullfile(destDir, pdqInputFileName), 'inputsStruct');
            else
                warning(message);
            end

                
        case 'time_order'
            %
            % Cases tested:
            %
            % 1. Cadences out of time order
            %
            % Note that this test case merely enables confirmation that 
            % both versions of PDQ do the same thing when start times are
            % jumbled. 
            %
            subDir = 'ref_data_by_qtr/q9/pdq-matlab-2957-31713/';
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});

            modouts = [42];
            retainFlags = false(84,1);
            retainFlags(modouts) = true;
            clearHistory = true;

            [status,message] = create_case(srcDir, destDir, retainFlags, clearHistory);

            if status
                load(fullfile(destDir, pdqInputFileName));
                
                if ~isempty(inputsStruct.stellarPdqTargets)
                    nNewCadences = length(inputsStruct.stellarPdqTargets(1).referencePixels(1).timeSeries);
                    nTotalCadences = length(inputsStruct.pdqTimestampSeries.startTimes);
                    newCadenceIndices = (nTotalCadences - nNewCadences):nTotalCadences;
                    timeStamps = inputsStruct.pdqTimestampSeries.startTimes();
                    jumbled = newCadenceIndices(randperm(length(newCadenceIndices)));
                    inputsStruct.pdqTimestampSeries.startTimes(newCadenceIndices) ...
                        = inputsStruct.pdqTimestampSeries.startTimes(jumbled);
                end
                
                save(fullfile(destDir, pdqInputFileName), 'inputsStruct');
            else
                warning(message);
            end

        case 'anomalous_values'
            %
            % Cases tested:
            %
            % 1. Anomolous values in Q4 reference data, resulting in
            %    KSOC-610
            %
            subDir = 'ref_data_by_qtr/q4/pdq-matlab-1017-17470-r6.0/';
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});

            [status,message] = create_case(srcDir, destDir);
            if ~status
               warning(message);
            end
            
               
        case 'random_extreme_values'
            %
            % Cases tested:
            %
            % 1. Random extreme or unexpected pixel values
            %
            subDir = 'ref_data_by_qtr/q9/pdq-matlab-2957-31713/';
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});

            modouts = [42];
            retainFlags = false(84,1);
            retainFlags(modouts) = true;
            clearHistory = true;

            [status,message] = create_case(srcDir, destDir, retainFlags, clearHistory);
            
            if status
                load(fullfile(destDir, pdqInputFileName));

                modules = [];
                outputs = [];
                template = pdqval_init_data_point_struct();
                dataPoints = pdqval_find_data_points_in_input_struct(inputsStruct, template);
                
                fhandle = @add_noise_to_data_point;
                dataPoints = arrayfun(fhandle, dataPoints);
                
                inputsStruct = pdqval_insert_data_points_in_input_struct(inputsStruct, dataPoints);
                
                save(fullfile(destDir, pdqInputFileName), 'inputsStruct');
            else
                warning(message);
            end

                
            
            
        case 'pointing_errors'
            %
            % Cases tested:
            %
            % 1. Pointing errors
            %
            subDir = 'ref_data_by_qtr/q2/keep--pdq-matlab-100-6480-8pixelsoff/'; % 8-pixel pointing error
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});

            [status,message] = create_case(srcDir, destDir);
            if ~status
               warning(message);
            end

            
        case 'missing_collateral'
            %
            % Cases tested:
            %
            % 1. Collateral pixels unavailable on four available  channels
            %
            subDir = 'ref_data_by_qtr/q9/pdq-matlab-2957-31713/';
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});

            modouts = [42];
            retainFlags = false(84,1);
            retainFlags(modouts) = true;
            clearHistory = true;
            
            [status,message] = create_case(srcDir, destDir, retainFlags, clearHistory);

            if status
                load(fullfile(destDir, pdqInputFileName));
                
                modules = [];
                outputs = [];
                targs = pdqval_find_targets(inputsStruct, 'PDQ_COLLATERAL', modules, outputs);
                inputsStruct = pdqval_prune_targets(inputsStruct, targs, false);

                save(fullfile(destDir, pdqInputFileName), 'inputsStruct');
            else
                warning(message);
            end

            
        case 'dynamic_range_only'
            %
            % Cases tested:
            %
            % 1. Dynamic range targets ONLY on mod.outS 2.1, 20.2.
            %    All targets on mod.outS 6.1, 10.3, 12.2, 24.3
            %
            subDir = 'ref_data_by_qtr/q9/pdq-matlab-2957-31713/';
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});

            modouts = [1; 13; 31; 38; 70; 83];
            retainFlags = false(84,1);
            retainFlags(modouts) = true;
            clearHistory = true;

            [status,message] = create_case(srcDir, destDir, retainFlags, clearHistory);

            if status
                load(fullfile(destDir, pdqInputFileName));
                                
                % Prune targets.
                findMatchingTargets = false; % Find targets that do *not* match.
                targs1  = pdqval_find_targets(inputsStruct, 'PDQ_DYNAMIC_RANGE', 2, 1,  findMatchingTargets);
                targs70 = pdqval_find_targets(inputsStruct, 'PDQ_DYNAMIC_RANGE', 20, 2, findMatchingTargets);
                targs   = [targs1; targs70];
                inputsStruct = pdqval_prune_targets(inputsStruct, targs);

                % Update the input file.
                save(fullfile(destDir, pdqInputFileName), 'inputsStruct');
            else
                warning(message);
            end
            
            
        case 'missing_background'
            %
            % Cases tested:
            %
            % 1. Background targets unavailable on four available channels
            %
            subDir = 'ref_data_by_qtr/q9/pdq-matlab-2957-31713/';
            srcDir = fullfile(srcRootDir, subDir);
            destDir = fullfile(destRootDir, caseList{caseIdx});
            
            modouts = [42];
            retainFlags = false(84,1);
            retainFlags(modouts) = true;
            clearHistory = true;
            
            [status,message] = create_case(srcDir, destDir, retainFlags, clearHistory);

            if status
                load(fullfile(destDir, pdqInputFileName));

                modules = [];
                outputs = [];
                targs = pdqval_find_targets(inputsStruct, 'PDQ_BACKGROUND', modules, outputs);             
                inputsStruct = pdqval_prune_targets(inputsStruct, targs, false);

                save(fullfile(destDir, pdqInputFileName), 'inputsStruct');
            else
                warning(message);
            end


%         case 'downselected_stellar'
%             %
%             % Cases tested:
%             %
%             % 1. Downselected stellar targets
%             %
%             if ~exist(stellarTargetFile)
%                 continue
%             end
%             
%             subDir = 'ref_data_by_qtr/q9/pdq-matlab-2957-31713/';
%             srcDir = fullfile(srcRootDir, subDir);
%             destDir = fullfile(destRootDir, caseList{caseIdx});
% 
%             [status,message] = create_case(srcDir, destDir);
%             if status
%                 load(fullfile(destDir, pdqInputFileName));
%                 
%                 modules = [];
%                 outputs = [];
%                 targs = pdqval_find_targets(inputsStruct, 'PDQ_STELLAR', modules, outputs);             
%                 inputsStruct = pdqval_prune_targets(inputsStruct, targs, false);
%                 inputsStruct = pdqval_downselect_targets_from_input_struct(inputsStruct, stellarTargetFile);
% 
%                 save(fullfile(destDir, pdqInputFileName), 'inputsStruct');
%             else
%                 warning(message);
%             end
            
        otherwise
            warning(['Unrecognized test case: ' caseList{caseIdx}]);
    end
    
end

return




%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create and populate a test case directory, copy the relevant spice files
% to a common directory, and set spice file pointer in the pdqInputStruct.
function [status, message] = create_case(srcDir, destDir, channels, clearHistory)

    fprintf(['**********************************************************************\n']);
    fprintf(['*\n']);
    fprintf(['* Creating test case ', destDir, '\n']);
    fprintf(['*\n']);
    fprintf(['**********************************************************************\n']);

    inputFilename = 'pdq-inputs-0.mat';
    message = '';
    
    if ~exist('clearHistory', 'var')
        clearHistory = false;
    end

    if ~exist('channels', 'var') || isempty(channels)
        channels = true(84,1);
    end
    
    if exist(destDir,'dir') 
        rmdir(destDir,'s');
    end

    status = mkdir(destDir);
    if (status ~= 1)
        message = ['Could not create directory ', destDir];
        return;
    end

    status = copyfile(fullfile(srcDir, inputFilename), destDir);
    if (status ~= 1)
        message = ['Copy operation failed for file ', inputFilename];
        rmdir(destDir, 's');
        return;
    end
    fileattrib(fullfile(destDir, inputFilename),'+w','a'); % Make sure file is writable
     
    % Load the PDQ input data struct.
    load(fullfile(destDir, inputFilename));
    
    % Prune all targets from the specified channels.
    inputsStruct = pdqval_prune_modouts_from_pdqInputStruct(inputsStruct, channels);  
    
    % Clear any history, if flags are set.
    if clearHistory
        inputsStruct = clear_history_from_input_struct(inputsStruct);
    end

    % Save the modified PDQ input struct.
    save(fullfile(destDir, inputFilename), 'inputsStruct');
    
    % Copy the required PRF files.
    for n = 1:length(channels)
        prfFilename = inputsStruct.prfModelFilenames{n};
        if ~isempty( strtrim(prfFilename) )
            status = copyfile( fullfile(srcDir, prfFilename), destDir);
            if ~status
                message = ['Could not copy PRF file ', fullfile(srcDir, prfFilename)];
                rmdir(destDir, 's');
                return;
            end
        end
    end
    
return

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
function pdqDataStruct = clear_history_from_input_struct(pdqDataStruct)
    emptyTsStruct = struct( ...
        'values',        [], ...
        'gapIndicators', [], ...
        'uncertainties', []  ...
        );
    
    historyStruct = pdqDataStruct.inputPdqTsData;
    
    fn = fieldnames(historyStruct);
    for i = 1:numel(fn)
        if ismember(fn{i}, {'pdqModuleOutputTsData','cadenceTimes'})
            historyStruct.(fn{i}) = [];
        else
            historyStruct.(fn{i}) = emptyTsStruct;
        end
    end
    
    pdqDataStruct.inputPdqTsData = historyStruct;
return


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Add zero-mean, high (50000) amplitude noise to a data point.
function dataPoint = add_noise_to_data_point(dataPoint)

    dataPoint.value = dataPoint.value + 100000*rand(1) - 50000;

return

