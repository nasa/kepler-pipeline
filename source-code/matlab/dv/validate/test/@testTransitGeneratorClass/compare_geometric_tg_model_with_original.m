function compare_geometric_tg_model_with_original(iTarget, inputsStruct)
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

debugFlag = 0;

if nargin == 1
    load dv-inputs-0.mat inputsStruct
end


%--------------------------------------------------------------------------
% test new transit model, new limb darkening model
%--------------------------------------------------------------------------
tic
display(' Testing the new transit model and new LD model')

inputsStruct.dvConfigurationStruct.transitModelName = 'mandel-agol_geometric_transit_model';
inputsStruct.dvConfigurationStruct.limbDarkeningModelName = 'kepler_nonlinear_limb_darkening_model';

dbstop if error;

transitModelStruct = convert_tps_parameters_to_geometric_transit_model(...
    inputsStruct, iTarget);

transitModelStruct.debugFlag = debugFlag;
[transitModelObject] = transitGeneratorClass(transitModelStruct);


[transitModelLightCurve4, cadenceTimes4] = ...
    generate_planet_model_light_curve(transitModelObject);


toc;
display(['New transit model and new LD model: ' num2str(toc)])
display(' ')
display('Planet model: ' )
transitModelStruct.planetModel
display(' ')
display(' ')

%--------------------------------------------------------------------------
% test old transit model, old limb darkening model
%--------------------------------------------------------------------------
tic
%display(' Testing the old transit model and old LD model')

inputsStruct.dvConfigurationStruct.transitModelName = 'mandel-agol_transit_model';
inputsStruct.dvConfigurationStruct.limbDarkeningModelName = 'claret_nonlinear_limb_darkening_model';

dbstop if error;

transitModelStruct = convert_tps_parameters_to_geometric_transit_model(...
    inputsStruct, iTarget);

transitModelStruct.debugFlag = debugFlag;
[transitModelObject] = transitGeneratorClass(transitModelStruct);


[transitModelLightCurve1, cadenceTimes1] = ...
    generate_planet_model_light_curve(transitModelObject);

toc;
display(['Old transit model and old LD model: ' num2str(toc)])
display(' ')
display('Planet model: ' )
transitModelStruct.planetModel
display(' ')
display(' ')



%--------------------------------------------------------------------------
% test old transit model, new limb darkening model
%--------------------------------------------------------------------------
tic
%display(' Testing the old transit model and new LD model')

inputsStruct.dvConfigurationStruct.transitModelName = 'mandel-agol_transit_model';
inputsStruct.dvConfigurationStruct.limbDarkeningModelName = 'kepler_nonlinear_limb_darkening_model';

dbstop if error;

transitModelStruct = convert_tps_parameters_to_geometric_transit_model(...
    inputsStruct, iTarget);

transitModelStruct.debugFlag = debugFlag;
[transitModelObject] = transitGeneratorClass(transitModelStruct);


[transitModelLightCurve3, cadenceTimes3] = ...
    generate_planet_model_light_curve(transitModelObject);


toc;
display(['Old transit model and new LD model: ' num2str(toc)])
display(' ')
display('Planet model: ' )
transitModelStruct.planetModel
display(' ')
display(' ')



%--------------------------------------------------------------------------
% test new transit model, old limb darkening model
%--------------------------------------------------------------------------
tic
display(' Testing the new transit model and old LD model')

inputsStruct.dvConfigurationStruct.transitModelName = 'mandel-agol_geometric_transit_model';
inputsStruct.dvConfigurationStruct.limbDarkeningModelName = 'claret_nonlinear_limb_darkening_model';

dbstop if error;

transitModelStruct = convert_tps_parameters_to_geometric_transit_model(...
    inputsStruct, iTarget);

transitModelStruct.debugFlag = debugFlag;
[transitModelObject] = transitGeneratorClass(transitModelStruct);


[transitModelLightCurve2, cadenceTimes2] = ...
    generate_planet_model_light_curve(transitModelObject); %#ok<*NASGU,*ASGLU>


toc;
display(['New transit model and old LD model: ' num2str(toc)])
display(' ')
display('Planet model: ' )
transitModelStruct.planetModel
display(' ')
display(' ')



return;





load /path/to/rec/test-data/dv/unit-tests/transitGeneratorClass/transit-generator-model-tps-earth-sun.mat

transitModel.planetModel.orbitalPeriodDays = 30;
transitModel.debugFlag = 2;

dbstop if error;
[transitModelObject] = transitGeneratorClass(transitModel);


[transitModelLightCurveOld, cadenceTimesOld] = ...
    generate_planet_model_light_curve(transitModelObject);



% set up new transit model struct (for 7.0 inputs)
transitModelStructNew = transitModel;

% add new parameters
transitModelStructNew.log10Metallicity                        = 0;
transitModelStructNew.modelNamesStruct.transitModelName       = 'mandel-agol_geometric_transit_model';
%transitModelStructNew.modelNamesStruct.limbDarkeningModelName = 'kepler_nonlinear_limb_darkening_model';
transitModelStructNew.modelNamesStruct.limbDarkeningModelName = 'claret_nonlinear_limb_darkening_model';
transitModelStructNew.transitSamplesPerCadence                = 11;

% remove old planet model fields
transitModelStructNew.planetModel = rmfield(transitModelStructNew.planetModel, 'transitDepthPpm');

% add with scaled parameters

transitModelStructNew.planetModel.ratioPlanetRadiusToStarRadius  = 0.01241;
transitModelStructNew.planetModel.ratioSemiMajorAxisToStarRadius = 40.634;



[transitModelObject] = transitGeneratorClass(transitModelStructNew);

[transitModelLightCurveNew, cadenceTimesNew] = ...
    generate_planet_model_light_curve(transitModelObject);


return;
