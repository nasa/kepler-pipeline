%% function [success] = intelligent_save (varargin)
%
% This function is called in exactly the same way as the built-in Matlab
% 'save' function. Therefore one needs only search and replace existing
% calls to save() in order to make code more robust.
%
% Attempts to save large variables to Matlab binary files have caused
% failures in the SOC piepline. It is therefore desirable to recognize and
% act to prevent such failures when possible. Only the HDF5 file format
% (specified with the '-v7.3' option) will support saving variables larger
% than 2GB. This function adds a layer between the user and the Matlab
% save() function, which examines the argument list and will automatically
% attempt to save in HDF5 format under the following conditions:
%
% (1) Neither the '-v7.3' nor the '-append' options are present in the
%     argument list.
% (2) One of the variables named in the argument list is >= 2GB in size, or
%     a failed attempt was made to save without the -v7.3 option.
%
% To clarify the first of these conditions, if the '-append' option is
% supplied, then the format is restricted to that of the existing file. If
% the file doesn't already exist, then the inclusion of the '-append'
% option will cause an error. If the '-v7.3' was specified in the argument
% list, then we are already saving in HDF5 format and nothing more can be
% done to ensure success.
%
% INPUTS
%     varargin : A valid argument list for save().
%
% OUTPUTS
%     success  : True if save was successful. False otherwise.
%
% NOTES
%   - If you'll be appending variables to a file and it's even *possible*
%     that one may be larger than 2GB, it's very important to create that
%     file using the -v7.3 option. This function can do nothing to remedy
%     the situation in which you need to append a large variable to a
%     .mat file that is not already in HDF5 format. 
%   - This function could be expanded to catch other errors as well.
%   - If you modify this function, use the function test_intelligent_save.m
%     to run an extensive battery of tests.
%   - See the following Wikipedia entry for more information about HDF5
%     format: https://en.wikipedia.org/wiki/Hierarchical_Data_Format
%%******************************************************************************
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
function [success] = intelligent_save(varargin)
    GB = 1024 ^ 3;
    HDF5_ARG = '-v7.3'; % Use the HDF5 format to allow variables >= 2GB.
    
    usingAppendMode =  any(strcmpi(varargin, '-append'));
    usingStructMode =  any(strcmpi(varargin, '-struct'));
          
    %----------------------------------------------------------------------
    % Examine arguments.
    %----------------------------------------------------------------------
    % Scan varargin for version options. 
    versionStr = get_version_string(varargin);
    
    % Determine variable sizes. If the '-struct' option was passed, then we
    % skip this step and rely on post-analysis of warning message to
    % decide what to do in the event of a failure.
    maxVarSizeBytes = 0;
    if ~usingStructMode
        for iArg = 1:numel(varargin)
            argStr = varargin{iArg};
            if iArg > 1 % First arg is always the filename.
                if ~isempty(argStr) && argStr(1) ~= '-' ...
                        && evalin('caller', ['exist(''', argStr,''', ''var'')'])
                    s = evalin('caller', ['whos(''', argStr, ''')']);
                    if s.bytes > maxVarSizeBytes;
                        maxVarSizeBytes = s.bytes;
                    end
                end
            end
        end
    end

    % If max variable size is greater than 2GB and we are NOT in append
    % mode, then save with the -v7.3 option. If -v7.3 was already specified
    % in the argument list, then do nothing.
    if ~usingAppendMode && ~strcmp(versionStr, HDF5_ARG) && maxVarSizeBytes > 2*GB
        display('intelligent_save: One or more variables >= 2GB. Saving with -v7.3.');
        versionStr = HDF5_ARG;
    end
    
    %----------------------------------------------------------------------
    % Save 
    %----------------------------------------------------------------------
    % turn of warning echo, save warning state and reset lastwarn.
    S = warning('off', 'all');
    lastwarn(''); % reset the warning message.

    % Make first attempt.
    commandStr = construct_command_str(varargin, versionStr);
    evalin('caller', commandStr);
    
    % Check to see whether the last operation caused a warning. If so, then
    % it may be because a variable is too big for the file format. Try v7.3
    % if it was not used in the first attempt.
    if ~isempty(lastwarn) && ~strcmp(versionStr, HDF5_ARG) && ~usingAppendMode
        display('intelligent_save: Error saving file. Retrying with -v7.3.');
        lastwarn('');
        commandStr = construct_command_str(varargin, HDF5_ARG);
        evalin('caller', commandStr);
   end

    %----------------------------------------------------------------------
    % Determine status and restore warning state.
    %----------------------------------------------------------------------
    % check for a new warning
    if (~isempty(lastwarn))
        display('intelligent_save: Error saving file. No file saved!');
        success = false;
    else
        success = true;
    end
    
    % restore warning state
    warning(S);
end

%%******************************************************************************
function commandStr = construct_command_str(argList, versionStr)

    % If a versionStr argument was supplied, use it to replace any version
    % specification in argList.
    if exist('versionStr', 'var') && ~isempty(versionStr)
        [~, versionArgIndex] = get_version_string(argList);
        if isempty(versionArgIndex)
            argList{end+1} = versionStr;
        else
            argList{versionArgIndex} = versionStr;
        end
    end
    
    argList = strcat({''''}, argList, {''''});
    argStr = sprintf(', %s', argList{:});
    commandStr = sprintf('save(%s)', argStr(3:end) ); %trim leading comma from argStr.
end

%%******************************************************************************
% Find the first valid version option in the argument list. Return the
% empty string if none are found.
function [versionStr, versionArgIndex] = get_version_string(argList)
    VALID_VERSION_OPTIONS = {'-v4','-v6','-v7','-v7.3'};
    versionStr = ''; % Empty versionStr allows save() to use the default.
   
    isVersionArg = ismember(lower(argList), VALID_VERSION_OPTIONS);
    versionArgIndex = find(isVersionArg, 1, 'first');
    if ~isempty(versionArgIndex)
        versionStr = argList{versionArgIndex};
    end
end
