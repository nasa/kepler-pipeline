% validate_tps_detections.m
% groundTruthStruct(1)
%
% ans =
%
%       keplerId: 6586143
%         module: 3
%         output: 1
%     etemRunDir: 'run_long_m3o1s1'
%     targetList: [1x1 struct]
%
% groundTruthStruct(1).targetList
%
% ans =
%
%                 keplerId: 6586143
%           lightCurveList: [1x1 struct]
%           lightCurveData: []
%      compositeLightCurve: [4320x1 double]
%          keplerMagnitude: 15.7100
%                       ra: 284.5532
%                      dec: 42.0114
%        logSurfaceGravity: 4.5990
%           logMetallicity: 0.1420
%     effectiveTemperature: 5873
%                     flux: 7.0245e+003
%                      row: 496
%                   column: 639
%              rowFraction: 8
%           columnFraction: 3
%        visiblePixelIndex: 641500
%            subPixelIndex: 28
%              initialData: [1x1 struct]
%
%
%
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

% tpsResults =
%
% 1x5703 struct array with fields:
%     keplerId
%     trialTransitPulseInHours
%     maxSingleEventStatistic
%     rmsCdpp
%     cdppTimeSeries
%     meanSingleEventStatistic
%     correlationTimeSeries
%     normalizationTimeSeries
%     bestPhaseInCadences
%     bestOrbitalPeriodInCadences
%     maxMultipleEventStatistic
%     detectedOrbitalPeriodInDays
%     timeToFirstTransitInDays
%     isPlanetACandidate
%     foldedStatisticAtTrialPhases
%     phaseLagInCadences
%     foldedStatisticAtTrialPeriods

function validationSummaryStruct = validate_tps_findings_using_etem_groundtruth(tpsOutputStruct, tpsInputStruct, groundTruthStruct)
clc;
close all;

diary on;

pwd

TCE_THRESHOLD = 7.1;

tpsResults = tpsOutputStruct.tpsResults;

keplerIdsAll = cat(1, tpsResults.keplerId);
nTargets = length(unique(keplerIdsAll));

falsePositives = zeros(nTargets,1);
correctDetections = zeros(nTargets,1);
missedDetections = zeros(nTargets,1);

falsePositivesIndex = zeros(nTargets,1);
correctDetectionsIndex = zeros(nTargets,1);
missedDetectionsIndex = zeros(nTargets,1);


nFalsePositives = 0;
nMissedDetections = 0;
nCorrectDetections = 0;
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = true;


errorInPeriod = zeros(5000,1);
targetsWithNoTransits = zeros(5000,1);
errorCount = 0;
targetsWithNoTransitsCount = 0;
noGroundTruthIndex = zeros(5000,1);
noGrounTruthCounter = 0;

MIN_LIGHT_CURVE = 2; % if stellar variability is on, then set it to 2

nCadences = length(tpsInputStruct.cadenceTimes.midTimestamps);
cadencesPerDay = 1./median(diff(tpsInputStruct.cadenceTimes.midTimestamps));
xVector = (1:nCadences)'./cadencesPerDay;

% collect the rows and columns of the targets that host planets
isp = false(nTargets,1);
for kk = 1:nTargets,
    if(length(groundTruthStruct(kk).targetList.lightCurveList) > 1),
        isp(kk) = true;
    end
end
groundTruthTargetIndex = find(isp);
tlist = cat(1, groundTruthStruct(isp).targetList);

groundTruthRows = cat(1, tlist.row);
groundTruthCols  = cat(1, tlist.column);



