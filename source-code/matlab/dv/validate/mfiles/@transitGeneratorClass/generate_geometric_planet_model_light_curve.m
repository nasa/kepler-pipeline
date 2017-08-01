function [transitModelLightCurve, timestamps] = ...
    generate_geometric_planet_model_light_curve(transitModelObject, oddEvenFlag)
%
% function [transitModelLightCurve, cadenceTimes]  =
%    generate_planet_model_light_curve(transitModelObject, oddEvenFlag)
%
% function to generate geometric transit model light curve.
%
%
% INPUTS:
%
% The transitModelObject with fields ordered as follows:
%
%   (1) cadenceTimes
%   (2) log10SurfaceGravity
%   (3) limbDarkeningCoefficients
%   (4) debugFlag
%   (5) planetModel    [struct] with the following fields:
%           transitEpochBkjd
%           eccentricity
%           longitudeOfPeriDegrees
%           planetRadiusEarthRadii
%           semimajorAxisAu
%           minImpactParameter
%           starRadiusSolarRadii
%           transitDurationHours
%           transitIngressTimeHours
%           transitDepthPpm
%           orbitalPeriodDays
%           ratioPlanetRadiusToStarRadius
%           ratioSemiMajorAxisToStarRadius
%   (6) modelNamesStruct
%   (7) timeParametersStruct
%   (8) transitModelLightCurve [array] allocated to zeros (one value per timestamp)
%
%   oddEvenFlag [scalar] a flag with value 0, 1, or 2 [optional, default is 0].
%
%
% OUTPUTS:
%
%  transitModelLightCurve         [array] transit flux light curve relative
%                                 to unobscured (=0) flux light curve
%
%  cadenceTimes (optional)        [array]
%
%   In the case where oddEvenFlag == 1, only the odd-numbered transits will
%   have nonzero values; in the case where oddEvenFlag == 2, only the
%   even-numbered transits will have nonzero values.
%--------------------------------------------------------------------------
%
% Version date:  2012-May-14.
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

% Modification history:
%
% 2012-May-14, JL:
%     Averaging algorithm is implemented for all data points
% 2010-November-18, EQ:
%     Initial release.  This function  can be called via
%     generate_planet_model_light_curve which is a wrapper for all model
%     light curve functions


% extract parameters from object
debugFlag    = transitModelObject.debugFlag;
timestamps   = transitModelObject.cadenceTimes;
planetModel  = transitModelObject.planetModel;
smallBodyCutoff = transitModelObject.smallBodyCutoff;

transitModelLightCurve = transitModelObject.transitModelLightCurve;
timeParametersStruct   = transitModelObject.timeParametersStruct;

ratioPlanetRadiusToStarRadius  = planetModel.ratioPlanetRadiusToStarRadius;


%--------------------------------------------------------------------------
% construct a new time array (from input timestamps and sample rate) from
% which to compute the transit model light curve
%--------------------------------------------------------------------------
[timestampArray, timestampsInTransitIdx] = ...
    construct_geometric_transit_time_array(transitModelObject);

timestampsInTransit = timestampArray(timestampsInTransitIdx);


%--------------------------------------------------------------------------
% compute impact parameter as a function of time (z)
%--------------------------------------------------------------------------
impactParameterArray = compute_geometric_orbit(transitModelObject, timestampsInTransit);


%--------------------------------------------------------------------------
% generate the light curve
%--------------------------------------------------------------------------
if ratioPlanetRadiusToStarRadius > smallBodyCutoff
    
    inTransitModelLightCurve = compute_geometric_large_body_transit_light_curve(...
        transitModelObject, impactParameterArray, timestampsInTransit);
else
    inTransitModelLightCurve = compute_geometric_small_body_transit_light_curve(...
        transitModelObject, impactParameterArray, timestampsInTransit);
end


%--------------------------------------------------------------------------
% sum the n samples for each "cadence"
%--------------------------------------------------------------------------
transitSamplesPerCadence = timeParametersStruct.transitSamplesPerCadence;
halfNumSample = floor(transitSamplesPerCadence/2);

fullLightCurveArray = zeros(length(timestampArray), 1);
fullLightCurveArray(timestampsInTransitIdx) = inTransitModelLightCurve;

timestampsIdxToFullArray = find(ismember(timestampArray, timestamps));


for iTimestamp = 1:length(timestamps)
    
    % find points associated with this input timestep
    idx = timestampsIdxToFullArray(iTimestamp);
    
%     if fullLightCurveArray(idx)~=0
%         
%         transitModelLightCurve(iTimestamp) = mean(fullLightCurveArray(idx - halfNumSample:...
%             idx + halfNumSample));
%     end

    transitModelLightCurve(iTimestamp) = mean( fullLightCurveArray( (idx-halfNumSample):(idx+halfNumSample) ) );

end


% plot the folded light curve
if (debugFlag > 1 && length(transitModelLightCurve) > 3)
        
    figure;
    
    lightCurveNormalizedToOne = transitModelLightCurve + 1;
    
    transitDepth = 1 - min(lightCurveNormalizedToOne);
    transitDepthPpm = transitDepth*1e6;
    
    plot(mod(timestamps, planetModel.orbitalPeriodDays), lightCurveNormalizedToOne, 'b.-')
    
    xlabel('Folded period (days)')
    ylabel('Flux relative to unobscured star')
    title(['Folded light curve, LD depth = ' num2str(transitDepthPpm) ' ppm']);
    grid on
end


%--------------------------------------------------------------------------
% manage oddEvenFlag values now
%--------------------------------------------------------------------------
transitNumber = identify_transit_cadences( transitModelObject, ...
    transitModelObject.cadenceTimes, 0 ) ;

oddTransitCadences = find( mod(transitNumber,2) == 1 ) ;
evenTransitCadences = find( mod(transitNumber,2) == 0 & transitNumber ~= 0 )  ;

switch oddEvenFlag
    
    case 0
    case 1
        transitModelLightCurve(evenTransitCadences) = 0 ; %#ok<FNDSB>
    case 2
        transitModelLightCurve(oddTransitCadences) = 0 ;  %#ok<FNDSB>
    otherwise
        error('dv:generatePlanetModelLightCurve:oddEvenFlagInvalid', ...
            'generate_geometric_planet_model_light_curve: oddEvenFlag value is invalid') ;
end


return;

