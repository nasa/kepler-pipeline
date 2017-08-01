function plot_wavelet_detail_coefficients(waveletTransform, nScalesPerFigure, titleString, dataGapIndicators, nStopScale, printPlotsFlag)
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

[nCadences, nScale] = size(waveletTransform);

if(~exist('nScalesPerFigure', 'var'))
    
    nScalesPerFigure = min(5, nScale);
    
elseif(isempty(nScalesPerFigure))
    
    nScalesPerFigure = min(5, nScale);
end

if(~exist('nStopScale', 'var'))
    
    nStopScale = nScale;
    
elseif(isempty(nStopScale))
    
    nStopScale = nScale;
    
end

if(~exist('titleString', 'var'))
    titleString = '';
end

if(~exist('printPlotsFlag', 'var'))
    printPlotsFlag = false;
end

if(~exist('dataGapIndicators', 'var'))
    dataGapIndicators = [];
end


if(nStopScale > 10)
    nStopScale = 10;
    warning('plot_wavelet_detail_coefficients:tooManyScalesToPlot', 'Number of wavelet scales exceeds 10; plotting only 10');
end;

nPlots = ceil(nStopScale/nScalesPerFigure); % how many figures to spawn....

plotHandles = zeros(nPlots,1);

xAxisValues = (1:nCadences)';

for jj = 1:nPlots

    plotHandles(jj) = figure;

    if(jj == 1)
        iSubPlotStart = 1;
        iSubPlotEnd = min(nStopScale,nScalesPerFigure);
    else
        iSubPlotStart = iSubPlotEnd+1;
        iSubPlotEnd = min(iSubPlotEnd+nScalesPerFigure, nStopScale);
    end;

    for i = iSubPlotStart:iSubPlotEnd
        if(i > nScalesPerFigure)
            ii = i - fix((i-1)/nScalesPerFigure)*nScalesPerFigure;
        else
            ii = i;
        end;

        subplot(nScalesPerFigure,1,ii);
        %plot(xAxisValues, waveletTransform(i,:),'b');
        plot(xAxisValues, waveletTransform(1:nCadences,i), 'b');
        hold on;
        plot(xAxisValues, waveletTransform(1:nCadences,i), 'm');

        maxValue = max(max(waveletTransform(1:nCadences,i)));

        hold on;
        if(~isempty(dataGapIndicators))
            iGapIndices = find(dataGapIndicators);
            plot( xAxisValues(iGapIndices), dataGapIndicators(iGapIndices).*maxValue, 'r.' );
        end

        %axis tight;

        set(gca, 'FontSize',7);
    end
end;
drawnow;

for k=1:length(plotHandles)

    figure(plotHandles(k)); % bring the focus back to the figure

    if(length(plotHandles) >1)
        subplot(nScalesPerFigure,1,1);
    else
        subplot(nStopScale,1,1);
    end

    title(titleString);

    subplot(nScalesPerFigure,1,nScalesPerFigure);

    xlabel('Cadences');
    set(gca,'fontsize',6);

    if(printPlotsFlag)
        fileNameStr = [titleString '_' num2str(k)];
        paperOrientationFlag = false;
        includeTimeFlag = false;
        printJpgFlag = true;

        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    end;
end;


return;


