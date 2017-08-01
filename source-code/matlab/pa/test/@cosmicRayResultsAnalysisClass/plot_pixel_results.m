function plot_pixel_results( obj, targetIndex )
%**************************************************************************
% function plot_pixel_results( obj, targetIndex, zeroCrossingCadences )
%**************************************************************************
%
% INPUTS:
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
    INJECTED_COLOR      = 'r'; % map(1,:);
    CORRECTED_COLOR     = 'b'; % map(2,:);
    MISS_COLOR          = 'r';
    HIT_COLOR           = 'g';
    FA_COLOR            = 'k';
    UNCERTAINTY_COLOR   = 'g'; % map(3,:);
    PREDICTION_COLOR    = [0 0.5 0.4]; %map(4,:); %;
    GROUND_TRUTH_COLOR  = [1 0.5 0]; % map(5,:);
    ZERO_CROSSING_COLOR = 'y'; % map(6,:);
    
    if ~isempty(obj.zeroCrossingIndicators)
        zcCadencesAvailable = true;
        zeroCrossingCadences = find(obj.zeroCrossingIndicators);
    else
        zcCadencesAvailable = false;
    end
    
    removeGroundTruthFlux  = false;
    plotInjected           = true;
    plotCorrected          = true;
    plotUncertainties      = false;
    plotPredictionResidual = false;
    plotTruth              = false;
    markGaps               = true;
    markZeroCrossings      = false;
    markFalseAlarms        = false;
    markHits               = false;
    markMisses             = false;
    
    setLineWidth = false;
    lineWidth = 1;
    xRange = [];
    resetYRange = true;
    
    pds = obj.targetArray(targetIndex).pixelDataStruct;
    nPixels = numel(pds);
    nCadences = length(pds(1).values);
    hasPredictionResidual = isfield(pds,'predictionResidual');
    hasPrediction = isfield(pds, obj.PREDICTION_FIELDNAME);
    truthAvailable = isfield(pds, 'cosmicRayFluxInjected');

    % Initialize optional time series.
    injectedCrFlux = zeros(nCadences,1);
    residual = zeros(nCadences,1);
    
    scrsz = get(0,'ScreenSize');
    h_fig = figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)/2]);    
    
    i = 1;
    step = 1;
    while i >=1 && i <= nPixels
        legendLabels = {};
        yRangeMat = [];
        
        pds(i).values(pds(i).gapIndicators) = NaN;
        
        if truthAvailable
            injectedCrFlux = pds(i).cosmicRayFluxInjected;
        end
 
        if hasPredictionResidual
            residual = pds(i).predictionResidual .* pds(i).uncertainties;
        end

        corrected       = pds(i).values;
        correction      = - pds(i).cosmicRaySignal;
        uncorrected     = corrected - correction; % Undo correction
        truth           = uncorrected - injectedCrFlux; % Uncorrupted flux.
                            
        if hasPrediction
            prediction  = pds(i).(obj.PREDICTION_FIELDNAME);
        else
            prediction  = uncorrected - residual;
        end
        
        %------------------------------------------------------------------
        % Plot time series.
        %------------------------------------------------------------------
        hold off
        
        if truthAvailable
            if plotInjected
                if removeGroundTruthFlux
                    yData = injectedCrFlux;
                    legendLabels(end+1) = {'Injected Cosmic Ray Flux'};
                else
                    yData = uncorrected;
                    legendLabels(end+1) = {'Uncorrected Flux'};
                end
                plot(yData, 'color', INJECTED_COLOR, 'linewidth', lineWidth, 'linestyle','-');
                hold on
                yRangeMat = [yRangeMat; [min(yData), max(yData)]];
            end

            if plotTruth && truthAvailable && ~removeGroundTruthFlux
                yData = truth;
                plot(yData, 'color', GROUND_TRUTH_COLOR, 'linewidth', lineWidth, 'linestyle','-');
                hold on
                legendLabels(end+1) = {'Ground Truth Flux'};
                yRangeMat = [yRangeMat; [min(yData), max(yData)]];
            end

            if plotUncertainties
                if removeGroundTruthFlux
                    yData = pds(i).uncertainties;
                    legendLabels(end+1) = {'Uncertainty'};
                else
                    yData = pds(i).uncertainties + truth;
                    legendLabels(end+1) = {'Uncertainty + Ground Truth Flux'};
                end
                plot(yData, 'color', UNCERTAINTY_COLOR, 'linewidth', lineWidth);
                hold on
                yRangeMat = [yRangeMat; [min(yData), max(yData)]];
            end
            
        else % ... not simulated data. In this case we remove the uncorrected flux values if removeGroundTruthFlux is set.
            
            if plotInjected
                if removeGroundTruthFlux
                    yData = zeros(nCadences, 1);
                    legendLabels(end+1) = {'(ground truth unavailable)'};
                else
                    yData = uncorrected;
                    legendLabels(end+1) = {'Uncorrected Flux'};
                end
                plot(yData, 'color', INJECTED_COLOR, 'linewidth', lineWidth, 'linestyle','-');
                hold on
                yRangeMat = [yRangeMat; [min(yData), max(yData)]];
            end

            if plotUncertainties
                if removeGroundTruthFlux
                    yData = pds(i).uncertainties;
                    legendLabels(end+1) = {'Uncertainty'};
                else
                    yData = pds(i).uncertainties + uncorrected;
                    legendLabels(end+1) = {'Uncertainty + Uncorrected Flux'};
                end
                plot(yData, 'color', UNCERTAINTY_COLOR, 'linewidth', lineWidth);
                hold on
                yRangeMat = [yRangeMat; [min(yData), max(yData)]];
            end
         
        end % if truthAvailable
        
        if plotCorrected   
            if removeGroundTruthFlux
                yData = correction;
                legendLabels(end+1) = {'Correction'};
            else
                yData = corrected;
                legendLabels(end+1) = {'Corrected Flux'};
            end
            plot(yData, 'color', CORRECTED_COLOR, 'linewidth', lineWidth, 'linestyle','-');
            hold on
            yRangeMat = [yRangeMat; [min(yData), max(yData)]];
        end
            
        if plotPredictionResidual && hasPredictionResidual
            if removeGroundTruthFlux
                legendLabels(end+1) = {'Prediction Residual'};
                plot(uncorrected - prediction, 'color', PREDICTION_COLOR, 'linewidth', lineWidth, 'linestyle','-');
                hold on
                yRangeMat = [yRangeMat; [min(residual), max(residual)]];
            else                
                legendLabels(end+1) = {'Predicted Flux'};
                plot(prediction, 'color', PREDICTION_COLOR, 'linewidth', lineWidth, 'linestyle','-');
                hold on
                yRangeMat = [yRangeMat; [min(prediction), max(prediction)]];
            end            
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
        axis([xRange yRange]);
 
        %------------------------------------------------------------------
        % Mark cadences (gaps, hits, misses, false alarms)
        %------------------------------------------------------------------        
        if markGaps
            gapCadences = find(pds(i).gapIndicators);
            mark_cadences(gca, gapCadences, GAP_COLOR, 0.5);
            legendLabels(end+1) = {'Gaps'};
        end
        
        if zcCadencesAvailable && markZeroCrossings
            mark_cadences(gca, zeroCrossingCadences, ZERO_CROSSING_COLOR);
            legendLabels(end+1) = {'Zero-Crossing Cadences'};            
        end
        
        % Only execute the following if simulated rays have been injected.
        if truthAvailable
            if markFalseAlarms
                faCadences = find(correction ~= 0 & injectedCrFlux == 0);
                if ~isempty(faCadences)
                    mark_cadences_with_lines(gca, faCadences, FA_COLOR, '-', lineWidth)
                    %mark_cadences(gca, faCadences, FA_COLOR, 0.8);
                    legendLabels(end+1) = {'False Alarms'};
                end
            end

            if markHits
                hitCadences = find(correction ~= 0 & injectedCrFlux ~= 0);
                if ~isempty(hitCadences)
                    mark_cadences_with_lines(gca, hitCadences, HIT_COLOR, '-', lineWidth)
                    %mark_cadences(gca, hitCadences, HIT_COLOR, 0.8);
                    legendLabels(end+1) = {'Hits'};
                end
            end

            if markMisses
                missCadences = find(correction == 0 & injectedCrFlux ~= 0);
                if ~isempty(missCadences)
                    mark_cadences(gca, missCadences, MISS_COLOR, 0.2);
                    legendLabels(end+1) = {'Misses'};
                end
            end
        end
        
        
        % Annotate
        titleStr = ['Pixel', num2str(i)];
        if isfield(obj.targetArray, 'keplerId')
            titleStr = strcat(titleStr, ', KID', ...
                num2str(obj.targetArray(targetIndex).keplerId));
        end
        title(titleStr);
        xlabel('Cadence');
        ylabel('Flux (e-)');
        legend(legendLabels);
        
        % Format
        fcf(legendLabels, setLineWidth);
        
        %------------------------------------------------------------------
        % Get user input
        %------------------------------------------------------------------
        reply = [];
        reply = input('Command [continue]: ', 's');
        switch reply
            case {'b','B'} % Go back one target
                i = mod(i - 2, nPixels) + 1;
                resetYRange = true; % reset the y range when changing time series
            case {'c','C'} % Toggle plotting of corrected flux.
                plotCorrected = ~plotCorrected;                
            case {'f','F'} % Mark false alarms
                markFalseAlarms = ~markFalseAlarms;
            case {'d','D'} % Print help.
                print_help();
            case {'g','G'} % Mark Gaps.
                markGaps = ~markGaps;
            case {'h','H'} % Mark Hits.
                markHits = ~markHits;
            case {'i','I'} % Toggle plotting of injected cosmic ray flux.
                plotInjected = ~plotInjected;
            case {'m','M'} % Mark Misses.                
                markMisses = ~markMisses;
            case {'o','O'} % zoom out.     
                if isempty(yRangeMat) 
                    yRange = ylim;
                else
                    yRange = [min(yRangeMat(:,1)), max(yRangeMat(:,2))];
                end
                axis([1, nCadences, yRange(1), yRange(2)]);
                resetYRange = true;
            case {'p','P'} % Toggle plotting of prediction residual.                
                plotPredictionResidual = ~plotPredictionResidual;
            case {'r','R'} % Reverse direction
                step = -step;
            case {'s','S'} % Toggle subtraction of ground truth flux.                
                removeGroundTruthFlux = ~removeGroundTruthFlux;
                resetYRange = true; 
            case {'t','T'} % Toggle plotting of ground truth.                
                plotTruth = ~plotTruth;
            case {'u','U'} % Toggle plotting of ground truth uncertainties.
                plotUncertainties = ~plotUncertainties;
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
                        i = val;
                    else
                        fprintf('Invalid input\n');
                    end
                else
                    i = mod(i-1 + step, nPixels)+1;
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
    fprintf('<index>: Go to the specified pixel index.\n');
    fprintf('b: Go back to the previous pixel.\n');
    fprintf('c: Plot corrected flux.\n');
    fprintf('f: Mark false alarm cadences.\n');
    fprintf('h: Mark hit cadences.\n');
    fprintf('i: Plot injected flux.\n');
    fprintf('m: Mark missed cadences.\n');
    fprintf('o: Zoom out.\n');
    fprintf('p: Plot predicted flux.\n');
    fprintf('q: QUIT\n');
    fprintf('r: Reverse direction.\n');
    fprintf('s: Subtract ground truth flux.\n');    
    fprintf('t: Plot ground truth.\n');
    fprintf('u: Plot uncertainties.\n');
    fprintf('w: toggle line width.\n');
    fprintf('z: Mark zero-crossing cadences.\n');
    fprintf('**************************************************\n');
