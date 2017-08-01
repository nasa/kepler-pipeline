function  C = reproduce_centroid_metrics_from_target_results( paRootPath, varargin )
%**************************************************************************
% C = reproduce_centroid_metrics_from_target_results( paRootPath, varargin )
%**************************************************************************
% 
%
% INPUTS
%
%     paRootPath     The full path to the directory containing task 
%                    directories for the pipeline instance (this is the
%                    directory containing the uow/ subdirectory). If
%                    unspecified, the current working directory is used.
%
%     All remaining inputs are optional attribute/value pairs. Valid
%     attributes and values are: 
%    
%     Attribute             Value
%     ---------             -----
%     'channelOrModout'     A N-by-1 or N-by-2 array of channels to
%                           examine.
%     'quarterOrCampaign'   A non-negative integer. The paRootPath
%                           directory may contain results for multiple
%                           quarters or campaigns. In such cases you may
%                           specify the quarter or campaign to examine. By
%                           default the lowest numbered quarter or campaign
%                           is processed.
%
% OUTPUTS
%     C            An N-channel struct array containing aggregated centroid
%                  metrics for each channel.
%
% NOTES
%     This function computs centroid metrics from outputs of the TARGETS 
%     processing state. Since SOC 9.3 we are reprocessing all targets,
%     including PPA targets, in the TARGETS processing state.
%
% USAGE EXAMPLES
%     Compute metrics for modouts 18.1 and 13.2:
%
%     >> reproduce_centroid_metrics_from_target_results( paRootPath, ...
%        'channelOrModout', [18, 1; 13, 2] );
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
    
    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addRequired('paRootPath',                        @(s)isdir(s)                       );
    parser.addParamValue('channelOrModout',        [1:84]', @validate_channels_and_modouts     );
    parser.addParamValue('quarterOrCampaign',           [], @(x)isempty(x) || isnumeric(x) && x>=0 );
    parser.parse(paRootPath, varargin{:});
    
    quarterOrCampaign = parser.Results.quarterOrCampaign;
    channelOrModout   = parser.Results.channelOrModout;
    
    nChannels = size(channelOrModout, 1);
            
    groupDirCellArray = get_group_dir( 'PA', channelOrModout, ...
            'rootPath', paRootPath, 'quarter', quarterOrCampaign);
    
    %----------------------------------------------------------------------
    % Process and plot each of the specified channels. 
    %----------------------------------------------------------------------
    for iChannel = 1:nChannels
        channelDir = groupDirCellArray{iChannel};
        
        fprintf('Processing channel %d of %d directory = %s ... \n', ...
            iChannel, nChannels, channelDir);
        
        if isempty(channelDir)
            continue;
        end
        
        subtaskDirs = find_subtask_dirs_by_processing_state(channelDir, 'TARGETS');
        nDirs = numel(subtaskDirs);
        
        metricsThisChannel = [];
        for iDir = 1:nDirs
            
            stDir = subtaskDirs{iDir};
            load( fullfile(channelDir, stDir, 'pa-outputs-0.mat') );
            
            metricsThisSubtask = produce_pa_centroid_metrics( outputsStruct );
            metricsThisChannel = append_metrics(metricsThisChannel, metricsThisSubtask);
            
        end % for iDir ...
        
        if exist('C', 'var')
            C(iChannel) = metricsThisChannel;
        else
            C = metricsThisChannel;
        end
        
    end % for iChannel ...
        
end

%**************************************************************************
function metrics = append_metrics(metrics, metricsToAppend)
    if(isempty(metrics))
        metrics = metricsToAppend;
    end
    metricsToAppend = rmfield(metricsToAppend, {'ccdModule', 'ccdOutput'});
    fName = fieldnames(metricsToAppend);
    for j=1:length(fName)
        metrics.(fName{j}) = [metrics.(fName{j}), metricsToAppend.(fName{j})];
    end
end

%**************************************************************************
function isValid = validate_channels_and_modouts(x)
    if size(x, 2) == 1
        isValid = validate_channels(x);
    elseif size(x, 2) == 2
        isValid = validate_modouts(x);
    else
        isValid = false; % x must be N-by-1 or N-by-2.
    end
end

%**************************************************************************
function isValid = validate_channels(x)
    isValid = isnumeric(x) &&  min(size(x)) == 1 ...
        && all(ismember(x, [1:84]));
end

%**************************************************************************
function isValid = validate_modouts(x)
    isValid = size(x,2) == 2 && ...
        all(ismember(x(:,1), [2:24])) && ...
        all(ismember(x(:,2), [1:4]));
end

%********************************** EOF ***********************************
