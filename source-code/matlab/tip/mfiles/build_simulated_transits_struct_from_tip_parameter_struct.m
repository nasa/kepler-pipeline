function [os] = build_simulated_transits_struct_from_tip_parameter_struct(is, varargin)
% function [os] = build_simulated_transits_struct_from_tip_parameter_struct(is, varargin)
%
% Produce a simulatedTransitsStructArray as used in DV to inject transits into the pixel time series if simulatedTransitsEnabled = true. A
% list of keplerIds may be passed in as an nTargetx1 array and only the matching keplerIds will be populated in the simulatedTransitsStruct.
% The default is to return entries for all keplerIds in the tip text file. 
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

% build list of keplerIds
if nargin > 1
    keplerIdList = varargin{1};
else
    keplerIdList = is.keplerId;
end

% which keplerIds on the input list do we have parameters for in the is?
tf = ismember( is.keplerId, keplerIdList );

if ~any(tf)
    % trivial case
    os = [];
    return;
else
    % set up first level of struct
    os.keplerId            = is.keplerId(tf);
    os.offsetEnabled       = logical(is.transitOffsetEnabled(tf));
    os.offsetArcSec        = is.transitOffsetArcsec(tf);
    os.offsetPhase         = is.transitOffsetPhase(tf);        
    os.transitSeparation   = is.transitSeparationDays(tf);
    os.offsetTransitDepth  = is.transitOffsetDepthPpm(tf) ./ 1e6;
    os.modeledDepth        = is.transitDepthPpm(tf) ./ 1e6;
    os.modeledWidth        = is.transitDurationHours(tf);

    valueStruct = struct('value',NaN,'uncertainty',-1);
    
%     modelNamesStruct = struct('transitModelName',       'mandel-agol_geometric_transit_model',...
%                               'limbDarkeningModelName', 'claret_nonlinear_limb_darkening_model');    
    

    modelNamesStruct = struct('transitModelName',       'mandel-agol_geometric_transit_model',...
                              'limbDarkeningModelName', 'kepler_nonlinear_limb_darkening_model');

%     modelNamesStruct = struct('transitModelName',       'mandel-agol_geometric_transit_model',...
%                               'limbDarkeningModelName', 'claret_nonlinear_limb_darkening_model_2011');
                          
    os.transitModelStructArray = repmat(struct('cadenceTimes',              [],...
                                               'log10SurfaceGravity',       valueStruct,...
                                               'effectiveTemp',             valueStruct,...
                                               'log10Metallicity',          valueStruct,...
                                               'radius',                    valueStruct,...
                                               'transitBufferCadences',     [],...
                                               'transitSamplesPerCadence',  11,...
                                               'configMaps',                [],...
                                               'modelNamesStruct',          modelNamesStruct,...
                                               'planetModel',               [],...
                                               'debugFlag',                 0),...
                                         numel(find(tf)),1);
end

% populate second level of struct
thisTargetIdx = 1;
for idx = rowvec(find(tf))

    % build up planetModel
    planetModel = struct('transitEpochBkjd',                is.epochBjd(idx),...
                         'eccentricity',                    is.eccentricity(idx),...
                         'longitudeOfPeriDegrees',          is.longitudeOfPeriDegrees(idx),...
                         'minImpactParameter',              is.impactParameter(idx),...
                         'orbitalPeriodDays',               is.orbitalPeriodDays(idx),...
                         'starRadiusSolarRadii',            is.stellarRadiusRsun(idx),...
                         'ratioPlanetRadiusToStarRadius',   is.RplanetOverRstar(idx),...
                         'ratioSemiMajorAxisToStarRadius',  is.semiMajorAxisOverRstar(idx));

    % fill out the target dependent transitModelStructArray elements
    os.transitModelStructArray(thisTargetIdx).log10SurfaceGravity.value = is.stellarLog10Gravity(idx);
    os.transitModelStructArray(thisTargetIdx).effectiveTemp.value       = is.stellarEffectiveTempKelvin(idx);
    os.transitModelStructArray(thisTargetIdx).log10Metallicity.value    = is.stellarLog10Metalicity(idx);
    os.transitModelStructArray(thisTargetIdx).radius.value              = is.stellarRadiusRsun(idx);
    os.transitModelStructArray(thisTargetIdx).transitBufferCadences     = is.transitBufferCadences(idx);
    os.transitModelStructArray(thisTargetIdx).planetModel               = planetModel;

    thisTargetIdx = thisTargetIdx + 1;
end    

