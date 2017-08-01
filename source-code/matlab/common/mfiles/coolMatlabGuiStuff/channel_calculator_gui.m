function status = channel_calculator_gui(action)
% status = channel_calculator_gui(action)
% displays a gui with editable text boxes for the user to
% enter mod/out numbers and have them automatically converted to channel
% number, and vice versa.
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

if nargin==0
    action = 'start';
end

switch(action)
    case 'start'
        modNumber = 2;
        outNumber = 1;
        channelNumber = convert_from_module_output(modNumber, outNumber);

        % load the Kepler Bumper sticker
        keplerBumper = imread('Kepler_bumper.jpg');
        keplerBumperSize = size(keplerBumper);
        bumperWidth =keplerBumperSize(2);
        bumperHeight = keplerBumperSize(1);
        
        dataWindowWidth = 200;
        
        % Open a new window for the gui
        screenSize = get(0,'screensize');
        figPos = round([.4*screenSize(3),.6*screenSize(4),keplerBumperSize(2)+dataWindowWidth,keplerBumperSize(1)]);
        
        hMainFigure = figure('WindowButtonDownFcn', '', ...
            'WindowButtonUpFcn', '', ...
            'WindowButtonMotionFcn','', ...
            'Interruptible','off', ...
            'DoubleBuffer', 'on', ...
            'NumberTitle','off', ...
            'IntegerHandle','off', ...
            'Position',figPos,...
            'MenuBar','none', ...
            'Toolbar','none', ...
            'Name',mfilename);
        
        hBumper = imagesc(keplerBumper);
        axis image
        set(gca,'units','pixels',...
            'pos',[0,0,bumperWidth,bumperHeight],...
            'xtick',[], 'ytick',[]);

        keplerBumperTongue = imread('KeplerBumperTongueSmall.jpg');
        
        hTongueAxis = axes;
        set(hTongueAxis,'units','pixels','pos',[0,0,bumperWidth,bumperHeight],...
            'vis','off', 'xtick',[], 'ytick',[], 'tag', 'tongueAxis');
        hTongue = imagesc(keplerBumperTongue);
        axis image
        set(hTongue,'vis','off','tag','tongue');
        set(hTongueAxis,'vis','off')
        
        [raspberrySound,Fs,bits] = auread('raspberry.au');
        raspberry.sound = raspberrySound;
        raspberry.Fs = Fs;
        raspberry.bits = bits;
        
        set(gcf,'userdata',raspberry);
        
        dataWindowWidthFraction = dataWindowWidth/(dataWindowWidth + bumperWidth);
        
        textButtonHeight = .15*bumperHeight;
        textButtonWidth = .4*dataWindowWidth;
        
        leftColumn = (dataWindowWidth-2*textButtonWidth)/3+bumperWidth;%(0.1*dataWindowWidth+bumperWidth);
        rightColumn  = ((dataWindowWidth-2*textButtonWidth)/3/2+.5*dataWindowWidth)+bumperWidth;%(0.6*dataWindowWidth+bumperWidth);
        centerColumn = (dataWindowWidth-textButtonWidth)/2+bumperWidth;%(0.35*dataWindowWidth+bumperWidth);
        
        hModButton  =   uicontrol(...    % button for updating Module Number 
                        'Parent', hMainFigure, ...
                        'Units','pixels',...
                        'HandleVisibility','callback', ...
                        'Position',[leftColumn 0.65*bumperHeight textButtonWidth textButtonHeight],...
                        'String',int2str(modNumber),...
                        'userData',modNumber,...
                        'fontsize',14,...
                        'style','edit',...
                        'tag','modButton',...
                        'Callback', @update_channel_number);

        hModText  =   uicontrol(...    % text for Module Number 
                        'Parent', hMainFigure, ...
                        'Units','pixels',...
                        'Position',[leftColumn 0.8*bumperHeight textButtonWidth textButtonHeight],...
                        'String','Module',...
                        'fontsize',14,...
                        'fontweight','bold',...
                        'userData',modNumber,...
                        'style','text',...
                        'backgroundcolor',get(hMainFigure,'color'),...
                        'tag','modText',...
                        'Callback', '');

        hOutButton  =   uicontrol(...    % button for updating Output Number 
                        'Parent', hMainFigure, ...
                        'Units','pixels',...
                        'HandleVisibility','callback', ...
                        'Position',[rightColumn 0.65*bumperHeight textButtonWidth textButtonHeight],...
                        'String',int2str(outNumber),...
                        'fontsize',14,...
                        'userData',outNumber,...
                        'style','edit',...
                        'tag','outButton',...
                        'Callback', @update_channel_number);

        hOutText  =   uicontrol(...    % text for Output Number 
                        'Parent', hMainFigure, ...
                        'Units','pixels',...
                        'Position',[rightColumn 0.8*bumperHeight textButtonWidth textButtonHeight],...
                        'String','Output',...
                        'fontsize',14,...
                        'fontweight','bold',...
                        'backgroundcolor',get(hMainFigure,'color'),...
                        'userData',modNumber,...
                        'style','text',...
                        'tag','modText',...
                        'Callback', '');

        hChannelButton  =   uicontrol(...    % button for updating Channel Number 
                        'Parent', hMainFigure, ...
                        'Units','pixels',...
                        'HandleVisibility','callback', ...
                        'Position',[centerColumn 0.3*bumperHeight textButtonWidth textButtonHeight],...
                        'String',int2str(channelNumber),...
                        'fontsize',14,...
                        'userData',channelNumber,...
                        'style','edit',...
                        'tag','channelButton',...
                        'Callback', @update_mod_out_numbers);

        hChannelText  =   uicontrol(...    % text for Channel Number 
                        'Parent', hMainFigure, ...
                        'Units','pixels',...
                        'Position',[centerColumn 0.45*bumperHeight textButtonWidth textButtonHeight],...
                        'String','Channel',...
                        'fontsize',14,...
                        'fontweight','bold',...
                        'userData',channelNumber,...
                        'backgroundcolor',get(hMainFigure,'color'),...
                        'style','text',...
                        'tag','modText',...
                        'Callback', '');

        hWarningText  =  uicontrol(...    % window for issueing warnings
                        'Parent', hMainFigure, ...
                        'Units','pixels',...
                        'Position',[bumperWidth+dataWindowWidth*.05 0.05*bumperHeight dataWindowWidth*.9 0.2*bumperHeight],...
                        'String','Warning: Invalid Mod or Out value!',...
                        'userData',channelNumber,...
                        'tag','warningText',...
                        'foregroundcolor','red',...
                        'fontsize',12,...
                        'fontweight','bold',...
                        'style','text',...
                        'backgroundcolor',get(hMainFigure,'color'),...
                        'visible','off',...
                        'Callback', '');
        
        set(hMainFigure,'handlevisibility','callback')
        
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_channel_number(varargin)

