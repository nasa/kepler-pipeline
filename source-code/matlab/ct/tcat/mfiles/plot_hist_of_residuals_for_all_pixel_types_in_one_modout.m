function plot_hist_of_residuals_for_all_pixel_types_in_one_modout(tcatInputDataStruct, xTalkOutputStruct, ...
    parallelXtalkPixelStruct, frameTransferXtalkPixelStruct, plotHistogramsFlag)
%______________________________________________________________________
% function plot_hist_of_residuals_for_all_pixel_types_in_one_modout(tcatInputDataStruct, xTalkOutputStruct, ...
%     parallelXtalkPixelStruct, frameTransferXtalkPixelStruct)
%
%   plotHistogramsFlag is an optional Boolean flag when set to false skips
%   plotting the histograms of parallel transfer crosstalk pixels annd
%   frame transfer crosstalk pixels. This is useful for debugging or
%   quickly getting only the mean and rms/std superposed plots. If this
%   parameter is not provided, it defaults to true and the histograms are
%   plotted.
%
%   nanmean, nanstd built-in functions are used  instead of the commonly
%   used mean, std to be robust against NaNs in the data.
%
%
%
% This function computes the mean, rms, or histograms of weighted
% rms residual for parallel/frame transfer cross talk pixels and produces
% Mod/Out type plots
%
%     Type 1: A stack of mean removed histograms (3D plots) of weighted RMS
%             residuals of fit (from BART) for all parallel/frame transfer
%             cross talk pixel types (1 through 32/ 1 through 16) for one
%             modout. Each figure contains parallel/frame transfer cross
%             talk pixels of all types plotted for one modout. There is a
%             total of 84 (or however many mod/outs are available) such plots
%             for parallel cross talk and 84 plots for frame transfer
%             crosstalk pixels
%
%             x axis - 'Parallel Crosstalk Pixel Type' or 'Frame Transfer
%                       Crosstalk Pixel Type'
%             y axis - 'Scatter of Mean Removed Residuals (DN/integration)'
%             z axis - 'Pixel Count'
%
%     Type 2: Plots of mean of residuals for parallel/frame transfer pixels
%             (3D plot and a superposed plot where each curve is offset from
%             the rest) a total of 4 plots
%
%             x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'  or
%                      'Frame Transfer Crosstalk Pixel Type'
%             y axis - 'Module/Output'
%             z axis - 'Mean of weighted RMS residual'
%
%     Type 3: Plots of rms of residuals for parallel/frame transfer pixels
%             (3D plot and a superposed plot where each curve is offset from
%             the rest) a total of 4 plots
%
%             x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'
%             y axis - 'Module/Output'
%             z axis - 'RMS of weighted RMS residual'
%
%
%______________________________________________________________________
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





%__________________________________________________________________________
% preliminaries
%__________________________________________________________________________
close all;

if(~exist('plotHistogramsFlag', 'var'))
    plotHistogramsFlag = true;
end


paperOrientationFlag = true;
includeTimeFlag = false;
printJpgFlag = true;
%printJpgFlag = false;


nModOuts = tcatInputDataStruct.fcConstantsStruct.MODULE_OUTPUTS;

nBins = tcatInputDataStruct.nHistogramBins;


plotsOffsetFactor = tcatInputDataStruct.stackedPlotsOffsetFactor;

modOutsProcessed = find(tcatInputDataStruct.modelFileAvailable);

numberOfFgsParallelPixels = xTalkOutputStruct.numberOfFgsParallelPixels;



% get the xBinLocations from the data
stdMin = Inf(numberOfFgsParallelPixels,1);

for k = 1:numberOfFgsParallelPixels

    stdMin(k) = min( max(nanstd(parallelXtalkPixelStruct(k).weightedRMSresidual, [],2)), stdMin(k));

end

xBinLocations =  linspace(-max(stdMin),max(stdMin), nBins);


yTickStr = cell(nModOuts,1);

[modules, outputs] = convert_to_module_output(1:nModOuts);
for j = 1:nModOuts

    yTickStr(j) = {['[' num2str(modules(j)) ', ' num2str(outputs(j)) ']']};

