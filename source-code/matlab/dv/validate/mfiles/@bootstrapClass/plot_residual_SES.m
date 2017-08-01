function plot_residual_SES(bootstrapObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_residual_SES(bootstrapObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plots the residual SES.  If there are multiple trial transit pulses,
% subplots are generated.
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

nTrialPulses = length(bootstrapObject.degappedSingleEventStatistics);

if (nTrialPulses < 1)
    return;
end

MAX_TRIAL_PULSES_PER_PLOT = 3;
for iTrialPulse = 1 : nTrialPulses
    
    subplotNumber = mod(iTrialPulse, MAX_TRIAL_PULSES_PER_PLOT);
    if (subplotNumber == 0)
        subplotNumber = MAX_TRIAL_PULSES_PER_PLOT;
    end
    
    if (subplotNumber == 1)
        figure;
        ax = zeros(1, MAX_TRIAL_PULSES_PER_PLOT);
    end

    ax(subplotNumber) = createSubPlot(...
        subplotNumber, MAX_TRIAL_PULSES_PER_PLOT, ...
        bootstrapObject.degappedSingleEventStatistics(iTrialPulse));

    if (subplotNumber == MAX_TRIAL_PULSES_PER_PLOT || iTrialPulse == nTrialPulses)
        firstPulse = bootstrapObject.degappedSingleEventStatistics(iTrialPulse - subplotNumber + 1).trialTransitPulseDuration;
        lastPulse = bootstrapObject.degappedSingleEventStatistics(iTrialPulse).trialTransitPulseDuration;
        % Prune unused axis handles.
        ax(ax == 0) = [];
        createPlot(ax, firstPulse, lastPulse);
    end

end

    function h =  createSubPlot(iSubplot, nSubplots, degappedSingleEventStatistics)
        
        ses = degappedSingleEventStatistics.degappedSortedCorrelationTimeSeries ...
            ./ degappedSingleEventStatistics.degappedSortedNormalizationTimeSeries;

        h = subplot(nSubplots, 1, iSubplot);
        dv_histfit(ses, 20);

        % Make room for title and axis labels.
        position = get(h, 'Position');
        position(4) = position(4) - 0.04;
        set(h, 'Position', position);
        
        title(sprintf('  %1.2f hour trial pulse, min=%1.2f, max=%1.2f, mean=%1.2f, std=%1.2f, N=%d', ...
            degappedSingleEventStatistics.trialTransitPulseDuration,  ...
            min(ses), max(ses), mean(ses), std(ses), length(ses)));
        
        ylabel('Counts');
    end

    function createPlot(ax, firstPulse, lastPulse)
    
        axes('Position', [0.1 0.9 0.8 .05], 'Box', 'off', 'Visible', 'off');

        title(sprintf('Single Event Statistics from Residual Flux for %1.2f to %1.2f Hours', ...
            firstPulse, lastPulse));
        set(get(gca, 'Title'), 'Visible', 'on');
        set(get(gca, 'Title'), 'FontWeight', 'bold');
        
        xlabel(ax(end), 'Detection Statistic (\sigma)');
        linkaxes(ax);
        
        captionString = ['Single event statistics for each trial transit pulse ' ...
            'duration after removal of transit signatures by model fitter for target ' ...
            num2str(bootstrapObject.keplerId) '. ' ...
            'These are used to compute multiple event statistics in the Bootstrap Test.'];
        set(gcf, 'userdata', captionString);
        
        % Save figure.
        residualSESFigureName = fullfile(bootstrapObject.dvFiguresRootDirectory, ...
            'summary-plots', ...
            sprintf('%09d-00-residual-ses-%03d-%03d.fig', ...
            bootstrapObject.keplerId, 10*firstPulse, 10*lastPulse));
        format_graphics_for_dv_report(gcf);
        saveas(gcf, residualSESFigureName);
        close(gcf);
    end

end