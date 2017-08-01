function verify_126pdc2
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_126pdc2
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Introduce random outliers into the flux time series for some PDC targets.
% Run the PDC matlab controller, and examine the corrected flux. Plot the
% original and corrected (including gap fill) versions of the target time
% series and clearly mark the locations of the injected and detected
% outliers.
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

originalFlux = [pdcDataStruct.targetDataStruct(1 : 5).values];
originalUncertainties = [pdcDataStruct.targetDataStruct(1 : 5).uncertainties];
originalGaps = [pdcDataStruct.targetDataStruct(1 : 5).gapIndicators];
originalOutlier = false(size(originalGaps));

rand('twister', 5489);
OUTLIERFRAC = 0.01;

for iTarget = 1 : 5
    flux = originalFlux( : , iTarget);
    uncertainties = originalUncertainties( : , iTarget);
    gaps = originalGaps( : , iTarget);
    rmsUncertainty = sqrt(mean(uncertainties(~gaps) .^ 2)');
    rands = rand(size(cadenceNumbers));
    isOutlier = rands < OUTLIERFRAC & ~gaps;
    for iOutlier = find(isOutlier')
        sign = 2 * (double(rand(1) < 0.5) - 0.5);
        level = (5 + (3 * rand(1))) * rmsUncertainty;
        flux(iOutlier) = flux(iOutlier) + sign * level;
    end
    originalFlux( : , iTarget) = flux;
    originalOutlier( : , iTarget) = isOutlier;
    pdcDataStruct.targetDataStruct(iTarget).values = flux;
end

cd(SCRATCHDIR);
pdcDataStruct.targetDataStruct(6 : end) = [];
[pdcResultsStruct] = pdc_matlab_controller(pdcDataStruct);

correctedFluxTimeSeries = ...
    [pdcResultsStruct.targetResultsStruct(1:5).correctedFluxTimeSeries];
correctedFlux = [correctedFluxTimeSeries.values];
outliers = [pdcResultsStruct.targetResultsStruct(1:5).outliers];

close all;
for iTarget = 1 : 5
    orig = originalFlux( : , iTarget);
    corr = correctedFlux( : , iTarget);
    isOutlier = originalOutlier( : , iTarget);
    indices = outliers(iTarget).indices + 1;
    plot(cadenceNumbers, orig, '.-');
    hold on
    plot(cadenceNumbers, corr, '.-r');
    plot(cadenceNumbers(isOutlier), orig(isOutlier), 'dk', 'LineWidth', 2);
    plot(cadenceNumbers(indices), orig(indices), 'og');
    plot(cadenceNumbers(indices), corr(indices), 'og');
    hold off
    title('[PDC] Original and Corrected Target Flux');
    xlabel('Cadence');
    ylabel('Flux (e-)');
    legend('Original Flux', 'Corrected Flux', 'Injected Outliers', 'Detected Outliers');
    grid
    pause
end

return
