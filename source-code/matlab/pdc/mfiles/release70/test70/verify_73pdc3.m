function verify_73pdc3
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_73pdc3
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute and plot the ratio of the standard deviation of the raw flux to
% the RMS uncertainty in the raw flux vs Kepler magnitude for all targets
% in the TC04 (DV, JT on / SV, AP off) test data set. Then compute and plot
% the ratio of the standard deviation of the corrected flux to the RMS
% uncertainty in the raw flux for the same targets. Repeat for the TC05
% (everything on) data set.
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
else
    TCPATH = '/path/to/release-5.0/monthly/';
end

TC04DIR = [TCPATH, 'TC04/pdc-matlab-36-2846'];
TC05DIR = [TCPATH, 'TC05/pdc-matlab-39-2974'];

verify(TC04DIR);
verify(TC05DIR);

return

function verify(directory)

invocation = 0;
fileName = ['pdc-inputs-', num2str(invocation), '.mat'];

cd(directory);
load(fileName);
pdcDataStruct = inputsStruct;
clear inputsStruct

mags = [pdcDataStruct.targetDataStruct.keplerMag];
rawFluxValues = [pdcDataStruct.targetDataStruct.values];
rawFluxUncertainties = [pdcDataStruct.targetDataStruct.uncertainties];
rawGapArray = [pdcDataStruct.targetDataStruct.gapIndicators];
clear pdcDataStruct

close all;
rawFluxValues(rawGapArray) = NaN;
plot(rawFluxValues);
title('[PDC] Raw Flux');
xlabel('Cadence');
ylabel('Flux (e-)');
pause

fileName = ['pdc-outputs-', num2str(invocation), '.mat'];
load(fileName);
pdcResultsStruct = outputsStruct;
clear outputsStruct

correctedFluxTimeSeries = ...
    [pdcResultsStruct.targetResultsStruct.correctedFluxTimeSeries];
correctedFluxValues = [correctedFluxTimeSeries.values];
correctedGapArray = [correctedFluxTimeSeries.gapIndicators];
clear pdcResultsStruct

correctedFluxValues(correctedGapArray) = NaN;
plot(correctedFluxValues);
title('[PDC] Corrected Flux');
xlabel('Cadence');
ylabel('Flux (e-)');
pause

nTargets = length(mags);
sigmaRawFlux = zeros([nTargets, 1]);
sigmaCorrectedFlux = zeros([nTargets, 1]);
rmsUncertainties = zeros([nTargets, 1]);
for iTarget = 1 : nTargets
    targetFlux = rawFluxValues( : , iTarget);
    targetUncertainties = rawFluxUncertainties( : , iTarget);
    targetGaps = rawGapArray( : , iTarget);
    sigmaRawFlux(iTarget) = std(targetFlux(~targetGaps));
    rmsUncertainties(iTarget) = ...
        sqrt(mean(targetUncertainties(~targetGaps) .^ 2));
    targetFlux = correctedFluxValues( : , iTarget);
    targetGaps = correctedGapArray( : , iTarget);
    sigmaCorrectedFlux(iTarget) = std(targetFlux(~targetGaps));
end

isValid = sum(~rawGapArray, 1)' > 1;
sigmaRawFlux(~isValid) = 0;
sigmaCorrectedFlux(~isValid) = 0;
rmsUncertainties(~isValid) = 0;

plot(mags(isValid), sigmaRawFlux(isValid) ./ rmsUncertainties(isValid), '.');
hold on
plot(mags(isValid), sigmaCorrectedFlux(isValid) ./ rmsUncertainties(isValid), '.r');
title('[PDC] Ratios of Flux Sigma to RMS Raw Flux Uncertainty vs Kepler Magnitude');
xlabel('Kepler Magnitude');
ylabel('Ratio');
legend('Raw Flux', 'Corrected Flux');
grid
pause

hold off
loglog(sigmaRawFlux(isValid), sigmaCorrectedFlux(isValid), '.');
hold on
x = axis;
maxAxis = max(x);
minAxis = min(x);
loglog([minAxis; maxAxis], [minAxis; maxAxis], 'k');
hold off
title('[PDC] Raw and Corrected Flux Sigmas')
xlabel('Raw Flux Sigma (e-)');
ylabel('Corrected Flux Sigma (e-)');
grid
pause

return
