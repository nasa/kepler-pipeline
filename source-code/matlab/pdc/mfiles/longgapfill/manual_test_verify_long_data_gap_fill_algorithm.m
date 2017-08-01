%function self = test_verify_long_data_gap_fill_algorithm(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_verify_long_data_gap_fill_algorithm(self)
%
%
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testPdcClass('test_verify_long_data_gap_fill_algorithm'));


%--------------------------------------------------------------------------
% Step 1: generate data for testing the short data gap fill science algorithm
% interface from an ETEM run
% The pwd is path/to/matlab/pdc
%--------------------------------------------------------------------------

% presentDir = pwd;
% cd .. % now in the pdc directory
% currentDirectory = pwd;
% cd ..% now in matlab directory
% cd ..% now in code directory
% cd ..% now in soc directory
%pdcInputs = pdc_generate_data_for_fill_long_data_gaps('160100', 'path/to/etem/quarter/1/', nFewStars,debugLevel);



% override nominal data loss percentage
% introduce nStarsPerCategory - 10% data gaps, including monthly contact gap
% no safemode gaps (?) (leave safemode gaps for long gap fill algorithm)

% clear;
% clc;
% close all;
%

function manual_test_verify_long_data_gap_fill_algorithm()
clear;
clc;
close all;
randn('state', 0);

constantsStruct.totalFractionalLoss = 0.20;
constantsStruct.nCadencePerDay = 48; % 48 samples per day
constantsStruct.daysInAMonth = 30; % 30 days in a month
constantsStruct.safeModeDuration = 8; % safe mode lasting 8 days
constantsStruct.maxSafeModes = 6; % max. number of safemodes
constantsStruct.missionDurationMonths = 48;
constantsStruct.nominalFractionalLoss = 0.125;
constantsStruct.defaultFractionalLoss = 0.05;


gapFillParametersStruct.madXFactor = 10;
gapFillParametersStruct.maxGiantTransitDurationInHours = 72;
gapFillParametersStruct.maxDetrendPolyOrder = 25;
gapFillParametersStruct.maxArOrderLimit =  25; %% max AR model order limit set for choose_fpe_model_order function.
gapFillParametersStruct.maxCorrelationWindowXFactor =  5; % samples in giant transit are excluded for filling in normal missing points, so don't change this
gapFillParametersStruct.cadenceDurationInMinutes = 30;
gapFillParametersStruct.gapFillModeIsAddBackPredictionError = true;
gapFillParametersStruct.waveletFamily = 'daub';
gapFillParametersStruct.waveletFilterLength = 12;


nStarsPerCategory = 1;
gapScenario = 'worst';


% run100200
% run110300
% run120400
% run130200
% run140400
% run150200
% run160300
% run170100
% run180300
% run190200
% run200200
% run20200
% run220400
% run230300
% run240100
% run60200
% run70300
% run80400
% run90100

