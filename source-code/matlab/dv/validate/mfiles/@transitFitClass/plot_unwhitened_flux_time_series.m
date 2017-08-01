function plotHandles = plot_unwhitened_flux_time_series( transitFitObject, targetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, ...
    fullDirectory, keplerId, iPlanet, defaultPeriod, oddEvenFilename ) 
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plotHandles = plot_unwhitened_flux_time_series( transitFitObject, targetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, ...
%    fullDirectory, keplerId, iPlanet, oddEvenFilename ) 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% Plot the unwhitened flux time series as a function of time, omitting the gapped or filled cadences.
%
% Version date:  2012-November-27.
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

% Modification Date:
%
%    2012-November-27, JL:
%       Add input argument 'defaultPeriod'
%    2012-October-3, JL:
%        Add transit event markers
%    2011-February-07, JL:
%        fix bug of cadence time indices 
%
%============================================================================================================================================

kjdOffsetFromJd = kjd_offset_from_jd;

TRANSIT_MARKER_SIZE = 6.0;
TRANSIT_MARKER_POSITION = 0.2;

% get the cadences to use

includedCadences = get_included_excluded_cadences( transitFitObject );
  
% get the fitted transit object

transitObject   = get_fitted_transit_object( transitFitObject );
cadenceTimes    = get( transitObject, 'cadenceTimes' );
flux            = targetFluxTimeSeries.values;

transitEpoch    = transitFitObject.finalParValues(transitFitObject.parameterMapStruct(1).transitEpochBkjd);
periodIndex     = transitFitObject.parameterMapStruct(1).orbitalPeriodDays;
if periodIndex ~= 0
    orbitalPeriod  = transitFitObject.finalParValues(periodIndex);
else
    orbitalPeriod  = defaultPeriod;
end

dataRange       = range(flux(includedCadences));
dataSteps       = [0.00006 0.00012 0.00030 0.0006 0.0012 0.0030 0.006 0.012 0.030 0.06 0.12 0.30 0.6];
offsetSteps     = [0.00010 0.00020 0.00050 0.0010 0.0020 0.0050 0.010 0.020 0.050 0.10 0.20 0.50 1.0 2.0];
dataOffset      = offsetSteps(sum(dataRange>dataSteps)+1);
  
nDataSetsPerFigure  = 4;
nTargetTables       = length(targetTableDataStruct);
nFigures            = ceil(nTargetTables/nDataSetsPerFigure);

colorValueArray = [ 1  0   0         % red
                    0  1   0         % green
                    0  1   1         % cyan
                    1  0.7 0         % orange
                    1  0   1  ];     % magenta

