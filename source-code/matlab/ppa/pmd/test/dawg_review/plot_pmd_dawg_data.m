function [outDir] = plot_pmd_dawg_data(pmdStructFile)
% function [outDir] = plot_pmd_dawg_data(pmdStructFile)
%
% This program plots the PMD time series of all module/outputs, creating
% png files for use in the LaTeX DAWG script. It should be run after
% retrieve_pmd_data_for_dawg.m. 
%
% Inputs:
%   pmdStructFile: full path file name to the PMD I/O struct file created
%       by retrieve_pmd_data_for_dawg.m
% Outputs:
%   outDir: directory where figures are put
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

% Retrieve PMD input and output structures of all module/outputs
load(pmdStructFile)

nChannels = length(pmdInputStructs);

% Define which PMD time series are plotted 
% these flags can be adjusted to create more or fewer figures, those needed
% by the LaTeX script are indicated
plottingPmdMetrics        = true;  % required for LaTeX DAWG script
plottingDerivedPmdMetrics = true;  % required for LaTeX DAWG script
plottingCosmicRayMetrics  = false;
plottingCdppMetrics       = true;  % required for LaTeX DAWG script

% Define color for each channel
channelList = 1:nChannels;
if nChannels==80 % mod 3 is dead!
    channelLabels = [1:4,9:84];
elseif nChannels==76 % mod 7 is dead too!
    channelLabels = [1:4,9:16,21:84];
else
    channelLabels = channelList;
end

colorSpec   = color_specification(nChannels);

mjds             = pmdInputStructs(1).cadenceTimes.midTimestamps;
mjdGapIndicators = pmdInputStructs(1).cadenceTimes.gapIndicators;
% mjdOffset        = datestr2mjd('01-Jan-2009 00:00:00');           % MJD offset for the plots
mjdOffset        = 55000;           % MJD offset for the plots

% I. Plot PMD metrics
compAxis=[];

if ( plottingPmdMetrics )
    
    metricsStr = {  'blackLevel',                           ...
                    'smearLevel',                           ...
                    'darkCurrent',                          ...
                    'brightness',                           ...
                    'encircledEnergy',                      ...
                    'achievedCompressionEfficiency',        ...
                    'theoreticalCompressionEfficiency',     ...
                    'ldeUndershoot' };

    ylabelStr = {   'ADU/read',                             ...
                    'photoelectron/cadence',                ...
                    'photoelectron/second',                 ...
                    'dimensionless',                        ...
                    'pixel',                                ...
                    'bit/pixel/cadence',                    ...
                    'bit/pixel/cadence',                    ...
                    'percent' };
                        
    for metricId = 1:length(metricsStr)

        hf=figure;

        hold on
        for i=1:nChannels
            
            channel       = channelList(i);
            channelLabeli = channelLabels(i);
            if ~isempty(pmdInputStructs(channel).inputTsData.(metricsStr{metricId})) % some metrics may be empty in K2
                values        = pmdInputStructs(channel).inputTsData.(metricsStr{metricId}).values;
                gapIndicators = mjdGapIndicators | pmdInputStructs(channel).inputTsData.(metricsStr{metricId}).gapIndicators;
                cleanedIndex  = find(~gapIndicators);
                if ( ~isempty(cleanedIndex) )
                    hp = plot(mjds(cleanedIndex)-mjdOffset, values(cleanedIndex)-values(cleanedIndex(1))*0, '.-', 'color', colorSpec(i,:), 'LineWidth', 1);
                    text(mjds(end)-mjdOffset+0.5, values(cleanedIndex(end))-values(cleanedIndex(1))*0, num2str(channelLabeli), 'color', colorSpec(i,:));
                    if strncmp(metricsStr{metricId},'achieved',8)  % look for achievedCompression metric to set scale
                        compAxis = axis;
                    end
                    if strncmp(metricsStr{metricId},'theoretical',8) & ~isempty(compAxis)
                        axis(compAxis);
                    end
                    
                end
            end
            
        end
        hold off;
        grid;
    
        XLim = get(gca, 'XLim');
        set(gca, 'XLim', [XLim(1) XLim(2)+1],'fontSize',12);
        
        title(['metric: ' metricsStr{metricId}], 'fontSize', 12);
        xlabel(['Elapsed MJDs (offset: ' num2str(mjdOffset) ')'],'fontSize',12);
        ylabel(ylabelStr{metricId}, 'fontSize', 12);

        % print png version of the figure
        print( hf, '-dpng', metricsStr{metricId});
    end

end


% II. Plot derived PMD mterics 

if ( plottingDerivedPmdMetrics ) 

    derivedMetricsStr = {   'backgroundLevel',                  ...
                            'centroidsMeanRow',                 ...
                            'centroidsMeanColumn',              ...
                            'plateScale' };                       
                        
    ylabelStr         = {   'photoelectron/cadence',            ...
                            'pixel',                            ...
                            'pixel',                            ...
                            'dimensionless' };
                        
    for metricId = 1:length(derivedMetricsStr)

        hf=figure;
        
        hold on;
        for i=1:nChannels
        
            channel = channelList(i);
            channelLabeli = channelLabels(i);
            values        = pmdOutputStructs(channel).outputTsData.(derivedMetricsStr{metricId}).values;
            gapIndicators = mjdGapIndicators | pmdOutputStructs(channel).outputTsData.(derivedMetricsStr{metricId}).gapIndicators;
            cleanedIndex  = find(~gapIndicators);
            if ( ~isempty(cleanedIndex) )
                plot(mjds(cleanedIndex)-mjdOffset, values(cleanedIndex)-values(cleanedIndex(1))*0, '.-', 'color', colorSpec(i,:), 'LineWidth', 1);
                text(mjds(end)-mjdOffset+0.5, values(cleanedIndex(end))-values(cleanedIndex(1))*0, num2str(channelLabeli), 'color', colorSpec(i,:));
            end
        end
        hold off;
        grid;
    
        XLim = get(gca, 'XLim');
        set(gca, 'XLim', [XLim(1) XLim(2)+1],'fontSize',12);
        
        title(['metric: ' derivedMetricsStr{metricId}], 'fontSize', 12);
        xlabel(['Elapsed MJDs (offset: ' num2str(mjdOffset) ')'],'fontSize',12);
        ylabel(ylabelStr{metricId}, 'fontSize', 12);
        
        % print png version of the figure
        print( hf, '-dpng', derivedMetricsStr{metricId});
    end

