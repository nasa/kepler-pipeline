function [paths, status, results] = pdqval_process_cases_old_report(versionStr, spiceFileDir, testPathsFile)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paths, status, fileFlags] = pdqval_process_cases_old_report(versionStr, spiceFileDir, testPathsFile)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
% This should be a one-time use function to address the special case of 
% PDQ testing across the transition from report generation with the Matlab
% Report Generator to Bill's Latex-based approach.
% ---------
% Use the version of pdq_matlab_controller() currently in the Matlab path
% to process either all PDQ input files in the sub tree, starting from the
% current working directory, or all input files in the directories listed
% in testPathsFile. In the interest of saving disk space, this function
% creates only the files 'pdqOutputStruct.mat' and selected report files.
%
% Inputs:
%
%     versionStr    : A string specifying the version of PDQ being run,
%                     usually either 'Production' or 'Planned'. This is
%                     appended to output file names to distinguish those
%                     created by different versions.
%
%     spiceFileDir  : A directory containing the spice files for all test
%                     cases. The default value is '[]', in which case the 
%                     spice file directories specified in the input
%                     structures are not modified. (default=[])
%
%     testPathsFile : An ASCII text file containing absolute path names for
%                     all PDQ input files to be processed, one file name
%                     per line. If not specified, a file will be created
%                     that contains the paths of all pdq input files under
%                     the current directory.
%     
% Outputs:
%
%     paths         : A list of directories processed.
%
%     status        : An array of flags indicating for each input whether 
%                     PDQ succeeded without throwing errors (1) or not (0).
%
%     results       : An Nx3 array of flags indicating for each path
%                     whether output files were successfully created (1) or
%                     not (0). The ordering is: [outputStruct report1
%                     report2 ...]
%
% Dependencies:
%     Uses the UNIX 'find' utility to obtain a list of directories to
%     process.
%
% Notes:
%     It is important to let this function run to completion since it
%     modifies the Matlab path and the shell variable LD_LIBRARY_PATH. It
%     also sets up a temporary directory that may be left hanging around
%     upon early termination. 
%
% RLM, 5/16/2011
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

%--------------------------------------------------------------------------
% Configure
%--------------------------------------------------------------------------
INPUT_STRUCT_FILENAME  = 'pdq-inputs-0.mat';
OUTPUT_STRUCT_FILENAME = 'pdqOutputStruct.mat';
DEFAULT_TEST_PATHS_FILENAME = 'test_paths.tmp';
N_CHANNEL_REPORTS = 1;

originalDir = pwd;

if ~exist('spiceFileDir', 'var')
  spiceFileDir = [];
end

