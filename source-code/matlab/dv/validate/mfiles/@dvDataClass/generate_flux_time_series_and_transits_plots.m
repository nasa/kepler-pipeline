function [dvResultsStruct] = generate_flux_time_series_and_transits_plots(dvDataObject, dvResultsStruct, iTarget, ...
    normalizedFluxTimeSeriesArray)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = generate_flux_time_series_and_transits_plots(dvDataObject, dvResultsStruct, iTarget, ...
%     normalizedFluxTimeSeriesArray)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot initial PDC flux time series of the specified target and mark the transits
% of identified planets with the epoch KJD/BKJD and the orbital period.
%
% Version date:  2011-July-05.
%
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

% Modification History:
%
%    2011_July-05, JL:
%        comment out duplicate lines to plot flux time series.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Retrieve KJD offset from MJD/JD
kjdOffsetFromMjd = kjd_offset_from_mjd;
kjdOffsetFromJd  = kjd_offset_from_jd;

% Retrieve debugLevel, cadenceTimes and barycentricCadenceTimes from dvDataObject
debugLevel               = dvDataObject.dvConfigurationStruct.debugLevel;
cadenceTimes             = dvDataObject.dvCadenceTimes.midTimestamps;         
cadenceNumbers           = dvDataObject.dvCadenceTimes.cadenceNumbers;
barycentricCadenceTimes  = dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps;

% Retrieve keplerId and dvFiguresRootDirectory from dvResultsStruct
keplerId                 = dvResultsStruct.targetResultsStruct(iTarget).keplerId;
dvFiguresRootDirectory   = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;

% Determine number of planets of the specified target and set the title strings of the plots
nPlanets = length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
if nPlanets==0
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'generateFluxTimeSeriesAndTransitsPlots', 'warning', 'Empty planetResutsStruct', iTarget, keplerId);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

% Set title strings of the subplots
titleStrTps = 'Flux Time Series with Transit Events';
titleStrFit = 'Flux Time Series with Transit Events';
titleStrRaw = 'Raw Flux Time Series';

% Retrieve flux time series from normalizedFluxTimeSeriesArray
fluxTimeSeriesValues    = normalizedFluxTimeSeriesArray(iTarget).values;

rawFluxTimeSeries       = dvDataObject.targetStruct(iTarget).rawFluxTimeSeries;
rawFluxTimeSeriesValues = rawFluxTimeSeries.values;
rawGapIndicators        = rawFluxTimeSeries.gapIndicators;

% Determine offset to plot flux time series of each quarter
dataRange   = range(fluxTimeSeriesValues(~rawGapIndicators));
dataMax     = max(fluxTimeSeriesValues(~rawGapIndicators)) + 0.1*dataRange;
dataMin     = min(fluxTimeSeriesValues(~rawGapIndicators)) - 0.1*dataRange;
dataSteps   = [0.00006 0.00012 0.00030 0.0006 0.0012 0.0030 0.006 0.012 0.030 0.06 0.12 0.30 0.6];
offsetSteps = [0.00010 0.00020 0.00050 0.0010 0.0020 0.0050 0.010 0.020 0.050 0.10 0.20 0.50 1.0 2.0];
dataOffset  = offsetSteps(sum(dataRange>dataSteps)+1);
dataMax     = dataMax + 0.15*dataOffset;

rawDataRange  = range(rawFluxTimeSeriesValues(~rawGapIndicators));
rawBuf   = rawDataRange;
rawScale = 1;
while rawBuf>10
    rawBuf   = rawBuf/10;
    rawScale = rawScale*10;
end
rawDataOffset = 0.5*floor(rawBuf)*rawScale*0;

nDataSetsPerFigure  = 4;
nTargetTables       = length(dvDataObject.targetTableDataStruct);
nFigures            = ceil(nTargetTables/nDataSetsPerFigure);

lineStyle       = '-';
colorValueArray = [ 1  0   0         % red
                    0  1   0         % green
                    0  1   1         % cyan
                    1  0.7 0         % orange
                    1  0   1  ];     % magenta
markerArray     = {'o', 'x', '^', 'v', 's', 'd'};