for iFigure = 1:nFigures
    
    hFig       = figure;     
           
    hVector    = [];
    strArray   = {};
    lineCount  = 0;
    
    quarterArray        = [];
    targetTableIdArray  = [];
    yOffsetArray        = [];
    startKjdArray       = [];
    
    for iDataSet = 1:nDataSetsPerFigure
        
        iTargetTable = (iFigure-1)*nDataSetsPerFigure + iDataSet;
        
        if iTargetTable <= nTargetTables
            
            % Determine start time offset, end KJD and end barycentric corrected KJD
            
            indexDataSet            = (cadenceNumbers >= targetTableDataStruct(iTargetTable).startCadence) & ...
                                      (cadenceNumbers <= targetTableDataStruct(iTargetTable).endCadence  );

            includedCadencesDataSet = includedCadences & indexDataSet;
            cadenceTimesDataSet     = cadenceTimes;
            fluxDataSet             = flux;
            
            cadenceTimesBuf         = cadenceTimesDataSet(indexDataSet);

            cadenceTimesDataSet(~includedCadencesDataSet) = NaN;
            fluxDataSet(~includedCadencesDataSet)         = NaN;
            
            
            quarter                 = targetTableDataStruct(iTargetTable).quarter;
            targetTableId           = targetTableDataStruct(iTargetTable).targetTableId;
            yOffset                 = (iDataSet-1)*dataOffset;
                
            quarterArray            = [quarterArray;        quarter      ];
            targetTableIdArray      = [targetTableIdArray;  targetTableId];
            yOffsetArray            = [yOffsetArray;        yOffset      ];

            if ~isempty(cadenceTimesBuf)
                
                startKjd            = floor(cadenceTimesBuf(1));
                endKjd              = ceil(cadenceTimesBuf(end));
                startKjdArray       = [startKjdArray;       startKjd     ];
                
                startTransitIndex   = ceil(  (startKjd - transitEpoch)/orbitalPeriod );
                endTransitIndex     = floor( (endKjd   - transitEpoch)/orbitalPeriod );
                transitIndices      = [startTransitIndex:endTransitIndex];
                
                if ~isempty(fluxDataSet) && ~all(isnan(fluxDataSet))
                    
                    hold on;
                    
                    colorValue = colorValueArray(mod(iDataSet-1, size(colorValueArray,1))+1, :);
                    hLine = plot(cadenceTimesDataSet-startKjd, fluxDataSet+yOffset, '.-', 'lineWidth', 2, 'color', colorValue);
                    
                    plot(transitEpoch+transitIndices*orbitalPeriod-startKjd, (TRANSIT_MARKER_POSITION*dataOffset+yOffset)*ones(size(transitIndices)), 'v', ...
                        'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black', 'MarkerSize', TRANSIT_MARKER_SIZE );
                    
                    lineCount = lineCount + 1;
                    hVector(lineCount)  = hLine;
                    strArray{lineCount} = ['Q-' num2str(quarter, '%02d') '/TT-' num2str(targetTableId, '%03d')];
                    
                    hold off;
                    
                end     %  if ~isempty(fluxDataSet)
                
            else
                
                startKjdArray       = [startKjdArray;  -1];
                
            end     %  if ~isempty(cadenceTimesBuf)
            
        end  % if iTargetTable <= nTargetTables
        
    end  % for iDataSet
    
    titleString = ['Planet ', num2str(iPlanet), ' : Unwhitened Unfolded PDC Flux Time Series'];
    title( titleString );
    xlabel('Elapsed BJD Since Start of Each Quarter');
    ylabel('Relative Flux');
    if length(yOffsetArray)>1
        set(gca, 'YTick', yOffsetArray);
    end
            
    if ~isempty(hVector) && (numel(hVector) == numel(strArray))
        hLegend = legend(hVector, strArray, 'Location','EastOutSide');
        set(hLegend, 'FontSize', 10);
    end
    
    strCaption = '';
    if length(quarterArray)==1
        if startKjdArray(1)~=-1
            strCaption = ['For the data of Quarter-' num2str(quarterArray(1), '%02d') '/TargetTableId-' num2str(targetTableIdArray(1), '%03d') ...
                ', start BJD is '  num2str(kjdOffsetFromJd+startKjdArray(1)) '.'];
        end
    else
        strCaption = '';
        for iQuarter=1:length(quarterArray)
            if startKjdArray(iQuarter)~=-1
                strCaption = [strCaption 'For the data of Quarter-' num2str(quarterArray(iQuarter), '%02d') '/TargetTableId-' num2str(targetTableIdArray(iQuarter), '%03d') ...
                    ', start BJD is ' num2str(kjdOffsetFromJd+startKjdArray(iQuarter)) ' and the vertical offset is ' num2str(yOffsetArray(iQuarter)) '. '];
            end
        end
    end
    set( hFig, 'UserData', ['PDC Flux time series for KeplerId ', num2str(keplerId), ', Planet candidate ', num2str(iPlanet),' in the unwhitened domain. ' strCaption ...
        ' Transit event markers indicate the location of transits of the given planet candidate. '] );
   
    format_graphics_for_dv_report( hFig );
    if ~isempty(yOffsetArray)
        set(gca, 'yLim', [yOffsetArray(1)-dataOffset yOffsetArray(end)+dataOffset]);
    end
    
    filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), oddEvenFilename,'unwhitened-', num2str(quarterArray(1), '%02d'), '-', num2str(targetTableIdArray(1), '%03d'),'.fig'];

    saveas( hFig, fullfile( fullDirectory, filename ) ) ;  
        
    plotHandles(iFigure,1) = hFig;
  
end     % for iFigure

return

% and that's it!

%
%
%
