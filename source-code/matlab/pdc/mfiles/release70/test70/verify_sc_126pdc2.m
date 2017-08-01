function verify_sc_126pdc2(flightDataDirString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_sc_126pdc2
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% SOC126
%   The SOC shall generate a quarterly Corrected Flux Time Series for each
%   target star with systematic errors removed.
%
% 126.PDC.2
%   The Pre-Search Data Conditioning CSCI shall identify single point outliers
%   in the flux time series for each target star.
%
%
% Introduce random outliers into the flux time series for some PDC targets.
% Run the PDC matlab controller, and examine the corrected flux. Plot the
% original and corrected (including gap fill) versions of the target time
% series and clearly mark the locations of the injected and detected
% outliers.
%
%
% flightDataDirString
%
% ex. /path/to/flight/q2/i956/pdc-matlab-956-22686
%     /path/to/flight/q2/i956/pdc-matlab-956-22692
%     /path/to/flight/q2/i956/pdc-matlab-956-22703%
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

SCRATCHDIR = '/path/to/matlab/pdc/test/';
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
cadenceNumbers = cadenceTimes.cadenceNumbers;

originalFlux = [pdcDataStruct.targetDataStruct.values];
originalUncertainties = [pdcDataStruct.targetDataStruct.uncertainties];
originalGaps = [pdcDataStruct.targetDataStruct.gapIndicators];
originalOutlier = false(size(originalGaps));

[numCadences numTargets] = size(originalFlux);


rand('twister', 5489);
OUTLIERFRAC = 0.01;

for iTarget = 1 : numTargets
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


%pdcDataStruct.targetDataStruct(6 : end) = [];
[pdcResultsStruct] = pdc_matlab_controller(pdcDataStruct);

correctedFluxTimeSeries = ...
    [pdcResultsStruct.targetResultsStruct.correctedFluxTimeSeries];
correctedFlux = [correctedFluxTimeSeries.values];
outliers = [pdcResultsStruct.targetResultsStruct.outliers];


% save environment
save sc_req_126pdc2_results_to_plot


% create figures
printJpgFlag = false;
paperOrientationFlag = false;
includeTimeFlag      = false;

for iTarget = 1 : numTargets
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

    fileNameStr = ['sc_req_126pdc2_figure' num2str(iTarget)];
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

end

return
