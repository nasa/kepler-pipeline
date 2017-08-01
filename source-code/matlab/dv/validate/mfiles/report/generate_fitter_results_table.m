%% generate_fitter_results_table
%
% modelDescriptionTable = generate_fitter_results_table(planetResultsStruct, fitType)
%
%% INPUTS
%
%   *planetResultsStruct:* [struct] the planet results
%               *fitType:* [string] one of 'all' or 'oddEven'
%
%% OUTPUTS
%
%   *modelDescriptionTable:* [cell array]  modelDescriptionTable
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
function transitsFitResultsTable = generate_fitter_results_table(planetResultsStruct, fitType)

warning('off', 'DV:retrieveModelParameter:illegalInput');
warning('off', 'DV:retrieveModelParameter:missingParams');

allTransitsFit = planetResultsStruct.allTransitsFit;
oddTransitsFit = planetResultsStruct.oddTransitsFit;
evenTransitsFit = planetResultsStruct.evenTransitsFit;
allTransitsFitPeriod = retrieve_model_parameter(allTransitsFit.modelParameters, 'orbitalPeriodDays');

% Simply return an empty cell array if the fitter failed.
isPlanetACandidate = false;
if (strcmp(fitType, 'all'))
    if (allTransitsFit.modelChiSquare > 0)
        isPlanetACandidate = true;
    end
elseif (strcmp(fitType, 'oddEven'))
    if (oddTransitsFit.modelChiSquare > 0 && evenTransitsFit.modelChiSquare > 0)
        isPlanetACandidate = true;
    end
else
    warning('DV:generate_fitter_results_table:illegalArgument', ...
        'fitType must be either all or oddEven');
end

if (~isPlanetACandidate && ~planetResultsStruct.planetCandidate.suspectedEclipsingBinary)
    transitsFitResultsTable = cell(0);
    return;
end

% When modifying rows, update these constants, including N_PARAMETERS, the
% variable rowsToKeep, and the rows added by create_row. Changing the order
% that rows are added by create_row is only cosmetic.
N_PARAMETERS = 18;
MODEL_FIT_SNR_ROW = 1;
ORBITAL_PERIOD_ROW = 2;
TRANSIT_EPOCH_ROW = 3;
IMPACT_PARAMETER_ROW = 4;
PLANET_RADIUS_TO_STAR_RADIUS_RATIO = 5;
SEMI_MAJOR_AXIS_TO_STAR_RADIUS_RATIO = 6;
PLANET_RADIUS_ROW = 7;
SEMI_MAJOR_AXIS_ROW = 8;
EFFECTIVE_STELLAR_FLUX_ROW = 9;
EQUILIBRIUM_TEMP_ROW = 10;
TRANSIT_DEPTH_ROW = 11;
TRANSIT_DURATION_ROW = 12;
TRANSIT_INGRESS_TIME_ROW = 13;
ECCENTRICITY_ROW = 14;
PERI_LONGITUDE_ROW = 15;
MODEL_CHI_SQUARE_ROW = 16;
MODEL_CHI_SQUARE_GOF_ROW = 17;
MODEL_CHI_SQUARE2_ROW = 18;

% When modifying columns, update these constants, including N_COLUMNS, the
% function create_row, and the variable columnsToKeep.
N_COLUMNS = 13;
PARAMETER_COLUMN = 1;
VALUE_COLUMN = 2;
UNCERTAINTY_COLUMN = 3;
ESTIMATED_VALUE_COLUMN = 4;
ODD_TRANSIT_VALUE_COLUMN = 5;
ODD_TRANSIT_UNCERTAINTY_COLUMN = 6;
EVEN_TRANSIT_VALUE_COLUMN = 7;
EVEN_TRANSIT_UNCERTAINTY_COLUMN = 8;
ODD_TRANSIT_ESTIMATED_VALUE_COLUMN = 9;
EVEN_TRANSIT_ESTIMATED_VALUE_COLUMN = 10;
UNITS_COLUMN = 11;
DIFF_SQRT_SUM_UNCERTAINTIES_COLUMN = 12;
DIFFERENCE_COLUMN = 13;