for j = 1:nTargets

    keplerId = tpsResults(j).keplerId;

    idx = find(cat(1, groundTruthStruct.keplerId) == keplerId); % should be 3
    if(isempty(idx))
        %fprintf('no ground truth for keplerId %d [j = %d]\n', keplerId, j);
        noGrounTruthCounter = noGrounTruthCounter + 1;
        noGroundTruthIndex(noGrounTruthCounter) = j;
        continue;
    end

    indexForThisKepId = find(keplerIdsAll == keplerId);

    nPositiveDetections = sum(cat(1,tpsResults(indexForThisKepId).isPlanetACandidate));
    nLightCurves = length(groundTruthStruct(idx).targetList.lightCurveList);
    
    keplerMag = tpsInputStruct.tpsTargets(j).diagnostics.keplerMag;
    ccdModule = tpsInputStruct.tpsTargets(j).diagnostics.ccdModule;
    ccdOutput = tpsInputStruct.tpsTargets(j).diagnostics.ccdOutput;
    
    titleStr0 = (['Kepler id: ' num2str(keplerId) ' Module/Output = ' num2str(ccdModule) '/' num2str(ccdOutput) ' KeplerMag = ' num2str(keplerMag, '%6.2f')]);


    if((nLightCurves < MIN_LIGHT_CURVE)&& nPositiveDetections == 0)
        targetsWithNoTransitsCount = targetsWithNoTransitsCount +1;
        targetsWithNoTransits(targetsWithNoTransitsCount) = j;

        continue;
    elseif((nLightCurves < MIN_LIGHT_CURVE)&& nPositiveDetections > 0)
        nFalsePositives = nFalsePositives + 1;
        falsePositives(nFalsePositives) = keplerId;
        falsePositivesIndex(nFalsePositives) = j;
        fprintf('-----------------------------------------------------\n\n');
        fprintf('false positive %d/%d for %d, j = %d\n',  nFalsePositives, nTargets, keplerId, j);
        % locate the background target that hosts the TCE

        trow = groundTruthStruct(idx).targetList.row;
        tcol = groundTruthStruct(idx).targetList.column;

        % nearest target
        distMetric = sqrt((groundTruthRows - trow).^2 + (groundTruthCols - tcol).^2);

        [minDist, minIndex] = min(distMetric);

        fprintf('-----------------------------------------------------\n');
        figure; h1 = plot(xVector, groundTruthStruct(idx).targetList.compositeLightCurve - 1,'.-');
        hold on;
        if(minDist < 10) % 10pixels distance
            h2 = plot(xVector, groundTruthStruct(groundTruthTargetIndex(minIndex)).targetList.compositeLightCurve - 1,'g.-');

            indexIntoInputStruct = find(cat(1,tpsInputStruct.tpsTargets.keplerId) == keplerId);
            inputFluxTimeSeries = (tpsInputStruct.tpsTargets(indexIntoInputStruct).fluxValue);
            hold on; h3 = plot(xVector, (inputFluxTimeSeries./median(inputFluxTimeSeries) - 1 ), 'r.-');

            legend([h1 h2 h3], {'ETEM composite light curve';'ETEM overlap target light curve'; 'Input flux time series'});

        else

            indexIntoInputStruct = find(cat(1,tpsInputStruct.tpsTargets.keplerId) == keplerId);
            inputFluxTimeSeries = (tpsInputStruct.tpsTargets(indexIntoInputStruct).fluxValue);
            hold on; h2 = plot(xVector, (inputFluxTimeSeries./median(inputFluxTimeSeries) - 1 ), 'r.-');

            legend([h1 h2], {'ETEM composite light curve';'Input flux time series'});

        end

        if(groundTruthStruct(idx).hasBgBinary)
            hold on; h3 = plot(xVector, groundTruthStruct(idx).bgBinaryInfo.lightCurve - 1, 'g.-');
            legend([h1 h2 h3], {'ETEM composite light curve';'Input flux time series'; 'Bkgd eclipsing binary'});
        end
        xlabel('days');
        ylabel('relative flux');


        title(titleStr0);

        fileNameStr = ['false_positive_' num2str(keplerId)];
        plot_to_file(fileNameStr,paperOrientationFlag, includeTimeFlag, printJpgFlag);

        % plot multiple event statistic versus orbital periods tested
        pc = tpsResults(j).possiblePeriodsInCadences;
        fs = tpsResults(j).foldedStatisticAtTrialPeriods;
        figure; plot(pc*(6.51*270/60/tpsInputStruct.tpsModuleParameters.superResolutionFactor)/(60*24), fs, '.-')
        xlabel('possible periods in days');
        ylabel('MES \sigma')
        titleStr2 = sprintf('ETEM ground truth: orbital period in days  %10.4f\n',etemOrbitalPeriodInDays );

        title({'Multiple Event Statistics versus Period'; titleStr0; titleStr2});

        fileNameStr = ['false_positive_MES_' num2str(keplerId)];
        plot_to_file(fileNameStr,paperOrientationFlag, includeTimeFlag, printJpgFlag);
        close all;
        continue;

    elseif((nLightCurves >= MIN_LIGHT_CURVE)&& nPositiveDetections == 0)
        nMissedDetections = nMissedDetections + 1;
        missedDetections(nMissedDetections) = keplerId;
        missedDetectionsIndex(nMissedDetections) = j;

        fprintf('-----------------------------------------------------\n\n');
        fprintf('missed detection %d/%d for %d, j = %d\n',  nMissedDetections, nTargets, keplerId, j);

        transitDepth = max(abs(groundTruthStruct(idx).targetList.lightCurveList(MIN_LIGHT_CURVE).lightCurve - 1))*1e6;
        nTransits = length(groundTruthStruct(idx).targetList.lightCurveList(2).lightCurveData.transitTimesMks);

        maxMes = cat(1,tpsResults(indexForThisKepId).maxMultipleEventStatistic);
        [maxMaxMes, maxIndex] = max(maxMes);

        rmsCdpp = tpsResults(indexForThisKepId(maxIndex)).rmsCdpp;

        nTransitsNeededForTce = ((TCE_THRESHOLD * rmsCdpp)/transitDepth)^2;

        etemOrbitalPeriodInDays = groundTruthStruct(idx).targetList.lightCurveList(MIN_LIGHT_CURVE).lightCurveData.orbitalPeriodMks(1)/(3600*24);

        fprintf('transit depth in ppm %f\n',  transitDepth);
        fprintf('rms CDPP in ppm  depth %f\n',  rmsCdpp);

        fprintf('max. maxMultipleEventStatistic  %f\n',  maxMaxMes);
        fprintf('number of transits in the light curve %d\n',  nTransits);
        fprintf('number of transits required for a TCE %d\n',  round(nTransitsNeededForTce));

        fprintf('ETEM ground truth: orbital period in days  %10.4f\n',etemOrbitalPeriodInDays );
        titleStr2 = sprintf('ETEM ground truth: orbital period in days  %10.4f\n',etemOrbitalPeriodInDays );

        fprintf('-----------------------------------------------------\n');

        figure; h1 = plot(xVector, groundTruthStruct(idx).targetList.compositeLightCurve - 1,'.-');
        indexIntoInputStruct = find(cat(1,tpsInputStruct.tpsTargets.keplerId) == keplerId);
        inputFluxTimeSeries = (tpsInputStruct.tpsTargets(indexIntoInputStruct).fluxValue);
        hold on; h2 = plot(xVector, (inputFluxTimeSeries./median(inputFluxTimeSeries)  - 1), 'r.-');
        h3 = plot(xVector, groundTruthStruct(idx).targetList.lightCurveList(MIN_LIGHT_CURVE).lightCurve - 1,'.-y', 'linewidth',3);
        legend([h1 h2 h3], {'ETEM composite light curve'; 'Input flux time series'; 'transit signal'});
        xlabel('days');
        ylabel('relative flux');


        title(titleStr0);

        fileNameStr = ['missed_detections_' num2str(keplerId)];
        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);


        % plot multipple event statistic versus orbital periods tested
        pc = tpsResults(j).possiblePeriodsInCadences;
        fs = tpsResults(j).foldedStatisticAtTrialPeriods;
        figure; plot(pc*(6.51*270/60/tpsInputStruct.tpsModuleParameters.superResolutionFactor)/(60*24), fs, '.-')
        xlabel('possible periods in days');
        ylabel('MES \sigma')
        title({'Multiple Event Statistics versus Period'; titleStr0; titleStr2});

        fileNameStr = ['missed_detections_MES_' num2str(keplerId)];
        plot_to_file(fileNameStr,paperOrientationFlag, includeTimeFlag, printJpgFlag);

        close all;
        continue;
    elseif ((nLightCurves >= MIN_LIGHT_CURVE)&& nPositiveDetections > 0)

        % find that event that gave rise max maxMultipleEventStatistic

        timeVector = groundTruthStruct(idx).targetList.lightCurveList(MIN_LIGHT_CURVE).timeVector/(3600*24);

        lightCurve = groundTruthStruct(idx).targetList.lightCurveList(MIN_LIGHT_CURVE).lightCurve;

        plot(timeVector - timeVector(1)+1, lightCurve,'x-');
        xlabel('days');
        ylabel('relative flux');
        title(titleStr0);

        etemTimeToInitialTransitInDays =  groundTruthStruct(idx).targetList.lightCurveList(MIN_LIGHT_CURVE).lightCurveData.transitTimesMks(1)/(3600*24) ...
            - tpsInputStruct.cadenceTimes(1).midTimestamps(1) ;

        fprintf('-----------------------------------------------------\n\n');
        fprintf('TCE for Kepler Id %d \n',keplerId );


        maxMes = cat(1,tpsResults(indexForThisKepId).maxMultipleEventStatistic);

        [maxMaxMes, maxIndex] = max(maxMes);

        tpsComputedTimeToInitialTransitInDays = tpsResults(indexForThisKepId(maxIndex)).timeToFirstTransitInDays;

        tpsDetectedOrbitalPeriodInDays = tpsResults(indexForThisKepId(maxIndex)).detectedOrbitalPeriodInDays;


        etemOrbitalPeriodInDays = groundTruthStruct(idx).targetList.lightCurveList(MIN_LIGHT_CURVE).lightCurveData.orbitalPeriodMks(1)/(3600*24);

        if(length(groundTruthStruct(idx).targetList.lightCurveList) > MIN_LIGHT_CURVE)
            etemOrbitalPeriodInDays2 = groundTruthStruct(idx).targetList.lightCurveList(MIN_LIGHT_CURVE+1).lightCurveData.orbitalPeriodMks(1)/(3600*24);
            etemTimeToInitialTransitInDays2 = tpsInputStruct.cadenceTimes(1).midTimestamps(1) - groundTruthStruct(idx).targetList.lightCurveList(MIN_LIGHT_CURVE+1).lightCurveData.transitTimesMks(1)/(3600*24) ;

            errorInPeriod1 =  abs(etemOrbitalPeriodInDays*24*60 - tpsDetectedOrbitalPeriodInDays*24*60);
            errorInPeriod2 =  abs(etemOrbitalPeriodInDays2*24*60 - tpsDetectedOrbitalPeriodInDays*24*60);
            errorInPeriodTemp = min( errorInPeriod1, errorInPeriod2);
            if(errorInPeriodTemp == errorInPeriod2)
                etemOrbitalPeriodInDays = etemOrbitalPeriodInDays2;
                etemTimeToInitialTransitInDays = etemTimeToInitialTransitInDays2;
                fprintf('TPS computed orbital period in days %10.4f \n',tpsDetectedOrbitalPeriodInDays );
                fprintf('ETEM ground truth: orbital period in days  %10.4f\n',etemOrbitalPeriodInDays );
                fprintf('TPS computed time to initial transit in days %10.4f\n',tpsComputedTimeToInitialTransitInDays );
                fprintf('ETEM ground truth:  time to initial transit %10.4f\n', etemTimeToInitialTransitInDays);
            else
                fprintf('TPS computed orbital period in days %10.4f \n',tpsDetectedOrbitalPeriodInDays );
                fprintf('ETEM ground truth: orbital period in days  %10.4f\n',etemOrbitalPeriodInDays );
                fprintf('TPS computed time to initial transit in days %10.4f\n',tpsComputedTimeToInitialTransitInDays );
                fprintf('ETEM ground truth:  time to initial transit %10.4f\n', etemTimeToInitialTransitInDays);

            end
        else
            fprintf('TPS computed orbital period in days %10.4f \n',tpsDetectedOrbitalPeriodInDays );
            fprintf('ETEM ground truth: orbital period in days  %10.4f\n',etemOrbitalPeriodInDays );
            fprintf('TPS computed time to initial transit in days %10.4f\n',tpsComputedTimeToInitialTransitInDays );
            fprintf('ETEM ground truth: time to initial transit %10.4f\n', etemTimeToInitialTransitInDays);

        end

        errorCount = errorCount + 1;

        errorInPeriod(errorCount) = etemOrbitalPeriodInDays*24*60 - tpsDetectedOrbitalPeriodInDays*24*60;
        fprintf('error in period in minutes =  %10.4f\n',errorInPeriod(errorCount));

        nCorrectDetections = nCorrectDetections+1;
        correctDetections(nCorrectDetections) = keplerId;
        correctDetectionsIndex(nCorrectDetections) = j;

    else
        fprintf('how did this condition occur??\n');
        continue;
    end


    figure; h1 = plot(xVector, groundTruthStruct(idx).targetList.compositeLightCurve - 1,'.-');
    indexIntoInputStruct = find(cat(1,tpsInputStruct.tpsTargets.keplerId) == keplerId);
    inputFluxTimeSeries = (tpsInputStruct.tpsTargets(indexIntoInputStruct).fluxValue);
    hold on; h2 = plot(xVector, (inputFluxTimeSeries./median(inputFluxTimeSeries) - 1 ), 'r.-');
    xlabel('days');
    ylabel('relative flux');
    title(titleStr0);

    legend([h1 h2], {'ETEM composite light curve'; 'Input flux time series'});


    fileNameStr = ['correct_detection_' num2str(keplerId)];
    plot_to_file(fileNameStr,paperOrientationFlag, includeTimeFlag, printJpgFlag);

    % plot multipple event statistic versus orbital periods tested
    pc = tpsResults(j).possiblePeriodsInCadences;
    fs = tpsResults(j).foldedStatisticAtTrialPeriods;
    figure; plot(pc*(6.51*270/60/tpsInputStruct.tpsModuleParameters.superResolutionFactor)/(60*24), fs, '.-')
    xlabel('possible periods in days');
    ylabel('MES \sigma')
    titleStr2 = sprintf('ETEM ground truth: orbital period in days  %10.4f\n',etemOrbitalPeriodInDays );

    title({'Multiple Event Statistics versus Period'; titleStr0; titleStr2});

    fileNameStr = ['correct_detection_MES_' num2str(keplerId)];
    plot_to_file(fileNameStr,paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;

end

errorInPeriod = errorInPeriod(1:errorCount);
targetsWithNoTransits = targetsWithNoTransits(1:targetsWithNoTransitsCount);
noGroundTruthIndex = noGroundTruthIndex(1:noGrounTruthCounter);


% contain keplerIds
correctDetections(nCorrectDetections+1:end) = [];
falsePositives(nFalsePositives+1:end) = [];
missedDetections(nMissedDetections+1:end) = [];

correctDetectionsIndex(nCorrectDetections+1:end) = [];
falsePositivesIndex(nFalsePositives+1:end) = [];
missedDetectionsIndex(nMissedDetections+1:end) = [];


validationSummaryStruct.errorInPeriod = errorInPeriod;
validationSummaryStruct.targetsWithNoTransits = targetsWithNoTransits;
validationSummaryStruct.noGroundTruthIndex = noGroundTruthIndex;
validationSummaryStruct.correctDetections = correctDetections;
validationSummaryStruct.falsePositives = falsePositives;
validationSummaryStruct.missedDetections = missedDetections;
validationSummaryStruct.correctDetectionsIndex = correctDetectionsIndex;
validationSummaryStruct.falsePositivesIndex = falsePositivesIndex;
validationSummaryStruct.missedDetectionsIndex = missedDetectionsIndex;

save validationSummaryStruct.mat validationSummaryStruct
diary off

return





