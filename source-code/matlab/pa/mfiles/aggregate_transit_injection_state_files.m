function P = aggregate_transit_injection_state_files( rootPath, stateFilename, varargin )
%
% function P = aggregate_transit_injection_state_files( rootPath, stateFilename, varargin )
% 
% This PA function collects the individual transit injection state files in the subtask directories with processingState = TARGETS and
% returns a structure containing the aggregated variable. All two dimension array variables in these state files are arranged as nCadence x
% nTarget and all one diimension variables are arranged as nTargets so row-wise concatenation works for all variables in the state file. The
% output is optionally written to a simulated transits state file in the root directory.
%
% INPUT:         rootPath == path to task file directory
%           stateFilename == 'pa_simulated_transits.mat' for the simulated transits state file. Other types of state file will work here if
%                             the arrangement of variables is such that row-wise contatenation is appropriate
%                varargin == set first variable argument to true in order to write out the aggregated variables
% OUTPUT:               P == structure containing the aggregated variables
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
TARGET_STATE = 'processingState_TARGETS.mat';

% determine varaible arguments
if nargin > 2
    writeFile = logical(varargin{1});
else
    writeFile = false;
end

% find all the subtask directories
D = dir([rootPath,SUBTASK_MASK]);

% initialize output
P = [];

if ~isempty(D)
    
    % loop over subtask directories
    for iDir = 1:length(D)
        % choose correct processing state
        if exist([rootPath,D(iDir).name,filesep,TARGET_STATE], 'file')
            % require simulated transit state file exist
            if exist([rootPath,D(iDir).name,filesep,stateFilename], 'file')
                % load the state file
                S = load ([rootPath,D(iDir).name,filesep,stateFilename]);
                if isempty(P)
                    % copy variables on first directory
                    P = S;
                else
                    % concatenate variables
                    fields = fieldnames(S);
                    for iField = 1:length(fields)
                        P.(fields{iField}) = [P.(fields{iField}), S.(fields{iField})];
                    end
                end
            else
                disp(['No ',stateFilename,' in ',rootPath,D(iDir).name]);
            end            
        end
    end
    
    % write the aggregated file variables to state file in root directory - use v7.3 support for variable larger than 2GB
    if ~isempty(P) && writeFile
        disp(['Saving aggregated state file ',stateFilename,' ...']);
        save([rootPath,filesep,stateFilename],'-struct','P','-v7.3');
    end
    
else
    disp(['Cannot aggregate state files. No subtask directories found under ',rootPath]);
end