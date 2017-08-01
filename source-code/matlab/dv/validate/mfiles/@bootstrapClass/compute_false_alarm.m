function [bootstrapResultsStruct dvResultsStruct] = ...
    compute_false_alarm(bootstrapObject, bootstrapResultsStruct, dvResultsStruct, doFigure)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [bootstrapResultsStruct dvResultsStruct] = ...
%    compute_false_alarm(bootstrapObject, bootstrapResultsStruct, dvResultsStruct, doFigure)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Adds the histograms from the different trial transit pulse durations, 
% normalizes them by the number of events and calculates the false alarm
% rate (probabilities) and significance at the maxMultipleEventStatistics 
% from TPS.
%
% When there are >= 2 bins in the histogram, a log10 of the linear fit is
% performed on the ccdf.  If maxMultipleEventStatistics lies within this
% range, then an interpolation is done to obtain the significance.  If the
% maxMultipleEventStatistics lies outside of this range, an extrapolation
% is done.
%
% In the case where there is only 1 bin in the histogram,
% maxMultipleEventSigma is checked to see if it lies within a bin, if so,
% the significance reported is the ccdf of this bin.  If it is outside of
% the bin, a Gaussian curve is used to extrapolate for the significance of
% the maxMultipleEventSigma.
%
% If doFigure is true, plots are generated.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:
%
%   bootstrapObject: [struct]  Contains all the information 
%                              required to bootstrap (build histogram).
% 
%         doFigure: [logical]  If true, for plots.
%
%  dvResultsStruct: [ struct]  Contains the maxMultipleEventStatistics from 
%                              TPS
%
%
% bootstrapResultsStruct: [struct]  Has the following fields-
%
%          statistics:   [float array]  In sigma, or the x axis for the
%                                       histograms.
%       probabilities:   [float array]  False alarm values for the 
%                                       associated statistics.                                                        
%        significance:         [float]  False alarm rate for the search
%                                       transit threshold.
%      histogramStruct:       [struct]  Contains the following the fields:
%                                       
%            trialTransitPulseDuration: [float]   Indicates whether the
%                                                   histogram counts are 
%                                                   coming from a 3, 6, 12,
%                                                   etc hour pulse.
%                        probabilities: [float]   probabilities generated after 
%                                                   bootstrapping.
%                         isHistSmooth: [logical]   If the histogram is 
%                                                   gaussian shaped.   
%                       finalSkipCount: [int]  final skip count for each
%                                              pulse.
%                   iterationsEstimate: [float]  estimate numIterations
%                     iterationsActual: [float] actual numIterations
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUTS:
%
%           bootstrapResultsStruct gets populated.
%           dvResultsStruct are populated with alerts, if triggered.
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

if nargin < 3
    doFigure = true;
end

% Get data from boostrapObject
searchTransitThreshold = bootstrapObject.searchTransitThreshold;
histogramBinWidth = bootstrapResultsStruct.histogramBinWidth;
targetNumber = bootstrapObject.targetNumber;
planetNumber = bootstrapObject.planetNumber;

% Get max MES from dvResultsStruct (coming from TPS)
maxMultipleEventSigma = dvResultsStruct.targetResultsStruct(targetNumber).planetResultsStruct(planetNumber).planetCandidate.maxMultipleEventSigma;

% compute the false alarm probability
[x, y, ~, indx] = compute_cumulative_probability( bootstrapObject, bootstrapResultsStruct );

% if there are no points above threshold then just keep everything
if isempty(indx)
    indx = 1;
end
       
[fit, gaussModel, thresholdForDesiredPfa, significanceTpsMes, ~, interpPlotFlag] = ...
    fit_bootstrap_cdf( x, y, searchTransitThreshold, maxMultipleEventSigma );

% Place significance in output structure
bootstrapResultsStruct.significance = significanceTpsMes;
bootstrapResultsStruct.bootstrapThresholdForDesiredPfa = thresholdForDesiredPfa;
bootstrapResultsStruct.bootstrapMesMean = gaussModel(1);
bootstrapResultsStruct.bootstrapMesStd = gaussModel(2);

