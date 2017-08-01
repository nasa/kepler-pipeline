% script to test dynamic noise object
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

configStruct = ETEM2_inputs_1channel_prf();
configStruct.runParamsData.simulationData.moduleNumber = 14;
configStruct.runParamsData.simulationData.outputNumber = 4;

pluginList = defined_plugin_classes();

runParamsObject = runParamsClass(configStruct.runParamsData);

% % fast T change: from 20 to 22 in 72 hours
% temperatureFunctionData.detector = 'PEDACQ3T';
% temperatureFunctionData.tThermal_in = -1/0.007;
% temperatureFunctionData.temp_equilibrium_in = 17;
% temperatureFunctionData.deltaT_initial_in = NaN;
% temperatureFunctionData.temp_initial = 20;
% temperatureFunctionData.dTdt_initial = NaN;
% temperatureFunctionData.linear_rate = 0.0;
% temperatureFunctionData.verbose = false;

% pluginList.dynamicNoiseData.temperatureFunctionData = temperatureFunctionData;
dynamicNoiseObject = dynamicNoiseClass(pluginList.dynamicNoiseData, runParamsObject);

nCadences = 242; % 3 days of prf data take
black = zeros(nCadences, 1070, 1132);

for cadence = 1:nCadences;
	[black(cadence, :, :), temperature(cadence)] = get_black_values(dynamicNoiseObject, cadence);
end

figure;
plot(temperature);
title('temperature');
xlabel('cadence (15 min)');
ylabel('degrees C');

figure;
imagesc(squeeze(black(1, :,:)));
title('2D black');

figure;
plot(squeeze(black(:,50,:))');
title('row 50 of 2d black');

figure;
plot(squeeze(black(:,:,500))');
title('column 500 of 2d black, uncalibrated');

% get calibration frame
[calibrationBlack, calibrationTemp] = get_black_values(dynamicNoiseObject, -1);
cb = repmat(calibrationBlack, [1, 1, nCadences]);
calibratedBlack = black - permute(cb, [3,1,2]);
figure;
imagesc(squeeze(calibratedBlack(1, :,:)));
title('calibrated');

figure;
plot(squeeze(calibratedBlack(:,:,500))');
title('column 500 of 2d black, calibrated');