end

% III. Plot cosmic ray metrics

if ( plottingCosmicRayMetrics )
    
    crStr      = {  'blackCosmicRayMetrics',            ...
                    'maskedSmearCosmicRayMetrics',      ...
                    'virtualSmearCosmicRayMetrics',     ...
                    'targetStarCosmicRayMetrics',       ...
                    'backgroundCosmicRayMetrics'    };
          
    crFieldStr = {  'hitRate',                          ...
                    'meanEnergy',                       ...
                    'energyVariance',                   ...
                    'energySkewness',                   ...
                    'energyKurtosis'                };

    ylabelStr  = {  'numberOfEvents/cm^2/second',       ...
                    'photoelectron',                    ...
                    'photoelectron^2',                  ...
                    'dimensionless',                    ...
                    'dimensionless'                 };
                    
    for crId = 1:length(crStr)
        
        for crFieldId = 1:length(crFieldStr)
        
            hf=figure;
            
            hold on
            for i=1:nChannels
                
                channel = channelList(i);
                channelLabeli = channelLabels(i);
                values        = pmdInputStructs(channel).inputTsData.(crStr{crId}).(crFieldStr{crFieldId}).values;
                gapIndicators = mjdGapIndicators | pmdInputStructs(channel).inputTsData.(crStr{crId}).(crFieldStr{crFieldId}).gapIndicators;
                cleanedIndex  = find(~gapIndicators);
                if ( ~isempty(cleanedIndex) )
                    plot(mjds(cleanedIndex)-mjdOffset, values(cleanedIndex), '.-', 'color', colorSpec(i,:), 'LineWidth', 1);
                    text(mjds(end)-mjdOffset+0.5, values(cleanedIndex(end)), num2str(channelLabeli), 'color', colorSpec(i,:));
                end
        
            end
            hold off;
            grid;
            
            XLim = get(gca, 'XLim');
            set(gca, 'XLim', [XLim(1) XLim(2)+1],'fontSize',12);

            title(['metric: ' crStr{crId} '.' crFieldStr{crFieldId}], 'fontSize',12);
            xlabel(['Elapsed MJDs (offset: ' num2str(mjdOffset) ')'],'fontSize',12);
            ylabel(ylabelStr{crFieldId}, 'fontSize', 12);

        % print png version of the figure
        print( hf, '-dpng', [crStr{crId} '_' crFieldStr{crFieldId}]);

        end

    end

end



% IV. Plot CDPP metrics

if ( plottingCdppMetrics )
    
    cdppStr = {     'cdppMeasured',     ...
                    'cdppExpected',     ...
                    'cdppRatio'     };

    magStr  = {     'mag9',             ...
                    'mag10',            ...
                    'mag11',            ...
                    'mag12',            ...
                    'mag13',            ...
                    'mag14',            ...
                    'mag15'         };
          
    hourStr = {     'threeHour',        ...
                    'sixHour',          ...
                    'twelveHour'    };
                
    ylabelStr = {   'ppm',              ...
                    'ppm',              ...
                    'dimensionless' };

    for magId = 1:length(magStr)
    
        for hourId = 1:length(hourStr)
        
            for cdppId = 1:length(cdppStr)
        
                hf=figure;
            
                hold on;
                for i=1:nChannels

                    channel = channelList(i);
                    channelLabeli = channelLabels(i);
                    values        = pmdOutputStructs(channel).outputTsData.(cdppStr{cdppId}).(magStr{magId}).(hourStr{hourId}).values;
                    gapIndicators = mjdGapIndicators | pmdOutputStructs(channel).outputTsData.(cdppStr{cdppId}).(magStr{magId}).(hourStr{hourId}).gapIndicators;
                    cleanedIndex  = find(~gapIndicators);
                    if ( ~isempty(cleanedIndex) )
                        plot(mjds(cleanedIndex)-mjdOffset, values(cleanedIndex), '.-', 'color', colorSpec(i,:), 'LineWidth', 1);
                        text(mjds(end)-mjdOffset+0.5, values(cleanedIndex(end)), num2str(channelLabeli), 'color', colorSpec(i,:));
                    end
    
                end
                hold off;
                grid;
            
                XLim = get(gca, 'XLim');
                set(gca, 'XLim', [XLim(1) XLim(2)+1],'fontSize',12);

                title(['metric: ' cdppStr{cdppId} '.' magStr{magId} '.' hourStr{hourId}]);
                xlabel(['Elapsed MJDs (offset: ' num2str(mjdOffset) ')'],'fontSize',12);
                ylabel(ylabelStr{cdppId}, 'fontSize', 12);

                % print png version of the figure
                print( hf, '-dpng', [cdppStr{cdppId} '_' magStr{magId} '_' hourStr{hourId}]);

            end
        
        end
    
    end
        
end
outDir = pwd;



