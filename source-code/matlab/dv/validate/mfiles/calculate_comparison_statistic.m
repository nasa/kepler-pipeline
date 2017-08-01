function [dvResultsStruct] = calculate_comparison_statistic(dataStruct, dvResultsStruct, iTarget, jPlanet, dataTypeString, debugLevel, planetNumber)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = calculate_comparison_statistic(dataStruct, dvResultsStruct, iTarget, jPlanet, dataTypeString, debugLevel, planetNumber)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Calculate statistic value and significance level under null hypothesis that all values in the input data structure are equal (chi-square test).
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Set default value of planetNumber
if (~exist('planetNumber','var'))
    planetNumber = 0;
end
    
% Set default statistic value and default significance level
comparisonStatistic.value        = 0;
comparisonStatistic.significance = -1;

% Retrieve data values and uncertainties from dataStruct
dataValue       = [dataStruct.value];
dataUncertainty = [dataStruct.uncertainty]; 
nDataPoints     = length(dataValue);

% Get keplerId and figure root directory of the given target.
keplerId               = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
dvFiguresRootDirectory = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;

% Generate warning message if the lengths of values and uncertainties do not agree
if ( length(dataValue)~=length(dataUncertainty) )
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'calculateComparisonStatistic', 'warning', ...
        ['Dimensions of ' dataTypeString ' values and uncertainties do not agree'], iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

% Get rid of the invalid data in dataValueCleaned and dataUncertaintyCleaned
gapIndicator           = (dataUncertainty<=0);
dataValueCleaned       = dataValue(~gapIndicator);
dataUncertaintyCleaned = dataUncertainty(~gapIndicator);

% Set NaNs to gapped values and uncertainties in dataValuePlot and dataUncertaintyPlot (NaNs are not displayed in the plot)
dataValuePlot                     = dataValue;
dataUncertaintyPlot               = dataUncertainty;
dataValuePlot(gapIndicator)       = NaN;
dataUncertaintyPlot(gapIndicator) = NaN;


% Get title string and figure file name from dataTypeString
dataTypeStringMatched = true;
switch (dataTypeString)
    case 'oddEvenTransitDepth'
        titleStr       = {['Comparison of Planet ' num2str(jPlanet)];
            'Odd and Even Transit Depths'};
        yLabelStr      = 'Transit Depth (ppm)';
