function  plot_stats(obj, resultsAnalysisArr)
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

    TITLE_FONTSIZE = 14;
    TITLE_WEIGHT = 'bold';
    LABEL_FONTSIZE = 12;
    LEGEND_FONTSIZE = 12;
    LINE_WIDTH = 1.5;
    MARKER_SIZE = 6;
    BIN_DIVISOR = 20;
    MISS_COLOR = 'g';
    HIT_COLOR = 'b';
    FALSE_ALARM_COLOR = 'r';
    
    nTests = numel(resultsAnalysisArr);
%    falsePosRateLimit = obj.spsdParams.spsdDetectionConfigurationStruct.falsePositiveRateLimit;

    allSizes = [];       % Fractional drop size of each *simulated* SPSD event.
    allSnr = [];         % Signal-to-noise ratio of each *simulated* SPSD event.
    allHit = false(0,1); % Hit (1) or miss (0) flag for each *simulated* SPSD event.
    
    allFp  = false(0,1); % False alarm flag (1=false alarm) for each *detected* SPSD event.

    allErr = [];         % Percent reduction in RMS error for each *target* in which one or more events were detected.
    allErrFp = [];       % False alarm flag (1=target contains a false alarm) for each target in which one or more events were detected.
    for i = 1:nTests
        sz = [resultsAnalysisArr(i).simulatedEvents.dropSize];
        allSizes = [allSizes; sz(:)];

        snr = [resultsAnalysisArr(i).simulatedEvents.snr];
        allSnr = [allSnr; snr(:)];
        
        hit = resultsAnalysisArr(i).performance.hits;
        allHit = [allHit; hit(:)];
        
        fp = resultsAnalysisArr(i).performance.falseAlarms;
        allFp = [allFp; fp(:)];

        err = resultsAnalysisArr(i).performance.correctionPerformance.rmsePercentReduction;
        allErr = [allErr; err(:)];
        
        errFp = [resultsAnalysisArr(i).performance.correctionPerformance.containsFalseAlarm];
        allErrFp = logical([allErrFp; errFp(:)]);
    end
        
    % Create figure
    scrsz = get(0,'ScreenSize');
    figure('Position',[1 scrsz(4)/1.2 scrsz(3)/1.2 scrsz(4)/1.2]);

    %----------------------------------------------------------------------
    % Histogram of drop sizes.
    %----------------------------------------------------------------------
    subplot(2, 2, 1);
    hist(allSizes,ceil(length(allSizes)/BIN_DIVISOR));
    subtitle = ['(total SPSDs injected = ', num2str(numel(allSnr)),')   '];
    title({'Distribution of Sensitivity Drops Injected   ', subtitle}, 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);
    xlabel('Avg. Pixel Sensitivity Drop (fraction)   ', 'fontsize', LABEL_FONTSIZE);
    ylabel('Frequency   ', 'fontsize', LABEL_FONTSIZE);
    
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','k','EdgeColor','k');

    %----------------------------------------------------------------------
    % Histograms of SNRs for hits and misses.
    %----------------------------------------------------------------------
    subplot(2, 2, 2);
    nbins = ceil(length(allSnr)/BIN_DIVISOR);
    step = (max(allSnr) - min(allSnr))/nbins;
    binCenters = min(allSnr) + step * ([0:nbins] + 0.5);
    
    hitSnr = allSnr(allHit);
    missSnr = allSnr(~allHit);
    hist(hitSnr,binCenters);
    hold on
    hist(missSnr,binCenters);    
    
    title('Detection Performance   ', 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);
    xlabel('SNR', 'fontsize', LABEL_FONTSIZE);
    ylabel('Frequency   ', 'fontsize', LABEL_FONTSIZE);
    legend({'hits', 'misses'}, 'Location', 'Best', 'fontsize', LEGEND_FONTSIZE);
    
    h = findobj(gca,'Type','patch');
    set(h(1),'FaceColor',MISS_COLOR,'EdgeColor',MISS_COLOR,'FaceAlpha', 0.2,'EdgeAlpha',0.2);
    set(h(2),'FaceColor',HIT_COLOR,'EdgeColor',HIT_COLOR,'FaceAlpha', 0.2,'EdgeAlpha',0.2);
        
    
    %----------------------------------------------------------------------
    % Plot of estimated P(hit) vs. SNR.
    %----------------------------------------------------------------------
    subplot(2, 2, 4)
    nbins = 100;
    snrRange = (max(allSnr) - min(allSnr));
    binEdges = min(allSnr) + [0:nbins] * snrRange/nbins;
    binCenters = binEdges(1:end-1) + diff(binEdges, 1)/2.0;
    probHitGivenSnrBin = zeros(size(binCenters));
    for i = 1:nbins
        ind = find(allSnr > binEdges(i) & allSnr < binEdges(i+1));
        nTotal = numel(ind);
        nHits = sum(allHit(ind));
        nMisses = sum(~allHit(ind));
        probHitGivenSnrBin(i)  = nHits/nTotal;
        probMissGivenSnrBin(i) = nMisses/nTotal;
    end
    ind = find(probHitGivenSnrBin >=1, 1); % Find the first index at which Prob == 1.0
    plot(binCenters(1:ind), probHitGivenSnrBin(1:ind), 'b*', 'LineStyle', '-', 'LineWidth', LINE_WIDTH, 'MarkerSize', MARKER_SIZE);
%     hold on;
%     plot(binCenters(1:ind), probMissGivenSnrBin(1:ind), 'rx', 'LineStyle', '--', 'LineWidth', LINE_WIDTH, 'MarkerSize', MARKER_SIZE);
    title('Detection Performance   ', 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);
    xlabel('SNR', 'fontsize', LABEL_FONTSIZE);
    ylabel('Probability   ', 'fontsize', LABEL_FONTSIZE);
%    legend({'P(hit | SNR)', 'P(miss | SNR)'}, 'Location', 'Best', 'fontsize', LEGEND_FONTSIZE);
    legend({'P(hit | SNR)'}, 'Location', 'Best', 'fontsize', LEGEND_FONTSIZE);
    grid on
    

    %----------------------------------------------------------------------
    % Plot Correction performance. 
    %----------------------------------------------------------------------
    subplot(2, 2, 3)
    nbins = ceil(length(allSnr)/BIN_DIVISOR);
    step = (100 - (-100))/nbins;
    binCenters = -100 + step * ([0:nbins] + 0.5);
    hist(allErr,binCenters);
     
    correctlyProcessedTargets = allErr(~allErrFp);
    falsePositiveTargets      = allErr(allErrFp);
    hist(correctlyProcessedTargets,binCenters);
    hold on
    hist(falsePositiveTargets,binCenters);    

    yRange = ylim;
    axis([-100, 100, yRange(1), yRange(2)]);
    title({'Correction Performance   ', '(Error reduction per TARGET)   '}, 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);
    xlabel('RMSE Reduction (%)', 'fontsize', LABEL_FONTSIZE);
    ylabel('Frequency   ', 'fontsize', LABEL_FONTSIZE);
    legend({'targets WITHOUT false alarms .', 'targets WITH false alarms .'}, 'Location', 'Best', 'fontsize', LEGEND_FONTSIZE);
    
    h = findobj(gca,'Type','patch');
    set(h(1),'FaceColor',FALSE_ALARM_COLOR,'EdgeColor',FALSE_ALARM_COLOR,'FaceAlpha', 1,'EdgeAlpha',1);
    set(h(2),'FaceColor',HIT_COLOR,'EdgeColor',HIT_COLOR,'FaceAlpha', 0.2,'EdgeAlpha',0.2);

    
end