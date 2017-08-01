function [pdcResultsStruct] = run_presearch_data_conditioning(pdcDataStructLoadString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdcResultsStruct] = test_presearch_data_conditioning(path, runs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function provides test data to the correct_systematic_error function
% for one or more ETEM runs. The 'path' of the directory containing the local
% ETEM run subdirectories must be specified as an argument. The numbers of the
% run subdirectories must specified by 'runs', e.g. {'80100', '80200'}.
%
% For each ETEM run, the following files must be present in the respective
% run subdirectories: run_params_rundddddd.mat, ktargets_rundddddd.mat,
% Ajit_rundddddd.mat and raw_flux_gcr_rundddddd.dat. If the debug flag is
% set, plots of rms fit error vs. stellar magnitude, mad vs. stellar
% magnitude, and relative flux, fitted flux and cotrended time series will
% be displayed.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%                        path: [string]  path to local ETEM run subdirectories
%                    runs: [cell array]  number strings of run subdirectories
%
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


% dx                   4454x1                  35632  double
% dy                   4454x1                  35632  double
% fluxTimeSeries       4454x1998            71192736  double
% keplerMag            1998x1                  15984  double
% runEndTime              1x1                      8  double
% runStartTime            1x1                      8  double

%keplerMag keplerId tadCrowdingMetric fluxTimeSeries dx dy runStartTime runEndTime moduleNumber outputNumber observingSeason;


eval(pdcDataStructLoadString);

debugFlag = 0;

sgPolyOrder = 6;
sgFrameSize = 385;
satSegThreshold = 12.0;
satSegExclusionZone = 180;
robustCotrendFitFlag = false;
madXFactor = 10;
maxGiantTransitDurationInHours = 72;
maxDetrendPolyOrder = 25;
maxArOrderLimit = 25;
maxCorrelationWindowXFactor = 5;
gapFillModeIsAddBackPredictionError = true;
nWaveletTaps = 12;
cadenceType = 'LONG';
cadenceDurationInMinutes = 30;
shortCadencesPerLongCadence = 30;
medianFilterLength = 11;
histogramLength = 20;
histogramCountFraction = 0.95;
outlierScanWindowSize = 144;
outlierThresholdXFactor = 4.0;

SECONDS_PER_DAY = 86400;

origDir = pwd;

pdcModuleParameters.sgPolyOrder = sgPolyOrder;
pdcModuleParameters.sgFrameSize = sgFrameSize;
pdcModuleParameters.satSegThreshold = satSegThreshold;
pdcModuleParameters.satSegExclusionZone = satSegExclusionZone;
pdcModuleParameters.robustCotrendFitFlag = robustCotrendFitFlag;
pdcModuleParameters.madXFactor = madXFactor;
pdcModuleParameters.maxGiantTransitDurationInHours = ...
    maxGiantTransitDurationInHours;
pdcModuleParameters.maxDetrendPolyOrder = maxDetrendPolyOrder;
pdcModuleParameters.maxArOrderLimit = maxArOrderLimit;
pdcModuleParameters.maxCorrelationWindowXFactor = ...
    maxCorrelationWindowXFactor;
pdcModuleParameters.gapFillModeIsAddBackPredictionError = ...
    gapFillModeIsAddBackPredictionError;
pdcModuleParameters.waveletFilterCoeffts = ...
    daubechies_low_pass_scaling_filter(nWaveletTaps);
pdcModuleParameters.cadenceType = cadenceType;
pdcModuleParameters.cadenceDurationInMinutes = cadenceDurationInMinutes;
pdcModuleParameters.shortCadencesPerLongCadence = ...
    shortCadencesPerLongCadence;
pdcModuleParameters.medianFilterLength = medianFilterLength;
pdcModuleParameters.histogramLength = histogramLength;
pdcModuleParameters.histogramCountFraction = histogramCountFraction;
pdcModuleParameters.outlierScanWindowSize = outlierScanWindowSize;
pdcModuleParameters.outlierThresholdXFactor = outlierThresholdXFactor;

[nCadences, nTargets] = size(fluxTimeSeries);


mjd = runStartTime;

timestamps = mjd + (0 : nCadences)' * ((runEndTime - runStartTime) / nCadences);



cadenceStartTimes = timestamps(1 : end - 1);
cadenceEndTimes = timestamps(2 : end);
mjdTimestamps = cadenceStartTimes + diff(timestamps) / 2;

ancillaryDataStruct(1).mnemonic = 'DX';
ancillaryDataStruct(1).timestamps = mjdTimestamps;
ancillaryDataStruct(1).isAncillaryEngineeringData = false;
ancillaryDataStruct(1).cotrendPolyOrder = 3;
ancillaryDataStruct(1).cotrendCrossProductIndices = 2;
ancillaryDataStruct(1).ancillaryTimeSeries.values = dx;
ancillaryDataStruct(1).ancillaryTimeSeries.uncertainties = ...
    ones([nCadences, 1]);
ancillaryDataStruct(1).ancillaryTimeSeries.gapIndicators = ...
    false([nCadences, 1]);

ancillaryDataStruct(2).mnemonic = 'DY';
ancillaryDataStruct(2).timestamps = mjdTimestamps;
ancillaryDataStruct(2).isAncillaryEngineeringData = false;
ancillaryDataStruct(2).cotrendPolyOrder = 3;
ancillaryDataStruct(2).cotrendCrossProductIndices = 1;
ancillaryDataStruct(2).ancillaryTimeSeries.values = dy;
ancillaryDataStruct(2).ancillaryTimeSeries.uncertainties = ...
    ones([nCadences, 1]);
ancillaryDataStruct(2).ancillaryTimeSeries.gapIndicators = ...
    false([nCadences, 1]);





relativeFluxTimeSeries = struct( ...
    'values', zeros(nCadences,1), ...
    'uncertainties', zeros(nCadences,1), ...
    'gapIndicators', false(nCadences,1) );

targetDataStruct = repmat(struct('relativeFluxTimeSeries', relativeFluxTimeSeries), nTargets, 1);

for j = 1 : nTargets
    targetDataStruct(j).keplerId = keplerId(j);
    targetDataStruct(j).relativeFluxTimeSeries.values = fluxTimeSeries( : , j);
    targetDataStruct(j).relativeFluxTimeSeries.uncertainties = ones([nCadences, 1]);
    targetDataStruct(j).relativeFluxTimeSeries.gapIndicators = false([nCadences, 1]);
end

pdcDataStruct.ccdModule = moduleNumber;
pdcDataStruct.ccdOutput = outputNumber;
pdcDataStruct.cadenceStartTimes = cadenceStartTimes;
pdcDataStruct.cadenceEndTimes = cadenceEndTimes;
pdcDataStruct.pdcModuleParameters = pdcModuleParameters;
pdcDataStruct.ancillaryDataStruct = ancillaryDataStruct;
pdcDataStruct.targetDataStruct = targetDataStruct;
pdcDataStruct.debugFlag = debugFlag;

[pdcResultsStruct] = pdc_matlab_controller(pdcDataStruct);

save pdcResults.mat pdcResultsStruct cadenceEndTimes cadenceStartTimes mjdTimestamps;
cd(origDir);

return
