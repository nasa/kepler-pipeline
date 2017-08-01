function  plot_sc_localization_and_correction_performance(scResultsAnalysisArr)
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
    BIN_DIVISOR = 10;
    
    HIT_COLOR = 'b';
    EDGE_COLOR = 'k';
    FALSE_ALARM_COLOR = 'r';
    FACE_ALPHA = 0.6;
    EDGE_ALPHA = 1.0;
    
    nTests = numel(scResultsAnalysisArr);
%    falsePosRateLimit = obj.spsdParams.spsdDetectionConfigurationStruct.falsePositiveRateLimit;

    allSizes = [];       % Fractional drop size of each *simulated* SPSD event.
    allSnr = [];         % Signal-to-noise ratio of each *simulated* SPSD event.
    allHit = false(0,1); % Hit (1) or miss (0) flag for each *simulated* SPSD event.
    
    allFp  = false(0,1); % False alarm flag (1=false alarm) for each *detected* SPSD event.

    allLoc = [];
    allErr = [];         % Percent reduction in RMS error for each *target* in which one or more events were detected.
    allErrFp = [];       % False alarm flag (1=target contains a false alarm) for each target in which one or more events were detected.
    for i = 1:nTests
        sz = [scResultsAnalysisArr(i).simulatedEvents.dropSize];
        allSizes = [allSizes; sz(:)];

        snr = [scResultsAnalysisArr(i).simulatedEvents.snr];
        allSnr = [allSnr; snr(:)];
        
        hit = scResultsAnalysisArr(i).hits;
        allHit = [allHit; hit(:)];
        
        fp = scResultsAnalysisArr(i).falseAlarms;
        allFp = [allFp; fp(:)];

        loc = [scResultsAnalysisArr(i).detectedEvents.localization];
        allLoc = [allLoc; loc(:)];
        
        err = [scResultsAnalysisArr(i).targetPerformance.rmsePercentReduction];
        allErr = [allErr; err(:)];
        
        errFp = [scResultsAnalysisArr(i).targetPerformance.containsFalseAlarms];
        allErrFp = logical([allErrFp; errFp(:)]);
    end
        
    % Create figure
    scrsz = get(0,'ScreenSize');
    figure('Position',[1 scrsz(4)/1.2 scrsz(3)/1.2 scrsz(4)/1.2]);
        
    
    %----------------------------------------------------------------------
    % Plot localization histogram.
    %----------------------------------------------------------------------
    subplot(1, 2, 1)
    binCenters = min(allLoc)-1:max(allLoc)+1;
    hist(allLoc, binCenters);
    title({'Localization Performance   ','on correctly detected events    '}, 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);
    xlabel('Distance (short cadences)   ', 'fontsize', LABEL_FONTSIZE);
    ylabel('Frequency   ', 'fontsize', LABEL_FONTSIZE);
    
    h = findobj(gca,'Type','patch');
    set(h(1),'FaceColor',HIT_COLOR,'EdgeColor',EDGE_COLOR,'FaceAlpha', FACE_ALPHA,'EdgeAlpha',EDGE_ALPHA);
        

    %----------------------------------------------------------------------
    % Plot Correction performance. 
    %----------------------------------------------------------------------
    subplot(1, 2, 2)
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
    title({'Correction Performance   ', '(error reduction per TARGET)   '}, 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);
    xlabel('RMSE Reduction (%)', 'fontsize', LABEL_FONTSIZE);
    ylabel('Frequency   ', 'fontsize', LABEL_FONTSIZE);
    legend({'targets WITHOUT false alarms .', 'targets WITH false alarms .'}, 'Location', 'Best', 'fontsize', LEGEND_FONTSIZE);
    
    h = findobj(gca,'Type','patch');
    set(h(1),'FaceColor',FALSE_ALARM_COLOR,'EdgeColor',EDGE_COLOR,'FaceAlpha', FACE_ALPHA,'EdgeAlpha',EDGE_ALPHA);
    set(h(2),'FaceColor',HIT_COLOR,'EdgeColor',EDGE_COLOR,'FaceAlpha', FACE_ALPHA,'EdgeAlpha',EDGE_ALPHA);

    %----------------------------------------------------------------------
    % Plot Corruption. 
    %----------------------------------------------------------------------

end