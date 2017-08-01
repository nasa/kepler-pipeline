function verify_143pa3
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_143pa3
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the uncertainties in the weighted least squares fits, (matlab)
% robust fits, and hybrid robust/weighted least squares fits to the
% background pixels for each cadence. Then plot the uncertainties in the
% background polynomial and those of the other fits.
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
TCPATH = [filesep, 'release-5.0',filesep,'monthly',filesep];

if ispc
    TCPATH = [filesep,TCPATH];
end

TC02DIR = [TCPATH,ZODI_ON_TASK_DIR];

invocation = 0;
fileName = ['pa-inputs-', num2str(invocation), '.mat'];

cd(TC02DIR);
load(fileName);
zodiOnDataStruct = inputsStruct;
clear inputsStruct

backgroundValues = [zodiOnDataStruct.backgroundDataStruct.values];
backgroundUncertainties = [zodiOnDataStruct.backgroundDataStruct.uncertainties];
gapArray = [zodiOnDataStruct.backgroundDataStruct.gapIndicators];

nCadences = size(backgroundUncertainties, 1);
lsCovariance = zeros([nCadences, 1]);
robCovariance = zeros([nCadences, 1]);
hybridCovariance = zeros([nCadences, 1]);

for iCadence = 1 : nCadences
    values = backgroundValues(iCadence, : )';
    variances = backgroundUncertainties(iCadence, : )' .^ 2;
    lsWeights = 1 ./ variances';
    gaps = gapArray(iCadence, : )';
    lsWeights(gaps) = 0;
    lsWeights = lsWeights / sum(lsWeights);
    lsCovariance(iCadence) = lsWeights * (variances .* lsWeights');
    [p, stats] = robustfit(ones(size(variances)), values, [], [], 'off');
    robCovariance(iCadence) = stats.covb;
    hybridWeights = (stats.w ./ variances)';
    hybridWeights = hybridWeights / sum(hybridWeights);
    hybridCovariance(iCadence) = hybridWeights * (variances .* hybridWeights');
end

BACKGROUNDFILE = 'pa_background.mat';
load(BACKGROUNDFILE);
backgroundPolyStruct = inputStruct;
clear inputStruct;

backgroundPoly = [backgroundPolyStruct.backgroundPoly];
backgroundPolyCovariance = [backgroundPoly.covariance]';

close all;
plot(sqrt(robCovariance), 'g');
hold on
plot(sqrt(hybridCovariance), 'm');
plot(sqrt(backgroundPolyCovariance), 'b');
plot(sqrt(lsCovariance), 'r');
title('[PA] Background Polynomial, Least Squares and Robust Fit Uncertainties');
xlabel('Cadence');
ylabel('Uncertainty (e-)');
legend('Robust Fit', 'Robust/WLS Fit', 'Background Polynomial', 'WLS');
grid

return
