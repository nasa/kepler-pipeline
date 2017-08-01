function groupDir = get_group_dir( csci, channelOrModout, varargin )
%**************************************************************************
% groupDir = get_group_dir(csci, channelOrModout, varargin )
%**************************************************************************
% Given a pipeline instance, return the symbolic link or canonical path to
% the group directory in which the specified data resides. This function
% assumes these links have been created, which is now always done on the
% front end (CAL, PA, PDC), but not necessarily for other components. You
% should verify the existence of a uow/ directory under rootPath if using
% this function to obtain TPS, DV, or other results.
%
% INPUTS
%
%     csci           A string specifying a CSCI. Must be one of the
%                    following (not case-sensitive): 'PDQ','CAL','PA',
%                    'PDC','TPS','DV','PPA','FC','GAR','TAD'.
%     channelOrModout Either an Nx1 array of channel numbers in the range
%                    [1:84] or an Nx2 array of of [module, output] pairs. 
%
%     All remaining inputs are optional attribute/value pairs. Valid
%     attributes and values are: 
%    
%     Attribute      Value
%     ---------      -----
%     'quarter'      An optional quarter (or campaign for K2) number in the
%                    range [0, 17]. If empty or unspecified, the earliest
%                    quarter processed by the pipeline instance is used.
%     'month'        An optional month in the range [1, 3]. If unspecified,
%                    then lowest available month number is used.
%     'rootPath'     The full path to the directory containing task 
%                    directories for the pipeline instance. If unspecified,
%                    the current working directory is used.
%     'returnLink'   If true (the default), return the name of the symbolic
%                    link to the group directory. If false, return the
%                    canonical filename (all symlinks on the path are
%                    evaluated).  
%     'fullPath'     If true (the default), return the full path to the
%                    group directory or its associated symlink. Otherwise
%                    return only the partial path under rootPath.
%
% OUTPUTS
%     groupDir       An N-length cell array of group directories containing
%                    results for the specified channels, quarter (or
%                    campaign), and month.  
% 
% NOTES
%     CSCI task directories are organized as shown below, where each group
%     (g-*) contains results from a single channel and quarter. The uow/
%     directory contains symbolic links to each group directory.
%
%     rootDir/
%     |-.pa-matlab-9244-585448/
%     |  |-.g-0
%     |  |-.g-1
%     |  |-.g-2
%     |
%     |-.pa-matlab-9244-585449/
%     |  |-.g-0
%     |  |-.g-1
%     |
%      -.uow/                        
%        |-.pa-9244-q02m1:m3-02.01 -> rootDir/pa-matlab-9244-585448/g-0
%        |-.pa-9244-q02m1:m3-02.02
%        |-.pa-9244-q02m1:m3-02.03
%        :           :
%
%     See the SOC Wiki for details on UOW symlink formats:
%
% USAGE EXAMPLES
%
% (1) In this example we request the symlinks under the current working
%     directory that point to units of work for campaign 0 modouts 2.1 and
%     6.4: 
%
%     >> cd /path/to/ksop-2020-c0-part2/pa-run2
%     >> groupDir = get_group_dir('pa', [2 1; 6 4], 'quarter', 0, ...
%        'fullPath', false)
%
%     groupDir = 
%
%     'uow/pa-305-q00m2-02.01'
%     'uow/pa-305-q00m2-06.04'
%
% (2) In the next example we request the full canonical filenames for
%     modouts 3.1 and 6.4. Note that since module 3 is not producing data
%     for the K2 mission, the corresponding group directory is empty.
%     
%     >> groupDir = get_group_dir('pa', [3 1; 6 4], 'quarter', 0, ...
%        'returnLink', false)
%
%        groupDir =
%
%        ''
%        '/path/to/ksop-2020-c0-part2/pa-run2/pa-matlab-305-7028/g-0'
%
%**************************************************************************        
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
    QUARTER_FORMAT = '%02d'; % Quarters are specified by two digits.
    MODOUT_FORMAT  = '%02d'; % Modules and outputs are specified by two digits.
    MONTH_FORMAT   = '%01d'; % Months are specified by a single digit.
    
    CSCI_LIST = { 'PDQ'; ...
                  'CAL'; ...
                  'PA' ; ...
                  'PDC'; ...
                  'TPS'; ...
                  'DV' ; ...
                  'PPA'; ...
                  'FC' ; ...
                  'GAR'; ...
                  'TAD'  ...
                };

    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addRequired('csci',                @(s)any(strcmpi(s, CSCI_LIST))     );
    parser.addRequired('channelOrModout',     @validate_channels_and_modouts     );
    parser.addParamValue('quarter',       [], @(x)isempty(x) || isnumeric(x) && x>=0 && x<=17  );
    parser.addParamValue('month',         [], @(x)isempty(x) || isnumeric(x) && x>=1 && x<=3   );
    parser.addParamValue('rootPath',     pwd, @(s)isdir(s)                       );
    parser.addParamValue('returnLink',  true, @(x)islogical(x) );
    parser.addParamValue('fullPath',    true, @(x)islogical(x) );
    parser.parse(csci, channelOrModout, varargin{:});
    
    csciStr     = lower(parser.Results.csci);
    quarter     = parser.Results.quarter;
    month       = parser.Results.month;
    rootPath    = parser.Results.rootPath;
    returnLink  = parser.Results.returnLink;
    fullPath    = parser.Results.fullPath;
        
    if size(channelOrModout, 2) == 2
        modules = channelOrModout(:,1);
        outputs = channelOrModout(:,2);
    else
        [modules, outputs] = convert_to_module_output(channelOrModout);
    end
    
    %----------------------------------------------------------------------
    % Find the requested symbolic links.
    %----------------------------------------------------------------------
    nModOuts   = length(modules);
    groupDir   = cell(nModOuts, 1);
    
    if isempty(quarter)
        quarterStr = '*';
    else
        quarterStr = num2str(quarter, QUARTER_FORMAT);
    end
    
    if isempty(month)
        monthStr = '*';
    else
        monthStr = num2str(month, MONTH_FORMAT);     
    end

    for iModOut = 1:nModOuts
        searchString = strcat(csciStr, '-*-q', quarterStr, 'm', monthStr, '-', ...
                num2str(modules(iModOut), MODOUT_FORMAT), '.', ...
                num2str(outputs(iModOut), MODOUT_FORMAT), '*');
        matches = dir( fullfile(rootPath, 'uow', searchString) );

        % If no matches were found, try eliminating the month specification.
        if isempty(matches)
            searchString = strcat(csciStr,'-*-q', quarterStr, '-', ...
                    num2str(modules(iModOut), MODOUT_FORMAT), '.', ...
                    num2str(outputs(iModOut), MODOUT_FORMAT), '*');
            matches = dir( fullfile(rootPath, 'uow', searchString) );
        end
        
        % Sort matching directories in ascending alphanumeric order. This will
        % key on quarter number and then on month. 
        matches = sort( {matches([matches.isdir]).name} ); 

        % Return an empty string if no matches were found.
        if ~isempty(matches)
            groupDir{iModOut} = fullfile(rootPath, 'uow', matches{1});
        else
            groupDir{iModOut} = '';
        end
    end
    
    %----------------------------------------------------------------------
    % Convert symlinks to canonical filenames if returnLink == false.
    %----------------------------------------------------------------------
    if returnLink == false
        for iModOut = 1:nModOuts
            command = ['readlink -e ', groupDir{iModOut}];
            [status, symlinkContents] = system(command);

            % Only make the substitution if the link contents were 
            % succesfully read, indicated by a return value of '0'.
            if status == 0
                groupDir{iModOut} = deblank(symlinkContents);
            else
                groupDir{iModOut} = '';
            end
        end
    end
    
    %----------------------------------------------------------------------
    % Strip off rootPath from elements in groupDir if fullPath == false
    %----------------------------------------------------------------------
    if fullPath == false
        startInd = length(rootPath) + 1;
        if rootPath(end) ~= '/'
             startInd = startInd + 1;
        end

        for iModOut = 1:nModOuts
            groupDir{iModOut} = groupDir{iModOut}(startInd:end);
        end
    end
end

function isValid = validate_channels_and_modouts(x)
    if size(x, 2) == 1
        isValid = validate_channels(x);
    elseif size(x, 2) == 2
        isValid = validate_modouts(x);
    else
        isValid = false; % x must be N-by-1 or N-by-2.
    end
end

function isValid = validate_channels(x)
    isValid = isnumeric(x) &&  min(size(x)) == 1 ...
        && all(ismember(x, [1:84]));
end

function isValid = validate_modouts(x)
    isValid = size(x,2) == 2 && ...
        all(ismember(x(:,1), [2:24])) && ...
        all(ismember(x(:,2), [1:4]));
end

%********************************** EOF ***********************************
