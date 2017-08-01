function browse_quarter1_by_noise(Q1StructInput)
% browse_quarter1_by_noise
% gui to allow user to browse the Q1 light curves.
% Enter a keplerID or just click on the top panel. Double click 
% in the top panel to enable dragging. Click again to disable dragging.
% the files Q1Struct.mat and Q1AllFluxes.dat must be on your MATLAB path.
% Copies of these have been placed on
% /path/to/browseQ1byNoise
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

persistent Q1Struct iPlot

if ~exist('Q1Struct.mat')==2
    error('Q1Struct.mat must be on your MATLAB path! A copy is on /path/to/browseQ1byNoise')
end


if ~exist('Q1AllFluxes.dat')==2
    error('Q1AllFluxes.dat must be on your MATLAB path! A copy is on /path/to/browseQ1byNoise')
end

if nargin == 0
    s = load('Q1Struct.mat');
    Q1StructInput = s.Q1Struct;
end

if ~isstruct(Q1StructInput)
    action = Q1StructInput;
else
    Q1Struct = Q1StructInput;
    action = 'start';
end

clear Q1StructInput

switch action
    case 'start'
        
        
        % read first light curve
        fid = fopen('Q1AllFluxes.dat','r','ieee-be');

        %nflux = Q1Struct.nflux;
        %Fflux = Q1Struct.Fflux;
        freq = Q1Struct.freq;
        kepMag = Q1Struct.kepMag;
        kepId = Q1Struct.kepId;
        cadenceTimes = Q1Struct.cadenceTimes;

        nStars = sum(Q1Struct.nTargets);
        nCadences = length(cadenceTimes);

        Q1Struct.nStars = nStars;
        Q1Struct.nCadences = nCadences;

        t = cadenceTimes - fix(cadenceTimes(1));

        Q1Struct.t = t;

        %Fflux = Fflux(1:floor(end/2)+1,:);

        %Q1Struct.Fflux = Fflux;

        %[maxFflux,iMaxFflux] = max(Fflux);

        %Q1Struct.maxFreq = Q1Struct.freq(iMaxFflux);

        %Q1Struct.maxFflux = maxFflux;

        %Q1Struct.iMaxFflux = iMaxFflux;

%        Fflux256 = uint8(round(Fflux/max(max(Fflux))*255));
        freq = (0:floor(length(t)/2))'/length(t)/diff(t(1:2));

        Q1Struct.freq = freq;

%        Fsort = -sort(sort(-Fflux(:,:)));

