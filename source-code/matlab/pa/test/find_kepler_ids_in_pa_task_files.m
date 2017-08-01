function subtaskDir = find_kepler_ids_in_pa_task_files(keplerId, mjd, rootPath, quarter)
%************************************************************************** 
% subtaskDir = find_kepler_ids_in_pa_task_files(keplerId, mjd, rootPath)
%************************************************************************** 
% Retrieve the subtask directories containing results for the given targets
% at the specified times. 
%
% INPUTS
%     keplerId    : An N-length array of valid kepler IDs.
%     mjd         : An N-length array of MJDs corrresponding to the entries
%                   in keplerId.
%     rootPath    : The full path to the directory containing task 
%                   directories for the pipeline instance (i.e., the
%                   directory that contains the uow/ directory). If
%                   unspecified, the current working directory is used.
%     quarter     : An integer specifying the desired quarter. This
%                   parameter need only be specified when results for
%                   multiple quarters reside under rootPath. If
%                   unspecified, the earliest quarter is used by default. 
%                   
% OUTPUTS
%     subtaskDir  : An N-length cell array of subtask directories
%                   containing results for each target at the specified
%                   time.  
%
% NOTES
%     This function uses sandbox tools that access Kepler databases. As a
%     rule of thumb use SPQ (kspq) when working with Kepler data and SPM
%     (kspm2) when working with K2.
%
%     As of SOC 9.3 all targets (PPA and non-PPA) are processed in the
%     TARGETS processing state. We therefore search only the TARGETS
%     subtask directories.
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

    if ~exist('rootPath','var') || ~isdir(rootPath)
        rootPath = pwd;
    end
    
    if ~exist('quarter','var')
        quarter = [];
    end

    subtaskDir = cell(length(keplerId), 1);
    
    % For each target and time.
    for iTarget = 1:length(keplerId)
        fprintf('Processing kepler ID %d ...\n', keplerId(iTarget));

        % Determine the associated task file directory.
        skyGroupStruct = retrieve_sky_group(keplerId(iTarget), mjd(iTarget));
        groupDir = cell2mat(get_group_dir( 'PA', [skyGroupStruct.ccdModule, ...
            skyGroupStruct.ccdOutput], 'rootPath', rootPath , 'quarter', quarter));
        
        if isempty(groupDir)   
            fprintf('Could not find PA group directory for mod.out %d.%d at MJD %d\n', ...
                skyGroupStruct.ccdModule, skyGroupStruct.ccdOutput, mjd(iTarget));
            continue;
        end

        % Identify TARGET subtask directories.
        targetsSubtaskDirs = ...
            find_subtask_dirs_by_processing_state( groupDir, 'TARGETS' );
        
        % Search TARGET subtask directories for the current target.
        for iDir=1:numel(targetsSubtaskDirs)
            fprintf('Searching subtask directory %s ...\n',targetsSubtaskDirs{iDir});
            load(fullfile(groupDir, targetsSubtaskDirs{iDir}, 'pa-outputs-0.mat'));
                        
            if( ~isempty(outputsStruct.targetStarResultsStruct) )
                if ismember(keplerId(iTarget), [outputsStruct.targetStarResultsStruct.keplerId])
                    subtaskDir{iTarget} = fullfile(groupDir, targetsSubtaskDirs{iDir});  
                    break;
                end
            end
        end
        
        if isempty(subtaskDir{iTarget})
            fprintf(['Could not find kepler ID %d in PA input', ...
                'files in directory %s\n'], keplerId(iTarget), groupDir);
        end
    end
           
end
    