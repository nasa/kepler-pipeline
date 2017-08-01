%*************************************************************************************************************
% classdef duaghterDispatcherClass
%
% Used to create 'daughter' processes for use within a 'mother' matlab session.
%
% For debugging purposes one would not want to spawn daughter matlab processes so the option exists to run everything in this matlab session.
%
% The initial purpose of this utility is to prevent memory defragmentation. By dispatching daughter matlab processes the memory can be isloated for each
% daughter. When the daughter ends the memory can be released back -- hence lessens fragamentation issues in Matlab.
%
% An instance of thsi class can also be created in the daughter and so when currently in a daughter process this status can also be recorded in this class
% (isInDaughter and daughterTaskString).
%
% Right now only one process can be dispatched at a time and no recursion.  TODO: allow for recursion and parallel daughters.
%
% Usage of this class can be a little convoluted. This is due to the Kepler pipeline being run on the NAS where there are no local matlab licenses. So instead
% each CSCI process is actually handled in an executable (e.g. pdc_main) which in turn calls the controller (e.g. pdc_matlab_controller). This means one cannot
% simply spawn a matlab session with the required function call, we must instead call the same executable (e.g. pdc_main) but with an optional argument which is
% passed to the matlab controller (e.g. pdc_matlab_controller) so that the controller knows to run the sub-process. Because of this there are two ways to spawn
% a daughter: 1) as a matlab session or 2) as a matlab executable. Which method you choose is controlled with <obj.doSpawnMatlabSession> and
% <obj.doSpawnMatlabExecutable>. 
%
% The spawning is performed using the system command in Matlab. There is no way to pass complex variables to the spawned matlab session or executable. Therefore
% all required variables are saved to a dispatching file. This file must be read in the daughter process and then the desired arguments to be returned must be
% saved in another dispatch file for loading in the mother matlab session. The dispatch function handles this in the mother. In the daughter you must take care
% of it yourself with the help of two functions: load_dispatched_arguments and save_returning_arguments. This can be performed in a wrapper function such as the
% example below: test_daughter_wrapper.
%
% Also, since the daughter may actually just be a function called in the mother (and not spawned in a daughter) your daughter function needs a way to detect if
% it is actually called in a daughter or just called in the mother. This is can be determined with check_for_dispatch_out_file. If it returns true then this is
% a dispatched function running in a daughter and arguments must be loaded and saved. If it returns false then returned arguments are simply passed back from
% the eval function call in dispatch which calls your function. 
%
% An example of using this class can be found in the test static method: test_daughter_dispatching. Which is also a unit test to confirm the class is functioning
% correctly.
%
%***
%
% Steps to set up daughter dispatching (see test_daughter_dispatching for an example):
%
%   1) Set up your daughter function for use with the dispatching class.  Your daughter function should contain these steps in addtion to the code you want to
%       call (see test_daughter_wrapper for an example): 
%           a) Construct a daughter disptcher in the daughter.  
%           b) Load the dispatched arguments from a file 
%           c) Run your desired command 
%           d) save the returned arguments to a file
%
%   2) Formulate the command string to call during dispatching
%
%   3) Construct a daughterDispatchingObject
%
%   4) Dispatch the daughter (The dispatch function takes care of saving and loading the arguments for the daughter) 
%
%   5) Continue on with your program. Your dispatcher class can be used for multiple daughter but only serially with no recursion.
%
%*************************************************************************************************************
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

classdef pdcDaughterDispatcherClass

properties (Constant)
    MATLABCALLSTRING        = 'matlab -nodisplay -nosplash -r '; % To call a standard non-gui matlab session
    DISPATCHOUTFILENAME     = 'dispatch_out_file.mat';   % Name of the dispatch file for arguments to the daughter
    DISPATCHBACKFILENAME    = 'dispatch_back_file.mat'; % Name of the dispatch file for returned arguments to the mother
    BEGINPROCESSTEXT        = 'BEGIN_SPAWNED_PROCESS'; % the text to first display after spawning a matlab process
end

properties(GetAccess = 'public', SetAccess = 'private')
    dispatchingEnabled          = false; % If true then daughters will be dispatched
    isInDaughter                = false; % If true then we are already in a call to a daughter
    daughterTaskString          = [] % [string] the current task of this daughter
    doSpawnMatlabSession        = false; % If true then spawning matlab session
    doSpawnMatlabExecutable     = false; % For pipeline runs call the Matlab executable
    executableCallString          = []; % The executable that will be called with the system command
