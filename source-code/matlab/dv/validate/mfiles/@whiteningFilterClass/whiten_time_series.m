function [whitenedFluxTimeSeriesValues, whitenedModelTimeSeriesValues, ...
    scaleFactor] = whiten_time_series(whiteningFilterObject, ...
    modelTimeSeriesValues)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [whitenedFluxTimeSeriesValues, whitenedModelTimeSeriesValues, ...
% scaleFactor] = whiten_time_series(whiteningFilterObject, ...
% modelTimeSeriesValues)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method whitens the flux time series that was used to instantiate the
% whitening filter object and an optional model time series.
%
% If there is no model time series, only the whitened version of the flux
% time series is returned. If a model time series does exist, the method
% also returns the whitened model time series.
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


% HARD CODE THE FFT BIN FRACTION FOR NOW.
BIN_FRACTION = 0.1;

% Get fields from the input object.
fluxTimeSeriesValues = whiteningFilterObject.fluxTimeSeriesValues;
scalingFilterCoeffts = whiteningFilterObject.scalingFilterCoeffts;
whiteningCoefficients = whiteningFilterObject.whiteningCoefficients;
outlierIndicators = whiteningFilterObject.outlierIndicators;
outlierFillValues = whiteningFilterObject.outlierFillValues;
gapFillConfigurationStruct = whiteningFilterObject.gapFillConfigurationStruct;
cadenceQuarterLabels = whiteningFilterObject.cadenceQuarterLabels;
noiseEstimationByQuarter = whiteningFilterObject.noiseEstimationByQuarterEnabled;

nCadences = length(fluxTimeSeriesValues);
whitenedModelTimeSeriesValues = [];

% set up the waveletObject
waveletObject = waveletClass( scalingFilterCoeffts );
waveletObject = set_outlier_vectors( waveletObject, outlierIndicators, ...
    outlierFillValues, gapFillConfigurationStruct, [] );
waveletObject = set_extended_flux( waveletObject, fluxTimeSeriesValues, ...
    noiseEstimationByQuarter, cadenceQuarterLabels);
waveletObject = set_custom_whitening_coefficients( waveletObject, whiteningCoefficients);
   
% Whiten the flux time series alone if no model time series exists.
% Otherwise whiten the model time series as well. Save only the first
% nCadences in each whitened series. 

whitenedFluxTimeSeriesValues = apply_whitening_to_time_series( waveletObject );

if exist('modelTimeSeriesValues', 'var')
    
    if length(modelTimeSeriesValues) ~= nCadences
        error('DV:whitenTimeSeries:incompatibleTimeSeriesLengths', ...
        'lengths of the flux and model time series do not agree');
    end
    
    whitenedModelTimeSeriesValues = apply_whitening_to_time_series( waveletObject, ...
        modelTimeSeriesValues, true);
end

% Compute the scale factor for the whitener, defined as ratio of amplitudes
% (not powers) at the high frequency end of the flux spectrum where stellar
% variability is low.
gapFilledFluxTimeSeriesValues = fluxTimeSeriesValues(1:nCadences);

gapFilledFluxTimeSeriesFft = fft(gapFilledFluxTimeSeriesValues, nCadences);
whitenedFluxTimeSeriesFft = fft(whitenedFluxTimeSeriesValues, nCadences);

nBins = round(BIN_FRACTION * nCadences / 2);
lastBin = 1 + floor(nCadences / 2);
firstBin = lastBin - nBins + 1;

scaleFactor = ...
    sqrt(sum(abs(whitenedFluxTimeSeriesFft(firstBin : lastBin)) .^ 2) / ...
    sum(abs(gapFilledFluxTimeSeriesFft(firstBin : lastBin)) .^ 2));

% Return
return