if ~exist('testPathsFile', 'var')
    command = ['!/bin/bash -c ''find `pwd` -name ', INPUT_STRUCT_FILENAME, ...
               ' -print > ', DEFAULT_TEST_PATHS_FILENAME, ''''];
    eval(command);
    testPathsFile = DEFAULT_TEST_PATHS_FILENAME;
end
  
%--------------------------------------------------------------------------
% Open file and read paths 
%--------------------------------------------------------------------------
fid = fopen(testPathsFile);
paths = {};
while ~feof(fid) 
    p = fgetl(fid);
    if ~isempty(p) 
        if p(1) ~= -1 && exist(p,'file')
            paths = [paths; fileparts(p)];
        end
    end
end
fclose(fid);

nPaths = numel(paths);

if nPaths < 1
    paths = [];
    status = [];
    results = [];
    return
end


%--------------------------------------------------------------------------
% Set environment and working directory
%--------------------------------------------------------------------------
originalPath = path;

% Create a temporary directory and move to it
tmp = tempname;
if ~mkdir(tmp)
    error('Unable to create temporary directory.');
end
cd(tmp);

%--------------------------------------------------------------------------
% Loop for each input struct
%
% We are changing environment variables, changing the current working
% directory, and creating a scratch directory. If an exception occurs we
% need to make sure the original state is restored. Therefore the main loop
% is enclosed in a try-catch block.
%
% Since one of our goals is to test whether PDQ throws errors, we keep
% going if it does. However, if an error occurs in the TESTING code, we
% stop and set status=0 for all unprocessed cases.
%--------------------------------------------------------------------------
status = true(nPaths, 1);
results = false(nPaths, N_CHANNEL_REPORTS + 2);
fprintf('>>>>> Start time = %s\n', datestr(clock)); % Write start time to diary

try
    for n = 1:nPaths
                
        fprintf(['**********************************************************************\n']);
        fprintf(['*\n']);
        fprintf(['* Processing test case ', paths{n}, '\n']);
        fprintf(['*\n']);
        fprintf(['**********************************************************************\n']);
        
        % Include the input directory in the Matlab search path
        addpath(paths{n});

        % Load the input and set spice file directory, if specified
        load(INPUT_STRUCT_FILENAME);
        if ~isempty(spiceFileDir);
            inputsStruct.raDec2PixModel.spiceFileDir = spiceFileDir;
        end

        % Run PDQ and detect any errors thrown
        lasterror('reset');

        try
            outStruct = pdq_matlab_controller(inputsStruct);
            %outStruct = dummy_test_function();
            %error('test');
        catch
            print_error_info();
            status(n) = false;
        end

        errorThrown = lasterror();
        if ~isempty(errorThrown.message)
            print_error_info();
            status(n) = false;
        end

        % If successful, move results to test directory
        if status(n)

            % Output structure
            srcFile = fullfile(tmp,OUTPUT_STRUCT_FILENAME);
            if exist(srcFile,'file')
                destFile = fullfile(paths{n}, modify_file_name(OUTPUT_STRUCT_FILENAME, versionStr));
                [success, message] = movefile(srcFile, destFile);
                if success
                    results(n,1) = true;
                end
            end

            
            % Make a list of report files to move.
            reportFileNames = {'PDQ_Summary_Report.pdf'};
            channels = find( pdqval_get_valid_channels(inputsStruct) );
            for k = 1:min(N_CHANNEL_REPORTS, numel(channels))
                reportFileNames(k+1) = {channel_report_filename(channels(k))};
            end

            % Move PDF reports
            for k = 1:numel(reportFileNames)
                srcFile = fullfile(tmp,reportFileNames{k});
                destFile = fullfile(paths{n}, modify_file_name(reportFileNames{k}, versionStr));
                [success, message] = movefile(srcFile, destFile);
                if success
                    results(n,k+1) = true;
                end
            end

        end

        % Remove the input directory from the Matlab search path
        path(originalPath);

        % Clean temp directory and workspace
        clear('inputsStruct');

        D = dir(tmp);
        for k = 1:numel(D)
            if ~strcmp(D(k).name, '.') && ~strcmp(D(k).name, '..')
                if D(k).isdir
                    rmdir(D(k).name,'s');
                else
                    delete(D(k).name);
                end
            end
        end
        
        % Clear class definitions, but preserve variables
        save( 'ridiculous_workaround.mat' );
        clear classes
        load( 'ridiculous_workaround.mat' );
        delete( 'ridiculous_workaround.mat' );
    end
catch
    print_error_info();
    status(n:end) = false;
    results(n:end,:) = false;
end

fprintf('>>>>> End time = %s\n', datestr(clock)); % Write completion time to diary

%--------------------------------------------------------------------------
% Restore original state
%--------------------------------------------------------------------------
path(originalPath);
cd(originalDir);
rmdir(tmp,'s');

return

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
% Generate a channel report file name, given a channel index
function name = channel_report_filename(channel)
    [module, output] = convert_to_module_output( channel );
    name = strcat('PDQ_Module_', num2str(module), '_Output_', ...
        num2str(output),'_ModOut_', num2str(channel),'_Report.pdf');
return


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
% Append a string to a file name while retaining the extension, if any.
function outName = modify_file_name(inName, modifier)
    [dummy, name, ext] = fileparts(inName);
    outName = [name, '_', modifier, ext];
return
               

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
% Print contents of lasterror
function print_error_info()
    errorThrown = lasterror();
    disp(errorThrown.message);
    disp(errorThrown.identifier);
    stackLength = length(errorThrown.stack);
    for jStack = 1:stackLength
        disp(errorThrown.stack(jStack))
    end
return

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
% Function to create an empty output file. Useful for testing whether
% pdqval_process_cases is functioning correctly without waiting for PDQ to
% run.
function outStruct = dummy_test_function()
    fid = fopen('pdqOutputStruct.mat','w');
    fclose(fid);
    outStruct = struct;
return