if doFigure
    
    % no need to plot zeros
    endIndex = find(y > 0,1,'last');
    x = x(1:endIndex);
    y = y(1:endIndex);
    fit = fit(1:endIndex);
    if indx > length(x)
        if any(y < 1)
            indx = find(y < 1, 1, 'first');
        else
            indx = 1;
        end
    end
    
    bsFig_h= figure;
    target_h = semilogy(x, y, '-bo');
    hold on
    complNormCdf = 0.5*erfc((x - histogramBinWidth/2)./sqrt(2));  % bins mark centers, so need shift
    gaussian_h =semilogy(x, complNormCdf, '--rx');

    if interpPlotFlag

        significance_h = semilogy(maxMultipleEventSigma, significanceTpsMes, 'gp');
        set(significance_h, 'markersize', 20)
        legend([target_h; gaussian_h; significance_h], ...
            'Planet Candidate', 'Standard Normal Distribution', 'Significance',...
            'location', 'SouthWest')
        xMax = x(end) + histogramBinWidth;
        xMin = x(indx) - histogramBinWidth;
        set(gca, 'xlim', [xMin, xMax]);

    else 

        if maxMultipleEventSigma <= x(end) + 3*histogramBinWidth

            fit_h = semilogy([x; maxMultipleEventSigma], [fit; significanceTpsMes], 'm-.');
            significance_h = semilogy(maxMultipleEventSigma, significanceTpsMes, 'gp');          
            set(significance_h, 'markersize', 20)
            legend([target_h; fit_h; gaussian_h; significance_h], ...
                'Planet Candidate',  'Planet Candidate, Gaussian Fit', ...
                'Standard Normal Distribution', 'Significance', ...
                'location', 'SouthWest')
            xMax = maxMultipleEventSigma + histogramBinWidth;
            xMin = x(indx) - histogramBinWidth;
            set(gca, 'xlim', [xMin, xMax]);

        else

            fit_h = semilogy(x, fit, 'm-.');
            xPos = x(end) + 2*histogramBinWidth;

            if significanceTpsMes > 0.1*y(end)
                significance_h = semilogy(xPos, significanceTpsMes, 'gp');
                arrow_h = text(xPos+0.5*histogramBinWidth, significanceTpsMes, '\rightarrow');

            else
                significance_h = semilogy(xPos, 0.1*y(end), 'gp');
                arrow_h = text(xPos+0.5*histogramBinWidth, 0.1*y(end), '\rightarrow');        
            end

            set(significance_h, 'markersize', 20)      
            set(arrow_h, 'fontsize', 40, 'color', 'g')
            legend([target_h; fit_h; gaussian_h; significance_h], ...
                'Planet Candidate',  'Planet Candidate, Gaussian Fit', ...
                'Standard Normal Distribution', 'Significance', ...
                'location', 'SouthWest')
            xMax = xPos + 1*histogramBinWidth;
            xMin = x(indx) - histogramBinWidth;
            set(gca, 'xlim', [xMin, xMax]);


        end   

    end
    
    title(sprintf('Bootstrap Results for Planet %d\n Max Multiple Event Sigma=%1.1f, False Alarm=%1.2e', ...
         bootstrapObject.planetNumber, maxMultipleEventSigma, significanceTpsMes))
    
    xlabel('Detection Statistic, \sigma')
    ylabel('False Alarm Rate')
    grid on
    
    gaussianEquivalent = sqrt(2) * erfcinv( 2 * significanceTpsMes );
    % Set caption
    captionString = ['Bootstrap results for target ', num2str(bootstrapObject.keplerId), ', planet ', num2str(planetNumber), ...
        '.  Cumulative sum of the probabilities', ...
        ' (derived from the histogram of counts) from upper tail to the search transit threshold;', ...
        ' false alarm probability is indicated by the star.  The Gaussian equivalent threshold for this', ...
        ' false alarm probability is ', num2str(gaussianEquivalent) '.' , ...
        ' The threshold on this distribution that achieves the same false alarm rate as a ' num2str(searchTransitThreshold), ...
        ' sigma threshold on a Gaussian distribution is ', num2str(thresholdForDesiredPfa) '.'];
    
    set(bsFig_h, 'userData', captionString)

    % Format figure for report standards
    format_graphics_for_dv_report(bsFig_h);
    set(gca, 'yminorgrid', 'off')
    
    bootstrapFigureName = fullfile(bootstrapObject.dvFiguresRootDirectory, ...
        sprintf('planet-%02d', bootstrapObject.planetNumber), ...
        'bootstrap-results', ...
        sprintf('%09d-%02d-bootstrap-false-alarm.fig', ...
        bootstrapObject.keplerId, bootstrapObject.planetNumber));

    % Save the figure in the specified directory
    saveas(bsFig_h, bootstrapFigureName)
    close(bsFig_h)       
end



return
