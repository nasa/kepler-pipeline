function transitModelStruct = create_transit_model_inputs_from_dv_fit(targetIndex, planetIndex, pathToData)
%
% function to create inputs to the transit signal generator from
% information extracted from the DV fitted parameters
%
%
% INPUTS:
%
% dvResultsStruct, which can be loaded as follows:
%
% load  /path/to/dv-matlab-880-34853/dv_post_fit_workspace.mat
%
%
% OUTPUTS:
%
% transitModelStruct [struct] with the following fields:
%
% transitModelStruct =
%              cadenceTimes: [3000x1 double]
%       log10SurfaceGravity: 4.4378
%             effectiveTemp: 5778
%                 debugFlag: 0
%          modelNamesStruct: [1x1 struct]
%     transitBufferCadences: 1
%                configMaps: [1x1 struct]
%               planetModel: [1x1 struct]
%
%
% transitModelStruct.modelNamesStruct =
%           transitModelName: 'mandel-agol_transit_model'
%     limbDarkeningModelName: 'claret_nonlinear_limb_darkening_model'
%
%
%     transitModelStruct.planetModel =
%            transitEpochMjd: 55012
%               eccentricity: 0
%     longitudeOfPeriDegrees: 0
%         minImpactParameter: 0
%       starRadiusSolarRadii: 1
%            transitDepthPpm: 103
%          orbitalPeriodDays: 365.25
%
%--------------------------------------------------------------------------
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



if nargin == 2
    pathToData = '/path/to/dv-matlab-880-34853';
end


load(fullfile(pathToData, 'dv_post_fit_workspace.mat'),   'dvDataObject', 'dvResultsStruct') ;


% extract parameters after fit
allTransitsFit = dvResultsStruct.targetResultsStruct(targetIndex).planetResultsStruct(planetIndex).allTransitsFit;



%--------------------------------------------------------------------------
% inputs from observable parameters
%--------------------------------------------------------------------------
%
% the computed additional parameters in this case are planetRadiusEarthRadii,
% semiMajorAxisAu, minImpactParameter, starRadiusSolarRadii
%
observableInputs.transitEpochMjd         = allTransitsFit.modelParameters(1).value;
observableInputs.eccentricity            = allTransitsFit.modelParameters(2).value;
observableInputs.longitudeOfPeriDegrees  = allTransitsFit.modelParameters(3).value;
observableInputs.transitDurationHours    = allTransitsFit.modelParameters(8).value;
observableInputs.transitIngressTimeHours = allTransitsFit.modelParameters(9).value;
observableInputs.transitDepthPpm         = allTransitsFit.modelParameters(10).value;
observableInputs.orbitalPeriodDays       = allTransitsFit.modelParameters(11).value;


%--------------------------------------------------------------------------
% inputs from physical parameters
%--------------------------------------------------------------------------
%
% the computed additional parameters in this case are transitDurationHours,
% transitIngressTimeHours, transitDepthPpm, orbitalPeriodDays
%
physicalInputs.transitEpochMjd         = allTransitsFit.modelParameters(1).value;
physicalInputs.eccentricity            = allTransitsFit.modelParameters(2).value;
physicalInputs.longitudeOfPeriDegrees  = allTransitsFit.modelParameters(3).value;
physicalInputs.planetRadiusEarthRadii  = allTransitsFit.modelParameters(4).value;
physicalInputs.semiMajorAxisAu         = allTransitsFit.modelParameters(5).value;
physicalInputs.minImpactParameter      = allTransitsFit.modelParameters(6).value;
physicalInputs.starRadiusSolarRadii    = allTransitsFit.modelParameters(7).value;


%--------------------------------------------------------------------------
% inputs from TPS parameters
%--------------------------------------------------------------------------
%
% the computed additional parameters in this case are semiMajorAxisAu,
% planetRadiusEarthRadii, transitDurationHours, transitIngressTimeHours
%
tpsInputs.transitEpochMjd         = allTransitsFit.modelParameters(1).value;
tpsInputs.eccentricity            = allTransitsFit.modelParameters(2).value;
tpsInputs.longitudeOfPeriDegrees  = allTransitsFit.modelParameters(3).value;
tpsInputs.minImpactParameter      = allTransitsFit.modelParameters(6).value;
tpsInputs.transitDepthPpm         = allTransitsFit.modelParameters(10).value;
tpsInputs.orbitalPeriodDays       = allTransitsFit.modelParameters(11).value;
tpsInputs.starRadiusSolarRadii    = allTransitsFit.modelParameters(7).value;


% additional parameters computed for output
% inclinationDegrees      = allTransitsFit.modelParameters(12).value;



%--------------------------------------------------------------------------
% extract other parameters needed by the transit generator class
%--------------------------------------------------------------------------
debugFlag = true;

transitBufferCadences = dvDataObject.planetFitConfigurationStruct.transitBufferCadences;

configMaps   = dvDataObject.configMaps(1);

modelNamesStruct.transitModelName       = dvDataObject.dvConfigurationStruct.transitModelName;
modelNamesStruct.limbDarkeningModelName = dvDataObject.dvConfigurationStruct.limbDarkeningModelName;


cadenceTimes = dvDataObject.barycentricCadenceTimes(targetIndex).midTimestamps;


%--------------------------------------------------------------------------
% extract stellar parameters
%--------------------------------------------------------------------------
log10SurfaceGravity = dvDataObject.targetStruct(targetIndex).log10SurfaceGravity.value;
effectiveTemp       = dvDataObject.targetStruct(targetIndex).effectiveTemp.value;



%--------------------------------------------------------------------------
% collect planet model parameters
%--------------------------------------------------------------------------
% planetModel = observableInputs;
% planetModel = physicalInputs;
planetModel = tpsInputs;


% add to output struct
transitModelStruct.cadenceTimes          = cadenceTimes;
transitModelStruct.log10SurfaceGravity   = log10SurfaceGravity;
transitModelStruct.effectiveTemp         = effectiveTemp;
transitModelStruct.debugFlag             = debugFlag;
transitModelStruct.modelNamesStruct      = modelNamesStruct;
transitModelStruct.transitBufferCadences = transitBufferCadences;
transitModelStruct.configMaps            = configMaps;
transitModelStruct.planetModel           = planetModel;



return;
