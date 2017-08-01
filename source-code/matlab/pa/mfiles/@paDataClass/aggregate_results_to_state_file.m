function aggregate_results_to_state_file( paDataObject )
%**************************************************************************
% function aggregate_results_to_state_file( paDataObject )
%**************************************************************************
% Aggregate results. Update the following state variables:
% 
%     cosmicRayEvents
%         1 x nEvents struct array of cosmic ray event structures.
%     nValidPixels
%         nCadences x 1 double array containing the number of valid pixels
%         per cadence.
%     pixelCoordinates 
%         nPixels x 2 double array of pixel coordinates.
%     pixelGaps
%         An nCadences x nPixels sparse array of logical gap indicators,
%         one column for each row in pixelCoordinates. 
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
    variables = {'cosmicRayEvents', 'nValidPixels', ...
                 'pixelCoordinates', 'pixelGaps', ...
                 'paTargetStarResultsStruct', 'limitStruct', ...
                 'raDecMagFitResults' };

    % Get file names and paths.
    paFileStruct        = paDataObject.paFileStruct;
    paRootTaskDir       = paFileStruct.paRootTaskDir;
    paStateFileName     = paFileStruct.paStateFileName;
    
    % Are we processing short cadence?
    processingShortCadence = strcmpi(paDataObject.cadenceType, 'short'); 
    
    % Obtain a list of TARGETS subtask directories.
    targetsSubTaskDirs = ...
        find_subtask_dirs_by_processing_state( paRootTaskDir, 'TARGETS' );
        
    % Initialize. We are aggregating "afresh" now since all targets,
    % including PPA targets, are processed in the TARGETS processing state.
    aggregated.cosmicRayEvents           = [];
    aggregated.nValidPixels              = ...
        zeros(size(paDataObject.cadenceTimes.gapIndicators));
    aggregated.pixelCoordinates          = [];
    aggregated.pixelGaps                 = [];
    aggregated.paTargetStarResultsStruct = [];
    aggregated.limitStruct               = [];
    aggregated.raDecMagFitResults        = [];
    
    for iSubtask = 1:numel(targetsSubTaskDirs) 
        
        % Read state file from subtask directory.
        new = load(fullfile(paRootTaskDir, targetsSubTaskDirs{iSubtask}, ...
            paStateFileName), variables{:});
                           
        % Aggregate cosmic ray results.
        if ~isempty(new.cosmicRayEvents)
            aggregated.cosmicRayEvents = ...
                horzcat(aggregated.cosmicRayEvents, new.cosmicRayEvents);   
            aggregated.cosmicRayEvents = ...
                remove_duplicate_cosmic_ray_events(aggregated.cosmicRayEvents);  

            [aggregated.pixelCoordinates, ...
             aggregated.pixelGaps, ...
             aggregated.nValidPixels] = ...
                update_pixel_coordinates_and_gaps( ...
                    aggregated.pixelCoordinates, ...
                    aggregated.pixelGaps, ...
                    new.pixelCoordinates(:,1), ... % ccd row coordinates
                    new.pixelCoordinates(:,2), ... % ccd column coordinates
                    new.pixelGaps); 
        end
        
        % Aggregate pa target results.
        aggregated.paTargetStarResultsStruct = ...
            horzcat(aggregated.paTargetStarResultsStruct, ...
                    new.paTargetStarResultsStruct); 
        aggregated.limitStruct = ...
            horzcat(aggregated.limitStruct, new.limitStruct);
        
        % Aggregate RA, Dec, and mag fitting results.
        aggregated.raDecMagFitResults = ...
            horzcat(aggregated.raDecMagFitResults, new.raDecMagFitResults);   
    end
    
    % Append fields of the aggregated state struct to the state file in the
    % root task directory, which overwrites the previously existing
    % variables. 
    cosmicRayEvents             = aggregated.cosmicRayEvents;
    nValidPixels                = aggregated.nValidPixels;
    pixelCoordinates            = aggregated.pixelCoordinates;
    pixelGaps                   = aggregated.pixelGaps;
    paTargetStarResultsStruct   = aggregated.paTargetStarResultsStruct;
    limitStruct                 = aggregated.limitStruct;
    raDecMagFitResults          = aggregated.raDecMagFitResults;

    clear aggregated new
        
    save(paStateFileName, variables{:}, '-append');
    
    % If processing short cadence, grab the interpolated motion polynomial
    % struct from the first TARGETS processing subtask.
    if processingShortCadence && ~isempty(targetsSubTaskDirs)
        load( fullfile(paRootTaskDir, targetsSubTaskDirs{1}, ...
            paStateFileName), 'motionPolyStruct');
        save(paStateFileName, 'motionPolyStruct', '-append');
    end
end
