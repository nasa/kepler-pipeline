function [whiteningFilterModel] = ...
generate_whitening_filter_model(fluxTimeSeriesValues, fluxTimeSeriesGapIndicators, ...
trialTransitPulseDuration, gapFillConfigurationStruct, tpsConfigurationStruct, ...
cadenceQuarterLabels)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [whiteningFilterModel] = ...
% generate_whitening_filter_model(fluxTimeSeriesValues, fluxTimeSeriesGapIndicators, ...
% trialTransitPulseDuration, gapFillConfigurationStruct, tpsConfigurationStruct) 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create a whitening filter model for the given flux time series. An
% whiteningFilterObject can be instantiated from the model, and whitening
% can be performed on the time series with or without an additional model
% time series.
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

% Make sure the quarter labels are specified if we are whitening by quarter
if tpsConfigurationStruct.noiseEstimationByQuarterEnabled && ...
        (~exist('cadenceQuarterLabels','var') || isempty(cadenceQuarterLabels))
    error('DV:generateWhiteningFilterModel:quarterLabelsUnspecified', ...
      'cadenceQuarterLabels must be specified if noiseEstimationByQuarterEnabled');
end

% initialize the optional input if necessary
if ~exist('cadenceQuarterLabels','var')
    cadenceQuarterLabels = [];
end

% Get fields from the input structures.
cadenceDurationInMinutes = ...
    gapFillConfigurationStruct.cadenceDurationInMinutes;
varianceWindowLengthMultiplier = ...
    tpsConfigurationStruct.varianceWindowLengthMultiplier;
waveletFamily = tpsConfigurationStruct.waveletFamily;
waveletFilterLength = tpsConfigurationStruct.waveletFilterLength;
noiseEstimationByQuarterEnabled = ...
    tpsConfigurationStruct.noiseEstimationByQuarterEnabled;

% Determine the variance window length.
minutesPerHour = ...
    get_unit_conversion('hour2sec') * get_unit_conversion('sec2min');
trialTransitPulseWidth = max(round(trialTransitPulseDuration * ...
    minutesPerHour / cadenceDurationInMinutes),1);
varianceWindowLength = ...
    trialTransitPulseWidth * varianceWindowLengthMultiplier;

% Create a transit pulse.
transitPulse = -ones([trialTransitPulseWidth, 1]);

% Determine the scaling filter coefficients.
if strcmpi(waveletFamily, 'daub')
  [scalingFilterCoeffts] = ...
      daubechies_low_pass_scaling_filter(waveletFilterLength);
else
  error('DV:generateWhiteningFilterModel:unsupportedWaveletFamily', ...
      [waveletFamily, ' is not a supported wavelet family']);
end

% Save the original flux time series values and gap indicators. All gaps
% will be filled, so set the filled indices accordingly.
whiteningFilterModel.fluxTimeSeriesValues = fluxTimeSeriesValues;
whiteningFilterModel.fluxTimeSeriesGapIndicators = ...
    fluxTimeSeriesGapIndicators;
whiteningFilterModel.filledIndices = ...
    find(fluxTimeSeriesGapIndicators);

% Fill any short data gaps in the flux time series.
debugFlag = false;
indexOfAstroEvents = 0;

[fluxTimeSeriesValues, masterIndex, fluxTimeSeriesGapIndicators, ...
    ~, fittedTrend] = ...
    fill_short_gaps(fluxTimeSeriesValues, fluxTimeSeriesGapIndicators, ...
    indexOfAstroEvents, debugFlag, gapFillConfigurationStruct);

% fill outliers to suppress them from entering long fill

outlierIndicators = false(size(fluxTimeSeriesValues));
outlierIndicators(masterIndex) = true;

fluxTimeSeriesOutliersFilled = fill_short_gaps(fluxTimeSeriesValues, ...
    outlierIndicators, [], debugFlag, gapFillConfigurationStruct, [], ...
    fittedTrend);

outlierFillValues = fluxTimeSeriesOutliersFilled(outlierIndicators);

% fill long gaps

fluxTimeSeriesValues = fill_missing_quarters_via_reflection( ...
    fluxTimeSeriesValues, fluxTimeSeriesGapIndicators, [], gapFillConfigurationStruct);

% Extend the length of the flux time series to the next power of two,
% regardless of whether the length is already a power of two (see
% TPS/compute_cdpp_time_series). Fill new and existing gaps.
%nCadences = length(fluxTimeSeriesValues);
%n1 = floor(log2(nCadences));
%n2 = n1 + 1;

%extendedFluxTimeSeriesValues = ...
%    [fluxTimeSeriesOutliersFilled; zeros([2^n2 - nCadences, 1])];
%extendedFluxTimeSeriesGapIndicators = ...
%    [fluxTimeSeriesGapIndicators; true([2^n2 - nCadences, 1])];
%outlierIndicatorsExtended = [outlierIndicators; false([2^n2 - nCadences, 1])];

%extendedFluxTimeSeriesValues = fill_missing_quarters_via_reflection( ...
%      extendedFluxTimeSeriesValues, extendedFluxTimeSeriesGapIndicators, ...
%      [], gapFillConfigurationStruct) ;
  
% put back the outliers

%extendedFluxTimeSeriesValues(outlierIndicatorsExtended) = ...
%    fluxTimeSeriesValues(outlierIndicators);

% Complete the model structure.
%whiteningFilterModel.extendedFluxTimeSeriesValues = ...
%    extendedFluxTimeSeriesValues;
whiteningFilterModel.fluxTimeSeriesValues = fluxTimeSeriesValues;
whiteningFilterModel.scalingFilterCoeffts = scalingFilterCoeffts;
whiteningFilterModel.transitPulse = transitPulse;
whiteningFilterModel.varianceWindowLength = varianceWindowLength;
whiteningFilterModel.gapFillConfigurationStruct = ...
    gapFillConfigurationStruct;
whiteningFilterModel.outlierIndicators = outlierIndicators;
whiteningFilterModel.outlierFillValues = outlierFillValues;
whiteningFilterModel.cadenceQuarterLabels = cadenceQuarterLabels;
whiteningFilterModel.noiseEstimationByQuarterEnabled = noiseEstimationByQuarterEnabled;

% Return
return