end


%__________________________________________________________________________
% plot of histograms of weighted RMS residuals of fit (from BART) for
% all parallel cross talk pixel types (1 through 32) for one modout.
% Each figure contains parallel cross talk pixels of all types plotted for
% one modout. There are a total of 84 such plots.
%__________________________________________________________________________


barGraphData = NaN( length(xBinLocations), numberOfFgsParallelPixels);

meanValue = NaN(numberOfFgsParallelPixels,1);
% rms = norm(x)/sqrt(n)
rmsValue = NaN(numberOfFgsParallelPixels,1);

barGraphDataForParallelXTalkStruct = repmat(struct('barGraphData', barGraphData, 'meanValue', meanValue, 'rmsValue', rmsValue), nModOuts,1);


for k = 1:nModOuts

    for j = 1:numberOfFgsParallelPixels

        if(tcatInputDataStruct.diagnosticFileAvailable(k))

            % histc is not affected by NaNs in the data - no need to filter
            histData = parallelXtalkPixelStruct(j).weightedRMSresidual(k,:);

            % remove mean after excluding NaN/Inf
            validIndex = find(isfinite(histData));

            histData = histData(validIndex);


            % trimmean???
            meanValue(j) = nanmean(histData);

            rmsValue(j) = norm(histData)/sqrt(length(histData));

            histData = histData - meanValue(j);

            barGraphDataForParallelXTalkStruct(k).barGraphData(:,j) = histc(histData, xBinLocations);
            barGraphDataForParallelXTalkStruct(k).meanValue(j) = meanValue(j);
            barGraphDataForParallelXTalkStruct(k).rmsValue(j) = rmsValue(j);

        end

    end
end

