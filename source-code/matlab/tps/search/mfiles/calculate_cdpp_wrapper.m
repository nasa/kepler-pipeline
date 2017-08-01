%*************************************************************************************************************
% function [cdpp] = calculate_cdpp_wrapper (fluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters)
%
% This function is a wrapper used to calculate the CDPP for a given target time series.
%
% The flux time series must be continuous with no gaps.
%
% If any configuration parameters are empty then the default values will be used. All default values can be used if the function is called as
%   [cdpp] = calculate_cdpp_wrapp (fluxTimeSeries);
% NOTE: This will assume a standard Kepler Long Cadence for cadencesPerHour!!!!!!
%
% The outputs is a struct array of the CDPP values for each input target. We could return as a big array but that would require the number of cadences
% (nCadences) be the same for each target. Thsi wrapper is meant to be a versitile tool to be used on any set of flux time series.
%
%
% The length of the time series must be longer than the transit duration. (Smoke test does not honor this condition). If shorter, then this function returns
% zeros.
%
% Inputs:
%   fluxTimeSeries  -- [struct array(nTargets)]
%       .values     -- [double array(nCadences)] The flux time series for each target
%   cadencesPerHour
%   trialTransitPulseDurationInHours    -- [int] 3, 6, 12  are common
%   tpsModuleParameters                 - [struct]
%       .usePolyFitTransitModel; % true = astrophysical, false = square waves 
%       .superResolutionFactor; % set to 1
%       .varianceWindowLengthMultiplier; % default is 7 cadences
%       .waveletFilterLength; % 12 taps is default
%
% Outputs:
%   cdpp    -- [struct array(nTargets)]
%       .values -- [double array(nCadences)] The CDPP cadence values for each target (nCadence can be different for each targets)
%       .rms    -- [double] The CDPP rms value
%
%*************************************************************************************************************
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

function [cdpp] = calculate_cdpp_wrapper(fluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters)

nTargets = length(fluxTimeSeries);

if (isempty(cadencesPerHour));
    cadencesPerHour = 2.0391; % standard long cadence length
end

if (isempty(trialTransitPulseDurationInHours ))
    trialTransitPulseDurationInHours = 6;   % 3, 6, 12  are common
end

if (isempty(tpsModuleParameters))
    usePolyFitTransitModel          = [];
    superResolutionFactor           = [];
    varianceWindowLengthMultiplier  = [];
    waveletFilterLength             = [];
else
    usePolyFitTransitModel          = tpsModuleParameters.usePolyFitTransitModel; % true = astrophysical, false = square waves
    superResolutionFactor           = tpsModuleParameters.superResolutionFactor; % set to 1
    varianceWindowLengthMultiplier  = tpsModuleParameters.varianceWindowLengthMultiplier; % default is 7 cadences
    waveletFilterLength             = tpsModuleParameters.waveletFilterLength; % 12 taps is default
end


% Set default values
if (isempty(usePolyFitTransitModel))
    usePolyFitTransitModel = false;
end

if (isempty(superResolutionFactor))
    superResolutionFactor = 1;
end

if (isempty(varianceWindowLengthMultiplier))
    varianceWindowLengthMultiplier = 7;
end

if (isempty(waveletFilterLength))
    waveletFilterLength = 12;
end

scalingFilterCoeffts = daubechies_low_pass_scaling_filter(waveletFilterLength);
trialTransitPulseWidth = floor(cadencesPerHour*trialTransitPulseDurationInHours); % cadencesPerHour is not an integer

varianceEstimationWindowLength = trialTransitPulseWidth * varianceWindowLengthMultiplier;

superResolutionStruct = struct('superResolutionFactor', superResolutionFactor, ...
    'pulseDurationInCadences', trialTransitPulseWidth, 'usePolyFitTransitModel', usePolyFitTransitModel) ;
superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;

waveletObject = waveletClass( scalingFilterCoeffts ) ;

%***

cdpp = repmat(struct('values', [], 'rms', []), [nTargets,1]);

for iTarget = 1 : nTargets

    fluxValues = fluxTimeSeries(iTarget).values;
    nCadences = length(fluxValues);

    % Catch if all values are zero.
    if (all(fluxValues == 0))
        % Would really like to use NaN here but the exporter hates NaNs
        cdpp(iTarget).values    = zeros(nCadences,1);
        cdpp(iTarget).rms       = 0.0;
        continue;
    end

    % If trialTransitPulseWidth is longer than nCadences then we cannot calculate CDPP!
    if (trialTransitPulseWidth > nCadences)
        % Would really like to use NaN here but the exporter hates NaNs
        cdpp(iTarget).values    = zeros(nCadences,1);
        cdpp(iTarget).rms       = 0.0;
        continue;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% get outlier info - Unnecessary step
   %outlierIndicators = tpsTargets(jStar).outlierIndicators ;
   %outlierFillValues = tpsTargets(jStar).outlierFillValues ;
   %useOutlierFreeFlux = true ;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    waveletObject = set_outlier_vectors( waveletObject, false(size(fluxValues)), [], -1 ) ;
    
    % Suppress warning for extended flux. Don't need it to tell me I'm asking it to extend the flux!
    warningState = warning('query', 'all');
    warning off all;
    waveletObject = set_extended_flux(waveletObject, fluxValues) ;
    warning(warningState);

    useOutlierFreeFlux = false;
    waveletObject = set_whitening_coefficients( waveletObject, varianceEstimationWindowLength, useOutlierFreeFlux ) ;
    superResolutionObject = set_wavelet_object( superResolutionObject, waveletObject ) ;

    [~, ~, normalizationTimeSeries] =  ...
        set_hires_statistics_time_series( superResolutionObject, nCadences ) ;

    cdpp(iTarget).values = 1e6./normalizationTimeSeries;

    % All values must be real, not infinite and not NaN
    gaps = false(nCadences,1);
    % isreal returns a single value, not an array for each arracy value, so we need to do a for-loop!
    for iCadence = 1 : nCadences
        if (~isreal(cdpp(iTarget).values(iCadence)))
            gaps(iCadence) = true;
        end
    end
    gaps(isinf(cdpp(iTarget).values))   = true;
    gaps(isnan(cdpp(iTarget).values))   = true;

    cdpp(iTarget).rms = compute_rms_value( cdpp(iTarget).values, gaps, true);

end

return;
