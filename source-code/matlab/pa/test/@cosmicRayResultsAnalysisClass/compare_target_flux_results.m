function compare_target_flux_results( varargin )
%**************************************************************************
% function compare_target_flux_results( varargin )
%**************************************************************************
% Compare the cosmic ray-corrected light curves from two different PA runs. 
%
% Can be called in any of the following ways:
%   compare_results( inputsStruct, cosmicRayEvents1, cosmicRayEvents2, labels )
%   compare_results( cosmicRayResultsAnalysisObject1, cosmicRayResultsAnalysisObject2, labels )
%   compare_results( cosmicRayResultsAnalysisObject, inputsStruct, cosmicRayEvents1, labels )
%
%   where 'labels' is a 2-element cell array of strings used to identify
%   the first and second data sets. 
%
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

    % Initialize the two cosmicRayResultsAnalysisClass objects to compare
    if isa(varargin{1}, 'cosmicRayResultsAnalysisClass')
        crraObj1 = varargin{1};
        if isa(varargin{1}, 'cosmicRayResultsAnalysisClass')
            crraObj2 = varargin{2};
            labelArg = 3;
        else
            crraObj2 = cosmicRayResultsAnalysisClass(varargin{2}, '', varargin{3});
            labelArg = 4;            
        end
    else
        crraObj1 = cosmicRayResultsAnalysisClass(varargin{1}, '', varargin{2});
        crraObj2 = cosmicRayResultsAnalysisClass(varargin{1}, '', varargin{3});
        labelArg = 4;
    end

    % Initialize the plotting labels
    if nargin >= labelArg
        versionLabels = varargin{labelArg};
    else
        versionLabels = {'Corrected Flux 1', 'Corrected Flux 2'};
    end

    % Set Argabrightening indicators, if available
    argabrighteningIndicators = crraObj1.argabrighteningIndicators;
    if ~isempty(argabrighteningIndicators)
        argaCadencesAvailable = true;
        argaCadences = find(argabrighteningIndicators);
    else
        argaCadencesAvailable = false;
    end
    
    % Set zero-crossing indicators, if available
    zeroCrossingIndicators = crraObj1.zeroCrossingIndicators;
    if ~isempty(zeroCrossingIndicators)
        zcCadencesAvailable = true;
        zeroCrossingCadences = find(zeroCrossingIndicators);
    else
        zcCadencesAvailable = false;
    end
    
    % Set thruster-firing indicators, if available
    thrusterFiringIndicators = crraObj1.thrusterFiringIndicators;
    if ~isempty(thrusterFiringIndicators)
        tfCadencesAvailable = true;
        thrusterFiringCadences = find(thrusterFiringIndicators);
    else
        tfCadencesAvailable = false;
    end
    
    %map = colormap('colorcube');
    GAP_COLOR             = [0.7 0.7 0.7];
    ZERO_CROSSING_COLOR   = 'y'; 
    ARGA_COLOR            = 'g'; 
    THRUSTER_COLOR        = 'm';
    UNCORRECTED_COLOR     = 'r'; 
    CORRECTED_1_COLOR     = 'b'; 
    CORRECTED_2_COLOR     = [0.2 0.8 0.7]; 
        
    nTargets  = length(crraObj1.inputArray);
    nCadences = length(crraObj1.timestamps);
    
    plotUncorrected       = true;
    plotCorrected1        = true;
    plotCorrected2        = true;
    
    plotPixelFlux         = true; 
    markArgaCadences      = false;
    markZeroCrossings     = false;
    markThrusterCadences  = false;
    markGaps              = true;
    plotOptimalAperture   = true;
    plotMotion            = true;
    
    setLineWidth = false;
    lineWidth = 1;
    xRange = [];
    resetYRange = true;    
    scrsz = get(0,'ScreenSize');
    h_fig = figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)/2]);    
    
    i = 1;
    step = 1;
    while i >=1 && i <= nTargets
        legendLabels = {};
        yRangeMat = [];
        
        uncorrected = crraObj1.inputArray(i);
        corrected1  = crraObj1.targetArray(i);
        corrected2  = crraObj2.targetArray(i);
        gaps        = any([crraObj1.inputArray(i).pixelDataStruct.gapIndicators], 2) ...
                    | any([crraObj2.inputArray(i).pixelDataStruct.gapIndicators], 2);
                
        % A pixel is considered inside the optimal aperture if its flag is
        % set in either crraObj1 or crraObj2.
        inOptAp     = [crraObj1.inputArray(i).pixelDataStruct.inOptimalAperture] ...
                    | [crraObj2.inputArray(i).pixelDataStruct.inOptimalAperture];
                
        if plotOptimalAperture
            inAperture = inOptAp;
            apertureTypeStr = 'optimal';
        else          
            inAperture = true(size(inOptAp));
            apertureTypeStr = 'mask';
        end
        
        %------------------------------------------------------------------
        % Plot image motion time series.
        %------------------------------------------------------------------
        if plotMotion && ~isempty(crraObj1.ancillaryTimeSeries)
           ha(1) = subplot(2, 1, 1);
           ha(2) = subplot(2, 1, 2);
           crraObj1.plot_image_motion(i, markGaps, ...
                                 markZeroCrossings, setLineWidth);
           linkaxes(ha, 'x');
        else
            ha = subplot(1,1,1);
        end
        
        % Set the current access for plotting target and pixel flux.
        axes(ha(1));
        
        %------------------------------------------------------------------
        % Plot target flux time series.
        %------------------------------------------------------------------
        hold off
                   
        if plotUncorrected
            yData = sum([uncorrected.pixelDataStruct(inAperture).values], 2);
            yData(gaps) = NaN;
            plot(yData, 'color', UNCORRECTED_COLOR, 'linewidth', lineWidth, 'linestyle','-');
            hold on
            legendLabels(end+1) = {'Uncorrected Flux'};
            yRangeMat = [yRangeMat; [min(yData), max(yData)]];
        end

        if plotCorrected1
            yData = sum([corrected1.pixelDataStruct(inAperture).values], 2);
            yData(gaps) = NaN;
            plot(yData, 'color', CORRECTED_1_COLOR, 'linewidth', lineWidth, 'linestyle','-');
            hold on
            legendLabels(end+1) = {versionLabels{1}};
            yRangeMat = [yRangeMat; [min(yData), max(yData)]];
        end

        if plotCorrected2
            yData = sum([corrected2.pixelDataStruct(inAperture).values], 2);
            yData(gaps) = NaN;
            plot(yData, 'color', CORRECTED_2_COLOR, 'linewidth', lineWidth, 'linestyle','-');
            hold on
            legendLabels(end+1) = {versionLabels{2}};
            yRangeMat = [yRangeMat; [min(yData), max(yData)]];
        end
        %------------------------------------------------------------------
        % Plot Pixel Flux.
        %------------------------------------------------------------------
        if plotPixelFlux
            if plotUncorrected
                yData = [uncorrected.pixelDataStruct(inAperture).values];
                yData(gaps, :) = NaN;
                hLines = plot(yData, 'color', UNCORRECTED_COLOR, 'linewidth', lineWidth, 'linestyle','-');
                for hLine = hLines(:)'
                    set(get(get(hLine,'Annotation'),'LegendInformation'), ...
                          'IconDisplayStyle','off'); % Exclude line from legend
                end
                yRangeMat = [yRangeMat; [min(min(yData)), max(max(yData))]];
            end

            if plotCorrected1
                yData = [corrected1.pixelDataStruct(inAperture).values];
                yData(gaps, :) = NaN;
                hLines = plot(yData, 'color', CORRECTED_1_COLOR, 'linewidth', lineWidth, 'linestyle','-');
                for hLine = hLines(:)'
                    set(get(get(hLine,'Annotation'),'LegendInformation'), ...
                          'IconDisplayStyle','off'); % Exclude line from legend
                end
                yRangeMat = [yRangeMat; [min(min(yData)), max(max(yData))]];
            end

            if plotCorrected2
                yData = [corrected2.pixelDataStruct(inAperture).values];
                yData(gaps, :) = NaN;
                hLines = plot(yData, 'color', CORRECTED_2_COLOR, 'linewidth', lineWidth, 'linestyle','-');
                for hLine = hLines(:)'
                    set(get(get(hLine,'Annotation'),'LegendInformation'), ...
                          'IconDisplayStyle','off'); % Exclude line from legend
                end
                yRangeMat = [yRangeMat; [min(min(yData)), max(max(yData))]];            
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
        % Mark cadences (gaps, zero crossings)
        %------------------------------------------------------------------        
        if markGaps
            gapCadences = find(gaps);
            mark_cadences(gca, gapCadences, GAP_COLOR, 0.5);
            legendLabels(end+1) = {'Gaps'};
        end
        
        if zcCadencesAvailable && markZeroCrossings
            mark_cadences(gca, zeroCrossingCadences, ZERO_CROSSING_COLOR);
            legendLabels(end+1) = {'Zero-Crossing Cadences'};            
        end        

        if argaCadencesAvailable && markArgaCadences
            mark_cadences(gca, argaCadences, ARGA_COLOR);
            legendLabels(end+1) = {'Argabrightening Cadences'};            
        end        
        
        if tfCadencesAvailable && markThrusterCadences
            mark_cadences(gca, thrusterFiringCadences, THRUSTER_COLOR);
            legendLabels(end+1) = {'Thruster Firing Cadences'};            
        end        
        
        %------------------------------------------------------------------        
        % Annotate
        %------------------------------------------------------------------        
        titleStr = ['Target ', num2str(i)];
        if isfield(crraObj1.targetArray, 'keplerId')
            titleStr = strcat(titleStr, ', KID', ...
                num2str(crraObj1.targetArray(i).keplerId));
        end
        subtitleStr = sprintf('(plotting %s aperture: %d pixels)', ...
            apertureTypeStr, nnz(inAperture));
        title({titleStr, subtitleStr});
        xlabel('Cadence');
        ylabel('Flux (e-)');
        legend(legendLabels);
        
        % Format
        targetDataLabels = {'Uncorrected Flux',versionLabels{1},versionLabels{2}};
        fcf(targetDataLabels, setLineWidth);
        
        %------------------------------------------------------------------
        % Get user input
        %------------------------------------------------------------------
        reply = [];
        reply = input('Command [continue]: ', 's');
        switch lower(reply)
            case '1' % Toggle plotting of uncorrected flux.
                plotCorrected1 = ~plotCorrected1;                
            case '2' % Toggle plotting of uncorrected flux.
                plotCorrected2 = ~plotCorrected2;                
            case 'a' % Toggle plotting target mask or optimal aperture.                
                plotOptimalAperture = ~plotOptimalAperture;
                resetYRange = true;
            case 'ab' % Toggle marking of Argabrightening cadences.                
                markArgaCadences = ~markArgaCadences;
            case 'b' % Go back one target
                i = mod(i - 2, nTargets) + 1;
                resetYRange = true; % reset the y range when changing time series
            case 'f' % Toggle marking of thruster firing cadences.                
                markThrusterCadences = ~markThrusterCadences;
            case 'g' % Mark Gaps.
                markGaps = ~markGaps;
            case 'h' % Print help.
                print_help();
            case 'm' % Toggle plotting motion time series.                
                plotMotion = ~plotMotion;
            case 'o' % zoom out.     
                if isempty(yRangeMat) 
                    yRange = ylim;
                else
                    yRange = [min(yRangeMat(:,1)), max(yRangeMat(:,2))];
                end
                axis([1, nCadences, yRange(1), yRange(2)]);
                resetYRange = true;
            case 'p' % Toggle plotting of pixel time series.
                plotPixelFlux = ~plotPixelFlux;
                resetYRange = true; 
            case 'r' % Reverse direction
                step = -step;
            case 's' % Toggle subtraction of ground truth flux.                
                removeGroundTruthFlux = ~removeGroundTruthFlux;
                resetYRange = true; 
            case 't' % Specify a target to examine.     
                fprintf('Current target = %d\n', i);
                i = str2num(input('Enter new target index: ', 's'));
                resetYRange = true; % reset the y range when changing time series
            case 'u' % Toggle plotting of uncorrected flux.
                plotUncorrected = ~plotUncorrected;                
            case 'w' % Toggle line width..                
                %lineWidth = mod(lineWidth, 2) + 1;
                setLineWidth = ~setLineWidth;
            case 'z' % Toggle marking of zero crossings.                
                markZeroCrossings = ~markZeroCrossings;
            case 'q' % QUIT
                break
            otherwise
                val = str2double(reply);
                if ~isnan(val)
                    if val == fix(val) && val > 0 && val <= nTargets % If valid index
                        i = val;
                    else
                        fprintf('Invalid input\n');
                    end
                else
                    i = mod(i-1 + step, nTargets)+1;
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
    fprintf('1: Toggle plotting of corrected flux 1.\n');
    fprintf('2: Toggle plotting of  corrected flux 2.\n');
    fprintf('a: Toggle plotting target mask or optimal aperture.\n');
    fprintf('ab: Mark Argabrightening cadences.\n');
    fprintf('b: Go back to the previous pixel.\n');
    fprintf('f: Mark thruster firing cadences.\n');
    fprintf('g: Mark gaps.\n');
    fprintf('m: Toggle plotting motion time series.\n');
    fprintf('h: Help.\n');
    fprintf('o: Zoom out.\n');
    fprintf('p: Toggle plotting of pixel time series.\n');
    fprintf('q: QUIT\n');
    fprintf('r: Reverse direction.\n');
    fprintf('t: Select a specific target (e.g., ''t 102''.\n');
    fprintf('u: Toggle plotting of uncorrected flux.\n');
    fprintf('w: Toggle line width.\n');
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