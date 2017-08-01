%******************************************************************************
% function [] = map_plot_robust_fit_vs_parameter (mapData, mapinput)
%
% This will plot the robust fit coefficients and a function of the speficied Kic parameters. To be used to
% find correlations between the parameter and robust fit coefficients.
%
% To be called in the debugger after map_robust_fit is called in MAP.
%
%******************************************************************************
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

function [] = map_plot_robust_fit_vs_parameter (mapData, mapInput, varargin)

figure;

kicStruct = [mapInput.targetDataStruct.kic];

paramNames = fieldnames(kicStruct);
if(mapData.centroid.centroidMotionDataExists)
    paramNames = [paramNames' ['rowCentroid'] ['colCentroid'] ['combinedCentroid']]';
end

if (isempty(varargin))
    % Work through all fields
    for iParam = 1 : length(aramNames)

        plot_this_param_index (mapData, mapInput, kicStruct, paramNames, iParam)

    end
else
    paramIndex = find(strcmp(varargin(1), paramNames));
    if (~isempty(paramIndex))
        plot_this_param_index (mapData, mapInput, kicStruct, paramNames, paramIndex)
    else
        error ('KIC name not found')
    end
end


%*******************************************************************************
%*******************************************************************************
%*******************************************************************************
% Internal functions

%*******************************************************************************
function [] = plot_this_param_index (mapData, mapInput, kicStruct, paramNames, paramIndex)

    % If a kic then find approriate kic struct
    if (paramIndex <= length(fieldnames(kicStruct)))
        xAll = eval(['[kicStruct.' char(paramNames(paramIndex)) ']'])';
        if (isstruct(xAll))
            xAll = [xAll.value]';
           %xAll = log(xAll);
        end
    else
        % Is a centroid motion parameter
        switch paramNames{paramIndex}

        case 'rowCentroid'
            xAll = [mapData.centroid.motion.row]';
        case 'colCentroid'
            xAll = [mapData.centroid.motion.col]';
        case 'combinedCentroid'
            xAll = [mapData.centroid.motion.combined]';
        otherwise
            error('Unknown parameter!')
        end
    end

    xLabel=paramNames{paramIndex};

    xReduced = [xAll(mapData.targetsForSvd)];
 
    % Sort the data
    [xAll, xAllSortOrder]         = sort(xAll);
    [xReduced, xReducedSortOrder] = sort(xReduced);

    for basisVectorIndex = 1 : mapData.nBasisVectors
        y        = mapData.robustFit.coefficients(basisVectorIndex,:)';
        yReduced = y(mapData.targetsForSvd);
 
        y        = y(xAllSortOrder);
        yReduced = yReduced(xReducedSortOrder);
 
        plot(xAll,y,'*b','MarkerSize',5);
        hold on;
        plot(xReduced, yReduced,'or','MarkerSize',5);
        upperBound = prctile(y,98);
        lowerBound = prctile(y,02);
        rightBound = prctile(xAll,98);
        leftBound  = prctile(xAll,02);
        dataRange = [leftBound rightBound lowerBound upperBound];
 
        % Plot mean and std of binned data 
        [allDataMean, allDataMad, allXValuesForStats] = window_data_statisitics (xAll, y, dataRange);
        [reducedDataMean, reducedDataMad, reducedXValuesForStats] = window_data_statisitics (xReduced, ...
                                             yReduced, dataRange);
        lineWidth = 2;
        plot(allXValuesForStats, allDataMean, '-b', 'LineWidth', lineWidth);
        plot(allXValuesForStats, allDataMean+allDataMad, '--b', 'LineWidth', lineWidth);
        plot(allXValuesForStats, allDataMean-allDataMad, '--b', 'LineWidth', lineWidth);
        plot(reducedXValuesForStats, reducedDataMean, '-r', 'LineWidth', lineWidth);
        plot(reducedXValuesForStats, reducedDataMean+reducedDataMad, '--r', 'LineWidth', lineWidth);
        plot(reducedXValuesForStats, reducedDataMean-reducedDataMad, '--r', 'LineWidth', lineWidth);
 
        if (dataRange(2) - dataRange(1) ~= 0.0 && dataRange(4) - dataRange(3) ~= 0.0 && all(~isnan(dataRange)))
            axis(dataRange);
        end
        TitleString = ['Coefficient ' num2str(basisVectorIndex) ' for all targets and reduced set' ];
        grid
        title(TitleString,'FontSize',14);
        xlabel(xLabel);
        ylabel('Coefficient Value');
        legend ('All Coefficients', 'Coefficients used for SVD');
        hold off;
       %string = ['Displaying Robust fit scatter of coefficient ', num2str(basisVectorIndex), ...
       %' of ', num2str(mapData.nBasisVectors), ' versus  ', xLabel];
       %display(string);
        pause();
    end

return

%*******************************************************************************
% Returns the data mean and mad over a travelling window 
function [dataMean, dataMad, xValuesForStats] = window_data_statisitics (x, y, dataRange)

windowWidth = 0.2; % 5% of data spread

xWindowHalfWidth = ((dataRange(2) - dataRange(1)) * windowWidth)/2.0;

% First only keep targets within dataRange (to remove outliers)
validData = x >= dataRange(1) & x <= dataRange(2) & y >= dataRange(3) & y <= dataRange(4);
x = x(validData);
y = y(validData);

% Pick only every tenth point
%x = x(1:10:end);
%y = y(1:10:end);

nDatum = length(x);
if (length(y) ~= nDatum)
    error('X and Y data must be same length');
end

dataMean = zeros(nDatum,1);
dataMad  = zeros(nDatum,1);

for iDatum = 1 : nDatum
    % Find data in window
    useThisData = (x >= (x(iDatum)-xWindowHalfWidth)) & (x <= (x(iDatum)+xWindowHalfWidth));
    yData = y(useThisData); 

    dataMean(iDatum) = mean(yData);
    dataMad(iDatum)  = mad(yData);
end

xValuesForStats = x;

return