%        Q1Struct.Fsort = Fsort;

        if ~isfield(Q1Struct,'madDiffNflux')
            madDiffNflux = generate_madDiffNflux(Q1Struct);
            Q1Struct.madDiffNflux = madDiffNflux;
        end

        %[temp,iSort] = sort(-Fsort(1,:));
        Q1Struct.topPlotX = Q1Struct.kepMag;
        Q1Struct.topPlotY = Q1Struct.madDiffNflux;
        %Q1Struct.topPlotY = sum(Q1Struct.Fsort(1:10,:),1)'./sum(Q1Struct.Fsort,1)';
        Q1Struct.xscale = 'linear';
        Q1Struct.yscale = 'log';
        Q1Struct.xlabel = 'Kepler Magnitude';
        Q1Struct.ylabel = '1/2 Hr to 1/2 Hr Precision';

        %[temp,iSort] = sort(-sum(Fsort(1:10,:)));
        % [temp,imax] = max(Fflux);
        % [temp,iSort] = sort(-imax);

        iPlot = 1;

       
        fseek(fid,4*nCadences*(iPlot-1),'bof');
        nfluxIth = fread(fid,[1639,1],'float32');
        fclose(fid)

        % Make scatter plots
        screenSize = get(0,'screensize');

        figPos = [1,1,screenSize(3)*.85,screenSize(4)*.8];
        figPos0 = figPos;

        hMainFigure = figure('WindowButtonDownFcn',...
            'browse_quarter1_by_noise(''down'')', ...
            'WindowButtonUpFcn',    '', ...
            'WindowButtonMotionFcn','browse_quarter1_by_noise(''motion'')', ...
            'Interruptible','off', ...
            'DoubleBuffer', 'on', ...
            'NumberTitle','off', 'IntegerHandle','off', ...
            'Name','Plot Quarter 1 Data Time Series',...
            'pos',figPos);


        % create 3 plots from top:
        % Top = Noise Plot
        % Middle = normalized flux time series
        % Third = Periodogram or Autocorrelation Sequence
        % Put radio buttons to left of top plot
        % to allow user to select all mod/outs
        % or a single mod/out for plotting/selecting purposes

        subplot(311)
        %semilogy(Q1Struct.kepMag,Q1Struct.madDiffNflux,'.','markersize',4)
        plot(Q1Struct.topPlotX,Q1Struct.topPlotY,'.','markersize',4)
        set(gca,'xscale',Q1Struct.xscale,'yscale',Q1Struct.yscale)

        xlabel(Q1Struct.xlabel,'fontsize',13)
        ylabel(Q1Struct.ylabel,'fontsize',13)

        hLine = line(Q1Struct.kepMag(iPlot),Q1Struct.madDiffNflux(iPlot));
        set(hLine,'color','r','marker','o','linestyle','none');
        set(hLine,'tag','targetMarker');

        set(gca,'tag','noisePlot')

        subplot(312)
        plot(t, nfluxIth)
        %title(int2str(kepId(iSort(1))));
        xlabel(['Time Since ',int2str(fix(cadenceTimes(1))),' MJD'],'fontsize',13)
        ylabel('Norm. Rel. Flux','fontsize',13)
        set(gca,'tag','nfluxPlot');

        FfluxIth = abs(fft(nfluxIth)).^2;
        FfluxIth = FfluxIth(1:length(Q1Struct.freq));

        subplot(313)
        semilogy(freq,FfluxIth)
        %title(int2str(kepId(iSort(1))));
        xlabel('Frequency, Cycles Per Day','fontsize',13)
        ylabel('PSD','fontsize',13)
        set(gca,'tag','periodogramPlot')

        buttonHeight = 20;
        buttonWidth = 120;

        figPos = get(gcf,'pos');
        figWidth = figPos(3);
        figHeight = figPos(4);

        hKepIdButton  =   uicontrol(...    % button for updating kepId
            'Parent', hMainFigure, ...
            'Units','pixels',...
            'HandleVisibility','callback', ...
            'Position',[round(figWidth/2) figHeight-50 buttonWidth buttonHeight],...
            'String',int2str(kepId(iPlot)),...
            'fontsize',12,...
            'userData',kepId(iPlot),...
            'style','edit',...
            'tag','kepIdButton',...
            'unit','norm',...
            'Callback', 'browse_quarter1_by_noise(''kepId'')');

            % create a push button to advance to the next light curve

            hNextButton  =   uicontrol(...    % button for next light curve
                'Parent', hMainFigure, ...
                'Units','pixels',...
                'HandleVisibility','callback', ...
                'Position',[round(figWidth/2)+buttonWidth*1.25 figHeight-50 buttonWidth buttonHeight],...
                'String','NEXT',...
                'fontsize',12,...
                'userData',[],...
                'style','push',...
                'tag','NextButton',...
                'unit','norm',...
                'Callback', 'browse_quarter1_by_noise(''next'')');

             % create a push button to go back to the previous light curve

            hPreviousButton  =   uicontrol(...    % button for previous light curve
                'Parent', hMainFigure, ...
                'Units','pixels',...
                'HandleVisibility','callback', ...
                'Position',[round(figWidth/2)-buttonWidth*1.25 figHeight-50 buttonWidth buttonHeight],...
                'String','PREVIOUS',...
                'fontsize',12,...
                'userData',[],...
                'style','push',...
                'tag','NextButton',...
                'unit','norm',...
                'Callback', 'browse_quarter1_by_noise(''previous'')');

            % create a push button to save current flux time series to an
            % ascii file

            hNextButton  =   uicontrol(...    % button for ascii save
                'Parent', hMainFigure, ...
                'Units','pixels',...
                'HandleVisibility','callback', ...
                'Position',[round(figWidth/2)+2*buttonWidth*1.25 figHeight-50 buttonWidth buttonHeight],...
                'String','SAVE ASCII',...
                'fontsize',12,...
                'userData',[],...
                'style','push',...
                'tag','SaveButton',...
                'unit','norm',...
                'Callback', 'browse_quarter1_by_noise(''save_ascii'')');

            if 0% temporary detour
            % create a push button to advance through current window

            hNextButton  =   uicontrol(...    % button for advance through
                'Parent', hMainFigure, ...
                'Units','pixels',...
                'HandleVisibility','callback', ...
                'Position',[round(figWidth/2)+2*buttonWidth*1.25 figHeight-50
                buttonWidth buttonHeight],...
                'String','ADVANCE',...
                'fontsize',12,...
                'userData',[],...
                'style','push',...
                'tag','AdvanceButton',...
                'unit','norm',...
                'Callback', 'browse_quarter1_by_noise(''advance'')');

            % create a push button to roll back to left edge of current window

            hPreviousButton  =   uicontrol(...
                'Parent', hMainFigure, ...
                'Units','pixels',...
                'HandleVisibility','callback', ...
                'Position',[round(figWidth/2)-2*buttonWidth*1.25 figHeight-50
                buttonWidth buttonHeight],...
                'String','ROLLBACK',...
                'fontsize',12,...
                'userData',[],...
                'style','push',...
                'tag','RollBackButton',...
                'unit','norm',...
                'Callback', 'browse_quarter1_by_noise(''roll_back'')');

            % create a push button to slide window back 250

            hPreviousButton  =   uicontrol(...
                'Parent', hMainFigure, ...
                'Units','pixels',...
                'HandleVisibility','callback', ...
                'Position',[round(figWidth/2)-3*buttonWidth*1.25 figHeight-50 buttonWidth buttonHeight],...
                'String','LEFT 250',...
                'fontsize',12,...
                'userData',[],...
                'style','push',...
                'tag','LeftButton',...
                'unit','norm',...
                'Callback', 'browse_quarter1_by_noise(''left250'')');

            % create a push button to slide window right 250

            hPreviousButton  =   uicontrol(...
                'Parent', hMainFigure, ...
                'Units','pixels',...
                'HandleVisibility','callback', ...
                'Position',[round(figWidth/2)+3*buttonWidth*1.25 figHeight-50 buttonWidth buttonHeight],...
                'String','RIGHT 250',...
                'fontsize',12,...
                'userData',[],...
                'style','push',...
                'tag','RightButton',...
                'unit','norm',...
                'Callback', 'browse_quarter1_by_noise(''right250'')');
        end % temporary detour

    case 'down'
        iPlot = down(Q1Struct, iPlot);
        update_graphics(Q1Struct, iPlot);

    case 'next'
        iPlot = iPlot + 1;
        if iPlot > Q1Struct.nStars
            iPlot = Q1Struct.nStars;
            return
        end
        update_graphics(Q1Struct, iPlot);

    case 'previous'
        iPlot = iPlot - 1;
        if iPlot<1
            iPlot = 1;
            return
        end
        update_graphics(Q1Struct, iPlot);


    case 'kepId'
        hKepId = findobj(gcf, 'tag', 'kepIdButton');
        newKepId = str2num(get(hKepId,'string'));
        iPlot = find(Q1Struct.kepId == newKepId);
        if isempty(iPlot)
            iPlot = 1;
        else
            set(hKepId,'string',int2str(Q1Struct.kepId(iPlot)));
        end
        update_graphics(Q1Struct, iPlot);

    case 'motion'
        if~strcmp(get(gcf,'selectiontype'),'normal')
            iPlot = down(Q1Struct, iPlot);
            update_graphics(Q1Struct, iPlot);
        end

    case 'save_ascii'
        outFileName = ['nflux',int2str(Q1Struct.kepId(iPlot)),'.txt'];
        
        nfluxIth = read_nflux_from_allFluxesFile(iPlot, Q1Struct.nCadences);
        
        outMat = [Q1Struct.cadenceTimes, nfluxIth];
        eval(['save ', outFileName,' outMat -ascii -double'])

