function dvResultsStruct = generate_weak_secondary_plots( dvDataObject, dvResultsStruct, ...
    thresholdCrossingEvent, iTarget, iPlanet )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function generate_weak_secondary_plots( dvDataObject, dvResultsStruct, ...
%    thresholdCrossingEvent, iTarget, iPlanet )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create figure displaying the MES vs. Phase for the weak secondary for the
% given planet candidate. The way the phase is wrapped gets changed so the
% values in the weakSecondaryStruct must also be updated in the results.
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

% Set constants.
DATA_MARKER_SIZE = 6.0;
EXTREMA_MARKER_SIZE = 6.0;

% Get required fields.
binsPerTransit = ...
    dvDataObject.planetFitConfigurationStruct.reportSummaryBinsPerTransit;
weakSecondaryStruct = thresholdCrossingEvent.weakSecondaryStruct;
planetResultsStruct = ...
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
transitDurationHours = thresholdCrossingEvent.trialTransitPulseDuration;
orbitalPeriodDays = planetResultsStruct.planetCandidate.orbitalPeriod;
keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;

% Get the MES and phase vectors along with the peak information.
% Set the MES = 0 values to NaN.
mesValues = weakSecondaryStruct.mes;
phaseDays = weakSecondaryStruct.phaseInDays;

mesValues(mesValues == 0) = NaN;

% Perform the binning and averaging.
[binnedPhaseDays, binnedMesValues] = ...
    bin_and_average_time_series_by_cadence_time( ...
    phaseDays, mesValues, 0, ...
    transitDurationHours / get_unit_conversion('day2hour') / binsPerTransit, ...
    isnan(mesValues));

% Shift x-axis so we go from -T/4 -> 3/4T.
isWrap = phaseDays < -orbitalPeriodDays / 4;
phaseDays(isWrap) = phaseDays(isWrap) + orbitalPeriodDays;
isWrap = binnedPhaseDays < -orbitalPeriodDays / 4;
binnedPhaseDays(isWrap) = binnedPhaseDays(isWrap) + orbitalPeriodDays;

[phaseDays, ix] = sort(phaseDays);
mesValues = mesValues(ix);

% Update the output so the values for the weak secondary reflect what is in
% the plot.
maxMesPhaseInDays = weakSecondaryStruct.maxMesPhaseInDays ;
minMesPhaseInDays = weakSecondaryStruct.minMesPhaseInDays ;
if (maxMesPhaseInDays < -orbitalPeriodDays / 4)
    maxMesPhaseInDays = maxMesPhaseInDays + orbitalPeriodDays ;
    planetResultsStruct.planetCandidate.weakSecondaryStruct.maxMesPhaseInDays = maxMesPhaseInDays;
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = planetResultsStruct ;
end
if (minMesPhaseInDays < -orbitalPeriodDays / 4)
    minMesPhaseInDays = minMesPhaseInDays + orbitalPeriodDays ;
    planetResultsStruct.planetCandidate.weakSecondaryStruct.minMesPhaseInDays = minMesPhaseInDays;
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = planetResultsStruct ;
end

% Construct the figure.
figure

plot(phaseDays, mesValues, '.-k', 'MarkerSize', DATA_MARKER_SIZE);
hold on
plot(binnedPhaseDays, binnedMesValues, 'ob', ...
    'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'cyan', ...
    'MarkerSize', DATA_MARKER_SIZE);
plot(maxMesPhaseInDays,weakSecondaryStruct.maxMes, 'pr', ...
    'MarkerSize', EXTREMA_MARKER_SIZE );
plot(minMesPhaseInDays,weakSecondaryStruct.minMes, 'pr', ...
    'MarkerSize', EXTREMA_MARKER_SIZE );

% Add title and labels.
string = sprintf('Planet %d : Secondary MES vs. Phase', iPlanet);
title(string);
xlabel('Phase [Days]');
ylabel('MES [\sigma]');

format_graphics_for_dv_report(gcf);

% Save the figure.
planetDir = sprintf('planet-%02d', iPlanet);

if isfield(dvResultsStruct.targetResultsStruct(iTarget), 'dvFiguresRootDirectory')
    dvFiguresRootDirectory = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
else
    dvFiguresRootDirectory = sprintf('target-%09d', targetStruct(iTarget).keplerId);
end % if / else

if ~exist(fullfile(dvFiguresRootDirectory, planetDir, 'report-summary'), 'dir')
            mkdir(fullfile(dvFiguresRootDirectory, planetDir, 'report-summary'));
end

userDataStr = ['The primary event has been set to zero and both the max and min of the resulting MES vs. Phase are marked with a red star.  '];
userDataStr = [userDataStr 'The best matched pulse duration in hours is ' num2str(transitDurationHours) '. '];
userDataStr = [userDataStr 'The maximum secondary MES and corresponding phase are ' num2str(weakSecondaryStruct.maxMes) ...
    ' and ' num2str(maxMesPhaseInDays) ' days respectively. '];
userDataStr = [userDataStr 'The minimum secondary MES and corresponding phase are ' num2str(weakSecondaryStruct.minMes) ...
    ' and ' num2str(minMesPhaseInDays) ' days respectively.'];

set(gcf, 'UserData', userDataStr);

figureName = fullfile(dvFiguresRootDirectory, planetDir, ...
    'report-summary', ...
    sprintf('%09d-%02d-weak-secondary-diagnostic.fig', ...
    keplerId, iPlanet));

saveas(gcf, figureName, 'fig');

% Close the figure.
close(gcf);

return