for iFigure = 1:nFigures
    
    hFig1       = figure;     % Detrended flux time series marked with TPS outputs
    hFig2       = figure;     % Detrended flux time series marked with DV fitter outputs
    hFig3       = figure;     % Raw       flux time series 
           
    hVector1    = [];
    strArray1   = {};
    lineCount1  = 0;
    
    hVector2    = [];
    strArray2   = {};
    lineCount2  = 0;

    hVector3    = [];
    strArray3   = {};
    lineCount3  = 0;

    quarterArray        = [];
    targetTableIdArray  = [];
    yOffsetArray        = [];
    rawOffsetArray      = [];
    startKjdArray       = [];
    
    for iDataSet = 1:nDataSetsPerFigure
        
        iTargetTable = (iFigure-1)*nDataSetsPerFigure + iDataSet;
        
        if iTargetTable <= nTargetTables
            
            % Determine start time offset, end KJD and end barycentric corrected KJD
            
            targetTableDataStruct           = dvDataObject.targetTableDataStruct(iTargetTable);
            indexDataSet                    = (cadenceNumbers >= targetTableDataStruct.startCadence) & (cadenceNumbers <= targetTableDataStruct.endCadence);

            validCadenceTimesKjd            = cadenceTimes(indexDataSet)- kjdOffsetFromMjd;
            validBarycentricCadenceTimesKjd = barycentricCadenceTimes(indexDataSet);
            validFluxTimeSeriesValues       = fluxTimeSeriesValues(indexDataSet);
            validRawFluxTimeSeriesValues    = rawFluxTimeSeriesValues(indexDataSet);
            validGapIndicatorsDataSet       = rawGapIndicators(indexDataSet);
            
            validFluxTimeSeriesValues(validGapIndicatorsDataSet)    = NaN;
            validRawFluxTimeSeriesValues(validGapIndicatorsDataSet) = NaN;
            
            quarter            = targetTableDataStruct.quarter;
            targetTableId      = targetTableDataStruct.targetTableId;
            yOffset            = (iDataSet-1)*dataOffset*1e6;
            rawOffset          = (iDataSet-1)*rawDataOffset;
            
            quarterArray       = [quarterArray;        quarter      ];
            targetTableIdArray = [targetTableIdArray;  targetTableId];
            yOffsetArray       = [yOffsetArray;        yOffset      ];
            rawOffsetArray     = [rawOffsetArray;      rawOffset    ];
            
            if ~isempty(validCadenceTimesKjd) && ~isempty(validBarycentricCadenceTimesKjd)
                
                startKjd      = min([floor(validCadenceTimesKjd(1)  )  floor(validBarycentricCadenceTimesKjd(1)  )]);
                endKjd        = max([ ceil(validCadenceTimesKjd(end))   ceil(validBarycentricCadenceTimesKjd(end))]);
                
                startKjdArray = [startKjdArray;       startKjd     ];
                
                % Plot flux time series and mark transits of identified planets with TPS outputs
                figure(hFig1);
                
                if ~isempty(validFluxTimeSeriesValues) && ~all(isnan(validFluxTimeSeriesValues))
                    
                    hold on;
                    
                    text(100, yOffset, ['Q-' num2str(quarter, '%02d') '/TT-' num2str(targetTableId, '%03d')], 'FontSize', 12, 'FontWeight', 'bold');
                    
                    for jPlanet=1:nPlanets
                        
                        colorValue  = colorValueArray(mod(jPlanet-1, size(colorValueArray,1))+1, :);
                        markerValue = markerArray{mod(jPlanet-1, size(markerArray,2))+1};
                        faceColor   = [1 1 1];        % white
                        
                        % Retrieve epochMjd and orbitalPeriod from planetCandidate of planetResultsStruct, which are determined by TPS
                        epochMjd      = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).planetCandidate.epochMjd;
                        orbitalPeriod = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).planetCandidate.orbitalPeriod;
                        if ( epochMjd<=0 )
                            
                            continue;
                            
                        elseif ( orbitalPeriod<=0 )
                            
                            transitKjd = epochMjd - kjdOffsetFromMjd;
                            if ( transitKjd>=startKjd && transitKjd<=endKjd )
                                xVec = [transitKjd transitKjd] - startKjd;
                                yVec = [dataMin dataMax]*1e6 + yOffset;
                                hLine   = plot(xVec,    yVec,    lineStyle, 'LineWidth', 1, 'color', colorValue);
                                hMarker = plot(xVec(2), yVec(2), markerValue, 'MarkerSize', 6, 'LineWidth', 2, ...
                                    'MarkerEdgeColor', colorValue, 'MarkerFaceColor', faceColor);
                                
                                strPlanet = ['planet ' num2str(jPlanet, '%02d')];
                                if ( isempty(strArray1) || ~ismember(strPlanet, strArray1) )
                                    lineCount1 = lineCount1 + 1;
                                    hVector1(lineCount1)  = hMarker;
                                    strArray1{lineCount1} = strPlanet;
                                end
                            end
                            
                        else
                            
                            % Mark the transits of the identified planet. Different planets are in different colors.
                            lineNum = 0;
                            transitKjd = epochMjd - kjdOffsetFromMjd;
                            while (transitKjd<=endKjd)
                                if (transitKjd>=startKjd)
                                    xVec = [transitKjd transitKjd] - startKjd;
                                    yVec = [dataMin dataMax]*1e6 + yOffset;
                                    hLine   = plot(xVec,    yVec,    lineStyle, 'LineWidth', 1, 'color', colorValue);
                                    hMarker = plot(xVec(2), yVec(2), markerValue, 'MarkerSize', 6, 'LineWidth', 2, ...
                                        'MarkerEdgeColor', colorValue, 'MarkerFaceColor', faceColor);
                                    lineNum = lineNum + 1;
                                end
                                transitKjd = transitKjd + orbitalPeriod;
                            end
                            
                            strPlanet = ['planet ' num2str(jPlanet, '%02d')];
                            if (lineNum>0 && ( isempty(strArray1) || ~ismember(strPlanet, strArray1) ) )
                                lineCount1 = lineCount1 + 1;
                                hVector1(lineCount1)  = hMarker;
                                strArray1{lineCount1} = strPlanet;
                            end
                            
                        end
                        
                    end     % for jPlanet
                    
                    % Plot the flux time series.
                    plot(validCadenceTimesKjd-startKjd, validFluxTimeSeriesValues*1e6+yOffset, 'k.-', 'lineWidth', 2, 'Marker', 'none');
                    
                    hold off
                    
                end     % if ~isempty(validFluxTimeSeriesValuesDataSet)
                
                % Plot flux time series and mark transits of identified planets with DV fitted model parameters
                figure(hFig2);
                
                if ~isempty(validFluxTimeSeriesValues) && ~all(isnan(validFluxTimeSeriesValues))
                    
                    hold on;
                    
                    text(100, yOffset, ['Q-' num2str(quarter, '%02d') '/TT-' num2str(targetTableId, '%03d')], 'FontSize', 12, 'FontWeight', 'bold');
                    
                    for jPlanet=1:nPlanets
                        
                        colorValue  = colorValueArray(mod(jPlanet-1, size(colorValueArray,1))+1, :);
                        markerValue = markerArray{mod(jPlanet-1, size(markerArray,2))+1};
                        faceColor   = [1 1 1];        % white
                        
                        % Retrieve allTransitsFit from dvResultsStruct
                        allTransitsFit = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).allTransitsFit;
                        if isempty( allTransitsFit.modelParameters )
                            continue;
                        end
                        
                        % Retrieve epochMjd and orbitalPeriod from model parameters of allTransitsFit
                        
                        parameterNames = {allTransitsFit.modelParameters.name} ;
                        epochPointer = find( strcmp( 'transitEpochBkjd', parameterNames ) ) ;
                        periodPointer = find( strcmp( 'orbitalPeriodDays', parameterNames ) ) ;
                        if isempty(epochPointer) || isempty( periodPointer )
                            continue ;
                        end
                        epochBkjd           = allTransitsFit.modelParameters(epochPointer).value;
                        epochBkjdUncer      = allTransitsFit.modelParameters(epochPointer).uncertainty;
                        orbitalPeriod       = allTransitsFit.modelParameters(periodPointer).value;
                        orbitalPeriodUncer  = allTransitsFit.modelParameters(periodPointer).uncertainty;
                        if ( epochBkjd<=0 || epochBkjdUncer<0 )
                            
                            continue;
                            
                        elseif ( orbitalPeriod<=0 || orbitalPeriodUncer<0 )
                            
                            transitKjd = epochBkjd;
                            if ( transitKjd>=startKjd && transitKjd<=endKjd )
                                xVec = [transitKjd transitKjd] - startKjd;
                                yVec = [dataMin dataMax]*1e6 + yOffset;
                                hLine   = plot(xVec,    yVec,    lineStyle, 'LineWidth', 1, 'color', colorValue);
                                hMarker = plot(xVec(2), yVec(2), markerValue, 'MarkerSize', 6, 'LineWidth', 2, ...
                                    'MarkerEdgeColor', colorValue, 'MarkerFaceColor', faceColor);
                                
                                strPlanet = ['planet ' num2str(jPlanet, '%02d')];
                                if ( isempty(strArray2) || ~ismember(strPlanet, strArray2) )
                                    lineCount2 = lineCount2 + 1;
                                    hVector2(lineCount2)  = hMarker;
                                    strArray2{lineCount2} = strPlanet;
                                end
                            end
                            
                        else
                            
                            % Mark the transits of the identified planet. Different planets are in different colors.
                            lineNum = 0;
                            transitKjd = epochBkjd;
                            while (transitKjd<=endKjd)
                                if (transitKjd>=startKjd)
                                    xVec = [transitKjd transitKjd] - startKjd;
                                    yVec = [dataMin dataMax]*1e6 + yOffset;
                                    hLine   = plot(xVec,    yVec, lineStyle, 'LineWidth', 1, 'color', colorValue);
                                    hMarker = plot(xVec(2), yVec(2), markerValue, 'MarkerSize', 6, 'LineWidth', 2, ...
                                        'MarkerEdgeColor', colorValue, 'MarkerFaceColor', faceColor);
                                    lineNum = lineNum + 1;
                                end
                                transitKjd = transitKjd + orbitalPeriod;
                            end
                            
                            strPlanet = ['planet ' num2str(jPlanet, '%02d')];
                            if (lineNum>0 && ( isempty(strArray2) || ~ismember(strPlanet, strArray2) ) )
                                lineCount2 = lineCount2 + 1;
                                hVector2(lineCount2)  = hMarker;
                                strArray2{lineCount2} = strPlanet;
                            end
                            
                        end
                        
                    end     % for jPlanet
                    
                    % Plot the flux time series.
                    plot(validBarycentricCadenceTimesKjd-startKjd, validFluxTimeSeriesValues*1e6+yOffset, 'k.-', 'lineWidth', 2, 'Marker', 'none');
                    
                    hold off
                    
                end     % if ~isempty(validFluxTimeSeriesValuesDataSet)
                
                % Plot flux time series and mark transits of identified planets with DV fitted model parameters
                figure(hFig3);
                
                if ~isempty(validRawFluxTimeSeriesValues) && ~all(isnan(validRawFluxTimeSeriesValues))
                    
                    hold on;
                    
                    colorValue = colorValueArray(mod(iDataSet-1, size(colorValueArray,1))+1, :);
                    hLine = plot(validCadenceTimesKjd-startKjd, validRawFluxTimeSeriesValues+rawOffset, '.-', 'lineWidth', 2, 'color', colorValue);
                    
                    lineCount3 = lineCount3 + 1;
                    hVector3(lineCount3)  = hLine;
                    strArray3{lineCount3} = ['Q-' num2str(quarter, '%02d') '/TT-' num2str(targetTableId, '%03d')];
                    
                    hold off;
                    
                end     %  if ~isempty(validRawFluxTimeSeriesValuesDataSet)
                
            else
                
                startKjdArray = [startKjdArray; -1];
                
            end     %  if ~isempty(validCadenceTimesKjd) && ~isempty(validBarycentricCadenceTimesKjd)

        end  % if iTargetTable <= nTargetTables
        
    end  % for iDataSet
    
    figure(hFig1);
    
    title(titleStrTps, 'horizontalAlignment', 'center');
    xlabel('Elapsed JD Since Start of Each Quarter') ;
    ylabel('Normalized Flux (ppm)');
    if length(yOffsetArray)>1
        set(gca, 'YTick', yOffsetArray);
    end
    
    if ~isempty(hVector1) && (numel(hVector1) == numel(strArray1))
        hLegend1 = legend(hVector1, strArray1, 'Location', 'EastOutside');
        set(hLegend1, 'FontSize', 10);
    end
    
    format_graphics_for_dv_report(hFig1);
    set(gca, 'xLim', [0, 120]);
    if ~isempty(yOffsetArray)
        set(gca, 'yLim', [yOffsetArray(1)-dataOffset*1e6 yOffsetArray(end)+dataOffset*1e6]);
    end
    
    figure(hFig2);
    
    title(titleStrFit, 'horizontalAlignment', 'center');
    xlabel('Elapsed BJD Since Start of Each Quarter') ;
    ylabel('Normalized Flux (ppm)');
    if length(yOffsetArray)>1
        set(gca, 'YTick', yOffsetArray);
    end
            
    if ~isempty(hVector2) && (numel(hVector2) == numel(strArray2))
        hLegend2 = legend(hVector2, strArray2, 'Location','EastOutside');
        set(hLegend2, 'FontSize', 10);
    end
        
    format_graphics_for_dv_report(hFig2);
    set(gca, 'xLim', [0, 120]);
    if ~isempty(yOffsetArray)
        set(gca, 'yLim', [yOffsetArray(1)-dataOffset*1e6 yOffsetArray(end)+dataOffset*1e6]);
    end
    
    figure(hFig3);
    
    title(titleStrRaw, 'horizontalAlignment', 'center');
    xlabel('Elapsed JD Since Start of Each Quarter') ;
    ylabel('Raw Flux (e-/cadence)');
               
    if ~isempty(hVector3) && (numel(hVector3) == numel(strArray3))
        hLegend3 = legend(hVector3, strArray3, 'Location','EastOutSide');
        set(hLegend3, 'FontSize', 10);
    end
        
    format_graphics_for_dv_report(hFig3);
    
    figureFilenameFit = [num2str(keplerId, '%09d'), '-00-flux-dv-fit-', ...
        num2str(quarterArray(1), '%02d'), '-', num2str(targetTableIdArray(1), '%03d'), '.fig'];
    figureFilenameTps   = [num2str(keplerId, '%09d'), '-00-flux-tps-',    ...
        num2str(quarterArray(1), '%02d'), '-', num2str(targetTableIdArray(1), '%03d'), '.fig'];
    userDataStrFit      = ['Summary plot of quarter-stitched PDC flux time series and transits for target ' num2str(keplerId) ...
        ', marked with DV fitted epoch/period (or TPS epoch/period if fit was not successful). '];
    userDataStrTps      = ['Summary plot of quarter-stitched PDC flux time series and transits for target ' num2str(keplerId) ...
        ', marked with TPS epoch/period. '];
    
    figureFilenameRaw       = [num2str(keplerId, '%09d'), '-00-raw-flux-',                   ...
        num2str(quarterArray(1), '%02d'), '-', num2str(targetTableIdArray(1), '%03d'), '.fig'];
    userDataStrRaw          = 'Summary plot of raw flux time series. ';
    
    % Set plot caption for the DV report
    if length(quarterArray)==1
        if startKjdArray(1)~=-1
            strTps = ['For the data of quarter ' num2str(quarterArray(1), '%d') ', target table ' num2str(targetTableIdArray(1), '%d') ...
                ', start JD is '  num2str(kjdOffsetFromJd+startKjdArray(1)) '.'];
            strFit = ['For the data of quarter ' num2str(quarterArray(1), '%d') ', target table ' num2str(targetTableIdArray(1), '%d') ...
                ', start BJD is ' num2str(kjdOffsetFromJd+startKjdArray(1)) '.'];
            strRaw = strTps;
        else
            strTps = '';
            strFit = '';
            strRaw = '';
        end
    else
        strTps = '';
        strFit = '';
        strRaw = '';
        for iQuarter=1:length(quarterArray)
            if startKjdArray(iQuarter)~=-1
                strTps = [strTps 'For the data of quarter ' num2str(quarterArray(iQuarter), '%d') ', target table ' num2str(targetTableIdArray(iQuarter), '%d') ...
                    ', start JD is '  num2str(kjdOffsetFromJd+startKjdArray(iQuarter)) ' and the vertical offset is ' num2str(yOffsetArray(iQuarter)) ' ppm. '];
                strFit = [strFit 'For the data of quarter ' num2str(quarterArray(iQuarter), '%d') ', target table ' num2str(targetTableIdArray(iQuarter), '%d') ...
                    ', start BJD is ' num2str(kjdOffsetFromJd+startKjdArray(iQuarter)) ' and the vertical offset is ' num2str(yOffsetArray(iQuarter)) ' ppm. '];
                strRaw = [strRaw 'For the data of quarter ' num2str(quarterArray(iQuarter), '%d') ', target table ' num2str(targetTableIdArray(iQuarter), '%d') ...
                    ', start JD is '  num2str(kjdOffsetFromJd+startKjdArray(iQuarter)) ' and the vertical offset is ' num2str(rawOffsetArray(iQuarter)) ' electrons/cadence. '];
            end
        end
    end
    set(hFig1, 'UserData', [userDataStrTps 'Transits of identified planets are labeled with epoch KJD and orbital period. '  strTps]);
    set(hFig2, 'UserData', [userDataStrFit 'Transits of identified planets are labeled with epoch BKJD and orbital period. ' strFit]);
    set(hFig3, 'UserData', [userDataStrRaw strRaw]);
    
    % Save figures to file
    saveas(hFig1, fullfile(dvFiguresRootDirectory, 'summary-plots', figureFilenameTps), 'fig');
    saveas(hFig2, fullfile(dvFiguresRootDirectory, 'summary-plots', figureFilenameFit), 'fig');
    saveas(hFig3, fullfile(dvFiguresRootDirectory, 'summary-plots', figureFilenameRaw), 'fig');
   
    % close figure
    if (debugLevel==0)
        close(hFig1);
        close(hFig2);
        close(hFig3);
    else
        drawnow;
    end

end  % for iFigure

return
