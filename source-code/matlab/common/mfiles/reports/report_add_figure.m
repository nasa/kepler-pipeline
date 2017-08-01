%% report_add_figure
%
% function report_add_figure(reportDir, fid, name, figureDirectory, basename, ...
%     [widthPercent, heightPercent [, landscape]])
%
% Converts a figure (basename.fig) into a PNG file (basename.png) and
% writes a LaTeX \newcommand line which maps name to basename into the given
% fid. The name is rendered LaTeX-safe with the function report_latex_safe.
%
% If the figure contains the property UserData and it is a string, it is
% written into a macro called '<name>Caption'. To introduce paragraphs into
% the caption, add \n\n to your caption and run sprintf on it before setting
% the 'UserData' property.
%
%% INPUTS
%
%        reportDir [string]: the directory that contains the report; an
%                            empty string means to use the current directory
%              fid [double]: the file identifier
%             name [string]: the name of the LaTeX variable
%  figureDirectory [string]: the name of the directory that contains the figure
%         basename [string]: the basename of the figure
%
% The following parameters are optional. If present, they are passed to the
% format_graphics_for_report function.
%
%      widthPercent [float]:  the percentage of the width that the figure
%                             is expected to use
%     heightPercent [float]:  the percentage of the height that the figure
%                             is expected to use
%       landscape [logical]:  an optional parameter that should be true if
%                             the target report is in landscape (default:
%                             false)
%
%% OUTPUTS
%
%      figureMacro [string]: the name of the LaTeX macro that is created
%                            for this figure, including the leading
%                            backslash (\)
%%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
function figureMacro = report_add_figure(reportDir, fid, name, figureDirectory, basename, ...
    widthPercent, heightPercent, landscape)

figure = fullfile(figureDirectory, [basename '.fig']);
image = [basename '.png'];

dir = fullfile(reportDir, fileparts(basename));
if (~exist(dir, 'dir'))
    mkdir(dir)
end

h = hgload(figure);
if (exist('widthPercent', 'var'))
    if (~exist('landscape', 'var'))
        landscape = false;
    end
    format_graphics_for_report(h, widthPercent, heightPercent, landscape, true);
end

% Helps to preserve aspect ratio in report.
set(h, 'PaperPositionMode', 'auto');

% Workaround for segmentation violation in saveas. The painters algorithm
% is recommended for vector output such as EPS. The OpenGL renderer is
% better for bitmaps, like PNG (although it is not always available and the
% ZBuffer algorithm will be used instead), however, OpenGL uses hardware
% when it is available and can produce different results. Explicitly use 
% ZBuffer as it is the least common denominator. See "Selecting a Renderer"
% in MATLAB help.
set(h, 'Renderer', 'ZBuffer');
print(h, fullfile(reportDir, image), '-dpng');

caption = get(h, 'UserData');

close(h);

figureMacro = report_add_string(fid, name, basename, false);
if (ischar(caption) && ~isempty(caption))
    report_add_string(fid, [name 'Caption'], caption);
end

end

