function P = aggregate_paTargetStarResults_fields_from_pa_state_files( rootPath, fields )
%
% function P = aggregate_paTargetStarResults_fields_from_pa_state_files( rootPath, fields )
% 
% This function collects the requested fields and only those fields from paTargetStarResultsStruct in the individual pa_state files in the
% subtask directories with processingState = TARGETS, aggregates them and returns a structure containing the aggregated fields. 
%
% INPUT:         rootPath == [string];path to task file directory
%               varaibles == [cell array of strings];list of pa_state varaibles to aggregate
% OUTPUT:               P == paTargetStarResultsStruct structure containing only the aggregated variables
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


% hard coded
SUBTASK_MASK = 'st-*';
STATE_FILENAME = 'pa_state.mat';
TARGET_STATE = 'processingState_TARGETS.mat';

             
% find all the subtask directories
D = dir([rootPath,SUBTASK_MASK]);

% initialize output
P = [];

if ~isempty(D)
    
    % loop over subtask directories
    for iDir = 1:length(D)
        % choose correct processing state
        if exist([rootPath,D(iDir).name,filesep,TARGET_STATE], 'file')
            % require pa state file exist
            if exist([rootPath,D(iDir).name,filesep,STATE_FILENAME], 'file')
                % load the state file
                S = load ([rootPath,D(iDir).name,filesep,STATE_FILENAME],'paTargetStarResultsStruct');
                % parse structure to contain only wanted fields
                oldFieldnames = fieldnames(S.paTargetStarResultsStruct);
                tf = ismember(fieldnames(S.paTargetStarResultsStruct),fields);
                if any(~tf)
                    S.paTargetStarResultsStruct = rmfield(S.paTargetStarResultsStruct,oldFieldnames(~tf));
                end                
                if isempty(P)
                    % copy variables on first directory
                    P = S;                    
                else
                    % aggregate with previous directory results
                    P.paTargetStarResultsStruct = horzcat(P.paTargetStarResultsStruct, S.paTargetStarResultsStruct);
                end
            else
                disp(['No ',STATE_FILENAME,' in ',rootPath,D(iDir).name]);
            end            
        end
    end
       
else
    disp(['Cannot aggregate state file variable. No subtask directories found under ',rootPath]);
end