end

%*******************************************************************************
methods

%*******************************************************************************
%*******************************************************************************
% Constructor:
%
% Inputs:
%   dispatchingEnabled      -- [logical] if true then processes will be spawned, otherwise run locally
%   daughterTaskString      -- [string] A label for the daughter task (in empty then this is the mother)
%   functionType            -- [string] {'MATLAB' | 'MATLABEXECUTABLE'} are we spawning a session or executable?
%   executableCallString      -- [string] The executable that will be called with the system command (only need to set if functionType = 'MATLABEXECUTABLE');
%

function obj = pdcDaughterDispatcherClass(dispatchingEnabled, daughterTaskString, functionType, executableCallString)

    obj.dispatchingEnabled = dispatchingEnabled;

    if (~isempty(daughterTaskString))
        % We are in a daughter already
        obj.isInDaughter = true;
        obj.daughterTaskString = daughterTaskString;
    else
        obj.isInDaughter = false;
        obj.daughterTaskString = [];
    end

    switch functionType
    case 'MATLAB'
        % Call a standard matlab non-gui session
        obj.doSpawnMatlabSession = true;
        obj.doSpawnMatlabExecutable  = false;
        obj.executableCallString = obj.MATLABCALLSTRING;
    case 'MATLABEXECUTABLE'
        % Call a matlab executable for a pipeline run
        obj.doSpawnMatlabSession = false;
        obj.doSpawnMatlabExecutable  = true;
        obj.executableCallString = executableCallString;
    otherwise
        error('pdcDaughterDispatcherClass: Right now only works with matlab sessions or executables');
    end

end % constructor

%*******************************************************************************
% 
%   This will do three things: 
%   1) Saves all arguments for the spawned function to a .mat file
%   2) spawns the main process
%   3) loads back in the results
%
%   If dispatching is enabled The arguments for the spawned process are handled in one file and the returned arguments on another. 
%   After the dispatch back arguments are loaded the dispatch back file is deleted.
%
%   If dispatching is disabled the command in <commandString> is just called with eval(commandString).
%   NOTE: since when dispatching is disabled this function simply just calls <commandString> one could bypass this dispatcher function and just call your
%   function in your wrapper!
%
% Inputs:
%   commandString       -- [string] the command to issue with spawn_process
%   daughterTaskString  -- [string] The label for the dispatched task
%   dispatchedArguments -- [string OPTIONAL any number] names of any arguments to be passed to the dispatched function
%
% Outputs:
%   returnedArguments   -- [varargout] any returned arguments from the dispatched function
%

function [varargout] = dispatch(obj, commandString, daughterTaskString, varargin)

    % Create local copies of all the passed arguments
    for iArg = 1 : length(varargin)
        eval([varargin{iArg}, ' = evalin(''caller'', varargin{iArg});']);
    end

    % We want to save to files ONLY dispatching is turned on
    if (obj.dispatchingEnabled)

        intelligent_save (obj.DISPATCHOUTFILENAME, 'daughterTaskString', varargin{:});
 
        % Now spawn the process
        success = obj.spawn_process (commandString);
 
        if (~success)
            error('dispatch: failed to spawn process');
        end

        % Load in the returned arguments
        if (~exist(obj.DISPATCHBACKFILENAME, 'file'))
            error('Dispatch back file does not appear to exist!');
        end
        returnedArguments = load(obj.DISPATCHBACKFILENAME); 
 
        % Make sure this dispatch file is from the just dispatched process
        if (~strcmp(daughterTaskString, returnedArguments.daughterTaskString))
            error ('The dispatch back file does not appear to originate from the dispatched processs');
        else
            % This was the correct process so delete back file
            system(['rm ', obj.DISPATCHBACKFILENAME]);
        end
 
        if (~exist('returnedArguments', 'var'))
            error ('Returned arguments do not appear to exist!');
        end
        
        returnedArguments = rmfield(returnedArguments, 'daughterTaskString');
        returnedFieldnames = fieldnames(returnedArguments);
        for iArg = 1 : nargout
            varargout{iArg} = returnedArguments.(returnedFieldnames{iArg});
        end

    else
        % Just call the command in Matlab
        % Dispatching turned off so just call the function but we need to keep track of all the returned arguments
        
        varargout = cell(nargout,1);
        [varargout{1:nargout}] = eval(commandString);

    end