%        figureFilename = 'odd_even_transit_depths.fig';
        figureFilename = [num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-odd-even-transit-depths.fig'] ;
        userDataStr    = ['Diagnostic plot of Odd/Even Transit Depth Test for keplerId ' num2str(keplerId) ', planet ' num2str(jPlanet) '. ' ...
                          'A significance level close to 1/0 favors a transiting planet/an eclipsing binary.'];
    case 'oddEvenTransitEpoch'
        titleStr       = {['Comparison of Planet ' num2str(jPlanet)];
            'Odd and Even Transit Epochs'};
        yLabelStr      = 'Transit Period (days)';
%        figureFilename = 'odd_even_transit_epochs.fig';
        figureFilename = [num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-odd-even-transit-epochs.fig'] ;
        userDataStr    = ['Diagnostic plot of Odd/Even Transit Epoch Test for keplerId ' num2str(keplerId) ', planet ' num2str(jPlanet) '. ' ...
                          'A significance level close to 1/0 favors a transiting planet/an eclipsing binary.'];
    case 'singleTransitDepth'
        titleStr       = {['Comparison of Planet ' num2str(jPlanet)];
            'Single Transit Depths'};
        yLabelStr      = 'Transit Depth (ppm)';
%        figureFilename = 'single_transit_depths.fig';
        figureFilename = [num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-single-transit-depths.fig'] ;
        userDataStr    = '';
    case 'singleTransitEpoch'
        titleStr       = {['Comparison of Planet ' num2str(jPlanet)];
            'Single Transit Epochs'};
        yLabelStr      = 'Transit Period (days)';
%        figureFilename = 'single_transit_epochs.fig';
        figureFilename = [num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-single-transit-epochs.fig'] ;
        userDataStr    = '';
    case 'singleTransitDuration'
        titleStr       = {['Comparison of Planet ' num2str(jPlanet)];
            'Single Transit Durations'};
        yLabelStr      = 'Transit Duration (hours)';
%        figureFilename = 'single_transit_durations.fig';
        figureFilename = [num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-single-transit-durations.fig'] ;
        userDataStr    = '';
    case 'shorterPeriod'
        titleStr       = {['Comparison of Periods of Planet ' num2str(jPlanet)];
            'and One with Shorter Period'};
        yLabelStr      = 'Transit Period (days)';
%        figureFilename = 'planet_and_one_with_shorter_period.fig';
        figureFilename = [num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-planet-and-one-with-shorter-period.fig'] ;
        userDataStr    = ['Diagnostic plot of Orbital Period Test for keplerId ' num2str(keplerId) '. ' ...
                          'Orbital periods of planet ' num2str(jPlanet) ' and the planet with shorter period are compared. ' ...
                          'A significance level close to 1/0 favors a transiting planet/an eclipsing binary.'];
    case 'longerPeriod'
        titleStr       = {['Comparison of Periods of Planet ' num2str(jPlanet)];
            'and One with Longer Period'};
        yLabelStr      = 'Transit Period (days)';
%        figureFilename = 'planet_and_one_with_longer_period.fig';
        figureFilename = [num2str(keplerId, '%09d'), '-', num2str(jPlanet, '%02d'), '-planet-and-one-with-longer-period.fig'] ;
        userDataStr    = ['Diagnostic plot of Orbital Period Test for keplerId ' num2str(keplerId) '. ' ...
                          'Orbital periods of planet ' num2str(jPlanet) ' and the planet with longer period are compared. ' ...
                          'A significance level close to 1/0 favors a transiting planet/an eclipsing binary.'];
    otherwise
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'calculateComparisonStatistic', 'warning', ...
            ['No matched data type string for the input ' dataTypeString], iTarget, keplerId, jPlanet);
        disp(dvResultsStruct.alerts(end).message);
        dataTypeStringMatched = false;
end

% Generate warning message when number of valid is less than 2
nValidData = length(dataValueCleaned);
if nValidData < 2
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'calculateComparisonStatistic', 'warning', ...
        ['Number of valid  ' dataTypeString ' data is less than 2'], iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

% Determine statistic value and significance level only when there are more than 1 valid data
if (nValidData>1 && dataTypeStringMatched)

    % Determine weighted mean value and the uncertainty, where the weights are inversed squared uncertainties
    weight = 1./dataUncertaintyCleaned.^2;
    weightedMean            = sum( weight.*dataValueCleaned)/sum(weight);
    weightedMeanUncertainty = 1/sqrt( sum(weight) );
    
    % Statistic value and significance level are determined under null hypothesis that all values in the data structure are equal
    % (chi-square test, where the degree of freedom is the number of valid data minus 1)
    comparisonStatistic.value        = sum( weight.*(dataValueCleaned-weightedMean).^2 );
    comparisonStatistic.significance = 1 - chi2cdf(comparisonStatistic.value, nValidData-1); 

    % In shorter/longer orbital period test, change the significance level in the output structure to (1-significanceLevel) 
    % so that a significance level close to 0 favors an eclipsing binary
    if strcmp(dataTypeString, 'shorterPeriod') || strcmp(dataTypeString, 'longerPeriod')
        comparisonStatistic.significance = 1 - comparisonStatistic.significance;
    end
    
    % Plot data values and uncertainties
        
    hFig = figure;
    
    % Plot the gapped data values and uncertainties where NaNs do not display
    errorbar(dataValuePlot, dataUncertaintyPlot, 'b*');
    grid;

    title([titleStr; ['(statistic: ' num2str(comparisonStatistic.value, '%1.4f') ...
        ' significance: ' num2str(comparisonStatistic.significance, '%1.4f') ')']]);
    ylabel(yLabelStr);
    set(gca, 'xtick', 1:nDataPoints);
    if ( findstr(dataTypeString, 'singleTransitEpoch') )
        xlabel('Indices of Valid Epoch Pairs (Last one is transit period)');
    elseif ( findstr(dataTypeString, 'singleTransit') )
        xlabel('Transit Index');
    elseif ( findstr(dataTypeString, 'shorterPeriod') )
        set(gca, 'xticklabel', {['Planet ' num2str(jPlanet)], 'Planet with Shorter Period'});
    elseif ( findstr(dataTypeString, 'longerPeriod') )
        set(gca, 'xticklabel', {['Planet ' num2str(jPlanet)], 'Planet with Longer Period'});
    elseif ( findstr(dataTypeString, 'oddEvenTransitEpoch') )
        set(gca, 'xticklabel', {'Difference of Odd/Even Epochs', 'Mean of Odd/Even Periods'});
    else
        set(gca, 'xticklabel', {'Odd Transit', 'Even Transit'});
    end
    
    hold on;
    dataIndex = 1:nDataPoints;
    onesVec   = ones(size(dataIndex));
    plot(dataIndex, weightedMean*onesVec, 'r.-');
    plot(dataIndex, (weightedMean+weightedMeanUncertainty)*onesVec, 'r--');
    plot(dataIndex, (weightedMean-weightedMeanUncertainty)*onesVec, 'r--');
    hold off;

    format_graphics_for_dv_report(hFig);

    % Set plot caption for the DV report
    set(hFig, 'UserData', userDataStr);
    
    % Save figure to file
    saveas(hFig, fullfile(dvFiguresRootDirectory, ['planet-' num2str(jPlanet, '%02d')], 'binary-discrimination-test-results', figureFilename), 'fig');

    % close figure
    if (debugLevel==0)
        close(hFig);
    else
        drawnow;
    end

end

% Update corresponding field in dvResultsStruct of the given target and planet based on dataTypeString
switch (dataTypeString)
    case 'oddEvenTransitDepth'
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).binaryDiscriminationResults.oddEvenTransitDepthComparisonStatistic        = ...
            comparisonStatistic;
    case 'oddEvenTransitEpoch'
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).binaryDiscriminationResults.oddEvenTransitEpochComparisonStatistic        = ...
            comparisonStatistic;
    case 'singleTransitDepth'
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).binaryDiscriminationResults.singleTransitDepthComparisonStatistic         = ...
            comparisonStatistic;
    case 'singleTransitEpoch'
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).binaryDiscriminationResults.singleTransitEpochComparisonStatistic         = ...
            comparisonStatistic;
    case 'singleTransitDuration'
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).binaryDiscriminationResults.singleTransitDurationComparisonStatistic      = ...
            comparisonStatistic;
    case 'shorterPeriod'
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).binaryDiscriminationResults.shorterPeriodComparisonStatistic              = ...
            comparisonStatistic;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).binaryDiscriminationResults.shorterPeriodComparisonStatistic.planetNumber = ...
            planetNumber;
    case 'longerPeriod'
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).binaryDiscriminationResults.longerPeriodComparisonStatistic               = ...
            comparisonStatistic;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).binaryDiscriminationResults.longerPeriodComparisonStatistic.planetNumber  = ...
            planetNumber;
    otherwise
        return;
end

return
