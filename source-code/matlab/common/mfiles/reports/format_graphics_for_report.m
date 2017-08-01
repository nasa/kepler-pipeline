%% format_graphics_for_report
%
% function format_graphics_for_report(h, widthPercent, heightPercent, landscape)
%
% Formats the given figure so that it is suitable for a report. It sets the
% resolution appropriately and emboldens titles and labels and makes them a
% uniform size.
% 
%% INPUTS
%
%              h [float]:  handle of the figure
%   widthPercent [float]:  the percentage of the width that the figure is 
%                          expected to use
%  heightPercent [float]:  the percentage of the height that the figure is
%                          expected to use
%    landscape [logical]:  an optional parameter that should be true if the
%                          target report is in landscape (default: false)
%        print [logical]:  an optional parameter that is true if the figure
%                          should be formatted for printing rather than
%                          screen (default: false)
%
%%
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
function format_graphics_for_report(h, widthPercent, heightPercent, landscape, print)

if (~exist('landscape', 'var'))
    landscape = false;
end
if (~exist('print', 'var'))
    print = false;
end

% Resolutions and paper size.
SCREEN_DPI = 72;
if (print)
    PRINT_DPI = 250;
else
    PRINT_DPI = SCREEN_DPI;
end
US_PAPER = [8.5 11];
SCREEN_TO_PRINT = PRINT_DPI / SCREEN_DPI;

% Font sizes and conversions.
FONT_SIZE = 8 * SCREEN_TO_PRINT;
TITLE_FONT_SIZE = 1.5 * FONT_SIZE;
LABEL_FONT_SIZE = 1.25 * FONT_SIZE;
MARKER_SCALE = 0.8 * SCREEN_TO_PRINT;
LINE_SCALE = SCREEN_TO_PRINT;
ANNOTATION_FONT_SIZE = 0.5 * FONT_SIZE;

% Calculate page pixel size assuming US paper (8.5"x11") at a screen
% resolution of 72 DPI.
width = US_PAPER(1) * PRINT_DPI;
height = US_PAPER(2) * PRINT_DPI;

% Swap if landscape.
if (landscape)
    tmp = width;
    width = height;
    height = tmp;
end

% Adjust to desired size.
width = widthPercent * width;
height = heightPercent * height;

% Set resolution of figure.
set(h, 'Units', 'pixels', 'Position', [0 0 width height]);

% Get all axis as well as the list of plots and subplots, which have an
% empty tag.  Note that legends and colorbars are of type axes as well and
% are tagged accordingly.
axis = findobj(h, 'Type', 'axes');
plots = findobj(h, 'Type', 'axes', 'Tag', '');
text = findobj(h, 'Type', 'text');
annotations = intersect(findall(h, 'Type', 'hggroup'), ...
    findall(gcf, '-property',  'FontSize'));

if (isempty(axis))
    return;
end

% Set font size for all plot axis, including annotations.
set(axis, 'FontSize', FONT_SIZE, 'FontWeight', 'normal', 'Box', 'on');
set(text, 'FontSize', FONT_SIZE, 'FontWeight', 'normal');
set(annotations, 'FontSize', ANNOTATION_FONT_SIZE, 'FontWeight', 'normal');

% Now set font size on title.
title = get(plots, 'Title');
if (length(title) == 1)
    title = {title};
end
set([title{:}], 'FontSize', TITLE_FONT_SIZE, 'FontWeight', 'bold');

% Now set font size on labels.
xLabel = get(plots, 'XLabel');
if (length(xLabel) == 1)
    xLabel = {xLabel};
end
set([xLabel{:}], 'FontSize', LABEL_FONT_SIZE, 'FontWeight', 'bold', ...
    'VerticalAlignment', 'top');

yLabel = get(plots, 'YLabel');
if (length(yLabel) == 1)
    yLabel = {yLabel};
end
set([yLabel{:}], 'FontSize', LABEL_FONT_SIZE, 'FontWeight', 'bold', ...
    'VerticalAlignment', 'bottom');

% Update line width. Unlike the other attributes, we cannot simply scale
% the width since we want narrow lines for time series with many, many
% segments.
%
% TODO How to discern between 2-point lines for outlines and 2-point lines
% for transit markers in flux figures?
% We may have to add an argument to this function to scale line segments of
% a certain length with a certain marker, or more generally, a closure that
% contains the appropriate query, like the findobj above.
arrayfun(@(h)update_line_width(h, LINE_SCALE), findobj(gcf, 'Type', 'line'));

% Update marker size.
markers = findobj(h, 'Type', 'line', '-not', 'Marker', 'none');
for i = 1:length(markers)
    oldSize = get(markers(i), 'MarkerSize');
    newSize = MARKER_SCALE * oldSize;
    set(markers(i), 'MarkerSize', newSize);
end
% oldSize = cell2mat(get(markers, 'MarkerSize'));
% newSize = num2cell(oldSize * SCREEN_TO_PRINT);
% set(markers, {'MarkerSize'}, newSize);

end

% Updates the line width for the given handle by the given scale and
% according to the number of segments in the line. The handle is returned.
function h = update_line_width(h, scale)

NO_SCALE_POINT_COUNT = 150;
nElements = length(get(h, 'XData'));

% As the number of elements go from 1..NO_SCALE_POINT_COUNT, the divisor
% goes from 1..scale and drives the adjustedScale from scale..1.
divisor = min(1, nElements / NO_SCALE_POINT_COUNT) * (scale - 1) + 1;
adjustedScale = scale / divisor;

% Update line width.
lineWidth = get(h, 'LineWidth');
newLineWidth =  ceil(adjustedScale * lineWidth);
set(h, 'LineWidth', newLineWidth);

end