transitsFitResultsTable = cell(N_PARAMETERS, N_COLUMNS);
planetCandidate = planetResultsStruct.planetCandidate;

% Add all content.
transitsFitResultsTable(MODEL_FIT_SNR_ROW,:) = create_row('SNR', 'modelFitSnr', '');
transitsFitResultsTable(TRANSIT_EPOCH_ROW,:) = create_row('Transit Epoch', 'transitEpochBkjd', 'BKJD');
transitsFitResultsTable(ECCENTRICITY_ROW,:) = create_row('Eccentricity', 'eccentricity', '');
transitsFitResultsTable(PERI_LONGITUDE_ROW,:) = create_row('Peri Longitude', 'longitudeOfPeriDegrees', 'degrees');
transitsFitResultsTable(PLANET_RADIUS_ROW,:) = create_row('Planet Radius', 'planetRadiusEarthRadii', 'Earth radii');
transitsFitResultsTable(PLANET_RADIUS_TO_STAR_RADIUS_RATIO,:) = create_row('Planet Radius to Star Radius Ratio', 'ratioPlanetRadiusToStarRadius', '');
transitsFitResultsTable(SEMI_MAJOR_AXIS_ROW,:) = create_row('Semi-major Axis', 'semiMajorAxisAu', 'AU');
transitsFitResultsTable(SEMI_MAJOR_AXIS_TO_STAR_RADIUS_RATIO,:) = create_row('Semi-major Axis to Star Radius Ratio', 'ratioSemiMajorAxisToStarRadius', '');
transitsFitResultsTable(IMPACT_PARAMETER_ROW,:) = create_row('Impact Parameter', 'minImpactParameter', '');
transitsFitResultsTable(TRANSIT_DURATION_ROW,:) = create_row('Transit Duration', 'transitDurationHours', 'hours');
transitsFitResultsTable(TRANSIT_INGRESS_TIME_ROW,:) = create_row('Transit Ingress Time', 'transitIngressTimeHours', 'hours');
transitsFitResultsTable(TRANSIT_DEPTH_ROW,:) = create_row('Transit Depth', 'transitDepthPpm', 'ppm');
transitsFitResultsTable(ORBITAL_PERIOD_ROW,:) = create_row('Orbital Period', 'orbitalPeriodDays', 'days');
transitsFitResultsTable(EFFECTIVE_STELLAR_FLUX_ROW,:) = create_row('Effective Stellar Flux', 'effectiveStellarFlux', 'Goldilocks');
transitsFitResultsTable(EQUILIBRIUM_TEMP_ROW,:) = create_row('Equilibrium Temperature', 'equilibriumTempKelvin', 'Kelvin');
transitsFitResultsTable(MODEL_CHI_SQUARE_ROW,:) = create_row('Model Chi Square Statistic (DoF)', 'modelChiSquare', '');
transitsFitResultsTable(MODEL_CHI_SQUARE_GOF_ROW,:) = ...
    create_alltransits_row_with_dof('Model Chi Square Goodness of Fit Statistic (DoF)', ...
    planetCandidate.modelChiSquareGof, planetCandidate.modelChiSquareGofDof);
transitsFitResultsTable(MODEL_CHI_SQUARE2_ROW,:) = ...
    create_alltransits_row_with_dof('Model Chi Square2 Statistic (DoF)', ...
    planetCandidate.modelChiSquare2, planetCandidate.modelChiSquareDof2);

% Trim rows that are not needed by this view.
allRows = 1 : N_PARAMETERS;
rowsToKeep = allRows;
if (~isPlanetACandidate)
    rowsToKeep = [TRANSIT_EPOCH_ROW ...
        TRANSIT_DURATION_ROW TRANSIT_DEPTH_ROW ORBITAL_PERIOD_ROW];
end
if (~strcmp(fitType, 'all'))
    rowsToKeep = setdiff(rowsToKeep, [MODEL_CHI_SQUARE_GOF_ROW, MODEL_CHI_SQUARE2_ROW]);
end
transitsFitResultsTable(setdiff(allRows, rowsToKeep),:) = [];

