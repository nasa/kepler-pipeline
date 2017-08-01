function transitModelStruct = validate_transit_generator_inputs(transitModelStruct)
%
% function to validate the inputs to the transit generator class.
%
%
% INPUTS (example):
%
%   transitModelStruct =
%
%              cadenceTimes: [3000x1 double]
%       log10SurfaceGravity: 4.4378         checked for Nans
%             effectiveTemp: 5778           checked for Nans
%          log10Metallicity: 0              checked for existence and for Nans
%                 debugFlag: 1
%          modelNamesStruct: [1x1 struct]   validated herein
%     transitBufferCadences: 1              validated in validate_dv_inputs
%                configMaps: [1x1 struct]   intentionally not validated in validate_dv_inputs
%               planetModel: [1x1 struct]
%
% transitModelStruct.modelNamesStruct =
%           transitModelName: 'mandel-agol_transit_model'
%     limbDarkeningModelName: 'claret_nonlinear_limb_darkening_model
%
% transitModelStruct.planetModel =
%               eccentricity: 0
%     longitudeOfPeriDegrees: 0
%         minImpactParameter: 0
%       starRadiusSolarRadii: 1             checked for existence and for Nans
%            transitDepthPpm: 103
%          orbitalPeriodDays: 10
%           transitEpochBkjd: 5.5012e+04
%
% Version date:  2012-August-23.
%
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

% Modification History:
%
%   2012-August-23, JL:
%     Stellar parameter structs are added in transitModelStruct
%   2010-Nov-08, EQ:
%     Initial release.  Will add more checks to planet model parameters as
%     DV v7.0 progresses.
%


% if no input, generate an error.
if nargin == 0 || isempty(transitModelStruct)
    error('DV:transitGeneratorClass:EmptyInputStruct', ...
        'The constructor must be called with an input structure');
end

% extract inputs
log10SurfaceGravity    = transitModelStruct.log10SurfaceGravity;
effectiveTemp          = transitModelStruct.effectiveTemp;
log10Metallicity       = transitModelStruct.log10Metallicity;
radius                 = transitModelStruct.radius;
modelNamesStruct       = transitModelStruct.modelNamesStruct;
planetModel            = transitModelStruct.planetModel;

% extract model names
transitModelName       = modelNamesStruct.transitModelName;
limbDarkeningModelName = modelNamesStruct.limbDarkeningModelName;

%--------------------------------------------------------------------------
% check the KIC parameters for valid values
%--------------------------------------------------------------------------
if isnan(log10SurfaceGravity.value)
    error('dv:transitGeneratorClass:log10SurfaceGravityNan', ...
        'transitGeneratorClass:  log10SurfaceGravity set to NaN');
    
end


if isnan(effectiveTemp.value)
    error('dv:transitGeneratorClass:effectiveTempNan', ...
        'transitGeneratorClass:  effectiveTemp set to NaN');
end


if isnan(log10Metallicity.value)
    error('dv:transitGeneratorClass:log10MetallicityNan', ...
        'transitGeneratorClass:  log10Metallicity set to NaN');
end


if isnan(radius.value)
    error('dv:transitGeneratorClass:starRadiusSolarRadiiNaN', ...
        'transitGeneratorClass:  starRadiusSolarRadii set to NaN');
end




%--------------------------------------------------------------------------
% validate the model names
%--------------------------------------------------------------------------
if  ~strcmpi(transitModelName, 'gaussian')  && ...
        ~strcmpi(transitModelName, 'mandel-agol_transit_model') && ...
        ~strcmpi(transitModelName, 'mandel-agol_geometric_transit_model') && ...
        ~strcmpi(transitModelName, 'trapezoidal_model')
    
    error('dv:transitGeneratorClass:invalidModel', ...
        'transitGeneratorClass: the only models that are currently supported are ''gaussian'', ''mandel-agol_transit_model'' and ''mandel-agol_geometric_transit_model''');

end

if ~isempty(limbDarkeningModelName)
    
    if ~strcmpi(limbDarkeningModelName, 'claret_nonlinear_limb_darkening_model') && ...
            ~strcmpi(limbDarkeningModelName, 'kepler_nonlinear_limb_darkening_model') && ...
            ~strcmpi(limbDarkeningModelName, 'claret_nonlinear_limb_darkening_model_2011')
        
        
        error('dv:transitGeneratorClass:invalidModel', ...
            'transitGeneratorClass: the only models that are currently supported are ''claret_nonlinear_limb_darkening_model'', ''kepler_nonlinear_limb_darkening_model'' and ''claret_nonlinear_limb_darkening_model_2011''');
    end
    
end


return;
