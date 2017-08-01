function [transitModel] = trapezoidal_fit_parameters_to_transit_model( ...
trapezoidalFit, targetStruct, cadenceTimes, planetFitConfigurationStruct, ...
trapezoidalFitConfigurationStruct, configMaps)
%
%  trapezoidal_fit_parameters_to_transit_model -- estimate the physical parameters which
%    correspond to a given threshold crossing event, and return them in the format of a
%    struct which instantiates a transitGeneratorClass object
%
% Version date:  2014-August-27.
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
%    2014-August-27, JT:
%        Refactored from convert_trapezoidal_fit_parameters_to_transit_model
%    2014-August-04, JL:
%        Initial release
%
%=========================================================================================

transitModel.cadenceTimes           = cadenceTimes;
%transitModel.medianDiffBkjdToKjd    = median( barycentricCadenceTimes.midTimestamps - ( dvDataObject.dvCadenceTimes.midTimestamps - kjd_offset_from_mjd) );

configMapObject                     = configMapClass(configMaps);
mjd                                 = cadenceTimes(1) + kjd_offset_from_mjd();
exposureTimeSec                     = get_exposure_time(configMapObject, mjd);
readoutTimeSec                      = get_readout_time(configMapObject, mjd);
numExposuresPerCadence              = get_number_of_exposures_per_long_cadence_period(configMapObject, mjd);
cadenceDurationDays                 = numExposuresPerCadence * (exposureTimeSec + readoutTimeSec) * get_unit_conversion('sec2day');
transitModel.cadenceDurationDays    = cadenceDurationDays;


% there are several parameters we can simply copy from the inputs

transitModel.log10SurfaceGravity    = targetStruct.log10SurfaceGravity;
transitModel.effectiveTemp          = targetStruct.effectiveTemp;
transitModel.log10Metallicity       = targetStruct.log10Metallicity;
transitModel.radius                 = targetStruct.radius;

% just set debugFlag to false; it is basically never used

transitModel.debugFlag              = false;

% fill in the names of the models which will be used

transitModel.modelNamesStruct.transitModelName        = trapezoidalFit.transitModelName;
transitModel.modelNamesStruct.limbDarkeningModelName  = trapezoidalFit.limbDarkeningModelName;

% fill in the transit buffer cadences, number of samples per cadence, config map information and smallBodyCutOff parameter

transitModel.configMaps               = configMaps;

transitModel.transitSamplesPerCadence = trapezoidalFitConfigurationStruct.transitSamplesPerCadence;
transitModel.transitFitRegion         = trapezoidalFitConfigurationStruct.transitFitRegion;

transitModel.transitBufferCadences    = planetFitConfigurationStruct.transitBufferCadences;
transitModel.smallBodyCutoff          = planetFitConfigurationStruct.smallBodyCutoff;
transitModel.defaultAlbedo            = planetFitConfigurationStruct.defaultAlbedo;
transitModel.defaultEffectiveTemp     = planetFitConfigurationStruct.defaultEffectiveTemp;

% Retrieve epochMjd time and orbitalPeriod from TCE. Adjust transit epoch time if necessary

modelParameters           = trapezoidalFit.modelParameters;
parameterNames            = {modelParameters.name};

index                     = strcmp(parameterNames, 'transitEpochBkjd');
transitEpochBkjd          = modelParameters(index).value;

index                     = strcmp(parameterNames, 'transitDepthPpm');
transitDepthPpm           = modelParameters(index).value;

index                     = strcmp(parameterNames, 'transitDurationHours');
transitDurationHours      = modelParameters(index).value;

index                     = strcmp(parameterNames, 'transitIngressTimeHours');
transitIngressTimeHours   = modelParameters(index).value;

index                     = strcmp(parameterNames, 'orbitalPeriodDays');
orbitalPeriodDays         = modelParameters(index).value;

% Now fill the planet model -- for test purposes, we will hand-construct a physical
% parameter set from the combination of orbital period, transit depth, star radius, and
% the minimum impact parameter, which is forced to zero (central transit).  At this time,
% set eccentricity and longitude of periastron to zero (we don't use these in DV 1, but
% they may come up later).

planetModel.transitEpochBkjd        = transitEpochBkjd;
planetModel.transitDepthPpm         = transitDepthPpm;
planetModel.transitDurationHours    = transitDurationHours;
planetModel.transitIngressTimeHours = transitIngressTimeHours;
planetModel.orbitalPeriodDays       = orbitalPeriodDays;

transitModel.planetModel             = planetModel;

return
