
function tps_construct_transit_detection_plots(tpsResults, tpsModuleParameters,possiblePeriodsInCadences)


% plot to file parameters
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
isLandscapeOrientationFlag = true;
includeTimeFlag = false;
printJpgFlag = false;


transitPulseDurationInHours = tpsResults.trialTransitPulseInHours;
cadencesPerDay = tpsModuleParameters.cadencesPerDay;
nCadences = length(tpsResults.correlationTimeSeries);



bestPhaseInCadences = tpsResults.bestPhaseInCadences;
keplerId = tpsResults.keplerId;
bestMultipleEventStatistic = tpsResults.maxMultipleEventStatistic;
bestOrbitalPeriodInDays = tpsResults.detectedOrbitalPeriodInDays;
bestPhaseInDays = tpsResults.timeToFirstTransitInDays;

foldedStatisticAtTrialPhases = tpsResults.foldedStatisticAtTrialPhases;
foldedStatisticAtTrialPeriods = tpsResults.foldedStatisticAtTrialPeriods;
phaseLagInCadences = tpsResults.phaseLagInCadences;

searchTransitThreshold = tpsModuleParameters.searchTransitThreshold;
correlationTimeSeries = tpsResults.correlationTimeSeries;
normalizationTimeSeries = tpsResults.normalizationTimeSeries;

minSearchPeriodInCadences = tpsModuleParameters.minimumSearchPeriodInDays * cadencesPerDay;


timeIndays = (0:nCadences-1)'/cadencesPerDay;

fontName = 'Coperplate Gothic Bold';
plotFontSize = 7;
gcaFontSize = 7;
axisColor = 'black';
textColor = [.5,.4,.8]*.5;

%--------------------------------------------------------------------------
% Single Event Statistics time series
%--------------------------------------------------------------------------
figure;
plot(timeIndays, correlationTimeSeries./normalizationTimeSeries,'b')

xlim(timeIndays([1,end]));

xlabel('Time, Days','fontsize',plotFontSize,'color',axisColor);
ylabel('Single Event Statistics, \sigma','fontsize',plotFontSize,'color',axisColor);

str1 = sprintf('Orbital period of planet %5.2f days Time to first transit %5.2f days', bestOrbitalPeriodInDays, bestPhaseInDays);
str2 = ['kepler Id ' num2str(keplerId)];

title({str1; str2},'fontsize',plotFontSize); % 2 line title
set(gca, 'fontsize', gcaFontSize);
% print to file


titleStr = ['KeplerId ' strtrim(num2str(keplerId, '%10d')) ' SES ' ...
    ' Period ' strtrim(num2str(bestOrbitalPeriodInDays, '%5.2f')) ...
    ' Phase ' strtrim(num2str(bestPhaseInDays, '%5.2f'))...
    ' Trial Transit Hours ' strtrim(num2str(transitPulseDurationInHours, '%2d')) ];

plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

%--------------------------------------------------------------------------
% Total Detection Statistics
%--------------------------------------------------------------------------
figure;

periodRangeInDays = possiblePeriodsInCadences/cadencesPerDay;
nPeriodsInRange = length(periodRangeInDays);
plot(periodRangeInDays, foldedStatisticAtTrialPeriods,'b')
xlim([minSearchPeriodInCadences,nCadences]./cadencesPerDay);


if bestMultipleEventStatistic > searchTransitThreshold   % explain 7 - the detection threshold
    if bestOrbitalPeriodInDays > periodRangeInDays(round(nPeriodsInRange/2))
        horiz = 'right';
        msgtext = 'PLANET FOUND! \rightarrow';
    else
        horiz = 'left';
        msgtext = '\leftarrow PLANET FOUND!';
    end
    line(bestOrbitalPeriodInDays, bestMultipleEventStatistic,'marker','o','color','k','markersize',7,'color','blue')
    text(bestOrbitalPeriodInDays, bestMultipleEventStatistic,msgtext,'fontsize',plotFontSize,...
        'color',textColor,'fontname',fontName,'horiz',horiz)
else
    text(periodRangeInDays(round(end/2)),bestMultipleEventStatistic,'SORRY, NO PLANET FOUND.',...
        'fontsize',plotFontSize,'color',textColor, 'fontname',fontName,'horiz','center')