hCallback = varargin{1};

hMainFigure = get(hCallback,'parent');

hModButton = findobj(hMainFigure,'tag','modButton');
hOutButton = findobj(hMainFigure,'tag','outButton');
hChannelButton = findobj(hMainFigure,'tag','channelButton');

hWarningText = findobj(hMainFigure,'tag','warningText');

hTongue = findobj(hMainFigure,'tag','tongue');
    
set(hWarningText,'visible','off');
set(hTongue,'vis','off');
set(get(hTongue,'parent'),'vis','off');


modNumber = str2num(get(hModButton,'string'));

outNumber = str2num(get(hOutButton,'string'));

try
    channelNumber = ...
        convert_from_module_output(modNumber, outNumber);
    
    % update info in objects
    set(hModButton, 'userData', modNumber);
    set(hOutButton, 'userData', outNumber);
    
    set(hChannelButton,'String',int2str(channelNumber));
    set(hChannelButton,'userData',channelNumber);
    
catch
    % didn't work out, display message and reset mod and out to old values
    set(hModButton, 'string', int2str(get(hModButton,'userData')) );
    set(hOutButton, 'string', int2str(get(hOutButton,'userData')) );

    % display warning message
    set(hWarningText,'string','Invalid mod or out number!','visible','on');
    
    set(hTongue,'vis','on');
    
    pause(.01)
    
    % sound raspberry
    raspberry = get(hMainFigure,'userdata');
    soundsc(raspberry.sound(1:round(end*2.5/4),:),raspberry.Fs,raspberry.bits)

end


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_mod_out_numbers(varargin)

hCallback = varargin{1};

hMainFigure = get(hCallback,'parent');

hModButton = findobj(hMainFigure,'tag','modButton');
hOutButton = findobj(hMainFigure,'tag','outButton');
hChannelButton = findobj(hMainFigure,'tag','channelButton');

hWarningText = findobj(hMainFigure,'tag','warningText');
hTongue = findobj(hMainFigure,'tag','tongue');
    
set(hWarningText,'visible','off');
set(hTongue,'vis','off');
set(get(hTongue,'Parent'),'vis','off');
    
channelNumber = str2num(get(hChannelButton,'string'));

if isempty(channelNumber)
    channelNumber = 0; % force error
end


try
    [modNumber, outNumber] = ...
        convert_to_module_output(channelNumber);
    
    % update info in objects
    set(hChannelButton, 'userData', channelNumber);
    
    set(hModButton,'String',int2str(modNumber));
    set(hModButton,'userData',modNumber);
    
    set(hOutButton,'String',int2str(outNumber));
    set(hOutButton,'userData',outNumber);
    
catch
    % didn't work out, display message and reset mod and out to old values
    set(hChannelButton, 'string', int2str(get(hChannelButton,'userData')) );


    % display warning message

    set(hWarningText,'string','Invalid channel number!','visible','on');
    
    set(hTongue,'vis','on');
    
    pause(.01)
        
    % sound raspberry
    raspberry = get(hMainFigure,'userData');
    soundsc(raspberry.sound(1:round(end*2.5/4),:),raspberry.Fs,raspberry.bits)
end


return


