function plot_hist_of_coeffts_for_all_pixel_types_in_one_modout(tcatInputDataStruct, xTalkOutputStruct, ...
    parallelXtalkPixelStruct, frameTransferXtalkPixelStruct, plotHistogramsFlag)
%______________________________________________________________________
% function plot_hist_of_coeffts_for_all_pixel_types_in_one_modout(tcatInputDataStruct, xTalkOutputStruct, ...
%     parallelXtalkPixelStruct, frameTransferXtalkPixelStruct)
%
%   plotHistogramsFlag is an optional Boolean flag when set to false skips
%   plotting the histograms of parallel transfer crosstalk pixels annd
%   frame transfer crosstalk pixels. This is useful for debugging or
%   quickly getting only the mean and rms/std superposed plots. If this
%   parameter is not provided, it defaults to true and the histograms are
%   plotted.
%
%
%   nanmean, nanstd built-in functions are used  instead of the commonly
%   used mean, std to be robust against NaNs in the data.
%
%
% This function computes the mean, rms, or histograms of thermal
% coefficients for parallel/frame transfer cross talk pixels and produces
% Mod/Out type plots
%
%     Type 1: A stack of mean removed histograms (3D plots) ofthermal
%             coefficients (1 and 2) of fit (from BART) for all
%             parallel/frame transfer cross talk pixel types (1 through 32/
%             1 through 16) for one modout. Each figure contains
%             parallel/frame transfer cross talk pixels of all types
%             plotted for one modout. There is a total of 84 (or however
%             many mod/outs are available) such plots for parallel cross
%             talk and 84 plots for frame transfer crosstalk pixels
%
%             x axis - 'Parallel Crosstalk Pixel Type' or 'Frame Transfer
%                       Crosstalk Pixel Type'
%             y axis - 'Scatter around zero mean'
%             z axis - 'Pixel count'
%
%     Type 2: Plots of mean of thermal coefficients (1 and 2) for
%             parallel/frame transfer pixels (3D plot and a superposed plot
%             where each curve is offset from the rest) a total of 4 plots
%
%             x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'  or
%                      'Frame Transfer Crosstalk Pixel Type'
%             y axis - 'Module/Output'
%             z axis - 'Mean of Linear Coefficient'  or
%                      'Mean of Constant Coefficient'
%
%     Type 3: Plots of rms of thermal coefficients (1 and 2) for
%             parallel/frame transfer pixels (3D plot and a superposed plot
%             where each curve is offset from the rest) a total of 4 plots
%
%             x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'
%             y axis - 'Module/Output'
%             z axis - 'Std of Linear Coefficient'  or
%                      'Std of Constant Coefficient'
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
stdMin1 = Inf(numberOfFgsParallelPixels,1);
stdMin2 = Inf(numberOfFgsParallelPixels,1);

for k = 1:numberOfFgsParallelPixels

    stdMin1(k) = min( max(nanstd(parallelXtalkPixelStruct(k).fittedThermalCoefficients1, [],2)), stdMin1(k));
    stdMin2(k) = min( max(nanstd(parallelXtalkPixelStruct(k).fittedThermalCoefficients2, [],2)), stdMin2(k));

end


xBinLocations1 =  linspace(-max(stdMin1),max(stdMin1), nBins);
xBinLocations2 =  linspace(-max(stdMin2),max(stdMin2), nBins);



yTickStr = cell(nModOuts,1);

[modules, outputs] = convert_to_module_output(1:nModOuts);

for j = 1:nModOuts

    yTickStr(j) = {['[' num2str(modules(j)) ', ' num2str(outputs(j)) ']']};

end


%__________________________________________________________________________
% plot of histograms of mean removed constant and linear Coefficients of fit (also
% known as thermal coefficients) (from BART) for parallel cross talk pixels
% of type 1 (through 32) across the entire focal plane.
% Each figure contains parallel cross talk pixel of one type plotted across
% the 84 modouts.
%__________________________________________________________________________

numberOfFgsParallelPixels = xTalkOutputStruct.numberOfFgsParallelPixels;

