function verify_126pdc1
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_126pdc1
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Introduce "short" gaps with random spacing and duration into the AJIT_X
% and AJIT_Y pipeline ancillary data. Run the PDC matlab controller, then
% load the conditioned ancillary data from disk. Plot the original and
% conditioned (filled) versions of the jitter time series.
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

if ispc
    TCPATH = '\path\to\release-5.0\monthly\';
    SCRATCHDIR = 'C:\path\to';
else
    TCPATH = '/path/to/release-5.0/monthly/';
    SCRATCHDIR = '/path/to/pdc';
end

TC04DIR = [TCPATH, 'TC04AJIT/pdc-matlab-36-2846'];

invocation = 0;
fileName = ['pdc-inputs-', num2str(invocation), '.mat'];

cd(TC04DIR);
load(fileName);
pdcDataStruct = inputsStruct;
clear inputsStruct

cadenceTimes = pdcDataStruct.cadenceTimes;
cadenceNumbers = cadenceTimes.cadenceNumbers;

originalAjitX = pdcDataStruct.ancillaryPipelineDataStruct(1).values;
originalAjitY = pdcDataStruct.ancillaryPipelineDataStruct(2).values;

rand('twister', 5489);
xGapIndicators = set_random_gaps(originalAjitX, 125);
yGapIndicators = set_random_gaps(originalAjitY, 125);

pdcDataStruct.ancillaryPipelineDataStruct(1).timestamps(xGapIndicators) = [];
pdcDataStruct.ancillaryPipelineDataStruct(1).values(xGapIndicators) = [];
pdcDataStruct.ancillaryPipelineDataStruct(1).uncertainties(xGapIndicators) = [];
pdcDataStruct.ancillaryPipelineDataStruct(2).timestamps(yGapIndicators) = [];
pdcDataStruct.ancillaryPipelineDataStruct(2).values(yGapIndicators) = [];
pdcDataStruct.ancillaryPipelineDataStruct(2).uncertainties(yGapIndicators) = [];

cd(SCRATCHDIR);
pdcDataStruct.targetDataStruct(6 : end) = [];
[pdcResultsStruct] = pdc_matlab_controller(pdcDataStruct);
clear pdcResultsStruct

load('pdc_cads.mat', 'conditionedAncillaryDataStruct');
filledAjitX = conditionedAncillaryDataStruct(1).ancillaryTimeSeries.values;
filledAjitY = conditionedAncillaryDataStruct(2).ancillaryTimeSeries.values;

close all;
plot(cadenceNumbers, originalAjitX, '.-');
hold on
plot(cadenceNumbers, filledAjitX, '.-r');
plot(cadenceNumbers(xGapIndicators), filledAjitX(xGapIndicators), 'og');
hold off
title('[PDC] Original and Conditioned AJIT-X');
xlabel('Cadence');
ylabel('Jitter (Pixels)');
legend('Original Ajit', 'Conditioned Ajit', 'Gap Markers');
grid
pause

plot(cadenceNumbers, originalAjitY, '.-');
hold on
plot(cadenceNumbers, filledAjitY, '.-r');
plot(cadenceNumbers(yGapIndicators), filledAjitY(yGapIndicators), 'og');
hold off
title('[PDC] Original and Conditioned AJIT-Y');
xlabel('Cadence');
ylabel('Jitter (Pixels)');
legend('Original Ajit', 'Conditioned Ajit', 'Gap Markers');
grid

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
