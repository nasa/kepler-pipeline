%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% function [correctededFluxTimeSeries, harmonicTimeSeries, alerts] = ...
% pdc_correct_flux_fraction_and_crowding_metric(cotrendedFluxTimeSeries, harmonicTimeSeries,...
% crowdingMetricArray, fluxFractionArray, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Descriptions
%  The normalization formula provided by J. Twicken is described as below:
%  crowdingCorrectedFlux = cotrendedFlux - (1 - crowdingMetric)* median(cotrendedFlux).
%  Gap indicators are used to compute the mean value by excluding the
%  positions where there are no flux values.
%
%  The harmonics are added back in for the corwding metrix correction but
%  then subtracted back out before the flux fraction correction
%
%  Accouting for the Flux Fraction is obtained simply by dividing the
%  corrected flux, the uncertaintiues and the harmonic series by the flux
%  fraction.  It is possible that the flux fraction for a target is zero if
%  the optimal aperture
%
%  The above normalization only affects the flux values, uncertainties and
%  harmonic values. The gapIndicators remain unchanged as output. The
%  normalization essentially performs two tasks:
%  1) Removes excess flux in the optimal aperture due to crowding by other 
%     light sources.
%  2) Corrects the the flux taking into account the fraction of the flux
%     within the aperture.
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%     cotrendedFluxTimeSeries is an array of structs (one per target) with the 
%     following fields:
%
%                    values: [float array]  flux values to be corrected
%             uncertainties: [float array]  uncertainties in flux values
%           gapIndicators: [logical array]  flux gap indicators
%
%--------------------------------------------------------------------------
%     harmonicTimeSeries is an array of structs (one per target) with the
%     following fields:
%
%                    values: [float array]  flux values to be corrected
%             uncertainties: [float array]  uncertainties in flux values
%           gapIndicators: [logical array]  flux gap indicators
%
%--------------------------------------------------------------------------
%     crowdingMetricArray is a float vector as follows:
%
%           crowdingMetricArray: [float array]  fraction of flux in aperture
%           due to other stars (crowding)
%
%--------------------------------------------------------------------------
%     fluxFractionArray is a float vector as follows
%
%           fluxFractionArray: [float array] fraction of total flux in
%           aperture
%
%--------------------------------------------------------------------------
%     alerts is an array of structs with the following fields:
%
%                           time: [double]  alert time, MJD
%                        severity [string]  alert severity ('error' or 'warning')
%                        message: [string]  alert message
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%     correctedFluxTimeSeries is an array of structs (one per target) with
%     the following fields:
%
%                    values: [float array]  flux values to be corrected
%             uncertainties: [float array]  uncertainties in flux values
%           gapIndicators: [logical array]  flux gap indicators
%
%--------------------------------------------------------------------------
%     harmonicTimeSeries is an array of structs (one per target) with the
%     following fields:
%
%                    values: [float array]  flux values to be corrected
%             uncertainties: [float array]  uncertainties in flux values
%           gapIndicators: [logical array]  flux gap indicators
%
%%--------------------------------------------------------------------------

function [correctedFluxTimeSeries, harmonicTimeSeries, alerts] = ...
pdc_correct_flux_fraction_and_crowding_metric(cotrendedFluxTimeSeries, harmonicTimeSeries,...
crowdingMetricArray, fluxFractionArray, alerts)

nCrowdingFactors = length(crowdingMetricArray);
nFluxFactors = length(fluxFractionArray);
nTargets = length(cotrendedFluxTimeSeries);

if ~(nCrowdingFactors == nTargets && nTargets > 0)
    error('PDC:pdc_correct_flux_fraction_and_crowding_metric:invalidCrowdingMetricArray', ...
    'The numbers of crowding metrics and targets are unequal');
end

if ~(nFluxFactors == nTargets && nTargets > 0)
    error('PDC:pdc_correct_flux_fraction_and_crowding_metric:invalidFluxFractionArray', ...
    'The numbers of flux fractions metrics and targets are unequal');
end

% create the output structure.
correctedFluxTimeSeries = cotrendedFluxTimeSeries;

% get the target flux values, uncertainties, harmomics and gap indicators.
targetValues                   = [cotrendedFluxTimeSeries.values];
targetUncertainties            = [cotrendedFluxTimeSeries.uncertainties];
harmonicValues                 = [harmonicTimeSeries.values];
gapIndicators                  = [cotrendedFluxTimeSeries.gapIndicators];
nCadences = size(targetValues, 1);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Crowding Metric Correction

% Add the harmonics (which have no gaps).
targetValues = targetValues + harmonicValues;

% remove the excess flux due to crowding.
targetValues(gapIndicators) = NaN;
medianValues = nanmedian(targetValues);
excessValues = (1 - crowdingMetricArray( : )') .* medianValues;
targetValues = targetValues - repmat(excessValues, [nCadences, 1]);

% remove the harmonics.
targetValues = targetValues - harmonicValues;
targetValues(gapIndicators) = 0;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Flux Fraction Correction

% Simply divide by the FluxFractionArray but do not divide by zero
validFluxFraction = find(fluxFractionArray);
if any(~fluxFractionArray)
    % If a flux fraction is zero then the gapIndicators should be true.
    % If this is not the case then issue a warning
    if any(any(~gapIndicators(:,~fluxFractionArray)))
        nFluxFractionIsZero = sum(any(~gapIndicators(:,~fluxFractionArray)));
            [alerts] = add_alert(alerts, 'Warning', ...
            [num2str(nFluxFractionIsZero), ...
            ' flux fraction values are zero but the flux is not gapped.']);
        disp(alerts(end).message);
    end
end 
fluxFractionValues                    = ones(nFluxFactors,1)';
fluxFractionValues(validFluxFraction) = fluxFractionArray(validFluxFraction);
fluxFractionValues                    = repmat(fluxFractionValues, [nCadences, 1]);

targetValues        = targetValues        ./ fluxFractionValues;
targetUncertainties = targetUncertainties ./ fluxFractionValues;
harmonicValues      = harmonicValues      ./ fluxFractionValues;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% turn 2D arrays back into original struct format.
for iTarget = 1 : nTargets
    correctedFluxTimeSeries(iTarget).values        = targetValues( : , iTarget);
    correctedFluxTimeSeries(iTarget).uncertainties = targetUncertainties( : , iTarget);
    harmonicTimeSeries(iTarget).values              = harmonicValues( : , iTarget);
end

% return.
return
