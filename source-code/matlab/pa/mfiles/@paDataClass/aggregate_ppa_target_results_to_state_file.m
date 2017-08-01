function aggregate_ppa_target_results_to_state_file( paDataObject )
%**************************************************************************
% function aggregate_ppa_target_results_to_state_file( paDataObject )
%**************************************************************************
% 
% Aggregate PPA target results for the purpose of motion polynomial
% generation. Update the following state variables:
% 
%     ppaTargetStarDataStruct
%         1 x numPpaTargets struct array.
%     ppaTargetStarResultsStruct
%         1 x numPpaTargets struct array of results for PPA targets.
%     paTargetStarResultsStruct 
%         1 x numNonPpaTargets struct array of target results for non-PPA
%         targets.
%     limitStruct 
%         1 x nTargets struct array of limit structures for each PPA and
%         non-PPA target.
%
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
    variables = {'ppaTargetStarDataStruct', ...
                 'ppaTargetStarResultsStruct', ...
                 'paTargetStarResultsStruct', ...
                 'limitStruct' };

    paFileStruct        = paDataObject.paFileStruct;
    paRootTaskDir       = paFileStruct.paRootTaskDir;
    paStateFileName     = paFileStruct.paStateFileName;
    
    % Obtain a list of PPA subtask directories.
    ppaSubTaskDirs = ...
        find_subtask_dirs_by_processing_state( paRootTaskDir, 'PPA_TARGETS' );
    
    % Initialize aggregated state variables from the state file in the root
    % task directory. 
    aggregated = load(fullfile(paRootTaskDir, paStateFileName), ...
        variables{:});

    % Aggregate state file contents.
    for iSubtask = 1:numel(ppaSubTaskDirs) 
        
        % Read state file from subtask directory.
        new = load( fullfile(paRootTaskDir, ppaSubTaskDirs{iSubtask}, ...
                    paStateFileName));
                    
        % Aggregate ppa target results.
        aggregated.ppaTargetStarDataStruct = ...
            horzcat(aggregated.ppaTargetStarDataStruct, ...
                    new.ppaTargetStarDataStruct);  
        aggregated.ppaTargetStarResultsStruct = ...
            horzcat(aggregated.ppaTargetStarResultsStruct, ...
                    new.ppaTargetStarResultsStruct);  
        aggregated.paTargetStarResultsStruct = ...
            horzcat(aggregated.paTargetStarResultsStruct, ...
                    new.paTargetStarResultsStruct); 
        aggregated.limitStruct = ...
            horzcat(aggregated.limitStruct, new.limitStruct);          
    end
         
    % Append fields of the aggregated state struct to the state file in the
    % root task directory, which overwrites the previously existing
    % variables. 
    ppaTargetStarDataStruct     = aggregated.ppaTargetStarDataStruct;
    ppaTargetStarResultsStruct  = aggregated.ppaTargetStarResultsStruct;
    paTargetStarResultsStruct   = aggregated.paTargetStarResultsStruct;
    limitStruct                 = aggregated.limitStruct;
    
    clear aggregated new
        
    save(paStateFileName, variables{:}, '-v7.3', '-append');
    
end
