function chatterStructArray = batch_evaluate_motion_polynomial_chatter( varargin )
%**************************************************************************
% chatterStructArray = batch_evaluate_motion_polynomial_chatter( varargin )
%**************************************************************************
% INPUTS
%     All inputs are optional attribute/value pairs. Valid attribute and
%     values are:
%    
%     Attribute      Value
%     ---------      -----
%     'pathName'     The full path to the directory containing task
%                    directories for the pipeline instance. Note that this
%                    path must have a sub-direcory named 'uow' that
%                    contains symlinks to the other task direcories
%                    (default is the current working directory).
%     'channelList'  An array of channel numbers in the range [1:84]
%                    (default = [1:84]).
%     'quarter'      An optional quarter number in the range [0, 17]. If
%                    empty or unspecified, the earliest quarter processed
%                    by the pipeline instance is used (default = []).
%     'firstDerivativeBreakpoints'
%                    (default = [0.0025, 0.010])
%     'fractionOfCadencesThreshold'
%                    (default = 0.005)
%     'fractionOfTargetsThreshold'
%                    (default = 0)
%
% OUTPUTS
%     chatterStructArray           
%     |              A struct array containing an element for each task
%     |              channel processed.
%     |-.ccdModule
%     |-.ccdOutput
%     |-.rowChatter
%     |-.rowOrder
%     |-.dashboard
%     |-.columnChatter
%     |-.columnOrder
%     |-.firstDerivativeBreakpoints
%     |-.fractionOfCadencesThreshold
%      -.fractionOfTargetsThreshold
%
% NOTES
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

%----------------------------------------------------------------------
% Parse and validate arguments.
%----------------------------------------------------------------------
parser = inputParser;
parser.addParamValue('channelList',                         [1:84], @(x)isnumeric(x) &&  min(size(x)) == 1 && all(ismember(x, 1:84)) );
parser.addParamValue('quarter',                                 [], @(x)isempty(x) || isnumeric(x) && x>=0 && x<=17  );
parser.addParamValue('pathName',                               '.', @(s)isdir(s)             );
parser.addParamValue('firstDerivativeBreakpoints', [0.0025, 0.010], @(x)isreal(x) && length(x) == 2 );
parser.addParamValue('fractionOfCadencesThreshold',          0.005, @(x)isreal(x) && x >= 0 );
parser.addParamValue('fractionOfTargetsThreshold',               0, @(x)isreal(x) && x >= 0 );
parser.parse(varargin{:});

channelList                 = parser.Results.channelList;
quarter                     = parser.Results.quarter;
pathName                    = parser.Results.pathName;
firstDerivativeBreakpoints  = parser.Results.firstDerivativeBreakpoints;
fractionOfCadencesThreshold = parser.Results.fractionOfCadencesThreshold;
fractionOfTargetsThreshold  = parser.Results.fractionOfTargetsThreshold;
%----------------------------------------------------------------------

% hard coded graphics constants
COLORMAP_FOR_POLYORDER = 'winter';
AXES_FULL_SCALE = 6500;                      % milli-pixels

TEXT_BOX1_LOCATION_X = -7250;                % milli-pixels
TEXT_BOX1_LOCATION_Y = 4800;
TEXT_BOX2_LOCATION_X = -7250;                % milli-pixels
TEXT_BOX2_LOCATION_Y = -4800;
TEXT_BOX3_LOCATION_X = 4100;                 % milli-pixels
TEXT_BOX3_LOCATION_Y = -4800;
TEXT_BOX4_LOCATION_X = 4100;                 % milli-pixels
TEXT_BOX4_LOCATION_Y = 5250;



% channel map in 10x10 grid
channelsOnGrid = ...
  [NaN   NaN     4     3     8     7    12    11   NaN   NaN;
   NaN   NaN     1     2     5     6     9    10   NaN   NaN;
    15    14    20    19    24    23    25    28    29    32;
    16    13    17    18    21    22    26    27    30    31;
    35    34    39    38    43    42    45    48    49    52;
    36    33    40    37    44    41    46    47    50    51;
    55    54    59    58    62    61    66    65    69    72;
    56    53    60    57    63    64    67    68    70    71;
   NaN   NaN    74    73    78    77    82    81   NaN   NaN;
   NaN   NaN    75    76    79    80    83    84   NaN   NaN];

