%% generate_fitter_results_table
%
% [startTable, endTable, allFitsFailed] = ...
%     generate_reduced_parameter_fit_results_tables(reducedParameterFitResults)
%
%% INPUTS
%
%   *reducedParameterFitResults:* [struct] four parameter fit results using
%   range of impact parameters
%
%% OUTPUTS
%
%    *startTable:* [cell array] rows up to but not including fit used to
%   seed five parameter model fits
%      *endTable:* [cell array] rows starting with fit used to seed five
%     parameter model fits
% *allFitsFailed:* [logical] true if all the reduced parameter fits failed
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
function [startTable, endTable, allFitsFailed] = ...
    generate_reduced_parameter_fit_results_tables(reducedParameterFitResults)

warning('off', 'DV:retrieveModelParameter:illegalInput');
warning('off', 'DV:retrieveModelParameter:missingParams');

startIndex = 1;
endIndex = 1;
allFitsFailed = 'false';

minChiSquareIndex = determine_min_chi_square_index(reducedParameterFitResults);

if (minChiSquareIndex == 0)
    allFitsFailed = 'true';
end

if (minChiSquareIndex > 0)
    startTable = cell(minChiSquareIndex - 1, 11);
    endTable = cell(length(reducedParameterFitResults) - minChiSquareIndex + 1, 11);
else
    startTable = cell(0, 11);
    endTable = cell(length(reducedParameterFitResults), 11);
end
for iPlanetModelFit = 1:length(reducedParameterFitResults)
    
    planetModelFit = reducedParameterFitResults(iPlanetModelFit);
    
    if (iPlanetModelFit < minChiSquareIndex)
        startTable(startIndex,:) = create_row(planetModelFit);
        startIndex = startIndex + 1;
    else
        endTable(endIndex,:) = create_row(planetModelFit); 
        endIndex = endIndex + 1;
    end
    
end % iPlanetModelFit

warning('on', 'DV:retrieveModelParameter:illegalInput');
warning('on', 'DV:retrieveModelParameter:missingParams');

%%
    function minValueIndex = determine_min_chi_square_index(planetModelFits)
        minValue = -1;
        minValueIndex = 0;
        for iFit = 1:length(planetModelFits)
            modelFit = planetModelFits(iFit);
            if ((modelFit.modelChiSquare < minValue || minValue == -1) ...
                && modelFit.modelChiSquare ~= -1)
                minValue = modelFit.modelChiSquare;
                minValueIndex = iFit;
            end
        end
    end

%% create_row
    function row = create_row(planetModelFit)
        
        impactParameter = retrieve_model_parameter( ...
            planetModelFit.modelParameters, 'minImpactParameter');
        
        if (~fit_failed(planetModelFit))
            planetRadiusToStarRadiusParameter = retrieve_model_parameter( ...
                planetModelFit.modelParameters, 'ratioPlanetRadiusToStarRadius');
            semiMajorAxisToStarRadiusParameter = retrieve_model_parameter( ...
                planetModelFit.modelParameters, 'ratioSemiMajorAxisToStarRadius');
            transitDepthParameter = retrieve_model_parameter( ...
                planetModelFit.modelParameters, 'transitDepthPpm');
            transitDurationParameter = retrieve_model_parameter( ...
                planetModelFit.modelParameters, 'transitDurationHours');
            
            % If the uncertainty is -1, neither value nor uncertainty are
            % to be written
            
            [planetRadiusToStarRadiusValueString, ...
                planetRadiusToStarRadiusUncertaintyString] = ...
                format_value_uncertainty_pair(...
                planetRadiusToStarRadiusParameter, '%1.7f', '%1.4e');
            
            [semiMajorAxisToStarRadiusValueString, ...
                semiMajorAxisToStarRadiusUncertaintyString] = ...
                format_value_uncertainty_pair(...
                semiMajorAxisToStarRadiusParameter, '%1.4f', '%1.4e');
            
            [transitDepthValueString, ...
                transitDepthUncertaintyString] = ...
                format_value_uncertainty_pair(...
                transitDepthParameter, '%1.0f', '%1.4e');
            
            [transitDurationValueString, ...
                transitDurationUncertaintyString] = ...
                format_value_uncertainty_pair(...
                transitDurationParameter, '%1.4f', '%1.4e');

            row = { ...
                sprintf('%1.2f', impactParameter.value) ...
                sprintf('%1.1f', planetModelFit.modelFitSnr) ...
                sprintf('%1.1f', planetModelFit.modelChiSquare) ...
                planetRadiusToStarRadiusValueString ...
                planetRadiusToStarRadiusUncertaintyString...
                semiMajorAxisToStarRadiusValueString ...
                semiMajorAxisToStarRadiusUncertaintyString ...
                transitDepthValueString ...
                transitDepthUncertaintyString ...
                transitDurationValueString ...
                transitDurationUncertaintyString ...
                };
        else
            row = { ...
                sprintf('%1.4f', impactParameter.value) ...
                'N/A' ...
                sprintf('%1.0f', planetModelFit.modelChiSquare) ...
                'N/A' ...
                '' ...
                'N/A' ...
                '' ...
                'N/A' ...
                '' ...
                'N/A' ...
                ''
                };
                
        end
    end

%% format_value_uncertainty_pair
%  Given a parameter that has a value field and an uncertainty field, and
%  format strings for those fields, return a pair of formatted strings.
%  If the uncertainty field equals -1, the strings are both empty.

    function [value_string uncertainty_string] = ...
            format_value_uncertainty_pair(parameter, value_format, ...
            uncertainty_format)
        if (parameter.uncertainty == -1)
            % The value and uncertainty are invalid; return empty strings
            value_string = '';
            uncertainty_string = '';
        else
            % The value and uncertaintly are valid; format them
            value_string = sprintf(value_format, parameter.value);
            uncertainty_string = ...
                sprintf(uncertainty_format, parameter.uncertainty);
        end
    end

%% fit_failed
    function failed = fit_failed(planetModelFit)
        
        failed = planetModelFit.modelChiSquare == -1;
    end
end
