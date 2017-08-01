function h_fig = format_current_figure(dataLabels, setLineWidth)
% format_current_figure.m 
% Format all axes in the current figure.
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

    if ~exist('setLineWidth', 'var')
        setLineWidth = true;
    end
    
    % Get handles for all non-legend axes.
    h_fig   = gcf();
    children = get(h_fig, 'Children');
    h_axes = findobj(children, 'Type', 'axes','-not','Tag','legend');
    
    for iAxes = 1:length(h_axes)
        format_axes(h_axes(iAxes), dataLabels, setLineWidth);
    end

    refreshdata(h_fig);
end

function format_axes(h_axes, dataLabels, setLineWidth)
    FONT = 'Arial';
    LINE_WIDTH = 1.0;
    LINE_WIDTH_DELTA = 1;
        
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
    
end

% 
% function h_fig = format_current_figure(baseLineWidth, lineWidthDelta, dataLabels)
% %**************************************************************************
% % function h_fig = fcf(baseLineWidth, lineWidthDelta, dataLabels)
% %**************************************************************************
% % Format the current figure.
% % 
% % INPUTS:
% %     baseLineWidth  : The fundamental line width for data series (default
% %                      = 0.5)
% %     lineWidthDelta : Adjust line width by this amount for successive data
% %                      series, allowing all to be visible (default = 0). 
% %     dataLabels     : (cell array) Format only the data series with these
% %                      labels (all data series are formatted by default).
% % OUTPUTS:
% %     h_fig          : The figure handle.
% %
% %**************************************************************************
% 
%     FONT = 'Arial';
%     DEFAULT_LINE_WIDTH = 0.5; %1.0;
%     BASE_FONT_SIZE = 12;
%     
%     if ~exist('baseLineWidth', 'var')
%         baseLineWidth = DEFAULT_LINE_WIDTH;
%     end
%     
%     if ~exist('lineWidthDelta', 'var')
%         lineWidthDelta = 0;
%     end
% 
%     h_fig   = gcf();
%     h_axes  = gca();
%     h_leg   = legend(h_axes);
%     h_title = get(h_axes,'Title');
%     h_xlab  = get(h_axes,'XLabel');
%     h_ylab  = get(h_axes,'YLabel');
% 
%     axesProperties = struct(...
%         'FontName',  FONT, ...
%         'FontUnits', 'points', ...
%         'FontSize', BASE_FONT_SIZE, ...
%         'FontWeight', 'normal', ...
%         'LineWidth', 1 ...
%         );
% 
%     xLabelProperties = struct(...
%         'FontName',  FONT, ...
%         'FontUnits', 'points', ...
%         'FontSize', BASE_FONT_SIZE, ...
%         'FontWeight', 'bold' ...
%         );
% 
%     titleProperties  = struct(...
%         'FontName',  FONT, ...
%         'FontUnits', 'points', ...
%         'FontSize', BASE_FONT_SIZE + 2, ...
%         'FontWeight', 'bold' ...
%         );
% 
%     legendProperties  = struct(...
%         'FontName',  FONT, ...
%         'FontUnits', 'points', ...
%         'FontSize', BASE_FONT_SIZE, ...
%         'FontWeight', 'normal' ...
%         );
% 
%     set(h_axes,  axesProperties);
%     set(h_title, titleProperties);
%     set(h_xlab,  xLabelProperties);
%     set(h_ylab,  xLabelProperties);
%     set(h_leg,   legendProperties);
% 
%     h_tmp = get(h_axes, 'Children');
%     h_line = findobj(h_tmp, 'Type', 'line');
% 
%     if ~exist('dataLabels', 'var')
%         dataLabels = get(h_line, 'DisplayName');
%     end
%             
%     % Find lines representing data series
%     h_data = [];
%     for n = 1:length(h_line)
%         if any(strcmp( get(h_line(n), 'DisplayName'), dataLabels ))
%             h_data = [h_data, h_line(n)];
%         end
%     end
% 
%     % Plot lines with increasing width (the list of child handles is in the
%     % reverse plotting order).
%     for i = 1:length(h_data)
%         set(h_data(i), 'LineWidth', baseLineWidth + i*lineWidthDelta);
%     end
% 
%     refreshdata(h_fig);
% end