% Trim columns that are not needed by this view.
allColumns = 1 : N_COLUMNS;
if (strcmp(fitType, 'all'))
    if (isPlanetACandidate)
        columnsToKeep = [PARAMETER_COLUMN VALUE_COLUMN UNCERTAINTY_COLUMN UNITS_COLUMN];
    else
        columnsToKeep = [PARAMETER_COLUMN ESTIMATED_VALUE_COLUMN UNITS_COLUMN];
    end
else
    if (isPlanetACandidate)
        columnsToKeep = [PARAMETER_COLUMN ...
            ODD_TRANSIT_VALUE_COLUMN ODD_TRANSIT_UNCERTAINTY_COLUMN ...
            EVEN_TRANSIT_VALUE_COLUMN EVEN_TRANSIT_UNCERTAINTY_COLUMN ...
            UNITS_COLUMN DIFF_SQRT_SUM_UNCERTAINTIES_COLUMN];
    else
        columnsToKeep = [PARAMETER_COLUMN ...
            ODD_TRANSIT_ESTIMATED_VALUE_COLUMN EVEN_TRANSIT_ESTIMATED_VALUE_COLUMN ...
            UNITS_COLUMN DIFFERENCE_COLUMN];
    end
end
transitsFitResultsTable(:,setdiff(allColumns, columnsToKeep)) = [];

warning('on', 'DV:retrieveModelParameter:illegalInput');
warning('on', 'DV:retrieveModelParameter:missingParams');

