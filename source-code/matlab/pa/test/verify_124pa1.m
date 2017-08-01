function verify_124pa1(invocation,cadenceType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_124pa1(invocation,cadenceType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the flux time series for all targets in the TC02 test data
% set. Then plot the mean flux for each target vs Kepler magnitude, along
% with the expected flux.
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
gapArray = [fluxTimeSeries.gapIndicators];
clear fluxTimeSeries zodiOnResultsStruct

close all;
fluxValues(gapArray) = NaN;
plot(fluxValues);
title('[PA] Flux Values');
xlabel('Cadence');
ylabel('Flux (e-)');
pause

fileName = ['pa-inputs-', num2str(invocation), '.mat'];
load(fileName);
zodiOnDataStruct = inputsStruct;
clear inputsStruct

cadenceTimes = zodiOnDataStruct.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;
validTimestamps = timestamps(~cadenceGapIndicators);

fcConstants = zodiOnDataStruct.fcConstants;
spacecraftConfigMap = zodiOnDataStruct.spacecraftConfigMap;
configMapObject = configMapClass(spacecraftConfigMap);
mag12FluxPerSecond = fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;
[ccdExposureTime] = get_exposure_time(configMapObject, validTimestamps);
[numberOfExposuresPerLongCadence] = ...
    get_number_of_exposures_per_long_cadence_period(configMapObject, ...
    validTimestamps);
standardMag12Flux =  mag12FluxPerSecond * ...
    median(ccdExposureTime .* numberOfExposuresPerLongCadence);

mags = [zodiOnDataStruct.targetStarDataStruct.keplerMag]';
fraction = [zodiOnDataStruct.targetStarDataStruct.fluxFractionInAperture]';
clear zodiOnDataStruct

fluxValues(gapArray) = 0;
nValues = sum(~gapArray, 1)';
meanValues = sum(fluxValues, 1)' ./ nValues;
isValid = nValues > 0 & meanValues > 0;
meanValues(~isValid) = 0;

close all;
semilogy(mags(isValid), meanValues(isValid), '.');
hold on
semilogy(mags(isValid), meanValues(isValid) ./ fraction(isValid), '.g');
semilogy((6:16)', mag2b((6:16)'-12) * standardMag12Flux, 'r');
title('[PA] Mean Flux vs Kepler Magnitude');
xlabel('Kepler Magnitude');
ylabel('Flux (e-)');
legend('Mean Flux', 'Mean Corrected for Flux Fraction', 'Expected Flux');
grid

return
