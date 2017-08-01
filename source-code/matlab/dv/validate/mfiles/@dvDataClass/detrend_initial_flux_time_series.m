function [dvResultsStruct] = detrend_initial_flux_time_series(dvDataObject, ...
dvResultsStruct, iTarget, iPlanet)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = detrend_intial_flux_time_series(dvDataObject, ...
% dvResultsStruct, iTarget, iPlanet)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Detrend (by median filtering) flux time series for the given planet
% candidate to support DV time series export to NExScI. Ignore the
% uncertainties due to the median filtering; these cannot be determined
% analytically but should be small in comparison with the uncertainties in
% the initial flux time series.
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

% Get the cadence duration in days.
dvCadenceTimes = dvDataObject.dvCadenceTimes;
cadenceGapIndicators = dvCadenceTimes.gapIndicators;

startTimestamps = dvCadenceTimes.startTimestamps(~cadenceGapIndicators);
endTimestamps = dvCadenceTimes.endTimestamps(~cadenceGapIndicators);
cadenceDurations = endTimestamps - startTimestamps;
cadenceDurationInDays = median(cadenceDurations);
clear startTimestamps endTimestamps cadenceDurations

% Get the initial flux time series and relevant fit results for the given
% planet candidate. Fall back to the trapezoidal model fit results if the
% all transits fit did not succeed.
planetResultsStruct = ...
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
initialFluxTimeSeries = ...
    planetResultsStruct.planetCandidate.initialFluxTimeSeries;
detrendedFluxTimeSeries = ...
    planetResultsStruct.detrendedFluxTimeSeries;
[fitResultsStruct, modelLightCurve] = ...
    get_fit_results_for_diagnostic_test(planetResultsStruct);
if isempty(fitResultsStruct)
    fitResultsStruct = planetResultsStruct.allTransitsFit;
    modelLightCurve = planetResultsStruct.modelLightCurve.values;
    modelLightCurve(planetResultsStruct.modelLightCurve.gapIndicators) = 0;
end % if
modelParameters = fitResultsStruct.modelParameters;
[periodStruct] = ...
    retrieve_model_parameter(modelParameters, 'orbitalPeriodDays');
orbitalPeriodDays = periodStruct.value;
[durationStruct] = ...
    retrieve_model_parameter(modelParameters, 'transitDurationHours');
transitDurationHours = durationStruct.value;

% Perform the detrending. The initial flux time series has been completely
% gap filled.
transitDurationMultiplier = ...
    dvDataObject.planetFitConfigurationStruct.transitDurationMultiplier;
transitDurationCadences = transitDurationHours / ...
    get_unit_conversion('day2hour') / cadenceDurationInDays;
transitPeriodCadences = orbitalPeriodDays / cadenceDurationInDays;

modelLightCurve(initialFluxTimeSeries.filledIndices) = 0;
[filteredTimeSeriesValues, detrendFilterLength] = ...
    remove_medfilt_from_time_series( ...
    initialFluxTimeSeries.values - modelLightCurve, ...
    transitDurationCadences, transitPeriodCadences, ...
    transitDurationMultiplier);
filteredTimeSeriesValues = filteredTimeSeriesValues + modelLightCurve;

% Populate the results structure. Ignore the uncertainties due to the
% median filtering; these cannot be determined analytically but should be
% small in comparison with the uncertainties in the initial flux time
% series. The initial flux time series is fully gap filled so no gap
% indicators should be set in the detrended flux time series. The
% filled indices carry over.
detrendedFluxTimeSeries.values = filteredTimeSeriesValues;
detrendedFluxTimeSeries.uncertainties = initialFluxTimeSeries.uncertainties;
detrendedFluxTimeSeries.gapIndicators = false(size(filteredTimeSeriesValues));
detrendedFluxTimeSeries.filledIndices = initialFluxTimeSeries.filledIndices;

planetResultsStruct.detrendFilterLength = detrendFilterLength;
planetResultsStruct.detrendedFluxTimeSeries = detrendedFluxTimeSeries;
dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
    planetResultsStruct;

% Return.
return
