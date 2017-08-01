function create_light_curve_from_etem_ground_truth(runDirPath)
%function create_light_curve_from_etem_ground_truth(runDirPath)
%
% function to compare the etem ground truth light curve with one generated
% with DV code using etem ground truth parameters
%
%
%
%
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

if nargin == 0
    %runDirPath = '/path/to/matlab/dv/etem_pipeline_runs/run_long_m2o4s1/';

    runDirPath = '/path/to/dev-pipeline/30Aug2009/etem/long/run_long_m7o3s1/';

end

cd(runDirPath)


%--------------------------------------------------------------------------
% load etem2 run ground truth structs
%--------------------------------------------------------------------------

display('Loading etem2 ground truth data scienceTargetList.mat');
load scienceTargetList.mat

display('Loading etem2 ground truth data targetScienceManagerData.mat');
warning off all

load targetScienceManagerData.mat
warning on all

%--------------------------------------------------------------------------
% loop through targets and save the Kepler ID for targets with injected
% planetary transits
%--------------------------------------------------------------------------
targetListKeplerIDs        = [targetList.keplerId]';


for i = 1:length(targetListKeplerIDs)


    numInjectedLightCurves = length(targetList(i).lightCurveList);

    keplerId = targetScienceManagerData.targetList(i).keplerId;

    if numInjectedLightCurves > 1


        %--------------------------------------------------------------------------
        % extract etem2 data
        %--------------------------------------------------------------------------

        limbDarkeningCoeffs = targetList(i).initialData(2).data.primaryPropertiesStruct.limbDarkeningCoeffs;

        display('ETEM2 limb darkening coefficients are:')
        limbDarkeningCoeffs(:)


        transitingOrbitObject = targetScienceManagerData.targetList(i).lightCurveList(2).object.transitingOrbitObject;

        descriptionString = targetScienceManagerData.targetList(i).lightCurveList(2).description;

        timeArrayDays  = transitingOrbitObject.timeVector*get_unit_conversion('sec2day');

        lightCurveData = transitingOrbitObject.lightCurveData;

        lightCurve     = transitingOrbitObject.lightCurve;


        transitEpochMjd        = lightCurveData.transitTimesMks(1)*get_unit_conversion('sec2day');
        eccentricity           = lightCurveData.eccentricity;
        minImpactParameter     = lightCurveData.minimumImpactParameter;
        starRadiusSolarRadii   = transitingOrbitObject.primaryRadiusMks *get_unit_conversion('meter2solarRadius');
        transitDepthPpm        = (1 - min(lightCurve))*1e6;
        orbitalPeriodDays      = transitingOrbitObject.orbitalPeriod;

        longitudeOfPeriDegrees = 0;
        % check this (longitudeOfPeriDegrees), may need to compute angle, altho won't make difference in DV:
        %
        % targetScienceManagerData.targetList(5).lightCurveList(2).object.transitingOrbitObject.periCenterR
        %    ans = 1.433290310212406e+10
        % targetScienceManagerData.targetList(5).lightCurveList(2).object.transitingOrbitObject.periCenterV
        %    ans =  1.0e+04 *  0   9.097888061565953


        transitTimeBufferDays  = transitingOrbitObject.transitTimeBuffer*get_unit_conversion('sec2day');
        cadencesPerDay         = transitingOrbitObject.runParamsClass.keplerData.cadencesPerDay;

        transitTimeBufferCadences = transitTimeBufferDays*cadencesPerDay;

        %--------------------------------------------------------------------------
        % plot the etem2 injected light curve for planetary transit
        %--------------------------------------------------------------------------

        figure;
        h1 = plot(mod(timeArrayDays, orbitalPeriodDays), lightCurve, 'cx-');

        title(['Target ' num2str(keplerId) ',  Etem2 ground truth (' num2str(descriptionString) ')' ])

        %--------------------------------------------------------------------------
        % set up DV transit model struct with etem2 parameters and create light curve
        %--------------------------------------------------------------------------

        transitModelStruct.cadenceTimes         = timeArrayDays;

        transitModelStruct.log10SurfaceGravity  = targetList(i).logSurfaceGravity;
        transitModelStruct.effectiveTemp        = targetList(i).effectiveTemperature;
        transitModelStruct.debugFlag            = false;



        transitModelStruct.modelNamesStruct.transitModelName       = 'mandel-agol_transit_model';
        transitModelStruct.modelNamesStruct.limbDarkeningModelName = 'claret_nonlinear_limb_darkening_model';

        transitModelStruct.transitBufferCadences = transitTimeBufferCadences;

        load /path/to/matlab/dv/test/configMaps.mat configMaps
        % transitModelStruct.configMaps            = retrieve_config_map(transitModelStruct.cadenceTimes(1));
        transitModelStruct.configMaps = configMaps;

        transitModelStruct.planetModel.transitEpochMjd        = transitEpochMjd;
        transitModelStruct.planetModel.eccentricity           = eccentricity;
        transitModelStruct.planetModel.minImpactParameter     = minImpactParameter;
        transitModelStruct.planetModel.starRadiusSolarRadii   = starRadiusSolarRadii;
        transitModelStruct.planetModel.transitDepthPpm        = transitDepthPpm;
        transitModelStruct.planetModel.orbitalPeriodDays      = orbitalPeriodDays;
        transitModelStruct.planetModel.longitudeOfPeriDegrees = longitudeOfPeriDegrees;


        if eccentricity == 0
            % instantiate the object
            transitModelObject = transitGeneratorClass(transitModelStruct);

            limbDarkeningCoefficients = get(transitModelObject, 'limbDarkeningCoefficients');

            display('DV limb darkening coefficients are: ')
            limbDarkeningCoefficients(:)

            % generate the relative flux light curve
            dbstop if error; [transitModelLightCurve, cadenceTimes]  =  generate_planet_model_light_curve(transitModelObject);

            hold on
            h2 = plot(mod(cadenceTimes, orbitalPeriodDays), transitModelLightCurve+1, 'm.-');
            
            legend([h1 h2], {'ETEM2'; 'DV'}, 'location', 'best')
        else
            legend(h1, {'ETEM2 LC not fit (non-zero ecc)'}, 'location', 'best')
            
        end

    end
end


return;

