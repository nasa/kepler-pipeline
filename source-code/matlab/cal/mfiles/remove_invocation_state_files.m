function result = remove_invocation_state_files( localFilenames )
% function result = remove_invocation_state_files( localFilenames )
%
% This CAL function removes the redundant invocation tagged state files from the state file directory. This should be run on the last call
% after the state files for all the invocations have been accumulated into single state files per type. The types of state files accumulated
% in CAL are: cal_comp_eff_state_#.mat, cal_metrics_state_#.mat, cal_pou_state_#.mat where # = invocation label.
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


stateFilePath = localFilenames.stateFilePath;

% list state files series to remove
state_file_root = {localFilenames.compRootFilename,...
                    localFilenames.metricsRootFilename,...
                    localFilenames.pouRootFilename};

result = false(size(state_file_root));                
                
for iSeries = 1:length(state_file_root)
    
    % check that the accumulated file exists
    if exist([stateFilePath, state_file_root{iSeries}, '.mat'], 'file') == 2
        
        % preserve the collateral invocation pou state file (pou_state_0.mat) in order to be able to run any single invocation in test and debug sessions
        if strcmp(state_file_root{iSeries},localFilenames.pouRootFilename)
            movefile([stateFilePath,localFilenames.pouRootFilename,'_0.mat'],[stateFilePath,'temp_state.mat']);
        end
        
        % remove the tagged files for this series leaving only the accumulated file
        delete([stateFilePath, state_file_root{iSeries}, '_*.mat']);
        result(iSeries) = true;
        
        % restore
        if strcmp(state_file_root{iSeries},localFilenames.pouRootFilename)
            movefile([stateFilePath,'temp_state.mat'],[stateFilePath,localFilenames.pouRootFilename,'_0.mat']);
        end        
    end
end


return;