end


return

%%%%%%%%%%%%%%%
function iPlot = down(Q1Struct, iPlot)

hNoisePlot = findobj(gcbo,'tag','noisePlot');

if gca ~= hNoisePlot
    return
end

cp = get(hNoisePlot,'CurrentPoint');
cx = cp(1,1);
cy = cp(1,2);

xlims  = xlim;

ylims = ylim;

if xlims(1) <= cx && cx <= xlims(2) ...
        && ylims(1) <= cy && cy <= ylims(2)
   
    if strcmp(get(gca,'xscale'),'linear')
        distFromPointX2 = (Q1Struct.topPlotX-cx).^2/diff(xlims).^2;
    else
        distFromPointX2 =...
        (log10(Q1Struct.topPlotX)-log10(cx)).^2/diff(log10(xlims)).^2;
    end
   
    if strcmp(get(gca,'yscale'),'linear')
        distFromPointY2 = (Q1Struct.topPlotY-cy).^2/diff(ylims).^2;
    else
        distFromPointY2 = ...
        (log10(Q1Struct.topPlotY)-log10(cy)).^2/diff(log10(ylims)).^2;
    end

    distFromPoint = distFromPointX2+distFromPointY2;
   
    iPlot = find(distFromPoint == min(distFromPoint));
    iPlot = iPlot(1);
   
