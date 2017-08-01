%% generate_trapezoidal_model_fit_results_table
%
% table = generate_trapezoidal_model_fit_results_table(trapezoidalFit)
%
%% INPUTS
%
%   *trapezoidalFit:* [struct] the trapezoidal model fit results
%
%% OUTPUTS
%
%   *table:* [cell array]  table of trapezoidal model fit results
%%
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
function table = generate_trapezoidal_model_fit_results_table(trapezoidalFit)

warning('off', 'DV:retrieveModelParameter:illegalInput');
warning('off', 'DV:retrieveModelParameter:missingParams');

% When modifying rows, update these constants, and the rows added by 
% create_row. Changing the order that rows are added by create_row 
% is only cosmetic.
N_PARAMETERS = 7; % number of parameters
MODEL_FIT_SNR_ROW = 1;
ORBITAL_PERIOD_ROW = 2;
TRANSIT_EPOCH_ROW = 3;
TRANSIT_DEPTH_ROW = 4;
TRANSIT_DURATION_ROW = 5;
TRANSIT_INGRESS_TIME_ROW = 6;
MODEL_CHI_SQUARE_ROW = 7;

% Columns include parameter, value, uncertainty, and units.
N_COLUMNS = 4;

table = cell(N_PARAMETERS, N_COLUMNS);

% Add all content.
table(MODEL_FIT_SNR_ROW,:) = create_row('SNR', 'modelFitSnr', '');
table(ORBITAL_PERIOD_ROW,:) = create_row('Orbital Period', 'orbitalPeriodDays', 'days');
table(TRANSIT_EPOCH_ROW,:) = create_row('Transit Epoch', 'transitEpochBkjd', 'BKJD');
table(TRANSIT_DEPTH_ROW,:) = create_row('Transit Depth', 'transitDepthPpm', 'ppm');
table(TRANSIT_DURATION_ROW,:) = create_row('Transit Duration', 'transitDurationHours', 'hours');
table(TRANSIT_INGRESS_TIME_ROW,:) = create_row('Transit Ingress Time', 'transitIngressTimeHours', 'hours');
table(MODEL_CHI_SQUARE_ROW,:) = ...
    create_trapezoidal_fit_row_with_dof('Model Chi Square Statistic (DoF)', ...
    trapezoidalFit.modelChiSquare, trapezoidalFit.modelDegreesOfFreedom);

warning('on', 'DV:retrieveModelParameter:illegalInput');
warning('on', 'DV:retrieveModelParameter:missingParams');

%% create_row
    function row = create_row(label, parameter, units)
        
        % The values for modelChiSquare and modeldegreesOfFreedom come from
        % the structure itself, not the array of parameters; hence the
        % special cases for them.
        trapezoidalFitParameter = struct('value', 0, 'uncertainty', -1);
        if (strcmp(parameter, 'modelChiSquare'))
            trapezoidalFitParameter.value = trapezoidalFit.modelChiSquare;
        elseif (strcmp(parameter, 'modelDegreesOfFreedom'))
            trapezoidalFitParameter.value = trapezoidalFit.modelDegreesOfFreedom;
        elseif (strcmp(parameter, 'modelFitSnr'))
            trapezoidalFitParameter.value = trapezoidalFit.modelFitSnr;
        else
            trapezoidalFitParameter = retrieve_model_parameter(trapezoidalFit.modelParameters, parameter);
        end
        
        % Set appropriate format for the value.
        valueFormat = '%1.4f';
        if (strcmp(parameter, 'modelChiSquare') ...
                || strcmp(parameter, 'modelDegreesOfFreedom') ...
                || strcmp(parameter, 'transitDepthPpm'))
            valueFormat = '%1.0f';
        elseif (strcmp(parameter, 'transitEpochBkjd') ...
                || strcmp(parameter, 'orbitalPeriodDays'))
            valueFormat = '%1.7f';
        elseif (strcmp(parameter, 'modelFitSnr'))
            valueFormat = '%1.1f';
        end
        
        % Turn the uncertainty into an appropriate string.
        trapezoidalFitUncertainty = '';
        if (trapezoidalFitParameter.uncertainty ~= -1)
            uncertaintyFormat = '%1.4e';
            trapezoidalFitUncertainty = sprintf(uncertaintyFormat, trapezoidalFitParameter.uncertainty);
        end
        
        % Emit a row for the given parameter.
        row = {label ...
            sprintf(valueFormat, trapezoidalFitParameter.value) ...
            trapezoidalFitUncertainty ...
            units};
    end

%% create_alltransits_row_with_dof
    function row = create_trapezoidal_fit_row_with_dof(label, value, dofValue)
        trapezoidalFitValue = sprintf('%1.1f (%1.0f)', value, dofValue);
        row = {label ...
            trapezoidalFitValue ...
            '' ... % trapezoidalFitUncertainty
            '' ... % trapezoidalFitUnits
            };
    end
end
