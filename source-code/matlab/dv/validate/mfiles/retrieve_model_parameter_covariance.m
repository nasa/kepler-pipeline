function [modelParameterCovariance] = retrieve_model_parameter_covariance( ...
modelParameters, fullModelParameterCovariance, parameterNameCellArray)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [modelParameterCovariance] = retrieve_model_parameter_covariance( ...
% modelParameters, fullModelParameterCovariance, parameterNameCellArray)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Retrieve the covariance matrix for the desired parameters from the full
% covariance matrix for all fitted and derived parameters.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:
%
%     modelParameters is an array of structs (one per model parameter) with
%     the following fields:
%
%                         name: [string]  parameter name
%                         value: [float]  estimated parameter value
%                   uncertainty: [float]  uncertainty in estimated parameter
%                      fitted: [logical]  true if parameter was fitted,
%                                         false if derived
%          fullModelParameterCovariance:
%                          [float array]  covariance matrix for all model
%                                         parameters
%
%       parameterNameCellArray: [string]  desired parameter names
%
% Outputs:
%   
%              modelParameterCovariance:
%                          [float array]  covariance matrix for desired model
%                                         parameters (nParameters x nParameters)
%
%
% As of 12/09/13 the following strings are expected for modelParameters.name
% 
%     transitEpochBkjd
%     eccentricity    
%     longitudeOfPeriDegrees
%     planetRadiusEarthRadii
%     semiMajorAxisAu       
%     minImpactParameter    
%     starRadiusSolarRadii
%     transitDurationHours 
%     transitIngressTimeHours
%     transitDepthPpm      
%     orbitalPeriodDays
%     ratioPlanetRadiusToStarRadius
%     ratioSemiMajorAxisToStarRadius
%     inclinationDegrees
%     equilibriumTempKelvin
% 
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
    
% Set default outputs
modelParameterCovariance = [];

% Check whether parameterNameCellArray contains legal parameter names
legalNames = get_planet_model_legal_fields('all');
if ~all(ismember(parameterNameCellArray, legalNames))
    warning('DV:retrieveModelParameterCovariance:illegalParam',...
        'Cell array of parameter names contains an illegal name');
    return;
end

% Get cell arrays of parameter names
if isempty(modelParameters)
    warning('DV:retrieveModelParameterCovariance:illegalInput',...
            'The input modelParameters are empty');
    return;
else
    nameCellArray  = {modelParameters.name};
end

% Get indices of matching model parameters
nParameters = length(modelParameters);
fullModelParameterCovariance = fullModelParameterCovariance(:);

[tf, loc] = ismember(parameterNameCellArray, nameCellArray); 
if ~all(tf)
    warning('DV:retrieveModelParameterCovariance:missingParams',...
        'Unable to retrieve covariance for all desired parameters');
    return;
elseif length(fullModelParameterCovariance) ~= nParameters * nParameters
    warning('DV:retrieveModelParameterCovariance:illegalInput',...
        'Model parameter covariance matrix is not sized correctly');
    return;
else
    fullModelParameterCovariance = ...
        reshape(fullModelParameterCovariance, [nParameters, nParameters]);
    modelParameterCovariance = fullModelParameterCovariance(loc, loc);
end

return