%% create_row
    function row = create_row(label, parameter, units)
        
        % Default formats.
        valueFormat = '%1.4f';
        uncertaintyFormat = '%1.4e';
        diffFormat = '%1.4f';
        modifiedDiffFormat = '%1.4e';
        
        % Default values.
        allTransitsUncertainty = '';
        oddTransitsUncertainty = '';
        evenTransitsUncertainty = '';
        
        % The values for modelChiSquare and modeldegreesOfFreedom come from
        % the structure itself, not the array of parameters; hence the
        % special cases for them.
        if (strcmp(parameter, 'modelChiSquare'))
            allTransitsParameter = struct('value', allTransitsFit.modelChiSquare, ...
                'uncertainty', 0);
            oddTransitsParameter = struct('value', oddTransitsFit.modelChiSquare, ...
                'uncertainty', 0);
            evenTransitsParameter = struct('value', evenTransitsFit.modelChiSquare, ...
                'uncertainty', 0);
            allDegreesOfFreedom = struct('value', allTransitsFit.modelDegreesOfFreedom, ...
                'uncertainty', 0);
            oddDegreesOfFreedom = struct('value', oddTransitsFit.modelDegreesOfFreedom, ...
                'uncertainty', 0);
            evenDegreesOfFreedom = struct('value', evenTransitsFit.modelDegreesOfFreedom, ...
                'uncertainty', 0);
        elseif (strcmp(parameter, 'modelFitSnr'))
            allTransitsParameter = struct('value', allTransitsFit.modelFitSnr, ...
                'uncertainty', 0);
            oddTransitsParameter = struct('value', oddTransitsFit.modelFitSnr, ...
                'uncertainty', 0);
            evenTransitsParameter = struct('value', evenTransitsFit.modelFitSnr, ...
                'uncertainty', 0);
        else
            allTransitsParameter = retrieve_model_parameter(allTransitsFit.modelParameters, parameter);
            if (allTransitsParameter.uncertainty == -1)
                allTransitsUncertainty = '';
            else
                allTransitsUncertainty = sprintf(uncertaintyFormat, allTransitsParameter.uncertainty);
            end
            
            oddTransitsParameter = retrieve_model_parameter(oddTransitsFit.modelParameters, parameter);
            if (oddTransitsParameter.uncertainty == -1)
                oddTransitsUncertainty = '';
            else
                oddTransitsUncertainty = sprintf(uncertaintyFormat, oddTransitsParameter.uncertainty);
            end
            
            evenTransitsParameter = retrieve_model_parameter(evenTransitsFit.modelParameters, parameter);
            if (evenTransitsParameter.uncertainty == -1)
                evenTransitsUncertainty = '';
            else
                evenTransitsUncertainty = sprintf(uncertaintyFormat, evenTransitsParameter.uncertainty);
            end
        end
        
        % Special cases for formats.
        if (strcmp(parameter, 'modelChiSquare'))
            valueFormat = '%1.1f (%.1f)'; % plus DoF
        elseif (strcmp(parameter, 'transitDepthPpm') ...
                || strcmp(parameter, 'equilibriumTempKelvin'))
            valueFormat = '%1.0f';
        elseif (strcmp(parameter, 'transitEpochBkjd') ...
                || strcmp(parameter, 'ratioPlanetRadiusToStarRadius') ...
                || strcmp(parameter, 'orbitalPeriodDays'))
            valueFormat = '%1.7f';
        elseif (strcmp(parameter, 'modelFitSnr'))
            valueFormat = '%1.1f';
        end
        
        % Calculate the difference columns for odd/even transit fits.
        diffString = '';
        diff = abs(oddTransitsParameter.value - evenTransitsParameter.value);
        if (~isnan(diff))
            diffString = sprintf(diffFormat, diff);
        end
        modifiedDiffString = '';
        if (strcmp(parameter, 'transitEpochBkjd'))
            diff = abs(diff - allTransitsFitPeriod.value);
            % Old behavior used the evenTransitFit struct.
            % orbitalPeriod = retrieve_model_parameter(evenTransitsFit.modelParameters, 'orbitalPeriodDays');
            % diff = abs(diff - orbitalPeriod.value);
        end
        modifiedDiff = diff/sqrt(oddTransitsParameter.uncertainty^2 + evenTransitsParameter.uncertainty^2);
        if (~isnan(modifiedDiff) && ~isinf(modifiedDiff) && ...
                (oddTransitsParameter.uncertainty ~= -1) && ...
                (evenTransitsParameter.uncertainty ~= -1))
            modifiedDiffString = sprintf(modifiedDiffFormat, modifiedDiff);
        end
        
        % Format the value.
        if (strcmp(parameter, 'modelChiSquare'))
            allTransitsValue = ...
                sprintf(valueFormat, allTransitsParameter.value, allDegreesOfFreedom.value);
        elseif (allTransitsParameter.uncertainty == -1)
            allTransitsValue = '';
        else
            allTransitsValue = ...
                sprintf(valueFormat, allTransitsParameter.value);
        end
        
        if (strcmp(parameter, 'modelChiSquare'))
            oddTransitsValue = ...
                sprintf(valueFormat, oddTransitsParameter.value, oddDegreesOfFreedom.value);
        elseif (oddTransitsParameter.uncertainty == -1)
            oddTransitsValue = '';
        else
            oddTransitsValue = ...
                sprintf(valueFormat, oddTransitsParameter.value);
        end
        
        if (strcmp(parameter, 'modelChiSquare'))
            evenTransitsValue = ...
                sprintf(valueFormat, evenTransitsParameter.value, evenDegreesOfFreedom.value);
        elseif (evenTransitsParameter.uncertainty == -1)
            evenTransitsValue = '';
        else
            evenTransitsValue = ...
                sprintf(valueFormat, evenTransitsParameter.value);
        end
            
        % Emit a row for the given parameter.
        row = {label ...
            allTransitsValue ...
            allTransitsUncertainty ...
            allTransitsValue ...
            oddTransitsValue ...
            oddTransitsUncertainty ...
            evenTransitsValue ...
            evenTransitsUncertainty ...
            oddTransitsValue ...
            evenTransitsValue ...
            units ...
            modifiedDiffString ...
            diffString};
    end

%% create_alltransits_row_with_dof
    function row = create_alltransits_row_with_dof(label, value, dofValue)
        allTransitsValue = sprintf('%1.1f (%1.0f)', value, dofValue);
        row = {label ...
            allTransitsValue ...
            '' ... % allTransitsUncertainty
            allTransitsValue ...
            '' ... % oddTransitsValue
            '' ... % oddTransitsUncertainty
            '' ... % evenTransitsValue
            '' ... % evenTransitsUncertainty
            '' ... % oddTransitsValue
            '' ... % evenTransitsValue
            '' ... % units
            '' ... % modifiedDiffString
            '' ... % diffString
            };
    end
end