barGraphData1 = NaN( length(xBinLocations1), numberOfFgsParallelPixels);
barGraphData2 = NaN( length(xBinLocations2), numberOfFgsParallelPixels);

meanValue = NaN(numberOfFgsParallelPixels,1);
% rms = norm(x)/sqrt(n)
stdValue = NaN(numberOfFgsParallelPixels,1);

barGraphDataForParallelXTalkStruct = repmat(struct('barGraphData1', barGraphData1, 'meanValue1', meanValue, 'stdValue1', stdValue, ...
    'barGraphData2', barGraphData2, 'meanValue2', meanValue, 'stdValue2', stdValue), nModOuts,1);


for k = 1:nModOuts

    for j = 1:numberOfFgsParallelPixels

        if(tcatInputDataStruct.modelFileAvailable(k))

            % constant coefficient from polynomial fit of each FFI pixel over a
            % range of tempertaure (thermal coefficient1)

            histData = parallelXtalkPixelStruct(j).fittedThermalCoefficients1(k,:);

            % remove mean after excluding NaN/Inf
            validIndex = find(isfinite(histData));

            histData = histData(validIndex);

            meanValue(j) = nanmean(histData);

            stdValue(j) = nanstd(histData);

            histData = histData - meanValue(j);

            barGraphDataForParallelXTalkStruct(k).barGraphData1(:,j) = histc(histData, xBinLocations1);
            barGraphDataForParallelXTalkStruct(k).meanValue1(j) = meanValue(j);
            barGraphDataForParallelXTalkStruct(k).stdValue1(j) = stdValue(j);


            % linear coefficient of polynomial fit (thermal coefficient2)

            histData = parallelXtalkPixelStruct(j).fittedThermalCoefficients2(k,:);

            % remove mean after excluding NaN/Inf
            validIndex = find(isfinite(histData));

            histData = histData(validIndex);

            meanValue(j) = nanmean(histData);

            stdValue(j) = nanstd(histData);

            histData = histData - meanValue(j);

            barGraphDataForParallelXTalkStruct(k).barGraphData2(:,j) = histc(histData, xBinLocations2);
            barGraphDataForParallelXTalkStruct(k).meanValue2(j) = meanValue(j);
            barGraphDataForParallelXTalkStruct(k).stdValue2(j) = stdValue(j);

        end

    end
end