end

return

%%%%%%%%%%%%%%%
function update_graphics(Q1Struct, iPlot)

hNfluxPlot = findobj(gcf,'tag','nfluxPlot');
hPeriodogramPlot = findobj(gcf,'tag','periodogramPlot');

nfluxIth = read_nflux_from_allFluxesFile(iPlot, Q1Struct.nCadences);

hLine = get(hNfluxPlot,'ch');
%set(hLine,'ydata',Q1Struct.nflux(:,iPlot));

set(hLine,'ydata',nfluxIth);

FfluxIth = abs(fft(nfluxIth)).^2;
FfluxIth = FfluxIth(1:length(Q1Struct.freq));

periodogramPlotStruct = get(hPeriodogramPlot,'userdata');
hLine = get(hPeriodogramPlot,'ch');
%set(hLine,'ydata',Q1Struct.Fflux(1:length(Q1Struct.freq),iPlot));
set(hLine,'ydata',FfluxIth);

hLine = findobj(gcf,'tag','targetMarker');
set(hLine,'xdata',Q1Struct.topPlotX(iPlot),'ydata',Q1Struct.topPlotY(iPlot));


hKepIdButton = findobj(gcf,'tag','kepIdButton');

set(hKepIdButton,'string',int2str(Q1Struct.kepId(iPlot)));

%%%%%%%%%%%%%%%%%%
function iPlot = update_kepId()

return


%%%%%%%%%%%%%%%%%%
function update_noisePlot(Q1Struct, iPlot)

return

%%%%%%%%%%%%%%%%%%
function madDiffNflux = generate_madDiffNflux(Q1Struct)
% madDiffNflux = generate_madDiffNflux(Q1Struct);

chunkSize = 1e4;
nCadences = length(Q1Struct.cadenceTimes);

fid = fopen('Q1AllFluxes.dat','r','ieee-be');

fseek(fid,0,'eof');

nBytes = ftell(fid);

nTargets = nBytes/4/nCadences;

fseek(fid,0,'bof');

madDiffNflux = zeros(nTargets,1);

ii = 1:chunkSize;
while 1
    
    ii(ii>nTargets) = [];
    if isempty(ii),
        break
    end
    
    nflux = fread(fid,[nCadences,chunkSize],'float32');

    madDiffNflux(ii) = mad(diff(nflux))'/1.12;
    
    ii = ii+chunkSize;
    
end

fclose(fid)

%%%%%%%%%%%%%%%%%%
function medAbsDev = mad(x)
% medAbsDev = mad(x)
[n,m]=size(x);

medAbsDev = zeros(1,m);

for i = 1:m
    medAbsDev(i) = median( abs( x(:,i)-median(x(:,i)) ) );
end

return

%%%%%%%%%%%%%%%%%%
function nfluxIth = read_nflux_from_allFluxesFile(iStar, nCadences)

fid = fopen('Q1AllFluxes.dat','r','ieee-be');
skip = 4*nCadences*(iStar-1);
fseek(fid,skip,'bof');
nfluxIth = fread(fid,[nCadences,1],'float32');
fclose(fid);

return
