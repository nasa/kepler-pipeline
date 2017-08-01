function verify_143pa2(invocation,cadenceType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_143pa2(invocation,cadenceType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the flux uncertainties for all targets in the TC02 test data set.
% Then plot the RMS flux uncertainty, the square root of the mean flux, and
% the flux sigma for each target vs Kepler magnitude. Finally, plot the RMS
% flux uncertainty vs sigma flux for each target.
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

ZODI_ON_TASK_DIR  = ['TC02' filesep 'pa-matlab-34-2634'];
LC_PATH = [filesep,'release-5.0',filesep,'monthly',filesep];
SC_PATH = 'TBD_SC_PATH';

if( strcmpi(cadenceType, 'long') )
    TCPATH = LC_PATH;
elseif( strcmpi(cadenceType, 'short') )
        TCPATH = SC_PATH;
else
    disp(['Cadence type ',cadenceType,' is invalid. Type must be *short* or *long*.']);
    return;
end

if ispc
    TCPATH = [filesep,TCPATH];
end

TC02DIR = [TCPATH,filesep,ZODI_ON_TASK_DIR];


fileName = ['pa-outputs-', num2str(invocation), '.mat'];

cd(TC02DIR);
load(fileName);
zodiOnResultsStruct = outputsStruct;
clear outputsStruct

fluxTimeSeries = ...
    [zodiOnResultsStruct.targetStarResultsStruct.fluxTimeSeries];
fluxValues = [fluxTimeSeries.values];
fluxUncertainties = [fluxTimeSeries.uncertainties];
gapArray = [fluxTimeSeries.gapIndicators];
clear fluxTimeSeries zodiOnResultsStruct

close all;
fluxUncertainties(gapArray) = NaN;
plot(fluxUncertainties);
title('[PA] Flux Uncertainties');
xlabel('Cadence');
ylabel('Uncertainty (e-)');
pause

fileName = ['pa-inputs-', num2str(invocation), '.mat'];
load(fileName);
zodiOnDataStruct = inputsStruct;
clear inputsStruct

mags = [zodiOnDataStruct.targetStarDataStruct.keplerMag];
clear zodiOnDataStruct

fluxValues(gapArray) = 0;
nValues = sum(~gapArray, 1)';
meanValues = sum(fluxValues, 1)' ./ nValues;
isValid = nValues > 0 & meanValues > 0;
meanValues(~isValid) = 0;
rootMeanValues = sqrt(meanValues);

nTargets = length(mags);
sigmaFlux = zeros([nTargets, 1]);
for iTarget = 1 : nTargets
    targetFlux = fluxValues( : , iTarget);
    targetGaps = gapArray( : , iTarget);
    sigmaFlux(iTarget) = std(targetFlux(~targetGaps));
end

fluxUncertainties(gapArray) = 0;
rmsUncertainties = sqrt(sum(fluxUncertainties .^ 2, 1)' ./ nValues);
rmsUncertainties(~isValid) = 0;

close all;
semilogy(mags(isValid), rmsUncertainties(isValid), '.');
hold on
semilogy(mags(isValid), rootMeanValues(isValid), '.r');
semilogy(mags(isValid), sigmaFlux(isValid), '.g');
title('[PA] RMS Flux Uncertainty, Root Flux and Flux Sigma vs Kepler Magnitude');
xlabel('Kepler Magnitude');
ylabel('Uncertainty (e-)');
legend('Uncertainty', 'Sqrt Target Flux', 'Std Target Flux');
grid
pause

hold off
loglog(rmsUncertainties(isValid), sigmaFlux(isValid), '.');
hold on
x = axis;
maxAxis = max(x);
minAxis = min(x);
loglog([minAxis; maxAxis], [minAxis; maxAxis], 'k');
title('[PA] RMS Flux Uncertainties & Flux Sigmas')
xlabel('RMS Uncertainty (e-)');
ylabel('Flux Sigma (e-)');
grid

return
