%*******************************************************************************
%% function [] = map_robust_fit (mapData, mapInput)
%*******************************************************************************
%
% Performs a robust fit of the mapData.U_hat basis vectors to all targets.
%
% The results are stored in the mapData.robustFit structure. Ideally this would be segreated out into
% substructures for each target. However, these results needs to be precombined into subarray throughout the
% code and Matlab provided no easy way to create arrays of substructure fields.
%
%
%*******************************************************************************
% Outputs:
%       mapData.robustFit -- [struct]
%           coefficients      -- [double matrix(nBasisVectors,nTargets)] The robust fit coefficients
%           basisVectorsToUse -- [logical matrix(nBasisVectors,nTarget)] which basis vectors to use for this target    
%       mapData.spikeRobustFit -- [struct]
%           coefficients      -- [double matrix(nBasisVectors,nTargets)] The robust fit coefficients
%           basisVectorsToUse -- [logical matrix(nBasisVectors,nTarget)] which basis vectors to use for this target    
% 
%*******************************************************************************
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

function [] = map_robust_fit (mapData, mapInput)

component = 'robustFit';

mapInput.debug.display(component, 'Robust Fitting Coefficients...');
tic
% The coefficients covariance matrix needs to be in a big matrix because Matlab offers no easy ways to create arrays
% of data divided into substructures : (
% In the mapResults object these will be segregated by target.
mapData.robustFit = struct( 'coefficients', zeros(mapData.nBasisVectors,mapData.nTargets), ...   
                            'basisVectorsToUse', true(mapData.nBasisVectors,mapData.nTargets)); % For now use all basis vectors   

% Find robust fit coefficients for all targets
% suppress warning for robustfit
warningState = warning('query', 'all');
warning off all;
for iTarget = 1:mapData.nTargets
    % Check if there are at least nBasisVector valid cadences in the data
    if (length(find(~isnan(mapData.normTargetDataStruct(iTarget).values))) <= length(find(mapData.robustFit.basisVectorsToUse(:,iTarget))))
        % not enough data points so no robust fit possible
        continue;
    end
    % Do not fit to gaps if this is K2 data
    % TODO: consider doing this for Kepler data as well! It's a good idea.
    if (mapInput.taskInfoStruct.thisIsK2Data)
        gaps = mapData.normTargetDataStruct(iTarget).gapIndicators;
        [mapData.robustFit.coefficients(mapData.robustFit.basisVectorsToUse(:,iTarget), iTarget), stats] = ...
            robustfit(mapData.basisVectors(~gaps,mapData.robustFit.basisVectorsToUse(:,iTarget)),mapData.normTargetDataStruct(iTarget).values(~gaps),[],[],'off');
    else
        [mapData.robustFit.coefficients(mapData.robustFit.basisVectorsToUse(:,iTarget), iTarget), stats] = ...
            robustfit(mapData.basisVectors(:,mapData.robustFit.basisVectorsToUse(:,iTarget)),mapData.normTargetDataStruct(iTarget).values,[],[],'off');
    end
    if (mapInput.debug.query(component, mapInput.debug.VERBOSEDEBUGLEVEL));
        mapInput.debug.waitbar(iTarget/mapData.nTargets, 'Robust fitting coefficients...')
    end
end
warning(warningState);

duration = toc;
mapInput.debug.display(component, ['Robust Fitting performed: ' num2str(duration) ...
    ' seconds = '  num2str(duration/60) ' minutes']);


%******
% Coefficient scatter plot
% Plot the coefficients for both all targets and only those used for SVD

if (mapInput.debug.query_do_plot(component));
    robustCoeffFig = mapInput.debug.create_figure;
    for basisVectorIndex = 1 : mapData.nBasisVectors
        for xIndex = 1 : 5
            mapInput.debug.select_figure(robustCoeffFig);
            if (xIndex == 1)
                xAll     = [mapData.kic.keplerMag];
                xReduced = [mapData.kic.keplerMag(mapData.targetsForSvd)];
                xLabel='Kepler Magnitude';
                fileLabel = 'keplerMag';
            elseif (xIndex == 2)
                xAll     = [mapData.kic.ra];
                xReduced = [mapData.kic.ra(mapData.targetsForSvd)];
                xLabel='Right Assension [degrees]';
                fileLabel = 'RA';
            elseif (xIndex == 3)
                xAll     = [mapData.kic.dec];
                xReduced = [mapData.kic.dec(mapData.targetsForSvd)];
                xLabel='Declination [hours]';
                fileLabel = 'Dec';
            elseif (xIndex == 4)
                xAll     = [mapData.kic.effTemp];
                xReduced = [mapData.kic.effTemp(mapData.targetsForSvd)];
                xLabel='Effective Tamperature [C]';
                fileLabel = 'EffTemp';
            else
                xAll     = [mapData.kic.logRadius];
                xReduced = [mapData.kic.logRadius(mapData.targetsForSvd)];
                xLabel='log(Radius) []';
                fileLabel = 'LogRadius';
            end

            y = mapData.robustFit.coefficients(basisVectorIndex,:)';

            % xAll can contain NaNs so trim off the NaNs
            % xReduced should contain no NaNs already
%           xAll = xAll(~isnan(xAll));
%           yNoNans = y(~isnan(xAll));
%           yNoNans = y;

            % Sort the data
            [xAll, xAllSortOrder]         = sort(xAll);
            [xReduced, xReducedSortOrder] = sort(xReduced);
            yReduced = y(mapData.targetsForSvd);
            y  = y(xAllSortOrder);
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

            axis(dataRange);
            TitleString = ['Coefficient ' num2str(basisVectorIndex) ' for all targets and reduced set' ];
            grid
            title(TitleString,'FontSize',14);
            xlabel(xLabel);
            ylabel('Coefficient Value');
            legend ('All Coefficients', 'Coefficients used for SVD');
            hold off;
            filename = ['robust_fit_scatter_', fileLabel];
            mapInput.debug.save_figure(robustCoeffFig, component, filename);
            string = ['Displaying Robust fit scatter of coefficient ', num2str(basisVectorIndex), ...
            ' of ', num2str(mapData.nBasisVectors), ' versus  ', xLabel];
            mapInput.debug.pause(string);
        end % over X index
    end % over components
end

%*******************************************************************************
%*******************************************************************************
%*******************************************************************************
% Internal functions

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
