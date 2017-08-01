function [transitModelObject, intermediateStruct] = ...
    compute_planet_model_light_curve(transitModelObject, intermediateStruct)
% function [transitModelObject, intermediateStruct] = ...
%   compute_planet_model_light_curve(transitModelObject, intermediateStruct)
%
% function to compute the flux light curve from the transiting planet.
%
% INPUTS:
%   transitModelObject
%   intermediateStruct
%
% OUTPUTS:
%   transitModelObject
%   intermediateStruct
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

debugFlag                = transitModelObject.debugFlag;

lightCurve               = transitModelObject.transitModelLightCurve;

primaryTransitExpStart   = find(intermediateStruct.exposureStartTransitSign == 1);
primaryTransitExpEnd     = find(intermediateStruct.exposureEndTransitSign == 1);

%--------------------------------------------------------------------------
% generate the light curve
%--------------------------------------------------------------------------

primaryRadiusMeters    = intermediateStruct.primaryRadiusMeters;
secondaryRadiusMeters  = intermediateStruct.secondaryRadiusMeters;

eclipsingObjectNormalizedRadius = secondaryRadiusMeters/primaryRadiusMeters;


exposureStartImpactParam = intermediateStruct.exposureStartImpactParam;
exposureEndImpactParam  = intermediateStruct.exposureEndImpactParam;

impactParameterStart = exposureStartImpactParam(primaryTransitExpStart);    %#ok<FNDSB>
impactParameterEnd   = exposureEndImpactParam(primaryTransitExpEnd);        %#ok<FNDSB>


if eclipsingObjectNormalizedRadius > 0.01

    [exposureStartLightCurve, nonLimbDarkenedTransitDepthPpm] = ...
        compute_large_body_transit_light_curve(transitModelObject, intermediateStruct, impactParameterStart);
    exposureEndLightCurve = compute_large_body_transit_light_curve(transitModelObject, ...
        intermediateStruct, impactParameterEnd);
else
    exposureStartLightCurve = compute_small_body_transit_light_curve(transitModelObject, ...
        intermediateStruct, impactParameterStart);
    exposureEndLightCurve   = compute_small_body_transit_light_curve(transitModelObject, ...
        intermediateStruct, impactParameterEnd);
end



%--------------------------------------------------------------------------
% associate a single value with each exposure
%--------------------------------------------------------------------------
exposureLightCurve = (exposureStartLightCurve + exposureEndLightCurve)/2;


sec2day = get_unit_conversion('sec2day');
transitExposureStartTimesSec = intermediateStruct.transitExposureStartTimes;
transitExposureEndTimesSec   = intermediateStruct.transitExposureEndTimes;

transitExposureStartTimesDays = sec2day*transitExposureStartTimesSec;
transitExposureEndTimesDays   = sec2day*transitExposureEndTimesSec;

transitExposureTimesDays = 1/2*(transitExposureStartTimesDays+transitExposureEndTimesDays);


%--------------------------------------------------------------------------
% sum the individual exposures into a cadence
%--------------------------------------------------------------------------
cadenceDurationSec          = intermediateStruct.cadenceDurationSec;
exposureTotalTimeSec        = intermediateStruct.exposureTotalTimeSec;
exposuresPerCadence         = intermediateStruct.numExposuresPerCadence;

transitExposureStartTimes   = intermediateStruct.transitExposureStartTimes;
transitExposureEndTimes     = intermediateStruct.transitExposureEndTimes;

cadenceMidTimesSec      = intermediateStruct.cadenceTimesSec;
cadenceMidTimesDays     = sec2day*cadenceMidTimesSec;

cadenceStartTimes = cadenceMidTimesSec - cadenceDurationSec/2;
cadenceEndTimes   = cadenceMidTimesSec + cadenceDurationSec/2;

if debugFlag > 0

    %---------------------------------------------------------------------
    % plot the light curve at each exposure
    %---------------------------------------------------------------------
    figure;
    h1 = plot(transitExposureTimesDays - cadenceMidTimesDays(1), exposureLightCurve+1, 'c.');
    title('Transit light curve')
end



% find the exposures that correspond to each cadence and sum up
for i = 1:length(cadenceMidTimesSec)

    exposuresInCadenceIdx = find(transitExposureStartTimes >= cadenceStartTimes(i) & ...
        transitExposureEndTimes <= cadenceEndTimes(i) + exposureTotalTimeSec);

    exposureLightCurveTmp = sum(exposureLightCurve(exposuresInCadenceIdx)); %#ok<FNDSB>

    lightCurve(i) = exposureLightCurveTmp/exposuresPerCadence;
end

computedDepthPpm = max(abs(lightCurve))*1e6;



if debugFlag > 0
    orbitalPeriodSec   = intermediateStruct.orbitalPeriodSec;
    orbitalPeriodDays  = orbitalPeriodSec*get_unit_conversion('sec2day');

    cadenceTimesMjd    = transitModelObject.cadenceTimes;

    %---------------------------------------------------------------------
    % overplot the light curve at each cadence
    %---------------------------------------------------------------------
    hold on
    h2 = plot(cadenceMidTimesDays - cadenceMidTimesDays(1), lightCurve+1, 'm.');

    xlabel(['Barycentric-corrected MJDs - ' num2str(cadenceMidTimesDays(1))])
    ylabel('Flux relative to unobscured star')
    grid on
    legend([h1 h2], {'mid-exposure values', 'cadence values'}, 'Location', 'Best');

    %---------------------------------------------------------------------
    % plot the folded light curve
    %---------------------------------------------------------------------
    figure;

    plot(mod(cadenceTimesMjd, orbitalPeriodDays), lightCurve+1, 'b.-')
    xlabel('Folded period (days)')
    ylabel('Flux relative to unobscured star')
    if eclipsingObjectNormalizedRadius > 0.01

        title(['Folded light curve, LD depth = ' num2str(computedDepthPpm, '%6.1f') ' ppm, non-LD depth = ' num2str(nonLimbDarkenedTransitDepthPpm) ' ppm']);
    else
        title(['Folded light curve, LD depth = ' num2str(computedDepthPpm, '%6.1f') ' ppm']);
    end
    grid on

end


%--------------------------------------------------------------------------
% save light curve data
%--------------------------------------------------------------------------
lightCurveData.orbitalPeriodSec                 = intermediateStruct.orbitalPeriodSec;
lightCurveData.midTransitTimesSec               = intermediateStruct.midTransitTimesSec;
lightCurveData.minImpactParameter               = intermediateStruct.minImpactParameter;
lightCurveData.secondaryRadiusMeters            = intermediateStruct.secondaryRadiusMeters;
lightCurveData.primaryRadiusMeters              = intermediateStruct.primaryRadiusMeters;
lightCurveData.eccentricity                     = intermediateStruct.eccentricity;

transitModelObject.transitModelLightCurve       = lightCurve;
intermediateStruct.lightCurveData               = lightCurveData;


return;