end % dispatch

%*******************************************************************************
% Loads in the dispatched arguments in the daughter process. 
%
% **This function will then delete the dispatch out file**

function [dispatchedArguments] = load_dispatched_arguments (obj)

    if (~obj.isInDaughter)
        error('Can only load dispatched arguments if in the daughter process');
    end

    % Load in the dispatched arguments
    if (~exist(obj.DISPATCHOUTFILENAME, 'file'))
        error('Dispatch out file does not appear to exist!');
    end
    dispatchedArguments = load(obj.DISPATCHOUTFILENAME); 

    % Make sure this dispatch file is from the just dispatched process
    if (~strcmp(obj.daughterTaskString, dispatchedArguments.daughterTaskString))
        error ('The dispatch out file does not appear to correpsond to this spawned process');
    else
        % This was the correct process so delete back file
        system(['rm ', obj.DISPATCHOUTFILENAME]);
    end

end % load_dispatched_arguments

%*******************************************************************************
% Saves the returning arguments in the daughter process
%
% Inputs:
%   dispatchedArguments -- [string OPTIONAL any number] names of any arguments to be passed to the dispatched function
%   

function [] = save_returning_arguments (obj, varargin)

    % we must already be in a daughter to save returning arguments
    if (~obj.isInDaughter)
        error('save_returning_arguments: We are not in a daughter!');
    end

    for iVar = 1 : length(varargin)
        eval([varargin{iVar}, ' = evalin(''caller'', varargin{iVar});']);
    end
    daughterTaskString = obj.daughterTaskString;
    intelligent_save(obj.DISPATCHBACKFILENAME, 'daughterTaskString', varargin{:});

end % save_returning_arguments    

%*******************************************************************************
% Trims all returned Matlab text before the obj.BEGINPROCESSTEXT

function [string] = trim_matlab_header(obj, string)

    string = string(strfind(string, obj.BEGINPROCESSTEXT)+length(obj.BEGINPROCESSTEXT):end);

end % trim_matlab_header

end % methods

%*******************************************************************************
%*******************************************************************************
%*******************************************************************************
methods(Access = 'private')

%*******************************************************************************
% Internal use, handles the actuall spawning of the process. Thsi is not called if dispatching is NOT enabled.
%
% Inputs: 
%   commandString       -- [string] the command to issue in the process to be called from obj.executableCallString
%
% Outputs:
%   success             -- [logical] true if command successfuly ran

