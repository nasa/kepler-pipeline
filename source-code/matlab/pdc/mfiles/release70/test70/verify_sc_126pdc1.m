function verify_sc_126pdc1(flightDataDirString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_sc_126pdc1
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% SOC126
%    The SOC shall generate a quarterly Corrected Flux Time Series for each
%    target star with systematic errors removed.
%
% 126.PDC.1
%    The Pre-Search Data Conditioning CSCI shall fill the data gaps in the
%    ancillary data that are not coincident with the data gaps in the flux time
%    series for each target star for performing systematic error correction.
%
%
% Introduce "short" gaps with random spacing and duration into the
% pipeline ancillary data. Run the PDC matlab controller, then
% load the conditioned ancillary data from disk. Plot the original and
% conditioned (filled) versions of the jitter time series.
%
%
% flightDataDirString
%
% ex. /path/to/flight/q2/i956/pdc-matlab-956-22686
%     /path/to/flight/q2/i956/pdc-matlab-956-22692
%     /path/to/flight/q2/i956/pdc-matlab-956-22703
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

SCRATCHDIR = '/path/to/matlab/pdc/test/run_pdc_here/';
cd(SCRATCHDIR);

invocation = 0;
fileName = ['pdc-inputs-', num2str(invocation), '.mat'];

if nargin==1
    cd(flightDataDirString);
    load(fileName);
    cd(SCRATCHDIR);
else
    load(fileName);
end


pdcDataStruct = inputsStruct;
clear inputsStruct

cadenceTimes = pdcDataStruct.cadenceTimes;
cadenceGapIndicators = cadenceTimes.gapIndicators;
midTimestamps = cadenceTimes.midTimestamps;
midTimestamps(cadenceGapIndicators) = interp1(find(~cadenceGapIndicators), ...
    midTimestamps(~cadenceGapIndicators), find(cadenceGapIndicators), ...
    'linear', 'extrap');

originalMnemonic1 = pdcDataStruct.ancillaryEngineeringDataStruct(1).values;
originalMnemonic2 = pdcDataStruct.ancillaryEngineeringDataStruct(2).values;
timestamps1 = pdcDataStruct.ancillaryEngineeringDataStruct(1).timestamps;
timestamps2 = pdcDataStruct.ancillaryEngineeringDataStruct(2).timestamps;

rand('twister', 5489);
gapIndicators1 = set_random_gaps(originalMnemonic1, 125);
gapIndicators2 = set_random_gaps(originalMnemonic2, 125);

pdcDataStruct.ancillaryEngineeringDataStruct(1).timestamps(gapIndicators1) = [];
pdcDataStruct.ancillaryEngineeringDataStruct(1).values(gapIndicators1) = [];
%pdcDataStruct.ancillaryEngineeringDataStruct(1).uncertainties(gapIndicators1) = [];

pdcDataStruct.ancillaryEngineeringDataStruct(2).timestamps(gapIndicators2) = [];
pdcDataStruct.ancillaryEngineeringDataStruct(2).values(gapIndicators2) = [];
%pdcDataStruct.ancillaryEngineeringDataStruct(2).uncertainties(gapIndicators2) = [];

pdcDataStruct.targetDataStruct(2 : end) = [];
[pdcResultsStruct] = pdc_matlab_controller(pdcDataStruct); %#ok<NASGU>
clear pdcResultsStruct


load('pdc_cads.mat', 'conditionedAncillaryDataStruct');
filledMnemonic1 = conditionedAncillaryDataStruct(1).ancillaryTimeSeries.values;
filledGapIndicators1 = conditionedAncillaryDataStruct(1).ancillaryTimeSeries.gapIndicators;
filledMnemonic2 = conditionedAncillaryDataStruct(2).ancillaryTimeSeries.values;
filledGapIndicators2 = conditionedAncillaryDataStruct(2).ancillaryTimeSeries.gapIndicators;

% save environment
save sc_req_126pdc1_results_to_plot

% create figures
printJpgFlag = false;
paperOrientationFlag = false;
includeTimeFlag      = false;

figure
plot(timestamps1, originalMnemonic1, '.-');
hold on
plot(timestamps1(gapIndicators1), originalMnemonic1(gapIndicators1), 'og')
plot(midTimestamps(~filledGapIndicators1), filledMnemonic1(~filledGapIndicators1), '.-r');
hold off
title('[PDC] Original and Conditioned Mnemonic 1');
xlabel('Cadence');
ylabel('Engineering Value');
legend('Original Values', 'Deleted Values', 'Conditioned Values');
grid
fileNameStr = 'sc_req_126pdc1_figure1';
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);


figure;
plot(timestamps2, originalMnemonic2, '.-');
hold on
plot(timestamps2(gapIndicators2), originalMnemonic2(gapIndicators2), 'og')
plot(midTimestamps(~filledGapIndicators2), filledMnemonic2(~filledGapIndicators2), '.-r');
hold off
title('[PDC] Original and Conditioned Mnemonic 2');
xlabel('Cadence');
ylabel('Engineering Value');
legend('Original Values', 'Deleted Values', 'Conditioned Values');
grid
fileNameStr = 'sc_req_126pdc1_figure2';
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

return


function [gapIndicators] = set_random_gaps(v, maxLength)

nCadences = length(v);
gapIndicators = false([nCadences, 1]);

startIndex = 2;
while startIndex < nCadences
    gapStart = 1 + fix(maxLength * rand(1));
    gapDuration = 1 + fix(maxLength * rand(1));
    startIndex = startIndex + gapStart;
    stopIndex = min(nCadences, startIndex + gapDuration - 1);
    if stopIndex < nCadences
        gapIndicators(startIndex : stopIndex) = true;
    end
    startIndex = maxLength + stopIndex;
end

return
