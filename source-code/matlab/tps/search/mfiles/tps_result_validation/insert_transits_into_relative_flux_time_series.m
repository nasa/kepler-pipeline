% insert_transits_into_relative_flux_time_series.m
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

% targetsWithNoTransits comes from running validate_tps_findings.m

noTransitsTargetsId = unique(cat(1,tpsResults(targetsWithNoTransits).keplerId));

%noTransitsTargetsId = inputsStruct.tpsTargets(1).keplerId;
% inputsStruct.tpsTargets(1)
%           keplerId: 6586004
%             kepMag: 13.0630
%     crowdingMetric: 0.9918
%        validKepMag: 0
%          fluxValue: [1440x1 double]
%        uncertainty: [1440x1 double]
%         gapIndices: []
%        fillIndices: []
%     outlierIndices: []


nTargets = length(inputsStruct.tpsTargets);

if (nTargets < 100)
    insertTargets = nTargets;
else
    insertTargets = 100;
end

hoursInDay = 24;

cadenceTimeStamps = cat(1, inputsStruct.cadenceTimes.midTimestamps);
cadencesPerHour = ( (1/median(diff(cadenceTimeStamps))/ hoursInDay)); % in days

% collect only insertTargets targets  for testing

insertCount = 0;

nCadences = length(inputsStruct.tpsTargets(1).fluxValue);

transitDurationsInHours = (1:14)';
transitPeriodInDays = (1:sqrt(2)/4:7)';
transitDepthsInPpm = (2000:50:10000)';

indexCadence = (1:nCadences)';


testInputStruct = inputsStruct;
transitSignature = zeros(nCadences,insertTargets);
insertedPeriodInDays = zeros(insertTargets,1);
insertedPhaseInDays = zeros(insertTargets,1);
insertedDurationInHours = zeros(insertTargets,1);
insertedTransitDepth = zeros(insertTargets,1);

for j = 1:nTargets

    if(insertCount > insertTargets)
        break;
    end

    keplerId = inputsStruct.tpsTargets(j).keplerId;
    if(ismember(keplerId,noTransitsTargetsId))

        insertCount = insertCount + 1;

        % collect transit signal
        transitDuration = transitDurationsInHours(unidrnd(length(transitDurationsInHours),1,1)); % hours
        orbitalPeriod = transitPeriodInDays(unidrnd(length(transitPeriodInDays),1,1)); % days
        transitDepth = transitDepthsInPpm(unidrnd(length(transitDepthsInPpm),1,1)); % ppm

        possiblePhaseInDays = (0.5:0.1:orbitalPeriod)';
        transitPhase = possiblePhaseInDays(unidrnd(length(possiblePhaseInDays),1,1)); % days

        transitSignal = - transitDepth*(abs(mod(indexCadence - transitPhase*24*cadencesPerHour + transitDuration* 0.5*cadencesPerHour, orbitalPeriod*24*cadencesPerHour)) < transitDuration* 0.5*cadencesPerHour); % transit signature
        testInputStruct.tpsTargets(insertCount) = inputsStruct.tpsTargets(j);

        transitSignature(:,insertCount) = transitSignal;

        insertedPeriodInDays(insertCount) = orbitalPeriod;
        insertedPhaseInDays(insertCount) = transitPhase;
        insertedDurationInHours(insertCount) = transitDuration;
        insertedTransitDepth(insertCount) = transitDepth;


    end

end

if(insertCount+1 < length(testInputStruct.tpsTargets))
    testInputStruct.tpsTargets(insertCount+1:end) = [];
end
for j = 1:insertTargets

    testInputStruct.tpsTargets(j).transitSignature = transitSignature(:,j);
    testInputStruct.tpsTargets(j).insertedPeriodInDays = insertedPeriodInDays(j);
    testInputStruct.tpsTargets(j).insertedPhaseInDays = insertedPhaseInDays(j);
    testInputStruct.tpsTargets(j).insertedDurationInHours = insertedDurationInHours(j);
    testInputStruct.tpsTargets(j).insertedTransitDepth = insertedTransitDepth(j);

end



% nStars = length(testInputStruct.tpsTargets);
%
% for j=1:nStars
%
%
%     fluxValue = testInputStruct.tpsTargets(j).fluxValue;
%
%     transitSignature = testInputStruct.tpsTargets(j).transitSignature;
%
%     fluxValue = fluxValue + median(fluxValue)*transitSignature*1e-6;
%
%     testInputStruct.tpsTargets(j).fluxValue = fluxValue;
%
%
% end
%


fprintf('');

% for j=1:insertTargets
%     testInputStruct.tpsTargets(j)
%     tpsOutputStruct.tpsResults(j)
%     tpsOutputStruct.tpsResults(j+insertTargets)
%     tpsOutputStruct.tpsResults(j+200)
%     pause
%     clc
% end
%
