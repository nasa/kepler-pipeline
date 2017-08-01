%% function [] = validate_crowding_metric_and_flux_fraction ()
%
% This function loads data from the current PDC outputs task
% directory and plots the raw flux, corrected flux and the expected
% correction due to the crowding metric and flux fraction.
%
% inputs:
%        None
%
% outputs:
%        None, just plots
%
%**************************************************************************
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

function [] = validate_crowding_metric_and_flux_fraction ()

% check if we are in an output task directory
if (~exist('pdc-inputs-0.mat') || ~exist('pdc-outputs-0.mat'))
    display('This does not appear to be a PDC output task directory')
    inDir = uigetdir('.', 'Select PDC Output Task Directory.');
    cd inDir;
end

load pdc-inputs-0.mat;
load pdc-outputs-0.mat;
module = num2str(outputsStruct.ccdModule);
output = num2str(outputsStruct.ccdOutput);
moduleString = ['Module: ', module, ' ,Output: ', output];
display(moduleString);
inputsStruct = pdcInputClass.process_channelDataStruct(inputsStruct);
nTargets = length(inputsStruct.targetDataStruct);

% Add in data anomalies to gaps
[inputsStruct.targetDataStruct ~] = pdc_gap_data_anomalies (inputsStruct.targetDataStruct, inputsStruct.cadenceTimes.dataAnomalyFlags, [], [], ...
                                                            inputsStruct.cadenceTimes, []);

crowdingMetricArray = [inputsStruct.targetDataStruct.crowdingMetric];
fluxFractionArray = [inputsStruct.targetDataStruct.fluxFractionInAperture];

targetUncorrectedValues = [inputsStruct.targetDataStruct.values];
targetUncertainties     = [inputsStruct.targetDataStruct.uncertainties];
targetUncorrectedGaps   = [inputsStruct.targetDataStruct.gapIndicators];
targetUncorrectedValues(targetUncorrectedGaps) = NaN;
targetUncertainties    (targetUncorrectedGaps) = NaN;


targetCorrectedValues = zeros(length(targetUncorrectedValues(:,1)), nTargets);
for iTarget = 1 : nTargets
    targetCorrectedValues(:,iTarget) = ...
        outputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.values;
end
targetCorrectedValues(targetUncorrectedGaps) = NaN;

%***
% Do a poor man's renormalization just on the median value
% There is no trend to the harmonics so no need to add them in is using the median.
medianUncorrectedValues        = nanmedian(targetUncorrectedValues);
medianUncorrectedUncertainties = nanmedian(targetUncertainties);
medianCorrectedValues          = nanmedian(targetCorrectedValues);

% Poor man's crowding metric correction
medianPoorCorrectedValues = medianUncorrectedValues .* crowdingMetricArray;

% Poor man's flux fraction correction
medianPoorCorrectedValues = medianPoorCorrectedValues ./ fluxFractionArray;

% Compare with corrected Values
correctedDiffValues = (medianCorrectedValues - medianUncorrectedValues) ./ medianUncorrectedValues;
poorDiffValues = (medianPoorCorrectedValues - medianUncorrectedValues) ./ medianUncorrectedValues;
%diffOfTheDiffs = correctedDiffValues - poorDiffValues;
diffOfTheDiffs = (medianCorrectedValues - medianPoorCorrectedValues) ./ medianUncorrectedValues;
normalizedUncertainty = medianUncorrectedUncertainties ./ medianUncorrectedValues;
figure;

subplot(2,1,1);
plot(correctedDiffValues, '*b');
hold on;
plot(poorDiffValues, '*r');
legend('Normalized PDC Corrected Valued', 'Normalized Simple Corrected Values')
title('Varifying Crowding Metric and Flux Fraction Corrected');
xlabel('Target Index');
ylabel('Normalized Target Value');

subplot(2,1,2);
plot(diffOfTheDiffs, '*m');
hold on;
%plot(normalizedUncertainty, '*c');
xlabel('Target Index');
ylabel('Relative Difference');
title('Difference Between above two');

return