% corresponding row, column index on grid
rowOnGrid = repmat([1:10]',1,10);
columnOnGrid = repmat(1:10,10,1);



% hard code pipeline filenames
PA_DAWG_MOTION = 'pa-dawg-motion.mat';
PA_MOTION_POLYS = 'pa_motion.mat';


% rowChatter and columnChatter are nBreakPoints x 2 arrays; one row for each breakpoint
% column (1) fraction of targets whose fraction of cadences above breakpoint are above cadenceFractionThreshold
% column (2) fraction of cadences whose fraction of targets above breakpoint are above targetFractionThreshold

% set up output data structure
chatterStructArray = repmat(struct('ccdModule',[],...
                                    'ccdOutput',[],...
                                    'rowChatter',[],...
                                    'rowOrder',[],...
                                    'dashboard',struct('green',false,...
                                                       'yellow',false,...
                                                       'red',false),...
                                    'columnChatter',[],...
                                    'columnOrder',[],...
                                    'firstDerivativeBreakpoints', firstDerivativeBreakpoints,...
                                    'fractionOfCadencesThreshold', fractionOfCadencesThreshold,...
                                    'fractionOfTargetsThreshold', fractionOfTargetsThreshold),length(channelList),1);


    
for iChannel = 1:length(channelList)
    
    channel = channelList(iChannel);
    
    channelPath = get_group_dir('PA', channel, ...
        'quarter', quarter, 'rootPath', pathName, 'fullPath', true);
    channelPath = channelPath{1};
    
    channelDir = get_group_dir('PA', channel, ...
        'quarter', quarter, 'rootPath', pathName, 'fullPath', false);
    channelDir = channelDir{1};
    
    s = load(fullfile(channelPath, PA_DAWG_MOTION));
    
    % evaluate chatter in each task directory
    chatterStructArray(iChannel).ccdModule = s.motionOutputStruct.ccdModule;
    chatterStructArray(iChannel).ccdOutput = s.motionOutputStruct.ccdOutput;
    currentChannel = convert_from_module_output(chatterStructArray(iChannel).ccdModule, chatterStructArray(iChannel).ccdOutput);
    
    disp(['Channel ',num2str(currentChannel),'    --   Processing ', channelDir, '...']);
    
    chatterStructArray(iChannel).rowChatter = ...
                evaluate_motion_polynomial_chatter( s.motionOutputStruct,...
                                                    firstDerivativeBreakpoints,...
                                                    fractionOfCadencesThreshold,...
                                                    fractionOfTargetsThreshold,...
                                                    'row');
    chatterStructArray(iChannel).columnChatter = ...
                evaluate_motion_polynomial_chatter( s.motionOutputStruct,...
                                                    firstDerivativeBreakpoints,...
                                                    fractionOfCadencesThreshold,...
                                                    fractionOfTargetsThreshold,...
                                                    'column');
    
    % extract the polynomial order from dawg dump if avaliable, otherwise use motion polynomials structure
    if( isfield(s.motionOutputStruct,'rowOrder') &&  isfield(s.motionOutputStruct,'colOrder') )
        chatterStructArray(iChannel).rowOrder = s.motionOutputStruct.rowOrder;
        chatterStructArray(iChannel).columnOrder = s.motionOutputStruct.colOrder;
    else
        load(fullfile(channelPath,PA_MOTION_POLYS));
        rowPolyGaps = ~logical([inputStruct.rowPolyStatus]);
        colPolyGaps = ~logical([inputStruct.colPolyStatus]);
        firstRow = find(~rowPolyGaps,1);
        firstCol = find(~colPolyGaps,1);
        if( ~isempty(firstRow) )
            chatterStructArray(iChannel).rowOrder = inputStruct(firstRow).rowPoly.order;
        else
            chatterStructArray(iChannel).rowOrder = NaN;
        end
        if( ~isempty(firstCol) )
            chatterStructArray(iChannel).columnOrder = inputStruct(firstCol).colPoly.order;
        else
            chatterStructArray(iChannel).columnOrder = NaN;
        end
    end
    
end




mod = [chatterStructArray.ccdModule];
out = [chatterStructArray.ccdOutput];

R = [chatterStructArray.rowChatter];
C = [chatterStructArray.columnChatter];




% bin chatter metric into 'green', 'yellow' and 'red' for each mod out
% compare fraction of targets exceeding first breakpoint to target fraction threshold
isgreenRow = R(1,1:2:end) <= fractionOfTargetsThreshold;
isyellowRow = R(1,1:2:end) > fractionOfTargetsThreshold & R(2,1:2:end) <= fractionOfTargetsThreshold;
isredRow = R(2,1:2:end) > fractionOfTargetsThreshold;
% compare fraction of targets exceeding first breakpoint and fraction of targets exceeding second breakpoint to target fraction threshold
isgreenCol = C(1,1:2:end) <= fractionOfTargetsThreshold;
isyellowCol = C(1,1:2:end) > fractionOfTargetsThreshold & C(2,1:2:end) <= fractionOfTargetsThreshold;
isredCol = C(2,1:2:end) > fractionOfTargetsThreshold;
% and so on ...
isred = isredRow | isredCol;
isyellow = (isyellowRow | isyellowCol) & ~isred;
isgreen = isgreenRow & isgreenCol;


% save logicals to output struct
for i=1:length(mod)
    chatterStructArray(i).dashboard.green = isgreen(i);
    chatterStructArray(i).dashboard.yellow = isyellow(i);
    chatterStructArray(i).dashboard.red = isred(i);
end


% display focal plane dashboard chart
f1 = figure;
pad_draw_ccd(1:42);
colour_my_mod_out( mod(isgreen), out(isgreen), 'g' );
colour_my_mod_out( mod(isyellow), out(isyellow), 'y' );
colour_my_mod_out( mod(isred), out(isred), 'r' );

axis off
set(gcf,'Color',[1 1 1]);
title('\bf\fontsize{14}Evaluated Motion Polynomial Chatter (milli-pixels)');
axis(AXES_FULL_SCALE.*[-1 1 -1 1]);

text(TEXT_BOX1_LOCATION_X, TEXT_BOX1_LOCATION_Y,...
        {'\itColor Breakpoints',...
        ['\rmgreen < ',num2str(firstDerivativeBreakpoints(1) * 1000)],...
        ['\rm',num2str(firstDerivativeBreakpoints(1) * 1000),' < yellow < ',num2str(firstDerivativeBreakpoints(2) * 1000)],...
        ['\rmred > ',num2str(firstDerivativeBreakpoints(2) * 1000)]});

text(TEXT_BOX2_LOCATION_X, TEXT_BOX2_LOCATION_Y,...
        {'\itNumber of Channels',...
        ['\rmgreen  ',num2str(numel(find(isgreen)))],...
        ['\rmyellow ',num2str(numel(find(isyellow)))],...
        ['\rmred    ',num2str(numel(find(isred)))]});
    
text(TEXT_BOX3_LOCATION_X, TEXT_BOX3_LOCATION_Y,...
        {'\itCadence Fraction Threshold',...
        ['\rm',num2str(fractionOfCadencesThreshold)],...
        '\itTarget Fraction Threshold',...
        ['\rm',num2str(fractionOfTargetsThreshold)]});    


% add channel numbers
% get x and y cordinates for approximate center of each mod out
[x,y] = morc_to_focal_plane_coords( mod(:), out(:), 535.*ones(size(mod(:))), 566.*ones(size(mod(:))), 'one-based' );
channel = convert_from_module_output(mod(:), out(:));
for iChannel = 1:length(channel)
    text(x(iChannel),y(iChannel),num2str(channel(iChannel)));
end

% save dashboard figure to current working directory
saveas(f1,'motion_dashboard','fig');


% display row and column motion polynomial fit order over focal plane

% % map channel vector to 10x10 grid
% [TF, idxIntoChannelOnGrid] = ismember( channel, channelsOnGrid ); 

% get row and column polynomial order and the max of the two
rowOrder = [chatterStructArray.rowOrder];
maxRowOrder = max(rowOrder);
minRowOrder = min(rowOrder);

colOrder = [chatterStructArray.columnOrder];
maxColOrder = max(colOrder);
minColOrder = min(colOrder);

maxRowColOrder = max([ rowOrder(:) colOrder(:) ], [], 2 );

% make colormap
C = colormap(COLORMAP_FOR_POLYORDER);
C_cell = mat2cell(C,ones(size(C,1),1),3);
numColors = length(C_cell);

% set color range (caxis)
orderMin = min([minRowOrder, minColOrder]);
orderMax = max([maxRowOrder, maxColOrder]);

if( orderMax - orderMin > 0 )
    cAxisForColorbar = [orderMin, orderMax];
else
    cAxisForColorbar = [orderMin, orderMax + 1];
end

                                                                        %#ok<*ASGLU>

if( ~all(isnan(rowOrder)) )
    
    if( orderMax - orderMin > 0 )
        rowOrderColorIdx = floor( (numColors - 1) .* (rowOrder - orderMin) ./ (orderMax - orderMin) ) + 1;
    else
        rowOrderColorIdx = ones(size(rowOrder));
    end
    
    f2 = figure;
    pad_draw_ccd(1:42);
    colour_my_mod_out( mod, out, C_cell(rowOrderColorIdx) );
    
%     % make image
%     rowOrderImage = nan(10);
%     rowOrderImage(rowOnGrid(idxIntoChannelOnGrid) + 10.*(columnOnGrid(idxIntoChannelOnGrid) - 1)) = rowOrder;
%     
%     % display image    
%     imagesc(rowOrderImage);
    
    colorbar;
    colormap(COLORMAP_FOR_POLYORDER);
    caxis(cAxisForColorbar);
    axis off;    
    set(gcf,'Color',[1 1 1]);
    title('\bf\fontsize{14}Row Motion Polynomial Order');
    
    % save polynomial order figure to current working directory
    saveas(f2,'row_motion_polynomial_order','fig');
end

if( ~all(isnan(colOrder)) )
    
    if( orderMax - orderMin > 0 )
        colOrderColorIdx = floor( (numColors - 1) .* (colOrder - orderMin) ./ (orderMax - orderMin) ) + 1;
    else
        colOrderColorIdx = ones(size(colOrder));
    end
    
    f3 = figure;
    pad_draw_ccd(1:42);
    colour_my_mod_out( mod, out, C_cell(colOrderColorIdx) );  
    
%     % make image
%     colOrderImage = nan(10);
%     colOrderImage(rowOnGrid(idxIntoChannelOnGrid) + 10.*(columnOnGrid(idxIntoChannelOnGrid) - 1)) = colOrder;
%     
%     % display image    
%     imagesc(colOrderImage);
    
    colorbar;
    colormap(COLORMAP_FOR_POLYORDER);
    caxis(cAxisForColorbar);
    axis off;    
    set(gcf,'Color',[1 1 1]);
    title('\bf\fontsize{14}Column Motion Polynomial Order');
    
    % save polynomial order figure to current working directory
    saveas(f3,'column_motion_polynomial_order','fig');
end

if( ~all(isnan(maxRowColOrder)) )
    
    if( orderMax - orderMin > 0 )
        orderColorIdx = floor( (numColors - 1) .* (maxRowColOrder - orderMin) ./ (orderMax - orderMin) ) + 1;
    else
        orderColorIdx = ones(size(colOrder));
    end
    
    f4 = figure;
    pad_draw_ccd(1:42);
    colour_my_mod_out( mod, out, C_cell(orderColorIdx) );  
    
%     % make image
%     colOrderImage = nan(10);
%     colOrderImage(rowOnGrid(idxIntoChannelOnGrid) + 10.*(columnOnGrid(idxIntoChannelOnGrid) - 1)) = colOrder;
%     
%     % display image    
%     imagesc(colOrderImage);
    
    colorbar;
    colormap(COLORMAP_FOR_POLYORDER);
    caxis(cAxisForColorbar);
    axis off;    
    set(gcf,'Color',[1 1 1]);
    title('\bf\fontsize{14}Maximim of Row and Column Motion Polynomial Order');
    
    % save polynomial order figure to current working directory
    saveas(f4,'max_row_and_column_motion_polynomial_order','fig');
end
    
    