end

function h_fig = fcf(dataLabels, setLineWidth)
% fcf.m 
% Format the current figure.

    FONT = 'Arial';
    LINE_WIDTH = 1.0;
    LINE_WIDTH_DELTA = 1;
    
    if ~exist('setLineWidth', 'var')
        setLineWidth = true;
    end

    h_fig   = gcf();
    h_axes  = gca();
    h_leg   = legend(h_axes);
    h_title = get(h_axes,'Title');
    h_xlab  = get(h_axes,'XLabel');
    h_ylab  = get(h_axes,'YLabel');

    axesProperties = struct(...
        'FontName',  FONT, ...
        'FontUnits', 'points', ...
        'FontSize', 14, ...
        'FontWeight', 'normal', ...
        'LineWidth', 1 ...
        );

    xLabelProperties = struct(...
        'FontName',  FONT, ...
        'FontUnits', 'points', ...
        'FontSize', 14, ...
        'FontWeight', 'bold' ...
        );

    titleProperties  = struct(...
        'FontName',  FONT, ...
        'FontUnits', 'points', ...
        'FontSize', 16, ...
        'FontWeight', 'bold' ...
        );

    legendProperties  = struct(...
        'FontName',  FONT, ...
        'FontUnits', 'points', ...
        'FontSize', 14, ...
        'FontWeight', 'normal' ...
        );

    set(h_axes,  axesProperties);
    set(h_title, titleProperties);
    set(h_xlab,  xLabelProperties);
    set(h_ylab,  xLabelProperties);
    set(h_leg,   legendProperties);

    % Modify line widths, if desired.
    if setLineWidth
        h_tmp = get(h_axes, 'Children');
        h_line = findobj(h_tmp, 'Type', 'line');

        % Find lines representing data series
        h_data = [];
        for n = 1:length(h_line)
            if any(strcmp( get(h_line(n), 'DisplayName'), dataLabels ))
                h_data = [h_data, h_line(n)];
            end
        end

        % Plot lines with increasing width (the list of child handles is in the
        % reverse plotting order).
        for i = 1:length(h_data)
            set(h_data(i), 'LineWidth', LINE_WIDTH + i*LINE_WIDTH_DELTA);
        end
    end
    
    refreshdata(h_fig);
