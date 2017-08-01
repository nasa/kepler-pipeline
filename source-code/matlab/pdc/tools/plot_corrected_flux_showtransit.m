%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%function [figureHandles] = plot_corrected_flux_showtransit(pdcInputsStruct, pdcOutputsStruct, ...
%    mapResultsStruct, targetList, harmonicTimeSeries, harmonicsFlag, manualPauseFlag, ...
%    saveFiguresFlag,customTitleString,KOI,outDir, figureHandles)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Plot raw and corrected flux time series for the given target list
% (indices) and transits calculated from KOI parameters (if available)
%
% mapResultsStruct can be passed as a cell array. The map fit will be plotted for each item in the array. This
% is useful for example for plotting all bands for multi-scale MAP.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%CALLED BY:
%  find_and_plot_corrected_flux_by_keplerId
%  find_and_plot_corrected_flux_by_KOI
%  examine_pdc_performance_by_skygroup
%  plot_corrected_flux_from_this_task_directory.m (wrapper to quickly use this function without needing to
%                                                   remeber all the inputs!
%
%CALLS
%  pdcToolsClass.generate_transit_pulse_train
%  pdcToolsClass.make_pdc_code_string
%  pdcToolsClass.quarter_lookup
%  pdcToolsClass.fill_MJD_gaps
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%INPUTS
%   pdcInputsStruct   -- [inputsStruct] struct from pdc-inputs-0.mat
%   pdcOutputsStruct  -- [outputsStruct] struct from pdc-outputs-0.mat
%   mapResultsStruct  -- [cell array of {mapResultsStruct}] struct from mapResultsStruct.mat
%                           Will plot MAP fit for each mapResultsStruct passed in this cell array
%   targetlist        -- [integer array] Target indices for targets to plot (NOT KeplerID). 
%                                       If does not exist or is [] then plots all targets
%   harmonicTimeSeries -- [unknown type to JCS] just use [] if you don't know either! Used to plot harmonics
%   harmonicsFlag     -- [logical] plot harmonics?
%   manualPauseFlag   -- [logical] Paues after each target is plotted?
%   saveFiguresFlag   -- [logical] Save each figure to file
%   customTitleString -- [char] Specific title for each plot and saved file name
%   KOI               -- [struct (see below)] KOI information to plot
%   outDir            -- [char] Directory to save files to (if saveFiguresFlag = true)
%   figureHandles     -- [int array] fingure handles to use for plots. If called with [] then new figures generated
%
%OUTPUTS
%   figureHandles     -- [int array (optional)] the figure handles for all plotted figure (can be passed back
%                                               in for next call to this function)
%  
%
%  KOI struct:  Optional.
%   KOI =
%
%       1x17 struct array with fields:
%           KOInum
%           KepId
%           KepMag
%           Epoch
%           Period
%           depth_ppm
%           duration_hr
%           SNR
%           taskDir
%           ccdModule
%           ccdOutput
%           targetIndex
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%OUTPUTS
%  NONE, just *.fig and *.jpg figures (if saveFiguresFlag = true)
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

function [varargout] = plot_corrected_flux_showtransit(pdcInputsStruct, pdcOutputsStruct, ...
    mapResultsStruct, targetList, harmonicTimeSeries, harmonicsFlag, manualPauseFlag, ...
    saveFiguresFlag, customTitleString, KOI, outDir, figureHandles)

targetDataStruct = pdcInputsStruct.targetDataStruct;
%collect MJD for transit calculation
MJDs = pdcToolsClass.fill_MJD_gaps(pdcInputsStruct.cadenceTimes.midTimestamps);
Quarter = pdcToolsClass.quarter_lookup(median(MJDs));
ccdModule = pdcInputsStruct.ccdModule;
ccdOutput = pdcInputsStruct.ccdOutput;

% Check which version of PDC was run. 
if (~isfield(pdcOutputsStruct, 'pdcVersion'))
    % Then this is the old school
    pdcVersion = 8.3; % Or earlier
else
    pdcVersion = pdcOutputsStruct.pdcVersion;
end

% Insubstantiate MAP results object
if (exist('mapResultsStruct', 'var') && ~isempty(mapResultsStruct))
    if (iscell(mapResultsStruct))
        mapResultsObject = cell(length(mapResultsStruct),1);
        for iStruct = 1 : length(mapResultsObject)
            % mapResultsClass has changed to decrease memory usage, but the old version is needed for old data
            if (~isfield(pdcOutputsStruct, 'pdcVersion') || pdcOutputsStruct.pdcVersion < 9.1)
                mapResultsObject{iStruct} = mapResultsClassLegacy.construct_from_struct(mapResultsStruct{iStruct});
            else
                mapResultsObject{iStruct} = mapResultsClass.construct_from_struct(mapResultsStruct{iStruct});
            end
        end
    else
        if (~exist(pdcOutputsStruct.pdcVersion) || pdcOutputsStruct.pdcVersion < 9.1)
            mapResultsObject = mapResultsClassLegacy.construct_from_struct(mapResultsStruct);
        else
            mapResultsObject = mapResultsClass.construct_from_struct(mapResultsStruct);
        end
    end
end

nTargets = length(pdcInputsStruct.targetDataStruct);
nCadences = length(pdcInputsStruct.targetDataStruct(1).values);

if ~exist('targetList', 'var') || isempty(targetList)
    targetList = 1 : nTargets;
end

if ~exist('harmonicsFlag', 'var')
    harmonicsFlag = false;
end

if harmonicsFlag && ~exist('harmonicTimeSeries', 'var')
    disp('warning: harmonic fits shown with solid green line may be scaled by fluxFractionInAperture');
end

if ~exist('manualPauseFlag', 'var')
    manualPauseFlag = false;
end

nPlots = 1;
if harmonicsFlag && ~isempty(harmonicTimeSeries)
    nPlots = nPlots + 1;
end

hPlot = 2;

% if figure handles are passed then use them
if (isempty(figureHandles))
    % Generate new figure handles
    mainFigureHandle = figure;
    if (exist ('mapResultsObject', 'var'))
        if (iscell(mapResultsObject))
            for iCell = 1 : length(mapResultsObject)
                mapFigureHandle(iCell) = figure;
            end
        else
            mapFigureHandle = figure;
        end        
        figureHandles = [mainFigureHandle mapFigureHandle];
    else
        figureHandles = [mainFigureHandle 0];
    end
else
    % Use given figure handles
    mainFigureHandle = figureHandles(1);
    mapFigureHandle  = figureHandles(2:end);
end

displayIndex = 0;
for iTarget = targetList(:)'
    displayIndex = displayIndex + 1;
    figure(mainFigureHandle);
    legendCell = [{'PDC in + cm + ffia'},{'PDC out'}];
    k = targetDataStruct(iTarget).keplerId;
    m = targetDataStruct(iTarget).keplerMag;
    g = targetDataStruct(iTarget).gapIndicators;
    ffia = targetDataStruct(iTarget).fluxFractionInAperture;
    cm = targetDataStruct(iTarget).crowdingMetric;
    isDisc = ~isempty(pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices);
    isOutlier = ~isempty(pdcOutputsStruct.targetResultsStruct(iTarget).outliers.indices);
    rvUnscaled = targetDataStruct(iTarget).values;
    rvUnscaled(g) = NaN;
    rvMedian = nanmedian(rvUnscaled);
    rv = (rvUnscaled - (1-cm)*rvMedian)/ffia;
    subplot(nPlots,1,1)
    hold off
    plot(rv, '.-b')
    hold on

    % NaN gaps in the PDC results flux if any exist
    resultsGaps = pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.gapIndicators;
    resultsFlux = pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.values;
    resultsFlux(resultsGaps) = NaN;

    plot(resultsFlux, '.-r');
    
    % Flag filled indices
    % Remember the 0-based Java sillyness
    filledIndices = false(nCadences,1);
    filledIndices(pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.filledIndices+1) = true;
    plot(find(filledIndices), resultsFlux(filledIndices), 'dk', 'MarkerSize',7);
    legendCell = [legendCell, {'Filled Indices'}];

    if isOutlier
        o = pdcOutputsStruct.targetResultsStruct(iTarget).outliers;
        x = o.indices + 1;
       %plot(x, o.values, 'ob');
        plot(x, rv(x), 'or')
       %legendCell = [legendCell, {'Outliers'}, {'Outliers'}];
        legendCell = [legendCell, {'Outliers'}];
    end
    
    if isDisc
        d = pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices + 1;
        plot(d, rv(d), 'sk', 'MarkerSize',12)
        plot(d+1, rv(d+1), 'sk', 'MarkerSize',12);
        plot(d, pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.values(d), 'sk');
        plot(d+1, pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.values(d+1), 'sk');
        legendCell = [legendCell, {'Discontinuities'}];
    end
    
    % dataProcessingStruct and mapProcessingStruct have been replaced by pdcProcessingStruct in pdcVersion 9.0.
    if (pdcVersion < 9.0)
        dataProcessingStruct = pdcOutputsStruct.targetResultsStruct(iTarget).dataProcessingStruct;
        codeString = pdcToolsClass.make_pdc_code_string(dataProcessingStruct);
    else
        codeString = [];
    end
    pdcGoodTotal =  pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.total.value;
    if (pdcVersion < 9.0)
        targetVariability = pdcOutputsStruct.targetResultsStruct(iTarget).mapProcessingStruct.targetVariability;
        priorWeight = pdcOutputsStruct.targetResultsStruct(iTarget).mapProcessingStruct.priorWeight;
    else
        targetVariability = pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.targetVariability;
        if (strcmp(pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.pdcMethod, 'multiScaleMap')) 
            % msMAP run so look at band 2 prior weight
            priorWeight = pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(2).priorWeight;
        elseif (strcmp(pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.pdcMethod, 'regularMap')) 
            priorWeight = pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).priorWeight;
        else
            display('unknown pdcMethod');
            priorWeight = 0.0;
        end
    end
    isKOI = 0;
    basicTitleString = [customTitleString ' Q' num2str(Quarter) '-' num2str(ccdModule) '.' num2str(ccdOutput) ...
        ' Tgt = ', num2str(iTarget), '; KID = ', num2str(k), '; Mag = ', num2str(m), ...
        '; proc-', codeString, ' ',...
        '; goodTtl = ', sprintf('%5.2f',pdcGoodTotal),...
        '; tgtVar = ',  sprintf('%5.2f',targetVariability),...
        '; priorWt = ',  sprintf('%5.2f',priorWeight)];
    if ~isempty(KOI)
        KOI_Index = find([KOI.KepId] == k);
        if ~isempty(KOI_Index)
            %Jason Rowe spreadsheet gives epoch in BJD - 2454900.  Convert to MJD,
            %taking care not to forget the vexing half day
            isKOI = 1;
            epoch = KOI(KOI_Index).Epoch + 54900 - 0.5;
            period = KOI(KOI_Index).Period;
            duration = KOI(KOI_Index).duration_hr;
            transitDepth = KOI(KOI_Index).depth_ppm;
            transit_pulse_train = pdcToolsClass.generate_transit_pulse_train(epoch, period, duration/24, MJDs);
            %plot scaled transit pulse train offset by a transit depth
            transitScaleFactor = (1 - transitDepth*1e-06)*nanmedian(pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.values);
            plot(transitScaleFactor*(1 + transitDepth*1e-06*transit_pulse_train),'k')
            legendCell = [legendCell,{'KOI'}];
            title([basicTitleString ...
                '; KOI = ', num2str(KOI(KOI_Index).KOInum),...
                '; dpth = ', sprintf('%5.1f',transitDepth), ...
                '; Per = ' sprintf('%5.2f',period) 'd',...
                ': Dur= ' sprintf('%5.2f',duration) ' hr'],'FontSize',10,'Interpreter','None')
        else
            title(basicTitleString,'FontSize',11)
        end
    else
        title(basicTitleString,'FontSize',11)
    end
    legend(legendCell,'Location','Best')
    xlabel('Cadence','FontSize',11)
    ylabel('Flux (e-/cadence)','FontSize',11)
    grid on

    if harmonicsFlag && exist('harmonicTimeSeries', 'var') && ~isempty(harmonicTimeSeries)
        subplot(nPlots,1,hPlot)
        hold off
        detrendUncorr = detrendcols(rv, 1, find(g));
        plot(detrendUncorr/nanmedian(rv), '.-b')
        hold on
        harmonicFreeCorrectedFlux = pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeCorrectedFluxTimeSeries.values;
        plot(harmonicFreeCorrectedFlux/nanmedian(harmonicFreeCorrectedFlux) - 1,'.-r')
        plot(harmonicTimeSeries(iTarget).values/nanmedian(harmonicFreeCorrectedFlux),'g')
        legend('unCorr - linear','harmonicFreeCorr', 'harmonics','Location','Best')
        title('Harmonics','FontSize',11)
        grid
        xlabel('Cadence')
        ylabel('df/f')
    end
    
    % Plot map results if mapResultsObject was passed
    if (exist ('mapResultsObject', 'var'))
        if (iscell(mapResultsObject))
            for iCell = 1 : length(mapResultsObject)
                if (~mapResultsObject{iCell}.mapFailed)
                    mapResultsObject{iCell}.plot_selected_targets('targetIndicesToPlot', iTarget, 'figureHandle', mapFigureHandle(iCell))
                end
            end
        else
            mapResultsObject.plot_selected_targets('targetIndicesToPlot', iTarget, 'figureHandle', mapFigureHandle)
        end
    end

    % Display goodness values and other diagnostics
    pdc_display_target_diagnostics (iTarget, pdcOutputsStruct)

    % Save figure if flag set
    if saveFiguresFlag
        outName = ['Q' num2str(Quarter) '-' num2str(ccdModule) '.' num2str(ccdOutput) ...
            '_KepID_', num2str(k)];
        if isKOI
            outName = [outName '_KOI_' num2str(KOI(KOI_Index).KOInum)];
        end
        customTitleString(isspace(customTitleString)) = '_';
        outName = [outName '_' customTitleString];
        saveas(mainFigureHandle,fullfile(outDir,[outName '.fig']))
        print(mainFigureHandle,'-djpeg','-r300',fullfile(outDir,[outName '.jpg']))
        if (exist ('mapResultsObject', 'var'))
            saveas(mapFigureHandle,fullfile(outDir,[outName '_map.fig']))
            print(mapFigureHandle,'-djpeg','-r300',fullfile(outDir,[outName '_map.jpg']))
        end
    end
    
    % Pause if flag set
    if manualPauseFlag
        disp(['Displaying results for kepler ID ', num2str(k), ', Target Index ', num2str(iTarget), ...
                '; Display Index ', num2str(displayIndex), ' of ', num2str(length(targetList))])
        pause
    else
        pause(1)
    end
    
    
end

if(nargout == 1)
    varargout = {figureHandles};
elseif(nargout > 1)
    error('plot_correct_flux_showtransit: only one optional argument valid at this time');
end

return
