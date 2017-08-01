function result = plot_pa_DAWG_dump_motion_by_target( M, varargin )
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


result  = true;

% plot formatting
MARKER_STRING = 'none';
COLOR_STRING = 'b';
MARKER_SIZE = 14;
LINE_STRING = '-';

yAxisLimit    = 1e-2;        % default y-axis limits

P1 = [ 20   685  600  415];
P2 = [ 670  120  600  980];
P3 = [1300  120  600  980];

if( nargin > 1 )
    if(any(strcmp(varargin{1},{'r','b','k','g','m','y'})))
        COLOR_STRING = varargin{1};
    end
    if( nargin > 2 )
        yAxisLimit = varargin{2};
        if( ~isnumeric(yAxisLimit) || yAxisLimit <= 0 )
            yAxisLimit = ylimDefault;
        end
    end
end



% plot target locations
h1 = figure(11);
plot(median(M.fittedCol),median(M.fittedRow),'.');
grid;
title(['PPA Target Locations - M/O ',num2str(M.ccdModule),'/',num2str(M.ccdOutput)]);
ylabel('ccdRow');
xlabel('ccdColumn');
    
% get the plotted data from current axes
c = get(gca,'Children');
xdata = get(c(end),'XData');
ydata = get(c(end),'YData');

set(h1,'Position',P1);


disp('------ RIGHT CLICK ON PLOT TO SELECT A TARGET -----------');
disp('------ Hit <CR> to exit. ------------------------------- ');

inLoop = true;
firstPlot = true;

while( inLoop )

    % get the location of the sected point 
    figure(11);
    [X, Y, mouseButton] = ginput(1);

    if( isempty(mouseButton) )
        % exit routine
        inLoop = false;
    else
        
        % calculate the radius^2 to the clicked point
        r2 = (xdata - X).^2 + (ydata - Y).^2;

        % find the closest data to the clicked point - this idx will be the
        % same as the target idx
        [minr2, idx] = min(r2);
        
        % re-plot the target locations
        figure(11);
        plot(median(M.fittedCol),median(M.fittedRow),'.');
        grid;
        title(['PPA Target Locations - M/O ',num2str(M.ccdModule),'/',num2str(M.ccdOutput)]);
        ylabel('ccdRow');
        xlabel('ccdColumn');
        hold on;

       % mark the selected target
        hold on;
        plot(median(M.fittedCol(:,idx)),median(M.fittedRow(:,idx)),'ro','MarkerSize',14);
        hold off;

        % plot the fitted row/col and diff row/col
        h2 = figure(14);
        ax(1) = subplot(2,1,1);
        v = M.fittedRow(:,idx)+M.rowResidual(:,idx);
        mv = v - medfilt1_soc(v, 48);
        plot(M.rowCadences,mv,'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        ylim(10*[prctile(mv, 5) prctile(mv, 95)]);
        grid;
        title(['Centroid row time series - M/O ',num2str(M.ccdModule),'/',num2str(M.ccdOutput),', Target Index = ',num2str(idx)]);
        ylabel('ROW');

        ax(2) = subplot(2,1,2);
        v = M.fittedCol(:,idx)+M.colResidual(:,idx);
        mv = v - medfilt1_soc(v, 48);
        plot(M.colCadences,mv,'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        ylim(10*[prctile(mv, 5) prctile(mv, 95)]);
        grid;
        title(['Centroid column time series - M/O ',num2str(M.ccdModule),'/',num2str(M.ccdOutput),', Target Index = ',num2str(idx)]);
        ylabel('ROW');

        % plot the fitted row/col and diff row/col
        h2 = figure(12);
        ax(1) = subplot(4,1,1);
        plot(M.rowCadences,M.rowResidual(:,idx),'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        grid;
        title(['Motion Polynomial Residuals - M/O ',num2str(M.ccdModule),'/',num2str(M.ccdOutput),', Target Index = ',num2str(idx)]);
        ylabel('ROW');

        ax(2) = subplot(4,1,2);
        plot(M.rowCadences(1:end-1),diff(M.rowResidual(:,idx)),'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        aa = axis;
        grid;
        axis([aa(1) aa(2) -yAxisLimit +yAxisLimit]);
        ylabel('diff ROW');

        ax(3) = subplot(4,1,3);
        plot(M.colCadences,M.colResidual(:,idx),'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        grid;
        ylabel('COL');

        ax(4) = subplot(4,1,4);
        plot(M.colCadences(1:end-1),diff(M.colResidual(:,idx)),'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        aa = axis;
        grid;
        axis([aa(1) aa(2) -yAxisLimit +yAxisLimit]);
        ylabel('diff COL');
        xlabel('cadence'); 
  
        % plot the fitted row/col and first derivative row/col
        h3 = figure(13);
        ax(5) = subplot(4,1,1);
        plot(M.rowCadences,detrend(M.fittedRow(:,idx)),'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        grid;
        title(['Motion Polynomial Evaluated - M/O ',num2str(M.ccdModule),'/',num2str(M.ccdOutput),', Target Index = ',num2str(idx)]);
        ylabel('detrended ROW');

        ax(6) = subplot(4,1,2);
        plot(M.rowCadences(1:end-1),diff(M.fittedRow(:,idx))./diff(M.rowCadences),...
            'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        aa = axis;
        grid;
        axis([aa(1) aa(2) -yAxisLimit +yAxisLimit]);
        ylabel('d/dCadence ROW');
        
        ax(7) = subplot(4,1,3);
        plot(M.colCadences,detrend(M.fittedCol(:,idx)),'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        grid;
        ylabel('detrended COL');

        ax(8) = subplot(4,1,4);
        plot(M.colCadences(1:end-1),diff(M.fittedCol(:,idx))./diff(M.colCadences),...
            'Marker',MARKER_STRING','Color',COLOR_STRING,'MarkerSize',MARKER_SIZE,'LineStyle',LINE_STRING');
        aa = axis;
        grid;
        axis([aa(1) aa(2) -yAxisLimit +yAxisLimit]);
        ylabel('d/dCadence COL');
        xlabel('cadence');
        
                
        if( firstPlot )
            set(h2,'Position',P2);
            set(h3,'Position',P3);
            linkaxes(ax,'x');
            firstPlot = false;
        end
        
    end
end
    