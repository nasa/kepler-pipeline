%% generate_target_table_summary_table
%
% function targetTableSummaryTable = generate_target_table_summary_table(...
%    targetStruct, targetResultsStruct)
%
% Creates a per-target table table that goes with the following headings:
% Quarter  Target Table  Module/Output  Crowding Metric  Flux Fraction Limb
% Darkening Coefficients #1, #2, #3, #4.
%%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
function targetTableSummaryTable = generate_target_table_summary_table(...
    targetStruct, targetResultsStruct)

N_COLUMNS = 9; % number of columns described above

nTargetTables = length(targetStruct.targetDataStruct);

% Number of rows in table is the heading and entry for each target table (1
% + nTargetTable) for each property (N_PROPERTIES).
targetTableSummaryTable = cell(nTargetTables, N_COLUMNS);

for iTargetTable = 1 : nTargetTables
    targetDataStruct = targetStruct.targetDataStruct(iTargetTable);
    limbDarkeningStruct = limb_darkening_struct_for_target_table_id(targetDataStruct.targetTableId);
    
    targetTableSummaryTable(iTargetTable, :) = { ...
        num2str(targetDataStruct.quarter) ...
        num2str(targetDataStruct.targetTableId) ...
        sprintf('%d/%d', targetDataStruct.ccdModule, targetDataStruct.ccdOutput) ...
        sprintf('%.4f', targetDataStruct.crowdingMetric) ...
        sprintf('%.4f', targetDataStruct.fluxFractionInAperture) ...
        sprintf('%.4f', limbDarkeningStruct.coefficient1) ...
        sprintf('%.4f', limbDarkeningStruct.coefficient2) ...
        sprintf('%.4f', limbDarkeningStruct.coefficient3) ...
        sprintf('%.4f', limbDarkeningStruct.coefficient4) ...
        };
end

    function limbDarkeningStruct = limb_darkening_struct_for_target_table_id(targetTableId)
        for iLimbDarkeningStruct = 1 : length(targetResultsStruct.limbDarkeningStruct)
            limbDarkeningStruct = targetResultsStruct.limbDarkeningStruct(iLimbDarkeningStruct);
            if (limbDarkeningStruct.targetTableId == targetTableId)
                return;
            end
        end
        warning('DV:generate_target_table_summary_table:limbDarkeningStructNotFound', ...
            'Could not find limbDarkeningStruct for target table ID %d', targetTableId);
        limbDarkeningStruct = struct('coefficient1', nan, 'coefficient2', nan, ...
            'coefficient3', nan, 'coefficient4', nan);
    end

end