% numberOfFgsParallelPixels plots of histograms
if(plotHistogramsFlag)

    for k = 1:nModOuts

        if(tcatInputDataStruct.diagnosticFileAvailable(k))
            figure;

            [mod out] = convert_to_module_output(k);

            h = bar3(xBinLocations, barGraphDataForParallelXTalkStruct(k).barGraphData,  'detached');

            shading interp
            for i = 1:length(h)
                zdata = get(h(i),'Zdata');
                set(h(i),'Cdata',zdata)
                set(h,'EdgeColor','k')
            end
            colorbar;

            set(gca, 'fontsize', 11);
            xlabel('Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
            zlabel('Pixel Count', 'fontsize',11,'fontweight','b');
            ylabel({'Scatter of Mean Removed Residuals'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

            titleStr = ({'Mean Removed Histograms of Weighted RMS Residual for Parallel Transfer Crosstalk'; ['Pixels for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k) ]});
            title(titleStr, 'fontsize',11,'fontweight','b');

            titleStr = ['Mean Removed Histograms of Weighted RMS Residual for Parallel Transfer Crosstalk Pixels for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k) ];
            plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

            close all;

        end
    end
end
% --------------------------------------------
% one plot of means of residuals
% --------------------------------------------




% need 32 colors
colorSpec = zeros(nModOuts, 3); % R, G, B colors

shuffleOrder = randperm(nModOuts);
shuffleOrder = shuffleOrder(:);

colorSpec(shuffleOrder,1) = linspace(0.001, 1, nModOuts);
shuffleOrder = randperm(nModOuts);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,2) = linspace(0.001, 1, nModOuts);
shuffleOrder = randperm(nModOuts);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,3) = linspace(0.001, 1, nModOuts);


for k = 1:nModOuts
    if(tcatInputDataStruct.diagnosticFileAvailable(k))

        plot3(1:numberOfFgsParallelPixels, repmat(k,numberOfFgsParallelPixels,1), barGraphDataForParallelXTalkStruct(k).meanValue(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);

        hold on;
    end
end

view([-3.5, 66]);

set(gca, 'fontsize', 11);
xlabel('Parallel Crosstalk Pixel Type','fontsize',11,'fontweight','b');
ylabel('Module/Output','fontsize',11,'fontweight','b');
zlabel({'Mean of Weighted RMS Residual'; '(DN/integration)'},'fontsize',11,'fontweight','b');

if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end


titleStr = ({'Mean of Weighted RMS Residual for all'; 'Parallel Transfer Crosstalk Pixel Types across each ModOut'});
title(titleStr, 'fontsize',11,'fontweight','b');
grid on;

titleStr = 'Mean of Weighted RMS Residual for all Parallel Transfer Crosstalk Pixel Types across each ModOut';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


% --------------------------------------------
% one plot of rms of rms residuals
% --------------------------------------------

for k = 1:nModOuts
    if(tcatInputDataStruct.diagnosticFileAvailable(k))

        plot3(1:numberOfFgsParallelPixels, repmat(k,numberOfFgsParallelPixels,1), barGraphDataForParallelXTalkStruct(k).rmsValue(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);

        hold on;
    end
end

view([-3.5, 66]);
set(gca, 'fontsize', 11);

xlabel('Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Module/Output', 'fontsize',11,'fontweight','b');
zlabel({'RMS of Weighted RMS Residual'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end


titleStr = ({'RMS of Weighted RMS Residual for all'; 'Parallel Transfer Crosstalk Pixel Types across each ModOut '});
title(titleStr, 'fontsize',11,'fontweight','b');
grid on;

%
titleStr = 'RMS of Weighted RMS Residual for all Parallel Transfer Crosstalk Pixel Types across each ModOut ';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

% --------------------------------------------
% one plot of means of residuals
% --------------------------------------------



for k = 1:nModOuts
    if(tcatInputDataStruct.diagnosticFileAvailable(k))

        plotOffset = max(nanstd([barGraphDataForParallelXTalkStruct.meanValue])) * plotsOffsetFactor;

        plot(barGraphDataForParallelXTalkStruct(k).meanValue(:) + k*plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        % attach a text label at the end of the line
        text(numberOfFgsParallelPixels, barGraphDataForParallelXTalkStruct(k).meanValue(end) + k*plotOffset,  ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',11, 'fontweight','b');

        hold on;
    end
end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 11);
xlabel('Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Mean of Weighted RMS Residual (DN/integration)', 'fontsize',11,'fontweight','b');

titleStr = ({'Mean of Weighted RMS Residual for all'; 'Parallel Transfer Crosstalk Pixel Types across each ModOut Superposed'});
title(titleStr, 'fontsize',11,'fontweight','b');

titleStr = 'Mean of Weighted RMS Residual for all Parallel Transfer Crosstalk Pixel Types across each ModOut Superposed';

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


% --------------------------------------------
% one plot of rms of rms residuals
% --------------------------------------------


for k = 1:nModOuts
    if(tcatInputDataStruct.diagnosticFileAvailable(k))

        plotOffset = max(nanstd([barGraphDataForParallelXTalkStruct.rmsValue])) * plotsOffsetFactor;

        plot(barGraphDataForParallelXTalkStruct(k).rmsValue(:) + k*plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        % attach a text label at the end of the line
        text(numberOfFgsParallelPixels, barGraphDataForParallelXTalkStruct(k).rmsValue(end) + k*plotOffset,  ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',11, 'fontweight','b');
        hold on;
    end
end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 11);
xlabel('Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel({'RMS of Weighted RMS Residual'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'RMS of Weighted RMS Residual for all'; 'Parallel Transfer Crosstalk Pixel Types across each ModOut Superposed'});
title(titleStr, 'fontsize',11,'fontweight','b');

%
titleStr = 'RMS of Weighted RMS Residual for all Parallel Transfer Crosstalk Pixel Types across each ModOut Superposed';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
%__________________________________________________________________________
% plot of histograms of weighted RMS residuals of fit (from BART) for all
% frame transfer cross talk pixel types (1 through 16) for one modout. Each
% figure contains frame transfer cross talk pixels of all types plotted for
% one modout. There are a total of 84 such plots.
%__________________________________________________________________________

numberOfFgsFramePixels = xTalkOutputStruct.numberOfFgsFramePixels;


% get the xBinLocations from the data
stdMin = Inf(numberOfFgsFramePixels,1);

for k = 1:numberOfFgsFramePixels

    stdMin(k) = min( max(nanstd(frameTransferXtalkPixelStruct(k).weightedRMSresidual, [],2)), stdMin(k));

end

xBinLocations =  linspace(-max(stdMin),max(stdMin), nBins);

barGraphData = NaN( length(xBinLocations),numberOfFgsFramePixels);

meanValue = NaN(numberOfFgsFramePixels,1);

% rms = norm(x)/sqrt(n)
rmsValue = NaN(numberOfFgsFramePixels,1);


barGraphDataForFrameXTalkStruct = repmat(struct('barGraphData', barGraphData, 'meanValue', meanValue, 'rmsValue', rmsValue), nModOuts,1);

for k = 1:nModOuts

    for j = 1:numberOfFgsFramePixels

        if(tcatInputDataStruct.diagnosticFileAvailable(k))

            % histc is not affected by NaNs in the data - no need to filter
            histData = frameTransferXtalkPixelStruct(j).weightedRMSresidual(k,:);

            % remove mean after excluding NaN/Inf
            validIndex = find(isfinite(histData));

            histData = histData(validIndex);

            meanValue(j) = nanmean(histData);

            rmsValue(j) = norm(histData)/sqrt(length(histData));

            histData = histData - meanValue(j);

            barGraphDataForFrameXTalkStruct(k).barGraphData(:,j) = histc(histData, xBinLocations);
            barGraphDataForFrameXTalkStruct(k).meanValue(j) = meanValue(j);
            barGraphDataForFrameXTalkStruct(k).rmsValue(j) = rmsValue(j);


        end

    end
end

%
if(plotHistogramsFlag)

    for k = 1:nModOuts
        if(tcatInputDataStruct.diagnosticFileAvailable(k))

            [mod out] = convert_to_module_output(k);

            figure;

            h = bar3(xBinLocations, barGraphDataForFrameXTalkStruct(k).barGraphData,  'detached');

            shading interp
            for i = 1:length(h)
                zdata = get(h(i),'Zdata');
                set(h(i),'Cdata',zdata)
                set(h,'EdgeColor','k')
            end
            colorbar;


            set(gca, 'fontsize', 11);
            xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
            zlabel('Pixel Count', 'fontsize',11,'fontweight','b');
            ylabel({'Scatter of Mean Removed Residuals'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

            titleStr = ({'Mean Removed Histograms of Weighted RMS Residual for Frame Transfer Crosstalk Pixels'; ['for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k) ]});
            title(titleStr, 'fontsize',11,'fontweight','b');


            titleStr = ['Mean Removed Histograms of Weighted RMS Residual for Frame Transfer Crosstalk Pixels for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k) ];
            plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

            close all;

        end
    end

end

% --------------------------------------------
% one plot of means of residuals
% --------------------------------------------



% need 32 colors
colorSpec = zeros(nModOuts, 3); % R, G, B colors

shuffleOrder = randperm(nModOuts);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,1) = linspace(0.001, 1, nModOuts);
shuffleOrder = randperm(nModOuts);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,2) = linspace(0.001, 1, nModOuts);
shuffleOrder = randperm(nModOuts);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,3) = linspace(0.001, 1, nModOuts);

for k = 1:nModOuts
    if(tcatInputDataStruct.diagnosticFileAvailable(k))

        plot3(1:numberOfFgsFramePixels, repmat(k,numberOfFgsFramePixels,1), barGraphDataForFrameXTalkStruct(k).meanValue(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);

        hold on;
    end
end

view([-3.5, 66]);

set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Module/Output', 'fontsize',11,'fontweight','b');
zlabel({'RMS of Weighted RMS Residual'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');


if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end
grid on


titleStr = ({'Mean of Weighted RMS Residual for all'; 'Frame Transfer Crosstalk Pixel Types across each ModOut'});
title(titleStr, 'fontsize',11,'fontweight','b');

titleStr = 'Mean of Weighted RMS Residual for all Frame Transfer Crosstalk Pixel Types across each ModOut';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


% --------------------------------------------
% one plot of rms of rms residuals
% --------------------------------------------


for k = 1:nModOuts
    if(tcatInputDataStruct.diagnosticFileAvailable(k))

        plot3(1:numberOfFgsFramePixels, repmat(k,numberOfFgsFramePixels,1), barGraphDataForFrameXTalkStruct(k).rmsValue(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);

        hold on;
    end
end

view([-3.5, 66]);

set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Module/Output', 'fontsize',11,'fontweight','b');
zlabel({'RMS of Weighted RMS Residual'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');


if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end
grid on


titleStr = ({'RMS of Weighted RMS Residual for all'; 'Frame Transfer Crosstalk Pixel Types across each ModOut'});
title(titleStr, 'fontsize',11,'fontweight','b');


titleStr = 'RMS of Weighted RMS Residual for all Frame Transfer Crosstalk Pixel Types across each ModOut';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


% --------------------------------------------
% one plot of means of residuals
% --------------------------------------------

for k = 1:nModOuts
    if(tcatInputDataStruct.diagnosticFileAvailable(k))

        plotOffset = max(nanstd([barGraphDataForFrameXTalkStruct.meanValue])) * plotsOffsetFactor;

        plot(barGraphDataForFrameXTalkStruct(k).meanValue(:)+ k*plotOffset,'p-', 'color', colorSpec(k,:),'LineWidth', 1);
        % attach a text label at the end of the line
        text(numberOfFgsFramePixels, barGraphDataForFrameXTalkStruct(k).meanValue(end)+ k*plotOffset,  ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',11, 'fontweight','b');


        hold on;
    end
end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel({'Mean of Weighted RMS Residual'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'Mean of Weighted RMS Residual for all'; 'Frame Transfer Crosstalk Pixel Types across each ModOut Superposed'});
title(titleStr, 'fontsize',11,'fontweight','b');

titleStr = 'Mean of Weighted RMS Residual for all Frame Transfer Crosstalk Pixel Types across each ModOut Superposed';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


% --------------------------------------------
% one plot of rms of rms residuals
% --------------------------------------------


for k = 1:nModOuts
    if(tcatInputDataStruct.diagnosticFileAvailable(k))

        plotOffset = max(nanstd([barGraphDataForFrameXTalkStruct.rmsValue])) * plotsOffsetFactor;
        plot(barGraphDataForFrameXTalkStruct(k).rmsValue(:)+ k*plotOffset,'p-', 'color', colorSpec(k,:),'LineWidth', 1);
        % attach a text label at the end of the line
        text(numberOfFgsFramePixels, barGraphDataForFrameXTalkStruct(k).rmsValue(end)+ k*plotOffset,  ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',11, 'fontweight','b');

        hold on;
    end
end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);


set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel({'RMS of Weighted RMS Residual'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'RMS of Weighted RMS Residual for all'; 'Frame Transfer Crosstalk Pixel Types across each ModOut Superposed'});
title(titleStr, 'fontsize',11,'fontweight','b');


titleStr = 'RMS of Weighted RMS Residual for all Frame Transfer Crosstalk Pixel Types across each ModOut Superposed';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;



%__________________________________________________________________________
% move image files to a directory
%__________________________________________________________________________


dirNameStr = 'residuals_plot_module_output';
if(~exist(dirNameStr, 'dir'))
    eval(['mkdir ' dirNameStr]);
end
sourceFileStr = '*ModOut*.*';
eval(['movefile '''  sourceFileStr '''  ' dirNameStr ' ' '''f''']);


%__________________________________________________________________________
% save computed values
%__________________________________________________________________________


modOutPlotsResidualForFrameXTalkStruct  = barGraphDataForFrameXTalkStruct;
modOutPlotsResidualForParallelXTalkStruct =  barGraphDataForParallelXTalkStruct;


save modOutPlotResidualData.mat modOutPlotsResidualForFrameXTalkStruct modOutPlotsResidualForParallelXTalkStruct;


return




