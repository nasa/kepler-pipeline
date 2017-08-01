function [paths, status, results] = pdqval_compare(productionFileName, plannedFileName, testPathsFile)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function status = pdqval_compare(productionFileName, plannedFileName, testPathsFile)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
% Compare the PDQ results in each of the designated test case directories.
% If none are specified, compare any results in directories under the
% current working directory.
%
% Inputs:
%     productionFileName : string specifying the name of the file
%                     containing results from the production version of
%                     PDQ. This name is assumed to be the same in all test
%                     case directories. 
%
%     plannedFileName : string specifying the name of the file containing
%                     results from the production version of PDQ. This name
%                     is assumed to be the same in all test case
%                     directories.  
%
%     testPathsFile : An ASCII text file containing absolute path names for
%                     all PDQ results files to be processed, one file name
%                     per line. If not specified, a file will be created
%                     that contains the paths of all pdq results files under
%                     the current directory.
%     
% Outputs:
% 
%     paths         : A list of directories processed.
%
%     status        : status(n) is set to 'true' if the comparison was
%                     successfully performed on files in directory
%                     paths{n}, and 'false' otherwise.
%
%     results       : results(n) is set to 'true' if the contents of the
%                     output structures in directory path{n} are identical
%                     and 'false' otherwise. If status(i) = 'false' (the
%                     comparison did not complete successfully) then 
%                     results(i) will be given a default value of 'false'.
%
% Dependencies:
%     Uses the UNIX 'find' utility to obtain a list of directories to
%     process.
%
% RLM, 4/18/2011
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
DEFAULT_TEST_PATHS_FILENAME = 'test_paths.tmp';
RESULTS_SUB_DIR = 'comparison_plots';

if ~exist('testPathsFile', 'var')
    command = ['!/bin/bash -c ''find `pwd` -name ', productionFileName, ...
               ' -print > ', DEFAULT_TEST_PATHS_FILENAME, ''''];
    eval(command);
    testPathsFile = DEFAULT_TEST_PATHS_FILENAME;
end
  
%--------------------------------------------------------------------------
% Open file, read paths, and check for existence of files 
%--------------------------------------------------------------------------
fid = fopen(testPathsFile);
paths = {};
while ~feof(fid) 
    p = fgetl(fid);
    if ~isempty(p) 
        if p(1) ~= -1 && exist(p,'file');
            paths = [paths; fileparts(p)]; 
        end
    end
end
fclose(fid);

% Prune paths if both input files aren't present.
n = 1;
while n <= numel(paths)
    if ~exist(fullfile(paths{n},productionFileName),'file') ... 
            || ~exist(fullfile(paths{n},plannedFileName),'file')
        paths(n) = [];
    else
        n = n + 1;
    end
end

nPaths = numel(paths);

if nPaths < 1
    paths = [];
    status = [];
    results = [];
    return
end


%--------------------------------------------------------------------------
% Loop for each pair of inputs
%
% We are changing the current working directory. If an exception occurs we
% need to make sure the original state is restored, so the main loop is
% enclosed in a try-catch block.
%--------------------------------------------------------------------------
originalPath = path;
testDir = pwd;

status = true(nPaths, 1);
results = false(nPaths, 1);
try
    for n = 1:nPaths

        % Include the input directory in the Matlab search path
        addpath(paths{n});
        
        resultsDir = fullfile(paths{n}, RESULTS_SUB_DIR);
        if ~mkdir(resultsDir)
            error('Unable to create temporary directory.');
        end
        cd(resultsDir);

        % Load the two pdqOutputStructs
        load(productionFileName);
        pdqOutputStructProduction = pdqOutputStruct;
        clear pdqOutputStruct;
        
        load(plannedFileName);
        pdqOutputStructPlanned = pdqOutputStruct;
        clear pdqOutputStruct;
        
        % compare results
        lasterror('reset');

        try
            construct_pdq_pipeline_runs_comparison_plots( ...
                pdqOutputStructProduction, pdqOutputStructPlanned, ...
                'Production', 'Planned');
            
            % Check for anomaly files
            results(n) = isempty(dir('*Anomaly_Report.txt'));
        catch
            print_error_info();
            status(n) = false;
        end

        errorThrown = lasterror();
        if ~isempty(errorThrown.message)
            print_error_info();
            status(n) = false;
        end
        
        % Remove the input directory from the Matlab search path
        path(originalPath);

    end
catch
    print_error_info();
    status(n:end) = false;
end

%--------------------------------------------------------------------------
% Restore original state
%--------------------------------------------------------------------------
path(originalPath);
cd(testDir);

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
        

        