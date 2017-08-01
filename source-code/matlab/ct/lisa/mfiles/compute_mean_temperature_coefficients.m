function lisaOutputStruct = compute_mean_temperature_coefficients(nModOuts, parallelXtalkPixelStruct, ...
    frameTransferXtalkPixelStruct, serialXtalkPixelStruct, robustThreshold, plottingEnabledFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function lisaOutputStruct = compute_mean_temperature_coefficients(nModOuts, parallelXtalkPixelStruct, ...
%    frameTransferXtalkPixelStruct, serialXtalkPixelStruct, robustThreshold, plottingEnabledFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function computes the mean value of the linear temperature coefficients, the uncertainty of
% the mean value and the weighted mean square error of the linear temperature coefficients for
% each type of FGS crosstalk pixel [Frame (16), Parallel (32), and Serial (1)] for each module output
% from BART outputs, which are included in the input structure arrays parallelXtalkPixelStruct,
% frameTransferXtalkPixelStruct and serialXtalkPixelStruct.
%
% The following plots are generated:
%
% (1) Plots of linear temperature coefficients and the error bars of all pixels for each FGS crosstalk 
%     pixel type [Frame (16), Parallel (32), and Serial (1)] for each module output;
%
% (2) 2D plots of mean value of the linear temperature coefficients, sigma of the mean value and the
%     weighted mean square error of the linear temperature coefficients for each FGS crosstalk pixel
%     type across the focal plane.
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


close all;

if(~exist('plottingEnabledFlag', 'var'))
    plottingEnabledFlag = false;
end

% Allocate memory for lisaOutputStruct

nFrameTransferPixels = length(frameTransferXtalkPixelStruct);
nParallelPixels      = length(parallelXtalkPixelStruct);
nSerialPixels        = length(serialXtalkPixelStruct);

pixelFamilyStruct       = struct( 'rows',                             [], ...        % nPixels x 1 double array
                                  'columns',                          [], ...        % nPixels x 1 double array
                                  'temperatureCoefficients',          [], ...        % nPixels x 1 double array
                                  'sigmaTemperatureCoefficients',     [], ...        % nPixels x 1 double array
                                  'effectiveRobustWeights',           [], ...        % nPixels x 1 double array
                                  'coefficientGapIndicators',         [], ...        % nPixels x 1 logical array
                                  'meanTemperatureCoefficient',       [], ...        % double
                                  'sigmaMeanTemperatureCoefficient',  [], ...        % double
                                  'weightedMse',                      [] );          % double

lisaOutputStruct_modOut = struct( 'module',                           [],                                                 ...
                                  'output',                           [],                                                 ...
                                  'frameTransferPixelFamily',         repmat(pixelFamilyStruct, nFrameTransferPixels, 1), ...
                                  'parallelPixelFamily',              repmat(pixelFamilyStruct, nParallelPixels, 1),      ...
                                  'serialPixelFamily',                repmat(pixelFamilyStruct, nSerialPixels, 1)         );

lisaOutputStruct        = repmat(lisaOutputStruct_modOut, 1, nModOuts);                              
                       
% Loop over all module/outputs

for iChannel = 1:nModOuts

    [mod, out] = convert_to_module_output(iChannel);

    lisaOutputStruct(iChannel).module = mod;
    lisaOutputStruct(iChannel).output = out;

    % Calculate mean value, sigma and weighted MSE for Frame Transfer crosstalk pixel type and generate plots of temperature coefficients and error bars
    lisaOutputStruct = generate_xtalk_pixel_family_outputs( ...
        lisaOutputStruct, frameTransferXtalkPixelStruct, nFrameTransferPixels, iChannel, 'frameTransfer', plottingEnabledFlag, robustThreshold);

    % Calculate mean value, sigma and weighted MSE for Parallel crosstalk pixel type and generate plots of temperature coefficients and error bars
    lisaOutputStruct = generate_xtalk_pixel_family_outputs( ...
        lisaOutputStruct, parallelXtalkPixelStruct,      nParallelPixels,      iChannel, 'parallel'     , plottingEnabledFlag, robustThreshold);
    
    % Calculate mean value, sigma and weighted MSE for Serial crosstalk pixel type and generate plots of temperature coefficients and error bars
    lisaOutputStruct = generate_xtalk_pixel_family_outputs( ...
        lisaOutputStruct, serialXtalkPixelStruct,        nSerialPixels,        iChannel, 'serial'       , plottingEnabledFlag, robustThreshold);

    % MoGenerate plots of temperature coefficients and teh error bars if plottingEnabledFlag is true
    
    if plottingEnabledFlag
        
        % Move plots of temperature coefficients and error bars to the subdirectory
        dirNameStr = ['temperature_coefficient_plots_for_xtalk_pixels_of_mod_' num2str(mod) '_out_' num2str(out)];
        if(~exist(dirNameStr, 'dir'))
            eval(['mkdir ' dirNameStr]);
        end
        sourceFileStr = '*_Crosstalk_Pixel_Type_*.*';
        eval(['movefile '''  sourceFileStr '''  ' dirNameStr ' ' '''f''']);
        
    end

end

% Allocate memory

meanTempCoefftFrameTransfer      = NaN(nFrameTransferPixels, nModOuts);
sigmaMeanTempCoefftFrameTransfer = NaN(nFrameTransferPixels, nModOuts);
weightedMseFrameTransfer         = NaN(nFrameTransferPixels, nModOuts);

meanTempCoefftParallel           = NaN(nParallelPixels,      nModOuts);
sigmaMeanTempCoefftParallel      = NaN(nParallelPixels,      nModOuts);
weightedMseParallel              = NaN(nParallelPixels,      nModOuts);

meanTempCoefftSerial             = NaN(nSerialPixels,        nModOuts);
sigmaMeanTempCoefftSerial        = NaN(nSerialPixels,        nModOuts);
weightedMseSerial                = NaN(nSerialPixels,        nModOuts);

% Generate matrices of mean values, sigmas of mean values and weightes MSEs for Frame Transfer, Parallel and Serial crosstalk pixel types

for iChannel = 1:nModOuts
    
    bufVec = [lisaOutputStruct(iChannel).frameTransferPixelFamily.meanTemperatureCoefficient     ];
    meanTempCoefftFrameTransfer(:, iChannel)        = bufVec(:);
    bufVec = [lisaOutputStruct(iChannel).frameTransferPixelFamily.sigmaMeanTemperatureCoefficient];
    sigmaMeanTempCoefftFrameTransfer(:, iChannel)   = bufVec(:);
    bufVec = [lisaOutputStruct(iChannel).frameTransferPixelFamily.weightedMse                    ];
    weightedMseFrameTransfer(:, iChannel)           = bufVec(:);
    
    bufVec = [lisaOutputStruct(iChannel).parallelPixelFamily.meanTemperatureCoefficient          ];
    meanTempCoefftParallel(:, iChannel)             = bufVec(:);
    bufVec = [lisaOutputStruct(iChannel).parallelPixelFamily.sigmaMeanTemperatureCoefficient     ];
    sigmaMeanTempCoefftParallel(:, iChannel)        = bufVec(:);
    bufVec = [lisaOutputStruct(iChannel).parallelPixelFamily.weightedMse                         ];
    weightedMseParallel(:, iChannel)                = bufVec(:);
    
    bufVec = [lisaOutputStruct(iChannel).serialPixelFamily.meanTemperatureCoefficient            ];
    meanTempCoefftSerial(:, iChannel)               = bufVec(:);
    bufVec = [lisaOutputStruct(iChannel).serialPixelFamily.sigmaMeanTemperatureCoefficient       ];
    sigmaMeanTempCoefftSerial(:, iChannel)          = bufVec(:);
    bufVec = [lisaOutputStruct(iChannel).serialPixelFamily.weightedMse                           ];
    weightedMseSerial(:, iChannel)                  = bufVec(:);

end

% Generate plots of mean values, sigmas of mean values and weighted MSEs for each crosstalk pixel type across the focal plane

generate_plots_focal_plane(meanTempCoefftFrameTransfer,      nFrameTransferPixels, nModOuts, 'Temperature Coefficient',          'Frame Transfer', 'DN/integration/C');
generate_plots_focal_plane(sigmaMeanTempCoefftFrameTransfer, nFrameTransferPixels, nModOuts, 'Sigma of Temperature Coefficient', 'Frame Transfer', 'DN/integration/C');
generate_plots_focal_plane(weightedMseFrameTransfer,         nFrameTransferPixels, nModOuts, 'Weighted MSE',                     'Frame Transfer', 'dimenssionless'  );

generate_plots_focal_plane(meanTempCoefftParallel,           nParallelPixels,      nModOuts, 'Temperature Coefficient',          'Parallel',       'DN/integration/C');
generate_plots_focal_plane(sigmaMeanTempCoefftParallel,      nParallelPixels,      nModOuts, 'Sigma of Temperature Coefficient', 'Parallel',       'DN/integration/C');
generate_plots_focal_plane(weightedMseParallel,              nParallelPixels,      nModOuts, 'Weighted MSE',                     'Parallel',       'dimenssionless'  );

generate_plots_focal_plane(meanTempCoefftSerial,             nSerialPixels,        nModOuts, 'Temperature Coefficient',          'Serial',         'DN/integration/C');
generate_plots_focal_plane(sigmaMeanTempCoefftSerial,        nSerialPixels,        nModOuts, 'Sigma of Temperature Coefficient', 'Serial',         'DN/integration/C');
generate_plots_focal_plane(weightedMseSerial,                nSerialPixels,        nModOuts, 'Weighted MSE',                     'Serial',         'dimenssionless'  );

% Move plots of mean values, sigmas of mean values and weighted MSEs to the subdirectory

dirNameStr = 'statistical_parameter_plots_across_focal_plane';
if(~exist(dirNameStr, 'dir'))
    eval(['mkdir ' dirNameStr]);
end

sourceFileStr = '*_across_the_Focal_Plane_*.*';
eval(['movefile '''  sourceFileStr '''  ' dirNameStr ' ' '''f''']);

return


function lisaOutputStruct = generate_xtalk_pixel_family_outputs(lisaOutputStruct, xtalkPixelStruct, nXtalkPixels, iChannel, xtalkString, ...
    plottingEnabledFlag, robustThreshold)

paperOrientationFlag = true;
includeTimeFlag      = false;
printJpgFlag         = true;

[mod, out]   = convert_to_module_output(iChannel);

for jXtalkPixel = 1:nXtalkPixels
    
    aPixelStruct     = xtalkPixelStruct(jXtalkPixel);
    tempCoeffts      = aPixelStruct.fittedThermalCoefficients1(iChannel,:)';
    sigmaTempCoeffts = aPixelStruct.sigmaFittedThermalCoefficients1(iChannel,:)';

    nPixels = length(tempCoeffts);
    if ( nPixels~=length(sigmaTempCoeffts) )
        error('LISA:computeMeanTemperatureCoefficients', ...
            ['Inconsistent dimension in temperature coefficient and sigma vectors for ' xtalkString 'crosstalk pixel type ' num2str(jXtalkPixel) ...
             ' of Module ' num2str(mod) ' Output ' num2str(out)]);
    end
    
    [meanValue, sigmaMeanValue, weightedMse, gapIndicators, effectiveRobustWeights] = ...
        compute_mean_value_for_pixel_family(nPixels, tempCoeffts, sigmaTempCoeffts, robustThreshold);
        
    eval(['lisaOutputStruct(' num2str(iChannel) ').' xtalkString 'PixelFamily(' num2str(jXtalkPixel) ').rows                            = aPixelStruct.rows;'     ]);
    eval(['lisaOutputStruct(' num2str(iChannel) ').' xtalkString 'PixelFamily(' num2str(jXtalkPixel) ').columns                         = aPixelStruct.columns;'  ]);
    eval(['lisaOutputStruct(' num2str(iChannel) ').' xtalkString 'PixelFamily(' num2str(jXtalkPixel) ').temperatureCoefficients         = tempCoeffts;'           ]);
    eval(['lisaOutputStruct(' num2str(iChannel) ').' xtalkString 'PixelFamily(' num2str(jXtalkPixel) ').sigmaTemperatureCoefficients    = sigmaTempCoeffts;'      ]);
    eval(['lisaOutputStruct(' num2str(iChannel) ').' xtalkString 'PixelFamily(' num2str(jXtalkPixel) ').effectiveRobustWeights          = effectiveRobustWeights;']);
    eval(['lisaOutputStruct(' num2str(iChannel) ').' xtalkString 'PixelFamily(' num2str(jXtalkPixel) ').coefficientGapIndicators        = gapIndicators;'         ]);
    eval(['lisaOutputStruct(' num2str(iChannel) ').' xtalkString 'PixelFamily(' num2str(jXtalkPixel) ').meanTemperatureCoefficient      = meanValue;'             ]);
    eval(['lisaOutputStruct(' num2str(iChannel) ').' xtalkString 'PixelFamily(' num2str(jXtalkPixel) ').sigmaMeanTemperatureCoefficient = sigmaMeanValue;'        ]);
    eval(['lisaOutputStruct(' num2str(iChannel) ').' xtalkString 'PixelFamily(' num2str(jXtalkPixel) ').weightedMse                     = weightedMse;'           ]);

    if plottingEnabledFlag
        
        switch xtalkString
            case 'frameTransfer'
                xtalkString1 = 'Frame Tansfer';
            case 'parallel'
                xtalkString1 = 'Parallel';
            otherwise
                xtalkString1 = 'Serial';
        end
        
        tempCoeffts(gapIndicators)      = NaN;
        sigmaTempCoeffts(gapIndicators) = NaN;
        
        tempCoefftsRobust                                 = tempCoeffts;
        sigmaTempCoefftsRobust                            = sigmaTempCoeffts;
        tempCoefftsRobust(effectiveRobustWeights~=0)      = NaN;
        sigmaTempCoefftsRobust(effectiveRobustWeights~=0) = NaN;
       
        figure;
        errorbar(tempCoeffts, sigmaTempCoeffts, 'b*');
        grid;
        hold on
        errorbar(tempCoefftsRobust, sigmaTempCoefftsRobust, 'g*');
        if (sigmaMeanValue>0)
            plot( meanValue                *ones(nPixels,1), 'r.-');
            plot((meanValue+sigmaMeanValue)*ones(nPixels,1), 'r--');
            plot((meanValue-sigmaMeanValue)*ones(nPixels,1), 'r--');
        end
        hold off
        
        set(gca, 'fontsize', 16);
        xlabel('Pixel Index');
        ylabel('DN/integration/C');

        titleStr = ['Temperature Coefficicents for ' xtalkString1 ' Crosstalk Pixel Type ' num2str(jXtalkPixel) ' of Module ' num2str(mod) ' Output ' num2str(out)];
        title(titleStr);

        plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

        close all;

    end

end

return


function [meanValue, sigmaMeanValue, weightedMse, gapIndicators, effectiveRobustWeights] = ...
    compute_mean_value_for_pixel_family(nPixels, tempCoeffts, sigmaTempCoeffts, robustThreshold)


    % Note: tempCoeffts, sigmaTempCoeffts and gapIndicators are all nPixels x 1 vectors        
    
    % Set gap indicators to be true for NaN, INF or sigmas <= 0
    
    gapIndicators = false(nPixels, 1);
    gapIndicators( isnan(tempCoeffts) | isinf(tempCoeffts) | isnan(sigmaTempCoeffts) | isinf(sigmaTempCoeffts) | (sigmaTempCoeffts<=0) ) = true;

    effectiveRobustWeights = zeros(nPixels,1);
    
    tempCoefftsCleaned      = tempCoeffts(~gapIndicators);
    sigmaTempCoefftsCleaned = sigmaTempCoeffts(~gapIndicators); 
    
    nValidData = length(tempCoefftsCleaned);

    if nValidData==0
        
        % When there is no valid data
        meanValue       = 0;
        sigmaMeanValue  = -1;
        weightedMse     = -1;
        
    elseif nValidData==1
        
        % When there is only one valid data
        
        meanValue       = tempCoefftsCleaned;
        sigmaMeanValue  = sigmaTempCoefftsCleaned;
        weightedMse     = -1;
        effectiveRobustWeights(~gapIndicators) = 1;
        
    else
        
        varianceVec     = sigmaTempCoefftsCleaned.^2;
      
        % Fit the temperature coefficients to a constant using robustfit
        
        warning off all
        [robustMean, robustStats] = robustfit(ones(nValidData,1), tempCoefftsCleaned, [], [], 'off');
        warning on all
        
        % Set the data points as outliers when the robust weights are less than the threshold
        
        isOutlier = robustStats.w<robustThreshold;
        robustWeights = robustStats.w(~isOutlier);
       
        % When the robust weights are less than the threshold, effective robust weights are set to 0
        
        effectiveRobustWeights(~gapIndicators) = robustStats.w;
        effectiveRobustWeights(effectiveRobustWeights<robustThreshold) = 0;
        
        % Remove th data points labelled as outliers
        
        tempCoefftsRobustCleaned        = tempCoefftsCleaned(~isOutlier);
        sigmaTempCoefftsRobustCleaned   = sigmaTempCoefftsCleaned(~isOutlier);
        
        nValidRobustData = length(tempCoefftsRobustCleaned);
        
        if nValidRobustData == 0
            
            meanValue       = 0;
            sigmaMeanValue  = -1;
            weightedMse     = -1;
            
        elseif nValidRobustData == 1
            
            meanValue       = tempCoefftsRobustCleaned;
            sigmaMeanValue  = sigmaTempCoefftsRobustCleaned;
            weightedMse     = -1;

        else
            
            varianceVec     = sigmaTempCoefftsRobustCleaned.^2;
            inverseVariance = 1./varianceVec;
            weights         = inverseVariance.*robustWeights;
            transformation  = weights'/sum(weights);
            
            meanValue       = transformation*tempCoefftsRobustCleaned;
            sigmaMeanValue  = sqrt( (transformation.^2)*varianceVec );
        
            diffVec         = tempCoefftsRobustCleaned - meanValue;
            weightedMse     = weights'*diffVec.^2/(nValidRobustData-1);
            
        end

    end
    
return


function generate_plots_focal_plane(dataMatrix, nXtalkPixels, nModOuts, dataTypeString, xtalkString, unitString)

paperOrientationFlag = true;
includeTimeFlag      = false;
printJpgFlag         = true;

tickStr = cell(nModOuts,1);
[modules, outputs] = convert_to_module_output(1:nModOuts);
for j = 1:nModOuts
    tickStr(j) = {['[' num2str(modules(j)) ', ' num2str(outputs(j)) ']']};
end

stdArray = zeros(nXtalkPixels, 1);
for i = 1:nXtalkPixels
    cleanedIndex = isfinite( dataMatrix(i,:) );
    stdArray(i)  = std( dataMatrix(i,cleanedIndex) );
end
maxStd = max(stdArray);

colorSpec = color_specification(nXtalkPixels);
if nXtalkPixels==1
    colorSpec = [0 0 1];
end

% --------------------------------------------
% 2D plot: superposed with offset
% --------------------------------------------

for i = 1:nXtalkPixels

    plot(dataMatrix(i,:)+(i-1)*4*maxStd, 'p-', 'color', colorSpec(i,:), 'LineWidth', 1);

    cleanedIndex = find( isfinite( dataMatrix(i,:) ) );
    if ( ~isempty(cleanedIndex) )
        text(nModOuts+1, dataMatrix(i,cleanedIndex(end))+(i-1)*4*maxStd, num2str(i));
    end

    hold on;

end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 16);
xlabel('Module/Output');
ylabel([dataTypeString ' of ' xtalkString ' Crosstalk Pixels (' unitString ')']);

titleStr = [dataTypeString ' of ' xtalkString ' Crosstalk Pixels across the Focal Plane Superposed with Offset'];
title(titleStr);

set(gca, 'xtick',      1:4:nModOuts);
set(gca, 'xticklabel', tickStr(1:4:nModOuts));

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

% --------------------------------------------
% 2D plot: superposed without offset
% --------------------------------------------

for i = 1:nXtalkPixels

    plot(dataMatrix(i,:), 'p-', 'color', colorSpec(i,:), 'LineWidth', 1);

    cleanedIndex = find( isfinite( dataMatrix(i,:) ) );
    if ( ~isempty(cleanedIndex) )
        text(nModOuts+1, dataMatrix(i,cleanedIndex(end)), num2str(i));
    end

    hold on;

end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 16);
xlabel('Module/Output');
ylabel([dataTypeString ' of ' xtalkString ' Crosstalk Pixels (' unitString ')']);

titleStr = [dataTypeString ' of ' xtalkString ' Crosstalk Pixels across the Focal Plane Superposed without Offset'];
title(titleStr);

set(gca, 'xtick',      1:4:nModOuts);
set(gca, 'xticklabel', tickStr(1:4:nModOuts));

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

return


function colorSpec = color_specification(nColor)

colorSpec = zeros(nColor,3); % R, G, B colors

shuffleOrder = randperm(nColor);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,1) = linspace(0.001, 1, nColor);

shuffleOrder = randperm(nColor);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,2) = linspace(0.001, 1, nColor);

shuffleOrder = randperm(nColor);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,3) = linspace(0.001, 1, nColor);

return


    