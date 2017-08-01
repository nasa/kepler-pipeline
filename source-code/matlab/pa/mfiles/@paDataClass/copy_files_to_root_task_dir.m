function copy_files_to_root_task_dir( paDataObject, copyOrMove )
%**************************************************************************
% function copy_files_to_root_task_dir( paDataObject, copyOrMove )
%**************************************************************************
% Method to copy file from the current subtask directory to the root task
% directory, depending on processing state.
%
% NOTES
%   - We do not move the files pa_background.mat and pa_motion.mat to the
%     parent directory because the java side expects them in the subtask
%     directories. These files contain redundant information anyway, since
%     the background and motion polynomials can be found in the state file
%     in the root directory.
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

    % Determine whether to copy the files or move them to the parent
    % directory.
    if ~exist('copyOrMove', 'var')
        copyOrMove = 'copy';
    end
    
    switch lower(copyOrMove)
        case 'copy'
            copy_or_move = @copyfile;
        case 'move'
            copy_or_move = @movefile;
        otherwise
            copy_or_move = @copyfile;
    end
    
    % Get file and path names from paDataObject.
    paFileStruct         = paDataObject.paFileStruct;
    paRootTaskDir        = paFileStruct.paRootTaskDir;
    paStateFileName      = paFileStruct.paStateFileName;
    
    paSimulatedTransitsFileName   = paFileStruct.paSimulatedTransitsFileName;
    paSimulatedTransitsBlob       = paFileStruct.paSimulatedTransitsBlob;
        
    simulatedTransitsEnabled = ...
        paDataObject.paConfigurationStruct.simulatedTransitsEnabled;
    
    switch paDataObject.processingState
        case 'BACKGROUND'
            filesToCopy = { paStateFileName, ...
                            'pa_rw_zero_crossings.fig', ...
                            'pa_background_aic.fig', ... 
                            'pa_mean_background_flux.fig', ...
                            'pa-dawg-background.mat' ...
                          };
        
        case 'GENERATE_MOTION_POLYNOMIALS'
            filesToCopy = { paStateFileName, ...
                            'pa_motion_aic.fig' ...
                          };
            
        case 'MOTION_BACKGROUND_BLOBS' % First call in short cadence.
            filesToCopy = { paStateFileName, ...
                            'pa_rw_zero_crossings.fig' ...
                          };
            
        case 'AGGREGATE_RESULTS'
            filesToCopy = { paStateFileName, ...
                            'pa_brightness.fig', ...
                            'pa_encircled_energy.fig', ...
                            'pa-dawg-motion.mat', ...
                            'pa-dawg-flux.mat', ...
                            'pa-dawg-centroid.mat' ...
                          };
                        
            if simulatedTransitsEnabled
                filesToCopy = horzcat(filesToCopy, ...
                            paSimulatedTransitsFileName, ...
                            paSimulatedTransitsBlob);
            end
            
        otherwise
            filesToCopy = {};
    end
        
    for iFile = 1:numel(filesToCopy)
        success = false;
        message = '';
        if exist(filesToCopy{iFile}, 'file')
            [success, message] = copy_or_move(filesToCopy{iFile}, paRootTaskDir);
        end
        
        if ~success
           fprintf('Could not %s file %s : %s\n', copyOrMove, filesToCopy{iFile}, message);
        end
    end

end