%pdcLongGapFillInputs = pdc_generate_data_for_fill_long_data_gaps('160300', '\path\to\etem\quarter\1\', nStarsPerCategory, gapScenario, constantsStruct);
%pdcLongGapFillInputs = pdc_generate_data_for_fill_long_data_gaps(140400', 'C:\path\to\matlab\pdc\test\', nStarsPerCategory, gapScenario, constantsStruct);
pdcLongGapFillInputs = pdc_generate_data_for_fill_long_data_gaps('3000', '/path/to/matlab/pdc/', nStarsPerCategory, gapScenario, constantsStruct);



% cd(currentDirectory);

[gapSizes] = find_datagap_sizes(pdcLongGapFillInputs.dataGapIndicators);
pdcLongGapFillInputs.gapSizes = gapSizes;



dataGapIndicators = pdcLongGapFillInputs.dataGapIndicators;
debugFlag = 0;
pdcLongGapFillInputs.debugFlag = debugFlag;
powerOfTwoLengthFlag = true;
pdcLongGapFillInputs.powerOfTwoLengthFlag = powerOfTwoLengthFlag;


[nCadences, nFlux] = size(pdcLongGapFillInputs.flux);
pdcLongGapFillOutputs.fluxWithGapsFilled = zeros(nCadences, nFlux);

scalingFilterCoefficients = daubechies_low_pass_scaling_filter(12);
pdcLongGapFillInputs.scalingFilterCoefficients = scalingFilterCoefficients;
close all;
clc;
printPlots = true;

for ii = 1:nFlux
    close all;

    fprintf('processing %d/%d, start = %d\n', ii, nFlux, ii);

    fluxWithGaps = pdcLongGapFillInputs.fluxWithGaps(:,ii);
    fluxTrue = pdcLongGapFillInputs.flux(:,ii);
    dataGapIndicators  = pdcLongGapFillInputs.dataGapIndicators;
    cadencesPerDay = 48;
    debugFlag =0;

    tic

    [reconstructedFilledTimeSeries, varianceAdjustedWaveletDetailCoefftsAtEachScale] = ...
        fill_long_data_gaps(fluxWithGaps, dataGapIndicators,  scalingFilterCoefficients, debugFlag, gapFillParametersStruct,powerOfTwoLengthFlag);


    pdcLongGapFillOutputs.fluxWithGapsFilled(:,ii) =  reconstructedFilledTimeSeries(1:nCadences);


    t1 = toc;
    fprintf('fill_long_data_gap took %f seconds\n', t1);

    nLength = length(fluxTrue);
    filterLength = length(scalingFilterCoefficients);

    % find out how many stages of filtering to do
    % for any signal that is band limited, there will be an upper nScales j = J,
    % above which the wavelet coefficients are negligibly small
    % nScales = log2(nLength)-floor(log2(filterLength))+1;


    nExtendedLength = length(reconstructedFilledTimeSeries);
    fluxTrue(nLength+1:nExtendedLength) = reconstructedFilledTimeSeries(nLength+1:nExtendedLength);
    nScales = round(log2(nExtendedLength)-floor(log2(filterLength)));

    [originalWaveletDetailCoefftsAtEachScale] = overcomplete_wavelet_transform(fluxTrue,scalingFilterCoefficients,nScales);

    waveletCoefftStruct(1).waveletTransform = originalWaveletDetailCoefftsAtEachScale;
    %    waveletCoefftStruct(1).titleString = {'Original Wavelet Coefficients for Each Scale'};
    waveletCoefftStruct(1).titleString = ['Star' num2str(ii)];



    waveletCoefftStruct(2).waveletTransform = varianceAdjustedWaveletDetailCoefftsAtEachScale;
    waveletCoefftStruct(2).titleString = {'Variance Adjusted Wavelet Coefficients for Each Scale'};

    [nScales] = size(varianceAdjustedWaveletDetailCoefftsAtEachScale, 2);

    plot_wavelet_detail_coefficients(waveletCoefftStruct, dataGapIndicators, nScales, printPlots, cadencesPerDay );

    tic
    [h1 h2 h3] = plot_data_gap_fill_results(~dataGapIndicators, fluxTrue(1:nLength), fluxWithGaps(1:nLength), reconstructedFilledTimeSeries(1:nLength));
    tn = toc;
    fprintf('plot time series %f seconds\n', tn);


    hold on;

    legend([h1 h2 h3 ],{'true','with gaps','gaps filled and variance adjusted' });

    set(gca,'fontsize',8);

    if(printPlots)
        fileNameStr = ['GapFilled_vs_Truth_For_Star_' num2str(ii)];
        paperOrientationFlag = false;
        includeTimeFlag = false;
        printJpgFlag = true;

        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    end;


    fprintf('\n\n')

    close all;
end;
%==========================================================================
function plot_wavelet_detail_coefficients(waveletCoefftStruct,dataGapIndicators,nStopScale, printPlots, cadencesPerDay)
nLength = length(dataGapIndicators);
nScalesPerFigure = 5;


[plotHandles]  = plot_each_wavelet_scale_and_mark_gaps(waveletCoefftStruct, dataGapIndicators,nLength, nStopScale, cadencesPerDay, nScalesPerFigure); % plot only the original length

for k=1:length(plotHandles)

    figure(plotHandles(k)); % bring the focus back to the figure

    if(length(plotHandles) >1)
        subplot(nScalesPerFigure,1,1);
    else
        subplot(nStopScale,1,1);
    end

    title(waveletCoefftStruct(1).titleString);
    legend('original time series', 'after long gap fill');

    subplot(nScalesPerFigure,1,nScalesPerFigure);

    xlabel('Time in days');
    set(gca,'fontsize',6);

    if(printPlots)
        fileNameStr = [char(waveletCoefftStruct(1).titleString) '_' num2str(k)];
        paperOrientationFlag = false;
        includeTimeFlag = false;
        printJpgFlag = true;

        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    end;
end;


return;


function [plotHandles] = plot_each_wavelet_scale_and_mark_gaps(waveletCoefftStruct, dataGapIndicators,nLength, nStopScale, cadencesPerDay, nScalesPerFigure)




xAxisValues = (1:nLength)./cadencesPerDay;


nRows = nScalesPerFigure;

if(nStopScale > 10)
    nStopScale = 10;
    % warning('PDC:LongGapFill:Plot', 'Number of wavelet scales exceeds 10; plotting only 10');
end;

nPlots = ceil(nStopScale/nRows); % how many figures to spawn....


plotHandles = zeros(nPlots,1);

for jj = 1:nPlots

    plotHandles(jj) = figure;

    if(jj == 1)
        iSubPlotStart = 1;
        iSubPlotEnd = min(nStopScale,nRows);
    else
        iSubPlotStart = iSubPlotEnd+1;
        iSubPlotEnd = min(iSubPlotEnd+nRows, nStopScale);
    end;

    for i = iSubPlotStart:iSubPlotEnd
        if(i > nRows)
            ii = i - fix((i-1)/nRows)*nRows;
        else
            ii = i;
        end;

        subplot(nRows,1,ii);
        %plot(xAxisValues, waveletTransform(i,:),'b');
        plot(xAxisValues, waveletCoefftStruct(1).waveletTransform(1:nLength,i), 'b');
        hold on;
        plot(xAxisValues, waveletCoefftStruct(2).waveletTransform(1:nLength,i), 'm');

        maxValue = max(waveletCoefftStruct(1).waveletTransform(1:nLength,i));
        maxValue = max(maxValue,max(waveletCoefftStruct(1).waveletTransform(1:nLength,i)));

        hold on;
        iGapIndices = find(dataGapIndicators);
        plot( xAxisValues(iGapIndices), dataGapIndicators(iGapIndices).*maxValue, 'r.' );

        %axis tight;

        set(gca, 'FontSize',7);
    end
end;
drawnow;
return
