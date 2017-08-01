function [transitModelObject, intermediateStruct] = compute_binary_model_light_curve(transitModelObject, intermediateStruct)
%
% function to compute the flux light curve from the transiting planet.
%
%
%
%
%
%
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

debugFlag                = intermediateStruct.debugFlag;

numCadences              = intermediateStruct.numCadences;
lightCurve               = zeros(numCadences, 1);

primaryTransitExpStart   = find(intermediateStruct.exposureStartTransitSign == 1);
secondaryTransitExpStart = find(intermediateStruct.exposureStartTransitSign == -1);

primaryTransitExpEnd     = find(intermediateStruct.exposureEndTransitSign == 1);
secondaryTransitExpEnd   = find(intermediateStruct.exposureEndTransitSign == -1);


%--------------------------------------------------------------------------
% generate the light curve
%--------------------------------------------------------------------------

primaryRadiusMeters    = intermediateStruct.primaryRadiusMeters;
secondaryRadiusMeters  = intermediateStruct.secondaryRadiusMeters;

eclipsingObjectNormalizedRadius = secondaryRadiusMeters/primaryRadiusMeters;


exposureStartImpactParam = intermediateStruct.exposureStartImpactParam;
exposureEndImpactParam  = intermediateStruct.exposureEndImpactParam;

% impactParameterStart = exposureStartImpactParam(primaryTransitExpStart);
% impactParameterEnd   = exposureStartImpactParam(primaryTransitExpEnd);


impactParameterStart = exposureStartImpactParam(primaryTransitExpStart); %#ok<FNDSB>
impactParameterEnd   = exposureEndImpactParam(primaryTransitExpEnd); %#ok<FNDSB>

if eclipsingObjectNormalizedRadius > 0.01

    exposureStartLightCurve = compute_large_body_transit_light_curve(transitModelObject, intermediateStruct, impactParameterStart);
    exposureEndLightCurve   = compute_large_body_transit_light_curve(transitModelObject, intermediateStruct, impactParameterEnd);
else
    exposureStartLightCurve = compute_small_body_transit_light_curve(transitModelObject, intermediateStruct, impactParameterStart);
    exposureEndLightCurve   = compute_small_body_transit_light_curve(transitModelObject, intermediateStruct, impactParameterEnd);

end


% this is the primary eclipse with the secondary in front.  Normalize the
% light curves according to the component luminosities
L1  = intermediateStruct.primaryLuminosity;
L2  = intermediateStruct.secondaryLuminosity;

exposureStartLightCurve = (L2 + exposureStartLightCurve*L1)/(L2 + L1);
exposureEndLightCurve   = (L2 + exposureEndLightCurve*L1)/(L2 + L1);

%--------------------------------------------------------------------------
% for eclipsing binaries
%--------------------------------------------------------------------------
if ~isempty(secondaryTransitExpStart)

    % if there is a secondary transit, switch the role of primary and secondary
    tempPrimaryRadiusMks    = intermediateStruct.secondaryRadiusMeters;
    tempSecondaryRadiusMks  = intermediateStruct.primaryRadiusMeters;

    eclipsingObjectNormalizedRadius = tempSecondaryRadiusMks/tempPrimaryRadiusMks;

    impactParameterStart = exposureStartImpactParam(secondaryTransitExpStart);
    impactParameterEnd   = exposureEndImpactParam(secondaryTransitExpEnd); %#ok<FNDSB>


    if eclipsingObjectNormalizedRadius > 0.01

        secondaryExpStartLightCurve = compute_flux_from_giant_planet_occult(transitModelObject, intermediateStruct, impactParameterStart);
        secondaryExpEndLightCurve   = compute_flux_from_giant_planet_occult(transitModelObject, intermediateStruct, impactParameterEnd);
    else
        secondaryExpStartLightCurve = compute_flux_from_small_planet_occult(transitModelObject, intermediateStruct, impactParameterStart);
        secondaryExpEndLightCurve   = compute_flux_from_small_planet_occult(transitModelObject, intermediateStruct, impactParameterEnd);
    end


    % this is the secondary eclipse with the primary in front.  Normalize the
    % light curves according to the component luminosities
    secondaryExpStartLightCurve = (L1 + secondaryExpStartLightCurve*L2)/(L1+L2);
    secondaryExpEndLightCurve   = (L1 + secondaryExpEndLightCurve*L2)/(L1+L2);

    exposureStartLightCurve     = [exposureStartLightCurve; secondaryExpStartLightCurve];
    exposureEndLightCurve       = [exposureEndLightCurve; secondaryExpEndLightCurve];
end


%--------------------------------------------------------------------------
% associate a single value with each exposure
%--------------------------------------------------------------------------

% use the trapezoidal rule to integrate a value for each exposure
integrationTimeSec     = intermediateStruct.integrationTimeSec;

% compute the actual integral via trapezoidal rule here
% exposureLightCurve = (integrationTimeSec/2)*(exposureStartLightCurve + exposureEndLightCurve);
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
exposuresPerCadence         = intermediateStruct.exposuresPerCadence;

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

    exposureLightCurveTmp = sum(exposureLightCurve(exposuresInCadenceIdx));

    lightCurve(i) = exposureLightCurveTmp/exposuresPerCadence;
end

if debugFlag > 0

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
    % plot the light curve at each cadence
    %---------------------------------------------------------------------
    figure;
    plot(cadenceMidTimesDays - cadenceMidTimesDays(1), lightCurve+1, 'm.')
    title('Light curve at each input cadence')

    xlabel(['Barycentric-corrected MJDs - ' num2str(cadenceMidTimesDays(1))])
    ylabel('Flux relative to unobscured star')
    grid on

    cadenceTimesMjd    = transitModelObject.cadenceTimes;
    sec2day            = get_unit_conversion('sec2day');
    midTransitTimesSec = intermediateStruct.midTransitTimesSec;
    midTransitTimesDay = sec2day * midTransitTimesSec;

    transitDurationDays = intermediateStruct.transitDurationDays;
    transitTimeBufferDays = intermediateStruct.transitTimeBufferDays;

    %---------------------------------------------------------------------
    % plot the folded light curve
    %---------------------------------------------------------------------
    figure;
    for i = 1:length(midTransitTimesDay)

        halfDuration = transitDurationDays + transitTimeBufferDays;


        lightCurveIdx = lightCurve((cadenceTimesMjd > (midTransitTimesDay(i) - halfDuration)) & ...
            (cadenceTimesMjd < (midTransitTimesDay(i) + halfDuration)));

        cadenceTimesIdx = cadenceTimesMjd((cadenceTimesMjd > (midTransitTimesDay(i) - halfDuration)) & ...
            (cadenceTimesMjd < (midTransitTimesDay(i) + halfDuration)));

        hold on
        plot(cadenceTimesIdx - midTransitTimesDay(i), lightCurveIdx+1, 'r.')

        xlabel('Offset from mid-transit time')
        ylabel('Flux relative to unobscured star')

        title('Folded light curve')
        grid on
    end
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
lightCurveData.primaryLuminosity                = intermediateStruct.primaryLuminosity;
lightCurveData.secondaryLuminosity              = intermediateStruct.secondaryLuminosity;


transitModelObject.transitModelLightCurve       = lightCurve;
intermediateStruct.lightCurveData               = lightCurveData;


return;
