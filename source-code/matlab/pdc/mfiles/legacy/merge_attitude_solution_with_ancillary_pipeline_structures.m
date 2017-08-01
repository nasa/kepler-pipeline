function [ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct] = ...
merge_attitude_solution_with_ancillary_pipeline_structures( ...
ancillaryAttitudeConfigurationStruct, attitudeSolutionStruct, ...
ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct, ...
longCadenceTimes)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct] = ...
% merge_attitude_solution_with_ancillary_pipeline_structures( ...
% ancillaryAttitudeConfigurationStruct, attitudeSolutionStruct, ...
% ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct, ...
% longCadenceTimes)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Merge the attitude solution with the ancillary pipeline data and
% configuration structures. It is not a standard time series as the other
% pipeline ancillary mnemonics so cannot be provided directly as input in
% the same fashion as the other pipeline ancillary data. The uncertainties
% are obtained as the square roots of the diagonal elements of the attitude
% solution covariance matrix. The off diagonal terms will not figure in the
% determination of the uncertainties in the conditioned attitude solution
% data.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Check if the attitude solution is populated.
if ~isempty(attitudeSolutionStruct) && ...
        ~isempty(attitudeSolutionStruct.gapIndicators)
    
    % Check if ancillary attitude configuration struct appears to be valid.
    if isempty(ancillaryAttitudeConfigurationStruct) || ...
            3 ~= length(ancillaryAttitudeConfigurationStruct.mnemonics)
        error('AncillaryDataConditioning:mergeAttitudeSolution:InvalidConfigurationStruct', ...
        'There must be 3 mnemonics in the ancillary attitude configuration structure')
    end
    
    % Get the mid-cadence timestamps and attitude solution gap indicators.
    timestamps = longCadenceTimes.midTimestamps;
    gapIndicators = attitudeSolutionStruct.gapIndicators;
    
    % Append the attitude solution data.
    ancillaryDataStruct.timestamps = timestamps(~gapIndicators);
    
    ancillaryDataStruct.mnemonic = ...
        ancillaryAttitudeConfigurationStruct.mnemonics{1};
    ancillaryDataStruct.values = ...
        attitudeSolutionStruct.ra(~gapIndicators);
    ancillaryDataStruct.uncertainties = ...
        sqrt(attitudeSolutionStruct.covarianceMatrix11(~gapIndicators));
    ancillaryPipelineDataStruct = ...
        [ancillaryPipelineDataStruct, ancillaryDataStruct];
    
    ancillaryDataStruct.mnemonic = ...
        ancillaryAttitudeConfigurationStruct.mnemonics{2};
    ancillaryDataStruct.values = ...
        attitudeSolutionStruct.dec(~gapIndicators);
    ancillaryDataStruct.uncertainties = ...
        sqrt(attitudeSolutionStruct.covarianceMatrix22(~gapIndicators));
    ancillaryPipelineDataStruct = ...
        [ancillaryPipelineDataStruct, ancillaryDataStruct];
    
    ancillaryDataStruct.mnemonic = ...
        ancillaryAttitudeConfigurationStruct.mnemonics{3};
    ancillaryDataStruct.values = ...
        attitudeSolutionStruct.roll(~gapIndicators);
    ancillaryDataStruct.uncertainties = ...
        sqrt(attitudeSolutionStruct.covarianceMatrix33(~gapIndicators));
    ancillaryPipelineDataStruct = ...
        [ancillaryPipelineDataStruct, ancillaryDataStruct];
    
    % Append the ancillary attitude configuration parameters.
    ancillaryPipelineConfigurationStruct.mnemonics = ...
        horzcat(ancillaryPipelineConfigurationStruct.mnemonics, ...
        ancillaryAttitudeConfigurationStruct.mnemonics);
    ancillaryPipelineConfigurationStruct.modelOrders = ...
        vertcat(ancillaryPipelineConfigurationStruct.modelOrders, ...
        ancillaryAttitudeConfigurationStruct.modelOrders);
    ancillaryPipelineConfigurationStruct.interactions = ...
        horzcat(ancillaryPipelineConfigurationStruct.interactions, ...
        ancillaryAttitudeConfigurationStruct.interactions);
    
end % if

% Return.
return
