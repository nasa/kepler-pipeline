function plot_pixels( obj, targetIndex )
%**************************************************************************
% function plot_pixel_results( obj, targetIndex, zeroCrossingCadences )
%**************************************************************************
%
% INPUTS:
%     zeroCrossingCadences : An array of indices on which  reaction wheel
%                            zero-crossings occurred.
%**************************************************************************
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
    %map = colormap('colorcube');
    GAP_COLOR           = [0.7 0.7 0.7];
    UNCORRECTED_COLOR   = 'r'; % map(1,:);
    CORRECTED_COLOR     = 'b'; % map(2,:);
    UNCERTAINTY_COLOR   = 'g'; % map(3,:);
    PREDICTION_COLOR    = [0 0.5 0.4]; %map(4,:); %;
    ZERO_CROSSING_COLOR = 'y'; % map(6,:);
    TREND_COLOR         = [1 0.5 0];
    HMF_COLOR           = [0.5 1 0];
    AR_COLOR            = [0 0.5 1];
    NONIMPULSIVE_COLOR  = [1 0 0.5];
            
    if ~exist('targetIndex', 'var')
        targetIndex = 1;
    end
    
    if ~isempty(obj.zeroCrossingIndicators)
        zcCadencesAvailable = true;
        zeroCrossingCadences = find(obj.zeroCrossingIndicators);
    else
        zcCadencesAvailable = false;
    end
    
    plotMotion             = false;
    plotUncorrected        = true;
    plotCorrected          = true;
    plotUncertainties      = false;
    plotPredicted          = false;
    plotComponents       = false;
    markGaps               = true;
    markZeroCrossings      = false;
    
    setLineWidth = false;
    lineWidth = 1;
    xRange = [];
    resetYRange = true;
    
    pds = obj.targetArray(targetIndex).pixelDataStruct;
    nPixels = numel(pds);
    nCadences = length(pds(1).values);
    
    hasPrediction   = isfield(pds,'prediction');
    hasComponents = isfield(pds,'largeScaleTrend') ...
                      && isfield(pds,'hmfModel') ...
                      && isfield(pds,'arModel') ...
                      && isfield(pds,'nonImpulsiveOutliers');
    
    % Set gapped values to NaN for plotting purposes.
    for iPixel = 1:nPixels
        gapIndicators = pds(iPixel).gapIndicators;
        pds(iPixel).values(gapIndicators)          = NaN;
        pds(iPixel).cosmicRaySignal(gapIndicators) = NaN;
        pds(iPixel).uncertainties(gapIndicators)   = NaN;
        
        if hasPrediction
            pds(iPixel).prediction(gapIndicators)  = NaN;
        end
        
        if hasComponents
            pds(iPixel).largeScaleTrend(gapIndicators)      = NaN;
            pds(iPixel).hmfModel(gapIndicators)             = NaN;
            pds(iPixel).arModel(gapIndicators)              = NaN;
            pds(iPixel).nonImpulsiveOutliers(gapIndicators) = NaN;
        end
    end
    
    %----------------------------------------------------------------------
    % Interactively plot results.
    %----------------------------------------------------------------------
    scrsz = get(0,'ScreenSize');
    h_fig = figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)/2]);    
    
    iPixel = 1;
    step = 1;
    while iPixel >=1 && iPixel <= nPixels
        legendLabels = {};
        yRangeMat = [];
                
        corrected       = pds(iPixel).values;
        correction      = - pds(iPixel).cosmicRaySignal;
        uncorrected     = corrected - correction; % Undo correction
                            
        if hasPrediction
            predicted  = pds(iPixel).prediction;
        end
        
        %------------------------------------------------------------------
        % Plot image motion time series.
        %------------------------------------------------------------------
        if plotMotion
           ha(1) = subplot(2, 1, 1);
           ha(2) = subplot(2, 1, 2);
           obj.plot_image_motion(targetIndex, markGaps, ...
                                 markZeroCrossings, setLineWidth);
           linkaxes(ha, 'x');
        else
            ha = subplot(1,1,1);
        end
        
        %------------------------------------------------------------------
        % Plot time series.
        %------------------------------------------------------------------
        hold( ha(1), 'off');

        if plotUncorrected
            yData = uncorrected;
            legendLabels(end+1) = {'Uncorrected Flux'};
            plot( ha(1), yData, 'color', UNCORRECTED_COLOR, 'linewidth', ...
                 lineWidth, 'linestyle','-');
            hold( ha(1), 'on');
            yRangeMat = [yRangeMat; [min(yData), max(yData)]];
        end
            
        if plotUncertainties
            yData = pds(iPixel).uncertainties + uncorrected;
            legendLabels(end+1) = {'Uncertainty + Uncorrected Flux'};
            plot( ha(1), yData, 'color', UNCERTAINTY_COLOR, 'linewidth', lineWidth);
            hold( ha(1), 'on');
            yRangeMat = [yRangeMat; [min(yData), max(yData)]];
        end
         
        if plotCorrected   
            yData = corrected;
            legendLabels(end+1) = {'Corrected Flux'};
            plot( ha(1), yData, 'color', CORRECTED_COLOR, 'linewidth', ...
                 lineWidth, 'linestyle','-');
            hold( ha(1), 'on');
            yRangeMat = [yRangeMat; [min(yData), max(yData)]];
        end
        
            
        if plotPredicted && hasPrediction       
            yData = predicted;
            legendLabels(end+1) = {'Predicted Flux'};
            plot( ha(1), yData, 'color', PREDICTION_COLOR, 'linewidth', ...
                 lineWidth, 'linestyle','-');
            hold( ha(1), 'on');
            yRangeMat = [yRangeMat; [min(yData), max(yData)]];          
        end

        if hasComponents && plotComponents
            intermediateMat = [pds(iPixel).largeScaleTrend, ...
                               pds(iPixel).hmfModel, ...
                               pds(iPixel).arModel, ...
                               pds(iPixel).nonImpulsiveOutliers];
            yData = cumsum(intermediateMat, 2);
            legendLabels(end+1:end+4) = {'Large-Scale Trend', '+ HMF Model', ...
                                   '+ AR Model', '+ Non-impulsive Outliers'};
            plot( ha(1), yData(:,1), 'color', TREND_COLOR, 'linewidth', ...
                 lineWidth, 'linestyle','-');
            hold( ha(1), 'on');
            plot( ha(1), yData(:,2), 'color', HMF_COLOR, 'linewidth', ...
                 lineWidth, 'linestyle','-');
            plot( ha(1), yData(:,3), 'color', AR_COLOR, 'linewidth', ...
                 lineWidth+1, 'linestyle','-');
            plot( ha(1), yData(:,4), 'color', NONIMPULSIVE_COLOR, 'linewidth', ...
                 lineWidth, 'linestyle','-');
            yRangeMat = [yRangeMat; [min(yData(:)), max(yData(:))]];          
        end
        
        %------------------------------------------------------------------
        % Set axis ranges.
        %------------------------------------------------------------------
        if isempty(xRange) 
            xRange = xlim;
        end
        if resetYRange
            if isempty(yRangeMat) 
                yRange = ylim;
            else
                yRange = [min(yRangeMat(:,1)), max(yRangeMat(:,2))];
            end
            resetYRange = false;
        end
        if yRange(2) <= 0 
            yRange(2) = -yRange(1);
        end
        axis( ha(1), [xRange yRange]);
 
        %------------------------------------------------------------------
        % Mark cadences (gaps, hits, misses, false alarms)
        %------------------------------------------------------------------        
        if markGaps && ~isempty(legendLabels)
            gapCadences = find(pds(iPixel).gapIndicators);
            cosmicRayResultsAnalysisClass.mark_cadences(ha(1), gapCadences, GAP_COLOR, 0.5);
            legendLabels(end+1) = {'Gaps'};
        end
        
        if zcCadencesAvailable && markZeroCrossings && ~isempty(legendLabels)
            cosmicRayResultsAnalysisClass.mark_cadences(ha(1), zeroCrossingCadences, ZERO_CROSSING_COLOR);
            legendLabels(end+1) = {'Zero-Crossing Cadences'};            
        end
        
        %------------------------------------------------------------------
        % Annotate
        %------------------------------------------------------------------
        
        % Label the primary (top) plot.
        if isfield(obj.targetArray, 'keplerId')
            kid = obj.targetArray(targetIndex).keplerId;
        else
            kid = [];
        end
        title(ha(1), ['KID',num2str(kid), ', Pixel ', num2str(iPixel)]);
        ylabel(ha(1), 'Flux (e-)');
        legend(ha(1), legendLabels);
        
        % Only label the x-axis of the bottom subplot.
        xlabel(ha(end), 'Cadence');
        
        % Format
        cosmicRayResultsAnalysisClass.format_current_figure(legendLabels, setLineWidth);
        
        %------------------------------------------------------------------
        % Get user input
        %------------------------------------------------------------------
        reply = [];
        reply = input('Command [continue]: ', 's');
        switch reply
            case {'b','B'} % Go back one target
                iPixel = mod(iPixel - 2, nPixels) + 1;
                resetYRange = true; % reset the y range when changing time series
            case {'c','C'} % Toggle plotting of corrected flux.
                plotCorrected = ~plotCorrected;                
            case {'d','D'} % Print help.
                print_help();
            case {'g','G'} % Mark gaps.
                markGaps = ~markGaps;
            case {'h','H','help','Help','HELP'} % Print help.
                print_help();
            case {'i','I'} % Toggle plotting of model components.
                plotComponents = ~plotComponents;
            case {'motion','Motion'} % Plot image motion.                
                plotMotion = ~plotMotion;
            case {'o','O'} % zoom out.     
                if isempty(yRangeMat) 
                    yRange = ylim;
                else
                    yRange = [min(yRangeMat(:,1)), max(yRangeMat(:,2))];
                end
                axis([1, nCadences, yRange(1), yRange(2)]);
                resetYRange = true;
            case {'p','P'} % Toggle plotting of prediction residual.                
                plotPredicted = ~plotPredicted;
            case {'r','R'} % Reverse direction
                step = -step;
            case {'u','U'} % Reverse direction
                plotUncorrected = ~plotUncorrected;
            case {'w','W'} % Toggle line width..                
                %lineWidth = mod(lineWidth, 2) + 1;
                setLineWidth = ~setLineWidth;
            case {'z','Z'} % Toggle marking of zero crossings.                
                markZeroCrossings = ~markZeroCrossings;
            case {'q','Q'} % QUIT
                break
            otherwise
                val = str2double(reply);
                if ~isnan(val)
                    if val == fix(val) && val > 0 && val <= nPixels % If valid index
                        iPixel = val;
                    else
                        fprintf('Invalid input\n');
                    end
                else
                    iPixel = mod(iPixel-1 + step, nPixels)+1;
                end                
                resetYRange = true; % reset the y range when changing time series
        end
        xRange = xlim;
        yRange = ylim;
    end
    
    % If the figure still exists, close it.
    if ishandle(h_fig)
       close(h_fig);
    end
    
end

function print_help()
    fprintf('**************************************************\n');
    fprintf('Valid Commands:\n');
    fprintf('<index>:   Go to the specified pixel index.\n');
    fprintf('b:         Go back to the previous pixel.\n');
    fprintf('c:         Toggle plotting of corrected flux.\n');
    fprintf('help:      Print help.\n');
    fprintf('i:         Toggle plotting of model components.\n');
    fprintf('motion:    Toggle plotting of motion/focus.\n');
    fprintf('o:         Zoom out.\n');
    fprintf('p:         Toggle plotting of predicted flux.\n');
    fprintf('q:         QUIT\n');
    fprintf('r:         Reverse direction.\n');
    fprintf('u:         Toggle plotting uncorrected flux.\n');
    fprintf('w:         Toggle line width.\n');
    fprintf('z:         Toggle marking of zero-crossing cadences.\n');
    fprintf('**************************************************\n');
end

%********************************** EOF ***********************************