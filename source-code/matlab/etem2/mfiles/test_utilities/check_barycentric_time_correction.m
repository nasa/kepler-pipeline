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
pluginList = defined_plugin_classes();
etem2ConfigurationStruct = ETEM2_inputs_example();
runParamsObject = runParamsClass(etem2ConfigurationStruct.runParamsData);

barycentricTimeCorrectionData = pluginList.barycentricTimeCorrectionData;
barycentricTimeCorrectionData.maxTimeLength = 2410;

etem2ConfigurationStruct.runParamsData.raDec2PixObject = ...
    get(runParamsObject,'raDec2PixObject') ;
barycentricTimeCorrectionObject = barycentricTimeCorrectionClass(...
    barycentricTimeCorrectionData, etem2ConfigurationStruct.runParamsData);

runStartTime = datestr2julian('1-Jan-2010'); % in jd

fovRa = get(runParamsObject, 'boresiteRa'); % in degrees
fovDec = get(runParamsObject, 'boresiteDec'); % in degrees

% compare a few points (which are directly evaluated) with many points modeled 
% as a polynomial
oneDayHours = runStartTime:1/24:runStartTime + 100; % one humdred days of hours
[timeOffsetHours, posHours] = get_time_correction(barycentricTimeCorrectionObject, fovRa, fovDec, oneDayHours);

oneDaySeconds = runStartTime:1/(24*3600):runStartTime + 100; % one hundred days of seconds
[timeOffsetSeconds, posSeconds] = get_time_correction(barycentricTimeCorrectionObject, fovRa, fovDec, oneDaySeconds);

figure;
subplot(1,3,1);
plot(oneDayHours - oneDayHours(1), posHours(:,1), oneDaySeconds - oneDaySeconds(1), posSeconds(:,1));
title('x');
xlabel('days from Jan 1 2010');
ylabel('meters');
legend('direct', 'polynomial');
subplot(1,3,2);
plot(oneDayHours - oneDayHours(1), posHours(:,2), oneDaySeconds - oneDaySeconds(1), posSeconds(:,2));
title('y');
legend('direct', 'polynomial');
xlabel('days from Jan 1 2010');
ylabel('meters');
subplot(1,3,3);
plot(oneDayHours - oneDayHours(1), posHours(:,3), oneDaySeconds - oneDaySeconds(1), posSeconds(:,3));
title('z');
legend('direct', 'polynomial');
xlabel('days from Jan 1 2010');
ylabel('meters');

figure;
plot(oneDayHours - oneDayHours(1), timeOffsetHours, oneDaySeconds - oneDaySeconds(1), timeOffsetSeconds);
title('time offset');
legend('direct', 'polynomial');
xlabel('days from Jan 1 2010');
ylabel('seconds');

% look at a year of time offsets via direct evaluation
oneYear = runStartTime:runStartTime+400;
timeOffsetYear = get_time_correction(barycentricTimeCorrectionObject, fovRa, fovDec, oneYear);
figure
plot(oneYear - oneYear(1), timeOffsetYear/60);
title('1 year time offset');
xlabel('days from Jan 1 2010');
ylabel('minutes');

