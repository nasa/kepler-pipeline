function transitModelStruct = create_transit_model_inputs_from_dv_inputs(inputsStruct, targetIndex, spiceFileDir)
%
%
% INPUTS:
%
% inputsStruct, which can be retrieved from (example):
% load /path/to/dv-matlab-880-34853/dv-inputs-0.mat inputsStruct
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


%--------------------------------------------------------------------------
% extract transit generator class parameters
%--------------------------------------------------------------------------
debugFlag = false;

transitBufferCadences = inputsStruct.planetFitConfigurationStruct.transitBufferCadences;

configMaps   = inputsStruct.configMaps(1);

modelNamesStruct.transitModelName       = inputsStruct.dvConfigurationStruct.transitModelName;
modelNamesStruct.limbDarkeningModelName = inputsStruct.dvConfigurationStruct.limbDarkeningModelName;

%--------------------------------------------------------------------------
% compute barycentric corrected times
%--------------------------------------------------------------------------
% if nargin > 2
%     inputsStruct.raDec2PixModel.spiceFileDir = spiceFileDir;
% end
%
% inputsStructTmp = compute_barycentric_corrected_timestamps(inputsStruct);
%
% cadenceTimes = inputsStructTmp.barycentricCadenceTimes(targetIndex).midTimestamps;
load barycentricCadenceTimes barycentricCadenceTimes
cadenceTimes = barycentricCadenceTimes;


%--------------------------------------------------------------------------
% extract stellar parameters
%--------------------------------------------------------------------------
log10SurfaceGravity = inputsStruct.targetStruct(targetIndex).log10SurfaceGravity.value;
effectiveTemp       = inputsStruct.targetStruct(targetIndex).effectiveTemp.value;

%--------------------------------------------------------------------------
% extract planet model parameters
%--------------------------------------------------------------------------


thresholdCrossingEvent = inputsStruct.targetStruct(targetIndex).thresholdCrossingEvent;

planetModel.transitEpochMjd         = thresholdCrossingEvent.epochMjd;
planetModel.eccentricity            = 0;
planetModel.longitudeOfPeriDegrees  = 0;
planetModel.minImpactParameter      = 0;
planetModel.starRadiusSolarRadii    = inputsStruct.targetStruct(targetIndex).radius.value;
planetModel.orbitalPeriodDays       = thresholdCrossingEvent.orbitalPeriod;

% compute the transit depth using method from convert_tps_parameters_to_transit_model:
%
% TPS doesn't determine anything which is quite comparable to the transit depth, but it
% does estimate the max single event statistic in sigmas; this is, very roughly, the ratio
% of the transit depth to the noise amplitude for a single transit.  The code block below
% does a somewhat hokey job of estimating the transit depth from the single event
% statistic.  It's probably not a very good estimator, but good enough (I hope!) for
% seeding the fit with.

transitDurationDays = thresholdCrossingEvent.trialTransitPulseDuration * ...
    get_unit_conversion('hour2day') ;


% get the cadence duration.  There is a remote possibility that the cadence duration will
% vary during the time of the data.  We will use the duration which is appropriate during
% the first cadence time, which is certainly good enough for the estimation purposes in
% this method.

configMapObject = configMapClass(configMaps);

mjd = inputsStruct.dvCadenceTimes.midTimestamps(1);

exposureTimeSec = get_exposure_time(configMapObject, mjd);
readoutTimeSec = get_readout_time(configMapObject, mjd);

numExposuresPerCadence = ...
    get_number_of_exposures_per_long_cadence_period(configMapObject, mjd) ;

cadenceDurationDays = numExposuresPerCadence * (exposureTimeSec + readoutTimeSec) * ...
    get_unit_conversion('sec2day') ;

fluxTimeSeries = inputsStruct.targetStruct(targetIndex).correctedFluxTimeSeries;

transitDepth = median(fluxTimeSeries.uncertainties) / ...
    median(fluxTimeSeries.values) * ...
    sqrt(cadenceDurationDays / transitDurationDays) * ...
    thresholdCrossingEvent.maxSingleEventSigma ;

% don't allow the transit depth to exceed the total range of values in the flux time
% series

transitDepth = min(transitDepth, fluxTimeSeriesRange) ;

planetModel.transitDepthPpm = transitDepth * 1e6 ;




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
