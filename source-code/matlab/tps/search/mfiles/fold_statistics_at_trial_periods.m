%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [maxStatistic, phaseLagInCadences, possiblePeriodsInCadences] =
% fold_statistics_at_trial_periods(tpsResults, tpsModuleParameters)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% find the period that gives the maximum detection statistic by folding the
% single event detection statistic for all possible periods
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

function [maxStatistic, phaseLagForMaxStatisticInCadences, possiblePeriodsInCadences, ...
    minStatistic, phaseLagForMinStatisticInCadences, meanMesEstimate, ...
    validPhaseSpaceFraction, mesHistogram] ...
    = fold_statistics_at_trial_periods(tpsResults, tpsModuleParameters, ...
    possiblePeriodsInCadences, diagnosticsDecimationFactor )

% possiblePeriodsInCadences is optional

if ~exist( 'possiblePeriodsInCadences', 'var' )
    possiblePeriodsInCadences = [] ;
end

if ( ~exist( 'diagnosticsDecimationFactor', 'var' ) || isempty(diagnosticsDecimationFactor) )
    diagnosticsDecimationFactor = 30 ; % may add this to the module parameters
end

% unpack

cadencesPerHour = tpsModuleParameters.cadencesPerHour;
superResolutionFactor = tpsModuleParameters.superResolutionFactor;
rho = tpsModuleParameters.searchPeriodStepControlFactor;
nCadences = length(tpsResults.correlationTimeSeries);
minSesCount = tpsModuleParameters.minSesInMesCount ;
mesHistogramMinMes = tpsModuleParameters.mesHistogramMinMes ;
mesHistogramMaxMes = tpsModuleParameters.mesHistogramMaxMes ;
mesHistogramBinSize = tpsModuleParameters.mesHistogramBinSize ;
trialTransitPulseInHours = tpsResults.trialTransitPulseInHours ;
deemphasisWeightSuperResolution = tpsResults.deemphasisWeightSuperResolution ;
deemphasisWeight = tpsResults.deemphasisWeight ;
correlationTimeSeries = tpsResults.correlationTimeSeriesHiRes;
normalizationTimeSeries = tpsResults.normalizationTimeSeriesHiRes;

% compute the period search space

if isempty(possiblePeriodsInCadences)
    possiblePeriodsInCadences = compute_search_periods( tpsModuleParameters, ...
        trialTransitPulseInHours, nCadences );
end

% compute the phase lag

deltaLagInCadences = compute_phase_lag_in_cadences( trialTransitPulseInHours, ...
    cadencesPerHour, superResolutionFactor, rho ) ;

% apply the deemphasis weights.  Note that there needs to be one factor for both
% data and signal in the correlation and normalization time series.  This
% allows the weight factor to operate correctly when weight -> zero, and also when there
% is only 1 event, with a non-zero, non-unity weight, in the sum.

[correlationTimeSeries, normalizationTimeSeries] = ...
    apply_deemphasis_weights( correlationTimeSeries, ...
    normalizationTimeSeries, deemphasisWeightSuperResolution ) ;

% do the folding

[maxStatistic, minStatistic,  phaseLagForMaxStatisticInCadences, ...
    phaseLagForMinStatisticInCadences, meanMesEstimate, ...
    validPhaseSpaceFraction, mesHistogram] = ...
    fold_periods(possiblePeriodsInCadences, correlationTimeSeries, ...
    normalizationTimeSeries,deltaLagInCadences, minSesCount, mesHistogramMinMes, ...
    mesHistogramMaxMes, mesHistogramBinSize) ;

% get the duty cycle

[~, ~, dutyCycle] = compute_duty_cycle( deemphasisWeight );
diagnosticsDecimationFactor = diagnosticsDecimationFactor * dutyCycle ;

% decimate the period space diagnostics

[meanMesEstimate, validPhaseSpaceFraction] = decimate_period_space_diagnostics( ...
    meanMesEstimate, validPhaseSpaceFraction, possiblePeriodsInCadences, ...
    nCadences, diagnosticsDecimationFactor ) ;

return