% numberOfFgsParallelPixels plots of histograms
if(plotHistogramsFlag)

    for k = 1:nModOuts

        if(tcatInputDataStruct.modelFileAvailable(k))

            [mod out] = convert_to_module_output(k);

            subplot(2,1,1);

            h = bar3(xBinLocations1, barGraphDataForParallelXTalkStruct(k).barGraphData1,  'detached');

            shading interp
            for i = 1:length(h)
                zdata = get(h(i),'Zdata');
                set(h(i),'Cdata',zdata)
                set(h,'EdgeColor','k')
            end
            colorbar;


            set(gca, 'fontsize', 10);

            xlabel('Parallel Crosstalk Pixel Type', 'fontsize',10,'fontweight','b');
            zlabel('Pixel Count', 'fontsize',10,'fontweight','b');
            ylabel({'Scatter of Mean Removed Linear'; 'Coeffficient (DN/integration/C)'}, 'fontsize',10,'fontweight','b');

            titleStr = ({'Mean Removed Histograms of Linear Coefficient for Parallel Transfer Crosstalk Pixels'; ['for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k)] });

            title(titleStr, 'fontsize',10,'fontweight','b');

            subplot(2,1,2);
            h = bar3(xBinLocations2, barGraphDataForParallelXTalkStruct(k).barGraphData2,  'detached');

            shading interp
            for i = 1:length(h)
                zdata = get(h(i),'Zdata');
                set(h(i),'Cdata',zdata)
                set(h,'EdgeColor','k')
            end
            colorbar;


            set(gca, 'fontsize', 10);
            xlabel('Parallel Crosstalk Pixel Type', 'fontsize',10,'fontweight','b');
            zlabel('Pixel Count', 'fontsize',10,'fontweight','b');
            ylabel({'Scatter of Mean Removed Constant'; 'Coefficient (DN/integration)'}, 'fontsize',10,'fontweight','b');

            titleStr = ({'Mean Removed Histograms of Constant Coefficient for Parallel Transfer Crosstalk Pixels'; ['for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k)]});
            title(titleStr, 'fontsize',10,'fontweight','b');


            titleStr = ['Histograms of Thermal Coefficients 1 and 2 for Parallel Transfer Crosstalk Pixels for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k) ];
            plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

            close all;
        end

    end
end
% -------------------------------------------------------------------------
% one plot of means of constant coefficient and linear coefficient of
% polynomial fit by  BART
% -------------------------------------------------------------------------

% need 32 colors
colorSpec = NaN(nModOuts, 3); % R, G, B colors

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

    if(tcatInputDataStruct.modelFileAvailable(k))
        subplot(2,1,1);
        plot3(1:numberOfFgsParallelPixels, repmat(k,numberOfFgsParallelPixels,1), barGraphDataForParallelXTalkStruct(k).meanValue1(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);
        hold on;

        subplot(2,1,2);
        plot3(1:numberOfFgsParallelPixels, repmat(k,numberOfFgsParallelPixels,1), barGraphDataForParallelXTalkStruct(k).meanValue2(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);
        hold on;
    end
end


subplot(2,1,1);
set(gca, 'fontsize', 11);

xlabel('Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Module/Output', 'fontsize',11,'fontweight','b');
zlabel({'Mean of Linear Coefficient of Fit'; '(DN/integration/C)'}, 'fontsize',11,'fontweight','b');


if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end


grid on;

titleStr = 'Mean of Linear Coefficent for All Parallel Transfer Crosstalk Pixel Types across  each ModOut';
title(titleStr, 'fontsize',11,'fontweight','b');


subplot(2,1,2);
set(gca, 'fontsize', 11);
xlabel('Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Module/Output', 'fontsize',11,'fontweight','b');
zlabel({'Mean of Constant Coefficient of Fit'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end

grid on;

titleStr = ({'Mean of Constant Coefficent for All Parallel Transfer'; 'Crosstalk Pixel Types across each ModOut'});

title(titleStr, 'fontsize',11,'fontweight','b');

titleStr = 'Mean of Thermal Coefficents 1 and 2 for All Parallel Transfer Crosstalk Pixel Types across each ModOut';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


% -------------------------------------------------------------------------
% one plot of rms linear coefficient and constant coefficient of fit
% -------------------------------------------------------------------------

for k = 1:nModOuts

    if(tcatInputDataStruct.modelFileAvailable(k))
        subplot(2,1,1);
        plot3(1:numberOfFgsParallelPixels, repmat(k,numberOfFgsParallelPixels,1), barGraphDataForParallelXTalkStruct(k).stdValue1(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);
        hold on;

        subplot(2,1,2);
        plot3(1:numberOfFgsParallelPixels, repmat(k,numberOfFgsParallelPixels,1), barGraphDataForParallelXTalkStruct(k).stdValue2(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);
    end
    hold on;

end

view([-3.5, 66]);

subplot(2,1,1);
set(gca, 'fontsize', 11);
xlabel('Module/Output', 'fontsize',11,'fontweight','b');
ylabel('FGS Parallel Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
zlabel({'Std of Linear Coefficient'; '(DN/integration/C)'}, 'fontsize',11,'fontweight','b');

grid on;

titleStr = ({'Std of Linear Coefficent for All Parallel Transfer'; 'Crosstalk Pixel Types across each ModOut'});

title(titleStr, 'fontsize',11,'fontweight','b');

if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end


subplot(2,1,2);
set(gca, 'fontsize', 11);
xlabel('Module/Output', 'fontsize',11,'fontweight','b');
ylabel( 'FGS Parallel Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
zlabel( {'Std of Constant Coefficient'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

grid on;

titleStr = ({'Std of Constant Coefficent for All Parallel Transfer'; 'Crosstalk Pixel Types across each ModOut'});

title(titleStr, 'fontsize',11,'fontweight','b');

if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end


titleStr = 'Std of Thermal Coefficents 1 and 2 for All Parallel Transfer Crosstalk Pixel Types across each ModOut';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

% -------------------------------------------------------------------------
% one plot of means of linear coefficient snd constant coefficient of fit
% -------------------------------------------------------------------------

h1 = subplot(2,1,1);
h2 = subplot(2,1,2);


for k = 1:nModOuts
    if(tcatInputDataStruct.modelFileAvailable(k))

        subplot(h1);
        plotOffset = max(nanstd([barGraphDataForParallelXTalkStruct.meanValue1])) * plotsOffsetFactor;

        plot(barGraphDataForParallelXTalkStruct(k).meanValue1(:) + k*plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        % attach a text label at the end of the line
        text(numberOfFgsParallelPixels, barGraphDataForParallelXTalkStruct(k).meanValue1(end) + k*plotOffset, ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',10, 'fontweight','b');

        hold on;


        subplot(h2);
        plotOffset = max(nanstd([barGraphDataForParallelXTalkStruct.meanValue2])) * plotsOffsetFactor;

        plot(barGraphDataForParallelXTalkStruct(k).meanValue2(:) + plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        text(numberOfFgsParallelPixels, barGraphDataForParallelXTalkStruct(k).meanValue2(end) + k*plotOffset, ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',10, 'fontweight','b');


        % attach a text label at the end of the line
        hold on;
    end
end



subplot(h1);
xRange = xlim;
xlim([xRange(1) xRange(2)+2]);


set(gca, 'fontsize', 11);
xlabel(h1,'Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel(h1,{'Mean of Linear Coefficient'; '(DN/integration/C)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'Mean of Linear Coefficient for All Parallel Transfer'; 'Crosstalk Pixel Types across each ModOut Superposed'});

title(h1,titleStr, 'fontsize',11,'fontweight','b');


subplot(h2);
xRange = xlim;
xlim([xRange(1) xRange(2)+2]);


set(gca, 'fontsize', 11);
xlabel(h2,'Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel(h2,{'Mean of Constant Coefficient'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'Mean of Constant Coefficient for All Parallel Transfer'; 'Crosstalk Pixel Types across each ModOut Superposed'});

title(h2,titleStr, 'fontsize',11,'fontweight','b');


titleStr = 'Mean of Thermal Coefficients 1 and 2 for All Parallel Transfer Crosstalk Pixel Types across each ModOut Superposed';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


%----------------------------- --------------------------------------------
% one plot of rms of linear and constant coefficients
%----------------------------- --------------------------------------------

h1 = subplot(2,1,1);
h2 = subplot(2,1,2);

for k = 1:nModOuts

    if(tcatInputDataStruct.modelFileAvailable(k))

        subplot(h1);

        plotOffset = max(nanstd([barGraphDataForParallelXTalkStruct.stdValue1])) * plotsOffsetFactor;

        plot(barGraphDataForParallelXTalkStruct(k).stdValue1(:) + k*plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        text(numberOfFgsParallelPixels, barGraphDataForParallelXTalkStruct(k).stdValue1(end)+k*plotOffset, ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',10, 'fontweight','b');

        hold on;

        subplot(h2);

        plotOffset = max(nanstd([barGraphDataForParallelXTalkStruct.stdValue2])) * plotsOffsetFactor;

        plot(barGraphDataForParallelXTalkStruct(k).stdValue2(:) +k*plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        text(numberOfFgsParallelPixels, barGraphDataForParallelXTalkStruct(k).stdValue2(end)+k*plotOffset, ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',10, 'fontweight','b');

        hold on;
    end
end


subplot(h1);
xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 11);

xlabel(h1,'Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel(h1,{'Std  of Linear Coefficient'; '(DN/integration/C)'}, 'fontsize',11,'fontweight','b');


titleStr = ({'Std of Linear Coefficient for All Parallel Transfer'; 'Crosstalk Pixel Types across each ModOut Superposed'});

title(h1, titleStr, 'fontsize',11,'fontweight','b');

subplot(h2);
xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 11);

xlabel(h2,'Parallel Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel(h2,{'Std of Constant Coefficient'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'Std of Constant Coefficient for All Parallel Transfer'; 'Crosstalk Pixel Types across each ModOut Superposed'});

title(h2,titleStr, 'fontsize',11,'fontweight','b');



titleStr = 'Std of Thermal Coefficients 1 and 2 for All Parallel Transfer Crosstalk Pixel Types across each ModOut Superposed';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;




%__________________________________________________________________________
% plot of histograms of thermal coefficients of fit (from BART) for frame
% transfer cross talk pixels of type 1 (through 16) across the entire focal
% plane.
% Each figure contains frame transfer cross talk pixel of one type plotted
% across the 84 modouts.
%__________________________________________________________________________

numberOfFgsFramePixels = xTalkOutputStruct.numberOfFgsFramePixels;

% get the xBinLocations from the data
stdMin1 = Inf(numberOfFgsFramePixels,1);
stdMin2 = Inf(numberOfFgsFramePixels,1);

for k = 1:numberOfFgsFramePixels

    stdMin1(k) = min( max(nanstd(frameTransferXtalkPixelStruct(k).fittedThermalCoefficients1, [],2)), stdMin1(k));
    stdMin2(k) = min( max(nanstd(frameTransferXtalkPixelStruct(k).fittedThermalCoefficients2, [],2)), stdMin2(k));

end


xBinLocations1 =  linspace(-max(stdMin1),max(stdMin1), nBins);
xBinLocations2 =  linspace(-max(stdMin2),max(stdMin2), nBins);



barGraphData1 = NaN( length(xBinLocations1),numberOfFgsFramePixels);
barGraphData2 = NaN( length(xBinLocations2),numberOfFgsFramePixels);

meanValue = NaN(numberOfFgsFramePixels,1);

% rms = norm(x)/sqrt(n)
stdValue = NaN(numberOfFgsFramePixels,1);

barGraphDataForFrameXTalkStruct = repmat(struct('barGraphData1', barGraphData1, 'meanValue1', meanValue, 'stdValue1', stdValue, ...
    'barGraphData2', barGraphData2, 'meanValue2', meanValue, 'stdValue2', stdValue), nModOuts,1);

for k = 1:nModOuts

    for j = 1:numberOfFgsFramePixels

        if(tcatInputDataStruct.modelFileAvailable(k))

            % linear coefficient of polynomial fit (thermal coefficient1)

            histData = frameTransferXtalkPixelStruct(j).fittedThermalCoefficients1(k,:);

            % remove mean after excluding NaN/Inf
            validIndex = find(isfinite(histData));

            histData = histData(validIndex);

            meanValue(j) = nanmean(histData);

            stdValue(j) = nanstd(histData);

            histData = histData - meanValue(j);

            barGraphDataForFrameXTalkStruct(k).barGraphData1(:,j) = histc(histData, xBinLocations1);
            barGraphDataForFrameXTalkStruct(k).meanValue1(j) = meanValue(j);
            barGraphDataForFrameXTalkStruct(k).stdValue1(j) = stdValue(j);


            % constant coefficient of polynomial fit (thermal coefficient2)
            histData = frameTransferXtalkPixelStruct(j).fittedThermalCoefficients2(k,:);

            % remove mean after excluding NaN/Inf
            validIndex = find(isfinite(histData));

            histData = histData(validIndex);

            meanValue(j) = nanmean(histData);

            stdValue(j) = nanstd(histData);

            histData = histData - meanValue(j);

            barGraphDataForFrameXTalkStruct(k).barGraphData2(:,j) = histc(histData, xBinLocations2);
            barGraphDataForFrameXTalkStruct(k).meanValue2(j) = meanValue(j);
            barGraphDataForFrameXTalkStruct(k).stdValue2(j) = stdValue(j);

        end

    end
end

%
if(plotHistogramsFlag)

    for k = 1:nModOuts

        if(tcatInputDataStruct.modelFileAvailable(k))

            [mod out] = convert_to_module_output(k);

            subplot(2,1,1);

            h = bar3(xBinLocations1, barGraphDataForFrameXTalkStruct(k).barGraphData1,  'detached');
            shading interp
            for i = 1:length(h)
                zdata = get(h(i),'Zdata');
                set(h(i),'Cdata',zdata)
                set(h,'EdgeColor','k')
            end
            colorbar;


            set(gca, 'fontsize', 10);
            xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',10,'fontweight','b');
            zlabel('Pixel Count', 'fontsize',10,'fontweight','b');
            ylabel({'Scatter of Mean Removed Linear'; 'Coefficient (DN/integration/C)'}, 'fontsize',10,'fontweight','b');

            titleStr = ({'Mean Removed Histograms of Linear Coefficient for Frame Transfer Crosstalk Pixels'; ['for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k)] });

            title(titleStr, 'fontsize',10,'fontweight','b');

            subplot(2,1,2);

            h = bar3(xBinLocations2, barGraphDataForFrameXTalkStruct(k).barGraphData2,  'detached');
            shading interp
            for i = 1:length(h)
                zdata = get(h(i),'Zdata');
                set(h(i),'Cdata',zdata)
                set(h,'EdgeColor','k')
            end
            colorbar;


            set(gca, 'fontsize', 10);
            xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',10,'fontweight','b');
            zlabel('Pixel Count', 'fontsize',11,'fontweight','b');
            ylabel({'Scatter of Mean Removed Constant Coefficient'; '(DN/integration)'}, 'fontsize',10,'fontweight','b');

            titleStr = ({'Mean Removed Histograms of Constant Coefficient for Frame Transfer Crosstalk Pixels'; ['for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k)] });

            title(titleStr, 'fontsize',10,'fontweight','b');


            titleStr = ['Thermal Coefficients 1 and 2 for Frame Transfer Crosstalk Pixel Types for Module ' num2str(mod) ' Output ' num2str(out), ' ModOut ', num2str(k) ];
            plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

            close all;

        end
    end

end

% -------------------------------------------------------------------------
% one plot of means of linear and constant coefficients
% -------------------------------------------------------------------------


% need 32 colors
colorSpec = NaN(nModOuts, 3); % R, G, B colors

shuffleOrder = randperm(nModOuts);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,1) = linspace(0.001, 1, nModOuts);
shuffleOrder = randperm(nModOuts);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,2) = linspace(0.001, 1, nModOuts);
shuffleOrder = randperm(nModOuts);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,3) = linspace(0.001, 1, nModOuts);


h1 = subplot(2,1,1);
h2 = subplot(2,1,2);

for k = 1:nModOuts

    if(tcatInputDataStruct.modelFileAvailable(k))

        subplot(h1);

        plot3(1:numberOfFgsFramePixels, repmat(k,numberOfFgsFramePixels,1), barGraphDataForFrameXTalkStruct(k).meanValue1(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);

        hold on;


        subplot(h2);

        plot3(1:numberOfFgsFramePixels, repmat(k,numberOfFgsFramePixels,1), barGraphDataForFrameXTalkStruct(k).meanValue2(:), 'p-', 'color', colorSpec(k,:),'LineWidth', 1);

        hold on;
    end
end



subplot(h1);
set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Module/Output', 'fontsize',11,'fontweight','b');
zlabel(h1, {'Mean of Linear Coefficient'; '(DN/integration/C)'}, 'fontsize',11,'fontweight','b');


if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end
grid on

titleStr = ({'Mean of Linear Coefficient for All Frame Transfer'; 'Crosstalk Pixel Types across each ModOut'});

title(h1, titleStr, 'fontsize',11,'fontweight','b');

grid on;


subplot(h2);
set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Module/Output', 'fontsize',11,'fontweight','b');
zlabel({'Mean of Constant Coefficient'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');


if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end
grid on

titleStr = ({'Mean of Constant Coefficient for All Frame Transfer'; 'Crosstalk Pixel Types across each ModOut'});

title(h1, titleStr, 'fontsize',11,'fontweight','b');
grid on;

titleStr = 'Mean of Thermal Coefficients 1 and 2 for All Frame Transfer Crosstalk Pixel Types across each ModOut';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


% -------------------------------------------------------------------------
% one plot of rms linear and constant coefficients
% -------------------------------------------------------------------------

h1 = subplot(2,1,1);
h2 = subplot(2,1,2);

for k = 1:nModOuts

    if(tcatInputDataStruct.modelFileAvailable(k))

        subplot(h1);
        plot3(1:numberOfFgsFramePixels, repmat(k,numberOfFgsFramePixels,1), barGraphDataForFrameXTalkStruct(k).stdValue1(:)  , 'p-', 'color', colorSpec(k,:),'LineWidth', 1);

        hold on;


        subplot(h2);
        plot3(1:numberOfFgsFramePixels, repmat(k,numberOfFgsFramePixels,1), barGraphDataForFrameXTalkStruct(k).stdValue2(:)  , 'p-', 'color', colorSpec(k,:),'LineWidth', 1);

        hold on;
    end
end




subplot(h1);
view([-3.5, 66]);
set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Module/Output', 'fontsize',11,'fontweight','b');
zlabel(h1, {'Std of Linear Coefficient'; '(DN/integration/C)'}, 'fontsize',11,'fontweight','b');


if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end
grid on

titleStr = ({'Std of Linear Coefficient for All Frame Transfer'; 'Crosstalk Pixel Types across each ModOut'});

title(h1, titleStr, 'fontsize',11,'fontweight','b');



subplot(h2);
view([-3.5, 66]);
set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel('Module/Output', 'fontsize',11,'fontweight','b');
zlabel({'Std of Constant Coefficient'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');


if(length(modOutsProcessed) > 10)
    set(gca, 'ytick', modOutsProcessed(1):4:modOutsProcessed(end));
    set(gca, 'yticklabel', yTickStr(modOutsProcessed(1):4:modOutsProcessed(end)));
else
    set(gca, 'ytick', modOutsProcessed);
    set(gca, 'yticklabel', yTickStr(modOutsProcessed));
end
grid on


titleStr = ({'Std of Constant Coefficient for All Frame Transfer'; 'Crosstalk Pixel Types across each ModOut'});

title(h2, titleStr, 'fontsize',11,'fontweight','b');


grid on;

titleStr = 'Std of Thermal Coefficients 1 and 2 for All Frame Transfer Crosstalk Pixel Types across each ModOut';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;



% -------------------------------------------------------------------------
% one plot of means of linear and constant coefficients
% -------------------------------------------------------------------------

h1 = subplot(2,1,1);
h2 = subplot(2,1,2);

for k = 1:nModOuts

    if(tcatInputDataStruct.modelFileAvailable(k))

        subplot(h1);

        plotOffset = max(nanstd([barGraphDataForFrameXTalkStruct.meanValue1])) * plotsOffsetFactor;

        plot(barGraphDataForFrameXTalkStruct(k).meanValue1(:) + k*plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        text(numberOfFgsFramePixels,  barGraphDataForFrameXTalkStruct(k).meanValue1(end) + k*plotOffset, ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',10, 'fontweight','b');

        % attach a text label at the end of the line
        hold on;


        subplot(h2);

        plotOffset = max(nanstd([barGraphDataForFrameXTalkStruct.meanValue2])) * plotsOffsetFactor;
        plot(barGraphDataForFrameXTalkStruct(k).meanValue2(:) + k*plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        % attach a text label at the end of the line
        text(numberOfFgsFramePixels,  barGraphDataForFrameXTalkStruct(k).meanValue2(end)+ k*plotOffset, ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',10, 'fontweight','b');


        hold on;
    end
end


subplot(h1);
xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel({'Mean of Linear Coefficient'; '(DN/integration/C)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'Mean of Linear Coefficient for All Frame Transfer Crosstalk'; 'Pixel Types across each ModOut Superposed'});

title(titleStr, 'fontsize',11,'fontweight','b');



subplot(h2);
xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel({'Mean of Constant Coefficient'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'Mean of Constant Coefficient for All Frame Transfer'; 'Crosstalk Pixel Types across each ModOut Superposed'});

title(titleStr, 'fontsize',11,'fontweight','b');


titleStr = 'Mean of Thermal Coefficients 1 and 2 for All Frame Transfer Crosstalk Pixel Types across each ModOut Superposed';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;


% -------------------------------------------------------------------------
% one plot of rms of linear and constant coefficients
% -------------------------------------------------------------------------

h1 = subplot(2,1,1);
h2 = subplot(2,1,2);

for k = 1:nModOuts
    if(tcatInputDataStruct.modelFileAvailable(k))


        subplot(h1);

        plotOffset = max(nanstd([barGraphDataForFrameXTalkStruct.stdValue1])) * plotsOffsetFactor;

        plot(barGraphDataForFrameXTalkStruct(k).stdValue1(:) + k*plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        % attach a text label at the end of the line
        text(numberOfFgsFramePixels, barGraphDataForFrameXTalkStruct(k).stdValue1(end)+ k*plotOffset, ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',10, 'fontweight','b');


        hold on;


        subplot(h2);
        plotOffset = max(nanstd([barGraphDataForFrameXTalkStruct.stdValue2])) * plotsOffsetFactor;

        plot(barGraphDataForFrameXTalkStruct(k).stdValue2(:) + k*plotOffset, 'p-','color', colorSpec(k,:),'LineWidth', 1);
        % attach a text label at the end of the line
        text(numberOfFgsFramePixels, barGraphDataForFrameXTalkStruct(k).stdValue2(end)+k*plotOffset, ['\rightarrow' repmat('.', unidrnd(10,1),1)' num2str(k)], 'color', colorSpec(k,:), 'fontsize',10, 'fontweight','b');


        hold on;
    end
end


subplot(h1);
xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b');
ylabel({'Std of Linear Coefficient'; '(DN/integration/C)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'Std of Linear Coefficient for All Frame Transfer'; 'Crosstalk Pixel Types across each ModOut Superposed'});

title(titleStr, 'fontsize',11,'fontweight','b');


subplot(h2);
xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 11);
xlabel('Frame Transfer Crosstalk Pixel Type', 'fontsize',11,'fontweight','b', 'fontsize',11,'fontweight','b');
ylabel({'Std of Constant Coefficient'; '(DN/integration)'}, 'fontsize',11,'fontweight','b');

titleStr = ({'Std of Constant Coefficient for All Frame Transfer'; 'Crosstalk Pixel Types across each ModOut Superposed'});

title(titleStr, 'fontsize',11,'fontweight','b');


titleStr = 'Std of Thermal Coefficients 1 and 2 for All Frame Transfer Crosstalk Pixel Types across each ModOut Superposed';
plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;




%__________________________________________________________________________
% move image files to a directory
%__________________________________________________________________________


dirNameStr = 'thermal_coefficients_plot_module_output';
if(~exist(dirNameStr, 'dir'))
    eval(['mkdir ' dirNameStr]);
end
sourceFileStr = '*ModOut*.*';
eval(['movefile '''  sourceFileStr '''  ' dirNameStr ' ' '''f''']);


%__________________________________________________________________________
% save computed values
%__________________________________________________________________________


modOutPlotsCoefftsForFrameXTalkStruct  = barGraphDataForFrameXTalkStruct;
modOutPlotsCoefftsForParallelXTalkStruct =  barGraphDataForParallelXTalkStruct;


save modOutPlotCoefftsData.mat modOutPlotsCoefftsForFrameXTalkStruct modOutPlotsCoefftsForParallelXTalkStruct;



return