end

xlabel('Period, Days','fontsize',plotFontSize,'color',axisColor)
ylabel('Total Detection Statistics, \sigma','fontsize',plotFontSize,'color',axisColor)


% zoom in on max statistics location and capture plot

str1 = sprintf('Orbital period of planet %5.2f days ', bestOrbitalPeriodInDays);
str2 = ['kepler Id ' num2str(keplerId)];

title({str1;str2},'fontsize',plotFontSize); % 2 line title
xlabel('Time, Days','fontsize',plotFontSize,'color',axisColor)
ylabel('Total Detection Statistics, \sigma','fontsize',plotFontSize,'color',axisColor)
set(gca, 'fontsize', gcaFontSize);

% print to file
% save the plot to a file in jpeg format with 200 dpi resolution


titleStr = ['KeplerId ' strtrim(num2str(keplerId, '%10d')) ' Total Det Stat '  strtrim(num2str(bestMultipleEventStatistic, '%8.2f'))...
    ' Period ' strtrim(num2str(bestOrbitalPeriodInDays, '%5.2f')), ' Phase ' strtrim(num2str(bestPhaseInDays, '%5.2f'))...
    ' Trial Transit Hours ' strtrim(num2str(transitPulseDurationInHours, '%2d')) ];


plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);



%--------------------------------------------------------------------------
% Stats vs Time to first Transit
%--------------------------------------------------------------------------
figure;

nPhaseLags = length(foldedStatisticAtTrialPhases);
plot(phaseLagInCadences./cadencesPerDay, foldedStatisticAtTrialPhases,'b')
xlim([phaseLagInCadences(1),phaseLagInCadences(end)]./cadencesPerDay);

set(gca,'tag','gameaxes');
xlabel('Time to First Transit, Days','fontsize',plotFontSize)
ylabel('Folded Detection Statistic, \sigma','fontsize',plotFontSize)
title('Statistics for Most Significant Candidate','fontsize',plotFontSize,'color',axisColor)


if (bestMultipleEventStatistic > searchTransitThreshold)
    line(bestPhaseInCadences./cadencesPerDay, bestMultipleEventStatistic, 'marker','o','color','k','markersize',8,'color','blue')
    if (bestPhaseInCadences > phaseLagInCadences(round(nPhaseLags/2)))
        horiz = 'right';
        msgtext = 'PLANET FOUND! \rightarrow';
        text(timeIndays(max(round(bestPhaseInCadences)-2,1)), bestMultipleEventStatistic, msgtext,'fontsize',plotFontSize,...
            'color',textColor, 'fontname',fontName,'horiz',horiz)
    else
        horiz = 'left';
        msgtext = '\leftarrow PLANET FOUND!';
        text(timeIndays(round(bestPhaseInCadences+0.5)), bestMultipleEventStatistic, msgtext,'fontsize',plotFontSize,...
            'color',textColor, 'fontname',fontName,'horiz',horiz)
    end
else
    text(timeIndays(fix(nPhaseLags/2)),bestMultipleEventStatistic,'SORRY, NO PLANET FOUND.','fontsize',plotFontSize,...
        'color',textColor, 'fontname',fontName,'horiz','center')
end



str1 = sprintf('First Transit occurring in %5.2f days ', bestPhaseInDays);
str2 = ['kepler Id ' num2str(keplerId)];

title({str1; str2},'fontsize',plotFontSize); % 2 line title
xlabel('Time, Days','fontsize',plotFontSize,'color',axisColor)
ylabel('Total Detection Statistics, \sigma','fontsize',plotFontSize,'color',axisColor)
set(gca, 'fontsize', gcaFontSize);

% print to file
% save the plot to a file in jpg format with 200 dpi resolution




titleStr = ['KeplerId ' strtrim(num2str(keplerId, '%10d'))  ' Total Det Stat '   ' Phase ' strtrim(num2str(bestPhaseInDays, '%5.2f'))...
    ' Period ' strtrim(num2str(bestOrbitalPeriodInDays, '%5.2f')), ...
    ' Trial Transit Hours ' strtrim(num2str(transitPulseDurationInHours, '%2d')) ];


plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);


return