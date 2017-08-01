function targetArray = add_aperture_sizes_and_target_positions( targetArray, paRootTaskDir, tadFile )
%**************************************************************************
% targetArray = add_aperture_sizes_and_target_positions( targetArray, paRootTaskDir, tadFile )
%**************************************************************************  
% Add aperture size fields to a target struct array.
%
% INPUTS
%     targetArray     : A struct array of the format produced by
%                       convert_cdpp_fov_struct_to_target_array().
%     paRootTaskDir   : The full path to the directory containing task 
%                       directories for the pipeline instance (this is the
%                       directory containing the uow/ subdirectory). 
%     tadFile         : An optional TAD file. Typically this is the file
%                       from the LAST trim dir (e.g., '/path/to
%                       /c4/tad/c4_feb2015/trimmed_v2/extract_tad_data/
%                       c4_feb2015_trimmed_v2_lc.mat').
% OUTPUTS
%     targetArray     : A copy of the input targetArray with the following
%                       fields added: pa1TadApertureSize (only added if a
%                       TAD file is provided), pa2TadApertureSize,
%                       usedApertureSize. 
%                        
% NOTES
%     This function assumes we're no longer operating in the PA1/sTAD/PA2
%     paradigm, but are running only PA2. It therefore adds only one input
%     and one output aperture size to each array element.
%
% USAGE EXAMPLES
%     >> paRootTaskDir = './lc/pa2';
%     >> targetArray = add_aperture_sizes_and_target_positions( ...
%        convert_cdpp_fov_struct_to_target_array( ...
%        paCoaClass.compile_FOV_statistics(0, dataPath) ), paRootTaskDir)
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
    modout = unique([colvec([targetArray.ccdModule]), ...
               colvec([targetArray.ccdOutput])], 'rows');
    channelOrModout = convert_from_module_output( modout(:,1), modout(:,2));
    nTargets = numel(targetArray); 

    %----------------------------------------------------------------------
    % Obtain original TAD optimal aperture sizes.
    %----------------------------------------------------------------------
    if exist('tadFile', 'var')
        % Load the file from the LAST trim dir.
        load(tadFile, 'tad')
        kepid       = cat(2,tad.kepid);
        npixInOptAp = cat(2,tad.npixInOptAp);
        npixInMask  = cat(2,tad.npixInMask);

        [tf, loc] = ismember(kepid, [targetArray.keplerId]);
        pa1TadApertureSize = nan(nTargets,1);
        pa1TadApertureSize(loc) = npixInOptAp;
        cellArray = num2cell(pa1TadApertureSize);
        [targetArray.pa1TadApertureSize] = deal(cellArray{:});
    end
    
    %----------------------------------------------------------------------
    % Obtain PA2 input and output optimal aperture sizes.
    %----------------------------------------------------------------------
    groupDirCellArray = get_group_dir( 'PA', channelOrModout, ...
            'rootPath', paRootTaskDir);
    isValidGroupDir = cellfun(@(x)~isempty(x), groupDirCellArray);
    if ~any(isValidGroupDir)
        return
    end
    
    groupDirCellArray = groupDirCellArray(isValidGroupDir);
    if size(channelOrModout, 2) == 2
        modouts  = channelOrModout(isValidGroupDir, :);
        channels = convert_from_module_output(channelOrModout(isValidGroupDir,1), channelOrModout(isValidGroupDir,2));
    else
        channels = channelOrModout(isValidGroupDir);
        [m, o]  = convert_to_module_output(channelOrModout(isValidGroupDir, :));
        modouts = [m,o];
    end

    nChannels = length(channels);
    
    for iChannel = 1:nChannels
        channelDir = groupDirCellArray{iChannel};
        
        fprintf('Processing channel %d of %d directory = %s ... \n', ...
            iChannel, nChannels, channelDir);
                        
        % Obtain PA output (used) optimal aperture sizes.
        load( fullfile(channelDir, 'pa_state.mat'), 'paTargetStarResultsStruct');
        for iTarget = 1:numel(paTargetStarResultsStruct)
            kid = paTargetStarResultsStruct(iTarget).keplerId;
            usedApertureSize = numel(paTargetStarResultsStruct(iTarget).optimalAperture.offsets);
            idx = find([targetArray.keplerId] == kid);
            if ~isempty(idx)
                targetArray(idx).usedApertureSize = usedApertureSize;
            end
        end        
        
        % Obtain PA2 input optimal aperture sizes.        
        subtaskDirs = find_subtask_dirs_by_processing_state( channelDir, 'TARGETS' );
        for iSubtask = 1:numel(subtaskDirs)
            subtaskPath = fullfile(channelDir, subtaskDirs{iSubtask});
            if exist(subtaskPath, 'dir')
                load( fullfile(subtaskPath, 'pa-inputs-0.mat'));
                for iTarget = 1:numel(inputsStruct.targetStarDataStruct)
                    kid = inputsStruct.targetStarDataStruct(iTarget).keplerId;
                    pa2TadApertureSize = nnz([inputsStruct.targetStarDataStruct(iTarget).pixelDataStruct.inOptimalAperture]);
                    idx = find([targetArray.keplerId] == kid);
                    if ~isempty(idx)
                        targetArray(idx).pa2TadApertureSize = pa2TadApertureSize;
                    end
                end
                
            end
        end
    end
end

%********************************** EOF ***********************************