end

function p = mark_cadences(h, cadences, color, alpha)
%**************************************************************************  
% p = mark_cadences(h, cadences, color, alpha)
%**************************************************************************  
% 
% INPUTS:
%     h             : An axes handle or [] to use current axes.
%     cadences      : List of relative cadences (indices) to mark.
%     color         : A 3-element vector
%**************************************************************************        
    if ~any(cadences)
        return
    end

    if ~ishandle(h)
        h = gca;
    end
        
    if ~exist('color','var')
        color = [0.7 0.7 0.7];
    end

    if ~exist('alpha','var')
        alpha = 0.2;
    end
    
    axes(h);
    
    original_hold_state = ishold(h);
    if original_hold_state == false
        hold on
    end
    
    nCadences = length(cadences);
    xCoords = repmat(cadences(:)',4,1) + repmat([-0.5; 0.5; 0.5; - 0.5], 1, nCadences);
    xCoords = reshape(xCoords, 4*nCadences, 1);
    ylimits = get(h,'ylim');
    yCoords = repmat([ylimits(1); ylimits(1); ylimits(2); ylimits(2)], nCadences, 1);
    
    verts  = [xCoords, yCoords];
    nVerts = length(verts);
    nRect  = fix(nVerts/4);
    faces  = reshape([1:nVerts]', 4, nRect)';
    
    p = patch('Faces',faces,'Vertices',verts,'FaceColor',color,'facealpha',alpha,'linestyle','none');
    
%     xCoords = [cadences(:)-0.5, cadences(:)+0.5, cadences(:)+0.5, cadences(:)-0.5];
%     ylimits = get(h,'ylim');
%     yCoords = repmat([ylimits(1) ylimits(1) ylimits(2) ylimits(2)], [size(xCoords,1), 1]);
%     
%     a_ = fill(xCoords',yCoords',color, 'facealpha', alpha);
%     set(a_,'facecolor',color,'edgecolor', color,'linestyle','none');
    
    if original_hold_state == false
        hold off
    end
end