function [success] = spawn_process (obj, commandString)

    success = false;

    if (obj.dispatchingEnabled)
        if (obj.doSpawnMatlabSession)
            systemCall = [obj.executableCallString, '" display(''',obj.BEGINPROCESSTEXT, ''');', commandString, '"'];
           %[status, results] = system (systemCall);
            [status] = system (systemCall);
        elseif (obj.doSpawnMatlabExecutable)
            % Otherwise we are calling a Matlab executable
            systemCall = [obj.executableCallString, ' ', commandString];
           %[status, results] = system(systemCall);
            [status] = system(systemCall);
        end
    
        if (status == 0)
            success = true;
           %results = obj.trim_matlab_header(results);
           %disp(results);
        else
            displayText = ['pdcDaughterDispatcherClass: failed to spawn process: ', systemCall];
           %disp(displayText);
           %disp(results);
            error(displayText);
        end

    else
        error('SPAWN_PROCESS: dispatching turned off, nothing can be done!');
        success = false;
    end

end % spawn_process

%*******************************************************************************
% This is the function called by the dispatcher unit test, All it does is create some matrices.
% 

function [magicMatrix, onesMatrix] = testing_function (obj, magicOrder, onesOrder)

    magicMatrix = magic(magicOrder);

    onesMatrix = ones(onesOrder);

end

end % private methods

%*******************************************************************************
%*******************************************************************************
%*******************************************************************************
methods(Static)

%*******************************************************************************
% Unit test to test functionality of daughter dispatching.
%
% It first tries dispatching a daughter and then just evaluates the command in this matlab session. Then it compares the returned results to verify they both
% ran.
%
% TODO: also test the ussage of an executable
%
% To test call
%   pdcDaughterDispatcherClass.test_daughterDispatching
%

function [success] = test_daughter_dispatching ()

    disp('Comparing the same Matlab process from both a local and spawned Matlab session...');

    magicOrder = 5;
    onesOrder = 5;

    daughterTaskString = 'testingDaughterDispatching';
    commandString = ['pdcDaughterDispatcherClass.test_daughter_wrapper(''', daughterTaskString, ''')'];
 
    %********
    % The dispatching run

    % We declare we are in the mother by setting daughterTaskString to empty set
    dispatchingEnabled = true;
    daughterDispatcher = pdcDaughterDispatcherClass(dispatchingEnabled, [], 'MATLAB', []);

    % Spawn a daughter passing the needed arguments
    [dispatchedMagicMatrix dispatchedOnesMatrix] = daughterDispatcher.dispatch(commandString, daughterTaskString, 'magicOrder', 'onesOrder');

    %********
    % The non-dispatching run

    % Try again but with dispatching disabled and see if we get the same results
    clear daughterDispatcher;
    dispatchingEnabled = false;
    daughterDispatcher = pdcDaughterDispatcherClass(dispatchingEnabled, [], 'MATLAB', []);

    % just call the command passing the needed arguments via commandString
    daughterTaskString = 'testingNoDispatching';
    commandString = ['pdcDaughterDispatcherClass.test_daughter_wrapper(''', daughterTaskString, ''', magicOrder, onesOrder)'];

    % NOTE: Alternatively here we could just call daughterDispatcher.testing_function directly! But, here I am using the formal method to test the
    % functionality.
    [localMagicMatrix localOnesMatrix] = daughterDispatcher.dispatch(commandString, daughterTaskString, 'magicOrder', 'onesOrder');

    % Compare the results from the two runs.
    if (all(all(dispatchedMagicMatrix == localMagicMatrix)) && all(all(dispatchedOnesMatrix == localOnesMatrix)))
        disp('***');
        display('Success! Daughter Dispatching works!')
        success = true;
    else
        display('DOH! Daughter Dispatching does not seem to work!')
        success = false;
    end


end % test_daughter_dispatching

%*******************************************************************************
% This is a wrapper that is called in the daughter to handle IO for the actuall command to be run (testing_function)

function [magicMatrix, onesMatrix] = test_daughter_wrapper (incomingDaughterTaskString, magicOrder, onesOrder)

    magicMatrix = [];
    onesMatrix  = [];
            
    % This is the daughter, but only if dispatching is enabled. So, check for the dispatch out file
    dispatchingEnabled = pdcDaughterDispatcherClass.check_for_dispatch_out_file;
    daughterDispatcher = pdcDaughterDispatcherClass(dispatchingEnabled, incomingDaughterTaskString, 'MATLAB', []);

    % Load in the needed arguments from the dispatch file
    if (dispatchingEnabled)

        disp('***');
        disp('Now in daughter process...');
        [dispatchedArguments] = daughterDispatcher.load_dispatched_arguments;

        % Call the actual command
        [magicMatrix, onesMatrix] = daughterDispatcher.testing_function(dispatchedArguments.magicOrder, dispatchedArguments.onesOrder);

        % Save the returned arguments
        daughterDispatcher.save_returning_arguments ('magicMatrix', 'onesMatrix');
        % Quit this session so we can proceed with the mother
        quit
    elseif (strcmp('testingNoDispatching', incomingDaughterTaskString));
        disp('***');
        disp('Now in local process...');
        % If magicOrder and onesOrder are directly passed then this is a dispatching disabled system call run
        % We need to just call the command.
        [magicMatrix, onesMatrix] = daughterDispatcher.testing_function(magicOrder, onesOrder);
    else
        error('Unknown task');
    end

end % test_daughter_wrapper

%*******************************************************************************
% This is needed for when potentially in a daughter process we need to check if we really are in a daughter or dispatching is not enabled and we are just
% evaluating the desired commands

function [dispatchingEnabled] = check_for_dispatch_out_file()

    if (exist(pdcDaughterDispatcherClass.DISPATCHOUTFILENAME, 'file'))
        dispatchingEnabled = true;
    else
        dispatchingEnabled = false;
    end

end % check_for_dispatch_out_file

end % static methods


end % classdef duaghterDispatcherClass
