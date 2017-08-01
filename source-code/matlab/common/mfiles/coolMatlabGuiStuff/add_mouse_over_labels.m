function hLabelsCopy = add_mouse_over_labels(varargin)
% hLabels = add_mouse_over_labels(figNum, x, y, labels, textPropName1, textPropValue1, ...)
% or
% add_mouse_over_labels('clearLabels')
% 
% Adds mouse-over labels on top of existing plots
% x and y are column vectors with the (x,y) coordinates specifying
% placement of the labels. The variable lables is a cell array of strings
% to be displayed. The dimensions of x, y and labels should agree (they
% should all have the same number of rows).
% figNum is the figure number or handle to the figure with the plot for
% which the labels are to be added.
% textPropName1, textPropValue1, textPropName2, textPropValue2, etc.
% must be valid property name/value pairs to be passed to the builtin
% function text, which is used to apply the labels. These optional inputs
% can be used to control the appearance of the labels, including size,
% color, orientation, etc.
%
% An example:
% x = randn(100,1);
% y = randn(100,1);
% labels = cellstr(int2str((1:100)'));
% figure
% plot(x,y,'x')
% add_mouse_over_labels(gcf, x, y, labels) 
%
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

%persistent hLabels x y labels %labelStyle

if nargin > 1
    figNum = varargin{1};
    if length(figNum)~=1||~ishandle(figNum)||~strcmp(get(figNum,'Type'),'figure')
        error('ADD_MOUSE_OVER_LABELS: invalid figure handle passed in as first argument')
    end
    mouseLabelsStruct = get(figNum, 'userdata');
    
    if isempty(mouseLabelsStruct)
        hLabels = [];
        labels = [];
        x = [];
        y = [];
    elseif ~strcmp(mouseLabelsStruct.name,'mouseLabelsStruct')
        error('invalid mouseLabelsStruct in figure user data')
    else
        hLabels = mouseLabelsStruct.hLabels;
        labels = mouseLabelsStruct.labels;
        x = mouseLabelsStruct.x;
        y = mouseLabelsStruct.y;
    end
    
    if ~isempty(hLabels)&&all(ishandle(hLabels))
        iStart = length(hLabels)+1;
        x=[x;varargin{2}];
        y = [y;varargin{3}];
        labels = [labels;varargin{4}];
    else
        iStart = 1;
        x = varargin{2};
        y = varargin{3};
        labels = varargin{4};
    end
    if length(varargin)>=5
        labelStyle = varargin(5:end);
    else
        labelStyle = {'fontsize',15,'color','magenta','fontweight','bold'};
    end
    
    nPoints = length(x);
    action = 'start';
else % get info from figure
    figNum = gcbf;
    action = varargin{1};

    mouseLabelsStruct = get(figNum, 'userdata'); 
    hLabels = mouseLabelsStruct.hLabels;
    labels = mouseLabelsStruct.labels;
    x = mouseLabelsStruct.x;
    y = mouseLabelsStruct.y;
end

v = axis;

xDistThresh = .05*(v(2)-v(1));
yDistThresh = .05*(v(4)-v(3));

if nargin == 0
    action = 'start';
end

switch (action)

    case 'start'

        set(figNum, 'WindowButtonMotionFcn','add_mouse_over_labels(''motion'')', ...
            'Interruptible','off', 'DoubleBuffer', 'on');

        set(gca,'Tag','graph');

        for i = iStart:nPoints
            %hLabels(i) = text(x(i),y(i),labels{i},'fontsize',15,'fontweight','bold','color','magenta');
            hLabels(i) = text(x(i),y(i),labels{i},labelStyle{:});
            set(hLabels(i),'visible','off')
        end

    case 'motion'
        fig = gcbf;

        ax = findobj(fig, 'Tag', 'graph');

        cp = get(ax,'CurrentPoint');
        cx = cp(1,1);
        cy = cp(1,2);

        xDistances = abs(x-cx);
        yDistances = abs(y-cy);


        v = axis;

        xDistances(x<v(1) | x>v(2) ) = inf;
        yDistances( y<v(3) | y > v(4)) = inf;

        set(hLabels(xDistances > xDistThresh | yDistances > yDistThresh),'visible','off')
        set(hLabels(xDistances <= xDistThresh & yDistances <= yDistThresh), 'visible','on')
    
end

if nargout>0
    hLabelsCopy = hLabels;
end


mouseLabelsStruct.name = 'mouseLabelsStruct';
mouseLabelsStruct.hLabels = hLabels;
mouseLabelsStruct.labels = labels;
mouseLabelsStruct.x = x;
mouseLabelsStruct.y = y;

set(figNum, 'userdata', mouseLabelsStruct)

return

 